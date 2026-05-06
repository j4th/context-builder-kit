---
name: rough-in
description: Decompose one framing milestone into Claude-Code-ready sub-sub-issues. Use this skill when the user wants to break a milestone into implementable issues, move from planning into execution, produce issue specs with acceptance criteria and Claude Code plan-mode prompts, or pick up the next milestone for implementation. Trigger when the user says 'rough in this milestone', 'break this milestone down', 'plan issues for M1', 'I have my framing, what's next', 'let's start building', references a specific framing milestone by F-number, or references the cascade at the rough-in level. **Use this skill even when the user doesn't explicitly say "rough-in" — the trigger is the moment of "I have a framing and need specs I can hand to Claude Code", not the vocabulary.** Phase 5 of the cascade. One milestone at a time, just-in-time. Produces ready-to-implement sub-sub-issues under a framing sub-issue, each with acceptance criteria, technical detail, and a Claude Code plan-mode prompt.
---

# Rough-in

Phase 5 of the six-phase AI-assisted development cascade. Takes one framing milestone (one `[<workstream-slug>:F<#>]` sub-issue created by framing) and produces a set of **ready-to-implement sub-sub-issues** under it — each with acceptance criteria, technical detail, and a Claude Code plan-mode prompt in the body. The output is the input for the finish phase, where Claude Code picks up each sub-sub-issue, runs plan mode against the prompt, writes code, opens a PR, and closes the sub-sub-issue on merge.

**Target executor**: rough-in's specs are designed for Claude Code plan mode, not a human typing each sub-sub-issue by hand. This framing affects two things that would otherwise default to human-executor norms: **Implementation-section shape** (state intent and constraints, not implementation sequences — plan mode is a decomposition engine and over-prescribing "how" overrides its priors) and **issue granularity** (review units, not atomic work units — plan mode will internally decompose a well-shaped issue into 5-10 steps, so pre-decomposing into small issues means the decomposition happens twice with the first pass strictly less informed). When in doubt about either, optimize for plan mode's strengths — codebase exploration, idiomatic code generation, constraint satisfaction — rather than human-executor defaults. See Anthropic's [Claude Code best practices](https://code.claude.com/docs/en/best-practices) for the canonical framing: *"Separate research and planning from implementation to avoid solving the wrong problem. Letting Claude jump straight to coding can produce code that solves the wrong problem."* Over-prescriptive Implementation sections force plan mode past its natural exploration phase; over-atomized issue lists force plan mode to do its decomposition work at the wrong layer. Both are failures of the same underlying miscalibration.

Rough-in is one-milestone-at-a-time, just-in-time, **by design**. Framing already captured the reason (one-project-at-a-time avoids waterfall regression); rough-in applies the same discipline at the milestone level because the same failure mode applies. Rough-in M_n today produces specs that M_n-1's actual build will teach you to revise — don't rough-in M_n before building M_n-1, or you'll throw away the work.

## What rough-in reads and what it produces

**Required inputs**:
- `docs/cbk/problem_brief.md` — for no-gos and constraints still relevant to implementation
- `docs/cbk/scaffold.md` — for the quality bar and working conventions
- `docs/cbk/blueprint.md` — for stack decisions, methodology, the workstream entry for this project
- `docs/cbk/frame-NN.md` (the **highest-numbered active** framing for the workstream being roughed-in) — for the refined definition, the specific milestone being roughed-in, the deferred meta-issues table, and the interface commitments
- **The framing sub-issue** on the planning backend (via `issue_read` in github-only profile) — for the slug inheritance, the milestone F-number, and any comments posted after framing committed
- `docs/ARCHITECTURE.md`, `docs/STANDARDS.md`, `CLAUDE.md` — foundation docs for architectural constraints, testing philosophy, and command conventions

**Produces**:
- One rough-in spec per sub-sub-issue, committed atomically as:
  - **In github-only profile**: a GitHub sub-issue parented under the framing sub-issue via `issue_write` + `sub_issue_write`, labeled `cascade-depth:roughed-in`, titled `[<slug>:F<#>:R<#>] <intent>`, with body containing the full spec
  - **In markdown-only profile**: an appended section to the framing's markdown file (or a new per-milestone rough-in markdown file — see profile-aware behavior section), no planning backend commit
  - **In Linear+GitHub profile**: a Linear sub-sub-issue parented under the framing F-issue via `mcp__linear__save_issue` with `parentId`, `team`, `labels: ["workstream:<slug>", "cascade-depth:roughed-in", <type>]`, `assignee`, and `blockedBy` chain to prior R-issues. Single-step (no separate parent-linkage call). See `references/github-only-vs-opinionated.md` § Linear+GitHub profile for full MCP-call shapes.
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

Rough-in's full flow (target identification → context gathering → research → HITL clarification → issue plan → issue drafting → HITL review → planning-backend commit, with eight HITL gates) is the **full mode**, not a requirement. Three rigor modes:

**Full mode** — eight HITL gates (one per step). Best for: the first rough-in of a new workstream, high-complexity milestones with multiple architectural decisions, milestones with significant user-managed work, anyone who wants every decision reviewed.

**Standard mode** — four HITL gates batched: (1) inheritance + pre-flight checks combined, (2) research depth proposal + open-question resolution combined, (3) issue plan review, (4) final pre-commit review of the full sub-sub-issue set. Best for: second or later rough-in of a workstream, milestones with established patterns from prior rough-in runs, building-on-existing-code milestones.

**Light mode** — one combined up-front confirmation listing what rough-in will produce, then run-to-completion until final presentation. Best for: users who say *"just give me the issues"*, *"I know what I'm doing"*, or who are roughing-in a small milestone with obvious decomposition.

**Detect-then-confirm** at session start: propose a mode in one sentence based on the user's opening message and any prior rough-in runs visible in `README.md` index. Let the user override in one word. If the opening message gives no signal, default to **standard mode** for first-time users.

**What rough-in must NOT skip even in light mode**: reading all required inputs in full, the deferred meta-issues pre-flight check, at least one HITL gate on the final sub-sub-issue set before commit, and the planning-backend commit atomic transition discipline.

## Step 1 — Inheritance and pre-flight checks

Read all required inputs in full, present verbatim inheritance summary including the specific framing milestone being roughed-in, run the mandatory deferred meta-issues pre-flight check.

The inheritance summary must quote the milestone's capability statement, rough issues list, and acceptance signal verbatim from frame-NN.md. Do not paraphrase — paraphrasing is the failure mode.

Detailed inheritance discipline lives in `references/inheritance.md`.

**HITL gate (full mode)**: present the inheritance summary and the meta-issues check result, get explicit user approval before moving to research.

## Step 2 — Milestone selection within framing

If the user has named the specific milestone (*"rough in F1"* or *"rough in the regex-pack verifier milestone"*), look it up in frame-NN.md and confirm the row. If the user said *"rough in the next milestone"*, read `README.md` index and prior rough-in records to determine which milestones in the current framing have been roughed-in, identify the next unroughed-in milestone in sequence, confirm with user.

If the user is re-roughing-in an already-roughed-in milestone (because the prior rough-in spec didn't survive contact with the code), treat the new rough-in as a deliberate cascade event that supersedes the prior one. The prior sub-sub-issues get closed with `state_reason: not_planned` + `superseded` label as part of the same atomic transition that creates the new ones. See `references/planning-backend-commit.md` for the re-rough-in pattern.

Also inherit the slug and F-number from the framing sub-issue title — read the parent framing sub-issue via `issue_read` to get the canonical slug + F-number pair, use these to construct sub-sub-issue names like `[<slug>:F<#>:R<#>]`. **Never re-derive the slug** from the workstream name or the framing capability name — always inherit from the parent's existing title.

**HITL gate**: confirm the milestone selection and the F-number being roughed-in.

## Step 3 — Research phase (depth is a user signal)

Resolve remaining uncertainty before producing issue specs. **Depth is a user signal, not a rough-in judgment** — same pattern as framing's research phase. Rough-in surfaces the signals (framing's open questions for this milestone, the complexity of the rough issues list, whether the stack has been exercised by prior rough-in runs, user expertise) and proposes a depth in one sentence. User confirms or overrides.

**When rough-in hits token pressure**, surface it explicitly and give the user the choice between finishing partial work, skimming to fit, or continuing in a follow-up message. **Never silently produce partial work and present it as complete.**

Two research sub-tracks, same structure as framing:

**3a. Implementation patterns** — look up concrete patterns for each rough issue's intent. What's the idiomatic approach in the stack for "Define trait with associated types"? What's the canonical TOML deserialization pattern? The goal is to resolve technical approach questions that would otherwise block issue spec drafting or force Claude Code to relitigate them during execution.

**3c. Resolve open questions from framing** — framing may have deferred decisions to rough-in with explicit trip-wires (*"revisit during rough-in"*). Read the Open questions section of frame-NN.md and either resolve each with the user or escalate back to framing if the question has become bigger than rough-in can handle.

**What rough-in does NOT research**: stack decisions (those are blueprint), methodology selection (blueprint), workstream-level interface commitments (framing), MCP server selection (blueprint), cascade-level conventions (scaffold/blueprint). Rough-in operates at the milestone level — patterns, specific libraries for specific rough issues, acceptance criteria detail, plan-mode prompt shape.

Detailed research patterns and question banks live in `references/research-phase.md`.

**HITL gate (full mode only)**: present research findings and the technical approach before producing the issue plan.

## Step 4 — Issue plan (before drafting individual specs)

Produce an **issue plan** — a short ordered list of sub-sub-issues with titles and one-sentence intents, before drafting the full specs. This is cheaper to iterate on than full specs and catches granularity problems (too many issues, too few, wrong boundaries) early.

Each issue plan entry has:
- **Sequence number and name** (e.g., "R1: Define Verifier trait")
- **Issue title** following the convention `[<slug>:F<#>:R<#>] <intent>`
- **One-sentence intent** (the thing this issue exists to do)
- **Issue type flag**: Claude-Code-implementable (default), user-managed (manual setup), or hybrid
- **Dependency on prior R-issues in the milestone**, if any
- **Whether this is the capstone** — the last issue in the milestone that integrates or validates the prior work and is often different in shape (see Capstone pattern below)

**Target count: 2-6 rough-in issues per milestone is typical for Claude-Code-executed workflows, and 3-7 for human-executed workflows.** The lower bound is 2 rather than 3 because Claude Code plan mode is itself a decomposition engine — [plan mode's read-only exploration phase adds a verification layer before code gets touched](https://code.claude.com/docs/en/best-practices), and when a well-shaped issue is handed to plan mode it internally decomposes into ~5-10 steps and executes them in sequence within one session. The right rough-in granularity is **"coherent review units with clean boundaries"** rather than "atomic work units." Two well-shaped issues that each plan-mode into ~5-10 internal steps is often preferable to four small issues that each plan-mode into 2-3 steps, because the per-issue `/finish` overhead (plan mode warmup, review cycles, PR latency, board-automation round trips) is real and compounds across a milestone.

**The honest test isn't the count, it's whether each issue is a coherent review unit.** A "coherent review unit" is: one reviewer can read the PR in one sitting and form a complete opinion about it; the work is scoped to a single cross-crate boundary or a single architectural concern; the work doesn't straddle a layer that would benefit from separate landing. If two issues are each coherent review units and merging them would make the reviewer's job harder, keep them separate. If two issues are each so small that reviewing them separately feels like reviewing the same code twice, merge them — the "why R1 before R2" reasoning doesn't disappear when they merge, it becomes internal plan-mode step ordering, which is cheaper to revise than issue-boundary ordering.

Outside the range signals a problem in the same spirit as before but with softer edges: **1 issue** often means the milestone is too small in a way that should have been caught at framing (fold into a sibling milestone), OR the milestone has one genuinely atomic piece of work with a clean boundary (legitimately 1-issue — note the departure from the typical range in the HITL gate and proceed). **8+ issues** means the milestone is too big (split via a re-framing trigger) or the rough-in author is pre-decomposing work that plan mode would handle internally (collapse adjacent issues with the review-unit test above).

**HITL gate**: present the issue plan as a numbered list with the narrative arc (*"R1 defines the trait, R2 implements the first concrete verifier, R3 wires the loader, R4 is the capstone integration + smoke test"*). Iterate until the user approves the plan. Surface any count outside the 2-6 range explicitly so the user can accept the departure consciously rather than by omission. **Do not draft individual specs until the plan is approved** — drafting specs is expensive and wasteful if the plan is wrong.

## Step 5 — Draft individual issue specs

For each approved issue plan entry, draft the full sub-sub-issue spec using the template in `references/templates/rough-in-spec-template.md`. Each spec contains:

1. **Title** — exact naming convention from the plan
2. **Intent** — one paragraph, expanded from the plan's one-sentence intent
3. **Acceptance criteria** — concrete, verifiable, user-visible or test-visible outcomes. "The tests pass" is not acceptance; "`cargo run -- regex/lesson_01.toml` succeeds with output matching `expected.txt`" is.
4. **Test plan** — named tests that satisfy each acceptance criterion. One named test per criterion (rephrased from imperative spec to declarative test name), quotable verbatim from the test runner's output. For logic-regime modules these are scaffolded as failing tests *before* implementation begins (see `.claude/rules/testing.md` for regime classification); for boundary adapters they're the conformance + shim dispatch tests; for UI / integration they're the assertions written after the surface exists. The test plan is what `/finish` Step 6 anchors on for the red-first scaffolding step — vague test names ("the function works") force the implementer to invent the contract, defeating the point.
5. **Technical detail** — the specifics Claude Code needs to know: files to create/modify, functions to define with signatures, patterns from research to follow, libraries to use, gotchas to avoid
6. **Claude Code plan-mode prompt** — the actual prompt the user (or the bootstrap-finish CLAUDE.md section) will hand to Claude Code's plan mode. This is the load-bearing output of rough-in. It must be self-contained enough that Claude Code can read it and produce a plan without needing to chase down external context.
7. **Dependencies** — explicit list of prior R-issues that must be complete before this one can start
8. **Done signal** — a specific, observable outcome that means this issue is done. Usually the same as the acceptance criteria's top-line check but stated as a verification command the user can run.

**The Claude Code plan-mode prompt is the most important part of each spec.** It's the thing that makes rough-in valuable over just "framing plus a wish list." A plan-mode prompt has these properties:

- Written in second person ("Implement the Verifier trait...") so Claude Code reads it as an instruction
- Contains enough architectural context to avoid relitigating framing's decisions
- Names specific files, constraints, and invariants; inlines signatures **only when they're verbatim from a locked interface commitment** (otherwise leaves signature shape to plan mode's Plan phase)
- Cites CLAUDE.md / ARCHITECTURE.md / STANDARDS.md sections by name when the rules matter
- Specifies the test or verification step that proves the implementation is correct
- Is ~300-800 words (up to ~1000 for cross-crate capstones) — long enough to be self-contained, short enough to read in one pass
- **States intent and constraints, not implementation sequences** — plan mode is a decomposition engine; over-prescriptive Implementation sections override its priors and produce strictly worse code than a cleaner prompt would. The only legitimate inline code blocks are IC-verbatim shapes prefaced with *"IC-N shape is verbatim and not negotiable."*

Detailed spec drafting guidance, the full eight-property list, pitfalls (including a CSV loader worked example), and plan-mode prompt patterns live in `references/plan-mode-prompts.md`.

### Example excerpt (what one rough-in spec looks like in practice)

To make the output shape concrete: here's what one sub-sub-issue spec looks like, taken from a real cascade run — R1 of M1 of a "regex-pack" workstream. Note the specificity — acceptance is observable, technical detail is concrete, plan-mode prompt is self-contained.

**Output fragment** (resulting `[regex-pack:F1:R1]` sub-issue body):

```markdown
## Intent

Define the `Verifier` trait as the load-bearing abstraction every pack will implement. This is the first concrete touch of the v0.4 hard gate's architectural commitment — the trait must accommodate all four verifier shapes without growing variant logic in `core-engine`.

## Acceptance criteria

- `crates/core-engine/src/verifier.rs` exists and compiles cleanly under `cargo check --workspace`
- The trait has associated types for `Input`, `Context`, `Error` and a single `verify` method
- `cargo doc --no-deps` renders the trait with complete rustdoc
- The trait compiles with no concrete impls (impls come in R2)

## Test plan

Regime: conformance-first (this is the trait declaration; concrete-impl conformance lands in R2). The trait file itself has nothing to TDD against until R2 has an impl, so the R1 test plan is a compile-and-doc smoke check rather than red-first unit tests.

- `cargo check --workspace` passes (trait declaration compiles)
- `cargo doc --no-deps` succeeds and the rendered output for `tuitor_engine::verifier::Verifier` includes the docstring referencing `docs/ARCHITECTURE.md § "The Verifier trait"`

## Technical detail

- File: `crates/core-engine/src/verifier.rs` (new file)
- Function: `trait Verifier { type Input; type Context; type Error; fn verify(&self, input: &Self::Input, ctx: &Self::Context) -> Result<(), Self::Error>; }`
- Add `pub mod verifier;` to `crates/core-engine/src/lib.rs`
- Cite `docs/ARCHITECTURE.md § "The Verifier trait"` for the rationale in the rustdoc header

## Claude Code plan-mode prompt

Implement the `Verifier` trait as defined in `docs/ARCHITECTURE.md § "The Verifier trait"`. The trait has associated types `Input`, `Context`, and `Error`, and a single method `verify(&self, input: &Self::Input, ctx: &Self::Context) -> Result<(), Self::Error>`. The trait is pure — no async, no I/O, no network, per the engine sync/offline invariant in STANDARDS.md § Unenforced invariants.

Create `crates/core-engine/src/verifier.rs`, define the trait with full rustdoc citing the ARCHITECTURE.md section, and add `pub mod verifier;` to `crates/core-engine/src/lib.rs`. Do not create any concrete implementations — those come in a later issue. Verify via `cargo check --workspace` and `cargo doc --no-deps`. Open a PR with `closes #<N>` where <N> is this issue's number.

## Dependencies

None — this is the first issue in M1.

## Done signal

`cargo check --workspace && cargo doc --no-deps` succeeds, the trait is visible in the rustdoc output, and the PR merges.
```

The full spec template lives in `references/templates/rough-in-spec-template.md`. The example above shows what one spec feels like in practice — every field populated, no placeholders, self-contained enough that Claude Code can execute it.

**HITL gate**: present each spec inline for review, or batch them into one presentation for standard/light mode. Iterate until the user approves each spec individually or the full set.

## Step 5.5 — Provision `/finish` slash command (if missing)

**Purpose**: ensure the `.claude/commands/finish.md` Claude Code slash command exists in the user's repo before rough-in commits the first sub-sub-issue. Without it, the user has no tooling to pick up the sub-sub-issues rough-in is about to create — they'd have to hand-write the slash command between the Step 6 commit and their first `/finish` invocation, which is friction at exactly the wrong moment.

**Idempotent and self-healing**: this step runs on every rough-in run but is a no-op in repos that already have `/finish` provisioned. Only the first rough-in run against a given repo actually commits the slash command file.

### Step protocol

1. **Query the repo** via `get_file_contents` for `.claude/commands/finish.md`
2. **Compare against the bundled template** at `references/finish-command.md` (specifically the content below the `--- BEGIN TEMPLATE ---` marker, which is the canonical slash command content)
3. **Classify the result**:
   - **File does not exist**: this is the cold-start case. Proceed to the HITL gate to commit the template.
   - **File exists and matches the bundled template verbatim**: already provisioned. Skip the step, log *"`/finish` slash command already provisioned, skipping Step 5.5"* in the inheritance summary. No HITL gate fires.
   - **File exists but differs from the bundled template**: drift detected. Surface to the user (see Drift handling below).

### Drift handling

When `.claude/commands/finish.md` exists but its content doesn't match the bundled template, rough-in surfaces the drift by presenting the **diff** (not the full file on either side) with three explicit options:

> "Your repo's `.claude/commands/finish.md` differs from the cascade's current bundled template. Here's the diff (context: 3 lines each side):
>
> ```diff
> [unified diff output, changed sections only]
> ```
>
> This could mean (a) you've customized it, (b) a prior cascade version wrote an older template that's since been revised, or (c) someone edited it outside the cascade. Three options:
>
> **1. Leave the existing version in place** — keep your customization / prior revision.
> **2. Overwrite with the current bundled template** — pick up cascade revisions or reset to current default.
> **3. Abort and handle manually** — inspect further in your editor, re-run rough-in when ready.
>
> Which?"

Rough-in waits for explicit user choice. Do not auto-select any option. Do not proceed past Step 5.5 until the user picks. **Never dump both full files** — the diff is what's actionable.

**Never overwrite silently**: the user's existing `/finish` may be a deliberate customization or a prior revision that shouldn't be reverted. The drift discipline respects user edits by default.

### HITL gate (only fires in the cold-start case)

When the file does not exist, rough-in presents a **structured summary** of the template — not the full template content — and asks for explicit approval:

> "Your repo doesn't have `.claude/commands/finish.md` yet. Before I commit the next sub-sub-issues, I want to commit the `/finish` slash command that will execute them.
>
> **What this is**: `.claude/commands/finish.md` — the Claude Code slash command invoked by `/finish <N>` to pick up a rough-in sub-sub-issue, verify its dependencies, run plan mode against the Implementation section, execute the plan, and open a PR that closes the issue.
>
> **Provenance**: bundled speculative v0, drafted before real execution data existed. Will be revised as part of the automation work tracked by the deferred meta-issue framing surfaced for this workstream (the automation recommender pass).
>
> **What the template does, in seven steps**:
> 1. Read the issue body via GitHub CLI
> 2. Parse the body's section structure (Context, Implementation, Acceptance, Test plan, Done signal, Dependencies, PR contract)
> 3. Verify all listed dependencies are closed; refuse to proceed if any are open
> 4. Idempotency check — don't re-run against an already-closed issue
> 5. Hand the Implementation section to plan mode as the primary anchor
> 6. Execute the approved plan
> 7. Open a PR with `closes #<N>` and wait for merge
>
> **Scope boundaries**: `/finish` does NOT write specs, modify issue bodies, auto-create dependent issues, or bypass dependencies. If the spec is wrong, `/finish` aborts and surfaces — re-rough-in is rough-in's job, not `/finish`'s.
>
> Commit this template to `.claude/commands/finish.md`? Reply **yes** / **ok** / **approved** to commit, **show full** to see the complete ~150-line template inline before deciding, or tell me what to adjust."

The user's options at this gate:
1. **Approve sight-unseen** (`yes`, `ok`, `approved`): rough-in commits the bundled template verbatim. This is the common case and the default path.
2. **Request full inspection** (`show full`, `let me see it`, `dump it`): rough-in dumps the full template content inline, then re-presents the approval prompt. This preserves the full one-way-door inspection option for users who want it.
3. **Request adjustments**: surface the proposed changes, discuss, and update the commit plan accordingly. Adjustments at this layer are rare (the template is speculative v0) but the path exists.

**Rationale**: the one-way-door property requires the user to have the *opportunity* to inspect what's landing and to *explicitly approve*. It does not require a wall-of-text default presentation. The structured summary is informative enough to support sight-unseen acceptance (seven step descriptions plus scope boundaries plus provenance), and the full template is one request away for anyone who wants deeper inspection. This hits the one-way-door discipline without forcing ~150 lines of markdown through every first rough-in run.

**This gate runs in every rigor mode, including light mode.** The one-way-door property is too strong for the gate to collapse. Light mode collapses other gates but not this one — but "doesn't collapse" means "still fires and gets explicit approval", not "still dumps 150 lines."

### Atomic transition (independent of Step 6)

Step 5.5's commit is **its own atomic transition**, not bundled with Step 6's planning-backend commit. The provisioning and the sub-sub-issue creation are logically independent:

- The slash command file doesn't depend on sub-sub-issues existing
- The sub-sub-issues don't depend on the slash command file existing

Running them in separate transitions is cleaner than bundling: if the slash command commit fails or hangs, rough-in surfaces the Step 5.5 failure and asks the user how to proceed. The user can retry the slash command commit, skip it and proceed to Step 6 anyway (with a note that the first `/finish` invocation will need the file committed by hand), or abort the whole rough-in run. Step 6 can still complete successfully even if Step 5.5 fails, though in that case rough-in's final output will flag the missing slash command.

**Partial failure recovery**: same discipline as the planning-backend commit. Stop immediately, surface state, do not retry blindly, wait for user direction. See `references/planning-backend-commit.md` § Partial failure recovery for the full protocol (Step 5.5 borrows it verbatim).

### Profile-aware behavior

**github-only profile**: as described above. The slash command file is committed to the repo via GitHub MCP, same pattern as the cascade issue templates scaffold commits during its Stage 2.5.

**opinionated profile** (Linear): the slash command still lives in the GitHub repo (code is in GitHub even when planning is in Linear), so the step runs identically to github-only profile. The `/finish` command's behavior may differ slightly in opinionated profile — specifically, step 1 of the slash command would read the Linear Issue rather than the GitHub Issue — but that's a concern for the bundled template's content, not for Step 5.5's provisioning logic.

**markdown-only profile**: Step 5.5 is **skipped entirely**. There are no GitHub sub-sub-issues in markdown-only profile, so there's nothing for `/finish` to pick up, so the slash command isn't needed. Rough-in logs *"Markdown-only profile — Step 5.5 skipped (no sub-sub-issues to /finish)"* in the inheritance summary and moves to Step 6 (which in markdown-only profile is itself a markdown-only commit per `references/github-only-vs-opinionated.md`).

### Why this step belongs in rough-in, not in a separate skill

The alternative was to build a sixth in-chat skill (bootstrap-finish) scoped narrowly to writing the slash command. That was rejected in favor of this step for three reasons:

1. **Timing**: the slash command needs to exist *before* the first `/finish` invocation, which means *before* any rough-in's sub-sub-issues are ready to be executed. Rough-in is the natural place for "provision the thing that will read my output."
2. **Self-bootstrapping**: a step inside rough-in means a fresh cascade run (consultation → scaffold → blueprint → framing → rough-in in an empty repo) ends up with a fully working cascade including `/finish`, with no separate bootstrap step the user has to remember.
3. **Scope parallel to scaffold's Stage 2.5**: scaffold commits issue templates as workspace infrastructure; rough-in commits the slash command as execution infrastructure. Both are idempotent, both are small, both run as "provision the thing the next phase needs." The pattern is consistent.

The deferred meta-issue for the automation recommender pass will revise the **template content** in `references/finish-command.md`, not the step structure. Step 5.5's shape is stable; the template it provisions is what evolves.

## Step 6 — Planning-backend commit (atomic transition)

After all specs are drafted and approved, commit the sub-sub-issues to the planning backend atomically with the markdown event log update. Same discipline as blueprint and framing: capture every operation, execute planning ops first, commit markdown second, rollback on failure, handle partial failure by stopping and surfacing state to the user.

Detailed commit step, slug inheritance, profile-aware behavior, atomic transition pattern, partial failure recovery, and failure modes live in `references/planning-backend-commit.md`.

**Execution presentation**: during the atomic transition, surface per-step status as a running checklist (one line per operation, no full tool responses). On any failure, switch to full-expansion mode and dump the failing step's raw response alongside the captured partial state. See `references/planning-backend-commit.md` § Presentation pattern for execution for the full protocol.

**HITL gate (final)**: present the full set of sub-sub-issues that will be created (titles, Milestones they'll be assigned to via parent, labels, plan-mode prompts) alongside the markdown event log entry. Get explicit user approval before the atomic transition runs.

## Step 7 — Post-transition presentation and summary

After Step 6's atomic transition succeeds, rough-in produces a **completion summary** that hands off to `/finish` and closes the run. This is not optional — the summary is the skill's final deliverable and what the user reads immediately after the commit lands.

The completion summary has four required sections:

### 1. Commits

List of SHAs landed during this run with one-line summaries. Example:

> **Commits landed**:
> - `a3f2c1d` — Sub-sub-issues #48, #49 created and parented under #37
> - `b8e4907` — docs/cbk/README.md rough-in event entry for M1

If Step 5.5 fired its own commit in this run (the `/finish` provisioning case), that commit is listed here too. If Step 5.5 was a no-op or skipped, don't list it — only real commits land in this section.

### 2. Sub-sub-issues

Table of issues created with title, number, dependency, and capstone marker. Example:

> | # | Title | Depends on | Capstone |
> |---|---|---|---|
> | #48 | [regex-pack:F1:R1] Define Verifier trait per IC-1 | None | — |
> | #49 | [regex-pack:F1:R2] Implement RegexConstructVerifier with match-span detail | #48 | ✓ |

For re-rough-in runs, also list any superseded prior issues in a second table so the user can see what was replaced: *"Prior issues superseded during this run: #45, #46, #47."*

### 3. Handoff

The exact next command the user should run plus what they should expect to see. This is the "what happens next" guidance and it must be specific enough to act on without re-reading the skill docs.

Example:

> **Handoff to `/finish`**:
>
> Run `/finish 48` in Claude Code to pick up R1. The first thing `/finish` does is transition #48 from Ready to In Progress on the board, then it reads the issue body and hands the Implementation section to plan mode. You'll see plan mode's proposal before any code gets written — approve or iterate there.
>
> After #48 closes via merged PR, `/finish 49` picks up R2. R2 depends on R1, so don't run it before #48's PR merges.

For cases where the first R-issue has open dependencies (e.g., the milestone's first rough-in issue depends on a deferred meta-issue that's still open), the handoff explicitly flags this: *"#48 depends on #23 closing — do not run `/finish 48` until #23 is resolved. The soonest-runnable issue is none; resolve dependencies first."*

### 4. Loose threads

**Observations from this run that didn't belong in a HITL gate but are worth surfacing for later attention.** This is where "this should become a skill revision" observations live. Without a structured place for these, they get lost between runs, which is exactly the calibration data the cascade needs most.

Three subcategories:

**Observations that might become skill revisions** — one-line observations with pointers to where the revision would land:
> - *"Step 4's count text still mentions 'typical 3-7 range' in one place that I updated to 2-6 during this run but flagged as drift — see SKILL.md line 111"*
> - *"The CSV loader bad/good example in plan-mode-prompts.md could use a TypeScript companion for non-Rust projects — add to Pitfall 6 in the next revision pass"*

**Observations that are repo-level state for the user to track** — free-form:
> - *"#23 is still open and gates M3 — will need to run the automation recommender before rough-in on F3 can start"*
> - *"The IC-1 shape in frame-01.md is locked for this milestone but may need revisiting at M3 when the TUI layer starts consuming it"*

**Observations that are cascade-level drift to flag** — explicit "drift detected" labeling:
> - *"Drift detected: .github/ISSUE_TEMPLATE/cascade-rough-in.md's HTML comments don't reference the eight-property shape — scaffold's canonical needs updating"*
> - *"Drift detected: Step 5.5 presentation was verbose during this run, noted as feedback for the next revision pass"*

If there are no observations in a subcategory, omit that subcategory rather than writing "none." If there are no loose threads at all, write "No loose threads from this run" as a single line rather than a full section — the section's absence from a summary is itself a signal.

### HITL gate — none

Step 7 does NOT have a HITL gate. The summary is rough-in's final output, not a check-in. The user reads it, acts on the handoff, or pushes back if something is wrong — but the summary itself is not gated on approval because there's nothing left to commit at this point.

### Rigor mode behavior

Step 7 runs in every rigor mode. Light mode can trim the subsection prose (shorter handoff, one-line commits) but cannot skip any of the four sections. The loose threads section is especially load-bearing for cascade calibration and light mode must not collapse it.

## Profile-aware behavior

**github-only profile** (default, fully fleshed out): sub-sub-issues are created via the two-step `issue_write` + `sub_issue_write` pattern, parented under the framing sub-issue, assigned the `cascade-depth:roughed-in` label, initial board Status set to Ready via the board automation rules (not directly by the cascade, since the github MCP doesn't expose Projects v2 field operations).

**Linear+GitHub profile**: sub-sub-issues are created via single-step `mcp__linear__save_issue` with `parentId` referencing the framing F-issue, full labels, `blockedBy` chain to prior R-issues, and the same atomic transition discipline as github-only (capture-execute-rollback, partial failure recovery via stop-and-surface). The `parentId` field eliminates the orphan-sub-issue failure mode that github-only's two-step pattern can hit. Closes-keyword for downstream PRs uses `Closes <TEAM>-<N>` per project's `cbk-conventions.md`. Full MCP shapes in `references/github-only-vs-opinionated.md`.

**markdown-only profile**: the entire planning-backend commit step is skipped. Rough-in specs land as appended sections in the framing's markdown file OR as a new per-milestone rough-in markdown file at `docs/cbk/frame-NN-M<#>-rough-in.md`, depending on user preference (gate question: *"Want the rough-in specs in a new file or appended to frame-NN.md?"*). The slug + F-number + R-number naming convention still applies in the markdown headings so the hierarchy is grep-able.

Detailed per-profile behavior and edge cases live in `references/planning-backend-commit.md` and `references/github-only-vs-opinionated.md`.

## The capstone pattern

Most milestones end with a **capstone issue** — the last sub-sub-issue that integrates the prior work and proves the milestone's capability. It's structurally different from the earlier issues:

- **Earlier issues** typically define modules, implement functions, wire config — unit-level work
- **The capstone** typically tests end-to-end, runs the first real fixture, opens the smoke test, or writes the integration test that proves the milestone's capability is actually real

The capstone is often the last chance to catch "we built the pieces but they don't compose" before the next milestone inherits the assumption that the pieces work. Rough-in should explicitly identify the capstone during issue plan drafting and note it in the plan.

**Not every milestone has a capstone.** Spike milestones (research-only) don't have one — their "capstone" is a document or decision. Infrastructure milestones often don't either — the done signal is "the workbench works" which is verified by the next milestone's first real run. Vertical slice milestones almost always have one because the demonstrable capability needs proving.

## Handoff contract to finish

When rough-in commits, the handoff to finish (Claude Code's native execution phase, not a chat skill) is:

- **The sub-sub-issues** exist on the planning backend, each with a body containing a ready-to-implement spec including a Claude Code plan-mode prompt
- **The `/finish` slash command** exists on disk at `.claude/commands/finish.md` in the user's repo, committed by Step 5.5 during the first rough-in run against the repo
- **The naming convention** (`[<slug>:F<#>:R<#>]`) is grep-able across the board
- **The dependencies** within the milestone are explicit so `/finish` can verify them and pick up issues in the right order
- **The done signals** are concrete so `/finish` knows when each issue is complete

**What `/finish {issue_number}` does with this** (once Step 5.5 has committed the slash command file): reads the next unblocked rough-in spec from the board, verifies dependencies, runs Claude Code plan mode against the Implementation section, iterates with the user until the plan is approved, executes the plan, opens a PR that closes the issue with `closes #<N>`, the board automation moves the issue to Done on PR merge, and the parent framing sub-issue's sub-issue progress field ticks forward.

**What rough-in must not pass to finish**: implementation code (that's finish's job), decisions that finish shouldn't be making (those belong in rough-in's HITL gates), or vague acceptance criteria that force finish to guess at "done."

**Slash command revision path**: the initial `.claude/commands/finish.md` that Step 5.5 provisions is a speculation-based starting point, drafted before real execution data existed. It will be revised as part of the automation recommender pass that framing typically surfaces as a deferred meta-issue for the first workstream. The revision updates `references/finish-command.md` in this skill bundle; future rough-in runs against new repos pick up the revised version, and existing repos either manually update their committed copy or wait for Step 5.5's drift detection to propose an update. See `references/handoff-to-finish.md` for the full revision path and timing guidance.

## HITL gates summary

- **Full mode — up to nine gates**: one per step step (inheritance + meta-check, milestone selection, research depth, research findings, issue plan, individual specs, batch review, Step 5.5 slash command provisioning [only in cold-start case], final pre-commit)
- **Standard mode — up to five gates**: inheritance + meta-check combined, research depth + findings combined, issue plan, Step 5.5 slash command provisioning [only in cold-start case], final pre-commit
- **Light mode — up to two gates**: combined up-front confirmation, Step 5.5 slash command provisioning [only in cold-start case] and final pre-commit combined

The deferred meta-issues pre-flight check and the final pre-commit gate run in every mode. **Step 5.5's provisioning gate also cannot collapse** when it fires (cold-start case), because the one-way-door property of committing a slash command file future Claude Code sessions will invoke is too strong. In the already-provisioned case, Step 5.5 is a silent no-op with no gate.

## Failure modes to defend against

- **Rough-in multiple milestones at once** — most common temptation. Resist. Rough-in one, build through finish, then rough-in the next.
- **Skipping the pre-flight checks** — light mode's biggest risk. The check is mandatory in every rigor mode; the sub-sub-issue creation is too expensive to unwind if a meta-issue should have blocked it.
- **Drafting individual specs before the issue plan is approved** — wastes work when the plan is wrong. Always approve the plan first.
- **Vague acceptance criteria** — "the tests pass" is not acceptance; "`cargo run -- X` produces output Y" is. Vague criteria force finish to guess.
- **Plan-mode prompts that require external context finish doesn't have** — prompts must be self-contained. If a prompt says "follow the pattern from the previous issue," finish has to chase down which previous issue, which is friction that erodes trust in the cascade.
- **Inventing acceptance signals or plan-mode prompts** instead of deriving them from the framing milestone's acceptance signal and the cascade's existing conventions
- **Partial-state failures during the atomic transition** — handled by the partial failure recovery protocol in `references/planning-backend-commit.md`. Never retry blindly, never auto-rollback on hang, always surface state to the user.
- **Slug drift from framing sub-issue** — the slug must be inherited from the parent's title, never re-derived. Drift here breaks the grep-ability of the hierarchy across all cascade artifacts.
- **Overwriting prior rough-in specs instead of creating new ones on re-rough-in** — re-rough-in creates new sub-sub-issues with higher R-numbers and supersedes the prior ones via close + label. Never overwrites.
- **Missing Pre-flight checks table in the framing** — if the framing pre-dates this pattern, surface as framing drift and ask the user to either confirm no meta-issues exist or loop back to framing.
- **Silently overwriting a user-customized `/finish` in Step 5.5** — if the repo already has `.claude/commands/finish.md` with content that differs from the bundled template, the user may have customized it deliberately. Defense: Step 5.5's drift detection surfaces the divergence with three explicit options (leave in place / overwrite / abort) and waits for the user to pick. Never auto-overwrite.
- **Committing sub-sub-issues before the slash command is in place (or detected as intentionally absent)** — if Step 5.5 fails and Step 6 proceeds anyway, the user ends up with sub-sub-issues but no tool to execute them. Defense: Step 5.5 runs before Step 6, and Step 6's final pre-commit gate surfaces any unresolved Step 5.5 state (slash command missing, drift unresolved, commit failed) so the user can decide whether to proceed with the known gap or abort.
- **Template drift between bundle and repo after cascade revisions** — the cascade's bundled `references/finish-command.md` gets updated (via the automation recommender pass or other revisions) but existing repos still have the old committed version. Defense: Step 5.5's drift detection catches this on the next rough-in run and offers to update, with the user's existing version preserved if they decline.

Detailed failure mode analysis with recovery patterns lives in `references/failure-modes.md`.

## Solo vs. team notes

**Solo**: rough-in is typically run by the same person who framed the milestone. HITL gates are lighter because the context is fresh. Standard or light mode is the usual pick.

**Team**: rough-in produces specs that other team members (or Claude Code, which is a kind of team member) will execute. Acceptance criteria and plan-mode prompts have to be self-contained in a way solo runs can sometimes get away with. Full mode is the usual pick, and the final pre-commit gate gets extra scrutiny because the specs are contracts with execution.

## Reference files

- `references/inheritance.md` — how to read the four required inputs (brief, scaffold, blueprint, frame-NN.md) + the parent framing sub-issue + foundation docs, verbatim summary template, pre-flight checks protocol in detail
- `references/research-phase.md` — implementation patterns research, open-question resolution, depth-as-user-signal pattern (shared discipline with framing)
- `references/templates/rough-in-spec-template.md` — the full sub-sub-issue spec template with worked example
- `references/plan-mode-prompts.md` — Claude Code plan-mode prompt patterns, what makes a prompt self-contained, common pitfalls
- `references/planning-backend-commit.md` — atomic transition pattern for rough-in, two-step `issue_write` + `sub_issue_write`, slug inheritance from parent, partial failure recovery, profile-aware behavior
- `references/finish-command.md` — bundled template for `.claude/commands/finish.md`, committed by Step 5.5 during the first rough-in run in a repo. Contains a wrapper explaining the template's purpose followed by the canonical slash command content below a `--- BEGIN TEMPLATE ---` marker.
- `references/hitl-question-bank.md` — categorized questions for inheritance, milestone selection, research, issue plan review, spec drafting, final pre-commit
- `references/github-only-vs-opinionated.md` — profile-aware behavior differences (including markdown-only handling)
- `references/failure-modes.md` — rough-in-specific failure modes with examples and recovery patterns
- `references/handoff-to-finish.md` — the handoff contract to Claude Code's finish phase, the revision path for the slash command template, timing guidance for the automation recommender pass
- `references/test_cases.md` — realistic test prompts (canonical first rough-in / subsequent rough-in / markdown-only / deferred meta-issue blocker hit / partial failure recovery) with success/failure criteria
- `references/backends.md` — the cascade meta-doc, bundled with this skill for self-contained reference

Read references on demand, not all at once. SKILL.md is a routing document; operational content lives in the references.
