# Planning-backend commit — creating framing capability sub-issues

After framing produces `frame-NN.md` with the milestones (capabilities) section populated, framing must commit one **sub-issue** to the planning backend per framing capability, all parented under the workstream's parent Issue (which already exists from blueprint). This step runs as part of framing's final commit, paired atomically with the markdown commit.

**Read `references/backends.md`** (the cascade meta-doc, bundled with this skill) for the underlying interface, the cascade hierarchy mapping, and the atomic transition pattern. This file is the operational implementation of `planning.create_capability` from that interface.

## Why sub-issues, not Milestones

The github MCP doesn't expose Milestone creation operations (see blueprint's planning-backend-commit.md for the full reasoning). Instead, the cascade uses GitHub's native sub-issue feature (GA'd 2025) to build the parent-child hierarchy. The github MCP provides `sub_issue_write` for adding/removing/re-parenting sub-issues, fully MCP-native.

The result for framing: each framing capability becomes a sub-issue parented under the workstream's parent Issue. Rough-in later creates sub-sub-issues parented under each framing sub-issue.

## What gets created

For each capability in `frame-NN.md` § Milestones, framing creates one sub-issue:

| Field | Source | Example |
|---|---|---|
| Title | `[<workstream-slug>:F<#>] <capability>` (slug inherited from the parent Issue title set by blueprint, F-number from the framing capability sequence) | `[regex-pack:F1] Verify one regex lesson end-to-end` |
| Body | Capability prose from `frame-NN.md` (capability statement, depends-on, rough issues list, acceptance signal) | (full markdown body) |
| Parent | Workstream parent Issue created by blueprint | `[regex-pack] Regex pack` |
| Labels | `cascade-depth:framed`, plus any inherited from the workstream | — |
| Initial column | Refinement (set by board automation rules — cascade does not directly set Status fields) | — |

The slug is inherited from the parent Issue title — framing reads the existing parent Issue (via `issue_read`) to get the canonical slug, never re-derives it from the workstream name. This ensures framing sub-issue prefixes match what blueprint committed.

### Issue body source — inherit from disk first

Framing constructs each sub-issue's body from one of two templates depending on the issue type: **`cascade-framing.md`** for capability sub-issues, **`cascade-meta.md`** for deferred meta-issues. Both templates live at `.github/ISSUE_TEMPLATE/` in the user's repo (committed by scaffold during its bootstrap step) and are the source of truth for their respective body shapes — see `references/backends.md` § Issue templates as workspace infrastructure for the full inherit-from-disk discipline.

**Read order** (applies to both templates):

1. **Disk first**: query `get_file_contents` for `.github/ISSUE_TEMPLATE/cascade-framing.md` (and `cascade-meta.md` if any meta-issues are being created in this transition) in the user's repo
2. **If found**: use the disk template, populating sections from the corresponding entries in `frame-NN.md`. The disk copy is canonical even if it differs from the bundled fallback.
3. **If not found**: fall back to the bundled copy at `references/issue-templates/<template-name>.md` in this skill bundle. Surface the disk-miss in the inheritance summary as a brownfield gap and recommend re-running scaffold's Stage 2.5 step.
4. **If disk and bundle differ**: always use disk, mention divergence as informational

**Population pattern for capability sub-issues** (`cascade-framing.md`): five sections to populate from the milestone's row in `frame-NN.md` § Milestones — Capability statement, Rough issues, Acceptance signal, Dependencies, Interface commitments. Plus a Links section that cites the relevant frame-NN.md section verbatim.

**Population pattern for meta-issues** (`cascade-meta.md`): five sections to populate from the row in `frame-NN.md` § Deferred meta-issues — Type (gate/decision/infrastructure), Subject, Depends on, Blocks, Resolution criteria. Plus a Links section that cites `frame-NN.md § Deferred meta-issues`. The Blocks section is load-bearing for rough-in's pre-flight check, so populate it precisely — rough-in pattern-matches against `M_n start` strings here.

Section heading names from both templates are preserved verbatim — do not rename, reorder, or omit sections that the templates provide. Adding additional sections after the template-provided ones is permitted if the capability or meta-issue has content that doesn't fit the standard sections.

## Atomic transition pattern (two-step per sub-issue)

Framing's planning-backend commit uses GitHub's two-step sub-issue creation:
1. Create the sub-issue via `issue_write` (returns issue number + id)
2. Link it to the parent via `sub_issue_write` with method `add` and the parent's issue_number + the new sub-issue's id

Both calls must succeed for the sub-issue to count as created. If step 1 succeeds but step 2 fails, the sub-issue exists as an orphan — framing's rollback must include orphan-cleanup.

Full transition order:
1. **Capture** the planned transition: `frame-NN.md` content + `README.md` index append + N (issue_write + sub_issue_write) pairs
2. **Execute planning ops first**: for each capability, run `issue_write` to create + `sub_issue_write` to link parent. Capture each sub-issue's `{number, id, url}` as it lands successfully.
3. **Execute the markdown commits**: commit `frame-NN.md` and the `README.md` index update via GitHub MCP
4. **On any failure during step 2**: close every sub-issue captured up to the failure point with `state_reason: not_planned` and label `transition-rollback`. Includes orphan cleanup if step 1 succeeded but step 2 failed for the failing sub-issue. Abort cleanly.
5. **On failure during step 3**: same rollback for all captured sub-issues, abort.

GitHub Issues cannot be deleted via the standard API — only closed. The cascade rollback uses **close + label**, not delete.

**Re-framing detection (cascade-event model)**: if this framing supersedes a prior framing of the same workstream, the prior framing's sub-issues must be marked superseded as part of the same atomic transition. Order: (1) create new sub-issues with parent link, (2) supersede prior sub-issues via `issue_write` update method (close `not_planned` + `superseded` label), (3) commit the new `frame-NN.md` and update the prior `frame-MM.md`'s status field from `active` to `superseded`, (4) append both events to `README.md` index. All atomic, all rolled back together on any failure.

**Parent state on re-framing**: re-framings do NOT change the workstream parent Issue's Status field — the parent stays in In Progress (or whatever the board automation rolled it to) because re-framing creates new active sub-issues that keep the workstream alive. The exception is when re-framing **abandons** the workstream entirely (no new sub-issues, just supersedes the old ones to kill the project). In that case framing explicitly sets the parent Status to **Archived** as part of the supersede transition. Framing surfaces this distinction at the HITL gate: *"This re-framing creates N new sub-issues [normal supersede]"* vs. *"This re-framing abandons the workstream — no new sub-issues, parent will be set to Archived"*.

## HITL gate update

Framing's existing final commit gate now mentions both halves of the transition. Lead with:

> "About to commit framing for `<workstream-slug>`:
> - Markdown: `docs/cbk/frame-NN.md` + append to `docs/cbk/README.md` index
> - Planning backend: N sub-issues (one per capability), all parented under the workstream's parent Issue:
>   - `[<slug>:F1] <capability 1>`
>   - `[<slug>:F2] <capability 2>`
>   - `[<slug>:F<N>] <capability N>`
>
> These commit atomically — either both land or neither does. Each sub-issue is created via `issue_write` then linked to the parent via `sub_issue_write`. The sub-issues become the work units that rough-in will attach sub-sub-issues to. Each sub-issue's body holds the capability prose from frame-NN.md.
>
> Approve the full transition?"

For re-framings, the gate also lists the prior sub-issues that will be superseded as part of the same operation.

## What framing does NOT create on the planning backend

- **The workstream parent Issue** — that's blueprint's job. Framing reads the existing parent Issue and parents its new sub-issues under it. If the parent Issue doesn't exist, framing surfaces the gap and asks whether to (a) loop back to blueprint to create it, or (b) abort.
- **Sub-sub-issues** — those belong to rough-in. Framing creates the framing-capability sub-issues; rough-in decomposes each into ready-to-implement sub-sub-issues.
- **Milestones** — not used by the cascade.

## Profile-aware behavior

**github-only profile** (default and validated): sub-issues created via the two-step `issue_write` + `sub_issue_write` pattern.

**opinionated profile (Linear+GitHub, validated)**: per `backends.md`, framing capabilities map to Linear Milestones (Linear has a Milestone primitive that GitHub doesn't). Created via Linear MCP.

**markdown-only profile**: this entire step is **skipped**. No sub-issues get created on the planning backend because there is no planning backend. The atomic transition collapses to a single half — just the markdown commits (`frame-NN.md` + `README.md` index update). There is no parent Issue to query (because blueprint didn't create one in markdown-only mode either), so the inheritance step reads the workstream's row in `blueprint.md` § Workstreams directly instead of querying a parent Issue. The slug is inherited from `blueprint.md`'s workstream entry, not from a parent Issue title — this is the one place where markdown-only mode's slug-derivation differs from github-only mode, and it works because both modes share the same slug-naming convention in the markdown.

The cascade still uses the same naming conventions inside `frame-NN.md` § Milestones (capability headings prefixed `[<slug>:F<#>]`, depends-on lines, acceptance signals, etc.) so the hierarchy is grep-able even without an Issue tree to render it. Re-framing detection still uses the cascade-event model (frame-NN.md numbering, supersedes via the status field in the markdown) — the planning-backend supersede operations are no-ops because there's nothing to close not-planned.

The HITL gate in markdown-only mode mentions only the markdown commit half:

> "About to commit framing for `<workstream-slug>`:
> - Markdown: `docs/cbk/frame-NN.md` + append to `docs/cbk/README.md` index
> - Planning backend: none (markdown-only profile)
>
> No planning operations to run, no sub-issues to create, no atomic transition needed beyond the markdown commit itself.
>
> Approve?"

## Partial failure recovery

The atomic transition pattern above describes the *intended* flow — capture, execute, rollback on failure. In practice, failures during multi-step transitions can leave the system in states the rollback discipline doesn't fully cover, especially when MCP calls hang, return ambiguous responses, or fail mid-network. Framing's transition is particularly vulnerable because the two-step `issue_write` + `sub_issue_write` pattern doubles the failure surface — either step can fail independently. **The skill must treat partial failure as a first-class case, not as something to retry blindly.**

**The right move on any partial failure**: stop, do not retry, surface state to the user, ask the user to verify state before proceeding.

Concretely, when a planning operation fails or hangs:

1. **Stop immediately** — do not retry the failing operation, do not proceed to the next operation in the captured list, do not attempt rollback automatically
2. **Surface the partial state explicitly** — name every operation that was captured, every operation that successfully completed (with its returned id/url), the operation that failed (with the error or "no response — assumed hung"), and every operation that was queued but never attempted. **For framing's two-step pattern specifically**: if `issue_write` succeeded but `sub_issue_write` failed or hung, name the orphan Issue explicitly so the user can find and inspect it.
3. **Ask the user to verify state** — *"I executed N operations successfully, the next one failed/hung, and M operations were queued behind it. Before I do anything else, please verify the state of the operations I think succeeded — they may or may not actually be in the state I have recorded. Once you've verified, tell me one of: (a) state matches my recording, proceed with rollback of the successful operations and abort, (b) state matches my recording, proceed with retry of the failed operation, (c) state does not match my recording — here's what's actually there."*
4. **Wait for explicit user confirmation** before any further action — rollback, retry, or abort. Do not assume the user wants any specific path.

**Why no automatic retry**: a failed planning operation might have actually succeeded server-side and the failure was in the response path. Retrying would create a duplicate. Framing's two-step pattern makes this especially dangerous because retrying `issue_write` after a hung first call could leave you with two issues both partially linked to the parent.

**Why no automatic rollback on hang vs. fail**: a hung operation might still be in flight server-side and may yet complete. Rolling back the predecessors would leave the system in a worse state than the partial commit. The user's verification step distinguishes "definitely failed" from "in unknown state" before any rollback action.

**The cascade is honest about partial state**, never assumes its model of server state is correct after a failure, and always defers to the user for the next move. This costs a moment of friction on every failure but is the only safe pattern given that GitHub MCP operations can fail in ways that are indistinguishable from success at the protocol level.

## Failure modes specific to this step

- **Missing workstream parent Issue** — framing tries to parent sub-issues under a workstream Issue that doesn't exist (blueprint wasn't run, was rolled back, or the Issue got closed). Defense: framing queries the parent Issue before the transition. If missing, surface the gap and ask whether to loop back to blueprint.
- **Slug mismatch** — framing constructs sub-issue prefixes using a slug that doesn't match the parent Issue's title. Defense: framing always inherits the slug from the parent Issue, never re-derives from the workstream name.
- **Orphan sub-issues from partial step-1/step-2 failure** — `issue_write` succeeded but `sub_issue_write` failed, leaving an Issue with no parent link. Defense: rollback includes orphan cleanup — close-with-rollback-label any orphan whose parent linking failed.
- **F-number collisions on re-framing** — re-framings use the same F-number sequence (F1, F2, ...) but the sub-issues are uniquely identified by their Issue number + parent linkage. Prior superseded sub-issues are closed-not-planned, new sub-issues are open. Board views filter by Status.
- **Re-framing rollback complexity** — re-framings have more moving parts. Capture every operation in execution order; rollback walks the captured list in reverse.
- **Parent state out of sync with descendant rollup** — the workstream parent Issue's Status doesn't match what the sub-issue progress field implies (e.g., parent stuck in Triage even though framing has created sub-issues). Defense: framing's transition relies on the board's automation rules to move the parent automatically via the sub-issue progress field. If this isn't happening, the rules aren't configured correctly — surface as a board configuration gap with instructions, don't try to manually set the parent state from framing (that would mask the broken automation and create silent drift).
- **Parent Archived not set on workstream-abandonment re-framing** — framing performs an abandonment re-framing (no new sub-issues, just supersedes the old ones) but forgets to set the parent's Status to Archived. The parent stays in In Progress and the board gives a wrong signal. Defense: framing detects abandonment re-framings by counting new sub-issues to be created (zero = abandonment) and explicitly sets parent Status = Archived as part of the supersede transition. The HITL gate language differs between normal re-framings and abandonment re-framings so the user knows which path is happening.
- **Inherited Projects v2 PAT scope assumption** — framing operates against the Issues + sub-issue API surface, which uses standard repo PAT scopes. Framing does NOT directly query the Projects v2 board, so it doesn't hit the project-scope gap that blueprint can hit. However, framing inherits the assumption that blueprint successfully verified the board state at its layer. If blueprint was forced into "honor-system mode" because of a missing project scope, the board automation rules that should auto-status framing's new sub-issues may not actually be in place. Framing surfaces this in its inheritance summary: *"Blueprint operated under honor-system mode for the Projects v2 board — I'm trusting that the board exists with the four standard automation rules. If your new sub-issues don't appear on the board after this commit, the rules aren't set up and you'll need to fix them at the board level."*
- **Brownfield: `frame-NN.md` exists but corresponding sub-issues don't** — this surfaces when a repo's framing was produced by a framing skill version that predated the planning-backend commit step. The markdown half committed cleanly but the sub-issues half was never run, so the repo has a complete frame-NN.md and zero framing capability sub-issues parented under the workstream Issue. Defense: framing's inheritance check detects this case (see the Brownfield recovery section below) and offers to complete the missing planning-backend commit against the existing frame-NN.md rather than producing a new frame file. This is deliberate — creating a new frame-(NN+1).md would supersede the prior framing as a cascade event, but the prior framing wasn't wrong, it was just incomplete. Recovery is a fill-in, not a supersede.
- **Title drift in cross-referenced issues** — an Issue's body references another Issue by title in prose (e.g., "Blocked by #23 — Run Claude Code automation recommender"), and later the referenced Issue's title gets updated (e.g., slug prefix added during a cascade cleanup pass). The issue number reference still resolves correctly, but the surrounding prose is now stale relative to the actual title. Defense: when framing writes issue bodies that reference other issues, **use issue numbers only** (`#23`) and avoid reproducing the referenced issue's title in prose. GitHub renders the current title dynamically via hover cards, so number-only references stay fresh without needing body edits. This applies to the handoff context, dependency sections, and any other prose that cites cascade artifacts by number. If a body accidentally includes a title that later drifts, the recovery is a **comment on the issue** (not a body edit) noting the drift — body edits rewrite history in ways that can confuse downstream tools, while comments preserve the historical record.
- **Defense-in-depth: `create_or_update_file` content-parameter ambiguity** — the GitHub MCP's `create_or_update_file` tool takes a `content` parameter that expects the literal file content string. If a path string is passed instead (e.g., `/home/claude/recovery/frame-01.md`), the tool commits the path string as the file's content (a silent, hard-to-notice corruption that only surfaces when someone reads the file). **Primary defense should be at the harness/prompt-config layer, not here** — this note is defense-in-depth. The cascade's secondary defense: prefer `push_files` over `create_or_update_file` for content-as-string operations. `push_files` uses an array of `{path, content}` objects where the path/content separation is structurally obvious and the mistake is harder to make. The cascade standard is `push_files` for all single-file and multi-file commits; `create_or_update_file` is allowed only when SHA-based update semantics are specifically needed (which framing's step does not — the atomic transition uses `push_files` for the markdown half).

## Brownfield recovery

This section covers the case where framing encounters a repo with an existing frame-NN.md but no corresponding framing capability sub-issues on the planning backend. This is the brownfield-recovery case — the markdown half of a prior framing run is present, but the planning-backend half is missing.

### Detecting the case during inheritance

Framing's inheritance check (Step 1) reads the existing `docs/cbk/` directory to determine the next framing number. When it finds existing frame files, it normally treats them as prior framings to inherit from. But there's a special case: **if the highest-numbered frame file's F-layer sub-issues don't exist on the planning backend**, framing should not automatically treat the new run as a re-framing (which would produce frame-(N+1).md). Instead, framing should detect the gap and surface recovery options.

The detection protocol:

1. Read the highest-numbered existing `frame-NN.md` file
2. Parse its milestones section to get the expected count of framing capability sub-issues (one per milestone, typically 3-6)
3. Query the workstream parent Issue via `issue_read get_sub_issues` to see how many framing capability sub-issues actually exist
4. Compare expected vs. actual:
   - **Expected > 0 and actual = 0**: the classic brownfield-recovery case. Neither half has landed yet — wait, actually the markdown IS present, so this is: the markdown half is done, the planning-backend half never ran. Surface recovery options.
   - **Expected > 0 and actual > 0 but counts mismatch**: the planning-backend commit ran partially (maybe stopped mid-way from a partial failure). Surface as a different case — the user may want to resume the partial transition rather than doing a full recovery.
   - **Expected > 0 and actual = expected**: normal case, nothing to recover. Proceed as inheritance.

### Recovery options

When framing detects the brownfield case, it surfaces three options to the user:

1. **Complete the missing planning-backend commit against the existing frame-NN.md** (recommended for clean brownfield recovery). Framing reads the existing frame-NN.md as its authoritative source, populates the `cascade-framing.md` issue template for each milestone, and commits the sub-issues via the normal Step 6 atomic transition. The existing frame-NN.md is unchanged except for an optional recovery note at the top documenting when the retroactive commit happened. No new frame file is created. The README.md index gets a "Retroactive recovery" entry.

2. **Re-frame the project from scratch** (for cases where the existing frame-NN.md is substantively out of date and the user wants a fresh pass). Framing treats the existing frame-NN.md as a prior framing to inherit from and produces frame-(NN+1).md. The prior frame file stays in the cascade history as superseded. The new frame-NN.md goes through the full framing flow including Step 6's sub-issue creation.

3. **Abort and handle manually** (for cases where the user wants to inspect the state before proceeding). Framing stops cleanly, the user does their own investigation or cleanup, and re-runs framing when ready.

### HITL gate for the recovery

The recovery HITL gate is **mandatory in every rigor mode**. The user must explicitly choose option 1, 2, or 3 — framing does not auto-pick based on inheritance signals. The gate language:

> "I found `docs/cbk/frame-NN.md` but zero framing capability sub-issues under issue #<workstream-parent>. This is a brownfield recovery case — the markdown half of a prior framing is present but the planning-backend half never ran (most likely because the framing skill version used for the prior run predated the planning-backend commit step).
>
> Three options for how to proceed:
>
> **1. Complete the missing planning-backend commit against the existing frame-NN.md.** I'll read frame-NN.md, populate cascade-framing.md for each milestone, and commit the sub-issues via the normal atomic transition. frame-NN.md itself stays unchanged except for an optional recovery note at the top. Recommended for clean recovery.
>
> **2. Re-frame from scratch.** I'll treat frame-NN.md as prior-framing inheritance and produce frame-(NN+1).md. Use this if the existing framing is substantively out of date and you want a fresh pass.
>
> **3. Abort and handle manually.** I'll stop cleanly so you can inspect state before proceeding.
>
> Which?"

### The recovery transition is the same atomic pattern

When the user picks option 1, the recovery runs **the exact same atomic transition as a fresh framing's Step 6** — the planning-backend commit, the markdown-half commit (a no-op or minimal recovery-note edit), the README.md index update. The partial-failure recovery protocol applies unchanged. The only thing different is the source — framing reads an existing frame-NN.md rather than producing a new one.

### When to NOT use brownfield recovery

- **The existing frame-NN.md has drifted substantively** from what the current cascade state requires (e.g., the project has progressed beyond the milestones the old framing described). Option 2 (re-frame from scratch) is correct here — brownfield recovery would just commit sub-issues for an outdated plan.
- **The workstream parent Issue's slug doesn't match what the existing frame-NN.md expects.** This is a different kind of drift — the parent was renamed or moved. Surface as a fifth option or abort; don't try to reconcile automatically.
- **Multiple frame files exist and it's unclear which is the active one.** Read README.md's index to determine which frame file is Active. If the index doesn't clearly identify one, surface the ambiguity and stop.

### What the recovery does NOT do automatically

- **Does not update existing meta-issues from the old framing** (they may have stale labels or parent linkage from the pre-recovery state). Those are a separate recovery pass and should be handled as a `## Meta-issue cleanup` step after the framing capability sub-issues land. The HITL gate for the recovery should mention if meta-issues need follow-up cleanup so the user knows to look.
- **Does not rewrite frame-NN.md's prose sections** beyond an optional recovery note at the top. Specifically, if frame-NN.md has a wrong handoff sentence or other content that would benefit from updating, the recovery does not fix it — that's a separate edit and should go through the normal "framing markdown edit" path, not the atomic transition.
- **Does not retroactively set Projects v2 Status fields** on the new sub-issues (the MCP surface for Projects v2 field manipulation is limited). The user sets those manually after the recovery completes, same as with a fresh framing run.

## What this step enables

After this step runs successfully, rough-in has everything it needs to operate against any one framing capability:

- The sub-issue exists on the planning backend, parented under the workstream Issue, with the capability prose as its body
- The slug + F-number pair is canonical and visible in the title prefix
- The markdown source-of-truth (`frame-NN.md`) is committed and traceable
- Rough-in inherits the slug + F-number from the sub-issue title to construct sub-sub-issue names like `[<slug>:F<#>:R<#>]` and uses `sub_issue_write` to parent its sub-sub-issues under the framing sub-issue

Rough-in reads the framing sub-issue (via `issue_read`) and the corresponding capability section in `frame-NN.md` as its inheritance step.
