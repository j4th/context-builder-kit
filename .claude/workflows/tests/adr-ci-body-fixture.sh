#!/usr/bin/env bash
# Fixture for .github/workflows/adr-immutability-check.yml: runs the job's own `run:` body — extracted from the
# workflow by extract-run-block.sh, never a copy — against a throwaway repository, one head commit per case off a
# shared base (context-builder-kit#60, context-builder-kit#61).
#   exit 1 — an existing numbered ADR modified (an ASCII, a non-ASCII and a spaced name), deleted, renamed, or
#            given a mode change; a base SHA git cannot read; two commits with no merge base. A git error is
#            never "no ADR changed".
#   exit 0 — a new ADR; an edit to README.md or corrections.md; a nested docs/adr/sub/0005-x.md (not a numbered
#            ADR); an edit to docs/adr/0009-notes/x.md, a file in a directory named like an ADR, which only the
#            `:(glob)` pathspec leaves out (a plain pathspec's `*` matches across `/`); and a branch that touches no ADR while the base branch gained one after the branch point (the
#            diff runs from the merge base, so the newer ADR is not read as deleted).
# The awk body this replaced read a name git prints quoted (non-ASCII) and a name awk splits (spaced) as "no ADR
# changed". Needs bash, git and awk; runs under mktemp, never in the checkout. Run by the verification block; also:
#   bash .claude/workflows/tests/adr-ci-body-fixture.sh
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../../.." && pwd)
# shellcheck source=extract-run-block.sh
. "$here/extract-run-block.sh"
body=$(extract_run_block "$root/.github/workflows/adr-immutability-check.yml" "Detect modified or deleted ADR files")
[ -n "$body" ] || { echo "FAIL: adr-immutability-check.yml has no 'Detect modified or deleted ADR files' step with a run: body"; exit 1; }
command -v git >/dev/null || { echo "adr-ci-body-fixture: needs git"; exit 1; }
t=$(mktemp -d)
trap 'rm -rf "$t"' EXIT
printf '%s\n' "$body" > "$t/step.sh"
repo="$t/repo"
git -c init.defaultBranch=main init -q "$repo"
g() { git -C "$repo" -c user.email=f@x -c user.name=f -c commit.gpgsign=false "$@"; }
mkdir -p "$repo/docs/adr"
for f in 0001-plain.md "0002-café.md" "0003-two words.md" 0004-delete.md 0005-rename.md 0006-mode.md README.md corrections.md; do
  printf '# %s\n' "$f" > "$repo/docs/adr/$f"
done
mkdir -p "$repo/docs/adr/0009-notes"; printf '# notes\n' > "$repo/docs/adr/0009-notes/x.md"
g add -A; g commit -q -m base
base=$(g rev-parse HEAD)

n=0
step() {  # step <want-exit> <description> <base sha> <head sha> — runs the job body as CI does
  local rc=0
  (cd "$repo" && env BASE_SHA="$3" HEAD_SHA="$4" bash "$t/step.sh") > "$t/out" 2>&1 || rc=$?
  n=$((n + 1))
  [ "$rc" -eq "$1" ] || { echo "FAIL: $2 (want exit $1, got $rc)"; sed 's/^/  | /' "$t/out"; exit 1; }
}
case_() {  # case_ <want-exit> <description> <mutation…> — applied on a fresh detached head off the base
  local want=$1 desc=$2; shift 2
  g checkout -q --detach "$base"
  (cd "$repo" && eval "$*")
  g add -A; g commit -q -m "$desc"
  step "$want" "$desc" "$base" "$(g rev-parse HEAD)"
}
case_ 1 "modify an ASCII-named ADR"    "printf 'x\n' >> docs/adr/0001-plain.md"
case_ 1 "modify a non-ASCII-named ADR" "printf 'x\n' >> 'docs/adr/0002-café.md'"
case_ 1 "modify a spaced-name ADR"     "printf 'x\n' >> 'docs/adr/0003-two words.md'"
case_ 1 "delete an ADR"                "git rm -q docs/adr/0004-delete.md"
case_ 1 "rename an ADR"                "git mv docs/adr/0005-rename.md docs/adr/0005-renamed.md"
case_ 1 "change an ADR's mode"         "chmod +x docs/adr/0006-mode.md"
case_ 0 "add a new ADR"                "printf '# new\n' > docs/adr/0007-new.md"
case_ 0 "edit the README index"        "printf 'x\n' >> docs/adr/README.md"
case_ 0 "append to the corrections register" "printf 'x\n' >> docs/adr/corrections.md"
case_ 0 "add a nested non-ADR file"    "mkdir -p docs/adr/sub && printf 'x\n' > docs/adr/sub/0005-x.md"
case_ 0 "edit a file in a directory named like an ADR" "printf 'x\n' >> docs/adr/0009-notes/x.md"

# The base branch moved on: an ADR merged there after this branch was cut is not this PR's deletion.
g checkout -q --detach "$base"; printf '# later\n' > "$repo/docs/adr/0008-later.md"; g add -A; g commit -q -m later
moved=$(g rev-parse HEAD)
g checkout -q --detach "$base"; printf 'y\n' >> "$repo/docs/adr/README.md"; g add -A; g commit -q -m behind
step 0 "a branch behind a base that gained an ADR after the branch point" "$moved" "$(g rev-parse HEAD)"

# Fail closed: a git error is never "no ADR changed" (context-builder-kit#61).
step 1 "a base SHA git cannot read fails closed" 0000000000000000000000000000000000000bad "$(g rev-parse HEAD)"
g checkout -q --orphan unrelated; g rm -rq --cached . >/dev/null; printf 'z\n' > "$repo/z.md"; g add z.md; g commit -q -m unrelated
step 1 "two commits with no merge base fail closed" "$base" "$(g rev-parse HEAD)"
echo "adr-ci-body-fixture: $n cases ok"
