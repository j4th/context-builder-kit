# Framing failure modes and defenses

Full elaboration of the failure modes framing should actively defend against. Each entry names the failure, explains why it happens, shows what it looks like, and documents the defense. These are the modes worth catching *during* framing — catching them after frame-NN.md is committed means paying a re-framing cost.

## 1. Framing all workstreams at once

**Why it happens**: the user has a clean blueprint with many workstreams and asks "frame this whole thing." The skill feels the pull toward being comprehensive. Waterfall regression is a well-documented failure mode in AI-assisted development (Thoughtworks Radar has flagged it explicitly).

**What it looks like**: framing produces `frame-01.md` through `frame-05.md` in a single session based only on what blueprint says, without any code having been built between them. The later framings are confabulated — they can't possibly know what frame-04 should look like before frame-01's code teaches the user something that should have changed frame-04's design.

**Defense**: framing is one-project-at-a-time, just-in-time, by design. If the user asks for multiple framings in one session, respond: *"Let me frame one project now. Once you've built through its M1 or M2, come back and I'll frame the next — by then you'll have learned things that should change my approach to the next framing. The research backs this: framing all at once is waterfall regression."*

**Exception**: the user can override with explicit acknowledgment. If the user says *"I understand the risk, frame three at once anyway"*, honor it but flag in each frame-NN.md's header: *"Note: this framing was produced in a batch session alongside frame-N-1 and frame-N+1, without code between framings. The usual cascade-event model assumes intervening build work — treat the later framings as more speculative."*

## 2. Skipping inheritance

**Why it happens**: the user explains the project verbally in detail, and framing rides that explanation into milestone production without actually reading the inheritance docs. Light-mode amplifies this — the user says "I know what I'm doing, just give me milestones" and framing skips the inheritance read to match the user's pace.

**What it looks like**: framing produces milestones that contradict blueprint's stack decisions, ignore the brief's no-gos, or invent interface commitments that conflict with prior framings. The user catches it late, usually during rough-in, and blames framing for drift.

**Defense**: reading the inheritance docs in full is non-negotiable in every rigor mode. The verbatim summary presentation is the forcing function — it's hard to skip the read when you have to quote the content back to the user. In light mode, the HITL gates can collapse but the inheritance read cannot.

## 3. Inventing milestones that don't match blueprint's methodology

**Why it happens**: the milestone shape defaults to vertical slicing regardless of context, but blueprint may have picked Shape Up (appetite-based), Scrum (sprint-bounded), or Kanban (continuous-flow). Framing produces milestones that look like generic vertical slices and ignores the methodology's constraints.

**What it looks like**: blueprint chose Shape Up with a 6-week appetite. Framing produces 8 milestones, each estimated at 1-2 weeks of work. The project now needs 8-16 weeks, busting the appetite by a factor of 2-3. The user notices late and has to re-frame or abandon the appetite constraint.

**Defense**: read blueprint's Methodology section in the inheritance phase and treat it as a constraint on milestone shape. For Shape Up, respect the appetite ceiling. For Scrum, size milestones to sprints. For Kanban, size milestones as discrete pull-units. Cite `methodology_register.md` when deciding shape — the register's "fails when" conditions usually catch methodology mismatches.

## 4. Auto-updating foundation docs without HITL approval

**Why it happens**: during research, framing notices that CLAUDE.md is missing a command the project needs, or ARCHITECTURE.md doesn't have a DECISION entry for something the project relies on. The pull is to "just fix it" — commit the update in the same session.

**What it looks like**: `frame-NN.md` gets committed and so does an updated `CLAUDE.md` with new commands added. The user didn't approve the CLAUDE.md update; it just appeared. Subsequent framings now inherit the unapproved change, compounding drift.

**Defense**: framing never mutates foundation docs directly. All suggested updates go in the "Suggested foundation doc updates" section of `frame-NN.md` — flagged as suggestions, never auto-applied. The user reviews suggestions during the final HITL gate and decides which to apply manually.

## 5. Treating interface commitments as informal cross-references

**Why it happens**: interface commitments are the hardest part of framing because they require thinking across framings — not just "what does this project do" but "what does this project owe to other projects that will consume its work." The temptation is to wave at commitments in prose ("oh, the tmux pack will probably use the verifier trait") instead of producing a proper table.

**What it looks like**: `frame-NN.md` has a Boundaries section that mentions commitments in passing but no Interface Commitments table. When frame-NN+1 runs, there's nothing to inherit — the next framing has to reconstruct the commitments from informal prose.

**Defense**: the Interface Commitments table is always present in `frame-NN.md`, even when empty. Empty table with the note *"No downstream consumers — this project's interfaces are internal only"* is signal. Absent table is a bug. Every commitment has four explicit columns: interface, consumer, stable-by-milestone, shape.

## 6. Overwriting prior framings instead of creating new ones

**Why it happens**: the user says "re-frame the regex project, the original framing was wrong" and framing writes to `frame-01.md` instead of creating `frame-04.md`. Conceptually tempting — "there's only one regex project, right?" — but structurally wrong.

**What it looks like**: `frame-01.md` gets overwritten with new content. The cascade history loses the information about what the original framing thought. Future debugging ("why did rough-in produce this issue spec?") can't trace back to the framing that was active when rough-in ran.

**Defense**: framings are cascade events, not project slots. Re-framing always produces a new file with the next sequence number. The prior framing stays on disk with status changed from `active` to `superseded`. The chronological index (`docs/cbk/README.md`) records both framings in sequence.

## 7. Producing milestones without demonstrable capabilities

**Why it happens**: the pull toward "M1: Foundation work" — setting up the scaffolding for the project without shipping a capability. This feels productive but produces a milestone the user can't demo.

**What it looks like**: `frame-NN.md` lists "M1: Project setup", "M2: Core module", "M3: Integration", "M4: Tests". None of these answer "what can the system now do?" The user finishes M1 and has no observable progress to show — just code that compiles.

**Defense**: every milestone's capability statement starts with "After this, the system can [verb]." Not "module X exists" but "the system can now X." The acceptance signal is a user-visible outcome, not a test. If you can't state a verb, the milestone isn't shaped right — merge it with the next milestone or split it to find the smallest shippable capability.

**Exception**: spike milestones deliver knowledge, not capability. The capability statement for a spike is *"After this, we have a decision on X"* — knowledge is the deliverable.

## 8. Skipping the cascade-events index update

**Why it happens**: `docs/cbk/README.md` is the chronological log that tracks the cascade timeline, but it's easy to forget when the main output is `frame-NN.md`. The skill commits the framing file and stops.

**What it looks like**: `docs/cbk/frame-01.md` exists but `docs/cbk/README.md` doesn't list it. Future framings can't find the highest existing sequence number to increment from. Rough-in can't find "what's next" because the timeline is invisible.

**Defense**: the cascade-events index update is part of the final HITL gate's commit operation. `frame-NN.md` and `README.md` get committed in the same operation, not separately. The HITL gate explicitly surfaces both: *"I'll commit frame-NN.md and the updated README.md index in one commit. The index row will be: <row>. Approve?"*

## 9. Using infrastructure milestones to hide workspace-level gaps

**Why it happens** *(identified during skill construction)*: framing notices the project needs tooling the workspace doesn't have — a dev server, a bundler, a new test runner. The pull is to add an infrastructure milestone to the project. But if *every* future project will also need that tooling, the infrastructure belongs at the workspace level (scaffold's job) and putting it inside a project-level milestone hides the workspace gap from the cascade.

**What it looks like**: `frame-NN.md` has `M1: Infrastructure` that provisions workspace-wide tooling — a CI pipeline that all future projects will need, a monorepo test runner that applies across projects, a deployment target that every project will share. The tooling gets built inside project M1. Future framings don't see the tooling as available at the workspace level because it was never added to scaffold — they rediscover the same gap and propose duplicate infrastructure milestones.

**Defense**: before writing an infrastructure milestone, ask the test question: *"Would every project in this workspace eventually need this?"* If yes, it's a workspace gap — flag it in the "Suggested foundation doc updates" section as *"workspace needs <tooling>, suggest looping back to blueprint/scaffold"* and do NOT put it inside the project's milestones. If no (the tooling is genuinely specific to this project — e.g., a React dev server in a project adding a GUI to an otherwise headless backend), an infrastructure milestone is the right call.

**Example where infrastructure milestone is right**: adding a GUI to a backend-only product. Scaffold set up backend CI/test/deploy. The GUI project needs a dev server, a bundler, component test infrastructure, and a frontend deployment pipeline. None of that exists in the workspace, and no future *backend* project will need it. Infrastructure M1 is the right call.

**Example where it's wrong**: the third backend service in a project where scaffold already provisioned backend CI/testing/deployment. Proposing "M1: set up CI for this service" is the failure mode — CI was scaffold's job and is workspace-wide, not per-project.

## 10. Planning-backend transition failures

These emerged with the github-only commit step (creating Issues per framing capability atomically with the markdown commit). Specific to the planning-backend half of framing's transition.

**Partial state on transition failure** — Issues created on the planning backend but the markdown commit failed (or vice versa). Defense: the atomic transition pattern in `references/planning-backend-commit.md` — capture each created Issue's id, roll back on any failure during either half. Re-framings have more moving parts and the rollback is more involved; capture every op in order, walk the captured list in reverse to undo.

**Missing workstream Milestone** — framing tries to assign Issues to a Milestone that doesn't exist (blueprint wasn't run, was rolled back, or someone deleted it). Defense: framing queries the Milestone before the transition and surfaces the gap with a loop-back-to-blueprint option if missing. Never silently creates a substitute.

**Slug mismatch between Issue prefix and Milestone title** — framing constructs Issue prefixes from a slug derived locally instead of inherited from the Milestone. Causes downstream prefix drift in rough-in sub-issues. Defense: framing always inherits the slug from the Milestone via `planning.query_nodes`, never from the workstream name in `blueprint.md`.

**Re-framing rollback complexity** — re-framings perform multiple coordinated operations (create new Issues, supersede prior Issues, commit two markdown updates, append two index rows). Failure midway leaves a more complex partial state. Defense: capture every operation in execution order, walk the captured list in reverse on rollback, surface any rollback failures with a manual recovery checklist.

## How to recover after hitting a failure mode

**Caught during framing** (before the final HITL gate): go back to the affected step. If inheritance was skipped, go back to Step 1 and read properly. If the methodology was ignored, go back to Step 5 and reshape the milestones. If interface commitments were informal, go back to Step 4 and add the table. Each failure mode has a corresponding step to return to.

**Caught after commit** (post-framing discovery): create a re-framing as the next cascade event. Do NOT overwrite the flawed framing. The prior framing's status changes from `active` to `superseded`; the new framing's `Builds on` section references the superseded one and its `Supersedes` field names it explicitly. The cascade history stays intact; only the active pointer moves forward.

**Caught during rough-in or code** (late discovery): same recovery — re-framing is a cascade event. Rough-in inherits whatever the highest-numbered active framing says. If that framing is wrong, create a new framing that supersedes it. Rough-in picks up the new one on its next run.

The general pattern: **failures never cause overwrites, only new cascade events.** The cascade is append-only at the file level; correction happens by adding newer events that supersede older ones, not by editing history.
