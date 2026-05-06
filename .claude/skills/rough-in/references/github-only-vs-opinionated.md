# Rough-in profile-aware behavior

This file is the operational detail behind rough-in's profile-aware behavior. It covers what differs between the three backend profiles (github-only, opinionated, markdown-only) in rough-in's specific layer, and how rough-in adapts its steps to each.

The cascade ships three backend profiles defined in scaffold and documented in `references/backends.md`. Rough-in inherits the profile choice from `scaffold.md`'s `profile:` field and adapts its Step 6 (planning-backend commit) accordingly. Steps 1-5 (inheritance, milestone selection, research, issue plan, spec drafting) are mostly profile-agnostic — the spec content is the same regardless of where it lands. The differences live in how the specs get committed.

## github-only profile (validated primary path)

**Status**: validated. This is the profile rough-in is built to run cleanly against, with full atomic transition, partial failure recovery, and inherit-from-disk discipline.

**Hierarchy**: rough-in creates **sub-sub-issues** parented under the framing capability sub-issue via GitHub's native sub-issue API. The full Issue tree per workstream is three deep:

```
Workstream parent Issue              [<slug>] <name>                        cascade-depth:rough
└── Framing capability sub-issue     [<slug>:F<#>] <capability>             cascade-depth:framed
    └── Rough-in sub-sub-issue       [<slug>:F<#>:R<#>] <intent>            cascade-depth:roughed-in
```

Each level is created via the two-step `issue_write` + `sub_issue_write` pattern. Rough-in's specific responsibility is the third level — the leaves of the planning-backend tree.

**MCP operations rough-in calls in github-only profile**:

| Operation | Tool | Purpose |
|---|---|---|
| `get_file_contents` | github MCP | Read `cascade-rough-in.md` from `.github/ISSUE_TEMPLATE/` (inherit-from-disk template source), read foundation docs |
| `issue_read get` | github MCP | Read parent framing sub-issue for slug+F-number inheritance, read foundation docs from issue context |
| `issue_read get_sub_issues` | github MCP | Query existing sub-sub-issues under the parent framing sub-issue (R-number collision detection) |
| `issue_write create` | github MCP | Create each new rough-in sub-sub-issue (step 1 of two-step pattern) |
| `sub_issue_write add` | github MCP | Link the new sub-sub-issue to the parent framing sub-issue (step 2 of two-step pattern) |
| `issue_write update` | github MCP | Update issue state during re-rough-in supersedes (close `not_planned` + add `superseded` label), or during partial-failure rollback (close `not_planned` + add `transition-rollback` label) |
| `create_or_update_file` | github MCP | Append the rough-in event entry to `docs/cbk/README.md` index |

**Body source**: `.github/ISSUE_TEMPLATE/cascade-rough-in.md` from disk first, falling back to `references/templates/rough-in-spec-template.md` from this skill bundle if the disk copy is missing. See `references/planning-backend-commit.md` § Issue body source for the full inherit-from-disk discipline.

**Initial Status**: **Ready**, set by board automation rules driven by the `cascade-depth:roughed-in` label. Rough-in does not directly set the Status field because the github MCP doesn't expose Projects v2 field operations. If the board's automation rules aren't configured, sub-sub-issues will land without a Status — surface as a board configuration gap.

**Atomic transition**: full pattern from `references/planning-backend-commit.md` § Atomic transition pattern. Two-step per sub-sub-issue, capture-execute-rollback discipline, partial failure recovery via stop-and-surface-to-user.

**This is the profile rough-in is built to run cleanly against**, and the Linear+GitHub profile below mirrors its discipline with single-step issue creation. All other profiles either inherit this skill's full validated patterns or accept deliberate planning-surface omissions.

## Linear+GitHub profile (validated)

**Status**: validated. Full atomic transition, partial failure recovery, and inherit-from-disk discipline run cleanly against Linear's MCP. The patterns below are portable across projects; project-specific identifiers (Linear team key, workstream slugs, label conventions) live in the project's `.claude/rules/cbk-conventions.md`.

**Hierarchy**: Linear's planning hierarchy uses parent/sub-issue relationships at arbitrary depth (rather than the Project → Milestone → Issue triplet which exists alongside but is orthogonal to the cascade structure). The cascade hierarchy maps cleanly to parent-child links:

| Cascade level | Linear entity | Title format | Labels |
|---|---|---|---|
| Workstream | Issue parented under the phase project | `[<slug>] <name>` | `workstream:<slug>` |
| Framing capability | Sub-issue under the workstream issue | `[<slug>:F<#>] <capability>` | `workstream:<slug>` + `cascade-depth:framed` + appetite |
| Rough-in spec | Sub-sub-issue under the framing F-issue | `[<slug>:F<#>:R<#>] <intent>` | `workstream:<slug>` + `cascade-depth:roughed-in` + type |

Rough-in's Step 6 creates **Linear sub-sub-issues** under the framing F-issue (which framing created in its Step 6) inside the workstream parent issue (which blueprint created at workstream-definition time). The MCP operations are different from github-only — `mcp__linear__save_issue` instead of `github:issue_write` — but the atomic transition discipline is the same: capture, execute, rollback on failure, partial failure recovery via stop-and-surface.

**MCP operations rough-in calls in Linear+GitHub profile**:

| Operation | Tool | Purpose |
|---|---|---|
| `mcp__linear__get_issue` (with `includeRelations: true`) | Linear MCP | Read parent F-issue for slug+F-number inheritance and `blockedBy` chain context |
| `mcp__linear__list_issues` (with `parentId`) | Linear MCP | Query existing R-issues under the F-issue (R-number collision / idempotency detection) |
| `mcp__linear__save_issue` (with `parentId`, `team`, `labels`, `assignee`, `blockedBy`) | Linear MCP | Create each new R-issue (single-step — `parentId` accepts the F-issue ID directly) |
| `mcp__linear__save_issue` (with `id` to update) | Linear MCP | Update issue state during re-rough-in supersedes (set status to `Cancelled` + add `superseded` label) |
| `mcp__github__create_or_update_file` | GitHub MCP | Append the rough-in event entry to `docs/cbk/README.md` index in the same atomic transition |

**Notable difference from github-only**: Linear's `save_issue` is single-step rather than two-step — it accepts the parent reference directly via `parentId`, so there's no separate parent-linkage call to fail on. This eliminates the orphan-sub-issue failure mode entirely. The atomic transition is simpler in Linear+GitHub profile because the failure surface per issue is half the size.

**Closes-keyword behavior**: PRs closing R-issues use `Closes <TEAM>-<N>` in the PR body (Linear's GitHub integration auto-recognizes the magic word). Branch names embed the issue ID (`<type>/<team>-<n>-<slug>`) so Linear's auto-link fires regardless of the PR body. See cbk-conventions.md for the project's exact branch-naming convention.

**Sub-issue rollup**: when all R-issues under an F close, the F closes automatically (configured at team level — see project's `cbk-conventions.md` for the recommended toggles). This is the cascade-correct behavior: framing milestones close when their work is done, workstream issues close when their framings close.

**Body source**: in Linear+GitHub profile, the body source is `cascade-rough-in.md` from `.github/ISSUE_TEMPLATE/` (the cascade issue templates land in the GitHub repo even when planning lives in Linear, because the templates are workspace infrastructure that serves both github-native and Linear-mirroring use cases). The same inherit-from-disk discipline applies — disk first, bundled fallback if missing.

**Atomic transition with Linear MCP failure recovery**: same pattern as github-only — capture intent before any writes, execute markdown commits and Linear writes in sequence, surface partial state on any failure rather than retrying blindly. The single-step `save_issue` makes the per-issue failure surface smaller than github-only's two-step pattern, but the cross-issue partial state (some R-issues created, others not) still requires user-decided recovery.

## markdown-only profile

**Status**: structurally supported with the inherit-from-disk discipline collapsing to a no-op for the planning-backend half.

**Hierarchy**: there is no planning backend in markdown-only mode. The cascade artifacts live entirely as markdown files in `docs/cbk/`. Rough-in's specs land as markdown content rather than as planning-backend Issues. The cascade hierarchy (workstream → framing → rough-in) is preserved entirely in the markdown structure, with naming conventions (`[<workstream-slug>:F<#>:R<#>]` headings) keeping it grep-able.

**Where rough-in specs land in markdown-only mode**: the user has a choice between two patterns. Rough-in surfaces the choice during Step 6's pre-commit gate with this question:

> "Markdown-only profile detected. Where do you want the rough-in specs to land?
>
> **(a) Appended to the existing `frame-NN.md` file** as a new `## Rough-in M<#>` section. Pro: keeps everything for one framing in one file. Con: frame-NN.md gets long for milestones with many R-issues.
>
> **(b) New per-milestone rough-in markdown file** at `docs/cbk/frame-NN-M<#>-rough-in.md`. Pro: each milestone's rough-in lives in its own file, easier to scan. Con: more files in the framings directory.
>
> Default is (a) for milestones with 3-4 R-issues and (b) for milestones with 5+ R-issues. Override?"

The default heuristic (3-4 → append, 5+ → new file) is rough-in's proposal; the user picks. The choice is recorded in the spec output so re-rough-in of the same milestone uses the same pattern (consistency within a workstream).

**MCP operations rough-in calls in markdown-only profile**:

| Operation | Tool | Purpose |
|---|---|---|
| `get_file_contents` | github MCP | Read scaffold.md, blueprint.md, frame-NN.md, foundation docs (same as github-only) |
| `create_or_update_file` | github MCP | Append rough-in spec content to `frame-NN.md` (option a) or create `frame-NN-M<#>-rough-in.md` (option b) |
| `create_or_update_file` | github MCP | Append the rough-in event entry to `docs/cbk/README.md` index |

**No planning-backend operations.** The atomic transition collapses to a single half (just the markdown commits). There is no rollback to perform on the planning side because no planning ops ran. Partial failure recovery applies to the markdown commits only — if the spec file commit succeeds but the framing.md index update fails, surface and ask the user to verify state before retry.

**Body source**: in markdown-only mode, rough-in still reads the `cascade-rough-in.md` template from `.github/ISSUE_TEMPLATE/` (because the templates may exist on disk even in markdown-only repos — scaffold commits them regardless of profile, since they're workspace infrastructure that serves both human-created Issues and the cascade's automated runs). The template's section structure is used inside the markdown spec content too, so the spec headings are consistent across profiles. If the disk template is missing, fall back to the bundled copy.

**Slug + F-number inheritance**: in markdown-only mode, rough-in inherits the slug + F-number from the framing's milestone entry in `frame-NN.md` directly, not from a parent issue title (because there isn't one). This is the one place where markdown-only mode's inheritance differs from github-only mode, and it works because both modes share the same slug-naming convention in the markdown.

**No `/finish` slash command in markdown-only mode** — `/finish` is a Claude Code slash command that reads GitHub Issues, and there are no Issues in markdown-only mode. The user executes rough-in specs by reading the markdown spec directly and running Claude Code (or implementing manually) against it. The bootstrap-finish skill, when it lands, will produce a CLAUDE.md section for github-only profile only — markdown-only users will need to read specs from disk and execute manually, which is the trade-off they accepted at scaffold's HITL gate when picking the profile.

## Profile detection during inheritance

Rough-in detects the profile by reading `scaffold.md`'s `profile:` field during Step 1 (inheritance). The profile field is one of:

- `github-only` — proceed with the full validated path
- `opinionated` — surface the kara-validated status, ask user to confirm Linear workspace is configured, proceed with caution
- `markdown-only` — surface the markdown-only acknowledgment in the inheritance gate (parallel to blueprint's markdown-only acknowledgment), confirm with user that the planning-backend half of every commit will be skipped, proceed with the markdown-only flow

If `scaffold.md` is missing, rough-in surfaces the gap and asks the user to either provide the file or confirm the profile manually. **Do not assume a default profile** — the choice is too consequential to fall back silently.

If `scaffold.md` exists but the `profile:` field is missing or has a value not in the three-profile set, surface as scaffold drift and ask the user to either correct scaffold.md or confirm the intended profile manually.

## Cross-profile invariants

Some things are the same regardless of profile:

- **Step 1-5 are profile-agnostic** — inheritance, milestone selection, research, issue plan drafting, and individual spec drafting produce the same content regardless of where it eventually lands. The profile only affects Step 6 (the commit).
- **The deferred meta-issues pre-flight check runs in every profile** — even in markdown-only mode, rough-in must read the framing's Pre-flight checks table and verify any meta-issue blocking the milestone is resolved. The check is independent of whether a planning backend exists.
- **The slug + F-number inheritance discipline applies in every profile** — slugs are inherited from the parent (framing sub-issue title in github-only, framing's milestone entry in markdown-only, Linear Milestone in opinionated). Never re-derive.
- **The R-number sequence discipline applies in every profile** — R-numbers continue across re-rough-ins, never reset to R1, even in markdown-only mode where there's no planning-backend collision risk. The discipline exists for grep-ability and historical record consistency, not just collision avoidance.
- **The HITL gate language adapts but the gate itself runs in every profile** — even in markdown-only mode where there's no planning-backend half to mention, the final pre-commit gate still runs and the user still explicitly approves the markdown commits.
- **Token pressure honesty applies in every profile** — never silently produce partial work, always surface partial state.

## Profile-aware failure mode summary

A quick reference of which failure modes apply to which profiles:

| Failure mode | github-only | opinionated | markdown-only |
|---|---|---|---|
| Missing parent framing sub-issue | ✅ | ✅ (Linear Milestone) | n/a (read frame-NN.md directly) |
| Slug or F-number mismatch | ✅ | ✅ | ✅ |
| R-number collision | ✅ | ✅ | ✅ |
| Orphan sub-sub-issues from partial step-1/step-2 failure | ✅ | n/a (single-step) | n/a |
| Re-rough-in supersedes already-completed work | ✅ | ✅ | ✅ |
| Re-rough-in rollback complexity | ✅ | ✅ | ✅ (markdown-side only) |
| Inherited Projects v2 PAT scope assumption | ✅ | n/a | n/a |
| Issue template missing on disk | ✅ | ✅ | ✅ (template still relevant for markdown structure) |
| Idempotency violations on partial-completion re-runs | ✅ | ✅ | ✅ |

The github-only profile has the most failure modes because it's the most automation-heavy. The opinionated profile has fewer because Linear's single-step issue creation eliminates the orphan-issue failure mode. The markdown-only profile has the fewest because there's no planning backend at all — but it still has most of the cascade-discipline failure modes (slug mismatch, R-number collision, re-rough-in handling) because those exist in the cascade's logical layer, not just in the planning-backend layer.
