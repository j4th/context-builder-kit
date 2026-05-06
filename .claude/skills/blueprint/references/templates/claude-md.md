# CLAUDE.md template

The agent's session primer. Loaded EVERY session by Claude Code. Must be lean.

**Research findings that shape this template** (preserved from the initiative-planner skill, all still applicable):
- ETH Zürich: Architecture sections increase inference cost without improving task success. Remove them — use `@docs/ARCHITECTURE.md` instead.
- HumanLayer: Claude Code's system prompt has ~50 instructions. Your CLAUDE.md competes for that attention. **Target <300 lines, <150 is better.**
- GitHub (analysis of 2,500 repos): Six core areas: commands, testing, project structure, code style, git workflow, boundaries.
- Key insight: Code examples beat prose descriptions. Agents are in-context learners — they follow patterns they see, not rules they read.
- Never put formatting/linting rules here. Use deterministic tools + hooks.

**Always-loaded vs on-demand**:
- CLAUDE.md = always loaded. Keep it minimal.
- ARCHITECTURE.md = loaded via `@docs/ARCHITECTURE.md` when building subsystems.
- STANDARDS.md = loaded via `@docs/STANDARDS.md` when doing PRs or quality checks.
- CONTRIBUTING.md = read once by humans, not Claude — do not @-reference unless specifically relevant.

## What to inherit before drafting

Before writing CLAUDE.md, pull these specific items from `docs/cbk/scaffold.md` and `docs/cbk/problem_brief.md`:

| From | What to extract | Where it goes in CLAUDE.md |
|---|---|---|
| `problem_brief.md` problem statement | One-line technical description | The line directly under the H1 title |
| `problem_brief.md` target user | Implicit context | Inform the tone (solo author = casual, external contributors = formal) |
| `problem_brief.md` no-gos | Constraints to enforce | Boundaries section |
| `scaffold.md` working conventions | Branch naming, commit format | Mention only if Claude Code needs to know (usually it does for git operations) |
| `scaffold.md` testing philosophy | Verbatim — do not paraphrase | Testing section |
| `scaffold.md` tool comfort | Calibration signal | First-timers need more explanation, veterans need less |
| Stack decisions (this phase) | Language, framework, tooling | Stack section |
| Methodology (this phase) | Workflow patterns | Patterns section if it changes how Claude should approach tasks |

**The most common CLAUDE.md inheritance failure**: writing a generic "best practices" CLAUDE.md that doesn't reflect the actual project's conventions and tool comfort. If scaffold.md said "first exposure to the cascade workflow," CLAUDE.md should explain cascade-relevant context that a veteran wouldn't need. If scaffold.md said "6 years SWE, comfortable with Git/CI/CD generally," CLAUDE.md skips Git basics.

## The template

```markdown
# [Project Name]

[One-line technical description from problem_brief.md.]

## Stack

[Language] [version] · [Framework] · [Key deps — one line]
Tooling: [runner] · [package manager] · [linter] · [typechecker] · [test framework]

## Commands

\```bash
[runner] setup          # [what it does]
[runner] check          # [quality gate — same as CI]
[runner] test           # [run tests]
[runner] test:quick     # [fast iteration — affected tests only]
[runner] lint           # [lint + format check]
[runner] typecheck      # [type checking]
[runner] dev            # [development mode]
[runner] fix            # [auto-fix]
\```

## Testing

[From scaffold.md's testing philosophy verbatim. Use a table only if there are
multiple test tiers worth distinguishing.]

| Tier | Command | Speed | Use when |
|------|---------|-------|----------|
| Quick | ... | ~Ns | Active iteration |
| Full | ... | ~Ns | Before commit |

## Patterns

[Show, don't tell. 2–4 critical patterns as CODE EXAMPLES.
Only patterns the agent would get wrong without seeing them.
If the project is pre-implementation, this section is sparse — that's fine.]

\```[language]
// RIGHT — [brief label]
[3–5 lines of correct pattern]

// WRONG — [what this prevents]
[2–3 lines of the mistake]
\```

## Boundaries

[From problem_brief.md no-gos plus stack decision constraints.
Each line is a hard "do not" or "off-limits" rule.]

- Do NOT [common expensive mistake]
- Do NOT [architectural violation from no-gos]
- Do NOT [dependency that shouldn't be added]
- [file/directory] is off-limits because [reason]

## Gotchas

[Things that silently break or surprise. For pre-implementation projects,
this is empty or speculative — leave a note that it gets enriched as code is written.]

- [Thing that silently breaks]
- [Import path or API quirk]
- [Tool-specific workaround]

## Status

[What's implemented, what's stubbed, what's next. Keep current.
For new projects from blueprint, this is "pre-implementation — see docs/cbk/blueprint.md for the workstreams roadmap."]

## References

- @docs/ARCHITECTURE.md — load when building a specific subsystem
- @docs/STANDARDS.md — load when doing PRs or quality checks
- @docs/cbk/blueprint.md — load when context about the initiative or workstreams is needed
- @docs/cbk/problem_brief.md — load when context about the original problem is needed
```

## What does NOT belong here

- **Architecture descriptions** — use `@docs/ARCHITECTURE.md` reference instead
- **Detailed code style rules** — use linter + formatter, not prose
- **Project structure trees** — agent can `ls`; only document non-obvious layout
- **Long explanations of why decisions were made** — that's the ARCHITECTURE.md decisions log
- **History or changelog** — irrelevant to agent behavior
- **Things the agent can infer from the code itself** — every line that could be inferred is wasted context
- **Cascade-internal metadata** — that's what `docs/cbk/blueprint.md` is for
- **The full problem brief** — `@`-reference it when relevant, don't paste it in

## Pre-implementation projects

When blueprint produces CLAUDE.md for a project that has no code yet, the doc is necessarily skeletal: stack decisions and conventions but no commands or gotchas. That's fine. Mark sections as "pre-implementation" or leave them empty with a note. CLAUDE.md gets enriched as code is written — blueprint produces version 1, the team updates it as they go. Do not pad it with speculative content to make it feel more complete.

## HITL presentation

When presenting the drafted CLAUDE.md for review, say explicitly: *"Here's the draft CLAUDE.md. It's the first doc Claude Code will load every session, so accuracy and brevity matter most. <Line count>. Let me know what to fix or cut."*

The user reviews. Common revision requests:
- "Add the X command we use" → add to Commands section
- "This testing tier doesn't exist yet" → remove or mark as future
- "The patterns section is missing how I do error handling" → add a code example
- "Boundaries are too vague" → tighten to specific files/dirs

Iterate until approved. Then commit via GitHub MCP to repo root as `CLAUDE.md`.

## Light-mode behavior

If the user invoked light mode and asked for CLAUDE.md, produce a tighter version:

- Skip the testing table (one-line testing description instead)
- Skip the patterns section if the project is pre-implementation
- Skip the gotchas section if there are no known gotchas yet
- Status section is one line
- References section keeps only the @-references the user actually uses

Target: ~50–100 lines for light mode, ~100–250 lines for default. Never over 300.
