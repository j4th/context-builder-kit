# Harvest 2 design — second reconciliation with the reference instance

**Date:** 2026-08-09
**Status:** Approved for execution
**Type:** Design spec for evolving `context-builder-kit` itself
**Prior:** `2026-07-04-cascade-kit-harvest-design.md` (harvest 1, landed as PR #4)

## What this is

The private reference instance continued running the cascade for another month after
harvest 1's snapshot — a full comparative-selection milestone cycle, an operational
config-modernization wave, and several incident-driven rule calibrations. This pass
harvests that delta back into the portable kit.

The comparison ran as a 14-agent orchestration (7 surface readers, each adversarially
verified against the kit's current main and against harvest 1's settled decisions):
97 classified candidates, ~51 landable after cross-surface dedup. The working harvest
map (with per-candidate instance pointers) is operator-private and not committed here;
this spec is the sanitized record of what changes, where it lands, and why.

## Governing constraints — one revised

Constraints 1 (portability), 3 (sanitized-only), and 4 (one-way) carry unchanged from
harvest 1. Constraint 2 is **revised**:

2. **Framework-not-tooling, re-tested per file (revision of harvest 1's D6).**
   Harvest 1 settled "no new standalone rule files; tooling principles fold into
   existing surfaces." The operator retired that as a blanket rule for this pass:
   the test is now **portable + self-contained to the kit's concerns**, judged per
   file on merits. Anything the instance built *on* the kit that helps and expands
   it gets examined; the demonstrable-output toolchain (and its house-style craft)
   remains out as heavily domain-specific (harvest 1's D5, re-confirmed). Rule files
   ship in the kit's established **template register** — bracketed placeholders
   where project-specific, the way `cbk-conventions.md` already works.

## Decisions (settled with the operator, 2026-08-09)

| # | Decision | Outcome |
|---|---|---|
| D7 | Reviewer persistent memory | **Adopt both**: per-project memory frontmatter on the kit's three shipped reviewers (mechanism ships empty) + the precedent-keeping discipline documented in `pr-review.md § Authoring a project-local reviewer`. |
| D8 | Phase-skill invocation posture | **Adopt the flip**: scaffold / blueprint / framing / rough-in become deliberate-invoke-only (`disable-model-invocation: true`); consultation (the funnel entry) stays model-invocable. Kit `CLAUDE.md` § "When the user invokes a skill" rewritten in lockstep. Rationale: downstream phases are expensive HITL one-way-door workflows; an accidental auto-trigger costs more than a missed trigger. |
| D9 | CI / supply-chain items | **Adopt, portable and light**: SHA-pin the kit's own CI workflow `uses:` refs + a settle-window sentence covering CI actions as an ecosystem; one sentence each for "linter-excluded surfaces need their own CI gate" and "an unattended CI agent's deliverable is the posted artifact, not its exit code." |
| D10 | Sequencing | **One PR** (`feat/harvest-from-instance-2`), atomic commits per cluster. |
| D11 | Tooling complex under revised constraint 2 | **Adopt as templates**: a workflows rule (agent workflow patterns), an orchestration rule (model/effort tiering, fan-out discipline), a tooling rule (tool-selection skeleton; stack sections bracketed), a sanitized review-sweep saved workflow, and a cheap-tier Explore agent exemplar. **Still out**: the instance's config-audit workflow artifact, the house-style rule, a standalone dependencies rule (the conventions section already owns the settle-window), and version-specific platform runtime quirks. |

## What lands — cluster summary

Tier labels follow harvest 1 (1 portable core · 3 governance · 4 judgment/optional).

### A · Executor research split (Tier 1)

`/finish`'s planning step conflated research with plan mode; plan mode is read-only,
so research could never execute a probe, a feasibility spike, or the test suite to
inform the plan. Split: **research first, executably, in the operator's current
permission mode** (read-only probes + scratchpad-scoped throwaway spikes; one hard
rule — no repo edits during research), **then enter plan mode as the self-disarm**
that gates the plan itself (assumption enumeration, guardrail respect, the
non-negotiable approval gate; approval restores the prior mode). Folds: spikes are
throwaway (only findings survive; the real work is built fresh from the approved
plan); state the permission mode a flow expects, note the command cannot set it, and
describe degradation; the deferred-hardening note pattern (when a safety rule stays
instruction-enforced, record why structural enforcement was shelved, the residual-gap
severity, and the revisit trigger); probe-pending facts ride as `[ASSUMPTION:]`
entries paired with step-0 read-only probes owned by the consuming issue.

### B · Research grounding (Tier 1)

Born from a real near-miss (a fan-out drafter declared a helper nonexistent from a
single-directory grep). Three rules into the framing + rough-in research references
(canonical statement in rough-in's; siblings point): existence/absence claims are
verified **repo-wide**, never single-directory; verifiers preferentially attack
**negative** claims (a wrong absence-claim ships duplicate machinery; a wrong line
number is cosmetic); drafters consult the run's existing grounding corpus before
re-deriving a fact it already grounds. Plus a named rough-in failure mode
(narrow-scope existence grepping) and, in the conventions' verify-against-reality
section, citation-verified research (verify every quotation against the fetched
source; record the tally; drop unverifiable citations).

### C · Review pass (Tier 1)

Choice-space additions to `pr-review.md`: an optional refute-by-default
**adversarial verification stage** between finding and triage (refuted findings need
no triage; direct dispatch remains the documented fallback, and the hand-off records
which path ran); **triage judgment stays with the caller**, never delegated to
dispatched agents; **a failed review agent is dropped coverage, not zero findings**
(track failed dimensions and unverified findings; surface and retry before treating
the pass complete); reviewer dispatch conditions live in exactly one authoritative
place (`§ Project-local agents` — cross-cutting reviewers unconditional, domain
reviewers path-matched); the rules-conformance reviewer runs unconditionally; the
pre-filtered changed-path list is computed once and reused.

### D · Hooks & enforcement (Tier 3)

Three new shipped hooks, each the enforcement companion of a discipline the kit
already documents (the harvest-1 `protect-lock-files` precedent): a hard-deny guard
blocking `git commit` on the default branch (branch-first is the rule); an ask-gate
on PR-state-changing `gh pr ready|merge|close|reopen` (the permission prompt *is*
the per-action operator OK; `git push` / `gh pr create` deliberately unmatched); an
ask-gate on knowledge-backend MCP writes (makes the HITL write discipline
allowlist-proof; reads flow free; the Notion tool-name matcher ships as the v1
reference, adjust-to-your-MCP). Plus: the **two-tier enforcement vocabulary**
(hard-deny for never-legitimate actions vs ask-gate for operator-only one-way doors)
recorded in the settings hook registry and the conventions' HITL heuristics;
fail-open warnings name the surviving backstop; and the D9 CI items.

### E · Reviewer memory & craft (Tier 1/3)

Per-project memory frontmatter on the three shipped reviewers (D7), plus the
precedent-keeping discipline in the reviewer-authoring note: four memory genres
(out-of-scope precedents, clean-review calibration baselines, de-facto-convention
prior art, conforming-pattern records); rule-shadowing memories name their expiry
condition; a clean review is a calibration asset (record why it was clean); **verify
by artifact, never by the diff's self-description** (commit order proves red-first;
grep-diff proves index sync); red-flag checklists pair with maintained do-not-flag
guard lists; a clean verdict on out-of-surface diffs is correct output; out-of-scope
precedents record the surface split, not a blanket exemption; when a rule clause
changes or retires, the reviewers that restate it are updated in the same change.

### F · Testing (Tier 1)

Two additions to `testing.md`, both incident-born: an **Integration cadence**
section (suites excluded from the CI gate need an explicit run cadence — after the
event classes that actually cause staleness, e.g. any merge that re-points a live
surface, and periodically between — or their pins rot silently; the sweep runs alone
against shared backing services; the sweep task pins its own optional dependency
groups or suites skip cleanly) and a **frozen-state pins over append-only stores**
anti-pattern (pin what the test owns — earliest row byte-exact, later rows
constrained to same-grain content copies, direction-agnostic; leave lifecycle claims
to lifecycle tests).

### G · Frame & issue lifecycle (Tier 1)

Three lifecycle grains the mutation discipline didn't name: an **additive
completeness pass** on an already-roughed-in milestone (classify each instinct as
present / genuine gap / deferred / category-error-recorded; lands as an append-only
ledger row); an **operator-gated in-place body refresh** for un-executed issues
whose specs carry factually wrong mechanisms (provenance comment + ledger row;
executed issues never retro-edited; shape changes still close-and-recreate); and
**milestone-scoped re-framing** (a new frame supersedes only one milestone of a
prior frame; the prior frame stays Active with an annotated status; retired ACs
recorded as retired-un-executed). Plus: the frame ledger broadens into a
milestone-lifecycle event log; the frame template gains inline `[F<N>.AC<M>]`
trace-ID examples (fixing the kit's own failing verification grep); the conventions
acknowledge R-issue-local AC numbering as the test-side trace anchor.

### H · Decision governance (Tier 3)

The charter meta-issue pattern gains a **pre-registration flavor** for wide
comparative milestones (closed candidate set, named targets and thresholds,
evaluation protocol, expected-outcome pre-commitments including likely-nulls, named
limitations every output inherits); deviations from pre-committed rules land as
**refining records with an honest-disclosure block**; post-freeze arrivals join an
exploratory tier that is surface-only at the gate; a standing gate's no-change
verdict is **recorded as a re-affirmation event**; risky-dependency spikes
pre-declare three first-class outcomes (promote / named fallback / documented drop);
**standing authorizations are scoped and recorded** and always exclude designated
one-way actions; `adr-new` documents clause-level Refines narratives and
Refines-targeting-non-decision-clauses; two optional-example extensions
(event-level companion docs linked from ledger rows; interface commitments
discharged as an authored hand-off spec with an audience-assumption header).

### I · Rules hygiene & posture (Tier 3/4)

Empirical operational constraints are **dated measurements with re-check triggers,
not standing rules** (a workaround written as a standing rule outlives its
evidence); **no unsourced claims about external-platform behavior** in rules files
(they propagate to sibling docs and reviewers before anyone re-checks); the D8
invocation-posture flip; the conventions' tooling-conventions row names model/effort
orchestration conventions as a recordable per-project choice.

### J · The tooling complex as templates (revised constraint 2)

Five new kit artifacts in the template register: `.claude/rules/workflows.md`
(the plan-mode/tasks/subagent triad, when-to-plan-mode, plan-revision signals,
verification-before-completing, dispatch and task-tracking judgment,
narrate-during-iteration, workflow anti-patterns, rules index);
`.claude/rules/orchestration.md` (ceiling rule, role ladder, effort-axis heuristic,
dispatch-mechanism decision, fan-out discipline pointing at the canonical grounding
statement; fast-aging platform specifics carried only as dated-stamped observations,
cost tables omitted); `.claude/rules/tooling.md` (built-ins-first principle and the
per-surface decision-rule table skeleton; stack sections bracketed; distinct from
blueprint's task-runner/CI `templates/tooling.md` — the two own different concerns);
`.claude/workflows/review-sweep.js` (find-then-adversarially-verify review
orchestration consuming the kit's reviewer roster; triage stays with the caller);
`.claude/agents/Explore.md` (cheap-tier read-only search exemplar of the role
ladder's mechanical tier).

## Non-goals — explicitly NOT harvested

- The demonstrable-output toolchain and its house-style craft (harvest 1 D5,
  re-confirmed by the operator this pass).
- The instance's config-audit workflow artifact (instance-checklist-specific; its
  pattern gets one sentence in the orchestration template).
- A standalone dependencies rule file (the conventions' settle-window section is
  the single owner; a second surface would drift).
- Version-specific platform runtime mechanics (age too fast even dated).
- Dense ADR-index digests (the kit's one-line index convention stands).
- Any reference to the private instance, anywhere in kit content.

## Verification — definition of done

Same battery as harvest 1, plus one flip:

1. Portability greps pass; counts ≤ pre-harvest baseline — except the trace-ID
   template grep, which this harvest turns from silently-failing to green.
2. No reference to the private instance anywhere in the diff (word-boundary
   denylist; "increase" false-positives excluded).
3. `test_cases.md` updated for framing and rough-in behavior changes.
4. Cited reference files exist; new rule templates are listed in the kit CLAUDE.md
   repo-layout tree and cross-referenced from the surfaces that point at them.
5. Both `/finish` copies byte-parallel; hooks pass `bash -n`; `settings.json` valid.
6. Framework-not-tooling check under the revised constraint: template register only,
   bracketed placeholders for anything project-specific.
