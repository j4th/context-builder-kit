---
name: rough-in
disable-model-invocation: true
description: Decompose one framing milestone into Claude-Code-ready sub-sub-issues. Use this skill when the user wants to break a milestone into implementable issues, move from planning into execution, produce issue specs with acceptance criteria and Claude Code plan-mode prompts, or pick up the next milestone for implementation. Trigger when the user says 'rough in this milestone', 'break this milestone down', 'plan issues for M1', 'I have my framing, what's next', 'let's start building', references a specific framing milestone by F-number, or references the cascade at the rough-in level. **Invoke deliberately — `disable-model-invocation` means this skill never auto-triggers; the moment for it is "I have a framing and need specs I can hand to Claude Code", even when the word "rough-in" never comes up.** Phase 5 of the cascade. One milestone at a time, just-in-time. Produces ready-to-implement sub-sub-issues under a framing sub-issue, each with acceptance criteria, technical detail, and a Claude Code plan-mode prompt.
---

# Rough-in

Phase 5 of the six-phase AI-assisted development cascade. Takes one framing milestone (one `[<workstream-slug>:F<#>]` sub-issue created by framing) and produces a set of **ready-to-implement sub-sub-issues** under it — each with acceptance criteria, technical detail, and a Claude Code plan-mode prompt in the body. The output is the input for the finish phase, where Claude Code picks up each sub-sub-issue, runs plan mode against the prompt, writes code, opens a PR, and closes the sub-sub-issue on merge.

**Target executor**: rough-in's specs are designed for Claude Code plan mode, not a human typing each sub-sub-issue by hand. This framing affects two things that would otherwise default to human-executor norms: **Implementation-section shape** (state intent and constraints, not implementation sequences — plan mode is a decomposition engine and over-prescribing "how" overrides its priors) and **issue granularity** (review units, not atomic work units — plan mode will internally decompose a well-shaped issue into 5-10 steps, so pre-decomposing into small issues means the decomposition happens twice with the first pass strictly less informed). When in doubt about either, optimize for plan mode's strengths — codebase exploration, idiomatic code generation, constraint satisfaction — rather than human-executor defaults. See Anthropic's [Claude Code best practices](https://code.claude.com/docs/en/best-practices) for the canonical framing: *"Separate research and planning from implementation to avoid solving the wrong problem. Letting Claude jump straight to coding can produce code that solves the wrong problem."* Over-prescriptive Implementation sections force plan mode past its natural exploration phase; over-atomized issue lists force plan mode to do its decomposition work at the wrong layer. Both are failures of the same underlying miscalibration.

Rough-in is one-milestone-at-a-time, just-in-time, **by design**. Framing already captured the reason (one-project-at-a-time avoids waterfall regression); rough-in applies the same discipline at the milestone level because the same failure mode applies. Rough-in M_n today produces specs that M_n-1's actual build will teach you to revise — don't rough-in M_n before building M_n-1, or you'll throw away the work.

## This skill is contract-first

The artifact is defined by **`references/contract.md`** — what one milestone's R-issue set must contain and the tests every spec must pass — together with the spec template and the executor's body parser. That is the whole read for drafting. The step-by-step procedure with its per-step gates (`references/procedure.md`) is on demand: full mode, or when a step is unclear.

Why: the 2026-09-02 A/B recorded in `references/contract.md`'s second paragraph and, in full, in `.claude/rules/orchestration-reference.md` § Applied instances — the artifact contract held in both arms, and what separated them was run material the procedure invited into the artifact. Nothing was retired — it moved.

## What rough-in reads and what it produces

**Required inputs**:
- `docs/cbk/problem_brief.md` — for no-gos and constraints still relevant to implementation
- `docs/cbk/scaffold.md` — for the quality bar and working conventions
- `docs/cbk/blueprint.md` — for stack decisions, methodology, the workstream entry for this project
- `docs/cbk/frame-NN.md` (the **highest-numbered active** framing for the workstream being roughed-in) — for the refined definition, the specific milestone being roughed-in, the deferred meta-issues table, and the interface commitments
- **The framing sub-issue** on the planning backend (via `issue_read` when planning = `github-issues`, `mcp__linear__get_issue` when planning = `linear`; not applicable when planning = `in-repo-markdown`) — for the slug inheritance, the milestone F-number, and any comments posted after framing committed
- `docs/ARCHITECTURE.md`, `docs/STANDARDS.md`, `CLAUDE.md` — foundation docs for architectural constraints, testing philosophy, and command conventions

**Produces**:
- One rough-in spec per sub-sub-issue, committed atomically as:
  - **In `github-issues` planning**: a GitHub sub-issue parented under the framing sub-issue via `issue_write` + `sub_issue_write`, labeled `cascade-depth:roughed-in`, titled `[<slug>:F<#>:R<#>] <intent>`, with body containing the full spec
  - **In `in-repo-markdown` planning**: an appended section to the framing's markdown file (or a new per-milestone rough-in markdown file — see backend-axis-aware behavior section), no planning backend commit
  - **In `linear` planning**: a Linear sub-sub-issue parented under the framing F-issue via `mcp__linear__save_issue` with `parentId`, `team`, `labels: ["workstream:<slug>", "cascade-depth:roughed-in", <type>]`, `assignee`, and `blockedBy` chain to prior R-issues. Single-step (no separate parent-linkage call). See `references/planning-backend-matrix.md` § `linear` planning axis for full MCP-call shapes.
    - **Set the Feature/Bug/Improvement type label in this initial `save_issue` call** (map from the R-issue's Conventional Commits `<type>`: `feat`→Feature, `fix`→Bug, everything else→Improvement). Linear caches the `{type}` branch-name prefix from the type label *at creation*, so applying it afterward won't fix the suggested branch. See `cbk-conventions.md` § Branch naming § Linear `{type}` placeholder.
- An update to `docs/cbk/README.md` chronological index noting that milestone M_n was roughed-in (append-only)

## Required pre-flight check: deferred meta-issues

Before decomposing any milestone, rough-in **MUST** read the Pre-flight checks table from the latest frame-NN.md and verify any meta-issue with `Blocks: M_n start` is resolved (closed) or explicitly cleared by the user. If unresolved meta-issues block M_n, **rough-in stops and surfaces the gap** rather than proceeding.

The check is mandatory in every rigor mode. The obligation lives on rough-in (framing's job is to populate the table; rough-in's job is to check it). The check cannot be skipped even in light mode — the one-way-door property is that sub-issues get created on the planning backend, and unwinding them after discovery that a meta-issue blocked the milestone is more expensive than catching the gap now.

**The check protocol**:
1. Read the framed file's Pre-flight checks section
2. For each row with `Blocks: M<n> start` (where M<n> is the milestone being roughed-in), read the corresponding GitHub issue state
3. If closed with `state_reason: completed` → resolved, proceed
4. If closed with any other reason → ask user whether "closed without completion" counts as resolved for this specific case
5. If open → stop, surface the blocker, ask user whether to (a) resolve the meta-issue first and resume, (b) explicitly clear the blocker as no longer applicable and record the decision, or (c) abort this rough-in run
6. Repeat for every blocking meta-issue before any decomposition work starts

**If the Pre-flight checks section says "No deferred meta-issues from this framing"** — proceed directly, the table was considered and is empty. If the section is missing entirely (older framing pre-dating this skill version), surface this as a framing-drift gap and ask the user to either confirm the framing has no meta-issues or loop back to framing for a proper table.

## Three rigor modes — light, standard, full

**Detect-then-confirm** at session start: propose a mode in one sentence from the user's opening message and any prior rough-in rows in the frame's `## Rough-in events` table; let the user override in one word. Default to **standard** for a first-time user.

- **Light mode — one gate.** One up-front confirmation (the milestone, the pre-flight result, anything the operator already knows the answer to), then run to completion: draft contract-first, verify, present the set with the issue plan and the decision list, provision and commit on approval.
- **Standard mode — three gates.** (1) inheritance + pre-flight; (2) the verified set — issue plan, coverage map and specs together, with the decision list; (3) the final pre-commit review, which also carries Step 5.5's provisioning state.
- **Full mode — up to nine gates**, one per step, following `references/procedure.md`. The contract still governs the output.

What no mode skips: reading every required input in full, the deferred-meta-issue pre-flight check, the **framing-invited judgment calls** (when a milestone's issue notes say "may compress 1+2" or "rough-in shapes the final boundaries", that decision is made explicitly and its reason recorded, in every mode), at least one gate on the final set before any planning-backend write, Step 5.5's provisioning gate when it fires, the atomic-transition discipline, and the verification pass below.

## How the specs are produced

1. **Read** the inputs above, `references/contract.md`, `references/templates/rough-in-spec-template.md`, and the executor's body parser (`.claude/commands/finish.md`'s preconditions, or the project's equivalent) — the parser's heading list is what every spec must carry, and where the disk issue template differs the parser wins and the drift is recorded.
2. **Draft the whole set** against the contract: the pre-flight result, the issue plan, the coverage map, every spec body, the commit-time text. Where a step would have stopped for a gate in a mode that has none, decide, proceed, and carry the question into the decision list. R-issues are review units, not work units; the frame's intents are inputs; criteria are numbered and traced; the artifact carries no run material.
3. **Verify before the gate** — one fresh-context verifier at the project's verify tier, per `references/contract.md` § Before the gate; fix its defects before presenting.
4. **Present** the set: the issue plan with its narrative arc ("R1 stands the harness up, R2 …, R4 is the capstone"), the milestone's capability, rough issues and acceptance signal quoted verbatim from the frame, the coverage map, each spec, and the decision list — the questions the draft would have asked.

Depth of research is a user signal: when the milestone's rough issues enter territory no prior rough-in has exercised, propose a depth and let the user confirm; never silently scale it down, and never present partial work as complete. `references/research-phase.md` has the depth patterns, what rough-in does **not** research, and the grounding rules for existence claims.

## The two one-way doors: provisioning the executor pair and the commit

Both run in the main loop after the gate, in every mode — never inside a dispatched drafter.

**Step 5.5 — provision the executor pair.** `/finish` is two files: `.claude/commands/finish.md` (the contract) and `.claude/commands/finish-procedure.md` (the procedure, read on demand). Idempotent, judged per file: if a file matches its bundled template — the body below the `--- BEGIN TEMPLATE ---` marker of `references/finish-command.md` for the contract, of `references/finish-procedure.md` for the procedure — it is a silent no-op; if it differs, present the **diff** (changed hunks only, never both files) with three options — leave in place, overwrite, abort — and wait; if it is missing, present the structured summary and get explicit approval before committing it. A cold start commits both files in one atomic transition. On any failure, stop and surface; never retry blindly. The full protocol is `references/procedure.md` § Step 5.5.

**Step 6 — the planning-backend commit.** One sub-sub-issue per spec, parented under the framing sub-issue, labelled `cascade-depth:roughed-in` (plus the workstream and validity-style labels the project uses), R-placeholders in dependencies and test tags resolved to numbers as the issues land; then the markdown half — the frame's events row, the index note, the roadmap flip where the project keeps one. Planning ops first, markdown second, capture-execute-rollback, and on partial failure stop and surface state to the user. The operational detail, slug inheritance, the re-rough-in and additive-pass patterns and the partial-failure protocol are `references/planning-backend-commit.md` and `references/procedure.md` § Step 6.

## Completion summary

The run's final deliverable, in every mode: **Commits** (SHAs with one-line summaries), **Sub-sub-issues** (a table of number, title, dependencies, capstone), **Handoff** (the exact next `/finish <N>` to run and what to expect; if the first R-issue has open dependencies, say so and name the soonest-runnable issue), and **Loose threads** (observations that might become skill revisions, repo state to track, cascade-level drift). Light mode may trim the prose, never a section; "No loose threads from this run" is a valid one-liner. `references/procedure.md` § Step 7 has the full shape.

## Phase exit checklist

Auto-checkable list that fires after the final gate, before declaring rough-in complete. Not a gate; a safety surface (the skill stops if any item fails), per `cbk-conventions.md` § Trip-wire pattern:

- [ ] The frame read in full; its `## Rough-in events` table examined; the milestone named and its slug + F-number inherited from the framing sub-issue's title
- [ ] Pre-flight rows checked: every row blocking this milestone's start is closed-completed or explicitly cleared and recorded; a row blocking one criterion is a dependency of the R-issue that owns it
- [ ] Idempotency: no R-issues exist for this milestone, or this is a declared re-rough-in, additive completeness pass or in-place refresh with its ledger row
- [ ] 2–6 R-issue specs (a departure stated and approved), each a coherent review unit; every F-level criterion owned by exactly one R-issue; the capstone named or its absence explained
- [ ] Every spec carries the executor's required headings in order; Implementation passes the eight properties with no non-IC code; R-level criteria numbered and cited; every test tag resolves; Assumptions present
- [ ] The executor pair's provisioning state known: present and matching, drift resolved by the operator, or cold-start committed
- [ ] Planning ops and the markdown half landed atomically, or partial state was surfaced cleanly; the frame's events row and the index note are in (and the roadmap flip, where the project keeps one)
- [ ] The verification pass ran and its defects were fixed or consciously kept (recorded in the gate)

## Backend-axis-aware behavior

Rough-in's behavior differs along **two independent axes** set by scaffold: the planning backend (`github-issues` / `linear` / `in-repo-markdown`) and the knowledge backend (`notion` / `none`). The planning-axis differences live in `references/planning-backend-matrix.md`; the knowledge-axis contract lives in `.claude/rules/knowledge-backend.md`.

**Planning axis**:

- **`github-issues`** (default, fully fleshed out): sub-sub-issues are created via the two-step `issue_write` + `sub_issue_write` pattern, parented under the framing sub-issue, assigned the `cascade-depth:roughed-in` label, initial board Status set to Ready via the board automation rules (not directly by the cascade, since the github MCP doesn't expose Projects v2 field operations).
- **`linear`**: sub-sub-issues are created via single-step `mcp__linear__save_issue` with `parentId` referencing the framing F-issue, full labels, `blockedBy` chain to prior R-issues, and the same atomic transition discipline as `github-issues` (capture-execute-rollback, partial failure recovery via stop-and-surface). The `parentId` field eliminates the orphan-sub-issue failure mode that the `github-issues` two-step pattern can hit. Closes-keyword for downstream PRs uses `Closes <TEAM>-<N>` per project's `cbk-conventions.md`. Full MCP shapes in `references/planning-backend-matrix.md`.
- **`in-repo-markdown`**: the entire planning-backend commit step is skipped. Rough-in specs land as appended sections in the framing's markdown file OR as a new per-milestone rough-in markdown file at `docs/cbk/frame-NN-M<#>-rough-in.md`, depending on operator preference (gate question: *"Want the rough-in specs in a new file or appended to frame-NN.md?"*). The slug + F-number + R-number naming convention still applies in the markdown headings so the hierarchy is grep-able.

Detailed per-axis behavior and edge cases live in `references/planning-backend-commit.md` and `references/planning-backend-matrix.md`.

**Knowledge axis** (`notion` / `none`):

- **`notion`**: rough-in **may optionally** read from Notion at its inheritance step (Step 1) — narrow opt-in search scoped to the current milestone, never auto-fetched. The operator decides per fetch. Per `.claude/rules/knowledge-backend.md` § "When to read."
- **Rough-in NEVER writes to the knowledge backend**, regardless of the knowledge-axis value. R-issue specs may LINK to Notion pages by URL when relevant context exists in Notion, but rough-in does not create or update Notion pages. This is by design: rough-in's specs land on the planning backend (or in markdown for `in-repo-markdown` planning); promoting durable knowledge to Notion is the operator's call at later phases or via direct edits, not a rough-in concern. There is no closing HITL gate for Notion writes at rough-in.
- **`none`**: no Notion interactions at all.

## Handoff contract to finish

When rough-in commits, the handoff to finish (Claude Code's native execution phase, not a chat skill) is:

- **The sub-sub-issues** exist on the planning backend, each with a body containing a ready-to-implement spec including a Claude Code plan-mode prompt
- **The executor pair** exists on disk — `.claude/commands/finish.md` (the contract) and `.claude/commands/finish-procedure.md` (the procedure) — committed by Step 5.5 during the first rough-in run against the repo
- **The naming convention** (`[<slug>:F<#>:R<#>]`) is grep-able across the board
- **The dependencies** within the milestone are explicit so `/finish` can verify them and pick up issues in the right order
- **The done signals** are concrete so `/finish` knows when each issue is complete

**What `/finish {issue_number}` does with this** (once Step 5.5 has committed the executor pair): reads the next unblocked rough-in spec from the board, verifies dependencies, runs Claude Code plan mode against the Implementation section, iterates with the user until the plan is approved, executes the plan, opens a PR that closes the issue with `closes #<N>`, the board automation moves the issue to Done on PR merge, and the parent framing sub-issue's sub-issue progress field ticks forward.

**What rough-in must not pass to finish**: implementation code (that's finish's job), decisions that finish shouldn't be making (those belong in rough-in's HITL gates), or vague acceptance criteria that force finish to guess at "done."

**Executor revision path**: the pair Step 5.5 provisions is the kit's current executor, revised as real executions surface gaps (the automation recommender pass framing typically surfaces as a deferred meta-issue for the first workstream is one such source). The revision updates `references/finish-command.md` and `references/finish-procedure.md` in this skill bundle; future rough-in runs against new repos pick up the revised version, and existing repos either manually update their committed copy or wait for Step 5.5's drift detection to propose an update. See `references/handoff-to-finish.md` for the full revision path and timing guidance.

## Project-level overrides

Project-specific overrides (workstream slugs, the executor and its heading list, the test-side trace-tag form, branch naming, layout, operational evidence) live in the project's `.claude/rules/cbk-conventions.md`. Read it at session start; treat its content as overrides on this skill's defaults.

## Reference files

- `references/contract.md` — **the default read**: what the R-issue set must contain, the tests each spec must pass, what the drafter returns, the verify-before-gate step
- `references/procedure.md` — the full step-by-step procedure (Steps 1–7 with their gates, Step 5.5's provisioning protocol, the capstone pattern, the HITL gates summary, failure modes, solo vs. team); full mode, or on demand
- `references/templates/rough-in-spec-template.md` — the full sub-sub-issue spec template with worked example
- `references/plan-mode-prompts.md` — the eight properties of a plan-mode prompt, the pitfalls with worked examples, the section-anchoring discipline
- `references/planning-backend-commit.md` — atomic transition pattern for rough-in, two-step `issue_write` + `sub_issue_write`, slug inheritance from parent, partial failure recovery, profile-aware behavior
- `references/finish-command.md` — bundled template for `.claude/commands/finish.md` (the executor's contract), committed by Step 5.5 during the first rough-in run in a repo
- `references/finish-procedure.md` — bundled template for `.claude/commands/finish-procedure.md` (the executor's procedure), provisioned beside the contract
- `references/inheritance.md` — how to read the required inputs, the verbatim summary template, the pre-flight protocol in detail
- `references/research-phase.md` — implementation-patterns research, open-question resolution, depth-as-user-signal, grounding existence claims
- `references/hitl-question-bank.md` — categorized questions per step (full and standard modes)
- `references/planning-backend-matrix.md`, `references/backends.md` — planning-axis behavior; the explicit "rough-in never writes to the knowledge backend" policy
- `references/failure-modes.md` — rough-in-specific failure modes with recovery patterns
- `references/handoff-to-finish.md` — the handoff contract to Claude Code's finish phase and the executor pair's revision path
- `references/test_cases.md` — realistic test prompts with success/failure criteria; the last case walks the contract-first default and its verification pass

Kit-wide operational contracts (`.claude/rules/`):
- `knowledge-backend.md` — knowledge-axis behavior (rough-in's read-only opt-in pattern; no writes). Loaded when scaffold.md records knowledge backend = `notion`.

Read references on demand, not all at once. SKILL.md routes; the contract, the template and the executor's parser are the drafting read; the procedure is the on-demand read.
