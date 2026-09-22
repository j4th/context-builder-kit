#!/usr/bin/env bash
# Fixture for agent-cost.py: four synthetic transcripts — one priced with cache tokens, one on a model the table
# does not know, one with no usage events and a truncated line, one mixing two priced models. Asserts the
# cache multipliers, per-model pricing of a mixed transcript, the named-and-excluded unpriced rows, the
# skipped-line count, the --json output and the exit codes.
# Run: bash .claude/workflows/tests/agent-cost-fixture.sh
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
script="$here/../agent-cost.py"
d=$(mktemp -d); e=$(mktemp -d)
trap 'rm -rf "$d" "$e"' EXIT
printf '%s\n' \
  '{"type":"user","timestamp":"2026-09-06T00:00:00Z","message":{"content":"arm one prompt"}}' \
  '{"type":"assistant","timestamp":"2026-09-06T00:01:00Z","message":{"model":"claude-opus-5","usage":{"input_tokens":1000000,"output_tokens":100000,"cache_creation_input_tokens":1000000,"cache_read_input_tokens":1000000}}}' \
  > "$d/agent-aaa.jsonl"
printf '%s\n' \
  '{"type":"user","timestamp":"2026-09-06T00:00:00Z","message":{"content":"arm two prompt"}}' \
  '{"type":"assistant","timestamp":"2026-09-06T00:02:00Z","message":{"model":"claude-future-9","usage":{"input_tokens":5,"output_tokens":5}}}' \
  > "$d/agent-bbb.jsonl"
printf '%s\n' \
  '{"type":"user","timestamp":"2026-09-06T00:00:00Z","message":{"content":"arm three prompt"}}' \
  '{"type":"assistant","timestamp":"2026-09-06T00:0' \
  > "$d/agent-ccc.jsonl"
printf '%s\n' \
  '{"type":"user","timestamp":"2026-09-06T00:00:00Z","message":{"content":"arm four prompt"}}' \
  '{"type":"assistant","timestamp":"2026-09-06T00:01:00Z","message":{"model":"claude-opus-5","usage":{"input_tokens":1000000,"output_tokens":0}}}' \
  '{"type":"assistant","timestamp":"2026-09-06T00:02:00Z","message":{"model":"claude-sonnet-5","usage":{"input_tokens":1000000,"output_tokens":0}}}' \
  > "$d/agent-ddd.jsonl"
printf '%s\n' \
  '{"type":"user","timestamp":"2026-09-06T00:00:00Z","message":{"content":"arm five prompt"}}' \
  '{"type":"assistant","timestamp":"2026-09-06T00:03:00Z","message":{"model":"claude-fable-5-1","usage":{"input_tokens":1000000,"output_tokens":0,"cache_read_input_tokens":1000000}}}' \
  > "$d/agent-eee.jsonl"
printf '%s\n' '{"type":"assistant","timestamp":"2026-09-06T00:0' > "$d/agent-fff.jsonl"
printf '%s\n' \
  '{"type":"assistant","message":{"model":"claude-haiku-4-5","usage":{"input_tokens":1000,"output_tokens":0}}}' \
  > "$d/agent-ggg.jsonl"
out=$(python3 "$script" "$d" --json "$d/out.json")
grep -qE '^aaa\b.*\b14\.25\b' <<<"$out" || { echo "expected aaa at \$14.25 (1M in @ \$5 + 1M cache write @ 1.25x + 1M cache read @ 0.1x + 100k out @ \$25); got:"; echo "$out"; exit 1; }
grep -qE '^ddd\b.*claude-opus-5,claude-sonnet-5.*\b7\.00\b' <<<"$out" || { echo "expected the mixed transcript priced per model at \$7.00 with both models named; got:"; echo "$out"; exit 1; }
grep -qE '^eee\b.*\b10\.25\b' <<<"$out" || { echo "expected eee at \$10.25 (1M in @ \$10 + 1M cache read @ 0.025x on the top tier — not \$11.00 at the 0.1x default); got:"; echo "$out"; exit 1; }
grep -q 'total list-price cost: \$31.50' <<<"$out" || { echo "expected a \$31.50 total (14.25 + 7.00 + 10.25 + 0.00 haiku); got:"; echo "$out"; exit 1; }
grep -q '4 of 7 agents priced' <<<"$out" || { echo "the priced/unpriced split is not printed (aaa, ddd, eee, ggg priced; bbb, ccc, fff not)"; echo "$out"; exit 1; }
grep -q '"agent": "bbb"' "$d/out.json" && grep -q '"cost_usd": null' "$d/out.json" || { echo "--json did not write the unpriced row with a null cost"; cat "$d/out.json"; exit 1; }
grep -q 'unpriced.*bbb, ccc, fff' <<<"$out" || { echo "the unpriced agents are not named (unknown model; no usage events)"; echo "$out"; exit 1; }
grep -q 'unparsable lines skipped.*ccc (1), fff (1)' <<<"$out" || { echo "the truncated transcript is not named with its skipped-line count"; echo "$out"; exit 1; }
grep -q '"agent": "ggg"' "$d/out.json" && grep -q '"minutes": null' "$d/out.json" || { echo "a transcript with fewer than two timestamps must report minutes as null, not crash or zero"; cat "$d/out.json"; exit 1; }
assert_exit() { local want=$1 desc=$2; shift 2; local rc=0; python3 "$script" "$@" >/dev/null 2>&1 || rc=$?; [ "$rc" -eq "$want" ] || { echo "$desc (got $rc)"; exit 1; }; }
assert_exit 2 "no arguments should exit 2"
assert_exit 1 "an empty directory should exit 1" "$e"
assert_exit 2 "--json without a path should exit 2" "$d" --json
echo "agent-cost-fixture: ok"
