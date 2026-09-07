# Framing — the procedure

Read this only when running framing in **full mode**, or when the contract-first draft (`contract.md`) leaves you unsure how a step is meant to go. In light and standard modes the contract, the two templates and the inputs are the whole read; `SKILL.md` routes. Nothing here overrides the contract: where the two differ, the contract governs and the difference is a defect to report.

The five steps below are the exercised procedure with their per-step gates. The HITL gates summary, the long-form backend-axis behaviour, the failure modes and the solo-versus-team notes follow them.

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
**D) Additive increment to a still-Active framing** — *"Add the completion milestone to this workstream — the prior frame's milestones are still open, this doesn't replace them"* → read the prior framing of that workstream, then treat the new framing as a deliberate cascade event that **adds** a milestone (or a small set) **without superseding** the prior frame. Both framings stay `Active`. The new framing takes the next sequential frame number, carries a **"Builds on: frame-NN"** header (not a "Supersedes" one), inherits the prior frame's charter and interface commitments verbatim, and its new milestone(s) coexist in the cascade with the prior frame's still-open milestones. Sequencing across the two frames' open milestones is operator pull-flow.

**E) Milestone-scoped re-framing** — *"M4's shape didn't survive contact with the code, but M1–M3 are built and Done"* → a third grain between whole-frame supersession (C) and the additive increment (D). The new frame supersedes **only the named milestone's shape**: its header states the scope explicitly ("Supersedes only milestone M<N> of frame-NN; M1–M<N-1> are built and Done"), the prior frame stays in the cascade **untouched** with its index status annotated via the permitted status-column mutation ("Active (M<N> superseded by frame-MM)"), and the retired milestone's acceptance-criteria set is recorded in the new frame as **retired un-executed** — never silently dropped, so a later reader can see what was promised and consciously withdrawn.

Additive increment vs. re-framing (pattern C) is a status distinction: re-framing **replaces** a milestone breakdown that didn't survive contact with the code (old frame → `Superseded`); an additive increment **extends** a workstream whose prior milestones are still valid and open (old frame stays `Active`). Reach for additive increment when a gap assessment or a newly-surfaced prerequisite reveals work the prior frame didn't cover *and* the prior frame's milestones are still the right shape. Reach for re-framing when the prior frame's milestones themselves need re-cutting — whole-frame (C) when the breakdown as a whole is wrong, milestone-scoped (E) when one milestone needs re-cutting and the rest are done or still right.

**A single-milestone additive increment is legitimate — do not fold it into a sibling.** An additive increment often carries exactly one milestone: the increment is one demonstrable capability, and its sub-pieces are R-issues *inside* that milestone, not milestones of their own (none independently passes the demonstrable-capability test — together they are the single capability). This is the sanctioned exception to Step 5's "1 milestone usually means fold into a sibling" heuristic — that smell applies to a *fresh* framing of a workstream, not to an increment on an already-Active one. State the shape in the frame header ("additive increment; one milestone") so a later reader doesn't mistake the single milestone for the anomaly.

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

**Calibration lean**: because execution is AI-assisted (plan mode decomposes a well-shaped issue into ~5–10 internal steps), rough-in tends to land at the *low* end of its 2–6 range — it routinely collapses framing's rough-issue sketch into fewer, coarser review units. Don't over-discretize at framing; when unsure between more-smaller and fewer-larger intents, prefer fewer. This is a lean, not a rule — it reflects a solo + AI-assisted appetite; a larger team may want finer boundaries.

### Absorbing intake candidates (if the project runs a contribution-intake lane)

Some projects run a **bottom-up contribution-intake lane** that files capability *candidates* under a workstream *before* framing — "we should build X" requests held in a project-specific holding surface for not-yet-framed work (see the project's `cbk-conventions.md`). When such candidates exist under the workstream you're framing (they appear in the parent's issue list framing already reads for its idempotency check), treat them as **inputs, not greenfield**: fold each candidate's intent into the milestone(s) it informs, and **reconcile** it as you create the F-issues — promote it 1:1 to its F-issue, or close it as superseded by the F-issue(s) it informed — so it leaves the project's holding surface (the concrete relabel/close op lives in the project's `cbk-conventions.md`). Surface the candidate→milestone mapping in the milestone HITL gate. Projects without an intake lane have nothing to absorb; skip.

### Milestone shape and pattern

Milestone shape is **flexible by default with vertical slicing as the recommended pattern** (the methodology register's recommendation):

- **Vertical slices** (default) — each milestone delivers end-to-end functionality for a subset of the project. Aligns with Linear Method's project methodology.
- **Spike milestones** — research-only checkpoints with no shippable output. Use sparingly, only when blueprint flagged a real research risk.
- **Infrastructure milestones** — CI, build, tooling work that enables later vertical slices. Greenfield projects often have one of these as M1.

If blueprint picked a specific methodology (Shape Up, Kanban, Scrum), honor it — Shape Up's appetite-based approach naturally produces vertical slices that fit a fixed appetite, Kanban's continuous flow produces continuously-sized milestones, Scrum's sprints produce sprint-bounded milestones.

Detailed milestone-shape guidance and the milestone template live in `references/templates/milestone-template.md`.

### Pre-flight meta-issues and the charter pattern

Not every unit of work a framing produces is a milestone. A **Pre-flight meta-issue** is a decision-or-de-risk unit that *gates* a milestone start rather than delivering a demonstrable capability: it produces decisions, governing ADR(s), a reference doc, and/or a throwaway spike, then unblocks the milestone(s) that depend on it. Pre-flight meta-issues are recorded as rows in the frame's **Pre-flight checks** table (never as milestones — they have no shippable capability), each carrying a `Blocks: M<n> start` marker; rough-in must verify each is resolved before decomposing the milestone it blocks (see § Handoff contract to rough-in).

The highest-leverage Pre-flight meta-issue is the **charter**. Emit one when a workstream's design **concept is frozen but its buildable spec is not** — the approach is already settled upstream (reviewer-enforced, or ratified at blueprint / in an existing ADR), yet the concrete pattern that *every* milestone will share (schema conventions, an identity or key strategy, a versioning discipline, a load pattern, cross-cutting per-row invariants) has not been pinned down. In that case framing emits a **standalone charter meta-issue** that, before the first buildable milestone lands:

- **Ratifies the cross-milestone contract** — settles the load-bearing engineering decisions and reconciles any conflicting specs inherited from prior phases into one authoritative set.
- **Produces the governing ADR(s)** — the immutable decisions every milestone inherits.
- **Produces a reference / pattern doc** — a concise buildable spec (a reference doc in the workstream's source tree) that downstream R-issues read and follow verbatim.
- **Optionally runs a throwaway de-risk spike** — when a concrete engineering risk should be settled before committing the pattern (e.g. *"does this approach hold at the real data scale, or under the real constraint?"*). The spike is disposable; only its verdict survives, into the ADR(s). A charter whose research is already settled carries **no spike** — decision-only is a legitimate charter shape.
- **Is marked `Blocks: M1 start`** (or whichever milestone is first to build on the pattern) in the Pre-flight checks table.

**Why standalone, not folded into M1**: the charter's decisions govern *all* the workstream's milestones, not just the first — and when a spike is involved, the pattern wants proving before any milestone commits to it. Folding a cross-milestone contract into M1 buries a decision that the later milestones equally depend on inside one milestone's implementation, and forecloses the spike. The charter earns its own blocked-by meta-issue precisely because its blast radius is the whole workstream.

**Charter output is inherited verbatim, never re-derived.** Once it resolves, its ADR(s) and reference doc are the source of truth; every downstream R-issue treats the pattern as a fixed constraint and does not re-litigate it. The charter simply concentrates the workstream's one-time decisions into a single gated artifact, so the milestones after it stay purely about demonstrable capability.

**The pre-registration flavor.** When a milestone runs a wide comparison or selection (many candidates × many metrics) that feeds a gated one-way decision, the charter pre-registers the rules in an immutable decision record **before any candidate runs**: the closed candidate set (adding one later costs a refining record), the named success targets and thresholds, the evaluation protocol, expected-outcome pre-commitments — **including likely-null expectations**, so a null result reads as confirmation rather than spin — and named known limitations that every downstream output inherits. Three companions keep the frozen rules honest:

- **Post-freeze arrivals join an exploratory tier.** A candidate that appears after rule-freeze runs surface-only at the gate — visible and compared, but ineligible for the gated decision unless a refining record admits it.
- **Deviations are refining records with honest disclosure** — what was pre-committed, what reality showed, and what changes (see the adr-new skill § Refines vs Supersedes) — never a silent re-interpretation.
- **A standing gate's no-change verdict is recorded.** When the gate runs and decides *no change*, that re-affirmation is a first-class event with rationale on the standing artifact — so absence-of-change stays distinguishable from gate-never-ran.

**Spikes pre-declare three outcomes.** A charter (or milestone) spike gating a risky adoption — a niche dependency, a native-build toolchain, an unproven approach — pre-declares **promote / named fallback / documented drop** as first-class outcomes, so a drop is a recorded verdict rather than a quiet abandonment, and the next risky adoption can cite the precedent instead of re-arguing the shape.

**When *not* to emit a charter**: if a decision is local to one milestone, fold it into that milestone — don't manufacture a Pre-flight meta-issue for it. If both the concept *and* the buildable spec are already settled upstream, skip straight to M1; a charter with nothing to ratify is ceremony. And if the *concept itself* is still unfrozen (you're choosing the approach, not just its buildable form), that belongs to blueprint or a spike milestone, not a charter.

### Example excerpt (what one milestone looks like in practice)

To make the output shape concrete: here's what one milestone spec looks like, taken from a real cascade run on a CLI-tutorial project whose first workstream was a "regex pack" of lessons. Note the specificity — the capability is a verb the system can do, the rough issues are concrete enough for rough-in to decompose, and the dependency is explicit.

**Input fragment** (user during milestone HITL):
> "M1 should be the smallest thing that proves the verifier trait works. Just enough to pass one regex lesson end-to-end. Nothing fancy."

**Output fragment** (resulting frame-01.md milestone excerpt):
```markdown
### F1 — M1: Pure-function verifier proves the trait

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


## Backend-axis-aware behavior

Framing's behavior differs along **two independent axes** set by scaffold: the planning backend (`github-issues` / `linear` / `in-repo-markdown`) and the knowledge backend (`notion` / `none`). The planning-axis differences live in `references/planning-backend-matrix.md`; the knowledge-axis contract lives in `.claude/rules/knowledge-backend.md`. Short version:

**Planning axis**:
- `github-issues`: framing creates one F-sub-issue per milestone under the workstream parent Issue via `issue_write` + `sub_issue_write add`. Markdown commit + sub-issue creation form one atomic transition.
- `linear`: framing creates one Linear F-issue per milestone via `mcp__linear__save_issue` parented under the workstream issue. Same atomic-transition discipline. Read the workstream parent via `mcp__linear__get_issue` first; idempotency-check via `mcp__linear__list_issues`. On partial failure, surface state — do not retry blindly.
- `in-repo-markdown`: no external planning entities. The frame-NN.md markdown is the entire planning artifact. Atomic transition collapses to a single half.

**Knowledge axis**:
- `notion`: framing **may optionally** read from the project's Notion hub at inheritance for richer context. Framing **may optionally** promote a cross-project meta-issue to a Notion runbook page when the meta-issue surfaces material that genuinely spans repos (NOT for normal milestone deferred-decision meta-issues; those stay in the planning backend or markdown). Both reads and writes are HITL-gated and default-SKIP.
- `none`: no Notion interactions.

The two axes compose independently. Always read `scaffold.md` to learn the operator's choice before behaving along either axis.

Detailed planning-axis behavior including failure modes lives in `references/planning-backend-matrix.md`. Knowledge-axis discipline lives in `.claude/rules/knowledge-backend.md`. Project-specific identifiers (Linear team key, workstream slugs, label conventions, hub URLs) live in the project's `.claude/rules/cbk-conventions.md`.

### Optional Notion-write gate (knowledge = `notion`, cross-project meta-issues only)

When framing surfaces a Pre-flight check / deferred meta-issue that's genuinely cross-project (e.g., a runbook that spans this repo and another, a vendor evaluation, an architectural decision affecting multiple workstreams), the closing HITL gate also asks:

> *"This meta-issue (`<title>`) looks cross-project. Want me to promote it to a Notion runbook page under the Engineering Wiki, so it's discoverable from outside this repo? Defaults to SKIP — the meta-issue stays in the planning backend (or in `frame-NN.md` for in-repo-markdown) regardless."*

Defaults to **SKIP**. Fires only for meta-issues marked as cross-project; never for normal milestone-blocking meta-issues. Per `.claude/rules/knowledge-backend.md` HITL discipline, announce the planned write before committing.


## HITL gates summary

Framing has five HITL gates in **full mode**, three in **standard mode**, and one in **light mode**.

**Full mode — five gates** (per-step review):

1. **After inheritance check** — user confirms the inheritance summary is accurate
2. **After project selection** — user confirms which project is being framed and the framing number
3. **After research phase** — user lands on the technical approach and the resolutions of the open technical questions
4. **After refined definition** — user reviews and approves the refined project definition
5. **After milestones** — user reviews the milestone list with narrative arc

**Standard mode — three gates** (step-boundary review):

1. **After inheritance + project selection combined** — user confirms inheritance and project selection in one batched gate
2. **After refined definition + milestones combined** — user reviews the refined definition with milestones together
3. **After frame-NN.md is drafted** — final review before commit

**Light mode — one gate**: a single up-front confirmation listing what framing will produce, then run-to-completion until the frame-NN.md file is presented for final review.

Each gate is an explicit "approve to proceed" moment. Iterate within a gate as many times as needed. The mode dial can be tuned mid-session.


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

