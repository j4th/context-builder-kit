---
name: Cascade rough-in issue
about: A rough-in sub-sub-issue under a framing milestone. Implementable by `/finish {issue_number}` in Claude Code, or by a human reading the body directly.
title: "[<workstream-slug>:F<#>:R<#>] <intent>"
labels: ["cascade-depth:roughed-in"]
assignees: []
---

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
Named tests that satisfy each acceptance criterion. One named test per
criterion (rephrased from imperative spec to declarative test name),
quotable verbatim from the test runner's output. /finish anchors on this
section for Step 6's red-first scaffolding step on logic-regime modules.

Identify the regime per `.claude/rules/testing.md` (or the project's
testing rules):
  - Logic regime: tests are scaffolded as failing tests BEFORE
    implementation; one test per acceptance criterion.
  - Conformance/boundary regime: conformance + shim dispatch tests for
    behaviour adapters, asserting the contract not the implementation.
  - Tests-as-shape-of-done regime: tests assert user-visible / operator-
    visible behavior after the surface exists; pinning, not driving.

Vague names ("the function works") force the implementer to invent the
contract, defeating the point. Quotable, specific names ("rejects empty
input with InputError::Empty") are the contract written in the same
words the test runner's output will use.
-->

Regime: _logic | conformance | tests-as-shape-of-done_

- _`test "specific contract assertion 1"`_
- _`test "specific contract assertion 2"`_
- _`test "specific contract assertion 3"`_

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
