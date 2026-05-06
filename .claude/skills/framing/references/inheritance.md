# Inheritance — how framing reads from prior phases and prior framings

Framing's inheritance is the most complex of the four cascade skills so far. It has to handle three different categories of prior content:

1. **Phase artifacts** that always exist when framing runs (problem brief, scaffold output, blueprint)
2. **Prior framings at framing's own level** that may or may not exist (frame-01, frame-02, etc.)
3. **The chronological framing index** that tracks the cascade timeline (`docs/cbk/README.md`)

Skipping any of these is the failure mode that minimum/light mode is most likely to cause. The inheritance check is the **first** step and the **only** step that cannot collapse even in light mode.

## What to read, in order

```
1. docs/cbk/problem_brief.md          (consultation output — required)
2. docs/cbk/scaffold.md                (scaffold output — required)
3. docs/cbk/blueprint.md               (blueprint output — required, especially § "Workstreams")
4. docs/cbk/README.md                 (the chronological index — required if it exists, otherwise skip)
5. docs/cbk/frame-NN.md       (every prior framing — required if any exist)
6. docs/ARCHITECTURE.md                (foundation doc — read for the Decisions Log)
7. docs/STANDARDS.md                   (foundation doc — read for the testing philosophy, PR review checklist, AND § Unenforced invariants)
8. CLAUDE.md                           (foundation doc — read for project conventions)
```

The first three are non-negotiable. Files 4-5 are conditional: if no prior framings exist, this is `frame-01` and there's nothing to inherit at framing's own level. Files 6-8 are foundation docs from blueprint that framing needs for context but doesn't deeply inherit from — read them, but don't treat their absence as a hard error (a user might have skipped CONTRIBUTING.md per the solo-private-pre-v1.0 rule, and that's fine).

**Read all required files in full.** Skimming or guessing at content is the biggest framing failure mode. If a file is too long to read in full because of token budget pressure, surface that explicitly to the user — *"I'm hitting token budget limits reading blueprint.md in full. I'll read sections 7 (Workstreams) and 3 (Stack decisions) carefully and skim the rest. Sound okay?"* — never silently skim.

## The verbatim summary template

After reading, present a verbatim inheritance summary that quotes the relevant content from each file. Do not paraphrase. Paraphrasing is what causes framing to drift from prior phases. The template:

```markdown
## Inheritance summary

I've read the following files in full:
- `docs/cbk/problem_brief.md` ([N] sections)
- `docs/cbk/scaffold.md` ([N] sections)
- `docs/cbk/blueprint.md` ([N] sections)
- `docs/cbk/README.md` (chronological index, [N] prior framings)
- `docs/cbk/frame-01.md` through frame-NN.md ([N] prior framings)
- `docs/ARCHITECTURE.md`, `docs/STANDARDS.md`, `CLAUDE.md` (foundation docs)

### From the problem brief

> [verbatim quote of the relevant constraint or no-go]

### From scaffold

**Quality bar (verbatim)**: [scaffold.md's quality bar field]
**Working conventions (verbatim)**: [branch naming, commit format, label taxonomy]

### From blueprint

**Methodology**: [blueprint's methodology selection with the citation]
**Workstream I'm framing**: [verbatim row from blueprint.md § "Workstreams"]

### From prior framings (the "builds on" inheritance)

[For each prior framing whose interface commitments matter for this framing:]
**frame-NN: [project name]** — interface commitments still in scope:
- [verbatim row from that framing's Interface Commitments table]

### From foundation docs

**Testing philosophy (from STANDARDS.md, verbatim)**: [the testing philosophy section]
**Unenforced invariants (from STANDARDS.md § Unenforced invariants, verbatim)**: [the full table — every row is a constraint on milestone design that no CI gate will catch, so framing's milestones must respect them or rough-in's code will fail review]
**Relevant Decisions Log entries (from ARCHITECTURE.md)**: [list DECISION-NNN entries that constrain this project]
```

The verbatim quoting matters because **the most common framing drift mode is "I read the brief and remembered what it said in different words."** Quoting forces you to confront what the brief actually says, which catches drift before it propagates into the milestones.

## The "Builds on" pattern for prior framings

This is unique to framing. Unlike consultation/scaffold/blueprint (which inherit from a fixed set of prior phases above them), framing also inherits from prior cascade events at its own level. Frame-03 reads frame-01 and frame-02 to know what's already been framed and what interface commitments exist.

**Reading order for prior framings**:

1. Read `docs/cbk/README.md` (the chronological index) to find the highest existing frame number. This is `<latest>`.
2. Read `frame-<latest>.md` first because it's the most recent and most likely to have current interface commitments.
3. Read prior framings backward in sequence (`frame-<latest-1>.md`, `frame-<latest-2>.md`, ...) **only if they have interface commitments that this framing's project might consume**. Skip prior framings whose Interface Commitments table is empty or whose commitments are clearly out of scope for this project.
4. The new framing this run produces will become `frame-<latest+1>.md`.

**What to extract from each prior framing**:

- The **Interface Commitments table** (verbatim) — what interface, which downstream consumer, stable by which milestone, brief shape
- The **Boundaries section** — specifically the "boundary agreements with siblings" subsection, which names other projects this framing made commitments to
- The **Status** at the top of the file — `active`, `superseded`, or `completed`. Superseded framings should still be read for historical context but their interface commitments may have been replaced by a later re-framing.
- The **Rough-in events table** (verbatim) — what each milestone *actually shipped* (vs. what its rough-issue sketch proposed). Rough-in appends a row per atomic-transition event with the sub-sub-issue links + compression rationale + capstone identifier + Step 5.5 outcomes. **The shipped reality is what this new framing inherits, not the original sketch.** If a prior milestone's sketch said "5 issues" but rough-in compressed to 3 and a new framing rough-issue count refers back to that compression-aware reality, the inheritance is faithful. If the new framing assumes the sketch's count, the inheritance is a paraphrase failure. Read the rough-in events table closely whenever the new framing depends on what a prior milestone actually delivered.

**What to ignore in prior framings**:

- The Approach and Components sections — those describe how the prior framing's project was built, which is implementation detail this framing doesn't need
- The Open questions section — those were resolved (or escalated) in subsequent framings or rough-in passes
- The Suggested foundation doc updates section — those should have been applied (or not) by the user; either way they're not framing's input

## Re-framing detection

If the user is re-framing a project that has already been framed (because the milestone shape didn't survive contact with the code, or because new information makes the prior framing wrong), the inheritance check needs to detect this and treat the re-framing as a deliberate cascade event:

1. **Read the prior framing in full**, not just its interface commitments
2. **Identify what changed** — typically the user explains: "the trait stabilization I planned for M3 actually has to happen in M1 because the regex impl revealed a constraint"
3. **The new framing supersedes the prior one**, but does not overwrite it. The prior framing's status changes from `active` to `superseded` in the chronological index. The new framing's `Builds on` section explicitly references the superseded framing.
4. **Interface commitments from the prior framing** that are still valid carry forward verbatim into the new framing. Commitments that are no longer valid get explicitly removed in the new framing's Interface Commitments table with a note: "REMOVED: was \<old commitment\>, no longer relevant because \<reason\>."

## Foundation doc inheritance

The foundation docs from blueprint (CLAUDE.md, ARCHITECTURE.md, STANDARDS.md, CONTRIBUTING.md) are read but not deeply inherited from in the same way the prior phase artifacts are. Specifically:

- **CLAUDE.md** is read for project conventions (commands, patterns, gotchas) that the milestones should respect. Framing should not invent commands that don't exist in CLAUDE.md, and any new commands proposed by framing should be flagged in the "Suggested foundation doc updates" section of frame-NN.md.
- **ARCHITECTURE.md** is read for the **Decisions Log** specifically. Decisions that constrain the project's approach (e.g., "DECISION-001: Use SQLite via rusqlite bundled") become Key Constraints in the refined definition. Do not relitigate decisions blueprint already made.
- **STANDARDS.md** is read for the **testing philosophy**, the **PR review checklist**, AND the **Unenforced invariants table** (added to the STANDARDS.md template after the cascade learned this lesson during blueprint's first real run). The milestones inherit the testing requirements from STANDARDS.md verbatim — don't impose stricter testing in framing than blueprint approved. **The Unenforced invariants table is a constraint set on milestone design**: every row is a textual rule that no CI gate enforces, so framing's milestones must respect every row or rough-in's code will fail review after the fact. If a row says "the engine is sync and offline — no tokio/.await/network I/O," framing must not produce a milestone that adds an async lesson loader to the engine. If the user wants to violate a row, that's an explicit decision to revise STANDARDS.md § Unenforced invariants first (Suggested foundation doc update), then frame the milestone — never silently violate.
- **CONTRIBUTING.md** may not exist if blueprint deferred it (per the solo-private-pre-v1.0 rule). Treat its absence as expected, not as an error.

## The HITL gate

Present the inheritance summary inline. Get explicit user approval before moving to project selection (Step 2). The gate question is the same shape as blueprint's:

> "Here's what I read from prior phases. The verbatim quotes are above — please flag anything I got wrong, anything I'm missing, or anything that's changed since the prior phase ran. Once you confirm, I'll move to project selection."

Common revision requests at this gate:

- "Quote the X section from the brief, not the Y section" → re-read and re-quote
- "Frame-02's interface commitment is no longer valid because we changed Z" → note the change, update the inheritance summary, ask whether the prior framing should be marked superseded
- "ARCHITECTURE.md DECISION-005 also constrains this project" → add it to the Decisions Log entries section
- "I never actually wrote a CONTRIBUTING.md, that's fine" → confirm the absence is expected, move on

Iterate within the gate until the user approves. Then move to Step 2.

## Light-mode behavior

Even in light mode, the inheritance check is mandatory. What can collapse:

- The verbatim summary can be **shorter** — only the most directly-relevant quotes from each file, not exhaustive
- The HITL gate can be combined with the project-selection gate (matching standard mode's gate-1 pattern)
- The "Builds on" reading of prior framings can skip framings whose Interface Commitments are clearly out of scope without explicit user confirmation

What cannot collapse:

- **Reading all required files in full** — non-negotiable
- **Quoting the relevant content verbatim** — paraphrasing is the failure mode; light mode doesn't change that
- **Surfacing the inheritance summary at all** — even in light mode the user sees what was inherited before milestones get produced
