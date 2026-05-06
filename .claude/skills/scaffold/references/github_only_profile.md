# GitHub-only profile

The fully-fleshed-out reference for the GitHub-only backend profile. Covers what scaffold actually does in each of the four detection states (see SKILL.md), every fallback path, and the operations against the consolidated GitHub MCP toolset. This is the v1 priority — the opinionated profile reference is a stub.

## What this profile provisions

A single GitHub repository that holds everything: code, planning (via GitHub Projects boards, repo Milestones, Issues), knowledge (markdown files in `docs/`), and conventions (markdown file at repo root or `.github/`). The cascade is **three-level**: project board → milestone → issue. Initiative-level artifacts (from blueprint) live as markdown documents, not as planning entities.

## Stage 2 — Resource provisioning by detection state

### State 1 — Full automation (GitHub MCP + projects toolset + write scopes)

### State 1 — MCP + write scopes (the common case)

MCP can create the repo and push files. Labels, milestones, and project boards **do not have MCP tools today** — those are manual operations regardless of PAT permissions. The flow:

**Via MCP:**
1. **Create the repository.** Use the `create_repository` tool. Inputs: name (derived from problem brief, in kebab-case, confirm with user), visibility (ask: public or private — solo defaults to private, team to whatever the org standard is), initialize with README, add a sensible `.gitignore` for the rough stack the user mentioned in the brief (or skip if no signal), and a license (MIT default for solo, ask for team).
2. **Push starter `.github/` files.** Commit via the file-creation tool: an issue template for bug reports, an issue template for features, a PR template, a `CODEOWNERS` file (single owner = the user, for solo; ask for team), and one CI workflow stub (`.github/workflows/ci.yml`) that runs an empty job — real CI gets configured in blueprint. Templates live in `references/scaffold_output_template.md`.

**Manual (generate instructions inline, user completes in browser tabs):**
3. **Create the label taxonomy.** Visit `<repo URL>/labels`. Delete or rename GitHub's auto-generated defaults (`bug`, `enhancement`, etc.) to avoid collisions with the cascade taxonomy, then create the standard set: `bug`, `feature`, `improvement`, `tech-debt`, `documentation`, plus area labels from the brief. Provide the full list with hex colors so the user can copy-paste.
4. **Create the project board.** Visit `<repo URL>/projects` → "New project". **Template choice**: pick "Board" (basic kanban) unless the user has a reason for another layout — Board is the simplest and maps cleanly to the cascade's issue-state flow. Project name is goal-based and matches the repo name (e.g. "notes-cli"), not date-based. Link the project to the repo.
5. **Skip milestones and issues.** Milestones are planning artifacts that belong in rough-in (phase 5). Issues belong in finish (phase 6). Do not create either in scaffold, even as "starters."

After step 4, present the verification matrix and walk the user through it. Then proceed to stage 3 (conventions).

### State 2 — MCP + read-only (brownfield audit only)

MCP can read repos, files, and issues — enough for the brownfield audit — but can't create or push anything. Surface what's missing:

> *"GitHub MCP is connected but in read-only mode — I can audit your existing setup but can't create anything. Two options: (a) update your token permissions (fine-grained PAT needs Contents read & write at minimum), reconnect, and I'll re-detect, or (b) I run the audit via MCP and generate manual instructions for all provisioning. Which do you prefer?"*

If (a), pause and re-detect. If (b), run the audit via MCP, then fall through to state 3 behavior for provisioning.

### State 3 — No MCP, full manual mode

Scaffold becomes a guided checklist. Generate step-by-step manual instructions for everything — repo creation, `.github/` files, label taxonomy, project board, conventions doc — with exact URLs, click-paths, and expected outcomes. Walk the user through interactively in small batches (3–4 steps at a time), wait for confirmation, then present the next batch.

The full manual checklist content lives in `manual_steps.md`. Reference that file when generating the walkthrough.

## Stage 3 — Conventions document

Same flow regardless of detection state. Build the scaffold output doc from `scaffold_output_template.md`, populated from discovery answers (team shape, preferences) and provisioning decisions (branch naming, labels, commit format). **Present inline in chat first for review.** Only commit after explicit approval.

1. **First try: commit to the repo via GitHub MCP**: create `docs/cbk/` directory, commit both `problem_brief.md` and `scaffold.md` to it. These are the preferred locations because later phases can find them via GitHub MCP without the user re-uploading.
2. **Fallback: downloadable artifacts via `create_file` + `present_files`.** Tell the user: *"I couldn't commit these via MCP. Here are the scaffold output doc and problem brief — please save them to `docs/cbk/scaffold.md` and `docs/cbk/problem_brief.md` in your repo so blueprint can find them."*

## What this profile does *not* do

- **Does not configure branch protection.** That's an admin operation that requires UI clicks. Add it to the manual instructions section of the bootstrap checklist with a link and recommended settings.
- **Does not set up GitHub Actions beyond a stub workflow file.** Real CI configuration depends on stack decisions that happen in blueprint.
- **Does not create the org-level project board.** Even when the user is in an org, scaffold creates a repo-scoped project. Org-level projects are an explicit user request, not a default.
- **Does not create milestones, issues, or any planning content.** Milestones belong in rough-in (phase 5), issues in finish (phase 6). Scaffold provisions the *workspace*; planning artifacts come later.
- **Does not commit `CLAUDE.md`, `AGENTS.md`, `.claude/`, or `.mcp.json`.** AI agent configuration belongs in blueprint, where stack decisions exist.
- **Does not configure secrets or environment variables.** Those are session-specific and security-sensitive; flag them in manual instructions.

## Verification actions for state 1 / state 2

When walking the user through the verification matrix in stage 2, use these test actions:

| Item | Test action | Expected outcome |
|---|---|---|
| Repository created | Visit the repo URL in a browser | Page loads, README is visible |
| Issue templates work | Click "New issue" in the repo | Templates appear in a dropdown |
| Label taxonomy applied | Visit `/labels` in the repo | All cascade labels present, GitHub defaults cleaned up |
| Project board exists | Visit the project URL | Board loads with "Board" template, repo is linked |
| Scaffold output committed | View `docs/cbk/scaffold.md` in the repo | File exists, contains `Profile: github-only` |
| Problem brief committed | View `docs/cbk/problem_brief.md` in the repo | File exists, contains problem statement and appetite |

If any row fails, surface it and offer to retry (for MCP operations) or re-walk the manual instructions for that specific row. Don't restart the whole stage.

## Common gotchas

- **Visibility default**: solo defaults to private; team defaults to whatever the user states. Always confirm explicitly — getting this wrong is recoverable but annoying.
- **License choice**: defaulting to MIT for solo is fine, but ask for teams. Never default to GPL or AGPL without explicit user opt-in — the implications are significant.
- **`.gitignore` overreach**: don't generate a 500-line `.gitignore` with every possible language. Pick one stack hint from the brief, generate that, note that the user can extend later.
- **Label cleanup on new repos**: GitHub auto-creates default labels (`bug`, `enhancement`, `question`, etc.) when initializing a repo. These will collide with the cascade taxonomy. When walking the user through manual label creation, tell them to delete or rename the auto-generated defaults first, then create the cascade set. One instruction, before the label list.
- **Project board template choice**: GitHub Projects asks which template to start from (Board, Table, Roadmap, Team planning). Default to **Board** (basic kanban) — it's the simplest and maps cleanly to issue state flow. Only suggest another template if the user has a specific reason.
- **Project-vs-project naming confusion**: a "project" in GitHub Projects is not the same as a "project" in the cascade. In GitHub-only mode, the cascade's framing-phase "project" maps to a GitHub project board. The project board name should match the repo name. Clarify once during stage 2.

## Minimum-mode behavior in this profile

If the user has invoked light mode (see SKILL.md), collapse the provisioning flow:

- **One up-front confirmation**, listing exactly what will be created (via MCP) and what will need manual steps
- **No per-step approval** during provisioning — run MCP steps, generate manual instructions in one batch, surface results together
- **Skip the verification matrix** unless the user asks for it
- **Skip the `.github/` issue templates** unless the brief implies they matter
- **Conventions doc is one paragraph**, not a full template

Even in light mode, the three-level constraint conversation still happens at least once (in one-sentence form). See `profile_selection.md`.
