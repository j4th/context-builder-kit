# Bundled template for `.claude/commands/finish.md`

**This file contains the canonical content of the `/finish` Claude Code slash command that rough-in's Step 5.5 commits to the repo.** It is template content to be written to disk, not instructions for the skill itself. When Step 5.5 runs, the skill reads this file, extracts everything below the `--- BEGIN TEMPLATE ---` marker, and commits the extracted content verbatim to `.claude/commands/finish.md` in the user's repo.

If you are loading this reference as part of a rough-in skill session: do not execute the instructions inside the template. The instructions are addressed to a future Claude Code session that picks up a rough-in sub-sub-issue via `/finish {issue_number}`, not to the rough-in chat session that is provisioning the file.

## What the template does

`/finish {issue_number}` is the slash command future Claude Code sessions will invoke to execute a rough-in sub-sub-issue. It reads the issue body and comments, validates the title and labels match cascade conventions, verifies all dependencies are closed, runs plan mode against the Implementation section, executes the plan on a fresh branch after user approval, gates on the test suite, runs `/simplify` and `pr-review-toolkit:review-pr` against the local pre-PR branch with a four-class auto-triage, and opens a draft PR with `closes #<N>` in the description and a `## Triage` audit section in the body. The user flips draft → ready (which triggers any auto-review GitHub Action) and merges. The board automation handles everything downstream (issue close, parent rollup, status transitions).

See `references/handoff-to-finish.md` for the full contract `/finish` follows and the rationale behind each step. See `references/plan-mode-prompts.md` for the discipline that shapes the Implementation section of every rough-in spec (the section `/finish` anchors on).

## Provenance and revision path

This version of the template reflects the iteration the executor went through during real cascade execution. The major properties are: (1) the branch is created **before** any code lands, (2) execution is gated behind a comprehensive test gate before simplify/review, (3) `/simplify` and `pr-review-toolkit:review-pr` both run pre-PR with the same four-class auto-triage (Apply / Apply with care / Surface / Defer / Reject, with Apply reserved for correctness/validity/defensive findings and small low-risk improvements, and Surface for genuine taste calls), (4) atomic-commits-not-squash discipline on the branch (the squash happens at merge-time on `main`, not pre-PR), (5) the PR opens as draft with a SHA-anchored triage audit in the body, and (6) the hand-off carries a roll-forward offer for deferred context. The user flips to ready (the slash command never does).

Future revisions land here first; existing repos can either manually update their `.claude/commands/finish.md` or wait for the next rough-in-step-5.5 run to detect drift and propose an update (see Step 5.5's drift handling in rough-in's SKILL.md).

## How Step 5.5 consumes this file

During rough-in's Step 5.5 (Provision `/finish` slash command if missing):

1. Rough-in queries whether `.claude/commands/finish.md` exists in the user's repo via `get_file_contents`
2. **Case A — file exists, byte-identical to bundled template**: silent no-op. Log "already provisioned, matches current bundle" in the inheritance summary. No HITL gate fires; nothing is landing, nothing to approve.
3. **Case B — file exists, differs from bundled template**: drift detected. Present the **diff** (not the full file), surface the three-option gate: (a) leave the repo's existing version in place (user has customized it or a prior revision is running), (b) overwrite with the current bundled template, (c) abort and handle manually. Diff presentation shows only the changed lines with a few lines of context on each side — do not dump both full files.
4. **Case C — file does not exist (cold start)**: read the template below the `--- BEGIN TEMPLATE ---` marker, fire the HITL gate with the **structured summary presentation pattern** below, commit to `.claude/commands/finish.md` on approval.

### Extracting the template body for comparison or commit

The template body is everything after the `--- BEGIN TEMPLATE ---` marker line. Extract it via:

```bash
awk '/^--- BEGIN TEMPLATE ---/{flag=1; next} flag' .claude/skills/rough-in/references/finish-command.md > /tmp/bundled-finish.md
```

Then compare against the repo's `.claude/commands/finish.md` with `diff` (Case B detection) or copy verbatim into the commit (Cases B-overwrite / C). Do not re-derive this extraction by hand on every run — the marker-line discipline is the contract; the awk snippet is the operational form.

### Structured summary presentation pattern (Case C, cold start)

Do **not** dump the full template inline at the HITL gate by default. The one-way-door discipline requires the user to have the opportunity to inspect what's landing and to explicitly approve — it does not require a wall-of-text presentation. The default presentation is a structured summary; the full content is available on demand.

**Present**:
- **What this is**: one sentence naming the file path and its role (*"`.claude/commands/finish.md` — the Claude Code slash command that `/finish <N>` invokes to pick up a rough-in sub-sub-issue, verify dependencies, run plan mode, execute on a fresh branch, gate on tests, simplify, run review-toolkit with auto-triage, and open a draft PR"*)
- **Provenance**: one sentence on where the template came from (*"current revision of the executor — branch-first, test-gated, runs `/simplify` and `pr-review-toolkit:review-pr` pre-PR with a four-class auto-triage, opens draft, hands off to user for ready-flip"*)
- **Structure**: a numbered list of the template's steps with one-line descriptions each (*"Step 1: Read the issue (+ comments, break-glass check) / Step 2: Parse sections / Step 3: Verify dependencies / Step 4: Idempotency / Step 5: Plan mode / Step 6: Create branch + execute / Step 7: Test gate / Step 8: Simplify + triage / Step 9: Review + triage / Step 10: Push + draft PR / Step 11: Hand off"* — roughly a dozen lines total)
- **Scope boundary**: one sentence on what `/finish` does NOT do (*"does not write specs, modify issue bodies, auto-create dependent issues, bypass dependencies, mark the PR ready, or merge"*)
- **Approval prompt**: *"Commit this template to `.claude/commands/finish.md`? You can review the full content first — reply 'show full' — or approve as-is with 'yes' / 'ok' / 'approved'."*

The user can still demand full inspection (`show full`, `let me see it`, etc.), in which case the full template dumps inline — that path preserves the one-way-door guarantee. The default path is sight-unseen acceptance based on the structured summary, which is the common case.

**Rationale**: first runs in a repo have zero drift (the template is new), so Case C is fundamentally "confirm you want the bundled default." The summary needs to be informative enough that sight-unseen acceptance is reasonable, but not so long that it defeats the purpose. A dozen or so structural lines plus the approval prompt hits that balance — long enough to justify trust, short enough to scan.

The one-way-door property is preserved in all three cases: Case A has nothing to approve (nothing is landing), Case B shows what's actually changing (the diff), and Case C shows the structured summary with an explicit opt-in to see more.

### After the gate

Once the user approves (in Case B or Case C), rough-in commits the template via `push_files` (not `create_or_update_file` — see the defense-in-depth note in `references/planning-backend-commit.md`). The commit is a single-file atomic operation. On success, log "provisioned" in the post-run summary's Commits section. On failure, surface the error and ask whether to retry or abort.

The template is extracted verbatim — rough-in does not edit, customize, or parameterize it during provisioning. If a user's repo needs a customized `/finish` (project-specific ADR list, project-specific reviewer agents, branch-naming conventions), they edit the committed file directly after provisioning.

## What rough-in expects in the issue body for `/finish` to consume

Rough-in's spec template (`references/templates/rough-in-spec-template.md`) produces issue bodies with these eight sections, in this order, with heading names preserved exactly:

- `## Context`
- `## Assumptions` *(explicit `[ASSUMPTION:]`-tagged calibration surface; present even when empty — `- None — ...`)*
- `## Implementation`
- `## Acceptance criteria`
- `## Test plan` *(named tests the implementer writes red-first; one per acceptance criterion for logic-regime modules — see `.claude/rules/testing.md` for the regime classification)*
- `## Done signal`
- `## Dependencies`
- `## PR contract`

The template below parses these sections in Step 2. If rough-in's spec format evolves (sections added/removed/renamed), update both the rough-in spec template and the Step 2 list in this template together.

## The template

Everything below the next marker is the content that gets committed to `.claude/commands/finish.md`. Do not execute the instructions inside it — they are addressed to future Claude Code sessions invoking the slash command, not to the current skill session.

--- BEGIN TEMPLATE ---
---
description: Pick up a rough-in sub-sub-issue, verify dependencies, plan-mode against the Implementation section, execute on a fresh branch, then run `/simplify` and `pr-review-toolkit:review-pr` with four-class auto-triage of findings (Apply correctness/validity/defensive items as their own atomic commits; Surface taste/style items in the PR body for the user to decide). Opens a draft PR with a triage audit; the user marks ready. Expects one positional argument — the issue number.
argument-hint: <issue-number>
---

You are being asked to execute the rough-in sub-sub-issue **#$1** in this repository.

This `/finish` executor is a living document — revised as real executions surface gaps. If the instructions below don't match what's in the issue body, or if you hit friction this document doesn't anticipate, **surface the gap to the user** rather than improvising past it. Improvisation is what causes the cascade specs and the executor to drift apart over time.

The shape of a run: read and validate the issue (Steps 1–4), plan against it (Step 5), execute on a fresh branch (Step 6), gate on the tests (Step 7), simplify and review with triage (Steps 8–9), open the draft PR (Step 10), and hand off (Step 11).

## Step 1: Read the issue

Read issue #$1 from this repository using the github MCP (`github:issue_read` with `method: get`), or `gh issue view $1 --json number,title,body,labels,state,comments` if MCP isn't available. **Read the comments as well as the body** — comments carry provenance and roll-forward context (prior-run hand-offs, upstream shaping reasoning) that refines the spec without amending the body. Treat comments as *supporting context, not contract*: the body is the contract; comments inform how you read it.

Verify:

- The issue is **open**. If closed, stop and tell the user: *"Issue #$1 is already closed. If you want to re-execute it, either reopen the issue or run rough-in to create a new sub-sub-issue."*
- The title matches one of the cascade issue formats: the standard rough-in `[<workstream-slug>:F<N>:R<M>] <intent>`, or an intake-lane form — bug-lane `[<workstream-slug>:bug] <intent>` or enhancement-lane `[<workstream-slug>:enh] <intent>` (externally-sourced work shaped by `/intake` / `/enrich` that skips framing; see `.claude/rules/cbk-conventions.md` § Contribution intake). In every case `<workstream-slug>` is one of the workstream slugs locked in this project's blueprint (`docs/cbk/blueprint.md` § Workstreams). If the title matches none of these, stop and ask whether this is actually a cascade issue or a different kind that got routed here by mistake.
- The labels include `cascade-depth:roughed-in`. If not, same question — confirm with the user before proceeding.

**Break-glass check.** Note whether the issue body or the operator's instructions carry a `<!-- skip-review-toolkit -->` marker (or an equivalent agreed marker). If present, the review pass (Step 9) is skipped per `pr-review.md` § Break-glass, and the hand-off records the reason. The marker is read *here*, from a surface that exists at gate time — not from the PR body, which doesn't exist until Step 10.

## Step 2: Parse the body section structure

The issue body should have these eight sections, in this order, with heading names preserved exactly:

- `## Context` — orientation for where this issue sits in the cascade
- `## Assumptions` — explicit calibration surface for ambiguity the rough-in author filled in (per Addy Osmani's "good spec for AI agents" pattern); each gap tagged `[ASSUMPTION:]` so plan mode can enumerate them. Valid contents include `- None — all parameters explicit from the framing intent and acceptance criteria.` when no assumptions were made; the section must be present even when empty.
- `## Implementation` — the load-bearing section you will use as the primary plan-mode anchor
- `## Acceptance criteria` — observable, verifiable outcomes the work must satisfy
- `## Test plan` — named tests the implementer writes red-first; one per acceptance criterion for logic-regime modules (see `.claude/rules/testing.md` for regime classification)
- `## Done signal` — the single command or observation that means the work is complete
- `## Dependencies` — prior sub-sub-issues that must be closed before this one can start
- `## PR contract` — how to close the issue when implementation is complete

If any section is missing or renamed, surface the mismatch to the user and ask whether to (a) proceed with the partial spec, (b) abort and return to chat so rough-in can fix the issue body, or (c) manually patch the body before proceeding. Do not silently work around a missing section.

## Step 3: Verify dependencies

Read the `## Dependencies` section. For each issue number listed:

- Query the issue state (`github:issue_read` with `method: get`, or `gh issue view <N>`)
- Confirm the issue is **closed** with `state_reason: completed`

If any dependency is open, or closed with a reason other than `completed`, **stop and refuse to proceed**. Tell the user: *"Issue #$1 depends on [list of unmet dependencies with their current states]. I can't proceed until those are resolved. Once they are, re-run `/finish $1` and I'll try again."*

Do not offer to "proceed anyway" or "skip the dependency check." If the user wants to bypass a dependency, they need to update the issue body in a deliberate rough-in revision, not via `/finish` runtime patching.

If the Dependencies section says "None" or is empty, the check passes immediately.

## Step 4: Idempotency check

Before starting work, check for existing state that suggests this issue is already in progress or done:

- Is there already an open PR with `closes #$1` in its description? If yes, stop and tell the user: *"PR #[pr-number] is already open against issue #$1. Do you want me to continue working on that PR, or is this a new attempt after the prior PR was closed?"* Wait for explicit direction.
- Is there a branch matching this repo's branch naming convention (`<type>/<short-description>`, see `CONTRIBUTING.md` § Branches) that looks like it was created for this issue? If yes, surface it and ask whether to continue on that branch or start fresh.

This isn't comprehensive — Claude Code can't detect every in-progress state. But the common cases (open PR, existing branch) are cheap to check and save the user from duplicate work.

## Step 5: Hand the body to plan mode

Construct a plan-mode prompt using the issue body. The primary anchor is the `## Implementation` section. The other sections are supporting context:

- `## Context` tells plan mode why this issue exists and where it sits in the cascade
- `## Assumptions` lists `[ASSUMPTION:]`-tagged calibration points the rough-in author surfaced. Plan mode **must enumerate each tagged item** in the plan output as a "Confirm or correct" line so the user can revise during plan iteration. **Do not silently resolve assumptions at plan time** — even when plan mode has a strong default, surface it so the user can push back. Resolved assumptions (those the user confirms or corrects) inline into the plan's relevant Implementation step rather than persisting as a separate "Resolved" subsection. If the section says `- None — ...` or contains no `[ASSUMPTION:]` lines, proceed silently.
- `## Acceptance criteria` become the contract the plan must satisfy
- `## Test plan` names the tests the plan must scaffold red-first (Step 6) before implementing — these are the executable form of the acceptance criteria
- `## Done signal` is the verification command the plan must produce as its final step
- `## Dependencies` are already verified, but useful context for plan mode if it wants to reference prior work
- `## PR contract` tells plan mode how to finish (open draft PR with `closes #$1`, Conventional Commits title)
- **Issue comments** (read in Step 1) are supporting context, not contract — provenance, prior-run hand-offs, and roll-forward notes that can sharpen the plan. Fold what's relevant into the plan; the body still governs.

In addition, the plan must respect:

- **`docs/adr/` Decisions Log**, indexed in `docs/ARCHITECTURE.md` § Decisions log. Any code introduced must conform to the relevant ADRs. If the spec asks for something that conflicts with an ADR, surface that conflict before executing.
- **`docs/STANDARDS.md` quality bar** — testing philosophy, coverage policy, AI-collaborator workflow.
- **`.claude/rules/testing.md`** — three regimes (test-first, conformance-first, tests-as-shape-of-done). The `## Test plan` named tests are the input to Step 6's red-first scaffolding for logic-regime modules.
- **`.claude/rules/logging.md`** — structured `Logger` calls, correlation ID propagation, telemetry vs Logger boundary.
- Any other `.claude/rules/<topic>.md` files load-bearing for the diff at hand.

**Run plan mode explicitly** — do not start writing code in this turn. Produce a plan, present it to the user, wait for explicit approval before executing. Non-negotiable even for small-looking issues, because the user's review is the last HITL gate before code lands.

**Scale the research to the work.** When the investigation spans many files, multiple subsystems, or competing hypotheses, fan out `Explore` / general-purpose subagents (one per area) and synthesize their findings yourself — gather with subagents, never delegate the synthesis. When a workflow/orchestration tool is available, orchestrate the research: parallel readers over the relevant subsystems, an adversarial verifier for any load-bearing assumption, then synthesize. Match the effort to the issue — a single-file change needs none of this; a cross-layer or multi-subsystem issue is where the fan-out earns its cost. This is plan-mode *research*, not a license to start writing code — the explicit plan-mode gate still holds.

You are allowed to fetch additional context during plan mode if the spec genuinely needs it — read cited docs (`docs/ARCHITECTURE.md`, individual ADR files in `docs/adr/`, `docs/STANDARDS.md`, `CLAUDE.md`, `docs/cbk/frame-NN.md` for the parent framing), look at sibling files in the affected module, query the parent framing sub-issue for background. But don't fetch context speculatively; only fetch what the current step actually needs.

**Resolving Notion URLs cited in the spec**: if the issue body (Context, Implementation, or any section) cites Notion page URLs as reference material, you may resolve those URLs via the Notion MCP if it's configured. Per `.claude/rules/knowledge-backend.md` § "HITL announcement discipline," announce each fetch before running: *"About to fetch `<page title>` from Notion. OK?"* Operator can decline per-page. If Notion MCP is not configured, surface and proceed without the Notion content (the URLs remain in the issue body as informational references).

## Step 6: Create the branch, then execute the plan

**The branch must exist before any code lands.** Create it first; everything from here runs on the branch, so nothing is ever committed to the base branch by accident.

1. **Create the branch** following this repo's naming from `CONTRIBUTING.md` § Branches: `<type>/<short-description>`, with the planning-backend ID embedded if applicable (e.g., `chore/abc-14-umbrella-init`). Type is one of: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `perf`, `style`, `build`, `ci`. **Do not push and do not open the PR yet.**
2. **Scaffold the named tests from `## Test plan` as failing tests first.** ExUnit `flunk("not implemented")` or pytest `pytest.fail("not implemented")` is fine — what matters is that the named tests exist and fail red before any implementation lands. Run the test runner once to confirm red. **If the runner reports "no tests ran" or passes silently when you expected red, stop and surface** — it isn't discovering the new tests (the path, naming convention, or test config is wrong). Don't implement over an unverified red gate.
3. **Implement to green, one test at a time.** Resist implementing past the next failing test — that's how TDD's documenting-the-design value gets lost.
4. **Refactor while green.**
5. **Commit the implementation** with a Conventional Commits message.

For conformance-first or tests-as-shape-of-done regimes, the order is different — see `.claude/rules/testing.md` for the workflow per regime. The `## Test plan` section is still the source of truth for what tests must exist; only the *order* relative to implementation differs.

**Atomic commits, not squash.** Each meaningful unit of work — initial implementation, each test-gate fix, the simplify pass, each Apply-class fix from a reviewer — gets its own focused commit on the branch with a Conventional Commits message. The squash happens **at merge-time on `main`** (`docs/STANDARDS.md` § Commit and branch conventions: "Squash-merge via PR — clean linear history on `main`"), not pre-PR. Per-branch atomic history is what the user reads to understand the diff, what the PR feedback loop needs for comment-to-commit linking, and what the auto-review action references in its inline comments. Do not `git commit --amend` past a commit you've already based later work on; do not pre-squash on the branch.

During execution, if you discover the spec is wrong in a way you can't work around (acceptance criterion is unverifiable, technical detail conflicts with code that already exists, architecture doc you're citing has drifted from the spec), **stop and surface the gap**. Do not patch the spec mid-execution. The right move is to abort `/finish`, return to chat, and run rough-in for a re-rough-in event that produces a corrected spec.

## Step 7: Comprehensive test gate

The project's `check` task (compile + lint + typecheck + test — whatever the project defines, e.g. `make check`, `just check`, `npm run check`) must pass **green** before simplify and review run. Categorize any red:

1. **Compile / lint / type errors** — fix them on the branch as atomic commits; don't proceed with a red branch.
2. **Failures from the `## Test plan` tests** — the implementation isn't complete. Return to the red-first cycle (Step 6.3).
3. **Failures from *unrelated* tests** — surface to the user. Either (a) the implementation broke a shared module the spec didn't anticipate, or (b) it's a pre-existing failure the spec assumed green. **Don't `skip`/`xfail`/comment out a test to make the suite pass — ask.** Muting a red test converts a real signal into a silent failure.

Green is the only acceptable state to enter the next step.

## Step 8: Simplify and triage

The principle for Steps 8–9: **the executor handles findings the codebase needs to be correct; the human handles findings about taste.** Correctness, validity, and defensive hardening auto-apply because there's a right answer. Style, clarity refactors, and naming preferences surface for the user because there isn't.

1. **Run `/simplify`** in your Claude Code session. Project-mandatory per `docs/STANDARDS.md` § Step 4 and `.claude/rules/simplification.md`. Review the simplify diff before continuing.
2. **Triage the simplify findings with the same four-class rubric as review** (Apply / Apply with care / Surface / Reject — see Step 9 and `.claude/rules/pr-review.md`). Behavior-preserving simplifications with a clear improvement are **Apply**, each as its own focused commit that names the finding. Larger-than-~15-LOC or cross-file restructures are **Apply with care** (own commit + flag in the hand-off). Taste calls are **Surface** (don't apply; note in the PR body). Anything that would change behavior, remove a defensive guard, or violate a rule is **Reject** (one-line dismissal).
3. **Re-run the `check` task after each Apply.** If it fails, revert the offending commit (`git reset --hard HEAD~1` while still local-only) and reclassify the finding as **Apply with care** or **Reject** — never enter Step 9 over a red branch.

## Step 9: Review and triage

1. **Run `pr-review-toolkit:review-pr`** against the local branch. The skill auto-discovers the diff via `git diff` + `gh pr view`; pre-PR, it falls back to `git diff main...HEAD`. Invoke with no args for the default full sweep. Do **not** pass the PR number as an argument — that's not the skill's interface.

   If `pr-review-toolkit:review-pr` is not installed or fails to invoke, stop and surface — do not silently skip. Tell the user: "install the `pr-review-toolkit` Claude plugin, or explicitly waive this run." The "does not skip" rule (below) means a missing toolkit blocks `/finish`.

   **Break-glass**: if a `<!-- skip-review-toolkit -->` marker was found in Step 1, skip this review pass. Record "Review-toolkit explicitly skipped per <reason>" in the hand-off. Don't silently skip; the audit trail lives in the PR body.

2. **Dispatch project-local reviewers in parallel** with the toolkit's generic agents when the diff touches code under their topics. Common project-local reviewers: an ADR-conformance reviewer (intersects ADRs against the diff), a logging-discipline reviewer (validates `.claude/rules/logging.md` conformance), and a cascade-rule reviewer (checks the diff against the project's other `.claude/rules/*.md`). If your repo hasn't authored these, the toolkit's generic agents alone are sufficient.

3. **Triage and auto-action findings per `.claude/rules/pr-review.md`.** That file is the canonical source for the four-class rubric (Apply / Apply with care / Surface / Defer / Reject), the Apply/Surface calibration per category (docs, defensive additions, naming, test additions, style), the "What NOT to flag" exclusion list, the path-conditional aggressiveness, and the anti-patterns. Read it now if it's not already in context.

   **Quick summary of the rubric for orientation** (the rules file is authoritative when in doubt):

   - **Apply** — behavior-preserving fix with concrete evidence of need (defects with reproducible failing path, factually wrong comments / rot, dead code / unused imports, existing-doc clarity improvements, defensive additions with concrete evidence, local-symbol renames when fact-based, missing docstrings on entirely-undocumented surfaces) **OR low-risk small changes** (≤ ~15 LOC, confined, no design call required, plausibly an improvement — typo fixes, redundant assertion drops, inlining one-shot helpers, extracting constants the agent already named, simplifying obvious-once-named expressions). One focused commit per finding with a Conventional Commits message that names it.
   - **Apply with care** — execute as its own commit but flag in the hand-off summary: cross-file refactors >~50 LOC, new module outside named files, materially altering changes, non-obvious correctness fixes.
   - **Surface** — do not apply, note with the agent's rationale verbatim. **Genuine design or taste calls only**: structural refactors that change surface area, speculative defensive guards (no concrete failing scenario), doc *expansions* of existing-but-thin sections, rule-of-three not hit on suggested abstractions, alternative approaches the agent prefers but the existing one is also fine. **NOT Surface**: small low-risk improvements (those go to Apply); style nits without strong rationale (those go to Reject with a one-line dismissal — surfacing them inflates the user's review surface).
   - **Defer** — conflicts with an ADR or out-of-scope.
   - **Reject** — agent factually misunderstood, OR style nit suggested without strong rationale (one-line dismissal is enough).

   **When uncertain about a small low-risk change, Apply. When uncertain about a design or taste call, Surface.** Atomic-commit history makes any wrong Apply call cheap to revert during draft review, and the user-side cost of triaging Surface items routinely exceeds applying-and-showing the diff. Reserve Surface for genuine taste calls and design decisions where reasonable people disagree. **Medium-confidence findings follow the same triage as high-confidence findings** — confidence is about whether the finding is real, not whether to apply it. **Don't bias away from being defensive**: defensive hardening (race guards, missing cleanups, future-edit foot-guns) is a correctness concern even when the test passes today — those go in Apply, not Surface.

   **Pre-filter generated files, lock files, vendored deps, and build artifacts** before the agents read them — see `pr-review.md` § Pre-filters.

   **One commit per logical fix.** Each Apply finding gets its own focused commit on the branch (`docs/STANDARDS.md` § Commit and branch conventions; the squash happens at merge-time on `main`, not pre-PR). Use `git commit --amend` only to clean up your own most recent commit before pushing if it had a typo or you forgot to stage a hunk; do not amend across logical boundaries.

   **Re-run the `check` task after each fix** (or at minimum after the last one in a batch). If it fails, revert the offending fix's commit (`git reset --hard HEAD~1` while still local-only) and reclassify the finding as **Apply with care** (re-attempt with more care) or **Defer** (with explanation) — do not push a branch with failing checks.

   If multiple agents disagree (one says X, another says not-X), pick the option that aligns with project rules (`.claude/rules/`, ADRs, `docs/STANDARDS.md`) and note the disagreement in the hand-off summary so the user can sanity-check.

## Step 10: Push and open the draft PR

1. **Push the branch** with `git push -u origin <branch>`. If the push fails (auth, network, branch protection), stop and surface the failure per § Partial failure handling. Local commits without a remote ref means `gh pr create` will fail too — fix the push first.
2. **Open the PR as a draft** via `gh pr create --draft`. PR title in Conventional Commits format (`<type>(<scope>)?: <subject>`). PR description includes:
   - `Closes #$1` for GitHub issues, or `Closes <KEY>-N` for planning-backend-tracked issues with a GitHub integration that recognizes the magic word. Put the close marker in the **PR body**, not just the title — body is the durable surface; titles can be edited at squash-merge time.
   - Citations to relevant ADRs, `frame-NN.md` milestones, or `.claude/rules/<topic>.md` files the implementation references.
   - A short summary of what changed and why.
   - A `## Triage` block listing every finding under its class. This is the audit surface — non-actioned findings live here, not lost:
     - **Apply (N)** / **Apply with care (N)** — one line per finding: `SHA <abbrev>: <one-line fix>` (for Apply with care, add the reason it needs scrutiny), so each actioned finding is traceable to its commit.
     - **Surface (N)** — one line per finding: `<file:line> — <the agent's verbatim rationale>`. Surface entries **must** carry the verbatim rationale so the user can decide during draft review without re-running the toolkit.
     - **Defer (N)** — `<verbatim rationale> — conflicts with <ADR / scope / framing>`.
     - **Reject (N)** — one-line dismissal.

   If `gh pr create --draft` fails (auth, missing scope, draft PRs disabled, rate limit, PR already exists for this branch), stop and surface the failure with per-step status.

## Step 11: Hand off

End your turn with a structured hand-off:

- The **PR URL**.
- A one-line **triage count**: `Apply: N · Apply with care: N · Surface: N · Defer: N · Reject: N`.
- The **verbatim Surface entries** repeated in chat, and the **verbatim Defer entries**, so the user can act without opening the PR body.
- A one-line **next action**, and a note that the PR is draft awaiting the user's review-and-flip-to-ready.

If any finding was classified **Defer** because it would conflict with an ADR or with the issue's design, lead the hand-off with that count and an explicit "Recommend addressing before flipping to ready, or accepting the deferral explicitly" line — the user still owns the call, but the framing must not flatten the conflict.

**Roll-forward offer** (HITL). If the run surfaced deferred context that a *later* unit of work will need — TODOs, contract facts the next issue depends on, intentional omissions, or a follow-up worth its own issue — **offer** to post a roll-forward comment **wherever it's relevant**: the next issue, a sibling, a downstream milestone issue, a meta-issue, or a brand-new follow-up. Do **not** hardwire it to "the next issue." Default to posting **post-merge** unless the deferred context blocks another issue's start. If nothing was deferred, skip this silently.

**Optional learning-runbook write to Notion** (only when knowledge backend = `notion` is configured for this repo, per `.cascade/backends.toml`): if this execution surfaced a learning that would be a useful durable cross-project runbook entry (e.g., a non-obvious gotcha with the stack, a recipe for a recurring task spanning repos, a corrected understanding of an external system's behavior), prompt the operator: *"Want to promote this learning to a Notion runbook page under the Engineering Wiki? Defaults to SKIP."* Defaults to **SKIP**. Per `.claude/rules/knowledge-backend.md` § "When to write" — this is the rare opt-in path; HITL-gated; never default. If the operator opts in, announce the planned write (title, parent, body preview) before committing. This step is gated to genuinely cross-project learnings only — local-to-the-PR observations stay in the PR body and the hand-off summary, not in Notion.

Do not call `gh pr ready` and do not merge — those remain the user's calls. The user's draft-review pass is where Surface findings get decided; they can ask you to apply any of them in the PR-feedback-loop turn, or wave them through.

## What `/finish` does NOT do

- **Does not modify the issue body.** If the spec is wrong, the user has to update it deliberately, not via runtime patching.
- **Does not handle re-rough-in.** Surface the need and return to chat for the rough-in skill.
- **Does not auto-create dependent issues.** If the work reveals a missing sub-sub-issue, surface and return to chat for rough-in.
- **Does not bypass dependencies.** Refuse to proceed when dependencies are unmet.
- **Does not modify cascade artifacts** (`docs/cbk/blueprint.md`, `docs/cbk/frame-NN.md`, etc.). Those are produced by chat-skill cascade phases.
- **Does not modify ADRs.** ADRs are immutable once accepted; revisions happen via new ADRs that supersede the old (chat-skill territory, not `/finish`).
- **Does not make workstream-level or framing-level decisions.** Those belong to upstream cascade phases (blueprint, framing, rough-in).
- **Does not skip `/simplify` or `pr-review-toolkit:review-pr`.** The simplify and review passes both run before the PR opens; the simplify pass is non-negotiable per `docs/STANDARDS.md` § Step 4, and the review-toolkit findings are auto-triaged with the four-class rubric (Apply for correctness/validity/defensive; Surface for taste/style; Defer/Reject for conflicts and agent errors). The one exception is an explicit break-glass marker (Step 1), which is recorded in the hand-off.
- **Does not mark the PR ready or merge it.** `/finish` ends at draft. The user flips to ready (which triggers any Claude Code GitHub Action auto-review configured at `.github/workflows/claude-review.yml`) and merges.
- **Does not respond to auto-review comments.** That's the PR feedback loop, not `/finish`.

## Partial failure handling

If any external operation — MCP call, Bash CLI (`gh`, `git`, the check task), or Skill invocation — fails or hangs during the above steps, **stop immediately** and surface the partial state to the user. Do not retry blindly (the failed call might have succeeded server-side and a retry would duplicate). Do not auto-recover. Surface, concretely:

- **What succeeded locally vs what reached the remote** — e.g., which commits are on the branch, whether the branch was pushed, whether the PR was created. A push or `gh` call that failed may have partially applied server-side; say which state is uncertain.
- **The specific next-action choices, with the consequence of each** — e.g., "retry the push (safe; the branch has no remote ref yet)" vs "the PR may already exist server-side; check before re-creating."

Then wait for explicit user direction. This matches the cascade's general principle: honesty about partial state is more valuable than automated recovery that might make things worse.

## When something surprises you

If the instructions above don't cover something you're seeing, **prefer surfacing to the user over improvising**. The gap you surface is data that feeds the next revision of this executor. The improvisation you'd otherwise make is data that gets lost.

Common surprises worth flagging explicitly when they occur:

- **The issue body has a different structure** (more or fewer sections, different heading names). Don't normalize. Surface and ask.
- **The plan touches a component where a configurability-first principle ADR applies** but the spec doesn't say which way to go (configurable vs locked). Surface the configurability question; don't unilaterally make the call.
- **The dependency chain references a planning-backend-only ID** (e.g., `KEY-123`) instead of a GitHub issue number. `/finish` operates on GitHub issues. Surface and ask the user how to bridge — likely either the planning-backend↔GitHub sync isn't configured yet, or the issue body is using the wrong identifier.
- **The cascade artifact referenced in the issue body doesn't exist** (e.g., `docs/cbk/frame-NN.md` not present). Means framing was skipped, the file is named differently, or the issue body is wrong. Surface, don't search blindly.
- **The implementation needs a new `.claude/rules/<topic>.md` file** to be load-bearing (e.g., the spec asks for a pattern and there's no rules file yet). Surface and ask whether to create the rules file as part of this PR or as a separate one first.
- **The implementation conflicts with an existing ADR.** Surface the conflict and propose either (a) writing a new ADR that supersedes the conflicting one (chat-skill territory, abort `/finish`) or (b) revising the spec via re-rough-in. Don't silently violate an ADR.
