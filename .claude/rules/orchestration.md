# Orchestration — model & effort tiering for agents, subagents, and workflows

> **This file is a template.** Copy it into a target project's `.claude/rules/orchestration.md`, record the project's posture in the bracketed spots, and keep the dated observations current per `cbk-conventions.md`'s dated-empirical-rails principle. Operational rule for **spending model capacity across parallel agents**: which model tier and effort level each dispatched agent gets, on every dispatch surface — agent definitions (`.claude/agents/*.md`), ad-hoc Agent-tool subagents, and Workflow `agent()` stages. Pairs with [`workflows.md`](workflows.md) (which pattern) and [`tooling.md`](tooling.md) (which tool); this file answers **which model, at which effort, how many at once**.

## The ceiling rule

**The main-loop model is the session's hard capability ceiling.** Spawned agents match or tier down — never up.

**Labelled policy, not platform guidance.** Nothing stops an agent definition from naming a higher tier; the platform-side ceilings are an org's model allowlist and, for the built-in Explore agent only, a cap at Opus on the Claude API (sub-agents § Built-in subagents › Explore). No first-party page states this rule or the allowance below, and the platform's own ladder runs the other way — Opus 5 first, then higher effort, then Fable 5.1 when evals still fall short (the models overview § Compare models) — while a per-completed-task comparison sometimes argues for the higher tier on the hard step. Every page named in short form here is quoted and linked in `orchestration-reference.md` § Generation notes — the sources and § Primary sources. The rule stays because escalation should be a deliberate *session-level* choice the operator makes, not something a subagent definition smuggles in; when the comparison says otherwise, escalate the session.

**The one-top-tier-agent allowance.** In a session running on the top capability tier, at most **one** top-tier agent per workflow/turn, reserved for the single *integrative* step whose output everything downstream inherits — synthesis, or a final-judgment step. The top tier's capability lead grows with task length and cross-cutting complexity, so its price pays off only there; spending it on short parallel worker calls forfeits the exact property that justifies the cost. **The slot is either the main loop or one fresh-context agent**, a per-task call: an agent when the inputs are bulky, the session is long, or the synthesizer should be independent of whoever wrote the prompts; the main loop when the step needs what only the conversation holds or the operator's gate follows immediately. Either way the main loop reads the *product*, verifies the claims it carries forward, and owns triage (`workflows.md` § Subagent dispatch — never delegate the decision). The slot's effort is explicit — `high` for synthesis — never above the session's. Under a mid-tier main loop, top-tier agents are never launched.

**Posture.** [Record the project's posture: which row the main loop runs by default and what a deliberate escalation looks like — dated, with the reason.] The exercised default:

| Main loop | Top-tier agents | Verify / judge | Default worker | Mechanical |
|---|---|---|---|---|
| workhorse tier — the baseline | never | workhorse | mid tier | smallest tier |
| top tier — deliberate escalation, recorded with its date and reason | at most one, per the allowance | workhorse | mid tier | smallest tier |

## The role ladder (model axis)

Tier by **role**, not by phase or file type:

| Role | Tier | Why |
|---|---|---|
| Mechanical: extraction, format/lint checks, large-N small-context sweeps, test execution, simple lookups | smallest tier (e.g. Haiku) | The tier the platform names for "simpler tasks that need the best speed and lowest costs, such as subagents" (the effort page § Effort levels); volume is the larger lever (§ Fan-out discipline) |
| Finders/gatherers: codebase scans, research gathering, review finding, doc drafting from a complete outline | mid tier (e.g. Sonnet) | Near-frontier at a fraction of the workhorse price; findings get adversarially verified downstream |
| Drafting a persistent cascade artifact — a frame, an R-issue set, an ADR, a PR body — or any output nothing downstream checks before it lands | workhorse tier (e.g. Opus) | Measured 2026-09-01: mid-tier drafts ranked last with the most false claims, procedure or contract (`orchestration-reference.md` § Applied instances). The mid tier drafts only what a verifier checks before it lands |
| Verify/judge: adversarial verification, judge panels, hard code reasoning, root-cause analysis | workhorse tier (e.g. Opus) | Accuracy outweighs cost where a wrong verdict propagates |
| The synthesis slot (top-tier sessions only, ≤1 per workflow/turn) | top tier | See the one-top-tier-agent allowance |

**The delineation test: tier by who catches the agent's mistakes.** If a verify stage or a judge reads the output before it persists, the mid tier is safe there; if nothing downstream checks it, the workhorse tier drafts it.

**The default is the workhorse tier, stated explicitly — not inherit.** Every dispatch — an agent definition's frontmatter, an Agent-tool call, a workflow `agent()` — names its model tier (the session model, stated as such, is a named tier — the sweep's verify stage is the exemplar) **and** its effort; a worker gets a chosen level, stated. Inherit is not neutral: under a top-tier main loop an unpinned fan-out is a top-tier fan-out (measured 2026-09-01 — `orchestration-reference.md` § Applied instances). Never pin *above* the session model. A mid-tier finder feeding a workhorse-tier verifier beats an all-workhorse fan-out on cost with negligible quality loss — the verify stage is what makes the cheap finder safe. Anthropic's published multi-agent result is the precedent for that shape: a lead agent over cheaper workers beat a single strong agent by 90.2% on their research eval — a 4-series result, dated 2025-06-13 ([multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system) § Benefits of multi-agent systems) — not a uniform-strong fan-out.

The kit ships two worked exemplars of the ladder: `.claude/agents/Explore.md` (search pinned to the mechanical tier; promote per-invocation for a genuinely hard scan) and `.claude/workflows/review-sweep.js` (roster read at runtime on the smallest tier → mid-tier find stage at `medium`, retried at `high` → dedup and a declared bound → verify stage at the session model, effort `high`; the run logs its planned agent count first and returns its own record; triage stays in the main thread, because judgment belongs to the session model); and `.claude/workflows/finish-ab/finish-ab.js` (executors and judges at the workhorse tier, model and effort named on every call, an even judge panel split by reading order).

### Generation notes — verified 2026-09-05; re-verify before re-citing

The lineup this file was calibrated on and the per-role defaults the shipped exemplars carry, recorded once and re-swept on any model change (effort names do not carry across models — match by observed thinking length). The facts behind the table — the aliases, the documented ladder (Opus 5 → higher effort → Fable 5.1), the price steps (2× / 2.5× / 2×), the no-dial smallest tier, Fable 5.1 searching less at `low`, Opus 5 over-verifying on self-check prose — and their verbatim sources are `orchestration-reference.md` § Generation notes — the sources.

| Role | Model | Effort |
|---|---|---|
| Mechanical (roster read, inventory, format sweep) | `haiku` | no dial — say so where a pin would go |
| Finder / gatherer (review finding, research reading) | `sonnet` | `medium`; retry at `high` |
| Drafter of a persistent artifact | `opus` | `high` |
| Verify / judge | the session model (workhorse by default) | `high`; `xhigh` for the hardest |
| The synthesis slot (top-tier sessions only) | `fable` | `high` |

## The effort axis (co-equal dial)

Effort is settable per agent definition (`effort:` frontmatter) and per workflow stage (`opts.effort`). It is a **co-equal dial with the model choice, not a cheaper substitute for it.** Anthropic's published heuristic for which one to reach for is a diagnostic question — *"did it not try hard enough, or did it not know enough?"* Raise **effort** when the agent skipped a file, didn't run the tests, or didn't check its work; switch to a **larger model** when it had all the pertinent context, clearly tried, and was still wrong. Their stated default: use the model's default effort level for most tasks ([model & effort in Claude Code](https://claude.com/blog/claude-model-and-effort-level-in-claude-code)).

- **Omitting effort is not neutral.** The API default is `high` — omitting the parameter and setting `high` behave identically — and the page's first best practice is "Set effort explicitly" (the effort page § How effort works, § Best practices); a subagent's `effort:` frontmatter "inherits from session" when omitted (sub-agents § Supported frontmatter fields), so an unpinned worker under an `xhigh` session runs at `xhigh`. Name it. Every source in this section is quoted in `orchestration-reference.md` § Generation notes — the sources.
- `low` — mechanical stages; the platform's own example of the level is "such as subagents" (the effort page § Effort levels). At lower effort the model would rather ask for context than dig (the model-and-effort blog, 2026-07-07), and a subagent cannot ask (`workflows.md` § Subagent dispatch) — a `low` worker needs a complete brief. Never `low` for search or research on Fable 5.1 (§ Generation notes).
- `medium` / `high` — start at `high` and use `low` and `medium` liberally wherever evals show quality holds (the effort page § Recommended effort levels for Claude Opus 5). `high` is the level for a worker whose output nothing downstream checks and for drafting a long deliverable; `xhigh`/`max` can draft the deliverable in thinking and write it again (the Fable 5.1 guide § Leave room for long outputs at xhigh and max effort).
- `xhigh` / `max` — verify and judge stages only; try `high` before `max`.
- **Not monotonic on agentic work**: higher effort up front often *reduces* turn count and total cost, while some routes do as well at a middle setting in less time. Treat effort as a dimension to sweep per role rather than a fixed setting — and try `high` before `max`.
- **Raise effort before adding prompt scaffolding; re-run failures at higher effort before switching model** (the Sonnet 5 guide § Calibrating effort and thinking depth; the cost page § Re-run failures at higher effort).
- **Not every model has the dial** — Haiku 4.5 has none (§ Generation notes). An `effort:` pin on a model without the dial is inert: it advertises a dial that never turns. Tier the model, not the dial.

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
- **Know the caps; they differ by surface, and one fails rather than queues.** The Agent tool fails — `Concurrent subagent limit reached`, with an instruction not to retry — at 20 concurrent subagents by default (sub-agents § Concurrent subagent limit, v2.1.217+; `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS` raises it). The Workflow runtime queues: up to 16 concurrent agents (fewer on a CPU-limited host), 4,096 items per call, 1,000 agents per run, and a `Large workflow` warning above 25 agents or 1.5M projected tokens (workflows § Behavior and limits, § Cost; the authored-size guideline is `workflowSizeGuideline`). The deterministic caps (`CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`, `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS`, the SDK's `max_budget_usd`; task budgets are not supported on Claude Code) are sourced in the reference half. Size the fan-out to the work inside those numbers; a throttling observation is a dated rail with its failure signature and a re-check trigger, never a standing cap (`cbk-conventions.md`, dated-empirical-rails).
- **Volume before tier.** Agents use about 4× the tokens of a chat and multi-agent systems about 15× (multi-agent research system § Benefits, 2025-06-13); agent teams about 7× a standard session when teammates run in plan mode (costs § Manage agent team costs). A price step between tiers is 2–2.5×; a width step is worse. Bound the fan-out first, then tier. What every subagent pays and what a wave shares is `orchestration-reference.md` § Cost terms and run hygiene.
- **Judge panels: an even number, half per reading order, and never rank alone.** Measured 2026-09-03, each judge's first pick tracked its own reading order until the panel was balanced; judges score dimensions and report contradicted claims first, ranks are read beside those (`orchestration-reference.md` § Applied instances; `.claude/workflows/finish-ab/`).
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
| Omitting the model and effort on every `agent()` call ("inherit is safe") | The default is the workhorse tier, stated, and effort named; under a top-tier main loop an unpinned fan-out is a top-tier fan-out |
| `max` effort as a default "to be safe" | Effort is non-monotonic on agentic work; name the level per role (§ Generation notes) and raise only on the stages that prove to need it |
| Fan-out sized by reflex rather than by the work | Pilot on a slice; the Agent tool fails past its cap and the workflow runtime queues past its — either way the tokens are spent |
| Keeping a workaround after the constraint lifts | Date every empirical rail with its failure signature and a re-check trigger; note retirements inline |
| Quoting "official guidance" with no resolvable source | Cite a URL or an authoritative local doc path. An unsourced quotation in a rules file propagates to sibling docs and reviewers before anyone re-checks it |
| An `effort:` pin on a model without the effort dial | The pin is inert and advertises a dial that never turns. Tier the model, not the dial |
| Choosing the cheap tier and then fanning out wide | Volume beats tier: multi-agent runs cost an order of magnitude more tokens than a chat. Bound the fan-out first, then tier |
| Self-check prose in a worker prompt ("verify your work", "use a subagent to double-check") | Over-verification on Opus 5 (§ Generation notes); an independent verifier that sees only the artifact and the rubric is the kit's shape |
| Reusing an effort table after a model change | Effort names do not carry across models; re-sweep and match by observed thinking length (§ Generation notes) |

## When to update this file

→ *Moved to* `orchestration-reference.md` § When to update this file *(path-scoped; see `cbk-conventions.md` § Rule loading and the instruction budget).*

## Primary sources

→ *Moved to* `orchestration-reference.md` § Primary sources *(path-scoped; see `cbk-conventions.md` § Rule loading and the instruction budget).*

## See also

- [`workflows.md`](workflows.md) — when to dispatch at all; plan-mode, TDD, verify-before-completing
- [`tooling.md`](tooling.md) — which tool for which operation
- [`pr-review.md`](pr-review.md) — the triage rubric `review-sweep` findings feed into
