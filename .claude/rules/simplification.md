# Simplification Rules

Operational rules for the `/simplify` Claude Code skill invocation in the cascade workflow. `docs/STANDARDS.md § Step 4` (or wherever your project documents the equivalent gate) establishes that simplification is non-optional before a PR moves draft → ready; this file is the practical detail.

## Plugin

`/simplify` is a Claude Code skill, not a project dependency — bundled with Claude Code as of 2.1.263 (2026-09-06, verified against the installed CLI bundle; re-verify after harness upgrades), or plugin-installed if your harness ships it that way. The skill owns the actual simplification logic; this file documents how the project uses it.

**Install / update**: nothing to install when it ships bundled; otherwise per Claude Code plugin documentation, with the plugin ID recorded in `.claude/settings.json` `enabledPlugins`. This rules file exists so the project doesn't lose track of the dependency either way.

## When to invoke

Always: before any PR moves draft → ready-for-review.

Optionally: after any large refactor, after a long implementation session, when reviewing a long-running branch before pushing.

## What the simplification pass does

The `/simplify` pass runs against the current branch and identifies:

- **Compressible code** — multiple sequential statements that could be one expression, redundant intermediate variables, repeated patterns that could be functions
- **Dead code** — commented-out blocks, unreachable branches, unused imports, unused parameters
- **Unnecessary indirection** — single-use wrapper functions, abstractions with one implementation that don't earn their layer
- **Over-clever expressions** — code that's compact but unreadable; simplification prefers readable over clever
- **Formatter cleanup** — final pass with whatever formatter your stack uses (e.g., `mix format`, `ruff format`, `prettier`, `gofmt`) after structural changes

## What the simplification pass does NOT do

- Does not change behavior. Test suite must still pass after simplification — if simplify changes behavior, that's a bug in the pass, not a feature.
- Does not remove code that *seems* unused but is actually exported / called via behaviour / loaded dynamically. Be cautious with macro-defined exports, protocol/interface impls discovered via reflection, and framework-conventional entry points (controller actions, scheduled job handlers, plugin hooks).
- Does not edit `.claude/rules/`, `docs/`, or `LICENSE` / `NOTICE`.

## Anti-patterns

### ❌ Skipping simplify on "small" PRs

The 50-line PR is exactly the one where simplify is fastest and cleanest. Skipping it because "it's small" is how 50-line PRs become 200-line PRs over time.

### ❌ Running simplify and then immediately marking ready without reviewing

The pass can over-compress or remove things that look unused but aren't. Quick review of the simplify diff is part of the step.

### ❌ Running simplify after auto-review has already commented

If auto-review flagged something, address that first via the PR feedback loop (see your `docs/STANDARDS.md` § PR feedback loop). Don't simplify *over* review feedback — that breaks the comment-to-commit traceability.
