# Profile-aware behavior — GitHub-only vs Linear+GitHub

How framing's behavior differs between the two backend profiles. Read this once at session start to understand the routing, then refer back when an operation is profile-specific.

The profile is determined by `scaffold.md`'s Cascade metadata section. **Read it before doing anything profile-dependent.** Do not guess the profile from context — every later phase trusts that framing correctly routed based on the scaffold output.

For project-specific overrides (workstream slugs, label schemes, Linear team name, branch-naming convention), see the project's `.claude/rules/cbk-conventions.md`. This file is the **portable** reference; project specifics live there.

## Quick reference matrix

| Operation | GitHub-only | Linear+GitHub |
|---|---|---|
| Read inheritance (prior phase artifacts) | `docs/cbk/*.md` via GitHub MCP | Same path, same MCP |
| Read prior framings | `docs/cbk/frame-NN.md` (flat) or `docs/cbk/framings/frame-NN.md` (nested) per project's cbk-conventions.md | Same path, same MCP |
| Cascade events index | `docs/cbk/README.md` (chronological, status column) | Same |
| Workstream parent issue | n/a — workstream lives only as a row in `blueprint.md` § Workstreams | Linear issue parented under the phase project (created at scaffold or blueprint time) |
| Research phase | No profile difference | No profile difference |
| Refined definition produced in | `docs/cbk/frame-NN.md` | Same file, plus a Linear F-issue with body summarizing the refined definition |
| Milestones produced in | Same file, sections under `## M<n>` headings | Same file; one Linear F-issue per milestone parented under the workstream issue |
| Interface Commitments table | Lives in the markdown file | Lives in the markdown file (Linear doesn't model these natively) |
| Pre-flight checks table | Lives in the markdown file under `## Pre-flight checks` | Same |
| Cascade-events index update | Append row to `docs/cbk/README.md` via GitHub MCP | Same |
| Handoff context | Lives in frame-NN.md | Lives in frame-NN.md (Linear F-issue body mirrors the milestone capability statement) |
| Linear MCP needed? | No | Yes — `mcp__linear__get_issue`, `mcp__linear__list_issues`, `mcp__linear__save_issue` |
| HITL gate count | 5 / 3 / 1 by rigor mode | Same |

## GitHub-only profile behavior

The default profile when scaffold picked github-only. Framing reads inputs from the GitHub repo via GitHub MCP, produces `frame-NN.md` + `docs/cbk/README.md` index update, and commits them back via GitHub MCP. No Linear, no cross-tool integration.

The structural fact that shapes everything: **github-only's three-level planning hierarchy (project board → milestone → issue) maps onto framing's output without needing a fourth level**. Framing's output IS the project-level content — it lives as markdown in `docs/cbk/` rather than as a planning entity. GitHub repo milestones may optionally be created via GitHub MCP (one per framing milestone) if the user wants tracking, but this is optional and not the source of truth — the markdown file is.

Concretely:

1. **Read inheritance** via GitHub MCP file-read against the repo URL from scaffold.md
2. **Read prior framings** via GitHub MCP — all `frame-NN.md` files that have interface commitments relevant to this project
3. **Run all five steps** (inheritance → project selection → research → refined definition → milestones) inside chat with HITL gates
4. **Commit frame-NN.md** to `docs/cbk/frame-NN.md` (or `docs/cbk/framings/frame-NN.md` if nested layout) via GitHub MCP after the final HITL gate
5. **Append to `docs/cbk/README.md`** (the chronological cascade-events index) via GitHub MCP in the same commit
6. **Optionally create GitHub repo milestones** if the user wants them — ask explicitly, don't create by default

**No Linear operations**, ever, in github-only mode. If the user asks "where do I see this in Linear?" the answer is "Linear isn't in scope for this profile — the cascade is in github-only mode, so framings live as markdown documents in `docs/cbk/`. If you want Linear, that would mean switching profiles, which is a scaffold-level decision."

## Linear+GitHub profile behavior

When scaffold picked Linear+GitHub, framing produces both the markdown artifact AND a Linear F-issue per milestone. The markdown is the canonical record (audit trail, timeline, interface commitments); Linear is the planning surface (assignment, status flow, cross-issue queries, the operator's daily board).

The structural fact that shapes everything: **Linear's parent/sub-issue hierarchy makes the cascade's three-level decomposition (workstream → framing F → rough-in R) directly representable**. Framing creates the F-level sub-issues under the workstream's parent issue; rough-in creates the R-level sub-sub-issues under each F. Status rolls up via Linear's parent auto-complete setting (configured at team level — see project's `cbk-conventions.md`).

### Entity hierarchy (Linear+GitHub)

```
Initiative                          (created by scaffold)
└── Project (one per phase)         (created by blueprint, e.g. "Phase 1 — MVP")
    └── Workstream parent issue     (created by blueprint or at first framing for the workstream;
        │                            title `[<workstream-slug>] <Workstream Name>`)
        └── Framing F sub-issue     (created by framing, this skill;
            │                        title `[<workstream-slug>:F<#>] <intent>`)
            └── Rough-in R sub-sub-issue   (created by rough-in, downstream skill)
```

The workstream parent issue is created **before** framing runs — typically at blueprint commit (one parent per workstream slug from blueprint's Workstreams table). Framing's pre-flight check confirms the parent exists; if it doesn't, framing surfaces the gap rather than creating it (workstream issue creation is blueprint's responsibility, not framing's).

### Concrete operations

1. **Read inheritance** — same as github-only via GitHub MCP file-read.
2. **Read prior framings** — same as github-only.
3. **Read workstream parent issue** via `mcp__linear__get_issue` with `id: "<TEAM>-<N>"` and `includeRelations: true`. Confirm:
   - Issue is open (status type `unstarted` or `started`)
   - Title matches `[<workstream-slug>] *` pattern
   - Labels include `workstream:<slug>` (per project's cbk-conventions.md)
4. **Idempotency check** — list existing F-issues under the parent via `mcp__linear__list_issues` with `parentId: "<parent-id>"`. If an F-issue already exists for this milestone (`[<slug>:F<#>] *` matching), surface to the user and either resume the existing draft or abort.
5. **Run five steps** (inheritance → project selection → research → refined definition → milestones) with HITL gates per rigor mode.
6. **Atomic transition** at the final HITL gate:
   - Commit `frame-NN.md` + `docs/cbk/README.md` index update via GitHub MCP (single commit, conventional-commits message)
   - Create one Linear F-issue per milestone via `mcp__linear__save_issue`:
     - `parentId`: the workstream parent issue's ID
     - `team`: the team key from scaffold.md / cbk-conventions.md
     - `title`: `[<workstream-slug>:F<#>] <milestone-intent>`
     - `description`: milestone capability statement + Acceptance criteria with `[F<N>.AC<M>]` trace IDs (per cbk-conventions.md trace-ID convention) + reference back to `docs/cbk/frame-NN.md` for full context
     - `labels`: `workstream:<slug>` + `cascade-depth:framed` + appetite label (`appetite:small|medium|big` per blueprint)
     - `assignee`: per scaffold.md / cbk-conventions.md
     - `blockedBy`: empty initially (rough-in chains R-issues with blockedBy; framing doesn't pre-chain F-issues unless milestones depend on each other across workstreams)
   - On partial failure (markdown committed but Linear creation failed, or vice versa), STOP and surface the partial state — do not retry blindly. The user decides recovery.
7. **Append a row to `docs/cbk/README.md`** describing this framing event in the same commit as the frame-NN.md commit.
8. **Optional Linear project description sync** — if the user wants the Linear phase project's description to mirror the workstream's framing summary, propose a manual paste (Linear MCP doesn't yet expose project-description editing in a stable way; document as user-action).

### What's profile-neutral (same in both)

- The frame-NN.md file content itself — Purpose, Approach, Components, Boundaries, Interface Commitments, Pre-flight checks, Open questions, Milestones with rough issues
- Trace ID convention (`[F<N>.AC<M>]`)
- Pre-flight checks pattern
- HITL gate count and timing
- Inheritance read protocol
- Research phase
- The Interface Commitments table (markdown only — Linear doesn't model commitments)

### Linear MCP error handling

If Linear MCP calls fail mid-transition (network, auth, schema mismatch):

- **Before any markdown commits**: abort and surface — no partial state on disk.
- **After markdown commits, before Linear writes**: complete the markdown commit, then surface the Linear gap. The user can either retry the Linear creation manually in the UI (fall back to manual creation) or re-run framing's transition step alone (idempotent if titles/labels/parent match — list-then-skip behavior).
- **Mid-Linear-batch** (some F-issues created, others not): surface partial state. The user decides whether to manually create the remaining via Linear UI or re-run with skip-existing semantics.

This is the cascade's general principle: honesty about partial state is more valuable than automated recovery that might make things worse.

### Sub-issue rollup behavior (Linear team setting)

The cascade-correct rollup posture (configured once at team level — see project's `cbk-conventions.md` for the recommended settings):

- **Auto-complete parent when all sub-issues complete**: ON. Matches cascade rollup semantics — when all R-issues under an F close, the F closes; when all F-issues under a workstream close, the workstream closes.
- **Auto-complete sub-issues when parent completes**: OFF. Preserves the independence of pre-created downstream issues; closing a parent should never silently close work that's still open.

These are user-action settings — not auto-applied via MCP. Document in the project's cbk-conventions.md and in any PR that affects the cascade.

## The Interface Commitments table is profile-neutral

The Interface Commitments table in `frame-NN.md` is **always markdown**, never a Linear-native entity. The reason is that Linear doesn't model cross-project interface commitments natively — there's no "commitment" entity type. Introducing one would require a custom field schema and significant UI work.

The Interface Commitments table stays in the markdown file in both profiles. Users who want Linear-side visibility into interface commitments can paste the table into the Linear project description manually. Automating this is a future enhancement.

## Profile detection failure modes

- **Guessing the profile from context.** Always read `scaffold.md` first. The Cascade metadata section names the profile explicitly — there's no excuse for inferring it from the user's word choice.
- **Assuming Linear MCP is connected in Linear+GitHub mode.** It might not be. Probe early via a simple `mcp__linear__list_teams` call; if missing, surface the gap and offer to either (a) wait while the user connects Linear MCP, (b) fall back to manual Linear operations after the markdown commit, or (c) switch to github-only fallback for this framing.
- **Committing frame-NN.md to a different location based on profile.** Don't. The path is determined by the project's cbk-conventions.md (flat or nested), not by the profile. Both profiles use the same path.
- **Creating workstream parent issues from framing.** Don't. Workstream parents are created by blueprint (or at scaffold for greenfield projects). If the parent doesn't exist when framing starts, surface the gap — this is a sign the cascade was entered at the wrong phase.
- **Skipping the atomic-transition partial-state surface.** Linear MCP failures aren't an excuse to silently skip Linear writes after markdown commits. Surface, document, defer to user.

## Light-mode behavior

Profile detection and routing is non-negotiable in light mode. The light-mode collapses apply to *what framing produces* (fewer gates, batched HITL, etc.), not to which profile the operations target.

For Linear+GitHub profile + light mode: still run the full atomic transition. Light mode collapses HITL gates (one final review of frame-NN.md + the Linear F-issue plan as a single batch), not the structural commitments to both surfaces.

## Project-specific evidence

The patterns in this file are project-agnostic. For project-specific operational evidence (which Linear team, which framings have run, which PRs landed), see the project's `.claude/rules/cbk-conventions.md`.
