---
paths:
  - ".claude/workflows/**"
  - ".claude/agents/**"
  - ".claude/rules/orchestration*.md"
---

# Orchestration — the reference half

> **Path-scoped.** Loads when a workflow, an agent definition, or this rule pair is read. `orchestration.md` (always loaded) keeps a pointer heading for every section here. Sections were moved verbatim on 2026-09-06. See `cbk-conventions.md` § Rule loading and the instruction budget.

## The three surfaces + resolution order

1. **Agent definitions** — `model:` / `effort:` frontmatter in `.claude/agents/*.md`.
2. **Ad-hoc subagents** — the Agent tool's per-invocation `model` param.
3. **Workflow stages** — `agent(prompt, {model, effort})` per call.

Resolution (highest wins): the subagent-model env override → per-invocation param → definition frontmatter → main-conversation model, all checked against the org's model allowlist (an excluded value is skipped and the agent runs on the inherited model). The per-invocation override is the escape hatch: a frontmatter-pinned cheap agent can be promoted for one hard call without editing its definition. Re-verify this order against the platform's current [sub-agents doc](https://code.claude.com/docs/en/sub-agents) after harness upgrades — subagent defaults have moved across versions (background-vs-foreground default, thinking inheritance, override persistence).

## Applied instances in this project

[Record the project's actual pins here as they're made, with dates and the reason — e.g. "the project reviewers pin the finder tier; their findings pass the review-sweep verify stage", "Explore overridden to the mechanical tier", "a reviewer promoted to the workhorse tier after observed misses on <date>". An empty section means no pins beyond the kit's shipped exemplars — that's a valid state, not a gap.]

## When to update this file

- The model lineup or pricing changes — re-verify against the platform docs and restamp the dated observations. **The lineup moves faster than this file does**; check the aliases, not just the prices.
- A harness version bump changes subagent defaults — re-read § The three surfaces and § Fan-out discipline against the current sub-agents doc after an upgrade.
- Real usage shows a tier mis-assignment (a reviewer needs the workhorse tier) — record the promotion and why in § Applied instances.
- **Every normative claim added here carries a resolvable source.** No quotation lands without a URL or authoritative local doc path; absence claims ("X is not supported") get a primary-source check first.

## Primary sources

Verified 2026-07-30 upstream of this template; **re-fetch before re-citing** rather than trusting the summary.

| Source | What it grounds |
|---|---|
| [`code.claude.com/docs/en/sub-agents`](https://code.claude.com/docs/en/sub-agents) | Resolution order, model allowlists, background-default behavior, `effort` frontmatter |
| [`claude.com/blog/claude-model-and-effort-level-in-claude-code`](https://claude.com/blog/claude-model-and-effort-level-in-claude-code) | The effort-vs-model heuristic; default-effort guidance |
| [`platform.claude.com/docs/en/build-with-claude/effort`](https://platform.claude.com/docs/en/build-with-claude/effort) | Which models support the effort dial |
| [`anthropic.com/engineering/multi-agent-research-system`](https://www.anthropic.com/engineering/multi-agent-research-system) | The strong-lead-plus-cheaper-workers result; multi-agent token multiples |
