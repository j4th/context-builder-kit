#!/usr/bin/env python3
"""Per-agent tokens, list-price cost, minutes and turns from a workflow run's transcripts.

Usage: python3 .claude/workflows/agent-cost.py <transcript-dir> [--json out.json]

<transcript-dir> is the directory the Workflow tool names in its result ("Transcript dir: …"); it holds one
agent-<id>.jsonl per agent. Each assistant message carries `message.usage` and `message.model`, so cost is
attributed to the model that actually answered, not to the label the script asked for. A transcript that
mixes models is priced per model; one unpriced model leaves that agent's row unpriced, and the row is named
and excluded from the total — never folded in as zero.

PRICE below is list price per MTok as of 2026-09-05 (platform.claude.com/docs/en/about-claude/models/overview
§ Compare models, Pricing row — quoted in .claude/rules/orchestration-reference.md § Generation notes — the
sources, which the kit's verification block diffs against PRICE), with cache writes at 1.25x input (5-minute TTL) and cache reads at 0.1x input. Every cache write is priced at the
5-minute rate — the per-TTL breakdown inside `cache_creation` is not read. A 1-hour cache TTL prices writes
at 2x; because the cache-write share differs by tier, that widens a write-heavy tier's ratio rather than
cancelling out (on one measured run, 2026-09-01, it moved a pooled top-tier:workhorse ratio from 3.2x to
3.6x). Re-verify the table against the models page before quoting absolute dollars.
"""
import datetime as dt
import glob
import json
import os
import sys

PRICE = {  # substring of the model id -> (input $/MTok, output $/MTok); verified 2026-09-05
    'fable': (10.0, 50.0),
    'opus': (5.0, 25.0),
    'sonnet': (2.0, 10.0),
    'haiku': (1.0, 5.0),
}


def tier(model):
    for key in PRICE:
        if key in model:
            return key
    return None


def first_prompt(events):
    """First 90 chars of the first user message — the only label the transcript itself carries."""
    for e in events:
        if e.get('type') != 'user':
            continue
        c = (e.get('message') or {}).get('content')
        text = c if isinstance(c, str) else ' '.join(x.get('text', '') for x in (c or []) if isinstance(x, dict))
        text = ' '.join(text.split())
        return text[:90]
    return '?'


def parse_iso(s):
    return dt.datetime.fromisoformat(s.replace('Z', '+00:00'))


def summarise(path):
    events = []
    skipped = 0  # unparsable lines (a transcript truncated by a killed agent) are counted, never silently dropped
    with open(path) as f:
        for line in f:
            try:
                events.append(json.loads(line))
            except json.JSONDecodeError:
                skipped += 1
    per_model = {}  # model id -> token counts; priced per model, so a mixed transcript is never billed at one tier
    stamps = []
    for e in events:
        if e.get('timestamp'):
            stamps.append(e['timestamp'])
        m = e.get('message') or {}
        u = m.get('usage')
        if not u:
            continue
        t = per_model.setdefault(m.get('model', '?'), dict(turns=0, inp=0, out=0, cw=0, cr=0))
        t['turns'] += 1
        t['inp'] += u.get('input_tokens', 0)
        t['out'] += u.get('output_tokens', 0)
        t['cw'] += u.get('cache_creation_input_tokens', 0)
        t['cr'] += u.get('cache_read_input_tokens', 0)
    model = ','.join(sorted(per_model)) or '?'
    totals = {k: sum(t[k] for t in per_model.values()) for k in ('turns', 'inp', 'out', 'cw', 'cr')}
    turns, inp, out, cw, cr = (totals[k] for k in ('turns', 'inp', 'out', 'cw', 'cr'))
    cost = None if not per_model else 0.0  # no usage events at all: unpriced and named, never a free row
    for name, t in per_model.items():
        k = tier(name)
        if k is None:
            cost = None  # one unpriced model leaves the whole row unpriced rather than partially counted
            break
        pi, po = PRICE[k]
        cost += (t['inp'] * pi + t['cw'] * pi * 1.25 + t['cr'] * pi * 0.10 + t['out'] * po) / 1e6
    minutes = None
    if len(stamps) >= 2:
        minutes = round((parse_iso(max(stamps)) - parse_iso(min(stamps))).total_seconds() / 60, 1)
    return dict(agent=os.path.basename(path)[6:-6], label=first_prompt(events), model=model, turns=turns,
                input=inp, cache_write=cw, cache_read=cr, output=out, cost_usd=cost, minutes=minutes, skipped_lines=skipped)


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    d = argv[1]
    rows = [summarise(f) for f in sorted(glob.glob(os.path.join(d, 'agent-*.jsonl')))]
    if not rows:
        print(f'no agent-*.jsonl under {d}')
        return 1
    cols = ['agent', 'label', 'model', 'turns', 'input', 'cache_write', 'cache_read', 'output', 'cost_usd', 'minutes']
    print('\t'.join(cols))
    for r in rows:
        print('\t'.join(f'{r[c]:.2f}' if isinstance(r[c], float) else str(r[c]) for c in cols))
    priced = [r for r in rows if r['cost_usd'] is not None]
    unpriced = [r['agent'] for r in rows if r['cost_usd'] is None]
    total = sum(r['cost_usd'] for r in priced)
    split = f' ({len(priced)} of {len(rows)} agents priced)' if unpriced else ''
    print(f'\nagents: {len(rows)}\ttotal list-price cost: ${total:.2f}{split}')
    if unpriced:
        print(f'unpriced (model not in PRICE or no usage events; named here and excluded from the total): {", ".join(unpriced)}')
    truncated = [f"{r['agent']} ({r['skipped_lines']})" for r in rows if r['skipped_lines']]
    if truncated:
        print(f'unparsable lines skipped (a truncated transcript undercounts its agent): {", ".join(truncated)}')
    if '--json' in argv:
        i = argv.index('--json') + 1
        if i >= len(argv):
            print('--json needs an output path')
            return 2
        outp = argv[i]
        with open(outp, 'w') as f:
            json.dump(rows, f, indent=1)
        print(f'wrote {outp}')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
