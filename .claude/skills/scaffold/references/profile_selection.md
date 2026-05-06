# Profile selection

The first conversation scaffold has with the user. Determines which backend profile the workspace will use, surfaces the structural trade-offs, and gets explicit acknowledgment before any provisioning. Read this before starting the scaffold flow.

## The two profiles in plain language

**GitHub-only** *(recommended starting point for most users)*. One tool. Code, planning, and knowledge all live in a single GitHub repository. Planning uses GitHub Projects boards, repo Milestones, and Issues. Knowledge and cascade artifacts live in `docs/cbk/`. Three-level planning hierarchy (project → milestone → issue), no native concept of "initiative".

**Opinionated (Linear + GitHub)**. Three tools, each doing what it's best at. Linear handles planning with a four-level hierarchy (initiatives → projects → milestones → issues). Notion holds long-form knowledge — initiative specs, decision logs, conventions. GitHub holds code. Cross-tool integrations (Linear's GitHub app, Linear's Notion integration) wire them together.

## The detect-then-confirm pattern

Don't ask "which profile do you want?" cold — that's a worse user experience than reading the room. Look at what you already know from the consultation brief, the user's opening message, and any context about their existing setup, then propose a profile in one sentence and let them confirm or override.

**Lean GitHub-only when:**
- Solo developer with no mention of Linear or Notion
- Small team that hasn't already standardized on a planning tool
- Brief explicitly mentions wanting to keep tooling minimal
- User says they're trying the cascade for the first time
- The problem is small enough that cross-project initiative coordination is overkill

**Lean opinionated when:**
- User mentions Linear, Notion, or "our existing workspace" in the brief or opening message
- Team of 3+ with a stated coordination problem across multiple projects
- User explicitly asks for "the full setup" or "the Linear flow"
- The brief implies multiple projects under a larger initiative umbrella

**Sample detect-then-confirm phrasings:**

> *"Sounds like you're solo with no existing planning tool — I'll start with the **GitHub-only** profile, which keeps everything in one repo. Say 'opinionated' or 'use Linear' if you'd rather wire up Linear and Notion alongside it."*

> *"You mentioned your team already uses Linear, so I'll set up the **opinionated profile** (Linear + GitHub). Say 'GitHub-only' if you'd rather keep planning in GitHub instead."*

> *"No strong signal either way — I'll default to **GitHub-only** since it's simpler. Say 'opinionated' if you want the Linear+Notion setup."*

One sentence, one default, one override path. Don't lay out a feature comparison table unless asked.

## The three-level constraint conversation (GitHub-only only)

If the user picks GitHub-only, you must surface the three-level constraint **before proceeding to stage 1**. This is the one piece of profile-selection content that the light-mode override floor still requires (see SKILL.md). Even a user who wants everything skipped needs to see this once.

**Default phrasing (full):**

> *"Quick heads up before I start provisioning. GitHub-only mode supports three planning levels: project boards, repo milestones, and issues. The cascade has four levels — initiatives, projects, milestones, issues. So in this profile, blueprint (phase 3) will produce an `initiative.md` markdown document but won't create a corresponding GitHub entity for it. Framing maps to project boards, rough-in to milestones, finish to issues. If you ever need cross-project initiative coordination later, you'd want to switch to a profile that includes a four-level planning tool like Linear. Sound okay?"*

**Minimum-mode phrasing (one sentence, when the user has asked to keep things terse):**

> *"Heads up — GitHub-only mode is three-level, so blueprint will produce an initiative doc but no GitHub entity for it. Continuing."*

If the user pushes back even on the light phrasing ("yes I read your skill, just go"), proceed. Note the override and move on. The user is the source of truth.

## The opinionated profile gap (v1)

If the user picks the opinionated profile, tell them honestly that the v1 reference is a stub:

> *"Heads up — the opinionated profile (Linear + GitHub) is structurally supported in the skill, but the detailed reference for it is a stub in v1. I'll walk you through what's documented and flag gaps as we hit them. If we hit something I don't have a clean answer for, I'll either fall back to manual instructions or offer to switch to GitHub-only mode. Sound okay to start?"*

This is honest about the state of the skill, gives the user an out, and avoids the worst failure mode (proceeding with a profile that's only half-implemented and pretending it's fine).

## Brownfield profile selection

If the user already has an existing setup (a repo, a Linear workspace, an existing label taxonomy), profile selection happens *with* the audit, not before. Read `brownfield_audit.md` for the audit script. Short version: detect what they already have, propose the profile that matches it ("you already have a Linear workspace, so I'll use the opinionated profile and audit the existing setup"), confirm, then run the audit before any writes.

## What to never do during profile selection

- **Never ask the user to compare features.** They picked Claude, not a procurement spreadsheet. Propose a default and let them override.
- **Never hide the three-level constraint to make GitHub-only look better.** It's a real limitation and surfacing it after provisioning is worse than friction up front.
- **Never proceed without explicit confirmation** of the profile choice. Even if the user opened with "use the opinionated profile", confirm once: *"Got it — opinionated profile (Linear + GitHub). Starting the audit."* Confirmation is one sentence, not a gate.
- **Never assume the user knows what "initiative" means in Linear vs. GitHub contexts.** If they ask, explain briefly. Don't lecture.

## After profile selection

Once the profile is chosen and (for GitHub-only) the three-level constraint has been acknowledged, run the three-state detection matrix from SKILL.md to figure out what's actually possible in this chat session, then proceed to discovery (the working-style step) before stage 1.
