# Harvest 4 — the kit as applied — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Land, in the kit, every issue-#58 finding with a proven fix — settings liveness, the hook stdin/exit contract with its fixture, the exercised fork detector, the verification-block repairs and rails, the harness defects, the records rot, the review-workflow templates — as one PR whose verification block is green after every commit.

**Architecture:** Every change is an edit to a file the kit already ships, plus three new files (`hook-contract-fixture.sh`, `run-verification-block.sh`, `.github/workflows/verify.yml`). Hunks ported from the two public target projects are re-authored generic. The verification block in `cbk-conventions-reference.md § Verification` is the test for every task; it gains checks as the tasks land and is run through the new extraction runner.

**Tech Stack:** Markdown, bash (hooks, fixtures, the block), JSON (`settings.json`), JavaScript (workflow scripts + `.mjs` stub harnesses), Python 3 (`agent-cost.py`), YAML (the review-workflow templates, the kit CI). Tools the block needs on the executing machine: `bash`, `jq`, `git`, `node`, `python3`.

**Spec:** `docs/superpowers/specs/2026-09-21-cascade-kit-harvest-4-design.md` — read it in full before Task 1; each task names the cluster (H1–H7) and decision (D30–D40) it implements.

## Global Constraints

- **Portability / sanitized / one-way.** No project name, issue key, package, crate or path from any target lands in kit content; the two public runs (you-are-hear, echosphere) are named only where issue #58 already names them; the private target is never named. Ported hunks are re-authored generic.
- **The block is the gate, after every task.** Run it through the runner Task 1 creates: `bash .claude/workflows/tests/run-verification-block.sh` — green, both sentinels printed. Until Task 1 lands, run the documented extraction: `awk '/^## Verification/{p=1} p' .claude/rules/cbk-conventions-reference.md | awk '/^```bash/{c=1;next} /^```/{c=0} c' > /tmp/cbk-verify.sh && bash -e /tmp/cbk-verify.sh`.
- **New checks are plain lines inside the single fence**; must-be-absent checks use `absent` with a self-splitting literal (`opinionate[d]`); positive chains are wrapped `{ … } || { echo …; exit 1; }`.
- **Hooks:** `bash -n` on every hook after editing it; `set -uo pipefail`, never `set -e`; no bash-4-only builtins (`mapfile`, `readarray`) — a stock macOS bash is 3.2; every hook header carries `Tier:` and, from Task 3, `Depends:`.
- **Executor pair byte-parallel.** Any edit to `.claude/commands/finish.md` is made identically to `.claude/skills/rough-in/references/finish-command.md` below its `--- BEGIN TEMPLATE ---` marker (line 83); the block diffs them.
- **Starters byte-identical.** Any edit to `.claude/skills/scaffold/references/adr-starters/README.md` is made identically to `docs/adr/README.md`; the block diffs the two directories.
- **Never commit on `main`; branch is `feat/harvest-4-applied-defects` (exists).** One commit per task, Conventional Commits naming the #58 item, trailer `Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>`. No CI-skip marker on any commit.
- **Platform claims carry a page and a date** (`https://code.claude.com/docs/en/hooks`, read 2026-09-21) or a dated field observation; none from memory.
- **Every `SKILL.md` stays under 500 lines** (the block enforces it).

## Decisions taken while planning (for the PR body)

- **D-P-1 — the extraction rails live in a runner script**, `.claude/workflows/tests/run-verification-block.sh`, not inside the block: a block cannot detect its own empty extraction or its own early exit. The kit's CI calls the runner; a target copies it as its check-task body (the conventions say so).
- **D-P-2 — the advisory-exemplar arm stays in the kit sub-block, guarded by "not a target"** (`[ ! -f docs/cbk/scaffold.md ]`), and the project sub-block asserts the target's declared `ADVISORY_WIRED` set instead — one variable, declared at the top of the project sub-block, default empty.
- **D-P-3 — the fixture's over-buffer probes cover the two decision sites the kit ships** (`protect-main-branch.sh`, `guard-pr-state.sh`) plus the detector's second stop; the kit has no close-keyword guard.
- **D-P-4 — the review-sweep retry reindex adopts finish-ab's index-list idiom** (the O(n) one); finish-ab's stays.
- **D-P-5 — `claude-review.yml` template already carries `checks: read` in the job block at `e92e9c4`**; the missing half is `additional_permissions`. `claude.yml` template lacks both. The plan edits exactly those.
- **D-P-6 — the base-ref fetch is a step, not a checkout change**: `ref: head.sha` stays (it is what the reviewer must review); a following step fetches `origin/<base>` so `git diff origin/<base>...HEAD` resolves.

---

### Task 0: Baseline and the plan commit

**Files:**
- Create: `docs/superpowers/plans/2026-09-21-harvest-4-applied-defects.md` (this file)

- [ ] **Step 1: Confirm the branch and a clean tree**

Run: `cd /home/j4th/Code/create/context-builder-kit && git branch --show-current && git status --short`
Expected: `feat/harvest-4-applied-defects`, and only this plan file untracked.

- [ ] **Step 2: Run the block at baseline and record the always-loaded total**

Run:
```bash
awk '/^## Verification/{p=1} p' .claude/rules/cbk-conventions-reference.md | awk '/^```bash/{c=1;next} /^```/{c=0} c' > /tmp/cbk-verify.sh && bash -e /tmp/cbk-verify.sh 2>&1 | tail -12
```
Expected: `always-loaded total: 130405 bytes`, `verification: kit sub-block complete`, `verification: done`, exit 0. Record the total for the PR body.

- [ ] **Step 3: Run the four stub fixtures**

Run: `node .claude/workflows/tests/load-workflow-shape.mjs && node .claude/workflows/tests/review-sweep-accounting.mjs && node .claude/workflows/tests/finish-ab-shape.mjs && bash .claude/workflows/tests/agent-cost-fixture.sh; echo "exit=$?"`
Expected: `exit=0`.

- [ ] **Step 4: Commit the plan**

```bash
git add docs/superpowers/plans/2026-09-21-harvest-4-applied-defects.md
git commit -m "docs(plan): harvest 4 implementation plan

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 1: Verification block — the runner with two rails, the two repaired checks, stderr kept, the kit's own CI (H4; D31, D-P-1, D-P-2)

**Files:**
- Create: `.claude/workflows/tests/run-verification-block.sh`
- Create: `.github/workflows/verify.yml`
- Modify: `.claude/rules/cbk-conventions-reference.md` — prose above the fence (§ Verification, line 468–471), the fence's preamble comment (lines 473–478), line 493 (`.mcp.json.example`), line 603 (the hook loop), lines 610–612 (launch-root dry-runs), the project sub-block (lines 669–699)

**Interfaces:**
- Produces: `bash .claude/workflows/tests/run-verification-block.sh` — exit 0 only when the extraction is non-empty, the block exits 0 **and** printed `verification: done`. Every later task's test step uses it.
- Produces: the project sub-block variable `ADVISORY_WIRED` (space-separated basenames; default empty).

- [ ] **Step 1: Write the runner**

```bash
#!/usr/bin/env bash
# Runs the verification block (cbk-conventions-reference.md § Verification) with two fail-loud
# rails the block cannot carry itself: an EMPTY extraction is red (the heading or the fence
# moved — a plain `bash -e` on an empty file exits 0), and an exit 0 that never printed the
# closing sentinel is red (the block ended early). The kit's CI calls this; a target project
# copies it as the body of the task its check command runs (cbk-conventions-reference.md
# § Verification › Run it). Run from the repository root: bash .claude/workflows/tests/run-verification-block.sh
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
```

Then: `chmod +x .claude/workflows/tests/run-verification-block.sh`

- [ ] **Step 2: Prove both rails by mutation, then restore**

Run (empty extraction): `cp .claude/rules/cbk-conventions-reference.md /tmp/ref.bak && sed -i 's/^## Verification$/## Verificationx/' .claude/rules/cbk-conventions-reference.md && bash .claude/workflows/tests/run-verification-block.sh; echo "exit=$?"; cp /tmp/ref.bak .claude/rules/cbk-conventions-reference.md`
Expected: `verification: EMPTY EXTRACTION …`, `exit=1`.

Run (missing sentinel): `sed -i 's/^echo "verification: done"$/echo "verification: dne"/' .claude/rules/cbk-conventions-reference.md && bash .claude/workflows/tests/run-verification-block.sh | tail -2; cp /tmp/ref.bak .claude/rules/cbk-conventions-reference.md && git diff --stat .claude/rules/cbk-conventions-reference.md`
Expected: `verification: exit 0 WITHOUT the done sentinel …`; the restore leaves no diff.

- [ ] **Step 3: Repair the `.mcp.json.example` operand (block line 493)**

Replace:
```bash
absent grep -rn -i "opinionate[d] profile\|opinionated_profil[e]" .claude/ README.md .mcp.json.example
```
with:
```bash
# The example env file is an operand only where it exists: a target that commits `.mcp.json` instead
# names that file here, and a project sub-block re-homed from a pre-split contract must split its own
# `opinionated profile` literal or this very line matches it (#58, second application, item 1).
mcpx=""; [ -f .mcp.json.example ] && mcpx=.mcp.json.example
absent grep -rn -i "opinionate[d] profile\|opinionated_profil[e]" .claude/ README.md $mcpx
```

- [ ] **Step 4: Make the advisory-exemplar arm kit-tree-only (block line 603) and add the project-side arm**

Replace, inside the `for h in .claude/hooks/*.sh; do … done` line, the arm:
```bash
case "$b" in format-on-edit.sh|analyze-on-edit.sh) [ "$n" -eq 0 ] || { echo "advisory exemplar $b is registered"; exit 1; };; *) [ "$n" -ge 1 ] || { echo "$b is not registered"; exit 1; };; esac
```
with:
```bash
case "$b" in format-on-edit.sh|analyze-on-edit.sh) if [ ! -f docs/cbk/scaffold.md ]; then [ "$n" -eq 0 ] || { echo "advisory exemplar $b is registered (the kit tree ships it unregistered; a target declares ADVISORY_WIRED in its sub-block)"; exit 1; }; fi;; *) [ "$n" -ge 1 ] || { echo "$b is not registered"; exit 1; };; esac
```
and change the comment line above the loop from "the advisory exemplars stay unregistered" to "the advisory exemplars stay unregistered on the kit tree (a target asserts its own wiring in the project sub-block)".

In the project sub-block, directly after the `if [ -f docs/cbk/scaffold.md ]; then` line, insert:
```bash

  # Advisory hooks the project wired (§ Hook authoring): name each registered one here, space-separated.
  # Each named hook must be registered exactly once; each unnamed one zero times. Default: none wired.
  ADVISORY_WIRED="${ADVISORY_WIRED:-}"
  for b in format-on-edit.sh analyze-on-edit.sh; do n=$(jq -r '[.hooks[][] | .hooks[] | .command] | map(select(endswith("'"$b"'"))) | length' .claude/settings.json); case " $ADVISORY_WIRED " in *" $b "*) [ "$n" -eq 1 ] || { echo "advisory hook $b is declared wired but registered $n times"; exit 1; };; *) [ "$n" -eq 0 ] || { echo "advisory hook $b is registered but not declared in ADVISORY_WIRED"; exit 1; };; esac; done
```

- [ ] **Step 5: Keep the launch-root dry-runs' diagnostic (block lines 610–612)**

Replace the three lines:
```bash
rc=0; printf '{"tool_name":"Agent","tool_input":{},"cwd":"%s/docs"}' "$PWD" | .claude/hooks/require-repo-root-for-agents.sh >/dev/null 2>&1 || rc=$?
[ "$rc" -eq 2 ] || { echo "launch-root guard did not DENY a subdirectory dispatch (exit $rc; only 2 blocks)"; exit 1; }
printf '{"tool_name":"Agent","tool_input":{},"cwd":"%s"}' "$PWD" | .claude/hooks/require-repo-root-for-agents.sh >/dev/null 2>&1 || { echo "launch-root guard blocked a root dispatch"; exit 1; }
```
with:
```bash
# stderr is kept and printed on failure: the hook's own reason is the diagnostic (#58 item 11).
rc=0; err=$(printf '{"tool_name":"Agent","tool_input":{},"cwd":"%s/docs"}' "$PWD" | .claude/hooks/require-repo-root-for-agents.sh 2>&1 >/dev/null) || rc=$?
[ "$rc" -eq 2 ] || { echo "launch-root guard did not DENY a subdirectory dispatch (exit $rc; only 2 blocks). The hook said:"; printf '  %s\n' "$err"; exit 1; }
rc=0; err=$(printf '{"tool_name":"Agent","tool_input":{},"cwd":"%s"}' "$PWD" | .claude/hooks/require-repo-root-for-agents.sh 2>&1 >/dev/null) || rc=$?
[ "$rc" -eq 0 ] || { echo "launch-root guard blocked a root dispatch (exit $rc). The hook said:"; printf '  %s\n' "$err"; exit 1; }
```

- [ ] **Step 6: State the runner in the prose above the fence**

After the paragraph that precedes the fence in § Verification (line 468–471), add:
```markdown
**Run it** through `.claude/workflows/tests/run-verification-block.sh`: it performs the documented extraction and adds two fail-loud rails the block cannot carry for itself — an empty extraction is red (a plain `bash -e` on an empty file exits 0), and an exit 0 that never printed `verification: done` is red. The kit's CI runs it on every pull request; a target wires the same script as the body of a task its check command depends on (a check nobody re-runs is a belief with a date on it — #58, second application, item 7). The block stays fail-fast: every red is fixed, or the check is narrowed in the project's own copy with an inline comment saying why — a "recorded" red cannot reach the sentinels.
```

- [ ] **Step 7: The kit's own CI**

Create `.github/workflows/verify.yml`:
```yaml
name: Verification block

# Runs cbk-conventions-reference.md § Verification through its runner on every pull request to
# main — no path filter, so it can be a required check (the required-checks trap in
# cbk-conventions.md § `[skip ci]` rule). ubuntu-latest ships bash, jq, git, node and python3
# (dated observation, 2026-09-21; the runner names any tool it cannot find).

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  verify:
    name: Verification block
    runs-on: ubuntu-latest
    timeout-minutes: 10
    permissions:
      contents: read
    steps:
      - name: Checkout
        uses: actions/checkout@11d5960a326750d5838078e36cf38b85af677262 # v4.4.0
      - name: Run the block through its runner
        run: bash .claude/workflows/tests/run-verification-block.sh
```

- [ ] **Step 8: Run the runner and the mutation for the new arm**

Run: `bash .claude/workflows/tests/run-verification-block.sh | tail -4; echo "exit=$?"`
Expected: both sentinels, `exit=0`.

Run (mutation — a target that wired the formatter, undeclared): in a throwaway copy `cp -r . /tmp/kitcopy && cd /tmp/kitcopy && touch docs/cbk/scaffold.md 2>/dev/null || (mkdir -p docs/cbk && touch docs/cbk/scaffold.md)` then register `format-on-edit.sh` in `settings.json`'s `PostToolUse` with `jq`, run the runner, expect `advisory hook format-on-edit.sh is registered but not declared in ADVISORY_WIRED`; then export `ADVISORY_WIRED=format-on-edit.sh` and expect the project sub-block to pass that arm. `cd -; rm -rf /tmp/kitcopy`.

- [ ] **Step 9: Commit**

```bash
git add .claude/workflows/tests/run-verification-block.sh .github/workflows/verify.yml .claude/rules/cbk-conventions-reference.md
git commit -m "fix(verification): runner with two rails, target-safe advisory arm, guarded .mcp.json.example, diagnostics kept, kit CI (#58 items 5, 11; second application 1, 6, 7)

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 2: Settings liveness — no exemplar object, the invariant asserted, the stanza in the hook headers (H1; D30)

**Files:**
- Modify: `.claude/settings.json` — delete the `_example_PostToolUse_formatter` and `_example_PostToolUse_analyzer` keys (lines 62–79); rewrite the ADVISORY and STOP sentences of `_comment_hooks` (line 3)
- Modify: `.claude/hooks/format-on-edit.sh` and `.claude/hooks/analyze-on-edit.sh` — header gains `Register:` lines
- Modify: `.claude/rules/cbk-conventions-reference.md` — § Hook authoring bullet (line 402); block: the invariant beside the hook-registry checks
- Modify: `README.md` § Customization item 3 — one sentence

- [ ] **Step 1: Delete the two exemplar objects from `settings.json`**

Run: `jq 'del(._example_PostToolUse_formatter, ._example_PostToolUse_analyzer)' .claude/settings.json > /tmp/s.json && mv /tmp/s.json .claude/settings.json && jq -r 'keys[]' .claude/settings.json`
Expected: no `_example_` key listed. (jq re-indents with two spaces, matching the file.)

- [ ] **Step 2: Rewrite the ADVISORY and STOP sentences in `_comment_hooks`**

In the `_comment_hooks` string, replace the sentence beginning `ADVISORY (PostToolUse, exit 0 always) ships as unregistered exemplars with their stanzas beside \`hooks\`:` up to `— copy a stanza into hooks.PostToolUse after wiring its case arms to your stack.` with:

```
ADVISORY (PostToolUse, exit 0 always) ships as two unregistered exemplars, format-on-edit.sh and analyze-on-edit.sh (the analyzer runs the project's analyzer on the edited file's package, errors only; measured under a second per package on a real run, 2026-09-05); each hook's header carries the registration stanza to copy into hooks.PostToolUse once its case arms are wired. NO exemplar object lives in this file: a top-level key holding a matcher/hooks object makes the harness discard the whole settings file — every guard, enabledMcpjsonServers and enabledPlugins inert, silently (Claude Code 2.1.270–2.1.278; single-variable probe on a real application 2026-09-13, the parser's fatal diagnostic read from the 2.1.278 bundle 2026-09-21), and the verification block asserts none is present.
```

and replace `detect-forked-agent-memory.sh exits 2 while a \`.claude/agent-memory/\` tree exists anywhere but the root` with `detect-forked-agent-memory.sh exits 2 while a \`.claude/agent-memory/\` or \`.claude/agent-memory-local/\` tree exists anywhere but the root (both memory scopes fork the same way)`.

Use `jq --arg c "<the full new comment>" '._comment_hooks = $c'` or a careful editor replacement inside the JSON string (escape `"` as `\"`). Verify: `jq -r '._comment_hooks' .claude/settings.json | grep -c 'NO exemplar object'` → `1`.

- [ ] **Step 3: The stanza in each advisory hook's header**

In `.claude/hooks/format-on-edit.sh`, after the `# Tier:     ADVISORY …` header line, add:
```bash
# Register: copy this object into hooks.PostToolUse in .claude/settings.json once the case
#           arms are wired — never as a top-level key (cbk-conventions-reference.md § Hook
#           authoring: a hook-shaped object outside `hooks` voids the whole settings file):
#           { "matcher": "Edit|Write|MultiEdit",
#             "hooks": [ { "type": "command",
#                          "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/format-on-edit.sh" } ] }
```
The same six lines in `.claude/hooks/analyze-on-edit.sh` after its `# Tier:     ADVISORY.` line, with `analyze-on-edit.sh` in the command. Then edit the analyzer header's existing sentence that says it "registers it via the `_example_…` stanza" (lines 2–4) to "the registration stanza is the `Register:` block below".

- [ ] **Step 4: Rewrite § Hook authoring's exemplar bullet (reference.md line 402)**

Replace the bullet `- **Exemplar stanzas ship commented out.** …` with:
```markdown
- **No hook-shaped object outside `hooks`, ever.** An advisory hook the project must wire to its stack (a formatter, an analyzer) ships unregistered, and its registration stanza lives in the hook's own header (`Register:`), copied into `hooks.PostToolUse` after the case arms are filled — so a fresh checkout never runs a formatter it does not have. JSON has no comments, and a "commented-out" stanza approximated by a live top-level object is a defect: any top-level key that is not `hooks` (nor one of the harness's own settings keys) whose value carries `matcher` or a non-empty `hooks` is a fatal settings diagnostic, after which the parser returns no settings at all — every guard, `enabledMcpjsonServers` and `enabledPlugins` inert, silently, with the verification block green (Claude Code 2.1.270–2.1.278: found on a real application by single-variable probe, 2026-09-13; the fatal path read from the 2.1.278 bundle, 2026-09-21; re-verify after upgrades). The block asserts the invariant on every run.
```
Then grep the file for any remaining `_example_PostToolUse` mention (the analyzer bullet says "the exemplar ships with them commented, inside the `case`" — that is about the case arms, keep it) and fix wording that still says the stanza sits "beside `hooks`".

- [ ] **Step 5: The invariant in the block**

Directly after the line `hookcomment=$(jq -r '._comment_hooks' .claude/settings.json)` insert:
```bash
# No hook-shaped object at the top level of settings.json (§ Hook authoring): the harness discards the
# whole file on one, silently. An empty key read is red, never a vacuous pass.
[ "$(jq -r 'keys | length' .claude/settings.json)" -ge 1 ] || { echo "settings.json: no top-level keys read — the check below would pass vacuously"; exit 1; }
bad=$(jq -r 'to_entries | map(select(.key != "hooks" and (.value | type == "object") and ((.value | has("matcher")) or (.value | has("hooks"))))) | .[].key' .claude/settings.json); [ -z "$bad" ] || { echo "settings.json: hook-shaped top-level object(s) void the whole file: $bad"; exit 1; }
absent grep -n '"_example_PostToolUse_' .claude/settings.json
```

- [ ] **Step 6: README § Customization item 3**

Append to item 3's sentence: ` Never add a hook-shaped object as a top-level key while doing so — the advisory hooks' registration stanzas live in their headers (see \`.claude/rules/cbk-conventions-reference.md\` § Hook authoring).`

- [ ] **Step 7: Prove the invariant by mutation, then run the runner**

Run: `cp .claude/settings.json /tmp/s.bak && jq '. + {"_example_PostToolUse_x": {"matcher":"Edit","hooks":[{"type":"command","command":"x"}]}}' /tmp/s.bak > .claude/settings.json && bash .claude/workflows/tests/run-verification-block.sh | grep 'void the whole file'; cp /tmp/s.bak .claude/settings.json`
Expected: `settings.json: hook-shaped top-level object(s) void the whole file: _example_PostToolUse_x`.

Run: `bash -n .claude/hooks/format-on-edit.sh && bash -n .claude/hooks/analyze-on-edit.sh && bash .claude/workflows/tests/run-verification-block.sh | tail -3`
Expected: both sentinels, exit 0.

- [ ] **Step 8: Commit**

```bash
git add .claude/settings.json .claude/hooks/format-on-edit.sh .claude/hooks/analyze-on-edit.sh .claude/rules/cbk-conventions-reference.md README.md
git commit -m "fix(settings): no exemplar object in settings.json — the stanza moves to the hook headers and the block asserts the invariant (#58, the settings-liveness finding)

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 3: § Hook authoring — the stdin/exit contract and the `Depends:` header line (H2; D33)

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md` § Hook authoring — the `**Header.**` bullet, the `**The stdin / exit contract.**` bullet, the `**Verify by payload.**` bullet

- [ ] **Step 1: The header shape gains `Depends:`**

In the `**Header.**` bullet, after the clause that names `Tier:`, add: `; a \`Depends:\` line naming each external dependency (jq, git, mktemp, a sourced helper) and what its absence costs — fail open, degrade unpruned, degrade unmonitored — so a rewrite that adds a dependency cannot leave the header claiming none (#58, 2026-09-07 comment).`

- [ ] **Step 2: Replace the stdin/exit-contract bullet**

Replace the bullet beginning `- **The stdin / exit contract.** JSON on stdin` with:
```markdown
- **The stdin / exit contract.** **Drain stdin before anything that can exit** — `input="$(cat)"` is the first statement after `set -uo pipefail`, above the dependency check and every other early exit. A hook that exits unread leaves its caller holding an open pipe with no reader, so the caller takes SIGPIPE; the masking needs a shell pipeline under `pipefail` (`printf … | hook`), where the writer's 141 becomes the *pipeline's* status and hides the hook's own exit code, so a guard that failed open correctly reads as a crash. That is exactly the shape of this file's § Verification dry-runs, the hook fixture, and any script that pipes a payload in; the harness's registered call is not that shape (a `command` entry with no `args` runs as one process with the payload written to its stdin — `https://code.claude.com/docs/en/hooks`, read 2026-09-21), and draining first is the contract regardless, because the test and verification surfaces are where a hook's exit code is read as its verdict. A payload smaller than the pipe buffer lets the writer finish first, so the race is one a small-payload test almost always wins — a regression test for a race must not itself be a race. **And never decide on the status of a pipeline whose reader can exit first.** `printf '%s' "$x" | grep -Eq …` reads like a string test, but grep exits on its first matching *line*, so a multi-line subject past the buffer leaves the writer to take SIGPIPE and `pipefail` turns a match into a 141 the `if` reads as *no match* — a guard bypassed with no warning, the one fail-open shape the next bullet forbids. A single long line hides it (grep must reach EOF to complete the line), so a filler-on-one-line probe reads clean. Feed the subject as a here-string (`grep -Eq … <<<"$x"`), which keeps grep's line semantics byte-for-byte and leaves nothing still writing when the reader exits (bash hands a small subject a pipe it has already filled and spills a large one to an unlinked temp file), and cap a report inside its producer (awk's own counter), never with `| head -N`. Measured on a real application, 2026-09-18: a >64 KiB multi-line commit body bypassed the main-branch deny outright and a long `gh pr merge --body` skipped the PR-state ask-gate (you-are-hear #81 → PR #82). Both halves are enforced by `.claude/workflows/tests/hook-contract-fixture.sh`, which reads every hook: one structural check asserts the drain is the first statement, the other that no hook pipes into an early-exiting reader — a tripwire over known spellings, not a proof, so a new hook still earns a behavioural case. Then the wire contract: JSON on stdin (`tool_name`, `tool_input`, and the common fields, `cwd` among them — `https://code.claude.com/docs/en/hooks-guide` § How hooks work). Exit 2 + stderr blocks (deny), exit 0 allows; an ask-gate prints `hookSpecificOutput.permissionDecision: "ask"` with a reason and exits 0 (`https://code.claude.com/docs/en/hooks`: allow / deny / ask / defer). Matching hooks in one group run in parallel — never rely on order between two hooks on the same event. `Stop` takes no matcher; `SubagentStop` matches agent types, and a finishing subagent has no hand-off — a repair-before-stop hook belongs on `Stop`. Verified 2026-09-06; re-verify after harness upgrades.
```

- [ ] **Step 3: Verify-by-payload names the fixture as the durable home**

In the `**Verify by payload.**` bullet, replace `the table of expected and observed exits goes in the PR body` with `the branches a payload can reach are asserted in \`.claude/workflows/tests/hook-contract-fixture.sh\` (durable, run by the block); the PR body's table is for the branches only a mutation can reach, named as such (#58 item 4)`.

- [ ] **Step 4: Run the runner and commit**

Run: `bash .claude/workflows/tests/run-verification-block.sh | tail -3` → both sentinels, exit 0.

```bash
git add .claude/rules/cbk-conventions-reference.md
git commit -m "docs(hooks): the stdin/exit contract — drain first, never decide on a pipe whose reader can exit first; Depends: in the header shape (#58 item 4; you-are-hear #81)

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 4: Every hook drains first; the three decision sites use here-strings (H2; D33)

**Files:**
- Modify: `.claude/hooks/format-on-edit.sh` (drain at 23 → after line 16), `analyze-on-edit.sh` (32 → after 27), `guard-pr-state.sh` (27 → after 18; here-string at 37), `protect-immutable-adrs.sh` (38 → after 24), `protect-lock-files.sh` (40 → after 24), `protect-main-branch.sh` (37 → after 26; here-string at 57), `require-repo-root-for-agents.sh` (55 → after 44), `require-knowledge-backend-ok.sh` (line 20 `cat > /dev/null` → `input="$(cat)"`), `detect-forked-agent-memory.sh` (rewritten wholesale in Task 6 — skip here)

- [ ] **Step 1: Move the drain in the seven jq-checking hooks**

For each of `format-on-edit.sh analyze-on-edit.sh guard-pr-state.sh protect-immutable-adrs.sh protect-lock-files.sh protect-main-branch.sh require-repo-root-for-agents.sh`: delete the existing `input="$(cat)"` line and insert, immediately after the `set -uo pipefail` line:
```bash

# Drain stdin before any early exit, or a piping caller's SIGPIPE masks this hook's own
# exit code (cbk-conventions-reference.md § Hook authoring › The stdin / exit contract).
input="$(cat)"
```
A `sed` that does both per file (GNU sed):
```bash
for h in format-on-edit analyze-on-edit guard-pr-state protect-immutable-adrs protect-lock-files protect-main-branch require-repo-root-for-agents; do
  f=.claude/hooks/$h.sh
  sed -i '/^input="\$(cat)"$/d' "$f"
  sed -i '/^set -uo pipefail$/a\
\
# Drain stdin before any early exit, or a piping caller'"'"'s SIGPIPE masks this hook'"'"'s own\
# exit code (cbk-conventions-reference.md § Hook authoring › The stdin / exit contract).\
input="$(cat)"' "$f"
  bash -n "$f" || exit 1
done
```
Check: `grep -n -A4 '^set -uo pipefail' .claude/hooks/*.sh | grep 'input=' | wc -l` → `7` (the knowledge-backend gate and the detector are handled separately).

- [ ] **Step 2: The knowledge-backend gate drains into a variable, first**

In `require-knowledge-backend-ok.sh`, replace line 20 `cat > /dev/null # consume stdin; the decision is unconditional for matched tools` with:
```bash
# Drain stdin first (cbk-conventions-reference.md § Hook authoring › The stdin / exit contract);
# the decision is unconditional for matched tools, so the payload is read and not inspected.
input="$(cat)"
```
(`set -u` is on and `input` is unused: append `: "$input"` on the next line so a stricter shell never flags it.)

- [ ] **Step 3: Here-strings at the two decision sites**

`guard-pr-state.sh` line 37 — replace:
```bash
if printf '%s' "$command" | grep -Eq '(^|[;&|[:space:]])gh([[:space:]]+[^[:space:]]+)*[[:space:]]+pr([[:space:]]+[^[:space:]]+)*[[:space:]]+(ready|merge|close|reopen)([[:space:]]|$|[;&|])'; then
```
with:
```bash
# A here-string, never `printf … | grep`: a reader that exits on its first match makes
# pipefail read a real match as NO MATCH (cbk-conventions-reference.md § Hook authoring).
if grep -Eq '(^|[;&|[:space:]])gh([[:space:]]+[^[:space:]]+)*[[:space:]]+pr([[:space:]]+[^[:space:]]+)*[[:space:]]+(ready|merge|close|reopen)([[:space:]]|$|[;&|])' <<<"$command"; then
```
`protect-main-branch.sh` line 57 — replace:
```bash
if ! printf '%s' "$command" | grep -Eq '(^|[;&|[:space:]])git([[:space:]]+[^[:space:]]+)*[[:space:]]+commit([[:space:]]|$)'; then
```
with:
```bash
# A here-string, never `printf … | grep`: a reader that exits on its first match makes
# pipefail read a real match as NO MATCH (cbk-conventions-reference.md § Hook authoring).
if ! grep -Eq '(^|[;&|[:space:]])git([[:space:]]+[^[:space:]]+)*[[:space:]]+commit([[:space:]]|$)' <<<"$command"; then
```
Patterns byte-identical; the here-string's trailing newline is immaterial (`$` is end-of-line).

- [ ] **Step 4: Prove the bypass is closed (before Task 5's fixture makes it durable)**

Run:
```bash
body='line of a long body wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww'; while [ ${#body} -lt 250000 ]; do body="$body
$body"; done
r=$(mktemp -d); git -c init.defaultBranch=main init -q "$r"; git -C "$r" -c user.email=f@x -c user.name=f commit -q --allow-empty -m init
printf "git commit -F - <<XEOF\n%s\nXEOF" "$body" | jq -Rs --arg cwd "$r" '{tool_name:"Bash",tool_input:{command:.},cwd:$cwd}' > "$r/pay"
.claude/hooks/protect-main-branch.sh < "$r/pay" >/dev/null 2>&1; echo "exit=$?"; rm -rf "$r"
```
Expected: `exit=2` (before Step 3 the same probe exits 0 — run it once on `git stash` to see the bypass, then `git stash pop`).

- [ ] **Step 5: Run the runner; commit**

Run: `for h in .claude/hooks/*.sh; do bash -n "$h" || echo "SYNTAX $h"; done; bash .claude/workflows/tests/run-verification-block.sh | tail -3`
Expected: no SYNTAX line; both sentinels.

```bash
git add .claude/hooks/
git commit -m "fix(hooks): drain stdin first in every hook; decide on here-strings, never on a pipe whose reader can exit first (#58 item 4; you-are-hear #81)

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 5: `hook-contract-fixture.sh` — the two structural checks and the over-buffer probes, run from the block (H2; D33, D-P-3)

**Files:**
- Create: `.claude/workflows/tests/hook-contract-fixture.sh`
- Modify: `.claude/rules/cbk-conventions-reference.md` — block: invoke the fixture beside the other fixtures

**Interfaces:**
- Consumes: the hooks as Task 4 left them; `detect-forked-agent-memory.sh` as Task 6 will leave it (the second-stop probe below passes on both bodies — the kit's and the exercised one — because both honour `stop_hook_active`).

- [ ] **Step 1: Write the fixture**

```bash
#!/usr/bin/env bash
# Fixture for the kit's hooks: the two properties every hook must have regardless of what it
# guards (cbk-conventions-reference.md § Hook authoring › The stdin / exit contract), asserted
# structurally over every .claude/hooks/*.sh, plus one over-buffer behavioural probe per
# decision site the kit ships. Runs against throwaway `git init` trees under mktemp, never the
# real checkout, and never depends on the directory it is launched from. Run by the
# verification block; also: bash .claude/workflows/tests/hook-contract-fixture.sh
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
hooks="$here/../../hooks"
MAINBRANCH="$hooks/protect-main-branch.sh"
PRSTATE="$hooks/guard-pr-state.sh"
STOP="$hooks/detect-forked-agent-memory.sh"
for h in "$MAINBRANCH" "$PRSTATE" "$STOP"; do [ -x "$h" ] || { echo "hook-contract-fixture: $h is missing or not executable"; exit 1; }; done
d=$(mktemp -d)
cleanup() { chmod -R u+rwX "$d" 2>/dev/null || true; rm -rf "$d"; }
trap cleanup EXIT

RC=0; ERR=""; OUT=""
want() { [ "$RC" -eq "$1" ] || { echo "FAIL: $2 (want exit $1, got $RC)"; [ -n "$ERR" ] && printf '  stderr: %s\n' "$ERR"; exit 1; }; }
says() { grep -q -- "$1" <<<"$ERR" || { echo "FAIL: $2 (stderr does not carry '$1')"; printf '  stderr: %s\n' "$ERR"; exit 1; }; }

# ── structural check 1: the drain is the first statement after `set -uo pipefail` ──
# Comment and blank lines are skipped; the first two statements must be exactly these.
want_drain_first="$(printf 'set -uo pipefail\ninput="$(cat)"')"
for h in "$hooks"/*.sh; do
  sig="$(awk '/^[[:space:]]*(#|$)/ { next } n < 2 { print; n++ }' "$h")"
  [ "$sig" = "$want_drain_first" ] || {
    echo "FAIL: $(basename "$h") does not drain stdin as its first statement"
    printf '%s\n' "$sig" | sed 's/^/  reads instead: /'
    exit 1
  }
done

# ── structural check 2: no hook decides on a pipeline whose reader can exit first ──
# A TRIPWIRE over known spellings (grep -q/-l/--quiet/--silent/-m N, head, read, sed …q, awk … exit
# after a `|`), not a proof; full-line comments are dropped (hooks quote the idiom while explaining
# it) and backslash/pipe continuations are joined first. A new hook still earns a behavioural case.
early_readers='[|][[:space:]]*(([{(]|timeout|xargs|env|stdbuf|while)[[:space:]]*[^|]*)?(grep[^|]*([[:space:]]-[A-Za-z]*[ql][A-Za-z]*([[:space:]]|$)|--quiet|--silent|--max-count|[[:space:]]-m[[:space:]]*[0-9])|head([[:space:]]|$)|read([[:space:]]|$)|sed[^|]*[[:space:]]['"'"'"]?[0-9$]*q|awk[^|]*exit)'
join_pipelines='
  { line = $0
    if (line ~ /^[[:space:]]*#/) line = ""
    buf = buf line
    if (buf ~ /[|\\][[:space:]]*$/) { sub(/\\[[:space:]]*$/, "", buf); next }
    print NR ": " buf; buf = ""
  }
  END { if (buf != "") print NR ": " buf }
'
for h in "$hooks"/*.sh; do
  hit="$(awk "$join_pipelines" "$h" | grep -E "$early_readers" || true)"
  [ -z "$hit" ] || {
    echo "FAIL: $(basename "$h") decides on a pipeline whose reader can exit first"
    printf '%s\n' "$hit" | sed 's/^/  /'
    exit 1
  }
done

# ── behavioural probes: a body of many lines, past any plausible reader ceiling ──
manybody='line of a long body wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww'
while [ ${#manybody} -lt 250000 ]; do manybody="$manybody
$manybody"; done
cmdpay() { jq -Rs --arg cwd "${2:-}" '{tool_name:"Bash",tool_input:{command:.},cwd:$cwd}' "$1"; }

# protect-main-branch is a HARD-DENY: a long commit body must not buy a bypass.
mainrepo="$d/mainrepo"; mkdir -p "$mainrepo"
git -c init.defaultBranch=main init -q "$mainrepo"
git -C "$mainrepo" -c user.email=f@x -c user.name=f commit -q --allow-empty -m init
printf "git commit -F - <<XEOF\n%s\nXEOF" "$manybody" > "$d/cmd-commit"
cmdpay "$d/cmd-commit" "$mainrepo" > "$d/pay-commit"
RC=0; ERR="$("$MAINBRANCH" < "$d/pay-commit" 2>&1 >/dev/null)" || RC=$?
want 2 "a commit on main is denied however long the command string is"
says "BLOCKED" "the long-command denial names itself"

# guard-pr-state is an ASK-GATE: its deliverable is the decision on STDOUT.
printf 'gh pr merge 5 --squash --body "%s"' "$manybody" > "$d/cmd-merge"
cmdpay "$d/cmd-merge" > "$d/pay-merge"
RC=0; ERR=""; OUT="$("$PRSTATE" < "$d/pay-merge" 2>/dev/null)" || RC=$?
want 0 "the PR-state ask-gate still exits 0 on a long command"
grep -q '"permissionDecision": "ask"' <<<"$OUT" || { echo "FAIL: gh pr merge with a long body did not raise the ask-gate"; exit 1; }

# The detector reads one field the same way; the cost there is the loop guard: a payload whose
# field sits early with the bulk after it must still be read as a second stop.
repo="$d/repo"; mkdir -p "$repo"; git -c init.defaultBranch=main init -q "$repo"
mkdir -p "$repo/pkg/a/.claude/agent-memory/reviewer"
printf '%s' "$manybody" > "$d/padfile"
jq -Rs '{stop_hook_active:true,pad:.}' "$d/padfile" > "$d/pay-stop"
RC=0; ERR="$(CLAUDE_PROJECT_DIR="$repo" "$STOP" < "$d/pay-stop" 2>&1 >/dev/null)" || RC=$?
want 0 "a second stop proceeds however long the payload is"
says "still present after one fix attempt" "and warns instead of blocking again"

echo "hook-contract-fixture: ok"
```
Then `chmod +x .claude/workflows/tests/hook-contract-fixture.sh`.

- [ ] **Step 2: Run it; prove each structural check by mutation**

Run: `bash .claude/workflows/tests/hook-contract-fixture.sh` → `hook-contract-fixture: ok`.

Mutation 1: `cp .claude/hooks/guard-pr-state.sh /tmp/g.bak && sed -i '0,/^input="\$(cat)"$/{/^input="\$(cat)"$/d}' .claude/hooks/guard-pr-state.sh && bash .claude/workflows/tests/hook-contract-fixture.sh; cp /tmp/g.bak .claude/hooks/guard-pr-state.sh` → `FAIL: guard-pr-state.sh does not drain stdin as its first statement`.

Mutation 2: `sed -i "s|if ! grep -Eq '\(^|if ! printf '%s' \"\$command\" \| grep -Eq '(^|" .claude/hooks/protect-main-branch.sh` (re-introduce the pipe on the decision line, then run the fixture) → `FAIL: protect-main-branch.sh decides on a pipeline whose reader can exit first`; restore with `git checkout .claude/hooks/protect-main-branch.sh` — no, Task 4's edit is uncommitted only if you skipped its commit; use `cp` backups as in mutation 1.

- [ ] **Step 3: Invoke it from the block**

After the line `bash .claude/workflows/tests/agent-cost-fixture.sh || { echo "agent-cost.py regressed on the fixture"; exit 1; }` insert:
```bash
# Every hook honours the stdin/exit contract (§ Hook authoring): structural checks over .claude/hooks/*.sh
# plus one over-buffer probe per decision site. Runs in throwaway trees; never touches this checkout.
bash .claude/workflows/tests/hook-contract-fixture.sh || { echo "a hook violates the stdin/exit contract (the fixture names it)"; exit 1; }
```

- [ ] **Step 4: Run the runner; commit**

Run: `bash .claude/workflows/tests/run-verification-block.sh | grep -E 'hook-contract-fixture: ok|verification: done'` → both lines.

```bash
git add .claude/workflows/tests/hook-contract-fixture.sh .claude/rules/cbk-conventions-reference.md
git commit -m "test(hooks): hook-contract-fixture — drain-first and no-early-reader asserted structurally, over-buffer probes on the two decision sites, run by the block (#58 item 4)

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 6: The fork detector — the exercised body, `.claude-pr` pruned, tooling paths are not forks (H3; D32)

**Files:**
- Modify: `.claude/hooks/detect-forked-agent-memory.sh` — full replacement
- Modify: `.claude/rules/cbk-conventions-reference.md` § .gitignore anchoring — the harness-transients bullet (line 271)

- [ ] **Step 1: Replace the hook body**

Write `.claude/hooks/detect-forked-agent-memory.sh` as the exercised body (issue #58 items 1–2 and the 2026-09-07 comment, re-authored generic). The full file:

```bash
#!/usr/bin/env bash
# Stop hook: refuse to finish while a reviewer's `memory: project` tree sits
# anywhere but the repository root.
#
# require-repo-root-for-agents.sh refuses the dispatch that causes a fork: a
# subagent starts in the main conversation's current working directory, and
# `memory: project` is the relative path `.claude/agent-memory/<name>/`
# (https://code.claude.com/docs/en/sub-agents, verified 2026-09-06). This hook
# catches the OUTCOME, whatever produced it — a second `.claude/agent-memory/`
# under a package, the shape a real run committed and repaired by hand. On the
# flip's auto-review it was found by a reviewer walking every changed file;
# here it is found before the hand-off, by the agent that made it.
#
# Blocked:  the main conversation's stop, once, while a stray agent-memory or
#           agent-memory-local directory exists — both memory scopes fork the same
#           way (exit 2 + the remediation on stderr).
# Allowed:  a clean tree; a second stop after one block (`stop_hook_active`);
#           a working directory that is not a git checkout (fail-open with a warning);
#           a tree under a directory the project's own ignore rules exclude, or under
#           `./.claude-pr` — see Residual below.
# Event:    Stop only. Not SubagentStop — a finishing subagent has no hand-off
#           to repair the tree in, and `stop_hook_active` is documented for
#           Stop; registering there would block every subagent of a review
#           pass while a stray tree exists (demonstrated 2026-09-06).
# Loop:     exit 2 on a Stop hook blocks the stop and feeds stderr to the
#           agent (https://code.claude.com/docs/en/hooks — exit-code table).
#           `stop_hook_active` is true when the agent is already continuing
#           from this hook: warn and let it stop. The harness overrides a Stop
#           hook after eight consecutive blocks without progress
#           (https://code.claude.com/docs/en/hooks-guide § Limitations and
#           troubleshooting › "Stop hook hits the block cap"; verified
#           2026-09-06, re-verify after upgrades), so this hook blocks at most
#           once per stop. A payload without the field is treated as the first
#           block (the assumption is stated, not silently defaulted).
# Residual: the walk prunes every directory the project's ignore rules exclude, so
#           a tree placed by hand or by tooling UNDER an ignored directory (a build
#           output, a tool cache) exits 0 — the dispatch that would create one is
#           refused by require-repo-root-for-agents.sh, which is the guard for that
#           case (#58 item 1's scenario table, reproduced independently 2026-09-13).
#           `./.claude-pr` is pruned unconditionally: it is the staging copy a
#           hosted review action makes of the branch's `.claude/` tree, committed
#           memory included — a copy, not a fork (#58, 2026-09-07 comment).
# Path:     registered as ${CLAUDE_PROJECT_DIR}/.claude/hooks/… (handlers run
#           in the current directory — https://code.claude.com/docs/en/hooks).
# Tier:     STOP.
# Depends:  NO jq — the one field this hook reads (`stop_hook_active`) is matched
#           with grep, so this backstop works exactly when the jq-dependent guards
#           have failed open. `git` is required for the root and used for the prune
#           list: without it the guard above fails open, and a failing `git
#           ls-files`/`check-ignore` leaves the prune list empty, so the scan runs
#           unpruned — slower, never blinder. `mktemp` is optional: it holds the
#           scan's stderr, and when no scratch file can be created the walk still
#           runs and says so rather than reporting a clean tree it could not have
#           verified. No bash-4-only builtins (a stock macOS bash is 3.2): the
#           directory list is read with a while loop, not mapfile.

set -uo pipefail

# Drain stdin before any early exit, or a piping caller's SIGPIPE masks this hook's own
# exit code (cbk-conventions-reference.md § Hook authoring › The stdin / exit contract).
input="$(cat)"

# The scan runs from the checkout's git top-level. CLAUDE_PROJECT_DIR is exported to the hook
# process (https://code.claude.com/docs/en/hooks — the same page documents the placeholder);
# when it is absent the process's own $PWD may be a subdirectory — the drift case — and a scan
# rooted there would treat <subdir>/.claude/agent-memory as the canonical tree and miss the fork.
PROJECT_DIR="$(git -C "${CLAUDE_PROJECT_DIR:-$PWD}" rev-parse --show-toplevel 2>/dev/null)" || {
  echo "detect-forked-agent-memory: WARNING — ${CLAUDE_PROJECT_DIR:-$PWD} is not inside a git checkout; fork detection inactive for this stop." >&2
  echo "                            Backstop: the verification block's Stop-hook check (cbk-conventions-reference.md § Verification)." >&2
  exit 0
}

# Absent field ⇒ first block. Present and true ⇒ the agent is already continuing from this hook.
# Matched with grep, not jq, so fork detection has no environment dependency to fail open on.
# A here-string, never `printf … | grep`: a reader that exits on its first match makes
# pipefail read a real match as NO MATCH (cbk-conventions-reference.md § Hook authoring).
active=""
grep -Eq '"stop_hook_active"[[:space:]]*:[[:space:]]*true' <<<"$input" && active="true"

cd "$PROJECT_DIR" || {
  echo "detect-forked-agent-memory: WARNING — cannot enter $PROJECT_DIR; fork detection inactive for this stop." >&2
  echo "                            Backstop: the verification block's Stop-hook check (cbk-conventions-reference.md § Verification)." >&2
  exit 0
}

# Every directory named agent-memory or agent-memory-local that is not the root's
# own (the `project` and `local` scopes fork identically). The walk prunes the root's
# own two trees, worktrees (each is its own checkout with its own root tree), .git,
# the hosted review action's staging copy (`./.claude-pr`), and every directory the
# project's own ignore rules exclude — `git ls-files --others --ignored
# --exclude-standard --directory` names them (build output, tool caches, vendored
# trees), so the skip list is .gitignore's, read at run time, never a hand-kept list
# of stack names (the hand-kept list missed a second project's tool cache on its first
# real application — #58 item 1). No -mindepth: as first written, -mindepth 2
# exempted depth-1 directories from the prune test, so a top-level node_modules was
# walked and its contents flagged (reproduced 2026-09-06). A stray tree under an
# untracked but unignored directory is still found — that is the fork case.
#
# Three rules make an ignore-driven list safe (#58 item 1):
#   1. Never prune a path that could BE or CONTAIN the tree this hook hunts for. A
#      project that ignores the memory directory by an unanchored name (`agent-memory/`
#      — the natural spelling for the `local` scope) or ignores `.claude/` wholesale
#      would otherwise have its own ignore rules hide the fork.
#   2. `-path` takes a glob, and `*`/`?` in it cross `/`. An ignored directory named
#      `*` (a legal Unix name) would splice in as `-path './*'`, prune the first
#      top-level entry the walk reaches, and report a clean tree with no stderr —
#      the silent miss this hook exists to stop. Metacharacters are escaped so an
#      entry prunes itself and nothing else.
#   3. `--directory` collapses a directory whose whole subtree is ignored into its
#      topmost ancestor, and in a repo with nothing committed yet that ancestor can
#      be `packages/` — a directory no ignore rule names. `git check-ignore` keeps
#      only the paths the rules actually exclude, so a collapsed ancestor is walked.
prunes=()
while IFS= read -r d; do
  d="${d%/}"
  [ -n "$d" ] || continue
  case "${d##*/}" in .claude|agent-memory|agent-memory-local) continue ;; esac
  prunes+=(-o -path "./$(printf '%s' "$d" | sed 's/[][*?\\]/\\&/g')")
done < <(
  git ls-files --others --ignored --exclude-standard --directory 2>/dev/null \
    | sed -n 's:/$::p' | git check-ignore --stdin 2>/dev/null || true
)
# find's stderr is kept, not discarded: an unreadable directory makes the scan partial,
# and a partial scan that reports "clean" is the silent miss this hook exists to stop
# (#58 item 2). A redirection to an uncreatable path would abort the walk before find
# ran, leaving forks empty and the tree reported clean — so the path is tested first
# and the walk degrades to unmonitored with a warning (#58, 2026-09-07 comment).
scan_err="$(mktemp 2>/dev/null || printf '%s/.detect-forked-agent-memory.%s.err' "${TMPDIR:-/tmp}" "$$")"
if ! : 2>/dev/null >"$scan_err"; then
  echo "detect-forked-agent-memory: WARNING — no scratch file for the scan's stderr ($scan_err); the walk runs unmonitored, so a partial scan cannot be reported." >&2
  scan_err=/dev/null
fi
forks=()
while IFS= read -r d; do forks+=("$d"); done < <(
  find . \( -path './.claude/agent-memory' -o -path './.claude/agent-memory-local' -o -path './.claude/worktrees' -o -path './.claude-pr' -o -name .git \
         ${prunes[@]+"${prunes[@]}"} \) -prune -o -type d \( -name agent-memory -o -name agent-memory-local \) -print 2>"$scan_err" | sort
)
if [ -s "$scan_err" ]; then
  echo "detect-forked-agent-memory: WARNING — the scan was partial; find could not read:" >&2
  head -n 5 "$scan_err" >&2
  echo "                            A stray tree under an unreadable directory is missed; fix the permissions and stop again." >&2
fi
[ "$scan_err" = /dev/null ] || rm -f "$scan_err"

[ "${#forks[@]}" -eq 0 ] && exit 0

if [ "$active" = "true" ]; then
  echo "detect-forked-agent-memory: WARNING — forked reviewer memory still present after one fix attempt; letting the stop proceed:" >&2
  printf '  %s\n' "${forks[@]}" >&2
  exit 0
fi

cat >&2 <<MSG
BLOCKED: a reviewer memory tree exists outside the repository root:
$(printf '  %s\n' "${forks[@]}")

Project-local reviewers declare \`memory: project\` or \`memory: local\`; the only
legitimate homes are $PROJECT_DIR/.claude/agent-memory/<reviewer>/ and
$PROJECT_DIR/.claude/agent-memory-local/<reviewer>/ (pr-review.md § Reviewer
precedent memory). Before stopping: move each <reviewer>/ directory's files
into the root tree, append their pointer lines to the root MEMORY.md for that
reviewer, delete the forked tree, and say so in the hand-off.

If the path above belongs to tooling rather than to a dispatched agent — a harness
staging copy, a container's workspace, a vendored checkout — it is not a fork and
nothing should be moved or deleted. Add it to .gitignore, anchored, and this scan
prunes it from then on (the review action's \`.claude-pr/\` staging copy is the
exercised case and is pruned unconditionally).
MSG
exit 2
```

- [ ] **Step 2: Payload checks against throwaway trees**

Run:
```bash
r=$(mktemp -d); git -c init.defaultBranch=main init -q "$r"; printf '/pkg/*/build/\n' > "$r/.gitignore"; mkdir -p "$r/pkg/a/.claude/agent-memory/x" "$r/pkg/b/build/.claude/agent-memory/y" "$r/.claude-pr/.claude/agent-memory/z"
printf '{"stop_hook_active":false}' | CLAUDE_PROJECT_DIR="$r" .claude/hooks/detect-forked-agent-memory.sh >/dev/null 2>/tmp/e; echo "exit=$?"; grep -c 'pkg/a' /tmp/e; grep -c 'build\|claude-pr' /tmp/e
rm -rf "$r/pkg/a"; printf '{"stop_hook_active":false}' | CLAUDE_PROJECT_DIR="$r" .claude/hooks/detect-forked-agent-memory.sh >/dev/null 2>&1; echo "clean-exit=$?"; rm -rf "$r"
```
Expected: `exit=2`, `1` (pkg/a reported), `0` (the ignored build tree and `.claude-pr` are pruned), then `clean-exit=0`. Also `bash -n` clean and `bash .claude/workflows/tests/hook-contract-fixture.sh` → ok.

- [ ] **Step 3: § .gitignore anchoring names `/.claude-pr/`**

Replace the bullet at line 271 with:
```markdown
- **Harness transients are ignored by anchored path** — the agent's scratch and memory-local trees (`/.claude/agent-memory-local/`, the session scratchpad if it is ever placed in-tree) and a hosted review action's staging copy of the branch's tooling (`/.claude-pr/` — it carries a copy of the committed memory tree, which the Stop-tier fork detector prunes unconditionally and the ignore-driven prune covers once the entry exists; #58, 2026-09-07 comment), never by a bare name that would also hide a real directory.
```

- [ ] **Step 4: Run the runner; commit**

Run: `bash .claude/workflows/tests/run-verification-block.sh | tail -3` → both sentinels.

```bash
git add .claude/hooks/detect-forked-agent-memory.sh .claude/rules/cbk-conventions-reference.md
git commit -m "fix(hooks): fork detector reads the project's ignore rules, keeps find's stderr, prunes the review action's staging copy, and names a tooling path as not-a-fork (#58 items 1, 2; the 2026-09-07 comment)

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 7: `agent-cost.py` — cache reads priced per tier; the fixture's missing rows (H5; D36)

**Files:**
- Modify: `.claude/workflows/agent-cost.py` — docstring line 14, `PRICE` block (line 26–31), the cost line (91)
- Modify: `.claude/workflows/tests/agent-cost-fixture.sh`

- [ ] **Step 1: Per-tier cache-read multipliers**

After the `PRICE = { … }` block add:
```python
CACHE_READ = {'fable': 0.025}  # cache hits and refreshes on the top tier are 0.025x base input
CACHE_READ_DEFAULT = 0.10      # every other tier: the standard 0.1x
# platform.claude.com/docs/en/build-with-claude/prompt-caching § Pricing, read 2026-09-07 (#58 item 6).
```
Replace line 91:
```python
        cost += (t['inp'] * pi + t['cw'] * pi * 1.25 + t['cr'] * pi * 0.10 + t['out'] * po) / 1e6
```
with:
```python
        cost += (t['inp'] * pi + t['cw'] * pi * 1.25 + t['cr'] * pi * CACHE_READ.get(k, CACHE_READ_DEFAULT) + t['out'] * po) / 1e6
```
In the docstring replace `and cache reads at 0.1x input.` with `and cache reads at 0.1x input except on the top tier, where cache hits and refreshes are 0.025x (CACHE_READ).`

- [ ] **Step 2: Fixture rows — a top-tier transcript, a zero-parseable-lines transcript, `minutes` null, the `--json` missing argument**

After the `agent-ddd.jsonl` block add:
```bash
printf '%s\n' \
  '{"type":"user","timestamp":"2026-09-06T00:00:00Z","message":{"content":"arm five prompt"}}' \
  '{"type":"assistant","timestamp":"2026-09-06T00:03:00Z","message":{"model":"claude-fable-5-1","usage":{"input_tokens":1000000,"output_tokens":0,"cache_read_input_tokens":1000000}}}' \
  > "$d/agent-eee.jsonl"
printf '%s\n' '{"type":"assistant","timestamp":"2026-09-06T00:0' > "$d/agent-fff.jsonl"
printf '%s\n' \
  '{"type":"assistant","message":{"model":"claude-haiku-4-5","usage":{"input_tokens":1000,"output_tokens":0}}}' \
  > "$d/agent-ggg.jsonl"
```
Replace the three assertions on lines 30–33 with:
```bash
grep -qE '^aaa\b.*\b14\.25\b' <<<"$out" || { echo "expected aaa at \$14.25 (1M in @ \$5 + 1M cache write @ 1.25x + 1M cache read @ 0.1x + 100k out @ \$25); got:"; echo "$out"; exit 1; }
grep -qE '^ddd\b.*claude-opus-5,claude-sonnet-5.*\b7\.00\b' <<<"$out" || { echo "expected the mixed transcript priced per model at \$7.00 with both models named; got:"; echo "$out"; exit 1; }
grep -qE '^eee\b.*\b10\.25\b' <<<"$out" || { echo "expected eee at \$10.25 (1M in @ \$10 + 1M cache read @ 0.025x on the top tier — not \$11.00 at the 0.1x default); got:"; echo "$out"; exit 1; }
grep -q 'total list-price cost: \$31.50' <<<"$out" || { echo "expected a \$31.50 total (14.25 + 7.00 + 10.25 + 0.00 haiku); got:"; echo "$out"; exit 1; }
grep -q '4 of 7 agents priced' <<<"$out" || { echo "the priced/unpriced split is not printed (aaa, ddd, eee, ggg priced; bbb, ccc, fff not)"; echo "$out"; exit 1; }
```
Amend the two `unpriced`/`unparsable` assertions to `bbb, ccc, fff` and `ccc (1), fff (1)`. Then add, before `assert_exit`:
```bash
grep -q '"agent": "ggg"' "$d/out.json" && grep -q '"minutes": null' "$d/out.json" || { echo "a transcript with fewer than two timestamps must report minutes as null, not crash or zero"; cat "$d/out.json"; exit 1; }
```
and after the existing `assert_exit` lines:
```bash
assert_exit 2 "--json without a path should exit 2" "$d" --json
```

- [ ] **Step 3: Run; commit**

Run: `bash .claude/workflows/tests/agent-cost-fixture.sh` → `agent-cost-fixture: ok`. Then the runner (its price diff reads `'fable': (10.0, 50.0)`-shaped rows only; `CACHE_READ` is not matched by `'[a-z]+': \([0-9.]+, [0-9.]+\)`? — it IS a float in braces but the regex needs two comma-separated numbers in parentheses; `{'fable': 0.025}` does not match. Confirm the diff line stays green).

```bash
git add .claude/workflows/agent-cost.py .claude/workflows/tests/agent-cost-fixture.sh
git commit -m "fix(workflows): agent-cost prices cache reads per tier (0.025x on the top tier); fixture rows for the top tier, a zero-line transcript, null minutes and --json without a path (#58 item 6, smaller item 5)

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 8: `review-sweep.js` — boundary-safe hint match, the roster read degrades on a throw, the retry reindex, the harness stops swallowing exceptions (H5; D-P-4)

**Files:**
- Modify: `.claude/workflows/review-sweep.js` lines 109, 139–141, 181–184
- Modify: `.claude/workflows/tests/review-sweep-accounting.mjs` line 38 (the stub), new scenarios after scenario 13

- [ ] **Step 1: The roster read degrades on a throw**

Change the closing of the `const roster = await agent(` call (line 109–115): after the closing `)` of `agent(...)` and before the `;`, append `.catch(() => null)` with the comment:
```js
  ).catch(() => null); // a throw (a budget ceiling — orchestration.md § Fan-out discipline) degrades exactly like a null read below; every other agent() here sits inside a parallel() thunk, which the runtime catches (#58 item 8)
```

- [ ] **Step 2: The boundary-safe match**

Replace line 141:
```js
    const matched = usable.filter((d) => files.some((f) => d.pathHints.some((h) => f.startsWith(h)))).map((d) => d.name);
```
with:
```js
    // Directory-boundary safe: `src/schema` must not claim `src/schema-extra/x` (#58 item 7). A hint
    // is a directory prefix, never a segment anchor — enumerate directories rather than reaching for
    // a regex the roster line cannot carry.
    const matched = usable.filter((d) => files.some((f) => d.pathHints.some((h) => f === h || f.startsWith(h + "/")))).map((d) => d.name);
```

- [ ] **Step 3: The retry reindex, finish-ab's idiom**

Replace lines 181–184:
```js
const failedFirst = dimensions.filter((_d, i) => firstPass[i] === null);
if (failedFirst.length) log(`review-sweep: ${failedFirst.length} find agent(s) returned nothing — retrying once at effort ${RETRY_EFFORT}: ${failedFirst.map((d) => d.key).join(", ")}`);
const retried = await parallel(failedFirst.map((dim) => () => findOnce(dim, RETRY_EFFORT, true)));
const results = dimensions.map((dim, i) => firstPass[i] ?? retried[failedFirst.indexOf(dim)] ?? null);
```
with:
```js
const failedIdx = dimensions.map((_d, i) => i).filter((i) => firstPass[i] === null);
if (failedIdx.length) log(`review-sweep: ${failedIdx.length} find agent(s) returned nothing — retrying once at effort ${RETRY_EFFORT}: ${failedIdx.map((i) => dimensions[i].key).join(", ")}`);
const retried = await parallel(failedIdx.map((i) => () => findOnce(dimensions[i], RETRY_EFFORT, true)));
const results = firstPass.slice();
failedIdx.forEach((i, k) => { results[i] = retried[k] ?? null; }); // the index-list reindex, shared with finish-ab.js (#58 smaller item 6)
```

- [ ] **Step 4: The harness stub propagates its own exceptions**

Replace line 38 of `review-sweep-accounting.mjs`:
```js
  const parallel = async (thunks) => Promise.all(thunks.map(async (t) => { try { return await t(); } catch { return null; } }));
```
with:
```js
  // A thunk that THROWS is a bug in this harness's own mock and must fail the test; the runtime
  // resolves a failed agent to null without throwing, so null is modelled by returning null (#58 item 10).
  const parallel = async (thunks) => Promise.all(thunks.map((t) => t()));
```

- [ ] **Step 5: Three new scenarios**

Append after scenario 13 (before the final summary line):
```js
// 14 — a hint matches on a directory boundary, never on a common prefix.
{
  const { out } = await scenario("boundary-safe hint", {
    args: { files: ["src/schema-extra/a.ts"] },
    roster: rosterOK, findings: {}, verdict: () => null,
  });
  assert.ok(!out.reviewers.includes("schema-reviewer"), "src/schema must not claim src/schema-extra/");
  const { out: exact } = await scenario("boundary-safe hint (exact)", { args: { files: ["src/schema"] }, roster: rosterOK, findings: {}, verdict: () => null });
  assert.ok(exact.reviewers.includes("schema-reviewer"), "a changed path equal to the hint matches");
  n += 2;
}

// 15 — a roster read that THROWS degrades like a null read: gate line, dropped coverage, no crash.
{
  const logs = [];
  const agent = async (_prompt, opts = {}) => { if ((opts.label ?? "").startsWith("roster:")) throw new Error("budget ceiling"); return opts.label?.startsWith("verify:") ? null : { findings: [] }; };
  const parallel = async (thunks) => Promise.all(thunks.map((t) => t()));
  const out = await run({ files: ["a"] }, agent, parallel, (m) => logs.push(m), () => {});
  assert.deepEqual(out.reviewers, []);
  assert.ok(out.droppedCoverage.some((d) => d.includes("roster read failed")), "a throwing roster read is dropped coverage, not an aborted run");
  assert.ok(typeof out.gateLine === "string" && out.gateLine.length > 0, "the run still returns its gate line");
  n++;
}

// 16 — the least-loaded-owner bound with THREE converging reporters charges the idle one.
{
  const three = { crossCutting: ["adr-conformance-reviewer", "cascade-rule-reviewer"], domain: [], note: "" };
  const { out } = await scenario("three converging reporters", {
    args: { files: ["a"], maxPerDimension: 1, maxVerify: 8 }, roster: three,
    findings: {
      "code-review": { findings: [F("a", 1, "cr only", "high"), F("a", 5, "shared", "low")] },
      "adr-conformance-reviewer": { findings: [F("a", 2, "adr only", "high"), F("a", 5, "shared", "low")] },
      "cascade-rule-reviewer": { findings: [F("a", 5, "shared", "low")] },
    },
    verdict: real,
  });
  assert.ok(out.confirmed.some((f) => f.line === 5), "the three-way shared finding is charged to the reporter with no other finding and verified");
  assert.ok(out.confirmed.some((f) => f.title === "cr only") && out.confirmed.some((f) => f.title === "adr only"), "neither loaded reporter loses its own unique finding to the shared one");
  n++;
}
```
(`run` is the loader's function already in scope at the top of the file.)

- [ ] **Step 6: Run; commit**

Run: `node .claude/workflows/tests/review-sweep-accounting.mjs && bash .claude/workflows/tests/run-verification-block.sh | tail -3`
Expected: the harness prints its scenario count with no assertion error; both sentinels.

```bash
git add .claude/workflows/review-sweep.js .claude/workflows/tests/review-sweep-accounting.mjs
git commit -m "fix(workflows): review-sweep matches hints on a directory boundary, degrades on a throwing roster read, reindexes retries by index; the harness stops swallowing its own exceptions (#58 items 7, 8, 10)

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 9: `finish-ab.js` — distinct arm labels, guarded `hallucinations`, effort read once; harness scenarios (H5)

**Files:**
- Modify: `.claude/workflows/finish-ab/finish-ab.js` lines 36–38, 132, 158–161
- Modify: `.claude/workflows/tests/finish-ab-shape.mjs` line 19 and new scenarios

- [ ] **Step 1: Arm labels distinct, beside `anon`**

After line 38 (`if (new Set(ids).size !== ids.length) throw …`) add:
```js
const armLabels = args.arms.map((c) => c.arm)
if (new Set(armLabels).size !== armLabels.length) throw new Error(`finish-ab: arm labels must be distinct — otherFile() picks the OTHER arm by label (got ${armLabels.join(", ")})`)
```

- [ ] **Step 2: `hallucinations ?? []` at both sites; effort once**

Replace lines 159 and 161:
```js
  flags[id] = jok.reduce((n, j) => n + j.hallucinations.filter((h) => h.arm === id).length, 0)
…
const unattributed = jok.reduce((n, j) => n + j.hallucinations.filter((h) => !ids.includes(h.arm)).length, 0)
```
with:
```js
  flags[id] = jok.reduce((n, j) => n + (j.hallucinations ?? []).filter((h) => h.arm === id).length, 0) // a well-formed ranking with no hallucinations field counts zero, never crashes (#58 item 9)
…
const unattributed = jok.reduce((n, j) => n + (j.hallucinations ?? []).filter((h) => !ids.includes(h.arm)).length, 0)
```
Replace line 132's `judgeOpts`:
```js
const judgeOpts = (j, i, retry) => { const effort = j.effort ?? "high"; return { label: `judge:${i + 1}@${effort}${retry ? ":retry" : ""}`, phase: "Judge", model: MODEL, effort, agentType: "general-purpose", schema: JUDGE_SCHEMA } }
```

- [ ] **Step 3: The harness stub propagates; three scenarios**

Replace line 19 of `finish-ab-shape.mjs`:
```js
  const parallel = async (thunks) => Promise.all(thunks.map((t) => t().catch(() => null)));
```
with:
```js
  const parallel = async (thunks) => Promise.all(thunks.map((t) => t())); // a throwing mock is a harness bug, not a "null agent" (#58 item 10)
```
Append before the harness's final failure summary:
```js
// N — duplicate arm labels are refused before any dispatch.
{
  let err = null; let dispatched = 0;
  const count = (opts) => { dispatched += 1; return armOk(opts); };
  try { await run({ ...base, arms: [arms[0], { ...arms[1], arm: "A" }] }, { armResult: count, judgeResult: judgeOk }); } catch (e) { err = e; }
  check(err && /arm labels must be distinct/.test(err.message), "duplicate arm labels throw");
  check(dispatched === 0, "and nothing was dispatched first");
}

// N+1 — a well-formed judge with no `hallucinations` field counts zero flags instead of crashing.
{
  const noHall = (opts) => { const j = judgeOk(opts); delete j.hallucinations; return j; };
  const { result } = await run(base, { armResult: armOk, judgeResult: noHall });
  check(result.flags.P === 0 && result.flags.Q === 0, `missing hallucinations counts zero (got ${JSON.stringify(result.flags)})`);
}

// N+2 — a contradicted claim naming no arm id is counted as unattributed, for neither arm.
{
  const stray = (opts) => { const j = judgeOk(opts); j.hallucinations = [{ arm: "Z", claim_verbatim: "x", contradicting_source: "y" }]; return j; };
  const { result, logs } = await run(base, { armResult: armOk, judgeResult: stray });
  check(result.unattributedFlags === 4, `four judges × one stray entry = 4 unattributed (got ${result.unattributedFlags})`);
  check(result.flags.P === 0 && result.flags.Q === 0, "stray entries count for neither arm");
  check(logs.some((l) => /name no arm id/.test(l)), "the stray entries are logged");
}
```
(Number the comments to follow the file's last scenario.)

- [ ] **Step 4: Run; commit**

Run: `node .claude/workflows/tests/finish-ab-shape.mjs; echo "exit=$?"` → `exit=0`; then the runner → both sentinels.

```bash
git add .claude/workflows/finish-ab/finish-ab.js .claude/workflows/tests/finish-ab-shape.mjs
git commit -m "fix(workflows): finish-ab refuses duplicate arm labels before dispatch, guards hallucinations at both sites, reads effort once; harness scenarios for unattributed flags (#58 item 9, smaller items 5–6)

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 10: `/finish` Step 1 admits the meta-issue title (H6; D35)

**Files:**
- Modify: `.claude/commands/finish.md` line 14 and line 21
- Modify: `.claude/skills/rough-in/references/finish-command.md` — the same two lines below the marker (line 83)

- [ ] **Step 1: The two sentences, in both files**

Line 14: replace `An intake-lane issue (\`[<slug>:bug]\`, \`[<slug>:enh]\`) has no frame; its provenance comment stands in.` with `An intake-lane issue (\`[<slug>:bug]\`, \`[<slug>:enh]\`) or a directly roughed-in meta (\`[<slug>:meta]\`) has no frame; its provenance comment stands in.`

Line 21: replace `The title is \`[<slug>:F<#>:R<#>] …\`, \`[<slug>:bug] …\` or \`[<slug>:enh] …\` with \`<slug>\` a workstream locked in \`docs/cbk/blueprint.md\` § Workstreams;` with `The title is \`[<slug>:F<#>:R<#>] …\`, \`[<slug>:bug] …\`, \`[<slug>:enh] …\` or \`[<slug>:meta] …\` with \`<slug>\` a workstream locked in \`docs/cbk/blueprint.md\` § Workstreams or the cascade/tooling lane's tag (\`cbk-conventions.md\` § Contribution intake — a meta reaches this executor roughed-in directly or through its \`[<slug>:<meta-tag>:R<#>]\` children; the \`cascade-depth:framed\` label the meta template applies at framing is the pre-rough-in state, not this check's — #58, smaller item 1);`

Apply with one `sed -i` expression on both files, then verify:
`diff <(awk '/^--- BEGIN TEMPLATE ---/{flag=1; next} flag' .claude/skills/rough-in/references/finish-command.md) .claude/commands/finish.md && echo byte-parallel`

- [ ] **Step 2: Run the runner (it diffs the pair); commit**

```bash
git add .claude/commands/finish.md .claude/skills/rough-in/references/finish-command.md
git commit -m "fix(finish): Step 1 admits the [<slug>:meta] title the kit's own templates emit (#58 smaller item 1)

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 11: ADR records — `adr-new` reads the index's form; the count rot; `Promotes:` defined; the reviewer cites by the register's own id form (H6; D39)

**Files:**
- Modify: `.claude/skills/adr-new/SKILL.md` — step 3 first bullet (line 51), the § Refines vs Supersedes vs Extends opening sentence (line 73), a `Promotes:` bullet after the `Refines:` bullet
- Modify: `.claude/skills/scaffold/references/adr-starters/README.md` line 27 **and** `docs/adr/README.md` line 27 (identical)
- Modify: `.claude/agents/adr-conformance-reviewer.md` line 55

- [ ] **Step 1: `adr-new` step 3**

Replace the bullet `- Add the row to the index table in number order; the status cell carries the grain and the parent inline (\`Accepted · Refines ADR-0007 (D2)\`, \`Accepted · Extends ADR-0003 (D1)\`).` with:
```markdown
   - Add the row to the index table in number order — **in the form the existing rows already use.** Read them first: which cell carries the relation grain and the parent (the kit's starter index puts it in the Status cell — `Accepted · Refines ADR-0007 (D2)` — while an index that predates the starter may carry it as a Title-cell parenthetical, with another separator, or in prose), and write the new row exactly that way. The separator is the index's convention, not this skill's; two real indexes already contradicted the pinned form two different ways (#58, 2026-09-07 comment).
```

- [ ] **Step 2: The count and `Promotes:`**

Replace `A new ADR connects to an existing one through one of two relationships. Both are recorded as header fields and both preserve the parent's immutability — neither ever edits the parent file.` with `A new ADR connects to an existing one through one of the relationships below (\`Supersedes:\`, \`Refines:\`, \`Extends:\`, and the clause-scoped form of the first); a \`Promotes:\` slot connects to a frozen corpus, not to an ADR. All are header fields and all preserve the parent's immutability — none ever edits the parent file.`

After the `- **\`Refines: ADR-NNNN (Dn, …)\`**` bullet add:
```markdown
- **`Promotes: <corpus path § heading>`** — the decision is lifted from a frozen pre-cascade corpus (consultation's frozen-corpus ingestion; `cbk-conventions.md` § Multi-surface facts names the corpus + errata pair). The corpus entry stays as written and the ADR becomes the decision's record home; the slot is the back-pointer. Not a relation to another ADR, so it carries no grain.
```

- [ ] **Step 3: The starter index and the kit's own index, identically**

Append to line 27 of both files: ` A project whose index predates this starter keeps its own form — the cell and separator its rows already use — and \`adr-new\` reads the rows before writing one.`

Check: `diff docs/adr/README.md .claude/skills/scaffold/references/adr-starters/README.md && echo identical`.

- [ ] **Step 4: The reviewer's id-form assumption**

Line 55 of `adr-conformance-reviewer.md`: replace `is cited by its \`C-\` number, never restated as a finding` with `is cited by the register's own id form (the starter numbers entries \`C-NNN\`; a register that predates it may number them in prose under per-ADR sections), never restated as a finding`.

- [ ] **Step 5: Run the runner; commit**

The block greps `Extends:` in these files and diffs the starters; `wc -l .claude/skills/adr-new/SKILL.md` stays under 500.

```bash
git add .claude/skills/adr-new/SKILL.md .claude/skills/scaffold/references/adr-starters/README.md docs/adr/README.md .claude/agents/adr-conformance-reviewer.md
git commit -m "fix(adr): adr-new writes the index row in the index's own form; the relation list states no count and defines Promotes:; the reviewer cites corrections by the register's id form (#58, 2026-09-07 comment; second application items 1, 3)

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 12: The small rot — the duplicated citation, the marker spelling, the pre-flight row, the stamped-state callouts, the `cwd` disagreement, the lock-file arms (H6)

**Files:**
- Modify: `.claude/skills/framing/references/procedure.md:107`
- Modify: `.claude/skills/rough-in/references/templates/rough-in-spec-template.md:256`
- Modify: `.claude/rules/cbk-conventions.md:234` (delete the row)
- Modify: `.claude/rules/logging.md:8`, `.claude/rules/testing.md:11`, `.claude/skills/scaffold/references/bootstrap_checklist_template.md:90-91`
- Modify: `.claude/hooks/require-repo-root-for-agents.sh` Timing paragraph (lines 25–33)
- Modify: `.claude/hooks/protect-lock-files.sh` lines 57–76

- [ ] **Step 1: S2 and S4**

`sed -i "s/See rough-in's the rough-in skill's/See the rough-in skill's/" .claude/skills/framing/references/procedure.md`
`sed -i 's|^MEASUREMENT / SPIKE VARIANT|MEASUREMENT/SPIKE VARIANT|' .claude/skills/rough-in/references/templates/rough-in-spec-template.md`
Check: `grep -c "rough-in's the rough-in" .claude/skills/framing/references/procedure.md` → 0; `grep -c 'MEASUREMENT / SPIKE' .claude/skills/rough-in/references/templates/rough-in-spec-template.md` → 0.

- [ ] **Step 2: The pre-flight Quick-reference row**

Delete line 234 of `cbk-conventions.md` (`| Adding a \`## Pre-flight checks\` row to a frame | Append-only edit to the frame's \`## Pre-flight checks\` table |`). Framing writes the table at frame creation and rough-in reads it; no skill appends to it, and the Mutation-discipline row names `## Rough-in events` as the only append-only table (#58, second application, item 4).

- [ ] **Step 3: Callouts true before and after stamping**

`logging.md` line 8 → 
```markdown
> **Path-scoped.** The `paths:` block above makes this rule load only when a matching file is read, not every session (`https://code.claude.com/docs/en/memory`). The globs are stamped at install — one entry per source extension (e.g. `"**/*.py"`, `"**/*.ts"`); until stamped they are bracketed placeholders that match nothing, which the conventions' verification block flags. This callout describes the mechanism and stays as it reads after stamping.
```
`testing.md` line 11 →
```markdown
> **Path-scoped.** This rule loads only when a test file or a test directory is read (`https://code.claude.com/docs/en/memory`). The globs are stamped at install — the project's test-file extension(s), and only the directory patterns it uses; until stamped they are placeholders the conventions' verification block flags. A stack whose unit tests live inline in source files (a `#[cfg(test)]` module) has no test-file extension: stamp the test directories alone and accept that inline modules reach this rule only through their directory. Anything a test-writing session needs *before* it opens a test file — the project's test-side trace-tag form, for one — is restated here rather than left in a rule this session never loads. This callout stays as it reads after stamping.
```
`bootstrap_checklist_template.md` lines 90–91: replace `\`paths:\` set to \`**/*.<ext>\`` with `\`paths:\` set to the project's source globs (the callout stays; it describes the mechanism)` and `\`paths:\` set to \`**/*_test.<ext>\`, \`**/test/**\`` with `\`paths:\` set to the project's test globs and directories (inline-test stacks: directories alone)`.

- [ ] **Step 4: The `cwd` disagreement in the launch-root guard's header**

Replace the Timing paragraph's last two sentences (`The confirmed deny is a session launched from a subdirectory … relaunch the session from the root.`) with:
```
#           The confirmed deny is a session launched from a subdirectory (the
#           verification block's payload dry-run); the remedy there is to relaunch
#           the session from the root. The hooks reference states the OPPOSITE of
#           the observation above — "cwd follows Claude: … the new directory after
#           Claude runs cd" (https://code.claude.com/docs/en/hooks § Reference
#           scripts by path, read 2026-09-07). The two disagree; this guard judges
#           whichever cwd the payload carries and is correct under either reading.
#           RE-VERIFY TRIGGER: a dispatch made after `cd <subdir>` that is denied
#           means the page's reading now holds — update this paragraph (#58, S3).
```

- [ ] **Step 5: Lock-file arms**

In `protect-lock-files.sh` change the case line to `uv.lock|pnpm-lock.yaml|package-lock.json|yarn.lock|Cargo.lock|Gemfile.lock|poetry.lock|composer.lock|mix.lock|pubspec.lock)` and add `  - pubspec.lock         →  dart pub get  /  flutter pub get  (pub upgrade to move a resolution)` after the `Cargo.lock` remediation line. After that arm's `;;` add a second arm:
```bash
  *.lock)
    cat >&2 <<EOF
BLOCKED: $rel looks like a package-manager lock file (the *.lock fallback arm — the
named ecosystems are listed above this arm in the hook; the next ecosystem is covered
by construction rather than by an edit, #58 item 3).
Run the package manager that owns it instead of editing it by hand. If this file is
NOT a lock file, add its name to the hook's exemption comment and say so in the PR.
EOF
    exit 2
    ;;
```
`bash -n` the hook; run `bash .claude/workflows/tests/hook-contract-fixture.sh`.

- [ ] **Step 6: Run the runner; commit**

```bash
git add .claude/skills/framing/references/procedure.md .claude/skills/rough-in/references/templates/rough-in-spec-template.md .claude/rules/cbk-conventions.md .claude/rules/logging.md .claude/rules/testing.md .claude/skills/scaffold/references/bootstrap_checklist_template.md .claude/hooks/require-repo-root-for-agents.sh .claude/hooks/protect-lock-files.sh
git commit -m "fix(kit): the duplicated citation, one marker spelling, the pre-flight row, stamped-state callouts, the cwd disagreement named, pubspec.lock and a *.lock fallback arm (#58 item 3, smaller items 2–4; second application items 2, 4)

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 13: Record the install sha; sync by merge (H6; D40)

**Files:**
- Modify: `.claude/skills/scaffold/references/scaffold_output_template.md` — both Cascade metadata tables (lines 19–23 and 124–128)
- Modify: `.claude/rules/cbk-conventions-reference.md` — new `## Syncing the kit` section before `## Verification`
- Modify: `.claude/rules/cbk-conventions.md` — a one-line pointer heading `## Syncing the kit` before `## Verification` (the contract/reference shape: every reference section has a pointer in the contract)

- [ ] **Step 1: The Kit commit row**

After `| **Repo** | <URL> |` add `| **Kit commit** | <context-builder-kit sha this \`.claude/\` was installed from — the base of the next sync> |`; after the example's `| **Repo** | https://github.com/jforth/notes-cli |` add `| **Kit commit** | e92e9c4 |`.

- [ ] **Step 2: § Syncing the kit (reference half)**

Insert before `## Verification` in the reference:
```markdown
## Syncing the kit

A target that recorded its **Kit commit** (scaffold's Cascade metadata table) syncs to a newer kit as a three-way merge, not a hand-reconciliation: for every file, `git merge-file <ours> <kit@install-sha> <kit@target-sha>` — base is the kit at the install sha, ours the project's copy, theirs the new kit. On a real application 47 of 48 files the project had customized auto-resolved (pure kit drift, derivable from the base); the conflict hunks were the two big rule files, where the kit's generalized text and the project's filled text both had to survive (#58, second application, item 10). The file-by-file table — classify each file as copy / add / merge / keep, then note what each merge must preserve — is the reusable artifact; write it before the branch. Two traps: a project sub-block re-homed into this file from a pre-split contract must split its own retired-vocabulary literals (or the block's `absent` check matches it), and byte-identity for `copy` rows is asserted against the target sha, so a fix a project needs ahead of the kit is filed upstream and carried as a named exception, never silently patched into a copy. Record the new sha in the table when the sync merges.
```
And in the contract (`cbk-conventions.md`), before `## Verification`:
```markdown
## Syncing the kit

Three-way `git merge-file` against the recorded **Kit commit**; the file-by-file table first. → `cbk-conventions-reference.md` § Syncing the kit.
```

- [ ] **Step 3: Run the runner; commit**

```bash
git add .claude/skills/scaffold/references/scaffold_output_template.md .claude/rules/cbk-conventions-reference.md .claude/rules/cbk-conventions.md
git commit -m "docs(conventions): record the install sha in the Cascade metadata table; § Syncing the kit — three-way merge-file, the file-by-file table first (#58, second application, item 10)

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 14: The review-workflow templates and the knowledge-backend matcher (H7; D37, D38)

**Files:**
- Modify: `.claude/skills/blueprint/references/templates/claude-review.yml` — lines 154–155 (`additional_permissions`), after the checkout step (line 109–112), the prompt's every-file paragraph (line 163)
- Modify: `.claude/skills/blueprint/references/templates/claude.yml` — lines 38–43 and 80–81
- Modify: `.claude/settings.json` — the knowledge-backend matcher (line 33 at `e92e9c4`; find it by `grep -n 'notion__notion-' .claude/settings.json`)
- Modify: `.claude/rules/knowledge-backend.md` line 230

- [ ] **Step 1: `checks: read` in `additional_permissions` (claude-review.yml) and in both places (claude.yml)**

claude-review.yml: replace
```yaml
          additional_permissions: |
            actions: read
```
with
```yaml
          # Named twice on purpose — here and in the job's `permissions:` block. The job block scopes
          # the workflow's own token; this input is what the action requests when it exchanges its OIDC
          # token for an app token (`parseAdditionalPermissions` in anthropics/claude-code-action
          # `src/github/token.ts`, read 2026-09-21). Without `checks: read` here, `gh pr checks` fails
          # `Resource not accessible by integration` and the review takes the PR body's claim of a green
          # gate at face value (observed 2026-09-18). `statuses: read` only when the rollup carries commit
          # statuses (a non-Actions CI, a deploy bot) — measure with `gh api repos/{owner}/{repo}/commits/<sha>/status`.
          additional_permissions: |
            actions: read
            checks: read
```
claude.yml: add `      checks: read           # `gh pr checks` is allowlisted below; the scope must match` after `      actions: read` in the job `permissions:` block, and the same `checks: read` line under `additional_permissions:` with a one-line `# named twice — see claude-review.yml` comment.

- [ ] **Step 2: The base ref exists in the checkout**

After the `Checkout PR HEAD` step in claude-review.yml add:
```yaml
      - name: Fetch the base ref (so `git diff origin/<base>...HEAD` resolves)
        # `ref: head.sha` above checks out only the PR head; without this the reviewer's first diff
        # against the base fails ("no merge base") and it spends turns retrying fetches its allowlist
        # refuses (#58 addendum, item 12). The ref name is read from an env var, never interpolated.
        env:
          BASE_REF: ${{ github.event.pull_request.base.ref }}
        run: git fetch --no-tags origin "+refs/heads/${BASE_REF}:refs/remotes/origin/${BASE_REF}"
```

- [ ] **Step 3: The prompt degrades explicitly on an oversized diff**

After the prompt line `and walk each one; read the surrounding file, not only the hunk, when context matters.` add:
```
            If the diff exceeds [N] changed files (a sync of vendored or kit-copied trees, a generated
            bulk), you cannot walk every file inside the turn cap: review the authored set the PR body
            names and every file that is not a byte-identical copy of its source, post the summary FIRST
            with the list of files you did not read, and say so in the verdict line. A capped run that
            posted nothing is the failure this clause prevents (#58 addendum, item 11).
```
(`[N]` is a project fill — the bracketed form the template already uses elsewhere; suggest 60, the turn cap.)

- [ ] **Step 4: The matcher, widened and dated**

In `.claude/settings.json` replace `"matcher": "mcp__(plugin_Notion_)?notion__notion-(create|update|move|duplicate|convert|delete).*"` with `"matcher": "mcp__(plugin_Notion_)?notion__notion-(create|update|move|duplicate|convert|delete|upload|spawn|send|stop).*"`, and in `_comment_hooks`'s ASK-GATE sentence extend `(Notion matcher shipped as the v1 reference — adjust the regex to your MCP's tool names;` to `(Notion matcher shipped as the v1 reference, dated 2026-09-21 — the live tool set added upload-skill (replaces a page's body), spawn-session / send-message-to-session (drive an agent that writes) and stop-session; a matcher is a dated observation of the vendor's tool names, so re-verify it when the MCP's tool list changes; adjust the regex to your MCP's tool names;`.

In `knowledge-backend.md` line 230 replace `(registered in \`settings.json\` against the knowledge-backend MCP's write-verb tool names — Notion's as the v1 reference)` with `(registered in \`settings.json\` against the knowledge-backend MCP's mutating tool names — Notion's \`create|update|move|duplicate|convert|delete|upload|spawn|send|stop\` as the v1 reference, dated 2026-09-21; the matcher is a dated observation, re-verified when the MCP's tool list changes)`.

- [ ] **Step 5: Run; commit**

Run: `python3 -c "import yaml,sys; [yaml.safe_load(open(f)) for f in sys.argv[1:]]" .claude/skills/blueprint/references/templates/claude-review.yml .claude/skills/blueprint/references/templates/claude.yml 2>/dev/null || echo "(PyYAML absent — the templates carry bracketed placeholders, which is expected to fail strict parsing; check indentation by eye)"; jq . .claude/settings.json >/dev/null && bash .claude/workflows/tests/run-verification-block.sh | tail -3`

```bash
git add .claude/skills/blueprint/references/templates/claude-review.yml .claude/skills/blueprint/references/templates/claude.yml .claude/settings.json .claude/rules/knowledge-backend.md
git commit -m "fix(templates): checks: read named twice in both review workflows, the base ref fetched, the prompt degrades explicitly on an oversized diff; the knowledge-backend matcher widened to the live tool set (#58 addendum items 11–12)

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 15: The always-loaded figure, the final run, the PR

**Files:**
- Modify: `README.md` § Customization item 4 — one sentence

- [ ] **Step 1: The figure**

Append to item 4: ` The always-loaded rule set at the kit's current sha totals the figure the verification block prints (\`always-loaded total: … bytes\`; 130,405 at harvest 4) — the number a fresh target starts from before path-scoping its own rules.`

- [ ] **Step 2: Everything green**

Run: `bash .claude/workflows/tests/run-verification-block.sh | tail -6 && for h in .claude/hooks/*.sh; do bash -n "$h"; done && node .claude/workflows/tests/load-workflow-shape.mjs && node .claude/workflows/tests/review-sweep-accounting.mjs && node .claude/workflows/tests/finish-ab-shape.mjs && bash .claude/workflows/tests/agent-cost-fixture.sh && bash .claude/workflows/tests/hook-contract-fixture.sh && echo ALL-GREEN`
Expected: `ALL-GREEN`, `always-loaded total:` printed (record it), no `_example_` key in settings, the executor pair byte-parallel.

Sanitization: `grep -rn -i 'crease\|CRE-[0-9]\|echosphere\|you-are-hear\|yah_\|ECH-[0-9]' .claude/ docs/adr/ README.md` → only the `#58`-adjacent mentions in the spec/plan (under `docs/superpowers/`) and the two public run names inside `.claude/` where a sentence already cites #58 with them (none expected; if any, rewrite to "a real application").

- [ ] **Step 3: Commit, push, one review sweep, the PR**

```bash
git add README.md
git commit -m "docs(readme): the always-loaded figure a fresh target starts from

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
git push -u origin feat/harvest-4-applied-defects
```
Run one dogfooded review sweep over `git diff main...HEAD` (the kit's `review-sweep.js` with `{base: "main", files: [...]}`), triage per `pr-review.md`, apply the Apply-class findings as their own commits, then open the draft PR with `Closes #58` and `Closes #33` in the body, a `## Review gate` block (the three lines), a `## Triage` block, and a `## Verification` list carrying the before/after always-loaded totals and the mutation results from Tasks 1, 2 and 5.

---

## Self-review (run before handing off)

1. **Spec coverage.** H1 → Task 2. H2 → Tasks 3, 4, 5. H3 → Task 6. H4 → Task 1. H5 → Tasks 7, 8, 9. H6 → Tasks 10, 11, 12, 13. H7 → Task 14. § Sequencing → the task order. § Verification 1–7 → Task 15 Step 2 plus the per-task runner steps. Non-goals untouched.
2. **Placeholder scan.** The only bracketed token intentionally left is `[N]` inside a blueprint template that already uses that form for project fills.
3. **Name consistency.** `run-verification-block.sh` (Tasks 1, every test step, CI), `hook-contract-fixture.sh` (Tasks 3, 5, 12, 15), `ADVISORY_WIRED` (Task 1 only), `CACHE_READ` / `CACHE_READ_DEFAULT` (Task 7), `failedIdx` (Task 8), `armLabels` (Task 9).
