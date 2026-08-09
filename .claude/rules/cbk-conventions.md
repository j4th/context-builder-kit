# Cascade Conventions — Project Template

Operational rules for this project's instantiation of the AI-assisted development cascade (consultation → scaffold → blueprint → framing → rough-in → `/finish`). The cascade skills under `.claude/skills/` provide the **portable** cascade tooling; this file records **project-specific overrides and operational choices**. When the skills cite "see your project's `cbk-conventions.md`," this is what they're pointing at.

> **This file is a template.** Copy it into a target project's `.claude/rules/cbk-conventions.md` and fill in the bracketed placeholders (`<TEAM>`, `<workstream-slug>`, paths, etc.) with the project's actual choices. Each section describes a choice space; this template offers a sensible default plus the alternatives. The defaults reflect the patterns most projects converge on, but every section can be overridden.

The principle:

- **Skills stay portable; project specifics live here.** The cascade skills can be installed in any project; they describe choice spaces and patterns generically. The project's specific instantiation — flat layout vs nested, branch-naming pattern, label scheme, operational evidence — lives in this file.
- **Two-way reference.** Skills cite this file as the project-level override surface. This file cites skills as the upstream pattern source. No project-specific identifiers (issue keys, framing numbers, slug names) should leak into skill content.
- **Exercised, not provisional.** Sections in a project's filled-in copy of this file should record choices the project has actually exercised, not guesses. As the project runs cascade cycles, update this file with what proved out.

## Surface inventory

A single glanceable manifest of where every surface for this project actually lives, so any "see your project's `cbk-conventions.md`" pointer resolves in one place. Fill in the bracketed values (delete rows that don't apply):

- **Code + cascade artifacts (the constant):** `<repo URL>`
- **Planning backend (`<GitHub Issues | Linear | in-repo markdown>`):** `<workspace / initiative / team+key / project pointers, as applicable>`
- **Knowledge backend (`<Notion | none>`):** `<hub URL + MCP server, if configured>`
- **Upstream / pre-cascade docs:** `<path to any frozen reference material, or "none">`
- **Problem brief / scaffold output:** `docs/cbk/problem_brief.md` · `docs/cbk/scaffold.md`
- **Tooling conventions:** `<record any project-specific tool / MCP-selection conventions here — e.g. which code-intelligence or live-docs MCP to prefer over the built-ins — or "defaults">`

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
| Bug-lane issue (externally-sourced) | `[<workstream-slug>:bug]` | `[<slug>:bug] <intent>` |
| Enhancement-lane issue (small capability) | `[<workstream-slug>:enh]` | `[<slug>:enh] <intent>` |
| Deferred meta-issue | `[<workstream-slug>:meta]` | `[<slug>:meta] <setup/decision intent>` |
| Meta-issue R sub-sub-issue | `[<workstream-slug>:<meta-tag>:R<#>]` | `[<slug>:<meta-tag>:R1] <intent>` |

**Workstream slugs** are locked at blueprint and immutable across the workstream's lifetime. The slug list lives in `docs/cbk/blueprint.md` § Workstreams. Each project fills in its own list there; this file shouldn't enumerate them.

Slug stability is load-bearing: branches reference it (`<type>/<TEAM>-<N>-<slug>...`), labels reference it (`workstream:<slug>`), commit messages reference it. A workstream that needs renaming triggers a re-blueprint, not in-place mutation.

A deferred meta-issue (`[<slug>:meta]`) can itself be roughed-in into R sub-sub-issues when a setup/decision meta is too large for one `/finish`. Its children take `[<slug>:<meta-tag>:R<#>]`, where `<meta-tag>` is a **short descriptive slug for that specific meta** (not the literal `meta`) — a workstream routinely carries several `[<slug>:meta]` issues, so `[<slug>:meta:R<#>]` would collide across them. The `<meta-tag>` is chosen at the meta's rough-in (a meta has no F-number — it is not a framing milestone) and stays stable across its children, keeping the hierarchy grep-able.

## Contribution intake — bug lane + enhancement lane

The cascade is **top-down**: workstream → framing → rough-in → `/finish` answers *"what capability are we building."* Externally-sourced reports — a collaborator's bug, a feature request, a member-filed ticket — are **bottom-up** (*"something's broken"* / *"I want X"*) and must **not** be forced through framing. This section defines the bottom-up lane. The `/intake` command (`.claude/commands/intake.md`) walks it — investigate + reproduce, or scope the acceptance shape — and `/enrich` (`.claude/commands/enrich.md`) is the single-issue sibling of `rough-in` that finishes an enhancement-lane spec.

### Front door — a holding surface for raw arrivals

Raw, externally-sourced reports land in a **holding surface** that is strictly *pre-`/intake`* — a place for incoming work *before* it is investigated and shaped, kept separate from cascade-structured issues. Pick whatever your planning backend offers:

- **Linear** — the team's **Triage** inbox (GitHub issues arrive via the Linear GitHub integration; members file directly).
- **GitHub Issues** — a `triage` label (or an unassigned / no-status column on the Projects v2 board) for issues not yet shaped.
- **Markdown-only** — an `## Inbox` section at the top of the cascade-events index (or a dedicated `docs/cbk/inbox.md`).

Once `/intake` shapes a report it **leaves the holding surface** carrying its cascade labels (`cascade-depth:*` and/or `enhancement`) and does **not** return. The complementary "shaped but not yet `/finish`-able" pool lives on a *label* axis (§ Awaiting cascade work), not on the holding surface — two non-overlapping surfaces: the holding state for raw arrivals, the `enhancement` label for post-`/intake` candidates awaiting `/enrich` or framing.

### Provenance marker

Every externally-sourced issue carries a provenance label; cascade-native issues carry none. This is the queryable external-vs-native distinction:

- **`source:<origin>`** — e.g. `source:github` (originated as a GitHub issue; also created in the repo so issue forms auto-apply it), `source:linear` (filed directly by a collaborator), or a generic `source:external`. "All external" is the union of the `source:*` labels.

The reporter and the origin URL also go in the issue body.

### The discriminator — four routes

`/intake` investigates + reproduces (a bug) or scopes the acceptance shape (a capability), then classifies into exactly one route:

| Incoming | Route | Skips framing? | Lands as |
|---|---|---|---|
| **Bug** in existing code | Bug lane | yes | Roughed-in bug issue under the relevant workstream — `/finish`-able directly |
| **Small net-new capability** (one `/finish`, no decomposition) | Enhancement lane | yes | A thin `[<slug>:enh]` candidate under the workstream, **enriched in place** by `/enrich` → `/finish`-able (no framing milestone) |
| **Large net-new capability / idea** | Framing backlog | no | Framing candidate under the workstream; **not** `/finish`-able until framed + roughed-in |
| **Cascade / tooling gap** | Cascade/tooling lane | usually | A meta-issue or roughed-in directly |

**Small vs large capability.** A *small* capability is one a single `/finish` can fully implement + test + review **without decomposing into multiple R-issues**: a bounded feature (≈ [Shape Up](https://basecamp.com/shapeup) "small" appetite) with no sub-dependencies on other unbuilt capabilities and no multi-workstream spread. It skips the framing milestone and is enriched in place by `/enrich` into a `[<slug>:enh]` roughed-in issue. A *large* capability — needs sequencing into multiple R-issues, depends on a prior capability landing first, or spans workstreams — goes to the framing backlog. **When `/intake` is unsure, it defaults to framing** (the conservative call); the operator can always collapse a frame into an enhancement-lane issue if the capability proves simpler than expected.

### The bug-lane convention

An investigated, reproduced bug becomes a roughed-in-quality issue **without an F-number**:

- **Title:** `[<slug>:bug] <intent>`. `<slug>` is a locked **workstream** slug (`docs/cbk/blueprint.md` § Workstreams) — *not* a label-only area. `/finish` validates the slug against the blueprint list, so cascade/tooling bugs do **not** use the bug lane; they route via the discriminator's "cascade / tooling gap" row.
- **Parent:** the workstream `[<slug>]` issue directly (no framing/F sub-issue between them).
- **Labels:** the rough-in R-issue label set for a bug — the workstream label (`workstream:<slug>`), `cascade-depth:roughed-in`, the planning backend's bug type label, and the `source:*` provenance label. Apply the type label at issue-creation (`save_issue`) time, not retroactively — some planning backends cache the suggested branch name from the creation-time type label (the real branch is hand-named at `/finish` time regardless).
- **Body:** the same eight sections `/finish` requires (`## Context` … `## PR contract`), generated by `/intake` with a verified failing test in `## Test plan` and `## Dependencies: None` (a bug fix to existing code has no rough-in dependencies).
- **Branch (at `/finish` time):** `fix/<TEAM>-<N>-<slug>`.
- **It skips framing.** There is no new capability to decompose; the investigation already produced the spec.

`/finish` accepts this `[<slug>:bug]` format alongside the standard `[<slug>:F<N>:R<M>]` rough-in format.

### The enhancement-lane convention

A small, scoped net-new capability becomes a roughed-in-quality issue **without an F-number** — the bottom-up sibling of the bug lane, mirroring it 1:1 except the spec comes from `/enrich`'s brainstorm + investigation (not a bug reproduction):

- **Title:** `[<slug>:enh] <intent>`. `<slug>` is a locked **workstream** slug — *not* a label-only area (a small cascade/tooling capability routes via the "cascade / tooling gap" row, not the enhancement lane).
- **Parent:** the workstream `[<slug>]` issue directly (no framing/F sub-issue between them).
- **Labels:** the rough-in R-issue label set — the workstream label (`workstream:<slug>`), `cascade-depth:roughed-in`, the type label matching the work (a feature type for a net-new capability, an improvement type for a small refactor/chore), and the `source:*` provenance label when externally-sourced via `/intake`. The transient framing-backlog `enhancement` marker that `/intake` applied to the *candidate* is **dropped** when the issue is enriched to roughed-in — `cascade-depth:roughed-in` is the readiness signal; the type label is the persistent nature (the same type-persists / state-graduates split the bug lane uses).
- **Body:** the same eight sections `/finish` requires (`## Context` … `## PR contract`), generated by **`/enrich`** (not `/intake`) with acceptance criteria sufficient for a single `/finish` and `## Dependencies: None` unless the capability depends on a prior rough-in issue. `/enrich` also posts a **provenance comment** capturing the framing + rough-in reasoning it collapsed inline.
- **Branch (at `/finish` time):** `feat/<TEAM>-<N>-<slug>` (or the type-matching prefix).
- **It skips framing.** The capability is small enough that `/enrich`'s scoped spec suffices; there is no milestone to decompose.

`/finish` accepts this `[<slug>:enh]` format alongside the `[<slug>:F<N>:R<M>]` rough-in and `[<slug>:bug]` bug-lane formats.

### Net-new *large* capabilities do NOT skip framing

If `/intake` classifies a report as a *large* net-new capability (multi-R, sub-dependent, or cross-workstream), it files a framing candidate and says so — it does **not** pretend the issue is `/finish`-able, and it does **not** route it through the enhancement lane. The operator runs `framing` → `rough-in` on it like any other capability. Honesty about the cascade boundary is the rule: only *small* capabilities (one `/finish`, no decomposition) take the enhancement lane.

### Awaiting cascade work — the not-yet-`/finish`-able holding signal

`/intake` files both non-bug routes — the enhancement-lane `[<slug>:enh]` candidate and the large-capability framing candidate — with the transient **`enhancement`** marker and **without** `cascade-depth:roughed-in`. That marker is the cascade's "shaped by `/intake`, not yet ready for `/finish`" signal, so an **open issue still carrying `enhancement`** is exactly a candidate awaiting a human-or-skill action — the queryable "holding" set. Surface it with your planning backend's **saved-view / filtered-query** mechanic, **not** a workflow-state change (candidates stay in the default backlog state `save_issue` assigns; the holding signal rides the *label* axis every skill already writes):

- **A saved view / filter "Awaiting cascade work"** — filter on **`label = enhancement`** (optionally `AND state is not Done/Canceled`). Surfaces both non-bug routes in one place. Mid-cascade issues — framed `[<slug>:F<#>]` F-issues (`cascade-depth:framed`), meta-issues, roughed-in R-issues — correctly stay out; they don't carry `enhancement`.
- For **markdown-only** projects, the equivalent is a section or query over the cascade-events index for entries tagged `enhancement`.

**Graduation (leaving the view).** Both routes **auto-clear** `enhancement`, so a candidate drops out the instant it graduates — no manual step, no orphans:

- **Enhancement lane** — `/enrich` swaps `enhancement` → `cascade-depth:roughed-in`.
- **Framing backlog** — `framing` absorbs the candidate into a milestone and reconciles it via one of: **promote** it 1:1 to that `[<slug>:F<#>]` F-issue (`save_issue` by id → retitle `[<slug>:F<#>] …`, drop `enhancement`, add `cascade-depth:framed`), or **close it as superseded** by the F-issue(s) it informed (`save_issue` by id → status Canceled + a comment linking the F-issue).

**Why a label, not the holding state.** The holding/triage surface is reserved for raw *pre-`/intake`* arrivals (§ Front door) and is driven by your backend's native inbox lifecycle (accept / decline / merge / snooze on Linear; the equivalent triage actions elsewhere). Setting a *shaped* candidate back into the holding state (a) clashes with that pre-investigation meaning, (b) collides with the native inbox actions — an inbox-clearer could accept/decline a held candidate — and (c) has **no exit** for framing candidates (they graduate via `framing → rough-in`, neither of which mutates backend state), so they'd accumulate there. The label view has none of these failure modes and needs no skill change.

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

**Two-level anchor in practice.** Rough-in R-issues routinely author their own numbered `## Acceptance criteria` list — derived from, but not identical to, the parent F-issue's ACs — and the R-issue is the unit `/finish` executes against, so **tests trace to the R-issue's own AC numbering** (e.g. a test docstring tagging `[<ISSUE-KEY> AC2]`) while the R-issue's AC list is what cites the parent's `[F<N>.AC<M>]` IDs. Both levels are trace anchors: the F-level IDs close the framing → rough-in loop; the R-level tags close the rough-in → test loop. Record the project's chosen test-side tag form here so conformance reviewers don't flag the R-level form as trace-ID drift.

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

### Linear `{type}` placeholder — set the type label at issue creation (Linear only)

*Applies only when the planning backend is Linear.* Linear's branch-name template (`Settings > Workspace > Branch names`) resolves `{type}` from the issue's built-in **Feature / Bug / Improvement** type label — and **caches the resolved value into the issue's `gitBranchName` at creation time**. Relabeling afterward does *not* update the suggested branch name, and an issue with no type label defaults to `Feature`, producing `feature/…` branches for `chore`/`docs`/`refactor` work that aren't in the Conventional Commits type list. So the type label must be set in the **initial** `save_issue` call, not retroactively. Mapping from the Conventional Commits type to Linear's coarser taxonomy:

| Conventional Commits type | Linear type label |
|---|---|
| `feat` | Feature |
| `fix` | Bug |
| everything else (`chore`, `docs`, `refactor`, `test`, `perf`, `style`, `build`, `ci`) | Improvement |

The rough-in / `/intake` / `/enrich` flows set this at issue-creation time — see the rough-in skill's planning-backend matrix.

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

**Required-checks-block-merge trap — a skip-marked HEAD commit can't merge under strict branch protection.** When `main` requires status-check contexts with "require branches to be up to date" (strict), the CI-skip marker suppresses the CI workflow entirely, so those required contexts **never report** — the platform parks them as "Expected — Waiting for status to be reported" and the merge stays blocked indefinitely. (A separate always-on workflow can still run, making the PR *look* green while it stays unmergeable.) Net: `[skip ci]` saves nothing for a PR that has to merge through branch protection. For a docs-only PR bound for `main`, either (a) skip the marker on the final commit so CI runs and reports, or (b) keep the marker on the content commits but end the branch on a non-marker commit (`git commit --allow-empty -m "ci: run gates to satisfy required checks"`) before requesting merge. Same root cause and fix as the auto-review trap; the marker still earns its keep on intermediate WIP commits that don't open a PR to `main`.

## Dependency settle-window — supply-chain discipline

No dependency version is adopted until its release is **≥ `<N>` days old** (7 is a common default) — a *settle window* so a yanked or day-zero-compromised release is caught upstream before this project is first-to-install. The window applies to **every lockfile-managed ecosystem** in the repo, not just the primary language's.

**Enforcement is per-ecosystem, at the tool that resolves versions.** Each lockfile-managed surface gets the release-age floor wired into its own mechanism — your ecosystem's cooldown mechanism (e.g. the dependency-update bot's cooldown setting, the package manager's release-age floor on its resolve / add / non-frozen sync operations, or a CI guard that fails the build when an active ecosystem is missing the floor). Record the concrete `<N>` and the per-ecosystem mechanism this project uses in this section of the filled-in copy — the pattern is portable, the config keys are not.

Two invariants keep the window honest; violate either and the policy inverts from protection into liability:

- **Cooldowns gate VERSION-updates only — security advisories still patch instantly.** The settle window slows *routine* version bumps, never security fixes. **Never widen a window to delay a security patch.** The whole point is to run behind on convenience updates and current on security ones.
- **Floors are a compatibility contract, not a volume lever.** A version-update fires on a new *release*, not on the floor value, so raising the floor (the oldest version the project supports) does **not** reduce update volume. Bump a floor only for a security advisory or a hard requirement — never to "catch up to latest". The one lever on update *volume* is the sweep schedule (how often routine bumps are batched — e.g. monthly).

**When you touch dependency plumbing:**

- **Adding a new ecosystem to the update bot** (a new package-ecosystem entry, uncommenting a stub): it MUST carry the release-age floor. A bare ecosystem with no floor should fail the CI guard rather than merge.
- **Scaffolding a new lockfile-managed surface** (e.g. a second language, or a frontend workstream landing): apply that ecosystem's release-age analogue in the *same* change that introduces the lockfile — don't defer it to a follow-up.
- **Lockfiles are tool-managed, not hand-edited.** Version changes flow through the package manager's lock / sync commands, never a manual edit to the lockfile. Where a project enforces this with a PreToolUse hook, note the hook path here.

Dependency-update-bot PRs are triaged by `pr-review.md`'s four-class rubric; this section states the adoption policy those PRs are gated by.

## Methodology — choice space

Blueprint picks a methodology from the register based on team shape, appetite, and quality bar. Common choices:

- **Linear cycles ON vs OFF**: solo + AI-assisted work usually doesn't need sprint synchronization → cycles disabled. Larger teams with ceremony benefit from cycles → enabled.
- **Issue execution: Kanban-flow vs sprint-bounded**: with cycles disabled, pick the next available issue (top of the Ready column), finish, merge, next. With cycles enabled, sprint scope sets the work-in-flight bound.
- **WIP limit**: `/finish` enforces single-issue execution by virtue of the slash-command shape, so a hard "one issue at a time" limit is the natural floor.
- **Appetite tagging**: framings can tag milestones with [Shape Up](https://basecamp.com/shapeup) appetite (small ~1 week, medium ~3 weeks, big ~6 weeks). Calendar weeks are aspirational, not enforced.
- **Flop / kill checkpoint** (optional): a pre-declared point at which the project honestly stops rather than continuing on sunk cost — a Shape-Up-adjacent circuit breaker (e.g. "if the core hypothesis hasn't proven out by milestone N, we end it deliberately"). Record the criterion if the project wants one.

Whichever methodology blueprint picks, this section in the project's filled-in copy of `cbk-conventions.md` should record: cycles on/off, pull-flow style, WIP discipline, appetite-tagging convention. Without this record, the methodology selection from blueprint is hard to operate against.

## Verify-against-reality before a one-way door (optional practice)

The portable framing skill trusts documentation. A project can add a heavier discipline if its stack is fast-moving or its data assumptions are load-bearing: **before committing a frame (or any one-way-door decision), verify the load-bearing assumptions against reality** rather than the docs. Two shapes, adopt if useful:

- **Prove-it spike** — a throwaway run against the real stack for a single load-bearing recipe (does this library API / this catalog / this data shape actually behave as the docs claim?), discarded once it answers the question. Distinct from a *shippable* spike milestone.
- **Rigor pass** — for a high-stakes frame, a short pre-commit pass that live-probes tooling currency and key data/interface assumptions, optionally with a multi-lens adversarial review of the draft frame before it's locked.

If a project adopts either, record its trigger here (e.g. "rigor pass on any frame that introduces a new external dependency"). Large research/rigor outputs can be committed as a companion file (`frame-NN-<slug>.md`) the frame links and rough-in inherits, rather than inlined or discarded.

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
| `docs/cbk/frame-MM.md` (additive increment) | **New file** (next sequential number); the prior frame is not mutated and stays `Active` | *No* supersession — an additive increment carries a `Builds on: frame-NN` header (not `Supersedes`); both frames stay `Active` and their open milestones coexist | Not every new framing replaces: an increment extends a workstream whose prior milestones are still valid and open, so the prior frame must not flip to `Superseded` (see framing SKILL.md Step 2 pattern D) |
| `docs/cbk/frame-MM.md` (milestone-scoped re-frame) | **New file** (next sequential number); the prior frame is not mutated | Header states `Supersedes only milestone M<N> of frame-NN`; the prior frame's index status is annotated `Active (M<N> superseded by frame-MM)` via the permitted status-column mutation; the retired milestone's acceptance-criteria set is recorded as retired-un-executed in the new frame | One milestone's shape can fail while its siblings are built and Done; whole-frame supersession would falsify the siblings' history (see framing SKILL.md Step 2 pattern E) |
| `docs/cbk/README.md` | **Append-only for new entries**; status column updates allowed | Status updates are mutations to single column, not whole-file rewrites | Status changes (Active → Superseded → Completed) need to flow |
| `docs/STANDARDS.md`, `docs/ARCHITECTURE.md`, `CLAUDE.md` | **Freely mutable** | n/a — living docs | Project-context docs evolve with the project; git history is the version archive |
| `.claude/rules/*.md` | **Freely mutable** | n/a | Operational rules; mutations are routine |
| `.claude/skills/*` | **Freely mutable** within the local copy | n/a | Tooling content; mutations refine the cascade |
| Code | **Freely mutable** | n/a | Standard code evolution |

Cascade events being append-only is structurally important: the cascade IS the audit trail of decisions. A new framing supersedes an old one with a new file; the old one stays in `docs/cbk/` for future readers to understand "we used to think X, now we think Y."
**ADR supersession has more than one grain.** The `docs/adr/*` row above shows whole-ADR supersession; two finer-grained relationships sit alongside it, both preserving the parent's immutability (neither edits the parent file):

- **Refine** — `Refines: ADR-NNNN (Dn, …)` in the child's header narrows or clause-level-clarifies a specific decision `Dn` in the parent **without invalidating it**. The parent stays **Accepted**; both parent and child are consulted for conformance. Use when implementation reveals an accepted clause was written too generally and needs a scoped reading, not a reversal. The parent gains **no back-pointer** (it is immutable) and **no status change** — discoverability comes from the child's `Refines:` field plus the child's ADR-index row.
- **Clause-scoped supersede** — `Supersedes: ADR-NNNN Dn` reverses only decision `Dn` of the parent while the parent's other clauses stand. The parent stays **Accepted** (it is not wholly superseded); the child's index row names the specific clause it replaces.

**Reviewers that check ADR conformance must follow the `Refines:` chain.** When an ADR intersecting a diff names a refiner (or a clause-scoped superseder), load that child too and apply its scoped clauses — a parent read in isolation yields the pre-narrowing reading. The kit's `adr-conformance-reviewer` agent (see `.claude/rules/pr-review.md` § Project-local agents to dispatch alongside) is where this chain-following lives.

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

**GitHub Projects v2 (when planning backend = GitHub Issues)**:
1. Create a Projects v2 board with sub-issue rendering enabled
2. Configure swimlanes grouped by parent issue
3. Status field with the cascade-relevant states (Backlog / Ready / In progress / In review / Done)

These are user actions, not auto-applied via MCP. Document the post-merge step in any PR that affects the cascade.

## Knowledge backend — operator's specific choices

If the project's knowledge backend is Notion (the v1 reference impl), record the operator's specific choices here. The operational contract for *how* the cascade uses the knowledge backend lives at `.claude/rules/knowledge-backend.md` — this section records *what* the operator has wired up for this specific project.

If knowledge backend = `none`, this section can stay blank or be deleted entirely.

```
Knowledge backend: Notion | none

Notion-specific (if Notion):

Hub URL:            <https://notion.so/...>
Hub location:       <teamspace> > <Projects DB> > <project name>
Engineering Wiki:   <URL or "n/a — cross-project artifacts live under hub">

Sub-pages adopted (mark which the project actually uses; see
`knowledge-backend.md` for the recommended vocabulary):
  [ ] Start here / Onboarding
  [ ] Decision Log              (DB)
  [ ] Meeting Notes             (DB)
  [ ] Research & Reference      (DB)
  [ ] Runbooks & Playbooks      (DB)
  [ ] Cascade Artifacts (mirror) (sync-block page)
  [ ] People & Context
  [ ] Archive

Verification cadence (per DB; default per knowledge-backend.md):
  Decision Log:           <90 / 180 / 365 days; default 180>
  Meeting Notes:          <cadence or "n/a">
  Research & Reference:   <cadence or "n/a">
  Runbooks & Playbooks:   <cadence or "n/a">

Notion MCP server:        <Notion's official MCP | other; specify>

Workspace deviations from kit recommendation (if any):
  <e.g., "ADRs is the local name for what the kit calls Decision Log">
  <e.g., "We use a flat page hierarchy, no Projects DB rollup">
  <e.g., "Verification disabled on Research & Reference (org policy)">
```

The kit's brownfield detection (run by scaffold's Stage 2 when knowledge backend = Notion) will surface what already exists in the operator's Notion. Record the post-detection state here so later phases inherit it rather than re-detecting cold.

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
| Knowledge backend operations (Notion reads/writes, HITL discipline, brownfield detection, lazy provisioning) | See `.claude/rules/knowledge-backend.md`; project-specific values in § Knowledge backend above |

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

# Knowledge-backend portability: project-specific Notion identifiers must
# NOT appear in skill content (only in this file or in `.cascade/backends.toml`).
! grep -rn "notion\.so/\|notion\.site/" .claude/skills/

# Old "opinionated profile" terminology must NOT appear in skill content
# (the constant + two axes refactor removed this concept).
! grep -rn -i "opinionated profile\|opinionated_profile" .claude/skills/

# This file is referenced from CLAUDE.md (or wherever the project's project-instructions live)
grep "@.claude/rules/cbk-conventions.md" CLAUDE.md
```

## References

- Upstream cascade tooling: `.claude/skills/{consultation,scaffold,blueprint,framing,rough-in}/SKILL.md`
- Cascade events for this project (once they exist): `docs/cbk/README.md`, `docs/cbk/blueprint.md`, `docs/cbk/frame-NN.md`
- Project docs (once they exist): `CLAUDE.md`, `docs/STANDARDS.md`, `docs/ARCHITECTURE.md`, `docs/adr/`
- Industry references: [GitHub Spec Kit](https://github.com/github/spec-kit), [Amazon Kiro Specs](https://kiro.dev/docs/specs/), [Tessl SDD](https://docs.tessl.io/use/spec-driven-development-with-tessl), [Martin Fowler / Birgitta Böckeler — SDD survey](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html), [Addy Osmani — How to write a good spec for AI agents](https://addyosmani.com/blog/good-spec/), [Anthropic Claude Code best practices](https://code.claude.com/docs/en/best-practices)
- Linear references: [GitHub integration](https://linear.app/docs/github-integration), [Parent / sub-issue auto-complete](https://linear.app/changelog/2024-09-06-auto-close-parent-and-sub-issues), [Branch naming](https://linear.app/changelog/2020-04-13-branch-naming)
