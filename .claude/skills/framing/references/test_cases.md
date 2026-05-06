# Framing test cases

Three realistic prompts for verifying the framing skill works correctly after any revision pass. Each test case represents a structurally distinct scenario — first framing of the cascade, subsequent framing that exercises the "Builds on" inheritance pattern, and re-framing that exercises the cascade-event-not-overwrite pattern. Run all three after any revision to confirm nothing regressed.

## Test case 1 — Canonical first framing (frame-01)

**Prompt (what the user says)**:
> Hey, I've finished blueprint for my CLI teaching tool project. The blueprint has three workstreams: regex pack (Rust, TOML-based lessons, verifier trait), tmux pack (shell layer, same verifier pattern), and bash pack (POSIX verifier). I want to frame the regex pack first since it proves the trait. Standard rigor please. Let's go.

**What framing should do**:

1. **Step 1 — Inheritance**: read `docs/cbk/problem_brief.md`, `docs/cbk/scaffold.md`, `docs/cbk/blueprint.md` in full via GitHub MCP. Check `docs/cbk/` — empty. Check `docs/cbk/README.md` — doesn't exist yet (this is frame-01). Present verbatim inheritance summary quoting the brief's no-gos, scaffold's quality bar, blueprint's regex pack workstream row, and blueprint's methodology section. HITL gate: user confirms summary.

2. **Step 2 — Project selection**: confirm "regex pack" against blueprint's workstreams table. Identify framing number as `frame-01`. HITL gate: user confirms.

3. **Step 3 — Research phase**: propose research depth ("medium — verifier trait pattern is greenfield for this workspace, but the TOML layer is conventional, and blueprint already resolved several open questions"). Run sub-track 3a on verifier trait implementations in Rust. Run sub-track 3c on 2-3 open questions. HITL gate: user approves technical approach. **In standard mode this gate is collapsed into gate 2 along with refined definition + milestones.**

4. **Step 4 — Refined definition**: produce Purpose, Approach, Components, Boundaries, Interface Commitments (the Verifier trait stabilizes by M2, consumer is frame-02 which doesn't exist yet — commitment is to a future framing), Key Constraints, Suggested foundation doc updates, Open questions.

5. **Step 5 — Milestones**: 3-5 milestones, default vertical slicing shape. M1 delivers one end-to-end regex lesson. Each milestone has capability verb, depends-on, rough issues, acceptance signal. HITL gate: user reviews narrative arc.

6. **Commit** `frame-01.md` + create `docs/cbk/README.md` with first index row via GitHub MCP.

**Success criteria**:
- Inheritance summary quotes verbatim (not paraphrased) from at least problem_brief, scaffold, and blueprint
- Research depth proposal happens explicitly as a user signal, not a silent default
- Frame file is named `frame-01.md` (not `frame-regex.md` or `frame-001.md`)
- Interface Commitments table is present even though the consumer doesn't exist yet
- Every milestone has a verb-phrase capability statement
- `README.md` index is created alongside `frame-01.md` in the same commit
- Exactly three HITL gates (standard mode)

**Failure signals**:
- Framing produces milestones without reading all three inheritance docs in full
- Research happens without asking the user about depth
- Interface Commitments section absent or written as prose instead of a table
- `README.md` index not created or created separately
- Framing all three workstreams instead of just the regex pack

## Test case 2 — Subsequent framing with "Builds on" inheritance

**Prompt (what the user says)**:
> Regex pack is built through M3, I'm ready to frame the tmux pack now. Full rigor because I want to review every step — this one depends on what frame-01 committed to and I want to make sure we don't break that contract.

**What framing should do**:

1. **Inheritance**: read all three phase artifacts AND `docs/cbk/frame-01.md` AND `docs/cbk/README.md`. Extract frame-01's Interface Commitments table verbatim — specifically the Verifier trait commitment marked "stable by M2." Present verbatim summary including the frame-01 commitments as a "Builds on" section. HITL gate: user confirms inheritance.

2. **Project selection**: confirm tmux pack. Read `docs/cbk/README.md` chronological index, find highest existing frame number (`frame-01`), increment to `frame-02`. HITL gate.

3. **Research phase**: propose research depth (likely "light for 3a — the pattern is established in frame-01 and being inherited; medium for 3c — tmux has its own open questions around shell subprocess handling"). Surface the inheritance explicitly: *"frame-01 already established the Verifier trait — I'm inheriting it, let me know if you'd rather I start fresh."* HITL gate (full mode): user reviews findings and approach.

4. **Refined definition**: Purpose, Approach, Components, Boundaries (including "boundary agreements with prior framings" subsection that explicitly names frame-01's Verifier trait as the consumption interface), Interface Commitments table. Header includes `Builds on: frame-01`. HITL gate.

5. **Milestones**: M1 consumes the Verifier trait from frame-01. Sequencing honors the fact that frame-01's M2 already shipped. HITL gate.

6. **Commit** `frame-02.md`, append row to `README.md`.

**Success criteria**:
- Inheritance phase explicitly reads frame-01.md and extracts its Interface Commitments table
- Header of frame-02.md has `Builds on: frame-01`
- Boundary agreements subsection exists and references frame-01 explicitly
- No new Verifier trait is proposed — the inherited one is consumed
- Five HITL gates (full mode, one per step)
- `README.md` has two rows after commit: one for frame-01, one for frame-02

**Failure signals**:
- frame-01 not read during inheritance phase
- Builds on header missing from frame-02.md
- Verifier trait silently reinvented in frame-02 despite frame-01 establishing it
- Interface commitments from frame-01 not surfaced in the inheritance summary
- Framing conflates frame-02 with a re-framing of frame-01 (they're different projects — tmux vs regex)

## Test case 3 — Re-framing after code (cascade event, not overwrite)

**Prompt (what the user says)**:
> So I built frame-01 through M3 and hit a wall. The Verifier trait I committed to in frame-01 has a constraint I didn't see — the `Context` associated type needs to be generic over lifetime in a way that breaks the whole trait shape. I need to re-frame the regex pack. The new trait design is different enough that I want a proper new framing, not an edit to frame-01.

**What framing should do**:

1. **Inheritance**: read all phase artifacts, read `frame-01.md` in full (this is a re-framing so the full file matters, not just interface commitments), read any other framings that exist at this point. Present inheritance summary that includes frame-01's Approach, Components, and Interface Commitments verbatim — the user needs to see exactly what's being superseded. HITL gate: user confirms and explains what changed.

2. **Project selection**: confirm this is a re-framing of the regex pack. Identify new framing number as `frame-<latest+1>` (depends on how many framings exist by this point — probably `frame-03` if frame-02 for tmux was already done). Confirm that `frame-01`'s status will change from `active` to `superseded`. HITL gate.

3. **Research phase**: propose depth ("medium — we need to resolve the lifetime constraint discovered during build, but the overall approach is mostly inherited from frame-01 with the trait shape fix"). Run sub-track 3c on the specific technical question that caused the re-framing. HITL gate (if full mode, else collapsed).

4. **Refined definition**: Header includes both `Builds on: frame-01` AND `Supersedes: frame-01`. Purpose and Approach reflect the new trait design. Interface Commitments table now has the corrected Verifier trait — with an explicit note on any commitments from frame-01 that are being removed ("REMOVED: Verifier trait shape from frame-01, no longer valid because of lifetime constraint discovered in M3"). HITL gate.

5. **Milestones**: new milestones for the re-framed project. M1 usually stays similar ("one end-to-end regex lesson") but the underlying trait work changes. HITL gate.

6. **Commit** `frame-<new>.md` AND update `frame-01.md`'s status field from `active` to `superseded` AND append a row to `README.md` with the new framing + a status change row for frame-01.

**Success criteria**:
- `frame-01.md` file still exists on disk with its status changed to `superseded` — NOT deleted, NOT overwritten
- New framing file has the next sequence number (not `frame-01-v2.md` or similar)
- New framing's header has both `Builds on: frame-01` and `Supersedes: frame-01`
- Interface Commitments table explicitly notes removed commitments
- `README.md` index shows both frame-01 (superseded) and the new framing (active)
- Rough-in running after this can find the new framing as "highest-numbered active framing"

**Failure signals**:
- `frame-01.md` gets overwritten (catastrophic failure — violates cascade-event model)
- New framing has `frame-01.md` as filename (sequence number not incremented)
- `frame-01.md` status not updated to superseded
- New framing lacks `Supersedes: frame-01` in header
- Interface Commitments table silently drops frame-01's commitments without noting the removal
- `README.md` index only shows the new framing, losing frame-01's history

## Test 4 — planning-backend commit (Issue creation per framing capability, atomic transition)

**Prompt (what the user says)**:
> Framing the regex-pack workstream. Profile is github-only. Blueprint already created the `regex-pack` Milestone. The framing produces 4 capabilities. Run the planning-backend commit alongside the markdown commit.

**What framing should do**:

1. Query the planning backend for the `regex-pack` Milestone via `planning.query_nodes`. Confirm it exists. If missing → surface gap, offer loop-back to blueprint, abort.
2. Read the canonical slug from the Milestone title (`regex-pack`) — do not re-derive from the workstream name in `blueprint.md`.
3. Construct 4 Issue titles using the inherited slug: `[regex-pack:F1] ...` through `[regex-pack:F4] ...`.
4. Present the final HITL gate listing both halves of the transition: the markdown commit (`frame-01.md` + append to `README.md` index) AND the 4 Issues to be created with their titles, all assigned to the `regex-pack` Milestone.
5. On user approval: execute planning ops first, capturing each Issue's `{id, url}` as it lands.
6. Execute markdown commits second (frame-01.md and README.md index update in one commit).
7. On any failure during step 5 or 6: rollback by deleting captured Issues, surface the rollback to the user, abort cleanly.
8. On full success: report both halves committed with Issue URLs and the markdown commit SHA.

**Success criteria**:
- Milestone existence check happens before any commit operation
- Slug is inherited from the Milestone title, not re-derived
- Both halves of the transition are presented at the HITL gate as one approval
- Planning operations execute first; markdown commit executes second
- All 4 Issues land on the planning backend with correct titles, bodies, Milestone assignment, and `cascade-depth:framed` label
- The markdown commit lands with `frame-01.md` and `README.md` updated atomically with the Issues
- Cascade is fully consistent after the transition

**Failure signals**:
- Markdown committed without Issues being created (transition not atomic)
- Issues created without markdown commit (transition not atomic, no rollback)
- Slug derived locally instead of inherited from Milestone (causes prefix drift)
- Framing proceeds when the Milestone is missing instead of looping back to blueprint
- Rollback skipped on transition failure
- Re-framing rollback leaves partial state without the manual recovery checklist

## How to run these test cases

For each test case: clear any existing framing state, seed the repo with the inheritance docs (or stub them for the test), run the prompt verbatim, and verify the success criteria. If any failure signal appears, the skill has regressed and needs a fix.

Test cases 1 and 2 should pass cleanly on any commit to the skill. Test case 3 is the highest-risk one because the cascade-event-not-overwrite pattern is the most counterintuitive — if any revision accidentally collapses re-framing into an edit operation, test case 3 will catch it.
