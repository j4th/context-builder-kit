#!/usr/bin/env python3
"""Per-agent tokens, list-price cost, minutes and turns from a workflow run's transcripts.

Usage: python3 .claude/workflows/agent-cost.py <transcript-dir> [--json out.json]

<transcript-dir> is the directory the Workflow tool names in its result ("Transcript dir: …"); it holds one
agent-<id>.jsonl per agent. Every assistant line carries `message.usage` and `message.model`, and one API response is
written as several lines that repeat its `message.id`, so a response is read once, from its last line; cost is
attributed to the model that actually answered, not to the label the script asked for. A transcript that
mixes models is priced per model; one unpriced model leaves that agent's row unpriced, and the row is named
and excluded from the total — never folded in as zero.

Each response is billed once across the directory, at its best copy. A fork's transcript (an Agent-tool `fork`, marked
`isFork` in the agent-<id>.meta.json Claude Code writes beside it) opens with copies of its parent's lines — the same
uuids and content under the fork's own agentId, carrying the parent's final usage where the parent's own last line is
a snapshot (below) — so a fork is read after its parent, keeps only what is not yet accounted for, and a response is
billed with its stopped copy wherever one exists. Billed per file, as before v1.0.0, a parent's spend counted once more
for every fork: up to a fifth of a directory's total in the three fork-bearing session directories on the measuring
machine (Claude Code 2.1.280, 2.1.281 and 2.1.285 transcripts, read 2026-10-01). A fork of the main loop inherited the
session transcript beside the subagents directory, whose responses are excluded without a row (no transcript on the
measuring machine shows that shape yet; the fixture models it). A fork whose parent is not at hand is cut at the user
message that hands it its task: the spawning call's tool result, beside a text block that opens with
<fork-boilerplate>. A fork with neither, and every fork of it, is unpriced and named. A response with no message id is
keyed by its transcript and line, the one exception to billing once per directory; Claude Code's responses carry ids. A
row is labelled by its meta.json description where there is one — a workflow stage's label — and otherwise by its
first prompt, and is timed from its own start: a fork's after the history it copied.

A response's last line that says "stop_reason": null was written mid-stream: its input and cache counts are final, but
its output, thinking included, is a snapshot, usually under ten tokens. Through Claude Code 2.1.276 nearly every
subagent response was written again once it stopped (89–99% by version on the measuring machine; 2.1.261, 40%); from
2.1.278 most are not (6–31%), and the agent's own transcript holds no other record of the final count. A fork's copy,
where there is one, does, and bills it. A response with no stopped copy anywhere is billed as recorded and its row is
named a floor; an absent key is no evidence either way.

PRICE below is list price per MTok as of 2026-09-30 (platform.claude.com/docs/en/about-claude/pricing, the model
pricing table — quoted in .claude/rules/orchestration-reference.md § Generation notes — the sources, which the kit's
verification block diffs against PRICE). It is keyed by model version, not family, because a version can reprice its
family: Opus 5.5 is $4/$20 where Opus 5 is $5/$25, and Opus 5 stays priced for transcripts recorded before Opus 5.5.
Cache writes are 1.25x input at the 5-minute TTL and 2x at the 1-hour TTL on every model (the same page's prompt-caching
table: "1-hour cache write | 2x base input price", read 2026-10-01), split by the per-TTL breakdown in
`usage.cache_creation` where a transcript records one — Claude Code's do, and a session on the 1-hour TTL writes all of
its cache there; a write with no breakdown is priced at the 5-minute rate. Until v1.0.0 every write was priced at
1.25x, which understated a 1-hour session's writes (context-builder-kit#58 item 6). Cache reads are 0.1x input
(CACHE_READ_DEFAULT) except where CACHE_READ says otherwise: 0.05x on Opus 5.5 and 0.025x on Fable 5.1 and Mythos 5.1 —
legacy Fable 5 stays at 0.1x (the same page's cache sentence, which the block diffs against CACHE_READ). A model id no
PRICE key matches whole is unpriced and named, never guessed at; so is a message whose `usage.speed` is not
"standard" — fast mode bills at a premium (the pricing page's § Fast mode pricing; "The response `usage` object
includes a `speed` field",
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
CACHE_WRITE_5M, CACHE_WRITE_1H = 1.25, 2.0  # every model; verified 2026-10-01
# Keyed by version like PRICE. Until v1.0.0 a family key ('fable') billed legacy Fable 5 at Fable 5.1's 0.025x, and a
# second, version-keyed dict merged in beside it would silently shadow the first (context-builder-kit#69) — so there is
# one dict, and the fixture counts its definitions. The per-tier rule landed with context-builder-kit#58 item 6; the
# per-version rates are the pricing page's cache sentence, read 2026-09-30.


def tier(model):
    """The PRICE key the model id names whole: the key itself, optionally followed by a -YYYYMMDD snapshot date (the
    dated form transcripts record for Haiku 4.5, claude-haiku-4-5-20251001) and the [1m] context-window variant, which
    bills at list ("Claude 4.6 and later models ... include the full 1M token context window at standard pricing", the
    pricing page § Long context pricing, read 2026-10-01). Any other bracketed variant names a rate the table does not
    know, so it is unpriced and named. So
    `claude-opus-5-5` never prices as `claude-opus-5`, and a point release the table does not know yet
    (`claude-opus-5-6`) is unpriced and named rather than priced as its predecessor, which is the mispricing a version
    key exists to prevent. A speed-marked id (fast mode) matches no key: its rate is not list."""
    if '[speed=' in model:
        return None
    return next((key for key in PRICE if re.fullmatch(rf'{re.escape(key)}(-\d{{8}})?(\[1m\])?', model)), None)


def first_prompt(events):
    """First 90 chars of the first user message — the label a transcript with no meta.json description carries."""
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


FORK_BOUNDARY = '<fork-boilerplate>'  # opens the text block beside the tool result that hands a fork its task


def read_jsonl(path):
    """A transcript's events, and how many lines did not parse (a transcript truncated by a killed agent): counted,
    never silently dropped."""
    events, skipped = [], 0
    with open(path) as f:
        for line in f:
            try:
                events.append(json.loads(line))
            except json.JSONDecodeError:
                skipped += 1
    return events, skipped


def responses_of(events, where):
    """One entry per API response, as (model, usage, index of its last line, state). One response is written as several
    lines (one per content block), each repeating its message id and usage, the output growing as it streams: keyed by
    id, the last line stands for the response, so it is billed once. A line with no id is a response of its own, keyed by
    its transcript (`where`) and line, so it never matches a line of another transcript — the one exception to billing a
    response once per directory, which no Claude Code response has needed (each carries an id). `state` is 'stopped'
    when the last line names a stop_reason, 'snapshot' when it says "stop_reason": null (written mid-stream: the input
    and cache counts are final, the output a snapshot), and 'unknown' when the key is absent."""
    out = {}
    for n, e in enumerate(events):
        m = e.get('message') or {}
        if m.get('usage'):
            state = 'unknown' if 'stop_reason' not in m else ('snapshot' if m['stop_reason'] is None else 'stopped')
            out[m.get('id') or ('line', where, n)] = (m.get('model', '?'), m['usage'], n, state)
    return out


def best_copies(transcripts):
    """Every response's best copy across the directory: a stopped copy over any other, then the larger output. A fork's
    copy of its parent's history carries the parent's final usage where the parent's own last line is a snapshot."""
    best = {}
    for responses in transcripts:
        for k, (model, u, _, state) in responses.items():
            rank = (state == 'stopped', u.get('output_tokens', 0))
            if k not in best or rank > best[k][0]:
                best[k] = (rank, model, u, state)
    return {k: v[1:] for k, v in best.items()}


def read_meta(path):
    """agent-<id>.meta.json beside the transcript: the agent's description and type and, for a fork, `isFork`, the
    `parentAgentId` it forked from and the `toolUseId` of the call that spawned it. {} when absent or unreadable, as for
    a transcript written before Claude Code wrote one."""
    try:
        with open(path[:-len('.jsonl')] + '.meta.json') as f:
            meta = json.load(f)
    except (OSError, json.JSONDecodeError):
        return {}
    return meta if isinstance(meta, dict) else {}


def is_fork(meta):
    return meta.get('isFork') is True or meta.get('agentType') == 'fork'


def session_transcript(path):
    """The main session's transcript, which a fork of the main loop inherited: <project>/<session>.jsonl, beside the
    <project>/<session>/subagents/ directory the fork's own transcript sits in. None when it is not there."""
    d = os.path.dirname(os.path.abspath(path))
    while os.path.basename(d) not in ('subagents', ''):
        d = os.path.dirname(d)
    s = os.path.dirname(d) + '.jsonl'
    return s if os.path.basename(d) == 'subagents' and os.path.isfile(s) else None


def fork_boundary(events, meta):
    """The index of the user message that hands a fork its task: a text block opening with <fork-boilerplate> beside
    the tool result for the call that spawned the fork (meta's `toolUseId`, where there is one). A line that merely
    quotes the marker — a grep result in the inherited history — is not it. None when there is no such message."""
    tid = meta.get('toolUseId')
    for n, e in enumerate(events):
        if e.get('type') != 'user':
            continue
        content = (e.get('message') or {}).get('content')
        blocks = content if isinstance(content, list) else [{'type': 'text', 'text': content or ''}]
        blocks = [b for b in blocks if isinstance(b, dict)]
        opens = any(b.get('type') == 'text' and str(b.get('text', '')).lstrip().startswith(FORK_BOUNDARY) for b in blocks)
        answers = tid is None or any(b.get('type') == 'tool_result' and b.get('tool_use_id') == tid for b in blocks)
        if opens and answers:
            return n
    return None


def summarise(path, meta, present, billed, unseparable_forks, transcript, best):
    """One agent's row. `billed` holds every response already accounted for in this run — billed to an earlier row, or
    excluded as history no row of this directory pays for — so each is billed once, at its best copy. A fork's
    transcript opens with copies of its parent's lines, so a fork is read after its parent and keeps only what is not
    yet accounted for. A fork whose parent is not in `present` inherited either the main session (a fork of the main
    loop, whose transcript is excluded without a row; no transcript on the measuring machine shows this shape yet, so
    only the fixture models it) or an agent that is not here, and then the message that hands the fork its task marks
    where its own work starts. A fork with neither, and every fork of it, is unpriced and named, never billed for history
    it cannot separate."""
    events, skipped = transcript
    responses = responses_of(events, path)
    fork, inherited, unseparable, cut = is_fork(meta), set(), False, None
    if fork:
        parent = meta.get('parentAgentId')
        if parent in present:
            unseparable = present[parent] in unseparable_forks
        else:
            session = None if parent else session_transcript(path)
            if session:
                inherited = set(responses_of(read_jsonl(session)[0], session))
            else:
                cut = fork_boundary(events, meta)
                if cut is None:
                    unseparable = True
                else:
                    inherited = {k for k, v in responses.items() if v[2] < cut}
    if unseparable:
        unseparable_forks.add(path)
        own = dict(responses)
    else:
        own = {k: v for k, v in responses.items() if k not in billed and k not in inherited}
        billed.update({k: None for k in responses if k not in own and k not in billed})
        billed.update({k: os.path.basename(path)[6:-6] for k in own})
    # Where this agent's own work begins: a fork's after the history it copied, any other transcript's at its top.
    start = 0
    if fork and not unseparable:
        start = cut if cut is not None else max((v[2] + 1 for k, v in responses.items() if k not in own), default=0)
    per_model = {}  # model id -> token counts; priced per model, so a mixed transcript is never billed at one tier
    snapshot = 0
    for k in own:
        model, u, _, state = own[k]
        if not unseparable:
            model, u, state = best[k]  # the stopped copy, where a fork kept one
        if model == '<synthetic>' and not any(u.get(f) for f in ('input_tokens', 'output_tokens',
                                                                   'cache_creation_input_tokens', 'cache_read_input_tokens')):
            continue  # a harness-written message with zero usage: nothing to price. One that ever carried usage stays,
            # so its row is unpriced and named rather than silently undercounted
        snapshot += state == 'snapshot'
        if u.get('speed') not in (None, 'standard'):
            model = f"{model} [speed={u['speed']}]"  # fast mode bills at another rate: named as unpriced, never guessed at
        t = per_model.setdefault(model, dict(turns=0, inp=0, out=0, cw=0, cw1h=0, cr=0))
        t['turns'] += 1
        t['inp'] += u.get('input_tokens', 0)
        t['out'] += u.get('output_tokens', 0)
        t['cw'] += u.get('cache_creation_input_tokens', 0)
        t['cw1h'] += (u.get('cache_creation') or {}).get('ephemeral_1h_input_tokens', 0)  # the rest of cw is 5-minute
        t['cr'] += u.get('cache_read_input_tokens', 0)
    model = ','.join(sorted(per_model)) or '?'
    turns, inp, out, cw, cr = (sum(t[k] for t in per_model.values()) for k in ('turns', 'inp', 'out', 'cw', 'cr'))
    cost = None if not per_model or unseparable else 0.0  # no usage events, or a fork that cannot be cut: never a guess
    for name, t in per_model.items():
        k = tier(name)
        if k is None or cost is None:
            cost = None  # one unpriced model leaves the whole row unpriced rather than partially counted
            break
        pi, po = PRICE[k]
        cw5m = max(t['cw'] - t['cw1h'], 0)
        cost += (t['inp'] * pi + cw5m * pi * CACHE_WRITE_5M + t['cw1h'] * pi * CACHE_WRITE_1H
                 + t['cr'] * pi * CACHE_READ.get(k, CACHE_READ_DEFAULT) + t['out'] * po) / 1e6
    stamps = [e['timestamp'] for e in events[start:] if e.get('timestamp')]
    minutes = None
    if len(stamps) >= 2:
        minutes = round((parse_iso(max(stamps)) - parse_iso(min(stamps))).total_seconds() / 60, 1)
    label = meta.get('description') or first_prompt(events[start:])
    return dict(agent=os.path.basename(path)[6:-6], label=label, model=model, turns=turns, input=inp, cache_write=cw,
                cache_read=cr, output=out, cost_usd=cost, minutes=minutes, skipped_lines=skipped,
                inherited=0 if unseparable else len(responses) - len(own), fork=fork, unseparable=unseparable,
                snapshot=snapshot, responses=len(own))


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    d = argv[1]
    paths = sorted(glob.glob(os.path.join(d, 'agent-*.jsonl')))
    if not paths:
        print(f'no agent-*.jsonl under {d}')
        return 1
    metas = {p: read_meta(p) for p in paths}
    present = {os.path.basename(p)[6:-6]: p for p in paths}
    transcripts = {p: read_jsonl(p) for p in paths}
    best = best_copies(responses_of(transcripts[p][0], p) for p in paths)

    def depth(p, seen=()):  # a fork is read after the parent it copied, at every level
        parent = present.get(metas[p].get('parentAgentId'))
        if not is_fork(metas[p]) or parent is None or parent in seen:
            return 0 if not is_fork(metas[p]) else 1
        return 1 + depth(parent, seen + (p,))
    billed, unseparable_forks = {}, set()
    by_path = {p: summarise(p, metas[p], present, billed, unseparable_forks, transcripts[p], best)
               for p in sorted(paths, key=lambda p: (depth(p), p))}
    rows = [by_path[p] for p in paths]
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
        print(f'unpriced (model not in PRICE, a fast-mode message, no usage events, or a fork whose inherited history could not be cut off; named here and excluded from the total): {", ".join(unpriced)}')
    inherited = [f"{r['agent']} ({r['inherited']})" for r in rows if r['inherited']]
    if inherited:
        print(f'inherited responses, billed once to the transcript that recorded them first (a fork opens with its parent\'s history; a fork of the main loop, with the session\'s, which is not in this total): {", ".join(inherited)}')
    floors = [f"{r['agent']} ({r['snapshot']} of {r['responses']})" for r in rows if r['snapshot']]
    if floors:
        print(f'output is a floor, and its cost with it, where a response\'s last line is a streaming snapshot ("stop_reason": null — from Claude Code 2.1.278 a subagent\'s responses are mostly written before their final usage): {", ".join(floors)}')
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
