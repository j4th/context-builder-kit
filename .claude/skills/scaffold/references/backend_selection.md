# Backend selection

The first conversation scaffold has with the user. Determines the backend shape — one constant plus two independent axes the operator picks — and surfaces the structural trade-offs before any provisioning runs. Read this before starting the scaffold flow.

The kit composes three surfaces:

- **Constant**: a GitHub repo (or other git host) containing core markdown docs (`CLAUDE.md`, `ARCHITECTURE.md`, `STANDARDS.md`, `CONTRIBUTING.md`, `docs/adr/*`, `docs/cbk/*`). Always present, always the immediate AI/dev context — not a choice.
- **Axis 1 — Planning backend**: where live work-tracking happens.
  - `github-issues` — GitHub Issues (sub-issues + Projects v2 board); 3 planning levels
  - `linear` — Linear (initiatives + projects + milestones + issues); 4 planning levels
  - `in-repo-markdown` — status tracked in `docs/cbk/README.md` only; no external board
- **Axis 2 — Knowledge backend**: durable longer-lived reference library.
  - `notion` — with the hub-as-DB-row pattern from `.claude/rules/knowledge-backend.md`
  - `none` — no external knowledge surface

Together: 3 × 2 = 6 valid combinations. Common shapes:

| Planning | Knowledge | Typical shape |
|---|---|---|
| `github-issues` | `none` | Solo / small team default starting point |
| `github-issues` | `notion` | Solo / small team with existing Notion reference content |
| `linear` | `none` | Larger team standardized on Linear, no durable knowledge curation |
| `linear` | `notion` | Larger team with both planning standardization and curated reference |
| `in-repo-markdown` | `none` | Design-doc mode; non-technical audience; small project |
| `in-repo-markdown` | `notion` | Design-doc mode with research backing in Notion |

## The detect-then-confirm pattern (per axis)

Don't ask "which configuration do you want?" cold — that's a worse user experience than reading the room. For each axis, look at what you already know from the consultation brief, the user's opening message, and any context about their existing setup. Propose one option in a sentence, and let the operator confirm or override.

Run the two axes **sequentially**: planning first (Stage 1), then knowledge (Stage 2). After both are chosen, confirm the resulting combination once (Stage 3) and proceed to provisioning.

### Stage 0 — Acknowledge the constant (one sentence)

Before either axis question, name what's always-true so the operator understands what's being chosen vs what just happens:

> *"Setting up the repo + core markdown docs (CLAUDE.md, ARCHITECTURE.md, STANDARDS.md, `docs/cbk/`) — those land regardless of the other choices. Now two axes to pick."*

One sentence; don't lecture. The point is to defuse the "GitHub-only profile" muddle that happens when operators interpret "github" as both "code lives in GitHub" (always true) and "planning lives in GitHub Issues" (the axis choice).

### Stage 1 — Planning backend

**Lean `github-issues` when**:
- Solo developer with no mention of Linear or other planning tool
- Small team that hasn't already standardized on a planning tool
- Brief explicitly mentions wanting to keep tooling minimal
- User says they're trying the cascade for the first time
- The problem is small enough that cross-project initiative coordination is overkill

**Lean `linear` when**:
- User mentions Linear or "our existing workspace" in the brief or opening message
- Team of 3+ with a stated coordination problem across multiple projects
- User explicitly asks for "the Linear flow" or "the full setup"
- The brief implies multiple projects under a larger initiative umbrella

**Lean `in-repo-markdown` when**:
- User explicitly doesn't want a kanban/board surface
- The cascade is being run as design documentation rather than active work tracking
- The audience for the cascade output (manager, PM, stakeholder) won't be living in GitHub Issues day-to-day
- The user is bootstrapping the cascade against a workspace where they don't have permission to create boards or labels

**Sample detect-then-confirm phrasings**:

> *"Sounds like you're solo with no existing planning tool — I'll wire planning to **GitHub Issues**. Say 'Linear' if you'd rather use that, or 'in-repo markdown' if you don't want an external board."*

> *"You mentioned your team already uses Linear, so I'll wire planning to **Linear**. Say 'GitHub Issues' if you'd rather keep planning in GitHub."*

> *"You said 'this is design documentation, not active work' — I'll wire planning to **in-repo markdown** (status in `docs/cbk/README.md`, no external board). Say 'GitHub Issues' or 'Linear' if you want a live tracker after all."*

One sentence, one default, one override path. Don't lay out a feature comparison table unless asked.

#### The three-level constraint conversation (planning = `github-issues` only)

If the user picks `github-issues`, surface the three-level constraint **before proceeding to Stage 2**. This is the one piece of axis-1 content the light-mode override floor still requires. Even a user who wants everything skipped needs to see this once.

**Default phrasing (full)**:

> *"Quick heads up before I move on. GitHub Issues supports three planning levels: project boards, sub-issues, sub-sub-issues. The cascade has four logical levels — initiatives, projects, milestones, issues. So in this configuration, blueprint (phase 3) will produce an `initiative.md` markdown document but won't create a corresponding GitHub entity for it. Framing maps to sub-issues, rough-in to sub-sub-issues, finish to PRs. If you ever need cross-project initiative coordination later, you'd want to switch to Linear. Sound okay?"*

**Minimum-mode phrasing (one sentence)**:

> *"Heads up — GitHub Issues is three-level, so blueprint will produce an initiative doc but no GitHub entity for it. Continuing."*

If the user pushes back even on the light phrasing ("yes I read your skill, just go"), proceed. Note the override and move on. The user is the source of truth.

#### The in-repo-markdown confirmation gate (planning = `in-repo-markdown` only)

`in-repo-markdown` is a one-way door at the cascade level — once scaffold commits it and blueprint and framing run against it, switching to a planning-backed configuration later means re-running scaffold and re-doing the planning half of every prior phase by hand. The choice deserves an explicit confirmation gate at the moment of selection, not a casual "sure, sounds good."

The gate language and behavior are unchanged from prior versions of the skill (see SKILL.md § "Markdown-only confirmation gate" / "In-repo markdown confirmation gate"). This gate runs in **every rigor mode**; light mode collapses other gates but not this one.

### Stage 2 — Knowledge backend

Run after planning is confirmed.

**Lean `notion` when**:
- User has Notion content (pasted URLs, mentions "I have a Notion", consultation Mode A/B from `consultation/references/notion_ingestion.md` was used)
- User says "our team uses Notion" or "our knowledge lives in Notion"
- Brief references long-form research, decision threads, or runbook material the operator considers durable

**Lean `none` when**:
- No mention of any knowledge tool in the brief or opening message
- User explicitly says "no external docs" or "keep it just the repo"
- Small project where repo markdown is sufficient and no Notion exists

**Other knowledge tools (Confluence, Obsidian, etc.)**: flag as unsupported in v1. Offer `none` + manual link conventions in the project's `cbk-conventions.md`. Future cascade revisions may add additional knowledge backends.

**Sample detect-then-confirm phrasings**:

> *"You shared Notion URLs at consultation — I'll wire **Notion** as the durable knowledge reference. Say 'no knowledge base' to skip."*

> *"No mention of any knowledge tool — I'll skip the knowledge backend (`none`). You can add Notion later if a need surfaces. Say 'use Notion' if you have a workspace you want wired in now."*

> *"You mentioned Confluence — that's unsupported in v1. Want to wire `none` (and link to Confluence manually from `cbk-conventions.md`), or hold off on the cascade until Confluence is added?"*

#### Hub-page conversation (knowledge = `notion` only)

If the operator picks `notion`, the immediate follow-up runs **brownfield Notion detection** via the Notion MCP — the operational contract is in `.claude/rules/knowledge-backend.md` § "Brownfield detection at scaffold." Short version:

- Detect (read-only): Engineering teamspace? Projects DB? Engineering Wiki? Existing project hub?
- Surface findings to operator
- Offer three options: (a) create new row in Projects DB, (b) designate existing page, (c) skip Notion provisioning

If consultation already designated a Notion scope (Mode A/B from `consultation/references/notion_ingestion.md`), scaffold **reuses that designation** rather than re-asking. The scope is in `problem_brief.md`'s `## Pre-cascade sources` section; read it before running detection.

If the Notion MCP isn't connected, surface honestly:

> *"Notion knowledge backend selected but the Notion MCP isn't configured. Want to set it up [link to Notion's MCP docs], proceed with manual URL designation, or fall back to `none`?"*

### Stage 3 — Confirm the combination

After both axes are chosen, restate the resulting configuration once:

> *"Got it: GitHub repo + Linear planning + Notion knowledge (hub: `<URL>`). Starting the scaffold."*

This single-sentence confirmation gives the operator one last chance to course-correct before provisioning begins. It's not a gate (no extra HITL), just a recap.

## Brownfield axis selection

If the user already has an existing setup (a repo, a Linear workspace, an existing label taxonomy, an existing Notion workspace), axis selection happens **with** the audit, not before. Read `brownfield_audit.md` for the audit script. Short version: detect what they already have, propose the combination that matches it (*"you already have a Linear workspace and Notion hub, so I'll wire planning to Linear + knowledge to Notion"*), confirm, then run the audit before any writes.

## What to never do during backend selection

- **Never ask the operator to compare features.** They picked Claude, not a procurement spreadsheet. Propose a default per axis and let them override.
- **Never hide the three-level constraint to make `github-issues` look better.** It's a real limitation and surfacing it after provisioning is worse than friction up front.
- **Never proceed without explicit confirmation** of each axis choice. The Stage 3 combined recap is not a substitute for the per-axis confirmations.
- **Never bundle the axes into a single "profile" question.** That's exactly the framing the refactor moved away from. Each axis is its own conversation.
- **Never default a knowledge backend** when the brief gives no signal. `none` is the safe default; operators can layer Notion on later.
- **Never assume the operator knows what "initiative" means in Linear vs. GitHub contexts.** If they ask, explain briefly. Don't lecture.

## After backend selection

Once both axes are chosen, the resulting combination is recorded in `.cascade/backends.toml` (see `backends.md` § Configuration). Run the three-state detection matrix from SKILL.md to figure out what's actually possible in this chat session for the planning backend, then proceed to discovery (the working-style step) before stage 1.

## A note on the old "opinionated profile" framing

Prior versions of this kit bundled `linear` planning and `notion` knowledge into a single "opinionated" profile. The constant + two axes refactor removed that bundling because it forced operators into either Linear+Notion together or neither — with no clean home for the most common mismatch (`github-issues` + `notion`, the "I have Notion context but no Linear" shape). Operators who arrive expecting "the opinionated profile" should be guided to picking `linear` for planning and `notion` for knowledge in sequence; the resulting combination is functionally identical to the old preset.
