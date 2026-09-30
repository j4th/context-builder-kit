#!/usr/bin/env bash
# Fixture for the verification-block runner (run-verification-block.sh): its fail-loud rails, driven
# against synthetic blocks in throwaway checkouts. The runner is copied in at its real relative path,
# so the runner tested is the runner the gate runs, and the block runs this fixture (the block guards
# the script that runs it).
#   green: a kit tree (no docs/cbk/scaffold.md) that prints `verification: done`; a filled target that
#          prints the project sentinel and `verification: done`.
#   red:   a filled target whose project sub-block never ran (only `verification: done` printed: a guard
#          that stops firing turns every project check off with the gate green, context-builder-kit#73);
#          an empty extraction; an exit 0 without the done sentinel; a block that exits non-zero.
# Not modelled: a deleted or renamed scaffold.md. The rail keys on the same file as the block's guard, so
# such a target looks like the kit's own tree, which owes only the done sentinel.
# Needs bash, git, awk and mktemp (the runner's own set); no network, no jq.
# Run: bash .claude/workflows/tests/run-verification-block-fixture.sh
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
runner="$here/run-verification-block.sh"
[ -f "$runner" ] || { echo "run-verification-block-fixture: the runner is missing ($runner)"; exit 1; }
d=$(mktemp -d)
trap 'rm -rf "$d"' EXIT

n=0
case_() {  # case_ <name> <want exit> <filled target? yes|no> <block body, or NONE for no fence> [text the output must carry]
  local name=$1 want=$2 target=$3 body=$4 says=${5:-}
  local c="$d/c$n"; n=$((n + 1))
  git -c init.defaultBranch=main init -q "$c"
  mkdir -p "$c/.claude/workflows/tests" "$c/.claude/rules"
  cp "$runner" "$c/.claude/workflows/tests/"
  if [ "$target" = yes ]; then mkdir -p "$c/docs/cbk"; : > "$c/docs/cbk/scaffold.md"; fi
  if [ "$body" = NONE ]; then
    printf '## Verification\n\nNo fence here.\n' > "$c/.claude/rules/cbk-conventions-reference.md"
  else
    printf '## Verification\n\n```bash\n%s\n```\n' "$body" > "$c/.claude/rules/cbk-conventions-reference.md"
  fi
  local rc=0 out
  out=$(bash "$c/.claude/workflows/tests/run-verification-block.sh" 2>&1) || rc=$?
  [ "$rc" -eq "$want" ] || { echo "FAIL: $name (want exit $want, got $rc)"; printf '%s\n' "$out" | sed 's/^/  | /'; exit 1; }
  [ -z "$says" ] || grep -qF -- "$says" <<<"$out" || { echo "FAIL: $name (output lacks '$says')"; printf '%s\n' "$out" | sed 's/^/  | /'; exit 1; }
  echo "ok: $name"
}

KIT='echo "verification: kit sub-block complete"'
PROJ='if [ -f docs/cbk/scaffold.md ]; then echo "verification: project sub-block complete"; fi'
SKIPPED='if [ -f docs/cbk/scaffold-moved.md ]; then echo "verification: project sub-block complete"; fi'
DONE='echo "verification: done"'

case_ "a kit tree that prints the done sentinel passes"          0 no  "$KIT
$PROJ
$DONE"
case_ "a filled target that prints both sentinels passes"        0 yes "$KIT
$PROJ
$DONE"
case_ "a filled target whose project sub-block never ran fails"  1 yes "$KIT
$SKIPPED
$DONE" "project sub-block complete"
case_ "an empty extraction fails"                                1 no  NONE "EMPTY EXTRACTION"
case_ "an exit 0 without the done sentinel fails"                1 no  "$KIT" "WITHOUT the done sentinel"
case_ "a block that exits non-zero fails"                        1 yes "$KIT
false
$DONE" "block exited 1"

echo "run-verification-block-fixture: $n cases ok"
