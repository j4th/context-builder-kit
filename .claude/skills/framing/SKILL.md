---
name: framing
description: Decompose a Linear project into sequenced milestones with rough issues. Use this skill when the user wants to break a project into milestones, plan implementation for a project, sequence build order, or move from planning into execution. Trigger when the user says 'plan this project', 'frame this project', 'what are the milestones', 'break this project down', 'how should I sequence this work', 'I have my plan, what's next', references a specific project by name, or references the cascade at the framing level. Also trigger when the user picks a workstream from blueprint and wants to go deeper. **Use this skill even when the user doesn't explicitly say "framing" — the trigger is the moment of "I have a workstream from blueprint and need real milestones I can build against", not the vocabulary.** Phase 4 of the cascade. One project at a time, just-in-time, never all at once. Produces a numbered cascade-event file (frame-NN.md) plus updates the chronological framing index.
---

# Framing

Phase 4 of the six-phase AI-assisted development cascade (analogous to Spec Kit's `Plan` and Kiro's `Design` phase). Takes one workstream from `docs/cbk/blueprint.md` § "Workstreams" and produces a refined project specification with sequenced milestones, each one a demonstrable capability the user can see, run, or test against. The output is a numbered cascade-event file (`docs/cbk/frame-NN.md` for projects using flat layout, or `docs/cbk/framings/frame-NN.md` for nested — see project's `.claude/rules/cbk-conventions.md`) plus an entry in the chronological cascade-events index at `docs/cbk/README.md`.

Framing is one-project-at-a-time, just-in-time, **by design**. The research is unambiguous on this — Beck, Böckeler, Anthropic, and the Thoughtworks Radar all warn against framing every project up front because the further-out projects get framed with stale information. Framing v0.4's bash project today is wasted work because you'll learn things from v0.1/v0.2/v0.3 that should change v0.4's design. Frame the next project, build it, then frame the project after that. The cascade is a funnel, not a waterfall.

**Target executor (transitive)**: framing's output feeds rough-in, which produces specs for Claude Code plan mode. Framing doesn't write plan-mode prompts directly, but its rough-issues list and its milestone boundaries are the seeds that rough-in shapes into Implementation sections. That transitivity affects framing in two specific ways: **rough-issues are intents, not prescriptions** (they describe *what* each rough-in R-issue should accomplish, not *how* to implement it — plan mode is a decomposition engine and even the rough-in author shouldn't pre-decompose into implementation sequences, let alone framing), and **milestones are demonstrable capabilities, not decomposed atoms** (each milestone is a verb the system can do, tested with the "can I show this to someone?" question, not a noun describing what was built). See [Anthropic's Claude Code best practices](https://code.claude.com/docs/en/best-practices) for the underlying framing: *"Separate research and planning from implementation to avoid solving the wrong problem. Letting Claude jump straight to coding can produce code that solves the wrong problem."* Over-prescriptive rough-issues at framing time propagate downstream as over-prescriptive Implementation sections at rough-in time, and over-atomized milestones propagate downstream as over-atomized R-issue lists. Both failures of the same underlying miscalibration show up at framing's layer first.

## Cascade events, not project slots

Each framing produces a **numbered** file: `frame-01.md` is the first framing the user did, `frame-02.md` is the second, and so on. The number is the framing's identity in the cascade timeline, not the project's identity.

Default flat layout (recommended; matches the ADR pattern for sequential, append-only cascade events with single-document artifacts):

```
docs/cbk/
├── README.md           ← chronological cascade-events index with status column
├── problem_brief.md    ← from consultation
├── scaffold.md         ← from scaffold
├── blueprint.md        ← from blueprint
├── frame-01.md         ← first framing (e.g. regex project)
├── frame-02.md         ← second framing (e.g. tmux project, after regex was built)
└── frame-NN.md         ← etc.
```

Nested layout (alternative; for projects whose framing events produce multi-file bundles):

```
docs/cbk/
├── README.md
├── ...prior phase artifacts...
└── framings/
    ├── frame-01/
    │   ├── frame-01.md
    │   └── ...sibling docs...
    └── frame-02/
        └── ...
```

The project picks layout via `.claude/rules/cbk-conventions.md`; framing reads that file at session start to determine the path shape. **For projects without an explicit conventions file, default to flat.**

This matters because **framings are events in time, not slots for projects**. If the user re-frames the regex project after some code is built (because they learned something that should change the milestone breakdown), the new framing becomes `frame-04.md` — both the original and the new one stay in the cascade history. The `docs/cbk/README.md` index tracks the timeline with a status column (Active / Completed / Superseded by frame-NN / Abandoned), and **rough-in always picks up the highest-numbered Active framing as "what's next."**

The user doesn't read these files day-to-day. The actual work product lives elsewhere in the repo (code, docs, tests). The `docs/cbk/` namespace is for cascade consumption — answering "what does the next phase need to know" — and the highest-numbered framing is always the answer to "what's next."

## Required inputs and how to read them

Framing requires three prior-phase artifacts as inputs, and optionally any prior framings:

- `docs/cbk/problem_brief.md` — from consultation
- `docs/cbk/scaffold.md` — from scaffold
- `docs/cbk/blueprint.md` — from blueprint, especially § "Workstreams"
- `docs/cbk/frame-NN.md` (any prior framings, if this is not frame-01 — flat layout default; nested at `docs/cbk/framings/frame-NN.md` if project's `cbk-conventions.md` configured nested)
- `docs/cbk/README.md` (the chronological cascade-events index, if it exists)

If any of the first three are missing, **do not silently proceed**. Either run the missing phase first, accept an uploaded file or verbal equivalent (and flag that the input is informal), or — if the user is starting framing cold without the prior phases — ask what's available and adapt.

**Reading the inputs**. If the repo is connected via GitHub MCP, read all relevant files via the MCP. If not, ask the user to upload them or paste them. Do not proceed until you have read the three required inputs in full plus any prior framings — framing depends on inheriting from them, and skimming or guessing at their content is the most common framing failure mode.

**The "Builds on" inheritance is unique to framing.** Unlike consultation/scaffold/blueprint (which inherit from a fixed set of prior phases), framing also inherits from any prior cascade events at its own level. Frame-03 reads frame-01 and frame-02 to know which interface commitments already exist and which milestones already shipped. This is what makes the cascade-event model work — framings build on each other, not just on the phases above.

Detailed inheritance discipline lives in `references/inheritance.md`.

## Three rigor modes — light, standard, full

Framing's full flow (inheritance → project selection → research phase → refined definition → milestones, with five HITL gates) is the **full mode**, not a requirement. There are three rigor modes:

**Full mode** — five HITL gates (one per step). Includes the development tooling research phase (MCP servers + Claude Code plugins specific to this project). Best for: greenfield projects, projects with significant architectural uncertainty, projects with multiple sibling dependencies, anyone who wants every decision reviewed before commit.

**Standard mode** — three HITL gates batched at meaningful boundaries: (1) after inheritance + project selection combined, (2) after refined definition + milestones combined, (3) final review of frame-NN.md before commit. Skips the development tooling research phase by default unless the user asks. Best for: users who have done the cascade once, projects with established patterns, building-on-existing-code projects where infrastructure is already in place.

**Light mode** — one combined up-front confirmation listing what framing will produce, then run-to-completion until presentation. Best for: users who say *"just give me the milestones"*, *"keep it minimal"*, *"I know what I'm doing"*, or who are framing a small, well-understood project where the milestones are nearly self-evident.

**Detect-then-confirm**: at session start, propose a mode in one sentence based on the user's opening message. *"Sounds like you've got a clear sense of how this project should break down — I'll run in **standard mode**, three gates total. Say 'full' for per-step gates or 'light' for one combined confirmation."* Let the user override in one word. If their opening message gives no signal, default to **standard mode** for first-time users since per-step review is heavy and most users don't need it on the first pass; offer to switch to **full mode** if they want every decision reviewed.

The mode dial can be tuned mid-session — if the user says *"actually let's go faster from here"* during full mode, switch to standard for the remaining steps without restarting.

What framing should *not* skip even in light mode: **reading the inputs in full** (skipping inheritance is the failure mode light mode is most likely to cause), **at least one explicit milestone with a demonstrable capability** (otherwise the framing has no concrete output), and **the frame-NN.md cascade event file** (the cascade's transition mechanism for this phase).

## Step 1 — Inheritance check

The first step always. Read all required inputs in full, present a verbatim inheritance summary, and gate before proceeding.

The inheritance summary must quote the brief's relevant content, the scaffold's quality bar, the blueprint's relevant workstream entry, and any prior framings' interface commitments verbatim. Do not paraphrase — paraphrasing is the failure mode.

Detailed inheritance discipline and the summary template live in `references/inheritance.md`.

**HITL gate**: present the inheritance summary inline, get explicit user approval before moving to project selection.

## Step 2 — Project selection from blueprint

Pick which workstream from blueprint to frame. There are three patterns:

**A) Named explicitly** — *"Frame the regex project"* → look it up in `docs/cbk/blueprint.md` § "Workstreams", confirm the row, proceed.

**B) Picked from sequence** — *"Frame the next one"* → read prior framings to determine which projects have been framed, identify the next unframed project from blueprint's workstreams table, confirm with user.

**C) Re-framing an already-framed project** — *"Re-frame the regex project, the milestone shape didn't survive contact with the code"* → read the prior framing of that project, treat the new framing as a deliberate cascade event that supersedes the prior one (without overwriting it), proceed. The prior framing stays in the cascade history.

Once the project is selected, **link back to the blueprint workstream explicitly**. The frame-NN.md header says: *"This frames the **\<project name\>** workstream from `docs/cbk/blueprint.md` § 'Workstreams', row N."*

Also identify the framing number: read `docs/cbk/README.md` (if it exists) to find the highest existing frame number, increment, and use that as this framing's number. If no framings exist, this is `frame-01`.

**HITL gate**: confirm the project selection and the framing number with the user.

## Step 3 — Research phase

Resolve genuine uncertainty before producing milestones. **Depth is a user signal, not a framing judgment** — framing surfaces the relevant signals (greenfield vs. building-on-existing, prior framings to inherit from, deferred decisions from blueprint, user expertise) and proposes a depth in one sentence, then lets the user confirm or override. Same shape as the rigor dial. **Never silently scale down research** — the user can't tell from the milestone output whether framing did a deep or shallow pass, so silent shortcuts erode trust.

When framing hits token pressure, surface it explicitly and give the user the choice between finishing partial work, skimming to fit, or continuing in a follow-up message. **Never silently produce partial work and present it as complete.**

Two research sub-tracks, both running in every rigor mode at the depth the user confirmed:

**3a. Implementation patterns** — when the project is greenfield or entering new technical territory, search for reference implementations, library tradeoffs, and established patterns. When the architecture docs already specify the approach, validate currency and surface gotchas. Cite from `methodology_register.md` when the cascade's shared knowledge has an answer for the pattern question (vertical slicing, walking skeleton, tracer bullets, spike solutions, YAGNI). If a prior framing established a pattern this project will inherit, surface the inheritance explicitly — never silently reuse.

**3c. Resolve open technical questions** — library choices that affect milestone boundaries, pattern choices that affect build sequence, interface decisions that affect downstream consumers, methodology-specific decisions that flow from blueprint's selection but get instantiated here.

**What framing does NOT research**: MCP server selection, Claude Code plugin selection, stack decisions, methodology selection, CI gate decisions. All of those belong in **blueprint** — framing inherits them and treats them as constraints. If framing notices the project would benefit from tooling not in the current setup, flag it as a Suggested foundation doc update in Step 4, never silently add it. The boundary between framing's project-level concerns and blueprint's workspace-level concerns is deliberate and documented in `backends.md`.

Detailed depth-proposal patterns, presentation templates, and the failure modes specific to this step live in `references/research-phase.md`.

**HITL gate (full mode only)**: present research findings, land on technical approach with the user before producing the refined definition.

## Step 4 — Refined project definition

Produce the refined project definition. This is the substantive output of framing — it captures everything learned in steps 1-3 and lands the technical approach in a structured form.

The refined definition has these sections (template in `references/templates/frame-output-template.md`):

1. **Header** — links to the blueprint workstream being expanded, names the framing number, lists "builds on" prior framings if any
2. **Purpose** — one paragraph, refined from the rough description
3. **Approach** — technical approach landed on in the research phase
4. **Components** — what gets built, with one-line technical descriptions and which milestone builds each
5. **Boundaries** — in scope, out of scope, agreements with sibling projects (i.e. with prior framings)
6. **Interface Commitments** — table: what interface, which downstream consumer, stable by which milestone, brief shape
7. **Key Constraints** — architectural, integration, forward-compatibility, performance, structural decisions
8. **Suggested foundation doc updates** — flagged as suggestions only, never auto-applied
9. **Open questions** — items deferred to rough-in or the next framing

The Interface Commitments table is the most valuable single output — it's the contract that enables future framings to know what they can build against, and it makes cross-framing dependencies explicit and milestone-dated. Preserve it as a first-class output regardless of rigor mode.

**HITL gate**: present the refined definition inline, iterate until the user approves.

## Step 5 — Milestones with rough issues

Decompose the project into sequenced milestones, each one a **demonstrable capability** — something the system can do that it couldn't before. Not "module X exists" but "the system can now [verb]."

Each milestone has:

- **Sequence number and name** (e.g., "M1: Regex pure-function verifier")
- **Capability** (one sentence: "After this, the system can verify regex lessons against expected matches")
- **Rough issues** (title + one-sentence intent each — these become inputs to rough-in, the next phase)
- **Internal dependencies** (which milestones gate which)
- **Issue type flags** (which are Claude-Code-implementable vs user-managed manual issues)

### Milestone count: as many as the workstream genuinely has demonstrable capabilities

**The honest test isn't the count, it's the demonstrable-capability test.** Each milestone should pass one specific question: *"Can I show this to someone and have them see a meaningful change in what the system can do?"* If yes, it's a milestone. If the answer is *"well, after this the code will be slightly better factored"* or *"after this we'll have added the next layer of the data model,"* it's not a milestone — it's a step inside one.

Typical workstreams produce **3-6 milestones**, but that range is a secondary signal, not a prescription. A small, tightly-scoped workstream might legitimately have 2 milestones (the walking-skeleton milestone and the completion milestone). A large, multi-surface workstream might legitimately have 6-7 milestones spanning infrastructure, feature slices, integration, and hardening. Outside the 2-7 range signals a problem in the same spirit as rough-in's 2-6 range: **1 milestone** usually means the workstream should be folded into a sibling (or is legitimately atomic, in which case note the departure and proceed), **8+ milestones** usually means the workstream is too big and should be split across two framings (escalate back to blueprint).

**Do not decompose milestones into implementation atoms just to hit a count.** A milestone that reads "After this, the system can run one lesson end-to-end" is stronger than five milestones that read "After this, we'll have the loader" / "After this, we'll have the verifier" / "After this, we'll have the CLI entry point" / etc. — the first is a demonstrable capability, the rest are implementation steps that happen *inside* a milestone. The failure mode to watch for: if adjacent milestones in your draft can't each pass the "can I show this to someone?" test, they're probably a single milestone pre-decomposed into steps.

### Rough issues: intents that rough-in will shape into coherent review units, not prescriptions

The **rough issues** list for each milestone is the seed that rough-in's Step 4 will read, inherit from, and shape into coherent review units per rough-in's own discipline. Framing does not pre-decide rough-in's R-issue boundaries — that's rough-in's job, done just-in-time with actual implementation context. Framing's job is to name the **intents** that rough-in will organize.

**Each rough issue is an intent, not a prescription.** The shape should be a one-sentence statement of *what the sub-sub-issue exists to do*, not *how it should be implemented*. Compare:

- ✅ *"Define the Verifier trait with associated types for Input, Context, Error per IC-1 from this framing"* — intent, points at the IC that locks the shape
- ❌ *"Create `crates/core-engine/src/verifier.rs` with `pub trait Verifier { type Input; type Context; type Error; fn verify(...) -> Result<(), Self::Error>; }`"* — prescription, inlines a signature rough-in should either derive from IC-1 or leave to plan mode

The intent phrasing matters because rough-in's Implementation sections (the thing handed to Claude Code plan mode) inherit their shape from framing's rough issues. If framing produces prescriptive rough issues, rough-in naturally inherits that prescriptive framing and produces over-specified Implementation sections. If framing produces intent-shaped rough issues, rough-in has room to apply its own eight-properties discipline without fighting against framing's seeds. See rough-in's `references/plan-mode-prompts.md` § Property 8 for the downstream discipline; framing's job is to set that discipline up for success by starting with intents.

**Rough issue count per milestone**: the same "review-unit discipline" that rough-in applies to R-issues applies (transitively) to framing's rough issues. Rough-in will ultimately produce **2-6 R-issues per milestone** for Claude-Code-executed workflows (see rough-in's Step 4). Framing's rough-issue list should therefore land in roughly the same range — 2-6 intents per milestone is typical. If framing's draft has 8+ rough issues for a milestone, that's a signal the milestone is too big (split it) or framing is pre-decomposing work that rough-in will naturally collapse (merge adjacent intents). If framing's draft has 1 rough issue for a milestone, either the milestone is truly atomic (legitimate, note and proceed) or the milestone is too small (fold into a sibling).

The range is secondary to the test: **each rough issue should be a coherent implementation intent that a rough-in R-issue could reasonably correspond to** — not necessarily 1:1, because rough-in may merge or split based on real implementation context, but in the same neighborhood of granularity.

### Milestone shape and pattern

Milestone shape is **flexible by default with vertical slicing as the recommended pattern** (the methodology register's recommendation):

- **Vertical slices** (default) — each milestone delivers end-to-end functionality for a subset of the project. Aligns with Linear Method's project methodology.
- **Spike milestones** — research-only checkpoints with no shippable output. Use sparingly, only when blueprint flagged a real research risk.
- **Infrastructure milestones** — CI, build, tooling work that enables later vertical slices. Greenfield projects often have one of these as M1.

If blueprint picked a specific methodology (Shape Up, Kanban, Scrum), honor it — Shape Up's appetite-based approach naturally produces vertical slices that fit a fixed appetite, Kanban's continuous flow produces continuously-sized milestones, Scrum's sprints produce sprint-bounded milestones.

Detailed milestone-shape guidance and the milestone template live in `references/templates/milestone-template.md`.

### Example excerpt (what one milestone looks like in practice)

To make the output shape concrete: here's what one milestone spec looks like, taken from a real cascade run on a CLI-tutorial project whose first workstream was a "regex pack" of lessons. Note the specificity — the capability is a verb the system can do, the rough issues are concrete enough for rough-in to decompose, and the dependency is explicit.

**Input fragment** (user during milestone HITL):
> "M1 should be the smallest thing that proves the verifier trait works. Just enough to pass one regex lesson end-to-end. Nothing fancy."

**Output fragment** (resulting frame-01.md milestone excerpt):
```markdown
### M1: Pure-function verifier proves the trait

**Capability**: After this, the system can run one TOML-defined regex lesson, verify the user's input against the lesson's expected matches, and report pass/fail with a hint on failure.

**Depends on**: Nothing — first milestone

**Rough issues** (5 total, all Claude-Code-implementable):
1. Define `Verifier` trait with `Input`, `Context`, `Error` associated types and `verify` method
2. Implement `RegexVerifier` as the first concrete impl, using the `regex` crate
3. Define `Lesson` struct with TOML deserialization for `prompt`, `expected_matches`, `foils`
4. Wire up minimal CLI entry point that loads one lesson, prompts the user, runs the verifier, prints result
5. Author the first regex lesson as a TOML fixture and a passing end-to-end test

**Issue notes**: All five issues are Claude-Code-implementable — no user-managed setup required because mise + cargo are already configured from scaffold. M1's "done" signal is `cargo run -- regex/lesson_01.toml` succeeds and a smoke test passes in CI.
```

The full milestone template lives in `references/templates/milestone-template.md`. The example above just shows what one milestone feels like in practice.

**HITL gate**: present the milestone list with the narrative arc (*"After M1 you can X. After M2 you can Y. By MN the project delivers Z."*). Iterate until the user approves.

Surface the structural tests explicitly in the gate:
- *"Each milestone here is a demonstrable capability — for M[i], the specific 'show this to someone' moment is [one-sentence demo]. Does each milestone pass that test, or are any of them really implementation steps that should be folded into a sibling?"*
- *"Each rough issue is phrased as an intent, not a prescription — they name *what* each sub-sub-issue should accomplish and leave the *how* to rough-in and plan mode. Anything in the list that feels like it's pre-deciding an implementation detail rough-in should decide?"*
- *"Rough-issue counts per milestone: [list them]. Rough-in will typically produce 2-6 R-issues per milestone for Claude-Code-executed workflows, so framing's intent list landing in that neighborhood is a good sign. If any milestone has 8+ rough issues, the milestone might be too big — want me to escalate back to splitting?"*

## Producing the frame-NN.md file

After step 5, framing produces the actual `docs/cbk/frame-NN.md` (or `docs/cbk/framings/frame-NN.md` per project's `cbk-conventions.md` layout) by combining the refined definition (step 4 output) and the milestones (step 5 output) into the single cascade-event file. The template is in `references/templates/frame-output-template.md`.

Append a row to `docs/cbk/README.md` (the chronological cascade-events index) with the framing number, the workstream framed, the date, and the status (`Active`).

Commit both files via GitHub MCP. Fall back to downloadable artifacts if MCP isn't available. The frame-NN.md file is the cascade artifact for this phase and is what rough-in will read.

**HITL gate (final)**: present the frame-NN.md file inline, get explicit user approval before commit.

## Phase exit checklist

Auto-checkable list that fires after the final HITL gate, before declaring framing complete. Not a gate (no user approval); a safety surface (skill stops if any item fails). Per cbk-conventions.md § Trip-wire pattern:

- [ ] `frame-NN.md` content includes all required sections: Purpose, Approach, Components, Boundaries, Interface Commitments, **Pre-flight checks** table (with empty-default `"No pre-flight blockers from this framing"` if none), Open questions, Milestones (each with `[F<N>.AC<M>]` trace IDs in acceptance criteria)
- [ ] Frame-NN's number was correctly identified (highest existing in `docs/cbk/README.md` + 1)
- [ ] Workstream parent issue exists (Linear+GitHub profile only) and matches the workstream slug
- [ ] No prior F-issue exists for this milestone (idempotency)
- [ ] Markdown commit and (Linear+GitHub) F-issue creation atomic transition succeeded, or partial state surfaced cleanly
- [ ] `docs/cbk/README.md` updated with new entry + status `Active`

## Profile-aware behavior

**GitHub-only profile**: `frame-NN.md` lives entirely as markdown in `docs/cbk/`. No Linear involvement. GitHub repo milestones may be created via GitHub MCP in the user's repo (one milestone per framing milestone) if the user wants tracking, but this is optional and not the source of truth — the markdown file is.

**Linear+GitHub profile**: framing produces both the markdown artifact AND a Linear F-issue per milestone. The markdown is the canonical record (audit trail, timeline, interface commitments); Linear is the planning surface (assignment, status flow, parent/sub-issue rollup, the operator's daily board). Concrete operations:
- Read the workstream parent issue via `mcp__linear__get_issue` (parent must exist before framing — created by blueprint at workstream-definition time).
- Idempotency check via `mcp__linear__list_issues` with `parentId` — abort if F-issues already exist for this milestone unless the user opts to resume.
- After the final HITL gate, atomic transition: commit `frame-NN.md` + `docs/cbk/README.md` index update via GitHub MCP, then create one Linear F-issue per milestone via `mcp__linear__save_issue` with `parentId` (workstream parent), `team`, `title` (`[<workstream-slug>:F<#>] <intent>`), `description` (capability + AC with `[F<N>.AC<M>]` trace IDs + reference back to frame-NN.md), `labels` (`workstream:<slug>` + `cascade-depth:framed` + appetite label), `assignee`, and empty `blockedBy`.
- On partial failure (markdown committed but Linear creation failed, or vice versa), surface the partial state — do not retry blindly.

Detailed profile-aware behavior including failure modes lives in `references/github-only-vs-opinionated.md`. Project-specific identifiers (Linear team key, workstream slugs, label conventions) live in the project's `.claude/rules/cbk-conventions.md`.

## HITL gates summary

Framing has five HITL gates in **full mode**, three in **standard mode**, and one in **light mode**.

**Full mode — five gates** (per-step review):

1. **After inheritance check** — user confirms the inheritance summary is accurate
2. **After project selection** — user confirms which project is being framed and the framing number
3. **After research phase** — user lands on technical approach and (in full mode) reviews MCP/plugin recommendations
4. **After refined definition** — user reviews and approves the refined project definition
5. **After milestones** — user reviews the milestone list with narrative arc

**Standard mode — three gates** (step-boundary review):

1. **After inheritance + project selection combined** — user confirms inheritance and project selection in one batched gate
2. **After refined definition + milestones combined** — user reviews the refined definition with milestones together
3. **After frame-NN.md is drafted** — final review before commit

**Light mode — one gate**: a single up-front confirmation listing what framing will produce, then run-to-completion until the frame-NN.md file is presented for final review.

Each gate is an explicit "approve to proceed" moment. Iterate within a gate as many times as needed. The mode dial can be tuned mid-session.

## Handoff contract to rough-in

When framing is complete, rough-in inherits:

- **The latest frame-NN.md** at `docs/cbk/frame-NN.md` (flat) or `docs/cbk/framings/frame-NN.md` (nested, per project's `cbk-conventions.md`) — containing refined definition, milestones, rough issues, interface commitments, **and the Pre-flight checks table**
- **The cascade-events index** at `docs/cbk/README.md` — for finding the latest framing (highest-numbered Active row)
- **All prior framings** at `docs/cbk/frame-NN.md` — for cross-framing interface commitments
- **Planning-backend issues created by framing** (in Linear+GitHub profile) — F-level sub-issues (labeled `cascade-depth:framed`) and any deferred meta-issues (labeled `cascade-depth:framed` + `meta`), all parented under the workstream parent issue

**What rough-in does with this**: reads the latest frame-NN.md (the highest-numbered one), picks one milestone from it, decomposes that milestone's rough issues into ready-to-implement issues (with acceptance criteria, technical detail, and Claude Code plan-mode prompts).

**Mandatory deferred meta-issues check**: before decomposing milestone M_n, rough-in MUST read the Pre-flight checks table from the latest frame-NN.md and verify any meta-issue with `Blocks: M_n start` is resolved (closed) or explicitly cleared (the user confirms it's no longer blocking). If unresolved meta-issues block M_n, **rough-in stops and surfaces the gap** rather than proceeding. The check obligation lives on rough-in, but the table existing in frame-NN.md is framing's responsibility — empty tables explicitly say "No deferred meta-issues from this framing" so rough-in knows the table was considered, not skipped.

**What framing must not pass to rough-in**: implementation code, detailed issue specs (those are rough-in's job), production deployment decisions (those happen later still), test specifications below the milestone-acceptance level.

**The latest framing is always the answer to "what's next."** Rough-in doesn't need to know about prior framings except as historical context for interface commitments — it always operates on the highest-numbered framing.

## Failure modes to defend against

- **Framing all workstreams at once** — most common temptation, especially when the user has a clean blueprint with many workstreams. Resist. Frame one, build, then frame the next.
- **Skipping inheritance** — light mode's biggest risk. Even in light mode, framing must read all required inputs in full.
- **Inventing milestones that don't match the methodology blueprint picked** — if blueprint chose Shape Up appetite-based, framing must respect appetite as the constraint, not impose Scrum-style sprints. Honor the methodology selection.
- **Auto-updating foundation docs without HITL approval** — framing flags suggested updates as a section in frame-NN.md, never silently mutates blueprint's foundation docs. The user reviews and applies updates manually.
- **Treating interface commitments as informal cross-references** — they're a first-class output. Every framing should produce an Interface Commitments table even if it's empty (which is itself signal — "this project has no downstream consumers, build it however").
- **Overwriting prior framings instead of creating new ones** — re-framing the same project produces a new `frame-NN.md` file with the next sequence number. The prior framing stays in the cascade history. Never overwrite.
- **Producing milestones without demonstrable capabilities** — "M1: scaffolding" is wrong. "M1: the system can run one regex lesson end-to-end" is right. Every milestone is a verb the system can do, not a noun describing what was built.
- **Skipping the cascade-events index update** — `docs/cbk/README.md` is the chronological log that tells future framings (and rough-in) where in the cascade we are. Forgetting to append to it makes the cascade timeline invisible.

Detailed failure mode analysis with recovery patterns lives in `references/failure-modes.md`.

## Solo vs. team notes

**Solo**: framing is largely a working session with the user's future self. Interface commitments still matter (they're contracts with future framings) but the ceremony around them is lighter. CONTRIBUTING.md updates are typically deferred. Rigor mode often defaults to standard or light.

**Team**: framing produces a contract that other team members will read. Interface Commitments are heavyweight — they say what other people can rely on. Methodology selection from blueprint is a team agreement that framing must respect. Rigor mode often defaults to full or standard.

## Project-level overrides

Project-specific overrides (workstream slugs, Linear team key, branch-naming convention, layout choice flat-vs-nested, project-specific operational evidence) live in the project's `.claude/rules/cbk-conventions.md`. Read that file at session start when running framing in a configured project; treat its content as overrides on top of this skill's defaults. If no `cbk-conventions.md` exists, framing operates with the defaults documented here.

## Reference files

- `references/planning-backend-commit.md` — the Issue-per-capability creation step, atomic transition pattern with the markdown commit, slug-inheritance-from-Milestone discipline, re-framing rollback handling (read this in tandem with `backends.md` from the cascade meta-doc set)

- `references/inheritance.md` — how to read prior phase artifacts and prior framings, the verbatim summary template, the "builds on" inheritance pattern
- `references/research-phase.md` — implementation patterns research, MCP/plugin recommendation discipline, open-question resolution
- `references/templates/frame-output-template.md` — the frame-NN.md cascade event file template with worked example
- `references/templates/milestone-template.md` — milestone shape guidance and the per-milestone template
- `references/hitl-question-bank.md` — clarifying questions for inheritance, project selection, research, refined definition, and milestone rounds
- `references/github-only-vs-opinionated.md` — profile-aware behavior differences
- `references/failure-modes.md` — framing-specific failure modes with examples
- `references/test_cases.md` — three realistic test prompts (canonical first framing / subsequent framing builds on prior / re-framing after code) with success criteria for verifying the skill still works after revisions

Read references on demand, not all at once. The SKILL.md is a routing document; the heavy operational content lives in the references.
