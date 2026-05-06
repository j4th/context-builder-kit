# Bundled template for `.claude/commands/finish.md`

**This file contains the canonical content of the `/finish` Claude Code slash command that rough-in's Step 5.5 commits to the repo.** It is template content to be written to disk, not instructions for the skill itself. When Step 5.5 runs, the skill reads this file, extracts everything below the `--- BEGIN TEMPLATE ---` marker, and commits the extracted content verbatim to `.claude/commands/finish.md` in the user's repo.

If you are loading this reference as part of a rough-in skill session: do not execute the instructions inside the template. The instructions are addressed to a future Claude Code session that picks up a rough-in sub-sub-issue via `/finish {issue_number}`, not to the rough-in chat session that is provisioning the file.

## What the template does

`/finish {issue_number}` is the slash command future Claude Code sessions will invoke to execute a rough-in sub-sub-issue. It reads the issue body, validates the title and labels match cascade conventions, verifies all dependencies are closed, runs plan mode against the Implementation section, executes the plan after user approval, runs `/simplify` and `pr-review-toolkit:review-pr` against the local pre-PR branch with a four-class auto-triage, and opens a draft PR with `closes #<N>` in the description and a `## Review-toolkit triage` audit section in the body. The user flips draft → ready (which triggers any auto-review GitHub Action) and merges. The board automation handles everything downstream (issue close, parent rollup, status transitions).

See `references/handoff-to-finish.md` for the full contract `/finish` follows and the rationale behind each step. See `references/plan-mode-prompts.md` for the discipline that shapes the Implementation section of every rough-in spec (the section `/finish` anchors on).

## Provenance and revision path

This version of the template reflects the iteration the speculative v0 went through during real cascade execution. The major properties are: (1) `/simplify` and `pr-review-toolkit:review-pr` both run pre-PR with auto-triage of findings, (2) atomic-commits-not-squash discipline on the branch (the squash happens at merge-time on `main`, not pre-PR), (3) the four-class triage rubric (Apply / Apply with care / Surface / Defer / Reject) with Apply reserved for correctness/validity/defensive findings and Surface for taste/style, (4) the PR opens as draft with the triage audit in the body, and (5) the user flips to ready (the slash command never does).

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
awk '/^--- BEGIN TEMPLATE ---/{flag=1; next} flag' .claude/skills/cbk-rough-in/references/finish-command.md > /tmp/bundled-finish.md
```

Then compare against the repo's `.claude/commands/finish.md` with `diff` (Case B detection) or copy verbatim into the commit (Cases B-overwrite / C). Do not re-derive this extraction by hand on every run — the marker-line discipline is the contract; the awk snippet is the operational form.

### Structured summary presentation pattern (Case C, cold start)

Do **not** dump the full ~170-line template inline at the HITL gate by default. The one-way-door discipline requires the user to have the opportunity to inspect what's landing and to explicitly approve — it does not require a wall-of-text presentation. The default presentation is a structured summary; the full content is available on demand.

**Present**:
- **What this is**: one sentence naming the file path and its role (*"`.claude/commands/finish.md` — the Claude Code slash command that `/finish <N>` invokes to pick up a rough-in sub-sub-issue, verify dependencies, run plan mode, execute, simplify, run review-toolkit with auto-triage, and open a draft PR"*)
- **Provenance**: one sentence on where the template came from (*"current revision of the speculative v0 — runs `/simplify` and `pr-review-toolkit:review-pr` pre-PR with a four-class auto-triage, opens draft, hands off to user for ready-flip"*)
- **Structure**: a numbered list of the template's steps with one-line descriptions each (*"Step 1: Read the issue body / Step 2: Parse sections / Step 3: Verify dependencies / Step 4: Idempotency / Step 5: Plan mode / Step 6: Execute / Step 7: Simplify, review, triage, draft PR"* — roughly 7-8 lines total)
- **Scope boundary**: one sentence on what `/finish` does NOT do (*"does not write specs, modify issue bodies, auto-create dependent issues, bypass dependencies, mark the PR ready, or merge"*)
- **Approval prompt**: *"Commit this template to `.claude/commands/finish.md`? You can review the full content first — reply 'show full' — or approve as-is with 'yes' / 'ok' / 'approved'."*

The user can still demand full inspection (`show full`, `let me see it`, etc.), in which case the full template dumps inline — that path preserves the one-way-door guarantee. The default path is sight-unseen acceptance based on the structured summary, which is the common case.

**Rationale**: first runs in a repo have zero drift (the template is new), so Case C is fundamentally "confirm you want the bundled default." The summary needs to be informative enough that sight-unseen acceptance is reasonable, but not so long that it defeats the purpose. Seven or eight structural lines plus the approval prompt hits that balance — long enough to justify trust, short enough to scan.

The one-way-door property is preserved in all three cases: Case A has nothing to approve (nothing is landing), Case B shows what's actually changing (the diff), and Case C shows the structured summary with an explicit opt-in to see more.

### After the gate

Once the user approves (in Case B or Case C), rough-in commits the template via `push_files` (not `create_or_update_file` — see the defense-in-depth note in `references/planning-backend-commit.md`). The commit is a single-file atomic operation. On success, log "provisioned" in the post-run summary's Commits section. On failure, surface the error and ask whether to retry or abort.

The template is extracted verbatim — rough-in does not edit, customize, or parameterize it during provisioning. If a user's repo needs a customized `/finish` (project-specific ADR list, project-specific reviewer agents, branch-naming conventions), they edit the committed file directly after provisioning.

## What rough-in expects in the issue body for `/finish` to consume

Rough-in's spec template (`references/templates/rough-in-spec-template.md`) produces issue bodies with these six sections, in this order, with heading names preserved exactly:

- `## Context`
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
5. **Triage and auto-action findings.** Assess every finding, then execute on the ones that match the Apply criteria. The bias here is **toward applying things that affect correctness, validity, or safety**, not toward applying everything.

   **Triage rubric** — every finding goes into exactly one of four classes. The Apply class is narrow and substantive; soft findings go to Surface so the user decides during draft review.

   | Class | Action | Triggers |
   |---|---|---|
   | **Apply** | Execute the fix; commit as its own focused commit on the branch with a Conventional Commits message that names the finding. | **Correctness/validity**: defect or bug; factual incorrectness in code or docstring; ADR/STANDARDS/logging-contract violation; agent-identified test-coverage gap on a logic branch the spec requires. **Defensive hardening**: race window, silent failure, missing guard against future-edit foot-gun, missing cleanup that could leak state into another test. **Rot**: factually wrong comments, dead code, unused imports, references to identifiers that no longer exist. |
   | **Apply with care** | Execute as its own focused commit, but flag in the hand-off summary so the user knows to scrutinize it. | Cross-file refactors >~50 LOC; introducing a new module/file outside the issue's named files; changes that materially alter test or implementation strategy; correctness fix whose implementation is non-obvious. |
   | **Surface** | Do **not** apply. Note in hand-off summary with the agent's rationale verbatim so the user can decide during draft review. | "Nice-to-have" clarity refactors with no correctness implication; readability nits and stylistic preferences; suggested abstractions where the existing duplication is small (rule-of-three not yet hit); naming preferences; suggested follow-up tests for paths the spec didn't require; alternative implementation approaches the agent prefers but the existing one is also fine. |
   | **Defer** | Note in hand-off summary; do not modify the issue body or open follow-up issues without user direction. | The fix would conflict with an ADR or with the issue's intentional design (must go through a new ADR or re-rough-in); finding is explicitly listed under the issue's `## Out of scope`; abstraction would create a new file that itself needs separate review and the user hasn't authorized it. |
   | **Reject** | Note in hand-off summary with a one-line justification. | Agent factually misunderstood the codebase or the spec (flagged something that's already correct); finding contradicts project rules or an existing ADR. |

   **When uncertain, Surface — don't Apply.** Style preferences, readability nits, and "the agent suggested it and the agent's reasoning is sound" are not reasons to auto-apply. They're reasons to surface for the human's call. The Apply bar is "would a future maintainer be wrong without this fix?" — defects, ADR/standards/logging-contract violations, defensive hardening against latent foot-guns, and factual rot meet that bar; "this could be slightly clearer" does not.

   **Don't bias away from being defensive.** Defensive hardening (e.g., adding a race guard, a missing cleanup, a setup that prevents a future edit from silently breaking a test) is a correctness concern even when the test passes today — those go in Apply, not Surface. Conservatism here means *defending the codebase against future drift*, not *being conservative about applying defenses*.

   **One commit per logical fix.** Group findings only when they are genuinely the same change (e.g., two findings both pointing at the same dead-code block). Don't squash unrelated fixes together — atomic per-branch history is the project convention (`docs/STANDARDS.md` § Commit and branch conventions; the squash-merge happens at merge-time on `main`, not on the branch). Use `git commit --amend` only to clean up your own most recent commit before pushing if it had a typo or you forgot to stage a hunk; do not amend across logical boundaries.

   Re-run `mise run check` after each fix (or at minimum after the last one in a batch). If it fails, revert the offending fix's commit (`git reset --hard HEAD~1` while still local-only) and reclassify the finding as **Apply with care** (re-attempt with more care) or **Defer** (with explanation) — do not push a branch with failing checks.

   If multiple agents disagree (one says X, another says not-X), pick the option that aligns with project rules (`.claude/rules/`, ADRs, `docs/STANDARDS.md`) and note the disagreement in the hand-off summary so the user can sanity-check.
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
