# Milestone template — shape guidance and per-milestone structure

Step 5 of framing produces milestones. Each milestone is a **demonstrable capability** — something the system can do that it couldn't before. Not "module X exists" but "the system can now [verb]." This template defines the per-milestone structure plus the milestone shapes framing supports and the methodology-aware variants.

## The five milestone shapes

Framing supports five milestone shapes. Vertical slicing is the default; the others apply when the project's nature or blueprint's methodology selection warrants them.

### 1. Vertical slice *(default)*

The default and most common shape. Each milestone delivers end-to-end functionality for a subset of the project — UI through business logic through data layer, all working for a narrow slice. The user can demo the slice and give feedback.

**When to use**: any project where rapid user feedback matters, where reducing integration risk is critical, where the user wants to make release decisions on coherent usable increments.

**Cite**: vertical slicing — Patton, *User Story Mapping* (O'Reilly, 2014). Also Linear Method's project methodology.

**Fails when**: teams revert to horizontal (layer-based) slicing, producing "milestones" that look like tasks with no user-visible value.

**Example**: M1 of the regex project — "After this, the system can verify one TOML-defined regex lesson against the user's input and report pass/fail."

### 2. Walking skeleton

A tiny end-to-end implementation linking together the main architectural components. Production code, not a prototype. Validates architecture, discovers integration constraints, reveals infrastructure gaps early.

**When to use**: at the start of a new project with significant architectural uncertainty, multiple integration points, or unfamiliar deployment environments. Often appropriate for the **first milestone** of a greenfield project where architecture and functionality need to evolve in parallel.

**Cite**: walking skeleton — Cockburn, *Crystal Clear* (Addison-Wesley, 2004). Also Freeman & Pryce, *Growing Object-Oriented Software, Guided by Tests* (2009).

**Fails when**: teams treat it as a throwaway prototype, over-invest in the skeleton before deploying end-to-end, or when architectural risk is minimal and the overhead isn't justified.

**Example**: M1 of a project that integrates three services — "After this, a request from the API gateway flows through the auth service, the data service, and the response service, returning a stub payload. End-to-end pipeline proven."

### 3. Tracer bullet

Lean end-to-end code that fires through all architectural layers to prove the path works under real conditions. Unlike walking skeleton (which validates *architecture*), tracer bullets validate the *technical approach* — they're production-quality code that lights up the path the rest of the work will follow.

**When to use**: when requirements are vague, technology is unfamiliar, or the environment is guaranteed to change. Gives the user something real to react to.

**Cite**: tracer bullets — Hunt & Thomas, *The Pragmatic Programmer* (20th Anniversary Edition, 2019), Topic 12.

**Fails when**: confused with prototyping (the code should not be throwaway), or when the team doesn't iterate after the first tracer.

**Example**: M1 of a project building a new lesson verifier shape — "After this, one minimal verifier impl exercises the trait, runs against one fixture, and proves the trait shape is workable. The verifier is real production code that future packs will extend."

### 4. Spike (research-only)

A time-boxed research milestone aimed at reducing uncertainty before committing to full implementation. Unlike the other shapes, **spikes do not deliver shippable functionality** — they deliver knowledge.

**When to use**: when blueprint flagged a real technical risk in `docs/cbk/blueprint.md` § "Open questions" that needs resolution before implementation can proceed. Use sparingly — most milestones should deliver shippable capability, not research.

**Cite**: spike solutions — Beck, *Extreme Programming Explained* (1999). Expanded by Jeffries in *Extreme Programming Installed* (2000).

**Fails when**: overused as a crutch that delays delivery, not properly time-boxed, or when the question isn't clearly defined upfront.

**Example**: M0 (or M1) of a project where the choice of vector database determines the rest of the architecture — "After this, we have benchmarks comparing pgvector, Qdrant, and Pinecone on our actual workload and a recommendation with rationale. No production code from this milestone — just a `docs/spikes/vector-db.md` and a decision."

### 5. Infrastructure (project-level)

Project-level tooling, workbench, or deployment setup that scaffold couldn't anticipate because the project didn't exist when scaffold ran. Unlike scaffold's workspace-level infrastructure (repo, CI, linting, base testing), infrastructure milestones set up the per-project scaffolding needed before any feature work can ship.

**When to use**: when the project being framed introduces a *new class of infrastructure* the workspace doesn't already have. The canonical example is adding a GUI to an existing backend: scaffold set up backend CI, backend testing, backend deployment, but the project that adds the GUI needs a dev server, a bundler, component testing infrastructure, and a frontend deployment pipeline — none of which exist in the workspace. An infrastructure milestone handles all of that before M2 starts building features.

**Other cases**: adding a mobile client to a web product, adding an embedded firmware component to a software product, introducing ML model training to a product that didn't previously have a training pipeline, switching deployment targets (adding Kubernetes to a project that was VM-based), introducing a new language to a monorepo.

**Not when to use**: when the project's infrastructure needs are already covered by scaffold's workspace-level setup. If you're building the third backend service in a project where scaffold already provisioned backend CI/testing/deployment, M1 is a vertical slice, not an infrastructure milestone. Infrastructure milestones exist for the *gap* between workspace-level and project-level tooling — when that gap doesn't exist, use vertical slicing.

**Also not when**: when the project's infrastructure needs reveal a gap in *workspace-level* tooling that all future projects will also need. In that case, flag it as a Suggested foundation doc update in frame-NN.md and loop back to blueprint or scaffold for a workspace-level fix rather than hiding the workspace gap inside a project-level milestone.

**Cite**: no single register entry — infrastructure milestones are a pragmatic concession to cascade realities, not a named pattern. Closest relative in the register is the walking skeleton (both are "structural work before feature work") but the two answer different questions — walking skeleton validates that the architecture *works end-to-end*, infrastructure sets up the *workbench* for the feature work that follows.

**Fails when**: used as a dumping ground for "setup tasks" that should have happened in scaffold; used to hide workspace-level gaps that all future projects will also hit; confused with walking skeleton (walking skeleton ends with a demonstrable end-to-end path through all layers; infrastructure ends with a working dev loop for the next milestone).

**Example**: M1 of a project adding a GUI to an existing backend — "After this, the frontend has a dev server, a bundler, Vitest for component testing, and a CI workflow that runs frontend tests. A smoke-test React component renders in the dev server and passes its Vitest test. No user-visible features yet — this milestone delivers the workbench that M2 onwards will build features in."

## Methodology-aware variants

Framing inherits the methodology blueprint picked. Honor the methodology when shaping milestones — don't impose Scrum-style sprints if blueprint chose Shape Up.

### Shape Up appetite-based

Each milestone fits within a sub-portion of the project's total appetite. Vertical slices that respect the appetite ceiling. The "circuit breaker" pattern from Shape Up applies: if a milestone busts its sub-appetite, stop and reshape rather than extending.

**Default milestone shape**: vertical slice. The appetite constraint forces narrow slices.

**Number of milestones**: typically 3-5 per project. More than 5 usually means the project should have been split in blueprint.

### Scrum sprint-bounded

Each milestone is roughly sprint-sized (1-2 weeks of team capacity). Milestones map onto sprints loosely — one milestone per sprint, or a milestone spanning two sprints if the team agrees.

**Default milestone shape**: vertical slice. Sprint boundaries naturally produce vertical slices.

**Number of milestones**: depends on project length. A 6-week project becomes 3-6 milestones depending on team velocity.

### Kanban continuous flow

Each milestone is a discrete unit of value pulled from the queue. WIP limits apply at the milestone level. Milestones don't map to fixed time windows; they map to coherent units of work.

**Default milestone shape**: vertical slice. Kanban's pull-based nature reinforces vertical slicing.

**Number of milestones**: variable, usually small (3-5) and added incrementally as work flows through.

### "No formal methodology, just discipline"

The project lacks a named methodology but still has discipline (testing, review, atomic commits). Milestones are vertical slices by default with no fixed cadence.

**Default milestone shape**: vertical slice.

**Number of milestones**: framing's judgment, usually 3-5 per project.

## Per-milestone template

Every milestone in `frame-NN.md` follows this structure:

```markdown
### M<#>: <Name>

**Capability**: After this, [concrete verb phrase — what the system can now do].

**Shape**: vertical slice | walking skeleton | tracer bullet | spike | infrastructure

**Depends on**: <Nothing — first milestone | M<#> ([what specifically this milestone needs from M<#>])>

**Rough issues** (~<count> intents — rough-in compresses on review-unit boundaries; <N> user-managed):
1. <Issue title> — [one-sentence intent]
2. <Issue title> — [one-sentence intent]
[Continue per issue]

**Issue notes**: [Anything rough-in needs to know about these issues — Claude-Code-implementable vs. user-managed flags, dependencies between issues, "done" signals at the milestone level, special tools or MCPs the issues require.]

**Acceptance signal**: [One sentence describing the observable signal that means this milestone is done. **Prefer a command or test the user can run** (e.g., `<cli-binary> <fixture-path>` succeeds and outputs `expected.txt`, or `<test-runner> <integration-test-path>` passes) **over an operational outcome** ("CI green on the merge PR", "the dashboard renders correctly"). Executable signals translate cleanly into rough-in's Test plan section and `/finish`'s done-signal verification step; operational signals force rough-in to invent an executable form during decomposition. When an executable signal isn't available — rare, usually true only for hardware-on-real-device rehearsals or visual-design-evaluation milestones — write the operational signal but flag it explicitly: *"operational signal only — rough-in's capstone will need to translate this to an executable form."*]
```

## Section-by-section authoring guidance

**Name** — short, descriptive, action-oriented when possible. "M1: Verifier trait + first regex lesson" beats "M1: Foundation work."

**Capability** — must be a verb. "The system can now verify regex lessons" is right. "Module X exists" is wrong. The capability is what the user demos to themselves at milestone close.

**Shape** — explicit. The shape determines what kind of milestone this is and informs how rough-in will decompose it. Default to vertical slice; only choose another shape when the project warrants it.

**Depends on** — between-milestone dependencies are first-class. Be specific about what the dependent milestone needs, not just "depends on M2." If M3 depends on M2's verifier trait being stable, say so.

**Rough issues** — the input rough-in will decompose. Each issue is a title plus a one-sentence **intent** — enough for rough-in to start, not enough for Claude Code to implement directly. Mark user-managed issues explicitly (those that can't be automated — repo settings, account creation, DNS changes).

*The intent-vs-prescription distinction is load-bearing.* Rough issues should describe **what each sub-sub-issue will accomplish**, not **how to implement it**. This matters because framing's rough-issue list is the seed that rough-in shapes into Implementation sections (the thing handed to Claude Code plan mode). Plan mode is a decomposition engine — [per Anthropic's Claude Code best practices](https://code.claude.com/docs/en/best-practices), separating research and planning from implementation is load-bearing for producing code that solves the right problem. When framing prescribes implementation details, those prescriptions propagate downstream through rough-in and override plan mode's priors, producing strictly worse code than a cleaner prompt would. See rough-in's `references/plan-mode-prompts.md` § Property 8 for the full downstream discipline — framing's job is to set that discipline up for success by starting with intents at the right layer.

**Examples of good intent phrasing**:

- ✅ *"Define the Verifier trait with Input, Context, Error associated types per IC-1 from this framing"* — names the thing, points at the IC that locks the shape, leaves signature details for rough-in to derive
- ✅ *"Implement the first concrete verifier impl using the regex crate, exercising the trait contract end-to-end"* — names the intent (prove the trait works), names the constraint (use the existing dep), leaves implementation to rough-in and plan mode
- ✅ *"Wire a minimal CLI entry point that loads one lesson, runs the verifier, reports pass/fail"* — names what the CLI does from the user's perspective, not how it's built internally
- ✅ *"Author the first regex lesson as a TOML fixture, shaped so it round-trips through the loader and passes end-to-end"* — names the fixture's purpose, names the invariant (round-trip), leaves fixture content details to rough-in

**Examples of bad prescription phrasing to avoid**:

- ❌ *"Create `crates/core-engine/src/verifier.rs` with `pub trait Verifier { type Input; type Context; type Error; fn verify(&self, input: &Self::Input, ctx: &Self::Context) -> Result<(), Self::Error>; }`"* — inlines a full signature at the framing layer, pre-decides shape details that should live in an IC (if architectural) or in rough-in/plan mode (if not)
- ❌ *"Implement `load_lesson(path: &Path) -> Result<Lesson, LoaderError>` that opens the file, parses TOML, validates required fields, returns the struct"* — prescribes both the signature and the implementation sequence; each of those decisions should land downstream when real code context is available
- ❌ *"Create `tests/regex_integration_test.rs` with `test_regex_lesson_01_passes` that runs the verifier against the fixture and asserts success"* — prescribes exact test file and function names; test naming should match the project's existing conventions, which plan mode will discover from real code

**The discipline test**: for each rough issue in your draft, ask *"am I naming what needs to happen, or am I telling someone how to type it?"* If it's the latter, strip the how and leave the what. If removing the how would leave the rough issue too vague to be actionable, the right fix is usually to point at an IC (if the shape is architectural) or to leave the decision for rough-in (if the shape is implementation detail). Neither of those is the rough issue's job to decide — framing's job is to establish intent and constraint, not to pre-decide implementation.

**Count per milestone**: rough-in will ultimately produce **2-6 R-issues per milestone** for Claude-Code-executed workflows (see rough-in's Step 4 for the review-unit discipline). Framing's rough-issue list should land in roughly the same range — 2-6 intents per milestone is typical. If a milestone's draft has 8+ rough issues, the milestone might be too big (split it, or escalate to re-framing) or framing is pre-decomposing work rough-in will naturally collapse (merge adjacent intents). If a milestone's draft has 1 rough issue, either the milestone is truly atomic (legitimate — note and proceed) or the milestone is too small to stand alone (fold into a sibling).

**Issue notes** — anything rough-in needs context for. Issue dependencies within the milestone, "done" signals, special tools required. This is the per-milestone equivalent of frame-NN.md's Handoff context section.

**Acceptance signal** — one sentence, observable. Not "all tests pass" but "the user can run X and see Y." This is the demo criterion — the thing that proves the capability is real.

## Issue type flags

Mark each rough issue with one of these flags so rough-in knows how to handle it:

- **Claude-Code-implementable** *(default)* — rough-in produces a full issue spec with acceptance criteria, technical detail, and a Claude Code plan-mode prompt. The user reviews the plan and runs Claude Code.
- **User-managed** — manual operations Claude can't automate. Examples: account creation, billing, OAuth setup, DNS changes, branch protection settings, secret provisioning, SSO/SAML, Linear workspace customization. Rough-in still produces an issue spec but the implementation step is the user clicking through a UI, not Claude Code running.
- **Hybrid** — issues that need both manual and automatable steps. Example: "Configure CI signing key" (user creates the key in the GitHub UI, Claude commits the workflow file that uses it). Rough-in splits hybrid issues into a manual sub-issue and an automatable sub-issue.

Default to Claude-Code-implementable unless the issue clearly involves something Claude can't do.

## Milestone count guidance

**The honest test is the demonstrable-capability test, not the count.** Each milestone should pass one specific question: *"Can I show this to someone and have them see a meaningful change in what the system can do?"* If yes, it's a milestone. If the answer is *"well, after this the code will be slightly better factored"* or *"after this we'll have added the next layer of the data model,"* it's not a milestone — it's a step inside one and should be folded.

Typical framings produce **3-5 milestones per project**, but that range is a secondary signal, not a prescription. A small, tightly-scoped project might legitimately have 2 milestones (walking skeleton + completion). A large, multi-surface project might legitimately have 6 milestones spanning infrastructure, feature slices, integration, and hardening. The range catches obvious calibration problems; it doesn't prescribe the right count for well-shaped projects.

**Outside the 2-7 range signals a problem** in the same spirit as before, with softer edges:

- **1 milestone**: project is usually too small to need framing (should have been a single milestone in another framing, or rough-in can handle it directly). Legitimately 1-milestone projects exist but are rare — note the departure and proceed.
- **2 milestones**: legitimate for small walking-skeleton-plus-completion projects. Confirm with the user that the two milestones each pass the demonstrable-capability test and that nothing is being pre-decomposed.
- **6-7 milestones**: legitimate for multi-surface projects. Verify each milestone independently passes the demonstrable-capability test — if any of them fail, those are the ones to fold.
- **8+ milestones**: project is usually too big and should be split in blueprint, OR framing is pre-decomposing work that should live inside milestones as rough issues rather than as separate milestones. Stop and surface to the user.

If you find yourself producing 8+ milestones, **stop and surface this to the user**: *"This project is breaking down into [N] milestones, which is more than the typical 3-5. Before we proceed, two diagnostic questions: (1) does each milestone pass the 'can I show this to someone' test, or are some of them implementation steps that should be folded? (2) If they all genuinely pass the test, the project might be too big — want me to escalate back to blueprint and propose splitting this workstream into two?"*

**Do not decompose milestones into implementation atoms just to hit a count.** A milestone that reads *"After this, the system can run one lesson end-to-end"* is stronger than five milestones that read *"After this, we'll have the loader"* / *"After this, we'll have the verifier"* / *"After this, we'll have the CLI entry point"* / etc. — the first is a demonstrable capability, the rest are implementation steps that happen *inside* a milestone. The failure mode to watch for: if adjacent milestones in your draft can't each pass the "can I show this to someone?" test independently, they're probably a single milestone pre-decomposed into steps.

## What does NOT belong in milestones

- **Implementation steps** — those are rough-in's job (and plan mode's, downstream of rough-in). A milestone's rough issues should name *intents*, not sequences of implementation steps. If a milestone's rough-issue list reads like a linear task breakdown, it's pre-decomposing work that should happen inside a single milestone at rough-in time.
- **Inlined function signatures or code blocks** — unless the signature is verbatim from an Interface Commitment (IC-N) in the framing's IC table, it should not appear in the milestone's rough issues. Non-IC signatures are implementation details rough-in and plan mode will decide with real code context in hand. See rough-in's `references/plan-mode-prompts.md` § Property 3's locked-signature carve-out for the downstream discipline.
- **Time estimates** — see frame-output-template.md, framing inherits appetite from blueprint
- **Test specifications** — milestone-level acceptance is enough; test detail is rough-in. Do not prescribe exact test file names or test function names at the framing layer — those conventions are discovered at rough-in/plan-mode time from the project's existing patterns.
- **Code** — never
- **Stack decisions** — those happened in blueprint; if a milestone needs to relitigate a stack decision, that's a signal blueprint missed something and should be revisited

## HITL pattern

When presenting milestones for review (part of Step 5's HITL gate), show:

1. **The milestone list** — sequence number, name, shape, capability, depends-on, rough issue count
2. **The narrative arc** — *"After M1 you can X. After M2 the system can Y. By MN, the project delivers Z."*
3. **Open questions** — anything framing couldn't resolve at the milestone level

Ask:
> "Before I commit this to frame-NN.md:
> - Any milestones that should merge or split?
> - Any missing capabilities?
> - Is the sequence right? Could any be parallelized?
> - Any rough issues that feel wrong-sized?
> - Does the narrative arc tell a coherent project story?"

Iterate until approved.
