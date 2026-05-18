# Planning-backend matrix for framing

How framing's behavior differs across the planning backend axis (`github-issues` / `linear` / `in-repo-markdown`). Knowledge backend concerns are **orthogonal** to this file — those live in `.claude/rules/knowledge-backend.md`.

The planning backend is determined by `scaffold.md`'s Cascade metadata section. **Read it before doing anything planning-axis-specific.** Do not guess from context — every later phase trusts that framing correctly routed based on the scaffold output.

For project-specific overrides (workstream slugs, label schemes, Linear team name, branch-naming convention), see the project's `.claude/rules/cbk-conventions.md`. This file is the **portable** reference; project specifics live there.

## Quick reference matrix

| Operation | `github-issues` | `linear` | `in-repo-markdown` |
|---|---|---|---|
| Read inheritance (prior phase artifacts) | `docs/cbk/*.md` via GitHub MCP | Same | Same |
| Read prior framings | `docs/cbk/frame-NN.md` (flat) or `docs/cbk/framings/frame-NN.md` (nested) per project's cbk-conventions.md | Same | Same |
| Cascade events index | `docs/cbk/README.md` (chronological, status column) | Same | Same |
| Workstream parent entity | GitHub parent Issue (created at blueprint) | Linear issue parented under the phase project (created at scaffold or blueprint) | n/a — workstream lives only as a row in `blueprint.md` § Workstreams |
| Research phase | No axis difference | No axis difference | No axis difference |
| Refined definition produced in | `docs/cbk/frame-NN.md` | Same file, plus a Linear F-issue with body summarizing the refined definition | Same file only |
| Milestones produced in | Same file, sections under `## M<n>` headings | Same file; one Linear F-issue per milestone parented under the workstream issue | Same file only |
| Interface Commitments table | Lives in the markdown file | Lives in the markdown file (Linear doesn't model these natively) | Same |
| Pre-flight checks table | Lives in the markdown file under `## Pre-flight checks` | Same | Same |
| Cascade-events index update | Append row to `docs/cbk/README.md` via GitHub MCP | Same | Same |
| Handoff context | Lives in frame-NN.md | Lives in frame-NN.md (Linear F-issue body mirrors the milestone capability statement) | Lives in frame-NN.md only |
| Linear MCP needed? | No | Yes — `mcp__linear__get_issue`, `mcp__linear__list_issues`, `mcp__linear__save_issue` | No |
| HITL gate count | 5 / 3 / 1 by rigor mode | Same | Same |

## `github-issues` planning behavior

The most common case. When scaffold picked `github-issues`, framing reads inputs from the GitHub repo via GitHub MCP, produces `frame-NN.md` + `docs/cbk/README.md` index update, and commits them back via GitHub MCP. No Linear, no cross-tool integration.

The structural fact that shapes everything: **GitHub's three-level planning hierarchy (parent Issue → sub-issue → sub-sub-issue) maps onto framing's output without needing a fourth level**. Framing's output IS the project-level content — it lives as markdown in `docs/cbk/` plus framing sub-issues parented under the workstream's parent Issue (already created by blueprint).

Concretely:

1. **Read inheritance** via GitHub MCP file-read against the repo URL from scaffold.md
2. **Read prior framings** via GitHub MCP — all `frame-NN.md` files that have interface commitments relevant to this project
3. **Read workstream parent Issue** via `issue_read` — confirm it exists, is open, title matches `[<workstream-slug>] *` pattern, has the `workstream:<slug>` label
4. **Idempotency check** — list existing F-sub-issues under the parent. If an F-sub-issue already exists for this milestone (`[<slug>:F<#>] *` matching), surface to the user and either resume or abort.
5. **Run all five steps** (inheritance → project selection → research → refined definition → milestones) inside chat with HITL gates
6. **Atomic transition** at the final HITL gate:
   - Commit `frame-NN.md` + `docs/cbk/README.md` index update via GitHub MCP (single commit)
   - Create one F-sub-issue per milestone via `issue_write` + `sub_issue_write add` parented under the workstream Issue
7. **No Linear operations**, ever, in `github-issues` mode.

## `linear` planning behavior

When scaffold picked `linear`, framing produces both the markdown artifact AND a Linear F-issue per milestone. The markdown is the canonical record (audit trail, timeline, interface commitments); Linear is the planning surface (assignment, status flow, cross-issue queries, the operator's daily board).

The structural fact that shapes everything: **Linear's parent/sub-issue hierarchy makes the cascade's three-level decomposition (workstream → framing F → rough-in R) directly representable**. Framing creates the F-level sub-issues under the workstream's parent issue; rough-in creates the R-level sub-sub-issues under each F. Status rolls up via Linear's parent auto-complete setting (configured at team level — see project's `cbk-conventions.md`).

### Entity hierarchy (`linear`)

```
Initiative                          (created by scaffold)
└── Project (one per phase)         (created by blueprint, e.g. "Phase 1 — MVP")
    └── Workstream parent issue     (created by blueprint or at first framing for the workstream;
        │                            title `[<workstream-slug>] <Workstream Name>`)
        └── Framing F sub-issue     (created by framing, this skill;
            │                        title `[<workstream-slug>:F<#>] <intent>`)
            └── Rough-in R sub-sub-issue   (created by rough-in, downstream skill)
```

The workstream parent issue is created **before** framing runs — typically at blueprint commit. Framing's pre-flight check confirms the parent exists; if it doesn't, framing surfaces the gap rather than creating it.

### Concrete operations

1. **Read inheritance** — same as `github-issues` via GitHub MCP file-read.
2. **Read prior framings** — same.
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

### What's planning-axis-neutral (same across all three)

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

- **Auto-complete parent when all sub-issues complete**: ON. Matches cascade rollup semantics.
- **Auto-complete sub-issues when parent completes**: OFF. Preserves the independence of pre-created downstream issues.

These are user-action settings — not auto-applied via MCP. Document in the project's cbk-conventions.md and in any PR that affects the cascade.

## `in-repo-markdown` planning behavior

When scaffold picked `in-repo-markdown`, framing's planning-side writes collapse — no Linear F-issues, no GitHub F-sub-issues. The `frame-NN.md` markdown is the entire planning artifact. The cascade event log (`docs/cbk/README.md`) is the timeline.

Concretely:

1. **Read inheritance** — same paths, same GitHub MCP.
2. **Read prior framings** — same.
3. **No workstream parent issue read** — workstream lives only as a row in `blueprint.md` § Workstreams.
4. **No idempotency check against an external system** — but framing should still check that `frame-NN.md` doesn't already exist with the same number (avoid clobbering prior cascade events).
5. **Run five steps** with HITL gates as normal.
6. **Atomic transition collapses** to a single half: commit `frame-NN.md` + `docs/cbk/README.md` index update via GitHub MCP. No Linear writes; no GitHub F-sub-issue creation.
7. Planning-side setup steps that would land in a GitHub or Linear F-issue (assignment, status flow) instead stay in `frame-NN.md` as `## Manual setup` or similar — operators work from the markdown directly.

## The Interface Commitments table is planning-axis-neutral

The Interface Commitments table in `frame-NN.md` is **always markdown**, never an external-system entity. The reason is that neither GitHub Issues nor Linear models cross-project interface commitments natively. The table stays in the markdown file across all three planning axes.

Operators who want external-system visibility into interface commitments can paste the table into a GitHub issue description or a Linear project description manually. Automating this is a future enhancement.

## Planning-axis detection failure modes

- **Guessing the planning backend from context.** Always read `scaffold.md` first. The Cascade metadata section names the planning axis explicitly.
- **Assuming Linear MCP is connected when planning = `linear`.** It might not be. Probe early via a simple `mcp__linear__list_teams` call; if missing, surface the gap and offer to either (a) wait while the operator connects Linear MCP, (b) fall back to manual Linear operations after the markdown commit, or (c) switch to `github-issues` fallback for this framing.
- **Committing frame-NN.md to a different location based on planning axis.** Don't. The path is determined by the project's cbk-conventions.md (flat or nested), not by the planning axis. All three planning axes use the same path.
- **Creating workstream parent issues from framing.** Don't. Workstream parents are created by blueprint. If the parent doesn't exist when framing starts, surface the gap — this is a sign the cascade was entered at the wrong phase.
- **Skipping the atomic-transition partial-state surface.** Linear MCP failures aren't an excuse to silently skip Linear writes after markdown commits. Surface, document, defer to user.

## Light-mode behavior

Planning-axis detection and routing is non-negotiable in light mode. The light-mode collapses apply to *what framing produces* (fewer gates, batched HITL, etc.), not to which planning backend the operations target.

For `linear` planning + light mode: still run the full atomic transition. Light mode collapses HITL gates (one final review of frame-NN.md + the Linear F-issue plan as a single batch), not the structural commitments to both surfaces.

## Knowledge backend interactions

The knowledge backend axis (`notion` / `none`) is orthogonal to this file. When knowledge = `notion`:

- Framing's optional inheritance fetch (read patterns from Notion at the inheritance step) is governed by `.claude/rules/knowledge-backend.md` § "When to read" — read-primary, opt-in, no default fetches.
- Framing's optional Notion-write gate (promoting a cross-project meta-issue to a Notion runbook when it surfaces material that genuinely spans repos) is governed by `.claude/rules/knowledge-backend.md` § "When to write" — default-SKIP, HITL-gated, fires only for cross-project meta-issues (NOT for normal milestone deferred-decision meta-issues, which stay in the planning backend or in-repo markdown).

Neither knowledge-backend interaction affects the planning-axis behavior documented above. The two axes can be mixed freely.

## Project-specific evidence

The patterns in this file are project-agnostic. For project-specific operational evidence (which Linear team, which framings have run, which PRs landed), see the project's `.claude/rules/cbk-conventions.md`.
