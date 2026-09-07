# Blueprint output template

The template for `docs/cbk/blueprint.md` — the cascade artifact this phase produces. Mirrors the shape of `scaffold.md`: cascade metadata at the top, substantive content below. Read by every later cascade phase (framing, rough-in, finish) and by Claude Code in any future session that needs to understand the strategic context of the project.

## What the file is for

`docs/cbk/blueprint.md` is the cascade's record of the strategic decisions blueprint made. It's not a foundation doc for human readers — it's a phase artifact for the cascade itself. The audience is the next phase of the cascade and any future Claude session that needs context about why the project is shaped the way it is.

It contains two kinds of information:

1. **Cascade metadata** — the decisions blueprint made (stack, methodology) plus pointers to where they're recorded in human-facing form (ARCHITECTURE.md, STANDARDS.md). This section is read first by any later phase.
2. **Strategic content** — the initiative as a whole: goal, success criteria, not in scope, dependencies, workstreams, open questions. Same shape as the existing initiative-planner output, with cascade-specific framing.

The combination of the two is what makes this file the single source of truth for "why are we building this and how is it organized."

## What to inherit before drafting

This is the file that ties the whole blueprint phase together, so inheritance is comprehensive:

| From | What to extract |
|---|---|
| `problem_brief.md` problem statement | Goal section (refined for the initiative scope) |
| `problem_brief.md` target users | Goal section context |
| `problem_brief.md` no-gos | Not In Scope section — verbatim, do not relax |
| `problem_brief.md` success criteria | Success Criteria section, possibly refined or expanded |
| `problem_brief.md` "Notes for blueprint" | Cascade metadata: deferred decisions list (now resolved) |
| `scaffold.md` Cascade metadata | Cascade metadata: planning backend + knowledge backend (verbatim) + hierarchy levels |
| `scaffold.md` cascade artifact layout | Cascade metadata: confirms `docs/cbk/` location |
| `scaffold.md` team shape | Implicit context for the workstreams section (how granular projects should be) |
| Stack decisions (this phase) | Cascade metadata: one-line per decision with pointer to ARCHITECTURE.md DECISION-NNN |
| Methodology selection (this phase) | Cascade metadata: top-level methodology + planning patterns + citations |
| Workstreams (this phase) | Core Projects and Horizon Projects sections |

## The template

```markdown
# Blueprint: <project name>

> **Phase**: blueprint (3 of 6) | **Status**: complete | **Date**: <YYYY-MM-DD>
>
> Produced by the blueprint skill from the problem brief and scaffold output.
> Read by framing (phase 4), rough-in (phase 5), and finish (phase 6).

---

## Cascade metadata

**Planning backend**: <github-issues | linear | in-repo-markdown> *(inherited verbatim from scaffold.md's Cascade metadata)*
**Knowledge backend**: <notion | none> *(inherited verbatim from scaffold.md)*
**Hierarchy levels**: 3 issue levels (workstream → framing → rough-in)

### Stack decisions

<One line per decision. Each line points to the full ARCHITECTURE.md entry
for context, alternatives, and consequences.>

- **Language**: <decision> — see ARCHITECTURE.md DECISION-001
- **Framework**: <decision> — see ARCHITECTURE.md DECISION-002
- **Storage**: <decision> — see ARCHITECTURE.md DECISION-003
- **Distribution**: <decision> — see ARCHITECTURE.md DECISION-004
- **Testing/CI**: <decision> — see ARCHITECTURE.md DECISION-005
- <etc — one entry per stack category that had a decision>

### Methodology

**Top-level**: <Shape Up | Scrum | Kanban | other> — <one-sentence justification tied to inherited context>
- Source: <citation from methodology register>

**Planning patterns**:
- <vertical slicing | walking skeleton | tracer bullets | etc.> — <one-sentence why>
- Source: <citation>

### Resolved deferrals from problem brief

<For each item in the brief's "Notes for blueprint" section, state how it
was resolved. If deferred further, note the trip-wire.>

- **<deferred item>**: <how resolved | further deferred until <condition>>
- <etc>

### Foundation docs produced

- <list of which foundation docs were actually produced — may be fewer than 6 in light mode>
- Tooling configs: <list of config files committed>

---

## Goal

<One paragraph. What this initiative achieves and why it matters. Concrete
enough to evaluate against, broad enough to encompass all workstreams.
Adapted from problem_brief.md problem statement, refined for the initiative
scope as a whole.>

## Success Criteria

<Concrete, verifiable criteria. Each one demoable or testable. Carries
forward from problem_brief.md success criteria, possibly expanded with
blueprint-specific criteria (e.g., "ARCHITECTURE.md decisions log has
entries for all load-bearing stack choices").>

- [ ] <criterion 1>
- [ ] <criterion 2>
- [ ] <etc>

## Not In Scope

<From problem_brief.md no-gos verbatim, plus any additional exclusions
blueprint identified during stack decisions or methodology selection.
Do not relax brief no-gos.>

- **<category>**: <exclusion and why>
- <etc>

## Dependencies

<External initiatives, services, APIs that the project depends on. Map
which workstreams are blocked by which dependencies.>

| Project | External Dependency | Blocked? |
|---------|--------------------|---------| 
| <project name> | <what it needs> | Yes/No/Partial |

[Or, if dependencies are minimal, a 1–2 sentence prose summary instead of a table.]

## Core Projects (ordered by dependency chain)

<Workstreams, grouped by build sequence. Each project has: name, one-
sentence purpose, key constraint or dependency. The framing phase will
turn each of these into a proper project specification.>

### Layer 1: <layer name> (build first)

**1. <Project Name>** — <one-sentence purpose>. <Key constraint or dependency.>

**2. <Project Name>** — <purpose>. <constraint>.

### Layer 2: <layer name> (build second, needs layer 1)

**3. <Project Name>** — ...

[Continue per layer.]

## Horizon Projects (tracked for context, no timeline)

<Real projects expected to build someday but no timeline pressure. Exist
in the initiative for context — when designing core projects, knowing the
horizon helps make forward-compatible choices.>

**N. <Project Name>** — <one-sentence purpose>.

## Open Questions

<Unresolved items that carry forward to framing. NOT failures — honest
about what couldn't be resolved at the blueprint level. Each item should
ideally have a trip-wire for when it gets revisited.>

- <Question 1> — revisit during <framing | rough-in | first real run>
- <etc>

## Notes for framing (next phase)

<What framing needs to know that isn't already in the rest of this file.>

- <Note 1>
- <Note 2>

## Credential model (evergreen)

[**What goes here**: the evergreen background — what credentials exist, why
each is needed, how they rotate, what scopes they have. NOT the ephemeral
"do these steps once" runlist — that lives in the handoff issue (see
`references/handoff-issue.md`). The split is: evergreen reference content
stays in this doc, one-time setup commands move to the issue tracker.]

[For each credential type the project uses, document:
- What it is (PAT, App, API key, etc.)
- What it's used for (CI auth, local MCP, deployment, etc.)
- Where it lives (env var, secret store, gitignored config file)
- Rotation cadence and trigger
- The minimum scopes required]

[Example structure for a project with two credential contexts:

| | **GitHub App** | **Fine-grained PAT** |
|---|---|---|
| Used by | `claude-code-action` in CI | Local GitHub MCP |
| Lives where | Repo secret + App install | `.mcp.json` (gitignored) |
| Authenticates as | App identity (bot) | The user |
| Rotation | App: re-install if compromised; secret: every 180d | Every 90d |
]

**Why this is in blueprint.md and not the handoff issue**: credential models don't go stale the way setup commands do. The user comes back to this section months later when they need to rotate the PAT or understand why a permission failed; it's a reference, not a checklist. The handoff issue is one-time work that closes; the credential model is forever.
```

## Amendments *(append-only)*

[Blueprint is a cascade event — immutable after commit except this section, § Retired
justifications and the Stack decisions table (`cbk-conventions.md` § Mutation discipline). A later phase that learns this blueprint was wrong in a way
that does not warrant a re-blueprint appends one dated row: what was stated, what
is true, which phase found it, where the correction landed (an ADR, a frame, a
rule). Never edit the section it amends; the row points at it.]

| Date | Amends (§) | Was | Is | Found by | Landed in |
|---|---|---|---|---|---|

## Retired justifications

[Decisions in this blueprint whose original justification was later retired — a
constraint that lifted, a dependency that changed, a measurement that aged out.
The decision may still stand; the row records that its original reason no longer
does, so nobody re-derives the decision from a dead premise. Dated; append-only.]

| Decision | Original justification | Retired on | Because | The decision now rests on |
|---|---|---|---|---|

## PR lifecycle

[Numbered, so every later phase and command cites a step number rather than a
paraphrase. The default; edit to what this project actually does:]

1. Branch per `cbk-conventions.md` § Branch naming (the issue-less form for maintenance)
2. Red tests, then the implementation — atomic commits
3. The `check` task green
4. `/simplify`, then `pr-review-toolkit:review-pr` with the sweep beside it — the floor, once
5. Draft PR carrying `## Review gate` and `## Triage`
6. The operator flips to ready; automated review runs where it is wired
7. `/pr-respond` per feedback round; `## Triage — round N` appended to the body
8. Merge (squash); the post-merge checklist from the `/finish` hand-off

## Newcomer traps *(gated on the operator's tool comfort)*

[Include only when scaffold's discovery recorded the operator as new to a tool in
this stack; omit for an experienced operator. One bullet per trap actually
expected here — the command that looks right and is not, the setting that
silently defaults, the file that must never be hand-edited — each naming the
reference doc that explains it.]

## Source precedence over non-cascade documents

[When a non-cascade document — a vendor README, an inherited design doc, a wiki
page, the frozen corpus — disagrees with a cascade artifact, which wins, in
order. The default: ADRs › this blueprint › the active frame › the `docs/`
foundation docs › the frozen corpus (through its errata) › external documents.
A document not on this list is context, not authority.]

## Operator runbooks *(the fifth foundation surface)*

[`docs/runbooks/` — one file per recurring operator task the code does not
automate: a deploy, a key rotation, a data migration, the measurement procedure.
Blueprint creates the directory with an index and the first runbook the stack
already needs; later phases add files there, never sections here. Each runbook:
preconditions, the commands verbatim, the verification, the rollback.]

## Domain label *(with its body contract)*

[The one label that marks an issue or PR as touching this project's guarded
domain surface — a schema, a protocol, a safety boundary — as `domain:<name>`,
and the block its PR body must carry: the heading, what it states (the invariant
touched, the check that proves it holds), and that a PR carrying the label
without the block is REQUEST CHANGES. The auto-review prompt reads this section.]

## What used to be here and isn't anymore

Earlier versions of this template had a "Manual setup runlist" section with the full first-build command sequence (run mise install, create the PAT with these scopes, run setup-claude.sh, install the GitHub App, etc). That content has moved to the handoff issue per the seventh-step pattern. Keeping it in blueprint.md was the failure mode of "doc section that goes stale the moment the user completes it" — the handoff issue closes naturally when the work is done, the doc would have to be edited.

**Rule**: if you're drafting blueprint.md content that reads like "do these steps once," stop — that content goes in the handoff issue. blueprint.md is for evergreen reference only.

## Planning-axis-aware behavior

On the `github-issues` and `in-repo-markdown` axes blueprint also writes `docs/cbk/ROADMAP.md` from `templates/roadmap.md`, seeded from § Core Projects: one *planned* row per project, the bootstrap row pointing at the handoff issue, `## Now` naming the first runnable command. It is a status surface, freely mutable, never the audit trail.

**`github-issues` planning**: this file is the *only* place the initiative content lives. There's no Linear initiative entity. Framing will read this file, decompose the workstreams into proper project specs, and create the GitHub workstream parent Issues + framing sub-issues from there.

**`linear` planning**: this file still gets committed to `docs/cbk/blueprint.md`, AND a Linear initiative entity gets created via Linear MCP with the same Goal, Success Criteria, Not In Scope, and Dependencies content. The file is the source of truth; the Linear entity is a queryable mirror. Framing reads the file; Linear is for human navigation and roll-up reporting.

**`in-repo-markdown` planning**: this file is the only place the initiative content lives. There's no external planning backend at all. The Workstreams table inside this file is the workstream registry; framing operates against the markdown directly.

Across all three planning axes, the file structure above is the same. Axis differences only affect *what additional artifacts get created* (Linear initiative, GitHub Issues, or neither), not what goes in the file.

## Authoring guidance per section

**Cascade metadata** — keep it terse. One line per decision, pointer to ARCHITECTURE.md for the full story. Resist the urge to duplicate ARCHITECTURE.md's Decisions Log here — pointers, not copies.

**Goal** — one paragraph, concrete. Test: read it cold to a new team member, can they tell you what the project is in their own words? If no, rewrite.

**Success Criteria** — each item must be demoable or testable. "Users can hold multi-turn conversations" is good. "The architecture is clean" is bad. 5–12 items typically.

**Not In Scope** — the most underrated section. Carries forward the brief's no-gos plus any additional exclusions blueprint identified. Be specific: "Mobile app" beats "other platforms."

**Dependencies** — map them precisely. The most valuable output is knowing what can proceed in parallel vs. what's blocked.

**Core Projects** — group by dependency layer, not by subsystem type. Each workstream gets: name, one sentence purpose, key constraint/dependency. Don't over-specify — framing will turn these into real project specs.

**Horizon Projects** — these are the "we'll get to them" items. Existing in the doc helps designers make forward-compatible choices for the core projects.

**Open Questions** — failures are silent, open questions are honest. Anything blueprint couldn't resolve goes here with a trip-wire for revisit.

## HITL gate (gate 6 — final)

The blueprint.md file is presented for review *last*, after all six foundation docs have been produced and approved. At this gate the user is reviewing the cascade artifact itself: *"Here's docs/cbk/blueprint.md, the cascade's record of this phase. The metadata at the top points to ARCHITECTURE.md for stack decision detail. The strategic content below carries forward from the problem brief. This is the last gate — once you approve, blueprint marks itself complete and framing inherits from this file."*

Common revision requests:
- "DECISION-005 in the metadata is missing X" → fix the metadata pointer
- "The Goal paragraph is too internal — make it readable to a stranger" → rewrite
- "Move project X from core to horizon" → reorder
- "Add an open question about Y" → add to Open Questions
- "The dependency map is wrong" → fix

Iterate until approved. Then commit via GitHub MCP to `docs/cbk/blueprint.md`. When planning = `linear`, also create the planner's initiative entity with matching content (see § planning-axis notes above).

## Light-mode behavior

Even in light mode, the cascade metadata top section is non-negotiable — that's how later phases find the axis values, hierarchy levels, stack decisions, and methodology choice. What can collapse:

- **Foundation docs produced list** — already short
- **Resolved deferrals** — one line per item instead of detailed
- **Goal** — one sentence instead of one paragraph
- **Success Criteria** — 3–5 items instead of 5–12
- **Not In Scope** — preserve brief no-gos, skip additional exclusions
- **Dependencies** — prose summary instead of table
- **Core Projects** — flat list instead of layered, name and one-sentence purpose only
- **Horizon Projects** — skip entirely
- **Open Questions** — keep, but terse

Target: 1 page for light mode, 3–5 pages for default. The cascade metadata top section stays intact in both — the rest collapses.
