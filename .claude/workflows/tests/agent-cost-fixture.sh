#!/usr/bin/env bash
# Fixture for agent-cost.py: eighteen synthetic transcripts, one case each — the set that shipped before
# context-builder-kit#69 and that issue's, unioned under distinct names. Priced: Opus 5 with cache tokens (aaa); a
# transcript mixing two priced models (ddd); Fable 5.1 at its 0.025x cache-read rate (eee); Opus 5.5 with cache tokens
# at its 0.05x rate (fff); Opus 5.5 beside a zero-usage <synthetic> message, which is skipped (ggg); a dated Haiku 4.5
# id with no timestamps, so minutes is null (jjj); Sonnet 5.5 (lll); legacy Fable 5 at the standard 0.1x, where a
# family key would bill it at Fable 5.1's 0.025x (mmm); Mythos 5.1 at 0.025x (nnn); an Opus 5.5 id with a [1m] suffix
# (ooo); an undated Haiku 4.5 id with no timestamps (qqq); one response written as two lines that share its
# message id — streaming snapshots, priced once from the last (rrr). Unpriced and named: a model the table does not know (bbb);
# no usage events and a truncated line (ccc); fast mode (hhh); a lone truncated line (iii); an unknown point release,
# never priced as its predecessor (kkk); a <synthetic> message that carries usage (ppp). Asserts the cache
# multipliers, per-model pricing of a mixed transcript, per-row facts read from the --json output (never two
# independent greps, which pass on any row carrying the value), that tier() matches a PRICE key whole whatever the
# dict order, that CACHE_READ is defined once, the skipped-line count and the exit codes. Every python3 call runs
# with -B, so no bytecode lands in the tree. Needs bash and python3.
# Run: bash .claude/workflows/tests/agent-cost-fixture.sh
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
script="$here/../agent-cost.py"
d=$(mktemp -d); e=$(mktemp -d)
trap 'rm -rf "$d" "$e"' EXIT
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
}
bad = []
for a, (cost, why) in want_cost.items():
    got = rows[a]['cost_usd']
    if got is None or abs(got - cost) > 1e-9:
        bad.append(f'{a}: cost {got!r}, want {cost} ({why})')
for a in ('bbb', 'ccc', 'hhh', 'iii', 'kkk', 'ppp'):  # unknown model; no usage; fast mode; truncated; unknown point release; <synthetic> with usage
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
grep -q 'total list-price cost: \$75.15' <<<"$out" || { echo "FAIL: expected a \$75.15 total (14.25 + 7.00 + 10.25 + 11.20 + 4.00 + 0.001 + 3.20 + 11.00 + 0.25 + 4.00 + 0.001 + 10.00); got:"; echo "$out"; exit 1; }
grep -q '12 of 18 agents priced' <<<"$out" || { echo "FAIL: the priced/unpriced split is not printed"; echo "$out"; exit 1; }
grep -q 'unpriced.*bbb, ccc, hhh, iii, kkk, ppp' <<<"$out" || { echo "FAIL: the unpriced agents are not named"; echo "$out"; exit 1; }
grep -q 'unparsable lines skipped.*ccc (1), iii (1)' <<<"$out" || { echo "FAIL: the truncated transcripts are not named with their skipped-line counts"; echo "$out"; exit 1; }
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
for unknown in ('claude-opus-5-6', 'claude-sonnet-5-5', 'claude-opus-50', 'claude-opus-5-5 [speed=fast]'):
    assert m.tier(unknown) is None, (unknown, m.tier(unknown))
EOF
# One CACHE_READ: a second definition silently shadows the first (the hazard a merge of two copies creates).
[ "$(grep -c '^CACHE_READ =' "$script")" -eq 1 ] || { echo "FAIL: agent-cost.py must define CACHE_READ exactly once"; exit 1; }
assert_exit() { local want=$1 desc=$2; shift 2; local rc=0; python3 -B "$script" "$@" >/dev/null 2>&1 || rc=$?; [ "$rc" -eq "$want" ] || { echo "FAIL: $desc (got $rc)"; exit 1; }; }
assert_exit 2 "no arguments should exit 2"
assert_exit 1 "an empty directory should exit 1" "$e"
assert_exit 2 "--json without a path should exit 2" "$d" --json
echo "agent-cost-fixture: ok"
