# backends.md — Backend Interface Specification

The five planning skills (consultation, scaffold, blueprint, framing, rough-in) and the Claude Code finish skill all interact with three logical systems: a **planning backend** (where the cascade hierarchy lives as queryable, statused work items), a **knowledge backend** (where long-form specs and the cascade event log live), and a **code backend** (where the repo, branches, and PRs live). This spec defines the operations skills can call against those backends so skills can be written tool-agnostically and concrete backends can be swapped via configuration.

The cascade ships with three backend profiles in v1:
- **github-only** — GitHub Projects v2 board + GitHub Issues with sub-issues + markdown in `docs/cbk/`. **Validated primary path.**
- **opinionated** — Linear (planning) + GitHub (code). **Validated** — exercised end-to-end via Linear MCP (`mcp__linear__save_issue` with `parentId`, label scheme, atomic transition with markdown commits).
- **markdown-only** — markdown in `docs/cbk/` and nothing else. No planning backend. The cascade event log IS the entire artifact set. **Use this when**: the user explicitly doesn't want a kanban/board surface, the cascade is being run as design documentation rather than active work tracking, the audience for the cascade output (e.g., a manager, a PM, a stakeholder) won't be living in GitHub Issues day-to-day, or the project is small enough that markdown alone is sufficient.

Future profiles (Jira, Confluence, GitLab, Plane, Obsidian) plug into the same interface.

## The cascade hierarchy and what each phase produces

The cascade has six phases. Three of them produce planning-backend objects; the others produce knowledge-backend artifacts only.

| Phase | Knowledge output | Planning output |
|---|---|---|
| Consultation | `docs/cbk/problem_brief.md` | nothing |
| Scaffold | `docs/cbk/scaffold.md` | repo + Project board (one-time, manual setup) |
| Blueprint | `docs/cbk/blueprint.md` (incl. workstreams table) | one **parent Issue** per workstream (no Milestones — see below) |
| Framing | `docs/cbk/frame-NN.md` (cascade event file, numbered) | one **sub-issue** per framing capability, parented under the workstream's parent Issue via `sub_issue_write` |
| Rough-in | (annotated frame-NN.md or per-issue spec) | one **sub-sub-issue** per rough issue, parented under the framing sub-issue via `sub_issue_write` |
| Finish (Claude Code) | code commits | PR closes the sub-issue |

**Three Issue levels on the planning backend, one Issue tree per workstream**: workstream parent Issue (created by blueprint, the long-lived container), framing capability sub-issue (created by framing, parented under the workstream Issue via GitHub's native sub-issue API), rough-in sub-sub-issue (created by rough-in, parented under the framing sub-issue). The cascade does NOT use GitHub Milestones — the github MCP exposes Milestone *assignment* but not Milestone *creation*, so the cascade builds hierarchy via sub-issues instead. Milestones are GA'd 2025 sub-issue native and fully MCP-supported via `sub_issue_write`.

**The cascade markdown is the source of truth** for the design history. The planning backend is the live work-tracking layer alongside it. Both must stay consistent — see "Atomic transitions" below.

## Naming conventions (cascade-set, grep-able)

| Layer | Title pattern | Length budget for body | Example |
|---|---|---|---|
| Workstream parent Issue | `[<workstream-slug>] <name>` | ≤50 chars after prefix | `[regex-pack] Regex pack` |
| Framing Issue | `[<workstream-slug>:F<#>] <capability>` | ≤50 chars after prefix | `[regex-pack:F1] Verify one regex lesson end-to-end` |
| Rough-in sub-issue | `[<workstream-slug>:F<#>:R<#>] <intent>` | ≤50 chars after prefix | `[regex-pack:F1:R1] Define Verifier trait` |

The bracketed prefix is searchable on flat lists, survives GitHub UI title truncation, and lets anyone reading the board see the hierarchy at a glance without expanding the parent-child tree.

## Lifecycle stages and kanban mapping

The cascade uses **one Projects v2 board per repo with one Status field and swimlanes grouped by parent Issue**. The board's swimlane-by-parent view gives a "full chain for this workstream" layout that maps to how humans actually work a cascade: you sit down on a workstream, not on all workstreams at once.

**Status field — seven values, ordered left-to-right**:

| Stage | Set when | Applies to |
|---|---|---|
| Triage | Blueprint creates the parent Issue, no framing yet | parent Issues only |
| Refinement | Framing creates the sub-issue | work units only |
| Ready | Rough-in produces sub-sub-issues; ready to pick up | work units only |
| In Progress | Work starts on a work unit (Claude Code or human pickup) OR any descendant is in flight (parents, via sub-issue progress rollup) | both |
| In Review | PR opens against this Issue (closes #N) | work units only — parents never visit this column |
| Done | PR merges and Issue closes (work units) OR every descendant is Done (parents, via sub-issue progress rollup) | both |
| Archived | Re-framing supersedes this Issue, closes with `state_reason: not_planned` + `superseded` label | both |

**Semantic invariant**: workstream parent Issues only occupy four of the seven states (Triage, In Progress, Done, Archived). The other three (Refinement, Ready, In Review) are meaningful only for work units. **This invariant is maintained by the state machine itself, not by a second Status field** — no automation rule transitions a parent into Refinement, Ready, or In Review because parents have no PRs and don't get picked up by humans, so no event ever triggers those transitions.

**Why not two Status fields or two boards**: Projects v2 only surfaces one Status field in the kanban view, and two boards fragments work tracking across two human check-in surfaces. The one-board-one-field model gives you a single place to look and trusts automation + semantics to keep parents and work units in their respective subsets of columns.

**Grouping by parent Issue**: the board's swimlane grouping is set to "parent issue" in the board settings. This creates one lane per workstream parent, with the parent row at the top of its lane and every descendant visible beneath it in whatever state it's in. Anyone reading the board sees the full chain for each workstream without expanding a tree.

**The sub-issue progress field is the load-bearing primitive for parent-state rollup.** GitHub Projects v2 added native sub-issue progress tracking as part of the sub-issue GA (2025) — it auto-counts open vs. closed sub-issues per parent and exposes this as a queryable field. The two parent state automations are:

- **Parent → In Progress** when the sub-issue progress field shows any open descendant (`subIssueProgress.completed < subIssueProgress.total`)
- **Parent → Done** when the sub-issue progress field shows 100% closed (`subIssueProgress.completed == subIssueProgress.total && total > 0`)

The cascade only needs to set the parent Status explicitly at two moments: **Triage** at creation, and **Archived** during workstream-abandonment supersedes. The In Progress and Done transitions are board-automation-driven via the progress field, not cascade-driven.

**Work unit automations are standard**:
- Work unit → In Review when a PR references it (`closes #N`)
- Work unit → Done when closed via merged PR

**Entry-state assignment for newly-created sub-issues**: when framing creates a framing capability sub-issue or rough-in creates a rough-in sub-sub-issue, the entry state depends on whether the sub-issue has unmet dependencies. The rule:

- **No unmet dependencies** → **Ready**. The cascade event (framing's or rough-in's HITL-approved commit) IS the triage pass, so putting the sub-issue into Triage would be a redundant second triage. Ready means "fully specified, unblocked, someone can pick it up."
- **Unmet dependencies (open blocking issues, unresolved meta-issues, prior F/R sub-issues still open)** → **Refinement**. Refinement here means "waiting on something else to land" — the sub-issue exists and is approved, but it can't be started yet. When the blocking dependencies all close, automation or a user should move it to Ready.
- **Work picked up by `/finish` or a human** → **In Progress** (via `/finish`'s first-action transition, or manual move). `/finish` explicitly moves Ready → In Progress as the very first thing it does, before reading the issue body or running plan mode. This announces work-in-progress to anyone else looking at the board and prevents accidental double-pickup.

The canonical lifecycle for a rough-in sub-sub-issue: **Refinement (while deps open) → Ready (when unblocked) → In Progress (when `/finish` picks up) → In Review (when PR opens) → Done (when PR merges)**.

Workstream parent Issues created by blueprint enter as **Triage** (no framing yet). Framing capability sub-issues created by framing enter as **Ready** if no prior F-sub-issue is open and **Refinement** otherwise. Meta-issues created by framing enter as **Ready** (meta-issues gate milestone starts but are not themselves blocked on other cascade artifacts at creation time).

**Board-automation gap (as of current cascade version)**: the MCP surface for setting Projects v2 Status field values directly from cascade skills is limited. In practice, skills committing new sub-issues may not be able to set the entry Status field programmatically as part of the atomic transition, which means the user or a board-level automation rule has to set it after creation. Skills should document this gap in their planning-backend-commit references and recommend that users either (a) configure a board automation rule that sets Status based on label + dependency state, or (b) manually set Status on newly-created sub-issues after each cascade commit. The long-term fix is either improved MCP tooling or a richer board automation rule set — both are deferred to a future cascade revision pass.

**Cascade-depth labels** (`cascade-depth:rough`, `cascade-depth:framed`, `cascade-depth:roughed-in`) are created for filtering, not swimlane grouping. *"Show me all roughed-in work across workstreams"* or *"show me all un-framed workstream parents"* become label-filter queries rather than separate views.

## Atomic transitions

Every cascade phase that produces both knowledge-backend AND planning-backend artifacts must perform the transition **atomically** — either both succeed or neither does, with rollback on failure.

**Order of operations** (the rollback discipline):
1. Create planning-backend objects (Milestones, Issues, sub-issues), capturing every created object's id
2. Commit knowledge-backend artifacts (markdown to `docs/cbk/`)
3. If knowledge commit fails: delete every planning-backend object captured in step 1
4. If any planning-backend operation fails midway: delete everything created up to that point and abort cleanly

The cascade never leaves the system in a half-done state (e.g., markdown committed but Issues missing, or Issues created but markdown commit failed). Skills must implement the transition as a single logical operation with explicit rollback paths.

**Partial failure recovery**: the rollback discipline above describes the *intended* flow, but real MCP operations can fail or hang in ways that leave state ambiguous (a call hangs but may have succeeded server-side; a response fails but the operation completed; a network glitch makes "definitely failed" indistinguishable from "in unknown state"). When this happens, the cascade **must not retry blindly and must not auto-rollback on hang**. The right move is: stop, surface partial state explicitly to the user with every captured operation listed by status, ask the user to verify state against the actual planning backend, wait for explicit user confirmation before any further action (rollback, retry, or abort). This costs a moment of friction on every failure but is the only safe pattern given that GitHub MCP operations can fail in ways indistinguishable from success at the protocol level. Skills document the per-phase partial failure recovery in their respective `references/planning-backend-commit.md`.

## The cascade-event model

`docs/cbk/frame-NN.md` files are **events in time**, not slots for workstreams. Each framing run produces a numbered file. Re-framing a workstream creates a *new* file with the next sequence number; the prior framing's status changes from `active` to `superseded`, but the file is never overwritten. The same pattern applies to the planning backend: re-framing creates new Issues and marks the prior framing's Issues as `superseded` (closed not-planned + label), but never deletes them.

`docs/cbk/README.md` is the chronological index. The highest-numbered active framing is always "what's next" for rough-in.

This pattern means **failures and corrections never cause overwrites, only new cascade events**. The cascade is append-only at the event-log level; correction happens by adding newer events that supersede older ones.

## Pre-flight checks

Framing surfaces concerns that don't decompose cleanly into any specific milestone's rough issues but DO need tracking because they gate transitions between milestones, gate the start of rough-in, or need to land independently of the milestone sequence. The cascade tracks these as **deferred meta-issues** — a first-class artifact alongside the milestone tree, not a footnote.

Every framing's `frame-NN.md` includes a required `## Pre-flight checks` section, even if empty. Each row in the table has: issue number (the GitHub issue created during framing's planning-backend commit), one-line subject, depends-on (what has to happen before this can start), blocks (what this gates — typically a milestone start or rough-in start), and type (`gate` / `decision` / `infrastructure`).

The corresponding GitHub issues are created during framing's planning-backend commit, parented under the workstream parent Issue with the `meta` label distinguishing them from framing capability sub-issues. Rough-in's mandatory inheritance step includes verifying that any meta-issue blocking the milestone it's about to decompose has been resolved or explicitly cleared — see the framing skill's handoff contract for the obligation language. Empty meta-issue tables explicitly say "No deferred meta-issues from this framing" so rough-in knows the table was considered, not skipped.

This pattern exists because every framing inevitably surfaces concerns that don't fit cleanly into the milestone decomposition, and giving them a structured home prevents them from falling through the cracks between framing and rough-in. The taxonomy walk that produces a vocabulary commitment (which goes in Interface Commitments), the automation recommender that has to land between two milestones (which goes in deferred meta-issues), and the open question that needs a user decision before rough-in starts (also a deferred meta-issue with type `decision`) are all examples of cross-milestone artifacts that the milestone decomposition alone can't hold.

## Issue templates as workspace infrastructure

The cascade ships **four GitHub issue templates** that scaffold commits to `.github/ISSUE_TEMPLATE/` as part of its bootstrap step. These templates serve as the source of truth for cascade Issue body shapes and are read from disk by downstream skills when they construct Issues. They also surface in GitHub's web UI when humans manually create issues, so cascade-shaped and human-shaped Issues land with identical structure.

| Template | Used by | Issue type | Title format |
|---|---|---|---|
| `cascade-workstream.md` | blueprint (or human) | Workstream parent Issue | `[<slug>] <n>` |
| `cascade-framing.md` | framing (or human) | Framing capability sub-issue | `[<slug>:F<#>] <capability>` |
| `cascade-rough-in.md` | rough-in (or human, or `/finish`) | Rough-in sub-sub-issue | `[<slug>:F<#>:R<#>] <intent>` |
| `cascade-meta.md` | framing (or human) | Deferred meta-issue | `[<slug>:meta] <subject>` |

Each template has YAML frontmatter (`name`, `about`, `title`, `labels`, `assignees`) so the GitHub web UI honors them. The body of each is structured but not strangling — sections that the relevant cascade phase populates, with HTML comments explaining what each section is for, written so that both automated cascade runs and human authors can use them effectively.

**Inherit-from-disk discipline**: downstream skills (blueprint, framing, rough-in) MUST attempt to read the relevant template from `.github/ISSUE_TEMPLATE/` in the user's repo via `get_file_contents` before constructing Issue bodies. The disk copy is the source of truth. Each skill ships a bundled fallback copy at `references/issue-templates/<template-name>.md` for two specific cases:

1. **Brownfield repos** that pre-date the cascade issue templates feature and lack the disk files. The skill surfaces this gap and proposes committing the cascade templates via a Suggested foundation doc update before proceeding.
2. **Initial cold-start failures** where MCP can't reach the repo for any reason but the user has confirmed the templates exist. The fallback lets the skill proceed with the bundled copy and flag the discrepancy in its output.

If the disk copy and the bundled copy diverge (the user has hand-edited the disk template), the skill **always uses the disk copy** — the user's edits are intentional and the cascade respects them. The skill may surface the divergence in its inheritance summary as informational ("the workspace's `cascade-rough-in.md` has been edited from the cascade default — using the workspace version") so the user knows the cascade is honoring their customization.

**The rough-in template is the load-bearing one** because the resulting Issue is intended to be runnable via Claude Code's `/finish {issue_number}` slash command. Its body has six sections (Context / Implementation / Acceptance criteria / Done signal / Dependencies / PR contract), and `/finish` will anchor hardest on the Implementation section while reading the rest as supporting context. The template's HTML comment block explicitly notes that section heading names must stay as written so `/finish` can identify them by name. Other sections (prose, links, code snippets) can be edited freely.

**Why issue templates are workspace infrastructure rather than per-skill artifacts**: putting the templates on disk in the standard GitHub location means (a) a human reading the repo can see what a cascade Issue looks like without unpacking any skill bundle, (b) the GitHub web UI offers them for manual issue creation, (c) board automation rules can be configured against the cascade-depth labels declared in the YAML frontmatter, (d) future cascade revisions can update the templates in one place and the next cascade run picks up the new format automatically, and (e) skill bundles stay smaller because they don't need to ship template content — they reference disk files instead.

## Configuration

Each project's backend selection lives in `.cascade/backends.toml` at the repo root, committed alongside the AI agent config that blueprint produces. Skills read this file to know which concrete tool to call.

```toml
# Profile: github-only (validated primary path)
[planning]
backend = "github"
project_number = 4              # the Projects v2 board number
repo = "<your-org>/<your-repo>"
auto_status_via_board_rules = true   # cascade does not set Status field directly

[knowledge]
backend = "markdown"
docs_path = "docs/cbk/"

[code]
backend = "github"
repo = "<your-org>/<your-repo>"
default_branch = "main"
```

```toml
# Profile: opinionated (partially validated — Linear operations not fully validated)
[planning]
backend = "linear"
team_id = "<TEAM_ID>"
workspace_url = "https://linear.app/<your-workspace>"

[knowledge]
backend = "notion"
hub_page_id = "abc123..."

[code]
backend = "github"
repo = "<your-org>/<your-repo>"
default_branch = "main"
```

```toml
# Profile: markdown-only
[planning]
backend = "none"

[knowledge]
backend = "markdown"
docs_path = "docs/cbk/"

[code]
backend = "github"
repo = "<your-org>/<your-repo>"
default_branch = "main"
```

In markdown-only mode, all `planning.*` operations become no-ops. The cascade still produces every markdown artifact it would produce in github-only mode (the workstreams table in `blueprint.md`, the framings in `frame-NN.md`, etc.) and uses the same naming conventions inside the markdown (`[<workstream-slug>:F<#>]` etc.) so the hierarchy is grep-able even without an Issue tree to render it. Setup steps that would normally land in a GitHub handoff issue stay in `blueprint.md` as a § Manual setup section instead. The atomic transition collapses to a single half (just the markdown commit) — there is no planning-backend half to roll back.

## The interface — operations

Skill prompts call these operations by their abstract name. Tool names appear only in user-facing status strings ("Creating your GitHub Milestone…"), never in operational logic.

```
planning.create_workstream(slug, description, metadata) → {id, url}
  # Creates a parent Issue (github-only) or Project (opinionated)
planning.create_capability(workstream_id, slug, capability, body, metadata) → {id, url}
  # Creates a sub-issue parented under the workstream Issue (github-only) or Linear Milestone (opinionated)
planning.create_work_unit(capability_id, slug, intent, body, metadata) → {id, url}
  # Creates a rough-in sub-sub-issue parented under the framing sub-issue (github-only) or Linear Issue (opinionated)
planning.update_node(node_id, fields) → {id, url}
planning.link_nodes(parent_id, child_id, relation) → ok
  # relation: "parent" | "blocks" | "blocked_by" | "relates_to"
planning.query_nodes(level, filters) → [{id, title, status, url}, ...]
planning.supersede_node(node_id, replacement_node_id) → ok
  # Closes with not-planned reason + label, never deletes
planning.create_label_taxonomy(labels) → ok

knowledge.create_doc(parent_path, title, body, metadata) → {id, url_or_path}
knowledge.update_doc(doc_id, body) → {id, url_or_path}
knowledge.read_doc(doc_id) → {title, body, metadata}
knowledge.append_to_event_log(log_path, entry) → ok
  # For the chronological README.md index

code.bootstrap_repo(name, visibility, scaffold_files) → {repo_url}
code.commit_artifacts(branch, files, message) → {commit_sha}
code.atomic_transition(planning_ops, knowledge_ops) → ok | rollback
  # Implements the atomic-with-rollback discipline above
```

## Backend implementation matrix

| Operation | GitHub (github-only) | Linear (opinionated) | None (markdown-only) | Markdown (knowledge) | Notion (knowledge) |
|---|---|---|---|---|---|
| `create_workstream` | parent Issue (no parent) | Project | no-op (returns synthetic id from slug) | — | — |
| `create_capability` | sub-issue (`issue_write` + `sub_issue_write add`) | Milestone | no-op | — | — |
| `create_work_unit` | sub-sub-issue (`issue_write` + `sub_issue_write add`) | Issue | no-op | — | — |
| `supersede_node` | close `not_planned` + `superseded` label | archive + label | no-op (markdown supersede via frame-NN.md status field) | — | — |
| `query_nodes` | native (REST + GraphQL for sub-issues) | native | reads markdown event log | — | — |
| `create_label_taxonomy` | repo labels | workspace labels | no-op | — | — |
| `create_doc` | — | — | `.md` file in `docs_path` | native page |
| `update_doc` | — | — | git commit | native edit |
| `read_doc` | — | — | file read | native fetch |
| `append_to_event_log` | — | — | git commit (append-only file) | native append |
| `bootstrap_repo` | native (GH MCP) | — | — | — |
| `commit_artifacts` | native (GH MCP) | — | — | — |
| `atomic_transition` | implemented in skill code (capture ids, rollback on failure) | same | — | — |

## Brownfield handling

All operations must be idempotent or expose a `reuse_existing` mode. `create_workstream` checks for an existing Milestone with the same slug before creating. `bootstrap_repo` verifies an existing repo and only adds missing scaffold files. `create_label_taxonomy` merges with existing labels rather than replacing. Scaffold's brownfield audit calls `query_nodes` and equivalent reads against all three backends before any write.

## Failure semantics

Every operation can fail. Skills handle three failure classes distinctly:

- **Transient** (network, rate limit) — retry with backoff.
- **Permission** (auth, scope) — surface to user with the exact missing permission and a remediation step.
- **Semantic** (the backend can't represent what was asked) — surface as a known limitation, not a bug. The github-only profile has fewer semantic gaps than initially feared because GitHub's sub-issue support (GA'd 2025) gives us native parent-child trees; the remaining gap is Projects v2 board field manipulation, which is handled via board automation rules instead of cascade-direct field setting.

## What's deliberately *not* in the interface

**OAuth and account creation, billing, branch protection, SSO, workflow state customization** — always manual. Scaffold provides instructions; the interface assumes credentials already exist.

**Project board creation itself** — the github-only profile assumes the Projects v2 board exists before scaffold runs, with the four standard automation rules configured (auto-add on Issue creation, auto-close on PR merge, etc.). Scaffold provides setup instructions for the board; the cascade does not create it.

**Code execution, test running, PR review** — these belong to the Claude Code finish skill, which uses native Claude Code tools rather than this interface. The finish skill *reads* from this interface (to pull issue/milestone context) but does not *write* through it for code operations — it commits, pushes, and opens PRs via standard git and the GitHub MCP server directly.

**Cycle/sprint management** — Linear has cycles, GitHub Projects has iterations, Jira has sprints. The cascade is cycle-agnostic by design; framing capabilities are the unit of vertical slicing, not sprints. Teams that use cycles layer them on top manually after rough-in produces sub-issues.

## The skill prompt discipline rule

Skill prompts call operations by their abstract name. Tool names appear only in user-facing status strings ("Creating your GitHub Milestone…"), never in operational logic. This is enforceable: the skill review checklist includes "grep the prompt for `linear`, `notion`, `github`, `milestone`, `issue` — any hit outside a status string or schema definition is a bug."

When an operation has a meaningful semantic difference between backends (e.g., GitHub Projects v2 board fields cannot be set via MCP and must rely on board automation rules), the skill must surface the difference at the relevant HITL gate so the user understands what they're approving. The interface hides mechanics, not meaningful trade-offs.

## Adding a third backend

The minimum work to add a backend (e.g., Jira for planning):

1. Implement all operations against the new tool's API or MCP server
2. Fill in a column of the implementation matrix
3. Document semantic gaps alongside this file
4. Add a profile example to this file's Configuration section
5. Run the cascade against a throwaway project end-to-end
6. Capture every "this doesn't quite map" moment as a known limitation, not as code complexity

The interface is intentionally small so the lift is bounded. If a future backend genuinely needs an operation that doesn't exist here, that's a signal to expand the interface deliberately — not to special-case the skill prompts.

## Resolved open questions (carried forward from v1)

**Q1 — Markdown audit trail**: phase-named branches give clean review/revert but produce branch noise. Direct commits to `docs/cbk/` on main with structured commit messages are simpler. **Resolved**: direct commits to main with the atomic transition pattern. The cascade-event model (frame-NN.md numbering, append-only) gives review and revert via git history rather than branches.

**Q2 — GitHub Projects three-level constraint**: faking initiatives with labels was tempting and wrong. **Resolved**: the cascade uses GitHub's native sub-issue feature (GA'd 2025) to build a three-deep Issue tree per workstream — workstream parent Issue, framing capability sub-issue, rough-in sub-sub-issue. The github MCP exposes `sub_issue_write` natively, so this is fully MCP-supported with no `gh` CLI shell-out. The cascade does NOT use GitHub Milestones because the github MCP exposes only Milestone *assignment*, not Milestone *creation*. There is no separate "initiative" object — the Projects v2 board itself plays that role, and the `blueprint.md` markdown file plays the documentation role. This is now the validated primary path.

## Open questions deferred to future passes

1. **Opinionated-profile validation**: the Linear/Notion mapping is structurally documented but has not been validated against a real cascade run. First opinionated-profile run will surface gaps and either fill in this spec or flag them as known limitations.
2. **Cross-workstream interface commitments on the planning backend**: the Interface Commitments table in `frame-NN.md` is currently markdown-only. There's no planning-backend representation of "this Issue commits to a stable interface that another Issue depends on." Future revision may add a `relates_to` link with custom semantics or a separate label taxonomy.
3. **Sub-rough-in nesting**: GitHub sub-issues support up to 8 levels deep. The cascade currently uses two levels (framing Issue → rough-in sub-issue). A future deepening (rough-in producing nested implementation steps) is structurally supported by the planning backend but not yet by the cascade skills.
