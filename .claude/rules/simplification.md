# Simplification Rules

Operational rules for the `/simplify` Claude Code skill invocation in the cascade workflow. `pr-review.md` § The floor makes the pass one half of the review floor, run before a PR moves draft → ready; this file is the practical detail.

## Plugin

`/simplify` is a Claude Code skill, not a project dependency — bundled with Claude Code as of 2.1.263 (2026-09-06, verified against the installed CLI bundle; re-verify after harness upgrades), or plugin-installed if your harness ships it that way. The skill owns the actual simplification logic; this file documents how the project uses it.

**Install / update**: nothing to install when it ships bundled; otherwise per Claude Code plugin documentation, with the plugin ID recorded in `.claude/settings.json` `enabledPlugins`. This rules file exists so the project doesn't lose track of the dependency either way.

## When to invoke

Always: before any PR moves draft → ready-for-review.

Optionally: after any large refactor, after a long implementation session, when reviewing a long-running branch before pushing.

## What the simplification pass does

"Four review agents run in parallel, covering reuse of existing helpers, simplification, efficiency, and whether the change is at the right level of abstraction. The review doesn't look for correctness bugs." It then applies the fixes (`https://code.claude.com/docs/en/commands`, the `/simplify` row, read 2026-09-30). Correctness is the other half of the floor, `pr-review-toolkit:review-pr`.

## What the project holds the pass to

- **Behaviour is preserved.** The test suite passes after the pass; a behaviour change is a defect in the pass, not a feature.
- **Code that only *seems* unused stays** when it is exported, called via behaviour or loaded dynamically. Be cautious with macro-defined exports, protocol/interface impls discovered via reflection, and framework-conventional entry points (controller actions, scheduled job handlers, plugin hooks).
- **Its edits stay in code.** A change to `.claude/rules/`, `docs/`, `LICENSE` or `NOTICE` is outside the pass's scope and is reverted, never committed as a simplify fix.
- **The formatter runs after it.** Formatting is not one of the pass's documented dimensions, so run the project's formatter (e.g., `mix format`, `ruff format`, `prettier`, `gofmt`) after its structural changes.

## Anti-patterns

### ❌ Skipping simplify on "small" PRs

The 50-line PR is exactly the one where simplify is fastest and cleanest. Skipping it because "it's small" is how 50-line PRs become 200-line PRs over time.

### ❌ Running simplify and then immediately marking ready without reviewing

The pass can over-compress or remove things that look unused but aren't. Quick review of the simplify diff is part of the step.

### ❌ Running simplify after auto-review has already commented

If auto-review flagged something, address that first via the PR feedback loop (`/pr-respond`). Don't simplify *over* review feedback — that breaks the comment-to-commit traceability.
