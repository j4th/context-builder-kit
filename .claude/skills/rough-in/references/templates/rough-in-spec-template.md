---
name: Cascade rough-in issue
about: A rough-in sub-sub-issue under a framing milestone. Implementable by `/finish {issue_number}` in Claude Code, or by a human reading the body directly.
title: "[<workstream-slug>:F<#>:R<#>] <intent>"
labels: ["cascade-depth:roughed-in"]
assignees: []
---

<!--
============================================================================
BUNDLED FALLBACK COPY — read this first if you're operating on this file.
============================================================================

This file is a fallback. The canonical template lives at:

    .github/ISSUE_TEMPLATE/cascade-rough-in.md

in the user's repo, committed by scaffold's Stage 2.5 step. Rough-in
reads the disk copy first via `get_file_contents` and only falls back to
this bundled copy if the disk copy is missing or unreadable.

If you're reading this comment as part of a rough-in run, it means one
of two things:

  1. The user's repo doesn't have `.github/ISSUE_TEMPLATE/cascade-rough-in.md`
     because scaffold's Stage 2.5 step was never run (brownfield repo
     that pre-dates the cascade issue templates feature). The right move
     is to surface this as a brownfield gap in the inheritance summary
     and propose committing the cascade templates as a Suggested
     foundation doc update before proceeding.

  2. MCP couldn't reach the repo for some reason but the user has
     confirmed the templates exist. Use this fallback for the current
     run and flag the discrepancy in the output.

Either way, the disk copy is always the source of truth. If the disk
copy and this fallback diverge (the user has hand-edited the disk
template), use the disk copy and mention the divergence as informational.

See `references/backends.md` § Issue templates as workspace
infrastructure for the full inherit-from-disk discipline.

The rest of this file is the cascade default content for cascade-rough-in.md
— identical to what scaffold ships in its own bundle, kept in sync via the
scaffold->blueprint->framing->rough-in propagation pattern.
============================================================================
-->

<!--
Cascade rough-in issue template.

This issue is structured so that:

  1. A human reading it can understand the intent, the work, the
     acceptance criteria, and the contract for closing it — without
     any cascade tooling.

  2. The cascade's `/finish {issue_number}` Claude Code slash command
     can read this body and hand it to plan mode. /finish anchors
     hardest on the "## Implementation" section but reads the rest
     as supporting context.

  3. The issue lands on the Projects v2 board with `cascade-depth:roughed-in`
     and is parented under a framing capability sub-issue. Board
     automation moves it to Ready on creation, In Progress when picked up,
     In Review when a PR opens, and Done when the PR merges.

You can edit any section freely. Prose, links, code snippets, references
to other docs are all fine — the template is structural, not dogmatic.

The only hard rule: keep the section headings as written. /finish
identifies sections by heading name, so renaming "Implementation" to
"What to build" will break the slash command's anchoring.
-->

## Context

<!--
One paragraph orienting the reader to where this issue sits in the cascade.
- Which workstream, framing, and milestone is this under?
- What does this issue enable that the cascade needs next?
- What does it deliberately not do (so the implementation stays scoped)?

If you cite cascade docs, link them: docs/cbk/blueprint.md, docs/ARCHITECTURE.md,
docs/cbk/frame-NN.md, etc.
-->

You are implementing R<#> of M<#> under the **<workstream-slug>** workstream's framing capability F<#> (link to parent: #<parent-issue-number>). _One paragraph of context here._

## Assumptions

<!--
Surface assumptions before any implementation content. Per Addy Osmani's
"how to write a good spec for AI agents" pattern. List every gap rough-in
filled in that the user might want to correct: API arities chosen without
verification, library versions assumed available, semantic interpretations
of the framing's intent that could go either way. Include `[ASSUMPTION:]`
tag prefix per item so /finish can grep for them at execution time.

If empty, write `- None — all parameters explicit from the framing intent
and acceptance criteria.` Do not delete the section.

Resolved assumptions (confirmed during implementation) move out of this
section and inline into the relevant ## Implementation paragraph; do not
maintain a separate "Resolved" subsection.
-->

- [ASSUMPTION: <gap description>] <one-line context — why this assumption was made and what would change if wrong>
- [ASSUMPTION: <next>] ...

## Implementation

<!--
The hottest section. /finish anchors on this when constructing the plan-mode prompt.

Target executor: Claude Code plan mode, not a human typing each step by hand.
This matters for how the section should be shaped — plan mode is a
decomposition engine, and over-prescriptive "how" prose overrides its priors
and produces strictly worse code than a cleaner prompt would. See Anthropic's
Claude Code best practices for the framing:
https://code.claude.com/docs/en/best-practices

The full eight properties of a good plan-mode prompt live in the rough-in
skill's references/plan-mode-prompts.md. The short version:

  1. Second person — "Create...", "Add...", "Update..." (instructions, not descriptions)
  2. Self-contained — readable cold, without chasing five other docs
  3. Specific files, constraints, and locked signatures — name the file, the
     contract, and the invariants; inline signatures ONLY if verbatim from a
     locked Interface Commitment (IC-N) from the framing, otherwise leave
     signature shape for plan mode to propose during its Plan phase
  4. Cites cascade docs by section name when rules matter
  5. Specifies the verification step embedded in the work
  6. ~300-800 words (up to ~1000 for cross-crate capstones)
  7. Names what NOT to do (defer-to-later-issue notes)
  8. States intent and constraints, NOT implementation sequences — the
     load-bearing calibration property for Claude-Code-executed workflows

Property 8 is the load-bearing one. The discipline test: scan for fenced
code blocks that are NOT verbatim from a locked IC-N. Each such block is a
candidate for deletion. If removing it would force the reader to make a
decision you already made, the decision belongs in the spec as a constraint
sentence, not as inlined code. If removing it costs nothing because the
properties are stated nearby, delete it. The ONLY legitimate inline code
blocks are IC-verbatim shapes prefaced with "IC-N shape is verbatim and not
negotiable — any deviation is a re-framing trigger."

Things to include:
  - Files to create or modify (with paths)
  - Constraints and invariants the implementation must satisfy
  - IC-verbatim signatures if any, prefaced as non-negotiable
  - Patterns or libraries to follow (with citations, not restatement)
  - Constraints from the cascade docs that apply (cite by section name)
  - Things explicitly NOT to do in this issue (defer-to-later-issue notes)

Things NOT to include (property 8 check):
  - Inlined function bodies for non-IC work
  - Prescribed test function names (plan mode discovers project conventions)
  - Step-by-step command sequences (plan mode decomposes these internally)

If the review of this spec feels like a code review rather than a spec
review, the Implementation section has drifted into prescription. Convert
inlined code blocks to constraint sentences, or delete them and trust plan
mode.
-->

_Concrete, instructional content here. Cite docs by section name when constraints matter. State intent and constraints; leave implementation sequences to plan mode unless an IC locks them._

## Acceptance criteria

<!--
Observable, verifiable outcomes. Each one is a checkbox so the implementer
can tick them off as they go. Avoid "the tests pass" — name the specific
test, command, or observation that proves the criterion.
-->

- [ ] _Specific outcome 1_
- [ ] _Specific outcome 2_
- [ ] _Specific outcome 3_

## Test plan

<!--
Named tests that satisfy each acceptance criterion. The implementer scaffolds
these as failing tests BEFORE writing any implementation code (test-first
discipline for logic-regime modules — see .claude/rules/testing.md for which
modules fall under which regime).

The mapping is:
  - One acceptance criterion → one named test (rephrased from imperative spec
    to declarative test name)
  - The test name should be quotable verbatim from the test runner's output
    (e.g., `mix test --trace` shows the description as you write it here)
  - For ExUnit: `Module.FunctionTest > "fits within 2048 tokens"` form
  - For pytest: `path/to/test_file.py::test_chunks_at_sentence_boundaries` form

Test regime per module class (see .claude/rules/testing.md or whichever rules
file the project uses for the full classification):
  - **Logic** (pure functions, internal state machines, business-rule modules):
    test-first. Tests fail red before any implementation lands. Named here.
  - **Boundary adapters** (driver/port modules, external-service backends,
    hardware/sidecar interfaces): conformance-first. The conformance loop test
    + shim dispatch tests are named here; the per-impl smoke tests are named
    here too.
  - **UI / integration** (web framework views, end-to-end orchestrations,
    hardware-on-real-device rehearsals): tests-as-shape-of-done. Named here,
    but the order is build → assert, not assert → build.

If a regime mix applies (e.g., a logic module accessed via a behaviour),
group the tests by file and note the regime per group:

  ### Logic (test-first)
  - `MyApp.MyModuleTest > "first criterion phrased as a declarative outcome"`
  - `MyApp.MyModuleTest > "second criterion phrased as a declarative outcome"`

  ### Conformance (conformance-first)
  - `MyApp.MyBackend.ConformanceTest > "concrete impl satisfies every behaviour callback"`

If the issue is purely UI / integration, note "Regime: tests-as-shape-of-done"
at the top of this section so the implementer knows the named tests are
written after the surface exists, not before.
-->

- _`Module.FunctionTest > "test name quoting acceptance criterion 1"`_
- _`Module.FunctionTest > "test name quoting acceptance criterion 2"`_
- _`Module.FunctionTest > "test name quoting acceptance criterion 3"`_

## Done signal

<!--
The single command or observation that means this issue is complete.
Usually a `cargo run -- X`, `pnpm test`, or `cargo check` invocation
with expected output, or a "the smoke test in CI passes" statement.
-->

`<command or observation>`

## Dependencies

<!--
Other rough-in issues that must be closed before this one can start.
List them by issue number only so /finish can verify them via the
GitHub API before handing the body to plan mode.

IMPORTANT: reference dependencies by issue number ONLY (e.g., `#42`), not
by number + title. Issue titles can drift during later cascade revisions
(e.g., a slug prefix gets added during a cleanup pass), and a body that
reproduces a stale title becomes misleading even though the number still
resolves correctly. GitHub renders the current title dynamically via
hover cards, so number-only references stay fresh without needing body
edits. If a dependency's context needs more than the hover card shows,
add a one-line note about what the dependency is FOR (what it enables
for this issue), not what it is CALLED.

If there are no dependencies, write "None".
-->

- #<N> _(one-line note on why this is a dependency, if useful)_

## PR contract

<!--
How to close this issue when implementation is complete. Standard text
across all rough-in issues so the pattern is uniform on the board.
-->

When all acceptance criteria are met, open a PR with `closes #<this_issue_number>` in the description. PR title follows Conventional Commits (e.g., `feat(<scope>): <subject>`). The board automation moves this issue to Done on PR merge and ticks the parent's sub-issue progress field forward.
