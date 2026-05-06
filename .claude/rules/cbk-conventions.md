# Cascade Conventions — Project Template

Operational rules for this project's instantiation of the AI-assisted development cascade (consultation → scaffold → blueprint → framing → rough-in → `/finish`). The cascade skills under `.claude/skills/` provide the **portable** cascade tooling; this file records **project-specific overrides and operational choices**. When the skills cite "see your project's `cbk-conventions.md`," this is what they're pointing at.

> **This file is a template.** Copy it into a target project's `.claude/rules/cbk-conventions.md` and fill in the bracketed placeholders (`<TEAM>`, `<workstream-slug>`, paths, etc.) with the project's actual choices. Each section describes a choice space; this template offers a sensible default plus the alternatives. The defaults reflect the patterns most projects converge on, but every section can be overridden.

The principle:

- **Skills stay portable; project specifics live here.** The cascade skills can be installed in any project; they describe choice spaces and patterns generically. The project's specific instantiation — flat layout vs nested, branch-naming pattern, label scheme, operational evidence — lives in this file.
- **Two-way reference.** Skills cite this file as the project-level override surface. This file cites skills as the upstream pattern source. No project-specific identifiers (issue keys, framing numbers, slug names) should leak into skill content.
- **Exercised, not provisional.** Sections in a project's filled-in copy of this file should record choices the project has actually exercised, not guesses. As the project runs cascade cycles, update this file with what proved out.

## Cascade artifact layout — flat (default) or nested

The default layout is **flat** under `docs/cbk/`:

```
docs/cbk/
├── README.md          ← chronological cascade-events index (status column)
├── problem_brief.md   ← from consultation
├── scaffold.md        ← from scaffold
├── blueprint.md       ← from blueprint phase
├── frame-01.md        ← first framing event
└── frame-NN.md        ← future framings, numbered chronologically across all workstreams
```

**Why flat is the default**: each cascade event is a single document. Most projects' framing events produce one `frame-NN.md` per event, not a multi-file bundle. The flat layout matches the ADR pattern (immutable, sequentially numbered, append-only, README-indexed) — a close analog to a single-document cascade artifact.

**Chronological tracking lives in two places**:

1. **`docs/cbk/README.md`** — across-cascade timeline. Status column tracks Active / Completed / Superseded by frame-NN / Abandoned. Mirrors the shape of `docs/adr/README.md`.
2. **`## Rough-in events` section inside each frame-NN.md** — per-frame timeline of rough-in events that built against that framing. Append-only table within the frame document. Useful for "which milestones from this framing have been roughed-in, on what date, with what capstone PR" lookups without leaving the frame.

Both serve distinct jobs: README is the across-frames table of contents; in-frame events log is the per-frame log. Don't conflate.

**When to override to nested**: if a project's framing events produce multi-file bundles (analogous to spec-kit's `specs/feature-X/{spec,plan,tasks}.md`), override to nested layout:

```
docs/cbk/
├── README.md
├── ...prior phase artifacts...
└── framings/
    ├── frame-01/
    │   ├── frame-01.md
    │   └── ...sibling docs...
    └── frame-02/
        └── ...
```

## Sub-issue hierarchy — three levels

The default hierarchy is **three levels**, on whichever planning backend the project picked at scaffold (Linear, GitHub Issues with sub-issues, or markdown-only):

```
Initiative / project root             (one per cascade phase or per project)
└── Workstream parent issue           (e.g. "[<workstream-slug>] <Workstream name>")
    └── Framing F sub-issue           (e.g. "[<workstream-slug>:F<#>] <Milestone intent>")
        └── Rough-in R sub-sub-issue  (e.g. "[<workstream-slug>:F<#>:R<#>] <R-issue intent>")
```

**Why three levels**: matches Linear's UX ceiling for sub-issue rollup rendering (4-level deep starts breaking project table view per Linear community discussion). Also matches Spec Kit's `Specify → Plan → Tasks` and Kiro's `Requirements → Design → Tasks` decomposition depth — 3 is the natural shape for spec-driven cascade work.

**Don't add a fourth tier.** If a rough-in R-issue is too large, decompose during `/finish`'s plan-mode (plan mode is the decomposition engine for sub-R work). Don't create R.M.K-style fourth-level sub-issues.

## Title-prefix scheme

Title prefixes are the structural identifier across the cascade. They survive any planning-backend mirror, the `gh` CLI output, and the Linear / GitHub Issues web UIs:

| Level | Title prefix | Example shape |
|---|---|---|
| Workstream parent | `[<workstream-slug>]` | `[<slug>] <Workstream name>` |
| Framing F sub-issue | `[<workstream-slug>:F<#>]` | `[<slug>:F1] <Milestone intent>` |
| Rough-in R sub-sub-issue | `[<workstream-slug>:F<#>:R<#>]` | `[<slug>:F1:R1] <R-issue intent>` |

**Workstream slugs** are locked at blueprint and immutable across the workstream's lifetime. The slug list lives in `docs/cbk/blueprint.md` § Workstreams. Each project fills in its own list there; this file shouldn't enumerate them.

Slug stability is load-bearing: branches reference it (`<type>/<TEAM>-<N>-<slug>...`), labels reference it (`workstream:<slug>`), commit messages reference it. A workstream that needs renaming triggers a re-blueprint, not in-place mutation.

## Trace ID convention

Acceptance criteria in framing F-issues carry inline IDs of the form `[F<N>.AC<M>]`:

```markdown
### M3 acceptance criteria

- [F3.AC1] <Boundary or behavioural criterion> ...
- [F3.AC2] <Test-runnable criterion> ...
- [F3.AC3] <Demonstrable-capability criterion> ...
```

Rough-in R-issues then reference these IDs in their own `## Acceptance criteria` and `## Test plan` sections:

```markdown
## Acceptance criteria

- [F3.AC1] <how this R-issue satisfies AC1>
- [F3.AC2] `<test command>` passes (covers F3.AC2 — <criterion summary>)
```

**Why trace IDs**: closes the framing → rough-in → test round-trip auditability. Without them, the link from "what M3 promised" → "what R-issue X implemented" → "what test verifies it" is implicit. With them, test-runner output cites `F3.AC2` and the framing F-issue body shows where it landed. Adopted from Kiro's `_Requirements: 1.1, 3.2_` pattern, simplified to a single bracketed ID inline rather than a separate trailing field.

**Backfill on existing artifacts is optional**: framings produced before adopting this convention shouldn't be retroactively edited (per ADR-pattern append-only discipline applied to cascade events). Adopt forward from whichever frame-NN this convention starts in.

## Branch naming

Pattern: `<type>/<TEAM>-<N>-<short-slug>`

- `<type>` is one of the [Conventional Commits](https://www.conventionalcommits.org/) types: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `perf`, `style`, `build`, `ci`
- `<TEAM>-<N>` is the planning-backend issue ID in lowercase (e.g. `abc-27` if the team prefix is ABC). For markdown-only projects, this collapses to `<short-slug>` only.
- `<short-slug>` is a kebab-case description of the work, ~3-6 words

Example shapes:
- `chore/<team>-27-foundation-close-integration-capstone`
- `feat/<team>-42-llm-backend-behaviour`
- `fix/<team>-118-asr-buffer-overflow`

**Why include the issue ID**: Linear's GitHub integration auto-links branches to issues when the issue ID appears anywhere in the branch name (substring match, not full match — see [Linear's branch-naming announcement](https://linear.app/changelog/2020-04-13-branch-naming)). Including the ID eliminates the magic-word-in-PR-body fallback path. The body marker (`Closes <TEAM>-N`) still works, but the branch-name path fires earlier and is more reliable.

`/finish` already creates branches in this shape; this convention codifies what was already happening.

## Closes-keyword conventions

PR body close markers depend on which planning backend the project picked at scaffold:

- **Linear-tracked issues** (opinionated profile): `Closes <TEAM>-N` in the PR **body** (not just the title — body is the durable surface; titles can be edited at squash-merge time without affecting the close marker)
- **GitHub-tracked issues** (github-only profile, or any GitHub-only sub-issue): `Closes #N` in the PR body
- **Both can coexist** in the same PR body if the PR closes one of each.
- **Markdown-only projects**: there are no issue-tracker entities to close; the cascade-event log entries are updated by hand.

Linear's recognized close-markers (case-insensitive): `close/closes/closed/closing`, `fix/fixes/fixed/fixing`, `resolve/resolves/resolved/resolving`, `complete/completes/completed/completing`, `implements`. See [Linear's GitHub integration docs](https://linear.app/docs/github-integration). Non-closing link-only markers: `ref`, `references`, `part of`, `related to`, `contributes to`, `towards`. GitHub recognizes a similar but smaller set.

PR titles are Conventional Commits format (`<type>(<scope>)?: <subject>`). The parenthetical issue mentions in titles are descriptive; the load-bearing close markers go in the body.

## Sub-issue rollup

For Linear projects, two team-level workflow settings (`Settings > Team > Workflow`) interact with the cascade:

- **(a) Auto-complete parent when all sub-issues complete** — **enable**. Matches cascade semantics: parent F-issue closes when all R-issues close; parent workstream issue closes when all F-issues close.
- **(b) Auto-complete sub-issues when parent completes** — **leave off**. The cascade may create rough-in R-issues in advance with `blockedBy` chains; auto-completing them when the parent closes would prematurely close work that's still open.

For GitHub-only projects, sub-issue rollup is a Projects v2 view configuration rather than a closure-cascading setting; the equivalent is just rendering the parent/child tree on a board view.

## `[skip ci]` rule

Permitted on:
- **Docs-only commits** — STANDARDS.md, CLAUDE.md, ARCHITECTURE.md, ADR additions, README updates
- **Planning-artifact commits** — `docs/cbk/*` updates (blueprint.md, frame-NN.md, README.md)
- **Cascade-event commits** — rough-in event-log entries appended to a frame, post-merge cascade-event records

Not permitted on:
- Code commits (any source, library, or test directories)
- Test commits
- `.github/workflows/*.yml` changes (CI workflows themselves — they need to verify they don't break the gates they install)
- Task-runner config changes (`mise.toml`, `Makefile`, `justfile`, `package.json` scripts — these can affect build behavior)
- `.claude/hooks/*` changes (hooks are operational; need verification they don't break)

**Squash-merge interaction**: if the project squash-merges to main, the squashed commit message on `main` is what matters for `[skip ci]`; per-branch commits with `[skip ci]` skip the per-branch CI runs, but the squash commit's message determines whether `main`'s CI runs.

**Auto-review trap — the CI-skip marker on the HEAD commit at flip-time blocks auto-review workflows.** GitHub's CI-skip matcher applies to the HEAD commit's message regardless of which event fires. If a docs commit that legitimately carries the marker happens to be HEAD when a `pull_request: ready_for_review` (or `synchronize`, `reopened`) event fires, any auto-review workflow (e.g., `.github/workflows/claude-review.yml`) is also skipped — not just the per-branch CI run you intended to skip. The symptom is a draft → ready flip with no auto-review comment.

How to avoid:
- When `/finish` (or any branch-prep flow) ends with marker-carrying docs commits, **end the branch on a non-marker commit** before flipping to ready. An empty commit (`git commit --allow-empty -m "ci: trigger auto-review workflow"`) is the cleanest fix when no other change is queued.
- Order commits so the last one is a code/test commit (which can't carry the marker per the rules above) — when feasible, it removes the foot-gun automatically.

**Substring trap — quoting the literal marker token in a commit-message body re-triggers the matcher.** GitHub's match is a substring scan across the entire message, not anchored to the subject line or the end. A commit whose body explains *why* it's a fix for this trap, but quotes the literal token while explaining, is itself skipped. Use a paraphrase (e.g., "the CI-skip marker", "the conventional skip-tag") in prose; reserve the literal `[skip ci]` for the actual flag at the end of the subject line where you intend it to fire.

## Methodology — choice space

Blueprint picks a methodology from the register based on team shape, appetite, and quality bar. Common choices:

- **Linear cycles ON vs OFF**: solo + AI-assisted work usually doesn't need sprint synchronization → cycles disabled. Larger teams with ceremony benefit from cycles → enabled.
- **Issue execution: Kanban-flow vs sprint-bounded**: with cycles disabled, pick the next available issue (top of the Ready column), finish, merge, next. With cycles enabled, sprint scope sets the work-in-flight bound.
- **WIP limit**: `/finish` enforces single-issue execution by virtue of the slash-command shape, so a hard "one issue at a time" limit is the natural floor.
- **Appetite tagging**: framings can tag milestones with [Shape Up](https://basecamp.com/shapeup) appetite (small ~1 week, medium ~3 weeks, big ~6 weeks). Calendar weeks are aspirational, not enforced.

Whichever methodology blueprint picks, this section in the project's filled-in copy of `cbk-conventions.md` should record: cycles on/off, pull-flow style, WIP discipline, appetite-tagging convention. Without this record, the methodology selection from blueprint is hard to operate against.

## ADR index sync

Every ADR addition (and every supersession) updates **multiple indexes** in lockstep:

1. **`docs/adr/README.md`** — canonical ADR index with status, dates, and short descriptions
2. **`docs/ARCHITECTURE.md` § Decisions log** — orientation-level table mirroring the README
3. **`docs/ARCHITECTURE.md` § Configurability summary** (if the project uses a configurability-first principle)
4. **`docs/cbk/blueprint.md` § Stack decisions** — also updated for post-blueprint ADRs (since blueprint.md is itself a cascade artifact)

The `adr-new` skill (at `.claude/skills/adr-new/SKILL.md`) automates the cross-index sync. Manual ADR creation works but is error-prone (multiple indexes to keep in sync); use the skill.

ADR immutability should be enforced two ways:
- **A PreToolUse hook** at `.claude/hooks/protect-immutable-adrs.sh` blocks Claude Code edits to existing ADR files
- **A CI lint** at `.github/workflows/adr-immutability-check.yml` diffs `docs/adr/[0-9]{4}-*.md` files in PRs and fails on changes to existing ADRs (closes the raw-git-access gap that the hook can't catch)

Both belong in any project that takes ADRs seriously; the kit's `adr-new` skill assumes both exist.

## Spec-Kit vocabulary mapping

The cascade phases align with the converging industry vocabulary from [GitHub Spec Kit](https://github.com/github/spec-kit) and [Amazon Kiro](https://kiro.dev/docs/specs/) (per [Martin Fowler / Birgitta Böckeler's SDD survey](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html)):

| Cascade phase | Spec Kit equivalent | Kiro equivalent | Job |
|---|---|---|---|
| `consultation` + `blueprint` | `Specify` | `Requirements` | Capture problem, scope, success criteria |
| `blueprint` ADRs | `Constitution` | (no analog — Kiro lacks ADR layer) | Immutable architectural decisions |
| `framing` | `Plan` | `Design` | Decompose project into milestones |
| `rough-in` | `Tasks` | `Tasks` | Decompose milestones into ready-to-implement specs |
| `/finish` | `Implement` | (Kiro IDE) | Execute one task end-to-end |

Use this mapping when explaining the cascade to someone familiar with Spec Kit or Kiro. Don't rename the cascade phases to match — the cascade vocabulary (consultation / blueprint / framing / rough-in / finish) is established and load-bearing across the skill set. The mapping is a Rosetta stone, not a rename.

## Mutation discipline

| Artifact | Mutation rule | Supersession pattern | Rationale |
|---|---|---|---|
| `docs/adr/[0-9]{4}-*.md` | **Immutable** | New ADR with `Supersedes: ADR-NNNN` field; old ADR's status changes to "Superseded by ADR-MMMM" | ADR-0000 immutability discipline + hook enforcement + CI lint |
| `docs/cbk/blueprint.md` | **Append-only for new ADRs** (the Stack decisions table); otherwise immutable to preserve cascade history | Re-blueprint creates new file | Blueprint is a cascade event; mutation breaks the audit trail |
| `docs/cbk/frame-NN.md` | **Append-only for `## Rough-in events` table**; otherwise immutable post-commit | Re-framing creates `frame-MM.md` with `Supersedes: frame-NN` field; old frame's status → "Superseded" | Frames are cascade events; rough-in events are the timeline log |
| `docs/cbk/README.md` | **Append-only for new entries**; status column updates allowed | Status updates are mutations to single column, not whole-file rewrites | Status changes (Active → Superseded → Completed) need to flow |
| `docs/STANDARDS.md`, `docs/ARCHITECTURE.md`, `CLAUDE.md` | **Freely mutable** | n/a — living docs | Project-context docs evolve with the project; git history is the version archive |
| `.claude/rules/*.md` | **Freely mutable** | n/a | Operational rules; mutations are routine |
| `.claude/skills/*` | **Freely mutable** within the local copy | n/a | Tooling content; mutations refine the cascade |
| Code | **Freely mutable** | n/a | Standard code evolution |

Cascade events being append-only is structurally important: the cascade IS the audit trail of decisions. A new framing supersedes an old one with a new file; the old one stays in `docs/cbk/` for future readers to understand "we used to think X, now we think Y."

## HITL gate load-bearing heuristics

When deciding whether a HITL gate in a cascade skill's standard mode should remain a gate, become a trip-wire (auto-checklist with no approval), or be removed entirely:

**Load-bearing if any of**:
- Next step writes outside the conversation (planning-backend `save_issue`, `git commit`, `git push`, `gh pr create` — Bezos one-way door)
- Reviewer accountability differs from originator's (agent-creates / user-verifies pattern)
- A miss propagates at >1× cost downstream (e.g. wrong workstream picked → 5 wrong sub-issues created)
- The artifact materially changes phase-to-phase (judgment-not-mechanics)
- Reviewer fatigue isn't already saturated (≤3 gates per phase at this point in the session)

**Trip-wire-able if**:
- Check is mechanical (file exists, count matches, format valid)
- Action is reversible at zero cost (text output to chat, no commits)
- A later gate covers the same risk (no duplicate review surface needed)
- The artifact is verbose enough that rubber-stamping is rational (>500 lines of generated markdown the reviewer skims)

**Should be removed entirely if**:
- It exists only because "approval feels rigorous"
- Its removal exposes no downstream one-way door
- It has empirically never produced a "no/edit" response across N cascade runs

**Standard-mode target**: 3 gates per cascade phase, with trip-wires filling the rest of the safety surface. Per the [Verschlimmbesserung](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html) / [Scott Logic "3.5 hours reviewing markdown"](https://blog.scottlogic.com/2025/) / [Digital Applied gate framework](https://www.digitalapplied.com/blog/agentic-workflow-approval-gate-framework-governance) consensus: 4+ gates per phase trains rubber-stamp culture, which silently degrades the load-bearing gates.

## Trip-wire / phase-exit checklist pattern

Every cascade phase exits via a `## Phase exit checklist` — a short, auto-checkable list that fires before the next phase starts. The checklist is **not a gate** (no user approval) but is a **safety surface** (the cascade skill stops if any item fails).

Example shape (rough-in's checklist):

```markdown
## Phase exit checklist

- [ ] Frame-NN.md fully read; in-doc `## Rough-in events` table examined
- [ ] All `blockedBy` dependencies for the milestone being roughed-in are closed-completed
- [ ] Pre-flight checks (deferred meta-issues + blocking deps + per-workstream invariants) all green
- [ ] Idempotency check passed (no existing R-issues for this milestone)
- [ ] Spec-drafting movement produced 2-6 R-issue specs (per review-unit discipline)
- [ ] Each R-issue spec has all 8 sections present (Context, Assumptions, Implementation, AC, Test plan, Done signal, Dependencies, PR contract)
```

The checklist runs auto-checkable; surfacing only failures. Per [GitHub Spec Kit's `⚠️ CRITICAL: No user story work can begin until this phase is complete` pattern](https://github.com/github/spec-kit/blob/main/spec-driven.md), modified for the cascade's gate-trim posture.

## Recommended planning-backend settings

Beyond what the cascade skills auto-configure, projects using a planning backend require these settings (one-time setup per project):

**Linear (opinionated profile)**:
1. **Cycles**: enable or disable per the methodology section above
2. **Workflow > Auto-complete parent when all sub-issues complete**: ON (matches cascade rollup semantics)
3. **Workflow > Auto-complete sub-issues when parent completes**: OFF (preserves R-issue independence)
4. **Workflow > Sub-issue rollup display**: ON (renders the cascade-tree view in project tables)
5. **Branch name template** (in `Settings > Workspace > Branch names`): `{type}/{teamPrefix}-{issueIdNumber}-{title}` matches the `<type>/<TEAM>-N-<slug>` convention

**GitHub Projects v2 (github-only profile)**:
1. Create a Projects v2 board with sub-issue rendering enabled
2. Configure swimlanes grouped by parent issue
3. Status field with the cascade-relevant states (Backlog / Ready / In progress / In review / Done)

These are user actions, not auto-applied via MCP. Document the post-merge step in any PR that affects the cascade.

## Quick reference

| What you're doing | Where the convention lives |
|---|---|
| Naming a cascade event | Flat `docs/cbk/<artifact>.md`, sequential numbering |
| Updating the cascade-events index | `docs/cbk/README.md` (status column) |
| Naming a planning-backend issue | `[<workstream-slug>:F<#>:R<#>] <intent>` |
| Naming a branch | `<type>/<TEAM>-<N>-<short-slug>` |
| Closing an issue from a PR | `Closes <TEAM>-N` (Linear) or `Closes #N` (GitHub) in PR body |
| Adding an ADR | `adr-new` skill (auto-syncs indexes) |
| Adding a `## Pre-flight checks` row to a frame | Append-only edit to the frame's `## Pre-flight checks` table |
| Skipping CI on a docs-only commit | Append `[skip ci]` to commit message subject |
| Mid-session gate trimming | See § HITL gate load-bearing heuristics |
| Phase exit | Run the `## Phase exit checklist` from the relevant cascade skill |

## Verification

After major edits to cascade skills or to a project's filled-in copy of this file, run these greps to confirm alignment. Adapt the patterns to the project's actual identifiers (issue-key prefix, framing-number range, project-specific names).

```bash
# Path drift: skills should not reference nested layout if the project picked flat (or vice versa)
! grep -rn "framings/\|framing\.md\b" .claude/skills/

# Stub language: no stubs should remain in the project's instantiation
! grep -rni "v1 stub\|stub status\|fall back to manual" .claude/skills/

# Section-name renames: ensure deprecated names don't reappear in skill content
! grep -rn "Movement [0-9]\|## Movement" .claude/skills/
! grep -rn "Deferred meta-issues" .claude/skills/

# Trace ID convention present in templates
grep -rn "\[F[0-9]\.AC[0-9]\]" .claude/skills/*/references/templates/

# Portability: project-specific identifiers must NOT appear in skill content.
# Replace <TEAM> with the project's actual issue-key prefix (e.g. ABC, FOO, BAR).
# Replace <project-name> with the project's name.
! grep -rn "<TEAM>-[0-9]\|<project-name>" .claude/skills/

# This file is referenced from CLAUDE.md (or wherever the project's project-instructions live)
grep "@.claude/rules/cbk-conventions.md" CLAUDE.md
```

## References

- Upstream cascade tooling: `.claude/skills/{consultation,scaffold,blueprint,framing,rough-in}/SKILL.md`
- Cascade events for this project (once they exist): `docs/cbk/README.md`, `docs/cbk/blueprint.md`, `docs/cbk/frame-NN.md`
- Project docs (once they exist): `CLAUDE.md`, `docs/STANDARDS.md`, `docs/ARCHITECTURE.md`, `docs/adr/`
- Industry references: [GitHub Spec Kit](https://github.com/github/spec-kit), [Amazon Kiro Specs](https://kiro.dev/docs/specs/), [Tessl SDD](https://docs.tessl.io/use/spec-driven-development-with-tessl), [Martin Fowler / Birgitta Böckeler — SDD survey](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html), [Addy Osmani — How to write a good spec for AI agents](https://addyosmani.com/blog/good-spec/), [Anthropic Claude Code best practices](https://code.claude.com/docs/en/best-practices)
- Linear references: [GitHub integration](https://linear.app/docs/github-integration), [Parent / sub-issue auto-complete](https://linear.app/changelog/2024-09-06-auto-close-parent-and-sub-issues), [Branch naming](https://linear.app/changelog/2020-04-13-branch-naming)
