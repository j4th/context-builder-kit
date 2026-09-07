#!/usr/bin/env bash
# Fixture for agent-cost.py: two synthetic transcripts — one on a priced model, one on a model the table
# does not know. Asserts per-model pricing, the named-and-excluded unpriced row, and the exit codes.
# Run: bash .claude/workflows/tests/agent-cost-fixture.sh
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
script="$here/../agent-cost.py"
d=$(mktemp -d); e=$(mktemp -d)
trap 'rm -rf "$d" "$e"' EXIT
printf '%s\n' \
  '{"type":"user","timestamp":"2026-09-06T00:00:00Z","message":{"content":"arm one prompt"}}' \
  '{"type":"assistant","timestamp":"2026-09-06T00:01:00Z","message":{"model":"claude-opus-5","usage":{"input_tokens":1000000,"output_tokens":100000,"cache_creation_input_tokens":0,"cache_read_input_tokens":0}}}' \
  > "$d/agent-aaa.jsonl"
printf '%s\n' \
  '{"type":"user","timestamp":"2026-09-06T00:00:00Z","message":{"content":"arm two prompt"}}' \
  '{"type":"assistant","timestamp":"2026-09-06T00:02:00Z","message":{"model":"claude-future-9","usage":{"input_tokens":5,"output_tokens":5}}}' \
  > "$d/agent-bbb.jsonl"
printf '%s\n' \
  '{"type":"user","timestamp":"2026-09-06T00:00:00Z","message":{"content":"arm three prompt"}}' \
  '{"type":"assistant","timestamp":"2026-09-06T00:0' \
  > "$d/agent-ccc.jsonl"
out=$(python3 "$script" "$d")
grep -q 'total list-price cost: \$7.50' <<<"$out" || { echo "expected a \$7.50 total (1,000,000 in @ \$5 + 100,000 out @ \$25); got:"; echo "$out"; exit 1; }
grep -q '1 of 3 agents priced' <<<"$out" || { echo "the priced/unpriced split is not printed"; echo "$out"; exit 1; }
grep -q 'unpriced.*bbb, ccc' <<<"$out" || { echo "the unpriced agents are not named (unknown model; no usage events)"; echo "$out"; exit 1; }
grep -q 'unparsable lines skipped.*ccc (1)' <<<"$out" || { echo "the truncated transcript is not named with its skipped-line count"; echo "$out"; exit 1; }
assert_exit() { local want=$1 desc=$2; shift 2; local rc=0; python3 "$script" "$@" >/dev/null 2>&1 || rc=$?; [ "$rc" -eq "$want" ] || { echo "$desc (got $rc)"; exit 1; }; }
assert_exit 2 "no arguments should exit 2"
assert_exit 1 "an empty directory should exit 1" "$e"
echo "agent-cost-fixture: ok"
