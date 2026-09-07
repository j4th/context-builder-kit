---
name: framing
disable-model-invocation: true
description: Decompose one workstream into sequenced milestones with rough issues. Use this skill when the user wants to break a project into milestones, plan implementation for a project, sequence build order, or move from planning into execution. Trigger when the user says 'plan this project', 'frame this project', 'what are the milestones', 'break this project down', 'how should I sequence this work', 'I have my plan, what's next', references a specific project by name, or references the cascade at the framing level. Also trigger when the user picks a workstream from blueprint and wants to go deeper. **Invoke deliberately — `disable-model-invocation` means this skill never auto-triggers; the moment for it is "I have a workstream from blueprint and need real milestones I can build against", even when the word "framing" never comes up.** Phase 4 of the cascade. One project at a time, just-in-time, never all at once. Produces a numbered cascade-event file (frame-NN.md) plus updates the chronological framing index.
---

# Framing

Phase 4 of the six-phase AI-assisted development cascade (analogous to Spec Kit's `Plan` and Kiro's `Design` phase). Takes one workstream from `docs/cbk/blueprint.md` § "Workstreams" and produces a refined project specification with sequenced milestones, each one a demonstrable capability the user can see, run, or test against. The output is a numbered cascade-event file (`docs/cbk/frame-NN.md` for projects using flat layout, or `docs/cbk/framings/frame-NN.md` for nested — see project's `.claude/rules/cbk-conventions.md`) plus an entry in the chronological cascade-events index at `docs/cbk/README.md`.

Framing is one-project-at-a-time, just-in-time, **by design**. The research is unambiguous on this — Beck, Böckeler, Anthropic, and the Thoughtworks Radar all warn against framing every project up front because the further-out projects get framed with stale information. Framing v0.4's bash project today is wasted work because you'll learn things from v0.1/v0.2/v0.3 that should change v0.4's design. Frame the next project, build it, then frame the project after that. The cascade is a funnel, not a waterfall.

**Target executor (transitive)**: framing's output feeds rough-in, which produces specs for Claude Code plan mode. Framing doesn't write plan-mode prompts directly, but its rough-issues list and its milestone boundaries are the seeds that rough-in shapes into Implementation sections. That transitivity affects framing in two specific ways: **rough-issues are intents, not prescriptions** (they describe *what* each rough-in R-issue should accomplish, not *how* to implement it — plan mode is a decomposition engine and even the rough-in author shouldn't pre-decompose into implementation sequences, let alone framing), and **milestones are demonstrable capabilities, not decomposed atoms** (each milestone is a verb the system can do, tested with the "can I show this to someone?" question, not a noun describing what was built). See [Anthropic's Claude Code best practices](https://code.claude.com/docs/en/best-practices) for the underlying framing: *"Separate research and planning from implementation to avoid solving the wrong problem. Letting Claude jump straight to coding can produce code that solves the wrong problem."* Over-prescriptive rough-issues at framing time propagate downstream as over-prescriptive Implementation sections at rough-in time, and over-atomized milestones propagate downstream as over-atomized R-issue lists. Both failures of the same underlying miscalibration show up at framing's layer first.

## This skill is contract-first

The artifact is defined by **`references/contract.md`** — what `frame-NN.md` must contain and the tests every milestone must pass — together with the two templates. That is the whole read for drafting. The step-by-step procedure with its per-step gates (`references/procedure.md`) is on demand: full mode, or when a step is unclear.

Why: the 2026-09-01 A/B recorded in `references/contract.md`'s opening paragraph and, in full, in `.claude/rules/orchestration-reference.md` § Applied instances — procedure written for earlier models is prescriptive in ways that now cost quality. Nothing was retired — it moved.

## Cascade events, not project slots

Each framing produces a **numbered** file: `frame-01.md` is the first framing the user did, `frame-02.md` the second, and so on. The number is the framing's identity in the cascade timeline, not the project's. Re-framing a project after code is built produces a new file with the next number; the prior framing stays in the history. The `docs/cbk/README.md` index tracks the timeline with a status column (Active / Completed / Superseded by frame-NN / Abandoned), and **rough-in always picks up the highest-numbered Active framing as "what's next."** Layout (flat by default, nested by override) comes from the project's `cbk-conventions.md`.

Five selection patterns exist — named explicitly, picked from sequence, whole-frame re-framing, additive increment (`Builds on:`, both frames stay Active), and milestone-scoped re-framing (`Supersedes only milestone M<N>`). The last three carry header and index-status rules; they are spelled out in `references/procedure.md` § Step 2 and in `cbk-conventions.md` § Mutation discipline.

## Required inputs and how to read them

- `docs/cbk/problem_brief.md` — from consultation
- `docs/cbk/scaffold.md` — from scaffold
- `docs/cbk/blueprint.md` — from blueprint, especially § "Workstreams" and any § "Notes for framing"
- `docs/cbk/frame-NN.md` — every prior framing (their interface commitments are inherited verbatim)
- `docs/cbk/README.md` — the cascade-events index, for the next frame number
- the project's decision records (ADRs, any design-decision ledger), `docs/ARCHITECTURE.md`, `CLAUDE.md`, `.claude/rules/cbk-conventions.md`
- the workstream's parent issue on the planning backend, and any intake candidates filed under it

Read them from the repo (or via the git-host MCP when that is how the repo is connected); if the files are not reachable, ask the user to upload or paste them. If any of the first three is missing, **do not silently proceed**: run the missing phase, accept an uploaded or verbal equivalent (and flag that the input is informal), or ask what is available. Read every input **in full** before drafting — skimming or guessing at their content is the most common framing failure, and it is the one light mode is most likely to cause. `references/inheritance.md` holds the verbatim-summary discipline for the modes that present one.

## Three rigor modes — light, standard, full

**Detect-then-confirm** at session start: propose a mode in one sentence from the user's opening message and let them override in one word. Default to **standard** for a first-time user. The dial can be turned mid-session.

- **Light mode — one gate.** One up-front confirmation (workstream, frame number, mode, anything the operator already knows the answer to), then run to completion: draft contract-first, verify, present the frame with the decision list, commit on approval. Best for "just give me the milestones" and workstreams whose shape is nearly self-evident.
- **Standard mode — three gates.** (1) inheritance + project selection; (2) the verified draft — refined definition and milestones together, with the decision list; (3) the final `frame-NN.md` before commit.
- **Full mode — five gates**, one per step, following `references/procedure.md`. The contract still governs the output. (Tooling research — MCP servers, plugins — is blueprint's in every mode.)

What no mode skips: reading the inputs in full, at least one milestone with a demonstrable capability, the `frame-NN.md` file, and the verification pass below.

## How the draft is produced

1. **Read** the inputs above, `references/contract.md`, `references/templates/frame-output-template.md` and `references/templates/milestone-template.md`.
2. **Draft the whole frame** against the contract. Where a step would have stopped for a gate in a mode that has none, decide, proceed, and carry the question into the decision list the gate presents. Rough issues are intents; milestones are capabilities; pre-flight units go in the table; interface commitments are first-class; appetite is re-estimated where the project asks, never absorbed.
3. **Verify before the gate** — one fresh-context verifier at the project's verify tier, per `references/contract.md` § Before the gate; fix its defects before presenting.
4. **Present** the frame with the decision list — the questions the draft would have asked — and the narrative arc ("After M1 you can X … by MN the project delivers Z"), and the structural tests stated plainly: each milestone's "show this to someone" moment, each rough issue an intent, rough-issue counts per milestone.

Depth of research is a user signal: when the project is greenfield or entering new technical territory, propose a depth and let the user confirm; never silently scale it down, and never present partial work as complete. `references/research-phase.md` has the depth patterns and what framing does **not** research (MCP servers, plugins, stack, methodology, CI gates — all blueprint's, inherited as constraints).

If the project runs a contribution-intake lane, candidates filed under the workstream are **inputs, not greenfield**: fold each into the milestone it informs and reconcile it at the commit (promote to its F-issue, or close as superseded). `cbk-conventions.md` names the concrete op.

## Producing the frame-NN.md file and committing

Write `docs/cbk/frame-NN.md` (path per the project's layout) from the approved draft and append a row to `docs/cbk/README.md` with the framing number, the workstream, the date and status `Active`. On a backend planning axis, create one F-sub-issue per milestone (and one meta-issue per pre-flight row) parented under the workstream's parent issue — the two-step create-then-link pattern, the atomic transition with the markdown commit, the rollback rules and the partial-failure protocol are in `references/planning-backend-commit.md`; the issue bodies come from the repo's `.github/ISSUE_TEMPLATE/cascade-framing.md` and `cascade-meta.md`, disk first. Where the project keeps a roadmap surface, add its rows in the same commit. If no commit path is available, hand the files to the operator as downloadable artifacts rather than leaving the frame in the conversation.

**HITL gate (final)**: present the file and the list of issues to be created; get explicit approval before any write. The gate wording is in `references/planning-backend-commit.md` § HITL gate update.

## Phase exit checklist

Auto-checkable list that fires after the final gate, before declaring framing complete. Not a gate; a safety surface (the skill stops if any item fails), per `cbk-conventions.md` § Trip-wire pattern:

- [ ] `frame-NN.md` content includes all required sections: Purpose, Approach, Components, Boundaries, Interface Commitments, **Pre-flight checks** table (with the empty-default text `"No deferred meta-issues from this framing"` if none — the string rough-in matches on), Open questions, Milestones (each with `[F<N>.AC<M>]` trace IDs in acceptance criteria)
- [ ] Frame-NN's number was correctly identified (highest existing in `docs/cbk/README.md` + 1)
- [ ] Workstream parent issue exists (github-issues and linear planning; n/a on in-repo-markdown) and matches the workstream slug
- [ ] No prior F-issue exists for this milestone (idempotency)
- [ ] Markdown commit and (on backend planning axes) F-issue creation atomic transition succeeded, or partial state surfaced cleanly
- [ ] `docs/cbk/README.md` updated with new entry + status `Active`
- [ ] If the project runs a contribution-intake lane (cbk-conventions): no candidate it filed under this workstream remains un-reconciled — each was promoted to an F-issue or closed as superseded
- [ ] The verification pass ran and its defects were fixed or consciously kept (recorded in the gate)

## Backend-axis-aware behavior

Two independent axes set by scaffold. **Planning**: `github-issues` creates F-sub-issues via issue-write plus sub-issue-link, atomic with the markdown commit; `linear` creates F-issues parented under the workstream issue via `save_issue`; `in-repo-markdown` has no external entities and the transition collapses to the markdown commit. **Knowledge**: `notion` permits optional reads at inheritance and a promote-to-runbook offer for genuinely cross-project meta-issues — reads and writes both HITL-gated and default-skip, never for normal milestone-blocking meta-issues, and every planned write announced before it is committed; `none` means no Notion interaction. The long form of both axes is `references/procedure.md` § Backend-axis-aware behavior; the operational detail is `references/planning-backend-matrix.md`, `references/backends.md`, and the project's `cbk-conventions.md` for the identifiers.

## Handoff contract to rough-in

When framing is complete, rough-in inherits:

- **The latest frame-NN.md** — refined definition, milestones, rough issues, interface commitments, **and the Pre-flight checks table**
- **The cascade-events index** at `docs/cbk/README.md` — for finding the latest framing (highest-numbered Active row)
- **All prior framings** — for cross-framing interface commitments
- **Planning-backend issues created by framing** — F-level sub-issues (labeled `cascade-depth:framed`) and any pre-flight meta-issues (`cascade-depth:framed` + `meta`), all parented under the workstream parent issue

**What rough-in does with this**: reads the latest frame-NN.md (the highest-numbered one), picks one milestone from it, and decomposes that milestone's rough issues into ready-to-implement issues (with acceptance criteria, technical detail, and Claude Code plan-mode prompts). Rough-in does not need prior framings except as historical context for interface commitments.

**Mandatory pre-flight check**: before decomposing milestone M_n, rough-in MUST read the Pre-flight checks table from the latest frame-NN.md and verify any row with `Blocks: M_n start` is resolved (closed) or explicitly cleared by the user. If unresolved rows block M_n, **rough-in stops and surfaces the gap**. The check obligation lives on rough-in; the table existing — with its explicit "none" when empty — is framing's responsibility.

**What framing must not pass to rough-in**: implementation code, detailed issue specs, production deployment decisions, test specifications below the milestone-acceptance level.

**The latest framing is always the answer to "what's next."**

## Project-level overrides

Project-specific overrides (workstream slugs, team key, branch naming, layout, operational evidence) live in the project's `.claude/rules/cbk-conventions.md`. Read it at session start; treat its content as overrides on this skill's defaults. If no `cbk-conventions.md` exists, framing operates with the defaults documented here.

## Reference files

- `references/contract.md` — **the default read**: what the frame must contain, the tests each milestone must pass, what the drafter returns, the verify-before-gate step
- `references/procedure.md` — the full step-by-step procedure (Steps 1–5, the long-form backend-axis behaviour, the five-gate summary, failure modes, solo vs. team); full mode, or on demand
- `references/templates/frame-output-template.md` — the frame-NN.md template with worked example
- `references/templates/milestone-template.md` — milestone shapes and the per-milestone template
- `references/planning-backend-commit.md` — the F-issue creation step, atomic transition, rollback, partial-failure recovery, brownfield recovery
- `references/inheritance.md` — reading prior artifacts, the verbatim summary template, the "builds on" pattern
- `references/research-phase.md` — depth patterns, what framing does not research
- `references/hitl-question-bank.md` — clarifying questions per round (full and standard modes)
- `references/planning-backend-matrix.md`, `references/backends.md` — planning-axis behavior
- `references/failure-modes.md` — framing-specific failure modes with recovery patterns
- `references/test_cases.md` — realistic test prompts with success criteria for verifying the skill after revisions; the last case walks the contract-first default and its verification pass

Read references on demand, not all at once. SKILL.md routes; the contract and the templates are the drafting read; the procedure is the on-demand read.
