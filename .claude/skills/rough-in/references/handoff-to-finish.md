# Handoff from rough-in to finish

This file is the operational detail behind rough-in's handoff contract to the finish phase. It covers what `/finish` is, what it does with rough-in's specs, the executor pair's provisioning (Step 5.5), the between-M1-and-M2 timing for when bootstrap-finish should run, what `/finish` doesn't do, and the manual-execution fallback that applies during the bootstrapping period.

The handoff from rough-in to finish is structurally different from the handoffs between the other cascade phases. Consultation, scaffold, blueprint, framing, and rough-in are all in-chat skills that produce markdown artifacts and planning-backend objects. Finish is the only cascade phase that runs in **Claude Code**, not in a chat interface, and it's the only phase that produces actual code committed via PRs. The bridge between rough-in's chat output (sub-sub-issues with spec bodies) and finish's Claude Code execution is a specific Claude Code slash command — `/finish` — that doesn't exist yet.

## What `/finish {issue_number}` is

`/finish` is a Claude Code slash command that picks up a rough-in sub-sub-issue and executes it through to a draft PR. It is **contract-first**: `.claude/commands/finish.md` states what a finished issue is and the tests the result must pass; `.claude/commands/finish-procedure.md` beside it is the step-by-step, read on demand when a step is unclear. The contract's shape, in brief:

1. **Read in full before planning** — the issue body and its comments, the parent frame, every decision record the issue cites, the foundation docs and the rules that bind the diff, and the repository itself.
2. **Preconditions** — the issue is open; the title is a cascade format and the labels carry `cascade-depth:roughed-in`; the body has exactly the eight headings in order (Context / Assumptions / Implementation / Acceptance criteria / Test plan / Done signal / Dependencies / PR contract); every dependency is closed as completed; no PR or branch exists for the issue; a break-glass marker is noted. A mismatch is surfaced, never normalised away.
3. **What the finished issue is** — a plan gated in plan mode after executable research; a branch before any code lands; tests red-first where the regime dictates; an implementation inside the spec's scope; atomic commits; the check task green; the review floor (`/simplify`, then `pr-review-toolkit:review-pr` with the bounded sweep beside it) run once and triaged; a draft PR carrying the `## Review gate` and `## Triage` blocks; a hand-off that stands on its own.
4. **The tests every finish must pass** and **what the command does not do** — the contract's closing sections.

The Implementation section is the load-bearing input to the plan. The other sections constrain what the plan produces: acceptance criteria become test targets, the done signal becomes the verification command, dependencies prove the issue is unblocked, the PR contract dictates the close marker and the title. Board automation handles the rest on merge — the issue moves to Done and the parent framing sub-issue's progress rolls up.

## How `/finish` gets provisioned: rough-in's Step 5.5

`/finish` is provisioned by **rough-in's Step 5.5**, which runs between spec drafting (Step 5) and the planning-backend commit (Step 6). Step 5.5 checks whether the executor pair — `.claude/commands/finish.md` (the contract) and `.claude/commands/finish-procedure.md` (the procedure) — exists in the user's repo via `get_file_contents`, judged per file, and handles three cases:

- **A file does not exist**: cold-start case. Rough-in reads the bundled templates from `references/finish-command.md` and `references/finish-procedure.md` (both below their `--- BEGIN TEMPLATE ---` markers), presents the structured summary at a HITL gate for user review, and commits both files to `.claude/commands/` in one atomic transition on approval.
- **Both files exist and match their bundled templates verbatim**: already provisioned. Step 5.5 is a silent no-op. No gate fires, no commit happens, rough-in logs the skip and moves to Step 6.
- **A file exists but differs from its bundled template**: drift detected on that file. Rough-in surfaces that file's diff with three explicit options (leave in place / overwrite / abort) and waits for the user to pick before proceeding.

Step 5.5 runs its own atomic transition — not bundled with Step 6's planning-backend commit. If the pair's commit fails, rough-in surfaces the failure and lets the user decide whether to retry, skip and proceed anyway, or abort the whole rough-in run. See rough-in's `references/procedure.md` § Step 5.5 for the full protocol.

**This step was originally planned as a separate "bootstrap-finish" skill** but was folded into rough-in for three reasons: (1) timing — the slash command needs to exist before the first sub-sub-issue is committed, which means rough-in is the natural place to provision it; (2) self-bootstrapping — a fresh cascade run ends up with a fully working cascade including `/finish` without requiring a separate bootstrap step the user has to remember; (3) scope parallel to scaffold's Stage 2.5 — scaffold commits issue templates as workspace infrastructure, rough-in commits the slash command as execution infrastructure, and both follow the same idempotent-provisioning pattern.

## Revision path via the automation recommender pass

The executor pair that Step 5.5 provisions on a fresh cascade run is the kit's **current revision** — contract-first since 2026-09-06, revised through real executions (`.claude/rules/orchestration-reference.md` § Applied instances). It is a measured starting point, not a finished one: every real execution that surfaces a gap feeds the revision path below.

The revision path:

1. **Framing typically surfaces a deferred meta-issue** during the first workstream's framing pass, titled something like "Run Claude Code automation recommender after M2". This meta-issue has `Blocks: M3 start` and type `decision` — it gates the start of the third milestone so the recommender has two milestones of real execution data to analyze (M1 and M2) before it runs.

2. **The recommender pass includes `/finish` in its revision scope** explicitly. The recommender looks at friction points from M1 and M2 execution, missing guardrails the initial command didn't anticipate, over-rigid guardrails that added friction without adding safety, better pattern matches, subagent opportunities, and hook opportunities. It produces recommendations for revising `/finish` alongside the other automation recommendations.

3. **Accepted recommendations update `references/finish-command.md` and `references/finish-procedure.md`** (the procedure half, provisioned beside it) in the rough-in skill bundle — not the committed copy in the user's repo directly. The skill bundle is the source of truth for the bundled template; the committed copy is what the bundled template provisioned on a specific date.

4. **Subsequent rough-in runs detect the drift** via Step 5.5's drift handling. When a user runs rough-in in a repo where the committed `/finish` differs from the updated bundled template, the step surfaces the drift and offers the three options. If the user picks "overwrite", the revised template replaces the committed copy in a single commit. If the user picks "leave in place", their existing customized version is preserved.

5. **Fresh cascade runs automatically pick up the updated template** because Step 5.5's cold-start case reads the current bundled template. A user starting a new cascade in a new repo two months after the recommender pass gets the revised `/finish` from the start.

## Why provisioning before this repo's first execution is OK

The counterargument to provisioning `/finish` before this repository has any execution data is that the executor may encode assumptions the project will not share. The counter-counterargument is that the friction of hand-writing `/finish` before the first execution is higher than the cost of revising it after two milestones, **and the provisioned version doesn't have to fit perfectly — it has to "surface gaps, never improvise past them"**.

The contract's opening paragraph enforces this discipline: *"If the issue does not match what this contract expects, or you hit friction it does not anticipate, **surface the gap** rather than improvising past it — the gap you surface is data for the next revision; the improvisation is data that gets lost."*

As long as the provisioned pair is honest about its provenance and sets up Claude Code to surface gaps rather than work around them, the friction patterns from early executions become visible in real time and feed the revision pass.

## What rough-in's specs need to look like for `/finish` to succeed

The eight properties from `references/plan-mode-prompts.md` are the load-bearing list. To restate them in the context of `/finish`'s contract:

1. **Second person**: `/finish` hands the Implementation section to plan mode as instructions. Plan mode reads instructions, not descriptions. Specs that describe what should exist instead of instructing what to create force plan mode to translate, which introduces drift.

2. **Self-contained**: `/finish` doesn't fetch additional context unless plan mode asks for it. Specs that require chasing context have plan mode either asking for clarification (slow) or guessing (error-prone).

3. **Specific files, constraints, and locked signatures**: plan mode needs to know which files to touch and which invariants to satisfy. Vague targets force plan mode to make decisions that should have been made during rough-in. Locked interface commitment signatures (IC-N from framing) should be inlined verbatim; other signatures should be described by contract, not prescribed by exact shape, so plan mode can propose the right signature from real codebase context.

4. **Cites cascade docs by section name**: `/finish` and plan mode can fetch cited sections if they want. Citations are pointers, not prerequisites — they let plan mode fetch additional context optionally without requiring it.

5. **Verification step embedded**: plan mode produces a plan that includes verification steps. If the spec doesn't name the verification step, plan mode has to invent one, which may not match what the user actually wants.

6. **~300-800 words (up to ~1000 for cross-crate capstones)**: plan mode reads the Implementation section in one pass. Sections that are too short don't have enough information; sections that are too long either get summarized internally (details get lost) or have drifted into prescriptive prose that belongs in plan mode's Plan phase (see property 8).

7. **Names what NOT to do**: plan mode tends to scope-creep helpfully if not constrained. Specs that explicitly forbid out-of-scope work prevent plan mode from doing work that belongs in a different sub-sub-issue.

8. **States intent and constraints, not implementation sequences**: plan mode is a decomposition engine — [Anthropic's best practices guidance](https://code.claude.com/docs/en/best-practices) recommends separating research and planning from implementation precisely so plan mode can explore real code context before committing to an approach. Specs that inline function bodies or prescribe test function names for non-IC work override plan mode's priors and produce strictly worse code than a cleaner prompt would. The only legitimate inline code blocks are IC-verbatim shapes prefaced with *"IC-N shape is verbatim and not negotiable."*

If a rough-in spec lacks any of these properties, `/finish` will technically still execute it but will produce worse plans than it should. The remedy is to revise the spec at rough-in time, not at finish time — the cost of a bad plan-mode prompt at finish time is much higher than the cost of revising at rough-in time, because at finish time the user is in plan mode iteration loops that are slower than chat-based spec review.

## What `/finish` does NOT do

- **Does not write rough-in specs** — that's rough-in's job. `/finish` reads specs that rough-in already produced.
- **Does not modify the issue body** — `/finish` reads the body, hands it to plan mode, and treats it as immutable. If the spec is wrong, the user has to update it (either by hand-editing the issue body or by re-running rough-in for a re-rough-in event), not by `/finish` patching it during execution.
- **Does not handle re-rough-in** — re-rough-in is rough-in's responsibility. If `/finish` discovers during execution that the spec is wrong (e.g., the acceptance criteria turn out to be unverifiable, or the technical detail conflicts with code that already exists), the right move is to abort `/finish`, return to chat, and run rough-in for a re-rough-in event. `/finish` doesn't try to fix the spec mid-execution.
- **Does not auto-create dependent issues** — if a sub-sub-issue's Implementation reveals that another sub-sub-issue should exist, `/finish` doesn't create it. The user returns to chat, runs rough-in to add the new spec, then re-runs `/finish` against the original issue once the new dependency is met.
- **Does not bypass dependencies** — if the Dependencies section lists open issues, `/finish` refuses to proceed even if the user insists. Dependencies exist for a reason; bypassing them is a re-rough-in event, not a finish event. The user can re-run rough-in to remove or change the dependency, then re-run `/finish`.
- **Does not modify the cascade event log** — `/finish` doesn't update `README.md` index, doesn't supersede prior sub-sub-issues, doesn't create new framings or workstreams. All cascade-event operations belong to chat-based skills.
- **Does not handle workstream-level decisions** — workstream scope, milestone sequencing, framing capability boundaries, and rough-in granularity are all chat-based decisions made by upstream cascade phases. `/finish` operates at the lowest level (one sub-sub-issue at a time) and doesn't make decisions above that level.

## Fallback for the edge case where Step 5.5 fails

If Step 5.5 fails for any reason (MCP hang, branch protection blocking the commit, user chooses to skip it explicitly) and the user still wants to execute a rough-in sub-sub-issue, the manual fallback is:

1. **Pick a rough-in sub-sub-issue** from the planning-backend tree (find an unblocked R-issue with `cascade-depth:roughed-in` label and Status = Ready)
2. **Read the issue body** in the GitHub web UI or via `gh issue view` from the command line
3. **Verify the Dependencies section** by hand — check that each listed dependency is closed
4. **Open Claude Code** in the repo, start a new session
5. **Hand the Implementation section to Claude Code's plan mode** by copying it into the chat or referencing it via `gh issue view <N> --json body`
6. **Iterate on the plan** with Claude Code as you would for any plan-mode session
7. **Execute the plan**, write the code, run the tests
8. **Open the PR** with `closes #<N>` in the description, following the issue's PR contract section
9. **Merge the PR**, watch the board automation move the issue to Done

This is identical to what `/finish` would do automatically; the only difference is the user drives the steps manually instead of typing one slash command. It's the safety net for when Step 5.5 couldn't provision the slash command for environmental reasons, not a planned execution pattern.

## What this handoff document doesn't cover

- **`/finish`'s implementation details** — Claude Code's slash command system handles them once `.claude/commands/finish.md` exists on disk
- **Plan mode's internals** — Claude Code's plan mode is a black box from rough-in's perspective
- **PR review patterns** — the cascade doesn't prescribe how PRs get reviewed; that's the team's process
- **Deployment, release, or rollout patterns** — out of cascade scope; the cascade ends at PR merge
- **The specific content of the bundled `/finish` templates** — that lives in `references/finish-command.md` (the contract) and `references/finish-procedure.md` (the procedure), below their `--- BEGIN TEMPLATE ---` markers. This document covers the handoff contract and revision path; the reference file covers the actual template content

If you're starting a fresh cascade run against a new repo, rough-in's Step 5.5 will provision the slash command automatically on its first run in that repo. No separate bootstrap step, no manual hand-writing. If Step 5.5 fails for environmental reasons, the fallback pattern above is available.
