# frame-NN.md template — the cascade event file

The template for `docs/cbk/frame-NN.md` — the cascade artifact framing produces. Each framing run produces one of these. The number `NN` is the framing's identity in the cascade timeline (frame-01, frame-02, etc.), not the project's identity. Re-framing the same project produces a *new* file with the next sequence number; the prior framing stays in the cascade history.

This template is read by Step 4 (refined definition) and Step 5 (milestones) when assembling the final file. The structure adapts project-planner's refined-project-template with cascade-specific additions: a header that links back to blueprint, a "Builds on" section listing prior framings, a status field that supports the supersedes-not-overwrites pattern, and a Suggested foundation doc updates section that flags changes without auto-applying them.

## What to inherit before drafting

| From | What to extract |
|---|---|
| `docs/cbk/blueprint.md` § "Workstreams" | The verbatim row for the project being framed — goes in the header link |
| `docs/cbk/blueprint.md` § "Stack decisions" | Decisions that constrain this project's approach — go in Key Constraints |
| `docs/cbk/blueprint.md` § "Methodology" | The methodology blueprint picked — informs milestone shape per `methodology_register.md` |
| `docs/cbk/scaffold.md` quality bar | Affects acceptance criteria strictness — goes in Approach |
| `docs/cbk/frame-N.md` (each prior framing) | Interface Commitments table verbatim — goes in "Builds on" section |
| Research phase output (Step 3) | Approach section, Open questions section |
| Milestone breakdown (Step 5) | Milestones section |

## The template

```markdown
# frame-<NN>: <project name>

> **Status**: active | superseded | completed
> **Date**: YYYY-MM-DD
> **Framing of**: `docs/cbk/blueprint.md` § "Workstreams" — **<row name>** (row N)
> **Builds on**: frame-<M>, frame-<L> *(or "no prior framings — first framing of the cascade")*
> **Supersedes**: frame-<K> *(only if this is a re-framing)*

---

## Purpose

[One paragraph. What this project delivers and why it matters. Refined from
the rough description in blueprint — more precise, informed by the research
phase. Should answer: what does the system gain when this project is complete?]

## Approach

[Technical approach landed on in the research phase. How are we building this?
What patterns, libraries, and architectural choices drive the design? Cite
ARCHITECTURE.md DECISION-NNN entries that constrain this project. Cite
methodology register entries (vertical slicing, walking skeleton, tracer bullets,
spike solutions, YAGNI) when they applied to per-milestone shape decisions.]

## Resolved during this framing

[Required section. Lists every gate, open question, or deferred decision
identified at framing entry that was closed during this framing event itself
(as opposed to being deferred to rough-in or a future framing). Common
examples: ADRs drafted and accepted during framing because the milestones
below cite them by number; library-version pins resolved here; pattern choices
landed during research; ambiguities in the brief or blueprint surfaced during
inheritance and reconciled with the user.

If nothing was resolved during this framing event (rare but legitimate —
typically only true for frame-01 of a project with extensive blueprint
groundwork), write "Nothing resolved during this framing event — all gates and
deferred decisions either pre-dated framing or were pushed to rough-in." Do
not leave the section empty.

The section is append-only history of what this framing event itself decided,
distinct from Open questions (deferred forward) and Deferred meta-issues
(structural blockers tracked separately).]

- **<Decision name>** — [one-line resolution + citation to the artifact that records it, e.g., "ADR-NNNN drafted and accepted during this framing event"]

## Components

- **<Component Name>** — [what it does, key technical detail, which milestones
  build it]
- **<Component Name>** — [what it does, key technical detail, which milestones
  build it]

## Boundaries

### In scope
- [Explicit list of what this project covers]

### Out of scope
- **<Item>** — [which sibling project owns this, or "deferred to future framing"]

### Boundary agreements with prior framings
- **frame-<M>**: "frame-M provides <interface/module>. This project consumes it
  starting from M<milestone number>."
- [Repeat per relevant prior framing]

## Interface Commitments

[The most valuable single output of framing. Enables future framings to know
what they can build against. Make commitments explicit and milestone-dated.

**Beyond API/interface commitments**, surface non-API commitments too: any
vocabulary, naming, schema, or pattern decision in this framing that future
framings should inherit verbatim rather than re-decide. These are the cheapest
to capture now and the most expensive to reconcile later. The Shape column
distinguishes them so the table at a glance shows whether commitments lean
entirely toward APIs (which might mean the prompt didn't fire) or include the
broader categories.]

| Interface | Consumer | Stable by | Shape | Brief |
|---|---|---|---|---|
| <name> | <downstream framing or "external"> | M<#> | api \| vocabulary \| schema \| convention \| pattern | <type sig or description> |

[If there are no downstream consumers and no cross-framing commitments, write
"No downstream consumers — this project's interfaces are internal only and no
vocabulary/schema/convention decisions were made here." Do not leave the
section empty.

**Prompt to ask before finalizing this section**: *"Beyond the API commitments
we already discussed, are there any vocabulary, naming, schema, or pattern
decisions in this framing that future framings should inherit verbatim rather
than re-decide?"* If yes, add them as rows with the appropriate Shape value.
If no, note it explicitly in the section so future readers know the question
was asked, not skipped.]

## Key Constraints

- [Architectural constraint from ARCHITECTURE.md DECISION-NNN — cite the entry]
- [Integration constraint with prior framings — cite the framing]
- [Forward-compatibility requirement from blueprint — cite the brief or blueprint]
- [Performance or reliability requirement from STANDARDS.md]
- [Structural decisions: things to bake in from day one, not retrofit]

## Milestones (ordered by dependency)

[Each milestone follows the structure from `references/templates/milestone-template.md`.
The narrative arc below the milestones is required.]

### M1: <name>

**Capability**: After this, [concrete verb phrase — what the system can now do].

**Depends on**: Nothing — first milestone *(or: "M0 — must be completed first")*

**Rough issues** (<count> total, <N> user-managed):
1. <Issue title> — [one-sentence intent]
2. <Issue title> — [one-sentence intent]
[Continue per issue]

**Issue notes**: [Anything rough-in needs to know about these issues — Claude-Code-implementable vs. user-managed flags, dependencies between issues, "done" signals at the milestone level.]

### M2: <name>

[same structure]

[Continue per milestone]

### Narrative arc

After M1 you can [X]. After M2 the system can [Y]. By M<N>, the project delivers [Z].

## Suggested foundation doc updates

[Flagged as suggestions only — never auto-applied. The user reviews each suggestion and decides whether to apply it manually.]

- **CLAUDE.md** — suggest adding `<command>` to the Commands section because [reason]
- **ARCHITECTURE.md** — suggest a new DECISION-NNN entry for [decision] discovered during this framing's research phase
- **STANDARDS.md** — no suggested updates *(or specific suggestion)*
- **CONTRIBUTING.md** — no suggested updates *(or specific suggestion)*

[If there are no suggestions, write "No suggested foundation doc updates from this framing." Do not leave the section empty.]

## Open questions

[Items deferred to rough-in or to a future framing. Each item should ideally have a trip-wire for when it gets revisited.]

- [Question 1] — revisit during rough-in *(or: "revisit at frame-<N+1>")*
- [Question 2] — revisit when [condition]

## Pre-flight checks

[Required section. Always present, even if empty.

Meta-issues are concerns surfaced during framing that don't decompose cleanly
into any specific milestone's rough issues but DO gate transitions between
milestones, gate the start of rough-in, or need to land independently of the
milestone sequence. The cascade tracks them as first-class artifacts because
they're inevitable — every framing surfaces some — and because rough-in MUST
check this table before decomposing any milestone.

Each meta-issue gets a corresponding GitHub issue created during framing's
planning-backend commit (parented under the workstream parent Issue with
label `cascade-depth:framed`, same as framing capability sub-issues, but
distinguished by the `meta` label).]

| Issue # | Subject | Depends on | Blocks | Type |
|---|---|---|---|---|
| #<N> | <one-line description> | <milestone exit / other meta-issue / "nothing"> | <milestone start / other meta-issue / "rough-in start"> | gate \| decision \| infrastructure |

[**Type values**:
- **gate**: blocks a transition between milestones. Rough-in must verify it's
  resolved before decomposing the gated milestone.
- **decision**: needs a call before a milestone can be roughed-in. Rough-in
  must surface the open question to the user before generating issue specs.
- **infrastructure**: needs to land independent of any specific milestone.
  Rough-in can decompose it independently of the milestone sequence.

If there are no deferred meta-issues from this framing, write "No deferred
meta-issues from this framing." Do not leave the section empty — the
explicit "none" tells rough-in the table was considered, not skipped.]

## Rough-in events

[Required section. Append-only log of rough-in cascade events that decomposed
this framing's milestones into Claude-Code-ready sub-sub-issues. Rough-in's
Step 6 atomic transition appends a row to this table per run.

Empty at framing-commit time. The table header below is the empty-state shape
— rough-in never modifies the header, only appends rows. If the framing is
re-framed before any rough-in runs, the new framing's table starts empty
again; rows from the prior framing's table do not carry forward.

Row schema:
- **Date**: ISO-8601 date the rough-in committed (the atomic-transition date,
  not the date `/finish` runs the issues)
- **Milestone**: F<#> (M<#>) identifier
- **Sub-sub-issues created**: bulleted or slash-separated list of issue links
- **Notes**: compression rationale, capstone identifier, re-rough-in marker,
  Step 5.5 outcomes, anything notable for the cascade event log. Reference
  the discipline that justified each decision, not the version history of the
  skill — see `references/planning-backend-commit.md` § "The README.md event
  entry shape" for the discipline-not-version-history rule.]

| Date | Milestone | Sub-sub-issues created | Notes |
|---|---|---|---|

## Handoff context

[A ~150-word compressed summary of this framing for downstream skills (rough-in, future framings). Compress ruthlessly. Include: the project's purpose, the chosen approach, the milestone arc, any active interface commitments, **and an explicit parent-pointer sentence naming how rough-in should find the framing capability sub-issues created by this framing's planning-backend commit** (typically "rough-in operates against `[<slug>:F<#>]` sub-issues parented under issue #<workstream-parent-number>, with F-numbers mapping 1:1 to milestone numbers"). This is what rough-in reads first when picking up frame-NN.md.

The parent-pointer sentence is load-bearing: without it, rough-in has to reconstruct the F-number-to-M-number mapping and the parent linkage from cascade conventions alone. Framing already knows these values at commit time (it just created the sub-issues), so writing them into the handoff context is cheap and removes ambiguity for every downstream rough-in run.

**Robust pattern for referencing other issues**: when the handoff context (or any other section) names specific issues, reference them by **issue number only** (`#37`, `#23`). Do not reproduce the issue's title in prose — titles can drift during later cascade revisions (see failure mode "Title drift in cross-referenced issues" in `references/planning-backend-commit.md`), while issue numbers are stable. GitHub's hover-card UI renders the current title dynamically, so number-only references stay fresh without needing edits.]

[Example handoff context, ~150 words:
> The regex project is the first workstream in the cascade and proves
> the Verifier trait against the simplest verifier shape (pure function).
> Approach: minimal trait with `Input`, `Context`, `Error` associated
> types; concrete `RegexVerifier` impl using the `regex` crate; lessons
> as TOML fixtures with `prompt`, `expected_matches`, `foils`. Five
> milestones build incrementally from M1 (one lesson end-to-end) through
> M5 (full pack with 25 lessons and CI integration). Interface commitment:
> the `Verifier` trait stabilizes by M2 — frame-02 (tmux pack) consumes
> it starting from its M1. Rough-in operates against `[regex-pack:F<#>]`
> framing capability sub-issues parented under #12, with F-numbers
> mapping 1:1 to milestone numbers (F1↔M1, F2↔M2, ..., F5↔M5). For the
> first rough-in run, that means #37 (F1/M1) as the parent. STANDARDS.md
> testing philosophy applies throughout.]
```

## Section-by-section authoring guidance

**Header** — the link back to blueprint is non-negotiable. The framing has to be traceable to the blueprint workstream it expanded. Status starts as `active`; only changes to `superseded` when a later re-framing supersedes this one (and only changes to `completed` when rough-in / build work has fully delivered the project).

**Purpose** — one paragraph, concrete. Test: read it cold, can the reader tell what the project is in their own words? Refine from the rough blueprint description.

**Approach** — this is where research findings land. Cite ARCHITECTURE.md DECISION-NNN entries verbatim where they constrain the project. Cite the methodology register when per-milestone patterns (vertical slicing, walking skeleton, tracer bullets, spike solutions) shaped specific milestones.

**Components** — what gets built, mapped to which milestones. Don't over-specify — components are nouns the user will recognize, not implementation details.

**Boundaries** — most underrated section. The "boundary agreements with prior framings" subsection is unique to framing and directly implements the cascade-event inheritance pattern. If this is frame-01, the subsection is empty (and that's fine — say so explicitly).

**Interface Commitments** — the highest-leverage single output. **Always present, even if empty.** An empty commitments table with the note "no downstream consumers — internal only" is signal; an absent table is a bug.

**Key Constraints** — pull from blueprint's DECISIONS_LOG, scaffold's quality bar, and the brief's no-gos. Constraints are facts the milestones must respect.

**Milestones** — load from `references/templates/milestone-template.md`. The narrative arc below the milestones is required because it's the test of "did framing produce a coherent project plan, or just a list of stuff to build."

**Suggested foundation doc updates** — flag suggestions, never auto-apply. **Always present, even if empty.** Empty section says "no suggestions"; absent section is a bug.

**Open questions** — defer items honestly. Each one should have a trip-wire ("revisit at rough-in" or "revisit when X happens"). Open questions without trip-wires become silent staleness.

**Handoff context** — the ~150-word compressed summary for rough-in. This is what rough-in reads first. Compress ruthlessly. The handoff context is the difference between "rough-in inherits everything verbatim" and "rough-in inherits the essence and looks up the rest as needed."

## What does NOT belong in frame-NN.md

- **Implementation code** — that's rough-in's job and Claude Code's job
- **Detailed issue specs** — rough-in will produce these from the rough issues
- **Time estimates** — framing inherits appetite from blueprint (when methodology is Shape Up); if blueprint chose a different methodology, framing produces estimates only on explicit user request
- **Production deployment decisions** — those happen later in the cascade
- **Test specifications below the milestone-acceptance level** — milestone-level acceptance is enough; test detail is rough-in's job

## Profile-aware behavior

**GitHub-only profile**: the entire frame-NN.md content lives in `docs/cbk/frame-NN.md`. Optionally, GitHub repo milestones can be created via GitHub MCP (one per milestone) for tracking, but the markdown file is the source of truth.

**Opinionated profile (Linear stub)**: the same markdown file gets committed to `docs/cbk/`, AND a corresponding Linear project + milestones get created via Linear MCP. The Linear entities mirror the markdown; the markdown is still the source of truth for the cascade.

## HITL gate

When presenting frame-NN.md for review (Step 4 + Step 5 combined output), lead with: *"Here's the draft frame-NN.md. The Interface Commitments section is the highest-leverage piece — please check it first. The Handoff Context at the bottom is what rough-in will read first, so it should compress the rest into ~150 words faithfully."*

Common revision requests:
- "M3 should be a tracer bullet not a vertical slice" → fix the milestone, update the narrative arc
- "The Interface Commitments table is missing the X commitment" → add the row, verify M-number
- "The Suggested foundation doc updates should include Y" → add the suggestion
- "The handoff context is too long — cut it to 100 words" → compress further

Iterate until approved. Then commit via GitHub MCP to `docs/cbk/frame-NN.md`, append the index entry to `docs/cbk/README.md`.
