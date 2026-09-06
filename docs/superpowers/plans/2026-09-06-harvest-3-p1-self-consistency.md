# Harvest 3 · P1 — Self-consistency and the instruction-budget split — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the kit stop being wrong about itself and the platform (issues #13 #14 #15 #16 #30 #40 #45), then route its instruction budget by shipping the three biggest rules as contract + path-scoped reference pairs (#53), with an audited hook registry, on one branch as one draft PR.

**Architecture:** This is an editorial repo — every change is markdown, YAML frontmatter, a bash verification block, or a hook script. The "test suite" is the verification block in `cbk-conventions.md § Verification` (rewritten in Task 2 into two labelled sub-blocks and green on the kit's own tree), plus byte-parallel diffs between bundled copies and their originals, plus crafted-payload dry-runs of every hook. Tasks land in dependency order; the split (Task 10) goes last because it relocates the verification block and every earlier task edits the files being split.

**Tech Stack:** Markdown, YAML frontmatter (`paths:`), bash + `grep`/`diff`/`comm`/`jq`, git. No build, no test runner.

**Spec:** `docs/superpowers/specs/2026-09-06-cascade-kit-harvest-3-design.md` — clusters C1 and C2, decisions D17 and D18, and § Verification — definition of done.

## Global Constraints

- **Branch:** all work on `feat/harvest-3-p1-self-consistency` (already exists; the spec is its first commit). Never commit on `main` — the `protect-main-branch.sh` hook blocks it, and it judges a compound command on the branch at entry, so `git switch` and the commit are always separate tool calls.
- **Portability invariant:** no project-specific identifiers in `.claude/` content; placeholders stay bracketed (`<TEAM>`, `<ext>`, `<project-name>`).
- **Sanitized only:** the private reference instance is never named. The two public runs may be named only where the open issues already name them (`j4th/echosphere`, `j4th/you-are-hear`); restamps and evidence are written generically ("a second real run, 2026-08-12/13").
- **No unsourced platform claims:** every statement about Claude Code behaviour carries the page it came from (`https://code.claude.com/docs/en/memory`, `https://code.claude.com/docs/en/sub-agents`, `https://platform.claude.com/docs/en/build-with-claude/effort`).
- **Commits:** Conventional Commits, one per task, subject naming the issue(s); trailer `Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>`. No `[skip ci]` marker on any commit (the PR must merge through required checks).
- **Byte-parallel pairs:** `.claude/commands/finish.md` ⇔ the template body in `.claude/skills/rough-in/references/finish-command.md`; `docs/adr/*` ⇔ `.claude/skills/scaffold/references/adr-starters/*`. Edit both halves in the same commit.
- **The shipped review sweep is not used for this PR's review** — `review-sweep.js` still has the uncapped one-verifier-per-finding defect (#10, fixed in P2). Review is the two skills invoked directly plus the three project reviewers dispatched by hand.
- **Run the verification block after every task** once Task 2 lands: `bash -e` over the block's kit sub-block must exit 0.

---

### Task 0: Baseline — record what is red and how much is always loaded

**Files:**
- Read: `.claude/rules/cbk-conventions.md` lines 519–563 (the current `## Verification` bash block)
- Create (scratch, not committed): `/tmp/p1-baseline.txt`

**Interfaces:**
- Produces: two numbers used in the PR body — the count of red checks on kit main (expected 6) and the always-loaded byte total (expected ≈175 KB).

- [ ] **Step 1: Extract and run the current block, one check per line, recording exit codes**

```bash
cd "$(git rev-parse --show-toplevel)"
awk '/^## Verification/{p=1} p' .claude/rules/cbk-conventions.md | awk '/^```bash/{c=1;next} /^```/{c=0} c' > /tmp/p1-block.sh
n=0; red=0
while IFS= read -r line; do
  case "$line" in ''|'#'*) continue;; esac
  n=$((n+1))
  if bash -c "$line" >/dev/null 2>&1; then echo "GREEN  $line"; else red=$((red+1)); echo "RED    $line"; fi
done < /tmp/p1-block.sh | tee /tmp/p1-baseline.txt
echo "checks=$n red=$red" | tee -a /tmp/p1-baseline.txt
```

Expected: `checks=15 red=6` (the six #13 names: the layout regex, the stub-language ban, the `Deferred meta-issues` ban, the placeholder-syntax portability grep, the broad Notion URL grep, and the `@.claude/rules/cbk-conventions.md` grep).

- [ ] **Step 2: Record the always-loaded set**

```bash
total=0; for f in .claude/rules/*.md; do head -1 "$f" | grep -q '^---$' || { s=$(wc -c < "$f"); total=$((total+s)); echo "always-loaded: $f ($s bytes)"; }; done; echo "always-loaded total: $total bytes" | tee -a /tmp/p1-baseline.txt
```

Expected: nine files listed (none carries frontmatter today), total between 170,000 and 180,000 bytes.

- [ ] **Step 3: No commit.** Keep `/tmp/p1-baseline.txt` for Task 11.

---

### Task 1: `@docs/…` is an eager import — teach the mention form (#14)

**Files:**
- Modify: `.claude/skills/blueprint/references/templates/claude-md.md:6,12-16,108-113,118,125,151`
- Modify: `.claude/skills/blueprint/references/templates/architecture.md:3,29`
- Modify: `.claude/skills/blueprint/references/templates/standards.md:29`
- Modify: `.claude/skills/blueprint/references/foundation-doc-templates.md:11,66`

**Interfaces:**
- Produces: a kit with zero `@docs/` occurrences under `.claude/skills/blueprint/`, which Task 2's rewritten grep asserts.

- [ ] **Step 1: `claude-md.md` line 6 — the research bullet**

Replace:
```
- ETH Zürich: Architecture sections increase inference cost without improving task success. Remove them — use `@docs/ARCHITECTURE.md` instead.
```
with:
```
- ETH Zürich: Architecture sections increase inference cost without improving task success. Remove them — mention `docs/ARCHITECTURE.md` as a backticked path and let the agent read it when a task needs it.
```

- [ ] **Step 2: `claude-md.md` lines 12–16 — the always-loaded block**

Replace the five-line block beginning `**Always-loaded vs on-demand**:` with:
```
**Always-loaded vs on-demand — and the `@` trap**:
- CLAUDE.md = always loaded. Keep it minimal.
- `docs/ARCHITECTURE.md` = read on demand when building subsystems. Mention it as a backticked path.
- `docs/STANDARDS.md` = read on demand when doing PRs or quality checks. Same rule.
- CONTRIBUTING.md = read once by humans, not Claude — do not mention it in CLAUDE.md unless specifically relevant.
- **`@path` is an import, not a mention.** Claude Code's memory documentation (`https://code.claude.com/docs/en/memory`) states that imported files are expanded and loaded into context at launch, alongside the CLAUDE.md that references them. A `@docs/ARCHITECTURE.md` line therefore loads the whole architecture doc into every session — the opposite of on-demand. A backticked path is inert: the agent reads it only when it decides to. Write `@` only for content that genuinely belongs in every session, and budget it as always-loaded.
```

- [ ] **Step 3: `claude-md.md` lines 108–113 — the emitted References block, and a note after the code fence**

Inside the emitted template, replace:
```
## References

- @docs/ARCHITECTURE.md — load when building a specific subsystem
- @docs/STANDARDS.md — load when doing PRs or quality checks
- @docs/cbk/blueprint.md — load when context about the initiative or workstreams is needed
- @docs/cbk/problem_brief.md — load when context about the original problem is needed
```
with:
```
## References

- `docs/ARCHITECTURE.md` — read when building a specific subsystem
- `docs/STANDARDS.md` — read when doing PRs or quality checks
- `docs/cbk/blueprint.md` — read when context about the initiative or workstreams is needed
- `docs/cbk/problem_brief.md` — read when context about the original problem is needed
```
Immediately after the closing code fence of the template (before `## What does NOT belong here`), add:
```
The References block lists backticked paths. They are mentions, not imports — never write them as `@docs/…`; see the `@` trap in the always-loaded note above.
```

- [ ] **Step 4: `claude-md.md` lines 118, 125, 151**

Line 118: replace `- **Architecture descriptions** — use \`@docs/ARCHITECTURE.md\` reference instead` with `- **Architecture descriptions** — mention \`docs/ARCHITECTURE.md\` and let the agent read it instead`.
Line 125: replace `- **The full problem brief** — \`@\`-reference it when relevant, don't paste it in` with `- **The full problem brief** — mention \`docs/cbk/problem_brief.md\` when relevant, don't paste it in`.
Line 151: replace `- References section keeps only the @-references the user actually uses` with `- References section keeps only the paths the user actually reads`.

- [ ] **Step 5: `architecture.md` lines 3 and 29**

Line 3: replace `On-demand reference doc. NOT loaded every session — loaded via \`@docs/ARCHITECTURE.md\` when building specific subsystems. Can be comprehensive because it doesn't compete with every session's context.` with `On-demand reference doc. NOT loaded every session — the agent reads \`docs/ARCHITECTURE.md\` when building specific subsystems (CLAUDE.md mentions it as a backticked path, never as an \`@\` import, which would expand it into every session at launch). Can be comprehensive because it doesn't compete with every session's context.`
Line 29: replace `> On-demand reference. Load via \`@docs/ARCHITECTURE.md\` when building subsystems.` with `> On-demand reference. Read \`docs/ARCHITECTURE.md\` when building subsystems.`

- [ ] **Step 6: `standards.md` line 29**

Replace `> Load via \`@docs/STANDARDS.md\` for PRs and quality checks.` with `> Read \`docs/STANDARDS.md\` for PRs and quality checks.`

- [ ] **Step 7: `foundation-doc-templates.md` lines 11 and 66**

Line 11: replace the table row's last cell `On-demand reference; load via \`@docs/STANDARDS.md\`` with `On-demand reference; read when doing PRs or quality checks`.
Line 66: replace the whole `**Exception**:` paragraph with:
```
**Exception**: README.md's Documentation table uses markdown links because the README's audience is GitHub's rendered view and the links are the whole point of the table. That is the only exception. CLAUDE.md does **not** get one: its references to the other docs are backticked paths, never `@docs/file.md` — Claude Code treats `@path` as an import and expands the file into context at launch (`https://code.claude.com/docs/en/memory`), so an `@`-reference in an always-loaded file loads its target every session. Exceptions are about target audience, not preference — only override the inline-code default when there's a real audience reason.
```

- [ ] **Step 8: Verify**

```bash
grep -rn "@docs/\|@-ref\|\`@\`-ref\|the @-references" .claude/skills/blueprint/ ; echo "exit=$?"
```
Expected: no lines printed, `exit=1`.

- [ ] **Step 9: Commit**

```bash
git add .claude/skills/blueprint/references
git commit -m "fix(blueprint): stop teaching @docs imports as on-demand loading (#14)" -m "Every @docs/… site in the four blueprint templates becomes a backticked mention with the memory-docs rationale stated once; the foundation-doc exception paragraph that justified the import is corrected at its source." -m "Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 2: A verification suite that is green on the kit's own tree (#13, the budget check from #15, the plugin carve-out, the axis mirror, the citation pins)

**Files:**
- Modify: `.claude/rules/cbk-conventions.md` — replace the entire `## Verification` section (lines 519–563 on main) with the block below.

**Interfaces:**
- Produces: `KIT` sub-block (must exit 0 on the kit tree and on a target project's `.claude/` copy) and `PROJECT` sub-block (runs only when `docs/cbk/scaffold.md` exists). Later tasks add lines to this block; Task 10 moves it verbatim into `cbk-conventions-reference.md`.

- [ ] **Step 1: Replace the section**

Replace everything from `## Verification` up to (not including) `## References` with:

````markdown
## Verification

Two audiences share one block. **Kit-repo checks** hold on the kit's own tree and on any target project's copy of `.claude/`; **project checks** hold only in a filled-in target project and skip themselves when `docs/cbk/scaffold.md` is absent. A red check is a defect in the check until proven otherwise: a suite with a permanently red line is a suite nobody runs, which is worse than no suite. Every check says what it catches. Run the block after major edits to cascade skills, to the rules, or to a project's filled-in copy of this file.

```bash
# ═══ KIT-REPO CHECKS — must be green on the kit tree and in every target project ═══

# Section-name renames: the "Movement" vocabulary was retired; it must not reappear in skill content.
! grep -rn "Movement [0-9]\|## Movement" .claude/skills/

# Trace ID convention present in the producing templates (positive check).
grep -rn "\[F[0-9]\.AC[0-9]\]" .claude/skills/*/references/templates/

# Knowledge-backend portability: a real Notion page id must not appear in skill content
# (signup links, `my-integrations` and `<workspace>` placeholders are fine — this matches ids only).
! grep -rnE "notion\.(so|site)/[0-9a-f]{16,}" .claude/skills/

# Old "opinionated profile" vocabulary must not appear in skill content
# (the constant + two axes refactor removed the concept).
! grep -rn -i "opinionated profile\|opinionated_profile" .claude/skills/

# CLAUDE.md points at this file as a backticked mention — deliberately NOT an `@` import,
# which would expand this whole file into every session at launch (memory docs).
grep -q "cbk-conventions" CLAUDE.md

# Producer templates emit the two-axis vocabulary (positive checks).
grep -n "Planning backend" .claude/skills/scaffold/references/scaffold_output_template.md
grep -n "Knowledge backend" .claude/skills/scaffold/references/scaffold_output_template.md
grep -rn "F<#> — M<#>" .claude/skills/framing/references/templates/

# Pre-refactor vocabulary must not appear anywhere in kit content (widened beyond skills).
# The regex splits its own literal so this line never matches itself or the reference half.
! grep -rnE "github-only \| opinionate[d]|Profile.*github-onl[y]" .claude/
! grep -rn "initiative\.md" .claude/ README.md
! grep -rn -i "opinionated profile" .claude/commands/ .claude/rules/pr-review.md .claude/rules/knowledge-backend.md README.md .mcp.json.example

# Citations a skill makes to a section another template emits are pinned as pairs: the
# consumer keeps citing a heading only while the producer keeps emitting it.
grep -q "^## Rough-in events" .claude/skills/framing/references/templates/frame-output-template.md
grep -q "^## Pre-flight checks" .claude/skills/framing/references/templates/frame-output-template.md
grep -q "^## Assumptions" .claude/skills/rough-in/references/templates/rough-in-spec-template.md
# Deferred pair (known red until #37 lands): adr-new cites `docs/ARCHITECTURE.md § Configurability summary`
# and `§ Open questions`, which the architecture template does not emit. Do not add the pin before #37.

# Context budget: every `.claude/rules/*.md` WITHOUT `paths:` frontmatter loads at launch,
# every session, and every non-fork subagent loads the set again. Print the always-loaded
# set and its size so the standing cost is a number, not a discovery.
total=0; for f in .claude/rules/*.md; do head -1 "$f" | grep -q '^---$' || { s=$(wc -c < "$f"); total=$((total+s)); echo "always-loaded: $f ($s bytes)"; }; done; echo "always-loaded total: $total bytes"

# ═══ PROJECT CHECKS — a filled-in target project only; skipped on the kit tree ═══
if [ -f docs/cbk/scaffold.md ]; then

  # Layout: the project's own artifacts follow the layout it chose. Flat is the default;
  # a project that chose the nested layout inverts this line.
  ! test -d docs/cbk/framings

  # Stub language: no stubs remain in the project's own artifacts ("fall back to manual"
  # is the kit's partial-failure doctrine and is allowed in skill content).
  ! grep -rni "v1 stub\|stub status" docs/

  # Portability: the project's REAL identifiers must not have leaked into portable skill content.
  # TEMPLATE LINE — substitute the two bracketed values with the project's issue-key prefix and
  # repo name before running; as shipped it is documentation, not a runnable check. Project-scoped
  # plugin directories under .claude/skills/ may legitimately name project paths — exclude them.
  # ! grep -rn "<TEAM-PREFIX>-[0-9]\|<repo-name>" .claude/skills/ --exclude-dir=<plugin-dir>

  # Axis record mirror: scaffold.md's Cascade metadata table is canonical and
  # .cascade/backends.toml is its machine-readable mirror; every value in the toml must appear in the table.
  if [ -f .cascade/backends.toml ]; then grep -oE '"[a-z-]+"' .cascade/backends.toml | tr -d '"' | while read -r v; do grep -q "$v" docs/cbk/scaffold.md || { echo "axis mismatch: $v is in backends.toml but not scaffold.md"; exit 1; }; done; fi

  # Path-scoped rules must carry stamped globs: a bracketed placeholder matches nothing,
  # so the rule would silently never load.
  for f in $(grep -l '^paths:' .claude/rules/*.md); do awk '/^---$/{c++; next} c==1' "$f" | grep -n '<' && { echo "unfilled paths placeholder in $f"; exit 1; }; done

fi
```
````

- [ ] **Step 2: Run the kit sub-block and confirm it is green**

```bash
awk '/^## Verification/{p=1} p' .claude/rules/cbk-conventions.md | awk '/^```bash/{c=1;next} /^```/{c=0} c' > /tmp/p1-block.sh
bash -e /tmp/p1-block.sh; echo "exit=$?"
```
Expected: the positive greps print their matching lines, the always-loaded loop prints nine files and a total, and `exit=0`. If any `!` line exits non-zero, read the offending hit — the check is wrong or the tree has a real leak; fix the right one.

- [ ] **Step 3: Confirm the PROJECT sub-block is inert on the kit tree**

```bash
[ -f docs/cbk/scaffold.md ] && echo "unexpected: kit tree has docs/cbk/scaffold.md" || echo "project block skipped (correct)"
```
Expected: `project block skipped (correct)`.

- [ ] **Step 4: Commit**

```bash
git add .claude/rules/cbk-conventions.md
git commit -m "fix(conventions): a verification suite that is green on the kit's own tree (#13)" -m "Two labelled sub-blocks (kit-repo / project), a comment per check saying what it catches, six repairs: layout and stub checks rescoped to the project's artifacts, the Deferred-meta-issues ban dropped (live vocabulary), the placeholder-syntax portability grep made an explicit template line with a plugin-directory carve-out, the Notion grep narrowed to a page-id shape, and the @-import grep replaced by a mention check. Adds the always-loaded budget print, the axis-record mirror check, the unfilled-glob check, and citation pins for the template headings skills cite." -m "Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 3: Path-scope `logging.md` and `testing.md`; state the rule-loading model (#15)

**Files:**
- Modify: `.claude/rules/logging.md:1-3` (prepend frontmatter + callout)
- Modify: `.claude/rules/testing.md:1-3` (prepend frontmatter + callout)
- Modify: `.claude/rules/cbk-conventions.md` — new section `## Rule loading and the instruction budget` inserted directly after `## Surface inventory` (before `## Cascade artifact layout`)

**Interfaces:**
- Produces: the section name `§ Rule loading and the instruction budget`, which Task 10's pointer lines and Task 11's README cite verbatim.

- [ ] **Step 1: `logging.md` — frontmatter and callout**

Prepend to the file (above `# Logging Rules`):
```
---
paths:
  - "**/*.<ext>"
---

```
Then insert directly after the `# Logging Rules` heading line:
```
> **Path-scoped — stamp the glob at install.** The `paths:` block above makes this rule load only when a matching file is read, not every session (`https://code.claude.com/docs/en/memory`). As shipped it carries a placeholder: replace `<ext>` with the project's source extension(s) — one entry per extension (e.g. `"**/*.py"`, `"**/*.ts"`). A placeholder glob matches nothing, so the rule would never load; the conventions' verification block flags an unfilled placeholder.

```

- [ ] **Step 2: `testing.md` — frontmatter and callout**

Prepend:
```
---
paths:
  - "**/*_test.<ext>"
  - "**/*.test.<ext>"
  - "**/test/**"
  - "**/tests/**"
---

```
Insert after `# Testing Rules`:
```
> **Path-scoped — stamp the globs at install.** This rule loads only when a test file or a test directory is read (`https://code.claude.com/docs/en/memory`). Replace `<ext>` with the project's test-file extension(s) and drop the directory patterns the project does not use. A placeholder glob matches nothing; the conventions' verification block flags it. Anything a test-writing session needs *before* it opens a test file — the project's test-side trace-tag form, for one — is restated here rather than left in a rule this session never loads.

```

- [ ] **Step 3: `cbk-conventions.md` — the new section**

Insert after the `## Surface inventory` section (its last bullet is `**Tooling conventions:**`) and before `## Cascade artifact layout — flat (default) or nested`:
```
## Rule loading and the instruction budget

Every file under `.claude/rules/` **without** `paths:` frontmatter loads into context at launch, every session, at the same priority as `CLAUDE.md` — and every non-fork custom subagent loads the same set again (`https://code.claude.com/docs/en/memory`, `https://code.claude.com/docs/en/sub-agents` § What loads at startup). A rule whose trigger is genuinely file-based carries a `paths:` block and loads only when a matching file is read. The kit ships:

- **Scoped by file type** — `logging.md`, `testing.md`. Their globs are bracketed placeholders the operator stamps at install; the verification block flags a placeholder left in.
- **Always loaded, on purpose** — `workflows.md` (a portable rule), `simplification.md`, `knowledge-backend.md` (deleted together with its hook and settings stanza when the knowledge axis is `none`), and the templates `tooling.md` and `orchestration.md` until the operator fills, path-scopes or deletes them — the bootstrap checklist's rule-file disposition pass decides each one.

Two rules keep scoping honest. **A section a task needs before it reads any trigger file is unreachable from a path-scoped rule** — restate the one line in the rule the task does load (the test-side trace-tag form lives in `testing.md` for this reason). **An `@path` line in `CLAUDE.md` is an import, not a mention** — it expands the target into every session at launch; write backticked paths. The verification block prints the always-loaded set with its byte count so the standing cost is a number, not a discovery; to measure a change rather than estimate it, the harness's `InstructionsLoaded` hook reports which instruction files loaded and why.
```

- [ ] **Step 4: Verify**

```bash
head -4 .claude/rules/logging.md; head -7 .claude/rules/testing.md
bash -e /tmp/p1-block.sh 2>&1 | grep "always-loaded"
grep -n "^## Rule loading and the instruction budget" .claude/rules/cbk-conventions.md
```
Expected: both files open with `---` / `paths:`; the always-loaded print now lists seven files (logging and testing gone) and a smaller total; the heading is found once.

- [ ] **Step 5: Commit**

```bash
git add .claude/rules/logging.md .claude/rules/testing.md .claude/rules/cbk-conventions.md
git commit -m "feat(rules): path-scope logging.md and testing.md; state the rule-loading model (#15)" -m "Placeholder paths: globs the operator stamps at install, a callout on each file, and a conventions section that says which rules load every session and why, with the two rules that keep scoping honest." -m "Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 4: The fill-or-delete pass, the phase-exit checklists, and `workflows.md` as a portable rule (#16, #30 proposal 3, D17)

**Files:**
- Modify: `.claude/skills/scaffold/references/bootstrap_checklist_template.md` (heading `## Three sections, in order` → four; new `### 4. Rule-file disposition`; a completed-items row)
- Modify: `.claude/skills/scaffold/SKILL.md:256` (four sections), `## HITL gates summary` item 4, `## Failure modes to defend against` (new row), new `## Phase exit checklist` section before `## Reference files`
- Modify: `.claude/skills/blueprint/SKILL.md` — new `## Phase exit checklist` section before `## Reference files`
- Modify: `.claude/rules/cbk-conventions.md § Trip-wire / phase-exit checklist pattern` — one standing item
- Modify: `.claude/rules/workflows.md:3` (banner)

**Interfaces:**
- Consumes: the always-loaded loop from Task 2's block (the checklist pastes its output).
- Produces: the section name `### 4. Rule-file disposition` and the phrase "rule-file disposition table", cited by Task 6's checklist row and Task 11's README.

- [ ] **Step 1: `bootstrap_checklist_template.md` — four sections**

Replace `## Three sections, in order` with `## Four sections, in order`. Insert the following before `## Tone and posture`:

````markdown
### 4. Rule-file disposition

The kit's `.claude/rules/` ships three template rules that carry bracketed placeholders (`cbk-conventions.md`, `orchestration.md`, `tooling.md`) and two path-scoped rules whose `paths:` globs are placeholders (`logging.md`, `testing.md`). Nothing else in the cascade ever asks about them, so this section does: print the always-loaded set with its size first (the loop in `cbk-conventions.md` § Verification), then require an explicit disposition per file. A row with no disposition is a defect, not a default — a real run reached dozens of merged PRs with `[Record the project's posture here]` still in an always-loaded rule.

```markdown
## 📐 Rule-file disposition

Always-loaded rules as of this checklist:
<paste the always-loaded loop's output — one line per file with its byte count, and the total>

| Rule | Disposition | Reason |
|---|---|---|
| `cbk-conventions.md` | filled | surface inventory, branch naming, close markers stamped from this scaffold |
| `orchestration.md` | filled / path-scoped / deleted | <e.g. "filled — default posture recorded"> |
| `tooling.md` | filled / path-scoped / deleted | <e.g. "deleted — no MCPs wired yet; restore from the kit when the first lands"> |
| `logging.md` | stamped | `paths:` set to `**/*.<ext>` |
| `testing.md` | stamped | `paths:` set to `**/*_test.<ext>`, `**/test/**` |
| `knowledge-backend.md` | kept / deleted | <"deleted with its hook and settings stanza — knowledge axis is none"> |

One-time choices settled here (each has a kit default; a choice with no forcing surface is a choice the kit made for you):
- **Reviewer agent-memory**: `memory: project` (committed under `.claude/agent-memory/`, precedents survive clones and get PR-reviewed) or `memory: local` (`.claude/agent-memory-local/`, never committed). Decision: <project | local>. Recorded in `cbk-conventions.md` § Surface inventory.
- **Licence**: <SPDX id | none yet — all rights reserved>. Recorded in `docs/cbk/scaffold.md` § Cascade metadata.
```

The dispositions and what each means: **filled** — the bracketed sections carry this project's values, and the file opens with a one-line provenance note (the date, that it was filled from the kit's template, where it deviates); choices are appended under the template prose, not written over it. **path-scoped** — the file gains a `paths:` block so it loads only when a matching file is read. **deleted** — the file governs a surface this project does not have, and boilerplate would only tax every session; delete every index that lists it in the same change (`CLAUDE.md`, `README.md`, the reviewer that enumerates it) and note the restore condition. **kept** is valid only for a rule with no placeholders. **stamped** is the path-scoped rules' equivalent of filled.

In light mode this section is one line per file.
````

Also add to the `## ✅ Completed (via MCP)` example block, after the Knowledge surface row:
```
- **ADR starters**: `docs/adr/` created from the kit's starters — README, template, and ADR-0000 dated <date>, deciders <who>
```

- [ ] **Step 2: `scaffold/SKILL.md` — four sections, gate note, failure mode**

Line 256: replace `Three sections: completed items (with links), manual instructions (with URLs and expected outcomes), verification matrix (with test actions). Template in \`references/bootstrap_checklist_template.md\`.` with `Four sections: completed items (with links), manual instructions (with URLs and expected outcomes), verification matrix (with test actions), and the rule-file disposition table (one row per shipped template or path-scoped rule, plus the one-time choices — reviewer memory scope, licence). Template in \`references/bootstrap_checklist_template.md\`.`

In `## HITL gates summary`, item 4: replace `4. **Provisioning** — user confirms what was created, walks verification matrix` with `4. **Provisioning** — user confirms what was created, walks the verification matrix, and settles the rule-file disposition table (checklist section 4)`.

In `## Failure modes to defend against`, add after the `**Skipping discovery**` bullet:
```
- **Template rule files left unfilled and undeleted** — a target project reaches dozens of merged PRs with `[Record the project's posture here]` still in an always-loaded rule, paying its token cost every session and getting none of its guidance. Defense: the bootstrap checklist's rule-file disposition section requires a per-file decision (filled / path-scoped / deleted) before gate 4 closes.
```

- [ ] **Step 3: `scaffold/SKILL.md` — phase exit checklist**

Insert before `## Reference files`:
```
## Phase exit checklist

Auto-checkable, fires after gate 6 and before scaffold declares itself complete. Not a gate (no approval); a safety surface — stop and surface if any item fails. Per `cbk-conventions.md` § Trip-wire / phase-exit checklist pattern.

- [ ] `docs/cbk/scaffold.md` and `docs/cbk/problem_brief.md` are committed
- [ ] The Cascade metadata rows in `docs/cbk/scaffold.md` agree with `.cascade/backends.toml` (the verification block's axis-mirror check passes)
- [ ] `docs/adr/` exists with the three starters and ADR-0000's header is filled: `grep -n "YYYY-MM-DD\|<project owner" docs/adr/0000-*.md` prints nothing
- [ ] On the github-issues and linear axes, the four cascade issue templates are on disk under `.github/ISSUE_TEMPLATE/`, and `cascade-rough-in.md` carries the eight headings including `## Assumptions`
- [ ] The bootstrap checklist's rule-file disposition table has a disposition for every shipped template and path-scoped rule; `logging.md` and `testing.md` carry stamped globs (no `<ext>` left)
- [ ] Every call this run exercised that a reference file flags as individually unexercised has been restamped in the same commit (`references/linear_planning.md` § Exercise status names the flags)
```

- [ ] **Step 4: `blueprint/SKILL.md` — phase exit checklist**

Insert before `## Reference files`:
```
## Phase exit checklist

Auto-checkable, fires after the final gate and before blueprint declares itself complete. Not a gate; a safety surface — stop and surface if any item fails. Per `cbk-conventions.md` § Trip-wire / phase-exit checklist pattern.

- [ ] The six docs exist at their paths (`CLAUDE.md`, `docs/ARCHITECTURE.md`, `docs/STANDARDS.md`, `CONTRIBUTING.md`, `README.md`, `docs/cbk/blueprint.md`), and `docs/cbk/blueprint.md` carries its Cascade metadata, Stack decisions, Methodology and Core Projects sections
- [ ] `CLAUDE.md` mentions the other docs as backticked paths: `grep -n "^- @\|@docs/" CLAUDE.md` prints nothing
- [ ] Every ADR blueprint wrote is indexed in `docs/adr/README.md` and in `docs/ARCHITECTURE.md` § Decisions Log, and `docs/cbk/blueprint.md` § Stack decisions lists it
- [ ] The handoff issue (or its in-repo-markdown equivalent) exists, and the workstream parent entities blueprint.md names exist on the planning backend
- [ ] Every call this run exercised that `references/planning-backend-matrix.md` flags as individually unexercised has been restamped in the same commit
```

- [ ] **Step 5: `cbk-conventions.md § Trip-wire / phase-exit checklist pattern`**

After the sentence ending `modified for the cascade's gate-trim posture.` (the section's last paragraph), add:
```
Every phase's checklist carries one standing item: **if this run exercised a call that a reference file flags as individually unexercised, restamp it in the same commit** — drop the flag, date the run generically ("a second real run, <date>"), and update the file's § Exercise status. A flag with a re-check trigger nobody fires is a rail that outlives its evidence.
```

- [ ] **Step 6: `workflows.md` line 3 — portable rule, not a template**

Replace `> **This file is a template.** Copy it into a target project's \`.claude/rules/workflows.md\` and adapt the bracketed placeholders. It guides which workflow pattern to apply when working in the project.` with `> **This file is a portable rule.** It applies as shipped. Its one bracketed section (§ Cost+scope-explicit) is optional — fill it if the project tracks paid resources or agent-run quota, delete it otherwise. It guides which workflow pattern to apply when working in the project.`

- [ ] **Step 7: Verify**

```bash
grep -n "^## Four sections\|^### 4. Rule-file disposition" .claude/skills/scaffold/references/bootstrap_checklist_template.md
grep -n "^## Phase exit checklist" .claude/skills/scaffold/SKILL.md .claude/skills/blueprint/SKILL.md
grep -n "Four sections" .claude/skills/scaffold/SKILL.md
grep -n "portable rule" .claude/rules/workflows.md
grep -c "\[.*\]" .claude/rules/workflows.md   # the optional block's bracket remains; nothing else changed
bash -e /tmp/p1-block.sh > /dev/null && echo GREEN
```
Expected: each grep prints its line; `GREEN`.

- [ ] **Step 8: Commit**

```bash
git add .claude/skills/scaffold .claude/skills/blueprint/SKILL.md .claude/rules/cbk-conventions.md .claude/rules/workflows.md
git commit -m "feat(scaffold): the rule-file disposition pass, phase-exit checklists for scaffold and blueprint, workflows.md as a portable rule (#16)" -m "The bootstrap checklist gains a fourth section that prints the always-loaded set and requires filled / path-scoped / deleted per template rule plus the one-time choices; scaffold and blueprint get the phase-exit checklists the conventions already claimed every phase has, each carrying the restamp-in-the-same-commit item (#30); workflows.md drops its template banner (D17)." -m "Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 5: Restamp the Linear exercise flags (#30 proposals 1–2)

**Files:**
- Modify: `.claude/skills/scaffold/references/linear_planning.md:5,35,44`
- Modify: `.claude/skills/blueprint/references/planning-backend-matrix.md:41,80` (line 59 stays)
- Check only: `.claude/skills/scaffold/SKILL.md:137,306`, `.claude/skills/blueprint/SKILL.md:233,235,327`

**Interfaces:**
- Produces: exactly one remaining "individually unexercised" flag in the kit (the initiative-content update call at `planning-backend-matrix.md:59`).

- [ ] **Step 1: `linear_planning.md`**

Line 5: replace the italic paragraph beginning `*One-run-exercised (a full real cascade ran on this configuration; recorded 2026-08-09` with:
```
*Two-run-exercised: a full real cascade ran on this configuration (recorded 2026-08-09), and a second real run provisioned the initiative and project shell over the planner MCP and write-verified them (2026-08-12/13) — per the dated-empirical-rails principle, re-verify the MCP tool surface before re-citing. The one call shape still individually unexercised is flagged in `planning-backend-matrix.md`; disclose and fall back per operation, never per axis.*
```
Line 35 (step 5): replace the whole item with:
```
5. **Initiative + project shell** — create the initiative and one project (status, target date) under it via the planner MCP (`save_initiative` / `save_project`). *Exercised: a second real run created both this way and write-verified them (2026-08-12/13). If a call misbehaves, disclose and fall back to the planner UI without ceremony.*
```
Line 44 (§ Exercise status): replace the paragraph with:
```
The shell model and steps 2–5, 7–8 are exercised (step 5 by a second real run, 2026-08-12/13); step 6's settings walk is operator-manual by design and carries no flag. When a later real run exercises a call flagged elsewhere, drop its flag and restamp the date in the same commit — every phase's exit checklist carries this item.
```

- [ ] **Step 2: `planning-backend-matrix.md`**

Line 41: replace the italic sentence and its follow-on with:
```
*Exercised by two real cascade runs (a full cascade, recorded 2026-08-09; a second run that provisioned the initiative and project shell over the planner MCP, 2026-08-12/13 — per the dated-empirical-rails principle, re-verify the MCP tool surface before re-citing).* The structural model below is the exercised one; the one call shape still individually unexercised is flagged inline.
```
Line 59 (step 3's flag): **leave unchanged.**
Line 80 (§ Exercise status): replace with:
```
The `linear` structural model above is **two-run-exercised** (a full real cascade ran on it, recorded 2026-08-09; a second real run created the initiative and project shell over the planner MCP, 2026-08-12/13). One call shape stays flagged: writing initiative content into an already-created initiative (step 3) — no run has exercised that update call yet. Disclose and fall back per operation, never per axis. When a later real run exercises it, drop the flag and restamp the date in the same commit.
```

- [ ] **Step 3: Sweep the companion surfaces**

```bash
grep -n "unexercised\|one-run" .claude/skills/scaffold/SKILL.md .claude/skills/blueprint/SKILL.md
grep -rn "individually unexercised" .claude/
```
Expected: the first grep prints nothing (those lines only route to the two files; no edit). The second prints exactly three lines: `linear_planning.md:5`, `planning-backend-matrix.md:41`, and `planning-backend-matrix.md:59`.

- [ ] **Step 4: Commit**

```bash
git add .claude/skills/scaffold/references/linear_planning.md .claude/skills/blueprint/references/planning-backend-matrix.md
git commit -m "docs(linear): restamp the exercise flags a second real run cleared (#30)" -m "Initiative and project creation over the planner MCP were exercised and write-verified on 2026-08-12/13; the flags drop and both files' exercise status says which single call shape (initiative-content update) still has no run behind it." -m "Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 6: Scaffold instantiates and fills the ADR starters (#40, D17)

**Files:**
- Create: `.claude/skills/scaffold/references/adr-starters/README.md`, `template.md`, `0000-record-architecture-decisions.md` (byte-identical copies of `docs/adr/*`)
- Modify: `.claude/skills/scaffold/SKILL.md` — a new step in `## Stage 3 — Scaffold output and knowledge surface`; a line in `## Reference files`
- Modify: `.claude/rules/cbk-conventions.md § Verification` — a byte-parallel check in the kit sub-block

**Interfaces:**
- Consumes: the checklist row and exit-checklist item from Task 4.
- Produces: the directory `references/adr-starters/`, cited by Task 11's README tree.

- [ ] **Step 1: Copy the starters**

```bash
mkdir -p .claude/skills/scaffold/references/adr-starters
cp docs/adr/README.md docs/adr/template.md docs/adr/0000-record-architecture-decisions.md .claude/skills/scaffold/references/adr-starters/
diff -rq docs/adr .claude/skills/scaffold/references/adr-starters && echo IDENTICAL
```
Expected: `IDENTICAL`. The kit's root `docs/adr/0000-…` keeps its `YYYY-MM-DD` / `<project owner / team>` placeholders (D17): it is a starter, filled at scaffold.

- [ ] **Step 2: `scaffold/SKILL.md` — the provisioning step**

In `## Stage 3 — Scaffold output and knowledge surface`, after the paragraph beginning `**The optional knowledge backend**`, add:
```
**Instantiate the ADR starters.** If the repo has no `docs/adr/`, copy the three starters from `references/adr-starters/` (`README.md`, `template.md`, `0000-record-architecture-decisions.md`) into `docs/adr/`. Whether they were just copied or arrived with the kit, fill ADR-0000's header before it lands: `Date:` = today's ISO-8601 date, `Deciders:` = the operator or team from discovery. Write the filled file through the same commit path as the other scaffold artifacts (the GitHub MCP commit, or the local fallback) — the ADR-immutability hook guards tool-mediated edits to existing decision records, and provisioning a starter is not an edit to an accepted decision. Then check: `grep -n "YYYY-MM-DD\|<project owner" docs/adr/0000-*.md` must print nothing. Record the copy in the bootstrap checklist's completed items. The bundled starters are byte-identical to the kit's root `docs/adr/`; the conventions' verification block pins the pair.
```
In `## Reference files`, add after the `references/issue-templates/` bullet:
```
- `references/adr-starters/` — the three `docs/adr/` starters scaffold instantiates (README, template, ADR-0000). Byte-identical to the kit's root `docs/adr/`; the verification block pins the pair.
```

- [ ] **Step 3: Verification block — the pin**

In `cbk-conventions.md § Verification`, in the kit sub-block after the citation-pin lines, add:
```
# Bundled starters stay byte-identical to their originals (the kit's root docs/adr/ is the source of truth).
[ -d docs/adr ] && diff -rq docs/adr .claude/skills/scaffold/references/adr-starters
```

- [ ] **Step 4: Verify**

```bash
awk '/^## Verification/{p=1} p' .claude/rules/cbk-conventions.md | awk '/^```bash/{c=1;next} /^```/{c=0} c' > /tmp/p1-block.sh
bash -e /tmp/p1-block.sh > /dev/null && echo GREEN
grep -n "Instantiate the ADR starters" .claude/skills/scaffold/SKILL.md
```
Expected: `GREEN`; the step is found.

- [ ] **Step 5: Commit**

```bash
git add .claude/skills/scaffold .claude/rules/cbk-conventions.md
git commit -m "feat(scaffold): instantiate the docs/adr starters and fill ADR-0000's header (#40)" -m "Bundled byte-identical starters under references/adr-starters/, a Stage 3 step that copies them when absent and fills Date and Deciders through the scaffold commit path, an exit grep for leftover placeholders, and a verification pin keeping the bundle equal to the root copy. The kit's own root starter keeps its placeholders (D17)." -m "Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 7: The eighth heading, and the executor's parser as the single authority (#45)

**Files:**
- Modify: `.claude/skills/scaffold/references/issue-templates/cascade-rough-in.md` — insert `## Assumptions` between `## Context` and `## Implementation`; amend the header comment
- Modify: `.claude/skills/rough-in/SKILL.md` — the paragraph beginning `**Section names + ordering on disk are project-specific.**` (line 139)
- Modify: `.claude/rules/cbk-conventions.md § Verification` — the heading-list agreement check

**Interfaces:**
- Produces: the eight-heading list `Context, Assumptions, Implementation, Acceptance criteria, Test plan, Done signal, Dependencies, PR contract` as the checked contract.

- [ ] **Step 1: Insert the section into the issue template**

Directly before the line `## Implementation` in `cascade-rough-in.md` (line 50), insert exactly the spec template's block (from `rough-in-spec-template.md` lines 90–110), so the two are identical:
```
## Assumptions

<!--
Surface assumptions before any implementation content. Per Addy Osmani's
"how to write a good spec for AI agents" pattern. List every gap rough-in
filled in that the user might want to correct: API arities chosen without
verification, library versions assumed available, semantic interpretations
of the framing's intent that could go either way. Include `[ASSUMPTION:]`
tag prefix per item so /finish can grep for them at execution time.

If empty, write `- None — all parameters explicit from the framing intent
and acceptance criteria.` Do not delete the section.

Resolved assumptions (confirmed during implementation) move out of this
section and inline into the relevant ## Implementation paragraph; do not
maintain a separate "Resolved" subsection.
-->

- [ASSUMPTION: <gap description>] <one-line context — why this assumption was made and what would change if wrong>
- [ASSUMPTION: <next>] ...

```
In the template's header comment, replace `The only hard rule: keep the section headings as written. /finish` with `The only hard rule: keep the eight section headings as written, in order. /finish`.

- [ ] **Step 2: `rough-in/SKILL.md` — the authority paragraph**

Read the paragraph at line 139 beginning `**Section names + ordering on disk are project-specific.**` in full, then replace that whole paragraph with:
```
**The executor's parser is the authority on section names.** `/finish` identifies sections by heading name and requires exactly eight, in order: Context, Assumptions, Implementation, Acceptance criteria, Test plan, Done signal, Dependencies, PR contract (`commands/finish.md` Step 2). The eight properties above are what every spec must *express*; the headings are how the executor *finds* them. Every other surface that restates the list — `references/templates/rough-in-spec-template.md`, the scaffold-shipped `issue-templates/cascade-rough-in.md`, `references/handoff-to-finish.md`, `references/plan-mode-prompts.md` — is a copy, and the conventions' verification block checks the two templates against each other and against the executor. A project that renames a section edits the executor first and the copies with it; a copy that disagrees with the executor is a defect to fix, never a difference to work around.
```

- [ ] **Step 3: Verification block — the heading-list check**

Add to the kit sub-block, after the starters pin:
```
# The eight-section contract: the scaffold-shipped issue template, the spec template and the
# executor's parser agree on the heading list (the executor is the authority; the others are copies).
diff <(grep '^## ' .claude/skills/scaffold/references/issue-templates/cascade-rough-in.md) <(grep '^## ' .claude/skills/rough-in/references/templates/rough-in-spec-template.md)
for h in Context Assumptions Implementation "Acceptance criteria" "Test plan" "Done signal" Dependencies "PR contract"; do grep -q "\`## $h\`" .claude/commands/finish.md || { echo "finish.md does not name ## $h"; exit 1; }; done
```
Then run the `diff` line alone first. If the spec template has `## ` lines outside its issue body (guidance headings), restrict both greps to the body — find the body's first and last heading and `sed -n` that range — and record the range in the check's comment. Do not weaken the check to a subset of headings.

- [ ] **Step 4: Verify**

```bash
grep -n "^## " .claude/skills/scaffold/references/issue-templates/cascade-rough-in.md
awk '/^## Verification/{p=1} p' .claude/rules/cbk-conventions.md | awk '/^```bash/{c=1;next} /^```/{c=0} c' > /tmp/p1-block.sh
bash -e /tmp/p1-block.sh > /dev/null && echo GREEN
```
Expected: eight headings in order with `## Assumptions` second; `GREEN`.

- [ ] **Step 5: Commit**

```bash
git add .claude/skills/scaffold/references/issue-templates/cascade-rough-in.md .claude/skills/rough-in/SKILL.md .claude/rules/cbk-conventions.md
git commit -m "fix(rough-in): the scaffold-shipped issue template carries ## Assumptions; the executor's parser is the heading authority (#45)" -m "Eight headings on every restatement, checked mechanically: the two templates against each other and each heading against commands/finish.md." -m "Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 8: Four live framing defects, two backend-named descriptions, and count-free preambles

**Files:**
- Modify: `.claude/skills/framing/SKILL.md:4,74,76,284,325,384,390`
- Modify: `.claude/skills/blueprint/SKILL.md:4,329`
- Modify: `.claude/skills/blueprint/references/test_cases.md:3`, `.claude/skills/consultation/references/test_cases.md:3`, `.claude/skills/scaffold/references/test_cases.md:3`, `.claude/skills/framing/references/test_cases.md:3`, `.claude/skills/rough-in/references/test_cases.md:3`, `.claude/skills/consultation/SKILL.md:178`
- Check: `.claude/skills/framing/references/research-phase.md`, `.claude/skills/framing/references/hitl-question-bank.md` for MCP/plugin recommendation text
- Modify: `.claude/rules/cbk-conventions.md § Verification` — two checks

**Interfaces:**
- Produces: the sentinel string `No deferred meta-issues from this framing` stated identically at every site.

- [ ] **Step 1: The sentinel (framing/SKILL.md line 284)**

Confirm the producer's exact phrase first:
```bash
sed -n '218,224p' .claude/skills/framing/references/templates/frame-output-template.md
grep -n "No deferred meta-issues from this framing" .claude/skills/rough-in/SKILL.md .claude/skills/rough-in/references/inheritance.md
```
Expected: the template writes `No deferred meta-issues from this framing` and rough-in matches that string. Then in `framing/SKILL.md` line 284 replace `**Pre-flight checks** table (with empty-default \`"No pre-flight blockers from this framing"\` if none)` with `**Pre-flight checks** table (with the empty-default text \`"No deferred meta-issues from this framing"\` if none — this exact string is what rough-in's pre-flight check matches; see \`references/templates/frame-output-template.md\` § Pre-flight checks)`.

- [ ] **Step 2: The tooling-research contradiction (lines 74, 76, 325, 384)**

Line 131 states the scope rule: `**What framing does NOT research**: MCP server selection, Claude Code plugin selection, stack decisions, methodology selection, CI gate decisions. All of those belong in **blueprint**`. Make the rigor modes and the gate list agree with it:
- Line 74: delete the sentence `Includes the development tooling research phase (MCP servers + Claude Code plugins specific to this project).` so the item reads `**Full mode** — five HITL gates (one per step). Best for: …`.
- Line 76: delete the sentence `Skips the development tooling research phase by default unless the user asks.`
- Line 325: replace `3. **After research phase** — user lands on technical approach and (in full mode) reviews MCP/plugin recommendations` with `3. **After research phase** — user lands on the technical approach and the resolutions of the open technical questions`.
- Line 384: replace `- \`references/research-phase.md\` — implementation patterns research, MCP/plugin recommendation discipline, open-question resolution` with `- \`references/research-phase.md\` — implementation patterns research, open-question resolution, the fan-out and grounding disciplines`.
Then sweep the references:
```bash
grep -n -i "MCP/plugin\|plugin recommendation\|MCP server" .claude/skills/framing/references/research-phase.md .claude/skills/framing/references/hitl-question-bank.md .claude/skills/framing/references/test_cases.md
```
Any line that *offers* a tooling-recommendation track (as opposed to `§ What framing does NOT research`, which forbids it) is rewritten to route the topic to blueprint; record each edit in the commit body.

- [ ] **Step 3: Axis-neutral descriptions (framing line 4, blueprint line 4)**

Framing: replace `Decompose a Linear project into sequenced milestones with rough issues.` with `Decompose one workstream into sequenced milestones with rough issues.`
Blueprint: replace `and either creates a Linear initiative or commits blueprint.md to the repo.` with `and commits blueprint.md to the repo alongside the planning-backend entities the project's axis calls for.`

- [ ] **Step 4: Count-free preambles**

- `framing/SKILL.md:390`: replace `— three realistic test prompts (canonical first framing / subsequent framing builds on prior / re-framing after code) with success criteria` with `— realistic test prompts (each names its scenario) with success criteria`.
- `blueprint/SKILL.md:329`: replace `— three realistic test prompts (canonical run / unusual stack / conflicting constraints) with success criteria` with `— realistic test prompts (canonical run, unusual stack, conflicting constraints, and later additions) with success criteria`.
- `consultation/SKILL.md:178`: replace `— three realistic test prompts (greenfield / brownfield / partial-context)` with `— realistic test prompts (greenfield, brownfield, partial-context)`.
- `blueprint/references/test_cases.md:3`: replace the opening `Three realistic test prompts that exercise` with `The realistic test prompts below exercise`.
- `consultation/references/test_cases.md:3`: replace `Three realistic test prompts that exercise` with `The realistic test prompts below exercise`.
- `scaffold/references/test_cases.md:3`: replace `Three realistic test prompts that exercise` with `The realistic test prompts below exercise`.
- `framing/references/test_cases.md:3`: replace `Six realistic prompts for verifying` with `Realistic prompts for verifying`.
- `rough-in/references/test_cases.md:3`: replace `This file contains eight realistic test prompts for verifying` with `This file contains realistic test prompts for verifying`.

- [ ] **Step 5: Verification block — two checks**

Add to the kit sub-block:
```
# Skill and command descriptions name cascade objects, never one backend's entity type
# (the phase skills below run on every planning axis).
! grep -n "^description:.*\bLinear\b" .claude/skills/framing/SKILL.md .claude/skills/blueprint/SKILL.md
# Counts embedded in prose rot: test-case preambles and their index lines state no count.
! grep -rnE "^(Three|Four|Five|Six|Seven|Eight) realistic" .claude/skills/*/references/test_cases.md
! grep -rnE "test_cases\.md\` — (three|four|five|six|seven|eight) realistic" .claude/skills/*/SKILL.md
```

- [ ] **Step 6: Verify**

```bash
grep -n "No pre-flight blockers\|tooling research phase\|MCP/plugin recommendations" .claude/skills/framing/SKILL.md; echo "exit=$?"
awk '/^## Verification/{p=1} p' .claude/rules/cbk-conventions.md | awk '/^```bash/{c=1;next} /^```/{c=0} c' > /tmp/p1-block.sh
bash -e /tmp/p1-block.sh > /dev/null && echo GREEN
```
Expected: `exit=1` (no hits); `GREEN`.

- [ ] **Step 7: Commit**

```bash
git add .claude/skills .claude/rules/cbk-conventions.md
git commit -m "fix(framing): four live defects — the sentinel rough-in matches, the tooling-research track the scope rule forbids, backend-named descriptions, counted preambles" -m "The phase-exit checklist quotes the exact empty-state string; full mode no longer adds MCP/plugin research that § What framing does NOT research forbids; framing and blueprint descriptions name cascade objects; test-case preambles and index lines drop their counts, with greps to keep both." -m "Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 9: Hook and settings audit — every hook expects only what the process provides

**Files:**
- Read/verify: `.claude/hooks/*.sh` (six), `.claude/settings.json`, `.mcp.json.example`, `README.md` § Required dependencies
- Modify: `.claude/hooks/protect-main-branch.sh` (header note), `.claude/settings.json` (an example PostToolUse stanza), possibly `README.md` § Claude Code plugins and `settings.json` `enabledPlugins` (only if Step 6 finds a defect)
- Modify: `.claude/rules/cbk-conventions.md § Branch naming` (one sentence)

**Interfaces:**
- Produces: a dry-run table (hook · payload · expected · observed) pasted into the PR body by Task 11.

- [ ] **Step 1: Registry ⇔ files**

```bash
for h in .claude/hooks/*.sh; do b=$(basename "$h"); printf '%-40s registered-in-array=%s\n' "$b" "$(jq -r '[.. | objects | select(has("command")) | .command] | map(select(endswith("'"$b"'"))) | length' .claude/settings.json)"; done
jq -r '[.. | objects | select(has("command")) | .command][]' .claude/settings.json | while read -r c; do [ -x "$c" ] || echo "MISSING or not executable: $c"; done
```
Expected: five hooks registered once each, `format-on-edit.sh` registered 0 (it is the exemplar), nothing missing. If a registered hook is not executable, `chmod +x` it and note it.

- [ ] **Step 2: Dry-run every hook on every branch it has**

```bash
H=.claude/hooks; P="$PWD"
run() { printf '%s' "$2" | CLAUDE_PROJECT_DIR="$P" "$H/$1" >/tmp/out 2>/tmp/err; echo "$1 :: $3 :: exit=$? :: stdout=$(tr -d '\n' </tmp/out | cut -c1-90)"; }
run protect-immutable-adrs.sh '{"tool_name":"Write","tool_input":{"file_path":"'"$P"'/docs/adr/0000-record-architecture-decisions.md"}}' "Write existing ADR → 2"
run protect-immutable-adrs.sh '{"tool_name":"Edit","tool_input":{"file_path":"'"$P"'/docs/adr/0000-record-architecture-decisions.md"}}' "Edit existing ADR → 2"
run protect-immutable-adrs.sh '{"tool_name":"Write","tool_input":{"file_path":"'"$P"'/docs/adr/0099-not-yet.md"}}' "Write new ADR → 0"
run protect-immutable-adrs.sh '{"tool_name":"Edit","tool_input":{"file_path":"'"$P"'/docs/adr/README.md"}}' "Edit index → 0"
run protect-immutable-adrs.sh '{"tool_name":"Read","tool_input":{"file_path":"'"$P"'/docs/adr/0000-record-architecture-decisions.md"}}' "Read → 0"
run protect-lock-files.sh '{"tool_name":"Edit","tool_input":{"file_path":"'"$P"'/package-lock.json"}}' "Edit lockfile → 2"
run protect-lock-files.sh '{"tool_name":"Edit","tool_input":{"file_path":"'"$P"'/package.json"}}' "Edit manifest → 0"
run guard-pr-state.sh '{"tool_name":"Bash","tool_input":{"command":"gh pr ready 12"}}' "gh pr ready → ask JSON, exit 0"
run guard-pr-state.sh '{"tool_name":"Bash","tool_input":{"command":"gh pr create --draft"}}' "gh pr create → 0, no JSON"
run guard-pr-state.sh '{"tool_name":"Bash","tool_input":{"command":"git push -u origin HEAD"}}' "git push → 0, no JSON"
run require-knowledge-backend-ok.sh '{"tool_name":"mcp__plugin_Notion_notion__notion-create-pages","tool_input":{}}' "notion create → ask JSON"
echo 'mcp__plugin_Notion_notion__notion-create-pages' | grep -E "$(jq -r '.hooks.PreToolUse[] | select(.matcher | test("notion")) | .matcher' .claude/settings.json)" && echo "matcher matches the plugin-namespaced tool name"
# protect-main-branch needs a real repo state: use a throwaway clone
T=$(mktemp -d); git clone -q "$P" "$T"; ( cd "$T" && printf '%s' '{"tool_name":"Bash","tool_input":{"command":"git commit -m x"}}' | CLAUDE_PROJECT_DIR="$T" "$P/$H/protect-main-branch.sh" >/dev/null 2>&1; echo "protect-main-branch :: commit on main → exit=$? (expect 2)"; printf '%s' '{"tool_name":"Bash","tool_input":{"command":"git switch -c t && git commit -m x"}}' | CLAUDE_PROJECT_DIR="$T" "$P/$H/protect-main-branch.sh" >/dev/null 2>&1; echo "protect-main-branch :: compound switch+commit on main → exit=$? (expect 2: judged at entry)"; git switch -q -c feat/x; printf '%s' '{"tool_name":"Bash","tool_input":{"command":"git commit -m x"}}' | CLAUDE_PROJECT_DIR="$T" "$P/$H/protect-main-branch.sh" >/dev/null 2>&1; echo "protect-main-branch :: commit on branch → exit=$? (expect 0)" ); rm -rf "$T"
# fail-open: no jq on PATH
PATH=/usr/bin/nonexistent printf '%s' '{"tool_name":"Write","tool_input":{"file_path":"x"}}' | env PATH=/nonexistent bash .claude/hooks/protect-immutable-adrs.sh; echo "no-jq → exit=$? (expect 0 with a stderr warning)"
```
Expected: every line's observed exit matches its expectation; the two ask-gate hooks print `"permissionDecision":"ask"` JSON; `git push` and `gh pr create` are silent. Record the table.

- [ ] **Step 3: The compound-command trap, stated where it bites**

In `protect-main-branch.sh`'s header comment, after the `Allowed:` lines, add:
```
# Timing:   the guard reads the branch BEFORE the command runs, so a compound
#           command that creates a branch and commits in one call is judged on
#           main and blocked. Create the branch and make the first commit in
#           separate tool calls.
```
In `cbk-conventions.md § Branch naming`, after `\`/finish\` already creates branches in this shape; this convention codifies what was already happening.` add:
```
Create the branch and make the first commit in **separate tool calls**: the default-branch guard judges a compound command on the branch at entry, so `git switch -c … && git commit …` is blocked even though the commit would have been legal by the time it ran.
```

- [ ] **Step 4: The exemplar's stanza ships beside it**

In `.claude/settings.json`, add a top-level key after `"hooks"` (underscore-prefixed keys are ignored by the harness the way the existing `_comment_*` keys are):
```json
"_example_PostToolUse_formatter": {
  "_comment": "Copy this object into hooks.PostToolUse after wiring .claude/hooks/format-on-edit.sh's case arms to your stack. Advisory tier: exit 0 always.",
  "matcher": "Edit|Write|MultiEdit",
  "hooks": [ { "type": "command", "command": ".claude/hooks/format-on-edit.sh" } ]
},
```
Then confirm the exemplar's arms are inert as shipped:
```bash
jq empty .claude/settings.json && echo "settings.json parses"
grep -n "case\|)\s*;;\|\*)" .claude/hooks/format-on-edit.sh | head
grep -n "cargo\|python" .claude/hooks/format-on-edit.sh
```
Expected: parses; the `*)` arm is a no-op; any `cargo`/`python` mention is inside a commented example arm, not an executed one. If an arm executes a formatter the kit does not ship, comment it out with a note.

- [ ] **Step 5: Plugin and MCP expectations**

```bash
jq -r '.enabledPlugins | keys[]' .claude/settings.json
claude plugin list 2>/dev/null | head -30
jq -r '.enabledMcpjsonServers[]' .claude/settings.json; jq -r '.mcpServers | keys[]' .mcp.json.example
```
Expected: every `enabledMcpjsonServers` id exists in `.mcp.json.example` (five and five). For plugins: `pr-review-toolkit` and `commit-commands` are installable plugins; if `claude plugin list` shows no `simplify` plugin because `/simplify` is a built-in skill in the current harness, change the `enabledPlugins` entry to a comment line in `_comment_enabledPlugins` ("`/simplify` is built into Claude Code as of <date>; listed here only if your install ships it as a plugin") and update README § Claude Code plugins to say the same. Record what `claude plugin list` printed in the PR body either way.

- [ ] **Step 6: Verify and commit**

```bash
for h in .claude/hooks/*.sh; do bash -n "$h" && echo "syntax ok $h"; done
bash -e /tmp/p1-block.sh > /dev/null && echo GREEN
git add .claude/hooks .claude/settings.json .claude/rules/cbk-conventions.md README.md
git commit -m "chore(hooks): audit the registry — every hook dry-run on every branch, the exemplar's stanza shipped beside it, the compound-command trap stated" -m "All six hooks pass bash -n and the crafted-payload dry-run (table in the PR body); the formatter exemplar's registration stanza ships as an example key; the default-branch guard's header and § Branch naming say branch creation and the first commit are separate calls; plugin and MCP expectations checked against what ships." -m "Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```
(Omit `README.md` from `git add` if Step 5 changed nothing there.)

---

### Task 10: Ship the three big rules as contract + path-scoped reference (#53, D18)

**Files:**
- Modify: `.claude/rules/cbk-conventions.md` (contract half); Create: `.claude/rules/cbk-conventions-reference.md`
- Modify: `.claude/rules/orchestration.md`; Create: `.claude/rules/orchestration-reference.md`
- Modify: `.claude/rules/pr-review.md`; Create: `.claude/rules/pr-review-reference.md`
- Modify: `.claude/rules/testing.md` (one restated line), `.claude/rules/workflows.md § Index of .claude/rules/*.md` (one row), `.claude/commands/finish.md` and `.claude/skills/rough-in/references/finish-command.md` (the triage read line, byte-parallel), `.claude/agents/cascade-rule-reviewer.md § Rules in scope`, `CLAUDE.md:41,77` and its rules list
- Modify: `cbk-conventions.md § Rule loading and the instruction budget` (the split bullet)

**Interfaces:**
- Consumes: `§ Rule loading and the instruction budget` (Task 3).
- Produces: six files; every `<rule>.md § <section>` citation in the repo still resolves (to a pointer in the contract, then to the reference).

- [ ] **Step 1: Snapshot the pre-split files**

```bash
mkdir -p /tmp/presplit && for f in cbk-conventions orchestration pr-review; do cp .claude/rules/$f.md /tmp/presplit/$f.md; done
```

- [ ] **Step 2: The section map (split by when the content is needed, never by length)**

`cbk-conventions.md` — **contract keeps**: the title, the template banner and principle bullets, `## Surface inventory`, `## Rule loading and the instruction budget`, `## Branch naming` (with `### Linear {type} placeholder`), `## Closes-keyword conventions`, `## [skip ci] rule`, `## ADR index sync`, `## Mutation discipline`, `## Quick reference`, `## References`. **Reference takes**: `## Cascade artifact layout — flat (default) or nested`, `## Sub-issue hierarchy — three levels`, `## Title-prefix scheme`, `## Contribution intake — bug lane + enhancement lane` (all `###` subsections), `## Trace ID convention`, `## Sub-issue rollup`, `## Dependency settle-window — supply-chain discipline`, `## Methodology — choice space`, `## Verify-against-reality before a one-way door (optional practice)`, `## Spec-Kit vocabulary mapping`, `## HITL gate load-bearing heuristics`, `## Trip-wire / phase-exit checklist pattern`, `## Recommended planning-backend settings`, `## Knowledge backend — operator's specific choices`, `## Verification`.

`orchestration.md` — **contract keeps**: title and banner, `## The ceiling rule`, `## The role ladder (model axis)`, `## The effort axis (co-equal dial)`, `## The dispatch-mechanism decision`, `## Fan-out discipline`, `## Anti-patterns`, `## See also`. **Reference takes**: `## The three surfaces + resolution order`, `## Applied instances in this project`, `## When to update this file`, `## Primary sources`.

`pr-review.md` — **contract keeps**: title and intro, `## Plugin`, `## When to invoke`, `## Project-local agents to dispatch alongside`, `## Pre-filters — strip before the agent reads`, `## Triage rubric — the four-class shape`, `## What NOT to flag — the exclusion list`, `## Break-glass override`, `## References`. **Reference takes**: `## Apply / Surface calibration` (with its five `###`), `## Path-conditional aggressiveness`, `## Anti-patterns` (with its six `###`), `## When to update this file`.

- [ ] **Step 3: Move each reference section verbatim, leaving a pointer heading in place**

For each section in the reference list: cut the section from the contract (the `## ` heading line through the line before the next `## ` heading) and append it to the reference file in original order. In the contract, leave the heading line and directly under it one pointer line:
```
→ *Moved to* `cbk-conventions-reference.md` § <exact heading text> *(path-scoped; see § Rule loading and the instruction budget).*
```
(Use the matching `-reference.md` name for the other two files.) The heading stays so every `cbk-conventions.md § <section>` citation across skills, commands, agents and workflows resolves to the pointer. Do this with an editor or a script, section by section — never by regex over the whole file — and keep `###` subsections attached to their `##` parent.

- [ ] **Step 4: Frontmatter and header for each reference half**

`cbk-conventions-reference.md` begins:
```
---
paths:
  - "docs/cbk/**"
  - "docs/adr/**"
  - ".claude/skills/**"
  - ".claude/commands/**"
  - ".claude/rules/cbk-conventions*.md"
  - ".claude/hooks/**"
  - ".claude/settings*.json"
  - ".github/**"
  - ".gitignore"
  - ".gitattributes"
  - "mise.toml"
  - "<manifest-and-lockfile-globs — e.g. **/package.json, **/Cargo.toml, **/*.lock>"
---

# Cascade Conventions — the reference half

> **Path-scoped.** This file holds the sections of `cbk-conventions.md` a session needs only when it touches a cascade artifact, a decision record, a skill or command, a hook or the settings file, a `.github/` file, a manifest or lockfile, `mise.toml`, `.gitignore` or `.gitattributes` — the `paths:` block above lists the triggers; replace the bracketed entry with the project's manifest and lockfile globs at install. `cbk-conventions.md` (always loaded) keeps a pointer heading for every section here, so `cbk-conventions.md § <section>` citations resolve to the pointer and the pointer to this file. Sections were moved verbatim on 2026-09-06; the split is by when the content is needed, never by length. See `cbk-conventions.md` § Rule loading and the instruction budget.
```
`orchestration-reference.md` begins:
```
---
paths:
  - ".claude/workflows/**"
  - ".claude/agents/**"
  - ".claude/rules/orchestration*.md"
---

# Orchestration — the reference half

> **Path-scoped.** Loads when a workflow, an agent definition, or this rule pair is read. `orchestration.md` (always loaded) keeps a pointer heading for every section here. Sections were moved verbatim on 2026-09-06. See `cbk-conventions.md` § Rule loading and the instruction budget.
```
`pr-review-reference.md` begins:
```
---
paths:
  - ".claude/rules/pr-review*.md"
  - ".claude/agents/**"
  - ".claude/workflows/**"
  - ".github/workflows/**"
---

# PR Review Rules — the reference half

> **Path-scoped.** Loads when a reviewer agent, a workflow, a CI workflow, or this rule pair is read. `pr-review.md` (always loaded) keeps a pointer heading for every section here. **A triage is not a file read**: the executor reads this file by name at its triage step (`commands/finish.md`), because nothing else triggers it there. Sections were moved verbatim on 2026-09-06. See `cbk-conventions.md` § Rule loading and the instruction budget.
```

- [ ] **Step 5: The restatements the split makes necessary**

- `testing.md` — in `## Test naming — quotable from the spec`, after the mapping bullets, add: `The test-side trace tag (the R-issue's own criterion numbering that a test docstring cites) is recorded in \`cbk-conventions-reference.md\` § Trace ID convention; it is restated here because a test-writing session loads this rule and may never open a cascade file.`
- `commands/finish.md` Step 9 item 3 (`**Triage and auto-action findings per \`.claude/rules/pr-review.md\`.**`): append the sentence `Read \`.claude/rules/pr-review-reference.md\` § Apply / Surface calibration and § Path-conditional aggressiveness before classifying — a triage is not a file read, so the path-scoped reference does not load on its own.` Make the identical edit in the template body of `.claude/skills/rough-in/references/finish-command.md`.
- `cbk-conventions.md § Rule loading and the instruction budget` — add a bullet between the two existing ones: `- **Split into an always-loaded contract and a path-scoped reference** — \`cbk-conventions.md\` / \`cbk-conventions-reference.md\`, \`orchestration.md\` / \`orchestration-reference.md\`, \`pr-review.md\` / \`pr-review-reference.md\`. Every moved section keeps its heading in the contract with a one-line pointer, so \`file § section\` citations resolve unchanged.`
- `workflows.md § Index of .claude/rules/*.md` — add a final row: `| \`*-reference.md\` | Only when a matching file is read | The path-scoped halves of the conventions, orchestration and review rules; every section has a pointer heading in its contract |`
- `.claude/agents/cascade-rule-reviewer.md § Rules in scope` — replace the four enumerated bullets and the `Note:` paragraph with:
```
Every file under `.claude/rules/` **except** `logging.md` (the logging reviewer's) and the `pr-review.md` pair (the rubric I apply, not a contract I check the diff against). That set is derived, not enumerated — a rule added, split or renamed is in scope the moment it lands. Today it is: `testing.md` (three-regime testing; the named tests trace to acceptance criteria), `cbk-conventions.md` and `cbk-conventions-reference.md` (branch naming, title prefixes, close markers, the `[skip ci]` rule, mutation discipline, workstream slug stability), `simplification.md`, `knowledge-backend.md` (writes HITL-gated and default-SKIP; the repo is canonical for code and cascade artifacts), `workflows.md`, `tooling.md`, `orchestration.md` and `orchestration-reference.md`. Read the reference half of a split rule when the contract's pointer names the section the diff touches.
```
- `CLAUDE.md` line 41: replace the `rules/` line's description with `← operational contracts (cbk-conventions, pr-review, orchestration — each split into an always-loaded contract and a path-scoped \`-reference.md\` half — plus testing, logging, simplification, knowledge-backend) and rule templates (tooling, orchestration); workflows.md is portable`. Line 77: replace `run the verification greps listed at the bottom of that file (under \`## Verification\`)` with `run the verification block in \`cbk-conventions-reference.md\` § Verification (the kit sub-block must be green on this tree)`. In the `Kit-wide operational contracts` list, add: `- \`cbk-conventions-reference.md\`, \`orchestration-reference.md\`, \`pr-review-reference.md\` — the path-scoped halves; see \`cbk-conventions.md\` § Rule loading and the instruction budget`.

- [ ] **Step 6: Integrity checks against the snapshot**

```bash
for f in cbk-conventions orchestration pr-review; do
  echo "== $f"
  # every ## heading of the pre-split file appears as a heading in exactly one half
  grep '^## ' /tmp/presplit/$f.md | sort > /tmp/o.txt
  cat .claude/rules/$f.md .claude/rules/$f-reference.md | grep '^## ' | sort | uniq -c | awk '$1!=1 && $1!=2{print "bad count:",$0}'
  cat .claude/rules/$f.md .claude/rules/$f-reference.md | grep '^## ' | sort -u > /tmp/p.txt
  comm -23 /tmp/o.txt /tmp/p.txt | sed 's/^/LOST HEADING: /'
  # every reference heading has a pointer in the contract
  grep '^## ' .claude/rules/$f-reference.md | sed 's/^## //' | while read -r h; do grep -qF "§ $h" .claude/rules/$f.md || echo "NO POINTER: $h"; done
  # no paragraph lost: every non-empty pre-split line is somewhere in the pair
  grep -v '^\s*$' /tmp/presplit/$f.md | sort -u > /tmp/ol.txt
  cat .claude/rules/$f.md .claude/rules/$f-reference.md | grep -v '^\s*$' | sort -u > /tmp/pl.txt
  comm -23 /tmp/ol.txt /tmp/pl.txt | sed 's/^/LOST LINE: /'
done
```
Expected: no `LOST HEADING`, `NO POINTER`, `LOST LINE` or `bad count` output (a moved heading appears twice — contract pointer plus reference — which the count filter allows; the only intentionally changed lines are the ones Step 5 added, which are new, not lost).

- [ ] **Step 7: The suite, from its new home**

```bash
awk '/^## Verification/{p=1} p' .claude/rules/cbk-conventions-reference.md | awk '/^```bash/{c=1;next} /^```/{c=0} c' > /tmp/p1-block.sh
bash -e /tmp/p1-block.sh | grep "always-loaded"; echo "exit=${PIPESTATUS[0]}"
grep -rn "cbk-conventions.md § Verification" .claude CLAUDE.md README.md
```
Expected: the always-loaded print lists `cbk-conventions.md`, `orchestration.md`, `pr-review.md`, `workflows.md`, `tooling.md`, `simplification.md`, `knowledge-backend.md` and a total well below Task 0's; `exit=0`; the last grep shows only pointer lines and the CLAUDE.md sentence rewritten in Step 5 (fix any other citation to name the reference half).

- [ ] **Step 8: Commit**

```bash
git add .claude/rules .claude/commands/finish.md .claude/skills/rough-in/references/finish-command.md .claude/agents/cascade-rule-reviewer.md CLAUDE.md
git commit -m "feat(rules): ship cbk-conventions, orchestration and pr-review as contract + path-scoped reference pairs (#53)" -m "Split by when the content is needed: the contract keeps what an agent obeys in ordinary work, the reference carries verification, calibration tables, traps and applied instances under paths: frontmatter, and every moved section keeps a pointer heading so file § section citations resolve unchanged. The executor reads the review reference by name at triage; testing.md restates the trace-tag pointer; the cascade-rule reviewer derives its scope instead of enumerating it." -m "Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 11: README and test-case sweep, the full battery, and the draft PR

**Files:**
- Modify: `README.md` § What the kit ships (the tree), § Project conventions (line 357), § Customization (lines 362–375), § Quick start step 2
- Modify: `.claude/skills/scaffold/references/test_cases.md`, `.claude/skills/blueprint/references/test_cases.md`, `.claude/skills/framing/references/test_cases.md` (success-criteria lines)
- Read: `/tmp/p1-baseline.txt`, the Task 9 dry-run table

**Interfaces:**
- Consumes: everything above.
- Produces: the draft PR.

- [ ] **Step 1: README — the tree**

Replace the code block under `## What the kit ships` with an accurate one:
```
.claude/
├── commands/
│   ├── finish.md                      ← Phase 6 executor slash command
│   ├── intake.md                      ← bottom-up entry: external report → /finish-able issue
│   ├── enrich.md                      ← rough-in for one small capability
│   └── pr-respond.md                  ← the PR feedback-loop executor
├── skills/
│   ├── consultation/                  ← Phase 1
│   ├── scaffold/                      ← Phase 2 (+ references/adr-starters/, references/issue-templates/)
│   ├── blueprint/                     ← Phase 3
│   ├── framing/                       ← Phase 4
│   ├── rough-in/                      ← Phase 5 (+ references/finish-command.md, the bundled executor)
│   └── adr-new/                       ← ADR scaffolder (used by blueprint and onward)
├── agents/
│   ├── adr-conformance-reviewer.md    ← dispatched on every review pass
│   ├── logging-discipline-reviewer.md ← same
│   ├── cascade-rule-reviewer.md       ← same
│   └── Explore.md                     ← cheap-tier search exemplar
├── hooks/
│   ├── protect-immutable-adrs.sh      ← hard-deny: edits to existing ADRs
│   ├── protect-lock-files.sh          ← hard-deny: hand edits to lock files
│   ├── protect-main-branch.sh         ← hard-deny: git commit on main
│   ├── guard-pr-state.sh              ← ask-gate: gh pr ready/merge/close/reopen
│   ├── require-knowledge-backend-ok.sh← ask-gate: knowledge-backend MCP writes
│   └── format-on-edit.sh              ← exemplar (unregistered; stanza in settings.json)
├── rules/
│   ├── cbk-conventions.md             ← project conventions — contract half (template; you fill this)
│   ├── cbk-conventions-reference.md   ← its path-scoped reference half
│   ├── orchestration.md               ← model × effort tiering — contract half (template)
│   ├── orchestration-reference.md     ← its path-scoped reference half
│   ├── pr-review.md                   ← review floor, roster, rubric — contract half
│   ├── pr-review-reference.md         ← its path-scoped reference half (calibration tables)
│   ├── testing.md                     ← three-regime testing (path-scoped; stamp the globs)
│   ├── logging.md                     ← structured logging (path-scoped; stamp the glob)
│   ├── simplification.md              ← /simplify contract
│   ├── workflows.md                   ← agent workflow patterns (portable)
│   ├── tooling.md                     ← tool-selection skeleton (template)
│   └── knowledge-backend.md           ← Notion-axis contract (delete with its hook when the axis is none)
├── workflows/
│   └── review-sweep.js                ← find-then-verify review orchestration
└── settings.json                      ← hook registration + plugin/MCP manifest

docs/adr/
├── README.md                          ← ADR index (starter — just ADR-0000)
├── template.md                        ← ADR template
└── 0000-record-architecture-decisions.md  ← meta-ADR establishing immutability (scaffold fills its header)

.github/workflows/
└── adr-immutability-check.yml         ← CI gate enforcing ADR-0000 at raw-git level

CLAUDE.md                              ← kit-level instructions for Claude Code
.mcp.json.example                      ← MCP server config template
```

- [ ] **Step 2: README — conventions, customization, quick start**

Line 357: replace `- The four rules files we ship (testing, logging, simplification, pr-review) — these are referenced by \`/finish\` and the reviewer agents` with `- The twelve files under \`.claude/rules/\`: the contract + reference pairs for conventions, orchestration and review; \`testing.md\` and \`logging.md\` (path-scoped — stamp their globs); \`simplification.md\`; \`workflows.md\` (portable); \`tooling.md\` (a template); and \`knowledge-backend.md\` for the Notion axis. \`/finish\` and the reviewer agents reference them by name.`

In `## Customization`, replace `Three files reliably need editing per project:` with `Four files reliably need editing per project, and scaffold's bootstrap checklist walks the decisions:` and add a fourth numbered item after item 3:
```
4. **`.claude/rules/logging.md` and `.claude/rules/testing.md`** — stamp the `paths:` globs at the top with your project's real extensions; they ship as placeholders and a placeholder glob loads nothing. Then settle a disposition for each template rule (`orchestration.md`, `tooling.md`, and the bracketed entry in `cbk-conventions-reference.md`'s `paths:`): fill, path-scope, or delete — see `cbk-conventions.md` § Rule loading and the instruction budget.
```
Under `Optional further customization`, replace the first bullet's parenthetical `(the kit ships \`adr-conformance-reviewer\` and \`logging-discipline-reviewer\`; add your own for project-specific concerns)` with `(the kit ships \`adr-conformance-reviewer\`, \`logging-discipline-reviewer\` and \`cascade-rule-reviewer\`; add your own for project-specific concerns)`.

In `## Quick start` step 2, replace the comment `# Fill in <TEAM>, <workstream-slug> placeholders and delete the` / `# "This file is a template" callout at the top once you're done.` with `# Fill in <TEAM>, <workstream-slug> placeholders; stamp the paths: globs in` / `# logging.md and testing.md; delete the template callouts once you're done.`

- [ ] **Step 3: Test cases**

Append one success-criterion bullet to the canonical case in each file:
- `scaffold/references/test_cases.md` (the canonical run): `- The bootstrap checklist has four sections; section 4 lists every shipped template and path-scoped rule with a disposition, and prints the always-loaded set first. \`docs/adr/\` exists with ADR-0000's header filled (no \`YYYY-MM-DD\`). The committed \`cascade-rough-in.md\` carries eight headings including \`## Assumptions\`.`
- `blueprint/references/test_cases.md` (the canonical run): `- The phase exit checklist ran: \`CLAUDE.md\` mentions the other docs as backticked paths (no \`@docs/\` line), and every ADR written is indexed in both indexes.`
- `framing/references/test_cases.md` (the canonical first framing): `- Full mode offered no MCP or plugin research track (framing does not research tooling); the frame's Pre-flight checks table carries the exact empty-state string \`No deferred meta-issues from this framing\` when empty.`

- [ ] **Step 4: The full battery**

```bash
awk '/^## Verification/{p=1} p' .claude/rules/cbk-conventions-reference.md | awk '/^```bash/{c=1;next} /^```/{c=0} c' > /tmp/p1-block.sh
bash -e /tmp/p1-block.sh > /tmp/p1-final.txt; echo "suite exit=$?"; grep "always-loaded total" /tmp/p1-final.txt; grep "always-loaded total" /tmp/p1-baseline.txt
for h in .claude/hooks/*.sh; do bash -n "$h" || echo "SYNTAX $h"; done; jq empty .claude/settings.json && echo "settings ok"
diff <(sed -n '/--- BEGIN TEMPLATE/,$p' .claude/skills/rough-in/references/finish-command.md | tail -n +2) .claude/commands/finish.md && echo "finish copies byte-parallel"
diff -rq docs/adr .claude/skills/scaffold/references/adr-starters && echo "adr starters byte-parallel"
grep -rn "@docs/" .claude/ ; echo "no @docs: exit=$?"
git status --short | wc -l
```
Expected: `suite exit=0`; the final always-loaded total is lower than the baseline (record both); no syntax errors; both byte-parallel lines print; `no @docs: exit=1`; the working tree is clean except this task's edits. If the `--- BEGIN TEMPLATE` marker line differs, read `rough-in/SKILL.md` Step 5.5 for the exact marker and adjust the `sed`.

- [ ] **Step 5: Commit**

```bash
git add README.md .claude/skills/scaffold/references/test_cases.md .claude/skills/blueprint/references/test_cases.md .claude/skills/framing/references/test_cases.md
git commit -m "docs(readme): the tree the kit actually ships, twelve rules, the four files to edit; test cases cover the new default paths" -m "Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

- [ ] **Step 6: Review pass, by hand**

Invoke `/simplify` on the branch, then `pr-review-toolkit:review-pr`, then dispatch the three project reviewers (`adr-conformance-reviewer`, `logging-discipline-reviewer`, `cascade-rule-reviewer`) with the changed-path list from `git diff --name-only main...HEAD`. Do **not** run `.claude/workflows/review-sweep.js` (its verify stage is uncapped until P2). Triage every finding per `pr-review.md § Triage rubric`; apply Apply-class items as their own commits; keep Surface items verbatim for the PR body.

- [ ] **Step 7: Open the draft PR**

```bash
git push -u origin feat/harvest-3-p1-self-consistency
gh pr create --draft --title "feat: harvest 3 P1 — the kit stops being wrong about itself, and routes its instruction budget" --body-file /tmp/p1-pr-body.md
```
`/tmp/p1-pr-body.md` carries, in this order: a two-paragraph summary; `Closes #13`, `Closes #14`, `Closes #15`, `Closes #16`, `Closes #30`, `Closes #40`, `Closes #45`, `Closes #53` each on its own line; a table `always-loaded bytes before / after` from `/tmp/p1-baseline.txt` and `/tmp/p1-final.txt`; the six-checks-red → 0 line; the hook dry-run table from Task 9 and the `claude plugin list` result; the review path (`/simplify` and `pr-review-toolkit:review-pr` invoked directly plus the three project reviewers; the shipped sweep deliberately not used, with #10 as the reason); the `## Triage` block with counts per class and the Surface items verbatim; and a `Spec:` line naming `docs/superpowers/specs/2026-09-06-cascade-kit-harvest-3-design.md`. Leave the PR in draft — the operator flips it.

---

## Self-review

**Spec coverage (C1, C2, D17, D18, § Verification):** #13 → Task 2; #14 → Task 1; #15 → Tasks 2–3 (+ README in 11); #16 → Task 4 (+ README in 11); #30 → Tasks 4 (proposal 3) and 5 (proposals 1–2); #40 → Task 6; #45 → Task 7; the four framing defects, backend-named descriptions and count-free wording → Task 8; the axis-none de-wiring rule → stated in Task 3's section and Task 4's disposition table (the mechanical set-removal step ships in P2 with the hook tiers); the axis-mirror check and citation pins → Task 2; the test-case coverage rule → Task 11; #53 → Task 10; the loaded-rules multiplier rationale → Task 3's section; the operator's hook audit → Task 9. Definition-of-done items 1–5 and 7 are exercised by Tasks 2, 10 and 11; item 6 (C11 citations) is P3's.

**Placeholder scan:** every step carries its replacement text or its command with an expected result; the two places that ask the executor to read before replacing (Task 7 Step 2, Task 8 Step 2's reference sweep) name the exact paragraph or grep and the exact replacement or rule.

**Consistency:** the section name `Rule loading and the instruction budget` (Task 3) is what Tasks 10 and 11 cite; the eight-heading list (Task 7) matches `commands/finish.md` Step 2; the pointer format (Task 10) is one line, file plus `§ heading`; the always-loaded loop is identical in Task 0, Task 2's block and Task 4's checklist; `memory: project` / `memory: local` (Task 4) are the scopes the sub-agents page documents.
