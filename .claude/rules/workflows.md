# Workflows — agent workflow patterns

> **This file is a portable rule.** It applies as shipped. Its one bracketed section (§ Cost+scope-explicit) is optional — fill it if the project tracks paid resources or agent-run quota, delete it otherwise. It guides which workflow pattern to apply when working in the project. Pairs with [`tooling.md`](tooling.md) (which tool) and [`orchestration.md`](orchestration.md) (which model/effort per dispatched agent) — together they answer "which pattern, which tool, which tier."
>
> Synthesized from Anthropic's [Claude Code best practices](https://www.anthropic.com/engineering/claude-code-best-practices), the [Humanlayer CLAUDE.md guide](https://www.humanlayer.dev/blog/writing-a-good-claude-md), the [Steve Kinney TDD-with-Claude course](https://stevekinney.com/courses/ai-development/test-driven-development-with-claude), and the Kiro / Spec-Kit / Martin-Fowler SDD comparison.
>
> The principle: **patterns are conditional, not universal.** TDD adds value when the spec is clear and the domain is deterministic; it adds friction when the work is exploratory or UI-visual. Subagents preserve context when the search would bloat the main session; they waste tokens when the search would fit in five messages. Match the pattern to the work, not the other way around.

## The triad: plan-mode + task-tracking + subagent dispatch

The high-leverage workflow shape for work that spans more than one file or one session:

1. **Plan mode** separates planning from execution. Read-only; the agent can read, search, dispatch research subagents, and ask questions — but cannot write, edit, or modify state. Forces alignment with the operator *before* code lands.
2. **Task-tracking** (the harness's task list) decomposes the plan into discrete trackable units. Each task is a step toward done. You can't add unbounded work — the task list IS the work surface.
3. **Subagent dispatch** (a search agent for fast codebase scans, a planning agent for design alternatives, general-purpose for complex multi-step research) offloads work that would bloat the main session. Run synchronous for sequential dependencies, asynchronous for truly parallel work.

The triad works because: plan mode prevents wrong directions; task-tracking enforces discipline (visible scope, completion gating); subagents preserve context (main session stays clean for synthesis + execution). For cascade work, the triad maps onto `/finish` directly — the issue body feeds executable research then a plan-mode gate; the task list is the in-session decomposition; subagents handle the deep research the rough-in spec implicitly assumes.

## When to enter plan mode

**Enter plan mode for**:

- Tasks touching > 2 files
- Tasks with architectural implications (introducing a new module, changing a public interface, modifying a workflow rule)
- Ambiguous specs (the issue body has `[ASSUMPTION:]` tags, or the acceptance criteria don't obviously translate to code)
- Multi-step refactors
- Anything where the cost of going the wrong direction exceeds the cost of planning

**Skip plan mode for**:

- Single-file fixes
- Typo corrections
- Mechanical refactors with clear-cut scope (rename a private symbol, update a comment, bump a version pin)
- Tasks where the operator already wrote the diff in chat

`/finish <N>` runs its research **executably** (in the operator's current permission mode) and then enters plan mode for the formal plan + the approval gate — the read-only gate covers the *plan*, not the research (see `.claude/commands/finish.md` Step 5: 5a research → 5b plan-gate). If an issue were trivial enough to skip the plan gate, the rough-in author would not have created a separate sub-sub-issue for it.

## Signals the plan needs revision

Stop and surface — **do not patch the spec mid-flight** — when:

- An acceptance criterion turns out unverifiable as written
- The technical detail conflicts with existing code, an ADR, or the framing milestone
- An assumption resolved at plan time turns out to have a hidden constraint
- The work reveals a missing dependency (the issue says "after X is done" and X isn't done)

The right move is to abort `/finish`, return to chat, and run rough-in for a re-rough-in event that produces a corrected spec. **Improvisation past the spec is silent failure** — see Anti-patterns.

## TDD where merited

**Three regimes** per [`testing.md`](testing.md) — choose based on module class, not personal preference:

| Regime | Module class | Workflow |
|---|---|---|
| **Test-first (TDD)** | Pure-function logic, decision modules, state machines, persistence ranking | Tests fail red → implement to green → refactor |
| **Conformance-first** | Behaviour adapters, external-service clients, hardware/sidecar boundaries | Behaviour declared → conformance loop → shim dispatch test → impl |
| **Tests-as-shape-of-done** | UI render, end-to-end integration, on-device rehearsal, declarative/query models | Build the surface → assert against observable behavior |

**Practitioner nuance on TDD with AI**:

- TDD adds value when: the spec is clear, the domain is deterministic, tests run fast. The test-name-quotable-from-acceptance-criterion mapping makes the contract explicit.
- "TDD feels frictional" usually signals **you're in the wrong regime** (per [`testing.md`](testing.md)), NOT that TDD is optional on logic modules. If the feature is exploratory (design-first), the module belongs in shape-of-done. If tests would require heavy mocking of external systems, the boundary belongs in conformance-first. If the work is UI/visual, screenshot iteration replaces test iteration. Logic-regime modules remain TDD-required.
- **Structural enforcement matters more than instruction**: writing tests as failing red BEFORE implementation prevents the implementer from rewriting them to pass. Committing the test first makes the contract immutable for that PR. The hooks in `.claude/hooks/` + the project's `check` task enforce non-negotiable invariants at runtime — they're far stronger than instructions.

## Verification-before-completing

**The single strongest differentiator** between working and broken agentic setups per Anthropic's best-practices guide.

Always provide acceptance criteria OR a failing test OR a screenshot OR a validator script **upfront in the prompt**. Examples:

- "Add error logging" → "Add error logging. Verify with a test that the error handler logs a message when the payment service fails. Run the test after implementing."
- "Update the dashboard layout" → "Update the dashboard layout to match `[screenshot]`. After implementing, take a screenshot of the result and compare to the reference."
- "Fix the lint error" → "Fix the lint error. Verify with `<the project's lint command>` exiting 0."

Without verification, plausible-looking code fails on edge cases and the operator becomes the only feedback loop. The cascade encodes this as `## Done signal` in every rough-in issue body — that's the verification surface the implementer runs.

**Verify-before-completing rules**:

1. Never claim "done" without running the verification command(s) and reporting their output (exit code at minimum).
2. For UI work, take a screenshot (or describe the visible state) — type-checking and tests don't catch visual bugs.
3. If the verification command fails, fix the underlying issue; don't skip or comment-out to make it pass.
4. If you can't run the verification (no UI, no test infrastructure), say so explicitly — don't claim success.

## Subagent dispatch

Subagents (search, planning, general-purpose, project-local reviewers) offload work that would bloat the main session. Which **model and effort** each dispatched agent gets — and the choice between skills, subagents, saved workflows, and agent teams — is governed by [`orchestration.md`](orchestration.md); this section owns the when-to-dispatch-at-all judgment.

**Dispatch one subagent when**:

- The scope is known and confined (single area of the codebase)
- The query is research-only (find, read, summarize — not modify)

**Dispatch 2–3 subagents in parallel when**:

- The scope is uncertain and multiple areas need exploration
- You need independent perspectives on a design (e.g., simplicity vs performance vs maintainability)
- The work would generate > 20 messages of search/log output in the main session

**Don't dispatch when**:

- The task is small (< 5 messages)
- The agent would need to ask the operator a clarifying question (subagents can't; only the main session can)
- The verification step needs to happen interactively

**Never delegate understanding.** The subagent gathers; you synthesize. Don't write "based on your findings, fix the bug" — write "Read `<file>:<line>`. The bug is that X happens when Y. Fix it by changing Z." If you can't write that specific instruction, the subagent hasn't given you enough — read the findings, then write the instruction.

**Ground the fan-out.** Any existence/absence claim a dispatched researcher asserts is verified repo-wide, verifiers preferentially attack negative claims, and drafters cite the run's grounding corpus — the full three-rule statement lives in the rough-in skill's `references/research-phase.md` § Grounding existence claims.

## Task-tracking vs in-head

**Track tasks** when:

- The work has ≥ 3 distinct steps
- The work spans multiple files / commits
- You're in plan mode (decomposition before execution)
- Multiple parts have dependencies you'll forget without writing down
- The operator will want to see progress without reading every tool call

**Don't track** for:

- Single-step tasks (read a file, write a one-liner, run a command)
- Tasks where the steps are sequential and obvious
- Trivial work where tracking would be ceremony, not signal

After completing a tracked task, **mark it completed immediately**. Don't batch updates. The task list is a live status surface for the operator; lag = confusion.

## Narrate-during-iteration

- Keep text turns flowing during back-and-forth. Don't go silent for 5 tool calls.
- Narrate **before** an action (one sentence: what you're about to do and why)
- Narrate **after** a result if it changes direction (one sentence: what you found and what's next)
- Reserve preview-and-confirm gates for genuinely risky ops — deletions, pushes to shared branches, anything that affects state outside the local repo

Don't preview-and-confirm trivial things (reading a file, running a check command). Don't go silent through a long sequence of edits. Find the middle: brief narration at meaningful moments.

## Cost+scope-explicit *(optional section — keep if your project tracks paid resources)*

[If the project's viability depends on staying within a resource budget, record the discipline here. The observed shape: every cascade artifact touching paid resources or scope surfaces (1) the monthly cost — default free tier; if non-zero, name the tier and the amount — and (2) the required-vs-aspirational distinction (which deliverables are load-bearing vs nice-to-have). Default to the free tier; a paid resource is named explicitly for the operator's eyes-open approval. Per-milestone cost surfaces live in the framing docs; per-PR cost notes go in the PR body when a paid resource is introduced or changed.]

## Spec-driven development (SDD)

The cascade phases are this project's SDD instantiation — see `cbk-conventions.md` § Spec-Kit vocabulary mapping for the Rosetta stone to Spec Kit / Kiro vocabulary.

**Don't ask the model to write freeform specs.** Verbose AI-generated specs get ignored. Use the cascade skills (which are bounded by HITL gates + structured outputs). If a non-cascade spec is needed, write it yourself in EARS notation (Given/When/Then for acceptance criteria) and keep it ≤ 1 page.

**The cascade IS the SDD discipline**; respect the phase boundaries. Skipping framing for a workstream and going straight to rough-in is "vibe-coding the spec" — a known anti-pattern.

## Anti-patterns

Workflow-level anti-patterns are inline here; domain-specific anti-patterns (testing, logging) live in their canonical rule file and are pointer-referenced below. Point, don't embed — duplicating anti-patterns across sibling rule files burns instruction-following budget and creates drift risk. The canonical file owns the depth; this file points at it.

**Workflow-level (inline)**:

| Anti-pattern | What it looks like | Mitigation |
|---|---|---|
| **Vibe coding** | Loose plan, no spec, "just start coding" on multi-file work | Use the cascade (rough-in → `/finish`) for any multi-file work; plan-mode for anything ambiguous |
| **Scope creep** | The agent autonomously "improves" beyond the request — touches files not in the issue, refactors unrelated code | Surface scope additions explicitly; never silently expand. The audit trail of operator-directed scope additions belongs in the PR body. |
| **Silent failure** | The agent says "done" but tests fail / behavior is wrong / docs lie | Verification-before-completing; report verification command exit codes |
| **CLAUDE.md / AGENTS.md bloat** | The file grows past ~200 lines; rule adherence collapses | Keep the top-level file focused on the working contract; depth lives in `.claude/rules/*.md` and `docs/`. Hooks enforce non-negotiables more reliably than instructions. |
| **Re-litigating ADRs** | Proposing changes that contradict an immutable ADR | The ADR-conformance reviewer + `.claude/hooks/protect-immutable-adrs.sh` catch most cases. When proposing a change that supersedes an ADR, write a new ADR with a `Supersedes:` field. |
| **Over-eager subagent dispatch** | 10 parallel agents for a small feature; tokens burnt for no benefit | Dispatch only when context-bloat risk is real, not by default. Single search agent for known scope; 2–3 only when the work genuinely parallelizes. |
| **Skip-to-green** | Tests fail; mark them skipped/expected-fail instead of fixing | Investigate root cause; surface to operator if the fix is beyond scope. Never skip-to-green. |

**Testing anti-patterns** — see [`testing.md § Anti-patterns`](testing.md) for the canonical list. Briefly: post-hoc TDD (test written after the implementation, knowing the answer — commit the test red first); snapshot tests as acceptance (assert properties, not frozen bytes); coverage-driven test bloat (every test must answer "what would a future maintainer be wrong about without this?"); frozen-state pins over append-only stores (pin what the test owns).

**Logging anti-patterns** — see [`logging.md § Anti-patterns`](logging.md) for the canonical list. Briefly: per-tick logging in high-frequency loops (telemetry events instead); string-interpolated context (structured metadata instead).

## Index of `.claude/rules/*.md`

| Rule | Use when | One-liner |
|---|---|---|
| [`testing.md`](testing.md) | Writing tests | Three regimes; test-name-quotable-from-acceptance-criterion; integration cadence |
| [`pr-review.md`](pr-review.md) | Triaging review findings | Four-class rubric; dispatch roster; adversarial-verify option |
| [`simplification.md`](simplification.md) | Running `/simplify` | Behavior-preserving auto-apply; same four-class triage; non-skippable |
| [`cbk-conventions.md`](cbk-conventions.md) | Working with cascade artifacts | Layout, branch names, PR markers, [skip ci] discipline, mutation discipline |
| [`knowledge-backend.md`](knowledge-backend.md) | Reading/writing the knowledge backend | HITL announcement discipline; write tiering |
| [`logging.md`](logging.md) | Adding structured-log calls or telemetry | Structured-only; correlation-ID propagation; telemetry-vs-Logger boundary |
| [`tooling.md`](tooling.md) | Picking a tool | Built-ins first-line; MCPs second-line for capability gaps; per-tool decision rules |
| [`orchestration.md`](orchestration.md) | Dispatching any agent, subagent, or workflow stage | Model×effort tiering under the ceiling rule; dispatch-mechanism decision; fan-out discipline |

## See also

- [Anthropic — Claude Code best practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Steve Kinney — TDD with Claude](https://stevekinney.com/courses/ai-development/test-driven-development-with-claude) — when TDD adds value vs friction
- [Humanlayer — Writing a good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md) — the 200-line rule, hooks-over-instructions
- [Martin Fowler / Birgitta Böckeler — SDD survey](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html)
- [Addy Osmani — How to write a good spec for AI agents](https://addyosmani.com/blog/good-spec/) — what `[ASSUMPTION:]` tagging buys
- [`tooling.md`](tooling.md), [`orchestration.md`](orchestration.md) — sister rules
