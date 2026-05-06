
---
description: Pick up a rough-in sub-sub-issue, verify dependencies, plan-mode against the Implementation section, execute, then run `/simplify` and `pr-review-toolkit:review-pr` with auto-triage of findings (Apply correctness/validity/defensive items as their own atomic commits; Surface taste/style items in the PR body for the user to decide). Opens a draft PR; the user marks ready. Expects one positional argument — the issue number.
argument-hint: <issue-number>
---

You are being asked to execute the rough-in sub-sub-issue **#$1** in this repository.

This is the initial version of `/finish` for this repo. It will be revised based on what early executions actually hit. If the instructions below don't match what's in the issue body, or if you hit friction this document doesn't anticipate, **surface the gap to the user** rather than improvising past it. Improvisation is what causes the cascade specs and the executor to drift apart over time.

## Step 1: Read the issue

Read issue #$1 from this repository using the github MCP (`github:issue_read` with `method: get`), or `gh issue view $1 --json number,title,body,labels,state` if MCP isn't available.

Verify:

- The issue is **open**. If closed, stop and tell the user: *"Issue #$1 is already closed. If you want to re-execute it, either reopen the issue or run rough-in to create a new sub-sub-issue."*
- The title matches the cascade rough-in format `[<workstream-slug>:F<N>:R<M>] <intent>` where `<workstream-slug>` is one of the workstream slugs locked in this project's blueprint (`docs/cbk/blueprint.md` § Workstreams). If not, stop and ask whether this is actually a cascade rough-in issue or a different kind of issue that got routed here by mistake.
- The labels include `cascade-depth:roughed-in`. If not, same question — confirm with the user before proceeding.

## Step 2: Parse the body section structure

The issue body should have these seven sections, in this order, with heading names preserved exactly:

- `## Context` — orientation for where this issue sits in the cascade
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
- `## Acceptance criteria` become the contract the plan must satisfy
- `## Test plan` names the tests the plan must scaffold red-first (Step 6) before implementing — these are the executable form of the acceptance criteria
- `## Done signal` is the verification command the plan must produce as its final step
- `## Dependencies` are already verified, but useful context for plan mode if it wants to reference prior work
- `## PR contract` tells plan mode how to finish (open draft PR with `closes #$1`, Conventional Commits title)

In addition, the plan must respect:

- **`docs/adr/` Decisions Log**, indexed in `docs/ARCHITECTURE.md` § Decisions log. Any code introduced must conform to the relevant ADRs. If the spec asks for something that conflicts with an ADR, surface that conflict before executing.
- **`docs/STANDARDS.md` quality bar** — testing philosophy, coverage policy, AI-collaborator workflow.
- **`.claude/rules/testing.md`** — three regimes (test-first, conformance-first, tests-as-shape-of-done). The `## Test plan` named tests are the input to Step 6's red-first scaffolding for logic-regime modules.
- **`.claude/rules/logging.md`** — structured `Logger` calls, correlation ID propagation, telemetry vs Logger boundary.
- Any other `.claude/rules/<topic>.md` files load-bearing for the diff at hand.

**Run plan mode explicitly** — do not start writing code in this turn. Produce a plan, present it to the user, wait for explicit approval before executing. Non-negotiable even for small-looking issues, because the user's review is the last HITL gate before code lands.

You are allowed to fetch additional context during plan mode if the spec genuinely needs it — read cited docs (`docs/ARCHITECTURE.md`, individual ADR files in `docs/adr/`, `docs/STANDARDS.md`, `CLAUDE.md`, `docs/cbk/frame-NN.md` for the parent framing), look at sibling files in the affected module, query the parent framing sub-issue for background. But don't fetch context speculatively; only fetch what the current step actually needs.

## Step 6: Execute the plan

After the user approves the plan, execute it. The execution order matters for logic-regime modules (see `.claude/rules/testing.md`):

1. **Scaffold the named tests from `## Test plan` as failing tests first.** ExUnit `flunk("not implemented")` or pytest `pytest.fail("not implemented")` is fine — what matters is that the named tests exist and fail red before any implementation lands. Run the test suite once to confirm red.
2. **Implement to green, one test at a time.** Resist implementing past the next failing test — that's how TDD's documenting-the-design value gets lost.
3. **Refactor while green.**
4. Run `mise run check` (compile + lint + typecheck + test) before declaring complete; this mirrors CI gates.
5. Verify against the Done signal before declaring complete.

For conformance-first or tests-as-shape-of-done regimes, the order is different — see `.claude/rules/testing.md` for the workflow per regime. The `## Test plan` section is still the source of truth for what tests must exist; only the *order* relative to implementation differs.

During execution, if you discover the spec is wrong in a way you can't work around (acceptance criterion is unverifiable, technical detail conflicts with code that already exists, architecture doc you're citing has drifted from the spec), **stop and surface the gap**. Do not patch the spec mid-execution. The right move is to abort `/finish`, return to chat, and run rough-in for a re-rough-in event that produces a corrected spec.

## Step 7: Simplify, review, action findings, then open the draft PR

Both `/simplify` and `pr-review-toolkit:review-pr` run **before** the PR opens, so the draft opens with a branch that has all correctness/validity/defensive findings already actioned — no "fix review-toolkit findings" follow-up PR-body churn the user has to drive for the things automation can settle definitively.

The principle: **the executor handles findings the codebase needs to be correct; the human handles findings about taste.** Correctness, validity, and defensive hardening auto-apply because there's a right answer. Style, clarity refactors, and naming preferences surface for the user because there isn't.

**Atomic commits, not squash.** Each meaningful unit of work — initial implementation, simplify pass, each Apply-class fix from the toolkit — gets its own focused commit on the branch with a Conventional Commits message. The squash happens **at merge-time on `main`** (`docs/STANDARDS.md` § Commit and branch conventions: "Squash-merge via PR — clean linear history on `main`"), not pre-PR. Per-branch atomic history is what the user reads to understand the diff, what `docs/STANDARDS.md` § Step 9 (PR feedback loop) needs for comment-to-commit linking, and what the auto-review action references in its inline comments. Do not `git commit --amend` past your initial implementation commit; do not pre-squash on the branch.

Once the implementation is complete and `mise run check` passes:

1. **Run `/simplify`** in your Claude Code session. Project-mandatory per `docs/STANDARDS.md` § Step 4. Review the simplify diff before continuing. Re-run `mise run check` after — if it fails, revert the simplify diff or fix the introduced regression before proceeding.
2. Create the branch following this repo's naming from `CONTRIBUTING.md` § Branches: `<type>/<short-description>`, with the planning-backend ID embedded if applicable (e.g., `chore/abc-14-umbrella-init`). Type is one of: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `perf`, `style`, `build`, `ci`. **Do not push and do not open the PR yet.**
3. Commit the work locally with a Conventional Commits message (per `CONTRIBUTING.md` § Commits). Squash-merge means per-branch commit granularity is invisible on `main` — favor clarity within the branch.
4. **Run `pr-review-toolkit:review-pr`** against the local branch. The skill auto-discovers the diff via `git diff` + `gh pr view`; pre-PR, it falls back to `git diff main...HEAD`. Invoke with no args for the default full sweep. Do **not** pass the PR number as an argument — that's not the skill's interface.

   If `pr-review-toolkit:review-pr` is not installed or fails to invoke, stop and surface — do not silently skip. Tell the user: "install the `pr-review-toolkit` Claude plugin, or explicitly waive this run." The "does not skip" rule (below) means a missing toolkit blocks `/finish`.

   In addition to the toolkit's specialized subagents, **also dispatch any project-local reviewers in parallel** when the diff touches code under their topics. Common project-local reviewers: an ADR-conformance reviewer (intersects ADRs against the diff) and a logging-discipline reviewer (validates `.claude/rules/logging.md` conformance). If your repo has not yet authored these, the toolkit's generic agents alone are sufficient.
5. **Triage and auto-action findings per `.claude/rules/pr-review.md`.** That file is the canonical source for the four-class rubric (Apply / Apply with care / Surface / Defer / Reject), the Apply/Surface calibration per category (docs, defensive additions, naming, test additions, style), the "What NOT to flag" exclusion list, the path-conditional aggressiveness, and the anti-patterns. Read it now if it's not already in context.

   **Quick summary of the rubric for orientation** (the rules file is authoritative when in doubt):

   - **Apply** — behavior-preserving fix with concrete evidence of need: defects with reproducible failing path, factually wrong comments / rot, dead code / unused imports, existing-doc clarity improvements, defensive additions with concrete evidence, local-symbol renames when fact-based, missing docstrings on entirely-undocumented surfaces. One focused commit per finding with a Conventional Commits message that names it.
   - **Apply with care** — execute as its own commit but flag in the hand-off summary: cross-file refactors >~50 LOC, new module outside named files, materially altering changes, non-obvious correctness fixes.
   - **Surface** — do not apply, note with agent's rationale verbatim: stylistic disagreement, structural refactors, speculative defensive guards (no concrete failing scenario), doc *expansions* of existing-but-thin sections, rule-of-three not hit on suggested abstractions, alternative approaches the agent prefers but the existing one is also fine.
   - **Defer** — conflicts with an ADR or out-of-scope.
   - **Reject** — agent factually misunderstood.

   **When uncertain, Surface — don't Apply.** The Apply gate is **behavior-preservation + concrete evidence**, not "the agent's reasoning is sound." Speculative findings without a demonstrated path go to Surface. Auto-applying speculative changes trains future humans (and agents) to ignore the bot.

   **Pre-filter generated files, lock files, vendored deps, and build artifacts** before the agents read them — see `pr-review.md` § Pre-filters.

   **One commit per logical fix.** Per the project's atomic-commits-not-squash discipline, each Apply finding gets its own focused commit on the branch (`docs/STANDARDS.md` § Commit and branch conventions; the squash happens at merge-time on `main`, not pre-PR). Use `git commit --amend` only to clean up your own most recent commit before pushing if it had a typo or you forgot to stage a hunk; do not amend across logical boundaries.

   Re-run `mise run check` after each fix (or at minimum after the last one in a batch). If it fails, revert the offending fix's commit (`git reset --hard HEAD~1` while still local-only) and reclassify the finding as **Apply with care** (re-attempt with more care) or **Defer** (with explanation) — do not push a branch with failing checks.

   If multiple agents disagree (one says X, another says not-X), pick the option that aligns with project rules (`.claude/rules/`, ADRs, `docs/STANDARDS.md`) and note the disagreement in the hand-off summary so the user can sanity-check.

   **Break-glass override**: if the PR body contains `<!-- skip-review-toolkit -->` (or equivalent agreed marker), Step 7's review-toolkit invocation is skipped per `pr-review.md` § Break-glass. The hand-off summary records "Review-toolkit explicitly skipped per <reason>." Don't silently skip; the audit trail is in the PR body.
6. **Push the branch** with `git push -u origin <branch>`. If the push fails (auth, network, branch protection), stop and surface the failure per § Partial failure handling. Local commits exist but no remote ref means `gh pr create` will fail too — fix the push first.
7. **Open the PR as a draft** via `gh pr create --draft`. PR title in Conventional Commits format (`<type>(<scope>)?: <subject>`). PR description includes:
   - `Closes #$1` for GitHub issues, or `Closes <KEY>-N` for planning-backend-tracked issues with a GitHub integration that recognizes the magic word. Put the close marker in the **PR body**, not just the title — body is the durable surface; titles can be edited at squash-merge time.
   - Citations to relevant ADRs, `frame-NN.md` milestones, or `.claude/rules/<topic>.md` files the implementation references.
   - A short summary of what changed and why.
   - A `## Review-toolkit triage` section listing each finding under its class (Apply / Apply with care / Surface / Defer / Reject) with a one-line outcome. **Surface** entries should include the agent's verbatim rationale so the user can decide during draft review without re-running the toolkit. This is the audit surface for the user; non-actioned findings live here, not lost.

   If `gh pr create --draft` fails (auth, missing scope, draft PRs disabled, rate limit, PR already exists for this branch), stop and surface the failure with per-step status.
8. **End your turn** with the PR URL, the review-toolkit triage summary (counts per class plus the concrete actioned items and the verbatim Surface entries), and a note that the PR is draft awaiting the user's review-and-flip-to-ready. Do not call `gh pr ready` and do not merge — those remain the user's calls.

   If any finding was classified **Defer** because it would conflict with an ADR or with the issue's design, lead the hand-off with that count and an explicit "Recommend addressing before flipping to ready, or accepting the deferral explicitly" line — the user still owns the call, but the framing must not flatten the conflict.

   The user's draft-review pass is where Surface findings get decided. They can ask you to apply any of them in the PR-feedback-loop turn, or wave them through.

## What `/finish` does NOT do

- **Does not modify the issue body.** If the spec is wrong, the user has to update it deliberately, not via runtime patching.
- **Does not handle re-rough-in.** Surface the need and return to chat for the rough-in skill.
- **Does not auto-create dependent issues.** If the work reveals a missing sub-sub-issue, surface and return to chat for rough-in.
- **Does not bypass dependencies.** Refuse to proceed when dependencies are unmet.
- **Does not modify cascade artifacts** (`docs/cbk/blueprint.md`, `docs/cbk/frame-NN.md`, etc.). Those are produced by chat-skill cascade phases.
- **Does not modify ADRs.** ADRs are immutable once accepted; revisions happen via new ADRs that supersede the old (chat-skill territory, not `/finish`).
- **Does not make workstream-level or framing-level decisions.** Those belong to upstream cascade phases (blueprint, framing, rough-in).
- **Does not skip `/simplify` or `pr-review-toolkit:review-pr`.** Step 7 invokes both before the PR opens; the simplify pass is non-negotiable per `docs/STANDARDS.md` § Step 4, and the review-toolkit findings are auto-triaged with the four-class rubric (Apply for correctness/validity/defensive; Surface for taste/style; Defer/Reject for conflicts and agent errors).
- **Does not mark the PR ready or merge it.** `/finish` ends at draft. The user flips to ready (which triggers any Claude Code GitHub Action auto-review configured at `.github/workflows/claude-review.yml`) and merges.
- **Does not respond to auto-review comments.** That's the PR feedback loop, not `/finish`.

## Partial failure handling

If any external operation — MCP call, Bash CLI (`gh`, `git`, `mise`), or Skill invocation — fails or hangs during the above steps, **stop immediately** and surface the partial state to the user with a per-step status. Do not retry blindly (the failed call might have succeeded server-side and retry would duplicate). Do not auto-recover. Wait for explicit user direction on how to proceed.

This matches the cascade's general principle: honesty about partial state is more valuable than automated recovery that might make things worse.

## When something surprises you

This is the initial version of `/finish` for this repo, and will be revised based on what early executions actually hit. If the instructions above don't cover something you're seeing, **prefer surfacing to the user over improvising**. The gap you surface is data that feeds the next revision. The improvisation you'd otherwise make is data that gets lost.

Common surprises worth flagging explicitly when they occur:

- **The issue body has a different structure** (more or fewer sections, different heading names). Don't normalize. Surface and ask.
- **The plan touches a component where a configurability-first principle ADR applies** but the spec doesn't say which way to go (configurable vs locked). Surface the configurability question; don't unilaterally make the call.
- **The dependency chain references a planning-backend-only ID** (e.g., `KEY-123`) instead of a GitHub issue number. `/finish` operates on GitHub issues. Surface and ask the user how to bridge — likely either the planning-backend↔GitHub sync isn't configured yet, or the issue body is using the wrong identifier.
- **The cascade artifact referenced in the issue body doesn't exist** (e.g., `docs/cbk/frame-NN.md` not present). Means framing was skipped, the file is named differently, or the issue body is wrong. Surface, don't search blindly.
- **The implementation needs a new `.claude/rules/<topic>.md` file** to be load-bearing (e.g., the spec asks for a pattern and there's no rules file yet). Surface and ask whether to create the rules file as part of this PR or as a separate one first.
- **The implementation conflicts with an existing ADR.** Surface the conflict and propose either (a) writing a new ADR that supersedes the conflicting one (chat-skill territory, abort `/finish`) or (b) revising the spec via re-rough-in. Don't silently violate an ADR.
