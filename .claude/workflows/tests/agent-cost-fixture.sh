#!/usr/bin/env bash
# Fixture for agent-cost.py: twenty synthetic transcripts, one case each — the set that shipped before
# context-builder-kit#69 and that issue's, unioned under distinct names. Priced: Opus 5 with cache tokens (aaa); a
# transcript mixing two priced models (ddd); Fable 5.1 at its 0.025x cache-read rate (eee); Opus 5.5 with cache tokens
# at its 0.05x rate (fff); Opus 5.5 beside a zero-usage <synthetic> message, which is skipped (ggg); a dated Haiku 4.5
# id with no timestamps, so minutes is null (jjj); Sonnet 5.5 (lll); legacy Fable 5 at the standard 0.1x, where a
# family key would bill it at Fable 5.1's 0.025x (mmm); Mythos 5.1 at 0.025x (nnn); an Opus 5.5 id with a [1m] suffix
# (ooo); an undated Haiku 4.5 id with no timestamps (qqq); one response written as two lines that share its
# message id — streaming snapshots, priced once from the last (rrr); Opus 5.5 cache writes split by TTL, the 5-minute half
# at 1.25x and the 1-hour half at 2x (sss). Unpriced and named: a model the table does not know (bbb);
# no usage events and a truncated line (ccc); fast mode (hhh); a lone truncated line (iii); an unknown point release,
# never priced as its predecessor (kkk); a <synthetic> message that carries usage (ppp); a bracketed variant other than
# [1m], whose rate the table does not know (ttt). Asserts the cache
# multipliers, per-model pricing of a mixed transcript, per-row facts read from the --json output (never two
# independent greps, which pass on any row carrying the value), that tier() matches a PRICE key whole whatever the
# dict order, that CACHE_READ is defined once, the skipped-line count and the exit codes. A second directory holds
# forks: a fork's transcript opens with its parent's history copied line for line, the parent's responses with their
# message ids and usage, so billed per file a parent's spend counted once more per fork. It asserts each response is
# billed once — to the parent, never to a fork, a fork of a fork, or a fork of the main loop (whose parent is the
# session transcript beside the subagents directory) — that a fork whose parent is not at hand is cut at the boundary
# line that hands it its task, that a fork with neither is unpriced and named, and that a row is labelled by its
# meta.json description and timed from the fork's own start. Every python3 call runs
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
if rows['ooo']['model'] != 'claude-opus-5-5[1m]':
    bad.append(f"ooo: the model column must carry the id as recorded, got {rows['ooo']['model']!r}")
if bad:
    print('FAIL: ' + '\n  '.join(bad))
    sys.exit(1)
EOF
grep -q 'total list-price cost: \$88.15' <<<"$out" || { echo "FAIL: expected a \$88.15 total (14.25 + 7.00 + 10.25 + 11.20 + 4.00 + 0.001 + 3.20 + 11.00 + 0.25 + 4.00 + 0.001 + 10.00 + 13.00); got:"; echo "$out"; exit 1; }
grep -q '13 of 20 agents priced' <<<"$out" || { echo "FAIL: the priced/unpriced split is not printed"; echo "$out"; exit 1; }
grep -q 'unpriced.*bbb, ccc, hhh, iii, kkk, ppp, ttt' <<<"$out" || { echo "FAIL: the unpriced agents are not named"; echo "$out"; exit 1; }
grep -q 'unparsable lines skipped.*ccc (1), iii (1)' <<<"$out" || { echo "FAIL: the truncated transcripts are not named with their skipped-line counts"; echo "$out"; exit 1; }
# ── Forks. The layout is Claude Code's: <project>/<session>.jsonl beside <project>/<session>/subagents/agent-*.jsonl,
# each with an agent-<id>.meta.json. Inherited lines are byte copies of the parent's; the fork's own work starts after
# the tool result that opens with <fork-boilerplate> (Claude Code 2.1.287 transcripts, 2026-10-01).
sd="$k/proj/sess1/subagents"; mkdir -p "$sd"
meta() { printf '%s\n' "$2" > "$sd/agent-$1.meta.json"; }
fk() { local a=$1; shift; printf '%s\n' "$@" > "$sd/agent-$a.jsonl"; }
r() { printf '{"type":"assistant","sessionId":"sess1","timestamp":"2026-09-30T00:0%s:00Z","message":{"id":"%s","model":"claude-opus-5-5","usage":{"input_tokens":1000000,"output_tokens":0}}}' "$1" "$2"; }
bp() { printf '{"type":"user","sessionId":"sess1","timestamp":"2026-09-30T00:0%s:00Z","message":{"role":"user","content":[{"type":"tool_result","content":"<fork-boilerplate> You are a worker fork. The transcript above is the parent history."}]}}' "$1"; }
P="$(u par)"
fk par "$P" "$(r 1 msg_p1)" "$(r 2 msg_p2)"
meta par '{"agentType":"pr-review-toolkit:comment-analyzer","description":"the parent reviewer","spawnDepth":1}'
fk fk1 "$P" "$(r 1 msg_p1)" "$(r 2 msg_p2)" "$(bp 5)" "$(r 7 msg_f1)"
meta fk1 '{"agentType":"fork","isFork":true,"parentAgentId":"par","description":"fork one","spawnDepth":2}'
fk fk2 "$P" "$(r 1 msg_p1)" "$(r 2 msg_p2)" "$(bp 5)" "$(r 7 msg_f1)" "$(bp 8)" "$(r 9 msg_g1)"
meta fk2 '{"agentType":"fork","isFork":true,"parentAgentId":"fk1","description":"a fork of fork one","spawnDepth":3}'
fk orphan "$P" "$(r 1 msg_q1)" "$(bp 5)" "$(r 6 msg_o1)"
meta orphan '{"agentType":"fork","isFork":true,"parentAgentId":"gone","description":"a fork whose parent is not here","spawnDepth":2}'
fk blind "$P" "$(r 1 msg_b0)" "$(r 2 msg_b1)"
meta blind '{"agentType":"fork","isFork":true,"parentAgentId":"gone2","description":"a fork with no boundary","spawnDepth":2}'
printf '%s\n' "$(u main)" "$(r 1 msg_s1)" > "$k/proj/sess1.jsonl"
fk mainfork "$(u main)" "$(r 1 msg_s1)" "$(r 4 msg_m1)"
meta mainfork '{"agentType":"fork","isFork":true,"description":"a fork of the main loop","spawnDepth":1}'
kout=$(python3 -B "$script" "$sd" --json "$k/out.json") || { echo "FAIL: the fork directory did not read"; echo "$kout"; exit 1; }
python3 -B - "$k/out.json" <<'EOF' || { echo "$kout"; exit 1; }
import json, sys
with open(sys.argv[1]) as f:
    rows = {r['agent']: r for r in json.load(f)}
bad = []
want = {'par': (8.0, 2, 'the parent reviewer'), 'fk1': (4.0, 1, 'fork one'), 'fk2': (4.0, 1, 'a fork of fork one'),
        'orphan': (4.0, 1, 'a fork whose parent is not here'), 'mainfork': (4.0, 1, 'a fork of the main loop')}
for a, (cost, turns, label) in want.items():
    got = rows[a]
    if got['cost_usd'] is None or abs(got['cost_usd'] - cost) > 1e-9 or got['turns'] != turns:
        bad.append(f"{a}: billed {got['cost_usd']!r} over {got['turns']} turns, want {cost} over {turns} (each response billed once)")
    if got['label'] != label:
        bad.append(f"{a}: labelled {got['label']!r}, want the meta.json description {label!r}")
if rows['blind']['cost_usd'] is not None:
    bad.append(f"blind: a fork with neither its parent nor a boundary must be unpriced, got {rows['blind']['cost_usd']!r}")
if rows['fk1']['minutes'] != 2.0:
    bad.append(f"fk1: timed from its own start (00:05) to its last line (00:07) is 2.0 minutes, got {rows['fk1']['minutes']!r}")
if (rows['fk1'].get('inherited'), rows['fk2'].get('inherited'), rows['par'].get('inherited')) != (2, 3, 0):
    bad.append(f"inherited counts: want fk1 2, fk2 3, par 0; got {rows['fk1'].get('inherited')}, {rows['fk2'].get('inherited')}, {rows['par'].get('inherited')}")
if bad:
    print('FAIL: ' + '\n  '.join(bad))
    sys.exit(1)
EOF
grep -q 'total list-price cost: \$24.00 (5 of 6 agents priced)' <<<"$kout" || { echo "FAIL: the fork directory's total must bill each response once: \$24.00 over 5 of 6 agents"; echo "$kout"; exit 1; }
grep -q 'unpriced.*blind' <<<"$kout" || { echo "FAIL: the unseparable fork is not named"; echo "$kout"; exit 1; }
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
