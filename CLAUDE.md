# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

`context-builder-kit` is **not a software project** — it is a kit that exports a set of Claude Code skills, commands, and rule files used to walk an idea from "raw thought" through to "automatically executed code issue." Everything in this repo is markdown content consumed by Claude Code itself; there is no code to build, no test suite to run, no application to start.

The deliverable is the contents of `.claude/` — the cascade skills (`consultation`, `scaffold`, `blueprint`, `framing`, `rough-in`), the `/finish` slash command, the `adr-new` skill, and the example project-rules file. They are designed to be installed (copied or symlinked) into target projects' `.claude/` directories.

## The cascade — what these skills do, in order

The skills compose into a six-phase **AI-assisted development cascade**. Each phase consumes the prior phase's artifact and produces the next. The phases trade in markdown documents (and, optionally, planning-backend entities like GitHub Issues or Linear issues) — they never produce code directly until the last phase.

| # | Phase | Skill / command | Input | Output |
|---|---|---|---|---|
| 1 | Consultation | `.claude/skills/consultation/` | A raw idea, verbally | `problem_brief.md` |
| 2 | Scaffold | `.claude/skills/scaffold/` | The problem brief | A repo + `scaffold.md` (planning surface choice, knowledge surface choice, conventions) |
| 3 | Blueprint | `.claude/skills/blueprint/` | Brief + scaffold output | Foundation docs (CLAUDE.md, ARCHITECTURE.md, STANDARDS.md, CONTRIBUTING.md) + `blueprint.md` (stack + workstreams) |
| 4 | Framing | `.claude/skills/framing/` | Blueprint + one workstream | `frame-NN.md` (milestones + rough issues for one workstream) |
| 5 | Rough-in | `.claude/skills/rough-in/` | One framing + one milestone | Sub-sub-issues with plan-mode prompts, each Claude-Code-ready |
| 6 | Finish | `.claude/commands/finish.md` (slash command) | One sub-sub-issue | A draft PR with code, tests, a `## Review gate` block (the two-skill floor, actually invoked, plus the bounded sweep) and the `## Triage` block |

The cascade is a **funnel, not a waterfall**: phases 4 and 5 operate **one project / one milestone at a time, just-in-time**. Framing v0.4 today is wasted if v0.1's actual build teaches you something that should change v0.4 — frame the next thing, build it, then frame the thing after that.

`adr-new` is auxiliary: a skill the *target* project's blueprint installs alongside the cascade skills to record immutable architecture decisions.

The cascade is top-down, but a **bottom-up contribution lane** complements it for externally-sourced work: `/intake` turns a bug report or feature request into a shaped `/finish`-able issue (investigate → reproduce → classify → shape, never lands code); `/enrich` is rough-in for a single small capability that skips the framing milestone; `/pr-respond` closes the PR-feedback loop (the inverse of `/finish`). The convention that governs the lane — bug/enhancement lanes, what skips framing vs stays framed — lives in `.claude/rules/cbk-conventions.md § Contribution intake`.

## Repo layout

```
.claude/
├── commands/
│   ├── finish.md                  ← the executor slash-command (phase 6)
│   ├── intake.md                  ← bottom-up entry: externally-sourced report → /finish-able issue
│   ├── enrich.md                  ← rough-in for one small capability (enhancement lane, skips framing)
│   └── pr-respond.md              ← the PR feedback-loop executor (inverse of /finish)
├── agents/                        ← project-local PR reviewers (adr-conformance, logging-discipline, cascade-rule; memory-enabled) + Explore (cheap-tier search exemplar)
├── hooks/                         ← guards in four tiers: hard-deny (protect-immutable-adrs, protect-lock-files, protect-main-branch, require-repo-root-for-agents) + ask-gate (guard-pr-state, require-knowledge-backend-ok) + advisory exemplars, unregistered (format-on-edit, analyze-on-edit) + stop (detect-forked-agent-memory)
├── rules/                         ← operational contracts (cbk-conventions, pr-review — each split into an always-loaded contract and a path-scoped `-reference.md` half — plus testing, logging, simplification, knowledge-backend) and rule templates (tooling; orchestration, itself also split); workflows.md is portable
├── workflows/                     ← saved orchestrations (review-sweep: find-then-adversarially-verify review pass)
└── skills/
    ├── consultation/SKILL.md      + references/   ← phase 1
    ├── scaffold/SKILL.md          + references/   ← phase 2
    ├── blueprint/SKILL.md         + references/   ← phase 3
    ├── framing/SKILL.md           + references/   ← phase 4
    ├── rough-in/SKILL.md          + references/   ← phase 5
    └── adr-new/SKILL.md                           ← ADR scaffolder (used by target projects)
```

Each skill follows the same pattern: a top-level `SKILL.md` with frontmatter (`name`, `description`) and a `references/` directory holding **templates** (the artifact templates the skill produces) and **operational reference docs** (failure modes, question banks, profile-specific behavior, inheritance discipline). Skills load their `references/*.md` lazily on demand — `SKILL.md` is the entrypoint and points at references when needed.

## Architectural principles to preserve when editing

These are load-bearing across the kit. Edits that violate them break the cascade in subtle ways that show up phases later.

- **Skills stay portable; project specifics live in `.claude/rules/cbk-conventions.md` of the *target* project.** No project-specific identifiers (issue keys like `<TEAM>-NN`, project or repo names, specific framing-number pins) should leak into skill content. The skills describe *choice spaces*; the rules file in the target project records *the operational choice*. The `.claude/rules/cbk-conventions.md` in this kit is a template with bracketed placeholders — a target project copies it and fills in its own values.
- **Cascade events are append-only.** Re-framing produces `frame-02.md` that supersedes `frame-01.md` via a status field; it does not overwrite. ADRs are immutable; superseding writes a new ADR. The cascade IS the audit trail of decisions.
- **Each phase has explicit HITL (human-in-the-loop) gates and explicit *rigor modes* (light / standard / full).** Don't collapse gates without considering the one-way-door property of the action they protect. A gate exists where a downstream commit (Linear write, GitHub Issue creation, branch/PR push, ADR commit) would be expensive to unwind.
- **Inheritance is verbatim, not paraphrased.** Each phase reads prior-phase artifacts in full and quotes the relevant content into its inheritance summary. Paraphrasing is the most common cascade failure mode.
- **`/finish` is the executor; planning happens upstream.** `/finish` does not modify issue bodies, does not handle re-rough-in, does not bypass dependencies, does not skip `/simplify` or `pr-review-toolkit:review-pr` (the floor — two skills actually invoked, once, recorded in the PR body's `## Review gate` block; the orchestrated sweep supplements and never substitutes). When `/finish` hits something the spec didn't anticipate, it surfaces and aborts rather than improvising — the gap is data for the next revision.
- **Issue letters reflect skills; M is frame-local, F continues per workstream.** Frame docs label milestones `### F<#> — M<#>: <name>`: `M` is the frame-local milestone position, `F` numbers the framing issue and continues the workstream's sequence across frames (never restarting), keeping `[F<N>.AC<M>]` trace IDs unique cascade-wide. `R` numbers rough-in's issues. See `cbk-conventions.md` § Title-prefix scheme.
- **Rough-in's specs target Claude Code plan mode, not a human typing.** The Implementation section states intent and constraints, not implementation sequences (plan mode is a decomposition engine; over-prescribing overrides its priors). Granularity is "coherent review units" (2-6 R-issues per milestone), not atomic work units.
- **Constant + two independent axes** for the backend shape:
  - **Constant**: GitHub repo (or other git host) with core markdown docs (CLAUDE.md, ARCHITECTURE.md, STANDARDS.md, CONTRIBUTING.md, `docs/adr/*`, `docs/cbk/*`). Always present, always the immediate AI/dev context, not negotiable.
  - **Axis 1 — Planning backend**: GitHub Issues / Linear / in-repo markdown. Where live work-tracking with status, parent/child, queryable state happens.
  - **Axis 2 — Knowledge backend**: Notion / none. A durable longer-lived reference library — pre-cascade research, cross-project decisions, runbooks that span repos. Distinct from the constant; sits *alongside* rather than replacing.
  - The axes generate a 3 × 2 = 6 matrix. There are no named "preset profiles" — operators pick each axis independently. Skills are axis-aware along both; new features must consider both. **The canonical axis record is `docs/cbk/scaffold.md` § Cascade metadata** (`Planning backend` / `Knowledge backend` rows); `.cascade/backends.toml` is the machine-readable mirror consumers fall back to. `in-repo-markdown` planning is design-doc mode: no `/finish` executor (disclosed at scaffold's gate), specs executed manually against the markdown.
- **Knowledge backend is read-primary at lower phases; writes are tiered and HITL-gated.** Default behavior: rely on repo + inheritance. Reach to the knowledge backend on demand when richer detail is needed. Writes are routine at consultation and scaffold (companion-page, hub establishment); HITL-gated and default-SKIP at blueprint / framing / rough-in / `/finish`. The operational contract lives in `.claude/rules/knowledge-backend.md`.

## Working in this repo

Because there is no build/test/lint, the verification surface is editorial:

- **When editing a `SKILL.md`**, also update its `references/test_cases.md` if the change touches behavior the test cases verify, and check that any cited reference file under `references/` still exists and matches.
- **When editing the `cbk-conventions.md` rule file**, run the verification block in `cbk-conventions-reference.md` § Verification (the kit sub-block must be green on this tree) to confirm portability invariants — e.g. that no project-specific identifiers leaked into skill content and that path/naming conventions stay consistent.
- **When adding a new reference doc to a skill**, follow the existing `references/<topic>.md` naming and add a pointer from `SKILL.md` to it. Skills don't auto-discover references; the entrypoint must cite them.
- **Templates live in `references/templates/`** and are quoted verbatim in skill output. Edits to a template change every future cascade artifact — treat them as the contract.

Common cross-cutting reference docs that recur in multiple skills (similar shape, axis-specific behavior in each):
- `references/backends.md` — backend interface mapping for the phase (both axes)
- `references/inheritance.md` — what to read from prior phases and how
- `references/failure-modes.md` — known traps for that phase
- `references/hitl-question-bank.md` — the gate language for that phase
- `references/planning-backend-commit.md` — the atomic-transition discipline for committing to the planning backend
- `references/planning-backend-matrix.md` — per-operation differences across planning backends (replaces the older `github-only-vs-opinionated.md` naming)

Kit-wide operational contracts (`.claude/rules/`):
- `cbk-conventions.md` — project-level conventions template (target projects copy + fill in)
- `pr-review.md`, `simplification.md`, `testing.md`, `logging.md` — operational discipline for the named tooling concern
- `knowledge-backend.md` — the operational contract for the knowledge-backend axis (read patterns, write tiering, HITL discipline, brownfield detection, lazy provisioning)
- `tooling.md`, `orchestration.md` — **templates** (like `cbk-conventions.md`): tool-selection skeleton and model/effort tiering. Target projects copy and fill the bracketed sections; fast-aging platform claims inside them are dated observations to re-verify, per the conventions' dated-empirical-rails principle
- `workflows.md` — a **portable rule** (agent workflow patterns), kept always-loaded on purpose; it is not a template
- `cbk-conventions-reference.md`, `orchestration-reference.md`, `pr-review-reference.md` — the path-scoped halves; see `cbk-conventions.md` § Rule loading and the instruction budget

## When the user invokes a skill

The skills are user-invocable via the Skill tool by the names declared in their frontmatter (`consultation`, `scaffold`, `blueprint`, `framing`, `rough-in`, `adr-new`). `/finish` is invoked as a slash command with one argument: the issue number. **Invocation posture is split by phase.** `consultation` — the funnel entry, where users don't yet know the cascade vocabulary — stays model-invocable, with triggers deliberately tied to the *shape* of the conversation rather than the vocabulary. The downstream phase skills (`scaffold`, `blueprint`, `framing`, `rough-in`) carry `disable-model-invocation: true` and never auto-trigger: each is an expensive, HITL-heavy workflow with one-way-door writes (repo creation, planning-backend commits), so an unwanted auto-trigger mid-conversation costs more than a missed one. Invoke them deliberately — each description names the moment it's for, and once inside the cascade the operator knows the phase names (`adr-new` follows the same deliberate posture).
