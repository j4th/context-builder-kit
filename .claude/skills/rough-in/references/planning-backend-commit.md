# Rough-in planning-backend commit

This file is the operational detail behind rough-in's Step 6 (Planning-backend commit). It covers what rough-in commits to the planning backend, how it inherits the spec body shape from disk, the atomic transition pattern, the re-rough-in supersede flow, partial failure recovery, profile-aware behavior, and failure modes.

Rough-in's commit is the third level of the cascade Issue tree — sub-sub-issues parented under framing capability sub-issues, which are themselves parented under workstream parent Issues. Each level uses the same two-step `issue_write` + `sub_issue_write` pattern, but rough-in's commit has additional concerns because it's the closest cascade phase to actual code execution: the body of each sub-sub-issue must be runnable by `/finish` without context fetching, and re-rough-in is more common than re-blueprint or re-framing because rough-in specs are the ones most likely not to survive contact with code.

**Read `references/backends.md`** (the cascade meta-doc, bundled with this skill) for the underlying interface, the cascade hierarchy mapping, the unified state machine, and the atomic transition pattern. This file is the operational implementation of `planning.create_work_unit` from that interface.

## What gets created

For each rough-in spec produced in Step 5, rough-in creates one **sub-sub-issue** parented under the framing capability sub-issue:

| Field | Source | Example |
|---|---|---|
| Title | `[<workstream-slug>:F<#>:R<#>] <intent>` (slug + F-number inherited from the parent framing sub-issue's title via `issue_read`, R-number from rough-in sequence) | `[regex-pack:F1:R1] Define Verifier trait` |
| Body | The full rough-in spec from Step 5, populated into the `cascade-rough-in.md` template (seven sections: Context / Implementation / Acceptance criteria / Test plan / Done signal / Dependencies / PR contract) | (full markdown body) |
| Parent | Framing capability sub-issue created by framing | `[regex-pack:F1] Verify one regex lesson end-to-end` |
| Labels | `cascade-depth:roughed-in`, plus any inherited from the parent framing sub-issue | — |
| Initial board Status | **Ready** (set by board automation rules, not directly by the cascade) | — |

The R-number sequence starts at R1 for the first issue in the milestone. Re-rough-in of the same milestone uses a continuing R-number sequence (R<N+1> where N is the highest R-number used so far in this milestone, including superseded R-issues), not a reset to R1. This means superseded R-issues are uniquely identified by their original R-number even after they're closed, and the active R-issues for the milestone always have higher R-numbers than the superseded ones. Board views can filter by Status to hide superseded sub-sub-issues.

The Initial board Status of **Ready** is set by Projects v2 board automation rules driven by the cascade-depth label — when an issue with `cascade-depth:roughed-in` is added to the board, the rule sets Status = Ready. The cascade does not directly manipulate Projects v2 field values because the github MCP doesn't expose Projects v2 field operations. If the board's automation rules aren't configured correctly, sub-sub-issues will land without a Status and the user will need to manually set them — surface this as a board configuration gap during the inheritance summary if rough-in detects it.

## Issue body source — inherit from disk first

Rough-in constructs each sub-sub-issue's body from the **`cascade-rough-in.md`** template. The template lives at `.github/ISSUE_TEMPLATE/cascade-rough-in.md` in the user's repo (committed by scaffold during its bootstrap step) and is the source of truth for the rough-in spec body shape — see `references/backends.md` § Issue templates as workspace infrastructure for the full inherit-from-disk discipline.

**Read order**:

1. **Disk first**: query `get_file_contents` for `.github/ISSUE_TEMPLATE/cascade-rough-in.md` in the user's repo
2. **If found**: use the disk template, populating the seven sections (Context / Implementation / Acceptance criteria / Test plan / Done signal / Dependencies / PR contract) from the spec drafted in Step 5. The disk copy is canonical even if it differs from the bundled fallback.
3. **If not found**: fall back to the bundled copy at `references/templates/rough-in-spec-template.md` in this skill bundle. Surface the disk-miss in the inheritance summary as a brownfield gap: *"Your repo doesn't have `.github/ISSUE_TEMPLATE/cascade-rough-in.md` — using the bundled fallback for now. I recommend re-running scaffold's Stage 2.5 step to commit the cascade issue templates so future runs read from disk."*
4. **If disk and bundle differ**: always use disk, mention the divergence in the inheritance summary as informational

**Population pattern**: rough-in reads the YAML frontmatter to verify the labels and title format match expectations, then fills the seven body sections with spec-specific content from Step 5. Section heading names from the template are preserved verbatim — do not rename, reorder, or omit sections that the template provides. Adding additional sections after the template-provided ones is permitted if a spec genuinely needs them (e.g., a research-heavy issue might benefit from a `## Background` section after Context), but this should be the exception, not the rule.

**The Implementation section is the load-bearing section** because `/finish` will anchor on it when constructing the plan-mode prompt. See `references/plan-mode-prompts.md` for the eight properties of a good Implementation section and the section-anchoring discipline for `/finish`.

## Atomic transition pattern (two-step per sub-sub-issue)

Rough-in's planning-backend commit uses GitHub's two-step sub-issue creation, same as framing's pattern:

1. Create the sub-sub-issue via `issue_write` (returns issue number + id)
2. Link it to the parent framing sub-issue via `sub_issue_write` with method `add` and the parent's issue_number + the new sub-sub-issue's id

Both calls must succeed for the sub-sub-issue to count as created. If step 1 succeeds but step 2 fails, the sub-sub-issue exists as an orphan — rough-in's rollback must include orphan-cleanup.

**Full transition order**:

1. **Capture** the planned transition: each spec's content + N (issue_write + sub_issue_write) pairs + the `README.md` index update entry noting that milestone M_n was roughed-in
2. **Execute planning ops first, dependency-aware**: for each spec, run `issue_write` to create the sub-sub-issue + `sub_issue_write` to link to the parent framing sub-issue. Capture each sub-sub-issue's `{number, id, url}` as it lands successfully. **Order matters**: create independent sub-sub-issues first (those whose Dependencies section says "None"), then create dependent sub-sub-issues last with `blockedBy: [<earlier-ids>]` populated from the captured ids. This is non-negotiable because Linear's `blockedBy` (and GitHub's parent linkage in some board automations) requires both issues to exist at the moment the relation is set, so creating a dependent sub-sub-issue before its dependency exists fails the planning op outright.
3. **Execute the markdown commits**: append the rough-in record to `README.md` index via GitHub MCP. The README.md index entry is short — date, milestone identifier (workstream slug + F-number + M-number), the R-number range created, links to the new sub-sub-issues.
4. **On any failure during step 2**: close every sub-sub-issue captured up to the failure point with `state_reason: not_planned` and label `transition-rollback`. Includes orphan cleanup if `issue_write` succeeded but `sub_issue_write` failed for the failing sub-sub-issue. Abort cleanly.
5. **On failure during step 3**: same rollback for all captured sub-sub-issues, abort.

GitHub Issues cannot be deleted via the standard API — only closed. The cascade rollback uses **close + label**, not delete.

**Re-rough-in detection (cascade-event model)**: if this rough-in supersedes a prior rough-in of the same milestone (because the prior specs didn't survive contact with code, or because the milestone's framing was updated and rough-in needs to re-decompose it), the prior rough-in's sub-sub-issues must be marked superseded as part of the same atomic transition. Order:

1. Create new sub-sub-issues with parent link to the framing sub-issue (R-numbers continue from where the prior rough-in left off — see R-numbering above)
2. Supersede prior sub-sub-issues via `issue_write` update method (close `not_planned` + `superseded` label) — but **only the ones that haven't been completed**. Already-merged sub-sub-issues stay closed-as-completed; only open or in-progress ones get superseded.
3. Append a new entry to `README.md` index recording the re-rough-in event with both the new R-number range and the list of superseded R-numbers
4. Atomic — all rolled back together on any failure

**Why the partial-supersede on re-rough-in**: if R1, R2, and R3 of the prior rough-in were already merged before R4 surfaced as needing rework, R1-R3 represent real work that's already in the codebase. Closing them as superseded would create a misleading historical record. Only R4 (the one that triggered the rework) and R5+ (the queued ones not yet started) get superseded; R1-R3 keep their `state_reason: completed` close.

### The framing.md event entry shape

The entry appended to `docs/cbk/README.md` for each rough-in run records the event in the cascade's append-only log. The entry has a required shape:

- **Date and milestone identifier**: *"2026-04-14 — regex-pack:F1:M1"*
- **R-number range created**: *"R1-R2 (2 sub-sub-issues)"*
- **Links to the new sub-sub-issues**: bulleted list with issue numbers and titles
- **Re-rough-in marker (if applicable)**: *"re-rough-in of M1 — supersedes R1-R4 from rough-in 2026-04-10"*
- **Compression rationale (when the actual R-count differs from the framing sketch)**: a one-paragraph note naming the sketch's count, the actual count, and which sketch items were dropped/folded plus why. Cite the discipline (review-unit boundaries, already-shipped from earlier milestone, capstone fold) rather than free-form rationale. Example: *"Compressed sketch's 4 issues to 3 along review-unit boundaries (per Step 4 guidance). Sketch's 'X' issue dropped — already landed in F1. Residual 'Y' verification folded into capstone."* If the actual count matches the sketch, this field is omitted.
- **Notable departures from defaults**: e.g., HITL gate that produced an explicit override, a spec that was deliberately shaped differently, Step 5.5 drift that was resolved during this run. **Reference the discipline that justified the decision, not the version history of the skill.**

**The reference-discipline-not-version-history rule**: rough-in event entries are part of the cascade's append-only log and should be readable by anyone later, without knowing which skill version the run was executed under. If a rough-in run produces 2 issues where the typical range might suggest more, the entry should say *"2 issues per the review-unit test in Step 4 — each issue is a coherent review unit and splitting further would add bureaucracy"*, not *"2 issues, below the typical range from the skill version at time of run, deliberately within the range from the revised skill that followed this run."* The second phrasing is honest chronology but creates weird forward references in an authoritative log and forces future readers to understand skill-revision history to parse the entry.

The discipline test for an event entry: *"could a reader understand why this run made this decision without knowing the history of the skill?"* If yes, the entry is shaped correctly. If no, the entry is leaning on version history as context instead of referencing the discipline directly, and should be rewritten to reference the discipline.

**Mid-run skill revisions as a special case**: if a skill is revised mid-run (a user's observation surfaces a real gap, the revision lands in the same chat session, the run continues with the revised skill), the honest record-keeping move is **not** a forward reference inside the rough-in event entry. Instead, append a **separate "skill revision applied mid-run" event** to framing.md documenting what changed and why, with the rough-in event entry itself referencing only the discipline (not the revision event). The two events are chronologically adjacent but semantically distinct — one is a rough-in of a milestone, the other is a skill revision — and they belong as separate log entries. This is rare but worth codifying because it will happen again as the cascade matures.

## HITL gate — final pre-commit

Rough-in's existing final pre-commit gate now mentions both halves of the transition. Lead with:

> "About to commit rough-in for `<workstream-slug>:F<#>:M<#>`:
>
> - Planning backend: N sub-sub-issues (one per spec), all parented under the framing sub-issue `[<slug>:F<#>] <capability>` (#<parent-issue-number>):
>   - `[<slug>:F<#>:R1] <intent 1>`
>   - `[<slug>:F<#>:R2] <intent 2>`
>   - `[<slug>:F<#>:R<N>] <intent N>`
> - Markdown: append entry to `docs/cbk/README.md` index recording this rough-in event
>
> These commit atomically — either both land or neither does. Each sub-sub-issue is created via `issue_write` then linked to the parent framing sub-issue via `sub_issue_write`. Each sub-sub-issue's body holds the full rough-in spec drafted in Step 5, ready for `/finish` to pick up.
>
> Approve the full transition?"

For re-rough-ins, the gate also lists the prior sub-sub-issues that will be superseded as part of the same operation, distinguishing already-merged ones (which stay completed) from open/in-progress ones (which get superseded).

## What rough-in does NOT create on the planning backend

- **The framing sub-issue** — that's framing's job. Rough-in reads the existing framing sub-issue and parents its new sub-sub-issues under it. If the framing sub-issue doesn't exist or has the wrong title format, rough-in surfaces the gap and asks whether to (a) loop back to framing, (b) abort.
- **The workstream parent Issue** — that's blueprint's job, two levels up.
- **A fourth level of sub-issues** — the cascade hierarchy is three deep. Rough-in's sub-sub-issues are leaves on the planning backend; their children are PRs (managed by `/finish` and git, not by the cascade's MCP operations).
- **Milestones** — not used by the cascade.
- **The Projects v2 board itself, or its automation rules, or its fields** — those are scaffold/manual setup. Rough-in assumes the board exists with the right configuration; if it doesn't, rough-in surfaces the gap during inheritance and offers to proceed in honor-system mode (parent rollup may not work correctly until the board is fixed).

## Profile-aware behavior

**github-only profile** (default): sub-sub-issues created via the two-step `issue_write` + `sub_issue_write` pattern, parented under the framing sub-issue, atomic with the markdown commit.

**opinionated profile** (Linear): per `references/backends.md`, rough-in items map to Linear Issues created via Linear MCP. Linear's hierarchy is Project → Milestone → Issue, so rough-in's sub-sub-issues become Linear Issues under the Linear Milestone that framing created. Same atomic transition pattern.

**markdown-only profile**: this entire step is **skipped**. No sub-sub-issues get created on the planning backend because there is no planning backend. The atomic transition collapses to a single half — just the markdown commits (the rough-in spec content lands as appended sections in the framing's markdown file or as a new per-milestone rough-in markdown file at `docs/cbk/frame-NN-M<#>-rough-in.md`, depending on user preference; plus the `README.md` index update). There is no rollback to perform on the planning side because no planning ops ran. The cascade still uses the same naming conventions inside the markdown (`[<workstream-slug>:F<#>:R<#>]` headings) so the hierarchy is grep-able even without a sub-sub-issue tree to render it.

In markdown-only mode, the slug + F-number is inherited from the workstream's row in `blueprint.md § Workstreams` and the framing's milestone entry in `frame-NN.md`, not from a parent issue title (because there isn't one). This is the one place where markdown-only mode's slug-derivation differs from github-only mode, and it works because both modes share the same slug-naming convention in the markdown.

The HITL gate in markdown-only mode mentions only the markdown commit half:

> "About to commit rough-in for `<workstream-slug>:F<#>:M<#>`:
> - Markdown: append rough-in spec sections to `docs/cbk/frame-NN.md` § Rough-in M<#> (or to a new `frame-NN-M<#>-rough-in.md` file, your choice)
> - Markdown: append entry to `docs/cbk/README.md` index recording this rough-in event
> - Planning backend: none (markdown-only profile)
>
> Approve the markdown commits?"

## Partial failure recovery

The atomic transition pattern above describes the *intended* flow — capture, execute, rollback on failure. In practice, failures during multi-step transitions can leave the system in states the rollback discipline doesn't fully cover, especially when MCP calls hang, return ambiguous responses, or fail mid-network. Rough-in's transition is particularly vulnerable because the two-step `issue_write` + `sub_issue_write` pattern doubles the failure surface — either step can fail independently — and rough-in often creates more sub-sub-issues per transition than framing creates sub-issues (3-7 R-issues per milestone vs typically 3-5 framing capabilities), so the failure surface is larger in absolute terms. **The skill must treat partial failure as a first-class case, not as something to retry blindly.**

**The right move on any partial failure**: stop, do not retry, surface state to the user, ask the user to verify state before proceeding.

Concretely, when a planning operation fails or hangs:

1. **Stop immediately** — do not retry the failing operation, do not proceed to the next operation in the captured list, do not attempt rollback automatically
2. **Surface the partial state explicitly** — name every operation that was captured, every operation that successfully completed (with its returned id/url), the operation that failed (with the error or "no response — assumed hung"), and every operation that was queued but never attempted. **For rough-in's two-step pattern specifically**: if `issue_write` succeeded but `sub_issue_write` failed or hung, name the orphan sub-sub-issue explicitly so the user can find and inspect it. **For re-rough-in transitions specifically**: name which prior sub-sub-issues had already been superseded (closed-not-planned + superseded label) before the failure, so the user knows which ones need to be reopened if the rollback happens.
3. **Ask the user to verify state** — *"I executed N operations successfully, the next one failed/hung, and M operations were queued behind it. Before I do anything else, please verify the state of the operations I think succeeded — they may or may not actually be in the state I have recorded. Once you've verified, tell me one of: (a) state matches my recording, proceed with rollback of the successful operations and abort, (b) state matches my recording, proceed with retry of the failed operation, (c) state does not match my recording — here's what's actually there."*
4. **Wait for explicit user confirmation** before any further action — rollback, retry, or abort. Do not assume the user wants any specific path.

**Why no automatic retry**: a failed planning operation might have actually succeeded server-side and the failure was in the response path. Retrying would create a duplicate. Rough-in's two-step pattern makes this especially dangerous because retrying `issue_write` after a hung first call could leave you with two sub-sub-issues both partially linked to the parent framing sub-issue, and both with the same R-number — which would break the cascade's R-number uniqueness invariant.

**Why no automatic rollback on hang vs. fail**: a hung operation might still be in flight server-side and may yet complete. Rolling back the predecessors would leave the system in a worse state than the partial commit. The user's verification step distinguishes "definitely failed" from "in unknown state" before any rollback action.

**The cascade is honest about partial state**, never assumes its model of server state is correct after a failure, and always defers to the user for the next move.

## Presentation pattern for execution

The partial-failure discipline above requires **raw visibility when things go wrong**. It does NOT require raw visibility when things go right. Running narration of every tool call's full response during a clean happy path produces a lot of screen output with no reviewable signal — each MCP response is a huge JSON blob that doesn't carry information the user needs to act on.

The rule: **compress on success, expand on failure.**

### Happy path — running checklist

During successful execution, surface per-step status as a **running checklist** with one line per step:

```
[✓] Step 1 — Created issue #48 ([regex-pack:F1:R1] Define Verifier trait)
[✓] Step 2 — Created issue #49 ([regex-pack:F1:R2] Implement RegexConstructVerifier with match-span detail)
[✓] Step 3 — Parented #48 under #37
[✓] Step 4 — Parented #49 under #37
[✓] Step 5 — Appended rough-in event to docs/cbk/README.md (commit <SHA>)
```

Each line is one operation with its outcome: issue number + title for creation, parent + child for sub-issue linking, path + commit SHA for markdown appends. No full JSON responses, no captured tool output, no debug dumps.

After the checklist, close with a **one-paragraph atomic transition summary**: the total number of operations, the time range, any deferred gotchas from the execution (e.g., *"Step 5.5 was a no-op on this run, template already provisioned"*). Then transition into the post-run summary (Step 7).

### Failure path — full expansion

The moment any step fails or hangs, switch presentation modes:

1. **Stop the checklist immediately** — do not proceed to the next step
2. **Dump the full tool response** for the failing step — raw JSON, error messages, whatever the MCP returned (or a clear "no response — assumed hung" marker)
3. **Re-present the running checklist of what succeeded before the failure** so the user can see the partial state in context
4. **Surface the partial state explicitly** per the Partial failure recovery protocol above
5. **Fire the three-option recovery gate** (rollback / retry / abort) and wait for explicit user direction

No compression on failure. The moment raw visibility matters is the moment something went wrong, and that's exactly the moment the cascade expands the presentation to give the user everything.

### Internal tracking is unchanged

This section is **purely about presentation** — what gets shown to the user. Claude still captures every operation and every response internally for rollback discipline, idempotency checking, and partial-failure recovery. The change is presentation shape, not instrumentation shape. If Claude needs to reference a tool response later (for rollback targeting or for surfacing during a failure), the full response is still in the captured-operations list; it just doesn't get dumped at the user during the happy path.

### When the user wants verbose mode anyway

Some users will want the full per-step tool responses for debugging or curiosity, especially on the first few cascade runs. The right behavior: honor explicit requests (*"show me the full responses"*, *"verbose mode"*, *"dump everything"*) and switch to the expanded format for the remainder of the run. Do not offer verbose mode proactively — the default is compressed checklist, and the user opts in if they want more.

## Failure modes specific to this step

- **Missing parent framing sub-issue** — rough-in tries to parent sub-sub-issues under a framing sub-issue that doesn't exist (framing wasn't run, was rolled back, or the issue got closed). Defense: rough-in queries the parent framing sub-issue during Step 1 (inheritance) and Step 2 (milestone selection). If missing, surface the gap and ask whether to loop back to framing.
- **Slug or F-number mismatch** — rough-in constructs sub-sub-issue prefixes using a slug or F-number that doesn't match the parent framing sub-issue's title. Defense: rough-in always inherits the slug AND the F-number from the parent's existing title via `issue_read` parsing, never re-derives from the workstream name or capability name.
- **R-number collision** — two rough-in specs in the same milestone end up with the same R-number, or a new rough-in spec accidentally reuses an R-number from a superseded prior rough-in. Defense: rough-in queries existing sub-sub-issues under the parent framing sub-issue (via `issue_read get_sub_issues`) before drafting Step 4's issue plan, identifies the highest existing R-number (including superseded ones), and starts the new sequence from R<highest+1>.
- **Orphan sub-sub-issues from partial step-1/step-2 failure** — `issue_write` succeeded but `sub_issue_write` failed, leaving a sub-sub-issue with no parent link. Defense: rollback includes orphan cleanup — close-with-rollback-label any orphan whose parent linking failed.
- **Re-rough-in supersedes work that was already completed** — the re-rough-in flow accidentally closes a sub-sub-issue that had already been merged via `/finish`. Defense: the partial-supersede rule above. Only open or in-progress sub-sub-issues get superseded; already-merged ones (closed with `state_reason: completed`) stay completed.
- **Re-rough-in rollback complexity** — re-rough-ins have more moving parts (new sub-sub-issues + supersedes of prior ones + README.md index update). Capture every operation in execution order; rollback walks the captured list in reverse, including unsuperseding any sub-sub-issues whose supersede was rolled back (reopen + remove `superseded` label + remove `transition-rollback` label).
- **Inherited Projects v2 PAT scope assumption** — rough-in operates against the Issues + sub-issue API surface, which uses standard repo PAT scopes. Rough-in does NOT directly query the Projects v2 board, so it doesn't hit the project-scope gap that blueprint can hit. However, rough-in inherits the assumption that blueprint successfully verified the board state at its layer. If blueprint was forced into "honor-system mode" because of a missing project scope, the board automation rules that should auto-status rough-in's new sub-sub-issues may not actually be in place. Rough-in surfaces this in its inheritance summary: *"Blueprint operated under honor-system mode for the Projects v2 board — I'm trusting that the board exists with the four standard automation rules. If your new sub-sub-issues don't appear with Status = Ready after this commit, the rules aren't set up and you'll need to fix them at the board level."*
- **Issue template missing on disk** — `.github/ISSUE_TEMPLATE/cascade-rough-in.md` doesn't exist in the user's repo because scaffold's Stage 2.5 was never run. Defense: rough-in falls back to the bundled `references/templates/rough-in-spec-template.md` and surfaces the gap as a brownfield issue with a recommendation to re-run scaffold's Stage 2.5.
- **Idempotency violations on partial-completion re-runs** — a previous rough-in run committed some sub-sub-issues before failing partway through, the user fixed the underlying issue and re-runs rough-in, and the re-run creates duplicates of the already-committed sub-sub-issues. Defense: rough-in's pre-commit pass checks for existing sub-sub-issues with the same titles under the parent framing sub-issue and surfaces them. The user can choose to (a) skip duplicates and only commit the missing ones, (b) supersede the existing ones and commit a fresh set, or (c) abort and resolve the duplication manually.
- **Title drift in cross-referenced issues** — a sub-sub-issue's body references another issue by title in prose (e.g., in the Dependencies section), and later the referenced issue's title gets updated (e.g., slug prefix added during a cleanup pass). The issue number reference still resolves correctly, but the surrounding prose is now stale relative to the actual title. Defense: rough-in's spec template instructs the Dependencies section to use **issue numbers only** (`#42`) and never to reproduce titles in prose. GitHub renders the current title dynamically via hover cards, so number-only references stay fresh without needing body edits. If a body accidentally includes a title that later drifts, the recovery is a **comment on the issue** (not a body edit) noting the drift — body edits rewrite history in ways that can confuse downstream tools and `/finish`, while comments preserve the historical record.
- **Defense-in-depth: `create_or_update_file` content-parameter ambiguity** — the GitHub MCP's `create_or_update_file` tool takes a `content` parameter that expects the literal file content string. If a path string is passed instead (e.g., `/home/claude/recovery/frame-01.md`), the tool commits the path string as the file's content (a silent, hard-to-notice corruption that only surfaces when someone reads the file). **Primary defense should be at the harness/prompt-config layer, not here** — this note is defense-in-depth. The cascade's secondary defense: prefer `push_files` over `create_or_update_file` for content-as-string operations. `push_files` uses an array of `{path, content}` objects where the path/content separation is structurally obvious and the mistake is harder to make. The cascade standard is `push_files` for all single-file and multi-file commits; `create_or_update_file` is allowed only when SHA-based update semantics are specifically needed (which rough-in's step does not — the atomic transition uses `push_files` for the markdown half).

## What this step enables

After this step runs successfully, `/finish` (Claude Code's finish phase, bootstrapped via the bootstrap-finish skill) has everything it needs to operate against any one sub-sub-issue:

- The sub-sub-issue exists on the planning backend, parented under the framing capability sub-issue, with the rough-in spec body shaped per `cascade-rough-in.md`
- The slug + F-number + R-number is canonical and visible in the title prefix
- The Implementation section is structured for `/finish` to anchor on
- The Dependencies section lists the prior R-issues that must be closed first, queryable by `/finish` before plan mode runs
- The PR contract section names how to close the issue when implementation is complete
- The board automation rules will move the issue through Ready → In Progress → In Review → Done as `/finish` executes the plan and opens the PR

`/finish` reads the sub-sub-issue (via `issue_read get`), verifies dependencies, hands the body to plan mode, executes the plan, and opens a PR. The board automation handles the status transitions and the parent rollup. See `references/handoff-to-finish.md` for the full handoff contract.
