---
name: scaffold
description: Provision the workspace infrastructure (repo, planning surface, knowledge surface) that the rest of the AI-assisted development cascade will use. Use this skill whenever the user has a problem brief and needs to set up where the work will live, or says things like "set up the workspace", "bootstrap the repo", "I'm starting a new repo", "where should I put this project", "I need to set up GitHub for this", "I have my plan, now what", or references the cascade at the scaffold level. Also use when a user wants to start a new project end-to-end and skipped consultation. **Use this skill even when the user doesn't explicitly ask for "scaffolding" or "bootstrap" — the trigger is the moment of "I have a plan and need a place to put it", not the vocabulary.** Phase 2 of the cascade. Supports three backend profiles — GitHub-only (validated), opinionated Linear+Notion (validated), and markdown-only (no planning surface, for users who don't want a board). Produces a scaffold output doc and bootstrap checklist.
---

# Scaffold

Phase 2 of the six-phase AI-assisted development cascade. Provisions the workspace where later phases will create and manage artifacts: a code repository, a planning surface, and a knowledge surface. Captures the team shape and working preferences that blueprint will formalize into developer-facing docs.

Scaffold is "construction site setup" — the crane is in, the foundation pad is poured, temporary utilities are installed. It is *not* the building. No code, no planning hierarchy, no AI agent configuration committed to the repo (those belong in blueprint). The output is infrastructure plus the working context that enables blueprint to produce standards.md, contributing.md, and the initiative spec.

This skill runs in chat and has no filesystem of its own. Everything it provisions happens through MCP servers the user has connected (primarily GitHub MCP, optionally Linear/Notion MCP), through manual instructions the user follows in browser tabs, or through downloadable markdown artifacts when MCP isn't available.

**Acquiring the problem brief.** Scaffold needs the problem brief's content to commit it to the repo. It may arrive as: an uploaded file, content in project knowledge, pasted inline in the chat, or already in context from a consultation session. If the brief isn't visible, ask: *"Can you share the problem brief from consultation? I'll commit it to the repo so blueprint can find it in a fresh session."* If the user ran consultation verbally and has no written brief, draft one from what's in context and present it for approval before committing.

If the user shows up wanting to scaffold but doesn't have any problem brief at all, **do not silently proceed**. Either run consultation first (offer to do so in-chat), or accept a verbal problem statement and note explicitly that the brief is informal — the cascade works better with a real brief, but a verbal one is acceptable for small projects.

## Light mode — when the user wants this lighter

Scaffold's full flow (profile selection → discovery → audit → provisioning → output, with five HITL gates) is the **full** mode, not a requirement. A user who says *"just give me a repo and some labels"*, *"keep it minimal"*, *"I know what I'm doing"* should get **light** mode. The skill is opinionated, not dogmatic.

Light-mode patterns:

- **Collapse gates**: combine everything into a single "here's what I'll do and what I need from you, ok?" confirmation up front.
- **Collapse discovery**: one message — *"Quick working-style check: solo or team, quality bar, and how familiar are you with these tools?"* — three answers, move on.
- **Skip the verification matrix**: offer it, don't force it.
- **Scaffold output is minimal**: cascade metadata + the few working conventions captured, no elaboration.

What scaffold should *not* skip even in light mode: the **three-level constraint conversation** (if GitHub-only is picked) — one sentence is enough. And a **minimal discovery round** — at least team shape and quality bar, because blueprint can't calibrate without them.

If the user pushes back even on those, proceed. Note the override and move on.

## Profile selection (runs first)

Scaffold supports three backend profiles. The user picks one before any work begins. Profile choice determines which MCPs the skill expects, which artifacts get produced, and how much (or whether) cascade hierarchy lives on a planning backend versus only in markdown.

### Profile A — GitHub-only *(recommended starting point, fully fleshed out)*

Code, planning, and knowledge all live in a single GitHub repository. Planning uses GitHub Projects v2 boards + Issues with sub-issues (GA'd 2025) for the parent/child hierarchy. Knowledge lives as markdown files in `docs/cbk/`. Workstreams become parent Issues, framing capabilities become sub-issues, rough-in items become sub-sub-issues, all on one Projects v2 board with one Status field and swimlanes grouped by parent. See `references/backends.md` for the full mapping.

### Profile B — Opinionated (Linear + GitHub) *(stub in v1)*

Planning in Linear (four-level hierarchy). Knowledge in Notion. Code in GitHub. Detailed reference (`references/opinionated_profile.md`) is a stub in v1.

### Profile C — Markdown-only *(no planning surface)*

Cascade artifacts live entirely as markdown files in `docs/cbk/`. **No GitHub Project board, no Issues, no Milestones, no Linear, no Notion** — just the markdown event log. The cascade still produces every markdown file it would produce in github-only mode (`problem_brief.md`, `scaffold.md`, `blueprint.md` with workstreams table, `framings/frame-NN.md` event files, `README.md` chronological index) and uses the same naming conventions inside the markdown (`[<workstream-slug>:F<#>]` headings, etc.) so the hierarchy is grep-able even without an Issue tree to render it.

**When to pick markdown-only**: the user explicitly doesn't want a kanban/board surface; the cascade is being run as design documentation rather than active work tracking; the audience for the cascade output (e.g., a manager, a PM, a stakeholder) won't be living in GitHub Issues day-to-day; the project is small enough that markdown alone is sufficient; the user is bootstrapping the cascade against a workspace where they don't have permission to create boards or labels; or the user is running the cascade purely for design rationale and decision history without intending to track work execution against it.

**What scaffold does in markdown-only mode**: provisions the repo (or verifies an existing repo) and the `docs/cbk/` directory, commits a `scaffold.md` with `profile: markdown-only`, and skips every planning-backend setup step (no Project board check, no label taxonomy creation, no Linear/Notion provisioning, no PAT scope check for `read:project`). The bootstrap checklist becomes much shorter — only the repo and `docs/cbk/` matter. Manual setup steps that exist in the other profiles for OAuth/board configuration/integration installation simply don't apply.

**What blueprint and framing do in markdown-only mode**: the entire planning-backend-commit step is skipped in both phases. The atomic transition collapses to a single half (just the markdown commit, no rollback needed). See blueprint and framing's `references/planning-backend-commit.md` for the per-phase markdown-only behavior, which is already plumbed through both skills.

### How to pick

Read `references/profile_selection.md`. Short version: detect from context, propose in one sentence, let user confirm or override. Signals that point to markdown-only specifically: user says *"I don't need a board"*, *"just give me the docs"*, *"I'm not going to track this in GitHub"*, *"this is for documentation"*, *"my manager won't read GitHub Issues"*, or describes the audience as non-technical / non-developer / not GitHub-native.

### Markdown-only confirmation gate (mandatory before committing to Profile C)

Markdown-only is a one-way door at the cascade level — once scaffold commits `profile: markdown-only` and blueprint and framing run against it, switching to a planning-backed profile later means re-running scaffold and re-doing the planning-backend half of every prior phase by hand. The choice deserves an explicit confirmation gate at the moment of selection, not a casual "sure, sounds good." Even if the user's opening message strongly signals markdown-only (they said *"my manager won't read GitHub Issues"* explicitly), scaffold runs this gate before committing.

The gate language:

> "Before I commit to markdown-only, I want to make sure you understand what you're opting out of, because this choice is hard to reverse later:
>
> - **No GitHub Project board**, no Issues, no sub-issues. The cascade produces zero entities on the planning backend.
> - **No kanban view** of work in progress. There is no "what's currently being worked on" surface anywhere — the cascade event log (`README.md` index) is the only place to see what's been framed and what's next.
> - **No automated work tracking**. Status, in-progress, in-review, done — none of these exist as queryable state. If you (or anyone else) want to know what state a workstream is in, you read the markdown.
> - **No board for collaborators to look at**. If anyone other than you needs to see work-in-flight, they're reading markdown files in the repo, not browsing a board.
> - **Setup steps stay in `blueprint.md` § Manual setup** instead of becoming a tracked GitHub handoff issue. You read the section, work through the steps, commit updates as you go.
> - **Switching profiles later is hard**. If you start in markdown-only and decide three workstreams in that you want a board after all, you'll need to re-run scaffold and re-create the planning-backend objects for every prior workstream by hand. The cascade can help, but it's not a one-command flip.
>
> What you keep:
>
> - Every markdown file the cascade would produce in any other profile (problem brief, scaffold output, blueprint with workstreams table, framings, foundation docs)
> - All naming conventions inside the markdown (`[<workstream-slug>:F<#>]` headings, slug discipline, etc.) so the hierarchy is grep-able
> - Unenforced invariants section, sanity pass, review-bot construction — all stack-config concerns work identically
> - The cascade-event model and supersedes-not-overwrites discipline at the markdown level
> - Full design history, decision rationale, and traceability — markdown-only is a complete record, just without the live work tracker
>
> Sound right? If yes, I'll commit `profile: markdown-only` and continue. If you'd rather have a board after all (even a bare-bones one), say so now and we'll go with **github-only** instead — that's the validated primary path and matches most cascade users."

The user's confirmation is binary: explicit "yes, markdown-only" or any hesitation → propose github-only as the alternative and re-run the gate against the new choice. **Never proceed past this gate on an implicit or ambiguous answer.** Scaffold's job here is to make sure the user is making the choice deliberately, not falling into it because the conversation was moving fast.

This gate runs in **every rigor mode**, not just full mode. It cannot be skipped or collapsed even in light mode — the one-way-door property is too strong to leave to inference. The light-mode collapse applies only to the *other* gates in scaffold's flow, not this one.

## The detection matrix (GitHub-only profile)

Before provisioning, detect what's possible in this session. As of early 2026, the GitHub MCP server can create repositories and push files, but **cannot** create labels, milestones, or project boards — regardless of PAT scopes. There is no "full automation" state. Every run involves MCP operations + manual instructions.

| State | GitHub MCP? | What MCP can do | What's manual | Behavior |
|---|---|---|---|---|
| **1. MCP + write** | ✅, write scopes | Create repo, push files | Labels, milestones, project board, branch protection, secrets | Automate repo + files via MCP. Manual instructions for the rest. |
| **2. MCP + read-only** | ✅, read-only | List repos, read files (brownfield audit) | Everything above + repo creation | Audit via MCP. All provisioning manual. |
| **3. No MCP** | ❌ | Nothing | Everything | Full manual guided checklist. |

**PAT guidance**: fine-grained PATs are recommended. Minimum: Repository permissions — Contents (read & write), Metadata (read). Projects V2 has a known gap in fine-grained PATs; classic PAT with `repo` and `project` scopes is the fallback.

**Tell the user which state you detected and what will be manual** before provisioning starts.

## Discovery step (runs after profile selection, before provisioning)

This is where scaffold captures the team shape and working preferences that blueprint needs to write standards.md and contributing.md. Without this, blueprint has to re-derive everything from scratch in a fresh session.

**Core questions** (batched at standard rigor, collapsed to one message at light):

1. *"Is this solo or team? If team — how many people, what roles, and who makes the call when there's a disagreement?"*
2. *"What's your quality bar for this project — move fast and iterate, or get it right from the start?"* (Single highest-value question scaffold can ask. Shapes testing, review, and CI decisions downstream.)
3. *"How do you want PRs to work? Reviewed by someone else, self-reviewed, or straight-to-main?"*
4. *"How comfortable are you with the tools we're setting up? First time with GitHub Actions / project boards, or veteran?"*
5. *"What pace are you working at — full-time, part-time, evenings-and-weekends?"* (Appetite was captured in consultation, but confirming here is cheap and the answer may have changed.)

At full rigor, each question gets its own turn with follow-ups. Probe deeper on quality bar especially — *"When you say 'move fast,' does that mean no tests, or tests for critical paths, or full TDD?"*

**Additional team-specific questions** (if team was the answer to Q1):
- *"Sync or async? Timezone spread?"*
- *"How do decisions get recorded — ADRs, PR descriptions, issue comments, verbal-and-move-on?"*
- *"Who reviews PRs — dedicated reviewer, round-robin, or whoever's available?"*

Answers feed into the scaffold output doc's Team Shape and Development Preferences sections. They are **not** finalized decisions — they're the user's stated preferences that blueprint will formalize.

**HITL gate**: reflect back what you heard in 2–3 sentences, confirm, move on.

## Stage 1 — Account and brownfield audit

Goal: confirm accounts exist and surface anything pre-existing.

For greenfield: fast confirmation that the user has the relevant accounts and permissions.

For brownfield: run the workspace audit from `references/brownfield_audit.md` — read existing state via MCP, surface what exists, ask what to keep/replace/avoid.

**What must always be manual**: account creation, billing, OAuth, admin permissions, team invites, SSO, branch protection, secrets. Canonical list in `references/manual_steps.md`.

**HITL gate**: user confirms account state and audit findings.

## Stage 2 — Resource provisioning

Goal: create the repo, planning surface, and label taxonomy.

What gets provisioned depends on profile and detection state. Full per-profile steps in `references/github_only_profile.md` and `references/opinionated_profile.md` (stub).

**Working conventions captured during this stage**: as you provision labels, branch naming, and commit format, confirm each with the user. These decisions become part of the scaffold output doc.

- **Branch naming**: propose a format based on team identifier from discovery, e.g. `{team-id}-{issue-number}-{short-description}`. Confirm with user.
- **Commit format**: propose Conventional Commits as default unless the user has a preference. Confirm.
- **Label taxonomy**: propose the cascade standard set (bug, feature, improvement, tech-debt, documentation) plus area labels derived from the problem brief. Confirm, then walk the user through manual creation.

**HITL gate**: user confirms what was created, walks verification matrix.

## Stage 2.5 — Provision cascade issue templates

Goal: commit the four cascade-aware GitHub issue templates to `.github/ISSUE_TEMPLATE/` so that downstream skills (blueprint, framing, rough-in) and human collaborators all use the same Issue body shapes.

**Why this is its own step**: the issue templates are workspace infrastructure, not a problem-specific artifact. They're structural — the cascade-shape they encode is the same across every project — and they need to land before any cascade phase that creates Issues. Putting template provisioning here means blueprint can read `.github/ISSUE_TEMPLATE/cascade-workstream.md` from disk when constructing parent Issue bodies, framing can read `cascade-framing.md` and `cascade-meta.md`, and rough-in can read `cascade-rough-in.md`. One source of truth, on disk, in the standard GitHub location, visible to the web UI for human-created issues.

**The four templates**:

| Template file | Used by | Issue type | Title format |
|---|---|---|---|
| `.github/ISSUE_TEMPLATE/cascade-workstream.md` | blueprint (or human) | Workstream parent Issue | `[<slug>] <name>` |
| `.github/ISSUE_TEMPLATE/cascade-framing.md` | framing (or human) | Framing capability sub-issue | `[<slug>:F<#>] <capability>` |
| `.github/ISSUE_TEMPLATE/cascade-rough-in.md` | rough-in (or human, or `/finish`) | Rough-in sub-sub-issue | `[<slug>:F<#>:R<#>] <intent>` |
| `.github/ISSUE_TEMPLATE/cascade-meta.md` | framing (or human) | Deferred meta-issue | `[<slug>:meta] <subject>` |

Each template has YAML frontmatter (`name`, `about`, `title`, `labels`, `assignees`) so the GitHub web UI honors them when humans manually create issues. The body of each is structured but not strangling — sections that downstream cascade phases populate, with HTML comments explaining what goes in each section, written so that both automated cascade runs and human authors can use them effectively.

**The rough-in template is the most novel** because the resulting Issue is intended to be runnable via Claude Code's `/finish {issue_number}` slash command. Its body has six sections (Context / Implementation / Acceptance criteria / Done signal / Dependencies / PR contract), and `/finish` will anchor hardest on the Implementation section while reading the rest as supporting context. The template makes the heading structure mandatory (sections can be edited freely but heading names must stay as-written) so `/finish` can identify sections by name.

**The reference templates live in this skill bundle** at `references/issue-templates/`. Scaffold reads them from there and writes them to `.github/ISSUE_TEMPLATE/` in the user's repo via GitHub MCP. The bundled copies are the source of truth that scaffold ships; the repo copies become the live source of truth that downstream skills and humans actually use.

**Step steps**:

1. **Read all four templates** from `references/issue-templates/` (this skill bundle)
2. **Verify the target directory** — check whether `.github/ISSUE_TEMPLATE/` already exists in the user's repo via `get_file_contents`. If yes, list any existing templates so the user can decide about overwrites. If no, the directory will be created on first commit.
3. **Idempotency check** — for each template, check whether it already exists in the repo. If a template with the same name exists with **identical content**, treat as already-provisioned and skip. If it exists with **different content**, surface to the user with the choice: (a) overwrite with the cascade version, (b) keep the existing version (the cascade will read it and adapt), or (c) abort the step.
4. **HITL gate**: present the list of templates that will be committed, including which (if any) will overwrite existing files. Get explicit user approval before any commit.
5. **Commit each template** via GitHub MCP. The four commits can be batched into a single PR or committed directly to the default branch depending on the user's branch protection rules — same pattern as the rest of scaffold's provisioning.
6. **Verification** — read each committed template back via `get_file_contents` to confirm it landed correctly. If any template doesn't read back identical to what was sent, surface as a commit failure and follow the partial failure recovery protocol from `references/backends.md` § Atomic transitions.

**Idempotency note**: this step is safe to re-run. Re-running scaffold against an already-provisioned repo will detect existing templates, skip identical ones, and only surface differences for user decision.

**Brownfield case**: if the user is running scaffold against a repo that already has hand-curated GitHub issue templates (e.g., a generic `feature_request.md` or `bug_report.md`), the step does NOT delete or modify them. It only adds the four cascade-* templates alongside whatever exists. The user's existing templates continue to work for non-cascade issues.

**Failure modes specific to this step**:

- **Template content drift between bundle and repo** — a previous scaffold run wrote templates that have since been hand-edited in the repo. Defense: idempotency check surfaces this as "exists with different content" and asks the user.
- **Templates exist but bundle has new versions** — a future scaffold revision adds a new template or updates an existing one. Same defense — surface as "different content" and ask.
- **Partial commit failure** — three templates land, the fourth fails or hangs. Defense: the partial failure recovery protocol from `references/backends.md` applies. Stop, surface state, ask user to verify before retry.
- **`.github/ISSUE_TEMPLATE/` directory doesn't exist and the repo has branch protection blocking direct-to-default commits** — the step falls back to opening a PR with the four templates. Same fallback as the rest of scaffold's provisioning.

**HITL gate**: user approves the template set before commit (covered in step 4 above).

## Stage 3 — Scaffold output and knowledge surface

Goal: write the scaffold output doc, commit it alongside the problem brief to `docs/cbk/`, and establish the knowledge surface.

**The knowledge surface: `docs/cbk/`.** All cascade planning artifacts live here. The `cbk` prefix (Context Builder Kit) keeps cascade artifacts separate from whatever docs the user writes organically.

```
docs/
└── cbk/
    ├── problem_brief.md    ← consultation output, committed by scaffold
    ├── scaffold.md          ← scaffold output (this stage)
    └── initiative.md        ← blueprint output (phase 3, later)
```

**The scaffold output doc: `docs/cbk/scaffold.md`.** Template in `references/scaffold_output_template.md`. Five sections:

1. **Cascade metadata** — profile, hierarchy levels, knowledge surface path, repo URL, project board URL, provisioned date. For Claude in future sessions.
2. **Team shape** — solo or team, size, roles, decision-maker, timezone/sync info. From discovery.
3. **Working conventions** — team identifier, branch naming, commit format, label taxonomy. From stage 2.
4. **Development preferences** — quality bar, PR/review process, testing philosophy, pace, decision recording. From discovery.
5. **Tool landscape** — connected MCPs, manual operations completed, integration status, tool comfort. From detection and provisioning.

**Present the scaffold output doc inline first**, let the user review and iterate, then commit. This is the output that blueprint reads to write standards.md and contributing.md — if it's wrong, everything downstream is wrong. Get it right here.

### Example excerpt (what one section looks like in practice)

To make the output shape concrete: here's what the **Working conventions** section looks like for a real scaffold of a Rust CLI tool. Note the specificity — branch and commit formats are stated with examples, not abstract patterns, and the team identifier is named explicitly.

**Input fragment** (user answers during discovery):
> "Solo project, weekends and weeknights, branch names should include the issue number, and I'm using Conventional Commits with engine/packs/cli scopes since I'm splitting the code into a workspace."

**Output fragment** (resulting scaffold.md excerpt):
```markdown
## Working conventions

**Team identifier**: TUI

**Branch naming**: `tui-<issue-number>-<short-description>`
Examples:
- `tui-12-verifier-trait`
- `tui-34-regex-lesson-anchors`

**Commit format**: Conventional Commits. Scopes: engine, packs, cli.

**Label taxonomy**:
- Type: bug, feature, improvement, tech-debt, documentation
- Area: area:engine, area:packs, area:cli
```

The full template with worked examples for every section lives in `references/scaffold_output_template.md`. Load it when drafting; the example above just shows what one section feels like.

**Commit order** — try in this order:
1. **GitHub MCP**: create `docs/cbk/` directory, commit `problem_brief.md` and `scaffold.md` to it.
2. **Fallback**: produce both as downloadable artifacts. Tell the user where each goes and that blueprint will need them.

**HITL gate (final)**: user approves the scaffold output doc and confirms the problem brief is committed. Scaffold marks itself complete.

## The bootstrap checklist — session artifact

Alongside the scaffold output doc (which is persistent), scaffold produces a **bootstrap checklist** for the current session only. It tells the user what was done, what they still need to do manually, and how to verify integrations.

Three sections: completed items (with links), manual instructions (with URLs and expected outcomes), verification matrix (with test actions). Template in `references/bootstrap_checklist_template.md`.

Present inline + downloadable artifact. Do not commit to repo (session-scoped).

## HITL gates summary

Six gates in the full flow. In light mode, they collapse to 1–2 — that's a legitimate user choice. The markdown-only confirmation gate (in Profile selection) and the issue-templates approval gate (Stage 2.5) cannot collapse even in light mode.

1. **Profile selection + detection** — user confirms profile, acknowledges three-level constraint if GitHub-only, runs the markdown-only confirmation gate if Profile C is being chosen
2. **Discovery** — user confirms team shape and working preferences
3. **Account/audit** — user confirms account state and audit findings
4. **Provisioning** — user confirms what was created, walks verification matrix
5. **Cascade issue templates** — user approves the four templates (or the subset that needs committing after the idempotency check) before they land in `.github/ISSUE_TEMPLATE/`
6. **Scaffold output** — user approves `docs/cbk/scaffold.md` and confirms problem brief committed

## Handoff contract to blueprint

When scaffold is complete, blueprint inherits:

- **A working repository** at a known URL
- **A label taxonomy** consistent across the workspace
- **A verified set of integrations** with known states
- **The four cascade issue templates** at `.github/ISSUE_TEMPLATE/cascade-{workstream,framing,rough-in,meta}.md` — blueprint reads `cascade-workstream.md` from the repo when constructing parent Issue bodies, framing reads `cascade-framing.md` and `cascade-meta.md`, rough-in reads `cascade-rough-in.md`. Repo files are the source of truth; the bundled copies in each skill are fallbacks for brownfield repos that lack them.
- **The scaffold output doc** at `docs/cbk/scaffold.md` — containing team shape, working conventions, development preferences, and cascade metadata
- **The problem brief** at `docs/cbk/problem_brief.md`
- **The knowledge surface** at `docs/cbk/` — where blueprint will commit `blueprint.md`

**What blueprint does with this**: reads `scaffold.md` and the problem brief, then produces standards.md, contributing.md, CLAUDE.md, architecture.md (with stack decisions), and `blueprint.md`. The working conventions and development preferences in `scaffold.md` are the raw material for those docs. The cascade issue templates are read from disk when blueprint creates workstream parent Issues.

**What scaffold must not pass to blueprint**: technology stack decisions, AI agent configuration, planning artifacts (workstreams, framings, issues beyond the cascade templates themselves), code beyond `.github/` templates and a starter README.

Blueprint reads scaffold's outputs at session start via GitHub MCP, or the user uploads them.

## Failure modes to defend against

- **Integration half-setup** — most common failure. Defense: verification matrix forces real test actions.
- **Inconsistent naming** — labels don't match branch naming convention. Defense: working conventions captured in one place in `scaffold.md`, derived from the same conversation.
- **Over-provisioning** — elaborate setup before needs are understood. Default is minimal; accommodate the user if they have clear reasons for more.
- **Premature AI configuration** — CLAUDE.md, AGENTS.md, `.claude/` belong in blueprint, not scaffold. Stack decisions don't exist yet.
- **Skipping discovery** — scaffold without discovery produces a scaffold output doc with empty preferences, forcing blueprint to re-derive everything. Even at light mode, capture team shape and quality bar.
- **Skipping the three-level constraint** — surface before profile commitment.
- **Committing before presenting** — the MCP commit is one tool call away. Always present inline and get approval first.
- **Skipping the issue templates step** — without `.github/ISSUE_TEMPLATE/cascade-*.md` in the repo, downstream skills fall back to bundle-internal templates and lose the inherit-from-disk discipline. Defense: Stage 2.5 is mandatory in every rigor mode; light mode collapses other gates but not this one.
- **Overwriting hand-curated existing templates** — if a user's repo has a hand-curated `feature_request.md` or `bug_report.md`, the cascade templates land alongside (not on top of) them. Defense: idempotency check distinguishes "already cascade-provisioned" from "exists but is not a cascade template" and never touches the latter.

## Reference files

- `references/profile_selection.md` — conversation script for picking between profiles, three-level constraint phrasing, markdown-only confirmation gate language
- `references/github_only_profile.md` — fully fleshed out provisioning for GitHub-only profile
- `references/opinionated_profile.md` — *stub* for Linear+GitHub profile
- `references/brownfield_audit.md` — workspace audit for users with existing repos/workspaces
- `references/scaffold_output_template.md` — template and worked example for `docs/cbk/scaffold.md`
- `references/bootstrap_checklist_template.md` — template for the session checklist
- `references/manual_steps.md` — canonical list of always-manual operations
- `references/issue-templates/` — the four cascade GitHub issue templates that Stage 2.5 commits to `.github/ISSUE_TEMPLATE/`. Each is a standalone markdown file with YAML frontmatter (`cascade-workstream.md`, `cascade-framing.md`, `cascade-rough-in.md`, `cascade-meta.md`). Source of truth for the cascade Issue body shapes — downstream skills read the committed copies from the repo, not the bundled copies here.
- `references/test_cases.md` — three realistic test prompts (solo greenfield / solo brownfield / team opinionated) with success criteria for verifying the skill still works after revisions

