# Planning-backend commit — creating workstream parent Issues

After blueprint produces `blueprint.md` with the workstreams table populated, blueprint must commit one **parent Issue** to the planning backend per workstream. The parent Issue is the long-lived container that framing will later attach sub-issues to via the GitHub sub-issue API. This step runs as part of blueprint's final commit, paired atomically with the markdown commit.

**Read `references/backends.md`** (the cascade meta-doc, bundled with this skill) for the underlying interface, the cascade hierarchy mapping, and the atomic transition pattern. This file is the operational implementation of `planning.create_workstream` from that interface.

## Why parent Issues, not Milestones

Earlier cascade designs used GitHub repo Milestones as the workstream container. **The github MCP does not expose Milestone creation operations** — only Milestone *assignment* via `issue_write`'s `milestone` parameter, which requires the Milestone to already exist. Creating Milestones via MCP is not possible without falling back to `gh` CLI shell-out, which is out of scope for the cascade.

GitHub sub-issues (GA'd 2025) are fully MCP-native: `sub_issue_write` adds/removes/re-parents sub-issues, `issue_read` with `get_sub_issues` queries the tree, `issue_write` creates the issues themselves. The cascade uses sub-issues for the parent-child hierarchy and skips Milestones entirely.

The result is a three-deep Issue tree per workstream:
- **Workstream parent Issue** (created by blueprint)
- **Framing capability sub-issue** (created by framing, parented under the workstream Issue)
- **Rough-in sub-sub-issue** (created by rough-in, parented under the framing sub-issue)

## What gets created

For each row in `blueprint.md` § Workstreams, blueprint creates one parent Issue:

| Field | Source | Example |
|---|---|---|
| Title | `[<workstream-slug>] <name>` | `[regex-pack] Regex pack` |
| Body | Workstream prose from `blueprint.md` (purpose, scope sketch, dependencies, links to relevant sections) | (full markdown body) |
| Labels | `cascade-depth:rough`, plus any blueprint-defined workstream labels | — |
| State | `open` | — |
| Initial board Status | **Triage** (set explicitly at creation) | — |

The slug becomes the canonical identifier for everything downstream — framing reads it from the parent Issue title to construct sub-issue names like `[regex-pack:F1] ...`, and rough-in inherits it again to construct sub-sub-issue names `[regex-pack:F1:R1] ...`. **Choose slugs deliberately**: they're permanent and visible everywhere.

**About the Triage initial Status**: workstream parent Issues live alongside work units in a single Status field with seven values, but parents only naturally occupy four of them (Triage / In Progress / Done / Archived). The other three (Refinement / Ready / In Review) never apply to parents because no automation rule transitions a parent into them — see `references/backends.md` § Lifecycle stages for the full state machine. Blueprint sets Triage explicitly at creation. The In Progress and Done transitions are handled automatically by Projects v2 board automation rules driven by the sub-issue progress field — when framing creates the first sub-issue, the parent's progress field updates and the board rule moves it to In Progress; when all descendants reach Done, the board rule moves it to Done. The cascade doesn't track rollup state directly. Archived is set explicitly by framing during a workstream-abandonment re-framing transition.

### Issue body source — inherit from disk first

Blueprint constructs each parent Issue's body from the **`cascade-workstream.md`** template. The template lives at `.github/ISSUE_TEMPLATE/cascade-workstream.md` in the user's repo (committed by scaffold during its bootstrap step) and is the source of truth for the parent Issue body shape — see `references/backends.md` § Issue templates as workspace infrastructure for the full inherit-from-disk discipline.

**Read order**:

1. **Disk first**: query `get_file_contents` for `.github/ISSUE_TEMPLATE/cascade-workstream.md` in the user's repo
2. **If found**: use the disk template, populating the four sections (Purpose / Scope sketch / Dependencies / Links) from the corresponding workstream entry in `blueprint.md § Workstreams`. The disk copy is canonical even if it differs from the bundled fallback — the user may have hand-edited it intentionally.
3. **If not found**: fall back to the bundled copy at `references/issue-templates/cascade-workstream.md` in this skill bundle. Surface the disk-miss in the inheritance summary as a brownfield gap: *"Your repo doesn't have `.github/ISSUE_TEMPLATE/cascade-workstream.md` — using the bundled fallback for now. I recommend re-running scaffold's Stage 2.5 step to commit the cascade issue templates so future runs read from disk."*
4. **If disk and bundle differ**: always use disk, mention the divergence in the inheritance summary as informational

**Population pattern**: blueprint reads the YAML frontmatter to verify the labels and title format match expectations, then fills the body sections with workstream-specific content from `blueprint.md`. Section heading names from the template are preserved verbatim — do not rename, reorder, or omit sections that the template provides. Adding additional sections after the template-provided ones is permitted if the workstream has content that doesn't fit the standard sections.

## Atomic transition pattern

The planning-backend commit and the markdown commit must be **atomic** — either both succeed or neither does. Order of operations:

1. **Capture** every operation as a planned transition
2. **Execute planning ops first**: create each parent Issue via `issue_write` create method, capturing each issue's `{number, id, url}`
3. **Execute the markdown commit**: commit `blueprint.md` and any other foundation docs via GitHub MCP
4. **On any failure during step 2**: close every parent Issue captured up to the failure point with `state_reason: not_planned` and label `transition-rollback`, abort cleanly, surface the partial-state message to the user
5. **On failure during step 3**: same rollback pattern for all captured Issues, abort, surface to user

GitHub Issues cannot be deleted via the standard API — only closed. The cascade rollback pattern uses **close + label**, not delete. The `transition-rollback` label makes failed transitions easy to find and clean up later if desired.

**Idempotency**: if a parent Issue with the target title already exists in the repo (queryable via `issue_read` or list_issues with title filter), blueprint reads it instead of creating a new one and updates its body if the content has changed. Brownfield runs of blueprint never duplicate workstream Issues.

## HITL gate update

Blueprint's existing final commit gate now mentions both halves of the transition. Lead with:

> "About to commit blueprint:
> - Markdown: `docs/cbk/blueprint.md` (and any updated foundation docs)
> - Planning backend: N parent Issues (one per workstream), each labeled `cascade-depth:rough`:
>   - `[<slug-1>] <name 1>`
>   - `[<slug-2>] <name 2>`
>   - `[<slug-N>] <name N>`
>
> These commit atomically — either both land or neither does. The parent Issues become the long-lived containers that framing will attach sub-issues to via GitHub's sub-issue API. Each parent Issue's body holds the workstream prose from blueprint.md.
>
> Approve the full transition?"

## What blueprint does NOT create on the planning backend

- **Sub-issues** — those belong to framing. Blueprint creates parent Issues; framing creates the first level of children against them.
- **Sub-sub-issues** — those belong to rough-in.
- **Milestones** — not used by the cascade at all. The github MCP doesn't expose Milestone creation, and the sub-issue tree provides the hierarchy we need.
- **Project board (Projects v2)** — that's a one-time scaffold-phase / manual setup. Blueprint assumes the board already exists with its automation rules configured. If the board doesn't exist, blueprint surfaces this as a setup gap.
- **Labels and label taxonomy** — blueprint may create the cascade-depth label set as part of label taxonomy creation, but this is a separate operation from parent Issue creation.

## Profile-aware behavior

**github-only profile** (default and validated): parent Issues are created via `issue_write`, the sub-issue tree is built via `sub_issue_write` in subsequent phases. Atomic with the markdown commit.

**opinionated profile** (Linear, kara-validated): per `backends.md`, Linear's hierarchy is Project → Milestone → Issue. Workstreams map to Linear Projects, framing capabilities to Linear Milestones, rough-in items to Linear Issues. The sub-issue collapse is github-only-specific.

**markdown-only profile**: this entire step is **skipped**. No parent Issues get created on the planning backend because there is no planning backend. The atomic transition collapses to a single half — just the markdown commit (`blueprint.md` + foundation docs). There is no rollback to perform on the planning side because no planning ops ran. The cascade still uses the same naming conventions inside `blueprint.md` § Workstreams (`[<workstream-slug>] <name>` headings, slug-derivation rule, etc.) so the hierarchy is grep-able and the markdown-only output remains structurally identical to the github-only output minus the GitHub Issue tree.

In markdown-only mode, **the handoff content stays in `blueprint.md` itself** as a § Manual setup section instead of being hoisted into a GitHub handoff issue. Same content shape (the rough setup layout), same trip-wire discipline for cleanup tracking, just lives in the markdown file rather than as a separate GitHub artifact. The user reads it from `blueprint.md` and works through the steps; updates to setup state go in commits to `blueprint.md` (or, after framing runs, in commits to `README.md` index or the relevant `frame-NN.md`), not in a separate handoff issue.

The HITL gate in markdown-only mode mentions only the markdown commit half:

> "About to commit blueprint:
> - Markdown: `docs/cbk/blueprint.md` (and any updated foundation docs)
> - Planning backend: none (markdown-only profile)
>
> No planning operations to run, no Issues to create, no atomic transition needed beyond the markdown commit itself.
>
> Approve?"

## Partial failure recovery

The atomic transition pattern above describes the *intended* flow — capture, execute, rollback on failure. In practice, failures during multi-step transitions can leave the system in states the rollback discipline doesn't fully cover, especially when MCP calls hang, return ambiguous responses, or fail mid-network. **The skill must treat partial failure as a first-class case, not as something to retry blindly.**

**The right move on any partial failure**: stop, do not retry, surface state to the user, ask the user to verify state before proceeding.

Concretely, when a planning operation fails or hangs:

1. **Stop immediately** — do not retry the failing operation, do not proceed to the next operation in the captured list, do not attempt rollback automatically
2. **Surface the partial state explicitly** — name every operation that was captured, every operation that successfully completed (with its returned id/url), the operation that failed (with the error or "no response — assumed hung"), and every operation that was queued but never attempted
3. **Ask the user to verify state** — *"I executed N operations successfully, the next one failed/hung, and M operations were queued behind it. Before I do anything else, please verify the state of the operations I think succeeded — they may or may not actually be in the state I have recorded. Once you've verified, tell me one of: (a) state matches my recording, proceed with rollback of the successful operations and abort, (b) state matches my recording, proceed with retry of the failed operation, (c) state does not match my recording — here's what's actually there."*
4. **Wait for explicit user confirmation** before any further action — rollback, retry, or abort. Do not assume the user wants any specific path.

**Why no automatic retry**: a failed planning operation might have actually succeeded server-side and the failure was in the response path. Retrying would create a duplicate. The cascade's idempotency checks defend against many duplication cases but not all of them, especially for operations where the server-assigned id is the only way to deduplicate.

**Why no automatic rollback on hang vs. fail**: a hung operation might still be in flight server-side and may yet complete. Rolling back the predecessors would leave the system in a worse state than the partial commit. The user's verification step distinguishes "definitely failed" from "in unknown state" before any rollback action.

**The cascade is honest about partial state**, never assumes its model of server state is correct after a failure, and always defers to the user for the next move. This costs a moment of friction on every failure but is the only safe pattern given that GitHub MCP operations can fail in ways that are indistinguishable from success at the protocol level.

## Failure modes specific to this step

- **Slug collisions across workstreams** — two different workstream names that slugify to the same string. Blueprint catches this before the transition by checking for unique slugs in the workstreams table. If a collision exists, blueprint refuses to commit and asks the user to disambiguate.
- **Slug collisions with existing parent Issues** — a workstream slug matches an existing parent Issue in the repo from prior cascade work. Blueprint surfaces the collision and asks whether to (a) reuse the existing parent Issue (brownfield path), (b) rename the workstream to disambiguate, or (c) abort.
- **Partial-state on transition failure** — covered by the close-with-rollback-label discipline above. If the rollback itself fails, blueprint surfaces the inconsistent state explicitly with a manual recovery checklist.
- **Project board missing or misconfigured** — blueprint detects this before the transition by querying the board via MCP. The check verifies: the board exists, it has **one Status field with seven values** (Triage / Refinement / Ready / In Progress / In Review / Done / Archived), the swimlane grouping is set to "parent issue", the parent-rollup automation rules driven by the sub-issue progress field are in place, and standard work-unit automations (PR open → In Review, PR merged → Done) are configured. If any piece is missing, blueprint pauses and surfaces the specific gap with setup instructions. Does not silently proceed.
- **Projects v2 PAT scope fallback** — the board-detection step assumes a Personal Access Token (PAT) with the `read:project` scope. Scaffold's bootstrap doesn't always grant this scope, especially for fine-grained PATs which require explicit per-permission opt-in. If the board query returns a 401/403 specifically because of missing project scope (distinct from "board doesn't exist"), blueprint surfaces this as a **scope gap**, not a missing-board gap, and offers two recovery paths: (a) update the PAT scope and retry the detection, or (b) skip board detection and proceed under the user's verbal assurance that the board exists with the right automation rules. Path (b) is a deliberate downgrade to honor-system mode and the user must explicitly accept it.
- **Parent state Triage not set on creation** — blueprint creates the parent Issue but the board's Status field stays empty (or gets the default "Backlog" set by board automation rules). Defense: blueprint explicitly sets Status = Triage as part of the creation operation. If the Projects v2 field write fails (e.g., because of the PAT scope gap), surface it to the user — don't silently leave the parent without a Status, because the rollup automation depends on it being initialized.
- **Sub-issue progress field not configured on the board** — the Projects v2 board exists but doesn't have the sub-issue progress field added as a column or used in automation rules. Without it, parent state never auto-rolls up from descendants and the parent Issue stays in Triage forever. Defense: blueprint's board-state check (the same one that verifies the four standard automation rules) must also verify the sub-issue progress field is configured. If missing, surface as a setup gap with instructions, same pattern as the missing-board case.
- **Idempotency violations on brownfield** — a re-run of blueprint produces a duplicate parent Issue instead of updating the existing one. Defense: every workstream's title is checked against existing open Issues with the same title before the create call; existing Issues get a body update, not a create.
- **Title drift in cross-referenced issues** — a parent Issue's body references another Issue by title in prose (e.g., in the Dependencies section), and later the referenced Issue's title gets updated (e.g., slug prefix added during a cleanup pass). The issue number reference still resolves correctly, but the surrounding prose is now stale relative to the actual title. Defense: when blueprint writes parent Issue bodies that reference other issues, **use issue numbers only** (`#23`) and avoid reproducing the referenced issue's title in prose. GitHub renders the current title dynamically via hover cards, so number-only references stay fresh without needing body edits. If a body accidentally includes a title that later drifts, the recovery is a **comment on the issue** (not a body edit) noting the drift — body edits rewrite history in ways that can confuse downstream skills.
- **Defense-in-depth: `create_or_update_file` content-parameter ambiguity** — the GitHub MCP's `create_or_update_file` tool takes a `content` parameter that expects the literal file content string. If a path string is passed instead (e.g., `/home/claude/recovery/blueprint.md`), the tool commits the path string as the file's content (a silent, hard-to-notice corruption that only surfaces when someone reads the file). **Primary defense should be at the harness/prompt-config layer, not here** — this note is defense-in-depth. The cascade's secondary defense: prefer `push_files` over `create_or_update_file` for content-as-string operations. `push_files` uses an array of `{path, content}` objects where the path/content separation is structurally obvious and the mistake is harder to make. The cascade standard is `push_files` for all single-file and multi-file commits; `create_or_update_file` is allowed only when SHA-based update semantics are specifically needed (which blueprint's step does not — the atomic transition uses `push_files` for the markdown half).

## What this step enables

After this step runs successfully, framing has everything it needs to operate against any one workstream:

- The parent Issue exists on the planning backend with the workstream prose as its body
- The slug is canonical and visible in the title
- The markdown source-of-truth (`blueprint.md`) is committed and traceable
- Framing inherits the slug from the parent Issue title and uses `sub_issue_write` to attach framing capability sub-issues to it

Framing reads the parent Issue (via `issue_read`) and the corresponding row in `blueprint.md` § Workstreams as its inheritance step.
