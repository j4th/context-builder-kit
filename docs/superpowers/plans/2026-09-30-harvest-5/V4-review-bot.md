# Harvest 5 — V4: Review-bot templates

This cluster closes the review-bot asks in the two blueprint workflow templates and the surfaces that describe them:
#67 (family aliases and an explicit `--effort` on every branch, the recorded model, the rebuilt "Assert the review
posted" step, the `paths` trigger, the prompt's reporting rules, the gate/allowlist note and the N sizing), #68 §2
(the base-branch configuration restore, the `.claude-pr/` copies, the symlinked and nested `CLAUDE.md`), #70 §1–3
(here-strings, `defaults: run: shell: bash`, `runs-on: ubuntu-24.04`, and the kit sub-block's three assertions) and
#58 R12, with four whole-kit review findings (security/18 workflow-level `concurrency`, security/22 the fork
guard, portability/35 the undated `track_progress` rail, claude-code/56 the CI skeleton's mutable tag pins) and seven
completeness-critic asks. It implements D47 and D48 and this cluster's share of D52 and D53. Trace rows: every `V4`
row of `2026-09-30-harvest-5-trace.md`, plus the handed-in `#69/c5859756889/3-C4`, `#69/c5881157875/3a` (template
half), `release/5` (the two template citations), `critic/18` (the fast branch's effort, from V5) and
`review/claude-code/56` (the CI skeleton's `uses:` pins, from V9); § Coverage maps each. It **consumes** V2's `.claude/workflows/tests/extract-run-block.sh` (the `extract_run_block`
function; V4 never defines it) and V1's runner, and it **hands** the `orchestration.md` review-bot paragraph and the
dated alias-release facts to V5 and the sync notes to V10 (§ Handed to other clusters). Two fixtures land here, each
run red against the unfixed template inside the commit that fixes it, and both run in the kit sub-block:
`review-trigger-fixture.py` (V4.2) and `review-assert-fixture.sh` (V4.3, extended in V4.4), which runs the
templates' own step bodies on **synthetic** comment pages and execution files authored for the kit — no recorded
project data ships. Every red and green result quoted below was produced by applying these exact edits to a scratch
clone of `643f7ff` (with a stand-in for V2's helper), task by task. Every quotation the text carries was fetched raw
and matched with `grep -F` on 2026-09-30; the fact steps re-run that match on the day of execution. Probe P3 (the
job-summary line) stays designed-unexercised, dated, with the evidence gathered (V4.4 Step 3).

**Conventions for this file.** Each **Edit** is one exact-string replacement: pass the first fenced block as the
Edit tool's `old_string` and the second as `new_string`, verbatim. Every anchor is text no other cluster's task
changes (master plan § Ownership map); if one is missing or matches twice, stop and reconcile — never guess. The
block edits anchor on the kit sentinel plus the blank line and the `PROJECT CHECKS` banner after it, so each task's
checks land immediately before `echo "verification: kit sub-block complete"`, after anything V1–V3 appended there;
if V1 renamed the banner, anchor on the sentinel line alone (it is unique in the file). No hook is touched in this
cluster, so the `bash -n` step applies to the fixture script. `always-loaded total` rises by 452 bytes in V4.6
(`tooling.md` 12,416 → 12,868); every other file this cluster touches is outside the always-loaded set. D59's split
(V5) pays for it; record the before and after for the PR body.

## Before V4.1 — preconditions (no commit)

- [ ] **Step 1: V1–V3 have landed and the block is green.**

Run: `cd /home/j4th/Code/create/context-builder-kit && git branch --show-current && bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`
Expected: `feat/harvest-5-v1.0.0`, then an `always-loaded total: <N> bytes` line, no `WARN` or `VIOLATION` line, `verification: kit sub-block complete`, `verification: done`,
`exit=0`. The runner is read by content, never by position: from V1 on, `run-verification-block-fixture` output
prints inside the block.

- [ ] **Step 2: V2's helper exists with the interface V4.3 and V4.4 source.**

Run: `bash -c '. .claude/workflows/tests/extract-run-block.sh && type -t extract_run_block'`
Expected: `function`. The contract relied on: `extract_run_block <workflow.yml> <step name>` prints the step's
`run: |` body, dedented, and prints nothing when the step or its `run:` is absent; the step name is compared as a
plain string. If V2 shipped another name or signature, stop and reconcile before V4.3.

- [ ] **Step 3: Define the fact-check helper** in the shell the fact steps run from. `$GH` serves a docs.github.com
article as raw markdown; `$CC/<page>.md` is a Claude Code page's raw form; `$A/<ref>/<path>` is the action's source.

```bash
fact() { local src=$1 page q; shift; page=$(curl -sL "$src" | sed -e "s/[‘’]/'/g" -e 's/[“”]/"/g'); [ -n "$page" ] || { echo "EMPTY: $src"; return 1; }; for q in "$@"; do if grep -qF -- "$q" <<<"$page"; then echo "ok: $q"; else echo "MISSING: $q"; fi; done; }
GH='https://docs.github.com/api/article/body?pathname=/en'
CC='https://code.claude.com/docs/en'
A='https://raw.githubusercontent.com/anthropics/claude-code-action'
mut() {  # mut <file> <old> <new> <command>: one exact replacement in a throwaway copy of the tree, then <command> there
  local M; M=$(mktemp -d); cp -a . "$M/kit"
  python3 - "$M/kit/$1" "$2" "$3" <<'PY'
import sys
p, old, new = sys.argv[1:4]
t = open(p, encoding="utf-8").read()
assert t.count(old) == 1, "mutant anchor is not unique: " + old
open(p, "w", encoding="utf-8").write(t.replace(old, new))
PY
  (cd "$M/kit" && eval "$4"); rm -rf "$M"
}
```

`mut` runs every mutant below on a copy, so the working tree is never touched.

A fact step passes only when every line reads `ok:`. A `MISSING:` line stops the task: reword the sentence to what
the page now says, re-date it, and note the change in the PR body. The text below carries `read 2026-09-30`, the
planning date. If a fact step runs on a later day, change `2026-09-30` to that day in the lines the task adds
(`git diff -U0` lists them) after the step passes — the planning-time observations dated 2026-09-24, 2026-09-29 and
2026-09-30 in V4.2–V4.5 keep their dates unless their probe is re-run.

### Task V4.1: The emitted workflows run bash with pipefail, on a named image, with no pipe into `grep -q` (`#70/body/1a`, `#70/body/1b`, `#70/body/1c`, `#70/body/2`, `#70/body/3`, `#67/c5901495773/8`, `critic/1`, `critic/2`, `review/claude-code/56`; D52)

**Files:**
- Modify: `.claude/skills/blueprint/references/templates/claude-review.yml` (the shell default before `jobs:`, the
`runs-on:` line, the label-removal step, the label picks)
- Modify: `.claude/skills/blueprint/references/templates/claude.yml` (the shell default, `runs-on:`, the skip check)
- Modify: `.claude/skills/blueprint/references/templates/tooling.md` (§ CI workflow construction pattern — the YAML
skeleton only: the shell default, `runs-on:`, and its two `uses:` pins)
- Modify: `.claude/skills/scaffold/references/github-starter-templates.md` (§ `.github/workflows/ci.yml` — the stub only)
- Modify: `.claude/rules/cbk-conventions-reference.md` (three kit-sub-block checks at the sentinel)

**Interfaces:**
- Consumes: nothing from earlier clusters beyond the green block.
- Produces: `defaults:` / `run:` / `shell: bash` in all four emitted workflows; `runs-on: ubuntu-24.04` in all four;
the label-removal step's captured read (`names="$(gh pr view …)" || { echo "::error::Could not read the PR's
labels."; exit 1; }`); the CI skeleton's two `uses:` lines in the fill-slot form `@[full-commit-sha] # v[version]`,
the form `claude.yml` pins its actions with, per the kit's full-SHA rule (`cbk-conventions-reference.md`
§ Dependency settle-window: "pin every `uses:` to a full commit SHA with a trailing version comment";
review/claude-code/56). The three checks (critic/1) are what V4.2–V4.6 must keep green: no `runs-on: ubuntu-latest`
under `.claude/skills/`; `^ *shell: bash$` in each of the four files; no `^[^#]*[|][[:space:]]*grep -[A-Za-z]*q` in
the two review templates. The kit's own `.github/workflows/*.yml` are V1's and V2's (the spec's settled call gives
them the same shell and image); these checks scope `.claude/skills/` only.

- [ ] **Step 1: Write the failing block checks.**

**Edit** — `.claude/rules/cbk-conventions-reference.md`: insert the lines immediately before the kit sentinel. Replace:

````
echo "verification: kit sub-block complete"

# ═══ PROJECT CHECKS
````

with:

````
# The workflows the kit emits (context-builder-kit#70): a named runner image, never the moving `-latest`
# label; `shell: bash` set in each, so every run: step has pipefail (unset, GitHub runs `bash -e {0}`); and no
# check piped into an early-exiting `grep -q`, which under pipefail can read a match as no match (§ Hook authoring).
absent grep -rn 'runs-on: ubuntu-lates[t]' .claude/skills/
for f in .claude/skills/blueprint/references/templates/claude-review.yml .claude/skills/blueprint/references/templates/claude.yml .claude/skills/blueprint/references/templates/tooling.md .claude/skills/scaffold/references/github-starter-templates.md; do grep -qE '^ *shell: bash$' "$f" || { echo "$f sets no 'shell: bash' (unset, GitHub runs bash -e {0}: no pipefail)"; exit 1; }; done
absent grep -nE '^[^#]*[|][[:space:]]*grep -[A-Za-z]*q' .claude/skills/blueprint/references/templates/claude-review.yml .claude/skills/blueprint/references/templates/claude.yml
echo "verification: kit sub-block complete"

# ═══ PROJECT CHECKS
````

- [ ] **Step 2: Run the block against the unfixed templates.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`
Expected (four `runs-on: ubuntu-latest` hit lines print above these, in the order `grep -r` walks the tree —
`github-starter-templates.md:192`, `claude-review.yml:72`, `claude.yml:50`, `templates/tooling.md:69` at `643f7ff`):

```
VIOLATION (matched above): grep -rn runs-on: ubuntu-lates[t] .claude/skills/
verification: block exited 1
exit=1
```

Record the `VIOLATION` line in the PR body's red-first table.

- [ ] **Step 3: Verify the platform facts this change writes** (P6), then make the change.

Run:

```bash
fact "$GH/actions/reference/workflows-and-actions/workflow-syntax" 'Note that this runs a different command to when `bash` is specified explicitly' 'bash --noprofile --norc -eo pipefail {0}' 'bash -e {0}'
fact "$GH/actions/reference/runners/github-hosted-runners" 'The `-latest` runner images are the latest stable images that GitHub provides' 'ubuntu-24.04'
fact "$GH/issues/using-labels-and-milestones-to-track-work/managing-labels" 'Deleting a label will remove the label from issues and pull requests'
```

Expected: six `ok:` lines. The label-deletion sentence sources critic/2's benign branch: the old comment called a
label deleted from the repository an error that "would break re-triggering for everyone"; deletion removes the label
from every PR, so this step sees it as already gone, and the comment now says re-triggering needs it recreated. The § Hook authoring citation is the kit's own
stdin/exit-contract bullet, which already states the pipefail-and-early-reader trap.

**Edit 1** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
concurrency:
  group: claude-review-${{ github.event.pull_request.number }}
  cancel-in-progress: true

jobs:
````

with:

````
concurrency:
  group: claude-review-${{ github.event.pull_request.number }}
  cancel-in-progress: true

# Every run: step runs `bash --noprofile --norc -eo pipefail {0}`. With no shell set, GitHub runs `bash -e {0}`
# instead, with no pipefail, so `cmd | tee log` passes when cmd fails. The shell table, of the unset case:
# "Note that this runs a different command to when `bash` is specified explicitly"
# (https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax, read 2026-09-30).
defaults:
  run:
    shell: bash

jobs:
````

**Edit 2** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
    runs-on: ubuntu-latest
    # Constraint 3 — a job-level timeout: the action has no timeout input of its own.
````

with:

````
    # A named image, never `ubuntu-latest`: "The `-latest` runner images are the latest stable images that
    # GitHub provides" (https://docs.github.com/en/actions/reference/runners/github-hosted-runners, read
    # 2026-09-30), so that label moves when GitHub re-points it and a runner change lands unreviewed. Bump
    # the image in a reviewed PR.
    runs-on: ubuntu-24.04
    # Constraint 3 — a job-level timeout: the action has no timeout input of its own.
````

**Edit 3** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
          set -uo pipefail
          # --repo because this step runs BEFORE checkout. Read the PR's labels first: the one
          # benign case is the label already gone from this PR (a concurrent run took it);
          # every other failure — including the label deleted from the repository's taxonomy,
          # which would break re-triggering for everyone — is an error.
          if gh pr view "$PR_NUMBER" --repo "$REPO" --json labels --jq '.labels[].name' | grep -qxF 'claude-review-again'; then
            gh pr edit "$PR_NUMBER" --repo "$REPO" --remove-label claude-review-again \
              || { echo "::error::Failed to remove the claude-review-again label."; exit 1; }
          else
            echo "Label already removed from this PR (benign concurrent run)."
          fi
````

with:

````
          set -uo pipefail
          # --repo because this step runs BEFORE checkout. The PR's labels are read first and captured,
          # so a failed read is an error, never "already removed". The one benign case is the label
          # already gone from this PR: a concurrent run took it, or the label was deleted from the
          # repository, which removes it everywhere — "Deleting a label will remove the label from
          # issues and pull requests" (https://docs.github.com/en/issues/using-labels-and-milestones-to-track-work/managing-labels,
          # read 2026-09-30) — and re-triggering then needs the label recreated. Every other failure
          # is an error. The match is a here-string, never `… | grep -q`: under pipefail a match can
          # read as no match once grep exits first (cbk-conventions-reference.md § Hook authoring).
          names="$(gh pr view "$PR_NUMBER" --repo "$REPO" --json labels --jq '.labels[].name')" \
            || { echo "::error::Could not read the PR's labels."; exit 1; }
          if grep -qxF 'claude-review-again' <<<"$names"; then
            gh pr edit "$PR_NUMBER" --repo "$REPO" --remove-label claude-review-again \
              || { echo "::error::Failed to remove the claude-review-again label."; exit 1; }
          else
            echo "Label already removed from this PR (a concurrent run took it, or the label was deleted from the repository)."
          fi
````

**Edit 4** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
          labels="${LABELS_JSON:-[]}"
          if printf '%s' "$labels" | grep -qF '"claude-deep-review"'; then
````

with:

````
          labels="${LABELS_JSON:-[]}"
          # Here-strings, never `printf … | grep -q`: under pipefail a match can read as no match.
          if grep -qF '"claude-deep-review"' <<<"$labels"; then
````

**Edit 5** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
          elif printf '%s' "$labels" | grep -qF '"claude-fast-review"'; then
````

with:

````
          elif grep -qF '"claude-fast-review"' <<<"$labels"; then
````

**Edit 6** — `.claude/skills/blueprint/references/templates/claude.yml`. Replace:

````
concurrency:
  group: claude-mention-${{ github.event.issue.number || github.event.pull_request.number }}
  cancel-in-progress: true

jobs:
````

with:

````
concurrency:
  group: claude-mention-${{ github.event.issue.number || github.event.pull_request.number }}
  cancel-in-progress: true

# `bash --noprofile --norc -eo pipefail {0}` on every run: step, not GitHub's `bash -e {0}` default, which has
# no pipefail (claude-review.yml's defaults comment carries the source).
defaults:
  run:
    shell: bash

jobs:
````

**Edit 7** — `.claude/skills/blueprint/references/templates/claude.yml`. Replace:

````
    runs-on: ubuntu-latest
    timeout-minutes: 20
````

with:

````
    # A named image, never `ubuntu-latest`, which moves when GitHub re-points it (claude-review.yml's runs-on
    # comment carries the source). Bump the image in a reviewed PR.
    runs-on: ubuntu-24.04
    timeout-minutes: 20
````

**Edit 8** — `.claude/skills/blueprint/references/templates/claude.yml`. Replace:

````
          elif printf '%s' "$ALL_LABELS" | grep -qF '"skip-claude"'; then
````

with:

````
          elif grep -qF '"skip-claude"' <<<"$ALL_LABELS"; then  # a here-string: under pipefail `printf … | grep -q` can read a match as none
````

**Edit 9** — `.claude/skills/blueprint/references/templates/tooling.md`. Replace:

````
jobs:
  <job-name-from-standards>:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: <language-setup-action@version>
````

with:

````
# `bash --noprofile --norc -eo pipefail {0}` on every run: step. Unset, GitHub runs `bash -e {0}`, with no
# pipefail (the shell table in https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax,
# read 2026-09-30).
defaults:
  run:
    shell: bash

jobs:
  <job-name-from-standards>:
    runs-on: ubuntu-24.04   # a named image: `ubuntu-latest` moves when GitHub re-points the label; bump in a reviewed PR
    steps:
      # Every `uses:` pinned to a full commit SHA with a trailing version comment, never a mutable tag, as the
      # review templates pin theirs (cbk-conventions-reference.md § Dependency settle-window); the update
      # bot's CI-actions entry bumps the pins.
      - uses: actions/checkout@[full-commit-sha] # v[version]
      - uses: <language-setup-action>@[full-commit-sha] # v[version]
````

**Edit 10** — `.claude/skills/scaffold/references/github-starter-templates.md`. Replace:

````
  push:
    branches: [main]

jobs:
  check:
````

with:

````
  push:
    branches: [main]

# `bash --noprofile --norc -eo pipefail {0}` on every run: step. Unset, GitHub runs `bash -e {0}`, with no
# pipefail (the shell table in https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax,
# read 2026-09-30).
defaults:
  run:
    shell: bash

jobs:
  check:
````

**Edit 11** — `.claude/skills/scaffold/references/github-starter-templates.md`. Replace:

````
    name: check
    runs-on: ubuntu-latest
````

with:

````
    name: check
    runs-on: ubuntu-24.04   # a named image: `ubuntu-latest` moves when GitHub re-points the label; bump in a reviewed PR
````

- [ ] **Step 4: Run the block, a YAML parse, the skeleton's pins, and the three mutants.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`
Expected: an `always-loaded total:` line unchanged against the previous commit's run (no always-loaded file is
touched), no `WARN` or `VIOLATION` line, `verification: kit sub-block complete`, `verification: done`, `exit=0`.

Run: `grep -E '^ *- uses: ' .claude/skills/blueprint/references/templates/tooling.md`
Expected (review/claude-code/56 — no mutable tag left in the skeleton):

```
      - uses: actions/checkout@[full-commit-sha] # v[version]
      - uses: <language-setup-action>@[full-commit-sha] # v[version]
```

Run: `python3 -c 'import sys, yaml; [yaml.safe_load(open(f)) for f in sys.argv[1:]]; print("yaml ok")' .claude/skills/blueprint/references/templates/claude-review.yml .claude/skills/blueprint/references/templates/claude.yml`
Expected: `yaml ok` (PyYAML is on this host; where it is not, say so in the PR body rather than skip silently).

Run each mutant (critic/1: each must turn the block red):

```bash
T=.claude/skills/blueprint/references/templates; B='bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2'
mut "$T/claude.yml" 'runs-on: ubuntu-24.04' 'runs-on: ubuntu-latest' "$B"
mut "$T/claude-review.yml" $'    shell: bash\n' $'    shell: sh\n' "$B"
mut "$T/claude-review.yml" "if grep -qF '\"claude-deep-review\"' <<<\"\$labels\"; then" "if printf '%s' \"\$labels\" | grep -qF '\"claude-deep-review\"'; then" "$B"
```

Expected, in order (each followed by `verification: block exited 1`):
`VIOLATION (matched above): grep -rn runs-on: ubuntu-lates[t] .claude/skills/`;
`.claude/skills/blueprint/references/templates/claude-review.yml sets no 'shell: bash' (unset, GitHub runs bash -e {0}: no pipefail)`;
`VIOLATION (matched above): grep -nE ^[^#]*[|][[:space:]]*grep -[A-Za-z]*q .claude/skills/blueprint/references/templates/claude-review.yml .claude/skills/blueprint/references/templates/claude.yml`.
The third mutant puts the deep-label `if` line back to `if printf '%s' "$labels" | grep -qF '"claude-deep-review"'; then`.

- [ ] **Step 5: Commit.**

```bash
git add .claude/skills/blueprint/references/templates/claude-review.yml .claude/skills/blueprint/references/templates/claude.yml .claude/skills/blueprint/references/templates/tooling.md .claude/skills/scaffold/references/github-starter-templates.md .claude/rules/cbk-conventions-reference.md
git commit -F - <<'MSG'
fix(review-bot): V4.1 — bash with pipefail, a named runner and here-strings in the emitted workflows

Every workflow the kit emits (both review templates, blueprint's CI skeleton, scaffold's CI stub) sets
`defaults: run: shell: bash`, so each run: step has pipefail, and runs on ubuntu-24.04 rather than the
moving -latest label. The review templates' label checks read a here-string instead of piping into an
early-exiting grep -q, and the label-removal step captures its label read, so a failed read is an
error and a label deleted from the repository is the sourced benign branch. The CI skeleton's two
`uses:` lines take the fill-slot form @[full-commit-sha] # v[version], as the review templates pin
theirs, instead of a mutable tag. The kit sub-block carries the three assertions, each shown red by a
mutant.

Trace: #70/body/1a, #70/body/1b, #70/body/1c, #70/body/2, #70/body/3, #67/c5901495773/8, critic/1, critic/2,
review/claude-code/56

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
```

### Task V4.2: When the review runs — a `paths` filter that reviews one-way-door markdown, job-level `concurrency`, a fork guard (`#67/c5901495773/1a`, `#67/c5901495773/1b`, `#67/c5901495773/1c`, `review/security/18`, `review/security/22`; D48)

**Files:**
- Create: `.claude/workflows/tests/review-trigger-fixture.py`
- Modify: `.claude/skills/blueprint/references/templates/claude-review.yml` (the trigger's filter, the workflow-level
`concurrency` removed, the job `if:` and its job-level `concurrency`, the prompt's skip clause)
- Modify: `.claude/skills/blueprint/references/templates/claude.yml` (the header bullet, `concurrency` to the job)
- Modify: `.claude/skills/blueprint/references/templates/tooling.md` (§ Automated review bot prompt construction —
the "Tool permissions and workflow-level config" sentence only)
- Modify: `.claude/rules/cbk-conventions-reference.md` (block lines at the sentinel)

**Interfaces:**
- Consumes: V4.1's `defaults:` block (its comment line `# Every run: step runs` anchors the concurrency removal).
- Produces: `python3 -B .claude/workflows/tests/review-trigger-fixture.py [workflow.yml …]` — with no arguments it
checks the filled `.github/workflows/claude-review.yml` where one exists and the blueprint template; exit 1 and a
`FAIL:` line on the first PR shape the filter gets wrong; exit 1 when it finds no workflow; a filled workflow with no
filter passes with a `NOTICE:` line (the spec's settled call), the template never does. The fork-guard string
`github.event.pull_request.head.repo.full_name == github.repository`. `concurrency:` only at job level in both
templates. The prose V10's sync note will name: a target's filled `claude-review.yml` is now checked by the kit
sub-block.
- The rows this lands: D48's order (`'**'`, the negations, then `.claude/**` and `docs/adr/**` last), with the page's
own wording in place of the issue's paraphrase (the settled call on the `paths-ignore` negation quote).

- [ ] **Step 1: Write the failing fixture and its block line.**

**Create** `.claude/workflows/tests/review-trigger-fixture.py` (mode 755), with exactly this content:

````python
#!/usr/bin/env python3
"""Which pull requests the auto-review workflow's path filter lets through, evaluated as GitHub does.

A docs-only PR is skipped, but markdown that is a one-way door — a rule, a skill, a command or an agent under
`.claude/`, an ADR under `docs/adr/` — is reviewed (pr-review.md § What NOT to flag: "Not automatically light
where the docs are one-way doors"). A cascade artifact under `docs/cbk/`, the other one-way door, stays skipped, as
the prompt's hard skip has it, and a human reviews it. `paths-ignore` cannot say that. GitHub's workflow syntax: "If
you want to both include and exclude path patterns for a single event, use the `paths` filter prefixed with the `!`
character to indicate which paths should be excluded", and "A matching positive pattern after a negative match will
include the path again" (https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax,
§ on.<push|pull_request|pull_request_target>.<paths|paths-ignore>, read 2026-09-30). So the filter is `paths:` with
its re-includes LAST, and this fixture pins the order: a re-include moved above the `!**/*.md` negation turns every
one-way-door PR back into a skipped one, silently.

Both semantics are evaluated, so the fixture reads a `paths-ignore` filter too, and goes red on the one-way-door
cases. Glob translation per the page's filter pattern cheat sheet: `*` matches any character but `/`, `**` any
character including `/` (and `**/` zero or more directories: `'**/README.md'` matches `README.md`), `?` zero or one
of the preceding character, and "Path patterns must match the whole path".

The blueprint template must carry a filter. A filled workflow with none reviews every PR; that is the project's
call, so it passes with a notice and its cases are skipped.
Run: python3 -B .claude/workflows/tests/review-trigger-fixture.py [workflow.yml ...]
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TEMPLATE = ROOT / ".claude/skills/blueprint/references/templates/claude-review.yml"
DEFAULT = [ROOT / ".github/workflows/claude-review.yml", TEMPLATE]


def glob_re(pattern: str) -> "re.Pattern[str]":
    out, i = "", 0
    while i < len(pattern):
        if pattern.startswith("**/", i):  # zero or more directories: '**/README.md' matches README.md
            out, i = out + "(?:.*/)?", i + 3
        elif pattern.startswith("**", i):
            out, i = out + ".*", i + 2
        elif pattern[i] == "*":
            out, i = out + "[^/]*", i + 1
        elif pattern[i] == "?":
            out, i = out + "?", i + 1
        else:
            out, i = out + re.escape(pattern[i]), i + 1
    return re.compile(out + r"\Z")


def trigger(text: str):
    """The pull_request filter kind (`paths` or `paths-ignore`) and its patterns, in order; None when there is none."""
    lines = text.splitlines()
    for n, line in enumerate(lines):
        m = re.match(r"^(\s+)(paths|paths-ignore):\s*$", line)
        if not m:
            continue
        indent, patterns = len(m.group(1)), []
        for item in lines[n + 1 :]:
            if not item.strip() or item.strip().startswith("#"):
                continue
            im = re.match(r"^(\s+)- ['\"]?([^'\"#]+?)['\"]?\s*(#.*)?$", item)
            if not im or len(im.group(1)) <= indent:
                break
            patterns.append(im.group(2))
        return m.group(2), patterns
    return None


def runs(kind: str, patterns: list, changed: list) -> bool:
    if kind == "paths-ignore":  # runs unless every changed path matches some pattern
        return any(not any(glob_re(p).match(f) for p in patterns) for f in changed)
    for f in changed:  # `paths`: patterns checked in order; a later match overrides an earlier one
        included = False
        for p in patterns:
            neg = p.startswith("!")
            if glob_re(p[1:] if neg else p).match(f):
                included = not neg
        if included:
            return True
    return False


CASES = [  # (a PR's changed paths, whether the review must run)
    (["src/app.py"], True),
    (["README.md", "src/app.py"], True),
    (["README.md"], False),
    (["docs/guide.md"], False),
    (["docs/cbk/frame-01.md"], False),
    ([".gitignore"], False),
    ([".claude/rules/pr-review.md"], True),
    ([".claude/skills/rough-in/SKILL.md"], True),
    ([".claude/commands/finish.md"], True),
    ([".claude/agents/adr-conformance-reviewer.md"], True),
    (["docs/adr/0042-example.md"], True),
    (["docs/adr/corrections.md", "README.md"], True),
]


def show(path: Path) -> str:
    """A workflow's path for a message: repository-relative where it can be, as given where it cannot."""
    try:
        return str(path.resolve().relative_to(ROOT))
    except ValueError:
        return str(path)


def main() -> int:
    files = [Path(a) for a in sys.argv[1:]] or [p for p in DEFAULT if p.exists()]
    if not files:  # a renamed workflow or a moved template must not pass as "0 cases ok"
        print(f"review-trigger-fixture: no review workflow to check (looked for {', '.join(show(p) for p in DEFAULT)})")
        return 1
    n = 0
    for wf in files:
        found = trigger(wf.read_text())
        if found is None:
            if wf.resolve() == TEMPLATE.resolve():
                print(f"FAIL: {show(wf)} has no paths or paths-ignore filter (the template must carry one)")
                return 1
            print(f"review-trigger-fixture: NOTICE: {show(wf)} has no path filter, so it reviews every PR; its cases are skipped")
            continue
        kind, patterns = found
        for changed, want in CASES:
            got = runs(kind, patterns, changed)
            if got != want:
                print(f"FAIL: {show(wf)}: a PR changing {changed} "
                      f"{'must' if want else 'must not'} run the review ({kind}: {patterns})")
                return 1
            n += 1
    print(f"review-trigger-fixture: {n} cases ok ({len(files)} workflow(s))")
    return 0


if __name__ == "__main__":
    sys.exit(main())
````

**Edit** — `.claude/rules/cbk-conventions-reference.md`: insert the lines immediately before the kit sentinel. Replace:

````
echo "verification: kit sub-block complete"

# ═══ PROJECT CHECKS
````

with:

````
# When the review runs: the path filter re-includes one-way-door markdown last (evaluated as GitHub does, over
# the template and any filled workflow); `concurrency` sits on the job, so a run the job's `if:` skips cannot cancel
# a live one; a fork PR, which gets no secrets, is skipped rather than failed.
python3 -B .claude/workflows/tests/review-trigger-fixture.py || { echo "the review workflow's path filter skips a PR it must review, or reviews one it must skip (the fixture names it)"; exit 1; }
absent grep -n '^concurrency:' .claude/skills/blueprint/references/templates/claude-review.yml .claude/skills/blueprint/references/templates/claude.yml
grep -qF 'github.event.pull_request.head.repo.full_name == github.repository' .claude/skills/blueprint/references/templates/claude-review.yml || { echo "templates/claude-review.yml has no fork guard in its job if:"; exit 1; }
echo "verification: kit sub-block complete"

# ═══ PROJECT CHECKS
````

- [ ] **Step 2: Run the fixture and the block against the unfixed template.**

Run: `python3 -B .claude/workflows/tests/review-trigger-fixture.py; echo "exit=$?"`
Expected:

```
FAIL: .claude/skills/blueprint/references/templates/claude-review.yml: a PR changing ['.claude/rules/pr-review.md'] must run the review (paths-ignore: ['docs/cbk/**', '**/*.md', '.gitignore', '.gitattributes', '.editorconfig', '.github/dependabot.yml'])
exit=1
```

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`
Expected: `the review workflow's path filter skips a PR it must review, or reviews one it must skip (the fixture names it)`,
`verification: block exited 1`, `exit=1`. Record the `FAIL:` line in the red-first table.

- [ ] **Step 3: Verify the platform facts, then make the change.**

Run:

```bash
fact "$GH/actions/reference/workflows-and-actions/workflow-syntax" 'use the `paths` filter prefixed with the `!` character to indicate which paths should be excluded' 'A matching positive pattern after a negative match will include the path again' 'Path patterns must match the whole path' 'If you want to both include and exclude path patterns for a single event'
fact "$GH/actions/reference/workflows-and-actions/events-that-trigger-workflows" 'With the exception of `GITHUB_TOKEN`, secrets are not passed to the runner when a workflow is triggered from a forked repository' 'The `GITHUB_TOKEN` has read-only permissions in pull requests from forked repositories'
grep -qF 'Not automatically light where the docs are one-way doors' .claude/rules/pr-review.md && echo "ok: pr-review.md § What NOT to flag"
```

Expected: seven `ok:` lines. The concurrency move rests on no documented sentence: the page says a group holds "at
most one running job or workflow", not when a skipped job joins one. The comment therefore states it as a dated
observation (runs that only skip were seen taking part in a workflow-level group — the review verifier's reading of
a target's run history, 2026-09-30) and marks the job-level half designed-unexercised with its re-check trigger.

**Edit 1** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
    # Docs-only and cascade-artifact PRs are not reviewed by the bot. This is NOT a
    # required check, so a paths filter is safe here (unlike ci.yml — cbk-conventions-reference.md
    # § Required-checks trap). A docs-only PR whose docs are one-way
    # doors (ADRs, the conventions) is reviewed by a human, not skipped by everyone.
    paths-ignore:
      - 'docs/cbk/**'
      - '**/*.md'
      - '.gitignore'
      - '.gitattributes'
      - '.editorconfig'
      - '.github/dependabot.yml'
      # [add the project's other prose-only paths]
````

with:

````
    # Docs-only PRs are not reviewed by the bot, but one-way-door markdown is: rules, skills, commands and
    # agents under `.claude/`, and ADRs under `docs/adr/` (pr-review.md § What NOT to flag: "Not
    # automatically light where the docs are one-way doors"). A cascade artifact under `docs/cbk/`, the other
    # one-way door, stays skipped, as the prompt's hard skip has it, and a human reviews it. `paths-ignore`
    # cannot re-include a path. GitHub: "use the `paths` filter prefixed with the `!` character to indicate
    # which paths should be excluded", and "A matching positive pattern after a negative match will include
    # the path again" (https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax,
    # read 2026-09-30). So the re-includes come LAST: one moved above `!**/*.md` silently skips every
    # one-way-door PR again, and `.claude/workflows/tests/review-trigger-fixture.py` pins the order. This is
    # NOT a required check, so a path filter is safe here (unlike ci.yml — cbk-conventions-reference.md
    # § Required-checks trap). The cost is more review runs against the subscription quota the token draws on.
    paths:
      - '**'
      - '!docs/cbk/**'
      - '!**/*.md'
      - '!.gitignore'
      - '!.gitattributes'
      - '!.editorconfig'
      - '!.github/dependabot.yml'
      # [add the project's other prose-only paths, each with a leading `!`, above the re-includes]
      - '.claude/**'
      - 'docs/adr/**'
````

**Edit 2** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
concurrency:
  group: claude-review-${{ github.event.pull_request.number }}
  cancel-in-progress: true

# Every run: step runs
````

with:

````
# Every run: step runs
````

**Edit 3** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
    name: Auto-review (inline + summary)
    if: |
      (github.event.action != 'labeled' || github.event.label.name == 'claude-review-again') &&
````

with:

````
    name: Auto-review (inline + summary)
    # A PR from a fork is skipped, not failed: "With the exception of `GITHUB_TOKEN`, secrets are not passed to
    # the runner when a workflow is triggered from a forked repository", and that token is read-only there
    # (https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows, read
    # 2026-09-30). The action could not authenticate, and every outside contribution would get a red check. A
    # human reviews a fork PR.
    if: |
      github.event.pull_request.head.repo.full_name == github.repository &&
      (github.event.action != 'labeled' || github.event.label.name == 'claude-review-again') &&
````

**Edit 4** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
      github.event.pull_request.user.login != 'claude[bot]'
    # A named image, never `ubuntu-latest`:
````

with:

````
      github.event.pull_request.user.login != 'claude[bot]'
    # `concurrency` sits on the job, not the workflow. A workflow-level group is entered by every run the
    # trigger creates, including a `labeled` run this job's `if:` then skips, and with `cancel-in-progress` that
    # run cancels the review in flight — runs that only skip were seen taking part in a workflow-level group in
    # a target's run history (2026-09-30). A job its `if:` skips never starts, so it should never enter a
    # job-level group: designed-unexercised (2026-09-30), re-check on the first `labeled` run after this lands.
    concurrency:
      group: claude-review-${{ github.event.pull_request.number }}
      cancel-in-progress: true
    # A named image, never `ubuntu-latest`:
````

**Edit 5** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
            - Docs-only or cascade-artifact PRs (`docs/cbk/`, `*.md` only): post the one-line summary
              `Docs-only PR — auto-review skipped per rule` and exit — unless the docs are one-way
              doors (ADRs, the conventions), which a human reviews.
````

with:

````
            - Docs-only or cascade-artifact PRs (`docs/cbk/`, `*.md` only): post the one-line summary
              `Docs-only PR — auto-review skipped per rule` and exit — unless the markdown is under
              `.claude/` or `docs/adr/`: rules, skills, commands, agents and ADRs are one-way doors,
              and you review them like code.
````

**Edit 6** — `.claude/skills/blueprint/references/templates/claude.yml`. Replace:

````
#   - concurrency + cancel-in-progress so a rapid back-and-forth does not queue
````

with:

````
#   - job-level concurrency + cancel-in-progress so a rapid back-and-forth does not queue
````

**Edit 7** — `.claude/skills/blueprint/references/templates/claude.yml`. Replace:

````
concurrency:
  group: claude-mention-${{ github.event.issue.number || github.event.pull_request.number }}
  cancel-in-progress: true

# `bash --noprofile
````

with:

````
# `bash --noprofile
````

**Edit 8** — `.claude/skills/blueprint/references/templates/claude.yml`. Replace:

````
      (github.event_name == 'issues' && (contains(github.event.issue.body, '@claude') || contains(github.event.issue.title, '@claude')))
    # A named image
````

with:

````
      (github.event_name == 'issues' && (contains(github.event.issue.body, '@claude') || contains(github.event.issue.title, '@claude')))
    # On the job, not the workflow: every comment and review event creates a run, and a workflow-level group
    # would let a run this `if:` skips (a reply with no @claude, a comment the bot posts) cancel the response
    # in flight (claude-review.yml's concurrency comment).
    concurrency:
      group: claude-mention-${{ github.event.issue.number || github.event.pull_request.number }}
      cancel-in-progress: true
    # A named image
````

**Edit 9** — `.claude/skills/blueprint/references/templates/tooling.md`. Replace:

````
For GitHub Actions specifically: `paths-ignore` for docs-only PRs, `concurrency` group with `cancel-in-progress`, `timeout-minutes` cap, `permissions:` block scoped to read-only contents + write pull-requests, `if:` filter for drafts/bots.
````

with:

````
For GitHub Actions specifically: a `paths` filter that skips docs-only PRs but re-includes one-way-door markdown (`.claude/**`, `docs/adr/**`) last — `paths-ignore` cannot re-include, and `templates/claude-review.yml`'s trigger comment says why the order matters; a job-level `concurrency` group with `cancel-in-progress`, so a run the job's `if:` skips cannot cancel a live review; a `timeout-minutes` cap; a `permissions:` block scoped to read-only contents + write pull-requests; an `if:` filter for drafts, bots and fork PRs.
````

- [ ] **Step 4: Run the fixture, a moved re-include, the no-filter notice, a YAML parse and the block.**

Run: `python3 -B .claude/workflows/tests/review-trigger-fixture.py; echo "exit=$?"`
Expected: `review-trigger-fixture: 12 cases ok (1 workflow(s))`, `exit=0`.

Run (a re-include moved above the negation must go red; a filled workflow with no filter must pass with a notice):

```bash
M=$(mktemp -d); T=.claude/skills/blueprint/references/templates/claude-review.yml
python3 - "$T" "$M/moved.yml" <<'PY'
import sys
t = open(sys.argv[1]).read()
t = t.replace("      - '.claude/**'\n", "", 1).replace("      - '!**/*.md'\n", "      - '.claude/**'\n      - '!**/*.md'\n", 1)
open(sys.argv[2], "w").write(t)
PY
python3 -B .claude/workflows/tests/review-trigger-fixture.py "$M/moved.yml"; echo "moved exit=$?"
awk '/^    paths:$/{skip=1; next} skip && /^      [-#]/{next} {skip=0; print}' "$T" > "$M/nofilter.yml"  # drops the filter block only; the steps stay
python3 -B .claude/workflows/tests/review-trigger-fixture.py "$M/nofilter.yml"; echo "nofilter exit=$?"
rm -rf "$M"
```

Expected: `FAIL: <tmp>/moved.yml: a PR changing ['.claude/rules/pr-review.md'] must run the review (paths: ['**', '!docs/cbk/**', '.claude/**', '!**/*.md', '!.gitignore', '!.gitattributes', '!.editorconfig', '!.github/dependabot.yml', 'docs/adr/**'])`,
`moved exit=1`; then `review-trigger-fixture: NOTICE: <tmp>/nofilter.yml has no path filter, so it reviews every PR; its cases are skipped`,
`review-trigger-fixture: 0 cases ok (1 workflow(s))`, `nofilter exit=0`.

Run: `python3 -c 'import sys, yaml; [yaml.safe_load(open(f)) for f in sys.argv[1:]]; print("yaml ok")' .claude/skills/blueprint/references/templates/claude-review.yml .claude/skills/blueprint/references/templates/claude.yml`
Expected: `yaml ok`.

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`
Expected: an `always-loaded total:` line unchanged against the previous commit's run, no `WARN` or `VIOLATION` line,
`verification: kit sub-block complete`, `verification: done`, `exit=0`.

- [ ] **Step 5: Commit.**

```bash
git add .claude/workflows/tests/review-trigger-fixture.py .claude/skills/blueprint/references/templates/claude-review.yml .claude/skills/blueprint/references/templates/claude.yml .claude/skills/blueprint/references/templates/tooling.md .claude/rules/cbk-conventions-reference.md
git commit -F - <<'MSG'
feat(review-bot): V4.2 — review one-way-door markdown, job-level concurrency and a fork guard

The review trigger is a `paths` filter whose re-includes (.claude/**, docs/adr/**) come after the
markdown negation, so rules, skills, commands, agents and ADRs are reviewed while docs-only PRs are
not; review-trigger-fixture.py evaluates the filter as GitHub does over twelve PR shapes and runs in
the kit sub-block, red first on the old paths-ignore. `concurrency` moves to the job in both
templates, so a run the job's if: skips cannot cancel a live review or response, and a fork PR, which
gets no secrets, is skipped rather than failed. The prompt's skip clause and blueprint's review-bot
paragraph name the same shape.

Trace: #67/c5901495773/1a, #67/c5901495773/1b, #67/c5901495773/1c, review/security/18, review/security/22

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
```

### Task V4.3: The assertion reads every page, keys on the verdict, and says why no session ran (`#67/c5877251222/1`, `#67/c5877251222/2`, `#67/c5877251222/3`, `#67/c5877251222/4`, `#67/c5881158070/1 (corrected by c5892401572/1)`, `#67/c5892401572/2`, `#67/c5892401572/3`, `#67/c5901495773/confirm-2`, `critic/12`, `critic/13`; D47's `id: review`, spec § Settled calls › Review bot)

**Files:**
- Create: `.claude/workflows/tests/review-assert-fixture.sh`
- Modify: `.claude/skills/blueprint/references/templates/claude-review.yml` (Constraint 4's stamp, `id: review` on the
Auto-review step, the "Assert the review posted" step)
- Modify: `.claude/rules/cbk-conventions-reference.md` (a block line at the sentinel)

**Interfaces:**
- Consumes: V2's `extract_run_block <workflow.yml> <step name>` from `.claude/workflows/tests/extract-run-block.sh`
(sourced, never redefined; the fixture refuses to run without it). V4.2's `!cancelled()` rationale (a superseded
run through `concurrency`).
- Produces: `id: review` on the Auto-review step — V4.4's record step reads `steps.review.outputs.execution_file`.
The step's env names `SESSION_RAN` and `BASE_SHA`; its condition `${{ !cancelled() }}`; the verdict pattern
`test("APPROVE|REQUEST CHANGES|NEEDS DISCUSSION")`, tied in its comment to the prompt's verdict line. The notices
`The review session ran but no summary with a verdict landed`, `… so this is an auth or setup failure, not a
validation skip`, `The review was skipped by claude-code-action's workflow validation` and `Could not list the PR's
comments` / `Could not read the PR's comments as JSON`. `bash .claude/workflows/tests/review-assert-fixture.sh`
(extended in V4.4); it finds the step by the prefix `- name: Assert the review posted`, so a filled workflow that
drops the `(constraint 4 …)` suffix is still found.
- Settled decisions honoured: the fixture ships with synthetic comment pages authored here (no recorded data); the
step's comment states its base-SHA limit for a PR into a non-default base; `REVIEW_LOGIN` stays the template's
placeholder, passed to `jq --arg`, rather than a hard-coded login. critic/12 is answered in the comment: the
`conclusion` output is not used because it is declared only from v1.0.188, while `execution_file` is declared at
every tag from v1.0.0 on.

- [ ] **Step 1: Write the failing fixture and its block line.**

**Create** `.claude/workflows/tests/review-assert-fixture.sh` (mode 755), with exactly this content:

````bash
#!/usr/bin/env bash
# Fixture for the review workflow's "Assert the review posted" step: runs the step's own `run:` body, extracted from
# the workflow by extract-run-block.sh (never a copy), with a fake `gh` first on PATH and a throwaway git repository
# standing in for the checkout. The comment pages are SYNTHETIC, authored here; no recorded project data ships. It
# checks blueprint's templates/claude-review.yml, and a filled .github/workflows/claude-review.yml where one exists.
# Asserts:
#   - a separate summary comment with a verdict passes, and so does a tracker comment that ends with the verdict;
#   - a summary on the second page of a 32-comment PR passes (the pages are slurped once, then counted; the fake
#     gh refuses --jq, which runs once per page);
#   - a summary written before the job started and edited after it passes (updated_at); one never touched since
#     then fails, and the failure names the start time;
#   - a tracker comment with no verdict fails, and the notice says the session ran and how to re-trigger;
#   - a verdict from another login does not count;
#   - an unreadable comment list fails and says so, whether `gh api` fails or answers with something not JSON;
#   - no session and this PR changing the workflow fails with the validation-skip notice, posted to the PR; no
#     session with the workflow unchanged fails with the auth-or-setup notice instead;
#   - structure: the step's condition is `${{ !cancelled() }}`, the job's first step records the start time, the
#     step reads it, and SESSION_RAN is keyed on the execution_file of the step with `id: review`.
# Each body runs the way GitHub runs a `shell: bash` step: bash --noprofile --norc -eo pipefail.
# Hermetic: mktemp trees only. Needs bash, git (2.28+, for `init -b`), jq.
# Run: bash .claude/workflows/tests/review-assert-fixture.sh
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../../.." && pwd)
command -v jq >/dev/null && command -v git >/dev/null || { echo "FAIL: review-assert-fixture needs jq and git"; exit 1; }
[ -f "$here/extract-run-block.sh" ] || { echo "FAIL: extract-run-block.sh is missing beside this fixture"; exit 1; }
# shellcheck source=extract-run-block.sh
. "$here/extract-run-block.sh"
type extract_run_block >/dev/null 2>&1 || { echo "FAIL: extract-run-block.sh defines no extract_run_block"; exit 1; }
wfs=("$root/.claude/skills/blueprint/references/templates/claude-review.yml")
[ -f "$root/.github/workflows/claude-review.yml" ] && wfs+=("$root/.github/workflows/claude-review.yml")

t=$(mktemp -d)
trap 'rm -rf "$t"' EXIT
mkdir -p "$t/bin"
cat > "$t/bin/gh" <<'EOF'
#!/usr/bin/env bash
# Fake gh: `gh api …` prints $FAKE_PAGES (or fails when FAKE_API_FAIL=1) and refuses --jq, which gh runs once per
# page; `gh pr comment … --body B` logs B.
case "$1" in
  api) case " $* " in *" --jq "*) echo "fake gh: --jq runs once per page; fetch the pages, then count them with jq -s" >&2; exit 2 ;; esac
       if [ "${FAKE_API_FAIL:-0}" = 1 ]; then echo "gh: HTTP 502" >&2; exit 1; fi; cat "$FAKE_PAGES" ;;
  pr) shift; while [ $# -gt 0 ]; do if [ "$1" = --body ]; then printf '%s\n' "$2" >> "$FAKE_POSTED"; fi; shift; done ;;
  *) echo "fake gh: unexpected: $*" >&2; exit 2 ;;
esac
EOF
chmod +x "$t/bin/gh"

# A checkout with a base and a head commit; `changed` makes HEAD differ in the workflow file the action validates.
repo() {  # repo <dir> <changed|same>
  git init -q -b main "$1"
  mkdir -p "$1/.github/workflows"; printf 'name: x\n' > "$1/.github/workflows/claude-review.yml"
  git -C "$1" add -A; git -C "$1" -c user.email=f@x -c user.name=f -c commit.gpgsign=false commit -q -m base
  if [ "$2" = changed ]; then printf 'name: y\n' > "$1/.github/workflows/claude-review.yml"; fi
  printf 'x\n' > "$1/other.txt"
  git -C "$1" add -A; git -C "$1" -c user.email=f@x -c user.name=f -c commit.gpgsign=false commit -q -m head
}
repo "$t/changed" changed; repo "$t/same" same

# Synthetic comment pages: c <login> <created_at> <updated_at> <body> is one comment; page joins comments into one page.
c() { jq -cn --arg u "$1" --arg c "$2" --arg up "$3" --arg b "$4" '{user: {login: $u}, created_at: $c, updated_at: $up, body: $b}'; }
page() { local IFS=,; printf '[%s]\n' "$*"; }
S=2026-09-28T01:00:00Z   # the job's recorded start
BOT='claude[bot]'
page "$(c octocat 2026-09-28T00:59:00Z 2026-09-28T00:59:00Z 'Looks fine to me.')" \
     "$(c "$BOT" 2026-09-28T01:05:00Z 2026-09-28T01:05:00Z '**REQUEST CHANGES** — 2 Apply, 1 Surface')" > "$t/summary.json"
page "$(c "$BOT" 2026-09-28T01:01:00Z 2026-09-28T01:09:00Z $'**Claude finished the task in 3m 2s** — [View job](https://example/run)\n\n**APPROVE WITH NITS** — 3 Surface')" > "$t/tracker-verdict.json"
page "$(c "$BOT" 2026-09-28T01:01:00Z 2026-09-28T01:04:00Z '**Claude finished the task in 3m 2s** — [View job](https://example/run)')" > "$t/tracker.json"
first=(); for i in $(seq 1 30); do first+=("$(c octocat "$S" "$S" "comment $i")"); done
{ page "${first[@]}"; page "$(c octocat "$S" "$S" 'comment 31')" "$(c "$BOT" 2026-09-28T01:05:00Z 2026-09-28T01:05:00Z '**NEEDS DISCUSSION**')"; } > "$t/paged.json"
page "$(c "$BOT" 2026-09-27T12:00:00Z 2026-09-28T01:02:00Z '**APPROVE** — no findings')" > "$t/edited.json"
page "$(c "$BOT" 2026-09-27T12:00:00Z 2026-09-27T12:00:00Z '**APPROVE** — no findings')" > "$t/stale.json"
page "$(c 'github-actions[bot]' 2026-09-28T01:05:00Z 2026-09-28T01:05:00Z 'NEEDS DISCUSSION — posted by another app')" > "$t/otherapp.json"
printf '[]\n' > "$t/empty.json"
printf 'not json\n' > "$t/notjson.json"

n=0
run() {  # run <body> <want-exit> <description> <pages> <session-ran> <repo> [VAR=value …]
  local body=$1 want=$2 desc=$3 pages=$4 ran=$5 dir=$6 rc=0; shift 6
  : > "$t/posted"
  (cd "$dir" && env PATH="$t/bin:$PATH" FAKE_PAGES="$pages" FAKE_POSTED="$t/posted" GH_TOKEN=x PR_NUMBER=1 REPO=o/r \
    STARTED_AT="$S" REVIEW_LOGIN="$BOT" SESSION_RAN="$ran" BASE_SHA="$(git -C "$dir" rev-parse HEAD~1)" \
    RUN_URL=https://example/run "$@" bash --noprofile --norc -eo pipefail "$body") > "$t/out" 2>&1 || rc=$?
  n=$((n + 1))
  [ "$rc" -eq "$want" ] || { echo "FAIL: $desc (want exit $want, got $rc)"; sed 's/^/  | /' "$t/out"; exit 1; }
}
says() { grep -qF -- "$1" "$t/out" || { echo "FAIL: $2 (output lacks '$1')"; sed 's/^/  | /' "$t/out"; exit 1; }; }
posted() { grep -qF -- "$1" "$t/posted" || { echo "FAIL: $2 (the PR notice lacks '$1')"; sed 's/^/  | /' "$t/posted"; exit 1; }; }

for wf in "${wfs[@]}"; do
  rel=${wf#"$root"/}
  name=$(grep -m1 -oE -e '- name: Assert the review posted.*' "$wf" | sed 's/^- name: //') || true
  [ -n "$name" ] || { echo "FAIL: $rel has no 'Assert the review posted' step"; exit 1; }
  body=$(extract_run_block "$wf" "$name")
  [ -n "$body" ] || { echo "FAIL: $rel: the '$name' step has no run: body"; exit 1; }
  printf '%s\n' "$body" > "$t/assert.sh"

  # Structure: a cancelled run is not evaluated; a comment older than the job's start never counts; an empty
  # execution_file is what tells "no session" apart.
  cond=$(awk -v want="- name: $name" 'index($0, want) {f=1; next} f && /^ *- name: /{exit} f && /^ *if: /{sub(/^ *if: /, ""); print; exit}' "$wf")
  [ "$cond" = '${{ !cancelled() }}' ] || { echo "FAIL: $rel: the assert step's condition is '$cond', not '\${{ !cancelled() }}' (always() reports a superseded run as a failure)"; exit 1; }
  first_step=$(awk '/^    steps:/{f=1; next} f && /^ *- name: /{print; exit}' "$wf")
  grep -q 'Record job start' <<<"$first_step" || { echo "FAIL: $rel: the job's first step is not 'Record job start' (got: $first_step)"; exit 1; }
  grep -qF 'STARTED_AT: ${{ steps.start.outputs.at }}' "$wf" || { echo "FAIL: $rel: the assert step does not read the recorded start time"; exit 1; }
  grep -qF "SESSION_RAN: \${{ steps.review.outputs.execution_file != '' }}" "$wf" || { echo "FAIL: $rel: SESSION_RAN is not keyed on the review step's execution_file"; exit 1; }
  step=$(awk '/- name: Auto-review$/{f=1; next} f && /^ *- name: /{exit} f' "$wf")
  grep -q '^ *id: review$' <<<"$step" || { echo "FAIL: $rel: the Auto-review step has no 'id: review' (SESSION_RAN reads it)"; exit 1; }

  A="$t/assert.sh"
  run "$A" 0 "$rel: a separate summary comment with a verdict" "$t/summary.json" true "$t/same"
  run "$A" 0 "$rel: a tracker comment that ends with the verdict" "$t/tracker-verdict.json" true "$t/same"
  run "$A" 0 "$rel: a summary on the second page of a 32-comment PR" "$t/paged.json" true "$t/same"
  run "$A" 0 "$rel: a summary written before the start and edited after it" "$t/edited.json" true "$t/same"
  run "$A" 1 "$rel: a summary written and last edited before the job started" "$t/stale.json" true "$t/same"
  says "No review summary since $S" "$rel: the failure names the start time"
  run "$A" 1 "$rel: a tracker comment with no verdict" "$t/tracker.json" true "$t/same"
  says "session ran but no summary" "$rel: the notice says the session ran"
  posted "claude-review-again" "$rel: the notice says how to re-trigger"
  run "$A" 1 "$rel: a verdict from another login" "$t/otherapp.json" true "$t/same"
  run "$A" 1 "$rel: an unreadable comment list" "$t/summary.json" true "$t/same" FAKE_API_FAIL=1
  says "Could not list the PR's comments" "$rel: the failure says the list could not be read"
  run "$A" 1 "$rel: a comment list that is not JSON" "$t/notjson.json" true "$t/same"
  says "Could not read the PR's comments as JSON" "$rel: the failure says the list could not be parsed"
  run "$A" 1 "$rel: no session, and this PR changes the workflow (the validation skip)" "$t/empty.json" false "$t/changed"
  says "workflow validation" "$rel: the skip is named as a validation skip"
  posted "changes .github/workflows/claude-review.yml" "$rel: the skip notice names the workflow change"
  run "$A" 1 "$rel: no session, and the workflow unchanged (an auth or setup failure)" "$t/empty.json" false "$t/same"
  says "auth or setup" "$rel: the no-session notice names auth or setup"
  if grep -qF "workflow validation" "$t/posted"; then echo "FAIL: $rel: an unchanged workflow was reported as a validation skip"; exit 1; fi
done
echo "review-assert-fixture: $n cases ok (${#wfs[@]} workflow(s), 5 structural checks each)"
````

**Edit** — `.claude/rules/cbk-conventions-reference.md`: insert the lines immediately before the kit sentinel. Replace:

````
echo "verification: kit sub-block complete"

# ═══ PROJECT CHECKS
````

with:

````
# The review workflow's own steps, run on synthetic data with a fake gh: "Assert the review posted" (slurped pages,
# the verdict marker on updated_at, !cancelled(), the no-session notice keyed on execution_file and a diff).
bash .claude/workflows/tests/review-assert-fixture.sh || { echo "a review-workflow step the fixture runs regressed (it names the case)"; exit 1; }
echo "verification: kit sub-block complete"

# ═══ PROJECT CHECKS
````

- [ ] **Step 2: Run the fixture and the block against the unfixed template.**

Run: `bash -n .claude/workflows/tests/review-assert-fixture.sh && bash .claude/workflows/tests/review-assert-fixture.sh; echo "exit=$?"`
Expected:

```
FAIL: .claude/skills/blueprint/references/templates/claude-review.yml: the assert step's condition is 'always()', not '${{ !cancelled() }}' (always() reports a superseded run as a failure)
exit=1
```

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`
Expected: `a review-workflow step the fixture runs regressed (it names the case)`, `verification: block exited 1`,
`exit=1`. Record the `FAIL:` line in the red-first table. (The behavioural cases also catch the old body: with only
the structure patched in, the first case fails with `fake gh: --jq runs once per page; fetch the pages, then count
them with jq -s`.)

- [ ] **Step 3: Verify the action facts, then make the change.**

Run:

```bash
outs() { curl -sL "$A/$1/action.yml" | sed -n '/^outputs:/,/^runs:/p' | grep -oE '^  [a-z_]+:' | tr -d ' :' | paste -sd ' '; }
for t in v1.0.0 v1.0.183 v1.0.187 v1.0.188 main; do echo "$t: $(outs $t)"; done
fact "$A/main/src/entrypoints/run.ts" 'Exiting due to workflow validation skip' 'skipped_due_to_workflow_validation_mismatch'
```

Expected:

```
v1.0.0: execution_file branch_name github_token
v1.0.183: execution_file branch_name github_token structured_output session_id
v1.0.187: execution_file branch_name github_token structured_output session_id
v1.0.188: conclusion execution_file branch_name github_token structured_output session_id
main: conclusion execution_file branch_name github_token structured_output session_id
ok: Exiting due to workflow validation skip
ok: skipped_due_to_workflow_validation_mismatch
```

(`skipped_due_to_workflow_validation_mismatch` is set by `core.setOutput` inside the action's run step but is not a
declared output of the action, which is why the step keys on `execution_file` plus a diff — the correction in
`#67/c5892401572/1`.) The two exercised-path dates in the new comments are observations from the kit issue, not
platform claims: the tracker comment carrying the verdict (a target, 2026-09-24) and the validation-skip negative
path (a target, 2026-09-29), both reported on context-builder-kit#67.

**Edit 1** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
# with continue-on-error so the job's verdict is the assertion's — red only when no summary
# comment from the review app appeared after the job started, with a one-line notice posted
# to the PR so the failure is visible there. Designed-unexercised as of 2026-09-06: verify on
# the first PR after this file lands and restamp this line.
````

with:

````
# with continue-on-error so the job's verdict is the assertion's — red only when no comment from
# the review app carrying a verdict was written or edited after the job started, with a notice
# posted to the PR that says why. Exercised in two targets by 2026-09-29 (context-builder-kit#67):
# the positive path (a separate summary comment, and a tracker comment that carries the verdict)
# and the validation-skip negative path.
````

**Edit 2** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
      - name: Auto-review
        # continue-on-error: the assertion step below decides the job's verdict (constraint 4).
````

with:

````
      - name: Auto-review
        id: review
        # continue-on-error: the assertion step below decides the job's verdict (constraint 4).
````

**Edit 3** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
      - name: Assert the review posted (constraint 4 — the artifact decides)
        if: always()
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          PR_NUMBER: ${{ github.event.pull_request.number }}
          REPO: ${{ github.repository }}
          STARTED_AT: ${{ steps.start.outputs.at }}
          REVIEW_LOGIN: "[<the review app's login, e.g. claude[bot]>]"
          RUN_URL: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}
        run: |
          set -uo pipefail
          n="$(gh api "repos/$REPO/issues/$PR_NUMBER/comments" --paginate \
                --jq "[.[] | select(.user.login == \"$REVIEW_LOGIN\") | select(.created_at >= \"$STARTED_AT\")] | length")" || n=0
          if [ "${n:-0}" -ge 1 ]; then
            echo "Review posted ($n comment(s) since $STARTED_AT)."
          else
            gh pr comment "$PR_NUMBER" --repo "$REPO" --body "Auto-review did not post a summary — see $RUN_URL. Re-trigger with the \`claude-review-again\` label." || true
            echo "::error::No review comment from $REVIEW_LOGIN since $STARTED_AT — the deliverable did not land (cbk-conventions.md § Deliverable trap)."
            exit 1
          fi
````

with:

````
      - name: Assert the review posted (constraint 4 — the artifact decides)
        # Three fixes over the first form (context-builder-kit#67):
        #   - pages are fetched once and slurped (`--paginate`, then `jq -s`): `gh api --paginate --jq`
        #     runs the filter once per page, so past 30 comments a posted review read as missing;
        #   - the summary is matched by its verdict marker, on `updated_at` since the job started: the
        #     action's tracker comment alone must not satisfy it, and an edit in place is a landing. A
        #     tracker that ends with the review's own text carries the verdict, and that is a landed
        #     review (observed in a target, 2026-09-24). The marker is the prompt's verdict line: a
        #     project that edits that vocabulary edits the `test(...)` pattern below with it;
        #   - `!cancelled()`, never `always()`: a run superseded through `concurrency` is not a failure.
        # Why no session started is read from the checkout, not from the action. Its validation-skip flag
        # is not a declared output, and its `conclusion` output is declared only from v1.0.188, while
        # `execution_file` is declared at every tag from v1.0.0 on (action.yml at each tag, read 2026-09-30). An empty
        # `execution_file` means no model session; then a diff of this file against the PR's base tells a
        # validation skip (the file changed) from an auth or setup failure (unchanged). The diff is against
        # the PR's base SHA: on a PR into a branch other than the default, that may not be the copy the
        # action validates against, and the notice can misname the cause. Every value arrives through env:,
        # never interpolated. `.claude/workflows/tests/review-assert-fixture.sh` runs this body.
        if: ${{ !cancelled() }}
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          PR_NUMBER: ${{ github.event.pull_request.number }}
          REPO: ${{ github.repository }}
          STARTED_AT: ${{ steps.start.outputs.at }}
          REVIEW_LOGIN: "[<the review app's login, e.g. claude[bot]>]"
          SESSION_RAN: ${{ steps.review.outputs.execution_file != '' }}
          BASE_SHA: ${{ github.event.pull_request.base.sha }}
          RUN_URL: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}
        run: |
          set -uo pipefail
          if ! comments="$(gh api "repos/$REPO/issues/$PR_NUMBER/comments?per_page=100" --paginate)"; then
            echo "::error::Could not list the PR's comments, so whether the review posted is unknown — see the log above."
            exit 1
          fi
          if ! n="$(jq -s --arg login "$REVIEW_LOGIN" --arg start "$STARTED_AT" '[.[][] | select(.user.login == $login and .updated_at >= $start and (.body | test("APPROVE|REQUEST CHANGES|NEEDS DISCUSSION")))] | length' <<<"$comments")"; then
            echo "::error::Could not read the PR's comments as JSON, so whether the review posted is unknown."
            exit 1
          fi
          if [ "$n" -ge 1 ]; then
            echo "Review summary posted: $n comment(s) from $REVIEW_LOGIN with a verdict since $STARTED_AT."
            exit 0
          fi
          if [ "$SESSION_RAN" = "true" ]; then
            why="The review session ran but no summary with a verdict landed — see $RUN_URL. Re-trigger with the \`claude-review-again\` label."
          else
            rc=0; git diff --quiet "$BASE_SHA" HEAD -- .github/workflows/claude-review.yml || rc=$?
            case "$rc" in
              0) why="The review did not run: no model session started, and this PR leaves .github/workflows/claude-review.yml unchanged, so this is an auth or setup failure, not a validation skip — see $RUN_URL. Fix the cause, then re-trigger with the \`claude-review-again\` label." ;;
              1) why="The review was skipped by claude-code-action's workflow validation: this PR changes .github/workflows/claude-review.yml, and the action skips a workflow that differs from the copy it validates against (its log says \"Exiting due to workflow validation skip\"). Re-triggering cannot fix that — review this PR another way; see $RUN_URL." ;;
              *) why="The review did not run: no model session started, and whether this PR changes .github/workflows/claude-review.yml could not be read (git diff exited $rc) — see $RUN_URL." ;;
            esac
          fi
          gh pr comment "$PR_NUMBER" --repo "$REPO" --body "Auto-review: no summary posted. $why" || echo "::warning::Could not post the notice to the PR either."
          echo "::error::No review summary since $STARTED_AT — the deliverable did not land (cbk-conventions.md § Deliverable trap). $why"
          exit 1
````

- [ ] **Step 4: Run the fixture, two behavioural mutants, a YAML parse and the block.**

Run: `bash -n .claude/workflows/tests/review-assert-fixture.sh && bash .claude/workflows/tests/review-assert-fixture.sh; echo "exit=$?"`
Expected: `review-assert-fixture: 11 cases ok (1 workflow(s), 5 structural checks each)`, `exit=0`.

Run (each mutant must turn the fixture red):

```bash
T=.claude/skills/blueprint/references/templates/claude-review.yml; F='bash .claude/workflows/tests/review-assert-fixture.sh 2>&1 | head -1'
mut "$T" '.updated_at >= $start' '.created_at >= $start' "$F"
mut "$T" 'if ! n="$(jq -s --arg' 'if ! n="$(jq --arg' "$F"
```

Expected: `FAIL: .claude/skills/blueprint/references/templates/claude-review.yml: a summary written before the start and edited after it (want exit 0, got 1)`,
then `FAIL: .claude/skills/blueprint/references/templates/claude-review.yml: a separate summary comment with a verdict (want exit 0, got 1)`.

Run: `python3 -c 'import sys, yaml; [yaml.safe_load(open(f)) for f in sys.argv[1:]]; print("yaml ok")' .claude/skills/blueprint/references/templates/claude-review.yml`
Expected: `yaml ok`.

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`
Expected: an `always-loaded total:` line unchanged against the previous commit's run, no `WARN` or `VIOLATION` line,
`verification: kit sub-block complete`, `verification: done`, `exit=0`.

- [ ] **Step 5: Commit.**

```bash
git add .claude/workflows/tests/review-assert-fixture.sh .claude/skills/blueprint/references/templates/claude-review.yml .claude/rules/cbk-conventions-reference.md
git commit -F - <<'MSG'
fix(review-bot): V4.3 — the review assertion reads every page, keys on the verdict and says why

"Assert the review posted" fetches the PR's comment pages once and counts them with jq -s (gh api
--paginate --jq ran per page, so a review past comment 30 read as missing); matches the review app's
comment by its verdict marker on updated_at, so the tracker alone never passes and a tracker ending
in the verdict does; runs on !cancelled(); and, when no summary landed, says why: the session ran
without a verdict, or no session started, told apart by a diff of the workflow against the PR base
(a validation skip) or not (auth or setup). The Auto-review step gains `id: review`, Constraint 4 is
restamped with the exercised paths, and review-assert-fixture.sh runs the step's own body on
synthetic comment pages through V2's extract-run-block.sh, red first on the old step.

Trace: #67/c5877251222/1, #67/c5877251222/2, #67/c5877251222/3, #67/c5877251222/4,
#67/c5881158070/1 (corrected by c5892401572/1), #67/c5892401572/2, #67/c5892401572/3,
#67/c5901495773/confirm-2, critic/12, critic/13

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
```

### Task V4.4: Models by family alias, effort named on every branch, the model that ran recorded (`#67/body/1a`, `#67/body/1b`, `#67/body/1c`, `#67/body/1d`, `#67/body/2a`, `#67/body/2b`, `#67/body/2c`, `#67/c5804984992/1`, `#67/c5881158070/2a`, `#67/c5881158070/2b + #67/c5892401572/Effort`, `#67/c5901495773/confirm-1`, `#67/c5901495773/5` template half, `#69/c5859756889/3-C4`, `#69/c5881157875/3a` template half, `critic/18` the fast branch; D47; probe P3)

**Files:**
- Modify: `.claude/workflows/tests/review-assert-fixture.sh` (the header list, and the record-step section before the
final `echo`)
- Modify: `.claude/skills/blueprint/references/templates/claude-review.yml` (the Model naming paragraph, the Pick-model
step, the prompt's model line, `--fallback-model`, the record step)
- Modify: `.claude/skills/blueprint/references/templates/claude.yml` (the header's model bullets, `id: claude`,
`claude_args`, the record step)
- Modify: `.claude/rules/cbk-conventions-reference.md` (block lines at the sentinel)

**Interfaces:**
- Consumes: V4.3's `id: review`; V2's `extract_run_block`; `orchestration.md` § Generation notes as a heading (it
exists at `643f7ff`; V5 lands the review-bot paragraph under it — § Handed to other clusters).
- Produces: the step name `Record the resolved model` in both templates (the fixture and V10's sync note use it);
`id: claude` on claude.yml's action step; `model=opus` (default and deep), `model=sonnet` (fast),
`--fallback-model sonnet`, and `--model opus --fallback-model sonnet --effort high` in claude.yml. The template's
default effort stays `high` (the settled call), the deep branch `xhigh`, the fast branch `high` — labelled in its
comment a pin pending a Sonnet 5.5 effort sweep, not a calibrated level (critic/18: Sonnet 5.5's levels are
recalibrated, and Claude Code runs it at `medium` when none is named; V5.3 and V5.4 label the rule-side pins "pending
a sweep" in the same sense). The job-summary
line reads `Review model: started <id> on Claude Code <version>, used <ids> (requested the <alias> alias at effort
<effort>)`, each value in backticks (`Mention model:` in claude.yml). The dated alias-release facts stay out of the templates (the
settled call); they are handed to V5 and V10. One addition over the exercised step: it also prints the session's
`claude_code_version` from the `init` message (a field of the SDK's `SDKSystemMessage` type), which is the version
`tooling.md`'s "check a harness fact against the version you run" (V4.6) compares with.
- #67/body/1c is reworded to what the live page states: the issue's "before Claude Code 2.1.257 `fable` means Fable
5" is not on the page, which says "Fable 5.1 requires Claude Code v2.1.257 or later" (and records a one-time
migration of saved `claude-fable-5` values at that release); the comment carries the page's sentence.

- [ ] **Step 1: Extend the fixture with the record-step cases (the failing test).**

**Edit 1** — `.claude/workflows/tests/review-assert-fixture.sh`. Replace:

````
#     step reads it, and SESSION_RAN is keyed on the execution_file of the step with `id: review`.
````

with:

````
#     step reads it, and SESSION_RAN is keyed on the execution_file of the step with `id: review`;
#   - "Record the resolved model", in both review templates: the step runs on `always()` when its action step wrote an
#     execution_file, with continue-on-error; on a synthetic execution file its job-summary line names the model the
#     session started on, its Claude Code version, every model that answered, and the alias and effort requested;
#     claude.yml's requested alias and effort equal the --model and --effort its claude_args pass.
````

**Edit 2** — `.claude/workflows/tests/review-assert-fixture.sh`. Replace:

````
echo "review-assert-fixture: $n cases ok (${#wfs[@]} workflow(s), 5 structural checks each)"
````

with:

````
# ── "Record the resolved model", in both templates: what the step writes to the job summary. Whether GitHub shows
# that line is designed-unexercised (the step's own comment says so); this pins what the step writes.
printf '%s\n' '[{"type":"system","subtype":"init","model":"claude-opus-5-5","claude_code_version":"2.1.285"},{"type":"assistant"},{"type":"result","subtype":"success","modelUsage":{"claude-opus-5-5":{},"claude-haiku-4-5":{}}}]' > "$t/exec.json"
printf '%s\n' '[{"type":"system","subtype":"init","model":"claude-opus-5-5","claude_code_version":"2.1.285"}]' > "$t/exec-noresult.json"
tdir="$root/.claude/skills/blueprint/references/templates"
for pair in claude-review.yml:review claude.yml:claude; do
  f=${pair%%:*}; id=${pair#*:}; wf="$tdir/$f"; rel=${wf#"$root"/}
  step=$(awk '/- name: Record the resolved model$/{f=1; print; next} f && /^ *- name: /{exit} f' "$wf")
  [ -n "$step" ] || { echo "FAIL: $rel has no 'Record the resolved model' step"; exit 1; }
  grep -qF "if: always() && steps.$id.outputs.execution_file != ''" <<<"$step" || { echo "FAIL: $rel: the record step does not run on always() when steps.$id wrote an execution_file"; exit 1; }
  grep -q '^ *continue-on-error: true$' <<<"$step" || { echo "FAIL: $rel: the record step is informational and must carry continue-on-error: true"; exit 1; }
  grep -qF "EXECUTION_FILE: \${{ steps.$id.outputs.execution_file }}" <<<"$step" || { echo "FAIL: $rel: the record step does not read steps.$id's execution_file"; exit 1; }
  body=$(extract_run_block "$wf" "Record the resolved model")
  [ -n "$body" ] || { echo "FAIL: $rel: the record step has no run: body"; exit 1; }
  printf '%s\n' "$body" > "$t/record.sh"
  for ex in exec exec-noresult; do
    : > "$t/summary"
    rc=0; env EXECUTION_FILE="$t/$ex.json" GITHUB_STEP_SUMMARY="$t/summary" REQUESTED=opus EFFORT=high \
      bash --noprofile --norc -eo pipefail "$t/record.sh" > "$t/out" 2>&1 || rc=$?
    n=$((n + 1))
    [ "$rc" -eq 0 ] || { echo "FAIL: $rel: the record step exited $rc on $ex.json"; sed 's/^/  | /' "$t/out"; exit 1; }
    case "$ex" in
      exec) want='started `claude-opus-5-5` on Claude Code `2.1.285`, used `claude-haiku-4-5, claude-opus-5-5` (requested the `opus` alias at effort `high`)' ;;
      *) want='used `none recorded`' ;;
    esac
    grep -qF -- "$want" "$t/summary" || { echo "FAIL: $rel: on $ex.json the job-summary line lacks '$want'"; sed 's/^/  | /' "$t/summary"; exit 1; }
  done
done
# claude.yml names its alias and effort twice, in claude_args and in the record step's env: the two must agree.
cy="$tdir/claude.yml"
args=$(awk '/claude_args: [|]/{f=1; next} f && /^ *(--|\$\{\{)/{print; next} {f=0}' "$cy")
m=$(awk '$1 == "--model" {print $2; exit}' <<<"$args"); e=$(awk '$1 == "--effort" {print $2; exit}' <<<"$args")
rec=$(awk '/- name: Record the resolved model$/{f=1; next} f' "$cy")
rq=$(awk '$1 == "REQUESTED:" {print $2; exit}' <<<"$rec"); ef=$(awk '$1 == "EFFORT:" {print $2; exit}' <<<"$rec")
if [ -z "$m" ] || [ "$m" != "$rq" ] || [ -z "$e" ] || [ "$e" != "$ef" ]; then
  echo "FAIL: claude.yml's record step names '$rq' at '$ef', but its claude_args run '$m' at '$e'"; exit 1
fi
echo "review-assert-fixture: $n cases ok (${#wfs[@]} workflow(s), 5 structural checks each; the record step in both templates)"
````

**Edit** — `.claude/rules/cbk-conventions-reference.md`: insert the lines immediately before the kit sentinel. Replace:

````
echo "verification: kit sub-block complete"

# ═══ PROJECT CHECKS
````

with:

````
# The review bots name the model by family alias, never an id placeholder and never `best`, and every claude_args
# passes --effort, because the default effort is per model (context-builder-kit#67).
absent grep -n 'model id>[]]' .claude/skills/blueprint/references/templates/claude-review.yml .claude/skills/blueprint/references/templates/claude.yml
absent grep -nE '(model=|--model |--fallback-model )best\b' .claude/skills/blueprint/references/templates/claude-review.yml .claude/skills/blueprint/references/templates/claude.yml
for t in claude-review.yml claude.yml; do a=$(awk '/claude_args: [|]/{f=1; next} f && /^ *(--|\$\{\{)/{print; next} {f=0}' .claude/skills/blueprint/references/templates/$t); grep -q -- '^ *--effort ' <<<"$a" || { echo "templates/$t: claude_args passes no --effort (the default is per model)"; exit 1; }; done
echo "verification: kit sub-block complete"

# ═══ PROJECT CHECKS
````

- [ ] **Step 2: Run the fixture and the block against the unfixed templates.**

Run: `bash -n .claude/workflows/tests/review-assert-fixture.sh && bash .claude/workflows/tests/review-assert-fixture.sh; echo "exit=$?"`
Expected: `FAIL: .claude/skills/blueprint/references/templates/claude-review.yml has no 'Record the resolved model' step`, `exit=1`.

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`
Expected: `a review-workflow step the fixture runs regressed (it names the case)`, `verification: block exited 1`,
`exit=1`. Record the `FAIL:` line in the red-first table.

- [ ] **Step 3: Verify the platform facts, run probe P3, then make the change.**

Run:

```bash
fact "$CC/model-config.md" 'Opus 5.5 and Sonnet 5.5 default to `medium`' 'where Fable is available to you, otherwise the same model as `opus`' 'Fable 5.1 requires Claude Code v2.1.257 or later' "in an Agent SDK application that doesn't show the prompt, Claude Code never asks for consent" 'Turning ultracode on or off with `/effort` or the `ultracode` setting leaves the effort level unchanged' 'Before v2.1.284, turning on ultracode set the session to `xhigh` effort' '### Model aliases' '### Adjust effort level'
fact "$CC/agent-sdk/typescript.md" 'per-model totals for every model call made through the query pipeline' 'claude_code_version: string;' 'modelUsage: { [modelName: string]: ModelUsage };' 'subtype: "init";'
fact "$GH/actions/reference/workflows-and-actions/workflow-commands" 'shown on the workflow run summary page'
fact "$A/main/src/entrypoints/run.ts" 'model: process.env.ANTHROPIC_MODEL' 'const claudeCodeVersion = '
fact "$A/main/base-action/src/parse-sdk-options.ts" 'model: options.model || modelFromClaudeArgs'
fact "$A/main/base-action/src/execution-file.ts" 'export async function writeExecutionFile' 'JSON.stringify(messages, null, 2)'
fact "$A/main/package.json" '"@anthropic-ai/claude-agent-sdk"'
fact "https://platform.claude.com/docs/en/build-with-claude/effort.md" 'Its levels are recalibrated, so a level doesn'\''t produce the same amount of thinking as the same level on Claude Sonnet 5'
```

Expected: twenty `ok:` lines. The last sources the fast branch's pin label (critic/18); V5.4 quotes the same
sentence.

**Probe P3 — does the record step's job-summary line land?** `gh run view --json jobs` reports each step and its
conclusion, not the rendered summary; read what it can:

```bash
id=$(gh run list -R j4th/you-are-hear --workflow claude-review.yml --status success -L 1 --json databaseId -q '.[0].databaseId')
gh run view "$id" -R j4th/you-are-hear --json jobs --jq '.jobs[].steps[] | select(.name | test("model")) | "\(.name) | \(.conclusion)"'
```

Expected at planning (run `36522054175`, 2026-09-29): `Pick model + effort from labels | success` and
`Record the model that ran | success` — the public target's step of the same body ran green. Then open that run's
summary page in a browser (`gh run view "$id" -R j4th/you-are-hear --web`) and look for a `Review model:` line.
**If it is not there, or no browser is available,** make Edit 10 as written and record P3 =
designed-unexercised (2026-09-30) in the PR body's probe table. **If the line is there,** make Edit 10 and then,
in the file, replace

```
        # job summary, read 2026-09-30). The step ran green in a target's review run on 2026-09-29, but the
        # rendered line was not read back, so its display stays designed-unexercised: restamp this line when a
        # run page shows it.
```

with (the date the page was read)

```
        # job summary, read 2026-09-30). A target's run page showed the line on <YYYY-MM-DD>.
```

and record P3 = exercised in the PR body.

**Edit 3** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
# (cbk-conventions.md § [skip ci] rule, the auto-review trap).
#
# Needs the `CLAUDE_CODE_OAUTH_TOKEN` Actions secret (`/install-github-app` in Claude Code).
````

with:

````
# (cbk-conventions.md § [skip ci] rule, the auto-review trap).
#
# Model naming — by family alias, never by id and never `best`: `opus` by default and on the deep path,
# `sonnet` on the fast path and as the fallback. `best` resolves to Fable "where Fable is available to you,
# otherwise the same model as `opus`" (https://code.claude.com/docs/en/model-config § Model aliases, read
# 2026-09-30), so an escalation through it would be silent. An alias resolves inside the Claude Code release
# the pinned action installs (`claudeCodeVersion` in its `src/entrypoints/run.ts`), so the action's commit SHA
# is the model pin: Dependabot's github-actions bump is the model bump, and a new model needs no edit here.
# The `Record the resolved model` step writes the model that ran to the job summary. Never set
# ANTHROPIC_MODEL on the action step: the action hands it to the SDK as the explicit model, and
# `model: options.model || modelFromClaudeArgs` lets it win over `--model` (`src/entrypoints/run.ts` and
# `base-action/src/parse-sdk-options.ts` at the pinned SHA, read 2026-09-30). The action-bump PR re-checks
# what is sized to the model rather than to the alias: each branch's `--effort`, `--max-turns`, and the
# prompt's degrade N (the note above claude_args; orchestration.md § Generation notes).
#
# Needs the `CLAUDE_CODE_OAUTH_TOKEN` Actions secret (`/install-github-app` in Claude Code).
````

**Edit 4** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
        # review in one session (`--disallowedTools Agent`); only the deep path fans out.
        env:
          LABELS_JSON: ${{ toJSON(github.event.pull_request.labels.*.name) }}
````

with:

````
        # review in one session (`--disallowedTools Agent`); only the deep path fans out.
        # Every branch names its effort, because the default is per model: "Opus 5.5 and Sonnet 5.5
        # default to `medium`" (https://code.claude.com/docs/en/model-config § Adjust effort level, read
        # 2026-09-30), so an unnamed effort drops whenever the alias moves. That makes the fast branch's
        # `high` load-bearing wherever `sonnet` resolves to Sonnet 5.5.
        env:
          LABELS_JSON: ${{ toJSON(github.event.pull_request.labels.*.name) }}
````

**Edit 5** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
            echo "model=[<top-tier or workhorse model id>]" >> "$GITHUB_OUTPUT"
            echo "effort=xhigh" >> "$GITHUB_OUTPUT"
            # `ultracode` as exercised on the deep path (a dated observation, 2026-09-06); re-verify the setting name after harness upgrades.
            echo "settings_arg=--settings '{\"ultracode\":true}'" >> "$GITHUB_OUTPUT"
````

with:

````
            # `opus`, or `fable` for a project that deliberately escalates its hardest reviews. Before choosing
            # `fable`: "Fable 5.1 requires Claude Code v2.1.257 or later", so an older pinned action cannot run
            # it; and "in an Agent SDK application that doesn't show the prompt, Claude Code never asks for
            # consent" before billing Fable to usage credits (both https://code.claude.com/docs/en/model-config,
            # read 2026-09-30) — this action is one (its package.json depends on @anthropic-ai/claude-agent-sdk).
            # Never `best`: the header's Model naming says why.
            echo "model=opus" >> "$GITHUB_OUTPUT"
            echo "effort=xhigh" >> "$GITHUB_OUTPUT"
            # `ultracode` turns on dynamic workflows and sets no effort: "Turning ultracode on or off with
            # `/effort` or the `ultracode` setting leaves the effort level unchanged" (the same page, from
            # Claude Code 2.1.284), so `xhigh` above is named, not implied.
            echo "settings_arg=--settings '{\"ultracode\":true}'" >> "$GITHUB_OUTPUT"
````

**Edit 6** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
            echo "model=[<mid-tier model id>]" >> "$GITHUB_OUTPUT"
            echo "effort=high" >> "$GITHUB_OUTPUT"
````

with:

````
            echo "model=sonnet" >> "$GITHUB_OUTPUT"
            # A pin pending a Sonnet 5.5 effort sweep, not a calibrated level: "Its levels are recalibrated,
            # so a level doesn't produce the same amount of thinking as the same level on Claude Sonnet 5"
            # (https://platform.claude.com/docs/en/build-with-claude/effort, read 2026-09-30), and Claude Code
            # runs Sonnet 5.5 at `medium` when no effort is named (this step's comment above). `high` holds
            # until a sweep on this project's own reviews moves it; the action bump that moves `sonnet`
            # re-checks it.
            echo "effort=high" >> "$GITHUB_OUTPUT"
````

**Edit 7** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
            echo "model=[<workhorse model id>]" >> "$GITHUB_OUTPUT"
````

with:

````
            echo "model=opus" >> "$GITHUB_OUTPUT"
````

**Edit 8** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
            Model in use: ${{ steps.model.outputs.model }} (effort: ${{ steps.model.outputs.effort }})
````

with:

````
            Model in use: the `${{ steps.model.outputs.model }}` alias at effort ${{ steps.model.outputs.effort }} (an alias, not a model id; the job summary records the model that ran).
````

**Edit 9** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
            --fallback-model [<mid-tier model id>]
````

with:

````
            --fallback-model sonnet
````

**Edit 10** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
            ${{ steps.model.outputs.disallow_arg }}

      - name: Assert the review posted
````

with:

````
            ${{ steps.model.outputs.disallow_arg }}

      - name: Record the resolved model
        # The alias says which family was asked for; this says which model ran. The action writes the session's
        # SDK messages to `execution_file` as a JSON array (`writeExecutionFile` in
        # `base-action/src/execution-file.ts`, read 2026-09-30). Its `init` message carries the `model` the
        # session started on and the `claude_code_version` it ran, and the `result` message's `modelUsage` holds
        # "per-model totals for every model call made through the query pipeline"
        # (https://code.claude.com/docs/en/agent-sdk/typescript, read 2026-09-30). `always()`, because a failed
        # review is the run whose model matters most; continue-on-error, because this step is informational
        # and must never redden a review that posted. What it appends is "shown on the workflow run summary
        # page" (https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-commands § Adding a
        # job summary, read 2026-09-30). The step ran green in a target's review run on 2026-09-29, but the
        # rendered line was not read back, so its display stays designed-unexercised: restamp this line when a
        # run page shows it.
        # `.claude/workflows/tests/review-assert-fixture.sh` runs this body on synthetic execution files.
        if: always() && steps.review.outputs.execution_file != ''
        continue-on-error: true
        env:
          EXECUTION_FILE: ${{ steps.review.outputs.execution_file }}
          REQUESTED: ${{ steps.model.outputs.model }}
          EFFORT: ${{ steps.model.outputs.effort }}
        run: |
          started=$(jq -r '[.[] | select(.type == "system" and .subtype == "init") | .model][0] // "unknown"' "$EXECUTION_FILE")
          version=$(jq -r '[.[] | select(.type == "system" and .subtype == "init") | .claude_code_version][0] // "unknown"' "$EXECUTION_FILE")
          used=$(jq -r '[.[] | select(.type == "result") | (.modelUsage // {}) | keys[]] | unique | join(", ")' "$EXECUTION_FILE")
          echo "Review model: started \`$started\` on Claude Code \`$version\`, used \`${used:-none recorded}\` (requested the \`$REQUESTED\` alias at effort \`$EFFORT\`)" >> "$GITHUB_STEP_SUMMARY"

      - name: Assert the review posted
````

**Edit 11** — `.claude/skills/blueprint/references/templates/claude.yml`. Replace:

````
#   - the workhorse model at its default effort: mentions are interactive and quota-sensitive
````

with:

````
#   - the `opus` alias at `high` effort, named rather than left to the default: mentions are
#     interactive and quota-sensitive, and "Opus 5.5 and Sonnet 5.5 default to `medium`"
#     (https://code.claude.com/docs/en/model-config § Adjust effort level, read 2026-09-30), so an
#     unnamed effort would move whenever the alias does
#   - the model by family alias, as claude-review.yml's Model naming paragraph says: the action's SHA
#     is the model pin, the `Record the resolved model` step writes the model that ran to the job
#     summary, and ANTHROPIC_MODEL is never set on the action step
````

**Edit 12** — `.claude/skills/blueprint/references/templates/claude.yml`. Replace:

````
      - name: Run Claude Code
        if: steps.gate.outputs.skip == 'false'
````

with:

````
      - name: Run Claude Code
        id: claude
        if: steps.gate.outputs.skip == 'false'
````

**Edit 13** — `.claude/skills/blueprint/references/templates/claude.yml`. Replace:

````
            --model [<workhorse model id>]
            --fallback-model [<mid-tier model id>]
            --max-turns 60
````

with:

````
            --model opus
            --fallback-model sonnet
            --effort high
            --max-turns 60
````

**Edit 14** — `.claude/skills/blueprint/references/templates/claude.yml`. Replace:

````
            --allowedTools "Bash(gh issue view:*),Bash(gh issue comment:*),Bash(gh pr view:*),Bash(gh pr diff:*),Bash(gh pr comment:*),Bash(gh pr checks:*),Bash(gh run view:*),Bash(gh run list:*),mcp__github_inline_comment__create_inline_comment"
````

with:

````
            --allowedTools "Bash(gh issue view:*),Bash(gh issue comment:*),Bash(gh pr view:*),Bash(gh pr diff:*),Bash(gh pr comment:*),Bash(gh pr checks:*),Bash(gh run view:*),Bash(gh run list:*),mcp__github_inline_comment__create_inline_comment"

      - name: Record the resolved model
        # The same step as claude-review.yml's; its comment carries the sources. Every value arrives through
        # env:, never interpolated into the command.
        if: always() && steps.claude.outputs.execution_file != ''
        continue-on-error: true
        env:
          EXECUTION_FILE: ${{ steps.claude.outputs.execution_file }}
          REQUESTED: opus     # the --model and --effort in claude_args above; review-assert-fixture.sh keeps them equal
          EFFORT: high
        run: |
          started=$(jq -r '[.[] | select(.type == "system" and .subtype == "init") | .model][0] // "unknown"' "$EXECUTION_FILE")
          version=$(jq -r '[.[] | select(.type == "system" and .subtype == "init") | .claude_code_version][0] // "unknown"' "$EXECUTION_FILE")
          used=$(jq -r '[.[] | select(.type == "result") | (.modelUsage // {}) | keys[]] | unique | join(", ")' "$EXECUTION_FILE")
          echo "Mention model: started \`$started\` on Claude Code \`$version\`, used \`${used:-none recorded}\` (requested the \`$REQUESTED\` alias at effort \`$EFFORT\`)" >> "$GITHUB_STEP_SUMMARY"
````

- [ ] **Step 4: Run the fixture, the fast branch's pin label, two mutants, a YAML parse and the block.**

Run: `bash -n .claude/workflows/tests/review-assert-fixture.sh && bash .claude/workflows/tests/review-assert-fixture.sh; echo "exit=$?"`
Expected: `review-assert-fixture: 15 cases ok (1 workflow(s), 5 structural checks each; the record step in both templates)`, `exit=0`.

Run: `grep -A7 'echo "model=sonnet"' .claude/skills/blueprint/references/templates/claude-review.yml | grep -cE 'A pin pending a Sonnet 5.5 effort sweep|echo "effort=high"'`
Expected: `2` — the label sits in the fast branch, beside its `effort=high` (critic/18).

Run:

```bash
T=.claude/skills/blueprint/references/templates; B='bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2'
mut "$T/claude-review.yml" $'echo "model=opus" >> "$GITHUB_OUTPUT"\n            echo "effort=high"' $'echo "model=[<workhorse model id>]" >> "$GITHUB_OUTPUT"\n            echo "effort=high"' "$B"
mut "$T/claude-review.yml" $'            --effort ${{ steps.model.outputs.effort }}\n' '' "$B"
```

Expected: the first mutant's last two lines are `VIOLATION (matched above): grep -n model id>[]] .claude/skills/blueprint/references/templates/claude-review.yml .claude/skills/blueprint/references/templates/claude.yml`
and `verification: block exited 1`; the second's are `templates/claude-review.yml: claude_args passes no --effort (the default is per model)`
and `verification: block exited 1`.

Run: `python3 -c 'import sys, yaml; [yaml.safe_load(open(f)) for f in sys.argv[1:]]; print("yaml ok")' .claude/skills/blueprint/references/templates/claude-review.yml .claude/skills/blueprint/references/templates/claude.yml`
Expected: `yaml ok`.

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`
Expected: an `always-loaded total:` line unchanged against the previous commit's run, no `WARN` or `VIOLATION` line,
`verification: kit sub-block complete`, `verification: done`, `exit=0`.

- [ ] **Step 5: Commit.**

```bash
git add .claude/workflows/tests/review-assert-fixture.sh .claude/skills/blueprint/references/templates/claude-review.yml .claude/skills/blueprint/references/templates/claude.yml .claude/rules/cbk-conventions-reference.md
git commit -F - <<'MSG'
feat(review-bot): V4.4 — family aliases, explicit effort and the recorded model

Both review templates name the model by family alias (opus by default and on the deep path, sonnet on
the fast path and as the fallback; never best), and every branch passes --effort, claude.yml at high,
because the default effort is per model and Opus 5.5 and Sonnet 5.5 default to medium. The header says
the action's pinned SHA is the model pin, never to set ANTHROPIC_MODEL (it wins over --model), and what
the action-bump PR re-checks; the deep branch says what choosing fable costs and why xhigh is named now
that ultracode sets no effort. A "Record the resolved model" step on both templates (continue-on-error)
writes the model the session started on, its Claude Code version and every model that answered to the
job summary, and the prompt's model line says it shows the alias. The fast branch's effort=high is
labelled a pin pending a Sonnet 5.5 effort sweep, since Sonnet 5.5's levels are recalibrated. The
fixture runs the record step on synthetic execution files, red first. Probe P3 recorded.

Trace: #67/body/1a, #67/body/1b, #67/body/1c, #67/body/1d, #67/body/2a, #67/body/2b, #67/body/2c,
#67/c5804984992/1, #67/c5881158070/2a, #67/c5881158070/2b + #67/c5892401572/Effort,
#67/c5901495773/confirm-1, #67/c5901495773/5 (template half), #69/c5859756889/3-C4,
#69/c5881157875/3a (template half), critic/18 (the fast branch)

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
```

### Task V4.5: What the reviewer is told — the base branch's configuration, CI through `gh pr checks`, commands actually run, the gate/allowlist pairing, N against the turn cap (`#68/body/2a (+c5861166655/2, c5881158244/1, c5892402074/2)`, `#68/body/2b`, `#68/body/2c`, `#68/body/2d`, `#68/c5881158244/2 (+c5892402074/2)`, `#68/c5901496131`, `#67/c5901495773/2`, `#67/c5901495773/3`, `#58/c5901493591/R12 = #67/c5901495773/4`, `#67/c5901495773/7`, `critic/14`, `critic/15`, `release/5` for the two template citations; D53)

**Files:**
- Modify: `.claude/skills/blueprint/references/templates/claude-review.yml` (the restore GOTCHA, the fetch-base
comment's citation, the prompt's restore section, the degrade clause, the summary-format paragraph, the notes above
`claude_args`)
- Modify: `.claude/skills/blueprint/references/templates/claude.yml` (the header's restore bullet)
- Modify: `.claude/rules/cbk-conventions-reference.md` (block lines at the sentinel)

**Interfaces:**
- Consumes: V4.4's claude.yml bullet ending `summary, and ANTHROPIC_MODEL is never set on the action step` (the
anchor for the restore bullet); V4.4's prompt line `Model in use: the …` sits just above the notes this task adds.
- Produces: the prompt section `## The base branch's configuration, and this PR's`; two new bracketed fills a target
must make — `[<if the root CLAUDE.md is a symlink to AGENTS.md, …>]` and `[<the CI job that runs the project's check
task>]`; the degrade placeholder `[N — the note above claude_args]`; the qualified citations
`context-builder-kit#58 addendum, item 11` and `item 12`, so V9's kit-wide bare-citation check (release/5) finds none
in these two templates. The sentences the block pins: `Report only commands you actually ran`,
`` gh pr checks` (this job grants ``, `must match each subcommand independently`.

- [ ] **Step 1: Write the failing block checks.**

**Edit** — `.claude/rules/cbk-conventions-reference.md`: insert the lines immediately before the kit sentinel. Replace:

````
echo "verification: kit sub-block complete"

# ═══ PROJECT CHECKS
````

with:

````
# What the reviewer is told (context-builder-kit#68): which configuration is the base branch's and where the PR's
# own copies are; that it reads CI with gh pr checks and reports only commands it ran; how a prompt gate pairs
# with the allowlist; how N is sized to the turn cap. Kit issues are cited qualified, never as a bare #N.
for f in .claude/skills/blueprint/references/templates/claude-review.yml .claude/skills/blueprint/references/templates/claude.yml; do grep -qF '.claude-pr/' "$f" || { echo "$f does not say the PR's own configuration copies are under .claude-pr/"; exit 1; }; done
for w in 'Report only commands you actually ran' 'gh pr checks` (this job grants' 'must match each subcommand independently' '[N — the note above claude_args]'; do grep -qF -- "$w" .claude/skills/blueprint/references/templates/claude-review.yml || { echo "templates/claude-review.yml lacks: $w"; exit 1; }; done
absent grep -nE '(^|[[:space:](,;])#[0-9]{1,3}\b' .claude/skills/blueprint/references/templates/claude-review.yml .claude/skills/blueprint/references/templates/claude.yml
echo "verification: kit sub-block complete"

# ═══ PROJECT CHECKS
````

- [ ] **Step 2: Run the block against the unfixed template.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`
Expected:

```
.claude/skills/blueprint/references/templates/claude-review.yml does not say the PR's own configuration copies are under .claude-pr/
verification: block exited 1
exit=1
```

Record that line in the red-first table.

- [ ] **Step 3: Verify the facts, re-run the turn-accounting probe, then make the change.**

Run:

```bash
fact "$CC/permissions.md" 'A rule must match each subcommand independently' 'is also read-only' '#### Compound commands' '#### Read-only commands'
fact "$A/main/src/github/operations/restore-config.ts" 'for review agents (not executed)' 'export function restoreConfigFromBase' 'export const SENSITIVE_PATHS'
curl -sL "$A/main/src/github/operations/restore-config.ts" | sed -n '/export const SENSITIVE_PATHS/,/];/p' | tr -d ' \n'; echo
```

Expected: seven `ok:` lines, then
`exportconstSENSITIVE_PATHS=[".claude",".mcp.json",".claude.json",".gitmodules",".ripgreprc","CLAUDE.md","CLAUDE.local.md",".husky",];`
— top-level paths only, no `AGENTS.md`, which is what the prompt section and both headers state.

**Probe — how `--max-turns` counts on the release the newest action pins.** First find that release:

```bash
tag=$(curl -sL 'https://api.github.com/repos/anthropics/claude-code-action/tags?per_page=1' | jq -r '.[0].name'); echo "$tag"
curl -sL "$A/$tag/src/entrypoints/run.ts" | grep -oE 'claudeCodeVersion = "[0-9.]+"'
claude --version
```

Expected at planning: `v1.0.237`, `claudeCodeVersion = "2.1.285"`, `2.1.285 (Claude Code)`. If the local Claude
Code differs from the tag's, run the probe anyway, name the version you measured in the comment, and say so in the
PR body. Then:

```bash
P=$(mktemp -d); cd "$P" && git init -q . && for i in 1 2 3 4 5; do echo "file $i" > f$i.txt; done
for m in 1 2; do claude -p "Read f1.txt, f2.txt, f3.txt, f4.txt and f5.txt — all five with parallel Read calls in ONE response — then reply with the single word DONE." --max-turns $m --output-format stream-json --verbose --allowedTools Read --model sonnet --effort low > run$m.jsonl 2>/dev/null; printf 'max-turns %s: ' $m; jq -r 'select(.type=="result") | "\(.subtype)"' run$m.jsonl; printf '  Read calls: '; jq -r 'select(.type=="assistant") | .message.content[] | select(.type=="tool_use") | .name' run$m.jsonl | wc -l; done
cd - >/dev/null; rm -rf "$P"
```

Expected at planning (2.1.285, 2026-09-30): `max-turns 1: error_max_turns` with `Read calls: 5`, then
`max-turns 2: success` with `Read calls: 5` — the five parallel reads spent one turn, so the cap counts round trips.
**If instead `max-turns 2` also ends `error_max_turns`,** the cap counts tool calls on this release: after making
Edit 6, replace these four lines of it

```
          # The degrade clause's N is what the turn cap leaves after the posting calls. On Claude Code 2.1.285
          # `--max-turns` counts round trips, not tool calls: five parallel `Read` calls in one response spent
          # one turn (measured 2026-09-30 with `claude -p --max-turns 1` and `2`, `--output-format stream-json`;
          # a target measured them per call on 2.1.274). A reviewer that reads one file per response spends a
```

with (the version and the date of the run)

```
          # The degrade clause's N is what the turn cap leaves after the posting calls. On Claude Code <version>
          # `--max-turns` counts tool calls, not round trips: five parallel `Read` calls in one response spent
          # five turns (measured <YYYY-MM-DD> with `claude -p --max-turns 1` and `2`, `--output-format stream-json`),
          # as a target measured on 2.1.274. A reviewer that reads one file per response spends a
```

Record the probe's result in the PR body's probe table either way.

**Edit 1** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
#
# GOTCHA: the CI-skip marker on the HEAD commit at the draft→ready flip silently blocks
````

with:

````
#
# GOTCHA — on a PR the session reads the BASE branch's configuration. Before it starts, the action restores
# `.claude`, `.mcp.json`, `CLAUDE.md` and a few other top-level paths from the base branch and keeps the PR's
# copies under `.claude-pr/` "for review agents (not executed)" (`SENSITIVE_PATHS` and `restoreConfigFromBase`
# in `src/github/operations/restore-config.ts` at the pinned SHA, read 2026-09-30). The list names top-level
# paths only, so a nested `CLAUDE.md`, or an `AGENTS.md` the root `CLAUDE.md` links to, is not restored and
# reads at the PR head: the restore closes settings, hooks and MCP servers, not every instructions file. The
# prompt tells the reviewer so; CI, not this review, runs the PR's own hooks and fixtures.
#
# GOTCHA: the CI-skip marker on the HEAD commit at the draft→ready flip silently blocks
````

**Edit 2** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
        # refuses (#58 addendum, item 12). The ref name is read from an env var, never interpolated.
````

with:

````
        # refuses (context-builder-kit#58 addendum, item 12). The ref name is read from an env var, never interpolated.
````

**Edit 3** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
            [<and the nested CLAUDE.md of each tree the diff touches>].

            ## What to do
````

with:

````
            [<and the nested CLAUDE.md of each tree the diff touches>].

            ## The base branch's configuration, and this PR's

            Before this session the action restored `.claude/`, `.mcp.json` and the root `CLAUDE.md`
            from the base branch and kept this PR's copies under `.claude-pr/`. A `Read` of `.claude/…`
            returns the base's copy, and a `.claude/` file this PR adds is not there at all: read this
            PR's version under `.claude-pr/` (for example `.claude-pr/.claude/rules/pr-review.md`);
            `gh pr diff` shows the change itself. A `CLAUDE.md` nested anywhere but under `.claude/` is
            not on the restore list, so it reads as this PR's own version [<if the root CLAUDE.md is a
            symlink to AGENTS.md, or the project's instructions live in another file not on the list:
            say that file is not restored either, so it reads as this PR's own version>]. Where this PR
            changes a rule you apply, review it against the rule as this PR states it, and say which
            version you used. You run none of this PR's hooks or fixtures: CI's [<the CI job that runs
            the project's check task>] is the check for a PR that changes them — read its result with
            `gh pr checks`.

            ## What to do
````

**Edit 4** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
            If the diff exceeds [N] changed files (a sync of vendored or kit-copied trees, a generated
            bulk), you cannot walk every file inside the turn cap: review the authored set the PR body
            names and every file that is not a byte-identical copy of its source, post the summary FIRST
            with the list of files you did not read, and say so in the verdict line. A capped run that
            posted nothing is the failure this clause prevents (#58 addendum, item 11).
````

with:

````
            If the diff exceeds [N — the note above claude_args] changed files (a sync of vendored or
            kit-copied trees, a generated bulk), you cannot walk every file inside the turn cap: review the
            authored set the PR body names and every file that is not a byte-identical copy of its source,
            post the summary FIRST with the list of files you did not read, and say so in the verdict line.
            A capped run that posted nothing is the failure this clause prevents (context-builder-kit#58
            addendum, item 11).
````

**Edit 5** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
            Then a counts table (Apply / Apply with care / Surface / Defer / Reject). Then three to
            seven lines on the most important findings and any cross-cutting concern. CI status is
            usually NOT readable from your token (`gh pr checks` fails with "Resource not accessible
            by integration"); if it is, reference a failed check, otherwise say nothing about CI —
            never report the permission error as a finding. End with one line on what is NOT in
            scope of this review.
````

with:

````
            Then a counts table (Apply / Apply with care / Surface / Defer / Reject). Then three to
            seven lines on the most important findings and any cross-cutting concern. Read CI with
            `gh pr checks` (this job grants `checks: read`) and reference a failed check; if it fails
            with "Resource not accessible by integration", the grant is missing — say so in one line,
            never as a finding. Report only commands you actually ran: a command you never issued is
            never reported as run, passed or refused. End with one line on what is NOT in scope of
            this review.
````

**Edit 6** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
          claude_args: |
            --model ${{ steps.model.outputs.model }}
````

with:

````
          # A gate the project adds to the prompt (a check command the reviewer may run) gets its own
          # --allowedTools entry below, and the two lists are edited together: a gate the prompt offers and
          # the list refuses is a review that reports a refusal. Claude Code splits a compound command, and
          # "A rule must match each subcommand independently"; a `cd` inside the working directory "is also
          # read-only" (https://code.claude.com/docs/en/permissions § Compound commands, § Read-only commands,
          # read 2026-09-30). Prefer one command per gate, and confirm a compound one on a real run. A gate
          # that runs a `.claude/`-hosted fixture runs the BASE branch's copy on a PR that changes it (the
          # header's restore GOTCHA): keep such fixtures out of the gates, or say in the prompt that the bot
          # runs the base copy.
          #
          # The degrade clause's N is what the turn cap leaves after the posting calls. On Claude Code 2.1.285
          # `--max-turns` counts round trips, not tool calls: five parallel `Read` calls in one response spent
          # one turn (measured 2026-09-30 with `claude -p --max-turns 1` and `2`, `--output-format stream-json`;
          # a target measured them per call on 2.1.274). A reviewer that reads one file per response spends a
          # turn a file either way, so at one `Read` a file keep about a third of the cap for the `gh` calls,
          # the inline comments and the summary: N = 40 against `--max-turns 60`. N and the cap move together:
          # re-measure on the release your pinned action installs, and the action-bump PR re-checks both
          # (orchestration.md § Generation notes).
          claude_args: |
            --model ${{ steps.model.outputs.model }}
````

**Edit 7** — `.claude/skills/blueprint/references/templates/claude.yml`. Replace:

````
#     summary, and ANTHROPIC_MODEL is never set on the action step
````

with:

````
#     summary, and ANTHROPIC_MODEL is never set on the action step
#   - on a PR the session reads the base branch's configuration: the action restores `.claude/`,
#     `.mcp.json` and the root `CLAUDE.md` from the base before it starts and keeps the PR's copies
#     under `.claude-pr/`; a nested `CLAUDE.md`, or an `AGENTS.md` the root one links to, reads at the
#     PR head (claude-review.yml's restore GOTCHA carries the source). This file passes no prompt of
#     its own; a prompt added here states those facts, as claude-review.yml's does
````

- [ ] **Step 4: Run the fixtures, a YAML parse and the block.**

Run: `bash .claude/workflows/tests/review-assert-fixture.sh && python3 -B .claude/workflows/tests/review-trigger-fixture.py`
Expected: `review-assert-fixture: 15 cases ok (1 workflow(s), 5 structural checks each; the record step in both templates)`,
`review-trigger-fixture: 12 cases ok (1 workflow(s))` — the prompt edits leave both steps' bodies and the trigger
untouched.

Run: `python3 -c 'import sys, yaml; [yaml.safe_load(open(f)) for f in sys.argv[1:]]; print("yaml ok")' .claude/skills/blueprint/references/templates/claude-review.yml .claude/skills/blueprint/references/templates/claude.yml`
Expected: `yaml ok`.

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`
Expected: an `always-loaded total:` line unchanged against the previous commit's run, no `WARN` or `VIOLATION` line,
`verification: kit sub-block complete`, `verification: done`, `exit=0`.

- [ ] **Step 5: Commit.**

```bash
git add .claude/skills/blueprint/references/templates/claude-review.yml .claude/skills/blueprint/references/templates/claude.yml .claude/rules/cbk-conventions-reference.md
git commit -F - <<'MSG'
feat(review-bot): V4.5 — the reviewer knows which configuration is the base branch's

The review prompt says the action restored .claude/, .mcp.json and the root CLAUDE.md from the base
branch and kept the PR's copies under .claude-pr/, that a nested CLAUDE.md (and, where a project has
one, a symlinked AGENTS.md) reads at the PR head, that a rule the PR changes is reviewed as the PR
states it with the version named, and that CI's check job, read with gh pr checks, is what runs the
PR's own hooks and fixtures. Both headers state the mechanism with its source. The summary reads CI
and reports only commands actually run; a note above claude_args pairs every prompt gate with an
--allowedTools entry and sizes the degrade clause's N (40) against --max-turns 60, re-measured on
Claude Code 2.1.285. The two kit-issue citations are qualified.

Trace: #68/body/2a (+c5861166655/2, c5881158244/1, c5892402074/2), #68/body/2b, #68/body/2c,
#68/body/2d, #68/c5881158244/2 (+c5892402074/2), #68/c5901496131, #67/c5901495773/2,
#67/c5901495773/3, #58/c5901493591/R12 = #67/c5901495773/4, #67/c5901495773/7, critic/14, critic/15,
release/5 (the two template citations)

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
```

### Task V4.6: Constraint 1 as the action states it, the action facts sourced, and `tooling.md` § Automated review (`#67/c5901495773/6`, `#67/c5901495773/9`, `review/portability/35`; D50)

**Files:**
- Modify: `.claude/rules/tooling.md` (§ Automated review on the git host — the decision rule only; V3 owns § MCP
configuration in the same file)
- Modify: `.claude/skills/blueprint/references/templates/claude-review.yml` (Constraint 1, Constraints 3 and 6, the
`track_progress` comment)
- Modify: `.claude/rules/cbk-conventions-reference.md` (the existing review-automation check's first literal, and a
block line at the sentinel)

**Interfaces:**
- Consumes: V4.3's "Assert the review posted" step (the decision rule names it) and V4.4's job-summary record.
- Produces: the phrase `cannot review any PR that changes it` in the template's Constraint 1 and in `tooling.md`,
each pinned by the block (the `tooling.md` check runs only where a target kept § Automated review on the git host —
the section is deletable). `always-loaded total` +452 bytes: `tooling.md` 12,416 → 12,868 at this commit's parent's
sizes. The `track_progress` conditional stays (a pin below v1.0.188 still needs it), now dated with its drop trigger.

- [ ] **Step 1: Write the failing checks.** The first edit changes an existing check's literal (it sits in the P4
review-automation group, above the sentinel); the second adds the `tooling.md` check.

**Edit 1** — `.claude/rules/cbk-conventions-reference.md`. Replace:

````
for w in 'cannot review the PR that introduces it' -- '--disallowedTools Agent' 
````

with:

````
for w in 'cannot review any PR that changes it' -- '--disallowedTools Agent' 
````

**Edit** — `.claude/rules/cbk-conventions-reference.md`: insert the lines immediately before the kit sentinel. Replace:

````
echo "verification: kit sub-block complete"

# ═══ PROJECT CHECKS
````

with:

````
# tooling.md's § Automated review, where the project kept it, states constraint 1 as the template does.
if grep -q '^## Automated review on the git host' .claude/rules/tooling.md; then grep -qF 'cannot review any PR that changes it' .claude/rules/tooling.md || { echo "tooling.md § Automated review says the workflow cannot review only the PR that introduces it"; exit 1; }; fi
echo "verification: kit sub-block complete"

# ═══ PROJECT CHECKS
````

- [ ] **Step 2: Run the block against the unfixed files.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`
Expected:

```
templates/claude-review.yml lacks: cannot review any PR that changes it
verification: block exited 1
exit=1
```

Record that line in the red-first table.

- [ ] **Step 3: Verify the action facts, then make the change.**

Run:

```bash
fact "$A/main/src/github/token.ts" 'This is expected when adding Claude Code workflows to new repositories or on PRs with workflow changes' 'export async function setupGitHubToken' 'OVERRIDE_GITHUB_TOKEN'
fact "$A/main/action.yml" 'OVERRIDE_GITHUB_TOKEN: ${{ inputs.github_token }}'
echo "timeout inputs: $(curl -sL "$A/main/action.yml" | sed -n '/^inputs:/,/^outputs:/p' | grep -ci timeout)"
for t in v1.0.187 v1.0.188 main; do echo "$t labeled: $(curl -sL "$A/$t/src/modes/detector.ts" | grep -c '"labeled"')"; done
```

Expected: four `ok:` lines, then `timeout inputs: 0`, `v1.0.187 labeled: 0`, `v1.0.188 labeled: 1`,
`main labeled: 1`. (review/portability/35: the old "unsupported on `labeled`" line held before v1.0.188 and is stale
after it; `timeout_minutes` is not an input at the pinned SHA, so constraint 3's claim stands, now sourced.)

**Edit 2** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
# Constraint 1 — the action cannot review the PR that introduces it: the action
# validates this file against the default branch and exits green without running on
# any PR that adds or changes it. Verify on the next PR, not this one.
````

with:

````
# Constraint 1 — this workflow cannot review any PR that changes it: claude-code-action skips, green and
# with no model session, on a PR that adds or changes this file. Its log: "This is expected when adding
# Claude Code workflows to new repositories or on PRs with workflow changes" (`src/github/token.ts` at the
# pinned SHA, read 2026-09-30); the comparison runs server side, at the action's token exchange. The last
# step goes red on such a PR and says why. Verify on the next PR, not this one.
````

**Edit 3** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
    # Constraint 3 — a job-level timeout: the action has no timeout input of its own.
````

with:

````
    # Constraint 3 — a job-level timeout: the action has no timeout input of its own (its action.yml at the
    # pinned SHA declares none, read 2026-09-30).
````

**Edit 4** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
    # Constraint 6 — permissions scoped to the job. `id-token: write` is required by the
    # action even in OAuth-token mode; `checks: read` for the prompt's `gh pr checks`.
````

with:

````
    # Constraint 6 — permissions scoped to the job. `id-token: write` is required by the action even in
    # OAuth-token mode: unless a `github_token` input is given, it exchanges an OIDC token for its app token
    # (`setupGitHubToken` in `src/github/token.ts`, read 2026-09-30). `checks: read` for the prompt's
    # `gh pr checks`.
````

**Edit 5** — `.claude/skills/blueprint/references/templates/claude-review.yml`. Replace:

````
          # track_progress is unsupported on `labeled` events (the action fails).
````

with:

````
          # Before claude-code-action v1.0.188, track_progress rejects a `labeled` event (the action fails);
          # v1.0.188 accepts it (`validActions` in `src/modes/detector.ts` at each tag, read 2026-09-30). Once
          # the pinned SHA is v1.0.188 or later, this can be `track_progress: true`.
````

**Edit 6** — `.claude/rules/tooling.md`. Replace:

````
The workflow cannot review the PR that introduces it; verify on the next one. Record here which labels the project actually created.
````

with:

````
The workflow cannot review any PR that changes it — `claude-code-action` skips it, green and with no session (the review template's Constraint 1 carries the source) — and its last step, `Assert the review posted`, goes red on such a PR with the reason; verify on the next PR. The model is named by family alias, so the action's pinned SHA fixes both the model and the Claude Code the bot runs, and the job summary records each: check a harness fact the bot asserts against the Claude Code version you run before acting on it. Record here which labels the project actually created.
````

- [ ] **Step 4: Run the fixtures, a YAML parse, the block, and record the budget.**

Run: `bash .claude/workflows/tests/review-assert-fixture.sh && python3 -B .claude/workflows/tests/review-trigger-fixture.py`
Expected: `review-assert-fixture: 15 cases ok (…)`, `review-trigger-fixture: 12 cases ok (1 workflow(s))`.

Run: `python3 -c 'import sys, yaml; [yaml.safe_load(open(f)) for f in sys.argv[1:]]; print("yaml ok")' .claude/skills/blueprint/references/templates/claude-review.yml`
Expected: `yaml ok`.

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'tooling.md|always-loaded total|WARN|verification: (kit|done)'; echo "exit=${PIPESTATUS[0]}"`
Expected: `always-loaded: .claude/rules/tooling.md (N bytes)` where N is the parent commit's figure plus 452
(12,868 when V3's edit to the same file has not changed its size), `always-loaded total: <parent + 452> bytes`, no
`WARN` line, `verification: kit sub-block complete`, `verification: done`, `exit=0`. Record both totals for the PR
body (D50); V5's D59 split pays the growth back.

- [ ] **Step 5: Commit.**

```bash
git add .claude/rules/tooling.md .claude/skills/blueprint/references/templates/claude-review.yml .claude/rules/cbk-conventions-reference.md
git commit -F - <<'MSG'
docs(review-bot): V4.6 — constraint 1 as the action states it; tooling.md § Automated review

The review template's Constraint 1 says the workflow cannot review any PR that changes it, quoting
the action's own log line for the skip, and tooling.md § Automated review says the same, names the
assert step that goes red on such a PR, and adds that the pinned action fixes the model and the
Claude Code the bot runs, so a harness fact the bot asserts is checked against the operator's version.
Constraints 3 and 6 are sourced to the action at the pinned SHA, and the track_progress rail is dated:
labeled is accepted from v1.0.188. The block's review-automation check and a tooling.md check follow
the corrected wording. Always-loaded +452 bytes (tooling.md).

Trace: #67/c5901495773/6, #67/c5901495773/9, review/portability/35

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
```

## Coverage

Every id in V4's pack, and where it lands.

| Id | Source | Lands in |
|---|---|---|
| `#67/body/1a` | item | V4.4 (claude.yml `--model opus`, `--fallback-model sonnet`) |
| `#67/body/1b` | item | V4.4 (`opus` default and deep, `sonnet` fast and fallback; never `best`) |
| `#67/body/1c` | item | V4.4 (the deep-branch `fable` comment, reworded to the live page's "Fable 5.1 requires Claude Code v2.1.257 or later") |
| `#67/body/1d` | item | V4.4 (Model naming paragraph: the SHA is the model pin; never ANTHROPIC_MODEL, sourced to the action) |
| `#67/body/2a` | item | V4.4 (`Record the resolved model` on claude-review.yml; `id: review` lands in V4.3) |
| `#67/body/2b` | item | V4.4 (claude.yml's record step and `id: claude`; the duplicated literals pinned equal by the fixture) |
| `#67/body/2c` | item | V4.4 (`Model in use: the … alias`) |
| `#67/body/3` | item | handed to V5 (the `orchestration.md` § Generation notes review-bot paragraph); the templates cite that heading from V4.4 |
| `#67/c5804984992/1` | item | V4.4 (`--effort high` on claude.yml, with the sourced reason) |
| `#67/c5877251222/1` | item | V4.3 (pages slurped once, `jq -s`; the fake gh refuses `--jq`) |
| `#67/c5877251222/2` | item | V4.3 (verdict marker on `updated_at`) |
| `#67/c5877251222/3` | item | V4.3 (`!cancelled()`) |
| `#67/c5877251222/4` | item | V4.3 (`SESSION_RAN` keyed on `execution_file`; two notices) |
| `#67/c5881158070/1 (corrected by c5892401572/1)` | item | V4.3 (the diff-keyed skip notice; the internal skip flag not used) |
| `#67/c5881158070/2a` | item | V4.4 (the Pick-model comment: the fast branch's `high` is load-bearing) |
| `#67/c5881158070/2b + #67/c5892401572/Effort` | item | V4.4 (the ultracode comment re-dated and sourced; `xhigh` named) |
| `#67/c5881158070/2c` | item | handed to V5 (`orchestration-reference.md` dated facts) and V10 (CHANGELOG v1.0.0 sync note) — not in the templates, per the settled call |
| `#67/c5892401572/2` | item | V4.3 (`review-assert-fixture.sh`, synthetic pages); `extract-run-block.sh` is V2's |
| `#67/c5892401572/3` | item | V4.3 (the tracker-with-verdict case and comment) |
| `#67/c5901495773/1a` | item | V4.2 (`paths:` in D48's order; prompt skip clause) |
| `#67/c5901495773/1b` | item | V4.2 (`review-trigger-fixture.py` in the kit sub-block) |
| `#67/c5901495773/1c` | item | V4.2 (blueprint `tooling.md` review-bot sentence) |
| `#67/c5901495773/2` | item | V4.5 (report only commands actually run) |
| `#67/c5901495773/3` | item | V4.5 (the gate/allowlist note above `claude_args`, sourced) |
| `#58/c5901493591/R12 = #67/c5901495773/4` | item | V4.5 (`[N — the note above claude_args]` and the sizing note, re-measured on 2.1.285) |
| `#67/c5901495773/5` | item | template half V4.4 (the header's re-check duty) and V4.5 (the N note); rules half handed to V5 |
| `#67/c5901495773/6` | item | V4.6 (`tooling.md`: harness facts checked against the operator's version) |
| `#67/c5901495773/7` | item | V4.5 (CI read with `gh pr checks`) |
| `#67/c5901495773/8` | item | V4.1 (the pointer to #70's items, landed there) |
| `#67/c5901495773/9` | item | V4.6 (`cannot review any PR that changes it`, template and `tooling.md`; the block literal) |
| `#67/c5901495773/confirm-1` | item | V4.4 (the record step reads the resolved `init.model`; the local probe saw `claude-sonnet-5-5` for `--model sonnet` on 2.1.285) |
| `#67/c5901495773/confirm-2` | item | V4.3 (Constraint 4 restamped with the exercised paths) |
| `#68/body/2a (+c5861166655/2, c5881158244/1, c5892402074/2)` | item | V4.5 (prompt section and header GOTCHA) |
| `#68/body/2b` | item | V4.5 (`.claude/`-hosted fixtures kept out of prompt gates) |
| `#68/body/2c` | item | V4.5 (CI's `[<the CI job that runs the project's check task>]` named as the check) |
| `#68/body/2d` | item | V4.5 (claude.yml's restore bullet) |
| `#68/c5881158244/2 (+c5892402074/2)` | item | V4.5 (the symlinked `AGENTS.md` bracket and the GOTCHA's consequence) |
| `#68/c5901496131` | item | V4.5 (nested `CLAUDE.md` reads at the PR head; both templates) |
| `#70/body/1a` | item | V4.1 |
| `#70/body/1b` | item | V4.1 |
| `#70/body/1c` | item | V4.1 |
| `#70/body/2` | item | V4.1 (both templates, the CI skeleton, the starter stub) |
| `#70/body/3` | item | V4.1 (same four files) |
| `#69/c5859756889/3-C4` | handedIn | V4.4 (claude.yml's effort; the rules paragraph is V5's) |
| `#69/c5881157875/3a` | handedIn | V4.4 (the template half: `--effort xhigh` explicit, the ultracode comment re-dated); the rules half is V5's |
| `release/5` | handedIn | V4.5 (the two `#58` citations in claude-review.yml, plus a scoped check); the kit-wide sweep and check are V9's/V10's |
| `critic/18` | handedIn | V4.4 (the fast branch's `effort=high` labelled, in a comment beside it, a pin pending a Sonnet 5.5 effort sweep, the recalibration quote sourced and fact-checked); the rule-side pins and the finder brief are V5.3's and V5.4's |
| `review/claude-code/56` | handedIn | V4.1 (Edit 9: the CI skeleton's two `uses:` lines in the fill-slot form `@[full-commit-sha] # v[version]`, as `claude.yml` pins its actions, per `cbk-conventions-reference.md` § Dependency settle-window; Step 4 greps them) |
| `critic/1` | critic | V4.1 (the three kit-sub-block assertions, each shown red by a mutant) |
| `critic/2` | critic | V4.1 (the label-removal comment: a deleted label is the benign branch, sourced) |
| `critic/12` | critic | V4.3 (considered; `conclusion` is not used because it is declared only from v1.0.188 — the step's comment says so) |
| `critic/13` | critic | V4.3 (empty `execution_file` plus the workflow diff) |
| `critic/14` | critic | V4.5 (re-measure on the release the pinned action installs) |
| `critic/15` | critic | V4.5 ("say which version you used") |
| `review/security/18` | review | V4.2 (`concurrency` at job level in both templates) with V4.3's `!cancelled()` |
| `review/security/22` | review | V4.2 (the fork guard in the job `if:`) |
| `review/portability/35` | review | V4.6 (`track_progress` dated to v1.0.188; constraints 1, 3 and 6 sourced) |

## Handed to other clusters

- **V2 — `.claude/workflows/tests/extract-run-block.sh`** (from `#67/c5892401572/2`). V4.3 and V4.4 source it and
never define it. The interface they rely on: `extract_run_block <workflow.yml> <step name>` prints the named step's
`run: |` body, dedented by the body's first-line indent, stops at the first non-blank line indented less, prints
nothing when the step or its `run:` is absent, and compares the step name as a plain string (a name may hold regex
metacharacters and `—`). The preconditions (Before V4.1, Step 2) check that `type -t extract_run_block` is `function`.
- **V5 — the `orchestration.md` review-bot paragraph** (`#67/body/3`, the rules half of `#67/c5901495773/5`). Suggested
content, re-authored onto V5's recalibrated text: the review bots are the one dispatch named by family alias, not
by ID; the alias resolves inside the Claude Code release the pinned action installs, so the action's SHA is the
model pin and Dependabot's action bump is the model bump; effort is per model, so both templates pass `--effort` on
every branch; the action-bump PR re-checks each branch's effort, `--max-turns` and the degrade clause's N, which are
sized together; ANTHROPIC_MODEL is never set on the action step. V4.4's and V4.5's template comments cite
`orchestration.md` § Generation notes for it, so the paragraph should sit under that heading.
- **V5 — dated facts for `orchestration-reference.md`** (`#67/c5881158070/2c`; the rules half of
`#69/c5881157875/3a`). Verified 2026-09-30 by reading `const claudeCodeVersion` in `src/entrypoints/run.ts` at each
tag: v1.0.183 → 2.1.220, v1.0.231 → 2.1.278, v1.0.232 → 2.1.280, v1.0.236 → 2.1.284, v1.0.237 → 2.1.285. The Claude
Code changelog: 2.1.280 (2026-09-22) "Added Claude Opus 5.5 (`claude-opus-5-5`), now the default Opus model"; 2.1.284
(2026-09-28) "Added Claude Sonnet 5.5 (`claude-sonnet-5-5`), now the default Sonnet model on the Anthropic API" and
"it no longer forces xhigh effort" for ultracode. So `opus` first means Opus 5.5 at v1.0.232 and `sonnet` Sonnet 5.5
at v1.0.236. Also available for V5 if it records turn accounting: on Claude Code 2.1.285, `--max-turns` counted
round trips (V4.5's probe, 2026-09-30).
- **V10 — the CHANGELOG v1.0.0 sync notes** (`#67/c5881158070/2c` and this cluster's shape changes). A target that
filled either review workflow hand-merges it: the `paths` filter replaces `paths-ignore` (the target's own prose-only
negations go above the re-includes); `concurrency` moves into the job; the fork guard; `defaults: run: shell: bash`;
`runs-on: ubuntu-24.04`; `id: review` / `id: claude`; the `Record the resolved model` step; the rebuilt "Assert the
review posted" step (keep the filled `REVIEW_LOGIN`); the prompt's restore section and its two new bracketed fills;
the notes above `claude_args`; claude.yml's `--effort high`. The kit sub-block now runs `review-trigger-fixture.py`
and `review-assert-fixture.sh` against the filled `.github/workflows/claude-review.yml` where one exists, so a target
that syncs the rules before its workflow is red until the workflow is merged. The alias fact: a target pinned below
claude-code-action v1.0.232 still gets Opus 5 from `opus`, and below v1.0.236 Sonnet 5 from `sonnet`.
- **V9 — the kit-wide bare-citation check** (`release/5`). V4.5 rewrote the only two bare citations in the review
templates and added a check scoped to those two files; V9's kit-wide check subsumes it (V9 may keep or fold the
scoped line).

## Not holding at planning time

None of V4's items, handed-in asks, critic asks or review findings failed to hold at `643f7ff`: V4's own three review
findings were verified by the review pass and re-checked here against the tree (the workflow-level `concurrency`
at `claude-review.yml:58` and `claude.yml:31`, no fork condition in the job `if:`, the undated `track_progress` line at
`claude-review.yml:160`). The handed-in `review/claude-code/56`, unverified by the review pass, holds at `643f7ff`:
blueprint's `templates/tooling.md:71–72` reads `- uses: actions/checkout@v4` and `- uses: <language-setup-action@version>`.
`critic/18` holds: the fast branch passes `effort=high` with no word that it is uncalibrated for Sonnet 5.5.
Two asks are narrowed rather than dropped, and both are re-checked at execution by the fact
steps: `#67/body/1c`'s "before 2.1.257 `fable` means Fable 5" is not on the live page (the text carries the page's
"Fable 5.1 requires Claude Code v2.1.257 or later" instead), and `#58 R12`'s "turns are spent per tool call" did not
reproduce on Claude Code 2.1.285, where five parallel reads spent one turn; N = 40 against 60 is kept because it is
right under either accounting for a reviewer that reads a file a response, and V4.5's probe decides the sentence.
