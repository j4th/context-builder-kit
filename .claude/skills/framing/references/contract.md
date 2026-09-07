# The framing contract — what the frame must contain and the tests it must pass

This is the default read for producing `docs/cbk/frame-NN.md`. It states *what* the artifact is, not *how* to
arrive at it. A drafter — the main loop or a dispatched agent — reads this, the two templates, and the inputs
below, and writes the whole frame. The step-by-step procedure with its per-step gates lives in `procedure.md`
and is read on demand (full mode, or when a step is unclear).

Why contract-first: on 2026-09-01 an A/B on a real workstream gave six drafters identical inputs at three model
tiers; three read the skill's procedure and its references, three read a 61-line ancestor of this file and the
template. At the workhorse tier and at the top tier, blind workhorse-tier judges ranked the contract-only drafts
first and second with no flagged false claims; the procedure-following drafts ranked third and fourth with three
flags each and prescriptive rough issues. The mid tier ranked last either way. Recorded in
`.claude/rules/orchestration-reference.md` § Applied instances.

## Read in full before writing

- `docs/cbk/problem_brief.md`, `docs/cbk/scaffold.md`, `docs/cbk/blueprint.md` (all of it; § Workstreams, the
  workstream's project entry, and any § Notes for framing bind), the roadmap surface if the project keeps one,
  `docs/cbk/README.md`, and every prior `docs/cbk/frame-NN.md` — prior frames' interface commitments are inherited
  verbatim.
- The project's decision records: `docs/adr/` and its index, and any design-decision ledger the project keeps.
- `docs/ARCHITECTURE.md`, `CLAUDE.md`, and `.claude/rules/cbk-conventions.md` (title prefixes, trace IDs,
  methodology, grain, layout, mutation discipline).
- `references/templates/frame-output-template.md` (the shape of the file) and
  `references/templates/milestone-template.md` (the shape of a milestone).
- The workstream's parent issue body on the planning backend, and any intake candidates filed under it.

Inherit; do not re-derive. Decisions and ADRs are fixed constraints: cite them where they bind and never
contradict them; where two immutable records disagree, say so and route the choice to a pre-flight decision.
Verify any claim about the codebase by reading or grepping the repo. If a foundation doc is wrong or missing
something, say so under "Suggested foundation doc updates"; never apply the change.

## What the file must contain

1. Every section of the template, in its order: the header (which blueprint workstream row this frames, the frame
   number, what it builds on or supersedes), Purpose, Approach, Resolved during this framing, Components (each with
   the milestone that builds it), Boundaries (in scope, out of scope, agreements with prior framings or sibling
   workstreams), Interface Commitments (a table: interface, consumer, stable by which milestone, shape, brief —
   first-class even if empty, with the non-API prompt answered), Key Constraints, Milestones, Narrative arc,
   Suggested foundation doc updates (suggestions only), Open questions (each with a revisit trigger), Pre-flight
   checks (a table; if none, the exact text "No deferred meta-issues from this framing" — rough-in matches on it),
   Rough-in events (an empty table), Handoff context (about 150 words, with the parent-pointer sentence).
2. Each milestone: heading `### F<N> — M<N>: <name>`; one Capability sentence of the form "After this, the system can
   …"; Depends on; an appetite as its own field where the methodology is appetite-based; acceptance criteria carrying
   `[F<N>.AC<M>]` trace IDs; rough issues, each a one-sentence intent (what it exists to do, never how — no file
   paths, no signatures, no implementation sequences); issue-type flags (Claude-Code-implementable or user-managed);
   issue notes with the milestone's done-signal.
3. F numbers are workstream-unique and never restart across frames. M numbers are frame-local.

## The tests every milestone must pass

- **Demonstrable capability**: "can I show this to someone and have them see a meaningful change in what the
  system can do?" A milestone is a verb the system can do, not a noun describing what was built and not an
  implementation step. Adjacent milestones that cannot each pass this test are one milestone pre-decomposed.
- **Count**: as many as the workstream genuinely has, typically 3–6, 2–7 at the outside. Where the project's
  conventions set a grain (fewer, larger), that grain binds.
- **Rough issues**: 2–6 intents per milestone is the neighbourhood; rough-in shapes them into review units later,
  so do not pre-decompose. When unsure between more-smaller and fewer-larger, choose fewer.
- **Pre-flight meta-issues**: a decision or de-risk unit that gates a milestone — a charter, a governing ADR, a
  throwaway spike whose verdict alone survives — goes in the Pre-flight checks table with `Blocks: M<n> start`, never
  as a milestone. If the concept and its buildable spec are both settled upstream, there is nothing to ratify;
  skip the ceremony. A project instruction that names a spike as the first milestone beats this generic rule; say
  so in Resolved. A spike gating a risky adoption pre-declares promote / named fallback / documented drop before
  the numbers arrive.
- **Methodology**: honour what blueprint chose (Shape Up appetite, Kanban flow, Scrum sprints); never impose
  another.
- **Scope of the phase**: framing does not choose MCP servers, plugins, stack, methodology or CI gates; those were
  blueprint's and are inherited as constraints. Flag a tooling gap as a suggested foundation doc update.
- **Appetite re-estimate**: where blueprint or the design ledger asks framing to re-estimate, state the arithmetic
  and the options for the operator; never absorb it into milestone sizing.

## What the drafter returns

Alongside the draft: the milestone count; the F-issue titles the commit will create (`[<slug>:F<N>] <intent>`,
one per milestone) and any meta-issue titles for pre-flight rows; the questions it would have put to the operator
had the run been interactive — these become the gate's decision list; and brief notes on what was verified in the
repo and what was resolved during drafting.

## Before the gate

The draft is verified before it is shown: one fresh-context verifier at the project's verify tier attacks every
citation and every claim about the repo against the sources, runs the phase exit checklist mechanically, and
returns defects with a verbatim quote each. Fix, then present. For a high-stakes frame, generate two or three
contract-first drafts, judge them blind, and synthesize from the winner. Tiering per the project's
`.claude/rules/orchestration.md`: drafters and verifiers at the workhorse tier, effort `high`, never a finder tier
for anything that lands in the artifact.
