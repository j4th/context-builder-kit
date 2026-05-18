# Linear planning

Operational reference for scaffold's provisioning when the planning backend axis is `linear`. Companion to `github_only_profile.md` (which covers the same shape when planning backend is `github-issues`).

The honesty disclosure to give the operator up front lives in `backend_selection.md`. Use it before starting.

## What this configuration provisions

- **Linear**: a team (admin-only, manual), a project under that team (via Linear MCP), workspace-level label taxonomy consistent with the cascade-standard label set, recommended cycle length based on appetite. Supports the full four-level hierarchy: initiatives → projects → milestones → issues.
- **GitHub**: same as the `github_only_profile.md` flow minus the GitHub Projects board (planning lives in Linear instead). Repo, labels, milestones (optional), starter `.github/` files.
- **Cross-tool integration**: Linear's GitHub app (OAuth, manual install) so commits and PRs from the GitHub repo flow into Linear's activity timeline.

The knowledge backend is **orthogonal** to this file. If the operator also picked `notion` for knowledge, see `notion_knowledge.md` for that axis's provisioning. Either knowledge backend (`notion` or `none`) is valid alongside Linear planning.

## What's documented enough to attempt

- **Repo creation in GitHub**: same as `github_only_profile.md` stage 1 steps 1–3 and 5. Skip the project board step (planning is in Linear, not GitHub Projects).
- **Conventions document with `planning = linear`**: same flow as the github-only path's stage 3, committed to the GitHub repo. The `.cascade/backends.toml` records `planning.backend = "linear"` per `backends.md` § Configuration.
- **Linear team verification**: read-only check via Linear MCP that the team exists and the operator has permission to create projects under it.

## What's deferred (gaps to flag honestly)

- **Linear project creation via MCP**: the operations exist (`mcp__linear__save_issue` with appropriate `teamId` and `parentId`), but the exact MCP tool names and inputs aren't documented in full here. Walk the operator through it, surface uncertainty, fall back to manual project creation in Linear's UI if MCP calls fail.
- **Linear label taxonomy provisioning**: same — exists but not documented in detail here.
- **Cross-tool integration verification**: every test action in the verification matrix needs to be defined per-integration, and that detailed table doesn't exist yet for the Linear-GitHub pairing.

These gaps don't block the configuration from being usable; they mean the skill walks the operator through manual fallback when MCP-driven automation hits one.

## Behavior when the operator picks `linear` for planning

1. Confirm Linear MCP is configured. If not, surface and offer fallback (manual Linear UI walkthrough).
2. Run the parts that *are* documented: GitHub repo provisioning, conventions doc with `planning = linear`, Linear team read-check.
3. For the gaps: walk through what should happen at a high level, ask the operator if they want to attempt it via MCP (with the caveat that the skill is guessing tool names for some operations) or do it manually in browser tabs.
4. Surface every gap as it happens. Do not pretend coverage that doesn't exist.
5. At the final HITL gate, mark scaffold as complete-with-gaps and document which pieces the operator provisioned manually so blueprint knows the state.

## When to flesh this out

The Linear-planning reference should get its full operational detail (MCP tool names per operation, label-taxonomy provisioning script, cross-tool verification matrix) after one real run through the `linear` + `notion` shape produces a working cascade end-to-end. Premature documentation of operations that haven't been exercised against a real session is exactly the kind of speculative work the cascade is supposed to avoid.
