# Opinionated profile (Linear + GitHub)

**Status: stub.** This profile is structurally supported in SKILL.md but the operational detail is deferred to a follow-up. If a user picks it, walk them through what's documented here, flag gaps explicitly, and offer to fall back to GitHub-only mode if they hit blockers.

The honesty disclosure to give the user up front lives in `profile_selection.md`. Use it before starting.

## What this profile provisions (intended scope)

- **Linear**: a team (admin-only, manual), a project under that team (via Linear MCP), workspace-level label taxonomy consistent with GitHub labels, recommended cycle length based on appetite. Supports the full four-level hierarchy: initiatives → projects → milestones → issues.
- **Notion**: a project hub page with sub-pages for the problem brief, decision log, meeting notes (teams), and documentation hierarchy. Notion integration must be manually shared with each page (always-manual operation).
- **GitHub**: same as the GitHub-only profile minus the GitHub Projects board (planning lives in Linear instead). Repo, labels, milestones (optional), starter `.github/` files.
- **Cross-tool integrations**: Linear's GitHub app (OAuth, manual install), Linear's Notion integration (manual enable in Linear settings).

## What's documented enough to attempt

- **Repo creation in GitHub**: same as `github_only_profile.md` stage 1 steps 1–3 and 5. Skip the project board step (planning is in Linear, not GitHub Projects).
- **Conventions document with `profile: opinionated, hierarchy_levels: 4`**: same flow as GitHub-only stage 3, committed to the GitHub repo.
- **Linear team verification**: read-only check via Linear MCP that the team exists and the user has permission to create projects under it.

## What's deferred (gaps to flag honestly)

- **Linear project creation via MCP**: the operations exist, but the exact tool names and inputs aren't documented in this stub. Walk the user through it, surface uncertainty, fall back to manual project creation in Linear's UI if MCP calls fail.
- **Linear label taxonomy provisioning**: same — exists but not documented in detail here.
- **Notion hub creation**: same.
- **Cross-tool integration verification**: every test action in the verification matrix needs to be defined per-integration, and that table doesn't exist yet.

## Behavior when the user picks this profile in v1

1. Give them the stub disclosure from `profile_selection.md`.
2. Confirm they want to proceed anyway (or fall back to GitHub-only).
3. Run the parts that *are* documented: GitHub repo provisioning, conventions doc with `profile: opinionated`, Linear team read-check.
4. For the gaps: walk through what should happen at a high level, ask the user if they want to attempt it via MCP (with the caveat that the skill is guessing tool names) or do it manually in browser tabs.
5. Surface every gap as it happens. Do not pretend coverage that doesn't exist.
6. At the final HITL gate, mark scaffold as complete-with-gaps and document which pieces the user provisioned manually so blueprint knows the state.

## When to flesh this out

The opinionated profile reference should get its full treatment after one real run through GitHub-only mode produces a working cascade end-to-end. Premature documentation of operations that haven't been exercised against a real session is exactly the kind of speculative work the cascade is supposed to avoid.
