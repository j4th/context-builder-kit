# The rough-in contract — what one milestone's R-issue set must contain and the tests each spec must pass

This is the default read for producing the sub-sub-issues of one framing milestone. It states *what* the artifact
is, not *how* to arrive at it. A drafter — the main loop or a dispatched agent — reads this, the spec template, the
executor's body parser, and the inputs below, and writes the whole set: the issue plan, the coverage map, every spec
body and the commit-time text. The step-by-step procedure with its per-step gates lives in `procedure.md` and is read
on demand (full mode, or when a step is unclear). The two one-way doors — provisioning the executor pair and the
planning-backend commit — belong to the main loop after the gate, never to a drafter.

Why contract-first: on 2026-09-02 an A/B on a real milestone gave four drafters identical inputs at two model tiers;
two read the skill's procedure and its references, two read a 109-line ancestor of this file plus the spec template.
Two of three blind workhorse-tier judges ranked a contract draft first and the procedure's workhorse-tier draft last;
every output in both arms carried the executor's headings and put no code in an Implementation section, so what
separated the arms was noise the procedure invited (a 150-line re-quoted inheritance block, fabricated line counts
from a template diff) and gaps this contract has since closed (numbered R-level criteria; the frame's open questions
cited as the frame's). Recorded in `.claude/rules/orchestration-reference.md` § Applied instances.

## Read in full before writing

- The highest-numbered **active** `docs/cbk/frame-NN.md` for the workstream — all of it. The milestone's own section
  (its capability, acceptance criteria, rough issues, issue notes and acceptance signal), § Interface Commitments,
  § Pre-flight checks, § Resolved during this framing, § Key Constraints, § Open questions and § Handoff context bind.
- The framing sub-issue for the milestone and every pre-flight meta-issue the frame names (state and body);
  `docs/cbk/README.md`; the roadmap surface if the project keeps one.
- `docs/cbk/problem_brief.md` (the no-gos), `docs/cbk/scaffold.md` (the quality bar, the cascade grain),
  `docs/cbk/blueprint.md` (stack decisions, methodology, the workstream's entry, notes for framing, amendments).
- The project's decision records — `docs/adr/` and its index, and any design-decision ledger — in full for every
  clause the milestone's criteria or the frame's § Resolved cite.
- `docs/ARCHITECTURE.md`, `docs/STANDARDS.md`, `CLAUDE.md`, `.claude/rules/cbk-conventions.md` (title prefixes, the
  trace-ID convention **including the project's test-side tag form**, branch naming, mutation discipline),
  `.claude/rules/testing.md`.
- The executor's body parser — `.claude/commands/finish.md`'s preconditions (the eight headings), or whatever the
  project's `cbk-conventions.md` names as the executor — and the disk issue template
  `.github/ISSUE_TEMPLATE/cascade-rough-in.md`. The executor's heading list wins where the two differ; record the
  drift, never fix the template from here.
- `references/templates/rough-in-spec-template.md` — the shape of one spec body.
- The repository itself: the task-runner config, the package manifests, the trees the milestone touches. Verify every
  claim about the codebase by reading or grepping; existence and absence claims are verified repo-wide from the root,
  never from one package. Never assert a package API from memory — read the pinned source.

Inherit; do not re-derive. Decisions, ADRs and the frame's § Resolved are fixed constraints: cite them where they bind
and never contradict them. The frame's rough issues are intents; you shape them into review units. The frame's open
questions are the frame's: cite them as `frame-NN § Open questions <n>`; a foundation doc that keeps its own
open-questions list is a different list with its own numbering, cited by its own document.

## What the output must contain

1. **The pre-flight result.** For every row of the frame's Pre-flight checks table: the issue's state and what it
   means for this milestone. A row that blocks the milestone's start and is open stops the run. A row that blocks one
   criterion becomes a dependency of the R-issue that owns that criterion. If the table reads "No deferred meta-issues
   from this framing", say so and proceed.
2. **An issue plan** before the specs: an ordered list, each entry with the title `[<slug>:F<#>:R<#>] <intent>` (slug
   and F-number inherited from the framing sub-issue's title, never re-derived), a one-sentence intent, a type flag
   (Claude-Code-implementable | user-managed | hybrid), its dependencies on prior R-issues, and a capstone marker. A
   spike milestone's capstone is the artifact that carries its verdict; say which R-issue owns it. A milestone with no
   capstone says why.
3. **A coverage map**: every acceptance criterion of the milestone (`[F<#>.AC<n>]`) owned by exactly one R-issue — a
   criterion two issues share names the owner and the contributor — and every R-issue owning at least one. The map
   must agree with the bodies.
4. **One full spec per R-issue**, with exactly the executor's headings, in its order, named exactly. Under the
   cascade's own `/finish` these are eight: `## Context`, `## Assumptions`, `## Implementation`, `## Acceptance
   criteria`, `## Test plan`, `## Done signal`, `## Dependencies`, `## PR contract`.
   - **Context**: one paragraph — where the issue sits ("You are implementing R<#> of M<#> under the **<slug>**
     workstream's framing capability F<#> (#<framing sub-issue>)"), what it enables, what it deliberately does not do.
   - **Assumptions**: every gap you filled, one `[ASSUMPTION: …]` line each with why it was made and what changes if it
     is wrong; or exactly `- None — all parameters explicit from the framing intent and acceptance criteria.` Never
     empty.
   - **Implementation**: the plan-mode prompt — see the tests below.
   - **Acceptance criteria**: numbered `[R<#>.AC<m>]`, as checkboxes, each an observable or test-visible outcome that
     names what proves it and cites the `[F<#>.AC<n>]` it discharges. "The tests pass" is not a criterion.
   - **Test plan**: the regime named (logic | conformance | tests-as-shape-of-done); one named test per criterion in the
     project's test-side tag form from `cbk-conventions.md` § Trace ID convention, keyed to the R-level number (the
     issue number is a placeholder until the commit). A tag that resolves to no numbered criterion is a defect. Where a
     criterion is a physical measurement no test can perform, name the mechanical stand-in (a record's completeness, a
     parsed value present) and flag the rest as operational, in an explicit list.
   - **Done signal**: one command or observation; an operational signal flagged as such. For a spike-shaped
     R-issue — one whose criteria are the operator's runs — the signal names the run-and-revise loop (the rows
     filled from the runs, with the harness fixed on the same branch until they are), not the draft PR.
   - **Dependencies**: identifiers only — `#N` for existing issues, `R<#>` placeholders for sibling R-issues, which the
     commit resolves — with one line on what each is *for*; or `None`. Never name an open issue in prose here unless it
     is a dependency: the executor refuses to proceed on any open issue it finds listed.
   - **PR contract**: the planning axis's close marker for this issue, a Conventional Commits title with the
     workstream's scope, the branch pattern, the project's review-gate floor, and the project's validity-style label
     wherever the diff touches a guard the project names.
5. **The labels** each issue gets and **the parent** it is linked under (the framing sub-issue).
6. **The commit-time text**: the row for the frame's `## Rough-in events` table (date, milestone, sub-sub-issues
   created, notes), the roadmap row's status flip if the project keeps a roadmap, and the one-line cascade-index note.
7. **Loose threads**: observations that belong to no spec — template drift, skill drift, repo state the operator
   should track — one line each. The seven-heading disk template beside an eight-heading executor is the canonical one.

## The tests every spec must pass

- **Review units, not work units.** 2–6 R-issues; each one a coherent review unit — one reviewer reads the PR in one
  sitting, one architectural concern, revertible as a unit. Where the project's conventions set a grain (fewer,
  larger; sized to what one `/finish` lands as one reviewable PR), that grain binds. The frame's intents are inputs,
  not the answer: merge or split them and say why. Two issues that would be reviewed as the same code twice are one
  issue. Outside 2–6, say so and why.
- **Implementation is a plan-mode prompt, not a recipe.** Second person, every sentence a verb the executor can act
  on. Self-contained: readable cold; citations are pointers, not prerequisites. Names specific files, constraints and
  invariants; inlines code only when verbatim from a locked Interface Commitment of the frame, prefaced "the IC-N shape
  is verbatim and not negotiable — any deviation is a re-framing trigger". Cites foundation docs by section name where
  a rule binds. Embeds the verification step in the work. Names what NOT to do — the scope creep a helpful executor
  would attempt. About 300–800 words, up to ~1000 for a capstone. States intent and constraints, never implementation
  sequences, function bodies, prescribed test-function names or step-by-step commands. If reviewing the spec would
  feel like reviewing code, it has failed. The full eight properties and their worked examples are in
  `references/plan-mode-prompts.md`.
- **Acceptance is observable and traceable.** Every criterion names the command, test or artifact that proves it and
  the F-level criterion it discharges; every test tag resolves to one numbered criterion; a measurement is a number in
  a committed artifact, and "it runs" proves nothing.
- **Grounding.** Every claim about the repo, a package API or a document is true and was checked; nothing re-decides
  what an ADR, a design-ledger entry or the frame's § Resolved fixes; platform, routes, paths and throwaway-versus-
  durable status come from the frame, not from the drafter.
- **The framing's judgment calls are honoured.** Where the milestone's issue notes invite a rough-in-time decision —
  a merge, an ordering, a dependency, what stands in for a test — make it and record the reason. Where the frame
  states a rule ("nothing in this milestone is a CI gate"), no spec re-decides it.
- **Honest type flags.** Physical runs, hardware, purchases and the operator's own observations are user-managed;
  harnesses, analysis and records are Claude-Code-implementable; a mixed issue is hybrid and says which half is which.
- **Scope of the phase.** Rough-in does not choose stack, methodology, MCP servers or CI gates; does not rough-in the
  next milestone; does not edit the frame beyond its events row; does not fix the issue template.
- **The artifact carries no run material.** No re-quoted brief, scaffold or blueprint text, no inheritance summary,
  no gate-question list, no provisioning diff inside a spec body or the set — those belong to the drafter's return and
  the gate presentation.

## What the drafter returns

Alongside the output: the R-issue count and titles in order; which is the capstone; the coverage map; the milestone's
capability sentence, rough-issue list and acceptance signal **quoted verbatim** from the frame (the gate's inheritance
check — quoted, never paraphrased); the questions it would have put to the operator had the run been interactive —
these become the gate's decision list; the repo claims it verified; and brief notes.

## Before the gate

The set is verified before it is shown: one fresh-context verifier at the project's verify tier attacks every
citation and every claim about the repo or a package API against the sources, checks the coverage map against the
bodies and every test tag against a numbered criterion, attacks absence claims hardest, runs the phase exit checklist
mechanically, and returns defects with a verbatim quote each. Fix, then present. For a high-stakes milestone, generate
two or three contract-first drafts, judge them blind, and synthesize from the winner. Tiering per the project's
`.claude/rules/orchestration.md`: drafters and verifiers at the workhorse tier, effort `high`, never a finder tier for
anything that lands in an issue body.
