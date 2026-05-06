# Rough-in inheritance

This file is the operational detail behind rough-in's Step 1 (Inheritance and pre-flight checks). It covers what rough-in reads, how it reads it, what verbatim summary it produces, and the protocol for the mandatory deferred meta-issues pre-flight check.

Rough-in is the fifth phase of the cascade. It inherits from four upstream artifacts (problem brief, scaffold output, blueprint, framing) and one parent issue (the framing capability sub-issue it's about to decompose). Inheritance discipline is the foundation of every cascade phase but rough-in's stakes are particularly high — the sub-sub-issues it produces will be handed to Claude Code via `/finish` for execution, so any inheritance gap shows up as a downstream execution failure.

## What rough-in must read in full

**Required inputs, read in this order:**

1. **`docs/cbk/problem_brief.md`** — for no-gos and constraints still relevant to implementation. Rough-in is the closest cascade phase to actual code, so the no-gos that felt abstract during framing now have concrete bite ("don't use feature X" means rough-in must not write a spec that requires feature X).

2. **`docs/cbk/scaffold.md`** — for the quality bar, working conventions (branch naming, commit format, label taxonomy), and tool comfort. The quality bar is the highest-leverage piece — it informs how strict the acceptance criteria need to be and how much technical detail belongs in each spec.

3. **`docs/cbk/blueprint.md`** — for stack decisions, the methodology, and the workstream entry that this rough-in operates within. Blueprint's workstreams table is where rough-in finds the workstream slug, but rough-in always re-verifies the slug from the parent framing sub-issue's title (see slug inheritance below).

4. **`docs/cbk/frame-NN.md`** — the **highest-numbered active** framing for the workstream being roughed-in. This is the load-bearing input. Rough-in reads:
   - The refined definition section (what the workstream is, restated by framing after research)
   - The specific milestone being roughed-in (the M_n entry in the milestones list, with its capability statement, rough issues list, and acceptance signal)
   - **The Pre-flight checks table** (mandatory pre-flight check input)
   - The Interface commitments table (for any commitments this milestone satisfies or relies on)
   - The Open questions section (some may need resolution during rough-in's research phase)

5. **The framing sub-issue on the planning backend** (via `issue_read` in github-only profile) — for the slug inheritance, the F-number, and any comments posted after framing committed (which may contain user notes or decisions that aren't in frame-NN.md yet).

6. **`docs/ARCHITECTURE.md`**, **`docs/STANDARDS.md`**, **`CLAUDE.md`** — foundation docs for architectural constraints, testing philosophy, and command conventions. Rough-in's specs cite these by section name, so rough-in must know which sections exist and what's in them.

**The "in full" requirement is non-negotiable**: paraphrasing or skimming any of these inputs is the failure mode. Rough-in's downstream output (the sub-sub-issue specs that Claude Code will execute) depends on accurate inheritance, and inaccuracy here propagates unrecoverably into the execution phase.

## Slug and F-number inheritance from the parent framing sub-issue

Rough-in must construct sub-sub-issue titles in the format `[<workstream-slug>:F<#>:R<#>] <intent>`. The slug and F-number both come from the **parent framing sub-issue's title**, never from re-derivation:

1. Read the parent framing sub-issue via `issue_read` (the issue number is provided by the user during Step 2 milestone selection, or inferred from the README.md index)
2. Parse the title — it's in the format `[<slug>:F<#>] <capability>`
3. Extract the slug (the part inside brackets before the colon) and the F-number (the part after the colon, after the F)
4. Construct rough-in titles by appending `:R<#>` and the intent: `[<slug>:F<#>:R<#>] <intent>`

**Never re-derive the slug** from the workstream name in `blueprint.md` § Workstreams or from the capability name in `frame-NN.md` § Milestones. Re-derivation is how slug drift happens — a user might rename a workstream after blueprint committed it but before framing inherited it, and any cascade phase that re-derives instead of inheriting will produce a slug that doesn't match the existing parent issue. Always inherit from the parent issue's existing title.

If the parent framing sub-issue's title doesn't match the expected `[<slug>:F<#>] <capability>` format, **stop and surface the gap** — this means either the framing was created outside the cascade (manually) or the framing skill was running an older version. Don't proceed with sub-sub-issue creation until the parent's title is fixed.

## Verbatim inheritance summary template

After reading all required inputs, rough-in presents an inheritance summary to the user as the first HITL gate of Step 1. The summary is **verbatim, not paraphrased** — direct quotes from the source documents in markdown blockquotes. Paraphrasing is the failure mode.

Template:

```markdown
## Rough-in inheritance summary

**From `problem_brief.md`** (the constraints still relevant at this layer):

> [Verbatim quote of the no-gos section, or the specific no-gos that
> matter for this milestone]

> [Verbatim quote of the appetite, if Shape Up methodology was selected
> in blueprint, since rough-in respects appetite as the constraint]

**From `scaffold.md`** (working conventions and quality bar):

> Quality bar: [verbatim from scaffold.md]
>
> Branch naming: [verbatim]
>
> Commit format: [verbatim]
>
> Testing philosophy: [verbatim from the development preferences section]

**From `blueprint.md`** (stack decisions and the workstream entry):

> [Verbatim quote of the workstream's entry in blueprint.md § Workstreams,
> including its purpose, scope sketch, and any links]

> Stack decisions relevant to this milestone: [verbatim]

> Methodology: [verbatim from blueprint.md § Methodology]

**From `frame-NN.md`** (the framing this rough-in operates within):

Refined definition:

> [Verbatim quote]

The milestone being roughed-in — **M<n>: <name>**:

> Capability statement: [verbatim]
>
> Rough issues:
> - [verbatim list]
>
> Acceptance signal: [verbatim]

**Interface commitments this milestone satisfies or relies on**:

> [Verbatim quote of the relevant rows from frame-NN.md § Interface Commitments]

**Open questions from framing relevant to this milestone**:

> [Verbatim quote of any rows from frame-NN.md § Open questions where
> the trip-wire mentions "rough-in" or this specific milestone]

**From the parent framing sub-issue** (#<N>):

> Title: [exact title as on GitHub]
>
> Slug inherited: `<slug>`
>
> F-number inherited: F<#>
>
> Comments since framing committed (if any): [verbatim or "none"]

**From foundation docs** (sections rough-in will cite in specs):

- `docs/ARCHITECTURE.md § <section name>`: [one-line summary of why this matters for this milestone]
- `docs/STANDARDS.md § <section name>`: [one-line summary]
- `CLAUDE.md § <section name>`: [one-line summary]

**Prior-milestone code state already on `main`** (what the framing's rough-issues list assumes vs. what's already shipped):

> [For each rough-issue in the milestone's framing sketch, classify against the current codebase:
>
> - **Already done (drop from decomposition)**: `<rough-issue intent>` — landed in F<N>:R<M> (PR #<N>, commit `<sha>`). Cite the file(s) that prove it.
> - **Partially done (refine scope)**: `<rough-issue intent>` — `<what's done>` already in `<file>`; remaining work is `<what's left>`.
> - **Not started (decompose normally)**: `<rough-issue intent>` — no relevant code on `main`.
>
> If the framing sketch's count diverges from the surviving "not started" count after this classification, surface the divergence explicitly in the issue plan (Step 4) so the user sees the compression rationale at a glance.]
```

**Why this subsection is mandatory**: framing-sketch rough-issue lists are written before the milestone's siblings have shipped, so by rough-in time some of the sketch items may already exist on `main` (landed in earlier milestones, in scaffold, in side cleanup commits, etc.). Without this classification, rough-in proposes redoing already-done work — concretely, real-world cascade runs have hit this when an item that was still in a milestone's sketch had already shipped in an earlier milestone (e.g., a coverage-upload setup that landed in an infrastructure milestone but was still listed in the sketch for a later milestone), forcing rough-in to compress the issue count with explicit rationale rather than mechanically reproducing the sketch. Doing the classification at inheritance time makes the compression visible and justifiable rather than improvised.

The summary is dense by design. Anything skipped here will need to be re-fetched later in the rough-in run, and re-fetching mid-run is where errors creep in. Front-load the reading.

## The mandatory deferred meta-issues pre-flight check

This is the single most important piece of rough-in's inheritance discipline. Framing produces a Pre-flight checks table in `frame-NN.md` capturing concerns that don't decompose into a specific milestone but DO gate transitions or rough-in. Rough-in **must check this table before decomposing any milestone** — see `references/backends.md` § Deferred meta-issues for the full first-class artifact discipline.

**Why this check exists**: the most common rough-in failure mode is decomposing a milestone whose preconditions haven't been met. Framing's open questions section catches some of these, but the meta-issues table is where structural blockers live (the automation recommender that has to land between M2 and M3, the architectural decision that has to be made before M4 can start, etc.). Without the check, rough-in would happily produce sub-sub-issues for M3 even though M3's start depends on a meta-issue that's still open. The downstream `/finish` phase would then attempt to execute work that was always going to fail because its prerequisites weren't ready.

### The check protocol — six steps

1. **Read the framing's Pre-flight checks section** from frame-NN.md. If the section is missing entirely (older framing pre-dating the deferred-meta-issues feature), this is itself a gap — surface it to the user as framing drift and ask whether to (a) loop back to framing to add the table, (b) confirm there are no meta-issues for this framing and proceed with explicit acknowledgment, or (c) abort the rough-in run.

2. **Filter the table to rows where the Blocks column mentions M_n start** (where M_n is the milestone being roughed-in). Other meta-issues in the table that don't block this specific milestone are not relevant to this check — they may block other milestones, but rough-in only cares about the ones blocking the milestone it's about to decompose.

3. **For each blocking meta-issue, read the corresponding GitHub issue state** via `issue_read`. The issue number is in the table's first column.

4. **Classify each issue's state**:
   - **Closed with `state_reason: completed`** → resolved, no action needed
   - **Closed with `state_reason: not_planned` or `state_reason: duplicate`** → ambiguous. Closed without completion. Ask the user explicitly: *"Meta-issue #<N> '<title>' is marked as not-planned. Does this count as resolved for the purpose of M_n's preconditions, or is it still blocking? If still blocking, M_n cannot be roughed-in until it lands."*
   - **Open** → unresolved blocker. Stop and surface (see step 5).

5. **If any meta-issue is still blocking, stop and surface the gap** with the three options:
   - **(a) Resolve the meta-issue first and resume rough-in** — the user works on the meta-issue (perhaps via a separate finish run if it has a `/finish`-able body, or manually), closes it, and tells rough-in to resume the check from step 3
   - **(b) Explicitly clear the blocker as no longer applicable** — the user judges that the meta-issue is no longer actually blocking M_n (e.g., the framing was wrong about the dependency, or the meta-issue's concern was addressed by a different mechanism). Rough-in records this decision in its inheritance summary as: *"Meta-issue #<N> was explicitly cleared by user as no longer blocking M_n. Reason: <user's words>."* and proceeds.
   - **(c) Abort the rough-in run** — the user decides this milestone can't be roughed-in yet, and rough-in stops cleanly without producing any specs or making any commits.

6. **Repeat steps 3-5 for every blocking meta-issue** before any decomposition work starts. The check must complete entirely before Step 2 (milestone selection confirmation) runs.

### Special case: the framing has no Pre-flight checks section

If the section is present but says "No deferred meta-issues from this framing" (the explicit empty-state phrase from the cascade-meta template), the check passes immediately. This is the normal case for most framings — meta-issues are common but not universal, and an empty table is meaningful signal that framing considered the question.

If the section is missing entirely (framing predates the feature), surface as framing drift per step 1.

### Special case: meta-issue depends on another meta-issue

A meta-issue's "Depends on" column may reference another meta-issue. Rough-in does NOT recursively walk meta-issue dependencies during the pre-flight check — it only checks the meta-issues directly blocking M_n. The dependency chain among meta-issues is the user's responsibility to understand and resolve in the right order. Rough-in surfaces each direct blocker individually and lets the user decide the resolution sequence.

### Special case: meta-issue blocks "rough-in start" rather than a specific milestone

Some meta-issues block rough-in entirely rather than a specific milestone — e.g., a `decision` type meta-issue that needs to be resolved before any rough-in can run against this framing. These appear in the table with `Blocks: rough-in start` rather than `Blocks: M_n start`. Rough-in's pre-flight check treats these as blockers for every milestone in the framing — if a `rough-in start` meta-issue is unresolved, no milestone in this framing can be roughed-in until it lands.

### What the check does NOT do

- **Does not re-verify the meta-issue's resolution criteria** — when a meta-issue is closed as completed, rough-in trusts the close. The user is responsible for ensuring the resolution criteria were actually met before closing.
- **Does not check meta-issues from prior framings of the same workstream** — only the current (highest-numbered active) framing's meta-issues are in scope. Prior framings' meta-issues are either superseded or were resolved before the current framing was created.
- **Does not check meta-issues from other workstreams' framings** — meta-issues are scoped to their workstream. Cross-workstream dependencies live in blueprint and are surfaced at the workstream-parent-issue level, not in framing's deferred meta-issues table.

## Foundation doc inheritance specifics

Rough-in's specs cite ARCHITECTURE.md, STANDARDS.md, and CLAUDE.md by section name. To do this accurately, rough-in must know which sections exist in each doc. The inheritance read pass should produce a mental map of:

**From ARCHITECTURE.md**:
- The list of section headings (top-level and second-level)
- The DECISION-NNN entries that are relevant to the milestone being roughed-in
- Any "Open architectural questions" entries that overlap with the milestone

**From STANDARDS.md**:
- The testing philosophy section (informs acceptance criteria specificity)
- The Unenforced invariants section (the most important — rough-in must not produce a spec that violates an invariant)
- Any quality-bar-specific sections (linting, formatting, CI strictness)

**From CLAUDE.md**:
- The commands section (informs done-signal phrasing — "run `mise run test`" vs "run `pnpm test`")
- The conventions section (informs technical detail phrasing)
- Any agent-specific guidance that affects how `/finish` will execute the spec

If a foundation doc is missing a section that rough-in expected to inherit from (e.g., STANDARDS.md doesn't have an Unenforced invariants section), surface it as a gap in the inheritance summary — *"STANDARDS.md doesn't have an Unenforced invariants section. Proceeding without invariants check for this rough-in run, which means the final pre-commit gate's invariants check will be a no-op. Recommend adding the section as a Suggested foundation doc update at the end of this rough-in."*

## What rough-in does NOT inherit

- **Rough-in specs from prior rough-in runs of the same milestone** — re-rough-in is a deliberate cascade event that supersedes prior runs (see Step 2 in SKILL.md). Prior specs are historical record, not inheritance input. The new rough-in starts from frame-NN.md, not from the prior rough-in output.
- **Implementation code from prior milestones** — rough-in operates at the spec level. Code review and pattern extraction from prior milestones happens during research (Step 3, sub-track 3a), not during inheritance.
- **PR feedback from prior `/finish` runs** — useful context but not authoritative. If the user wants to incorporate lessons from prior PR feedback, they can mention it during research phase, but rough-in doesn't automatically read closed PRs.
- **The opinionated profile's Linear-side state** — rough-in operates against github-only profile primarily; opinionated profile uses the same patterns with Linear MCP and falls back to manual where operations aren't documented.

## After inheritance: the HITL gate

In full and standard mode, the inheritance summary is presented to the user for explicit approval before Step 2 runs. The gate language: *"Here's the inheritance summary plus the pre-flight checks result. Anything to correct before I proceed to milestone selection confirmation?"*

The user can:
- **Approve** → rough-in moves to Step 2
- **Correct** → user names specific gaps or errors, rough-in re-reads the relevant input and re-presents
- **Abort** → user decides this rough-in run shouldn't proceed (perhaps the inheritance revealed something that needs to be addressed at framing level first)

In light mode, the inheritance summary is still produced but presented alongside the up-front combined confirmation gate rather than as a separate gate. The user can still abort or correct, but the default flow is approve-and-proceed.

The pre-flight checks **runs in every rigor mode**, including light. Light mode collapses other gates but cannot collapse this one — the one-way-door property of sub-sub-issue creation is too strong.
