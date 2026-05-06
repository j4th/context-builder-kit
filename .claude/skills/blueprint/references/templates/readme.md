# README.md template

Human entry point. What is this, why should I care, how do I run it. **Get someone from zero to running in 5 minutes.**

**Cascade-specific note**: README.md almost always exists from scaffold (which seeds it with a one-line description and license info). Blueprint **updates** the existing README rather than rewriting it from scratch. The update adds stack info, install commands, and pointers to the rest of the docs — but preserves whatever the user wrote in scaffold.

## What to inherit before drafting

| From | What to extract | Where it goes in README.md |
|---|---|---|
| Existing README from scaffold | One-line description, license | Top of file — preserve |
| `problem_brief.md` problem statement | What the project is and why it matters | The 1–2 paragraph description |
| `problem_brief.md` target users | Who this is for | Implicit in the description |
| `problem_brief.md` success criteria | What "working" looks like | "What you can do" section |
| Stack decisions (this phase) | Language, framework, install mechanism | Install section, Stack table |
| `scaffold.md` profile | Whether to link to a project board | Status section |

## The template

```markdown
# [Project Name]

> [One-line description from scaffold or problem brief.]

[1–2 paragraph description. Problem, audience, differentiator. Pulled from
problem_brief.md problem statement and target users — adapted for a public
audience (less internal jargon, more reader-friendly framing).]

## What you can do

[Concrete examples — show the actual experience, not a feature list. For
pre-implementation projects, this is "what you'll be able to do" with a
note that the project is pre-v0.1.]

## Install

\```bash
[exact commands — zero to running, derived from stack decisions]
\```

[Platform notes if applicable — macOS only, Linux only, cross-platform.]

## Configuration

[Env vars, feature flags, defaults. Link to .env.example if applicable.
Skip this section entirely if there's nothing to configure.]

## Stack

| | |
|---|---|
| Language | [from stack decisions] |
| Framework | [from stack decisions] |
| Storage | [from stack decisions] |
| Build | [from stack decisions] |
| Test | [from stack decisions] |

## Development

\```bash
[clone → setup → verify, derived from stack decisions]
\```

See [CONTRIBUTING.md](./CONTRIBUTING.md) for the full developer walkthrough.

## Documentation

| Doc | Covers |
|-----|--------|
| [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md) | System design, decisions log |
| [docs/STANDARDS.md](./docs/STANDARDS.md) | Workflow, PR checklist, quality gates |
| [CONTRIBUTING.md](./CONTRIBUTING.md) | New-contributor walkthrough |
| [CLAUDE.md](./CLAUDE.md) | Claude Code session primer |

## Status

[What works, what's in progress, key metrics. For pre-implementation, this
is "pre-v0.1, see docs/cbk/blueprint.md for the workstreams roadmap."
For projects past v0.1, link to releases.]

## License

[From scaffold's license choice — typically MIT, GPL, Apache 2.0, or proprietary.]
```

## What does NOT belong here

- **Cascade-internal artifacts** (`docs/cbk/` files) — those are not for the public
- **Stack decision rationale** — that's ARCHITECTURE.md Decisions Log
- **PR review checklist** — that's STANDARDS.md
- **Detailed contributor onboarding** — that's CONTRIBUTING.md
- **Long architectural descriptions** — that's ARCHITECTURE.md
- **Roadmap with dates** — promises age badly; stick to "what works now" and link to a roadmap doc if one exists

## Updating, not rewriting

When blueprint updates an existing scaffold-produced README:

1. **Preserve** the title, one-line description, and license
2. **Add or expand** the description to 1–2 paragraphs based on the problem brief
3. **Add** the What You Can Do section
4. **Add** Install, Configuration (if needed), Stack, Development sections
5. **Add** the Documentation table linking the other foundation docs
6. **Add** the Status section
7. **Confirm** the license matches what scaffold set up

The result should *feel like an evolved version* of the scaffold README, not a different doc that happens to have the same title.

## HITL presentation

When presenting the updated README for review, lead with: *"Here's the updated README. I preserved the original one-line description and license from scaffold, then added [list of new sections]. Let me know if any of the additions don't match how you'd describe the project to a stranger."*

Common revision requests:
- "The description is too internal-jargon-heavy" → simplify the framing for a public audience
- "Don't mention X yet, it's not ready" → move from What You Can Do to Status
- "Install section is missing the prerequisite Y" → add to Install
- "Documentation table should not link to docs/cbk/" → confirm and remove (cbk artifacts are not public-facing)

Iterate until approved. Then commit via GitHub MCP to repo root as `README.md` (overwriting the existing version).

## Light-mode behavior

If the user invoked light mode:

- **Just add the install command and stack table** to the existing README — skip the rest
- **Skip the Documentation table** unless multiple foundation docs were produced
- **Skip the What You Can Do section** for pre-implementation projects

For light mode, the README update may be 5–10 added lines to the existing scaffold README rather than a full restructure. That's fine — it's still an update, just a tighter one.
