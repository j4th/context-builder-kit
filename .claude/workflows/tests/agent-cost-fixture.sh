#!/usr/bin/env bash
# Fixture for agent-cost.py: twenty-one synthetic transcripts, one case each — the set that shipped before
# context-builder-kit#69 and that issue's, unioned under distinct names. Priced: Opus 5 with cache tokens (aaa); a
# transcript mixing two priced models (ddd); Fable 5.1 at its 0.025x cache-read rate (eee); Opus 5.5 with cache tokens
# at its 0.05x rate (fff); Opus 5.5 beside a zero-usage <synthetic> message, which is skipped (ggg); a dated Haiku 4.5
# id with no timestamps, so minutes is null (jjj); Sonnet 5.5 (lll); legacy Fable 5 at the standard 0.1x, where a
# family key would bill it at Fable 5.1's 0.025x (mmm); Mythos 5.1 at 0.025x (nnn); an Opus 5.5 id with a [1m] suffix
# (ooo); an undated Haiku 4.5 id with no timestamps (qqq); one response written as two lines that share its
# message id — streaming snapshots, priced once from the last (rrr); Opus 5.5 cache writes split by TTL, the 5-minute half
# at 1.25x and the 1-hour half at 2x (sss); a response whose last line is a streaming snapshot ("stop_reason": null)
# beside one that stopped, so the row's output is named a floor (vvv). Unpriced and named: a model the table does not know (bbb);
# no usage events and a truncated line (ccc); fast mode (hhh); a lone truncated line (iii); an unknown point release,
# never priced as its predecessor (kkk); a <synthetic> message that carries usage (ppp); a bracketed variant other than
# [1m], whose rate the table does not know (ttt). Asserts the cache
# multipliers, per-model pricing of a mixed transcript, per-row facts read from the --json output (never two
# independent greps, which pass on any row carrying the value), that tier() matches a PRICE key whole whatever the
# dict order, that CACHE_READ is defined once, the skipped-line count and the exit codes. A second directory holds
# forks: a fork's transcript opens with its parent's history copied line for line, the parent's responses with their
# message ids and usage, so billed per file a parent's spend counted once more per fork. It asserts each response is
# billed once — to the parent, never to a fork, a fork of a fork, a fork of the main loop (whose parent is the session
# transcript beside the subagents directory) or a fork of any of those — and at its best copy, the stopped one, where
# the parent kept only a snapshot; that a fork whose parent is not at hand is cut at the message that hands it its task,
# never at an inherited line quoting the marker; that a fork with neither, and its own forks, are unpriced and named;
# that two transcripts that are not forks share a response without losing their labels or timing; and that a row is
# labelled by its meta.json description and timed from its own start. Every python3 call runs
# with -B, so no bytecode lands in the tree. Needs bash and python3.
# Run: bash .claude/workflows/tests/agent-cost-fixture.sh
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
script="$here/../agent-cost.py"
d=$(mktemp -d); e=$(mktemp -d); k=$(mktemp -d)
trap 'rm -rf "$d" "$e" "$k"' EXIT
row() {  # row <agent> <json line>… — one transcript per agent
  local a=$1; shift
  printf '%s\n' "$@" > "$d/agent-$a.jsonl"
}
u() { printf '{"type":"user","timestamp":"2026-09-30T00:00:00Z","message":{"content":"%s prompt"}}' "$1"; }
m() { printf '{"type":"assistant","timestamp":"2026-09-30T00:0%s:00Z","message":{"model":"%s","usage":%s}}' "$1" "$2" "$3"; }
mi() { printf '{"type":"assistant","timestamp":"2026-09-30T00:0%s:00Z","message":{"id":"%s","model":"%s","usage":%s}}' "$1" "$2" "$3" "$4"; }
row aaa "$(u aaa)" "$(m 1 claude-opus-5 '{"input_tokens":1000000,"output_tokens":100000,"cache_creation_input_tokens":1000000,"cache_read_input_tokens":1000000}')"
row bbb "$(u bbb)" "$(m 2 claude-future-9 '{"input_tokens":5,"output_tokens":5}')"
row ccc "$(u ccc)" '{"type":"assistant","timestamp":"2026-09-30T00:0'
row ddd "$(u ddd)" "$(m 1 claude-opus-5 '{"input_tokens":1000000,"output_tokens":0}')" "$(m 2 claude-sonnet-5 '{"input_tokens":1000000,"output_tokens":0}')"
row eee "$(u eee)" "$(m 3 claude-fable-5-1 '{"input_tokens":1000000,"output_tokens":0,"cache_read_input_tokens":1000000}')"
row fff "$(u fff)" "$(m 1 claude-opus-5-5 '{"input_tokens":1000000,"output_tokens":100000,"cache_creation_input_tokens":1000000,"cache_read_input_tokens":1000000}')"
row ggg "$(u ggg)" "$(m 1 claude-opus-5-5 '{"input_tokens":1000000,"output_tokens":0,"speed":"standard"}')" \
  "$(m 2 '<synthetic>' '{"input_tokens":0,"output_tokens":0,"cache_creation_input_tokens":0,"cache_read_input_tokens":0}')"
row hhh "$(u hhh)" "$(m 1 claude-opus-5-5 '{"input_tokens":1000000,"output_tokens":0,"speed":"fast"}')"
row iii '{"type":"assistant","timestamp":"2026-09-30T00:0'
row jjj '{"type":"assistant","message":{"model":"claude-haiku-4-5-20251001","usage":{"input_tokens":1000,"output_tokens":0}}}'
row kkk "$(u kkk)" "$(m 1 claude-opus-5-6 '{"input_tokens":1000000,"output_tokens":0}')"
row lll "$(u lll)" "$(m 1 claude-sonnet-5-5 '{"input_tokens":1000000,"output_tokens":100000,"cache_read_input_tokens":1000000}')"
row mmm "$(u mmm)" "$(m 1 claude-fable-5 '{"input_tokens":1000000,"output_tokens":0,"cache_read_input_tokens":1000000}')"
row nnn "$(u nnn)" "$(m 1 claude-mythos-5-1 '{"input_tokens":0,"output_tokens":0,"cache_read_input_tokens":1000000}')"
row ooo "$(u ooo)" "$(m 1 'claude-opus-5-5[1m]' '{"input_tokens":1000000,"output_tokens":0}')"
row ppp "$(u ppp)" "$(m 1 claude-opus-5-5 '{"input_tokens":1000000,"output_tokens":0}')" "$(m 2 '<synthetic>' '{"input_tokens":5,"output_tokens":0}')"
row qqq '{"type":"assistant","message":{"model":"claude-haiku-4-5","usage":{"input_tokens":1000,"output_tokens":0}}}'
# Claude Code writes one response as several transcript lines that repeat its message id and usage, output growing
# as it streams: summed per line, a response is billed two or three times.
row rrr "$(u rrr)" "$(mi 1 msg_r1 claude-opus-5-5 '{"input_tokens":1000000,"output_tokens":3}')" \
  "$(mi 1 msg_r1 claude-opus-5-5 '{"input_tokens":1000000,"output_tokens":100000}')" \
  "$(mi 2 msg_r2 claude-opus-5-5 '{"input_tokens":1000000,"output_tokens":0}')"
# A 1-hour cache write bills at 2x input, a 5-minute one at 1.25x; Claude Code records the split in usage.cache_creation.
row sss "$(u sss)" "$(m 1 claude-opus-5-5 '{"input_tokens":0,"output_tokens":0,"cache_creation_input_tokens":2000000,"cache_creation":{"ephemeral_5m_input_tokens":1000000,"ephemeral_1h_input_tokens":1000000}}')"
row ttt "$(u ttt)" "$(m 1 'claude-opus-5-5[2m]' '{"input_tokens":1000000,"output_tokens":0}')"
# Claude Code 2.1.278 and later write most of a subagent's responses before their final usage: the last line says
# "stop_reason": null and its output is a snapshot. The usage is billed as recorded, and the row says it is a floor.
row vvv "$(u vvv)" '{"type":"assistant","timestamp":"2026-09-30T00:01:00Z","message":{"id":"msg_v1","model":"claude-opus-5-5","stop_reason":null,"usage":{"input_tokens":1000000,"output_tokens":8}}}'   '{"type":"assistant","timestamp":"2026-09-30T00:02:00Z","message":{"id":"msg_v2","model":"claude-opus-5-5","stop_reason":"end_turn","usage":{"input_tokens":1000000,"output_tokens":0}}}'
out=$(python3 -B "$script" "$d" --json "$d/out.json")
# Per-row facts, read from the JSON by agent: two independent greps would pass on any row carrying the value.
python3 -B - "$d/out.json" <<'EOF' || { echo "$out"; exit 1; }
import json, sys
with open(sys.argv[1]) as f:
    rows = {r['agent']: r for r in json.load(f)}
want_cost = {
    'aaa': (14.25, '1M in @ $5 + 1M cache write @ 1.25x + 1M cache read @ 0.1x + 100k out @ $25'),
    'ddd': (7.00, 'a mixed transcript priced per model: 1M Opus 5 in + 1M Sonnet 5 in'),
    'eee': (10.25, 'Fable 5.1: 1M in @ $10 + 1M cache read @ 0.025x'),
    'fff': (11.20, 'Opus 5.5: 1M in @ $4 + 1M cache write @ 1.25x + 1M cache read @ 0.05x + 100k out @ $20 — never Opus 5'),
    'ggg': (4.00, 'a zero-usage <synthetic> message must not unprice its row'),
    'jjj': (0.001, 'a dated Haiku 4.5 id (claude-haiku-4-5-20251001) prices as Haiku 4.5'),
    'lll': (3.20, 'Sonnet 5.5: 1M in @ $2 + 1M cache read @ 0.1x + 100k out @ $10'),
    'mmm': (11.00, 'legacy Fable 5: 1M in @ $10 + 1M cache read @ the standard 0.1x — not 0.025x, which is Fable 5.1 only'),
    'nnn': (0.25, 'Mythos 5.1: 1M cache read @ 0.025x of $10'),
    'ooo': (4.00, 'an Opus 5.5 id with a [1m] suffix prices as Opus 5.5'),
    'qqq': (0.001, 'an undated Haiku 4.5 id prices as Haiku 4.5'),
    'rrr': (10.00, 'two responses, one written as two lines sharing its message id: 2M in @ $4 + 100k out @ $20, the last snapshot once'),
    'sss': (13.00, 'Opus 5.5 cache writes: 1M at the 5-minute 1.25x ($5) + 1M at the 1-hour 2x ($8)'),
    'vvv': (8.00016, 'two Opus 5.5 responses: 2M in @ $4 + the 8 snapshot output tokens @ $20, billed as recorded'),
}
bad = []
for a, (cost, why) in want_cost.items():
    got = rows[a]['cost_usd']
    if got is None or abs(got - cost) > 1e-9:
        bad.append(f'{a}: cost {got!r}, want {cost} ({why})')
for a in ('bbb', 'ccc', 'hhh', 'iii', 'kkk', 'ppp', 'ttt'):  # unknown model; no usage; fast mode; truncated; unknown point release; <synthetic> with usage; unknown variant
    if rows[a]['cost_usd'] is not None:
        bad.append(f'{a}: must be unpriced (null cost), got {rows[a]["cost_usd"]!r}')
for a in ('ccc', 'iii', 'jjj', 'qqq'):  # one timestamp, then none at all
    if rows[a]['minutes'] is not None:
        bad.append(f'{a}: fewer than two timestamps must report minutes null, not {rows[a]["minutes"]!r}')
if (rows['rrr']['turns'], rows['rrr']['output']) != (2, 100000):
    bad.append(f"rrr: one response is one turn, its usage the last line's: want 2 turns and 100000 output, got {rows['rrr']['turns']} and {rows['rrr']['output']}")
if (rows['vvv'].get('snapshot'), rows['aaa'].get('snapshot')) != (1, 0):
    bad.append(f"snapshot counts: vvv has one response recorded only as a snapshot, aaa none (no stop_reason key is no evidence); got {rows['vvv'].get('snapshot')} and {rows['aaa'].get('snapshot')}")
if rows['ooo']['model'] != 'claude-opus-5-5[1m]':
    bad.append(f"ooo: the model column must carry the id as recorded, got {rows['ooo']['model']!r}")
if bad:
    print('FAIL: ' + '\n  '.join(bad))
    sys.exit(1)
EOF
grep -q 'total list-price cost: \$96.15' <<<"$out" || { echo "FAIL: expected a \$96.15 total (14.25 + 7.00 + 10.25 + 11.20 + 4.00 + 0.001 + 3.20 + 11.00 + 0.25 + 4.00 + 0.001 + 10.00 + 13.00 + 8.00016); got:"; echo "$out"; exit 1; }
grep -q '14 of 21 agents priced' <<<"$out" || { echo "FAIL: the priced/unpriced split is not printed"; echo "$out"; exit 1; }
grep -q 'output is a floor.*vvv (1 of 2)' <<<"$out" || { echo "FAIL: the snapshot row is not named a floor"; echo "$out"; exit 1; }
grep -q 'unpriced.*bbb, ccc, hhh, iii, kkk, ppp, ttt' <<<"$out" || { echo "FAIL: the unpriced agents are not named"; echo "$out"; exit 1; }
grep -q 'unparsable lines skipped.*ccc (1), iii (1)' <<<"$out" || { echo "FAIL: the truncated transcripts are not named with their skipped-line counts"; echo "$out"; exit 1; }
# ── Forks. The layout is Claude Code's: <project>/<session>.jsonl beside <project>/<session>/subagents/agent-*.jsonl,
# each with an agent-<id>.meta.json. A fork's transcript opens with copies of its parent's lines — same uuids and
# content, its own agentId, and the parent's final usage where the parent recorded only a snapshot — then the user
# message that hands it its task: the tool result for the meta's toolUseId beside a text block that opens with
# <fork-boilerplate> (Claude Code 2.1.280, 2.1.281 and 2.1.285 transcripts, read 2026-10-01).
sd="$k/proj/sess1/subagents"; mkdir -p "$sd"
meta() { printf '%s\n' "$2" > "$sd/agent-$1.meta.json"; }
fk() { local a=$1; shift; printf '%s\n' "$@" > "$sd/agent-$a.jsonl"; }
r() { printf '{"type":"assistant","sessionId":"sess1","timestamp":"2026-09-30T00:0%s:00Z","message":{"id":"%s","model":"claude-opus-5-5","usage":{"input_tokens":1000000,"output_tokens":0}}}' "$1" "$2"; }
bp() { printf '{"type":"user","sessionId":"sess1","timestamp":"2026-09-30T00:0%s:00Z","message":{"role":"user","content":[{"type":"tool_result","tool_use_id":"%s","content":"Fork started — processing in background"},{"type":"text","text":"<fork-boilerplate>\\nYou are a worker fork. The transcript above is the parent history."}]}}' "$1" "$2"; }
quote() { printf '{"type":"user","sessionId":"sess1","timestamp":"2026-09-30T00:0%s:00Z","message":{"role":"user","content":[{"type":"tool_result","tool_use_id":"toolu_grep","content":"agent-cost.py: FORK_BOUNDARY = <fork-boilerplate>"}]}}' "$1"; }
P="$(u par)"
fk par "$P" "$(r 1 msg_p1)" "$(r 2 msg_p2)"
meta par '{"agentType":"pr-review-toolkit:comment-analyzer","description":"the parent reviewer","spawnDepth":1}'
fk fk1 "$P" "$(r 1 msg_p1)" "$(r 2 msg_p2)" "$(bp 5 toolu_fk1)" "$(r 7 msg_f1)"
meta fk1 '{"agentType":"fork","isFork":true,"parentAgentId":"par","toolUseId":"toolu_fk1","description":"fork one","spawnDepth":2}'
# A fork of fork one, named to sort before it: only the reader's depth order can read fork one first.
fk fa2 "$P" "$(r 1 msg_p1)" "$(r 2 msg_p2)" "$(bp 5 toolu_fk1)" "$(r 7 msg_f1)" "$(bp 8 toolu_fa2)" "$(r 9 msg_g1)"
meta fa2 '{"agentType":"fork","isFork":true,"parentAgentId":"fk1","toolUseId":"toolu_fa2","description":"a fork of fork one","spawnDepth":3}'
# A fork whose parent is not here: cut at its boundary, not at an inherited line that quotes the marker.
fk orphan "$P" "$(r 1 msg_q1)" "$(quote 2)" "$(r 3 msg_q2)" "$(bp 5 toolu_orphan)" "$(r 6 msg_o1)"
meta orphan '{"agentType":"fork","isFork":true,"parentAgentId":"gone","toolUseId":"toolu_orphan","description":"a fork whose parent is not here","spawnDepth":2}'
# The same with no toolUseId in its meta.json: the text block's opening alone marks the boundary.
fk orphan2 "$P" "$(r 1 msg_q3)" "$(quote 2)" "$(r 3 msg_q4)" "$(bp 5 toolu_any)" "$(r 6 msg_o2)"
meta orphan2 '{"agentType":"fork","isFork":true,"parentAgentId":"gone3","description":"an orphan with no toolUseId","spawnDepth":2}'
fk ochild "$P" "$(r 1 msg_q1)" "$(quote 2)" "$(r 3 msg_q2)" "$(bp 5 toolu_orphan)" "$(r 6 msg_o1)" "$(bp 7 toolu_och)" "$(r 8 msg_oc1)"
meta ochild '{"agentType":"fork","isFork":true,"parentAgentId":"orphan","toolUseId":"toolu_och","description":"a fork of the orphan","spawnDepth":3}'
fk blind "$P" "$(r 1 msg_b0)" "$(r 2 msg_b1)"
meta blind '{"agentType":"fork","isFork":true,"parentAgentId":"gone2","description":"a fork with no boundary","spawnDepth":2}'
fk bchild "$P" "$(r 1 msg_b0)" "$(r 2 msg_b1)" "$(bp 4 toolu_bc)" "$(r 5 msg_bc1)"
meta bchild '{"agentType":"fork","isFork":true,"parentAgentId":"blind","toolUseId":"toolu_bc","description":"a fork of the unseparable fork","spawnDepth":3}'
printf '%s\n' "$(u main)" "$(r 1 msg_s1)" > "$k/proj/sess1.jsonl"
fk mainfork "$(u main)" "$(r 1 msg_s1)" "$(r 4 msg_m1)"
meta mainfork '{"agentType":"fork","isFork":true,"description":"a fork of the main loop","spawnDepth":1}'
fk mchild "$(u main)" "$(r 1 msg_s1)" "$(r 4 msg_m1)" "$(bp 5 toolu_mc)" "$(r 6 msg_mc1)"
meta mchild '{"agentType":"fork","isFork":true,"parentAgentId":"mainfork","toolUseId":"toolu_mc","description":"a fork of the main-loop fork","spawnDepth":2}'
# The parent recorded its response only as a snapshot; the fork's copy carries the final usage, which bills it.
fk pb "$(u pb)" '{"type":"assistant","timestamp":"2026-09-30T00:01:00Z","message":{"id":"msg_pb1","model":"claude-opus-5-5","stop_reason":null,"usage":{"input_tokens":1000000,"output_tokens":8}}}'
meta pb '{"agentType":"general-purpose","description":"a parent with a snapshot","spawnDepth":1}'
fk pbf "$(u pb)" '{"type":"assistant","timestamp":"2026-09-30T00:01:00Z","message":{"id":"msg_pb1","model":"claude-opus-5-5","stop_reason":"tool_use","usage":{"input_tokens":1000000,"output_tokens":100000}}}' "$(bp 2 toolu_pbf)" "$(r 3 msg_pbf1)"
meta pbf '{"agentType":"fork","isFork":true,"parentAgentId":"pb","toolUseId":"toolu_pbf","description":"its fork","spawnDepth":2}'
# Two transcripts that are not forks share a response: billed once, and the second keeps its own label and timing.
fk dupa "$(u dupa)" "$(r 1 msg_da1)" "$(r 2 msg_shared)"
fk dupb "$(u dupb)" "$(r 1 msg_db1)" "$(r 3 msg_shared)"
kout=$(python3 -B "$script" "$sd" --json "$k/out.json") || { echo "FAIL: the fork directory did not read"; echo "$kout"; exit 1; }
python3 -B - "$k/out.json" <<'EOF' || { echo "$kout"; exit 1; }
import json, sys
with open(sys.argv[1]) as f:
    rows = {r['agent']: r for r in json.load(f)}
bad = []
want = {'par': (8.0, 2, 'the parent reviewer'), 'fk1': (4.0, 1, 'fork one'), 'fa2': (4.0, 1, 'a fork of fork one'),
        'orphan': (4.0, 1, 'a fork whose parent is not here'), 'ochild': (4.0, 1, 'a fork of the orphan'),
        'orphan2': (4.0, 1, 'an orphan with no toolUseId'),
        'mainfork': (4.0, 1, 'a fork of the main loop'), 'mchild': (4.0, 1, 'a fork of the main-loop fork'),
        'pb': (6.0, 1, 'a parent with a snapshot'), 'pbf': (4.0, 1, 'its fork'),
        'dupa': (8.0, 2, 'dupa prompt'), 'dupb': (4.0, 1, 'dupb prompt')}
for a, (cost, turns, label) in want.items():
    got = rows[a]
    if got['cost_usd'] is None or abs(got['cost_usd'] - cost) > 1e-9 or got['turns'] != turns:
        bad.append(f"{a}: billed {got['cost_usd']!r} over {got['turns']} turns, want {cost} over {turns} (each response billed once, at its best copy)")
    if got['label'] != label:
        bad.append(f"{a}: labelled {got['label']!r}, want {label!r}")
for a in ('blind', 'bchild'):
    if rows[a]['cost_usd'] is not None:
        bad.append(f"{a}: a fork whose inherited history cannot be cut off, or whose parent's cannot, must be unpriced, got {rows[a]['cost_usd']!r}")
if (rows['fk1']['minutes'], rows['orphan']['minutes'], rows['dupb']['minutes']) != (2.0, 1.0, 3.0):
    bad.append(f"timing: fk1 from 00:05 to 00:07 is 2.0, orphan from its boundary at 00:05 to 00:06 is 1.0, dupb (no fork) from 00:00 to 00:03 is 3.0; got {rows['fk1']['minutes']!r}, {rows['orphan']['minutes']!r}, {rows['dupb']['minutes']!r}")
if [rows[a].get('inherited') for a in ('par', 'fk1', 'fa2', 'ochild', 'mchild', 'dupb')] != [0, 2, 3, 3, 2, 1]:
    bad.append(f"inherited counts: want par 0, fk1 2, fa2 3, ochild 3, mchild 2, dupb 1; got {[rows[a].get('inherited') for a in ('par', 'fk1', 'fa2', 'ochild', 'mchild', 'dupb')]}")
if rows['pb'].get('snapshot') != 0:
    bad.append(f"pb: its snapshot has a stopped copy in its fork, so it is no floor; got snapshot {rows['pb'].get('snapshot')!r}")
if bad:
    print('FAIL: ' + '\n  '.join(bad))
    sys.exit(1)
EOF
grep -q 'total list-price cost: \$58.00 (12 of 14 agents priced)' <<<"$kout" || { echo "FAIL: the fork directory's total must bill each response once: \$58.00 over 12 of 14 agents"; echo "$kout"; exit 1; }
grep -q 'unpriced.*bchild, blind' <<<"$kout" || { echo "FAIL: the unseparable forks are not named"; echo "$kout"; exit 1; }
grep -q 'inherited' <<<"$kout" || { echo "FAIL: the summary does not say what the forks inherited"; echo "$kout"; exit 1; }
# tier() must match a PRICE key WHOLE whatever the dict order. With a family key listed first, a first-match (or
# substring) rule prices Opus 5.5 as Opus 5 and Fable 5.1 as Fable 5 — the rows above cannot see that, because PRICE
# happens to list the longer key first.
python3 -B - "$script" <<'EOF' || { echo "FAIL: tier() does not match a PRICE key whole: a longer id, or one a shorter key prefixes, was priced as that key"; exit 1; }
import importlib.util, sys
spec = importlib.util.spec_from_file_location('agent_cost', sys.argv[1])
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
m.PRICE = {'claude-opus-5': (5.0, 25.0), 'claude-opus-5-5': (4.0, 20.0), 'claude-fable-5': (10.0, 50.0), 'claude-fable-5-1': (10.0, 50.0)}
for model, key in (('claude-opus-5-5-20260922', 'claude-opus-5-5'), ('claude-opus-5', 'claude-opus-5'),
                   ('claude-opus-5-5[1m]', 'claude-opus-5-5'), ('claude-fable-5-1', 'claude-fable-5-1'),
                   ('claude-fable-5', 'claude-fable-5')):
    assert m.tier(model) == key, (model, m.tier(model), key)
for unknown in ('claude-opus-5-6', 'claude-sonnet-5-5', 'claude-opus-50', 'claude-opus-5-5 [speed=fast]', 'claude-opus-5-5[2m]'):
    assert m.tier(unknown) is None, (unknown, m.tier(unknown))
EOF
# One CACHE_READ: a second definition silently shadows the first (the hazard a merge of two copies creates).
[ "$(grep -c '^CACHE_READ =' "$script")" -eq 1 ] || { echo "FAIL: agent-cost.py must define CACHE_READ exactly once"; exit 1; }
assert_exit() { local want=$1 desc=$2; shift 2; local rc=0; python3 -B "$script" "$@" >/dev/null 2>&1 || rc=$?; [ "$rc" -eq "$want" ] || { echo "FAIL: $desc (got $rc)"; exit 1; }; }
assert_exit 2 "no arguments should exit 2"
assert_exit 1 "an empty directory should exit 1" "$e"
assert_exit 2 "--json without a path should exit 2" "$d" --json
echo "agent-cost-fixture: ok"
