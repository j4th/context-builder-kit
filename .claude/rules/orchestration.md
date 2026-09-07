# Orchestration — model & effort tiering for agents, subagents, and workflows

> **This file is a template.** Copy it into a target project's `.claude/rules/orchestration.md`, record the project's posture in the bracketed spots, and keep the dated observations current per `cbk-conventions.md`'s dated-empirical-rails principle. Operational rule for **spending model capacity across parallel agents**: which model tier and effort level each dispatched agent gets, on every dispatch surface — agent definitions (`.claude/agents/*.md`), ad-hoc Agent-tool subagents, and Workflow `agent()` stages. Pairs with [`workflows.md`](workflows.md) (which pattern) and [`tooling.md`](tooling.md) (which tool); this file answers **which model, at which effort, how many at once**.

## The ceiling rule

**The main-loop model is the session's hard capability ceiling.** Spawned agents match or tier down — never up.

This is project policy, not a platform invariant — nothing stops an agent definition from naming a higher tier, and the platform enforces no tier relative to the main conversation (an org's model allowlist is the only platform-side restriction). The policy exists because escalation should be a deliberate *session-level* choice the operator makes, not something a subagent definition smuggles in.

**The one-top-tier-agent allowance.** In a session running on the top capability tier, at most **one** top-tier agent per workflow/turn, reserved for the single *integrative* step whose output everything downstream inherits — synthesis, or a final-judgment step. The top tier's capability lead grows with task length and cross-cutting complexity, so its price pays off only there; spending it on short parallel worker calls forfeits the exact property that justifies the cost. Under a mid-tier main loop, top-tier agents are never launched.

**[Record the project's default posture here** — which tier the main loop normally runs, and what a deliberate escalation looks like.**]**

## The role ladder (model axis)

Tier by **role**, not by phase or file type:

| Role | Tier | Why |
|---|---|---|
| Mechanical: extraction, format/lint checks, large-N small-context sweeps, test execution, simple lookups | smallest tier (e.g. Haiku) | The "sub-agent tasks" tier; large cost multiple below the workhorse tiers |
| Finders/gatherers: codebase scans, research gathering, review finding, doc drafting from a complete outline | mid tier (e.g. Sonnet) | Near-frontier at a fraction of the workhorse price; findings get adversarially verified downstream |
| Verify/judge: adversarial verification, judge panels, hard code reasoning, root-cause analysis | workhorse tier (e.g. Opus) | Accuracy outweighs cost where a wrong verdict propagates |
| The synthesis slot (top-tier sessions only, ≤1 per workflow/turn) | top tier | See the one-top-tier-agent allowance |

**Default is inherit (omit the model).** Pinning is the exception, taken only when the role obviously fits a different tier. Never pin *above* the session model. A mid-tier finder feeding a workhorse-tier verifier beats an all-workhorse fan-out on cost with negligible quality loss — the verify stage is what makes the cheap finder safe. Anthropic's published multi-agent result is the canonical precedent for that shape: a strong lead agent over cheaper workers, not a uniform-strong fan-out ([multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system)).

The kit ships two worked exemplars of the ladder: `.claude/agents/Explore.md` (search pinned to the mechanical tier; promote per-invocation for a genuinely hard scan) and `.claude/workflows/review-sweep.js` (roster read at runtime → mid-tier find stage → dedup and a declared bound → verify stage at the session model, effort high; the run logs its planned agent count first and returns its own record; triage stays in the main thread, because judgment belongs to the session model).

## The effort axis (co-equal dial)

Effort is settable per agent definition (`effort:` frontmatter) and per workflow stage (`opts.effort`). It is a **co-equal dial with the model choice, not a cheaper substitute for it.** Anthropic's published heuristic for which one to reach for is a diagnostic question — *"did it not try hard enough, or did it not know enough?"* Raise **effort** when the agent skipped a file, didn't run the tests, or didn't check its work; switch to a **larger model** when it had all the pertinent context, clearly tried, and was still wrong. Their stated default: use the model's default effort level for most tasks ([model & effort in Claude Code](https://claude.com/blog/claude-model-and-effort-level-in-claude-code)).

- `low` — mechanical stages (inventory readers, format sweeps).
- inherit (omit) — the default for standard work.
- `high` / `xhigh` — reserved for the hardest verify/judge stages.
- **Not monotonic on agentic work**: higher effort up front often *reduces* turn count and total cost, while some routes do as well at a middle setting in less time. Treat effort as a dimension to sweep per role rather than a fixed setting — and try `high` before `max`.
- **Not every model has the dial** — check the platform's [effort docs](https://platform.claude.com/docs/en/build-with-claude/effort) for which models support it. An `effort:` pin on a model without the dial is inert: it advertises a dial that never turns. Tier the model, not the dial. *(Dated observation, 2026-07: the smallest tier — Haiku 4.5 — had no effort levels.)*

## The three surfaces + resolution order

→ *Moved to* `orchestration-reference.md` § The three surfaces + resolution order *(path-scoped; see `cbk-conventions.md` § Rule loading and the instruction budget).*

## The dispatch-mechanism decision

| Mechanism | Who holds the plan | Reach for it when |
|---|---|---|
| Skill | The written instructions | Codified procedure executed in one context |
| Subagent (Agent tool) | The model, turn-by-turn | Confined research/task; context isolation |
| Workflow (`.claude/workflows/`) | A deterministic script | Fan-out, pipelines, loops over many agents; repeatable orchestration |
| Agent team | A lead agent + teammates | Long-lived parallel collaborators — [record adoption status; experimental surfaces change fast] |

[`workflows.md`](workflows.md) § Subagent dispatch owns the *when-to-dispatch-at-all* judgment; this table owns *which mechanism* once you've decided to dispatch.

## Fan-out discipline

- **Bound the work, not the concurrency.** The cap below is about how many agents run at once; a *work* bound — how many deduplicated findings a review sweep carries into its verify stage, how many items a fan-out may act on — is a design decision every fan-out declares before it dispatches, logs as a planned count, and reports overflow from, never silently (`pr-review.md` § Fan-outs are bounded: the sweep's 3-per-dimension / 8-verified defaults). Naming the runtime's concurrency cap as a reason to skip a work bound is the mis-sizing this bullet exists to prevent.
- **Let the runtime's cap govern — don't author a lower one.** Size the fan-out to the work, bounded by the harness's authored-size guideline, and let the runtime queue the excess. If throttling appears (agents dying near-instantly with zero tokens, or schema-bound agents returning without structured output), throttle to small waves — and **record the observation dated, with its failure signature and a re-check trigger**, never as a standing cap. A cap written as a standing rule outlives its evidence (`cbk-conventions.md`, dated-empirical-rails).
- **Read contractual limits off the live tool description** (concurrency cap, lifetime agent cap, per-call item cap) rather than trusting a rules-file snapshot.
- **Keep the retry pass regardless of concurrency.** Agents resolve null for reasons unrelated to throttling — filter, re-run the gaps, and log what was dropped.
- **No silent caps**: a workflow that bounds coverage (top-N, sampling, no-retry) must log what was dropped — silent truncation reads as "covered everything" when it didn't.
- **Pilot on a slice** before any large run — a parameterized workflow should accept a scope argument so the first run can cover a bounded subset.
- **Ground existence claims.** Every fan-out drafter/researcher prompt requires repo-wide verification of existence/absence claims; verifier passes preferentially attack **negative** claims; drafters cite the run's grounding corpus before re-deriving facts it already covers. The canonical three-rule statement lives in the rough-in skill's `references/research-phase.md` § Grounding existence claims.

## Applied instances in this project

→ *Moved to* `orchestration-reference.md` § Applied instances in this project *(path-scoped; see `cbk-conventions.md` § Rule loading and the instruction budget).*

## Anti-patterns

| Anti-pattern | Instead |
|---|---|
| Launching an above-ceiling agent "just this once" | The ceiling rule has no exceptions; escalate the *session* deliberately if the task warrants it |
| Several top-tier agents in a top-tier session ("parallel synthesis") | One integrative step per workflow/turn gets the top tier; parallel work is worker-tier by definition |
| Pinning the workhorse tier on every reviewer/finder "for quality" | Mid-tier finder + workhorse verifier is the calibrated shape; an all-workhorse fan-out pays a large multiple for negligible gain |
| Pinning models on every `agent()` call by reflex | Default is inherit; pin only when the role obviously fits a different tier |
| `max` effort as a default "to be safe" | Effort is non-monotonic on agentic work; inherit, then raise only on the stages that prove to need it |
| Fan-out sized by reflex rather than by the work | Pilot on a slice and set a budget directive — the runtime queues the excess, but the tokens are still spent |
| Keeping a workaround after the constraint lifts | Date every empirical rail with its failure signature and a re-check trigger; note retirements inline |
| Quoting "official guidance" with no resolvable source | Cite a URL or an authoritative local doc path. An unsourced quotation in a rules file propagates to sibling docs and reviewers before anyone re-checks it |
| An `effort:` pin on a model without the effort dial | The pin is inert and advertises a dial that never turns. Tier the model, not the dial |
| Choosing the cheap tier and then fanning out wide | Volume beats tier: multi-agent runs cost an order of magnitude more tokens than a chat. Bound the fan-out first, then tier |

## When to update this file

→ *Moved to* `orchestration-reference.md` § When to update this file *(path-scoped; see `cbk-conventions.md` § Rule loading and the instruction budget).*

## Primary sources

→ *Moved to* `orchestration-reference.md` § Primary sources *(path-scoped; see `cbk-conventions.md` § Rule loading and the instruction budget).*

## See also

- [`workflows.md`](workflows.md) — when to dispatch at all; plan-mode, TDD, verify-before-completing
- [`tooling.md`](tooling.md) — which tool for which operation
- [`pr-review.md`](pr-review.md) — the triage rubric `review-sweep` findings feed into
