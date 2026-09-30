# Harvest 5 — V9: Consistency, citations and small rot

**Scope.** V9 makes the kit's text agree with itself and cite only what exists. It lands #63 (the four executor citations of `CONTRIBUTING.md` § Branches and the `STANDARDS.md` headings the template never emits, repointed at the conventions and the rules; the eight citations of the retired § Deferred meta-issues repointed at § Pre-flight checks, with the block check widened to any citation; the `cascade-rule-reviewer`'s commit-format pointer); #66 item 1 (adr-new's restatement of § ADR relation grains becomes a pointer, and its heading becomes `## Relation grains`); #68 item 1 (D54: any issue a PR closes keys its branch, the Quick reference names both forms and the github-issues key form); #58 R2 (the fifth `/finish` title form, in all four executor files) and R3 (adr-new reads the index's rows and pins no separator); the capstone close-marker sentence in `finish.md` item 8 as a dated observation (#69/body/CAP, handed from V5); every verified consistency and portability finding of the whole-kit review in V9's class, and every unverified one, each re-checked on 2026-09-30 and found holding; D53's bare kit-issue citation sweep with its kit-tree-only check, and the sibling name removed from § Hook authoring; and D62. Trace ids: `#63/body`, `#63/c5901495240/1`, `#63/c5901495240/1/check`, `#63/c5901495240/2`, `#66/body/1`, `#68/body/1a` (the conventions half), `#68/body/1b`, `#58/c5901493591/R2`, `#58/c5901493591/R3`, `#58/c5901493591/residue-1`, `#69/c5859756889/apply-h4/4`, `release/5` (the sweep and the check), `critic/11`, and the review rows listed in § Coverage. By the ownership map it also lands parts of rows other packs carry: `#69/body/CAP` (the executor sentence), `release/9` and `release/10` (V10's pack), and `review/consistency/8` (its `finish.md` citation) and `review/consistency/40` (V3's pack). **It consumes from earlier clusters:** V1's runner and sentinel layout; V3's argument rename (no anchor below contains an argument placeholder, so `$1` → a named argument cannot break one); V2's rewrite of § Hook authoring (V9.21 anchors only on the sibling parenthetical inside it); V5's D59 split (its pointer headings keep `knowledge-backend.md § …` citations resolving) and its hand-off of the capstone sentence; and each owner's own bare-citation rewrites (V2 hooks, V4 `claude-review.yml`, V6 harness, V7 `review-sweep.js`) — V9.21 sweeps whatever is left.

## Conventions for this file

- **Anchors are exact strings** copied from `643f7ff` and dry-run in order on a scratch copy of the kit (each anchor asserted to occur exactly once, every Step 2 run red, every Step 4 run green, 2026-09-30). Line numbers are orientation only. Where an earlier cluster may already have landed the same edit, the step says what to check and when to skip.
- **Checks append at the sentinel, in task order.** Every Step 1 inserts its lines immediately before `echo "verification: kit sub-block complete"`; the block is fail-fast, so the Step 2 output is that task's own message. A kit-tree-only check is guarded `[ -f docs/cbk/scaffold.md ] || …`, the idiom the adr-starters diff already uses.
- **`grep` typed at a prompt.** The block runs in a child `bash -e`, which finds GNU `/usr/bin/grep`; an interactive shell whose `grep` is a function or an alias (this machine's is `ugrep`) does not reach it. Commands this file asks you to type use `command grep` or `git grep`.
- **Byte-parallel pairs.** `commands/finish.md` ↔ `rough-in/references/finish-command.md` (below `--- BEGIN TEMPLATE ---`), `commands/finish-procedure.md` ↔ `rough-in/references/finish-procedure.md`, and — from V9.7 — the four `references/backends.md` copies take every edit identically, in the same commit.
- **Always-loaded ledger (D50).** V9 alone, measured on `643f7ff`: V9.3 +280 bytes (`cbk-conventions.md`), V9.4 −1 (`simplification.md`, 0 when V3.7 has rewritten that line first, as it plans), V9.10 +3, V9.12 +389 — 130,628 → 131,299, net **+671** (+672 after V3.7), inside the 1,359 bytes of headroom V5's plan leaves for V2, V3, V4, V7 and V9 together. V5's D59 split is the lever that pays it; record the delta in the PR body's before/after.
- **Commit messages** carry no CI-skip token (V9.12's subject paraphrases it) and no closing keyword beside an issue number; trace rows are listed under "Trace rows landed:".

### Task V9.1: The executor quartet cites the conventions and admits a meta's child title (#63/body, critic/11, release/9, review/consistency/40, review/consistency/8 (the finish.md citation), #58/c5901493591/R2, #69/c5859756889/apply-h4/4 and release/5 (finish.md:21, finish-command.md:104); D53, D54)

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md`
- Modify: `.claude/commands/finish.md`
- Modify: `.claude/skills/rough-in/references/finish-command.md`
- Modify: `.claude/commands/finish-procedure.md`
- Modify: `.claude/skills/rough-in/references/finish-procedure.md`

**Interfaces:**
- Consumes: the runner and the kit-sub-block sentinel (V1); the executor files after V3's frontmatter and argument edits — none of the anchors below contains `$1` or the frontmatter. If V3 already repointed a `STANDARDS.md` citation under its `review/consistency/40`, that anchor is gone: confirm that `command grep -nE 'STANDARDS[.]md.? § (Step [0-9]|Commit and branch)' .claude/commands/finish-procedure.md` prints nothing for the line in question, and skip that replacement in both copies.
- Produces: the block messages `…: Step 1 does not admit a meta's child as the fifth title form` and `… does not name the same five title forms as the contract's Step 1`; the contract fragment ``or a meta's child `[<slug>:<meta-tag>:R<#>] …`, with`` in both contract copies; `the contract's Step 1 names the same five forms` in both procedure copies; the procedure's branch sentence citing `cbk-conventions.md` § Branch naming with the D54 wording (V10's README customisation paragraph, `review/release/30`, can point at it).

- [ ] **Step 1: Write the check.** In `.claude/rules/cbk-conventions-reference.md` § Verification, insert these lines immediately before `echo "verification: kit sub-block complete"`:

~~~~bash
# The executor quartet (V9.1): /finish admits five title forms, the procedure names the same five, and neither cites a
# CONTRIBUTING or STANDARDS heading the kit's templates do not emit (D53; the literals split themselves).
for f in .claude/commands/finish.md .claude/skills/rough-in/references/finish-command.md; do grep -qF '`[<slug>:<meta-tag>:R<#>] …`, with' "$f" || { echo "$f: Step 1 does not admit a meta's child as the fifth title form"; exit 1; }; done
for f in .claude/commands/finish-procedure.md .claude/skills/rough-in/references/finish-procedure.md; do grep -q 'same five forms' "$f" || { echo "$f does not name the same five title forms as the contract's Step 1"; exit 1; }; done
absent grep -nE 'CONTRIBUTING\.md` § Branche[s]|STANDARDS\.md` § (Step [0-9]|Commit and branch convention[s])' .claude/commands/finish.md .claude/commands/finish-procedure.md .claude/skills/rough-in/references/finish-command.md .claude/skills/rough-in/references/finish-procedure.md
~~~~

- [ ] **Step 2: Run it against the unfixed files — it must fail.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected (the last two lines, then the exit):

~~~~text
.claude/commands/finish.md: Step 1 does not admit a meta's child as the fifth title form
verification: block exited 1
exit=1
~~~~

- [ ] **Step 3: Make the change.** Each replacement is an exact-string edit; each anchor was verified to occur exactly once at `643f7ff` plus the earlier V9 tasks, in text no other cluster's task changes (§ Ownership map) unless this task names the exception. If an anchor is missing, stop and reconcile — never guess.

In each of `.claude/commands/finish.md`, `.claude/skills/rough-in/references/finish-command.md` — identically, replace:

~~~~text
`[<slug>:F<#>:R<#>] …`, `[<slug>:bug] …`, `[<slug>:enh] …` or `[<slug>:meta] …` with `<slug>` a workstream
~~~~

with:

~~~~text
`[<slug>:F<#>:R<#>] …`, `[<slug>:bug] …`, `[<slug>:enh] …`, `[<slug>:meta] …` or a meta's child `[<slug>:<meta-tag>:R<#>] …`, with `<slug>` a workstream
~~~~

In each of `.claude/commands/finish.md`, `.claude/skills/rough-in/references/finish-command.md` — identically, replace:

~~~~text
not this check's — #58, smaller item 1);
~~~~

with:

~~~~text
not this check's — context-builder-kit#58, smaller item 1);
~~~~

In each of `.claude/commands/finish-procedure.md`, `.claude/skills/rough-in/references/finish-procedure.md` — identically, replace:

~~~~text
— or a roughed-in meta `[<workstream-slug>:meta] <intent>` (a cascade / tooling gap that reaches the executor directly or through its `[<slug>:<meta-tag>:R<#>]` children; the contract's Step 1 names the same four forms).
~~~~

with:

~~~~text
— a roughed-in meta `[<workstream-slug>:meta] <intent>` (a cascade / tooling gap that reaches the executor directly), or one of that meta's children `[<workstream-slug>:<meta-tag>:R<M>] <intent>` (the contract's Step 1 names the same five forms).
~~~~

In each of `.claude/commands/finish-procedure.md`, `.claude/skills/rough-in/references/finish-procedure.md` — identically, replace:

~~~~text
- Is there a branch matching this repo's branch naming convention (`<type>/<short-description>`, see `CONTRIBUTING.md` § Branches) that looks like it was created for this issue?
~~~~

with:

~~~~text
- Is there a branch matching this repo's branch naming convention (`<type>/<TEAM>-<N>-<short-slug>`, `cbk-conventions.md` § Branch naming) that looks like it was created for this issue?
~~~~

In each of `.claude/commands/finish-procedure.md`, `.claude/skills/rough-in/references/finish-procedure.md` — identically, replace:

~~~~text
1. **Create the branch** following this repo's naming from `CONTRIBUTING.md` § Branches: `<type>/<short-description>`, with the planning-backend ID embedded in lowercase (e.g., `chore/abc-14-umbrella-init`) — on linear planning the ID substring is what fires the planner's branch auto-link to the issue, so it is load-bearing, not decorative.
~~~~

with:

~~~~text
1. **Create the branch** following `cbk-conventions.md` § Branch naming: `<type>/<TEAM>-<N>-<short-slug>`, with the issue's key embedded in lowercase — the issue number on github-issues (e.g., `feat/42-verifier-trait`), the planner ID on linear (e.g., `chore/abc-14-umbrella-init`), where the ID substring is what fires the planner's branch auto-link to the issue, so it is load-bearing, not decorative. A PR that closes an issue carries that issue's key in its branch; the issue-less form is only for work no issue tracks, never a `/finish` run.
~~~~

In each of `.claude/commands/finish-procedure.md`, `.claude/skills/rough-in/references/finish-procedure.md` — identically, replace:

~~~~text
(`docs/STANDARDS.md` § Commit and branch conventions: "Squash-merge via PR — clean linear history on `main`"), not pre-PR.
~~~~

with:

~~~~text
(the contract, item 5), not pre-PR.
~~~~

In each of `.claude/commands/finish-procedure.md`, `.claude/skills/rough-in/references/finish-procedure.md` — identically, replace:

~~~~text
Project-mandatory per `docs/STANDARDS.md` § Step 4 and `.claude/rules/simplification.md`.
~~~~

with:

~~~~text
Mandatory per `.claude/rules/simplification.md` § When to invoke and `.claude/rules/pr-review.md` § The floor.
~~~~

In each of `.claude/commands/finish-procedure.md`, `.claude/skills/rough-in/references/finish-procedure.md` — identically, replace:

~~~~text
(`docs/STANDARDS.md` § Commit and branch conventions; the squash happens at merge-time on `main`, not pre-PR)
~~~~

with:

~~~~text
(the contract, item 5; the squash happens at merge-time on `main`, not pre-PR)
~~~~

In each of `.claude/commands/finish-procedure.md`, `.claude/skills/rough-in/references/finish-procedure.md` — identically, replace:

~~~~text
the simplify pass is non-negotiable per `docs/STANDARDS.md` § Step 4,
~~~~

with:

~~~~text
the simplify pass is non-negotiable per `.claude/rules/simplification.md` § When to invoke and `pr-review.md` § The floor,
~~~~

- [ ] **Step 4: Run the block — it must pass.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`

Expected (read by content, not position — `N` is the tree's always-loaded total at this point, and no `WARN` or `VIOLATION` line prints):

~~~~text
always-loaded total: N bytes
verification: kit sub-block complete
verification: done
exit=0
~~~~

- [ ] **Step 5: Commit.**

~~~~bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/commands/finish.md \
  .claude/skills/rough-in/references/finish-command.md \
  .claude/commands/finish-procedure.md \
  .claude/skills/rough-in/references/finish-procedure.md
git commit -F- <<'MSG'
fix(executor): V9.1 — /finish cites the conventions and admits a meta's child title

The procedure's branch citations move from a CONTRIBUTING heading a target
may rename to cbk-conventions.md § Branch naming, with the D54 key rule and
the github-issues key form; its STANDARDS citations move to the rules that
own the gates (simplification.md § When to invoke, pr-review.md § The floor)
and to the contract's item 5. Step 1 admits a meta's child as the fifth
title form in all four executor files; the kit's own issue is cited as
context-builder-kit#58. The block pins the five forms and refuses the
retired citations in the executor quartet.

Trace rows landed: #63/body, critic/11, release/9, review/consistency/40,
review/consistency/8 (finish.md citation), #58/c5901493591/R2,
#69/c5859756889/apply-h4/4 and release/5 (the executor pair).

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
~~~~

---

### Task V9.2: A capstone PR names its milestone issue — GitHub rolls no closure up (#69/body/CAP (handed from V5); spec § Settled calls › Recalibration)

The spec settles it: the capstone close-marker sentence goes into `finish.md` item 8 as a dated observation. GitHub's sub-issues page was read raw on 2026-09-30 (`curl -sL 'https://docs.github.com/api/article/body?pathname=/en/issues/tracking-your-work-with-issues/using-issues/adding-sub-issues' | command grep -ci close` prints `0` — the page documents no parent closure), so the closure fact is the public run's observation (you-are-hear, 2026-09-05 to 2026-09-07), written generically. V5's plan hands the whole row to V9, § Sub-issue rollup included (master § Ownership map); Step 3 still checks that anchor first.

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md`
- Modify: `.claude/commands/finish.md`
- Modify: `.claude/skills/rough-in/references/finish-command.md`
- Modify: `.claude/commands/finish-procedure.md`
- Modify: `.claude/skills/rough-in/references/finish-procedure.md`

**Interfaces:**
- Consumes: V5's hand-off of `#69/body/CAP` (its plan's § Coverage and hand-off 7); V9.1's edits to the same four files (none of this task's anchors overlaps them).
- Produces: the sentence `GitHub closes no parent when its sub-issues close` in both contract copies (pinned by the block); the procedure's Step 10 bullet `capstone PR (its milestone's last R-issue)`; `cbk-conventions-reference.md` § Sub-issue rollup naming the owner of each closure.

- [ ] **Step 1: Write the check.** In `.claude/rules/cbk-conventions-reference.md` § Verification, insert these lines immediately before `echo "verification: kit sub-block complete"`:

~~~~bash
# The capstone close marker (V9.2): on github-issues nothing closes a milestone for you, so the executor's contract and
# its procedure both name the framing issue in a capstone PR's close markers.
for f in .claude/commands/finish.md .claude/skills/rough-in/references/finish-command.md; do grep -q 'GitHub closes no parent when its sub-issues close' "$f" || { echo "$f: item 8 does not name the milestone issue in a capstone PR's close markers"; exit 1; }; done
for f in .claude/commands/finish-procedure.md .claude/skills/rough-in/references/finish-procedure.md; do grep -q "capstone PR (its milestone's last R-issue)" "$f" || { echo "$f: Step 10 does not name the capstone close marker"; exit 1; }; done
~~~~

- [ ] **Step 2: Run it against the unfixed files — it must fail.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected (the last two lines, then the exit):

~~~~text
.claude/commands/finish.md: item 8 does not name the milestone issue in a capstone PR's close markers
verification: block exited 1
exit=1
~~~~

- [ ] **Step 3: Make the change.** Each replacement is an exact-string edit; each anchor was verified to occur exactly once at `643f7ff` plus the earlier V9 tasks, in text no other cluster's task changes (§ Ownership map) unless this task names the exception. If an anchor is missing, stop and reconcile — never guess.

The last replacement below is § Sub-issue rollup's GitHub paragraph, which V5's plan hands to V9. First run `command grep -c 'For GitHub-only projects, sub-issue rollup is a Projects v2 view configuration' .claude/rules/cbk-conventions-reference.md`: `1` (the expected case) — apply it; `0` means another commit rewrote the paragraph — skip that one replacement and confirm the new text names the capstone PR as the milestone's closer.

In each of `.claude/commands/finish.md`, `.claude/skills/rough-in/references/finish-command.md` — identically, replace:

~~~~text
The PR is never flipped to ready and never merged by this run; both are the operator's.
~~~~

with:

~~~~text
On github-issues, when this is the milestone's last R-issue (its capstone), the close markers also name the parent `[<slug>:F<#>]` framing issue: GitHub closes no parent when its sub-issues close (observed on a real application, 2026-09-05 to 2026-09-07 — a milestone issue stayed open with every child closed; the sub-issues page, `https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/adding-sub-issues`, read 2026-09-30, documents no parent closure), so a milestone no PR names stays open. The PR is never flipped to ready and never merged by this run; both are the operator's.
~~~~

In each of `.claude/commands/finish-procedure.md`, `.claude/skills/rough-in/references/finish-procedure.md` — identically, replace:

~~~~text
   - Citations to relevant ADRs, `frame-NN.md` milestones, or `.claude/rules/<topic>.md` files the implementation references.
~~~~

with:

~~~~text
   - On github-issues, a capstone PR (its milestone's last R-issue) also names the parent `[<slug>:F<#>]` framing issue in its close markers — GitHub closes no parent when its sub-issues close (the contract, item 8).
   - Citations to relevant ADRs, `frame-NN.md` milestones, or `.claude/rules/<topic>.md` files the implementation references.
~~~~

In `.claude/rules/cbk-conventions-reference.md`, replace:

~~~~text
For GitHub-only projects, sub-issue rollup is a Projects v2 view configuration rather than a closure-cascading setting; the equivalent is just rendering the parent/child tree on a board view.
~~~~

with:

~~~~text
On github-issues, nothing cascades closure up the tree: GitHub closes no parent when its sub-issues close (observed on a real application, 2026-09-05 to 2026-09-07; the sub-issues page documents no parent closure — `https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/adding-sub-issues`, read 2026-09-30), and a Projects v2 board only renders the parent/child tree. So each closure has an owner: the milestone's capstone PR names the `[<slug>:F<#>]` framing issue in its close markers (`commands/finish.md`, item 8), and the operator closes the workstream parent by hand when its last milestone closes.
~~~~

- [ ] **Step 4: Run the block — it must pass.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`

Expected (read by content, not position — `N` is the tree's always-loaded total at this point, and no `WARN` or `VIOLATION` line prints):

~~~~text
always-loaded total: N bytes
verification: kit sub-block complete
verification: done
exit=0
~~~~

- [ ] **Step 5: Commit.**

~~~~bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/commands/finish.md \
  .claude/skills/rough-in/references/finish-command.md \
  .claude/commands/finish-procedure.md \
  .claude/skills/rough-in/references/finish-procedure.md
git commit -F- <<'MSG'
docs(executor): V9.2 — a capstone PR names its milestone issue in its close markers

On github-issues nothing closes a parent when its sub-issues close
(observed on a real application, 2026-09-05 to 2026-09-07; GitHub's
sub-issues page, read 2026-09-30, documents no parent closure). The
contract's item 8 and the procedure's Step 10 now have the milestone's
last R-issue name the [<slug>:F<#>] framing issue in its close markers,
and § Sub-issue rollup names the owner of each closure.

Trace rows landed: #69/body/CAP (handed from V5).

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
~~~~

---

### Task V9.3: The branch rule: any issue a PR closes keys its branch (#68/body/1a (the conventions, scaffold and contributing halves), #68/body/1b, review/consistency/3 (cbk-conventions.md:61); D54, D50)

The hook's remediation comment (`protect-main-branch.sh:79`, `#68/body/1a`'s fourth site) is V2's: V2.4 rewords it to `# work no issue tracks` (and the line above it to `# an issue this PR closes`) in its own commit, and that wording stands — no V9 step re-edits the hook or checks its comment text. The block's existing pins (``grep -q 'short-slug>` with'`` on the conventions, `short-slug` on the hook) stay green: the issue-less sentence keeps ``takes the form `<type>/<short-slug>` with no issue segment`` verbatim. The PR-body statement "operator-directed maintenance; no cascade issue" is kept verbatim — it is true of every issue-less branch.

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md`
- Modify: `.claude/rules/cbk-conventions.md`
- Modify: `.claude/skills/scaffold/references/scaffold_output_template.md`
- Modify: `.claude/skills/blueprint/references/templates/contributing.md`

**Interfaces:**
- Consumes: nothing from other clusters; V2's hook comment lands independently.
- Produces: the bolded sentence **Any issue a PR closes — cascade or not — puts its key in the branch** in § Branch naming; the Quick reference row naming both forms; `the bare issue number on github-issues`. Always-loaded: +280 bytes.

- [ ] **Step 1: Write the check.** In `.claude/rules/cbk-conventions-reference.md` § Verification, insert these lines immediately before `echo "verification: kit sub-block complete"`:

~~~~bash
# The branch rule (D54): a PR that closes any issue keys its branch, the Quick reference names both forms, and the
# github-issues key form is named.
{ grep -q 'Any issue a PR closes' .claude/rules/cbk-conventions.md && grep -q '^| Naming a branch |.*only for work no issue tracks' .claude/rules/cbk-conventions.md && grep -q 'bare issue number on github-issues' .claude/rules/cbk-conventions.md; } || { echo "cbk-conventions.md § Branch naming or its Quick reference row lacks the D54 branch rule"; exit 1; }
~~~~

- [ ] **Step 2: Run it against the unfixed files — it must fail.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected (the last two lines, then the exit):

~~~~text
cbk-conventions.md § Branch naming or its Quick reference row lacks the D54 branch rule
verification: block exited 1
exit=1
~~~~

- [ ] **Step 3: Make the change.** Each replacement is an exact-string edit; each anchor was verified to occur exactly once at `643f7ff` plus the earlier V9 tasks, in text no other cluster's task changes (§ Ownership map) unless this task names the exception. If an anchor is missing, stop and reconcile — never guess.

In `.claude/rules/cbk-conventions.md`, replace:

~~~~text
- `<TEAM>-<N>` is the planning-backend issue ID in lowercase (e.g. `abc-27` if the team prefix is ABC). For markdown-only projects, this collapses to `<short-slug>` only.
~~~~

with:

~~~~text
- `<TEAM>-<N>` is the planning-backend issue key in lowercase (e.g. `abc-27` if the team prefix is ABC; the bare issue number on github-issues). On in-repo-markdown planning, this collapses to `<short-slug>` only.
~~~~

In `.claude/rules/cbk-conventions.md`, replace:

~~~~text
**The issue-less branch.** Operator-directed maintenance that no cascade issue tracks — a dependency bump
~~~~

with:

~~~~text
**The issue-less branch.** Operator-directed maintenance that no issue tracks — a dependency bump
~~~~

In `.claude/rules/cbk-conventions.md`, replace:

~~~~text
as its first line. The scope fence is § Contribution intake:
~~~~

with:

~~~~text
as its first line. **Any issue a PR closes — cascade or not — puts its key in the branch**, so branch, close marker and issue agree; an issue-less branch carries no close marker. The scope fence is § Contribution intake:
~~~~

In `.claude/rules/cbk-conventions.md`, replace:

~~~~text
| Naming a branch | `<type>/<TEAM>-<N>-<short-slug>` |
~~~~

with:

~~~~text
| Naming a branch | `<type>/<TEAM>-<N>-<short-slug>` when the PR closes an issue; `<type>/<short-slug>` only for work no issue tracks |
~~~~

In `.claude/skills/scaffold/references/scaffold_output_template.md`, replace:

~~~~text
issue-less maintenance uses `<type>/<short-description>` with the PR-body statement
"operator-directed maintenance; no cascade issue")
~~~~

with:

~~~~text
maintenance no issue tracks uses `<type>/<short-description>` with the PR-body statement
"operator-directed maintenance; no cascade issue"; a PR that closes any issue keeps its key in the branch)
~~~~

In `.claude/skills/blueprint/references/templates/contributing.md`, replace:

~~~~text
Operator-directed maintenance with no cascade issue uses `<type>/<short-slug>` and opens its PR with the line "operator-directed maintenance; no cascade issue" (`cbk-conventions.md` § Branch naming).
~~~~

with:

~~~~text
A PR that closes any issue carries that issue's key in its branch. Operator-directed maintenance that no issue tracks uses `<type>/<short-slug>` and opens its PR with the line "operator-directed maintenance; no cascade issue" (`cbk-conventions.md` § Branch naming).
~~~~

- [ ] **Step 4: Run the block — it must pass.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`

Expected (read by content, not position — `N` is the tree's always-loaded total at this point, and no `WARN` or `VIOLATION` line prints):

~~~~text
always-loaded total: N bytes
verification: kit sub-block complete
verification: done
exit=0
~~~~

Budget (D50): run `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | command grep '^always-loaded total'` on the tree before Step 3 and again now; the second total is exactly 280 bytes higher than the first (`cbk-conventions.md` grows from 30,058 to 30,338 bytes on `643f7ff`). Record both in the PR body's before/after ledger.

- [ ] **Step 5: Commit.**

~~~~bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/rules/cbk-conventions.md \
  .claude/skills/scaffold/references/scaffold_output_template.md \
  .claude/skills/blueprint/references/templates/contributing.md
git commit -F- <<'MSG'
docs(conventions): V9.3 — any issue a PR closes keys its branch (D54)

§ Branch naming says the issue's key rides the branch whenever a PR closes
an issue, cascade issue or not, and names the github-issues key form (the
bare number); the issue-less form is only for work no issue tracks. The
Quick reference row names both forms; the scaffold output template and the
contributing template echo the rule. Always-loaded +280 bytes.

Trace rows landed: #68/body/1a (conventions, scaffold, contributing),
#68/body/1b, review/consistency/3 (cbk-conventions.md:61).

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
~~~~

---

### Task V9.4: STANDARDS citations name headings the blueprint template emits (release/9 (the citations outside the executor); D53)

The blueprint `standards.md` template emits Git Workflow, Testing Requirements, PR Review Checklist, CI Pipeline and Unenforced invariants (`command grep -n '^## ' .claude/skills/blueprint/references/templates/standards.md`). Four kit sentences cite headings it never emits. The two hedged cites (`pr-review.md:3`, `simplification.md:3` — "or wherever your project documents the equivalent gate") stay, as `release/9` recommends.

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md`
- Modify: `.claude/skills/rough-in/references/plan-mode-prompts.md`
- Modify: `.claude/rules/testing.md`
- Modify: `.claude/rules/pr-review-reference.md`
- Modify: `.claude/rules/simplification.md`

**Interfaces:**
- Consumes: V3.7's rewrite of `simplification.md:45` (its `review/consistency/40` part), when it has landed; V5's edit to `simplification.md` (its Plugin section) and V7's to `pr-review-reference.md` (§ Anti-patterns, § Authoring) do not touch these sentences.
- Produces: the block's `absent` check over `.claude/` for the four non-emitted `STANDARDS.md` headings. Always-loaded: −1 byte (`simplification.md`) or 0 when V3.7 landed that line.

- [ ] **Step 1: Write the check.** In `.claude/rules/cbk-conventions-reference.md` § Verification, insert these lines immediately before `echo "verification: kit sub-block complete"`:

~~~~bash
# STANDARDS citations name headings the blueprint template emits (D53): Git Workflow, Testing Requirements, PR Review
# Checklist, CI Pipeline, Unenforced invariants — never a heading a target's STANDARDS.md does not have.
absent grep -rnE 'STANDARDS\.md`? § (Testing philosoph[y]|PR feedback loo[p]|PR review proces[s]|Commit and branch convention[s])' .claude/
~~~~

- [ ] **Step 2: Run it against the unfixed files — it must fail.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected (the last two lines, then the exit):

~~~~text
VIOLATION (matched above): grep -rnE STANDARDS\.md`? § (Testing philosoph[y]|PR feedback loo[p]|PR review proces[s]|Commit and branch convention[s]) .claude/
verification: block exited 1
exit=1
~~~~

Above those lines the run lists the offending lines — at `643f7ff` four: `pr-review-reference.md:142`, `simplification.md:45`, `testing.md:255`, `plan-mode-prompts.md:60`. V3.7 rewrites `simplification.md:45` before V9 runs (its part of `review/consistency/40`), so that line is usually gone by now.

- [ ] **Step 3: Make the change.** Each replacement is an exact-string edit; each anchor was verified to occur exactly once at `643f7ff` plus the earlier V9 tasks, in text no other cluster's task changes (§ Ownership map) unless this task names the exception. If an anchor is missing, stop and reconcile — never guess.

Two of these sentences may already be fixed by another cluster. V3.7 rewrites `simplification.md:45` to ``(`/pr-respond`)``: if ``command grep -c 'see your `docs/STANDARDS.md` § PR feedback loop' .claude/rules/simplification.md`` prints `0`, skip the `simplification.md` replacement below. V3 hands `pr-review-reference.md:142` to V7: if `command grep -c '§ PR review process points here' .claude/rules/pr-review-reference.md` prints `0`, V7 landed it — skip that replacement. Every other replacement applies as written.

In `.claude/skills/rough-in/references/plan-mode-prompts.md`, replace:

~~~~text
`docs/STANDARDS.md § Testing philosophy`
~~~~

with:

~~~~text
`docs/STANDARDS.md § Testing Requirements`
~~~~

In `.claude/rules/testing.md`, replace:

~~~~text
The corresponding entry in `docs/STANDARDS.md` § Testing philosophy points here
~~~~

with:

~~~~text
The corresponding entry in `docs/STANDARDS.md` § Testing Requirements points here
~~~~

In `.claude/rules/pr-review-reference.md`, replace:

~~~~text
The corresponding entry in `docs/STANDARDS.md` § PR review process points here
~~~~

with:

~~~~text
The corresponding entry in `docs/STANDARDS.md` § PR Review Checklist points here
~~~~

In `.claude/rules/simplification.md`, replace:

~~~~text
address that first via the PR feedback loop (see your `docs/STANDARDS.md` § PR feedback loop).
~~~~

with:

~~~~text
address that first via the PR feedback loop (`/pr-respond`, `.claude/commands/pr-respond.md`).
~~~~

- [ ] **Step 4: Run the block — it must pass.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`

Expected (read by content, not position — `N` is the tree's always-loaded total at this point, and no `WARN` or `VIOLATION` line prints):

~~~~text
always-loaded total: N bytes
verification: kit sub-block complete
verification: done
exit=0
~~~~

Budget (D50): run `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | command grep '^always-loaded total'` on the tree before Step 3 and again now; if you applied the `simplification.md` replacement the second total is exactly 1 byte lower, and if V3.7 had already rewritten that line the two are equal. Record both in the PR body's before/after ledger.

- [ ] **Step 5: Commit.**

~~~~bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/skills/rough-in/references/plan-mode-prompts.md \
  .claude/rules/testing.md \
  .claude/rules/pr-review-reference.md \
  .claude/rules/simplification.md
git commit -F- <<'MSG'
docs(rules): V9.4 — STANDARDS citations name headings the template emits

testing.md, pr-review-reference.md and plan-mode-prompts.md cited STANDARDS
headings the blueprint template never emits (Testing philosophy, PR review
process); they now cite Testing Requirements and PR Review Checklist.
simplification.md's anti-pattern points at /pr-respond instead of a
STANDARDS "PR feedback loop" heading. The block refuses the four retired
heading names anywhere under .claude/.

Trace rows landed: release/9 (citations outside the executor).

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
~~~~

---

### Task V9.5: Section citations that resolve: § Pre-flight checks, the PR-title pointer, the event-entry shape (#63/c5901495240/1, #63/c5901495240/1/check, #63/c5901495240/2, review/consistency/47 (the frame-template and inheritance cites); D53, D51)

The third dangling cite in `review/consistency/47` — the reviewer's `knowledge-backend.md` § "no cascade-artifact / ADR mirroring" — is V3's `review/claude-code/59` on the same line 45; this task edits only line 42 of that file. The two `cascade-meta.md` copies (scaffold, framing) take identical edits. A target's committed `.github/ISSUE_TEMPLATE/cascade-meta.md` is a byte copy of scaffold's, so the project sub-block gains a check that fires until the target re-copies it — V10's v1.0.0 Sync notes name that.

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md`
- Modify: `.claude/skills/scaffold/references/issue-templates/cascade-meta.md`
- Modify: `.claude/skills/framing/references/issue-templates/cascade-meta.md`
- Modify: `.claude/skills/framing/references/templates/frame-output-template.md`
- Modify: `.claude/skills/framing/references/planning-backend-commit.md`
- Modify: `.claude/skills/rough-in/references/inheritance.md`
- Modify: `.claude/agents/cascade-rule-reviewer.md`

**Interfaces:**
- Consumes: nothing; V3's line-45 edit is independent.
- Produces: the widened retired-section check `absent grep -rnE "Deferred meta-issue[s]" .claude/skills/` (kit sub-block) and the project-sub-block `.github/ISSUE_TEMPLATE/cascade-meta.md` check; the Sync note V10 writes ("re-copy `.github/ISSUE_TEMPLATE/cascade-meta.md` from scaffold's `references/issue-templates/`").

- [ ] **Step 1: Write the check.** In `.claude/rules/cbk-conventions-reference.md` § Verification, insert these lines immediately before `echo "verification: kit sub-block complete"`:

~~~~bash
# The retired frame section (context-builder-kit#63): frames emit § Pre-flight checks, and no skill cites the old section
# by its plural name — any citation, not only a heading (the singular "Deferred meta-issue" is an issue type and stays).
absent grep -rnE "Deferred meta-issue[s]" .claude/skills/
# Section pointers that resolve: the reviewer's PR-title pointer names a heading the conventions have, and the frame
# template cites the event-entry shape in the rough-in skill, the one file that carries it.
absent grep -n "Closes-keyword conventions / commit forma[t]" .claude/agents/cascade-rule-reviewer.md
grep -q "the rough-in skill's \`references/planning-backend-commit.md\`" .claude/skills/framing/references/templates/frame-output-template.md || { echo "frame-output-template.md cites the event-entry shape in a file that lacks it"; exit 1; }
~~~~

In `.claude/rules/cbk-conventions-reference.md`, insert these three lines, followed by one blank line, immediately before the line `  echo "verification: project sub-block complete"` (two-space indent; the blank line already above that echo now sits above the new comment):

~~~~bash
  # A committed cascade-meta issue template is a byte copy of scaffold's: it cites § Pre-flight checks, never the retired
  # plural section (context-builder-kit#63 — re-copy it from the kit when this fires).
  [ ! -f .github/ISSUE_TEMPLATE/cascade-meta.md ] || absent grep -n "Deferred meta-issue[s]" .github/ISSUE_TEMPLATE/cascade-meta.md
~~~~

- [ ] **Step 2: Run it against the unfixed files — it must fail.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected (the last two lines, then the exit):

~~~~text
VIOLATION (matched above): grep -rnE Deferred meta-issue[s] .claude/skills/
verification: block exited 1
exit=1
~~~~

Above those lines the run lists the seven lines that carry the eight citations (lines 20 and 99 of each `cascade-meta.md`, `frame-output-template.md:71`, `planning-backend-commit.md:40` with two, `inheritance.md:136`).

- [ ] **Step 3: Make the change.** Each replacement is an exact-string edit; each anchor was verified to occur exactly once at `643f7ff` plus the earlier V9 tasks, in text no other cluster's task changes (§ Ownership map) unless this task names the exception. If an anchor is missing, stop and reconcile — never guess.

In each of `.claude/skills/scaffold/references/issue-templates/cascade-meta.md`, `.claude/skills/framing/references/issue-templates/cascade-meta.md` — identically, replace:

~~~~text
Rough-in's mandatory pre-flight check reads the Deferred meta-issues
table from frame-NN.md
~~~~

with:

~~~~text
Rough-in's mandatory pre-flight check reads the Pre-flight checks
table from frame-NN.md
~~~~

In each of `.claude/skills/scaffold/references/issue-templates/cascade-meta.md`, `.claude/skills/framing/references/issue-templates/cascade-meta.md` — identically, replace:

~~~~text
- [`docs/cbk/frame-NN.md` § Deferred meta-issues](../blob/main/docs/cbk/frame-NN.md)
~~~~

with:

~~~~text
- [`docs/cbk/frame-NN.md` § Pre-flight checks](../blob/main/docs/cbk/frame-NN.md)
~~~~

In `.claude/skills/framing/references/templates/frame-output-template.md`, replace:

~~~~text
distinct from Open questions (deferred forward) and Deferred meta-issues
(structural blockers tracked separately).]
~~~~

with:

~~~~text
distinct from Open questions (deferred forward) and Pre-flight checks
(structural blockers tracked separately).]
~~~~

In `.claude/skills/framing/references/templates/frame-output-template.md`, replace:

~~~~text
  skill — see `references/planning-backend-commit.md` § "The README.md event
  entry shape" for the discipline-not-version-history rule.]
~~~~

with:

~~~~text
  skill — see the rough-in skill's `references/planning-backend-commit.md`
  § "The README.md event entry shape" for the discipline-not-version-history rule.]
~~~~

In `.claude/skills/framing/references/planning-backend-commit.md`, replace:

~~~~text
from the row in `frame-NN.md` § Deferred meta-issues —
~~~~

with:

~~~~text
from the row in `frame-NN.md` § Pre-flight checks —
~~~~

In `.claude/skills/framing/references/planning-backend-commit.md`, replace:

~~~~text
cites `frame-NN.md § Deferred meta-issues`.
~~~~

with:

~~~~text
cites `frame-NN.md § Pre-flight checks`.
~~~~

In `.claude/skills/rough-in/references/inheritance.md`, replace:

~~~~text
see `references/backends.md` § Deferred meta-issues for
~~~~

with:

~~~~text
see `references/backends.md` § Pre-flight checks for
~~~~

In `.claude/agents/cascade-rule-reviewer.md`, replace:

~~~~text
`cbk-conventions.md` § Closes-keyword conventions / commit format
~~~~

with:

~~~~text
`cbk-conventions.md` § Closes-keyword conventions (PR titles are Conventional Commits)
~~~~

- [ ] **Step 4: Run the block — it must pass.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`

Expected (read by content, not position — `N` is the tree's always-loaded total at this point, and no `WARN` or `VIOLATION` line prints):

~~~~text
always-loaded total: N bytes
verification: kit sub-block complete
verification: done
exit=0
~~~~

Then prove the project-sub-block check on a simulated target (the kit tree skips it):

```bash
t=$(mktemp -d) && cp -a . "$t/kit" && cd "$t/kit" && rm -rf docs/superpowers && mkdir -p docs/cbk .github/ISSUE_TEMPLATE && printf '# scaffold\n' > docs/cbk/scaffold.md
for f in $(command grep -l '^paths:' .claude/rules/*.md); do awk '/^---$/{c++} { if (c==1 && $0 ~ /</) { print "  - \"src/**\""; next } print }' "$f" > "$f.tmp" && mv "$f.tmp" "$f"; done
git show 643f7ff:.claude/skills/scaffold/references/issue-templates/cascade-meta.md > .github/ISSUE_TEMPLATE/cascade-meta.md
bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2
cp .claude/skills/scaffold/references/issue-templates/cascade-meta.md .github/ISSUE_TEMPLATE/ && bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"
cd - >/dev/null && rm -rf "$t"
```

Expected: first, from the positional red run, `VIOLATION (matched above): grep -n Deferred meta-issue[s] .github/ISSUE_TEMPLATE/cascade-meta.md` and `verification: block exited 1` (the failing check's line really is second-to-last); then, read by content, `always-loaded total: N bytes`, `verification: kit sub-block complete`, `verification: project sub-block complete`, `verification: done` and `exit=0`, with no `VIOLATION` line. If an earlier project check fires first on this unfilled scratch target (another cluster's bracketed slot), fill that slot in the scratch copy and re-run.

- [ ] **Step 5: Commit.**

~~~~bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/skills/scaffold/references/issue-templates/cascade-meta.md \
  .claude/skills/framing/references/issue-templates/cascade-meta.md \
  .claude/skills/framing/references/templates/frame-output-template.md \
  .claude/skills/framing/references/planning-backend-commit.md \
  .claude/skills/rough-in/references/inheritance.md \
  .claude/agents/cascade-rule-reviewer.md
git commit -F- <<'MSG'
docs(skills): V9.5 — citations name sections that exist

The eight prose citations of the retired frame section cite § Pre-flight
checks, the heading frames emit; the block's retired-section check widens
from the heading to any citation, and a target's committed cascade-meta
issue template is checked in the project sub-block. The reviewer's PR-title
pointer drops the "commit format" tail the conventions never had, and the
frame template cites the event-entry shape in the rough-in skill, the one
file that carries it.

Trace rows landed: #63/c5901495240/1, #63/c5901495240/1/check,
#63/c5901495240/2, review/consistency/47 (frame template, inheritance).

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
~~~~

---

### Task V9.6: adr-new points at § ADR relation grains and reads the index's own form (#66/body/1, #58/c5901493591/residue-1, #58/c5901493591/R3, #69/c5859756889/apply-h4/4 and release/5 (adr-new:51); D53; D39 (harvest 4) completed)

The two paragraphs only the skill carried (non-decision-clause refines, honest-disclosure refines) move into `cbk-conventions-reference.md` § ADR relation grains first — framing's procedure cites the second — then the skill's section shrinks to a pointer plus its own mechanics and is retitled `## Relation grains`. The reference half is path-scoped, so the move costs no always-loaded bytes; the skill drops from 10,632 to 7,949 bytes. The block's existing pins stay green: `Extends:` in adr-new, and the `Configurability summar[y]\|§ Open question[s]` absence.

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md`
- Modify: `.claude/skills/adr-new/SKILL.md`
- Modify: `.claude/skills/framing/references/procedure.md`

**Interfaces:**
- Consumes: nothing from other clusters.
- Produces: `## Relation grains` in `adr-new/SKILL.md` (a target's citation of "adr-new § Refines vs Supersedes" must repoint — V10's Sync notes); the two moved paragraphs, headed `**Refines may target non-decision clauses.**` and `**Honest-disclosure refines.**`, in § ADR relation grains; the R3 wording in adr-new Step 3 and in the reference half.

- [ ] **Step 1: Write the check.** In `.claude/rules/cbk-conventions-reference.md` § Verification, insert these lines immediately before `echo "verification: kit sub-block complete"`:

~~~~bash
# adr-new points at § ADR relation grains instead of restating it (context-builder-kit#66): the skill keeps its own
# mechanics under ## Relation grains, the old heading is cited nowhere, and the two paragraphs only the skill carried
# now live in the reference half.
grep -q '^## Relation grains' .claude/skills/adr-new/SKILL.md || { echo "adr-new/SKILL.md lacks ## Relation grains (the pointer to § ADR relation grains)"; exit 1; }
absent grep -rn "Refines vs Supersede[s]" .claude/
{ grep -q 'Honest-disclosure refines' .claude/rules/cbk-conventions-reference.md && grep -q 'Refines may target non-decision clauses' .claude/rules/cbk-conventions-reference.md; } || { echo "§ ADR relation grains lacks the non-decision-clause or honest-disclosure refine"; exit 1; }
~~~~

- [ ] **Step 2: Run it against the unfixed files — it must fail.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected (the last two lines, then the exit):

~~~~text
adr-new/SKILL.md lacks ## Relation grains (the pointer to § ADR relation grains)
verification: block exited 1
exit=1
~~~~

- [ ] **Step 3: Make the change.** Each replacement is an exact-string edit; each anchor was verified to occur exactly once at `643f7ff` plus the earlier V9 tasks, in text no other cluster's task changes (§ Ownership map) unless this task names the exception. If an anchor is missing, stop and reconcile — never guess.

The first replacement is the whole section from `## Refines vs Supersedes vs Extends` to the end of `adr-new/SKILL.md` (4,975 bytes at `643f7ff`); the file's two trailing newlines are outside the anchor and stay. Apply the reference-half insertion (the third-to-last replacement) before or after it — the anchors are independent.

In `.claude/skills/adr-new/SKILL.md`, replace:

~~~~text
## Refines vs Supersedes vs Extends

**See also** `docs/adr/corrections.md` — a wrong *claim* in an accepted ADR (a citation, a figure, an attribution, a formula) is none of these grains; it is an append-only register entry, and the ADR stays as written.

A new ADR connects to an existing one through one of the relationships below (`Supersedes:`, `Refines:`, `Extends:`, and the clause-scoped form of the first); a `Promotes:` slot connects to a frozen corpus, not to an ADR. All are header fields and all preserve the parent's immutability — none ever edits the parent file.

- **`Supersedes: ADR-NNNN`** — the new ADR *replaces* the parent's decision. The parent's status becomes `Superseded by ADR-MMMM`; new code follows the new ADR. This is the relationship the interactive **Supersedes?** input captures, and the one Step 3's index-marking handles.
- **`Refines: ADR-NNNN (Dn, …)`** — the new ADR *clause-level-clarifies or narrows* a specific decision `Dn` in the parent **without invalidating it**. The parent stays `Accepted`; both parent and child are consulted when evaluating conformance. Use this when implementation reveals that an accepted clause was written too generally and needs a scoped reading (e.g. "this rule applies only to <entity-type>"), not a reversal.
- **`Promotes: <corpus path § heading>`** — the decision is lifted from a frozen pre-cascade corpus (consultation's frozen-corpus ingestion; `cbk-conventions.md` § Multi-surface facts names the corpus + errata pair). The corpus entry stays as written and the ADR becomes the decision's record home; the slot is the back-pointer. Not a relation to another ADR, so it carries no grain.

**Clause-scoped supersession.** Supersession can also target a single clause rather than a whole ADR: `Supersedes: ADR-NNNN Dn` reverses only decision `Dn` of the parent while the parent's other clauses stand. The parent's status stays `Accepted` (it is not wholly superseded); the child's index row names the specific clause it replaces.

**Header narrative.** A `Refines:` header carries more than the pointer: for each named parent clause, one or two sentences stating what is narrowed or additionally sanctioned and what stays binding, ending with an explicit "all parents stay Accepted and immutable" line. A bare `Refines: ADR-NNNN (D2)` forces every future reader to re-derive the delta; the clause-level narrative is what makes the chain readable at conformance-check speed.

**`Extends: ADR-NNNN (Dn, …)`** — the new ADR *adds an obligation beside* a parent clause that stays satisfied as written; the parent is not narrowed and stays `Accepted`. **The disambiguation test:** a child that removes a permitted reading of the parent clause is a Refine; one that adds an obligation beside a clause that stays satisfied is an Extend. The header narrative is the same as a refine's — per clause, what is added and what stays binding — and the asymmetry is the same: no back-pointer on the parent.

**Refines may target non-decision clauses.** The over-general text isn't always a `Dn` decision — a refine can scope a parent's `§ Consequences` (or another named section) when that's where the statement being narrowed lives: `Refines: ADR-NNNN (§ Consequences — <what>)`. The same rules apply: parent untouched, both consulted.

**Honest-disclosure refines.** When execution falsifies a rule an earlier ADR pre-committed to (a threshold, a protocol, an expected outcome), the deviation lands as a refining ADR whose body discloses all three parts — what was pre-committed, what reality showed, and what changes — never as a silent re-interpretation. The disclosure is the point: a pre-commitment only disciplines future decisions if deviations from it are visibly recorded.

**How the skill handles each:**

- Add a **Refines?** input alongside the Supersedes? input (Inputs, above) — if yes, capture the parent number and the specific decision clauses in `ADR-NNNN (Dn, …)` form.
- In Step 2, fill the `Refines:` field (or the clause-scoped `Supersedes:` field) in the new ADR's header.
- In Step 3, add the child's index row naming its `Refines:`, `Extends:` (or clause-scoped supersession) target. **A refined parent gains no back-pointer and no status change** — it stays `Accepted`, and discoverability comes from the child's header field plus the child's index row. Only a *whole-ADR* supersession flips the parent's index status to `Superseded by ADR-NNNN`; a pure refine (or a clause-scoped supersede) leaves the parent `Accepted`.

**Reviewers must follow the `Refines:` and `Extends:` chains.** When an ADR-conformance check finds an ADR that intersects a diff, it also loads any ADR that names that ADR in a `Refines:`, `Extends:` (or clause-scoped `Supersedes:`) field and applies the child's clauses — an extender can fail a diff the parent passes. A parent read in isolation — without its refiners — yields the pre-narrowing, too-general reading.
~~~~

with:

~~~~text
## Relation grains

The grains — whole and clause-scoped Supersede, Refine, Extend, Promote — their disambiguation test, the refines that scope a non-decision clause or disclose a falsified pre-commitment, and the rule that reviewers follow the `Refines:` and `Extends:` chains are stated once, in `.claude/rules/cbk-conventions-reference.md` § ADR relation grains; read it before filling a relation slot. **See also** `docs/adr/corrections.md` — a wrong *claim* in an accepted ADR (a citation, a figure, an attribution, a formula) is none of these grains; it is an append-only register entry, and the ADR stays as written.

**Header narrative.** A `Refines:` or `Extends:` header carries more than the pointer: for each named parent clause, one or two sentences stating what is narrowed, added or additionally sanctioned and what stays binding, ending with an explicit "all parents stay Accepted and immutable" line. A bare `Refines: ADR-NNNN (D2)` forces every future reader to re-derive the delta; the clause-level narrative is what makes the chain readable at conformance-check speed.

**How the skill handles each:**

- The Inputs above name the parent: for **Refines?** and **Extends?** with its clauses in `ADR-NNNN (Dn, …)` form, for **Supersedes?** the whole ADR or one clause (`ADR-NNNN Dn`), and for **Promotes?** the corpus path and heading.
- Step 2 fills the matching header slot — `Supersedes:` (whole or clause-scoped), `Refines:`, `Extends:` or `Promotes:` — with the narrative above, and deletes the unused lines.
- Step 3 adds the child's index row naming its target. **A refined or extended parent gains no back-pointer and no status change** — it stays `Accepted`, and discoverability comes from the child's header field plus the child's index row. Only a *whole-ADR* supersession flips the parent's index status to `Superseded by ADR-NNNN`; a clause-scoped supersession annotates the parent's row in the index's own form (Step 3).
~~~~

In `.claude/skills/adr-new/SKILL.md`, replace:

~~~~text
same form (§ Refines vs Supersedes has the disambiguation test).
~~~~

with:

~~~~text
same form (`cbk-conventions-reference.md` § ADR relation grains has the disambiguation test).
~~~~

In `.claude/skills/adr-new/SKILL.md`, replace:

~~~~text
two real indexes already contradicted the pinned form two different ways (#58, 2026-09-07 comment).
~~~~

with:

~~~~text
two real indexes already contradicted the pinned form two different ways (context-builder-kit#58, 2026-09-07 comment).
~~~~

In `.claude/skills/adr-new/SKILL.md`, replace:

~~~~text
A clause-scoped supersession annotates the parent's row (`Accepted · Dn superseded by ADR-${NNNN}`); a refine or extend leaves the parent's row as it was.
~~~~

with:

~~~~text
A clause-scoped supersession annotates the parent's row in the form this index already uses for one — read the rows first; an index can hold more than one form (the starter's is `Accepted · Dn superseded by ADR-${NNNN}` in the Status cell; a parent whose title already carries a relation parenthetical may take it inside that parenthetical), and the separator is the index's. A refine or extend leaves the parent's row as it was.
~~~~

In `.claude/rules/cbk-conventions-reference.md`, replace:

~~~~text
the child's index row names the specific clause it replaces, and the parent's index row is annotated (`Accepted · Dn superseded by ADR-MMMM`) while the parent file stays untouched.
~~~~

with:

~~~~text
the child's index row names the specific clause it replaces, and the parent's index row is annotated in the index's own form — the kit's starter index writes `Accepted · Dn superseded by ADR-MMMM` in the Status cell, and a target's index sets its own cell and separator (`adr-new` reads the existing rows first) — while the parent file stays untouched.
~~~~

In `.claude/rules/cbk-conventions-reference.md`, replace:

~~~~text
and the status cell carries grain and parent inline (`Accepted · Extends ADR-0003 (D1)`).
~~~~

with:

~~~~text
and in the kit's starter index the Status cell carries grain and parent inline (`Accepted · Extends ADR-0003 (D1)`); a target's index keeps its own form.
~~~~

In `.claude/rules/cbk-conventions-reference.md`, replace:

~~~~text
A wrong **claim** inside an accepted ADR
~~~~

with:

~~~~text
**Refines may target non-decision clauses.** The over-general text isn't always a `Dn` decision — a refine can scope a parent's `§ Consequences` (or another named section) when that's where the statement being narrowed lives: `Refines: ADR-NNNN (§ Consequences — <what>)`. The same rules apply: parent untouched, both consulted.

**Honest-disclosure refines.** When execution falsifies a rule an earlier ADR pre-committed to (a threshold, a protocol, an expected outcome), the deviation lands as a refining ADR whose body discloses all three parts — what was pre-committed, what reality showed, and what changes — never as a silent re-interpretation. The disclosure is the point: a pre-commitment only disciplines future decisions if deviations from it are visibly recorded.

A wrong **claim** inside an accepted ADR
~~~~

In `.claude/skills/framing/references/procedure.md`, replace:

~~~~text
(see the adr-new skill § Refines vs Supersedes)
~~~~

with:

~~~~text
(`cbk-conventions-reference.md` § ADR relation grains › Honest-disclosure refines)
~~~~

- [ ] **Step 4: Run the block — it must pass.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`

Expected (read by content, not position — `N` is the tree's always-loaded total at this point, and no `WARN` or `VIOLATION` line prints):

~~~~text
always-loaded total: N bytes
verification: kit sub-block complete
verification: done
exit=0
~~~~

- [ ] **Step 5: Commit.**

~~~~bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/skills/adr-new/SKILL.md \
  .claude/skills/framing/references/procedure.md
git commit -F- <<'MSG'
docs(adr-new): V9.6 — point at § ADR relation grains; read the index's own form

adr-new's § Refines vs Supersedes vs Extends restated the reference half's
§ ADR relation grains; it becomes ## Relation grains, a pointer plus the
skill's own mechanics (header narrative, which step fills which slot). The
two paragraphs only the skill carried move into § ADR relation grains, and
framing's procedure cites them there. Step 3 and the reference half stop
pinning the starter index's separator: the executor reads the rows first,
and a target's index keeps its own cell and separator.

Trace rows landed: #66/body/1, #58/c5901493591/residue-1,
#58/c5901493591/R3, #69/c5859756889/apply-h4/4 and release/5 (adr-new:51).

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
~~~~

---

### Task V9.7: backends.md: the board-automation rail dated, the progress field sourced, the four copies diffed (review/portability/34; D53 (dated rails); the master plan's byte-parallel list)

Facts read raw on 2026-09-30 and matched with `grep -F`:
- `curl -sL 'https://docs.github.com/api/article/body?pathname=/en/issues/tracking-your-work-with-issues/using-issues/adding-sub-issues'` contains `Parent issues and sub-issue progress is also available in your projects, allowing you to build views, filter, and group by parent issue`.
- `curl -sL 'https://docs.github.com/api/article/body?pathname=/en/issues/planning-and-tracking-with-projects/automating-your-project/using-the-built-in-automations'` contains `two workflows are enabled by default` (closed → Done, merged → Done; nothing keyed on a parent or on progress).
- `curl -sL https://docs.github.com/public/fpt/schema.docs.graphql` contains `subIssuesSummary: SubIssuesSummary!` on `type Issue`, and `type SubIssuesSummary` has `completed`, `total` and `percentCompleted` — there is no `subIssueProgress` field, so the two automation bullets are corrected to the schema's name.

This task lands the four-copy diff first, so V9.8 and V9.10's edits to the same copies are pinned.

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md`
- Modify: `.claude/skills/scaffold/references/backends.md`
- Modify: `.claude/skills/blueprint/references/backends.md`
- Modify: `.claude/skills/framing/references/backends.md`
- Modify: `.claude/skills/rough-in/references/backends.md`
- Modify: `.claude/skills/framing/references/planning-backend-commit.md`

**Interfaces:**
- Consumes: scaffold's SKILL.md § The detection matrix and its 2026-09-06 observation (unchanged).
- Produces: the kit-sub-block `cmp -s` of the three copies against scaffold's (message `…/references/backends.md drifted from scaffold's copy (the four copies are byte-identical)`), which V9.8 and V9.10 rely on; the `absent` check for the undated rail and the non-existent field.

- [ ] **Step 1: Write the check.** In `.claude/rules/cbk-conventions-reference.md` § Verification, insert these lines immediately before `echo "verification: kit sub-block complete"`:

~~~~bash
# The four backends.md copies are one file in four skills: byte-identical, so a restamp lands in all four or fails here.
for s in blueprint framing rough-in; do cmp -s .claude/skills/scaffold/references/backends.md .claude/skills/$s/references/backends.md || { echo "$s/references/backends.md drifted from scaffold's copy (the four copies are byte-identical)"; exit 1; }; done
# Its board-automation rail is dated, and no skill names a sub-issue field the GraphQL schema lacks.
absent grep -rn "as of current cascade versio[n]\|subIssueProgres[s]" .claude/skills/
~~~~

- [ ] **Step 2: Run it against the unfixed files — it must fail.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected (the last two lines, then the exit):

~~~~text
VIOLATION (matched above): grep -rn as of current cascade versio[n]\|subIssueProgres[s] .claude/skills/
verification: block exited 1
exit=1
~~~~

- [ ] **Step 3: Make the change.** Each replacement is an exact-string edit; each anchor was verified to occur exactly once at `643f7ff` plus the earlier V9 tasks, in text no other cluster's task changes (§ Ownership map) unless this task names the exception. If an anchor is missing, stop and reconcile — never guess.

In each of `.claude/skills/scaffold/references/backends.md`, `.claude/skills/blueprint/references/backends.md`, `.claude/skills/framing/references/backends.md`, `.claude/skills/rough-in/references/backends.md` — identically, replace:

~~~~text
**The sub-issue progress field is the load-bearing primitive for parent-state rollup.** GitHub Projects v2 added native sub-issue progress tracking as part of the sub-issue GA (2025) — it auto-counts open vs. closed sub-issues per parent and exposes this as a queryable field. The two parent state automations are:

- **Parent → In Progress** when the sub-issue progress field shows any open descendant (`subIssueProgress.completed < subIssueProgress.total`)
- **Parent → Done** when the sub-issue progress field shows 100% closed (`subIssueProgress.completed == subIssueProgress.total && total > 0`)

The cascade only needs to set the parent Status explicitly at two moments: **Triage** at creation, and **Archived** during workstream-abandonment supersedes. The In Progress and Done transitions are board-automation-driven via the progress field, not cascade-driven.
~~~~

with:

~~~~text
**The sub-issue progress field is the load-bearing primitive for parent-state rollup.** Projects expose it — "Parent issues and sub-issue progress is also available in your projects, allowing you to build views, filter, and group by parent issue" (`https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/adding-sub-issues`, read 2026-09-30) — and the GraphQL `Issue.subIssuesSummary` field carries the counts (`completed`, `total`, `percentCompleted`; `https://docs.github.com/public/fpt/schema.docs.graphql`, read 2026-09-30). **No built-in project workflow moves a parent on it**: the documented built-ins set Status on item events — added, closed, merged — and two are enabled by default (`https://docs.github.com/en/issues/planning-and-tracking-with-projects/automating-your-project/using-the-built-in-automations`, read 2026-09-30). The two parent transitions are therefore automation the project builds itself (an Actions workflow or a GraphQL script), or a hand move:

- **Parent → In Progress** when any descendant is open (`subIssuesSummary.completed < subIssuesSummary.total`)
- **Parent → Done** when every descendant is closed (`subIssuesSummary.completed == subIssuesSummary.total && total > 0`)

The cascade only needs to set the parent Status explicitly at two moments: **Triage** at creation, and **Archived** during workstream-abandonment supersedes. The In Progress and Done transitions belong to that project-built automation (or the operator), not to the cascade.
~~~~

In each of `.claude/skills/scaffold/references/backends.md`, `.claude/skills/blueprint/references/backends.md`, `.claude/skills/framing/references/backends.md`, `.claude/skills/rough-in/references/backends.md` — identically, replace:

~~~~text
**Board-automation gap (as of current cascade version)**: the MCP surface for setting Projects v2 Status field values directly from cascade skills is limited. In practice, skills committing new sub-issues may not be able to set the entry Status field programmatically as part of the atomic transition, which means the user or a board-level automation rule has to set it after creation. Skills should document this gap in their planning-backend-commit references and recommend that users either (a) configure a board automation rule that sets Status based on label + dependency state, or (b) manually set Status on newly-created sub-issues after each cascade commit. The long-term fix is either improved MCP tooling or a richer board automation rule set — both are deferred to a future cascade revision pass.
~~~~

with:

~~~~text
**Board-automation gap (a dated rail, observed 2026-09-06: the GitHub MCP server's tool list carried no project-board tools — scaffold's SKILL.md § The detection matrix records it; re-read the tool list before relying on this)**: skills committing new sub-issues cannot set the entry Status field as part of the atomic transition, so the user or a project-built automation sets it after creation. Skills document this gap in their planning-backend-commit references and recommend that users either (a) build an automation (an Actions workflow or a GraphQL script) that sets Status from the label and dependency state — no built-in project workflow keys on either — or (b) set Status by hand on newly-created sub-issues after each cascade commit. The long-term fix is either an MCP server with project-board tools or that project-built automation — both are deferred to a future cascade revision pass.
~~~~

In `.claude/skills/framing/references/planning-backend-commit.md`, replace:

~~~~text
(the MCP surface for Projects v2 field manipulation is limited)
~~~~

with:

~~~~text
(the GitHub MCP server's tool list carried no project-board tools when observed on 2026-09-06 — the board-automation gap in `references/backends.md`)
~~~~

- [ ] **Step 4: Run the block — it must pass.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`

Expected (read by content, not position — `N` is the tree's always-loaded total at this point, and no `WARN` or `VIOLATION` line prints):

~~~~text
always-loaded total: N bytes
verification: kit sub-block complete
verification: done
exit=0
~~~~

- [ ] **Step 5: Commit.**

~~~~bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/skills/scaffold/references/backends.md \
  .claude/skills/blueprint/references/backends.md \
  .claude/skills/framing/references/backends.md \
  .claude/skills/rough-in/references/backends.md \
  .claude/skills/framing/references/planning-backend-commit.md
git commit -F- <<'MSG'
docs(backends): V9.7 — board-automation rail dated, progress field sourced, copies diffed

The four byte-identical backends.md copies carried an undated rail ("as of
current cascade version") and an automation keyed on a GraphQL field the
schema does not have. The rail is dated to the 2026-09-06 tool-list
observation with its re-read trigger; the progress field is quoted from the
sub-issues page and the schema (subIssuesSummary), and the parent
transitions are named as automation the project builds, since no built-in
project workflow keys on a parent (all read 2026-09-30). The block now diffs
the four copies.

Trace rows landed: review/portability/34.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
~~~~

- [ ] **Step 6: Prove the new diff guard by mutation, after the commit** (the restore reads the committed file, so it must follow Step 5).

Run: `printf 'x' >> .claude/skills/rough-in/references/backends.md && bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; git checkout -- .claude/skills/rough-in/references/backends.md && git status --short`

Expected: `rough-in/references/backends.md drifted from scaffold's copy (the four copies are byte-identical)`, `verification: block exited 1`, and no `git status` output after the restore. Record the mutation line in the PR body's red-first table (the other checks in this task were red against the unfixed files in Step 2).

---

### Task V9.8: Eight sections, everywhere the rough-in body is described (review/consistency/4, review/claude-code/11; D53 (the executor's parser is the authority))

`commands/finish.md` Preconditions 1 requires exactly eight headings; eight files still said six or seven (scaffold's SKILL.md, the four `backends.md` copies, rough-in's `planning-backend-commit.md`, `test_cases.md`, `plan-mode-prompts.md`), `procedure.md` listed an older eight-item shape, and `plan-mode-prompts.md` and `planning-backend-commit.md` still described `/finish` as a future "bootstrap-finish" skill. The new check reuses the `$L` list the block already derives from the scaffold template (the line above the `handoff-to-finish.md` loop), so a renamed section fails in every restatement at once. The stale-count pattern is written so the corrected prose cannot match it ("the other sections", never "the other seven sections").

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md`
- Modify: `.claude/skills/scaffold/SKILL.md`
- Modify: `.claude/skills/scaffold/references/backends.md`
- Modify: `.claude/skills/blueprint/references/backends.md`
- Modify: `.claude/skills/framing/references/backends.md`
- Modify: `.claude/skills/rough-in/references/backends.md`
- Modify: `.claude/skills/rough-in/references/planning-backend-commit.md`
- Modify: `.claude/skills/rough-in/references/test_cases.md`
- Modify: `.claude/skills/rough-in/references/procedure.md`
- Modify: `.claude/skills/rough-in/references/plan-mode-prompts.md`
- Modify: `.claude/skills/rough-in/references/failure-modes.md`

**Interfaces:**
- Consumes: V9.7's four-copy diff (the `backends.md` edit lands in all four copies); `$L`, set earlier in the block.
- Produces: the extended restatement check over scaffold's SKILL.md, the four `backends.md` copies and rough-in's `planning-backend-commit.md`, and the stale-count `absent` check over the rough-in skill and scaffold's SKILL.md.

- [ ] **Step 1: Write the check.** In `.claude/rules/cbk-conventions-reference.md` § Verification, insert these lines immediately before `echo "verification: kit sub-block complete"`:

~~~~bash
# The eight-section list, restated (V9.8): scaffold's SKILL.md, the four backends.md copies and rough-in's commit
# reference carry the executor's list verbatim too, and no rough-in surface states a stale count ($L is set above).
for f in .claude/skills/scaffold/SKILL.md .claude/skills/*/references/backends.md .claude/skills/rough-in/references/planning-backend-commit.md; do grep -qF "($L)" "$f" || { echo "$f does not carry the executor's section list ($L)"; exit 1; }; done
absent grep -rniE "(six|seven) (standard )?(sections|headings)|other five sections|these six heading|six-section" .claude/skills/rough-in .claude/skills/scaffold/SKILL.md
~~~~

- [ ] **Step 2: Run it against the unfixed files — it must fail.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected (the last two lines, then the exit):

~~~~text
.claude/skills/scaffold/SKILL.md does not carry the executor's section list (Context / Assumptions / Implementation / Acceptance criteria / Test plan / Done signal / Dependencies / PR contract)
verification: block exited 1
exit=1
~~~~

- [ ] **Step 3: Make the change.** Each replacement is an exact-string edit; each anchor was verified to occur exactly once at `643f7ff` plus the earlier V9 tasks, in text no other cluster's task changes (§ Ownership map) unless this task names the exception. If an anchor is missing, stop and reconcile — never guess.

In each of `.claude/skills/scaffold/SKILL.md`, `.claude/skills/scaffold/references/backends.md`, `.claude/skills/blueprint/references/backends.md`, `.claude/skills/framing/references/backends.md`, `.claude/skills/rough-in/references/backends.md` — identically, replace:

~~~~text
Its body has six sections (Context / Implementation / Acceptance criteria / Done signal / Dependencies / PR contract), and `/finish` will anchor hardest
~~~~

with:

~~~~text
Its body has eight sections (Context / Assumptions / Implementation / Acceptance criteria / Test plan / Done signal / Dependencies / PR contract), and `/finish` will anchor hardest
~~~~

In `.claude/skills/rough-in/references/planning-backend-commit.md`, replace:

~~~~text
populated into the `cascade-rough-in.md` template (seven sections: Context / Implementation / Acceptance criteria / Test plan / Done signal / Dependencies / PR contract)
~~~~

with:

~~~~text
populated into the `cascade-rough-in.md` template, its eight sections (Context / Assumptions / Implementation / Acceptance criteria / Test plan / Done signal / Dependencies / PR contract)
~~~~

In `.claude/skills/rough-in/references/planning-backend-commit.md`, replace:

~~~~text
populating the seven sections (Context / Implementation / Acceptance criteria / Test plan / Done signal / Dependencies / PR contract) from the spec
~~~~

with:

~~~~text
populating the eight sections (Context / Assumptions / Implementation / Acceptance criteria / Test plan / Done signal / Dependencies / PR contract) from the spec
~~~~

In `.claude/skills/rough-in/references/planning-backend-commit.md`, replace:

~~~~text
After this step runs successfully, `/finish` (Claude Code's finish phase, bootstrapped via the bootstrap-finish skill) has everything
~~~~

with:

~~~~text
After this step runs successfully, `/finish` (Claude Code's finish phase, provisioned at Step 5.5) has everything
~~~~

In `.claude/skills/rough-in/references/test_cases.md`, replace:

~~~~text
populates the six sections, ensures
~~~~

with:

~~~~text
populates the eight sections, ensures
~~~~

In `.claude/skills/rough-in/references/test_cases.md`, replace:

~~~~text
- Each R-issue's body has the six standard sections with heading names preserved verbatim
~~~~

with:

~~~~text
- Each R-issue's body has the eight sections the executor requires (`commands/finish.md` § Preconditions), with heading names preserved verbatim
~~~~

In `.claude/skills/rough-in/references/test_cases.md`, replace:

~~~~text
with the six-section structure preserved
~~~~

with:

~~~~text
with the eight-section structure preserved
~~~~

In `.claude/skills/rough-in/references/procedure.md`, replace:

~~~~text
For each approved issue plan entry, draft the full sub-sub-issue spec using the template in `references/templates/rough-in-spec-template.md`. Each spec contains:

1. **Title** — exact naming convention from the plan
2. **Intent** — one paragraph, expanded from the plan's one-sentence intent
3. **Acceptance criteria** — concrete, verifiable, user-visible or test-visible outcomes. "The tests pass" is not acceptance; "`cargo run -- regex/lesson_01.toml` succeeds with output matching `expected.txt`" is.
4. **Test plan** — named tests that satisfy each acceptance criterion. One named test per criterion (rephrased from imperative spec to declarative test name), quotable verbatim from the test runner's output. For logic-regime modules these are scaffolded as failing tests *before* implementation begins (see `.claude/rules/testing.md` for regime classification); for boundary adapters they're the conformance + shim dispatch tests; for UI / integration they're the assertions written after the surface exists. The test plan is what `/finish`'s execute step anchors on for the red-first scaffolding — vague test names ("the function works") force the implementer to invent the contract, defeating the point.
5. **Technical detail** — the specifics Claude Code needs to know: files to create/modify, functions to define with signatures, patterns from research to follow, libraries to use, gotchas to avoid
6. **Claude Code plan-mode prompt** — the actual prompt the user (or the bootstrap-finish CLAUDE.md section) will hand to Claude Code's plan mode. This is the load-bearing output of rough-in. It must be self-contained enough that Claude Code can read it and produce a plan without needing to chase down external context.
7. **Dependencies** — explicit list of prior R-issues that must be complete before this one can start
8. **Done signal** — a specific, observable outcome that means this issue is done. Usually the same as the acceptance criteria's top-line check but stated as a verification command the user can run.
~~~~

with:

~~~~text
For each approved issue plan entry, draft the full sub-sub-issue spec using the template in `references/templates/rough-in-spec-template.md`, titled exactly as the plan names it. Each spec carries the executor's eight headings, in order (`references/contract.md` states what each must hold):

1. **Context** — one paragraph: where the issue sits in the cascade, what it enables, what it deliberately does not do.
2. **Assumptions** — every gap filled, one `[ASSUMPTION: …]` line each with why it was made and what changes if it is wrong; or the explicit `- None — …` line. Never empty.
3. **Implementation** — the plan-mode prompt: intent and constraints for Claude Code's plan mode — the files to create or modify, the interfaces verbatim from the frame's commitments, the patterns research found, the gotchas to avoid. This is the load-bearing output of rough-in, self-contained enough that plan mode needs no external chase (`references/plan-mode-prompts.md` states its eight properties).
4. **Acceptance criteria** — concrete, verifiable, user-visible or test-visible outcomes, numbered `[R<#>.AC<m>]` as checkboxes, each citing the `[F<#>.AC<n>]` it discharges. "The tests pass" is not acceptance; "`cargo run -- regex/lesson_01.toml` succeeds with output matching `expected.txt`" is.
5. **Test plan** — the regime named (see `.claude/rules/testing.md` for regime classification) and one named test per criterion, in the project's test-side tag form keyed to the R-level number, quotable verbatim from the test runner's output. For logic-regime modules these are scaffolded as failing tests *before* implementation begins; for boundary adapters they're the conformance + shim dispatch tests; for UI / integration they're the assertions written after the surface exists. The test plan is what `/finish`'s execute step anchors on for the red-first scaffolding — vague test names ("the function works") force the implementer to invent the contract, defeating the point.
6. **Done signal** — a specific, observable outcome that means this issue is done. Usually the same as the acceptance criteria's top-line check but stated as a verification command the user can run.
7. **Dependencies** — explicit list of prior R-issues that must be complete before this one can start.
8. **PR contract** — how the plan finishes: the draft PR with the planning axis's close marker and a Conventional Commits title.
~~~~

In `.claude/skills/rough-in/references/procedure.md`, replace:

~~~~text
requires exactly eight, in order: Context, Assumptions, Implementation, Acceptance criteria, Test plan, Done signal, Dependencies, PR contract (`commands/finish.md` § Preconditions; the procedure's Step 2). The eight properties above are what every spec must *express*; the headings are how the executor *finds* them. Every other surface that restates the list — `references/templates/rough-in-spec-template.md`, the scaffold-shipped `issue-templates/cascade-rough-in.md`, `references/handoff-to-finish.md`, `references/plan-mode-prompts.md` — is a copy,
~~~~

with:

~~~~text
requires exactly these eight, in this order (`commands/finish.md` § Preconditions; the procedure's Step 2). Every other surface that restates the list — `references/templates/rough-in-spec-template.md`, the scaffold-shipped `issue-templates/cascade-rough-in.md`, `references/handoff-to-finish.md`, `references/plan-mode-prompts.md`, `references/planning-backend-commit.md`, scaffold's SKILL.md and the four `references/backends.md` copies — is a copy,
~~~~

In `.claude/skills/rough-in/references/plan-mode-prompts.md`, replace:

~~~~text
It will be defined in CLAUDE.md by the bootstrap-finish skill (the sixth and final in-chat skill, scoped to writing the finish section into CLAUDE.md once M1 of the first workstream has been built by hand). For now, the contract `/finish` will follow is:
~~~~

with:

~~~~text
It ships as `.claude/commands/finish.md` — rough-in provisions it at Step 5.5 from the bundled `references/finish-command.md` — and the part of its contract rough-in's specs feed is:
~~~~

In `.claude/skills/rough-in/references/plan-mode-prompts.md`, replace:

~~~~text
The Implementation section is the hottest, but the other five sections of the spec template each have a specific role
~~~~

with:

~~~~text
The Implementation section is the hottest, but each of the other sections of the spec template has a specific role
~~~~

In `.claude/skills/rough-in/references/failure-modes.md`, replace:

~~~~text
plus the other five sections)
~~~~

with:

~~~~text
plus the other sections)
~~~~

In `.claude/skills/rough-in/references/plan-mode-prompts.md`, replace:

~~~~text
It's the "why this issue exists" answer in one paragraph. Not the place for instructions.
~~~~

with:

~~~~text
It's the "why this issue exists" answer in one paragraph. Not the place for instructions.
- **Assumptions** lists every gap the drafter filled, one `[ASSUMPTION: …]` line each with why it was made and what changes if it is wrong — or the explicit `- None — …` line. `/finish` confirms or corrects each at its plan gate. Never empty.
~~~~

In `.claude/skills/rough-in/references/plan-mode-prompts.md`, replace:

~~~~text
It's where the executor proves the implementation is done. Not the place for instructions on how to get there.
~~~~

with:

~~~~text
It's where the executor proves the implementation is done. Not the place for instructions on how to get there.
- **Test plan** names the regime and one test per criterion in the project's test-side tag form, quotable from the runner — the red-first scaffold `/finish` builds before the implementation. Not the place for the implementation itself.
~~~~

In `.claude/skills/rough-in/references/plan-mode-prompts.md`, replace:

~~~~text
## Section-anchoring discipline for `/finish`

`/finish` identifies sections by their `## ` heading names. The standard six headings are:

```
## Context
## Implementation
## Acceptance criteria
## Done signal
## Dependencies
## PR contract
```

**These heading names are mandatory**. Sections can be edited freely (prose, lists, code, links, tables — whatever fits the issue) but the heading names must stay as written. Renaming "Implementation" to "What to build" or "Acceptance criteria" to "How we'll know it's done" will break `/finish`'s anchoring.

The cascade-rough-in.md template enforces this with an HTML comment block at the top of the file: *"The only hard rule: keep the section headings as written. /finish identifies sections by heading name, so renaming 'Implementation' to 'What to build' will break the slash command's anchoring."*

When rough-in drafts a spec, it must use exactly these six heading names in exactly this order. If a milestone genuinely needs additional sections (e.g., a research-heavy issue might benefit from a `## Background` section), add them after the standard six rather than renaming or replacing standard sections.
~~~~

with:

~~~~text
## Section-anchoring discipline for `/finish`

`/finish` identifies sections by their `## ` heading names. The eight headings, in order, are:

```
## Context
## Assumptions
## Implementation
## Acceptance criteria
## Test plan
## Done signal
## Dependencies
## PR contract
```

**These heading names are mandatory**. Sections can be edited freely (prose, lists, code, links, tables — whatever fits the issue) but the heading names must stay as written. Renaming "Implementation" to "What to build" or "Acceptance criteria" to "How we'll know it's done" will break `/finish`'s anchoring.

The cascade-rough-in.md template enforces this with an HTML comment block at the top of the file: *"The only hard rule: keep the section headings as written. /finish identifies sections by heading name, so renaming 'Implementation' to 'What to build' will break the slash command's anchoring."*

When rough-in drafts a spec, it must use exactly these eight heading names in exactly this order. If a milestone genuinely needs additional sections (e.g., a research-heavy issue might benefit from a `## Background` section), add them after the eight rather than renaming or replacing them.
~~~~

In `.claude/skills/rough-in/references/plan-mode-prompts.md`, replace:

~~~~text
- **`/finish`'s actual implementation** — that's bootstrap-finish's job, not rough-in's.
~~~~

with:

~~~~text
- **`/finish`'s actual implementation** — that's `.claude/commands/finish.md`, provisioned at Step 5.5, not rough-in's.
~~~~

In `.claude/skills/rough-in/references/plan-mode-prompts.md`, delete this line (and the newline before it):

~~~~text
- **The bootstrap-finish skill itself** — that's the sixth in-chat skill, scoped separately, built between M1 and M2 of the first workstream once execution data informs what `/finish` should do.
~~~~

- [ ] **Step 4: Run the block — it must pass.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`

Expected (read by content, not position — `N` is the tree's always-loaded total at this point, and no `WARN` or `VIOLATION` line prints):

~~~~text
always-loaded total: N bytes
verification: kit sub-block complete
verification: done
exit=0
~~~~

- [ ] **Step 5: Commit.**

~~~~bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/skills/scaffold/SKILL.md \
  .claude/skills/scaffold/references/backends.md \
  .claude/skills/blueprint/references/backends.md \
  .claude/skills/framing/references/backends.md \
  .claude/skills/rough-in/references/backends.md \
  .claude/skills/rough-in/references/planning-backend-commit.md \
  .claude/skills/rough-in/references/test_cases.md \
  .claude/skills/rough-in/references/procedure.md \
  .claude/skills/rough-in/references/plan-mode-prompts.md \
  .claude/skills/rough-in/references/failure-modes.md
git commit -F- <<'MSG'
docs(rough-in): V9.8 — eight sections everywhere the spec body is described

Scaffold's SKILL.md, the four backends.md copies, rough-in's commit
reference, its test cases and its plan-mode reference said six or seven
sections while the executor requires eight; a drafter following "exactly
these six" produced specs /finish refuses. Every restatement now carries
the executor's list, procedure.md's Step 5 lists the eight headings instead
of an older item shape, and the "bootstrap-finish" future tense is gone.
The block extends its restatement check to these files and refuses a stale
count.

Trace rows landed: review/consistency/4, review/claude-code/11.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
~~~~

---

### Task V9.9: One acceptance-criteria form: `[R<#>.AC<m>]`, citing the `[F<#>.AC<n>]` it discharges (review/consistency/5; D53)

rough-in's `contract.md` requires numbered `[R<#>.AC<m>]` criteria, as checkboxes, each citing the `[F<#>.AC<n>]` it discharges; the two templates a drafter copies showed only unnumbered placeholders, and § Trace ID convention's example labelled an R-issue's criteria with the parent's ID. The test-side tag stays the project's fill slot (`testing.md` and § Trace ID convention's "Two-level anchor" paragraph are unchanged). A target's committed `.github/ISSUE_TEMPLATE/cascade-rough-in.md` is a byte copy of scaffold's — V10's Sync notes name the re-copy.

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md`
- Modify: `.claude/skills/rough-in/references/templates/rough-in-spec-template.md`
- Modify: `.claude/skills/scaffold/references/issue-templates/cascade-rough-in.md`

**Interfaces:**
- Consumes: nothing.
- Produces: the check that both template bodies carry `[R<#>.AC1]` outside their comments.

- [ ] **Step 1: Write the check.** In `.claude/rules/cbk-conventions-reference.md` § Verification, insert these lines immediately before `echo "verification: kit sub-block complete"`:

~~~~bash
# One acceptance-criteria form (V9.9): both rough-in templates default to numbered [R<#>.AC<m>] criteria outside their
# comments, as the rough-in contract requires; a commented variant alone does not count.
for f in .claude/skills/rough-in/references/templates/rough-in-spec-template.md .claude/skills/scaffold/references/issue-templates/cascade-rough-in.md; do awk '/<!--/{c=1} !c{print} /-->/{c=0}' "$f" | grep -qF '[R<#>.AC1]' || { echo "$f: the default acceptance criteria are not numbered [R<#>.AC<m>] (the rough-in contract's form)"; exit 1; }; done
~~~~

- [ ] **Step 2: Run it against the unfixed files — it must fail.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected (the last two lines, then the exit):

~~~~text
.claude/skills/rough-in/references/templates/rough-in-spec-template.md: the default acceptance criteria are not numbered [R<#>.AC<m>] (the rough-in contract's form)
verification: block exited 1
exit=1
~~~~

- [ ] **Step 3: Make the change.** Each replacement is an exact-string edit; each anchor was verified to occur exactly once at `643f7ff` plus the earlier V9 tasks, in text no other cluster's task changes (§ Ownership map) unless this task names the exception. If an anchor is missing, stop and reconcile — never guess.

In each of `.claude/skills/rough-in/references/templates/rough-in-spec-template.md`, `.claude/skills/scaffold/references/issue-templates/cascade-rough-in.md` — identically, replace:

~~~~text
<!--
Observable, verifiable outcomes. Each one is a checkbox so the implementer
can tick them off as they go. Avoid "the tests pass" — name the specific
test, command, or observation that proves the criterion.
-->

- [ ] _Specific outcome 1_
- [ ] _Specific outcome 2_
- [ ] _Specific outcome 3_
~~~~

with:

~~~~text
<!--
Observable, verifiable outcomes. Each one is a checkbox so the implementer
can tick them off as they go, numbered [R<#>.AC<m>] and citing the
[F<#>.AC<n>] it discharges. Avoid "the tests pass" — name the specific
test, command, or observation that proves the criterion.
-->

- [ ] [R<#>.AC1] _Specific outcome 1 — what proves it_ (discharges [F<#>.AC<n>])
- [ ] [R<#>.AC2] _Specific outcome 2 — what proves it_ (discharges [F<#>.AC<n>])
- [ ] [R<#>.AC3] _Specific outcome 3 — what proves it_ (discharges [F<#>.AC<n>])
~~~~

In `.claude/rules/cbk-conventions-reference.md`, replace:

~~~~text
Rough-in R-issues then reference these IDs in their own `## Acceptance criteria` and `## Test plan` sections:
~~~~

with:

~~~~text
Rough-in R-issues number their own criteria `[R<#>.AC<m>]` and cite these IDs from them, in `## Acceptance criteria` and `## Test plan`:
~~~~

In `.claude/rules/cbk-conventions-reference.md`, replace:

~~~~text
- [F3.AC1] <how this R-issue satisfies AC1>
- [F3.AC2] `<test command>` passes (covers F3.AC2 — <criterion summary>)
~~~~

with:

~~~~text
- [ ] [R2.AC1] <how this R-issue satisfies it> (discharges [F3.AC1])
- [ ] [R2.AC2] `<test command>` passes (discharges [F3.AC2] — <criterion summary>)
~~~~

- [ ] **Step 4: Run the block — it must pass.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`

Expected (read by content, not position — `N` is the tree's always-loaded total at this point, and no `WARN` or `VIOLATION` line prints):

~~~~text
always-loaded total: N bytes
verification: kit sub-block complete
verification: done
exit=0
~~~~

- [ ] **Step 5: Commit.**

~~~~bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/skills/rough-in/references/templates/rough-in-spec-template.md \
  .claude/skills/scaffold/references/issue-templates/cascade-rough-in.md
git commit -F- <<'MSG'
docs(rough-in): V9.9 — one acceptance-criteria form across contract, templates and conventions

Both templates a drafter copies now default to numbered [R<#>.AC<m>]
checkboxes that cite the [F<#>.AC<n>] they discharge, the form the rough-in
contract requires and /finish's fidelity test keys on; § Trace ID
convention's example stops labelling an R-issue's criteria with the parent's
ID. The block checks the templates' default bodies, outside comments.

Trace rows landed: review/consistency/5.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
~~~~

---

### Task V9.10: One name per axis value: `in-repo-markdown`, never a profile (review/consistency/3, review/consistency/50; D53; the constant + two axes (CLAUDE.md))

Blueprint's acknowledgment keyed on a `profile` field scaffold never writes; the canonical record is `docs/cbk/scaffold.md` § Cascade metadata (`Planning backend`), with `.cascade/backends.toml` as its mirror. The same retired vocabulary sat in three `planning-backend-commit.md` gate quotes, rough-in's Test 3, `backend_selection.md`'s citation of a heading that does not exist, the four `backends.md` copies and rough-in's `inheritance.md`. `review/consistency/50` rides here: rough-in claimed scaffold commits the issue templates on every axis, but scaffold skips planning provisioning on in-repo-markdown (`scaffold/SKILL.md` § Stage 2 and its exit checklist), so the Test 3 setup and the matrix's body-source sentence now say so. The file `github_only_profile.md` keeps its name (the block and SKILL.md cite it); the case-sensitive pattern leaves its `GitHub-only profile` title alone.

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md`
- Modify: `.claude/skills/blueprint/SKILL.md`
- Modify: `.claude/skills/blueprint/references/planning-backend-commit.md`
- Modify: `.claude/skills/framing/references/planning-backend-commit.md`
- Modify: `.claude/skills/rough-in/references/planning-backend-commit.md`
- Modify: `.claude/skills/scaffold/references/backends.md`
- Modify: `.claude/skills/blueprint/references/backends.md`
- Modify: `.claude/skills/framing/references/backends.md`
- Modify: `.claude/skills/rough-in/references/backends.md`
- Modify: `.claude/skills/scaffold/references/backend_selection.md`
- Modify: `.claude/skills/rough-in/references/inheritance.md`
- Modify: `.claude/skills/rough-in/references/test_cases.md`
- Modify: `.claude/skills/rough-in/references/planning-backend-matrix.md`
- Modify: `.claude/rules/cbk-conventions.md`

**Interfaces:**
- Consumes: V9.7's four-copy diff; V9.8's edit to `test_cases.md` line 88 (a different line).
- Produces: the `absent` check for `github-only profile`, `markdown-only profile`, `profile: markdown-only` and `profile field is` over `.claude/`. Always-loaded: +3 bytes (`cbk-conventions.md` § Closes-keyword conventions).

- [ ] **Step 1: Write the check.** In `.claude/rules/cbk-conventions-reference.md` § Verification, insert these lines immediately before `echo "verification: kit sub-block complete"`:

~~~~bash
# One name per axis value (V9.10): scaffold records `Planning backend: in-repo-markdown` and there are no named
# profiles, so nothing keys on a profile field or names a retired profile (the literals split themselves).
absent grep -rnE "github-only profil[e]|[Mm]arkdown-only profil[e]|profile: markdown-onl[y]|profile fiel[d] is" .claude/
~~~~

- [ ] **Step 2: Run it against the unfixed files — it must fail.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected (the last two lines, then the exit):

~~~~text
VIOLATION (matched above): grep -rnE github-only profil[e]|[Mm]arkdown-only profil[e]|profile: markdown-onl[y]|profile fiel[d] is .claude/
verification: block exited 1
exit=1
~~~~

- [ ] **Step 3: Make the change.** Each replacement is an exact-string edit; each anchor was verified to occur exactly once at `643f7ff` plus the earlier V9 tasks, in text no other cluster's task changes (§ Ownership map) unless this task names the exception. If an anchor is missing, stop and reconcile — never guess.

In `.claude/skills/blueprint/SKILL.md`, replace:

~~~~text
### Markdown-only profile acknowledgment (runs only if scaffold landed in markdown-only mode)
~~~~

with:

~~~~text
### In-repo-markdown acknowledgment (runs only when `Planning backend` is `in-repo-markdown`)
~~~~

In `.claude/skills/blueprint/SKILL.md`, replace:

~~~~text
If scaffold's profile field is `markdown-only`, blueprint adds a one-line acknowledgment to the inheritance gate before proceeding. The user already confirmed markdown-only at scaffold's full HITL gate,
~~~~

with:

~~~~text
If `docs/cbk/scaffold.md` § Cascade metadata records `Planning backend` as `in-repo-markdown` (falling back to `.cascade/backends.toml`), blueprint adds a one-line acknowledgment to the inheritance gate before proceeding. The user already confirmed that axis at scaffold's in-repo-markdown confirmation gate,
~~~~

In `.claude/skills/blueprint/SKILL.md`, replace:

~~~~text
> "I see scaffold landed in **markdown-only** profile. That means
~~~~

with:

~~~~text
> "I see scaffold chose **in-repo-markdown** planning. That means
~~~~

In `.claude/skills/blueprint/SKILL.md`, replace:

~~~~text
do you want to revisit the profile choice before I commit anything?"
~~~~

with:

~~~~text
do you want to revisit the planning axis before I commit anything?"
~~~~

In `.claude/skills/blueprint/SKILL.md`, replace:

~~~~text
If the user wants to revisit the profile, blueprint pauses and tells them to re-run scaffold with the new profile choice — blueprint cannot change the profile mid-session because the profile is committed in `scaffold.md` and changing it requires re-running scaffold's confirmation gate. This is intentional: profile is a one-way door at the cascade level, set once at scaffold time.
~~~~

with:

~~~~text
If the user wants to revisit the axis, blueprint pauses and tells them to re-run scaffold with the new planning choice — blueprint cannot change the planning axis mid-session because it is committed in `scaffold.md` and changing it requires re-running scaffold's confirmation gate. This is intentional: the planning axis is a one-way door at the cascade level, set once at scaffold time.
~~~~

In `.claude/skills/blueprint/SKILL.md`, replace:

~~~~text
the markdown-only behavior is already plumbed
~~~~

with:

~~~~text
the in-repo-markdown behavior is already plumbed
~~~~

In each of `.claude/skills/blueprint/references/planning-backend-commit.md`, `.claude/skills/framing/references/planning-backend-commit.md`, `.claude/skills/rough-in/references/planning-backend-commit.md` — identically, replace:

~~~~text
The HITL gate in markdown-only mode mentions only the markdown commit half:
~~~~

with:

~~~~text
The HITL gate on in-repo-markdown planning mentions only the markdown commit half:
~~~~

In each of `.claude/skills/blueprint/references/planning-backend-commit.md`, `.claude/skills/framing/references/planning-backend-commit.md`, `.claude/skills/rough-in/references/planning-backend-commit.md` — identically, replace:

~~~~text
> - Planning backend: none (markdown-only profile)
~~~~

with:

~~~~text
> - Planning backend: in-repo-markdown (no planning operations)
~~~~

In each of `.claude/skills/scaffold/references/backends.md`, `.claude/skills/blueprint/references/backends.md`, `.claude/skills/framing/references/backends.md`, `.claude/skills/rough-in/references/backends.md` — identically, replace:

~~~~text
The github-only profile has fewer semantic gaps
~~~~

with:

~~~~text
GitHub Issues planning has fewer semantic gaps
~~~~

In each of `.claude/skills/scaffold/references/backends.md`, `.claude/skills/blueprint/references/backends.md`, `.claude/skills/framing/references/backends.md`, `.claude/skills/rough-in/references/backends.md` — identically, replace:

~~~~text
the github-only profile assumes the Projects v2 board exists
~~~~

with:

~~~~text
github-issues planning assumes the Projects v2 board exists
~~~~

In `.claude/skills/scaffold/references/backend_selection.md`, replace:

~~~~text
(see SKILL.md § "Markdown-only confirmation gate" / "In-repo markdown confirmation gate")
~~~~

with:

~~~~text
(see SKILL.md § The in-repo-markdown confirmation gate)
~~~~

In `.claude/skills/rough-in/references/inheritance.md`, replace:

~~~~text
(via `issue_read` in github-only profile)
~~~~

with:

~~~~text
(via `issue_read` on github-issues planning)
~~~~

In `.claude/skills/rough-in/references/test_cases.md`, replace:

~~~~text
## Test 3 — Markdown-only profile rough-in
~~~~

with:

~~~~text
## Test 3 — In-repo-markdown planning rough-in
~~~~

In `.claude/skills/rough-in/references/test_cases.md`, replace:

~~~~text
- A repo where scaffold landed in markdown-only profile (`scaffold.md` has `profile: markdown-only`)
~~~~

with:

~~~~text
- A repo where scaffold chose in-repo-markdown planning (`scaffold.md` § Cascade metadata records `Planning backend` as `in-repo-markdown`)
~~~~

In `.claude/skills/rough-in/references/test_cases.md`, replace:

~~~~text
- `.github/ISSUE_TEMPLATE/cascade-rough-in.md` exists (scaffold commits the templates regardless of profile)
~~~~

with:

~~~~text
- No `.github/ISSUE_TEMPLATE/cascade-rough-in.md` is expected — scaffold skips planning provisioning on this axis — so rough-in drafts from its bundled `references/templates/rough-in-spec-template.md`
~~~~

In `.claude/skills/rough-in/references/test_cases.md`, replace:

~~~~text
- The user has explicitly chosen markdown-only at scaffold's confirmation gate
~~~~

with:

~~~~text
- The user has explicitly chosen in-repo-markdown at scaffold's confirmation gate
~~~~

In `.claude/skills/rough-in/references/test_cases.md`, replace:

~~~~text
reads scaffold.md, detects `profile: markdown-only`, surfaces the markdown-only acknowledgment in the inheritance gate (parallel to blueprint's markdown-only acknowledgment): *"This is markdown-only profile — I'll skip
~~~~

with:

~~~~text
reads scaffold.md, detects `Planning backend: in-repo-markdown`, surfaces the in-repo-markdown acknowledgment in the inheritance gate (parallel to blueprint's in-repo-markdown acknowledgment): *"This is in-repo-markdown planning — I'll skip
~~~~

In `.claude/skills/rough-in/references/test_cases.md`, replace:

~~~~text
- The markdown-only acknowledgment fires correctly
~~~~

with:

~~~~text
- The in-repo-markdown acknowledgment fires correctly
~~~~

In `.claude/skills/rough-in/references/planning-backend-matrix.md`, replace:

~~~~text
(because the templates may exist on disk even in repos without external planning — scaffold commits them regardless of the planning axis, since they're workspace infrastructure that serves both human-created Issues and the cascade's automated runs). The template's section structure is used inside the markdown spec content too, so the spec headings are consistent across planning axes. If the disk template is missing, fall back to the bundled copy.
~~~~

with:

~~~~text
when an operator committed one there by hand — scaffold itself commits the templates only on the github-issues and linear axes and skips planning provisioning on this one, so the disk copy is usually absent. The template's section structure is used inside the markdown spec content too, so the spec headings are consistent across planning axes. Without the disk template, draft from the bundled `references/templates/rough-in-spec-template.md`, whose headings the verification block diffs against scaffold's issue template.
~~~~

In `.claude/rules/cbk-conventions.md`, replace:

~~~~text
- **Markdown-only projects**: there are no issue-tracker entities to close;
~~~~

with:

~~~~text
- **In-repo-markdown planning**: there are no issue-tracker entities to close;
~~~~

- [ ] **Step 4: Run the block — it must pass.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`

Expected (read by content, not position — `N` is the tree's always-loaded total at this point, and no `WARN` or `VIOLATION` line prints):

~~~~text
always-loaded total: N bytes
verification: kit sub-block complete
verification: done
exit=0
~~~~

Budget (D50): run `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | command grep '^always-loaded total'` on the tree before Step 3 and again now; the second total is exactly 3 bytes higher than the first (`cbk-conventions.md` § Closes-keyword conventions). Record both in the PR body's before/after ledger.

- [ ] **Step 5: Commit.**

~~~~bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/skills/blueprint/SKILL.md \
  .claude/skills/blueprint/references/planning-backend-commit.md \
  .claude/skills/framing/references/planning-backend-commit.md \
  .claude/skills/rough-in/references/planning-backend-commit.md \
  .claude/skills/scaffold/references/backends.md \
  .claude/skills/blueprint/references/backends.md \
  .claude/skills/framing/references/backends.md \
  .claude/skills/rough-in/references/backends.md \
  .claude/skills/scaffold/references/backend_selection.md \
  .claude/skills/rough-in/references/inheritance.md \
  .claude/skills/rough-in/references/test_cases.md \
  .claude/skills/rough-in/references/planning-backend-matrix.md \
  .claude/rules/cbk-conventions.md
git commit -F- <<'MSG'
docs(skills): V9.10 — the planning axis has one name: in-repo-markdown

Blueprint's acknowledgment keyed on a profile field scaffold never writes;
it now reads Planning backend from scaffold.md § Cascade metadata (falling
back to .cascade/backends.toml). The gate quotes, rough-in's Test 3, the
backends copies, inheritance.md, backend_selection.md's dead heading cite and
the closes-keyword bullet use the axis value. Rough-in no longer claims
scaffold commits the issue templates on every axis: on in-repo-markdown it
drafts from its bundled template. The block refuses the retired profile
vocabulary.

Trace rows landed: review/consistency/3, review/consistency/50.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
~~~~

---

### Task V9.11: The methodology register is not a file: cite the primary source (review/portability/33; D53)

`git ls-files | command grep -i 'methodolog\|sdd'` lists only blueprint's `methodology-selection.md` and consultation's `methodology_register_excerpt.md`: no `methodology_register.md` and no `sdd.md` ships, yet blueprint, framing and consultation told the agent to read or cite them (blueprint's with no fallback). The fix keeps "the methodology register" as a concept — the named methodologies, each cited by primary source — and repoints every file citation at the two shipped excerpts or at the primary source.

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md`
- Modify: `.claude/skills/blueprint/references/methodology-selection.md`
- Modify: `.claude/skills/blueprint/SKILL.md`
- Modify: `.claude/skills/blueprint/references/blueprint-output-template.md`
- Modify: `.claude/skills/consultation/references/methodology_register_excerpt.md`
- Modify: `.claude/skills/consultation/SKILL.md`
- Modify: `.claude/skills/framing/references/research-phase.md`
- Modify: `.claude/skills/framing/references/hitl-question-bank.md`
- Modify: `.claude/skills/framing/references/failure-modes.md`
- Modify: `.claude/skills/framing/references/procedure.md`
- Modify: `.claude/skills/framing/references/templates/frame-output-template.md`

**Interfaces:**
- Consumes: V5's edit to framing's `research-phase.md` (the grounding-rule count, a different line).
- Produces: the `absent` check for `methodology_register.md`, `sdd.md` and the "full register lives outside" claims over `.claude/`.

- [ ] **Step 1: Write the check.** In `.claude/rules/cbk-conventions-reference.md` § Verification, insert these lines immediately before `echo "verification: kit sub-block complete"`:

~~~~bash
# The methodology register is not a file (V9.11): the kit ships two excerpts and cites every pattern by its primary
# source, so no skill tells an agent to read a register file or an SDD file the kit does not ship.
absent grep -rn 'methodology_register\.m[d]\|sdd\.m[d]\|full register lives outsid[e]\|full register is share[d]' .claude/
~~~~

- [ ] **Step 2: Run it against the unfixed files — it must fail.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected (the last two lines, then the exit):

~~~~text
VIOLATION (matched above): grep -rn methodology_register\.m[d]\|sdd\.m[d]\|full register lives outsid[e]\|full register is share[d] .claude/
verification: block exited 1
exit=1
~~~~

- [ ] **Step 3: Make the change.** Each replacement is an exact-string edit; each anchor was verified to occur exactly once at `643f7ff` plus the earlier V9 tasks, in text no other cluster's task changes (§ Ownership map) unless this task names the exception. If an anchor is missing, stop and reconcile — never guess.

In `.claude/skills/blueprint/references/methodology-selection.md`, replace:

~~~~text
The methodology register lives outside this skill — it's a shared reference across all six cascade phases at `methodology_register.md` in the cascade root. Read it before this step if you haven't already in this session. It contains entries for
~~~~

with:

~~~~text
The methodology register is not a file the kit ships: it is the named methodologies and patterns below, each cited by its primary source (author, work, chapter). This file carries the project-level entries; the consultation skill's `references/methodology_register_excerpt.md` carries the shaping entries (Shape Up, spikes, YAGNI) in full. The register spans
~~~~

In `.claude/skills/blueprint/SKILL.md`, replace:

~~~~text
The methodology register lives outside this skill (it's shared across all six cascade phases). The blueprint-relevant entries
~~~~

with:

~~~~text
The methodology register is not a shipped file — it is the named methodologies each cited by primary source. The blueprint-relevant entries
~~~~

In `.claude/skills/blueprint/references/blueprint-output-template.md`, replace:

~~~~text
- Source: <citation from methodology register>
~~~~

with:

~~~~text
- Source: <primary source — author, work, chapter>
~~~~

In `.claude/skills/consultation/references/methodology_register_excerpt.md`, replace:

~~~~text
The full register is shared across all six cascade phases and lives outside this skill — this excerpt is the subset most useful during problem-brief writing.
~~~~

with:

~~~~text
The kit ships no full register file — later phases cite their patterns by primary source, and blueprint's `references/methodology-selection.md` carries the project-level methodologies — so this excerpt is the subset most useful during problem-brief writing.
~~~~

In `.claude/skills/consultation/references/methodology_register_excerpt.md`, replace:

~~~~text
## Pointers to the full register
~~~~

with:

~~~~text
## Pointers for later phases
~~~~

In `.claude/skills/consultation/references/methodology_register_excerpt.md`, replace:

~~~~text
If the user wants to read more than the excerpt above, point them at the full register.
~~~~

with:

~~~~text
If the user wants to read more than the excerpt above, point them at the primary sources the later phases cite.
~~~~

In `.claude/skills/consultation/SKILL.md`, replace:

~~~~text
spike solutions, YAGNI, and pointers to the full register for later phases.
~~~~

with:

~~~~text
spike solutions, YAGNI, and pointers to the primary sources later phases cite.
~~~~

In `.claude/skills/consultation/SKILL.md`, replace:

~~~~text
The full register lives outside this skill and is shared across all six cascade phases. If the user asks about patterns not in the excerpt, say so and offer to search.
~~~~

with:

~~~~text
The kit ships no full register file. If the user asks about a pattern not in the excerpt, say so and offer to search, citing the primary source you find.
~~~~

In `.claude/skills/consultation/SKILL.md`, replace:

~~~~text
From `sdd.md` and Shape Up chapters 2–5.
~~~~

with:

~~~~text
From Shape Up chapters 2–5 and the spec-driven-development sources the conventions cite (`cbk-conventions.md` § References).
~~~~

In `.claude/skills/consultation/SKILL.md`, replace:

~~~~text
— Shape Up, spikes, YAGNI entries plus pointers to the full register
~~~~

with:

~~~~text
— Shape Up, spikes, YAGNI entries plus pointers for later phases
~~~~

In `.claude/skills/framing/references/research-phase.md`, replace:

~~~~text
**Cite from `methodology_register.md` where relevant — at the per-milestone level**
~~~~

with:

~~~~text
**Cite the pattern's primary source where relevant — at the per-milestone level**
~~~~

In `.claude/skills/framing/references/research-phase.md`, replace:

~~~~text
- **Recommending patterns without citing `methodology_register.md`**
~~~~

with:

~~~~text
- **Recommending patterns without citing their primary source**
~~~~

In `.claude/skills/framing/references/hitl-question-bank.md`, replace:

~~~~text
Pattern names come from `methodology_register.md`;
~~~~

with:

~~~~text
Pattern names come from their primary sources;
~~~~

In `.claude/skills/framing/references/failure-modes.md`, replace:

~~~~text
Cite `methodology_register.md` when deciding shape — the register's "fails when" conditions usually catch methodology mismatches.
~~~~

with:

~~~~text
Cite the methodology's primary source when deciding shape — its "fails when" conditions usually catch methodology mismatches.
~~~~

In `.claude/skills/framing/references/procedure.md`, replace:

~~~~text
Cite from `methodology_register.md` when the cascade's shared knowledge has an answer for the pattern question
~~~~

with:

~~~~text
Cite the pattern's primary source when one answers the pattern question
~~~~

In `.claude/skills/framing/references/templates/frame-output-template.md`, replace:

~~~~text
informs milestone shape per `methodology_register.md` |
~~~~

with:

~~~~text
informs milestone shape per the methodology's primary source |
~~~~

- [ ] **Step 4: Run the block — it must pass.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`

Expected (read by content, not position — `N` is the tree's always-loaded total at this point, and no `WARN` or `VIOLATION` line prints):

~~~~text
always-loaded total: N bytes
verification: kit sub-block complete
verification: done
exit=0
~~~~

- [ ] **Step 5: Commit.**

~~~~bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/skills/blueprint/references/methodology-selection.md \
  .claude/skills/blueprint/SKILL.md \
  .claude/skills/blueprint/references/blueprint-output-template.md \
  .claude/skills/consultation/references/methodology_register_excerpt.md \
  .claude/skills/consultation/SKILL.md \
  .claude/skills/framing/references/research-phase.md \
  .claude/skills/framing/references/hitl-question-bank.md \
  .claude/skills/framing/references/failure-modes.md \
  .claude/skills/framing/references/procedure.md \
  .claude/skills/framing/references/templates/frame-output-template.md
git commit -F- <<'MSG'
docs(skills): V9.11 — no citation of a methodology register file the kit does not ship

Blueprint, framing and consultation told the agent to read
methodology_register.md or cited sdd.md; neither ships. The register is now
stated as what it is — the named methodologies, each cited by its primary
source — with blueprint's methodology-selection.md and consultation's
excerpt as the two shipped summaries. The block refuses the unshipped file
names.

Trace rows landed: review/portability/33.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
~~~~

---

### Task V9.12: The CI-skip trap, sourced: five spellings, the trailer, the events it covers (review/portability/36; D53 (dated platform claims); constraint 7)

Read raw on 2026-09-30: `curl -sL 'https://docs.github.com/api/article/body?pathname=/en/actions/how-tos/manage-workflow-runs/skip-workflow-runs'`. Each of these matches with `command grep -cF` (count 1): `the HEAD commit of a pull request`; ``Skip instructions only apply to the `push` and `pull_request` events.``; ``won't stop a workflow that's triggered `on: pull_request_target` ``; ``* `[ci skip]` ``, ``* `[no ci]` ``, ``* `[skip actions]` ``, ``* `[actions skip]` ``; ``* `skip-checks: true` ``; `be preceded by two empty lines`; `` `skip-checks` should be last``. The verifier's correction holds: the trailer is positional (last trailer, after two empty lines), not a substring hazard, and the text says so. **This commit's own message must not contain any of the five tokens** — its subject and body paraphrase.

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md`
- Modify: `.claude/rules/cbk-conventions.md`

**Interfaces:**
- Consumes: nothing; the § `[skip ci]` rule section is unassigned in the ownership map and this finding is V9's. The Required-checks paragraph beside it (V2's reference-half region) is untouched.
- Produces: the check that `cbk-conventions.md` names all five tokens, the trailer and the page. Always-loaded: +389 bytes.

- [ ] **Step 1: Write the check.** In `.claude/rules/cbk-conventions-reference.md` § Verification, insert these lines immediately before `echo "verification: kit sub-block complete"`:

~~~~bash
# The CI-skip trap is sourced and names every spelling (V9.12): five bracket tokens and the trailer, with the dated page.
for m in '[skip ci]' '[ci skip]' '[no ci]' '[skip actions]' '[actions skip]' 'skip-checks: true' 'skip-workflow-runs'; do grep -qF -- "$m" .claude/rules/cbk-conventions.md || { echo "cbk-conventions.md § [skip ci] rule does not name: $m"; exit 1; }; done
~~~~

- [ ] **Step 2: Run it against the unfixed files — it must fail.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected (the last two lines, then the exit):

~~~~text
cbk-conventions.md § [skip ci] rule does not name: [ci skip]
verification: block exited 1
exit=1
~~~~

- [ ] **Step 3: Make the change.** Each replacement is an exact-string edit; each anchor was verified to occur exactly once at `643f7ff` plus the earlier V9 tasks, in text no other cluster's task changes (§ Ownership map) unless this task names the exception. If an anchor is missing, stop and reconcile — never guess.

In `.claude/rules/cbk-conventions.md`, replace:

~~~~text
GitHub's CI-skip matcher applies to the HEAD commit's message regardless of which event fires.
~~~~

with:

~~~~text
For workflows triggered `on: push` or `on: pull_request`, GitHub reads the skip marker from the pushed commits or the pull request's HEAD commit; `pull_request_target` is not skipped (`https://docs.github.com/en/actions/how-tos/manage-workflow-runs/skip-workflow-runs`, read 2026-09-30).
~~~~

In `.claude/rules/cbk-conventions.md`, replace:

~~~~text
**Substring trap — quoting the literal marker token in a commit-message body re-triggers the matcher.** GitHub's match is a substring scan across the entire message, not anchored to the subject line or the end. A commit whose body explains *why* it's a fix for this trap, but quotes the literal token while explaining, is itself skipped. Use a paraphrase (e.g., "the CI-skip marker", "the conventional skip-tag") in prose; reserve the literal `[skip ci]` for the actual flag at the end of the subject line where you intend it to fire.
~~~~

with:

~~~~text
**Substring trap — quoting a marker token in a commit-message body re-triggers the matcher.** GitHub skips on any of five strings in the message — `[skip ci]`, `[ci skip]`, `[no ci]`, `[skip actions]`, `[actions skip]` — and on a `skip-checks: true` (or `skip-checks:true`) trailer, which counts only as the message's last trailer after two empty lines (same page). The match is a substring scan across the entire message, not anchored to the subject line or the end: a commit whose body explains *why* it's a fix for this trap, but quotes a token while explaining, is itself skipped. Use a paraphrase (e.g., "the CI-skip marker", "the conventional skip-tag") in prose; reserve a literal token for the flag you intend to fire.
~~~~

- [ ] **Step 4: Run the block — it must pass.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`

Expected (read by content, not position — `N` is the tree's always-loaded total at this point, and no `WARN` or `VIOLATION` line prints):

~~~~text
always-loaded total: N bytes
verification: kit sub-block complete
verification: done
exit=0
~~~~

Budget (D50): run `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | command grep '^always-loaded total'` on the tree before Step 3 and again now; the second total is exactly 389 bytes higher than the first (`cbk-conventions.md` § `[skip ci]` rule). Record both in the PR body's before/after ledger.

- [ ] **Step 5: Commit.**

~~~~bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/rules/cbk-conventions.md
git commit -F- <<'MSG'
docs(conventions): V9.12 — the CI-skip trap cites GitHub and names every spelling

The auto-review and substring traps named one marker and said the matcher
applies "regardless of which event fires". GitHub's skip-workflow-runs page
(read 2026-09-30) lists five bracket spellings plus a trailer form, and
applies them to push and pull_request only. The rule now names all
five, describes the trailer as positional, scopes the events and dates the
page. Always-loaded +389 bytes.

Trace rows landed: review/portability/36.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
~~~~

---

### Task V9.13: Linear's free plan, dated at the page that states it (review/portability/37; constraint 7)

Read on 2026-09-30: `curl -sL -A 'Mozilla/5.0' https://linear.app/pricing`, tags stripped, shows the Free column as `Free`, `$0`, `Free for everyone`, `Unlimited members`, `2 teams`, `250 issues` (each matched with `command grep -cF` on the stripped text). The shipped line said "up to 10 users".

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md`
- Modify: `.claude/skills/scaffold/references/manual_steps.md`

**Interfaces:**
- Consumes: V8's edits to `manual_steps.md` (line 26, a different line).
- Produces: the check that the line cites `linear.app/pricing` and no longer says "up to 10 users".

- [ ] **Step 1: Write the check.** In `.claude/rules/cbk-conventions-reference.md` § Verification, insert these lines immediately before `echo "verification: kit sub-block complete"`:

~~~~bash
# The Linear free-plan limits are dated at the page that states them (V9.13), not a stale seat count.
grep -q 'linear.app/pricing' .claude/skills/scaffold/references/manual_steps.md || { echo "manual_steps.md: the Linear free-plan line cites no dated pricing page"; exit 1; }
absent grep -n 'up to 10 user[s]' .claude/skills/scaffold/references/manual_steps.md
~~~~

- [ ] **Step 2: Run it against the unfixed files — it must fail.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected (the last two lines, then the exit):

~~~~text
manual_steps.md: the Linear free-plan line cites no dated pricing page
verification: block exited 1
exit=1
~~~~

- [ ] **Step 3: Make the change.** Each replacement is an exact-string edit; each anchor was verified to occur exactly once at `643f7ff` plus the earlier V9 tasks, in text no other cluster's task changes (§ Ownership map) unless this task names the exception. If an anchor is missing, stop and reconcile — never guess.

In `.claude/skills/scaffold/references/manual_steps.md`, replace:

~~~~text
https://linear.app/signup. Free tier supports up to 10 users.
~~~~

with:

~~~~text
https://linear.app/signup. The Free plan lists unlimited members, 2 teams and 250 issues (`https://linear.app/pricing`, read 2026-09-30) — the issue cap is the limit a cascade meets first, since every milestone adds a framing issue and its R-issues.
~~~~

- [ ] **Step 4: Run the block — it must pass.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`

Expected (read by content, not position — `N` is the tree's always-loaded total at this point, and no `WARN` or `VIOLATION` line prints):

~~~~text
always-loaded total: N bytes
verification: kit sub-block complete
verification: done
exit=0
~~~~

- [ ] **Step 5: Commit.**

~~~~bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/skills/scaffold/references/manual_steps.md
git commit -F- <<'MSG'
docs(scaffold): V9.13 — Linear's free plan, dated at the pricing page

The account-creation step said the free tier supports up to 10 users; the
pricing page (read 2026-09-30) lists unlimited members, 2 teams and 250
issues. The issue cap is the limit a cascade meets first.

Trace rows landed: review/portability/37.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
~~~~

---

### Task V9.14: Scaffold's label taxonomy includes the labels its flows apply (review/consistency/39 (unverified; holds); D56)

Checked 2026-09-30: the starter bug form applies `triage` (`github-starter-templates.md:18`), the supersede flows apply `superseded` (the four `backends.md` copies, rough-in's `planning-backend-matrix.md:32`, `hitl-question-bank.md:114`), and the rollback flows apply `transition-rollback` (blueprint, framing and rough-in `planning-backend-commit.md`); `github_only_profile.md` Step 3 — "a label named nowhere is not created" — creates none of them.

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md`
- Modify: `.claude/skills/scaffold/references/github_only_profile.md`
- Modify: `.claude/skills/scaffold/references/linear_planning.md`

**Interfaces:**
- Consumes: nothing.
- Produces: the **lifecycle** axis in Step 3 and the Linear label line; the check that all three labels are in the taxonomy.

- [ ] **Step 1: Write the check.** In `.claude/rules/cbk-conventions-reference.md` § Verification, insert these lines immediately before `echo "verification: kit sub-block complete"`:

~~~~bash
# Every label a flow applies is in scaffold's taxonomy (V9.14): the intake holding label and the supersede and rollback
# marks are created with the rest, never on a repo that lacks them.
for l in triage superseded transition-rollback; do grep -q "\`$l\`" .claude/skills/scaffold/references/github_only_profile.md || { echo "github_only_profile.md's label taxonomy lacks \`$l\` (a flow applies it)"; exit 1; }; done
~~~~

- [ ] **Step 2: Run it against the unfixed files — it must fail.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected (the last two lines, then the exit):

~~~~text
github_only_profile.md's label taxonomy lacks `triage` (a flow applies it)
verification: block exited 1
exit=1
~~~~

- [ ] **Step 3: Make the change.** Each replacement is an exact-string edit; each anchor was verified to occur exactly once at `643f7ff` plus the earlier V9 tasks, in text no other cluster's task changes (§ Ownership map) unless this task names the exception. If an anchor is missing, stop and reconcile — never guess.

In `.claude/skills/scaffold/references/github_only_profile.md`, replace:

~~~~text
**meta** — `meta`; **review control**
~~~~

with:

~~~~text
**meta** — `meta`; **lifecycle** — `triage` (the starter bug form's holding label, `cbk-conventions-reference.md` § Front door), `superseded` (the re-framing and re-rough-in supersedes), `transition-rollback` (a partial-failure rollback); **review control**
~~~~

In `.claude/skills/scaffold/references/linear_planning.md`, replace:

~~~~text
plus one `area:<slug>` label per anticipated workstream area, mirroring the GitHub label set.
~~~~

with:

~~~~text
plus one `area:<slug>` label per anticipated workstream area and the lifecycle labels the supersede and rollback flows apply (`superseded`, `transition-rollback`), mirroring the GitHub label set.
~~~~

- [ ] **Step 4: Run the block — it must pass.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`

Expected (read by content, not position — `N` is the tree's always-loaded total at this point, and no `WARN` or `VIOLATION` line prints):

~~~~text
always-loaded total: N bytes
verification: kit sub-block complete
verification: done
exit=0
~~~~

- [ ] **Step 5: Commit.**

~~~~bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/skills/scaffold/references/github_only_profile.md \
  .claude/skills/scaffold/references/linear_planning.md
git commit -F- <<'MSG'
docs(scaffold): V9.14 — the label taxonomy creates the labels the flows apply

The starter bug form applies triage, the supersede flows superseded and the
partial-failure rollback transition-rollback, but scaffold's taxonomy
created none of them. Step 3 gains a lifecycle axis and the Linear taxonomy
names the two it uses; the block checks all three.

Trace rows landed: review/consistency/39.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
~~~~

---

### Task V9.15: Scaffold's reference and checklist agree with its SKILL.md (review/consistency/41, review/claude-code/55, review/consistency/46 (all unverified; all hold); D56)

Checked 2026-09-30. (41) `github_only_profile.md` says "four detection states" and opens with an empty duplicate `### State 1` heading; SKILL.md's matrix has three; the bootstrap checklist template still says "state 2" and "State 4 (no MCP)". (55) Its light-mode list says "Skip the `.github/` issue templates", while SKILL.md keeps Stage 2.5's gate in every rigor mode. (46) SKILL.md says "five HITL gates" at line 21 and lists six at § HITL gates summary. The finding's second suggestion — renaming backend selection's Stage 0–3 so "Stage N" has one meaning — is not taken (a rename across `backend_selection.md` and the test cases for a naming preference); the one ambiguous citation (SKILL.md:47) gains its qualifier instead. The checklist template is shared: these two sentences sit outside every other cluster's rows.

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md`
- Modify: `.claude/skills/scaffold/references/github_only_profile.md`
- Modify: `.claude/skills/scaffold/references/bootstrap_checklist_template.md`
- Modify: `.claude/skills/scaffold/SKILL.md`

**Interfaces:**
- Consumes: V1, V2, V5 and V8's rows in `bootstrap_checklist_template.md` (different lines).
- Produces: the `absent` check for the stale state and gate wording over `.claude/skills/scaffold/`.

- [ ] **Step 1: Write the check.** In `.claude/rules/cbk-conventions-reference.md` § Verification, insert these lines immediately before `echo "verification: kit sub-block complete"`:

~~~~bash
# Scaffold's reference and checklist agree with its SKILL.md (V9.15): three detection states, one heading each, Stage
# 2.5's templates kept in light mode, and the gate count its own summary lists (the literals split themselves).
absent grep -rnE "four detection state[s]|State [4] \(no MCP\)|because state [2]\)|Full automation \(GitHub MCP|Skip the \`\.github/\` issue template[s]|with five HITL gate[s]" .claude/skills/scaffold/
~~~~

- [ ] **Step 2: Run it against the unfixed files — it must fail.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected (the last two lines, then the exit):

~~~~text
VIOLATION (matched above): grep -rnE four detection state[s]|State [4] \(no MCP\)|because state [2]\)|Full automation \(GitHub MCP|Skip the `\.github/` issue template[s]|with five HITL gate[s] .claude/skills/scaffold/
verification: block exited 1
exit=1
~~~~

- [ ] **Step 3: Make the change.** Each replacement is an exact-string edit; each anchor was verified to occur exactly once at `643f7ff` plus the earlier V9 tasks, in text no other cluster's task changes (§ Ownership map) unless this task names the exception. If an anchor is missing, stop and reconcile — never guess.

In `.claude/skills/scaffold/references/github_only_profile.md`, replace:

~~~~text
Covers what scaffold actually does in each of the four detection states (see SKILL.md),
~~~~

with:

~~~~text
Covers what scaffold actually does in each of the three detection states (SKILL.md § The detection matrix),
~~~~

In `.claude/skills/scaffold/references/github_only_profile.md`, replace:

~~~~text
### State 1 — Full automation (GitHub MCP + projects toolset + write scopes)

### State 1 — MCP + write scopes (the common case)
~~~~

with:

~~~~text
### State 1 — MCP + write scopes (the common case)
~~~~

In `.claude/skills/scaffold/references/github_only_profile.md`, replace:

~~~~text
- **Skip the `.github/` issue templates** unless the brief implies they matter
~~~~

with:

~~~~text
- **Skip the starter bug and feature forms** unless the brief implies they matter — never Stage 2.5's cascade issue templates, whose approval gate SKILL.md keeps in every rigor mode
~~~~

In `.claude/skills/scaffold/references/bootstrap_checklist_template.md`, replace:

~~~~text
(e.g. no project board because state 2)
~~~~

with:

~~~~text
(e.g. no project board because the operator declined one)
~~~~

In `.claude/skills/scaffold/references/bootstrap_checklist_template.md`, replace:

~~~~text
State 2 (no projects toolset) omits the project board row. State 4 (no MCP) puts everything in section 2 (manual instructions) and the verification matrix becomes longer.
~~~~

with:

~~~~text
Without the GitHub MCP (SKILL.md's third detection state), everything goes in section 2 (manual instructions) and the verification matrix becomes longer.
~~~~

In `.claude/skills/scaffold/SKILL.md`, replace:

~~~~text
with five HITL gates
~~~~

with:

~~~~text
with six HITL gates
~~~~

In `.claude/skills/scaffold/SKILL.md`, replace:

~~~~text
If knowledge = `notion`, Stage 2's follow-up runs
~~~~

with:

~~~~text
If knowledge = `notion`, backend selection's Stage 2 follow-up runs
~~~~

- [ ] **Step 4: Run the block — it must pass.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`

Expected (read by content, not position — `N` is the tree's always-loaded total at this point, and no `WARN` or `VIOLATION` line prints):

~~~~text
always-loaded total: N bytes
verification: kit sub-block complete
verification: done
exit=0
~~~~

- [ ] **Step 5: Commit.**

~~~~bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/skills/scaffold/references/github_only_profile.md \
  .claude/skills/scaffold/references/bootstrap_checklist_template.md \
  .claude/skills/scaffold/SKILL.md
git commit -F- <<'MSG'
docs(scaffold): V9.15 — the reference and checklist agree with SKILL.md

github_only_profile.md said four detection states and carried an empty
duplicate State 1 heading; the checklist template used the retired four-state
numbering; light mode skipped the issue templates SKILL.md keeps mandatory;
and SKILL.md counted five gates where its summary lists six. Each now
matches SKILL.md, and the block refuses the stale wording.

Trace rows landed: review/consistency/41, review/claude-code/55,
review/consistency/46.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
~~~~

---

### Task V9.16: The count ranges agree with the contracts (review/consistency/42 (unverified; holds); D56)

Checked 2026-09-30: rough-in's `test_cases.md:24` expects 3-7 R-issues against the contract's 2–6 (`rough-in/references/contract.md:96`, SKILL.md:93, README, the conventions' example checklist); framing's `milestone-template.md:185` says 3-5 milestones per project against the contract's 3–6, 2–7 at the outside (`framing/references/contract.md:55`, `procedure.md:94`). Framing's `test_cases.md:20` ("3-5 milestones" for one worked example) sits inside that range and stays.

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md`
- Modify: `.claude/skills/rough-in/references/test_cases.md`
- Modify: `.claude/skills/framing/references/templates/milestone-template.md`

**Interfaces:**
- Consumes: nothing.
- Produces: two `absent` checks pinning the corrected ranges.

- [ ] **Step 1: Write the check.** In `.claude/rules/cbk-conventions-reference.md` § Verification, insert these lines immediately before `echo "verification: kit sub-block complete"`:

~~~~bash
# The count ranges have one statement each (V9.16): 2–6 R-issues per milestone (rough-in's contract) and 3–6 milestones
# per workstream, 2–7 at the outside (framing's contract) — the test case and the milestone template agree.
absent grep -n "produces 3-7 R-issue[s]" .claude/skills/rough-in/references/test_cases.md
absent grep -n "3-5 milestones per projec[t]" .claude/skills/framing/references/templates/milestone-template.md
~~~~

- [ ] **Step 2: Run it against the unfixed files — it must fail.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected (the last two lines, then the exit):

~~~~text
VIOLATION (matched above): grep -n produces 3-7 R-issue[s] .claude/skills/rough-in/references/test_cases.md
verification: block exited 1
exit=1
~~~~

- [ ] **Step 3: Make the change.** Each replacement is an exact-string edit; each anchor was verified to occur exactly once at `643f7ff` plus the earlier V9 tasks, in text no other cluster's task changes (§ Ownership map) unless this task names the exception. If an anchor is missing, stop and reconcile — never guess.

In `.claude/skills/rough-in/references/test_cases.md`, replace:

~~~~text
produces 3-7 R-issues with titles
~~~~

with:

~~~~text
produces 2-6 R-issues with titles
~~~~

In `.claude/skills/framing/references/templates/milestone-template.md`, replace:

~~~~text
Typical framings produce **3-5 milestones per project**, but that range is a secondary signal, not a prescription. A small, tightly-scoped project might legitimately have 2 milestones (walking skeleton + completion). A large, multi-surface project might legitimately have 6 milestones spanning
~~~~

with:

~~~~text
Typical framings produce **3-6 milestones per workstream** (2-7 at the outside — `references/contract.md`), but that range is a secondary signal, not a prescription. A small, tightly-scoped workstream might legitimately have 2 milestones (walking skeleton + completion). A large, multi-surface workstream might legitimately have 6-7 milestones spanning
~~~~

- [ ] **Step 4: Run the block — it must pass.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`

Expected (read by content, not position — `N` is the tree's always-loaded total at this point, and no `WARN` or `VIOLATION` line prints):

~~~~text
always-loaded total: N bytes
verification: kit sub-block complete
verification: done
exit=0
~~~~

- [ ] **Step 5: Commit.**

~~~~bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/skills/rough-in/references/test_cases.md \
  .claude/skills/framing/references/templates/milestone-template.md
git commit -F- <<'MSG'
docs(skills): V9.16 — count ranges agree with the contracts

Rough-in's test case expected 3-7 R-issues against the contract's 2-6, and
the milestone template said 3-5 milestones per project against framing's
3-6 (2-7 at the outside). Both now state the contract's range.

Trace rows landed: review/consistency/42.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
~~~~

---

### Task V9.17: The restamp standing item is on every checklist the conventions say carries it (review/consistency/43 (unverified; holds); D56)

Checked 2026-09-30: `cbk-conventions-reference.md` § Phase exit checklist says every shipped phase-exit checklist "(scaffold, blueprint, framing)" carries the restamp item; `command grep -n restamp .claude/skills/framing/SKILL.md .claude/skills/rough-in/SKILL.md` prints nothing, though framing's and rough-in's `backends.md` carry a `Designed-unexercised` flag. The item is added to both (the claim then covers four phases).

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md`
- Modify: `.claude/skills/framing/SKILL.md`
- Modify: `.claude/skills/rough-in/SKILL.md`

**Interfaces:**
- Consumes: nothing.
- Produces: the check that all four phase SKILL.md checklists carry the item.

- [ ] **Step 1: Write the check.** In `.claude/rules/cbk-conventions-reference.md` § Verification, insert these lines immediately before `echo "verification: kit sub-block complete"`:

~~~~bash
# The restamp standing item is on every phase-exit checklist the conventions say carries it (V9.17).
for s in scaffold blueprint framing rough-in; do grep -q 'flags as individually unexercised has been restamped in the same commit' .claude/skills/$s/SKILL.md || { echo "$s/SKILL.md's phase-exit checklist lacks the restamp standing item"; exit 1; }; done
~~~~

- [ ] **Step 2: Run it against the unfixed files — it must fail.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected (the last two lines, then the exit):

~~~~text
framing/SKILL.md's phase-exit checklist lacks the restamp standing item
verification: block exited 1
exit=1
~~~~

- [ ] **Step 3: Make the change.** Each replacement is an exact-string edit; each anchor was verified to occur exactly once at `643f7ff` plus the earlier V9 tasks, in text no other cluster's task changes (§ Ownership map) unless this task names the exception. If an anchor is missing, stop and reconcile — never guess.

In each of `.claude/skills/framing/SKILL.md`, `.claude/skills/rough-in/SKILL.md` — identically, replace:

~~~~text
- [ ] The verification pass ran and its defects were fixed or consciously kept (recorded in the gate)
~~~~

with:

~~~~text
- [ ] The verification pass ran and its defects were fixed or consciously kept (recorded in the gate)
- [ ] Every call this run exercised that `references/backends.md` flags as individually unexercised has been restamped in the same commit
~~~~

In `.claude/rules/cbk-conventions-reference.md`, replace:

~~~~text
Every phase-exit checklist the kit ships (scaffold, blueprint, framing) carries one standing item:
~~~~

with:

~~~~text
Every phase-exit checklist the kit ships (scaffold, blueprint, framing, rough-in) carries one standing item:
~~~~

- [ ] **Step 4: Run the block — it must pass.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`

Expected (read by content, not position — `N` is the tree's always-loaded total at this point, and no `WARN` or `VIOLATION` line prints):

~~~~text
always-loaded total: N bytes
verification: kit sub-block complete
verification: done
exit=0
~~~~

- [ ] **Step 5: Commit.**

~~~~bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/skills/framing/SKILL.md \
  .claude/skills/rough-in/SKILL.md
git commit -F- <<'MSG'
docs(skills): V9.17 — the restamp item on framing's and rough-in's exit checklists

The conventions said every shipped phase-exit checklist carries the
"restamp an exercised unexercised call" item; framing's and rough-in's did
not, though their backends.md carries such a flag. Both gain it, the claim
names four phases, and the block checks all four.

Trace rows landed: review/consistency/43.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
~~~~

---

### Task V9.18: Blueprint counts its docs the way its own table does (review/consistency/51 (unverified; holds); D56)

Checked 2026-09-30: `blueprint/SKILL.md` says six prose foundation docs, but its table lists seven (`docs/cbk/ROADMAP.md` on two axes); gate 4 claims "six iterations, one per doc" while gate 6 reviews `blueprint.md`, doc 6. The README's "six" (line 161) is V10's — handed with the count wording.

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md`
- Modify: `.claude/skills/blueprint/SKILL.md`
- Modify: `.claude/skills/blueprint/references/foundation-doc-templates.md`

**Interfaces:**
- Consumes: nothing.
- Produces: the check for the axis-aware count and the corrected gate-4 wording.

- [ ] **Step 1: Write the check.** In `.claude/rules/cbk-conventions-reference.md` § Verification, insert these lines immediately before `echo "verification: kit sub-block complete"`:

~~~~bash
# Blueprint counts its docs the way its own table does (V9.18): six, plus ROADMAP.md on two axes; gate 4 does not
# re-review blueprint.md, which gate 6 owns.
grep -q 'seven on the `github-issues` and `in-repo-markdown` axes' .claude/skills/blueprint/SKILL.md || { echo "blueprint/SKILL.md counts six foundation docs where its table lists seven on two axes"; exit 1; }
absent grep -n "six iterations through this gate, one per do[c]" .claude/skills/blueprint/SKILL.md
~~~~

- [ ] **Step 2: Run it against the unfixed files — it must fail.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected (the last two lines, then the exit):

~~~~text
blueprint/SKILL.md counts six foundation docs where its table lists seven on two axes
verification: block exited 1
exit=1
~~~~

- [ ] **Step 3: Make the change.** Each replacement is an exact-string edit; each anchor was verified to occur exactly once at `643f7ff` plus the earlier V9 tasks, in text no other cluster's task changes (§ Ownership map) unless this task names the exception. If an anchor is missing, stop and reconcile — never guess.

In `.claude/skills/blueprint/SKILL.md`, replace:

~~~~text
Blueprint produces six prose foundation docs plus tooling configs.
~~~~

with:

~~~~text
Blueprint produces six prose foundation docs — seven on the `github-issues` and `in-repo-markdown` axes, where `docs/cbk/ROADMAP.md` joins them — plus tooling configs.
~~~~

In `.claude/skills/blueprint/SKILL.md`, replace:

~~~~text
(six iterations through this gate, one per doc)
~~~~

with:

~~~~text
(one iteration per doc in the table above except `docs/cbk/blueprint.md`, which gate 6 reviews — `ROADMAP.md` included where the axis produces it)
~~~~

In `.claude/skills/blueprint/SKILL.md`, replace:

~~~~text
- **Six foundation docs** at known locations, all reviewed and committed
~~~~

with:

~~~~text
- **Six foundation docs** (seven with `docs/cbk/ROADMAP.md` on the `github-issues` and `in-repo-markdown` axes) at known locations, all reviewed and committed
~~~~

In `.claude/skills/blueprint/references/foundation-doc-templates.md`, replace:

~~~~text
Blueprint produces six prose foundation documents plus tooling configs.
~~~~

with:

~~~~text
Blueprint produces six prose foundation documents — seven on the `github-issues` and `in-repo-markdown` axes, where `docs/cbk/ROADMAP.md` joins them (`templates/roadmap.md`) — plus tooling configs.
~~~~

- [ ] **Step 4: Run the block — it must pass.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`

Expected (read by content, not position — `N` is the tree's always-loaded total at this point, and no `WARN` or `VIOLATION` line prints):

~~~~text
always-loaded total: N bytes
verification: kit sub-block complete
verification: done
exit=0
~~~~

- [ ] **Step 5: Commit.**

~~~~bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/skills/blueprint/SKILL.md \
  .claude/skills/blueprint/references/foundation-doc-templates.md
git commit -F- <<'MSG'
docs(blueprint): V9.18 — the doc count matches the table: six, seven on two axes

Blueprint said six foundation docs while its table lists ROADMAP.md as the
seventh on the github-issues and in-repo-markdown axes, and gate 4 counted
blueprint.md, which gate 6 reviews. The count, the gate and the hand-off
contract now say what the table does.

Trace rows landed: review/consistency/51.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
~~~~

---

### Task V9.19: A reference half's pointer claim is checked, not asserted (review/consistency/49 (unverified; holds); D56; `cbk-conventions.md` § Multi-surface facts)

Checked 2026-09-30 (the `## Acceptance criteria` and `## Phase exit checklist` hits are example headings inside code fences, excluded): `cbk-conventions-reference.md` has four `## ` sections with no pointer heading in the contract (§ .gitignore anchoring, § ADR relation grains, § Required-checks trap, § Hook authoring), `pr-review-reference.md` two (§ Authoring a project-local reviewer, § Reviewer precedent memory — genres and staleness), `orchestration-reference.md` two — each preamble claims "a pointer heading for every section here". Adding eight headings to always-loaded contracts would cost bytes D59 is paying down; the claim is corrected instead, and the block turns it into a check. `orchestration-reference.md` (and V5's new `knowledge-backend-reference.md`) are V5's — handed with the sentence. If a cluster before V9 added a new `## ` section to either half, Step 2 names it: add it to that preamble's list.

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md`
- Modify: `.claude/rules/pr-review-reference.md`

**Interfaces:**
- Consumes: V2's and V8's sections in the conventions' reference half (unchanged headings); V7's edits to `pr-review-reference.md` (§ Anti-patterns, § Authoring — no new `## ` heading).
- Produces: the check that every `## ` section of the two halves has a contract pointer heading or is named in its preamble — any later cluster adding a section to either half names it there.

- [ ] **Step 1: Write the check.** In `.claude/rules/cbk-conventions-reference.md` § Verification, insert these lines immediately before `echo "verification: kit sub-block complete"`:

~~~~bash
# A reference half's pointer claim is checked, not asserted (V9.19): every `## ` section outside a code fence has a
# pointer heading in its contract or is named in the half's preamble as added since the split. The heading list is fed
# as a here-string, so a failing heading's exit 1 ends the block from its own shell.
for p in cbk-conventions pr-review; do r=.claude/rules/$p-reference.md; pre=$(grep -m1 '^> \*\*Path-scoped' "$r"); while IFS= read -r h; do [ -n "$h" ] || continue; grep -qxF "## $h" .claude/rules/$p.md || grep -qF "§ $h" <<<"$pre" || { echo "$r § $h has no pointer heading in $p.md and is not named in its preamble"; exit 1; }; done <<<"$(awk '/^```/{f=!f; next} !f && /^## /{sub(/^## /, ""); print}' "$r")"; done
~~~~

- [ ] **Step 2: Run it against the unfixed files — it must fail.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected (the last two lines, then the exit):

~~~~text
.claude/rules/cbk-conventions-reference.md § .gitignore anchoring has no pointer heading in cbk-conventions.md and is not named in its preamble
verification: block exited 1
exit=1
~~~~

- [ ] **Step 3: Make the change.** Each replacement is an exact-string edit; each anchor was verified to occur exactly once at `643f7ff` plus the earlier V9 tasks, in text no other cluster's task changes (§ Ownership map) unless this task names the exception. If an anchor is missing, stop and reconcile — never guess.

In `.claude/rules/cbk-conventions-reference.md`, replace:

~~~~text
`cbk-conventions.md` (always loaded) keeps a pointer heading for every section here, so `cbk-conventions.md § <section>` citations resolve to the pointer and the pointer to this file.
~~~~

with:

~~~~text
`cbk-conventions.md` (always loaded) keeps a pointer heading for every section moved here at the split, so `cbk-conventions.md § <section>` citations resolve to the pointer and the pointer to this file; a section added here since (§ .gitignore anchoring, § ADR relation grains, § Required-checks trap, § Hook authoring) is cited by this file's own name, `cbk-conventions-reference.md § <section>`.
~~~~

In `.claude/rules/pr-review-reference.md`, replace:

~~~~text
`pr-review.md` (always loaded) keeps a pointer heading for every section here.
~~~~

with:

~~~~text
`pr-review.md` (always loaded) keeps a pointer heading for every section moved here at the split; a section added here since (§ Authoring a project-local reviewer, § Reviewer precedent memory — genres and staleness) is cited by this file's own name.
~~~~

Then widen the check to V5's halves where they already agree. Run `command grep -c 'added here since' .claude/rules/orchestration-reference.md .claude/rules/knowledge-backend-reference.md 2>/dev/null`. For each half that prints `1` (V5 used the handed sentence, § Handed to other clusters › V5), add its stem to the loop in the Step 1 check — `for p in cbk-conventions pr-review orchestration knowledge-backend; do` with only the stems that passed — and re-run the block. A half that prints `0` or does not exist stays out of the loop; its handed row stands for V5.

- [ ] **Step 4: Run the block — it must pass.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`

Expected (read by content, not position — `N` is the tree's always-loaded total at this point, and no `WARN` or `VIOLATION` line prints):

~~~~text
always-loaded total: N bytes
verification: kit sub-block complete
verification: done
exit=0
~~~~

- [ ] **Step 5: Commit.**

~~~~bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/rules/pr-review-reference.md
git commit -F- <<'MSG'
docs(rules): V9.19 — the reference halves' pointer claim is checked

cbk-conventions-reference.md and pr-review-reference.md claimed their
contracts keep a pointer heading for every section, but six sections added
after the split have none. Each preamble now says which sections moved at
the split and names the ones added since, which are cited by the reference
file's own name; the block checks every section against that statement.

Trace rows landed: review/consistency/49 (cbk-conventions and pr-review
halves).

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
~~~~

---

### Task V9.20: Invented names in the kit's examples (review/claude-code/54 (unverified; holds — the identifier half); D56; the portability invariant)

Checked 2026-09-30: `command grep -rn -i 'tuito[r]\|anubi[s]\|per-Pilo[t]\|Servo\.set_angl[e]' .claude/` finds five lines in rough-in's `procedure.md`, `adr-new/SKILL.md` and `agents/adr-conformance-reviewer.md` — identifiers from other projects in portable examples. The finding's `#58` half lands in V9.1, V9.6 and V9.21. The check is kit-tree only: a target's own examples may name its own domain.

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md`
- Modify: `.claude/skills/rough-in/references/procedure.md`
- Modify: `.claude/skills/adr-new/SKILL.md`
- Modify: `.claude/agents/adr-conformance-reviewer.md`

**Interfaces:**
- Consumes: V9.6's rewrite of `adr-new/SKILL.md` (different lines: 27, 28 and 33).
- Produces: the kit-tree-only `absent` check for the four identifiers.

- [ ] **Step 1: Write the check.** In `.claude/rules/cbk-conventions-reference.md` § Verification, insert these lines immediately before `echo "verification: kit sub-block complete"`:

~~~~bash
# Kit tree only: no foreign project's identifiers in the kit's examples (V9.20) — examples are invented, generic names.
[ -f docs/cbk/scaffold.md ] || absent grep -rn -i 'tuito[r]\|anubi[s]\|per-Pilo[t]\|Servo\.set_angl[e]' .claude/
~~~~

- [ ] **Step 2: Run it against the unfixed files — it must fail.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected (the last two lines, then the exit):

~~~~text
VIOLATION (matched above): grep -rn -i tuito[r]\|anubi[s]\|per-Pilo[t]\|Servo\.set_angl[e] .claude/
verification: block exited 1
exit=1
~~~~

- [ ] **Step 3: Make the change.** Each replacement is an exact-string edit; each anchor was verified to occur exactly once at `643f7ff` plus the earlier V9 tasks, in text no other cluster's task changes (§ Ownership map) unless this task names the exception. If an anchor is missing, stop and reconcile — never guess.

In `.claude/skills/rough-in/references/procedure.md`, replace:

~~~~text
the rendered output for `tuitor_engine::verifier::Verifier` includes
~~~~

with:

~~~~text
the rendered output for `core_engine::verifier::Verifier` includes
~~~~

In `.claude/skills/adr-new/SKILL.md`, replace:

~~~~text
Example: `vector-store-as-anubis-tool`.
~~~~

with:

~~~~text
Example: `vector-store-as-agent-tool`.
~~~~

In `.claude/skills/adr-new/SKILL.md`, replace:

~~~~text
Example: `Vector store as an Anubis tool, not an MCP server`.
~~~~

with:

~~~~text
Example: `Vector store as an agent tool, not an MCP server`.
~~~~

In `.claude/skills/adr-new/SKILL.md`, replace:

~~~~text
Format: `yes (per-Pilot) | no (config-time)`.
~~~~

with:

~~~~text
Format: `yes (per-tenant) | no (config-time)`.
~~~~

In `.claude/agents/adr-conformance-reviewer.md`, replace:

~~~~text
(line 42 calls `Servo.set_angle/2` directly)
~~~~

with:

~~~~text
(line 42 calls `Actuator.set_angle/2` directly)
~~~~

- [ ] **Step 4: Run the block — it must pass.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`

Expected (read by content, not position — `N` is the tree's always-loaded total at this point, and no `WARN` or `VIOLATION` line prints):

~~~~text
always-loaded total: N bytes
verification: kit sub-block complete
verification: done
exit=0
~~~~

- [ ] **Step 5: Commit.**

~~~~bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/skills/rough-in/references/procedure.md \
  .claude/skills/adr-new/SKILL.md \
  .claude/agents/adr-conformance-reviewer.md
git commit -F- <<'MSG'
docs(skills): V9.20 — the kit's examples use invented names

Rough-in's worked example, adr-new's slug, title and configurability
examples and the ADR reviewer's "be specific" example named identifiers from
other projects. They are replaced with generic ones, and the block keeps
them out of the kit tree.

Trace rows landed: review/claude-code/54 (identifiers).

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
~~~~

---

### Task V9.21: No sibling name and no bare kit-issue number in shipped content (review/portability/31, review/portability/32, release/5, release/10, #69/c5859756889/apply-h4/4; D53)

Both checks are kit-tree only: in a target, a bare `#81` is the target's own issue and its own name belongs in its README. The sibling check uses `git grep` so the untracked `.claude/agent-memory/` is not read. The bare-citation scope is the list `release/5` measured — the rules, hooks, workflows, agents, the executor quartet, adr-new, the blueprint templates, `settings.json` and `.github` — never `.claude/skills/*/references` broadly, whose examples use illustrative numbers (`#42`, `#48`). The verifier's correction stands: GitHub does not autolink `#N` in repository files, so the harm is a citation that resolves to the wrong issue when an agent follows it, not a mis-link. V10's `README.md`, `CHANGELOG.md` and `CLAUDE.md` are checked by V10. The sibling parenthetical sits in V2's § Hook authoring bullet, and V2 (earlier in the order) replaces it with `(context-builder-kit#58 item 4)`; so on the planned order the sibling check is already green when this task runs, and Step 3's deletion is skipped because its anchor is absent.

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md`
- (and every file the Step 3 sweep lists — at `643f7ff` plus V9.1–V9.20: `.claude/hooks/detect-forked-agent-memory.sh`, `protect-lock-files.sh`, `require-repo-root-for-agents.sh`, `.claude/skills/blueprint/references/templates/claude-review.yml`, `.claude/workflows/agent-cost.py`, `finish-ab/finish-ab.js`, `review-sweep.js`, `tests/finish-ab-shape.mjs`, `tests/review-sweep-accounting.mjs`; whatever their owners V2, V4, V6 and V7 already rewrote drops out)

**Interfaces:**
- Consumes: the owners' own rewrites (V2 hooks, V4 `claude-review.yml`, V6 harness files, V7 `review-sweep.js` and its test), V9.1's executor pair and V9.6's adr-new line; V10's § Syncing the kit paragraph carries one citation this sweep rewrites token-for-token (`(context-builder-kit#58, second application, item 10)`), so V10 anchors on that form.
- Produces: the two kit-tree-only checks; every kit-issue citation in the scoped paths in the form `context-builder-kit#N` — the form every later cluster writes.

- [ ] **Step 1: Write the check.** In `.claude/rules/cbk-conventions-reference.md` § Verification, insert these lines immediately before `echo "verification: kit sub-block complete"`:

~~~~bash
# Kit tree only (V9.21, D53): shipped content names no sibling project, and cites the kit's own issues as
# context-builder-kit#N — a bare number reads as the target's own issue once the file is copied into a target.
# The patterns split or bracket themselves so these lines never match.
[ -f docs/cbk/scaffold.md ] || absent git grep -n -i -E 'you-are-hea[r]|echospher[e]' -- .claude .github README.md CLAUDE.md
[ -f docs/cbk/scaffold.md ] || absent grep -rnE '(^|[[:space:](,;])#[0-9]{1,3}\b' .claude/rules .claude/hooks .claude/workflows .claude/agents .claude/commands/finish.md .claude/commands/finish-procedure.md .claude/skills/rough-in/references/finish-command.md .claude/skills/rough-in/references/finish-procedure.md .claude/skills/adr-new .claude/skills/blueprint/references/templates .claude/settings.json .github
~~~~

- [ ] **Step 2: Run it against the unfixed files — it must fail.**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected on the planned order — V2 has already replaced the sibling parenthetical with `(context-builder-kit#58 item 4)`, so the sibling check passes and the bare-citation check is the first to fire (the last two lines, then the exit):

~~~~text
VIOLATION (matched above): grep -rnE (^|[[:space:](,;])#[0-9]{1,3}\b .claude/rules .claude/hooks .claude/workflows .claude/agents .claude/commands/finish.md .claude/commands/finish-procedure.md .claude/skills/rough-in/references/finish-command.md .claude/skills/rough-in/references/finish-procedure.md .claude/skills/adr-new .claude/skills/blueprint/references/templates .claude/settings.json .github
verification: block exited 1
exit=1
~~~~

If the parenthetical `(you-are-hear #81 → PR #82)` is still in the file (V2 has not landed), the sibling check fires first instead: `VIOLATION (matched above): git grep -n -i -E you-are-hea[r]|echospher[e] -- .claude .github README.md CLAUDE.md`, then `verification: block exited 1`. Prove by a mutation you restore at once each check that did not go red above — on the planned order the sibling check always needs it, and the bare-citation check needs it too if every owner already rewrote its citations and the run above exited 0:

- `printf '\n<!-- see #58 -->\n' >> .claude/rules/simplification.md && bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; git checkout -- .claude/rules/simplification.md` — expected: the bare-citation `VIOLATION (matched above): grep -rnE …` line and `verification: block exited 1`.
- `printf '\n<!-- you-are-hear -->\n' >> .claude/rules/simplification.md && bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; git checkout -- .claude/rules/simplification.md` — expected: the `git grep` sibling VIOLATION line and `verification: block exited 1`.

Record whichever red lines you observed in the PR body's red-first table.

- [ ] **Step 3: Make the change.** Each replacement is an exact-string edit; each anchor was verified to occur exactly once at `643f7ff` plus the earlier V9 tasks, in text no other cluster's task changes (§ Ownership map) unless this task names the exception. If an anchor is missing, stop and reconcile — never guess.

**Conditional — skip this deletion when its anchor is absent.** V2 (earlier in the order) rewrites this parenthetical to `(context-builder-kit#58 item 4)` in § Hook authoring's stdin/exit-contract bullet, so on the planned order the anchor below is gone and this edit is skipped; that absence is the one exception to "stop and reconcile" above. Check first: `command grep -c 'you-are-hear #81' .claude/rules/cbk-conventions-reference.md` — `0` with `command grep -c '(context-builder-kit#58 item 4)' .claude/rules/cbk-conventions-reference.md` printing at least `1` means V2 landed: skip the deletion, leave V2's citation as it is, and say so in the commit body. Only when the first count is `1` (V2 has not landed), in `.claude/rules/cbk-conventions-reference.md`, delete exactly this text — the leading space included, so the sentence closes on the period that follows it:

~~~~text
 (you-are-hear #81 → PR #82)
~~~~

If both counts are `0`, the sentence was rewritten some other way: stop and reconcile.

Then show the second check red on the tree as it now stands, before the sweep (if Step 2's run already showed this line, this run repeats it; if the run exits 0 because every owner already rewrote its citations, Step 2's mutation is this check's red — go on to the sweep, whose count is then `0` from the start):

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2`

Expected: `VIOLATION (matched above): grep -rnE (^|[[:space:](,;])#[0-9]{1,3}\b .claude/rules .claude/hooks .claude/workflows .claude/agents .claude/commands/finish.md .claude/commands/finish-procedure.md .claude/skills/rough-in/references/finish-command.md .claude/skills/rough-in/references/finish-procedure.md .claude/skills/adr-new .claude/skills/blueprint/references/templates .claude/settings.json .github` and `verification: block exited 1`. (On `643f7ff` plus V9.1–V9.20 alone the grep lists 26 lines: `detect-forked-agent-memory.sh` 6, `protect-lock-files.sh` 1, `require-repo-root-for-agents.sh` 1, `cbk-conventions-reference.md` 9, `claude-review.yml` 2, `agent-cost.py` 1, `finish-ab.js` 1, `review-sweep.js` 3, `finish-ab-shape.mjs` 1, `review-sweep-accounting.mjs` 1. After V1–V8 it lists only what their owners left.)

Now sweep the rest — the same pattern, rewritten token for token (GNU `sed`, which the block's host already requires for `\b`):

```bash
P='.claude/rules .claude/hooks .claude/workflows .claude/agents .claude/commands/finish.md .claude/commands/finish-procedure.md .claude/skills/rough-in/references/finish-command.md .claude/skills/rough-in/references/finish-procedure.md .claude/skills/adr-new .claude/skills/blueprint/references/templates .claude/settings.json .github'
command grep -rnE '(^|[[:space:](,;])#[0-9]{1,3}\b' $P
command grep -rlE '(^|[[:space:](,;])#[0-9]{1,3}\b' $P | xargs -r sed -i -E 's/(^|[[:space:](,;])#([0-9]{1,3})\b/\1context-builder-kit#\2/g'
command grep -rnE '(^|[[:space:](,;])#[0-9]{1,3}\b' $P | wc -l
git diff -U0 | command grep '^+[^+]' | command grep -oE '.{0,40}context-builder-kit#[0-9]+.{0,20}'
```

Expected: the first grep lists the remaining citations; the count after the sweep is `0`; every line the last command prints is a citation (`(context-builder-kit#58 item 1)`, `(context-builder-kit#34)` and the like). If any changed line is code rather than a comment or prose, restore that hunk (`git checkout -p`) and edit it by hand. Name, in the commit body, each file whose owner had left a bare citation.

- [ ] **Step 4: Run the block — it must pass.**

Syntax on the touched code: `for h in .claude/hooks/*.sh; do bash -n "$h" || echo "BAD $h"; done; jq empty .claude/settings.json && python3 -c 'import ast, sys; ast.parse(open(sys.argv[1]).read())' .claude/workflows/agent-cost.py && echo ok` — expected `ok` and no `BAD` line. (Parse with `ast`, not `python3 -m py_compile`, which writes a `.claude/workflows/__pycache__/` into the checkout.) The block itself runs the harness stubs (`review-sweep-accounting.mjs`, `finish-ab-shape.mjs`, `agent-cost-fixture.sh`) and the hook fixture, which cover the rewritten comments' files.

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`

Expected (read by content, not position — `N` is the tree's always-loaded total at this point, and no `WARN` or `VIOLATION` line prints):

~~~~text
always-loaded total: N bytes
verification: kit sub-block complete
verification: done
exit=0
~~~~

- [ ] **Step 5: Commit.**

~~~~bash
git add -u .claude .github
swept=$(git diff --cached --name-only | command grep -vxF .claude/rules/cbk-conventions-reference.md || true)
{ cat <<'MSG'
docs(portability): V9.21 — no sibling name, no bare kit-issue number in shipped content

The stdin/exit bullet's sibling parenthetical was already re-cited by V2 as
context-builder-kit#58 item 4, so its deletion was skipped (its anchor was
absent). Every remaining bare citation of the kit's own issues in
the rules, hooks, workflows, agents, executor, adr-new, blueprint templates,
settings and .github becomes context-builder-kit#N, since a bare number is
read as the target's own issue once the file is copied into a target. Two
kit-tree-only checks keep both out.

Trace rows landed: review/portability/31, review/portability/32, release/5
(the sweep and the check), release/10, #69/c5859756889/apply-h4/4.

Files whose owner had left a bare citation, swept here:
MSG
printf '%s\n' "${swept:-none}" | sed 's/^/- /'
printf '\nCo-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>\n'
} | git commit -F-
~~~~

The generated list is the "name each file" the sweep step asks for; `git log -1 --format=%B` should end on the trailer line. If Step 3's deletion did run (V2 had not landed), replace the body's first sentence, before committing, with: "The stdin/exit bullet named a sibling project and cited its issue and PR bare; the dated measurement already carries the evidence, so the parenthetical goes."

---

### Task V9.22: Bracket-split the private target's name in the harvest-4 plan (D62)

The harvest-4 plan's sanitization step (`docs/superpowers/plans/2026-09-21-harvest-4-applied-defects.md:1318`) carries the private target's name, and its ticket-key prefix, as literal alternatives inside a `grep -i` pattern — the only occurrence in the tree. D62: bracket-split them at HEAD; history keeps the old text, and no history rewrite is proposed. A bracketed letter still matches the same text in a `grep` pattern, so the documented command is unchanged in effect. This file names neither: it writes the split forms `cr[e]ase` and `CR[E]-[0-9]` only, and the `perl` substitution below matches the literals through capture groups.

**Files:**
- Modify: `docs/superpowers/plans/2026-09-21-harvest-4-applied-defects.md` (line 1318 only)

**Interfaces:**
- Consumes: nothing.
- Produces: a tree on which the master plan's Task F1 Step 2 denylist grep (`git grep -n -i -E '\bcr[e]ase\b|CR[E]-[0-9]' -- .`) exits 1.

- [ ] **Step 1: The check is the master plan's F1 denylist, counted so the output names no literal.**

Run: `git grep -c -i -E '\bcr[e]ase\b|CR[E]-[0-9]' -- . ; echo "hits=$?"`

- [ ] **Step 2: Run it on the unfixed tree — it must find the one line.**

Expected:

~~~~text
docs/superpowers/plans/2026-09-21-harvest-4-applied-defects.md:1
hits=0
~~~~

- [ ] **Step 3: Split both literals on that line only.**

Run:

~~~~bash
perl -pi -e 'if (/^Sanitization: `grep -rn -i /) { s/\bc(r)e(a)se\b/cr[e]ase/; s/\bC(R)E-\[0-9\]/CR[E]-[0-9]/ }' docs/superpowers/plans/2026-09-21-harvest-4-applied-defects.md
git diff --stat
~~~~

Expected: `1 file changed, 1 insertion(+), 1 deletion(-)`, and the line now begins ``Sanitization: `grep -rn -i 'cr[e]ase\|CR[E]-[0-9]\|echosphere\|you-are-hear\|yah_\|ECH-[0-9]' .claude/ docs/adr/ README.md` ``.

- [ ] **Step 4: Run the denylist and the block.**

Run: `git grep -c -i -E '\bcr[e]ase\b|CR[E]-[0-9]' -- . ; echo "hits=$?"; bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`

Expected (the runner read by content, not position — `N` is the tree's always-loaded total at this point, and no `WARN` or `VIOLATION` line prints):

~~~~text
hits=1
always-loaded total: N bytes
verification: kit sub-block complete
verification: done
exit=0
~~~~

(This cluster file and the other harvest-5 plans are in the tree when this runs; `hits=1` confirms they, too, carry only split forms.)

- [ ] **Step 5: Commit.**

~~~~bash
git add docs/superpowers/plans/2026-09-21-harvest-4-applied-defects.md
git commit -F- <<'MSG'
docs(plan): V9.22 — bracket-split the private target's name in the harvest-4 plan (D62)

The harvest-4 plan's sanitization grep carried the private target's name
and ticket-key prefix as literals; both are bracket-split at HEAD, which
leaves the pattern's matches unchanged. History keeps the old text; no
history rewrite is proposed.

Trace rows landed: D62.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
~~~~

---

## Coverage

Every id in V9's work pack (items, handedIn, critic, review), plus the V9-assigned trace rows that sit in another pack and the other packs' rows V9 lands by the ownership map.

| Id | Lands in |
|---|---|
| `#63/body` | V9.1 |
| `#63/c5901495240/1` | V9.5 |
| `#63/c5901495240/1/check` | V9.5 |
| `#63/c5901495240/2` | V9.5 |
| `#66/body/1` | V9.6 |
| `#66/body/2` | handed to V3 (the `_comment_hooks` trim) and V2 (the ask-gate header's ten verbs) |
| `#66/c5901495490` | handed to V5 (`knowledge-backend.md` § Hook enforcement layer becomes a pointer) |
| `#68/body/1a` | V9.3 (conventions, scaffold output template, contributing template); handed to V2 (`protect-main-branch.sh:79`) |
| `#68/body/1b` | V9.3 |
| `#58/c5901493591/R2` | V9.1 |
| `#58/c5901493591/R3` | V9.6 |
| `#58/c5901493591/R14` | handed to V10 (the audit method in this repository's `CLAUDE.md`); applied by the harvest-5 trace and master Task F3. The harvest-4 spec is history and is not edited |
| `#58/c5901493591/residue-1` | V9.6 |
| `#58/c5901493591/residue-2` | non-goal (spec § Non-goals: collect-then-exit; D31 stands, recorded in the spec, not kit text) |
| `#69/c5859756889/apply-h4/1` | handed to V2 (§ Hook authoring) |
| `#69/c5859756889/apply-h4/2` | handed to V10 (§ Syncing the kit, CHANGELOG v0.5.0) |
| `#69/c5859756889/apply-h4/3` | handed to V10 (§ Syncing the kit, reference half only) |
| `#69/c5859756889/apply-h4/4` | V9.1, V9.6, V9.21; owners V2, V4, V6, V7 in their own files |
| `#69/c5859756889/apply-h4/5` | handed to V10 (CHANGELOG v0.5.0 Sync note) |
| `#69/c5859756889/apply-h4/6` | handed to V1 (the runner call in the tooling template and the checklist — R4) and V10 (CHANGELOG v0.5.0 Sync note) |
| `#69/c5901496433/sync-note` | handed to V10 (§ Syncing the kit and the v1.0.0 Sync notes) |
| `release/5` (handedIn) | V9.21 (the remainder and the kit-tree check); V9.1 and V9.6 for the executor pair and adr-new; owners V2, V4, V6, V7 in their files; V10's files by V10 |
| `critic/9` | handed to V10 (`CLAUDE.md` § Working in this repo: the R14 audit method) |
| `critic/11` | V9.1 |
| `review/consistency/3` | V9.10; `cbk-conventions.md:61` in V9.3 |
| `review/consistency/4` | V9.8 |
| `review/consistency/5` | V9.9 |
| `review/claude-code/11` | V9.8 |
| `review/portability/31` | V9.21 |
| `review/portability/32` | V9.21 |
| `review/portability/33` | V9.11 |
| `review/portability/34` | V9.7 |
| `review/portability/36` | V9.12 |
| `review/portability/37` | V9.13 |
| `review/consistency/39` | V9.14 (unverified; holds) |
| `review/consistency/41` | V9.15 (unverified; holds) |
| `review/consistency/42` | V9.16 (unverified; holds) |
| `review/consistency/43` | V9.17 (unverified; holds) |
| `review/consistency/46` | V9.15 (unverified; holds — the count and the one ambiguous citation; see § Not holding) |
| `review/consistency/47` | V9.5 (frame template, `inheritance.md`); handed to V3 (the reviewer's line 45 — its `review/claude-code/59`) |
| `review/consistency/48` | handed to V2 (unverified; holds) |
| `review/consistency/49` | V9.19 (the conventions and pr-review halves); handed to V5 (the orchestration and knowledge-backend halves) |
| `review/consistency/50` | V9.10 (unverified; holds) |
| `review/consistency/51` | V9.18 (unverified; holds); handed to V10 (`README.md:161`) |
| `review/claude-code/54` | V9.20 (identifiers; unverified, holds); its `#58` half in V9.1, V9.6, V9.21 |
| `review/claude-code/55` | V9.15 (unverified; holds) |
| `review/claude-code/56` | handed to V4 (unverified; holds) |
| `review/portability/67` | handed to V6 (unverified; holds) |
| `review/portability/68` | handed to V1 (unverified; holds) |
| `review/portability/38` (trace: V9; V5's pack) | V5 — `knowledge-backend.md` is V5's by the ownership map; verified facts in § Handed › V5 |
| `review/claude-code/57` (trace: V9; V5's pack) | V5 (the D59 split) |
| `review/portability/66` (trace: V9; V8's pack) | V8 (`.github/dependabot.yml.example`) |
| `#69/body/CAP` (V5's pack) | V9.2 — handed whole from V5: `finish.md` item 8, its bundled copy, the procedure pair's Step 10 and § Sub-issue rollup |
| `release/9` (V10's pack) | V9.1 (the executor procedure) and V9.4 (the other STANDARDS citations) |
| `release/10` (V10's pack) | V9.21 |
| `review/consistency/40` (V3's pack) | V9.1 (the executor pair) and V9.4 (`testing.md:255`, and `pr-review-reference.md:142` unless V7 landed it); V3.7 lands `simplification.md:3`, `:45` and the logging reviewer's cite; V10 lands `README.md:392` |
| `review/consistency/8` (V3's pack) | V9.1 (the `finish.md` citation) and V9.21 (the sibling name and the kit-tree checks) |

## Handed to other clusters

**V1**
- `review/portability/68`: the bootstrap checklist's rule-file disposition pass (`bootstrap_checklist_template.md:77` and its table) omits `cbk-conventions-reference.md`, whose `paths:` block carries `"<manifest-and-lockfile-globs — e.g. **/package.json, **/Cargo.toml, **/*.lock>"`; the project sub-block's placeholder check then goes red on a file the checklist never named. This is the spec's § Settled calls › Gate row ("Scaffold's disposition table gains a row for `cbk-conventions-reference.md`'s manifest and lockfile globs"). V5's `#65/body/1` edits the same line 77 sentence — one of the two restates the file count.
- `#69/c5859756889/apply-h4/6`: the tooling template's verification task is the one-line runner call (`bash .claude/workflows/tests/run-verification-block.sh`), a leg of `check`, never an inline extraction — V1's R4.

**V2**
- `#68/body/1a`, the hook half: `protect-main-branch.sh:79`'s remediation comments — V2.4's wording stands: `# cascade issue` becomes `# an issue this PR closes`, and `# operator-directed maintenance, no issue` becomes `# work no issue tracks`. V9 does not re-edit either line, and no V9 check reads the hook's comment wording. The block's `grep -q 'short-slug' .claude/hooks/protect-main-branch.sh` must stay green.
- `#66/body/2`, the hook half: move the ten-verb rationale (`upload` replaces a body; `spawn` and `send` drive a writing agent; `stop` ends one) into `require-knowledge-backend-ok.sh`'s header and correct its six-verb list to the matcher `settings.json` registers: `notion-(create|update|move|duplicate|convert|delete|upload|spawn|send|stop).*`.
- `#69/c5859756889/apply-h4/1`: one sentence in § Hook authoring's stdin/exit-contract bullet (the spec puts it beside the sourced-helper contract): a project's own hooks are held to the same contract — the hook fixture reads every `.claude/hooks/*.sh`, so the drain-first and early-reader checks bind a target's guards as they bind the kit's. No sister-project clause.
- `review/consistency/48` (holds): § Hook authoring's tally ("the three hooks authored with this section … the earlier five") counts eight of nine hooks; `guard-pr-state.sh`, `require-knowledge-backend-ok.sh` and `format-on-edit.sh` carry `Tier:` but no `Blocked:`/`Allowed:` (`command grep -c '^# \(Blocked\|Allowed\):'` prints 0 for each). State the tally by name, or drop it once every header carries the full shape (the master plan's global constraint puts `Tier:` and `Depends:` in every header).
- § Hook authoring's stdin/exit-contract bullet also carries the sibling parenthetical `(you-are-hear #81 → PR #82)`; V2 rewrites it to `(context-builder-kit#58 item 4)` in its own commit, so V9.21's Step 3 deletion is skipped when its anchor is absent (the step says so).

**V3**
- `#66/body/2`, the registry half: `settings.json`'s `_comment_hooks` (4,103 characters) trimmed to the registry plus pointers — every hook basename and the words `HARD-DENY`, `ASK-GATE`, `ADVISORY`, `STOP` kept, since the block reads them; still valid JSON.
- `review/consistency/47`, line 45 of `agents/cascade-rule-reviewer.md` (the same line as V3's `review/claude-code/59`): cite `knowledge-backend.md` § The code-adjacent split — canonical (its "Never" list), which resolves before and after V5's split. V9.5 edits only line 42 of that file.
- `review/consistency/40`: the executor pair lands in V9.1 and `testing.md:255` in V9.4, as V3's plan hands them; V9.4 skips `simplification.md:45` when V3.7 has rewritten it. `review/consistency/8`'s `finish.md` citation lands in V9.1. V3's frontmatter and argument edits to the same files are untouched by V9's anchors (none contains `$1`).

**V4**
- `review/claude-code/56` (holds): the CI skeleton in blueprint's `templates/tooling.md` has `- uses: actions/checkout@v4` and `<language-setup-action@version>`, against `cbk-conventions-reference.md` § Dependency settle-window's full-SHA pin; use `claude-review.yml`'s placeholder form, `@[full-commit-sha] # v[version]`, in the same edit as V4's `#70` shell and runner-image changes.
- `claude-review.yml`'s two bare citations (lines 117 and 185 at `643f7ff`) become `context-builder-kit#58 addendum, item 12` and `… item 11` in V4's commit; V9.21 sweeps them if they remain.

**V5**
- `#66/c5901495490`: `knowledge-backend.md` § Hook enforcement layer becomes a pointer to `cbk-conventions-reference.md` § HITL gate load-bearing heuristics › Mechanize the gates, keeping the hook's name, its dated Notion matcher and the unmatched reads (−56 bytes, measured by the issue).
- `review/consistency/49`, the orchestration and knowledge-backend halves: each preamble claims "keeps a pointer heading for every section here", but `orchestration-reference.md`'s § Generation notes — the sources and § Cost terms and run hygiene have no pointer heading in `orchestration.md`. Use V9.19's sentence shape so V9.19 can add the half to its loop: "`orchestration.md` (always loaded) keeps a pointer heading for every section moved here at the split; a section added here since (§ Generation notes — the sources, § Cost terms and run hygiene) is cited by this file's own name." Do the same for `knowledge-backend-reference.md` if its preamble makes the claim.
- `review/portability/38` (in V5's pack; the trace row says V9): read raw on 2026-09-30 — `https://www.notion.com/help/wikis-and-verified-pages` says `This feature is available on Business and Enterprise Plans.`; `https://www.notion.com/releases/2026-02-24` dates Notion 3.3's Custom Agents. The § Wiki pattern's Verification requirement is plan-gated; name the prerequisite and give the Free/Plus fallback (an Owner person property plus a "Verify by" date property on the same 90/180/365-day cadence), and cite and date the 3.3 section.
- `#69/body/CAP`: V5's plan hands the whole row to V9; V9.2 lands it, § Sub-issue rollup included.

**V6**
- `review/portability/67` (holds): the block's price diff lowercases with GNU-only `\L` in `sed` — `echo 'Opus 5 $5/$25' | busybox sed -E 's/^([A-Z][a-z]+) [0-9.]+ \$([0-9]+)\/\$([0-9]+)/\L\1 \2 \3/'` prints `LOpus 5 25` (GNU prints `opus 5 25`). When V6 re-keys the diff by version, lowercase portably (`tr '[:upper:]' '[:lower:]'` or `awk '{print tolower($0)}'`).
- The bare citations in `agent-cost.py`, `finish-ab.js` and `finish-ab-shape.mjs` become `context-builder-kit#58 …` in V6's commits; V9.21 sweeps any left.

**V7**
- The bare citations in `review-sweep.js` (three) and `review-sweep-accounting.mjs` (one) become `context-builder-kit#58 …` in V7's commits; V9.21 sweeps any left.
- `pr-review-reference.md:142` ("`docs/STANDARDS.md` § PR review process points here"), which V3's plan hands to V7: V9.4 lands it as § PR Review Checklist unless V7 already has, so V7 need not.

**V10**
- `#69/c5859756889/apply-h4/2`, `/3`, `/5`, `/6` and `#69/c5901496433/sync-note`: § Syncing the kit's notes and the CHANGELOG's Sync notes, as the spec's V10 section lists them.
- `#58/c5901493591/R14` and `critic/9`: the audit method in this repository's `CLAUDE.md` § Working in this repo.
- `review/consistency/51`: `README.md:161` says six foundation docs; V9.18's wording is "six prose foundation docs — seven on the `github-issues` and `in-repo-markdown` axes, where `docs/cbk/ROADMAP.md` joins them".
- Sync notes V9 creates, for the v1.0.0 section: (a) a target's `.github/ISSUE_TEMPLATE/cascade-meta.md` and `cascade-rough-in.md` are byte copies of scaffold's `references/issue-templates/` and are re-copied — V9.5's project-sub-block check fires until `cascade-meta.md` is; (b) a target citation of "adr-new § Refines vs Supersedes" repoints at `adr-new` § Relation grains or `cbk-conventions-reference.md` § ADR relation grains; (c) the bare-citation rewrite touches about thirteen kit files a target copies byte-for-byte — take the kit's side; (d) the D54 branch rule; (e) the CI-skip section's wording.
- § Syncing the kit's paragraph carries one citation V9.21 rewrites token-for-token: anchor on `(context-builder-kit#58, second application, item 10)`. `README.md`, `CHANGELOG.md` and `CLAUDE.md` are outside V9.21's scope; V10 checks its own files for bare citations and sibling names (master Task F1 Step 3).

## Not holding at planning time

Every unverified finding in V9's pack was re-checked on 2026-09-30 against `643f7ff` and holds; each is re-checked again when its task runs (D56). The parts below did not hold, or are not taken, and land nowhere:

- `review/portability/31` and `review/portability/32`, the stated harm: GitHub does not autolink `#N` in repository files — `curl -sL 'https://docs.github.com/api/article/body?pathname=/en/get-started/writing-on-github/working-with-advanced-formatting/autolinked-references-and-urls'` contains `> Autolinked references are not created in wikis or files in a repository.` The fixes still land (V9.21): a bare number resolves to the wrong issue when an agent follows it.
- `review/portability/36`, one claim: a body that merely quotes `skip-checks: true` is not skipped — the trailer counts only as the message's last trailer after two empty lines. V9.12 describes it as positional, not as a substring hazard.
- `review/consistency/5`, one claim: the `[<ISSUE-KEY> AC2]` test tag in § Trace ID convention's "Two-level anchor" paragraph is the project's fill slot, not a third conflicting form; it and `testing.md`'s restatement stay as written.
- `review/consistency/42`, one claim: framing's `test_cases.md:20` ("3-5 milestones" for one worked example) sits inside the contract's 3–6 range; it stays.
- `review/consistency/46`, the second suggestion: renaming backend selection's "Stage 0–3" so "Stage N" has one meaning is a naming preference across `backend_selection.md` and the test cases; not taken. The one ambiguous citation gains a qualifier in V9.15.
- `review/consistency/3`, one suggestion: renaming `scaffold/references/github_only_profile.md` is not taken — the block and SKILL.md cite the file by name, and its title "GitHub-only profile" is not the retired lowercase phrase V9.10's check refuses.
