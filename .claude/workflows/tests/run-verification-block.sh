#!/usr/bin/env bash
# Runs the verification block (cbk-conventions-reference.md § Verification) with two fail-loud
# rails the block cannot carry itself: an EMPTY extraction is red (the heading or the fence
# moved — a plain `bash -e` on an empty file exits 0), and an exit 0 that never printed the
# closing sentinel is red (the block ended early). The kit's CI calls this; a target project
# copies it as the body of the task its check command runs (cbk-conventions-reference.md
# § Verification › Run it). Run from anywhere inside the checkout:
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
