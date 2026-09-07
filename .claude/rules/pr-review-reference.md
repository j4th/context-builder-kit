---
paths:
  - ".claude/rules/pr-review*.md"
  - ".claude/agents/**"
  - ".claude/workflows/**"
  - ".github/workflows/**"
---

# PR Review Rules — the reference half

> **Path-scoped.** Loads when a reviewer agent, a workflow, a CI workflow, or this rule pair is read. `pr-review.md` (always loaded) keeps a pointer heading for every section here. **A triage is not a file read**: the executor reads this file by name at its triage step (`commands/finish.md`), because nothing else triggers it there. Sections were moved verbatim on 2026-09-06. See `cbk-conventions.md` § Rule loading and the instruction budget.

## Apply / Surface calibration

The calibration that distinguishes this rubric from a generic "Apply correctness, Surface taste" split. Each category names what crosses into Apply and what stays in Surface.

### Documentation

| Sub-category | Class | Why |
|---|---|---|
| Existing-doc improvements (clarity, precision, accuracy on docstrings/comments that already exist) | **Apply** | Behavior-preserving. Rewrite cost is symmetric to review cost. Future AI sessions read these and the cost of leaving them imprecise compounds. |
| Missing docstring on a function/module that is **entirely undocumented** | **Apply** | The gap is structural, not subjective — there's no debate about whether one "should exist." Apply when ≤5 lines of generated docstring. |
| Doc *expansion* of a section that already has some explanation ("this could use more detail") | **Surface** | Subjective; the human decides whether the existing explanation is sufficient. Matches CodeRabbit's separate-PR pattern for docstring generation. |
| Comment that is factually wrong (describes behavior that no longer exists) | **Apply** | Rot. Already in the standard Apply class. |
| README / ARCHITECTURE.md / CLAUDE.md prose improvements | **Apply** when ≤5 lines and clearly factual; **Surface** when stylistic or restructuring | Same gate as docstrings. |

### Defensive additions

| Sub-category | Class | Why |
|---|---|---|
| Null guard / type narrowing / assertion when there's a **concrete failing path** in the diff (the test suite would exercise it, or a demonstrated nil/error case appears in the changed code) | **Apply** | "Prove it or discard it" — if the foot-gun is real, the fix is cheap. |
| Speculative guard — "what if X were null someday" with no demonstrated path | **Surface** | This is the canonical noise category in practitioner literature. Speculative guards train people to ignore the bot. |
| Cleanup that prevents state leak between tests (missing `setup` / `teardown` / `finally`) | **Apply** | Concrete: the test pollution is reproducible. |
| Race window / silent failure with concrete timing or path evidence | **Apply** | Concrete defect. |

### Naming and renames

| Sub-category | Class | Why |
|---|---|---|
| Local-symbol rename, new name is a **fact-based correction** (the symbol is mis-named for what it does) | **Apply** | Cheap; tests catch breakage; future readability compounds. |
| Local-symbol rename, new name is a **taste improvement** (debatable better) | **Surface** | Genuine disagreement; human's call. |
| Cross-file rename, exported symbol, public API | **Apply with care** | Ripple effect across consumers; needs human scrutiny even when correct. |

### Test additions

| Sub-category | Class | Why |
|---|---|---|
| Test for an uncovered branch **on the diff**, when the test is small | **Apply** | Free coverage on code we just wrote. The branch is real; testing it costs nothing. |
| Test for code outside the diff | **Surface** | Out of scope for this PR; the pattern of "while we're here" tests grows the PR uncontrollably. |
| Suggested property-based / fuzz / load test as follow-up | **Surface** | Material new test infrastructure; human decides. |

### Style / formatting

| Sub-category | Class | Why |
|---|---|---|
| Formatter / linter violations not auto-caught by `mise run check` | **Apply** | If the project's check task should have caught it, fixing the lint is part of finishing. |
| Stylistic preference with a substantive rationale (e.g., consistency with a project pattern in `STANDARDS.md`, readability impact the agent can articulate) | **Surface** | Genuine taste call; human's judgment. |
| Stylistic nit the agent suggested without a strong rationale (one-liner vs multi-line, function vs method, naming flavor) | **Reject** | One-line dismissal in the hand-off. Surfacing these with verbatim rationale just inflates the user's review surface — that's the exact pattern that trains humans to ignore the bot. |

## Path-conditional aggressiveness

The rubric isn't uniform across path types. Adapt to where AI context is strongest vs weakest:

- **Test files** (`test/`, `tests/`, `*_test.*`, `__tests__/`) — **more aggressive Apply**. AI context for test-shape and assertion patterns is strong; blast radius is contained (test pollution catches itself). Naming, restructure-for-clarity, even modest refactors lean Apply.
- **Business logic** (`lib/`, `src/`, `apps/`) — **standard rubric**. Apply correctness/safety/behavior-preserving improvements; Surface style/structural changes.
- **Public API surface** (anything exported from a published package, anything a downstream consumer imports) — **more conservative Apply**. Even behavior-preserving renames have ripple effects. Apply with care for any signature change; Surface for any rename of an exported symbol.
- **Infrastructure / config** (`config/`, `.github/workflows/`, deployment manifests, `mise.toml` and equivalent) — **more conservative Apply**. Silent failures here are expensive (CI breaks, deploys break). Surface anything beyond strict factual fixes; let the human decide.

## Anti-patterns

### ❌ Auto-applying speculative findings

If the agent flagged something with no concrete failing scenario, no test pollution, no demonstrated path — Surface it. Auto-applying speculative changes trains future humans (and agents) to ignore the bot's findings; the noise is the cost.

### ❌ Squashing multiple Apply commits into one

Per `/finish`'s atomic-commits-not-squash discipline, each Apply finding gets its own focused commit on the branch. The squash happens at merge-time on `main` (the project's squash-merge convention), not pre-PR. One commit per logical fix.

### ❌ Applying when `mise run check` isn't passing first

Apply commits over a red branch hide regressions. Run `mise run check` after each Apply (or at minimum after the last in a batch); revert the Apply if it breaks the check, and reclassify as Apply-with-care or Defer.

### ❌ Re-running review-toolkit to override the human's earlier Surface decision

If the human reviewed the draft PR, decided to leave a Surface item alone, and the next sweep flags it again with the same reasoning — that's fine to surface again, but **don't auto-apply it**. The human's call stands until they explicitly ask for the change.

### ❌ Running review-toolkit on a docs-only PR

If the diff is entirely under `docs/` or matches `*.md`, the toolkit's specialized agents have nothing to chew on. Skip the sweep; the simplify pass is sufficient.

### ❌ Padding the hand-off summary with "looks good" prose

The hand-off is the audit surface. List counts per class plus the concrete actioned items and the verbatim Surface entries. If everything classified as Reject, say so in one line — don't pad.

### ❌ Describing a review instead of running one

"The diff was reviewed for X, Y and Z" by an agent that read the diff is not `/simplify` or `pr-review-toolkit:review-pr` having run. The floor is two skill invocations; a description of what they would have found is the failure mode the `## Review gate` block exists to catch (`pr-review.md` § The floor).

### ❌ A PR body without a `## Review gate` block

A body that carries `## Triage` but no `## Review gate` is treated as un-reviewed whatever the hand-off says — the block is the only auditable record that the two skills ran, and a waived skill is recorded on its line, never omitted.

## Authoring a project-local reviewer

The contract's paragraph (`pr-review.md` § Project-local agents › Authoring) gives the shape; this is the craft that real runs settled on.

- **Two archetypes.** A **decision-text reviewer** checks a diff against clauses in frozen decision records (ADRs, a design-decisions file): it follows `Refines:` chains, quotes the clause, and reports the violated clause with the rubric class. Beneath it sits the **laws reviewer**: a domain contract stated as a table of *laws* (invariants a subsystem must hold — a clock discipline, a purity boundary, a schema's byte-identity), each law one checklist item. The laws reviewer is the semantic complement of a CI grep — where `ci/check-<thing>.sh` greps tokens at fixed paths, the reviewer judges what the tokens mean, and its report says which of the two caught each finding.
- **The section skeleton** (the exercised laws reviewer's, generalized): `## Inputs` · `## Contract surface (frozen sources, in precedence order)` · `## Checklist (grep-first, then read context)` · `## Do-not-flag guard list` (each entry with its eviction condition) · `## Not covered` · `## Report` · `## Hand-offs` · `## Writing memory` (the kit's shared section, last). A checklist item reads: the law's name and its source clause; the grep that finds candidates; the sanctioned sites the grep will also hit; what a hit means.
- **Grep-first checklist items.** Every item begins with the grep that finds candidates (`rg -n '<pattern>' <paths>`), then the semantic check on what the grep returned. A checklist item without a grep is a reviewer reading the whole diff on every run.
- **Standing refusals with their sanctioned alternative.** State what this reviewer never does — never proposes a new ADR (`/adr-new` is the route), never edits the diff (report, never propose a patch), never re-litigates a memory-recorded disposition — each with the route the work takes instead.
- **Stated coverage gaps.** A `## Not covered` list: the surfaces adjacent to this reviewer's contract that it does not check and who does. A reviewer without one is assumed to cover what it does not.
- **Report, never propose.** Findings are `file:line` + the violated clause + the rubric class + a one-sentence fix direction. Patches, rewrites and "here is the corrected block" are the executor's job after triage.
- **Two drift tripwires, in the body.** (1) *Roster:* "my entry in `pr-review.md` § Project-local agents must exist with my dispatch condition; if it does not, report myself as unregistered before reviewing" — the sweep reads that roster at runtime, so an unregistered reviewer never runs in it. (2) *Memory:* the memory-directory tripwire. Both live in the kit's shared `## Writing memory` section (the last section of every shipped reviewer, kept identical by the verification block), so a project-authored reviewer gets them by carrying that section.
- **Eviction conditions for guard lists.** Every do-not-flag entry carries the condition under which it is removed ("until the conventions formalize X"; "while `<file>` still carries `<token>`"). A guard list without eviction conditions only ever grows, and the reviewer's silence stops meaning anything.
- **Path-matched triggers come from usage, and are written for the roster reader.** The scope this section lists for a domain reviewer is the set of directories where the governed API is *used* (grep the tree for its calls and types), written as bare path prefixes on the reviewer's own entry line — the sweep's roster agent parses this section into `pathHints`, matches changed paths by prefix, and reports a glob or prose hint as dropped coverage.

## Reviewer precedent memory — genres and staleness

The depth behind `pr-review.md` § Reviewer precedent memory. Across runs a reviewer accumulates four genres of precedent, and consulting them before flagging is what stops re-litigation of settled calls:

- **Out-of-scope precedents** (`out-of-scope-`) — a token or surface ruled outside this reviewer's contract, recorded with the *surface split*, since the same token can be in-scope on one surface and out on another (a log field vs a persisted column).
- **Clean-review calibration baselines** (`clean-baseline-`) — a clean review is a calibration asset: record *why* it was clean, what was checked and by what method, so the next run inherits the method, not just the verdict. **One baseline per surface, appended to in place**: a further clean pass on the same surface adds a dated delta line, and a new file is earned only by a new method. A baseline for a tree the project marks throwaway carries the expiry "delete when the tree is deleted".
- **De-facto-convention prior art** (`convention-`) — an established local pattern that deviates from a documented rule; a deviation worth keeping permanently belongs in the rule, not the memory.
- **Conforming-pattern records** (`conforming-`) — both-polarity evidence, verified-conformant and verified-violating instances, with dates.

Three further kinds carry their own prefixes: dependency facts (`dependency-`; a pinned library's verified behavior, with its version), findings with their disposition (`finding-`; what was flagged, what the caller decided, why — so a settled call is not re-litigated), and reusable verification techniques (`technique-`; a method worth reusing, with the command that runs it).

**Every genre carries a reconsider trigger.** A baseline scoped to a snapshot of a moving set (an ADR range, a rule section) names the change that invalidates it. A static drop condition is one form; the other is a **living record** appended across passes — a dated `**Update (<date>, <branch>):**` block naming the bar it re-decides against and the verdict held after this pass, which may revert — compacted when it carries more than three updates (fold the older ones into the summary, keep the last two verbatim).

## When to update this file

This rules file is load-bearing the moment `/finish`'s review pass dispatches `pr-review-toolkit`. Update it when:

- A finding type recurs in the Surface column that should clearly be Apply (or vice versa) — add a row to the Apply/Surface calibration table.
- A new noise pattern emerges that should be excluded — add it to the "What NOT to flag" list.
- A new project-local reviewer agent is authored — add it to § Project-local agents.
- A rule clause any rules file states is changed or retired — sweep the reviewer agents that restate it as an enforcement target and update them **in the same change**; reviewer scope lists cache rule content and rot silently when the rule moves without them.
- A path-conditional pattern emerges (e.g., a project-specific directory that needs its own aggressiveness setting) — add a row to § Path-conditional aggressiveness.
- The break-glass mechanism gets used more than ~5% of the time — that's a signal the rubric is mis-calibrated, not the override mechanism. Investigate.
- The `## Review gate` block's shape changes — edit its one home (`pr-review.md` § The floor) and check that `/finish` Step 10 still cites it rather than carrying a copy.

The corresponding entry in `docs/STANDARDS.md` § PR review process points here for the operational detail; that file states the principle, this file states the contract.
