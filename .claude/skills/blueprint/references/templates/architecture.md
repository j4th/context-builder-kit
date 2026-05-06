# ARCHITECTURE.md template

On-demand reference doc. NOT loaded every session — loaded via `@docs/ARCHITECTURE.md` when building specific subsystems. Can be comprehensive because it doesn't compete with every session's context.

**Research-informed priorities** (preserved from initiative-planner, all still applicable):
- **Decisions log with rejected alternatives = highest agent value** (prevents relitigating)
- Design principles as short constraints, not philosophy
- Component relationships matter more than component descriptions
- Directory READMEs in each major folder complement this doc

## What to inherit before drafting

| From | What to extract | Where it goes in ARCHITECTURE.md |
|---|---|---|
| `problem_brief.md` proposed approach | Architectural sketch — the *shape* of the system | System Overview section |
| `problem_brief.md` no-gos | Architectural constraints | Design Principles (as constraint-style rules) |
| `problem_brief.md` current state (brownfield) | What exists today | Project Structure section, Component Deep Dives |
| `scaffold.md` quality bar | Testing rigor | Testing Architecture section |
| Stack decisions (this phase) | All language/framework/storage/distribution/testing choices | Tech Stack table AND Decisions Log entries with alternatives |
| Methodology (this phase) | Walking skeleton or tracer bullets if either was chosen | System Overview (mention as the first deliverable) |

**The Decisions Log is where blueprint's stack decisions get formally recorded.** Every decision from the stack-decisions step becomes a DECISION-NNN entry with context, options considered, decision, and consequences. This is the single most valuable section of ARCHITECTURE.md — it's what prevents the team (and Claude in future sessions) from re-litigating choices that have already been made.

## The template

```markdown
# [Project Name] — Architecture

> On-demand reference. Load via `@docs/ARCHITECTURE.md` when building subsystems.

## Design Principles

1. **[Principle]** — [one sentence, constraint-style]
2. **[Principle]** — [one sentence]
3. **[Principle]** — [one sentence]

[3–7 principles maximum. Each one is a constraint the system enforces, not
a philosophy statement. "All state is local" is a principle. "Code should be
clean" is not.]

## Tech Stack

| Layer | Tool | Version | Notes |
|-------|------|---------|-------|
| Language | [from stack decisions] | [version] | [one-line note] |
| Framework | ... | ... | ... |
| Storage | ... | ... | ... |
| Build | ... | ... | ... |
| Test | ... | ... | ... |
| CI | ... | ... | ... |

## System Overview

[How major components interact. Data flow, message patterns, shared state.
Focus on RELATIONSHIPS, not descriptions — the agent reads the code for details.]

[For pre-implementation projects, this section describes the *intended* shape
based on stack decisions and the brief's proposed approach. Mark it as
"intended architecture, will be refined as code is written."]

## Project Structure

[ONLY if non-obvious. If the layout follows framework conventions, skip this —
it actively misleads when it goes stale. If included, keep it annotated and
mark which directories are off-limits.]

## Component Deep Dives

### [Component]
[What it does, what it depends on, key interfaces.
Include behaviour/interface definitions as code.]

[For pre-implementation, this section is sparse — just the components named
in the brief's proposed approach with one-line descriptions each.]

## Testing Architecture

[Test tiers, fixture strategy, mocking approach. What tests WHERE.
Inherit from scaffold.md's testing philosophy — do not invent.]

## Decisions Log

[Append-only. Never delete. Supersede with new entries when decisions change.]

### DECISION-001: [Title — one of blueprint's stack decisions]
**Date:** YYYY-MM-DD | **Status:** Accepted
**Context:** [What problem was being solved, what constraints applied — pull from problem_brief.md and scaffold.md]
**Options:**
1. [Option A — pros/cons/trade-offs]
2. [Option B — pros/cons/trade-offs]
3. [Option C if relevant]
**Decision:** [Chosen option + the one-sentence justification from the stack decisions step]
**Consequences:** [What follows from this decision — both intended and side-effect]

### DECISION-002: [Next stack decision]
[same format]

[One entry per significant stack decision blueprint made. Library-level picks
do not get entries — only load-bearing structural choices.]
```

## What does NOT belong here

- **Day-to-day workflow** — that's STANDARDS.md and CONTRIBUTING.md
- **Commands and tooling specifics** — that's CLAUDE.md
- **Marketing/positioning** — that's STRATEGIC_BRIEF.md if it exists, README.md otherwise
- **Cascade-internal metadata** — that's `docs/cbk/blueprint.md`
- **Implementation tutorials** — ARCHITECTURE.md describes structure, not how-to
- **Library version pinning detail** — the Tech Stack table lists major versions; lock files handle exact pins

## Decisions Log discipline

The decisions log is the section blueprint cares most about, because it's the place where the stack-decisions step output gets recorded in a form that survives the cascade. Three rules:

1. **Append-only.** Never delete a DECISION entry. If a decision is reversed, write a new entry that supersedes it (with the new entry's Status as "Accepted, supersedes DECISION-NNN" and the old entry's Status changed to "Superseded by DECISION-MMM").
2. **Alternatives must be real.** Each entry lists 2–3 options with their actual trade-offs, not strawmen. "We considered using bash but rejected it because it doesn't scale" is fine. "We considered everything else but they were all worse" is not.
3. **Justification ties to inherited context.** The Decision field for each entry should reference the brief's constraint, the scaffold's quality bar, or the inherited team context that drove the choice. Decisions without inherited context look arbitrary.

## HITL presentation

When presenting the drafted ARCHITECTURE.md for review, lead with the Decisions Log section: *"Here's the draft ARCHITECTURE.md. The most important section is the Decisions Log at the bottom — it records every stack decision with alternatives. Please check that section first."*

Common revision requests:
- "DECISION-003 should mention X as a rejected option" → add to Options
- "The justification for DECISION-001 doesn't match the brief" → fix the Decision/Context fields
- "We need a principle about Y" → add to Design Principles
- "Tech Stack table is missing Z" → add the row

Iterate until approved. Then commit via GitHub MCP to `docs/ARCHITECTURE.md`.

## Light-mode behavior

If the user invoked light mode and asked for ARCHITECTURE.md, produce a tighter version:

- **Skip Project Structure** unless the layout is non-obvious and the user explicitly wants it
- **Skip Component Deep Dives** for pre-implementation projects
- **Decisions Log entries get the four fields** (Context, Options, Decision, Consequences) but each in 1–2 sentences instead of paragraphs
- **Testing Architecture** is one paragraph instead of structured sections

Target: 1–2 pages for light mode, 3–5 for default. Skip the doc entirely if the user said "no architecture doc."
