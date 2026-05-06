# Methodology selection step

The second substantive step after stack decisions. Picks the development methodology from the methodology register based on context inherited from scaffold and the problem brief. The methodology choice influences how STANDARDS.md frames PR cycles, how blueprint.md groups workstreams, and how framing structures projects in the next phase.

## The register

The methodology register lives outside this skill — it's a shared reference across all six cascade phases at `methodology_register.md` in the cascade root. Read it before this step if you haven't already in this session. It contains entries for Shape Up, Scrum, Kanban, vertical slicing, walking skeleton, tracer bullets, YAGNI, spike solutions, augmented coding, harness engineering, spec-driven development, TDD with AI agents, context engineering, trunk-based development, continuous delivery, code review, pair programming, ADRs, and DORA metrics.

Blueprint cares mostly about the **scoping methodologies** category (Shape Up, Scrum, Kanban) for the top-level methodology choice, and the **planning patterns** category (vertical slicing, walking skeleton, tracer bullets, YAGNI, spike solutions) for how to structure the workstreams that go into `blueprint.md`. The other categories matter at later phases (scaffold already touched some, framing/rough-in/finish will touch others).

## Decision tree for the top-level methodology

Use inherited context to propose a default. The branches:

**Solo + bursty + no deadline pressure** → **Shape Up appetite-based**, applied per-deliverable rather than per-six-week-cycle. The user fixes scope per pack/feature/release, and the calendar floats. This is a strong default for hobby projects, side projects, and any solo work where the user wants discipline without ceremony.

**Solo + steady + flow-shaped work** → **Kanban**, with WIP limits even for one person. Useful when the project is more about ongoing maintenance, content production, or research than feature shipping. Less common as a default, but real.

**Small team (2–5) + cross-functional + iterative product** → **Scrum** if the team has discipline for the ceremonies, **Shape Up** if they don't. Default to Shape Up unless the team has explicitly used Scrum before and liked it. Scrum with a small team that hasn't done it before usually becomes "FlaccidScrum" (Fowler's term — Scrum without the engineering practices that make it work).

**Small team (2–5) + ongoing operations or maintenance** → **Kanban** with explicit WIP limits.

**Larger team (6–10)** → almost certainly Scrum or Shape Up depending on culture; Kanban as a fallback for ops-heavy work. Larger teams need more explicit coordination structures than solo or pair contexts.

**Brownfield with unknown architecture** → suggest a **walking skeleton** as the first concrete deliverable regardless of top-level methodology, so the team validates the architecture before piling on features.

**Greenfield with high uncertainty** → suggest **tracer bullets** to validate the path through all layers, plus a top-level methodology that supports iteration (Shape Up or Kanban, not Scrum's fixed sprint commitment).

**Multi-month strategic effort with known phases** → top-level methodology can be Scrum or Shape Up; the more important add is **vertical slicing** for how workstreams get structured in `blueprint.md`.

## The detect-then-confirm phrasing

Same pattern as stack decisions and consultation. One sentence proposal, one sentence justification tied to inherited context, one override path:

> *"Given the bursty solo cadence and your stated discipline of fixed scope per pack from the brief, I'd recommend Shape Up's appetite-based scoping — fixed scope per pack, variable calendar between packs (Singer, Shape Up ch. 3). Sound right, or would you rather use something else?"*

> *"Your scaffold output described a 4-person team doing iterative product work with no prior methodology experience. I'd recommend Shape Up over Scrum here — the appetite-based shaping is easier to start cold than Scrum's full ceremony set. (Singer, Shape Up; contrast with Schwaber & Sutherland, Scrum Guide.) Or stick with Scrum if anyone on the team has run it before."*

> *"You mentioned ongoing maintenance work with no defined endpoints. Kanban with WIP limits is the natural fit (Anderson, Kanban, 2010) — start with your current process and improve it incrementally. Sound right?"*

**Citation discipline.** Always name the source. Recommendations without citations don't get recorded. Same rule as consultation.

## Layering planning patterns on top

The top-level methodology answers "how does work get organized over time?" The planning patterns answer "how do specific deliverables get structured?" Both matter for `blueprint.md`'s workstreams section.

After picking the top-level methodology, propose 1–2 planning patterns to layer on:

- **Vertical slicing** for how workstreams get carved up. Almost always a good idea — propose by default unless the brief explicitly contradicts it.
- **Walking skeleton** as the *first* workstream, when there's architectural uncertainty. Always a good idea for brownfield or unfamiliar stacks.
- **Tracer bullets** as the first workstream, when the path through all layers needs validation. Often paired with walking skeleton.
- **Spike solutions** as a *named* deferral mechanism for risks the brief flagged as rabbit holes. "We'll spike the streaming question in week 1" gets recorded as an open question in `blueprint.md` with a trip-wire.
- **YAGNI** as a guiding rule rather than a discrete deliverable — surface it during stack decisions if the user is reaching for speculative features, but don't burn a register slot just to mention it.

## How methodology influences the foundation docs

This is the main reason methodology selection happens before doc production. Each methodology shapes specific doc sections:

| Doc | What methodology influences |
|---|---|
| **CLAUDE.md** | Workflow norms ("we ship one feature at a time and run the full test suite between each"), the way Claude Code is expected to interact with the project |
| **STANDARDS.md** | PR cycle length, review rigor, testing expectations, how quality gates relate to methodology cycles (if any), whether ADRs are required for stack changes |
| **CONTRIBUTING.md** | "How to make a change" walkthrough — Shape Up reads differently than Kanban reads differently than Scrum |
| **ARCHITECTURE.md** | Whether walking skeleton or tracer bullets are first deliverables; if so, that goes in the system structure section |
| **README.md** | Almost nothing — methodology rarely matters to the README's audience |
| **blueprint.md** | Workstreams section — organized by methodology (Shape Up = appetite blocks; Kanban = continuous flow; Scrum = sprint groupings) |

When producing each foundation doc, blueprint should pull the methodology decision into the relevant sections rather than making the user re-state it.

## The HITL gate (gate 3)

After proposing a top-level methodology and 1–2 planning patterns, present the full methodology summary inline:

```
## Methodology selection

**Top-level**: <Shape Up | Scrum | Kanban | other> — <one-sentence justification>
- Source: <citation>

**Planning patterns**:
- <Vertical slicing | Walking skeleton | Tracer bullets | etc.> — <one-sentence why>
- Source: <citation>

**How this shapes the foundation docs**:
- STANDARDS.md: <key implication>
- CONTRIBUTING.md: <key implication>
- blueprint.md workstreams: <key implication>

Sound right, or would you rather adjust before I start drafting docs?
```

Iterate until the user approves. Methodology choice then propagates into every foundation doc that gets produced in the next stage.

## Failure modes specific to methodology selection

- **Methodology dogmatism.** Recommending Shape Up because the cascade examples use it, not because it fits this project. The register is a menu, not a prescription. If the user's context points to Kanban, propose Kanban.
- **Methodology cargo-culting.** Recommending Scrum because the team is "agile" without checking whether they actually want sprint ceremonies. Most teams who say "we're agile" mean "we don't do waterfall," which is not the same as wanting Scrum.
- **Skipping the planning patterns.** Top-level methodology alone is incomplete — the planning patterns are what make the methodology actionable for the workstreams. At least propose vertical slicing.
- **No citation.** Every recommendation needs a source from the register. Skill of the agent, not preference of the agent.
- **Over-specifying.** Methodology selection is not the place to define sprint length, exact WIP limits, or ceremony schedules. Those are framing-phase decisions. Blueprint picks *what* methodology, not *all the parameters of how to run it*.

## Light-mode behavior

If the user invoked light mode, collapse to:

- **One sentence proposing the top-level methodology** with citation, based on inherited context
- **One sentence proposing 1 planning pattern** (almost always vertical slicing), with citation
- **One-sentence approval ask**

The full per-doc impact table can be skipped — blueprint will reference the methodology choice when producing each doc anyway. If the user names a methodology directly ("use Shape Up") without invoking light mode, skip the proposal entirely and just confirm the citation.

What light mode *cannot* skip: the citation. Recommendations without sources are bugs even in light mode.
