#!/usr/bin/env python3
"""Per-agent tokens, list-price cost, minutes and turns from a workflow run's transcripts.

Usage: python3 .claude/workflows/agent-cost.py <transcript-dir> [--json out.json]

<transcript-dir> is the directory the Workflow tool names in its result ("Transcript dir: …"); it holds one
agent-<id>.jsonl per agent. Each assistant message carries `message.usage` and `message.model`, so cost is
attributed to the model that actually answered, not to the label the script asked for. A transcript that
mixes models is priced per model; one unpriced model leaves that agent's row unpriced, and the row is named
and excluded from the total — never folded in as zero.

PRICE below is list price per MTok as of 2026-09-30 (platform.claude.com/docs/en/about-claude/pricing, the model
pricing table — quoted in .claude/rules/orchestration-reference.md § Generation notes — the sources, which the kit's
verification block diffs against PRICE). It is keyed by model version, not family, because a version can reprice its
family: Opus 5.5 is $4/$20 where Opus 5 is $5/$25, and Opus 5 stays priced for transcripts recorded before Opus 5.5.
Cache writes are 1.25x input (5-minute TTL) on every model. Cache reads are 0.1x input (CACHE_READ_DEFAULT) except
where CACHE_READ says otherwise: 0.05x on Opus 5.5 and 0.025x on Fable 5.1 and Mythos 5.1 — legacy Fable 5 stays at
0.1x (the same page's cache sentence, which the block diffs against CACHE_READ). Every cache write is priced at the
5-minute rate — the per-TTL breakdown inside `cache_creation` is not read. A 1-hour cache TTL prices writes at 2x;
because the cache-write share differs by tier, that widens a write-heavy tier's ratio rather than cancelling out (on
one measured run, 2026-09-01, it moved a pooled top-tier:workhorse ratio from 3.2x to 3.6x — both priced with the top
tier's cache reads at 0.1x, so both are upper bounds if that run's top tier was Fable 5.1, which reads cache at
0.025x; the transcripts' model ids settle it, context-builder-kit#58 item 6). A model id no PRICE key matches whole is
unpriced and named, never guessed at; so is a message whose `usage.speed` is not "standard" — fast mode bills at a
premium (the pricing page's § Fast mode pricing; "The response `usage` object includes a `speed` field",
platform.claude.com/docs/en/build-with-claude/fast-mode, read 2026-09-30). A `<synthetic>` message the harness writes
itself with zero usage is skipped rather than left to unprice its agent's row; one that carries usage is not
(observed in Claude Code transcripts, context-builder-kit#69). Re-verify the table against the pricing page before
quoting absolute dollars.
"""
import datetime as dt
import glob
import json
import os
import re
import sys

PRICE = {  # model version -> (input $/MTok, output $/MTok); verified 2026-09-30
    'claude-fable-5-1': (10.0, 50.0),
    'claude-fable-5': (10.0, 50.0),
    'claude-mythos-5-1': (10.0, 50.0),
    'claude-opus-5-5': (4.0, 20.0),
    'claude-opus-5': (5.0, 25.0),
    'claude-sonnet-5-5': (2.0, 10.0),
    'claude-sonnet-5': (2.0, 10.0),
    'claude-haiku-4-5': (1.0, 5.0),
}
CACHE_READ = {  # PRICE key -> cache-read multiplier where it is not CACHE_READ_DEFAULT; verified 2026-09-30
    'claude-fable-5-1': 0.025,
    'claude-mythos-5-1': 0.025,
    'claude-opus-5-5': 0.05,
}
CACHE_READ_DEFAULT = 0.1  # every other model, legacy Fable 5 included: the standard 0.1x
# Keyed by version like PRICE. Until v1.0.0 a family key ('fable') billed legacy Fable 5 at Fable 5.1's 0.025x, and a
# second, version-keyed dict merged in beside it would silently shadow the first (context-builder-kit#69) — so there is
# one dict, and the fixture counts its definitions. The per-tier rule landed with context-builder-kit#58 item 6; the
# per-version rates are the pricing page's cache sentence, read 2026-09-30.


def tier(model):
    """The PRICE key the model id names whole: the key itself, optionally followed by a -YYYYMMDD snapshot date (the
    dated form transcripts record for Haiku 4.5, claude-haiku-4-5-20251001) and a bracketed variant such as [1m]. So
    `claude-opus-5-5` never prices as `claude-opus-5`, and a point release the table does not know yet
    (`claude-opus-5-6`) is unpriced and named rather than priced as its predecessor, which is the mispricing a version
    key exists to prevent. A speed-marked id (fast mode) matches no key: its rate is not list."""
    if '[speed=' in model:
        return None
    return next((key for key in PRICE if re.fullmatch(rf'{re.escape(key)}(-\d{{8}})?(\[[^\]]*\])?', model)), None)


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
    # One API response is written as several lines (one per content block), each repeating its message id and usage,
    # the output growing as it streams: keyed by id, the last line stands for the response, so it is billed once. A
    # line with no id is a response of its own.
    responses = {}
    for n, e in enumerate(events):
        if e.get('timestamp'):
            stamps.append(e['timestamp'])
        m = e.get('message') or {}
        if m.get('usage'):
            responses[m.get('id') or ('line', n)] = (m.get('model', '?'), m['usage'])
    for model, u in responses.values():
        if model == '<synthetic>' and not any(u.get(f) for f in ('input_tokens', 'output_tokens',
                                                                   'cache_creation_input_tokens', 'cache_read_input_tokens')):
            continue  # a harness-written message with zero usage: nothing to price. One that ever carried usage stays,
            # so its row is unpriced and named rather than silently undercounted
        if u.get('speed') not in (None, 'standard'):
            model = f"{model} [speed={u['speed']}]"  # fast mode bills at another rate: named as unpriced, never guessed at
        t = per_model.setdefault(model, dict(turns=0, inp=0, out=0, cw=0, cr=0))
        t['turns'] += 1
        t['inp'] += u.get('input_tokens', 0)
        t['out'] += u.get('output_tokens', 0)
        t['cw'] += u.get('cache_creation_input_tokens', 0)
        t['cr'] += u.get('cache_read_input_tokens', 0)
    model = ','.join(sorted(per_model)) or '?'
    turns, inp, out, cw, cr = (sum(t[k] for t in per_model.values()) for k in ('turns', 'inp', 'out', 'cw', 'cr'))
    cost = None if not per_model else 0.0  # no usage events at all: unpriced and named, never a free row
    for name, t in per_model.items():
        k = tier(name)
        if k is None:
            cost = None  # one unpriced model leaves the whole row unpriced rather than partially counted
            break
        pi, po = PRICE[k]
        cost += (t['inp'] * pi + t['cw'] * pi * 1.25 + t['cr'] * pi * CACHE_READ.get(k, CACHE_READ_DEFAULT) + t['out'] * po) / 1e6
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
        print(f'unpriced (model not in PRICE, a fast-mode message, or no usage events; named here and excluded from the total): {", ".join(unpriced)}')
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
