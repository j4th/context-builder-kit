# Linear planning

Operational reference for scaffold's provisioning when the planning backend axis is `linear`. Companion to `github_only_profile.md` (which covers the same shape when planning backend is `github-issues`).

*One-run-exercised (a full real cascade ran on this configuration; recorded 2026-08-09 — per the dated-empirical-rails principle, re-verify the MCP tool surface before re-citing). Individually-unexercised call shapes are flagged inline; disclose and fall back per operation, never per axis.*

The honesty disclosure to give the operator up front lives in `backend_selection.md`. Use it before starting.

## What this configuration provisions

The **shell** the later phases build inside — provisioned here because it is workspace infrastructure, exactly like the repo and its labels:

```
Initiative                      (the cascade's top-level container)
└── Project shell               (one per phase/release; status + target date set)
    └── [workstream parent issues — created by BLUEPRINT, not scaffold]
        └── [F / R sub-issues — framing / rough-in]
```

Two load-bearing negatives from the exercised run: the cascade uses the planner's **parent/sub-issue links, never its Project-milestones field** (framing capabilities are F sub-issues), and workstreams are **parent issues, never Projects**.

- **Linear**: the team (admin-only — the operator creates it in the planner UI mid-scaffold; record the team name and the issue-key prefix `<TEAM>`), the initiative, the project shell with target date, and the team label taxonomy — the cascade-depth set (`cascade-depth:rough` / `framed` / `roughed-in`, `meta`) plus one `area:<slug>` label per anticipated workstream area, mirroring the GitHub label set.
- **Linear workflow settings** (operator-manual, from `cbk-conventions.md` § Recommended planning-backend settings): auto-complete parent ON, auto-complete sub-issues OFF, sub-issue rollup display ON, branch-name template `{type}/{teamPrefix}-{issueIdNumber}-{title}`.
- **GitHub**: same as the `github_only_profile.md` flow minus the GitHub Projects board (planning lives in Linear instead). Repo, labels, starter `.github/` files.
- **Cross-tool integration**: Linear's GitHub app (OAuth, manual install). Exercised heavily: branch names carrying the lowercase `<team>-<n>` substring auto-link to issues, and `Closes <TEAM>-N` in PR bodies closes them on merge.

The knowledge backend is **orthogonal** to this file. If the operator also picked `notion` for knowledge, see `notion_knowledge.md` for that axis's provisioning. Either knowledge backend (`notion` or `none`) is valid alongside Linear planning.

## Provisioning sequence

1. **Confirm Linear MCP is configured** (probe with `mcp__linear__list_teams`). If not, surface and offer fallback (manual Linear UI walkthrough for every planner step below).
2. **GitHub repo provisioning** — same as `github_only_profile.md` stage 1 steps 1–3 and 5; skip the project board step.
3. **Team** — operator-manual in the planner UI (team creation is admin-scoped). Capture the team name + `<TEAM>` prefix; verify via a read (`list_teams`).
4. **Team labels** — provision the cascade-depth + area label set (`mcp__linear__create_issue_label` per label). Exercised.
5. **Initiative + project shell** — create the initiative and one project (status, target date) under it. *Call shapes individually unexercised via MCP (`save_initiative` / `save_project`) — the exercised run's entities were created interactively; attempt, disclose, fall back to the planner UI without ceremony.*
6. **Workflow settings** — walk the operator through the four settings above (manual; not exposed via MCP).
7. **GitHub app integration** — operator installs Linear's GitHub app (OAuth). Verify with one test: a branch named `<type>/<team>-<n>-test` shows up on the issue's activity, or a draft PR body `Closes <TEAM>-N` links.
8. **Record everything in scaffold.md's Cascade metadata** (workspace, initiative, team + prefix, project shell — with URLs) and mirror the axis choice to `.cascade/backends.toml`. Blueprint verifies this shell rather than re-detecting it.

At the final HITL gate, note anything the operator provisioned manually so blueprint knows the state.

## Exercise status

The shell model and steps 2–4, 7–8 are exercised; step 5's MCP call shapes and step 6's settings walk are flagged above. When a later real run exercises a flagged call, drop its flag and restamp the date.
