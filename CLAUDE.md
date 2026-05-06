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
| 2 | Scaffold | `.claude/skills/scaffold/` | The problem brief | A repo + `scaffold.md` (planning surface, conventions) |
| 3 | Blueprint | `.claude/skills/blueprint/` | Brief + scaffold output | Foundation docs (CLAUDE.md, ARCHITECTURE.md, STANDARDS.md, CONTRIBUTING.md) + `blueprint.md` (stack + workstreams) |
| 4 | Framing | `.claude/skills/framing/` | Blueprint + one workstream | `frame-NN.md` (milestones + rough issues for one workstream) |
| 5 | Rough-in | `.claude/skills/rough-in/` | One framing + one milestone | Sub-sub-issues with plan-mode prompts, each Claude-Code-ready |
| 6 | Finish | `.claude/commands/finish.md` (slash command) | One sub-sub-issue | A draft PR with code, tests, and review-toolkit triage |

The cascade is a **funnel, not a waterfall**: phases 4 and 5 operate **one project / one milestone at a time, just-in-time**. Framing v0.4 today is wasted if v0.1's actual build teaches you something that should change v0.4 — frame the next thing, build it, then frame the thing after that.

`adr-new` is auxiliary: a skill the *target* project's blueprint installs alongside the cascade skills to record immutable architecture decisions.

## Repo layout

```
.claude/
├── commands/finish.md             ← the executor slash-command (phase 6)
├── rules/cbk-conventions.md       ← project-level convention overrides template (a target project copies this and fills in)
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

- **Skills stay portable; project specifics live in `.claude/rules/cbk-conventions.md` of the *target* project.** No project-specific identifiers (issue keys like `<TEAM>-NN`, project or repo names, specific framing-number pins) should leak into skill content. The skills describe *choice spaces*; the rules file in the target project records *the validated choice*. The `.claude/rules/cbk-conventions.md` in this kit is a template with bracketed placeholders — a target project copies it and fills in its own values.
- **Cascade events are append-only.** Re-framing produces `frame-02.md` that supersedes `frame-01.md` via a status field; it does not overwrite. ADRs are immutable; superseding writes a new ADR. The cascade IS the audit trail of decisions.
- **Each phase has explicit HITL (human-in-the-loop) gates and explicit *rigor modes* (light / standard / full).** Don't collapse gates without considering the one-way-door property of the action they protect. A gate exists where a downstream commit (Linear write, GitHub Issue creation, branch/PR push, ADR commit) would be expensive to unwind.
- **Inheritance is verbatim, not paraphrased.** Each phase reads prior-phase artifacts in full and quotes the relevant content into its inheritance summary. Paraphrasing is the most common cascade failure mode.
- **`/finish` is the executor; planning happens upstream.** `/finish` does not modify issue bodies, does not handle re-rough-in, does not bypass dependencies, does not skip `/simplify` or `pr-review-toolkit:review-pr`. When `/finish` hits something the spec didn't anticipate, it surfaces and aborts rather than improvising — the gap is data for the next revision.
- **Rough-in's specs target Claude Code plan mode, not a human typing.** The Implementation section states intent and constraints, not implementation sequences (plan mode is a decomposition engine; over-prescribing overrides its priors). Granularity is "coherent review units" (2-6 R-issues per milestone), not atomic work units.
- **Three backend profiles** are first-class: `github-only` (validated primary path), `opinionated` Linear+GitHub (validated, less complete refs), `markdown-only` (no planning surface, design-doc mode). Profile selection is a one-way door at the cascade level — every phase has profile-aware behavior; new features must consider all three.

## Working in this repo

Because there is no build/test/lint, the verification surface is editorial:

- **When editing a `SKILL.md`**, also update its `references/test_cases.md` if the change touches behavior the test cases verify, and check that any cited reference file under `references/` still exists and matches.
- **When editing the `cbk-conventions.md` rule file**, run the verification greps listed at the bottom of that file (under `## Verification`) to confirm portability invariants — e.g. that no project-specific identifiers leaked into skill content and that path/naming conventions stay consistent.
- **When adding a new reference doc to a skill**, follow the existing `references/<topic>.md` naming and add a pointer from `SKILL.md` to it. Skills don't auto-discover references; the entrypoint must cite them.
- **Templates live in `references/templates/`** and are quoted verbatim in skill output. Edits to a template change every future cascade artifact — treat them as the contract.

Common cross-cutting reference docs that recur in multiple skills (similar shape, profile-specific behavior in each):
- `references/backends.md` — backend profile mapping for the phase
- `references/inheritance.md` — what to read from prior phases and how
- `references/failure-modes.md` — known traps for that phase
- `references/hitl-question-bank.md` — the gate language for that phase
- `references/planning-backend-commit.md` — the atomic-transition discipline for committing to the planning backend
- `references/github-only-vs-opinionated.md` — per-operation differences across profiles

## When the user invokes a skill

The skills are user-invocable via the Skill tool by the names declared in their frontmatter (`consultation`, `scaffold`, `blueprint`, `framing`, `rough-in`, `adr-new`). `/finish` is invoked as a slash command with one argument: the issue number. The skill descriptions (in each `SKILL.md` frontmatter) include the trigger phrasings — read those before responding to a request that might activate one. The triggers are deliberately tied to the *shape* of the conversation, not the vocabulary, because most users at any given phase don't yet know the cascade exists by name.
