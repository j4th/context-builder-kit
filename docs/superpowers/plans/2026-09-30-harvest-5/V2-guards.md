# Harvest 5 — V2: Guards and their CI backstops

This cluster makes every guard the kit ships decide on what a tool call really touches, refuse input it cannot read, name the backstop that still stands when it fails open, and prove each branch by payload — and it makes the CI backstops behind those guards exist and fail closed. It closes #60 (the ADR guard's ten bypass spellings, the shared resolver `.claude/hooks/lib/resolve-path.sh`, the parse-nothing ADR job, the frozen-corpus recipe, the backstop-exists check), #61 (the ADR job's `mapfile` that read a git error as a pass), #62 (every fail-open warning names its backstop), #58's residue rows R1, R6, R8 and R13 and the § Hook authoring half of R11, and the whole-kit review's `review/security/19` (the two-dot ADR diff) and `review/security/20` (the unanchored main-branch and PR-state patterns); the trace rows are listed per task and in § Coverage. It implements D43, D44, D55 and D61, the backstop half of D51, and runs probes P1 and P4. It consumes V1: the runner `bash .claude/workflows/tests/run-verification-block.sh`, the two sentinels, and V1's `stop_hook_clean`, whose literal `WARNING` contract `hook-payloads-fixture.sh` pins on every could-not-look branch of the detector. It produces the shared `extract-run-block.sh` that V4's assert-step fixture sources, the `hook-guards-fixture.sh` SKIP line V5's knowledge-axis-`none` dry run expects, and the helper, slots and behaviour changes V3, V8 and V10 describe (§ Handed to other clusters).

**How this file runs.**
- **Base.** V1 has landed. Every edit below anchors on text V1 does not change. New kit-sub-block checks go immediately before `echo "verification: kit sub-block complete"`; new project-sub-block checks go immediately before `  echo "verification: project sub-block complete"`. Because V1's lines run before them, each "run" step greps the runner's output for this task's lines and the sentinels rather than reading its tail.
- **Measured, not assumed.** Every red-first line below was produced on 2026-09-30 in a scratch clone of `643f7ff`, and the whole V2.1–V2.8 sequence was replayed there from these exact texts, with the block green after each commit. Line numbers are "at `74edf84`", for orientation only; if an anchor is missing, stop and reconcile.
- **Case counts.** `protected-paths-hook-fixture.sh` reports 48 cases on a host with `/proc` and `unshare -rm` (45 with its bind-mount SKIP line, 47 with its `/proc` SKIP line). `hook-guards-fixture.sh` reports 64 after V2.3 and 85 after V2.4 (three fewer with its knowledge-backend SKIP line). `hook-payloads-fixture.sh` reports 33 (32 with its SKIP line, when run as root). `adr-ci-body-fixture.sh` reports 13.
- **Modes.** `extract-run-block.sh` and `lib/resolve-path.sh` are sourced, never run: mode 644. Every fixture and hook is 755. `git add` records the mode; check it with `git ls-files -s <path>`.
- **Scratch copies** are made with `S=$(mktemp -d) && cp -a . "$S/kit"` from the repository root and removed after; the real tree is changed only by the steps that say so.
- **Commits** use a quoted heredoc (`git commit -F - <<'MSG'`), so no backtick or `$` in a message is expanded. The branch is `feat/harvest-5-v1.0.0`, never `main`.
### Task V2.1: The ADR job parses no paths, diffs from the merge base and fails closed (#60/c5876324022/adr-job, #60/c5881158391/port-glob-body, #60/c5892401033/adr-job-glob-fixture, #60/c5901494943/3, #61/body/fix, #61/body/grep, review/security/19, #67/c5892401572/2 (the extractor); D55, D44)

**Files:**
- Create: `.claude/workflows/tests/extract-run-block.sh` (mode 644)
- Create: `.claude/workflows/tests/adr-ci-body-fixture.sh` (mode 755)
- Modify: `.github/workflows/adr-immutability-check.yml` (whole file; the job name `ADR immutability` and the step name `Detect modified or deleted ADR files` are kept)
- Modify: `.claude/rules/cbk-conventions-reference.md` — § Verification, the kit sentinel

**Interfaces:**
- Produces: `extract_run_block <workflow.yml> <step name>`, defined by sourcing `.claude/workflows/tests/extract-run-block.sh`. It prints the step's `run: |` body, dedented, or nothing when the step or its `run:` is absent. V4's `review-assert-fixture.sh` sources this file as it is; V4 does not fork or edit it.
- Produces: the step name `Detect modified or deleted ADR files` as the fixture's key. Renaming the step turns the fixture red with `FAIL: adr-immutability-check.yml has no 'Detect modified or deleted ADR files' step with a run: body`.
- Produces: block pins on `:(glob)docs/adr/`, `--diff-filter=a`, `--no-renames` and `"$BASE_SHA...$HEAD_SHA"` in the step's commands (its comments stripped: the job's comments name every flag, so a whole-file `grep -F` passes with the flag deleted), on the whole lines `    shell: bash`, `    runs-on: ubuntu-24.04` and `          filter: blob:none`, and the absence of `mapfile` fed by a process substitution under `.github/workflows` and `.claude/skills/blueprint/references/templates` (V4's template edits must keep it absent).
- Produces: `.github/workflows/adr-immutability-check.yml` as the named backstop that V2.2's hook messages and V2.6's mutation row cite.
- Decides V1's hand-off item 2 (D52 for the ADR job): the job's `shell: bash` and `runs-on: ubuntu-24.04` pins are **unconditional**, not kit-tree-only like V1.7's `verify.yml` line. The ADR job ships in the drop-in set and is the named backstop of the ADR guard, so a target keeps the pins, or narrows the check in its own copy with a comment (a self-hosted runner). V1.7's line stays `verify.yml`'s own; this task adds a separate check rather than extending V1.7's file list.

- [ ] **Step 1: Write the shared extractor and the failing fixture**

Create `.claude/workflows/tests/extract-run-block.sh`:
```bash
# shellcheck shell=bash
# Sourced by every fixture that runs a workflow step's own body, so the fixture runs the exact bytes CI runs
# rather than a copy that drifts. Defines one function and runs nothing on source; never reads stdin.
#
#   extract_run_block <workflow.yml> <step name>
#
# Prints the step's `run: |` body, dedented. The step is found by its `- name:` value compared as a plain
# string (a name may hold regex metacharacters). The body starts after the step's `run: |` line and ends at
# the first non-blank line indented less than the body's first line — YAML's literal-block rule. Prints
# nothing when the step or its `run:` is absent; a caller treats an empty body as a failure, never as a pass.
# Needs awk only (POSIX: no gawk extension is used).
extract_run_block() {
  awk -v want="$2" '
    function ind(s) { match(s, /^ */); return RLENGTH }
    !found {
      line = $0; sub(/^ *- name: /, "", line)
      if ($0 ~ /^ *- name: / && line == want) { found = 1; step = ind($0) }
      next
    }
    found && !inrun {
      if ($0 ~ /^ *- / && ind($0) <= step) exit        # the next step began: this one has no run: block
      if ($0 ~ /^ *run: \|/) inrun = 1
      next
    }
    inrun {
      if ($0 ~ /^ *$/) { blank++; next }
      if (!body) body = ind($0)
      if (ind($0) < body) exit
      while (blank > 0) { print ""; blank-- }
      print substr($0, body + 1)
    }
  ' "$1"
}
```

Create `.claude/workflows/tests/adr-ci-body-fixture.sh`:
```bash
#!/usr/bin/env bash
# Fixture for .github/workflows/adr-immutability-check.yml: runs the job's own `run:` body — extracted from the
# workflow by extract-run-block.sh, never a copy — against a throwaway repository, one head commit per case off a
# shared base (context-builder-kit#60, context-builder-kit#61).
#   exit 1 — an existing numbered ADR modified (an ASCII, a non-ASCII and a spaced name), deleted, renamed, or
#            given a mode change; a base SHA git cannot read; two commits with no merge base. A git error is
#            never "no ADR changed".
#   exit 0 — a new ADR; an edit to README.md or corrections.md; a nested docs/adr/sub/0005-x.md (not a numbered
#            ADR); and a branch that touches no ADR while the base branch gained one after the branch point (the
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
```

Run: `chmod 644 .claude/workflows/tests/extract-run-block.sh && chmod 755 .claude/workflows/tests/adr-ci-body-fixture.sh`

- [ ] **Step 2: Run the fixture against the unfixed job, and show the two other defects**

Run: `bash .claude/workflows/tests/adr-ci-body-fixture.sh; echo "exit=$?"`
Expected:
```text
FAIL: modify a non-ASCII-named ADR (want exit 1, got 0)
  | No numbered ADR files changed in this PR.
exit=1
```
Record the FAIL line in the PR body's red-first table.

The fixture stops at its first failure, so show the stale-base defect (review/security/19) and the fail-open (#61) against the unfixed body directly. Run from the repository root:
```bash
S=$(mktemp -d)
. .claude/workflows/tests/extract-run-block.sh
extract_run_block .github/workflows/adr-immutability-check.yml "Detect modified or deleted ADR files" > "$S/old.sh"
g() { git -C "$S/r" -c user.email=x@x -c user.name=x -c commit.gpgsign=false "$@"; }
git -c init.defaultBranch=main init -q "$S/r"; mkdir -p "$S/r/docs/adr"; echo a > "$S/r/docs/adr/0001-a.md"
g add -A; g commit -qm base; b=$(g rev-parse HEAD)
echo later > "$S/r/docs/adr/0002-later.md"; g add -A; g commit -qm later; m=$(g rev-parse HEAD)
g checkout -q --detach "$b"; echo y > "$S/r/notes.md"; g add -A; g commit -qm behind; h=$(g rev-parse HEAD)
(cd "$S/r" && BASE_SHA=$m HEAD_SHA=$h bash "$S/old.sh" >/dev/null 2>&1); echo "stale base: exit=$? (the unfixed body fails a PR that touched no ADR)"
rc=0; out=$(cd "$S/r" && BASE_SHA=0000000000000000000000000000000000000bad HEAD_SHA=$h bash "$S/old.sh" 2>/dev/null) || rc=$?; printf '%s\n' "$out"; echo "bad base SHA: exit=$rc (the unfixed body passes on a git error)"
rm -rf "$S"
```
Expected:
```text
stale base: exit=1 (the unfixed body fails a PR that touched no ADR)
No numbered ADR files changed in this PR.
bad base SHA: exit=0 (the unfixed body passes on a git error)
```
Record both lines in the red-first table. #61/body/grep needs no change of its own: record in the PR body that a repository-wide grep for `mapfile`, `readarray` and `< <(` over `*.yml`, `*.yaml`, `*.sh` and `*.md` (excluding `docs/superpowers/`) finds the ADR job as the only live `mapfile` of a process substitution under `set -e`, and that the block now pins its absence.

- [ ] **Step 3: Verify the platform facts, rewrite the job, add the block checks**

The new job comments state three facts. Re-read each raw today:

Run: `curl -sL 'https://docs.github.com/api/article/body?pathname=/en/actions/reference/workflows-and-actions/workflow-syntax' | grep -F -e 'bash --noprofile --norc -eo pipefail {0}' -e 'bash -e {0}' | head -2 | cut -c1-80`
Expected: two table rows, one for `unspecified` ending in `bash -e {0}` and one for `bash` ending in `bash --noprofile --norc -eo pipefail {0}`. If either is missing, stop: the `defaults:` comment cannot be written as drafted.

Run: `curl -sL https://raw.githubusercontent.com/actions/checkout/11d5960a326750d5838078e36cf38b85af677262/action.yml | grep -A2 '^  filter:'`
Expected: `  filter:` then `    description: >` then `      Partially clone against a given filter.`

Run (the blobless measurement the comment dates):
```bash
S=$(mktemp -d) && g() { git -C "$S/src" -c user.email=a@b -c user.name=a -c commit.gpgsign=false "$@"; } \
&& git -c init.defaultBranch=main init -q "$S/src" && mkdir -p "$S/src/docs/adr" \
&& for i in 1 2 3; do echo "# $i" > "$S/src/docs/adr/000$i-a.md"; done && g add -A && g commit -qm base && b=$(g rev-parse HEAD) \
&& echo x >> "$S/src/docs/adr/0001-a.md" && echo n > "$S/src/docs/adr/0009-n.md" && g add -A && g commit -qm head && h=$(g rev-parse HEAD) \
&& g config uploadpack.allowFilter true && git clone -q --no-checkout --filter=blob:none "file://$S/src" "$S/c" \
&& git -C "$S/c" rev-list --objects --missing=print --all | grep -c '^?' \
&& git -C "$S/c" diff --no-renames --diff-filter=a --name-status "$b...$h" -- ':(glob)docs/adr/[0-9][0-9][0-9][0-9]-*.md' \
&& git -C "$S/c" rev-list --objects --missing=print --all | grep -c '^?'; rm -rf "$S"
```
Expected: the same missing-object count before and after (it was `5`, then `M	docs/adr/0001-a.md`, then `5`). If the second count is larger, stop: the diff fetched blobs, and `filter: blob:none` must not ship.

Replace the whole of `.github/workflows/adr-immutability-check.yml` with:
```yaml
name: ADR immutability check

# Closes the raw-git-access gap that the PreToolUse hook can't catch.
# Per ADR-0000, ADRs are immutable once accepted — revisions go via new ADRs
# that supersede the old. This workflow fails the PR if any existing
# `docs/adr/[0-9]{4}-*.md` file has been modified (additions of new ADR
# files are allowed; deletions and modifications are not).

# No `paths:` filter, on purpose: a required check that is skipped by a path
# filter never reports and parks the PR forever (cbk-conventions-reference.md
# § Required-checks trap, cause 2). The job exits 0 in seconds when no
# ADR changed, so always-run costs nothing.
on:
  pull_request:
    branches: [main]

# `shell: bash` runs every step as `bash --noprofile --norc -eo pipefail {0}`;
# an unspecified shell runs `bash -e {0}`, without pipefail
# (https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax,
# read 2026-09-30).
defaults:
  run:
    shell: bash

jobs:
  immutability:
    # The check-run context a ruleset requires. Pinned before promotion and never
    # renamed afterwards — matching is by name (the trap's cause 3).
    name: ADR immutability
    # A named image, not a moving label: the runner changes only by a reviewed edit.
    runs-on: ubuntu-24.04
    steps:
      - name: Checkout PR branch
        # SHA-pinned per cbk-conventions.md § Dependency settle-window: tag refs
        # are mutable and open to tag-retag compromise.
        uses: actions/checkout@11d5960a326750d5838078e36cf38b85af677262 # v4.4.0
        with:
          # The full commit graph (the diff needs the merge base) and no blobs:
          # with --no-renames, `git diff --name-status` compares tree entries, so
          # no ADR blob is fetched (a blobless clone's missing-object count was
          # unchanged across the diff, measured 2026-09-30). `filter` is an input
          # of the pinned action (its action.yml at this SHA, read 2026-09-30).
          # The property rests on --no-renames staying in the body below; the
          # verification block pins the two together.
          fetch-depth: 0
          filter: blob:none

      - name: Detect modified or deleted ADR files
        env:
          BASE_SHA: ${{ github.event.pull_request.base.sha }}
          HEAD_SHA: ${{ github.event.pull_request.head.sha }}
        run: |
          set -euo pipefail

          # Every change to an existing numbered ADR — docs/adr/NNNN-*.md directly under docs/adr/ —
          # fails the check; an added ADR passes, and README.md, template.md, corrections.md and nested
          # files are exempt. The body parses no paths: a `:(glob)` pathspec selects the numbered ADRs
          # (`*` does not cross `/`), `--diff-filter=a` drops additions, `--no-renames` turns a rename
          # into the deletion it is, and any output fails. The awk path match this replaced missed a
          # name git prints quoted (a non-ASCII one) and a name awk splits (a spaced one); both read
          # as "no ADR changed" (context-builder-kit#60).
          # Three dots: the diff runs from the merge base of the two SHAs, so an ADR merged to the base
          # branch after this branch was cut is not read as deleted here.
          # Fail closed: command substitution hands `git diff`'s status to the `||`, so a git error
          # (an unreadable SHA, no merge base) is never "no ADR changed" (context-builder-kit#61).
          # This body runs under .claude/workflows/tests/adr-ci-body-fixture.sh.
          changes="$(git diff --no-renames --diff-filter=a --name-status "$BASE_SHA...$HEAD_SHA" -- ':(glob)docs/adr/[0-9][0-9][0-9][0-9]-*.md')" \
            || { echo "::error::git diff $BASE_SHA...$HEAD_SHA failed; not reporting a pass on no data."; exit 1; }

          if [ -z "$changes" ]; then
            echo "No existing numbered ADR changed in this PR."
            exit 0
          fi

          echo "::error::ADR immutability violation: existing ADRs cannot be modified, deleted, renamed or re-moded."
          echo "Per docs/adr/0000-record-architecture-decisions.md, ADRs are immutable once accepted."
          echo "To revise a decision, write a new ADR that supersedes the old one; a wrong claim goes to docs/adr/corrections.md."
          echo ""
          echo "Forbidden changes:"
          printf '%s\n' "$changes"
          exit 1
```

Edit `.claude/rules/cbk-conventions-reference.md` — in § Verification, replace the kit sentinel line (exact; it occurs once):
```bash
echo "verification: kit sub-block complete"
```
with (the new checks sit immediately before it):
```bash
# The ADR-immutability job's own run: body on a throwaway repository (context-builder-kit#60,
# context-builder-kit#61): a modified ADR with an ASCII, non-ASCII or spaced name, a deletion, a rename and a
# mode change fail it; a new ADR, the README, the corrections register and a nested non-ADR pass; a branch
# behind a base that gained an ADR passes (the diff runs from the merge base); an unreadable base SHA and no
# merge base fail closed. Needs git.
bash .claude/workflows/tests/adr-ci-body-fixture.sh || { echo "adr-immutability-check.yml's body regressed on its fixture"; exit 1; }
# The job's shape the fixture cannot see: the parse-nothing pathspec and the merge-base diff, a blobless checkout
# that stays blobless only while --no-renames holds, bash with pipefail, a named runner image; and no workflow or
# workflow template reads a process substitution into mapfile, whose failure `set -e` never sees (context-builder-kit#61).
# The flags are read from the step's commands with its comments stripped, and the keys as whole lines, because the
# job's own comments name every one of them. Unconditional: the job ships in the drop-in set, so a target keeps the
# pins, or narrows this check in its own copy with a comment saying why (a self-hosted runner, say).
. .claude/workflows/tests/extract-run-block.sh
adrcmd=$(extract_run_block .github/workflows/adr-immutability-check.yml "Detect modified or deleted ADR files" | grep -v '^[[:space:]]*#' || true)
for w in ":(glob)docs/adr/" "--diff-filter=a" "--no-renames" '"$BASE_SHA...$HEAD_SHA"'; do grep -qF -- "$w" <<<"$adrcmd" || { echo "adr-immutability-check.yml's run: body lacks: $w"; exit 1; }; done
for l in "    shell: bash" "    runs-on: ubuntu-24.04" "          filter: blob:none"; do grep -qxF -- "$l" .github/workflows/adr-immutability-check.yml || { echo "adr-immutability-check.yml lacks the line:$l"; exit 1; }; done
absent grep -rnE 'mapfile[^<]*<[[:space:]]*<\(' .github/workflows .claude/skills/blueprint/references/templates
echo "verification: kit sub-block complete"
```

- [ ] **Step 4: Run the fixture and the block**

Run: `bash .claude/workflows/tests/adr-ci-body-fixture.sh; echo "exit=$?"`
Expected: `adr-ci-body-fixture: 13 cases ok`, `exit=0`.

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'adr-ci-body-fixture|^verification: (kit sub-block complete|done)$|^verification: block exited'; echo "exit=${PIPESTATUS[0]}"`
Expected: `adr-ci-body-fixture: 13 cases ok`, `verification: kit sub-block complete`, `verification: done`, `exit=0`.

Run (the shape pins bite on the flag or key, not on the comments that name it — in a scratch copy):
```bash
S=$(mktemp -d) && cp -a . "$S/kit" && cd "$S/kit" && w=.github/workflows/adr-immutability-check.yml && cp "$w" "$S/w" \
&& for m in 's/git diff --no-renames --diff/git diff --diff/' '/^defaults:$/,/^    shell: bash$/d' 's/^          filter: blob:none$/          # dropped/'; do
  cp "$S/w" "$w"; sed -i "$m" "$w"; bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E "adr-immutability-check.yml('s run: body)? lacks"; done; cd - >/dev/null; rm -rf "$S"
```
Expected, one line per mutant: `adr-immutability-check.yml's run: body lacks: --no-renames`, `adr-immutability-check.yml lacks the line:    shell: bash`, `adr-immutability-check.yml lacks the line:          filter: blob:none`. (Deleting `--diff-filter=a` is caught by the fixture itself: `FAIL: add a new ADR (want exit 0, got 1)`.)

- [ ] **Step 5: Commit**

```bash
git add .claude/workflows/tests/extract-run-block.sh .claude/workflows/tests/adr-ci-body-fixture.sh .github/workflows/adr-immutability-check.yml .claude/rules/cbk-conventions-reference.md
git commit -q -F - <<'MSG'
fix(V2): the ADR job parses no paths, diffs from the merge base and fails closed

The job's body is a :(glob) pathspec with --diff-filter=a and --no-renames, and
any output fails it: the awk match it replaces read a quoted non-ASCII name and a
spaced name as "no ADR changed". The diff is three-dot, so an ADR merged to the
base after the branch point no longer reads as a deletion. A git error now fails
the step, where mapfile of a process substitution read it as a pass. The checkout
is blobless; the job runs under shell: bash on a named runner image.
adr-ci-body-fixture.sh runs the job's own body, extracted by the shared
extract-run-block.sh; the block runs the fixture and pins what it cannot see.

Red first: FAIL: modify a non-ASCII-named ADR (want exit 1, got 0)

Trace: #60/c5876324022/adr-job, #60/c5881158391/port-glob-body,
#60/c5892401033/adr-job-glob-fixture, #60/c5901494943/3, #61/body/fix,
#61/body/grep, review/security/19; the extractor for #67/c5892401572/2.
Decisions: D55, D44.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
```
### Task V2.2: The ADR guard resolves the path it judges, through a shared helper (#60/body/fix, #60/body/alt, #60/body/fixture, #60/c5876324022/table, #60/c5876324022/closed-1, #60/c5876324022/closed-2, #60/c5876324022/closed-3, #60/c5876324022/closed-4, #60/c5876324022/closed-5, #60/c5876324022/closed-6, #60/c5876324022/closed-note, #60/c5881158391/port-helper, #60/c5892401033/helper, #60/c5892401033/adr-path-independent, #60/c5892401033/linked-worktrees, #60/c5892401033/ef-inode, #60/c5892401033/gitignore-trap, #60/c5892401033/fixture, #60/c5901494943/2a, #60/c5901494943/2b, #60/c5901494943/2c, #60/c5901494943/2d, #60/c5901494943/2e, #62/body/extra-adr-hook, #58/c5901493591/R1 (the path guard), release/5 (§ Hook authoring), #69/c5859756889/apply-h4/1, review/consistency/48; D43, D44, D61)

**Files:**
- Create: `.claude/hooks/lib/resolve-path.sh` (mode 644)
- Create: `.claude/workflows/tests/protected-paths-hook-fixture.sh` (mode 755)
- Modify: `.claude/hooks/protect-immutable-adrs.sh` (whole file)
- Modify: `.claude/workflows/tests/hook-contract-fixture.sh` (header lines 2–5, the early-reader loop at line 51)
- Modify: `.claude/rules/cbk-conventions-reference.md` — § Hook authoring (the opening paragraph, the Header bullet, the stdin bullet's citation, the Project-relative paths bullet, a new bullet before Four tiers, the Verify by payload citation) and § Verification (the kit sentinel)

**Interfaces:**
- Produces: `.claude/hooks/lib/resolve-path.sh`, functions only: `rp_payload <payload>` (sets `RP_TOOL`, `RP_FILE`, `RP_CWD`; returns 1 on a payload jq cannot read), `rp_lexnorm <path> <base>` (`RP_LEX`), `rp_canon <path> <base>` (`RP_CANON`; flags `RP_THROUGH_PROC`, `RP_UNREADABLE`), `rp_target <file_path> <cwd>` (`RP_T_LEXICAL`, `RP_T_PHYSICAL`), `rp_roots <hook path>` (`RP_ROOTS`), `rp_linked_worktree <physical path>` (`RP_WT`), `rp_nearest_dir <path>` (`RP_DIR`), `rp_same_entry <guarded dir> <target dir> <target file> [<glob>]` (`RP_HIT`). A target's corpus guard is the second caller; the kit ships none.
- Produces: the ADR guard's fail-open messages, pinned by the fixture: the missing-helper warning names `helper`, `Backstop` and `adr-immutability-check.yml`; the jq warning names `jq not installed` and `Backstop`; every refusal still names `docs/adr/corrections.md` (the block's existing check).
- Produces: the § Hook authoring bullet that begins `- **A sourced helper, and a target's own hooks, keep the same contract.**` — the one statement of the sourced-helper contract. It names the `!/.claude/hooks/lib/` trap and cites § .gitignore anchoring, where V8.4 lands the negation bullet (`**A negation keeps the hook helpers tracked.**`) with its sources; the section exists at `74edf84`, so the citation holds between the two commits.
- Produces: the block check `absent git check-ignore -q --no-index .claude/hooks/lib/resolve-path.sh`.
- Consumes: `.github/workflows/adr-immutability-check.yml` (V2.1) as the backstop the messages name.

- [ ] **Step 1: Write the failing fixture**

Create `.claude/workflows/tests/protected-paths-hook-fixture.sh`:
```bash
#!/usr/bin/env bash
# Fixture for the path guard that sources .claude/hooks/lib/resolve-path.sh — protect-immutable-adrs.sh, which
# denies an existing docs/adr/NNNN-*.md in ANY checkout — and for the helper's root-scoped functions, driven through
# a corpus guard the fixture writes for itself (the kit ships no corpus guard; a target with a frozen corpus writes
# its own on this helper). Deny cases are the spellings context-builder-kit#60 measured against the ADR hook: a `..`
# segment, `.` and a doubled slash, a trailing-slash project dir, a relative path from a subdirectory, a symlinked
# directory, a symlink to the file, a hardlink, a path through /proc, an unparseable payload (a lone UTF-16
# surrogate), and a project dir pointing at another checkout — plus the control, a project root containing a space,
# and a hardlink inside a linked worktree. Allow cases are the neighbours a looser match catches. The hooks run from
# a copy of the checkout's layout (.claude/hooks + lib) inside throwaway `git init` trees; the real checkout is never
# touched and the launch directory never matters. Only exit 2 denies, so every case asserts the exact exit. The
# guard's fail-open branches — no lib/ helper, and no jq on PATH — exit 0 and name the surviving backstop.
# Needs bash, git, jq, readlink (GNU or BSD). Four cases need more and print a SKIP line where the host lacks it:
# the /proc case needs /proc/self/root, and the three bind-mount cases need `unshare -rm` (an unprivileged user and
# mount namespace). Run by the verification block; also: bash .claude/workflows/tests/protected-paths-hook-fixture.sh
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
src="$here/../../hooks"
ADR=protect-immutable-adrs.sh; CORPUS=corpus-double.sh
[ -f "$src/$ADR" ] || { echo "protected-paths-hook-fixture: $src/$ADR is missing"; exit 1; }
command -v jq >/dev/null && command -v git >/dev/null || { echo "protected-paths-hook-fixture: needs jq and git"; exit 1; }
t=$(mktemp -d)
cleanup() { chmod -R u+rwX "$t" 2>/dev/null || true; rm -rf "$t"; }
trap cleanup EXIT

install_hooks() {  # install_hooks <checkout root>: the guard where settings.json registers it, lib beside it
  mkdir -p "$1/.claude/hooks"
  cp "$src/$ADR" "$1/.claude/hooks/"
  if [ -d "$src/lib" ]; then cp -R "$src/lib" "$1/.claude/hooks/"; fi  # absent, the deny cases below go red
  cat > "$1/.claude/hooks/$CORPUS" <<'EOF'
#!/usr/bin/env bash
# The fixture's root-scoped guard over docs/corpus/ — anything under it, additions too, in the hook's own checkout,
# the project dir's, or a linked worktree of either — in the shape a target's frozen-corpus guard takes.
set -uo pipefail
input="$(cat)"
here=${BASH_SOURCE[0]%/*}
. "$here/lib/resolve-path.sh"
deny() { echo "BLOCKED: $1" >&2; exit 2; }
rp_payload "$input" || deny "the payload could not be read"
case "$RP_TOOL" in Edit|Write|MultiEdit) ;; *) exit 0 ;; esac
[ -n "$RP_FILE" ] || exit 0
rp_target "$RP_FILE" "$RP_CWD"
[ -z "$RP_THROUGH_PROC" ] || deny "a path through /proc"
[ -z "$RP_UNREADABLE" ] || deny "an unreadable symlink"
rp_roots "${BASH_SOURCE[0]}"
roots=("${RP_ROOTS[@]}")
for t in "$RP_T_LEXICAL" "$RP_T_PHYSICAL"; do rp_linked_worktree "$t"; [ -z "$RP_WT" ] || roots+=("$RP_WT"); done
for root in "${roots[@]}"; do
  c="${root%/}/docs/corpus"
  for t in "$RP_T_LEXICAL" "$RP_T_PHYSICAL"; do case "$t" in "$c"|"$c/"*) deny "$t is in the corpus" ;; esac; done
done
rp_nearest_dir "$RP_T_PHYSICAL"
file=''; [ -f "$RP_T_PHYSICAL" ] && file=$RP_T_PHYSICAL
for root in "${roots[@]}"; do
  c="${root%/}/docs/corpus"; [ -d "$c" ] || continue
  RP_HIT=''; if rp_same_entry "$c" "$RP_DIR" "$file"; then deny "$RP_FILE is $RP_HIT by another name"; fi
done
exit 0
EOF
  chmod +x "$1/.claude/hooks/$ADR" "$1/.claude/hooks/$CORPUS"
}
make_root() {  # make_root <dir>: a committed checkout shaped like a target
  mkdir -p "$1/docs/adr/sub" "$1/docs/adr-old" "$1/docs/corpus" "$1/docs/sub"
  for f in 0001-x.md README.md template.md corrections.md sub/0001-x.md; do printf '# %s\n' "$f" > "$1/docs/adr/$f"; done
  printf 'old\n' > "$1/docs/adr-old/0001-x.md"
  printf 'frozen\n' > "$1/docs/corpus/00-overview.md"
  printf 'notes\n' > "$1/docs/corpus-notes.md"
  git -c init.defaultBranch=main init -q "$1"
  git -C "$1" add -A; git -C "$1" -c user.email=f@x -c user.name=f -c commit.gpgsign=false commit -q -m base
  install_hooks "$1"
}
root="$t/repo"; other="$t/other"; spaced="$t/a b/repo"
make_root "$root"; make_root "$other"; make_root "$spaced"
git -C "$root" worktree add -q --detach "$root/.claude/worktrees/wt" HEAD
git -C "$root" worktree add -q --detach "$t/wt-outside" HEAD
ln -s docs/adr "$root/adr-link"; ln -s docs/adr/0001-x.md "$root/adr-file-link.md"
ln -s docs/corpus "$root/corpus-link"; ln -s docs/corpus/00-overview.md "$root/corpus-file-link.md"
ln "$root/docs/adr/0001-x.md" "$root/adr-hard.md"; ln "$root/docs/corpus/00-overview.md" "$root/corpus-hard.md"
ln "$t/wt-outside/docs/adr/0001-x.md" "$t/wt-outside/notes-hard.md"
ln -s loop-b "$root/loop-a"; ln -s loop-a "$root/loop-b"
A="$root/docs/adr/0001-x.md"; C="$root/docs/corpus/00-overview.md"

n=0
fail() { echo "FAIL [$1]: $2"; sed 's/^/  stderr: /' "$t/err"; exit 1; }
# probe <want> <description> <hook> <hook root> <cwd> <project dir or -> <tool> <file_path>
probe() {
  local want=$1 desc=$2 hook=$3 hroot=$4 cwd=$5 pd=$6 tool=$7 fp=$8 rc=0 payload
  payload=$(jq -cn --arg tool "$tool" --arg fp "$fp" --arg cwd "$cwd" '{tool_name: $tool, tool_input: {file_path: $fp}, cwd: $cwd}')
  if [ "$pd" = - ]; then
    (cd "$cwd" && printf '%s' "$payload" | env -u CLAUDE_PROJECT_DIR "$hroot/.claude/hooks/$hook") >/dev/null 2>"$t/err" || rc=$?
  else
    (cd "$cwd" && printf '%s' "$payload" | env CLAUDE_PROJECT_DIR="$pd" "$hroot/.claude/hooks/$hook") >/dev/null 2>"$t/err" || rc=$?
  fi
  n=$((n + 1))
  [ "$rc" -eq "$want" ] || fail "$hook" "$desc (want exit $want, got $rc)"
}
raw() {  # raw <want> <description> <hook> <raw payload>: the payload byte for byte
  local rc=0
  (cd "$root" && printf '%s' "$4" | env CLAUDE_PROJECT_DIR="$root" "$root/.claude/hooks/$3") >/dev/null 2>"$t/err" || rc=$?
  n=$((n + 1))
  [ "$rc" -eq "$1" ] || fail "$3" "$2 (want exit $1, got $rc)"
}

# ── protect-immutable-adrs.sh: deny every spelling of an existing numbered ADR ──
probe 2 "control: the absolute path"                          $ADR "$root" "$root" "$root" Edit "$A"
probe 2 "Write to an existing ADR"                             $ADR "$root" "$root" "$root" Write "$A"
probe 2 "MultiEdit on an existing ADR"                         $ADR "$root" "$root" "$root" MultiEdit "$A"
probe 2 "a .. segment (docs/sub/../adr/)"                      $ADR "$root" "$root" "$root" Edit "$root/docs/sub/../adr/0001-x.md"
probe 2 "a . segment and a doubled slash"                      $ADR "$root" "$root" "$root" Edit "$root/docs/./adr//0001-x.md"
probe 2 "CLAUDE_PROJECT_DIR with a trailing slash"             $ADR "$root" "$root" "$root/" Edit "$A"
probe 2 "a relative path from a subdirectory"                  $ADR "$root" "$root/docs/sub" "$root" Edit "../adr/0001-x.md"
probe 2 "a symlinked directory into docs/adr"                  $ADR "$root" "$root" "$root" Edit "$root/adr-link/0001-x.md"
probe 2 "a symlink to the ADR file"                            $ADR "$root" "$root" "$root" Edit "$root/adr-file-link.md"
probe 2 "a hardlink to the ADR file"                           $ADR "$root" "$root" "$root" Edit "$root/adr-hard.md"
if [ -e /proc/self/root ]; then
  probe 2 "a path through /proc/self/root"                     $ADR "$root" "$root" "$root" Edit "/proc/self/root$A"
else
  echo "SKIP: a path through /proc/self/root (/proc unavailable)"
fi
raw 2 "a lone UTF-16 surrogate makes the payload unparseable, and that is refused" $ADR \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$A\",\"content\":\"x\\ud800y\"},\"cwd\":\"$root\"}"
raw 2 "a file_path that is an object cannot be read, and is refused" $ADR '{"tool_name":"Edit","tool_input":{"file_path":{"x":1}}}'
probe 2 "CLAUDE_PROJECT_DIR set to another checkout"           $ADR "$root" "$root" "$other" Edit "$A"
probe 2 "CLAUDE_PROJECT_DIR unset, launched from a subdirectory" $ADR "$root" "$root/docs/sub" - Edit "$A"
probe 2 "another checkout's existing ADR (every target's ADRs are immutable)" $ADR "$root" "$root" "$root" Edit "$other/docs/adr/0001-x.md"
probe 2 "an existing ADR in a linked worktree"                 $ADR "$root" "$root" "$root" Edit "$t/wt-outside/docs/adr/0001-x.md"
probe 2 "a hardlink inside a linked worktree to that worktree's ADR" $ADR "$root" "$root" "$root" Edit "$t/wt-outside/notes-hard.md"
probe 2 "a project root containing a space"                   $ADR "$spaced" "$spaced" "$spaced" Edit "$spaced/docs/adr/0001-x.md"
probe 2 "a relative path under a project root containing a space" $ADR "$spaced" "$spaced/docs/sub" "$spaced" Edit "../adr/0001-x.md"
rc=0; (cd "$root" && jq -cn --arg fp "$root/adr-hard.md" --arg cwd "$root" '{tool_name:"Edit",tool_input:{file_path:$fp},cwd:$cwd}' \
  | env -u CLAUDE_PROJECT_DIR .claude/hooks/$ADR) >/dev/null 2>"$t/err" || rc=$?
n=$((n + 1)); [ "$rc" -eq 2 ] || fail $ADR "a hardlink, with the hook launched by a relative path (want exit 2, got $rc)"
# ── protect-immutable-adrs.sh: allow the neighbours ──
probe 0 "a new ADR"                                            $ADR "$root" "$root" "$root" Write "$root/docs/adr/0099-new.md"
probe 0 "the README index"                                     $ADR "$root" "$root" "$root" Edit "$root/docs/adr/README.md"
probe 0 "the template"                                         $ADR "$root" "$root" "$root" Edit "$root/docs/adr/template.md"
probe 0 "the corrections register"                             $ADR "$root" "$root" "$root" Edit "$root/docs/adr/corrections.md"
probe 0 "a sibling directory sharing the prefix (docs/adr-old/)" $ADR "$root" "$root" "$root" Edit "$root/docs/adr-old/0001-x.md"
probe 0 "a nested file under docs/adr/sub/"                    $ADR "$root" "$root" "$root" Edit "$root/docs/adr/sub/0001-x.md"
probe 0 "a symlink loop ends, and is not an ADR"               $ADR "$root" "$root" "$root" Edit "$root/loop-a/x.md"
probe 0 "a Read of an ADR"                                     $ADR "$root" "$root" "$root" Read "$A"
probe 0 "a payload with no file_path"                          $ADR "$root" "$root" "$root" Edit ""
probe 0 "a path read exactly: an ADR name plus a trailing newline is another file" $ADR "$root" "$root" "$root" Write "$A"$'\n'

# ── the helper's root-scoped functions, through the fixture's corpus guard ──
probe 2 "corpus: control, the absolute path"                   $CORPUS "$root" "$root" "$root" Edit "$C"
probe 2 "corpus: a new file (additions are frozen too)"        $CORPUS "$root" "$root" "$root" Write "$root/docs/corpus/09-new.md"
probe 2 "corpus: a .. segment"                                 $CORPUS "$root" "$root" "$root" Edit "$root/docs/adr/../corpus/00-overview.md"
probe 2 "corpus: a symlinked directory"                        $CORPUS "$root" "$root" "$root" Write "$root/corpus-link/new.md"
probe 2 "corpus: a symlink to a corpus file"                   $CORPUS "$root" "$root" "$root" Edit "$root/corpus-file-link.md"
probe 2 "corpus: a hardlink to a corpus file"                  $CORPUS "$root" "$root" "$root" Edit "$root/corpus-hard.md"
probe 2 "corpus: a project dir pointing elsewhere (the hook's own checkout is guarded)" $CORPUS "$root" "$root" "$other" Edit "$C"
probe 2 "corpus: a linked worktree inside the checkout"        $CORPUS "$root" "$root" "$root" Edit "$root/.claude/worktrees/wt/docs/corpus/00-overview.md"
probe 2 "corpus: a linked worktree outside the checkout"       $CORPUS "$root" "$root" "$root" Write "$t/wt-outside/docs/corpus/new.md"
probe 0 "corpus: another repository's corpus is not this project's" $CORPUS "$root" "$root" "$root" Edit "$other/docs/corpus/00-overview.md"
probe 0 "corpus: a sibling that shares the name as a prefix"   $CORPUS "$root" "$root" "$root" Edit "$root/docs/corpus-notes.md"
probe 0 "corpus: a symlink loop ends, and is not the corpus"   $CORPUS "$root" "$root" "$root" Edit "$root/loop-a/x.md"

# ── a bind mount of the guarded directory (same device and inode, another path) — needs a user and mount namespace ──
if unshare -rm true 2>/dev/null; then
  mkdir -p "$t/alias-adr" "$t/alias-corpus"
  bind() {  # bind <want> <description> <hook> <guarded dir> <alias> <file_path>
    local rc=0
    unshare -rm bash -c 'mount --bind "$1" "$2" && cd "$3" && jq -cn --arg fp "$4" --arg cwd "$3" "{tool_name:\"Write\",tool_input:{file_path:\$fp},cwd:\$cwd}" | CLAUDE_PROJECT_DIR="$3" "$3/.claude/hooks/$5"' \
      _ "$4" "$5" "$root" "$6" "$3" >/dev/null 2>"$t/err" || rc=$?
    n=$((n + 1))
    [ "$rc" -eq "$1" ] || fail "$3" "$2 (want exit $1, got $rc)"
  }
  bind 2 "an existing ADR through a bind mount of docs/adr"    $ADR "$root/docs/adr" "$t/alias-adr" "$t/alias-adr/0001-x.md"
  bind 0 "a new ADR through a bind mount of docs/adr"          $ADR "$root/docs/adr" "$t/alias-adr" "$t/alias-adr/0099-new.md"
  bind 2 "corpus: a new file through a bind mount of the corpus" $CORPUS "$root/docs/corpus" "$t/alias-corpus" "$t/alias-corpus/new.md"
else
  echo "SKIP: three bind-mount cases (unshare -rm unavailable: no unprivileged user and mount namespace)"
fi

# ── a copy without its lib/ helper fails open, and says which backstop still stands ──
solo="$t/solo"; mkdir -p "$solo/.claude/hooks"; cp "$src/$ADR" "$solo/.claude/hooks/"; chmod +x "$solo/.claude/hooks/$ADR"
rc=0; (cd "$root" && jq -cn --arg fp "$A" '{tool_name:"Edit",tool_input:{file_path:$fp}}' | env CLAUDE_PROJECT_DIR="$root" "$solo/.claude/hooks/$ADR") >/dev/null 2>"$t/err" || rc=$?
n=$((n + 1))
[ "$rc" -eq 0 ] || fail $ADR "a copy without lib/ must fail open (want exit 0, got $rc)"
{ grep -q 'helper' "$t/err" && grep -q 'Backstop' "$t/err" && grep -q 'adr-immutability-check.yml' "$t/err"; } || fail $ADR "the missing-helper warning must name the helper and the backstop's workflow"
# ── with no jq on PATH the guard fails open, and says which backstop still stands (a PATH holding only what the
#    guard runs before its jq check) ──
nojq="$t/nojq"; mkdir -p "$nojq"
for tool in bash cat readlink; do p=$(type -P "$tool" || true); [ -n "$p" ] && ln -sf "$p" "$nojq/$tool"; done
rc=0; (cd "$root" && jq -cn --arg fp "$A" '{tool_name:"Edit",tool_input:{file_path:$fp}}' > "$t/pay-nojq" && env -i PATH="$nojq" HOME="$HOME" CLAUDE_PROJECT_DIR="$root" bash "$src/$ADR" < "$t/pay-nojq") >/dev/null 2>"$t/err" || rc=$?
n=$((n + 1))
[ "$rc" -eq 0 ] || fail $ADR "with no jq the guard must fail open (want exit 0, got $rc)"
{ grep -q 'jq not installed' "$t/err" && grep -q 'Backstop' "$t/err"; } || fail $ADR "the no-jq warning must say jq is missing and name the backstop"
echo "protected-paths-hook-fixture: $n cases ok"
```

Run: `chmod 755 .claude/workflows/tests/protected-paths-hook-fixture.sh`

- [ ] **Step 2: Run it against the unfixed hook, and show the tripwire's blind spot**

Run: `bash .claude/workflows/tests/protected-paths-hook-fixture.sh; echo "exit=$?"`
Expected:
```text
FAIL [protect-immutable-adrs.sh]: a .. segment (docs/sub/../adr/) (want exit 2, got 0)
exit=1
```
(The control, Write and MultiEdit cases pass on the unfixed hook; the first spelling it misses is the `..` segment.) Record the FAIL line in the red-first table.

Run (a pipeline that can exit early, planted in a helper, is invisible to the unfixed tripwire):
```bash
S=$(mktemp -d) && cp -a . "$S/kit" && mkdir -p "$S/kit/.claude/hooks/lib" \
&& printf 'x() { printf "%%s" "$1" | grep -q y; }\n' > "$S/kit/.claude/hooks/lib/x.sh" \
&& (cd "$S/kit" && bash .claude/workflows/tests/hook-contract-fixture.sh; echo "exit=$?"); rm -rf "$S"
```
Expected: `hook-contract-fixture: ok`, `exit=0` — the miss. Record it beside the FAIL line.

- [ ] **Step 3: Verify the platform fact, then land the helper, the hook, the tripwire and § Hook authoring**

Run: `curl -sL https://code.claude.com/docs/en/hooks.md | grep -F 'Handlers run in the current directory' | cut -c1-70`
Expected: `Handlers run in the current directory with Claude Code's environment.` If absent, stop: the hook's `Path:` line quotes it.

Create `.claude/hooks/lib/resolve-path.sh` (then `chmod 644 .claude/hooks/lib/resolve-path.sh`):
```bash
# shellcheck shell=bash
# Sourced by a path guard after it drains stdin — protect-immutable-adrs.sh in the kit, and a target's own guard
# over a frozen corpus (the consultation skill's references/frozen_corpus_ingestion.md § The enforcement set).
# Never run, never reads stdin, defines functions only: no top-level statement runs on source. It answers one
# question the guards share: where does an Edit/Write/MultiEdit's `file_path` really land?
#
# Why a resolver: a prefix or suffix match on the payload's path string is bypassed by every spelling that names
# the same file differently. context-builder-kit#60 measured ten against the ADR hook — a `..` segment, `.` and
# `//`, a trailing-slash CLAUDE_PROJECT_DIR, a relative path, a symlinked directory, a symlink to the file, a
# hardlink, /proc/self/root, an unparseable payload, a project dir pointing elsewhere — and a suffix match closes
# three of them. Taking the root from the file's own checkout (`git -C "$(dirname "$file")" rev-parse
# --show-toplevel`) closes none: git fails for a new file in a directory that does not exist yet, and the root it
# finds follows no symlink, hardlink or /proc link. The recipe, which closes all ten:
#   - the payload is read exactly, in one jq process (@sh-quoted, so a trailing newline survives), and a payload
#     jq cannot read is reported for the guard to refuse;
#   - the path is resolved two ways — lexically, collapsing `..` as a writer that normalizes the path would, and
#     physically, one component at a time through symlinks, `..` taken from the physical parent — and a guard
#     denies when either reading lands in its tree; an unreadable symlink and any path through /proc (whose magic
#     links resolve per process, so a readlink run here is not the writer) are flagged for the guard to refuse;
#   - the roots are the calling hook's own checkout, derived LEXICALLY from the hook's path (a symlinked
#     .claude/hooks must not move it), and CLAUDE_PROJECT_DIR; a linked worktree of either (its `.git` file's
#     gitdir resolves under the root's .git/worktrees/) is found on demand, in pure bash;
#   - the same file or directory under another name (a hardlink, a bind mount) is caught with bash's own `-ef`
#     over a glob walk: no stat or find, so no missing tool can switch the check off.
# Bash 3.2-safe (no mapfile, no associative arrays, no ${x,,}); pure bash plus jq and readlink. The contract a
# sourcing hook keeps is cbk-conventions-reference.md § Hook authoring (sourced helpers). Fixture:
# .claude/workflows/tests/protected-paths-hook-fixture.sh, which also drives the root-scoped functions through a
# corpus guard of its own.

# rp_payload <payload>: RP_TOOL, RP_FILE and RP_CWD from the hook payload, read exactly, in ONE jq process. jq's
# @sh single-quotes each value, so a trailing newline in a path survives the command substitution, and eval
# assigns the three at once. Returns 1 when jq cannot read the payload — not parseable (jq refuses a lone UTF-16
# surrogate escape anywhere in the input), not an object, or a field no shell word can hold, such as an object
# where a path belongs — and the caller refuses.
rp_payload() {
  local fields
  fields=$(jq -r 'if type == "object" then @sh "RP_TOOL=\(.tool_name // "") RP_FILE=\(.tool_input.file_path // "") RP_CWD=\(.cwd // "")" else error("not an object") end' <<<"$1" 2>/dev/null) || return 1
  eval "$fields"
}

# rp_lexnorm <path> <base>: <path> made absolute against <base>, with `.`, empty components and `..` collapsed
# LEXICALLY. Result in RP_LEX.
rp_lexnorm() {
  local rest=$1 out='' part
  [[ "$rest" == /* ]] || rest="$2/$rest"
  while [ -n "$rest" ]; do
    case "$rest" in */*) part=${rest%%/*}; rest=${rest#*/} ;; *) part=$rest; rest='' ;; esac
    case "$part" in
      ''|.) ;;
      ..) out=${out%/*} ;;
      *) out="$out/$part" ;;
    esac
  done
  RP_LEX=${out:-/}
}

# rp_canon <path> <base>: the physical path the kernel would open, component by component — every symlink followed
# where it is met (its exact text: a target may end in a newline), `..` from the PHYSICAL parent, components that
# do not exist kept as given. Result in RP_CANON. Flags, never guesses: RP_THROUGH_PROC (a path through /proc) and
# RP_UNREADABLE (a symlink it could not read). After 40 symlink hops the rest of the path is taken as given, so a
# symlink loop ends.
rp_canon() {
  local rest=$1 phys=/ part cand link hops=0
  [[ "$rest" == /* ]] || rest="$2/$rest"
  while [ -n "$rest" ]; do
    case "$rest" in */*) part=${rest%%/*}; rest=${rest#*/} ;; *) part=$rest; rest='' ;; esac
    case "$part" in
      ''|.) ;;
      ..) phys=${phys%/*}; [ -n "$phys" ] || phys=/ ;;
      *)
        if [ "$phys" = / ]; then cand="/$part"; else cand="$phys/$part"; fi
        case "$cand" in /proc|/proc/*) RP_THROUGH_PROC=$cand ;; esac
        if [ -L "$cand" ] && [ "$hops" -lt 40 ]; then
          hops=$((hops + 1))
          link=$(readlink -- "$cand" 2>/dev/null && printf x)
          case "$link" in
            *x) link=${link%x}; link=${link%$'\n'} ;;
            *) RP_UNREADABLE=$cand; phys=$cand; continue ;;
          esac
          [[ "$link" == /* ]] && phys=/
          rest="$link/$rest"
        else
          phys=$cand
        fi
        ;;
    esac
  done
  RP_CANON=$phys
}

# rp_target <file_path> <cwd>: RP_T_LEXICAL and RP_T_PHYSICAL — the target under both readings of `..` (lexical,
# as a writer that normalizes the path resolves it; physical, as the kernel resolves a raw path), a relative path
# resolved against the payload's cwd. Clears, then sets, RP_THROUGH_PROC and RP_UNREADABLE.
rp_target() {
  local base=${2:-$PWD}
  [[ "$base" == /* ]] || base="$PWD/$base"
  RP_THROUGH_PROC='' RP_UNREADABLE=''
  rp_lexnorm "$1" "$base"; rp_canon "$RP_LEX" /; RP_T_LEXICAL=$RP_CANON
  rp_canon "$1" "$base"; RP_T_PHYSICAL=$RP_CANON
}

# rp_roots <calling hook's path>: RP_ROOTS — the hook's own checkout (the hook is <root>/.claude/hooks/<name>.sh,
# taken lexically, then resolved physically like the target) and CLAUDE_PROJECT_DIR when it is set and names
# another directory, so a worktree session's hook also guards the checkout the session belongs to.
rp_roots() {
  local r
  rp_lexnorm "$1" "$PWD"
  r=${RP_LEX%/*}; r=${r%/*}; r=${r%/*}
  rp_canon "${r:-/}" /
  RP_ROOTS=("$RP_CANON")
  if [ -n "${CLAUDE_PROJECT_DIR:-}" ]; then
    rp_canon "$CLAUDE_PROJECT_DIR" "$PWD"
    # In an ordinary session the project dir IS the hook's checkout: one root, so no walk runs twice.
    [ "$RP_CANON" -ef "${RP_ROOTS[0]}" ] || RP_ROOTS+=("$RP_CANON")
  fi
}

# rp_linked_worktree <physical path>: RP_WT — the root of the checkout the path lives in when that checkout is a
# linked worktree of a root in RP_ROOTS (its `.git` is a file whose `gitdir:` resolves under
# <root>/.git/worktrees/), else empty. Pure bash: the `.git` file is read with the `read` builtin; no git runs.
rp_linked_worktree() {
  local d=$1 line gd r
  RP_WT=''
  while [ -n "$d" ] && [ "$d" != / ] && [ ! -d "$d" ]; do d=${d%/*}; done
  [ -n "$d" ] || d=/
  while :; do
    if [ -f "$d/.git" ]; then
      line=''
      IFS= read -r line < "$d/.git" || true
      case "$line" in "gitdir: "*) gd=${line#gitdir: } ;; *) return 0 ;; esac
      [[ "$gd" == /* ]] || gd="$d/$gd"
      rp_canon "$gd" /
      for r in "${RP_ROOTS[@]}"; do
        case "$RP_CANON" in "${r%/}/.git/worktrees/"*) RP_WT=$d; return 0 ;; esac
      done
      return 0
    fi
    [ -d "$d/.git" ] && return 0
    [ "$d" = / ] && return 0
    d=${d%/*}; [ -n "$d" ] || d=/
  done
}

# rp_nearest_dir <path>: RP_DIR — the path itself if it is a directory, else its nearest existing ancestor.
rp_nearest_dir() {
  RP_DIR=$1
  while [ ! -d "$RP_DIR" ]; do RP_DIR=${RP_DIR%/*}; [ -n "$RP_DIR" ] || RP_DIR=/; done
}

# rp_same_entry <guarded dir> <target dir> <target file, or empty> [<file glob>]: returns 0 and sets RP_HIT when
# <target file> is one of the guarded files (a hardlink) or <target dir> is the guarded dir under another name (a
# bind mount) — same device and inode, by bash's `-ef`, over a walk in bash globs. Without a glob the whole tree is
# guarded: every file, and every subdirectory as a directory too (a corpus). With one, only the files that glob
# names directly under the guarded dir, and the dir itself, with no recursion (the numbered ADRs); the files are
# compared first, so a hardlink is caught whatever directory it is reached through.
rp_same_entry() {
  local e
  if [ -n "${4:-}" ]; then
    if [ -n "$3" ]; then
      for e in "$1"/$4; do  # $4 unquoted on purpose: it is the glob
        if [ -f "$e" ] && [ ! -L "$e" ] && [ "$e" -ef "$3" ]; then RP_HIT=$e; return 0; fi
      done
    fi
    if [ "$1" -ef "$2" ]; then RP_HIT=$1; return 0; fi
    return 1
  fi
  if [ "$1" -ef "$2" ]; then RP_HIT=$1; return 0; fi
  for e in "$1"/* "$1"/.[!.]* "$1"/..?*; do
    if [ -d "$e" ] && [ ! -L "$e" ]; then
      rp_same_entry "$e" "$2" "$3" && return 0
    elif [ -n "$3" ] && [ -f "$e" ] && [ ! -L "$e" ] && [ "$e" -ef "$3" ]; then
      RP_HIT=$e; return 0
    fi
  done
  return 1
}
```

Replace the whole of `.claude/hooks/protect-immutable-adrs.sh` with (mode stays 755):
```bash
#!/usr/bin/env bash
# PreToolUse hook (Edit|Write|MultiEdit): block edits/writes to existing immutable ADR files.
#
# ADRs in docs/adr/<NNNN>-*.md are immutable per ADR-0000. Superseding requires a NEW ADR (with a higher number
# that links to the old one as `Supersedes:`) — never an edit to the old one.
#
# Allowed:  creating a new ADR file (NNNN doesn't exist yet — tested on the RESOLVED path, so creation stays
#           allowed); editing docs/adr/template.md, docs/adr/README.md (the index) and docs/adr/corrections.md
#           (the append-only claim register — where a wrong citation, figure, attribution or formula in an
#           accepted ADR is corrected); a file nested below docs/adr/, and a sibling directory that only shares
#           the prefix (docs/adr-old/); every other tool.
# Blocked:  any Edit/Write/MultiEdit whose target resolves — lexically or physically — to an existing
#           docs/adr/NNNN-*.md in ANY checkout: every target keeps its immutable ADRs at that path, and a session
#           in one target edits its siblings; the same ADR under another name in the hook's own checkout, the
#           project dir's, or a linked worktree of either (a hardlink to an ADR, a bind mount of docs/adr/ — same
#           device and inode); a path through /proc, a symlink that cannot be read, and a payload jq cannot read
#           — none of them can be checked, so each is refused.
# Path:     resolved by .claude/hooks/lib/resolve-path.sh (the recipe and the ten spellings it closes are in its
#           header; context-builder-kit#60). Registered as ${CLAUDE_PROJECT_DIR}/.claude/hooks/… — "Handlers run in
#           the current directory" (https://code.claude.com/docs/en/hooks, read 2026-09-30), so a bare relative
#           path would not resolve from a subdirectory.
# Not seen: a write through the Bash tool (the matcher is Edit|Write|MultiEdit), a case-insensitive filesystem, a
#           hand edit, and a symlink swapped between this check and the write. CI's ADR immutability job
#           (.github/workflows/adr-immutability-check.yml) refuses any of them that reaches a PR.
# Tier:     HARD-DENY (see the registry comment in .claude/settings.json).
# Depends:  jq (the payload) — absent, the guard fails open: exit 0 with a stderr warning naming CI's ADR
#           immutability job as the backstop. The sourced helper .claude/hooks/lib/resolve-path.sh — absent, the
#           same fail-open and the same backstop. readlink (a symlink's target) — absent, a path through a symlink
#           is refused. Nothing else: the device-and-inode check is bash's own `-ef`.
#
# Hook receives JSON on stdin with the tool input. Exit 2 + stderr blocks. Fixture:
# .claude/workflows/tests/protected-paths-hook-fixture.sh.

set -uo pipefail

# Drain stdin before any early exit, or a piping caller's SIGPIPE masks this hook's own
# exit code (cbk-conventions-reference.md § Hook authoring › The stdin / exit contract).
input="$(cat)"
# Deliberately NOT `set -e`: on an environment defect an abort exits non-2, which the hook
# contract reads as NON-blocking — the ADR edit would go through with a cryptic error. Warn and
# fall open instead, naming the backstop.

if ! command -v jq &>/dev/null; then
  echo "protect-immutable-adrs: WARNING — jq not installed; ADR-immutability protection DISABLED." >&2
  echo "                        Install jq to re-enable. Backstop: CI's ADR immutability job (.github/workflows/adr-immutability-check.yml) still refuses the change at PR time." >&2
  exit 0
fi

case "${BASH_SOURCE[0]}" in */*) here=${BASH_SOURCE[0]%/*} ;; *) here=. ;; esac
if [ ! -r "$here/lib/resolve-path.sh" ]; then
  echo "protect-immutable-adrs: WARNING — its path helper $here/lib/resolve-path.sh is missing; ADR-immutability protection DISABLED." >&2
  echo "                        Backstop: CI's ADR immutability job (.github/workflows/adr-immutability-check.yml) still refuses the change at PR time." >&2
  exit 0
fi
# shellcheck source=lib/resolve-path.sh
. "$here/lib/resolve-path.sh"

# deny <why> <detail>: the one refusal, with the ADR's standing explanation.
deny() {
  cat >&2 <<EOF
BLOCKED: ${1:+$1 }ADRs are immutable (per ADR-0000).
$2

To change a decision, write a NEW ADR with the next number that supersedes
this one. Add 'Supersedes: ADR-NNNN' to the new ADR's frontmatter and update
the old one's status only via that new ADR's existence (do not edit the old
file's status field directly — the README index expresses supersession).

A wrong citation, figure, attribution or formula is not a decision revision:
record it as an entry in docs/adr/corrections.md (append-only) and leave this
file as written.
EOF
  exit 2
}

# This hook is registered for Edit|Write|MultiEdit only, so a payload it cannot read is still one of those — and
# its path cannot be checked, so it is refused rather than allowed.
rp_payload "$input" || deny "the tool payload could not be read (not parseable JSON, or a field no shell word can hold), so its path cannot be checked." \
  "(A lone UTF-16 surrogate escape in the tool input does this — jq refuses it. Remove it and retry.)"

case "$RP_TOOL" in
  Edit|Write|MultiEdit) ;;
  *) exit 0 ;;
esac
[[ -z "$RP_FILE" ]] && exit 0

rp_target "$RP_FILE" "$RP_CWD"
[ -z "$RP_THROUGH_PROC" ] || deny "the path goes through /proc ($RP_THROUGH_PROC), whose links resolve per process." \
  "File: $RP_FILE — this hook cannot see where the writer's /proc/self would land, so an edit through /proc is refused."
[ -z "$RP_UNREADABLE" ] || deny "a symlink on the path could not be read ($RP_UNREADABLE), so the path cannot be checked." \
  "File: $RP_FILE — is readlink installed?"

# An existing numbered ADR directly under docs/adr/, under either reading of the path, in any checkout.
adr_re='(^|/)docs/adr/[0-9]{4}-[^/]*\.md$'
for t in "$RP_T_LEXICAL" "$RP_T_PHYSICAL"; do
  if [[ "$t" =~ $adr_re ]] && [ -f "$t" ]; then
    deny "" "File: $RP_FILE
Resolves to: $t"
  fi
done

# The same ADR under another name — a hardlink to an ADR file, or a bind mount of docs/adr/ itself — in the hook's
# own checkout, the project dir's, or the linked worktree of either that the target lives in: another path, the
# same device and inode.
rp_roots "${BASH_SOURCE[0]}"
roots=("${RP_ROOTS[@]}")
rp_linked_worktree "$RP_T_PHYSICAL"
[ -z "$RP_WT" ] || roots+=("$RP_WT")
rp_nearest_dir "$RP_T_PHYSICAL"
base=${RP_T_PHYSICAL##*/}
file=''
[ -f "$RP_T_PHYSICAL" ] && file=$RP_T_PHYSICAL
for root in "${roots[@]}"; do
  adrs="${root%/}/docs/adr"
  [ -d "$adrs" ] || continue
  RP_HIT=''
  rp_same_entry "$adrs" "$RP_DIR" "$file" '[0-9][0-9][0-9][0-9]-*.md' || continue
  if [ -d "$RP_HIT" ]; then
    # docs/adr/ itself by another name: only an EXISTING numbered ADR is refused — a new one may still be created.
    { [[ "/docs/adr/$base" =~ $adr_re ]] && [ -f "$RP_DIR/$base" ]; } || continue
    deny "" "File: $RP_FILE
Its directory is $adrs by another name (same device and inode — a bind mount?)."
  fi
  deny "" "File: $RP_FILE
It is the ADR $RP_HIT by another name (same device and inode — a hardlink?)."
done

exit 0
```

Edit `.claude/workflows/tests/hook-contract-fixture.sh` — replace this text (exact; it occurs once):
```bash
# structurally over every .claude/hooks/*.sh, plus behavioural probes: one over-buffer probe per
```
with:
```bash
# structurally over every .claude/hooks/*.sh — and the early-reader check over every sourced
# .claude/hooks/lib/*.sh helper too (a helper never drains stdin, so check 1 skips it) — plus
# behavioural probes: one over-buffer probe per
```

Edit `.claude/workflows/tests/hook-contract-fixture.sh` — replace this text (exact; it occurs once):
```bash
for h in "$hooks"/*.sh; do
  hit=
```
with:
```bash
libs=("$hooks"/lib/*.sh)
[ -e "${libs[0]}" ] || libs=()
for h in "$hooks"/*.sh ${libs[@]+"${libs[@]}"}; do
  hit=
```


In § Hook authoring, six replacements. The first corrects the tally sentence, which no longer matches the hooks once this one reaches the full header shape (the same defect the review logged as `review/consistency/48`); the third, fourth and sixth rewrite the section's bare kit-issue citations (D53), the fourth also removing a sibling project's name and issue numbers:

Edit `.claude/rules/cbk-conventions-reference.md` — replace this text (exact; it occurs once):
```markdown
The three hooks authored with this section carry every line; the earlier five carry `Blocked:`/`Allowed:` and `Tier:` (the line the verification block asserts) and approximate the rest — bring a hook up to the full shape when you next edit it.
```
with:
```markdown
Every hook carries `Tier:` (the line the verification block asserts); the full shape is every line below — bring a hook up to it when you next edit it.
```

Edit `.claude/rules/cbk-conventions-reference.md` — replace this text (exact; it occurs once):
```markdown
`Path:` naming the placeholder registration;
```
with:
```markdown
`Path:` naming the placeholder registration (and, for a path guard, how the path is resolved); `Not seen:` naming what the guard cannot see and the backstop that refuses it instead;
```

Edit `.claude/rules/cbk-conventions-reference.md` — replace this text (exact; it occurs once):
```markdown
cannot leave the header claiming none (#58, 2026-09-07 comment).
```
with:
```markdown
cannot leave the header claiming none (context-builder-kit#58, 2026-09-07 comment).
```

Edit `.claude/rules/cbk-conventions-reference.md` — replace this text (exact; it occurs once):
```markdown
skipped the PR-state ask-gate (you-are-hear #81 → PR #82).
```
with:
```markdown
skipped the PR-state ask-gate (context-builder-kit#58 item 4).
```

Edit `.claude/rules/cbk-conventions-reference.md` — replace this text (exact; it occurs once):
```markdown
inside a worktree the project dir stays where the session started while the file lives in the worktree.
```
with:
```markdown
inside a worktree the project dir stays where the session started while the file lives in the worktree. A path *guard* never takes its root from the path it judges: git fails for a new file in a directory that does not exist yet, and a root found from the path follows no symlink, hardlink or `/proc` link (context-builder-kit#60) — it resolves the path with the sourced helper below.
```

Edit `.claude/rules/cbk-conventions-reference.md` — replace this text (exact; it occurs once):
```markdown
named as such (#58 item 4).
```
with:
```markdown
named as such (context-builder-kit#58 item 4).
```


Then add the sourced-helper bullet before the Four tiers bullet:

Edit `.claude/rules/cbk-conventions-reference.md` — replace this text (exact; it occurs once, at the start of the Four tiers bullet):
```markdown
- **Four tiers** — hard-deny, ask-gate, advisory, stop
```
with:
```markdown
- **A sourced helper, and a target's own hooks, keep the same contract.** A hook that sources a helper keeps it in `.claude/hooks/lib/`, sources it only **after** the stdin drain, names it on its `Depends:` line, and fails open when it is missing — exit 0 with a warning that names the surviving backstop, never a crash. The helper defines functions only (nothing runs on source) and never reads stdin; `hook-contract-fixture.sh`'s early-reader check reads `lib/*.sh` too, and its drain-first check skips them. The kit ships one: `lib/resolve-path.sh`, which reads the payload exactly and resolves a path lexically and physically (its header carries the recipe). `protect-immutable-adrs.sh` sources it, and a target's frozen-corpus guard can share it (the consultation skill's `references/frozen_corpus_ingestion.md` § The enforcement set scaffold registers); `protected-paths-hook-fixture.sh` drives both modes. **A `.gitignore` can hide the helper:** a stack template's unanchored `lib/` ignores `.claude/hooks/lib/` too, so `git add .claude` skips the helper without a word and every clone of that tree fails open. Such a target adds the anchored negation `!/.claude/hooks/lib/` after that line (§ .gitignore anchoring carries the negation and why its place in the file matters), and the verification block asserts the helper is not ignored. A target's own hooks under `.claude/hooks/` are held to this whole section, as the kit's are — the contract fixture reads every file there.
- **Four tiers** — hard-deny, ask-gate, advisory, stop
```


Edit `.claude/rules/cbk-conventions-reference.md` — in § Verification, replace the kit sentinel line (exact; it occurs once):
```bash
echo "verification: kit sub-block complete"
```
with (the new checks sit immediately before it):
```bash
# The path guard that sources lib/resolve-path.sh (context-builder-kit#60): every spelling that issue measured — `..`,
# `.` and `//`, a trailing-slash or foreign project dir, a relative path, symlinks, a hardlink, /proc, an
# unparseable payload — is denied, and so are a project root containing a space and a hardlink in a linked
# worktree; the neighbours a looser match catches pass; the helper's root-scoped functions run through a corpus
# guard the fixture writes for itself; a copy without its helper and a PATH without jq fail open naming the
# backstop. The /proc and bind-mount cases print a SKIP line where the host lacks /proc or `unshare -rm`.
bash .claude/workflows/tests/protected-paths-hook-fixture.sh || { echo "protect-immutable-adrs.sh or lib/resolve-path.sh regressed on its fixture"; exit 1; }
# The helper is tracked, never hidden: a stack template's unanchored `lib/` in .gitignore makes `git add` skip it
# without a word (§ Hook authoring). --no-index, so the pattern counts even for a file already tracked.
absent git check-ignore -q --no-index .claude/hooks/lib/resolve-path.sh
echo "verification: kit sub-block complete"
```

- [ ] **Step 4: Run the fixtures, the tripwire again, `bash -n` and the block**

Run: `bash .claude/workflows/tests/protected-paths-hook-fixture.sh; echo "exit=$?"`
Expected: `protected-paths-hook-fixture: 48 cases ok` (or 45 after `SKIP: three bind-mount cases (unshare -rm unavailable: no unprivileged user and mount namespace)`), `exit=0`.

Run: `bash .claude/workflows/tests/hook-contract-fixture.sh && bash -n .claude/hooks/protect-immutable-adrs.sh && bash -n .claude/hooks/lib/resolve-path.sh && git check-ignore -q --no-index .claude/hooks/lib/resolve-path.sh; echo "ignored-rc=$?"`
Expected: `hook-contract-fixture: ok`, then `ignored-rc=1` (not ignored).

Run the planted-pipeline command from Step 2 again.
Expected: `FAIL: x.sh decides on a pipeline whose reader can exit first`, the planted line, `exit=1` — the tripwire now reads `lib/`.

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'protected-paths-hook-fixture|^verification: (kit sub-block complete|done)$|^verification: block exited'; echo "exit=${PIPESTATUS[0]}"`
Expected: `protected-paths-hook-fixture: 48 cases ok` (or 45 with its SKIP line), `verification: kit sub-block complete`, `verification: done`, `exit=0`.

- [ ] **Step 5: Commit**

```bash
git add .claude/hooks/lib/resolve-path.sh .claude/hooks/protect-immutable-adrs.sh .claude/workflows/tests/protected-paths-hook-fixture.sh .claude/workflows/tests/hook-contract-fixture.sh .claude/rules/cbk-conventions-reference.md
git ls-files -s .claude/hooks/lib/resolve-path.sh | cut -c1-6
git commit -q -F - <<'MSG'
fix(V2): the ADR guard resolves the path it judges, through a shared helper

protect-immutable-adrs.sh matched the payload's path text against a prefix, so
every spelling context-builder-kit#60 measured passed: a .. segment, . and //, a
trailing-slash or foreign project dir, a relative path, a symlinked directory, a
symlink to the file, a hardlink, /proc/self/root and an unparseable payload. The
guard now sources .claude/hooks/lib/resolve-path.sh: the payload read exactly in
one jq, the path resolved lexically and physically, /proc and unreadable symlinks
refused, the same file under another name caught by bash's -ef over the hook's own
checkout, the project dir and a linked worktree. The deny is path-independent: an
existing docs/adr/NNNN-*.md in any checkout; the existence test runs on the
resolved path, so a new ADR stays creatable. A missing helper or jq fails open
naming the ADR job. hook-contract-fixture.sh's early-reader check reads lib/*.sh;
section Hook authoring states the sourced-helper contract and the lib/ gitignore
trap, and the block asserts the helper is not ignored.

Red first: FAIL [protect-immutable-adrs.sh]: a .. segment (docs/sub/../adr/) (want exit 2, got 0)

Trace: #60/body/fix, #60/body/alt, #60/body/fixture, #60/c5876324022/table,
#60/c5876324022/closed-1, closed-2, closed-3, closed-4,
#60/c5876324022/closed-5, closed-6, #60/c5876324022/closed-note,
#60/c5881158391/port-helper, #60/c5892401033/helper,
#60/c5892401033/adr-path-independent, #60/c5892401033/linked-worktrees,
#60/c5892401033/ef-inode, #60/c5892401033/gitignore-trap,
#60/c5892401033/fixture, #60/c5901494943/2a, 2b, 2c, 2d, 2e,
#62/body/extra-adr-hook,
#58/c5901493591/R1 (the path guard), release/5 (section Hook authoring),
#69/c5859756889/apply-h4/1 (a target's own hooks, held to the same contract),
review/consistency/48 (the tally, rewritten count-free).
Decisions: D43, D44, D61.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
```
Expected from `git ls-files -s`: `100644`.
### Task V2.3: Every fail-open names its backstop, and an unreadable payload is refused or asked (#62/body/lock-files, #62/body/pr-state, #62/body/main-branch, #58/c5901493591/R8, #58/c5901493591/R1 (the four guards), critic/8, #66/body/2 (the ask-gate header), release/5 (protect-lock-files.sh); D61, D44)

**Files:**
- Create: `.claude/workflows/tests/hook-guards-fixture.sh` (mode 755)
- Modify: `.claude/hooks/protect-lock-files.sh` (header lines 9–22, the jq warning at line 40, the fallback arm at lines 82–86)
- Modify: `.claude/hooks/protect-main-branch.sh` (header lines 21–24, gaining a `Depends:` line after `Tier:`; the jq warning at lines 36–37, the non-repo warning at line 67)
- Modify: `.claude/hooks/guard-pr-state.sh` (header lines 14–16, the jq warning at lines 26–27)
- Modify: `.claude/hooks/require-knowledge-backend-ok.sh` (header lines 2–9 and 17)
- Modify: `.claude/rules/cbk-conventions-reference.md` — § Hook authoring's Fail-open bullet; § Verification's kit and project sentinels
- Modify: `.claude/skills/scaffold/references/bootstrap_checklist_template.md` — § 4 Rule-file disposition, the one-time choices list

**Interfaces:**
- Produces: `.claude/workflows/tests/hook-guards-fixture.sh`. It finds the knowledge-backend ask-gate through `settings.json` — the `.sh` path in the `command` or `args` of the `PreToolUse` entry whose matcher starts `mcp__` — never by name, so V3's move to exec form does not break it (tested on shell form, on `args: []` and on `command: "bash"` with the path in `args`). With no such entry it prints `SKIP: the knowledge-backend ask-gate (no mcp__ matcher in settings.json — the knowledge axis is none)` — the line V5's knowledge-axis-`none` dry run expects (Review Focus 3).
- Produces: the wording the fixture pins, which any later edit to these hooks keeps: `BLOCKED`, `git switch -c`, `not a git repo`, `jq not installed`, `Backstop`, `Backstops`, `could not read the tool payload`, `package-manager-managed`, `pnpm install`, `fallback arm`, "above the `*.lock)` arm", and the absence of `exemption comment`.
- Produces: three bracketed backstop slots — `[the project's CI lockfile check — …]` in `protect-lock-files.sh`, and `[the base branch's ruleset — pull requests only — where one exists]` in both warnings of `protect-main-branch.sh` — the bootstrap row `**Hook backstop slots**` that fills them, and the project-sub-block check `absent grep -nE 'Backstops?( until then)?: \[' .claude/hooks/*.sh` that refuses one left unfilled.
- Produces: the § Hook authoring sentence `**An unreadable payload is not an environment defect.**`, cited by every hook header this cluster touches. V3's registry comment restates the fail-open rule with it (§ Handed to other clusters).

- [ ] **Step 1: Write the failing fixture**

Create `.claude/workflows/tests/hook-guards-fixture.sh`:
```bash
#!/usr/bin/env bash
# Behavioural cases for the four guards no other fixture drives by payload: the main-branch deny
# (protect-main-branch.sh), the PR-state ask-gate (guard-pr-state.sh), the lock-file deny (protect-lock-files.sh) and
# the knowledge-backend ask-gate — every branch each documents in its header gets a crafted payload and an asserted
# exit or decision (§ Hook authoring › Verify by payload, made durable; context-builder-kit#58 item 4). A payload jq
# cannot read is refused by each deny and asked by each ask-gate; each fail-open warning names what still stands; one
# case per deny runs from a project root containing a space. hook-contract-fixture.sh checks every hook's structure
# and one over-buffer probe per decision site; hook-payloads-fixture.sh drives the launch-root guard and the fork
# detector; protected-paths-hook-fixture.sh drives the path guard. The two advisory exemplars (format-on-edit.sh,
# analyze-on-edit.sh) ship with no live case arm, so there is no branch to drive until a target fills one.
# The knowledge-backend guard is found by the registry, not by name: the script (the `command`, or an `args` element,
# ending in .sh) of the settings.json entry whose matcher names a knowledge-backend MCP tool (mcp__…), so shell form
# and exec form both resolve. A target whose knowledge axis is `none` deletes that guard and its stanza at the
# bootstrap disposition pass, and its cases then print a SKIP line.
# Every case runs against throwaway `git init` trees under mktemp, never the real repository; the hooks run from their
# real path, so a change to any of them is caught. Needs bash, git and jq; runs in throwaway trees.
# Run by the verification block; also: bash .claude/workflows/tests/hook-guards-fixture.sh
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
hooks="$here/../../hooks"
settings="$here/../../settings.json"
MAIN="$hooks/protect-main-branch.sh"; PRS="$hooks/guard-pr-state.sh"; LOCK="$hooks/protect-lock-files.sh"
for h in "$MAIN" "$PRS" "$LOCK"; do [ -x "$h" ] || { echo "hook-guards-fixture: $h is missing or not executable"; exit 1; }; done
command -v jq >/dev/null && command -v git >/dev/null || { echo "hook-guards-fixture: needs jq and git"; exit 1; }
[ -f "$settings" ] || { echo "hook-guards-fixture: $settings is missing"; exit 1; }
kbname=$(jq -r '[.hooks.PreToolUse[]? | select((.matcher // "") | test("^mcp__")) | .hooks[] | [.command] + (.args // []) | map(select(type == "string" and endswith(".sh"))) | .[0] // empty] | first // empty' "$settings")
KB=""; [ -z "$kbname" ] || KB="$hooks/${kbname##*/}"
d=$(mktemp -d)
trap 'rm -rf "$d"' EXIT
# Git discovery stops at the throwaway root (the ceiling is its parent), so a TMPDIR inside a work tree cannot turn
# the non-checkout case into a checkout.
export GIT_CEILING_DIRECTORIES="${d%/*}"

repo_on() {  # repo_on <dir> <branch>: a throwaway checkout with one commit, on <branch>
  git -c init.defaultBranch=main init -q "$1"
  git -C "$1" -c user.email=t@t -c user.name=t -c commit.gpgsign=false commit -q --allow-empty -m x
  [ "$2" = main ] || git -C "$1" switch -q -c "$2"
}
repo_on "$d/on-main" main; repo_on "$d/on-master" main; git -C "$d/on-master" branch -q -m master; repo_on "$d/on-feat" feat/x
repo_on "$d/a b" main
mkdir -p "$d/plain"

n=0; RC=0; OUT=""; ERR=""
run() {  # run <hook> <payload> [env args…]: RC, OUT (stdout), ERR (stderr); runs in $RUN_CWD when it is set
  local hook=$1 payload=$2; shift 2
  RC=0; OUT="$(cd "${RUN_CWD:-$PWD}" && printf '%s' "$payload" | env "$@" "$hook" 2>"$d/err")" || RC=$?; ERR="$(cat "$d/err")"; n=$((n + 1))
}
want() { [ "$RC" -eq "$1" ] || { echo "FAIL: $2 (want exit $1, got $RC)"; [ -n "$ERR" ] && printf '  stderr: %s\n' "$ERR"; exit 1; }; }
says() { grep -q -- "$1" <<<"$ERR" || { echo "FAIL: $2 (stderr lacks '$1')"; printf '  stderr: %s\n' "$ERR"; exit 1; }; }
asks() { [ "$RC" -eq 0 ] && jq -e '.hookSpecificOutput.permissionDecision == "ask"' >/dev/null 2>&1 <<<"$OUT" \
  || { echo "FAIL: $1 (want an ask decision on stdout, exit 0; got exit $RC)"; printf '  stdout: %s\n' "$OUT"; exit 1; }; }
silent() { [ "$RC" -eq 0 ] && [ -z "$OUT" ] || { echo "FAIL: $1 (want exit 0 and no decision; got exit $RC)"; printf '  stdout: %s\n' "$OUT"; exit 1; }; }
bash_payload() { jq -cn --arg c "$1" --arg cwd "$2" '{tool_name:"Bash", tool_input:{command:$c}, cwd:$cwd}'; }
edit_payload() { jq -cn --arg t "$1" --arg f "$2" '{tool_name:$t, tool_input:{file_path:$f}}'; }
surrogate() { printf '{"tool_name":"%s","tool_input":{"%s":"%s","content":"x\\ud800y"},"cwd":"%s"}' "$1" "$2" "$3" "$4"; }
nojq="$d/nojq"; mkdir -p "$nojq"
for t in bash cat git basename dirname; do p=$(type -P "$t" || true); [ -n "$p" ] && ln -sf "$p" "$nojq/$t"; done

# ── protect-main-branch.sh (HARD-DENY: a `git commit` on main or master) ──
run "$MAIN" "$(bash_payload 'git commit -m x' "$d/on-main")";        want 2 "a commit on main is denied"
says "BLOCKED" "the denial names itself"; says "git switch -c" "the denial gives the branch-first remediation"
run "$MAIN" "$(bash_payload 'git commit -m x' "$d/on-master")";      want 2 "a commit on master is denied"
run "$MAIN" "$(bash_payload 'git commit -m x' "$d/on-feat")";        want 0 "a commit on a feature branch is allowed"
run "$MAIN" "$(bash_payload 'git -C . commit -m x' "$d/on-main")";   want 2 "options between git and commit are still a commit"
run "$MAIN" "$(bash_payload 'git add -A && git commit -m x' "$d/on-main")"; want 2 "a commit after && is still a commit"
run "$MAIN" "$(bash_payload 'echo legit commitment' "$d/on-main")";  want 0 "text merely containing the phrase is allowed"
run "$MAIN" "$(bash_payload 'git status' "$d/on-main")";             want 0 "a non-commit git command is allowed"
run "$MAIN" "$(jq -cn --arg cwd "$d/on-main" '{tool_name:"Edit", tool_input:{file_path:"x"}, cwd:$cwd}')"; want 0 "a non-Bash tool passes through"
run "$MAIN" "$(bash_payload '' "$d/on-main")";                       want 0 "an empty command passes through"
run "$MAIN" "$(bash_payload 'git commit -m x' "$d/a b")";            want 2 "a commit on main under a project root containing a space is denied"
# The payload's cwd wins over CLAUDE_PROJECT_DIR, both ways (the two disagree in a worktree session).
run "$MAIN" "$(bash_payload 'git commit -m x' "$d/on-feat")" CLAUDE_PROJECT_DIR="$d/on-main"; want 0 "payload cwd on a feature branch wins over a project dir on main"
run "$MAIN" "$(bash_payload 'git commit -m x' "$d/on-main")" CLAUDE_PROJECT_DIR="$d/on-feat"; want 2 "payload cwd on main wins over a project dir on a feature branch"
run "$MAIN" "$(jq -cn '{tool_name:"Bash", tool_input:{command:"git commit -m x"}}')" CLAUDE_PROJECT_DIR="$d/on-main"; want 2 "with no payload cwd, the project dir decides"
# With neither a payload cwd nor CLAUDE_PROJECT_DIR, the hook's own working directory decides ($PWD, the last fallback).
RUN_CWD="$d/on-main" run "$MAIN" "$(jq -cn '{tool_name:"Bash", tool_input:{command:"git commit -m x"}}')" -u CLAUDE_PROJECT_DIR; want 2 "with no cwd and no project dir, \$PWD on main is denied"
RUN_CWD="$d/on-feat" run "$MAIN" "$(jq -cn '{tool_name:"Bash", tool_input:{command:"git commit -m x"}}')" -u CLAUDE_PROJECT_DIR; want 0 "with no cwd and no project dir, \$PWD on a feature branch is allowed"
# A commit with nothing after it — the end-of-command form, reached after && or alone.
run "$MAIN" "$(bash_payload 'git add -A && git commit' "$d/on-main")"; want 2 "a bare commit at the end of the command is still a commit"
run "$MAIN" "$(bash_payload 'git commit' "$d/on-main")";             want 2 "a bare commit alone is a commit"
# Fail-open branches name what still stands.
run "$MAIN" "$(bash_payload 'git commit -m x' "$d/plain")";          want 0 "a directory that is not a checkout fails open"
says "not a git repo" "the non-checkout warning says why"; says "Backstop" "the non-checkout warning names a backstop"
run "$MAIN" "$(bash_payload 'git commit -m x' "$d/on-main")" -i PATH="$nojq" HOME="$HOME"; want 0 "no jq fails open"
says "jq not installed" "the no-jq warning says why"; says "Backstops" "the no-jq warning names the backstops"
# Input it cannot read is refused, on any branch: the guard cannot tell what it is.
run "$MAIN" "$(surrogate Bash command 'git commit -m x' "$d/on-feat")"; want 2 "a payload jq cannot parse is refused"
says "could not read the tool payload" "the refusal says why"
run "$MAIN" '["not", "an", "object"]';                               want 2 "a payload that is not an object is refused"

# ── guard-pr-state.sh (ASK-GATE: a PR-state change) ──
for c in 'gh pr merge 7 --squash' 'gh pr ready 7' 'gh pr close 7' 'gh pr reopen 7' \
         'gh -R o/r pr merge 7' 'gh pr --repo o/r ready 7' 'git push && gh pr merge 7' \
         'gh pr merge' 'gh pr ready' 'git push && gh pr merge'; do  # the bare forms act on the current branch's PR
  run "$PRS" "$(bash_payload "$c" "$d/on-feat")"; asks "a PR-state change asks: $c"
done
for c in 'gh pr create --draft' 'gh pr view 7' 'gh pr list' 'gh pr checks 7' 'gh issue close 7'; do
  run "$PRS" "$(bash_payload "$c" "$d/on-feat")"; silent "no decision for: $c"
done
run "$PRS" "$(jq -cn '{tool_name:"Edit", tool_input:{file_path:"x"}}')"; silent "a non-Bash tool passes through"
run "$PRS" "$(bash_payload 'gh pr merge 7' "$d/on-feat")" -i PATH="$nojq" HOME="$HOME"; want 0 "no jq fails open"
says "jq not installed" "the no-jq warning says why"; says "Backstop" "the no-jq warning names what still stands"
run "$PRS" "$(surrogate Bash command 'gh pr merge 7' "$d/on-feat")"; asks "a payload jq cannot parse gets the prompt"
run "$PRS" 'not json at all';                                        asks "a payload that is not JSON gets the prompt"

# ── protect-lock-files.sh (HARD-DENY: a hand edit to a lock file) ──
for f in uv.lock pnpm-lock.yaml package-lock.json yarn.lock Cargo.lock Gemfile.lock poetry.lock composer.lock mix.lock pubspec.lock; do
  run "$LOCK" "$(edit_payload Edit "$d/on-feat/$f")"; want 2 "a hand edit to $f is denied"
  says "package-manager-managed" "$f is denied by its named arm, not the fallback"
done
run "$LOCK" "$(edit_payload Write "$d/on-feat/frontend/pnpm-lock.yaml")"; want 2 "a nested lock file is denied too"
says "pnpm install" "the named arm gives its package manager"
run "$LOCK" "$(edit_payload Edit "$d/a b/uv.lock")";                want 2 "a lock file under a project root containing a space is denied"
run "$LOCK" "$(edit_payload MultiEdit "$d/on-feat/flake.lock")"; want 2 "an unnamed *.lock is denied by the fallback arm"
says "fallback arm" "the fallback denial names itself"
says "above the \`\*.lock)\` arm" "the fallback gives the real route for a non-lock file: a case arm above it"
! grep -q "exemption comment" <<<"$ERR" || { echo "FAIL: the fallback still points at an exemption comment the hook does not have"; exit 1; }
for f in pyproject.toml lockfile.md uv.lock.md docs/locking.lock.txt; do
  run "$LOCK" "$(edit_payload Edit "$d/on-feat/$f")"; want 0 "a non-lock file is allowed: $f"
done
run "$LOCK" "$(edit_payload Read "$d/on-feat/uv.lock")"; want 0 "a read of a lock file is allowed"
run "$LOCK" "$(jq -cn '{tool_name:"Edit", tool_input:{}}')";   want 0 "an empty file_path passes through"
run "$LOCK" "$(edit_payload Edit "$d/on-feat/uv.lock")" -i PATH="$nojq" HOME="$HOME"; want 0 "no jq fails open"
says "jq not installed" "the no-jq warning says why"; says "Backstop" "the no-jq warning names what still stands"
run "$LOCK" "$(surrogate Write file_path "$d/on-feat/uv.lock" "$d/on-feat")"; want 2 "a payload jq cannot parse is refused"
says "could not read the tool payload" "the refusal says why"

# ── the knowledge-backend ask-gate (ASK-GATE: every knowledge-backend write) — asks whatever the payload ──
if [ -n "$KB" ]; then
  [ -x "$KB" ] || { echo "FAIL: settings.json registers ${kbname##*/}, which is missing or not executable"; exit 1; }
  run "$KB" '{"tool_name":"mcp__notion__notion-update-page","tool_input":{"page_id":"x"}}'; asks "a knowledge-backend write asks"
  run "$KB" 'not json at all';                                                           asks "an unparseable payload still asks (no parse, no fail-open)"
  run "$KB" '';                                                                          asks "an empty payload still asks"
else
  echo "SKIP: the knowledge-backend ask-gate (no mcp__ matcher in settings.json — the knowledge axis is none)"
fi

echo "hook-guards-fixture: $n cases ok"
```

Run: `chmod 755 .claude/workflows/tests/hook-guards-fixture.sh`

- [ ] **Step 2: Run it against the unfixed hooks**

Run: `bash .claude/workflows/tests/hook-guards-fixture.sh; echo "exit=$?"`
Expected:
```text
FAIL: the non-checkout warning names a backstop (stderr lacks 'Backstop')
  stderr: protect-main-branch: WARNING — /tmp/tmp.XXXXXXXXXX/plain is not a git repo; guard inactive for this call.
exit=1
```
(the temp path varies). Record the FAIL line in the red-first table. The unreadable-payload cases sit at the end of each guard's section; each is red on the unfixed hooks too (exit 0 for a lone-surrogate payload, D61's probe at `74edf84`).

- [ ] **Step 3: Land the wording, the refusals and the rule**

No platform fact is new here: the ask-gate's ten-verb rationale is moved, unchanged and still dated 2026-09-21, from the registry comment into the hook header (#66/body/2's first half; the trim of the registry comment is V9's and V3's).

Edit `.claude/hooks/protect-lock-files.sh` — replace this text (exact; it occurs once):
```bash
# Allowed:
#   - Bash invocations of the package manager (the proper way to change locks)
#   - Reads of lock files (no Edit/Write involved)
# Blocked:
#   - Edit/Write/MultiEdit on lock files
#
# Hook receives JSON on stdin with the tool input. Exit 2 + stderr blocks.
#
# Fail-open on environment defects (missing jq, unset CLAUDE_PROJECT_DIR):
# exit 0 with a loud stderr warning. The alternative (failing closed) converts
# a targeted lock-file block into a universal Edit/Write/MultiEdit block, which
# is worse than allowing a lock-file edit to slip through. The operator notices
# the warning and fixes their environment.
# Tier:     HARD-DENY (see the registry comment in .claude/settings.json).
```
with:
```bash
# Allowed:  Bash invocations of the package manager (the proper way to change locks); reads of lock
#           files (no Edit/Write involved); a file with a case arm of its own above the `*.lock)` arm.
# Blocked:  Edit/Write/MultiEdit on a lock file — a named ecosystem's, or any other `*.lock` by the
#           fallback arm; and a payload jq cannot read, whose path cannot be checked.
# Not seen: an edit through a symlink under another name (the guard decides on the path text, so a
#           link named deps.txt that points at uv.lock passes), and a write through the Bash tool
#           (unmatched on purpose: the package manager is the route). The project's CI lockfile
#           check, where one exists, refuses a drifted lock at PR time.
# Tier:     HARD-DENY (see the registry comment in .claude/settings.json).
# Depends:  jq (the payload) — absent, the guard fails open: exit 0 with a stderr warning naming the
#           project's CI lockfile check as the backstop (a bracketed slot the project fills).
#
# Hook receives JSON on stdin with the tool input. Exit 2 + stderr blocks. Fail-open on environment
# defects (missing jq, unset CLAUDE_PROJECT_DIR): exit 0 with a loud stderr warning — failing closed
# would turn a targeted lock-file block into a universal Edit/Write/MultiEdit block. Input the guard
# cannot read is not an environment defect, and is refused (cbk-conventions-reference.md § Hook
# authoring). Fixture: .claude/workflows/tests/hook-guards-fixture.sh.
```


Edit `.claude/hooks/protect-lock-files.sh` — replace this text (exact; it occurs once):
```bash
  echo "                    Install jq to re-enable. Lock-file edits will NOT be caught until fixed." >&2
  exit 0
fi
```
with:
```bash
  echo "                    Install jq to re-enable. Backstop until then: [the project's CI lockfile check — a" >&2
  echo "                    locked or frozen-lockfile install that fails when the lock file and its manifest disagree]." >&2
  exit 0
fi

# A payload jq cannot read is refused, never waved through: this hook runs on Edit|Write|MultiEdit only,
# so the call is still a file write, and its path cannot be checked (a lone UTF-16 surrogate escape
# anywhere in the tool input does this).
if ! jq -e 'type == "object"' >/dev/null 2>&1 <<<"$input"; then
  echo "BLOCKED: protect-lock-files could not read the tool payload (not parseable JSON, or not an object)," >&2
  echo "so its path cannot be checked. A lone UTF-16 surrogate escape in the tool input does this — remove it and retry." >&2
  exit 2
fi
```


Edit `.claude/hooks/protect-lock-files.sh` — replace this text (exact; it occurs once):
```bash
by construction rather than by an edit, #58 item 3).
Run the package manager that owns it instead of editing it by hand. If this file is
NOT a lock file, add its name to the hook's exemption comment and say so in the PR.
```
with:
```bash
by construction rather than by an edit, context-builder-kit#58 item 3).
Run the package manager that owns it instead of editing it by hand. If this file is
NOT a lock file, give it a case arm of its own above the \`*.lock)\` arm in this hook
(an arm that exits 0), and say so in the PR.
```


Edit `.claude/hooks/protect-main-branch.sh` — replace this text (exact; it occurs once):
```bash
# Hook receives JSON on stdin with the tool input. Exit 2 + stderr blocks.
# Fail-open on environment defects (missing jq, non-repo cwd): exit 0 with a
# loud stderr warning, mirroring protect-lock-files.sh.
# Tier:     HARD-DENY (see the registry comment in .claude/settings.json).
```
with (the hook gains the `Depends:` line every header carries, which it lacked):
```bash
# Hook receives JSON on stdin with the tool input. Exit 2 + stderr blocks.
# Fail-open on environment defects (missing jq, non-repo cwd): exit 0 with a
# loud stderr warning naming the backstops, mirroring protect-lock-files.sh.
# A payload jq cannot read is refused (cbk-conventions-reference.md § Hook
# authoring). Fixture: .claude/workflows/tests/hook-guards-fixture.sh.
# Tier:     HARD-DENY (see the registry comment in .claude/settings.json).
# Depends:  jq (the payload) and git (the branch) — absent jq, the guard fails
#           open: exit 0 with a stderr warning naming the backstops; absent git,
#           or a working directory that is not a checkout, the same.
```


Edit `.claude/hooks/protect-main-branch.sh` — replace this text (exact; it occurs once):
```bash
  echo "                     Install jq to re-enable. Until then the only backstop is the operator" >&2
  echo "                     noticing a commit on main before pushing." >&2
  exit 0
fi
```
with:
```bash
  echo "                     Install jq to re-enable. Backstops until then: [the base branch's ruleset —" >&2
  echo "                     pull requests only — where one exists], and the operator noticing a commit" >&2
  echo "                     on local main before branching." >&2
  exit 0
fi

# A payload jq cannot read is refused: its command and working directory cannot be checked, and a
# guard that waved it through would fall to one lone UTF-16 surrogate escape in the command.
if ! jq -e 'type == "object"' >/dev/null 2>&1 <<<"$input"; then
  echo "BLOCKED: protect-main-branch could not read the tool payload (not parseable JSON, or not an object)," >&2
  echo "so it cannot tell whether this is a commit on main. A lone UTF-16 surrogate escape in the command does this — remove it and retry." >&2
  exit 2
fi
```


Edit `.claude/hooks/protect-main-branch.sh` — replace this text (exact; it occurs once):
```bash
  echo "protect-main-branch: WARNING — $PROJECT_DIR is not a git repo; guard inactive for this call." >&2
  exit 0
```
with:
```bash
  echo "protect-main-branch: WARNING — $PROJECT_DIR is not a git repo; guard inactive for this call." >&2
  echo "                     Backstop: [the base branch's ruleset — pull requests only — where one exists]." >&2
  exit 0
```


Edit `.claude/hooks/guard-pr-state.sh` — replace this text (exact; it occurs once):
```bash
# Fail-open on environment defects (missing jq), mirroring
# protect-lock-files.sh.
# Tier:     ASK-GATE (see the registry comment in .claude/settings.json).
```
with:
```bash
# Tier:     ASK-GATE (see the registry comment in .claude/settings.json).
# Depends:  jq (the payload) — absent, the guard fails open: exit 0 with a stderr
#           warning that says no mechanical backstop exists. A payload jq cannot
#           read is not an environment defect: it gets the prompt
#           (cbk-conventions-reference.md § Hook authoring).
# Fixture:  .claude/workflows/tests/hook-guards-fixture.sh.
```


Edit `.claude/hooks/guard-pr-state.sh` — replace this text (exact; it occurs once):
```bash
  echo "                Until fixed, the only backstop is the prose rule in /finish and" >&2
  echo "                /pr-respond that PR-state changes are the operator's calls." >&2
  exit 0
fi
```
with:
```bash
  echo "                Install jq to re-enable. Backstop until then: none mechanical — every" >&2
  echo "                gh pr ready/merge/close/reopen needs the operator's explicit per-action OK." >&2
  exit 0
fi

# A payload jq cannot read gets the prompt, never a pass: its command cannot be checked, so the
# operator decides.
if ! jq -e 'type == "object"' >/dev/null 2>&1 <<<"$input"; then
  cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "ask",
    "permissionDecisionReason": "guard-pr-state could not read this tool payload (not parseable JSON, or not an object), so it cannot tell whether the command changes a PR's state. Approve only if the operator asked for exactly this command."
  }
}
EOF
  exit 0
fi
```


Edit `.claude/hooks/require-knowledge-backend-ok.sh` — replace this text (exact; it occurs once):
```bash
# PreToolUse hook: force a per-action operator confirmation on every
# knowledge-backend WRITE tool call. The matcher in settings.json owns the
# tool-name pattern — the shipped regex covers Notion (the kit's v1 reference
# knowledge backend) mutating verbs (create/update/move/duplicate/convert/
# delete) across both the direct mcp__notion__* and plugin-namespaced tool
# names; when the MCP grows a new mutating verb, widen the matcher — and
# adjust it to your configured MCP's tool names if your knowledge backend
# differs. Reads (fetch/search) are unmatched and unaffected.
```
with:
```bash
# PreToolUse hook: force a per-action operator confirmation on every
# knowledge-backend WRITE tool call. The matcher in settings.json owns the
# tool-name pattern. The shipped regex covers the ten mutating verbs of Notion
# (the kit's v1 reference knowledge backend), across both the direct
# mcp__notion__* and plugin-namespaced tool names: create, update, move,
# duplicate, convert and delete, plus upload (upload-skill replaces a page's
# body), spawn and send (spawn-session and send-message-to-session drive an
# agent that writes) and stop (stop-session). The verb list is a dated
# observation of the vendor's tool names (2026-09-21): re-verify it when the
# MCP's tool list changes, widen the matcher for a new mutating verb, and
# adjust it to your configured MCP's tool names if your knowledge backend
# differs. Reads (fetch/search) are unmatched and unaffected.
```


Edit `.claude/hooks/require-knowledge-backend-ok.sh` — replace this text (exact; it occurs once):
```bash
# Tier:     ASK-GATE (see the registry comment in .claude/settings.json).

set -uo pipefail
# Drain stdin first
```
with:
```bash
# Tier:     ASK-GATE (see the registry comment in .claude/settings.json).
# Depends:  nothing — the decision is unconditional for a matched tool, so the
#           payload is never parsed, and an unreadable one asks like any other
#           (cbk-conventions-reference.md § Hook authoring).
# Fixture:  .claude/workflows/tests/hook-guards-fixture.sh.

set -uo pipefail
# Drain stdin first
```


Edit `.claude/rules/cbk-conventions-reference.md` — replace this text (exact; it occurs once):
```markdown
a guard exits 0 with a stderr warning that names the surviving backstop — the CI lint, the Stop-tier hook, the verification block — never fails closed into a universal block. 
```
with:
```markdown
a guard exits 0 with a stderr warning that names the surviving backstop — the CI lint, the Stop-tier hook, the verification block — never fails closed into a universal block. **An unreadable payload is not an environment defect.** Input the guard cannot read — JSON jq cannot parse (a lone UTF-16 surrogate escape anywhere in the tool input does it) or a value that is not an object — cannot be checked, so a hard-deny guard refuses it (exit 2, saying why) and an ask-gate asks; waving it through would let one crafted character bypass the guard (context-builder-kit#60). A backstop only the project can supply — a CI lockfile check, the base branch's ruleset — ships as a bracketed slot in the warning, filled at scaffold's rule-file disposition pass; the project sub-block refuses a slot left unfilled. 
```


Edit `.claude/rules/cbk-conventions-reference.md` — replace this text (exact; it occurs once):
```markdown
  echo "verification: project sub-block complete"
```
with:
```markdown
  # A hook's fail-open warning names the backstop that still stands; where that backstop is the project's own (a CI
  # lockfile check, the base branch's ruleset) the kit ships a bracketed slot, filled at scaffold's rule-file
  # disposition pass (§ Hook authoring). An unfilled slot prints a placeholder at the moment the guard is down.
  absent grep -nE 'Backstops?( until then)?: \[' .claude/hooks/*.sh

  echo "verification: project sub-block complete"
```


Edit `.claude/skills/scaffold/references/bootstrap_checklist_template.md` — replace this text (exact; it occurs once):
```markdown
- **Orchestration posture** recorded in `.claude/rules/orchestration.md` § The ceiling rule — which row the main loop runs by default (the exercised default is the workhorse tier) and what a deliberate escalation to the top tier looks like, dated with the reason. Decision: <workhorse | top-tier escalation, dated>.
```
with:
```markdown
- **Orchestration posture** recorded in `.claude/rules/orchestration.md` § The ceiling rule — which row the main loop runs by default (the exercised default is the workhorse tier) and what a deliberate escalation to the top tier looks like, dated with the reason. Decision: <workhorse | top-tier escalation, dated>.
- **Hook backstop slots**: two guards' fail-open warnings name a backstop only the project can supply — `protect-lock-files.sh`'s `[the project's CI lockfile check …]`, and `protect-main-branch.sh`'s `[the base branch's ruleset …]` (in both of its warnings). Replace each bracket with the real check or ruleset, or with `none` and the reason. Decision: <lockfile check | none — reason> · <ruleset | none — reason>. The project sub-block of the verification block refuses a slot left bracketed.
```


Edit `.claude/rules/cbk-conventions-reference.md` — in § Verification, replace the kit sentinel line (exact; it occurs once):
```bash
echo "verification: kit sub-block complete"
```
with (the new checks sit immediately before it):
```bash
# The four guards no other fixture drives by payload — the main-branch deny, the PR-state ask-gate, the lock-file
# deny (every named arm, the *.lock fallback, the non-lock neighbours) and the knowledge-backend ask-gate, found by
# its registry entry — on every branch their headers document: an unreadable payload refused by a deny and asked by
# an ask-gate, each fail-open warning naming what still stands, one deny per guard from a root containing a space
# (context-builder-kit#58 item 4, context-builder-kit#62). Needs git and jq; runs in throwaway trees.
bash .claude/workflows/tests/hook-guards-fixture.sh || { echo "a guard regressed on its fixture (protect-main-branch.sh / guard-pr-state.sh / protect-lock-files.sh / the knowledge-backend ask-gate)"; exit 1; }
echo "verification: kit sub-block complete"
```

- [ ] **Step 4: Run the fixture, `bash -n`, the slot check and the block**

Run: `bash .claude/workflows/tests/hook-guards-fixture.sh; echo "exit=$?"`
Expected: `hook-guards-fixture: 64 cases ok`, `exit=0`.

Run: `for h in protect-lock-files protect-main-branch guard-pr-state require-knowledge-backend-ok; do bash -n .claude/hooks/$h.sh || echo "SYNTAX: $h"; done; bash .claude/workflows/tests/hook-contract-fixture.sh`
Expected: `hook-contract-fixture: ok` and no `SYNTAX:` line.

Run (the project-sub-block check bites on the unfilled kit tree, as it must in a target that skipped the slots): `grep -nE 'Backstops?( until then)?: \[' .claude/hooks/*.sh | cut -d: -f1,2`
Expected: `.claude/hooks/protect-lock-files.sh:43`, `.claude/hooks/protect-main-branch.sh:41`, `.claude/hooks/protect-main-branch.sh:82` (line numbers as measured in the scratch replay).

Run (the knowledge-axis-`none` skip, in a scratch copy):
```bash
S=$(mktemp -d) && cp -a . "$S/kit" && cd "$S/kit" \
&& jq '.hooks.PreToolUse |= map(select(.matcher | test("^mcp__") | not))' .claude/settings.json > "$S/s.json" && mv "$S/s.json" .claude/settings.json \
&& rm .claude/hooks/require-knowledge-backend-ok.sh && bash .claude/workflows/tests/hook-guards-fixture.sh | tail -2; cd - >/dev/null; rm -rf "$S"
```
Expected: `SKIP: the knowledge-backend ask-gate (no mcp__ matcher in settings.json — the knowledge axis is none)` then `hook-guards-fixture: 61 cases ok`.

Run (V1's hand-off item 3 — Review Focus 4 keeps holding: a fresh scaffold is red until the disposition pass fills the slots, then prints all three sentinels. It uses V1.4's helper `${TMPDIR:-/tmp}/v1-fresh-scaffold.sh`; if it is gone, re-create it from V1.4 Step 1's `cat > … <<'EOF'` block first. The helper is not committed, and the slot lines stay in it for V5's re-run):
```bash
. "${TMPDIR:-/tmp}/v1-fresh-scaffold.sh"; fresh_scaffold yes
echo ---
h="${TMPDIR:-/tmp}/v1-fresh-scaffold.sh"
cat > "${TMPDIR:-/tmp}/v2-slots.txt" <<'EOF'
  # The disposition pass fills the hook backstop slots (bootstrap checklist § 4, Hook backstop slots; V2.3).
  sed -i -e "s/until then: \[the project's CI lockfile check — a/until then: the CI job's \`uv sync --locked\` — a/" -e 's/its manifest disagree\]\./its manifest disagree./' "$t/.claude/hooks/protect-lock-files.sh"
  sed -i -e "s/until then: \[the base branch's ruleset —/until then: the base branch's ruleset —/" -e 's/where one exists\], and the operator/where one exists, and the operator/' -e "s/Backstop: \[the base branch's ruleset — pull requests only — where one exists\]\./Backstop: the base branch's ruleset (pull requests only)./" "$t/.claude/hooks/protect-main-branch.sh"
EOF
n=$(grep -n 'rules/testing.md"$' "$h" | cut -d: -f1); grep -q 'Hook backstop slots' "$h" || sed -i "${n}r ${TMPDIR:-/tmp}/v2-slots.txt" "$h"
. "$h"; fresh_scaffold yes
```
Expected: `exit=1`, `verification: kit sub-block complete`, `verification: block exited 1` (the project sub-block's slot check), then `---`, then `exit=0`, `verification: kit sub-block complete`, `verification: project sub-block complete`, `verification: done`. Every V2 fixture this task and V2.1–V2.2 added runs green inside the scaffolded target too.

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'hook-guards-fixture|^verification: (kit sub-block complete|done)$|^verification: block exited'; echo "exit=${PIPESTATUS[0]}"`
Expected: `hook-guards-fixture: 64 cases ok`, `verification: kit sub-block complete`, `verification: done`, `exit=0`.

- [ ] **Step 5: Commit**

```bash
git add .claude/workflows/tests/hook-guards-fixture.sh .claude/hooks/protect-lock-files.sh .claude/hooks/protect-main-branch.sh .claude/hooks/guard-pr-state.sh .claude/hooks/require-knowledge-backend-ok.sh .claude/rules/cbk-conventions-reference.md .claude/skills/scaffold/references/bootstrap_checklist_template.md
git commit -q -F - <<'MSG'
fix(V2): every fail-open names its backstop; an unreadable payload is refused or asked

The lock-file, main-branch and PR-state guards failed open on a payload jq cannot
parse (one lone UTF-16 surrogate escape); the two denies now refuse it and the
ask-gate asks, and section Hook authoring says why an unreadable payload is not an
environment defect. Each fail-open warning names what still stands: a bracketed
slot for the project's CI lockfile check and for the base branch's ruleset, filled
at scaffold's rule-file disposition pass (a new bootstrap row) and refused unfilled
by the project sub-block; the PR-state gate says no mechanical backstop exists.
The lock-file fallback's remediation names the real route, a case arm above the
*.lock) arm. The knowledge-backend ask-gate's header carries its ten verbs, and
protect-main-branch.sh gains the Depends: line every header carries.
hook-guards-fixture.sh drives every branch of the four guards, finds the ask-gate
through the registry, and runs one deny per guard from a root containing a space.

Red first: FAIL: the non-checkout warning names a backstop (stderr lacks 'Backstop')

Trace: #62/body/lock-files, #62/body/pr-state, #62/body/main-branch,
#58/c5901493591/R8, #58/c5901493591/R1 (the four guards), critic/8,
#66/body/2 (the ask-gate header), release/5 (protect-lock-files.sh).
Decisions: D61, D44.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
```
### Task V2.4: The main-branch and PR-state patterns anchor on non-word characters (review/security/20, #68/body/1a (the guard's remediation); D44)

**Files:**
- Modify: `.claude/workflows/tests/hook-guards-fixture.sh` (two insertions)
- Modify: `.claude/hooks/protect-main-branch.sh` (header `Blocked:`/`Allowed:` lines 10–14, the pattern comment at lines 52–59, the pattern at line 62, the remediation at lines 78–79)
- Modify: `.claude/hooks/guard-pr-state.sh` (header, the pattern comment at lines 37–39, the pattern at line 42)

**Interfaces:**
- Produces: the two patterns `(^|[^[:alnum:]_.-])git([[:space:]]+[^[:space:]]+)*[[:space:]]+commit([^[:alnum:]_.-]|$)` and `(^|[^[:alnum:]_.-])gh([[:space:]]+[^[:space:]]+)*[[:space:]]+pr([[:space:]]+[^[:space:]]+)*[[:space:]]+(ready|merge|close|reopen)([^[:alnum:]_.-]|$)`, and a `Not seen:` line in each header naming what a pattern guard cannot see.
- Produces: the remediation comments `# an issue this PR closes` and `# work no issue tracks` (#68/body/1a's echo site in this hook; V9 lands the rule in § Branch naming). The block's `grep -q 'short-slug'` on this hook stays green.
- Consumes: `hook-guards-fixture.sh` from V2.3.

- [ ] **Step 1: Extend the fixture with the bypass spellings**

Edit `.claude/workflows/tests/hook-guards-fixture.sh` — replace this text (exact; it occurs once):
```bash
run "$MAIN" "$(bash_payload 'git commit' "$d/on-main")";             want 2 "a bare commit alone is a commit"
```
with:
```bash
run "$MAIN" "$(bash_payload 'git commit' "$d/on-main")";             want 2 "a bare commit alone is a commit"
# Both anchors are negated classes: a commit reached through a subshell, a quoted `-c` string, an absolute path or a
# trailing separator is still a commit; `commit-tree` and a `commit.*` key are not.
for c in 'bash -c "git commit -m x"' "sh -c 'git commit -m x'" '(git commit -m x)' '$(git commit -m x)' \
         '`git commit -m x`' '/usr/bin/git commit -m x' 'git commit;' 'git commit&&true' 'true;git commit'; do
  run "$MAIN" "$(bash_payload "$c" "$d/on-main")"; want 2 "a commit on main is denied: $c"
done
for c in 'git commit-tree HEAD^{tree} -m x' 'git -c commit.gpgsign=false log' 'git config commit.gpgsign true' 'git log --grep=commit'; do
  run "$MAIN" "$(bash_payload "$c" "$d/on-main")"; want 0 "not a commit: $c"
done
```


Edit `.claude/workflows/tests/hook-guards-fixture.sh` — replace this text (exact; it occurs once):
```bash
  run "$PRS" "$(bash_payload "$c" "$d/on-feat")"; asks "a PR-state change asks: $c"
done
for c in 'gh pr create --draft'
```
with:
```bash
  run "$PRS" "$(bash_payload "$c" "$d/on-feat")"; asks "a PR-state change asks: $c"
done
for c in 'bash -c "gh pr merge 5"' '(gh pr merge 5)' '$(gh pr merge 5)' '/usr/bin/gh pr merge 5' '(gh pr merge)' 'gh pr close 5;echo done'; do
  run "$PRS" "$(bash_payload "$c" "$d/on-feat")"; asks "a PR-state change asks: $c"
done
for c in 'gh pr view 7 --json mergeable' 'gh pr list --state merged'; do
  run "$PRS" "$(bash_payload "$c" "$d/on-feat")"; silent "no decision for: $c"
done
for c in 'gh pr create --draft'
```


- [ ] **Step 2: Run it against the unfixed patterns**

Run: `bash .claude/workflows/tests/hook-guards-fixture.sh; echo "exit=$?"`
Expected:
```text
FAIL: a commit on main is denied: bash -c "git commit -m x" (want exit 2, got 0)
exit=1
```
Record the FAIL line. The PR-state half is red on its own too: with the main-branch pattern fixed and the PR-state one not, the fixture stops at `FAIL: a PR-state change asks: bash -c "gh pr merge 5" (want an ask decision on stdout, exit 0; got exit 0)` (measured in the scratch replay); record it as the second line.

- [ ] **Step 3: Harden both patterns and name what they cannot see**

No platform fact is stated; the anchors' behaviour is measured by the fixture's cases.

Edit `.claude/hooks/protect-main-branch.sh` — replace this text (exact; it occurs once):
```bash
# Blocked:  Bash tool calls whose command contains a token-anchored `git`
#           followed (any number of option tokens later) by a `commit` token,
#           while the call's working directory is on main or master.
# Allowed:  everything else — commits on feature branches, and all
#           non-commit git commands on main.
```
with:
```bash
# Blocked:  Bash tool calls whose command contains `git` — at the start, or
#           after any character that cannot continue a word (a space, `;`, `&`,
#           `|`, `(`, `$(`, a backtick, a quote, the `/` of /usr/bin/git) —
#           followed, any number of option tokens later, by a `commit` token that
#           no word character, `.` or `-` continues, while the call's working
#           directory is on main or master; and a payload jq cannot read.
# Allowed:  everything else — commits on feature branches, non-commit git
#           commands on main, `git commit-tree`, and a `commit.*` config key.
# Not seen: a commit the command spells indirectly — `eval`, a variable holding
#           `git`, a git alias, a script that commits. A pattern guard reads the
#           text, not what runs; the base branch's ruleset, where one exists,
#           refuses such a commit when it is pushed.
```


Edit `.claude/hooks/protect-main-branch.sh` — replace this text (exact; it occurs once):
```bash
# operator can override by running the commit themselves; under-matching
# would be a silent bypass, which is worse for a deny-tier guard.
```
with:
```bash
# operator can override by running the commit themselves; under-matching
# would be a silent bypass, which is worse for a deny-tier guard. Both anchors
# are negated classes: `git` may follow anything that cannot continue a word,
# so `bash -c "git commit …"`, `(git commit …)`, `$(git commit …)` and
# `/usr/bin/git commit` are caught; `commit` may be followed by anything but a
# word character, `.` or `-`, so `git commit;` and `git commit&&…` are caught
# while `git commit-tree` and `git config commit.gpgsign …` are not (each
# measured 2026-09-30; the fixture holds the cases).
```


Edit `.claude/hooks/protect-main-branch.sh` — replace this text (exact; it occurs once):
```bash
if ! grep -Eq '(^|[;&|[:space:]])git([[:space:]]+[^[:space:]]+)*[[:space:]]+commit([[:space:]]|$)' <<<"$command"; then
```
with:
```bash
if ! grep -Eq '(^|[^[:alnum:]_.-])git([[:space:]]+[^[:space:]]+)*[[:space:]]+commit([^[:alnum:]_.-]|$)' <<<"$command"; then
```


Edit `.claude/hooks/protect-main-branch.sh` — replace this text (exact; it occurs once):
```bash
  git switch -c <type>/<team>-<n>-<short-slug>        # cascade issue
  git switch -c <type>/<short-slug>                   # operator-directed maintenance, no issue
```
with:
```bash
  git switch -c <type>/<team>-<n>-<short-slug>        # an issue this PR closes
  git switch -c <type>/<short-slug>                   # work no issue tracks
```


Edit `.claude/hooks/guard-pr-state.sh` — replace this text (exact; it occurs once):
```bash
# Tier:     ASK-GATE (see the registry comment in .claude/settings.json).
# Depends:
```
with:
```bash
# Not seen: a PR-state change the command spells indirectly — `eval`, a
#           variable holding `gh`, a `gh` alias, `gh api` against the pulls
#           endpoint — and one made in the web UI. No mechanical backstop exists:
#           the per-action OK is the operator's.
# Tier:     ASK-GATE (see the registry comment in .claude/settings.json).
# Depends:
```


Edit `.claude/hooks/guard-pr-state.sh` — replace this text (exact; it occurs once):
```bash
# command) costs one extra confirmation — acceptable for an ask-gate.
```
with:
```bash
# command) costs one extra confirmation — acceptable for an ask-gate. The
# anchors are negated classes, as in protect-main-branch.sh: `gh` may follow
# anything that cannot continue a word (`bash -c "gh pr merge 5"`,
# `(gh pr merge 5)`, `$(gh pr merge 5)`, `/usr/bin/gh`), and the verb anything
# but a word character, `.` or `-` (measured 2026-09-30; the fixture holds the cases).
```


Edit `.claude/hooks/guard-pr-state.sh` — replace this text (exact; it occurs once):
```bash
if grep -Eq '(^|[;&|[:space:]])gh([[:space:]]+[^[:space:]]+)*[[:space:]]+pr([[:space:]]+[^[:space:]]+)*[[:space:]]+(ready|merge|close|reopen)([[:space:]]|$|[;&|])' <<<"$command"; then
```
with:
```bash
if grep -Eq '(^|[^[:alnum:]_.-])gh([[:space:]]+[^[:space:]]+)*[[:space:]]+pr([[:space:]]+[^[:space:]]+)*[[:space:]]+(ready|merge|close|reopen)([^[:alnum:]_.-]|$)' <<<"$command"; then
```


- [ ] **Step 4: Run the fixture, `bash -n`, the contract fixture and the block**

Run: `bash .claude/workflows/tests/hook-guards-fixture.sh; echo "exit=$?"`
Expected: `hook-guards-fixture: 85 cases ok`, `exit=0`.

Run: `bash -n .claude/hooks/protect-main-branch.sh && bash -n .claude/hooks/guard-pr-state.sh && bash .claude/workflows/tests/hook-contract-fixture.sh`
Expected: `hook-contract-fixture: ok` (the over-buffer commit and merge probes still bite).

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'hook-guards-fixture|^verification: (kit sub-block complete|done)$|^verification: block exited'; echo "exit=${PIPESTATUS[0]}"`
Expected: `hook-guards-fixture: 85 cases ok`, `verification: kit sub-block complete`, `verification: done`, `exit=0`.

- [ ] **Step 5: Commit**

```bash
git add .claude/workflows/tests/hook-guards-fixture.sh .claude/hooks/protect-main-branch.sh .claude/hooks/guard-pr-state.sh
git commit -q -F - <<'MSG'
fix(V2): the main-branch and PR-state patterns anchor on non-word characters

The left anchor admitted only a start, a space or ;&|, so a commit on main passed
the hard-deny inside bash -c "…", sh -c '…', a subshell, $(…), backticks or through
/usr/bin/git, and the right anchor let git commit; and git commit&&… through; the
PR-state ask-gate shared the left anchor. Both anchors are now negated classes:
anything that cannot continue a word before, anything but a word character, . or
- after, so git commit-tree and git config commit.gpgsign stay allowed. Each
header's Not seen: line names what a pattern guard cannot see (eval, a variable, an
alias). The remediation's comments say "an issue this PR closes" and "work no issue
tracks". The fixture gains every spelling, both ways.

Red first: FAIL: a commit on main is denied: bash -c "git commit -m x" (want exit 2, got 0)

Trace: review/security/20, #68/body/1a (the guard's remediation).
Decision: D44.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
```
### Task V2.5: The launch-root guard and the fork detector, by payload — and probe P1 (#58/c5901493591/R1 (the two hooks), #58/c5901493591/R6, #58/c5901493591/R13, #73/body/2 (the WARNING pins), release/5 (the two hooks); D61, D44; probe P1)

**Files:**
- Create: `.claude/workflows/tests/hook-payloads-fixture.sh` (mode 755)
- Modify: `.claude/hooks/require-repo-root-for-agents.sh` (header `Blocked:` line 16–17, `Timing:` lines 25–40, `Depends:` lines 46–49; a refusal after the jq check at line 68)
- Modify: `.claude/hooks/detect-forked-agent-memory.sh` (six bare citations; rule 1 at lines 100–103)
- Modify: `.claude/hooks/protect-main-branch.sh` (the cwd comment at lines 43–45)
- Modify: `.claude/rules/cbk-conventions-reference.md` — § Hook authoring's Header bullet (the `Timing:` clause) and § Verification (the kit sentinel)

**Interfaces:**
- Produces: `.claude/workflows/tests/hook-payloads-fixture.sh`, asserting the literal `WARNING` on every could-not-look branch of the detector (outside a checkout, a partial scan) — the contract V1's `stop_hook_clean` reads — and on the launch-root guard's non-checkout branch.
- Produces: P1's answer, written into three places in one variant: the launch-root guard's `Timing:` paragraph, the main-branch guard's cwd comment, and § Hook authoring's Header bullet. V10's CHANGELOG sync note states the variant's behaviour.
- Consumes: V1's Stop-hook check (unchanged here); nothing in this task changes the detector's messages.

- [ ] **Step 1: Write the failing fixture**

Create `.claude/workflows/tests/hook-payloads-fixture.sh`:
```bash
#!/usr/bin/env bash
# Behavioural cases for the two hooks hook-contract-fixture.sh covers only structurally or in part: the launch-root
# guard (require-repo-root-for-agents.sh, PreToolUse, HARD-DENY) and the forked-memory detector
# (detect-forked-agent-memory.sh, Stop). Every branch each documents in its `Blocked:` / `Allowed:` header is
# exercised with a crafted payload and an asserted exit — § Hook authoring › Verify by payload, made durable
# (context-builder-kit#58 items 1, 2 and 4). Neither hook sources a helper. Every could-not-look branch of the
# detector prints the literal WARNING the verification block's Stop-hook check reads; the cases assert it.
# Two fail-open branches are reachable only by mutation, not by payload (the guard's race between its git call and
# its `cd`; the detector's `cd` failure) — stated here rather than claimed as payload coverage.
# Every case runs against throwaway `git init` trees under mktemp, never the real repository, and never depends on
# the directory the fixture is launched from; the hooks run from their real path, so a change to either is caught.
# Needs bash, git and jq; `find`, `sed`, `sort` and `mktemp` for the detector. The partial-scan case needs a
# directory the walk cannot read, which root can read anyway: run as root it prints a SKIP line.
# Run by the verification block; also: bash .claude/workflows/tests/hook-payloads-fixture.sh
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
hooks="$here/../../hooks"
GUARD="$hooks/require-repo-root-for-agents.sh"
STOP="$hooks/detect-forked-agent-memory.sh"
[ -x "$GUARD" ] && [ -x "$STOP" ] || { echo "hook-payloads-fixture: a hook is missing or not executable"; exit 1; }
command -v jq >/dev/null && command -v git >/dev/null || { echo "hook-payloads-fixture: needs jq and git"; exit 1; }
d=$(mktemp -d)
cleanup() { chmod -R u+rwX "$d" 2>/dev/null || true; rm -rf "$d"; }
trap cleanup EXIT
# Git discovery stops at the throwaway root (the ceiling is its parent), so a TMPDIR inside a work tree cannot turn
# the outside-a-checkout cases into inside ones.
export GIT_CEILING_DIRECTORIES="${d%/*}"

# A throwaway checkout whose ignore rules name one build directory and one tool cache, so the ignore-driven prune has
# something to prune that is not hard-coded anywhere.
repo="$d/repo"; mkdir -p "$repo"
git -c init.defaultBranch=main init -q "$repo"
ignore() { printf '%b' "$1" > "$repo/.gitignore"; }
ignore '/pkg/*/build/\n/pkg/*/.cache/\n'
mkdir -p "$repo/pkg/a" "$repo/docs" "$repo/.claude/agent-memory/reviewer"
spaced="$d/a b"; mkdir -p "$spaced/docs"; git -c init.defaultBranch=main init -q "$spaced"

n=0; RC=0; ERR=""
guard() { RC=0; ERR="$(printf '%s' "$1" | "$GUARD" 2>&1 >/dev/null)" || RC=$?; n=$((n + 1)); }
guard_in() { RC=0; ERR="$(cd "$1" && printf '%s' "$2" | "$GUARD" 2>&1 >/dev/null)" || RC=$?; n=$((n + 1)); }
stop() { RC=0; ERR="$(printf '%s' "$2" | CLAUDE_PROJECT_DIR="$1" "$STOP" 2>&1 >/dev/null)" || RC=$?; n=$((n + 1)); }
want() { [ "$RC" -eq "$1" ] || { echo "FAIL: $2 (want exit $1, got $RC)"; [ -n "$ERR" ] && printf '  stderr: %s\n' "$ERR"; exit 1; }; }
says() { grep -q -- "$1" <<<"$ERR" || { echo "FAIL: $2 (stderr does not carry '$1')"; printf '  stderr: %s\n' "$ERR"; exit 1; }; }
payload() { jq -cn --arg t "$1" --arg cwd "$2" '{tool_name:$t, tool_input:{}, cwd:$cwd}'; }

# ── the launch-root guard ──
guard "$(payload Agent "$repo")";         want 0 "Agent from the checkout root is allowed"
guard "$(payload Agent "$repo/docs")";    want 2 "Agent from a subdirectory is denied"
guard "$(payload Task "$repo/docs")";     want 2 "Task (the older tool name) from a subdirectory is denied"
guard "$(payload Workflow "$repo/docs")"; want 2 "Workflow from a subdirectory is denied"
guard "$(payload Bash "$repo/docs")";     want 0 "a non-matching tool passes through"
guard "$(payload Agent "$repo/docs")";    says "BLOCKED" "the denial names itself"
says "$repo" "the denial names the root to return to"
guard "$(payload Agent "$spaced")";       want 0 "Agent from a root containing a space is allowed"
guard "$(payload Agent "$spaced/docs")";  want 2 "Agent from a subdirectory of a root containing a space is denied"
# Canonicalization: a symlinked or trailing-slash spelling of the root IS the root (a false HARD-DENY otherwise).
ln -s "$repo" "$d/rootlink"
guard "$(payload Agent "$d/rootlink")";      want 0 "a symlink to the root is not a false mismatch"
guard "$(payload Agent "$repo/")";           want 0 "a trailing slash on the root is not a false mismatch"
guard "$(payload Agent "$d/rootlink/docs")"; want 2 "a symlinked subdirectory is still denied"
# The cwd fallback resolves against the PROCESS's directory, asserted from a controlled directory both ways.
guard_in "$repo" '{"tool_name":"Agent","tool_input":{}}';      want 0 "no cwd field: falls back to \$PWD, allowed at the root"
guard_in "$repo/docs" '{"tool_name":"Agent","tool_input":{}}'; want 2 "no cwd field: falls back to \$PWD, denied in a subdirectory"
# Fail-open branches: each exits 0, warns, and names a surviving backstop.
guard "$(payload Agent "$d")"; want 0 "a cwd outside any checkout fails open"
says "WARNING" "the non-checkout warning is a WARNING"; says "not inside a git checkout" "the non-checkout warning says why"
says "Backstop:" "the non-checkout warning names a backstop"
bin="$d/bin"; mkdir -p "$bin"
for t in bash git cat printf sed dirname basename find grep sort head mktemp rm; do
  p=$(type -P "$t" || true); [ -n "$p" ] && ln -sf "$p" "$bin/$t"
done
RC=0; ERR="$(printf '%s' "$(payload Agent "$repo/docs")" | env -i PATH="$bin" HOME="$HOME" bash "$GUARD" 2>&1 >/dev/null)" || RC=$?; n=$((n + 1))
want 0 "the guard fails open when jq is absent"
says "jq not installed" "the jq warning says why"; says "Backstop:" "the jq warning names a backstop"
# Input it cannot read is refused: the guard cannot tell where the dispatch launches from.
guard "$(printf '{"tool_name":"Agent","tool_input":{"prompt":"x\\ud800y"},"cwd":"%s"}' "$repo")"; want 2 "a payload jq cannot parse is refused"
says "could not read the tool payload" "the refusal says why"
guard '["Agent"]';                        want 2 "a payload that is not an object is refused"

# ── the forked-memory detector ──
stop "$repo" '{"stop_hook_active":false}'; want 0 "a clean tree lets the stop proceed"
stop "$repo" '{}';                          want 0 "the root's own agent-memory tree is not a fork"
mkdir -p "$repo/pkg/a/.claude/agent-memory/reviewer"
stop "$repo" '{}';                          want 2 "a stray agent-memory under a package blocks the stop"
says "BLOCKED" "the block names itself"
says "pkg/a/.claude/agent-memory" "the block names the stray path"
stop "$repo" '{"stop_hook_active": true}';  want 0 "a second stop after one block proceeds"
says "still present after one fix attempt" "the second stop warns instead of blocking"
rm -rf "$repo/pkg/a/.claude"
mkdir -p "$repo/pkg/a/.claude/agent-memory-local/reviewer"
stop "$repo" '{}';                          want 2 "the local memory scope forks the same way"
says "agent-memory-local" "the block names the local-scope path"
rm -rf "$repo/pkg/a/.claude"
# A worktree is its own checkout with its own root tree, so its memory is not a fork.
mkdir -p "$repo/.claude/worktrees/wt/.claude/agent-memory/reviewer"
stop "$repo" '{}';                          want 0 "a worktree's own agent-memory tree is pruned"
rm -rf "$repo/.claude/worktrees"
# The prune list is the project's own ignore rules, read at run time: both ignored directories are pruned, an
# unignored one is not.
mkdir -p "$repo/pkg/a/build/agent-memory" "$repo/pkg/a/.cache/agent-memory"
stop "$repo" '{}';                          want 0 "trees under ignored directories are pruned"
mkdir -p "$repo/pkg/a/vendored/agent-memory"
stop "$repo" '{}';                          want 2 "a tree under an untracked but UNignored directory is still found"
says "vendored/agent-memory" "the block names the unignored stray path"
rm -rf "$repo/pkg/a/vendored" "$repo/pkg/a/build" "$repo/pkg/a/.cache"
# An ignore-driven prune list is attacker-shaped input; three rules keep it safe, each against a tree that would
# defeat a naive splice.
mkdir -p "$repo/pkg/a/.claude/agent-memory/reviewer"
( cd "$repo" && mkdir -p -- '*' )
ignore '\\*/\n'
stop "$repo" '{}';                          want 2 "an ignored directory named '*' prunes itself, not the whole walk"
rm -rf "${repo:?}/*"
ignore 'agent-memory/\n'
stop "$repo" '{}';                          want 2 "an ignore rule naming the memory tree never hides it"
ignore '.claude/\n'
stop "$repo" '{}';                          want 2 "an ignore rule naming .claude never hides a fork inside it"
ignore 'reviewer/\n'
stop "$repo" '{}';                          want 2 "a collapsed ancestor that no rule names is still walked"
ignore '/pkg/*/build/\n/pkg/*/.cache/\n'
rm -rf "$repo/pkg/a/.claude"
# The scan is rooted at the checkout's top level, so a project dir pointing at a subdirectory still finds a fork.
mkdir -p "$repo/pkg/a/.claude/agent-memory/reviewer"
stop "$repo/docs" '{}';                     want 2 "a subdirectory project dir still scans from the top level"
# No jq dependency: the detector backstops exactly the case where the jq-dependent guards have failed open.
RC=0; ERR="$(printf '{}' | env -i PATH="$bin" HOME="$HOME" CLAUDE_PROJECT_DIR="$repo" bash "$STOP" 2>&1 >/dev/null)" || RC=$?; n=$((n + 1))
want 2 "the detector blocks without jq on PATH"
rm -rf "$repo/pkg/a/.claude"
stop "$d" '{}';                             want 0 "a project dir outside any checkout fails open"
says "WARNING" "the non-checkout warning is a WARNING"; says "not inside a git checkout" "the non-checkout warning says why"
says "Backstop:" "the non-checkout warning names a backstop"
# A directory the walk cannot read makes the scan partial; reporting "clean" there is the silent miss the hook exists
# to stop, so it warns. Root ignores mode bits, so the case cannot be staged there.
if [ "$(id -u)" -ne 0 ]; then
  mkdir -p "$repo/pkg/a/sealed/inner"; chmod 000 "$repo/pkg/a/sealed"
  stop "$repo" '{}';                        want 0 "an unreadable directory does not fake a block"
  says "WARNING" "a partial scan is a WARNING"; says "the scan was partial" "a partial scan is reported, never silently clean"
  chmod 755 "$repo/pkg/a/sealed"; rm -rf "$repo/pkg/a/sealed"
else
  echo "SKIP: the detector's partial-scan case (an unreadable directory unavailable: running as root)"
fi
echo "hook-payloads-fixture: $n cases ok"
```

Run: `chmod 755 .claude/workflows/tests/hook-payloads-fixture.sh`

- [ ] **Step 2: Run it against the unfixed guard, and run probe P1**

Run: `bash .claude/workflows/tests/hook-payloads-fixture.sh; echo "exit=$?"`
Expected:
```text
FAIL: a payload jq cannot parse is refused (want exit 2, got 0)
  stderr: jq: parse error: Invalid \uXXXX\uXXXX surrogate pair escape at line 1, column 54
exit=1
```
(the column varies with the temp path). Record the FAIL line. Every earlier case passes on the unfixed hooks: they pin behaviour the two hooks already have, including the partial-scan warning R6 found unpinned.

**Probe P1 — a hook payload's `cwd` after the Bash tool runs `cd`.** The hooks page says the field is "the new directory after Claude runs `cd`"; harvest 3 measured the opposite (2026-09-07), and the launch-root guard's header rests on that measurement. Run, from the repository root, in a throwaway repository (it spends one short Haiku session and a subagent):
```bash
curl -sL https://code.claude.com/docs/en/hooks.md | grep -cF 'the new directory after Claude runs `cd`'
claude --version
P=$(mktemp -d)/p1 && mkdir -p "$P/docs" && git -c init.defaultBranch=main init -q "$P" \
&& git -C "$P" -c user.email=p@x -c user.name=p -c commit.gpgsign=false commit -q --allow-empty -m init
cat > "$P/log-cwd.sh" <<EOF
#!/usr/bin/env bash
input="\$(cat)"
jq -c '{tool_name, cwd, command: .tool_input.command}' <<<"\$input" >> "$P/cwd.log"
exit 0
EOF
chmod +x "$P/log-cwd.sh"
jq -n --arg c "$P/log-cwd.sh" '{hooks: {PreToolUse: [{matcher: "Bash|Agent|Task", hooks: [{type: "command", command: $c}]}]}}' > "$P/p1-settings.json"
(cd "$P" && timeout 300 claude -p --model haiku --settings "$P/p1-settings.json" \
  --allowedTools 'Bash(pwd)' 'Bash(cd docs)' 'Agent' --max-turns 8 \
  "Make exactly these tool calls, one at a time, in order: a Bash call running pwd; a Bash call running cd docs; a Bash call running pwd; then one Agent call whose task is to reply with the single word done. Then reply with the word finished." < /dev/null)
cat "$P/cwd.log"
```
Expected: `1` (the page's `cwd follows Claude` bullet carries the phrase), the CLI version, `finished`, and four log lines — Bash `pwd`, Bash `cd docs`, Bash `pwd`, then `Agent`. If the count is `0`, stop: the quotation in the texts below cannot be written.

**Decision rule.** Read the `cwd` of the first log line after the `cd docs` line and of the `Agent` line:
- both end in `/p1/docs` → **variant B** (the field follows `cd`; the guard now denies a dispatch made after a `cd` into a subdirectory);
- both end in `/p1` → **variant A** (the field stays at the launch directory, as measured 2026-09-07);
- they disagree → stop and report both lines to the operator; neither text below is true.

Two dry runs of this procedure on 2026-09-30, Claude Code 2.1.285 (the drafter's, and the plan verifier's independent re-run), logged `…/p1/docs` for both: **variant B**. Apply the variant your own run shows. In the chosen variant's texts, replace `2.1.285` with the version `claude --version` printed and `2026-09-30` with the run date, if they differ. Record the four log lines, the version and the variant in the PR body under P1.

**Under variant B, this session is guarded too.** The kit's `settings.json` registers the working-tree hook, so from this commit on an Agent or Workflow dispatch made while the Bash tool's directory is not the repository root is denied, in the executor's own session as well (F2's review sweep included). Every step in these cluster files that enters a scratch copy returns with `cd -`; run `cd "$(git rev-parse --show-toplevel)"` as its own command before any dispatch.

- [ ] **Step 3: Refuse an unreadable payload, write P1's answer, correct rule 1**

The launch-root guard's other three edits (the same in both variants):
Edit `.claude/hooks/require-repo-root-for-agents.sh` — replace this text (exact; it occurs once):
```bash
# Blocked:  Task, Agent and Workflow tool calls whose working directory is not
#           the git top-level of the checkout it sits in.
```
with:
```bash
# Blocked:  Task, Agent and Workflow tool calls whose working directory is not
#           the git top-level of the checkout it sits in; and a payload jq cannot
#           read, whose working directory cannot be checked.
```


Edit `.claude/hooks/require-repo-root-for-agents.sh` — replace this text (exact; it occurs once):
```bash
#           naming the backstop, detect-forked-agent-memory.sh (Stop tier,
#           needs no jq).
```
with:
```bash
#           naming the backstop, detect-forked-agent-memory.sh (Stop tier,
#           needs no jq). A payload jq cannot read is not an environment defect:
#           it is refused (cbk-conventions-reference.md § Hook authoring).
#           Fixture: .claude/workflows/tests/hook-payloads-fixture.sh.
```


Edit `.claude/hooks/require-repo-root-for-agents.sh` — replace this text (exact; it occurs once):
```bash
  echo "                              catches a stray agent-memory tree before the hand-off; git status shows it untracked." >&2
  exit 0
fi
```
with:
```bash
  echo "                              catches a stray agent-memory tree before the hand-off; git status shows it untracked." >&2
  exit 0
fi

# A payload jq cannot read is refused: this hook runs on Task|Agent|Workflow only, so the call is
# still a dispatch, and where it launches from cannot be checked.
if ! jq -e 'type == "object"' >/dev/null 2>&1 <<<"$input"; then
  echo "BLOCKED: require-repo-root-for-agents could not read the tool payload (not parseable JSON, or not an object)," >&2
  echo "so it cannot tell where this dispatch launches from. A lone UTF-16 surrogate escape in the tool input does this — remove it and retry." >&2
  exit 2
fi
```


**Variant B** (the field follows `cd`) — three replacements:

Edit `.claude/hooks/require-repo-root-for-agents.sh` — replace this text (exact; it occurs once):
```bash
# Timing:   the guard reads the payload's `cwd` (a common field on every hook
#           event — https://code.claude.com/docs/en/hooks-guide § How hooks
#           work) BEFORE the tool runs. That field is the SESSION's working
#           directory — where Claude Code was launched — not the Bash tool's
#           persisted shell directory: a real dispatch made after `cd docs` in
#           the shell was allowed, with the payload cwd still at the root (dated
#           observation, 2026-09-07). The confirmed deny is a session launched
#           from a subdirectory (the verification block's payload dry-run); the
#           remedy there is to relaunch the session from the root. The hooks
#           reference states the OPPOSITE of the observation above — "cwd follows
#           Claude: … the new directory after Claude runs cd"
#           (https://code.claude.com/docs/en/hooks § Reference scripts by path,
#           read 2026-09-07). The two disagree; this guard judges whichever cwd
#           the payload carries and is correct under either reading. RE-VERIFY
#           TRIGGER: a dispatch made after `cd <subdir>` that is denied means the
#           page's reading now holds — update this paragraph (#58, S3).
```
with:
```bash
# Timing:   the guard reads the payload's `cwd` (a common field on every hook
#           event — https://code.claude.com/docs/en/hooks-guide § How hooks
#           work) BEFORE the tool runs. That field follows the Bash tool's `cd`
#           — "the new directory after Claude runs `cd`"
#           (https://code.claude.com/docs/en/hooks § Reference scripts by path,
#           read 2026-09-30) — and a logging-hook probe on Claude Code 2.1.285
#           showed it (2026-09-30): a Bash call and an Agent dispatch made after
#           `cd docs` both carried <root>/docs. So a dispatch made after a `cd`
#           into a subdirectory is denied, and the remedy is to `cd` back to the
#           root as its own command. The 2026-09-07 observation that the field
#           stayed at the session's launch directory is retired
#           (context-builder-kit#58, S3). RE-VERIFY TRIGGER: a dispatch made after
#           `cd <subdir>` that is allowed means the field stopped following `cd` —
#           re-run the probe and update this paragraph.
```

Edit `.claude/hooks/protect-main-branch.sh` — replace this text (exact; it occurs once):
```bash
# The Bash tool's payload carries the call's working directory; the branch
# check must use it (not a fixed project dir), or a commit run from a
# worktree / nested repo is judged against the wrong repo's branch.
```
with:
```bash
# The payload's `cwd` is the directory the Bash tool is in — it follows `cd`
# (probe, 2026-09-30; require-repo-root-for-agents.sh § Timing) — so a commit
# run from a worktree or a nested repo is judged against that checkout's
# branch, not a fixed project dir. Precedence: cwd, CLAUDE_PROJECT_DIR, $PWD.
```

Edit `.claude/rules/cbk-conventions-reference.md` — in § Hook authoring's Header bullet, replace this text (exact; it occurs once):
```markdown
and the payload `cwd` is the session's launch directory, which a shell `cd` does not move — a real dispatch, 2026-09-07 — so a launch-directory guard is answered by relaunching the session from the root)
```
with:
```markdown
and the payload `cwd` follows the Bash tool's `cd` — "the new directory after Claude runs `cd`" (`https://code.claude.com/docs/en/hooks`, read 2026-09-30; a logging-hook probe on Claude Code 2.1.285, 2026-09-30, retired the 2026-09-07 observation that it did not) — so a launch-directory guard is answered by returning to the root as its own command)
```


**Variant A** (the field stays at the launch directory) — three replacements instead:

Edit `.claude/hooks/require-repo-root-for-agents.sh` — replace this text (exact; it occurs once):
```bash
# Timing:   the guard reads the payload's `cwd` (a common field on every hook
#           event — https://code.claude.com/docs/en/hooks-guide § How hooks
#           work) BEFORE the tool runs. That field is the SESSION's working
#           directory — where Claude Code was launched — not the Bash tool's
#           persisted shell directory: a real dispatch made after `cd docs` in
#           the shell was allowed, with the payload cwd still at the root (dated
#           observation, 2026-09-07). The confirmed deny is a session launched
#           from a subdirectory (the verification block's payload dry-run); the
#           remedy there is to relaunch the session from the root. The hooks
#           reference states the OPPOSITE of the observation above — "cwd follows
#           Claude: … the new directory after Claude runs cd"
#           (https://code.claude.com/docs/en/hooks § Reference scripts by path,
#           read 2026-09-07). The two disagree; this guard judges whichever cwd
#           the payload carries and is correct under either reading. RE-VERIFY
#           TRIGGER: a dispatch made after `cd <subdir>` that is denied means the
#           page's reading now holds — update this paragraph (#58, S3).
```
with:
```bash
# Timing:   the guard reads the payload's `cwd` (a common field on every hook
#           event — https://code.claude.com/docs/en/hooks-guide § How hooks
#           work) BEFORE the tool runs. That field is the SESSION's working
#           directory — where Claude Code was launched — not the Bash tool's
#           persisted shell directory: a logging-hook probe on Claude Code 2.1.285
#           (2026-09-30) logged the launch directory for a Bash call and an Agent
#           dispatch made after `cd docs`, as a real dispatch did on 2026-09-07.
#           The confirmed deny is a session launched from a subdirectory (the
#           verification block's payload dry-run); the remedy there is to relaunch
#           the session from the root. The hooks reference states the OPPOSITE —
#           "the new directory after Claude runs `cd`"
#           (https://code.claude.com/docs/en/hooks § Reference scripts by path,
#           read 2026-09-30); this guard judges whichever cwd the payload carries
#           and is correct under either reading. RE-VERIFY TRIGGER: a dispatch
#           made after `cd <subdir>` that is denied means the page's reading now
#           holds — re-run the probe and update this paragraph
#           (context-builder-kit#58, S3).
```

Edit `.claude/hooks/protect-main-branch.sh` — replace this text (exact; it occurs once):
```bash
# The Bash tool's payload carries the call's working directory; the branch
# check must use it (not a fixed project dir), or a commit run from a
# worktree / nested repo is judged against the wrong repo's branch.
```
with:
```bash
# The payload's `cwd` is the session's launch directory, which a shell `cd`
# does not move (probe, 2026-09-30; require-repo-root-for-agents.sh § Timing);
# judged there, a session launched inside a worktree or a nested repo is checked
# against that checkout's branch. Precedence: cwd, CLAUDE_PROJECT_DIR, $PWD.
```

Edit `.claude/rules/cbk-conventions-reference.md` — in § Hook authoring's Header bullet, replace this text (exact; it occurs once):
```markdown
and the payload `cwd` is the session's launch directory, which a shell `cd` does not move — a real dispatch, 2026-09-07 — so a launch-directory guard is answered by relaunching the session from the root)
```
with:
```markdown
and the payload `cwd` is the session's launch directory, which a shell `cd` does not move — a real dispatch, 2026-09-07, and a logging-hook probe on Claude Code 2.1.285, 2026-09-30, against the hooks page's "the new directory after Claude runs `cd`" (`https://code.claude.com/docs/en/hooks`, read 2026-09-30) — so a launch-directory guard is answered by relaunching the session from the root)
```


The detector: first the bare citations (D53), then rule 1 (R13). Rule 1 promised never to prune a path that could be or contain the tree, which its own `Residual:` line contradicts; the code tests only a directory's own name.

Edit `.claude/hooks/detect-forked-agent-memory.sh` — replace every occurrence (Edit with `replace_all: true`; the file carries it only as a bare kit-issue citation, six times at `74edf84`):
```text
#58
```
with:
```text
context-builder-kit#58
```

Edit `.claude/hooks/detect-forked-agent-memory.sh` — replace this text (exact; it occurs once):
```bash
#   1. Never prune a path that could BE or CONTAIN the tree this hook hunts for. A
#      project that ignores the memory directory by an unanchored name (`agent-memory/`
#      — the natural spelling for the `local` scope) or ignores `.claude/` wholesale
#      would otherwise have its own ignore rules hide the fork.
```
with:
```bash
#   1. Never prune a directory whose own name is one of the three this rule protects —
#      the two the hook hunts, `agent-memory` and `agent-memory-local`, and `.claude`,
#      which holds them: such a directory could BE or CONTAIN the tree. A project that
#      ignores the memory directory by an unanchored name (`agent-memory/` — the natural
#      spelling for the `local` scope) or ignores `.claude/` wholesale would otherwise
#      have its own ignore rules hide the fork. A tree nested inside some OTHER ignored
#      directory is pruned with it — the Residual above, a limit of this rule, not a
#      promise it keeps.
```


Edit `.claude/rules/cbk-conventions-reference.md` — in § Verification, replace the kit sentinel line (exact; it occurs once):
```bash
echo "verification: kit sub-block complete"
```
with (the new checks sit immediately before it):
```bash
# The launch-root guard and the forked-memory detector on every branch their headers document, by payload
# (context-builder-kit#58 items 1, 2 and 4): the guard's deny and allow by working directory, a root containing a
# space, canonicalization, the $PWD fallback, an unreadable payload refused, and its fail-open branches; the
# detector's block, second stop, prune rules and ignore-driven pruning, and every could-not-look branch printing
# WARNING — the partial scan included (a SKIP line when run as root). Needs git and jq; runs in throwaway trees.
bash .claude/workflows/tests/hook-payloads-fixture.sh || { echo "require-repo-root-for-agents.sh or detect-forked-agent-memory.sh regressed on its fixture"; exit 1; }
echo "verification: kit sub-block complete"
```

- [ ] **Step 4: Run the fixture, `bash -n` and the block**

Run: `bash .claude/workflows/tests/hook-payloads-fixture.sh; echo "exit=$?"`
Expected: `hook-payloads-fixture: 33 cases ok` (or `SKIP: the detector's partial-scan case (an unreadable directory unavailable: running as root)` and 32), `exit=0`.

Run: `for h in require-repo-root-for-agents detect-forked-agent-memory protect-main-branch; do bash -n .claude/hooks/$h.sh || echo "SYNTAX: $h"; done; grep -c 'context-builder-kit#58' .claude/hooks/detect-forked-agent-memory.sh; grep -nE '(^|[^-a-z])#58' .claude/hooks/detect-forked-agent-memory.sh .claude/hooks/require-repo-root-for-agents.sh | grep -v 'context-builder-kit#58'; echo "bare=$?"`
Expected: no `SYNTAX:` line, `6`, `bare=1`.

Run: `bash .claude/workflows/tests/hook-guards-fixture.sh | tail -1`
Expected: `hook-guards-fixture: 85 cases ok` (the main-branch guard's comment changed, not its code).

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'hook-payloads-fixture|^verification: (kit sub-block complete|done)$|^verification: block exited'; echo "exit=${PIPESTATUS[0]}"`
Expected: `hook-payloads-fixture: 33 cases ok`, `verification: kit sub-block complete`, `verification: done`, `exit=0`.

- [ ] **Step 5: Commit**

```bash
git add .claude/workflows/tests/hook-payloads-fixture.sh .claude/hooks/require-repo-root-for-agents.sh .claude/hooks/detect-forked-agent-memory.sh .claude/hooks/protect-main-branch.sh .claude/rules/cbk-conventions-reference.md
git commit -q -F - <<'MSG'
fix(V2): the launch-root guard refuses what it cannot read; both agent hooks, by payload

require-repo-root-for-agents.sh failed open on a payload jq cannot parse; it now
refuses it. hook-payloads-fixture.sh drives every branch the launch-root guard and
the forked-memory detector document, a root containing a space included, and pins
the literal WARNING on each could-not-look branch, the partial scan among them
(context-builder-kit#58 items 1, 2 and 4). Probe P1 settled whether a hook
payload's cwd follows the Bash tool's cd on the release CLI; the guard's Timing
paragraph, the main-branch guard's cwd comment and section Hook authoring state
the answer, dated. The detector's rule 1 now states what it guarantees and points
at its Residual; its bare citations are qualified.

Red first: FAIL: a payload jq cannot parse is refused (want exit 2, got 0)

Trace: #58/c5901493591/R1 (the two hooks), #58/c5901493591/R6,
#58/c5901493591/R13, #73/body/2 (the WARNING pins), release/5 (the two hooks).
Decisions: D61, D44. Probe: P1.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
```
### Task V2.6: Every backstop a rule names exists (#60/c5876324022/corpus-s1, #60/c5881158391/port-s1, #60/c5892401033/suggestion-1-built; D51)

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md` — § Verification: the kit sentinel (the `backstops()` check) and the project sentinel (the task-runner arm)
- Modify: `.claude/rules/cbk-conventions.md` — § Mutation discipline, the two-views paragraph (always loaded: +152 bytes, measured 130,628 → 130,780 in the scratch replay; recorded for D50's before and after)

**Interfaces:**
- Produces: the kit-sub-block function `backstops <text>` and its three reads: § Mutation discipline of `cbk-conventions.md`, the `_comment_hooks` string of `.claude/settings.json`, and every `.claude/hooks/*.sh`. Each `.github/workflows/<file>.yml` or `scripts/<file>.(sh|py)` they name must exist. V3's registry sentence may name the ADR workflow (the check then reads it too); a hook or registry text that names a workflow must name a real one.
- Produces: the project-sub-block `mise run <task>` arm, live only where `mise.toml` exists.
- Consumes: `.github/workflows/adr-immutability-check.yml` (V2.1).

- [ ] **Step 1: Write the failing check**

Edit `.claude/rules/cbk-conventions-reference.md` — in § Verification, replace the kit sentinel line (exact; it occurs once):
```bash
echo "verification: kit sub-block complete"
```
with (the new checks sit immediately before it):
```bash
# Every backstop the mutation table, the hook registry or a hook header names exists — a `.github/workflows/*.yml`
# file or a `scripts/*` file (context-builder-kit#60 comment, suggestion 1: a CI job named but never landed is how a
# target's frozen corpus went two weeks with no backstop behind its hook). The checker is asked about bogus names
# first, so it cannot pass by matching nothing, and a mutation section that names no checkable backstop is red.
backstops() {  # backstops <text>: prints each workflow or script path the text names that does not exist; returns 1 if any
  local miss=0 tok
  while IFS= read -r tok; do [ -z "$tok" ] || [ -f "$tok" ] || { echo "  names $tok, which does not exist"; miss=1; }; done <<<"$(grep -oE '\.github/workflows/[A-Za-z0-9._-]+\.ya?ml|scripts/[A-Za-z0-9._/-]+\.(sh|py)' <<<"$1" | sort -u || true)"
  return $miss
}
if backstops ".github/workflows/no-such-job.yml scripts/no-such-leg.sh" >/dev/null; then echo "backstops(): a bogus name passed — the checker is broken"; exit 1; fi
mt=$(awk '/^## Mutation discipline/{p=1; next} p && /^## /{exit} p' .claude/rules/cbk-conventions.md)
grep -qE '\.github/workflows/[A-Za-z0-9._-]+\.ya?ml' <<<"$mt" || { echo "cbk-conventions.md § Mutation discipline names no CI backstop in a checkable form (.github/workflows/<file>.yml)"; exit 1; }
backstops "$mt
$(jq -r '._comment_hooks' .claude/settings.json)
$(cat .claude/hooks/*.sh)" || { echo "the mutation table, the hook registry or a hook header names a CI workflow or script that does not exist (above)"; exit 1; }
echo "verification: kit sub-block complete"
```

- [ ] **Step 2: Run it against the unfixed contract**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'names no CI backstop|^verification: (kit sub-block complete|done)$|^verification: block exited'; echo "exit=${PIPESTATUS[0]}"`
Expected:
```text
cbk-conventions.md § Mutation discipline names no CI backstop in a checkable form (.github/workflows/<file>.yml)
verification: block exited 1
exit=1
```
The mutation table names its CI lint only as "the CI lint", so nothing is checkable. Record the line in the red-first table.

- [ ] **Step 3: Name the backstop by path, and add the task-runner arm**

Edit `.claude/rules/cbk-conventions.md` — replace this text (exact; it occurs once):
```markdown
A row enforced by a hook names it: ADRs → `protect-immutable-adrs.sh` (plus the CI lint); lock files → `protect-lock-files.sh`.
```
with:
```markdown
A row enforced by a hook names it: ADRs → `protect-immutable-adrs.sh` (plus the CI lint, `.github/workflows/adr-immutability-check.yml`); lock files → `protect-lock-files.sh`.
```


Edit `.claude/rules/cbk-conventions.md` — replace this text (exact; it occurs once):
```markdown
and the verification block checks the registry against the files. The authoring shape lives in
```
with:
```markdown
and the verification block checks the registry against the files — and that every workflow or script a backstop names here, in the registry or in a hook header exists. The authoring shape lives in
```


Edit `.claude/rules/cbk-conventions-reference.md` — replace this text (exact; it occurs once):
```markdown
  echo "verification: project sub-block complete"
```
with:
```markdown
  # A backstop named as a task-runner task exists in the runner's config (the kit sub-block checks workflow and script
  # paths; a task name needs the project's runner). The mise arm is the exercised one, and it reads the `[tasks.<name>]`
  # table form; for another runner, swap the two patterns (a `just <task>` name against the justfile's recipes) —
  # unexercised.
  if [ -f mise.toml ]; then
    for tok in $(cat <(awk '/^## Mutation discipline/{p=1; next} p && /^## /{exit} p' .claude/rules/cbk-conventions.md) <(jq -r '._comment_hooks' .claude/settings.json) .claude/hooks/*.sh | grep -oE 'mise run [a-z][a-z0-9:_-]*' | sed 's/^mise run //' | sort -u || true); do
      grep -qE "^\[tasks\.(\"$tok\"|$tok)\]" mise.toml || { echo "a backstop names 'mise run $tok', which is not a task in mise.toml"; exit 1; }
    done
  fi

  echo "verification: project sub-block complete"
```


- [ ] **Step 4: Run the block, then prove the check bites**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'names no CI backstop|names a CI workflow|^verification: (kit sub-block complete|done)$|^verification: block exited'; echo "exit=${PIPESTATUS[0]}"`
Expected: `verification: kit sub-block complete`, `verification: done`, `exit=0`.

Run (a backstop named but absent, in a scratch copy):
```bash
S=$(mktemp -d) && cp -a . "$S/kit" && cd "$S/kit" \
&& sed -i 's#(plus the CI lint, `.github/workflows/adr-immutability-check.yml`)#(plus the CI lint, `.github/workflows/adr-immutability-chek.yml`)#' .claude/rules/cbk-conventions.md \
&& bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -3; cd - >/dev/null; rm -rf "$S"
```
Expected:
```text
  names .github/workflows/adr-immutability-chek.yml, which does not exist
the mutation table, the hook registry or a hook header names a CI workflow or script that does not exist (above)
verification: block exited 1
```

Run (the project arm, on a synthetic tree):
```bash
S=$(mktemp -d) && mkdir -p "$S/.claude/rules" "$S/.claude/hooks" && cd "$S" \
&& printf '## Mutation discipline\nrow: `mise run frozen-corpus`\n## Next\n' > .claude/rules/cbk-conventions.md \
&& echo '{"_comment_hooks":"x mise run check"}' > .claude/settings.json && echo '# hook' > .claude/hooks/a.sh \
&& printf '[tasks.frozen-corpus]\n' > mise.toml \
&& awk '/# A backstop named as a task-runner task/{p=1} p&&/^  fi$/{print; exit} p' "$OLDPWD/.claude/rules/cbk-conventions-reference.md" > arm.sh \
&& bash -e arm.sh; echo "exit=$?"; cd "$OLDPWD"; rm -rf "$S"
```
Expected: `a backstop names 'mise run check', which is not a task in mise.toml`, `exit=1`.

- [ ] **Step 5: Commit**

```bash
git add .claude/rules/cbk-conventions-reference.md .claude/rules/cbk-conventions.md
git commit -q -F - <<'MSG'
feat(V2): the block checks that every backstop a rule names exists

A CI job named as a hook's backstop but never landed is how a target's frozen
corpus went two weeks unguarded (context-builder-kit#60, suggestion 1). The kit
sub-block now reads the mutation table, the hook registry and every hook header,
and fails on a .github/workflows or scripts path that does not exist; the checker
is asked about bogus names first, and a mutation section that names no checkable
backstop is red. The table's ADR row names its workflow by path. The project
sub-block resolves `mise run <task>` names against mise.toml where one exists.

Red first: cbk-conventions.md § Mutation discipline names no CI backstop in a checkable form (.github/workflows/<file>.yml)

Trace: #60/c5876324022/corpus-s1, #60/c5881158391/port-s1,
#60/c5892401033/suggestion-1-built.
Decision: D51.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
```
### Task V2.7: The frozen-corpus recipe carries the CI job's closures, one checklist row per item (#60/c5901494943/1, #60/c5876324022/corpus-s2, #60/c5876324022/echosphere-z, #60/c5892401033/corpus-leg, #60/c5892401033/leg-defects, critic/6, critic/7; D55)

**Files:**
- Modify: `.claude/skills/consultation/references/frozen_corpus_ingestion.md` — § The enforcement set scaffold registers (its first bullet, and its closing sentence)
- Modify: `.claude/skills/scaffold/references/bootstrap_checklist_template.md` — § 3 Verification matrix, after its closing paragraph
- Modify: `.claude/skills/scaffold/references/brownfield_audit.md` — the frozen-corpus bullet (line 35)
- Modify: `.claude/skills/consultation/references/test_cases.md` — Test 4's handoff criterion
- Modify: `.claude/rules/cbk-conventions-reference.md` — § Verification (the kit sentinel)

**Interfaces:**
- Produces: the enforcement-set bullet `**The CI job's closures.**` (nine closures and the additions call), and six verification rows keyed `| Corpus hook |`, `| Corpus CI job |`, `| Corpus CI job's closures |`, `| Corpus \`.gitattributes\` |`, `| Corpus editor settings |`, `| Corpus formatter skip |`, which the block asserts.
- Consumes: `lib/resolve-path.sh`'s root-scoped mode (V2.2) and the ADR job's parse-nothing body (V2.1), which the recipe tells a target to build on. No corpus guard or corpus CI script ships (D55; spec § Non-goals).

- [ ] **Step 1: Write the failing check**

Edit `.claude/rules/cbk-conventions-reference.md` — in § Verification, replace the kit sentinel line (exact; it occurs once):
```bash
echo "verification: kit sub-block complete"
```
with (the new checks sit immediately before it):
```bash
# The frozen-corpus recipe (context-builder-kit#60): the enforcement set lists the CI job's closures and builds the job on
# the ADR job's parse-nothing body; the bootstrap checklist carries one verification row per item, never one for all.
{ grep -q "The CI job's closures" .claude/skills/consultation/references/frozen_corpus_ingestion.md && grep -qF ':(glob)' .claude/skills/consultation/references/frozen_corpus_ingestion.md; } || { echo "frozen_corpus_ingestion.md lacks the CI job's closure list or the parse-nothing body"; exit 1; }
for r in 'Corpus hook |' 'Corpus CI job |' "Corpus CI job's closures |" 'Corpus `.gitattributes` |' 'Corpus editor settings |' 'Corpus formatter skip |'; do grep -qF "| $r" .claude/skills/scaffold/references/bootstrap_checklist_template.md || { echo "the bootstrap checklist lacks the corpus verification row: $r"; exit 1; }; done
absent grep -n "carries the four items as one ro[w]" .claude/skills/consultation/references/frozen_corpus_ingestion.md
echo "verification: kit sub-block complete"
```

- [ ] **Step 2: Run it against the unfixed recipe**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'closure list|corpus verification row|^verification: (kit sub-block complete|done)$|^verification: block exited'; echo "exit=${PIPESTATUS[0]}"`
Expected:
```text
frozen_corpus_ingestion.md lacks the CI job's closure list or the parse-nothing body
verification: block exited 1
exit=1
```
Record the line in the red-first table.

- [ ] **Step 3: Verify the platform fact, then write the recipe and the rows**

Run: `curl -sL https://raw.githubusercontent.com/actions/checkout/11d5960a326750d5838078e36cf38b85af677262/README.md | grep -cF 'fetch all history for all branches and tags'`
Expected: `1`. If `0`, stop: the first closure quotes it.

Edit `.claude/skills/consultation/references/frozen_corpus_ingestion.md` — replace this text (exact; it occurs once):
```markdown
- **A hook and a CI job on the corpus pattern** — the immutability hook and the ADR-immutability CI job extended (or copied) to match the corpus path, with a block message that names the errata companion as the place a correction goes.
```
with:
```markdown
- **A hook and a CI job on the corpus pattern**, each with a block message that names the errata companion as the place a correction goes. The hook is a guard over the corpus path that sources `.claude/hooks/lib/resolve-path.sh` in its root-scoped mode — the corpus under the hook's own checkout, the project dir's and a linked worktree of either, each path resolved lexically and physically (`cbk-conventions-reference.md` § Hook authoring, on sourced helpers). The CI job extends (or copies) the kit's ADR-immutability job with that job's parse-nothing body — a `:(glob)` pathspec, `--no-renames`, a three-dot diff from the merge base, `--diff-filter=a` only if additions pass, any output failing and any git error failing — never an awk match on parsed paths, which reads a quoted non-ASCII name or a spaced one as "no change".
- **The CI job's closures.** The hook sees only the agent's edit tools; the CI job is the backstop for a Bash write, a hand edit or a case-insensitive filesystem, and a job that compares the corpus with its base can be fooled more ways than a hook. Two targets red-teamed their corpus jobs. Both implement every closure below, and each is a fixture case in at least one of them — except clearing git's environment and ignoring grafts, which neither fixture drives yet. The kit ships no corpus job; this list is what the two measured:
  - the base resolves from fully qualified refs (`refs/remotes/origin/<default>`, then `refs/heads/<default>`) — a tag or local branch named `origin/main` would shadow the bare name, and `actions/checkout` with `fetch-depth: 0` fetches "all history for all branches and tags" (its README at the kit's pinned SHA, read 2026-09-30); no base fails, never skips;
  - on the default branch, or a branch with no commits of its own, the merge base is HEAD, so the last commit is compared with its parent;
  - `GIT_DIR`, `GIT_WORK_TREE`, `GIT_INDEX_FILE` and their kin are cleared, and replace refs and grafts ignored;
  - nothing is sourced from the tree under check — a PR-supplied helper could define a `git` function that silences every diff;
  - the commits, the index and the working tree are each compared with the base, so an edit staged or committed with the tree put back is caught;
  - the bytes on disk are hashed with `--no-filters` against the base blob — git's own diffs trust the index (assume-unchanged, skip-worktree) and apply checkout conversions (`core.autocrlf`, a `.gitattributes` eol, encoding or filter a PR can commit);
  - a path's type is compared before its content, so a symlink standing in for a file is a change even when what it reaches is identical; a failed `readlink` stops the job;
  - every path list is read NUL-separated (`-z`) — a quoted non-ASCII name otherwise reads as a missing file;
  - every git call fails the job on error; an error is never read as "unchanged".

  Whether an added file passes (a newly frozen document added by hand in a reviewed commit) is the target's call: of the two targets, one allows additions and the other freezes the directory whole.
```


Edit `.claude/skills/consultation/references/frozen_corpus_ingestion.md` — replace this text (exact; it occurs once):
```markdown
Scaffold's brownfield audit and backend selection read the designated path from `## Pre-cascade sources`; the bootstrap checklist carries the four items as one row.
```
with:
```markdown
Scaffold's brownfield audit and backend selection read the designated path from `## Pre-cascade sources`; the verification matrix of the scaffold skill's `references/bootstrap_checklist_template.md` carries one row per item above, so no item is ticked off with the others.
```


Edit `.claude/skills/scaffold/references/bootstrap_checklist_template.md` — replace this text (exact; it occurs once):
```markdown
Only include rows that are actually applicable. State 2 (no projects toolset) omits the project board row. State 4 (no MCP) puts everything in section 2 (manual instructions) and the verification matrix becomes longer.
```
with:
~~~~markdown
Only include rows that are actually applicable. State 2 (no projects toolset) omits the project board row. State 4 (no MCP) puts everything in section 2 (manual instructions) and the verification matrix becomes longer.

**When a frozen corpus is designated** (`problem_brief.md` § Pre-cascade sources names one — the consultation skill's `references/frozen_corpus_ingestion.md`), the matrix gains one row per item of its enforcement set, so no item is ticked off with the others. Omit these rows when no corpus is designated:

```markdown
| Corpus hook | Pipe an Edit payload naming a corpus file into the corpus guard | Exit 2; the message names the errata companion | ☐ |
| Corpus CI job | Open a throwaway PR that edits one corpus file | The job fails, and its check is one of the ruleset's required contexts | ☐ |
| Corpus CI job's closures | Read the job against the closure list in `frozen_corpus_ingestion.md` § The enforcement set scaffold registers | Every closure is implemented; the ones the job's own fixture drives are named | ☐ |
| Corpus `.gitattributes` | `git check-attr linguist-documentation <corpus path>/<any file>` | The attribute reads `false` | ☐ |
| Corpus editor settings | Open a corpus file in the editor and save it unchanged | `git status` shows no change (no whitespace trim, no final newline added) | ☐ |
| Corpus formatter skip | Run the docs formatter's check over the corpus path | It rewrites nothing | ☐ |
```
~~~~


Edit `.claude/skills/scaffold/references/brownfield_audit.md` — replace this text (exact; it occurs once):
```markdown
and register the enforcement set in the same commit — the immutability hook and CI job extended to the corpus pattern with a block message naming the errata, the `.gitattributes` `linguist-documentation=false` line, the editor trim/newline unsets, the formatter skip entry.
```
with:
```markdown
and register the enforcement set in the same commit — a corpus guard on `.claude/hooks/lib/resolve-path.sh` and a CI job built on the ADR job's parse-nothing body with the closures that reference lists, each naming the errata in its block message; the `.gitattributes` `linguist-documentation=false` line; the editor trim/newline unsets; the formatter skip entry — and give each item its own row in the bootstrap checklist's verification matrix.
```


Edit `.claude/skills/consultation/references/test_cases.md` — replace this text (exact; it occurs once):
```markdown
- The brief's `## Handoff notes for later phases` addresses scaffold by name (land the corpus at the recorded path, register the enforcement set) and blueprint by name (which decisions may be promoted, with the `Promotes:` form)
```
with:
```markdown
- The brief's `## Handoff notes for later phases` addresses scaffold by name (land the corpus at the recorded path, register the enforcement set — the corpus guard, the CI job with its closures, and the other items, each a verification row of its own) and blueprint by name (which decisions may be promoted, with the `Promotes:` form)
```


The closures are re-authored from two targets' red-team rounds; the shipped text names neither target, and the kit ships none of their scripts.

- [ ] **Step 4: Run the block**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'closure list|corpus verification row|^verification: (kit sub-block complete|done)$|^verification: block exited'; echo "exit=${PIPESTATUS[0]}"`
Expected: `verification: kit sub-block complete`, `verification: done`, `exit=0`.

- [ ] **Step 5: Commit**

```bash
git add .claude/skills/consultation/references/frozen_corpus_ingestion.md .claude/skills/scaffold/references/bootstrap_checklist_template.md .claude/skills/scaffold/references/brownfield_audit.md .claude/skills/consultation/references/test_cases.md .claude/rules/cbk-conventions-reference.md
git commit -q -F - <<'MSG'
docs(V2): the frozen-corpus recipe carries the CI job's closures, one checklist row per item

Consultation's enforcement set told a target to extend the ADR job, which then
inherited its awk path match. The recipe now builds the corpus guard on
lib/resolve-path.sh's root-scoped mode and the corpus CI job on the ADR job's
parse-nothing body, and lists the nine closures two targets' red-team rounds
measured, ending with the additions call each target makes. The bootstrap
checklist gains one verification row per enforcement item, so no item is ticked
off with the others; brownfield audit and consultation's Test 4 say the same.
The block asserts the closures and the six rows.

Red first: frozen_corpus_ingestion.md lacks the CI job's closure list or the parse-nothing body

Trace: #60/c5901494943/1, #60/c5876324022/corpus-s2,
#60/c5876324022/echosphere-z, #60/c5892401033/corpus-leg,
#60/c5892401033/leg-defects, critic/6, critic/7.
Decision: D55.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
```
### Task V2.8: § Hook authoring names the fixture of every hook family and the three-edit wiring (#58/c5901493591/R1 (§ Verify by payload), #58/c5901493591/R11 (§ Hook authoring); D44)

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md` — § Hook authoring's "No hook-shaped object" bullet and Verify by payload bullet; § Verification (the kit sentinel)
- Modify: `.claude/workflows/tests/hook-contract-fixture.sh` (header line 8)

**Interfaces:**
- Produces: the sentence "Wiring one is three edits, not one: …" — V8 writes the same three edits into both advisory exemplars' `Register:` headers.
- Produces: the Verify by payload bullet naming `hook-guards-fixture.sh`, `hook-payloads-fixture.sh`, `protected-paths-hook-fixture.sh` and `hook-contract-fixture.sh`, asserted by the block.

- [ ] **Step 1: Write the failing check**

Edit `.claude/rules/cbk-conventions-reference.md` — in § Verification, replace the kit sentinel line (exact; it occurs once):
```bash
echo "verification: kit sub-block complete"
```
with (the new checks sit immediately before it):
```bash
# § Hook authoring › Verify by payload names the fixture of every hook family, and each one it names exists; the section
# says that wiring an advisory hook is three edits (context-builder-kit#58 item 4 and its residue).
vp=$(grep '^- \*\*Verify by payload\.\*\*' .claude/rules/cbk-conventions-reference.md)
for f in hook-guards-fixture.sh hook-payloads-fixture.sh protected-paths-hook-fixture.sh hook-contract-fixture.sh; do grep -qF "$f" <<<"$vp" || { echo "§ Hook authoring › Verify by payload does not name $f"; exit 1; }; [ -f ".claude/workflows/tests/$f" ] || { echo "§ Hook authoring › Verify by payload names $f, which does not exist"; exit 1; }; done
grep -q 'ADVISORY_WIRED' <<<"$(awk '/^## Hook authoring/{p=1; next} p && /^## /{exit} p' .claude/rules/cbk-conventions-reference.md)" || { echo "§ Hook authoring does not say that wiring an advisory hook also names it in ADVISORY_WIRED"; exit 1; }
echo "verification: kit sub-block complete"
```

- [ ] **Step 2: Run it against the unfixed section**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'Verify by payload|ADVISORY_WIRED|^verification: (kit sub-block complete|done)$|^verification: block exited'; echo "exit=${PIPESTATUS[0]}"`
Expected:
```text
§ Hook authoring › Verify by payload does not name hook-guards-fixture.sh
verification: block exited 1
exit=1
```
The bullet still says the payload-reachable branches are asserted in `hook-contract-fixture.sh`, which drives none of the ADR guard, the knowledge-backend ask-gate or the main-branch allow cases. Record the line.

- [ ] **Step 3: Rewrite the two bullets and the contract fixture's header**

Edit `.claude/rules/cbk-conventions-reference.md` — replace this text (exact; it occurs once):
```markdown
copied into `hooks.PostToolUse` after the case arms are filled — so a fresh checkout never runs a formatter it does not have.
```
with:
```markdown
copied into `hooks.PostToolUse` after the case arms are filled — so a fresh checkout never runs a formatter it does not have. Wiring one is three edits, not one: the stanza into `hooks.PostToolUse`, the hook's name into the project sub-block's `ADVISORY_WIRED`, and its name into `cbk-conventions.md` § Mutation discipline's two-views paragraph — the verification block checks all three, so a registration alone turns it red.
```


Edit `.claude/rules/cbk-conventions-reference.md` — replace this text (exact; it occurs once):
```markdown
- **Verify by payload.** When a hook is authored or changed, each branch it has is exercised by piping a crafted JSON payload and asserting the exact exit (only 2 denies — a crash is not a block), plus one real dispatch for a guard whose matcher is a dated observation; the branches a payload can reach are asserted in `.claude/workflows/tests/hook-contract-fixture.sh` (durable, run by the block), and the PR body's table is for the branches only a mutation can reach, named as such (context-builder-kit#58 item 4). The verification block re-runs a subset on every run — the launch-root guard's deny and allow payloads, and the Stop hook against the live tree — while a state-mutating dry-run (a stray memory tree, a commit on `main`) runs against a fixture or a throwaway clone at authoring time.
```
with:
```markdown
- **Verify by payload.** When a hook is authored or changed, each branch it has is exercised by piping a crafted JSON payload and asserting the exact exit (only 2 denies — a crash is not a block), plus one real dispatch for a guard whose matcher is a dated observation. The branches a payload can reach are asserted durably, one fixture per hook family under `.claude/workflows/tests/`, each run by the verification block: `hook-guards-fixture.sh` (the main-branch deny, the PR-state ask-gate, the lock-file deny, the knowledge-backend ask-gate), `hook-payloads-fixture.sh` (the launch-root guard, the fork detector) and `protected-paths-hook-fixture.sh` (the ADR guard and the path helper); `hook-contract-fixture.sh` holds the structural checks and one over-buffer probe per decision site. A target that adds a hook adds its cases to its family's fixture, or writes a fixture of its own and runs it from the block. The PR body's table is for the branches only a mutation can reach, named as such (context-builder-kit#58 item 4). The verification block also re-runs a subset against the live tree — the launch-root guard's deny and allow payloads, and the Stop hook — while a state-mutating dry-run (a stray memory tree, a commit on `main`) runs against a fixture or a throwaway clone.
```


Edit `.claude/workflows/tests/hook-contract-fixture.sh` — replace this text (exact; it occurs once):
```bash
# arms. Runs against throwaway `git init` trees under mktemp, never the real checkout, and never
```
with:
```bash
# arms; every branch a payload can reach is driven by the family fixtures beside it —
# hook-guards-fixture.sh, hook-payloads-fixture.sh and protected-paths-hook-fixture.sh.
# Runs against throwaway `git init` trees under mktemp, never the real checkout, and never
```


- [ ] **Step 4: Run the contract fixture and the block**

Run: `bash .claude/workflows/tests/hook-contract-fixture.sh`
Expected: `hook-contract-fixture: ok`.

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'Verify by payload|ADVISORY_WIRED|^verification: (kit sub-block complete|done)$|^verification: block exited'; echo "exit=${PIPESTATUS[0]}"`
Expected: `verification: kit sub-block complete`, `verification: done`, `exit=0`.

- [ ] **Step 5: Commit**

```bash
git add .claude/rules/cbk-conventions-reference.md .claude/workflows/tests/hook-contract-fixture.sh
git commit -q -F - <<'MSG'
docs(V2): section Hook authoring names every hook family's fixture and the three-edit wiring

Verify by payload said the payload-reachable branches were asserted in
hook-contract-fixture.sh, which drove none of the ADR guard, the knowledge-backend
ask-gate or the main-branch allow cases. It now names the fixture of each hook
family, all run by the block, and what a target does when it adds a hook. The
advisory-hook bullet says that wiring one is three edits: the stanza, the
ADVISORY_WIRED name and the two-views paragraph, each checked by the block. The
block asserts both.

Red first: § Hook authoring › Verify by payload does not name hook-guards-fixture.sh

Trace: #58/c5901493591/R1 (section Verify by payload), #58/c5901493591/R11
(section Hook authoring; the exemplars' Register: headers are V8's).
Decision: D44.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
```
### Task V2.9: Probe P4 — record whether CI runs the bind-mount cases (probe P4; D44)

**When:** after Task F4 Step 2 (the draft PR exists and `verify.yml` has run on it), before Task F4 Step 3. It is the one V2 commit that lands after the review floor; it changes one comment line of a fixture, which F2 does not re-review.

**Files:**
- Modify: `.claude/workflows/tests/protected-paths-hook-fixture.sh` (header lines 14–16)

**Interfaces:**
- Produces: a dated observation of the kit's CI runner in the fixture's header, and the P4 line of the PR body.

- [ ] **Step 1: Read the PR's run**

Run:
```bash
run=$(gh run list --branch feat/harvest-5-v1.0.0 --workflow verify.yml --limit 1 --json databaseId -q '.[0].databaseId')
gh run view "$run" --log | grep -E 'SKIP: three bind-mount cases|protected-paths-hook-fixture: [0-9]+ cases ok'
gh run view "$run" --json url,createdAt -q '.url + " " + .createdAt'
grep -m1 'runs-on:' .github/workflows/verify.yml
```
Expected: either **(i)** `SKIP: three bind-mount cases (unshare -rm unavailable: no unprivileged user and mount namespace)` and `protected-paths-hook-fixture: 45 cases ok`, or **(ii)** `protected-paths-hook-fixture: 48 cases ok` with no SKIP line; then the run's URL and timestamp, and the runner label. A count other than 45 or 48 means a `/proc` skip or a regression: stop and read the log.

- [ ] **Step 2: Write the observation**

In the text below, `<label>` is the `runs-on:` value the grep printed, `<url>` the run URL and `<date>` the run's date (the first ten characters of `createdAt`). These are the measured values; the sentence is otherwise exact.

For **(i)**:
Edit `.claude/workflows/tests/protected-paths-hook-fixture.sh` — replace this text (exact; it occurs once):
```bash
# mount namespace). Run by the verification block; also: bash .claude/workflows/tests/protected-paths-hook-fixture.sh
```
with:
```bash
# mount namespace). On the kit's CI runner (verify.yml, runs-on: <label>) `unshare -rm` is denied, so the bind-mount
# cases SKIP there and run on a host that allows them (observed <url>, <date>).
# Run by the verification block; also: bash .claude/workflows/tests/protected-paths-hook-fixture.sh
```


For **(ii)**, the same anchor, replaced with:
```bash
# mount namespace). On the kit's CI runner (verify.yml, runs-on: <label>) `unshare -rm` is allowed, so the bind-mount
# cases run there too (observed <url>, <date>).
# Run by the verification block; also: bash .claude/workflows/tests/protected-paths-hook-fixture.sh
```

- [ ] **Step 3: Run the fixture and the block**

Run: `bash .claude/workflows/tests/protected-paths-hook-fixture.sh | tail -1 && bash -n .claude/workflows/tests/protected-paths-hook-fixture.sh`
Expected: `protected-paths-hook-fixture: 48 cases ok` locally (or 45 with the SKIP line).

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'protected-paths-hook-fixture|^verification: (kit sub-block complete|done)$|^verification: block exited'; echo "exit=${PIPESTATUS[0]}"`
Expected: the fixture's line, `verification: kit sub-block complete`, `verification: done`, `exit=0`.

- [ ] **Step 4: Commit, push, and record P4 in the PR body**

```bash
git add .claude/workflows/tests/protected-paths-hook-fixture.sh
git commit -q -F - <<'MSG'
test(V2): record whether the kit's CI runs the bind-mount cases (probe P4)

The three bind-mount cases of protected-paths-hook-fixture.sh need an
unprivileged user and mount namespace, and print a SKIP line where the host has
none. The fixture's header now records, dated, what the kit's CI runner did on
this PR's run.

Probe: P4. Decision: D44.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
git push
```
Add to the PR body's probe section: `P4 — unshare -rm on <label>: <denied (bind-mount cases SKIP) | allowed (cases run)>, <url>`. The commit carries no CI-skip marker, so the branch still ends on a commit CI runs (Task F4 Step 3).

## Coverage

Every id in the V2 work pack — its items, the parts of other clusters' items handed in, the completeness critic's asks and the review findings — and where it lands.

| Id | Kind | Lands in |
|---|---|---|
| `#60/body/fix` | item | V2.2 (the hook's registry sentence: handed to V3) |
| `#60/body/alt` | item | V2.2 — no code; the helper's header and § Hook authoring's Project-relative paths bullet record why a root taken from the file's own checkout closes none of the ten spellings |
| `#60/body/fixture` | item | V2.2 (`protected-paths-hook-fixture.sh`: "CLAUDE_PROJECT_DIR set to another checkout", "another checkout's existing ADR") |
| `#60/c5876324022/table` | item | V2.2 |
| `#60/c5876324022/closed-1` | item | V2.2 (`rp_payload`; the refusal) |
| `#60/c5876324022/closed-2` | item | V2.2 (`rp_lexnorm`, `rp_canon`, `rp_target`) |
| `#60/c5876324022/closed-3` | item | V2.2 (`RP_THROUGH_PROC`; the fixture's `/proc` case, SKIP where `/proc` is absent) |
| `#60/c5876324022/closed-4` | item | V2.2 (`rp_same_entry` with `-ef`; the hardlink and bind-mount cases) |
| `#60/c5876324022/closed-5` | item | V2.2 (`rp_roots`; the relative-launch case) |
| `#60/c5876324022/closed-6` | item | V2.2 (the allow side: prefix sibling, another checkout's corpus, a symlink loop) |
| `#60/c5876324022/closed-note` | item | V2.2 (existence on the resolved path; the header's `Not seen:` line) |
| `#60/c5876324022/corpus-s1` | item | V2.6 (the registry's own sentence naming the ADR workflow: handed to V3) |
| `#60/c5876324022/corpus-s2` | item | V2.7 |
| `#60/c5876324022/adr-job` | item | V2.1 |
| `#60/c5876324022/echosphere-z` | item | V2.7 (the `-z` closure) |
| `#60/c5881158391/status` | item | handed to V10 (the v1.0.0 Sync note for a target that customized its ADR hook) |
| `#60/c5881158391/port-helper` | item | V2.2 |
| `#60/c5881158391/port-glob-body` | item | V2.1 |
| `#60/c5881158391/port-s1` | item | V2.6 |
| `#60/c5892401033/helper` | item | V2.2 (the registry sentence: handed to V3; `CLAUDE.md` layout and README hooks tree: handed to V10) |
| `#60/c5892401033/adr-path-independent` | item | V2.2 (header `Blocked:`; the "another checkout's existing ADR" case) |
| `#60/c5892401033/linked-worktrees` | item | V2.2 (`rp_linked_worktree`, called by the ADR hook's hardlink arm and by the fixture's corpus guard) |
| `#60/c5892401033/ef-inode` | item | V2.2 |
| `#60/c5892401033/gitignore-trap` | item | V2.2 (the trap named in § Hook authoring, citing § .gitignore anchoring; the block check). The negation bullet in § .gitignore anchoring and the starter harness block's negation line: handed to V8 (V8.4) |
| `#60/c5892401033/adr-job-glob-fixture` | item | V2.1 |
| `#60/c5892401033/suggestion-1-built` | item | V2.6 |
| `#60/c5892401033/corpus-leg` | item | V2.7 (the recipe's prose). The corpus CI script itself: non-goal (spec § Non-goals, D55) |
| `#60/c5892401033/leg-defects` | item | V2.7 (the type-before-content and failed-`readlink` closures) |
| `#60/c5892401033/fixture` | item | V2.2 |
| `#60/c5901494943/1` | item | V2.7 |
| `#60/c5901494943/2a` | item | V2.2 |
| `#60/c5901494943/2b` | item | V2.2 |
| `#60/c5901494943/2c` | item | V2.2 |
| `#60/c5901494943/2d` | item | V2.2 |
| `#60/c5901494943/2e` | item | V2.2 (one statement, in § Hook authoring) |
| `#60/c5901494943/3` | item | V2.1 |
| `#61/body/fix` | item | V2.1 |
| `#61/body/grep` | item | V2.1 (the grep recorded in the PR body; the block pins the absence) |
| `#62/body/lock-files` | item | V2.3 |
| `#62/body/pr-state` | item | V2.3 |
| `#62/body/main-branch` | item | V2.3 |
| `#62/body/extra-adr-hook` | item | V2.2 |
| `#58/c5901493591/R1` | item | V2.2 (path guard), V2.3 (four guards), V2.5 (two agent hooks), V2.8 (§ Verify by payload) |
| `#58/c5901493591/R6` | item | V2.5 |
| `#58/c5901493591/R8` | item | V2.3 |
| `#58/c5901493591/R11` | item | V2.8 (§ Hook authoring). Both exemplars' `Register:` headers: handed to V8 |
| `#58/c5901493591/R13` | item | V2.5 |
| `#73/body/2` | handed in (home V1) | V2.5 — `hook-payloads-fixture.sh` pins the literal `WARNING` on the detector's could-not-look branches; the detector's text is unchanged. V1 lands `stop_hook_clean` |
| `#67/c5892401572/2` | handed in (home V4) | V2.1 — `extract-run-block.sh`. V4 lands `review-assert-fixture.sh` on it |
| `#66/body/2` | handed in (home V9) | V2.3 — the ten-verb rationale moved into `require-knowledge-backend-ok.sh`'s header, its six-verb sentence corrected. The `_comment_hooks` trim: V9 and V3 |
| `#68/body/1a` | handed in (home V9) | V2.4 — the main-branch guard's two remediation comments. § Branch naming and the other echo sites: V9 |
| `#69/c5859756889/apply-h4/1` | handed in by V9 (not in the pack) | V2.2 — the sourced-helper bullet's last sentence: a target's own hooks under `.claude/hooks/` are held to § Hook authoring, and the contract fixture reads every file there. Named in V2.2's commit |
| `review/consistency/48` | handed in by V9 (not in the pack) | V2.2 — § Hook authoring's tally sentence, rewritten count-free. Named in V2.2's commit |
| `release/5` | handed in (home V10) | V2.2 (§ Hook authoring's three), V2.3 (`protect-lock-files.sh`), V2.5 (`detect-forked-agent-memory.sh` ×6, `require-repo-root-for-agents.sh`). The rest of the sweep and its block check: V9 and V10 |
| `critic/6` | critic | V2.7 |
| `critic/7` | critic | V2.7 |
| `critic/8` | critic | V2.3 (the ask-gate found by the registry; payload-cwd precedence both ways), with V2.2 and V2.5 (the block runs all three fixtures) |
| `review/security/19` | review (verified) | V2.1 |
| `review/security/20` | review (verified) | V2.4 |

Also landed here, with no trace row of their own: D61 on every hard-deny and ask-gate hook (V2.2, V2.3, V2.5); probe P1 (V2.5); probe P4 (V2.9); Review Focus 2, a project root containing a space (V2.2, V2.3, V2.5); V1's hand-off item 2, D52 for the ADR job, decided unconditional (V2.1); V1's hand-off item 3, the fresh scaffold re-run with the backstop slots filled, so Review Focus 4 keeps holding (V2.3); and `protect-main-branch.sh`'s missing `Depends:` line (V2.3).

## Handed to other clusters

- **V3** (owner of `.claude/settings.json`):
  - In `_comment_hooks`, the ADR sentence says the guard resolves the path lexically and physically through `.claude/hooks/lib/resolve-path.sh`, denies an existing numbered ADR in any checkout, and names `.github/workflows/adr-immutability-check.yml` as its backstop (`#60/body/fix`, `#60/c5892401033/helper`, `#60/c5876324022/corpus-s1`). V2.6's `backstops()` reads the registry, so the path named must exist.
  - The sentence "All guards fail open … on environment defects" gains that a hard-deny refuses, and an ask-gate asks, on a payload jq cannot read (D61; § Hook authoring's Fail-open bullet is the source).
  - The "Canonical dry-run" sentence names the three family fixtures instead of "the PR body's table" (R1; § Hook authoring › Verify by payload is the source).
  - Moving registrations to exec form makes two clauses in V2's § Hook authoring describe shell form: the Project-relative paths bullet ("The registry names `${CLAUDE_PROJECT_DIR}/.claude/hooks/<name>.sh`") and the stdin bullet ("a `command` entry with no `args` runs as one process …"). V3 edits those two clauses when it lands exec form; V2 grants that region. This declines V3's hand-off of `review/claude-code/10` to V2: its two sentences state the exec form and the block check that refuses shell form, and both exist only after V3.2, so written here they would be false for two commits. They land in V3.2's commit, the reassignment V3's own hand-off provides for.
- **V8**:
  - Both advisory exemplars' `Register:` headers carry the three edits in the words of V2.8's sentence (R11).
  - § .gitignore anchoring gains the negation bullet (V8.4 (c), `**A negation keeps the hook helpers tracked.**`), which V2.2's § Hook authoring bullet cites; under `cbk-conventions.md` § Multi-surface facts that bullet should name § Hook authoring back, as the sourced-helper contract's home. The starter `.gitignore` harness block in `github-starter-templates.md` carries `!/.claude/hooks/lib/` below every stack section (`#60/c5892401033/gitignore-trap`).
- **V9**: `#66/body/2`'s trim may now drop the ten-verb rationale from `_comment_hooks` (it lives in the hook header since V2.3). V2.2 lands and names `review/consistency/48` (§ Hook authoring's tally, rewritten count-free) and `#69/c5859756889/apply-h4/1` (a target's own hooks held to the section), both handed to V2 by V9. It also replaces the sibling parenthetical at the stdin bullet with `context-builder-kit#58 item 4`, so V9.21's first replacement is skipped; `review/portability/31` stays V9.21's row to name. The bare citations left in the reference half outside V2's regions (§ .gitignore anchoring, § Syncing the kit, § Verification's comments) are V8's, V10's and V1's or V9's.
- **V10**: `CLAUDE.md`'s layout line and the README hooks tree add `hooks/lib/` (`#60/c5892401033/helper`). The v1.0.0 Sync notes say: a target with a customized ADR hook takes the kit's hook plus `lib/resolve-path.sh` (a copy row and an add row) and checks `git status` shows the helper tracked, since an unanchored `lib/` in `.gitignore` hides it without a word; the ADR deny is now path-independent; the three backstop slots are filled at the disposition pass or the project sub-block goes red; an unreadable payload is refused or asked; the launch-root guard's behaviour after a `cd` (P1's variant); a target that copied the ADR job re-copies it (three-dot, blobless, `shell: bash`); three new fixtures run in the block (`#60/c5881158391/status`).
- **V1**: `verify.yml` is V1's file; the settled call that the kit's own workflows carry `defaults: run: shell: bash` and a named runner image lands there, as V2.1 lands it in the ADR job.
- **V4**: `extract-run-block.sh` is sourced as shipped; `review-assert-fixture.sh` finds its step by `- name:` value, as `adr-ci-body-fixture.sh` does.
- **V5**: the knowledge-axis-`none` dry run (Review Focus 3) expects `SKIP: the knowledge-backend ask-gate (no mcp__ matcher in settings.json — the knowledge axis is none)` from `hook-guards-fixture.sh`, and the ask-gate's header, not the rule file, carries the verb list.

## Not holding at planning time

None. Each unverified or partial claim in the V2 pack was re-checked against the kit on 2026-09-30:
- `review/security/19` holds: the two-dot body, extracted from the job and run on a throwaway repository whose base gained `0002-later.md` after the branch point, printed `D	docs/adr/0002-later.md` and exited 1 (V2.1 Step 2).
- `review/security/20` holds: `bash -c "git commit -m x"` on `main` exited 0 against the unfixed guard, and `bash -c "gh pr merge 5"` raised no ask (V2.4 Step 2). The verifier's corrected pattern is the one V2.4 ships: it also catches `/usr/bin/git commit` and leaves `git config commit.gpgsign true` allowed.
- `#62/body/pr-state` (partial) holds in part: the warning named a backstop, but a prose rule; V2.3 rewords it to "none mechanical".
- `#60/c5876324022/closed-note` and `#60/c5892401033/adr-path-independent` (partial) hold: the unfixed hook tested existence on the unresolved path and was root-scoped only by its prefix strip.
- `#61/body/grep` was never a defect claim (`no` at `74edf84`): the grep finds only the ADR job, and V2.1 pins the absence.
All of them are re-checked at execution by the red-first steps above.
