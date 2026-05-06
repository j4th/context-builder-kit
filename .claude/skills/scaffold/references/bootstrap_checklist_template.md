# Bootstrap checklist template

The session-scoped artifact scaffold produces alongside the conventions document. Unlike the conventions doc (which is persistent and gets read by every later phase), the bootstrap checklist is for the current user in the current session. It tells them what was done, what they still need to do manually, and how to verify each integration works.

## Storage

- **Inline in chat**: present the checklist in the chat for immediate use during stage 2's HITL gate
- **Downloadable artifact**: also produce as `bootstrap_checklist.md` via `create_file` + `present_files` so the user can save or share it
- **Do not commit to repo**: the checklist is session-scoped, not persistent. The conventions doc is the persistent artifact

## Three sections, in order

### 1. Completed items

Resources provisioned via MCP, with links and a one-line description each. Format:

```markdown
## ✅ Completed (via MCP)

- **Repository**: <repo URL> — created with README, .gitignore, MIT license
- **Issue templates**: bug report and feature request templates added under `.github/ISSUE_TEMPLATE/`
- **PR template**: added at `.github/pull_request_template.md`
- **Scaffold output doc**: committed at `<repo>/docs/cbk/scaffold.md`
- **Problem brief**: committed at `<repo>/docs/cbk/problem_brief.md`
- **Knowledge surface**: `docs/cbk/` directory created

## 🔧 Completed manually (by you during this session)

- **Label taxonomy**: 5 type labels and 3 area labels created (see `docs/cbk/scaffold.md`)
- **Project board**: <project URL> — Board template, repo linked
```

If a row is not applicable (e.g. no project board because state 2), omit it. Don't show empty rows.

### 2. Manual instructions

Steps the user must complete themselves in browser tabs. Each item has an exact URL and an expected outcome. Format:

```markdown
## 🔧 Manual steps for you

These are operations scaffold cannot automate. Do them in browser tabs:

- **Branch protection**: Visit <repo URL>/settings/branches → "Add rule" → branch name pattern `main` → enable "Require pull request before merging" and "Require status checks to pass". Expected outcome: main is protected from direct pushes.
- **Repository secrets** (if needed): Visit <repo URL>/settings/secrets/actions → "New repository secret" for any deployment tokens or API keys. Expected outcome: secrets visible in the secrets list.
- **Team member invites** (team only): Visit <repo URL>/settings/access → "Invite a collaborator". Expected outcome: invitees receive email.
- **OAuth integrations** (opinionated profile only): see profile-specific instructions in `manual_steps.md`.
```

Use the canonical list from `manual_steps.md` — do not invent new manual steps. If the project genuinely needs something not in that list, surface it as an exception and note the gap.

### 3. Verification matrix

A table the user walks through to confirm each integration actually works. The point of this section is **catching half-setup failures** — the most common scaffold failure mode is something that looks configured but doesn't actually work end-to-end. Each row has a test action and an expected outcome.

```markdown
## ✓ Verification matrix

Walk through each row. If anything fails, retry or fall back to manual instructions for that row only.

| Item | Test action | Expected outcome | Status |
|---|---|---|---|
| Repo accessible | Visit <repo URL> in a browser | Page loads, README renders | ☐ |
| Issue templates work | Click "New issue" in the repo | Bug and feature templates appear in dropdown | ☐ |
| Labels exist | Visit <repo URL>/labels | All cascade labels present, GitHub defaults cleaned up | ☐ |
| Project board exists | Visit <project URL> | Board loads with Board template, repo is linked | ☐ |
| Scaffold output readable | View <repo URL>/blob/main/docs/cbk/scaffold.md | File renders, contains `Profile: github-only` | ☐ |
| Problem brief committed | View <repo URL>/blob/main/docs/cbk/problem_brief.md | File renders, contains problem statement and appetite | ☐ |
| Branch protection (if configured) | Try to push directly to main from a clone | Push is rejected | ☐ |
```

Only include rows that are actually applicable. State 2 (no projects toolset) omits the project board row. State 4 (no MCP) puts everything in section 2 (manual instructions) and the verification matrix becomes longer.

## Tone and posture

The bootstrap checklist is the user's hand-off document. They will look at it after the chat ends, possibly weeks later, and try to figure out what state they're in. Write it accordingly:

- **No skill internals**: don't mention "stage 2" or "detection state" or "the three-state matrix" — those are skill mechanics, not user concepts
- **Real URLs, not placeholders**: every URL in the checklist must be a real link to a real resource. Placeholders (`<repo URL>`) are only allowed in this template file
- **Test actions, not assertions**: "Visit X and confirm Y" is good. "X is configured" without a test action is a checkbox the user will tick without checking
- **Honest about what didn't happen**: if a manual step is required, say so plainly. Don't bury it under "completed" framing

## Minimum-mode collapse

If the user invoked light mode, the checklist collapses to:

```markdown
# Bootstrap complete

**Done**: <one-line summary of what got created>
**You still need to**: <one-line list of manual steps, or "nothing">
**Quick check**: <one verification action — visit the repo URL and confirm it loads>

Scaffold output doc is at `docs/cbk/scaffold.md`.
```

Five lines. The user took responsibility for skipping the full ceremony; the checklist honors that.

## Anti-patterns to avoid

- **Performative completeness**: don't list 30 rows in the verification matrix when 5 are load-bearing. Long checklists get skimmed, short ones get walked
- **Mixing sections**: completed, manual, and verification are three different things. Don't merge them into a single "to do" list
- **Burying failures**: if something failed during provisioning, surface it in section 2 (manual fallback) explicitly, with the failure reason and what the user should do instead. Silent failures in scaffold cause loud failures in blueprint
- **Skipping the verification matrix entirely** (in full mode): the matrix is the half-setup defense. In light mode the user can opt out; in full mode it should be present
