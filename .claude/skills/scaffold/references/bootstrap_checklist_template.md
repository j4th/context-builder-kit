# Bootstrap checklist template

The session-scoped artifact scaffold produces alongside the conventions document. Unlike the conventions doc (which is persistent and gets read by every later phase), the bootstrap checklist is for the current user in the current session. It tells them what was done, what they still need to do manually, and how to verify each integration works.

## Storage

- **Inline in chat**: present the checklist in the chat for immediate use during stage 2's HITL gate
- **Downloadable artifact**: also produce as `bootstrap_checklist.md` via `create_file` + `present_files` so the user can save or share it
- **Do not commit to repo**: the checklist is session-scoped, not persistent. The conventions doc is the persistent artifact

## Four sections, in order

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
- **ADR starters**: `docs/adr/` created from the kit's starters — README, template, and ADR-0000 dated <date>, deciders <who>

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
- **OAuth integrations** (only when planning = `linear` or knowledge = `notion`): see axis-specific instructions in `manual_steps.md`.
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
| Scaffold output readable | View <repo URL>/blob/main/docs/cbk/scaffold.md | File renders, Cascade metadata reads `Planning backend: github-issues` | ☐ |
| Problem brief committed | View <repo URL>/blob/main/docs/cbk/problem_brief.md | File renders, contains problem statement and appetite | ☐ |
| Branch protection (if configured) | Try to push directly to main from a clone | Push is rejected | ☐ |
```

Only include rows that are actually applicable. State 2 (no projects toolset) omits the project board row. State 4 (no MCP) puts everything in section 2 (manual instructions) and the verification matrix becomes longer.

### 4. Rule-file disposition

The kit's `.claude/rules/` ships three template rules that carry bracketed placeholders (`cbk-conventions.md`, `orchestration.md`, `tooling.md`) and two path-scoped rules whose `paths:` globs are placeholders (`logging.md`, `testing.md`). Nothing else in the cascade ever asks about them, so this section does: print the always-loaded set with its size first (the loop in `cbk-conventions.md` § Verification), then require an explicit disposition per file. A row with no disposition is a defect, not a default — a real run reached dozens of merged PRs with `[Record the project's posture here]` still in an always-loaded rule.

```markdown
## 📐 Rule-file disposition

Always-loaded rules as of this checklist:
<paste the always-loaded loop's output — one line per file with its byte count, and the total>

| Rule | Disposition | Reason |
|---|---|---|
| `cbk-conventions.md` | filled | surface inventory, branch naming, close markers stamped from this scaffold |
| `orchestration.md` | filled / path-scoped / deleted | <e.g. "filled — default posture recorded"> |
| `tooling.md` | filled / path-scoped / deleted | <e.g. "deleted — no MCPs wired yet; restore from the kit when the first lands"> |
| `logging.md` | stamped | `paths:` set to `**/*.<ext>` |
| `testing.md` | stamped | `paths:` set to `**/*_test.<ext>`, `**/test/**` |
| `knowledge-backend.md` | kept / deleted | <"deleted with its hook and settings stanza — knowledge axis is none"> |

One-time choices settled here (each has a kit default; a choice with no forcing surface is a choice the kit made for you):
- **Reviewer agent-memory**: `memory: project` (committed under `.claude/agent-memory/`, precedents survive clones and get PR-reviewed) or `memory: local` (`.claude/agent-memory-local/`, never committed). Decision: <project | local>. Recorded in `cbk-conventions.md` § Surface inventory.
- **Licence**: <SPDX id | none yet — all rights reserved>. Recorded in `docs/cbk/scaffold.md` § Cascade metadata.
```

The dispositions and what each means: **filled** — the bracketed sections carry this project's values, and the file opens with a one-line provenance note (the date, that it was filled from the kit's template, where it deviates); choices are appended under the template prose, not written over it. **path-scoped** — the file gains a `paths:` block so it loads only when a matching file is read. **deleted** — the file governs a surface this project does not have, and boilerplate would only tax every session; delete every index that lists it in the same change (`CLAUDE.md`, `README.md`, the reviewer that enumerates it) and note the restore condition. **kept** is valid only for a rule with no placeholders. **stamped** is the path-scoped rules' equivalent of filled.

In light mode this section is one line per file.

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
