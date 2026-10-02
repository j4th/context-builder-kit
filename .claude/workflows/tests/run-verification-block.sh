#!/usr/bin/env bash
# Runs the verification block (cbk-conventions-reference.md § Verification) with three fail-loud
# rails the block cannot carry itself: an EMPTY extraction is red (the heading or the fence
# moved — a plain `bash -e` on an empty file exits 0); an exit 0 that never printed the
# closing sentinel is red (the block ended early); and in a filled target (docs/cbk/scaffold.md
# exists) an exit 0 that never printed the project sentinel is red (the project sub-block was
# skipped). Fixture: run-verification-block-fixture.sh, which the block itself runs. The kit's CI
# calls this; a target project copies it as the body of the task its check command depends on
# (cbk-conventions-reference.md § Verification › Run it). Run from anywhere inside the checkout:
#   bash .claude/workflows/tests/run-verification-block.sh
set -uo pipefail
here=$(cd "$(dirname "$0")" && pwd)
root=$(git -C "$here" rev-parse --show-toplevel 2>/dev/null) || { echo "run-verification-block: not inside a git checkout"; exit 1; }
cd "$root" || exit 1
tmp=$(mktemp) || exit 1
trap 'rm -f "$tmp"' EXIT
awk '/^## Verification/{p=1} p' .claude/rules/cbk-conventions-reference.md | awk '/^```bash/{c=1;next} /^```/{c=0} c' > "$tmp"
[ -s "$tmp" ] || { echo "verification: EMPTY EXTRACTION — '## Verification' or its bash fence moved in cbk-conventions-reference.md"; exit 1; }
rc=0; out=$(bash -e "$tmp" 2>&1) || rc=$?
printf '%s\n' "$out"
[ "$rc" -eq 0 ] || { echo "verification: block exited $rc"; exit "$rc"; }
grep -q '^verification: done$' <<<"$out" || { echo "verification: exit 0 WITHOUT the done sentinel — the block ended early"; exit 1; }
# A filled target also owes the project sentinel. `verification: done` prints whether or not the project
# sub-block ran, so a guard that stops firing (moved, edited, pointed at another file) would turn every
# project check off with the gate green (context-builder-kit#73). The rail keys on the same file as the
# guard, so a deleted or renamed scaffold.md makes a target look like the kit's own tree, which owes only
# the done sentinel; that case is not caught here.
if [ -f docs/cbk/scaffold.md ]; then
  grep -q '^verification: project sub-block complete$' <<<"$out" \
    || { echo "verification: a filled target's project sub-block never completed — docs/cbk/scaffold.md exists but 'verification: project sub-block complete' was not printed"; exit 1; }
fi
