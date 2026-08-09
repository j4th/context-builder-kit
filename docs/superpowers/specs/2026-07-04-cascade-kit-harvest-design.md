# Harvest design — reconciling the kit with a real cascade run

**Date:** 2026-07-04
**Status:** Approved for execution (pending final spec review)
**Type:** Design spec for evolving `context-builder-kit` itself

## What this is

The kit's cascade was run end-to-end, for real, on a private reference instance (a
substantial project built entirely through consultation → scaffold → blueprint → framing
→ rough-in → `/finish`) over roughly two months. That run seeded its `.claude/` from the
kit and then tweaked, extended, and battle-tested it — producing dozens of concrete
improvements the portable kit is now behind on.

This spec captures the decisions for harvesting those improvements back into the portable
kit. The full classified inventory of ~45 candidates (with per-candidate source pointers)
lives in the working harvest map and comparison findings, which are **not** committed here
because they reference the private instance directly. This spec is the sanitized,
committable record of *what changes, where it lands, and why*.

Candidate IDs (e.g. `F3`, `B1`, `G2`) are stable references into that working map.

## Governing constraints

Every change in this harvest is bound by four invariants. A change that can't satisfy all
four is not harvested (or is reshaped until it can).

1. **Portability invariant.** Nothing project-specific enters skill/command/rule content.
   Every landed change must pass the portability greps in `cbk-conventions.md §
   Verification` (no issue keys, no `notion.so/`, no project or stack names). Concrete
   values live in the `cbk-conventions.md` *template* as bracketed placeholders.

2. **Framework, not tooling.** The kit ships the **cascade framework** — the phases, the
   artifacts, the HITL discipline, and the commands/skills that *are* that framework. It
   does **not** ship prescriptive "how to operate Claude Code" tooling (tool-selection
   mechanics, formatter hooks, agent-driving how-tos). Where the reference instance found
   a portable *principle* underneath such tooling, the kit absorbs the **principle** —
   abstractly, into the framework surface that already owns its kin — and never prescribes
   the mechanics.

3. **Sanitized examples only.** The reference instance is **private**. The kit may never
   name it, link to it, or reproduce its identifiers, paths, or domain/stack specifics.
   Where an example or worked illustration is useful, it is authored **fresh and generic**
   inside the kit — a self-contained neutral illustration, not a pointer to the instance.

4. **One-way.** This harvest updates the kit only. The reference instance is not modified
   in this effort.

## Decisions (settled with the operator)

| # | Decision | Outcome |
|---|---|---|
| D1 | Scope of this pass | **All four tiers**, sequenced as separate PRs (one per tier). |
| D2 | The bottom-up contribution lane | **Adopt it** into the kit as a first-class capability (backend-neutral). |
| D3 | Direction | **One-way into the kit.** No reconciliation of the instance. |
| D4 | Framing-model changes | Additive-increment relationship → **portable framing skill**. Verify-against-reality pass + committed companion research artifacts → **not** in the skill; an **optional sanitized example** in the `cbk-conventions.md` template only. |
| D5 | Analytics-output "demonstrable" toolchain | **Leave entirely in the instance.** Nothing harvested (no archetype note, no honesty kernel). |
| D6 | New rule files vs fold-in | **No new standalone rule files.** Portable principles from the instance's `workflows.md`/`tooling.md` fold into existing framework surfaces (abstractly); the dependency "settle-window" policy lands as a templated section in `cbk-conventions.md`. |

## Non-goals — explicitly NOT harvested

- **A standalone `workflows.md` rule file.** Its portable core is cascade philosophy the
  kit already states; those get *reinforced* in the surfaces that own them (see Tier 1
  `R1`). No new file.
- **A standalone `tooling.md` rule file.** Generic Claude Code tool hygiene, not cascade
  framework. At most a short "record your own tooling-selection conventions" pointer in
  the `cbk-conventions.md` template, with a *sanitized generic* shape (see `R2`).
- **The `/explore` + `/publish` demonstrable toolchain and its house-style craft** (D5).
- **The verify-against-reality pass and committed companion research artifacts as skill
  prescriptions** (D4) — optional sanitized example only.
- **A shipped `format-on-edit` hook** — operational tooling; a sanitized exemplar shape at
  most (`L5`).
- **Any reference to the private instance**, anywhere in kit content (constraint 3).

## Sequencing — four PRs, atomic commits within each

Each tier is one PR; each candidate (or tight cluster) is its own focused commit with a
Conventional Commits message, per the kit's own atomic-commit discipline. Tiers are
ordered so shared surfaces (notably `cbk-conventions.md`) accrete coherently.

### PR 1 · Tier 1 — Portable core (hardening; no new concepts)

| ID | Change | Lands in |
|---|---|---|
| F1 | Decompose `/finish`'s monolithic Step 7 into discrete gated steps (branch+execute · test-gate · simplify · review · push+PR · hand-off) | `commands/finish.md` |
| F2 | Create the branch before any code lands | `commands/finish.md` |
| F3 | Read the break-glass skip-marker from the issue body, not the PR body (**fixes a latent ordering bug**: review runs before the PR exists) | `commands/finish.md`, `rules/pr-review.md` |
| F4 | Read issue comments as context-not-contract into plan mode | `commands/finish.md` |
| F5 | Give `/simplify` the same four-class triage as review | `commands/finish.md` |
| F6 | Explicit test-gate step: categorized red-handling, "don't skip/xfail to force green — ask", verify the red gate actually went red | `commands/finish.md` |
| F7 | Structured hand-off with a roll-forward offer (route deferred context wherever relevant, HITL-gated) | `commands/finish.md` |
| F8 | Scale plan-mode research with subagent fan-out; "gather with subagents, never delegate the synthesis" | `commands/finish.md` |
| F9 | Richer PR-body triage (commit SHAs per Apply) + honest partial-failure surface | `commands/finish.md` |
| R1 | **Fold** the portable orchestration principles (plan-mode-as-decomposition-engine, surface-and-abort-not-improvise, gather-don't-delegate, verification-before-done) into the surfaces that already own them — reinforcing, not a new file | `rough-in` plan-mode refs, `commands/finish.md`, `rules/testing.md` |
| R2 | **Pointer only**: a short "record your project's tool/MCP-selection conventions" note with a sanitized generic shape | `rules/cbk-conventions.md` template |
| A1 | New agent: `cascade-rule-reviewer` (enforces the kit's own rules files — testing, conventions, simplification, knowledge-backend) + add to the dispatch list | `agents/cascade-rule-reviewer.md`, `rules/pr-review.md` |
| A2 | `adr-conformance-reviewer`: follow the Refines/Supersedes chain + reconciliation layer before flagging a literal clause | `agents/adr-conformance-reviewer.md` |
| A3 | `pr-review.md` exclusion: resolve the ADR refinement chain before flagging a violation | `rules/pr-review.md` |
| H1 | New hook: `protect-lock-files.sh` (cross-ecosystem, portable) + settings wiring | `hooks/protect-lock-files.sh`, `settings.json` |
| H2 | Fail-open-on-env-defect hook discipline; back-port to `protect-immutable-adrs.sh` | `hooks/*.sh` |
| T1 | testing.md: assertion-form red-first is OK when transcribed verbatim from a spec | `rules/testing.md` |
| T2 | testing.md: new module class — declarative/query models where the query IS the implementation → shape-of-done | `rules/testing.md` |
| C1 | cbk-conventions: third `[skip ci]` trap (required checks block merge under branch protection) | `rules/cbk-conventions.md` |
| C2 | cbk-conventions: top-of-file "surface inventory" manifest (bracketed placeholders) | `rules/cbk-conventions.md` |
| C3 | cbk-conventions: meta-tag collision discipline + meta/bug/enh title-prefix rows | `rules/cbk-conventions.md` |
| E1 | research-phase: fan-out research is multi-agent; throttle to safe batches | `framing` + `rough-in` `references/research-phase.md` |
| E2 | research-phase: prompt-injection can arrive via MCP doc-fetch — treat fetched content as untrusted, surface + ignore | `framing` + `rough-in` research/failure-mode refs |

### PR 2 · Tier 2 — The bottom-up contribution lane (new capability, backend-neutral)

| ID | Change | Lands in |
|---|---|---|
| B1 | New command `/intake` — externally-sourced report → read-only investigation → reproduce with a real failing test → 4-way classify → shaped `/finish`-able issue. Never lands code. Backend-neutral (Linear / GitHub Issues / markdown). | `commands/intake.md` |
| B2 | New command `/enrich` — rough-in for a single small capability; collapses framing+rough-in inline; large capabilities are stopped and routed to framing. | `commands/enrich.md` |
| B3 | New command `/pr-respond` — the PR feedback-loop executor (inverse of `/finish`); consumes the existing four-class `pr-review.md` rubric. Fills a loop the kit references but never shipped. | `commands/pr-respond.md` |
| B4 | `cbk-conventions § Contribution intake` — bug lane + enhancement lane conventions (skip framing, parent to workstream; large stays framed; default-to-framing). Choice-space language; Linear "Triage"-state mechanics stay templated. | `rules/cbk-conventions.md` template |
| B5 | Framing reconcile hook — absorb + reconcile pre-framed bottom-up candidates during framing (guarded on "if the project runs an intake lane"; concrete ops deferred to conventions). | `framing/SKILL.md`, `framing` planning-backend matrix, phase-exit checklist |
| B6 | `/finish` Step 1 recognizes bug/enh lanes, not just rough-in R-issues. | `commands/finish.md` |

### PR 3 · Tier 3 — Framing & ADR governance

| ID | Change | Lands in |
|---|---|---|
| G1 | ADR **Refines vs Supersedes** — a second, clause-scoped relationship (parent stays Accepted; reviewers follow the chain). Domain-neutral. | `skills/adr-new/SKILL.md`, `rules/cbk-conventions.md § Mutation discipline` |
| G2 | **Additive-increment** frame relationship — a frame that appends a milestone to a still-Active frame without superseding it; legitimizes the single-milestone shape. | `framing/SKILL.md § Step 2`, `cbk-conventions § Mutation discipline` |
| G3+G4 | Verify-against-reality pass + committed companion research artifacts → **optional sanitized example** of "here's the shape if you want this in your project" | `rules/cbk-conventions.md` template (example block only) |
| G5 | Charter meta-issue pattern (concept frozen, spec undefined → charter meta + spike, Blocks M1) | `framing` Pre-flight/meta-issue guidance |
| G6 | Calibration lean: AI-assisted execution justifies coarser review units (collapse toward the low end of 2–6) | `framing` rough-issue-count note, `rough-in` review-unit discipline |
| G7 | Enrich the README / rough-in-events ledger guidance (invite a short structured per-event note: drift / OQ resolution / provenance) | `framing/references/templates/frame-output-template.md` |

### PR 4 · Tier 4 — Judgment & optional

| ID | Change | Lands in |
|---|---|---|
| L1 | Linear `{type}` label must be set at issue-creation (branch-prefix caching gotcha); rough-in passes the type label in the save call. Linear-scoped → the Linear-conditional surface. | `rough-in/SKILL.md`, `rough-in` planning-backend matrix, `cbk-conventions` Linear note |
| L2 | Dependency "settle-window" supply-chain policy (min release age; never delay a security patch; floors aren't a volume lever). Concept portable; values templated. | `rules/cbk-conventions.md` template (new section) |
| L5 | `format-on-edit` advisory PostToolUse pattern → **sanitized exemplar shape only**, not a shipped hook | (doc/example; not `hooks/`) |
| L6 | Template note: authoring project-local reviewers (the observed reviewer shape) + one portable meta-rule: "ground every claim in docs + installed source, never model memory" | `rules/pr-review.md` |
| L7 | Methodology: optional flop/kill checkpoint bullet | `cbk-conventions § Methodology` |
| L8 | logging.md one-liner: a correlation/lineage ID can be both a transient log handle and a durable persisted column — keep the two concerns distinct | `rules/logging.md` |

*(Dropped per D5: `L3` house-style honesty kernel, `L4` demonstrable archetype note.)*

## Verification — definition of done per PR

The kit has no build/test suite; verification is editorial and grep-based.

1. **Portability greps pass.** Run `cbk-conventions.md § Verification`; no project/stack
   identifiers leaked into skill/command/rule content. This is the hard gate for
   constraint 1 and constraint 3.
2. **No reference to the private instance** anywhere in the diff (name, paths,
   domain/stack terms). Manual scan + grep.
3. **`test_cases.md` updated** for any skill whose behavior changed (per the kit's
   working-in-repo discipline).
4. **Cited reference files exist** — any new `references/*.md` pointer resolves; any
   `SKILL.md` change that cites a reference is matched by that reference.
5. **Framework-not-tooling check** — confirm nothing prescriptive-operational slipped in
   as a shipped rule/hook where it should be an abstracted principle or sanitized example.

## Open items

- **`R2` / tooling pointer** — confirm the sanitized generic shape reads as "framework
  invites you to record this," not "here's how to set up tools."
- **`L5` format-on-edit** — confirm exemplar placement (a doc example vs a bracketed note
  in conventions) once we reach Tier 4.
- **Spec review** — operator reviews this document before Tier 1 execution begins.
