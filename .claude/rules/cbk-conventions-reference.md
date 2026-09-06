---
paths:
  - "docs/cbk/**"
  - "docs/adr/**"
  - ".claude/skills/**"
  - ".claude/commands/**"
  - ".claude/rules/cbk-conventions*.md"
  - ".claude/hooks/**"
  - ".claude/settings*.json"
  - ".github/**"
  - ".gitignore"
  - ".gitattributes"
  - "mise.toml"
  - "<manifest-and-lockfile-globs — e.g. **/package.json, **/Cargo.toml, **/*.lock>"
---

# Cascade Conventions — the reference half

> **Path-scoped.** This file holds the sections of `cbk-conventions.md` a session needs only when it touches a cascade artifact, a decision record, a skill or command, a hook or the settings file, a `.github/` file, a manifest or lockfile, `mise.toml`, `.gitignore` or `.gitattributes` — the `paths:` block above lists the triggers; replace the bracketed entry with the project's manifest and lockfile globs at install. `cbk-conventions.md` (always loaded) keeps a pointer heading for every section here, so `cbk-conventions.md § <section>` citations resolve to the pointer and the pointer to this file. Sections were moved verbatim on 2026-09-06; the split is by when the content is needed, never by length. See `cbk-conventions.md` § Rule loading and the instruction budget.

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

**Letters reflect skills; M is frame-local, F continues per workstream.** `M<#>` labels a milestone *inside its frame* (frame-local; a re-cut milestone may sub-letter, e.g. M6a / M6b when one milestone is replaced by two). `F<#>` numbers the framing capability issue and **continues across frames within a workstream** — never restarting per frame — so `[F<N>.AC<M>]` trace IDs stay unique across the workstream's whole cascade history (a superseded milestone's F-number retires with it, un-executed; its replacements take fresh F-numbers). Milestone headings in `frame-NN.md` carry both: `### F<#> — M<#>: <name>`. `R<#>` numbers rough-in's issues under their F.

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
- **Markdown-only** — a `labels:` line inside the issue record (below) carrying the same tokens (`source:github`, `cascade-depth:roughed-in`, `enhancement`, the type), greppable exactly like the backend labels. Graduation = editing that line.

The reporter and the origin URL also go in the issue body.

### The markdown issue record (in-repo-markdown planning)

On the markdown planning axis the lane's "issue entity" is a file: `docs/cbk/issues/<slug>-<lane>-<NN>.md` (lane = `bug` | `enh`; `NN` sequential per slug+lane), listed in the cascade-events index. Its shape:

- **H1** = the would-be issue title (`[<slug>:bug] <intent>` / `[<slug>:enh] <intent>`) — this heading (or the file path) is what `/enrich` takes as its argument.
- **A `labels:` line** directly under the H1 carrying the token set the backend lanes would use (provenance, cascade-depth, type, transient `enhancement`) plus a `status:` token (`open` | `done` | `superseded`) — the per-record analog of backend state, flipped by hand post-merge.
- **The eight-section body** (`## Context` … `## PR contract`), identical to the backend lanes; `/enrich`'s provenance note appends as a `## Provenance` section rather than a comment.

The same `labels:` / `status:` line convention applies to the **R-spec sections rough-in emits on this axis** (whether appended to `frame-NN.md` or in a per-milestone rough-in file): each `[<slug>:F<#>:R<#>]` heading carries its own `status:` token, which is what a dependent spec's `## Dependencies` check reads and what the operator flips post-merge.

There is no `/finish` on this axis — the record is executed by opening a Claude Code session against it directly; the hand-off from `/intake`/`/enrich` says so.

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
### F3 — M3: <name>

- [F3.AC1] <Boundary or behavioural criterion> ...
- [F3.AC2] <Test-runnable criterion> ...
- [F3.AC3] <Demonstrable-capability criterion> ...
```

`F<N>` is workstream-unique and continues across frames (§ Title-prefix scheme), so a trace ID never collides with an earlier frame's. Nested criteria (`[F3.AC2.1]`) are permitted when a criterion decomposes. Rough-in R-issues then reference these IDs in their own `## Acceptance criteria` and `## Test plan` sections:

```markdown
## Acceptance criteria

- [F3.AC1] <how this R-issue satisfies AC1>
- [F3.AC2] `<test command>` passes (covers F3.AC2 — <criterion summary>)
```

**Why trace IDs**: closes the framing → rough-in → test round-trip auditability. Without them, the link from "what M3 promised" → "what R-issue X implemented" → "what test verifies it" is implicit. With them, test-runner output cites `F3.AC2` and the framing F-issue body shows where it landed. Adopted from Kiro's `_Requirements: 1.1, 3.2_` pattern, simplified to a single bracketed ID inline rather than a separate trailing field.

**Backfill on existing artifacts is optional**: framings produced before adopting this convention shouldn't be retroactively edited (per ADR-pattern append-only discipline applied to cascade events). Adopt forward from whichever frame-NN this convention starts in.

**Two-level anchor in practice.** Rough-in R-issues routinely author their own numbered `## Acceptance criteria` list — derived from, but not identical to, the parent F-issue's ACs — and the R-issue is the unit `/finish` executes against, so **tests trace to the R-issue's own AC numbering** (e.g. a test docstring tagging `[<ISSUE-KEY> AC2]`) while the R-issue's AC list is what cites the parent's `[F<N>.AC<M>]` IDs. Both levels are trace anchors: the F-level IDs close the framing → rough-in loop; the R-level tags close the rough-in → test loop. Record the project's chosen test-side tag form here so conformance reviewers don't flag the R-level form as trace-ID drift.

## Sub-issue rollup

For Linear projects, two team-level workflow settings (`Settings > Team > Workflow`) interact with the cascade:

- **(a) Auto-complete parent when all sub-issues complete** — **enable**. Matches cascade semantics: parent F-issue closes when all R-issues close; parent workstream issue closes when all F-issues close.
- **(b) Auto-complete sub-issues when parent completes** — **leave off**. The cascade may create rough-in R-issues in advance with `blockedBy` chains; auto-completing them when the parent closes would prematurely close work that's still open.

For GitHub-only projects, sub-issue rollup is a Projects v2 view configuration rather than a closure-cascading setting; the equivalent is just rendering the parent/child tree on a board view.

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

**CI workflow actions are dependencies too.** A tag reference (`uses: vendor/action@vN`) is mutable and open to tag-retag compromise: pin every `uses:` to a full commit SHA with a trailing version comment (`@<sha> # vN.N.N`), resolve initial pins to the newest release in the current major that satisfies the settle window, and let the update bot's CI-actions ecosystem entry maintain the pins routinely (it carries the release-age floor like every other ecosystem).

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

If a project adopts either, record its trigger here (e.g. "rigor pass on any frame that introduces a new external dependency"). Large research/rigor outputs can be committed as a companion file (`frame-NN-<slug>.md`) the frame links and rough-in inherits, rather than inlined or discarded. The same companion shape works at **event grain**: a dated design/research distillation linked from the ledger row that produced it, opening with a short provenance header (builds-on / grounded-by / what it produced), with the raw research corpus archived outside the repo. When a companion is research-backed, **verify every quotation against the fetched source before committing and record the tally** ("N/N citations verbatim-verified"); a citation that can't be re-verified is dropped, not kept on faith.

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

**Mechanize the gates that must survive session drift.** A gate whose rule is absolute (no judgment call) can be enforced by a PreToolUse hook instead of prose, in two tiers: **hard-deny** for actions never legitimate for the agent (editing immutable ADRs, hand-editing lock files, committing on main), **ask-gate** for one-way doors legitimate only when operator-instructed (PR-state changes, knowledge-backend writes) — where the forced permission prompt *is* the per-action HITL approval and fires even when a broad allowlist would otherwise auto-approve. See the hook registry in `.claude/settings.json`. When a safety rule stays instruction-enforced instead, record a **deferred-hardening note** — why structural enforcement was shelved, the residual-gap severity, and the revisit trigger — so the gap stays visible instead of forgotten.

**Standing authorizations are scoped and recorded.** A session- or plan-scoped "blanket OK for the actions in this plan" is legitimate HITL calibration only when it names the exact pre-approved action set, is recorded in the governing artifact, and states that anything outside the set stays gated. Designated one-way actions are excluded from standing authorization entirely — they always take a fresh per-action approval, even mid-session, even when everything else is pre-approved.

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

Every phase-exit checklist the kit ships (scaffold, blueprint, framing) carries one standing item: **if this run exercised a call that a reference file flags as individually unexercised, restamp it in the same commit** — drop the flag, date the run generically ("a second real run, <date>"), and update the file's § Exercise status. A flag with a re-check trigger nobody fires is a rail that outlives its evidence.

## Recommended planning-backend settings

Beyond what the cascade skills auto-configure, projects using a planning backend require these settings (one-time setup per project):

**Linear (linear planning)**:
1. **Cycles**: enable or disable per the methodology section above
2. **Workflow > Auto-complete parent when all sub-issues complete**: ON (matches cascade rollup semantics)
3. **Workflow > Auto-complete sub-issues when parent completes**: OFF (preserves R-issue independence)
4. **Workflow > Sub-issue rollup display**: ON (renders the cascade-tree view in project tables)
5. **Branch name template** (in `Settings > Workspace > Branch names`): `{type}/{teamPrefix}-{issueIdNumber}-{title}` matches the `<type>/<TEAM>-N-<slug>` convention

**GitHub Projects v2 (when planning backend = GitHub Issues)** — *designed-unexercised as of 2026-08-09 (no real cascade run has exercised this board contract yet; the canonical spec is `backends.md` § Lifecycle stages and kanban mapping (the board contract) — expect calibration on first real use)*:
1. Create a Projects v2 board with sub-issue rendering enabled
2. Configure swimlanes grouped by parent issue
3. One Status field with the seven canonical values (Triage / Refinement / Ready / In Progress / In Review / Done / Archived) per `backends.md` — not a reduced set
4. Board automation rules: entry Status from label, parent In Progress/Done from the sub-issue progress field, PR open → In Review, PR merged → Done — the cascade does **not** set the Status field via MCP (`auto_status_via_board_rules = true`)

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

## Verification

Two audiences share one block. **Kit-repo checks** hold on the kit's own tree and on any target project's copy of `.claude/`; **project checks** hold only in a filled-in target project and skip themselves when `docs/cbk/scaffold.md` is absent. A red check is a defect in the check until proven otherwise: a suite with a permanently red line is a suite nobody runs, which is worse than no suite. Every check says what it catches. Run the block after major edits to cascade skills, to the rules, or to a project's filled-in copy of this file.

```bash
# ═══ KIT-REPO CHECKS — must be green on the kit tree and in every target project ═══

# Run the block with `bash -e`. A must-be-absent check cannot be written `! grep …`: set -e exempts
# a `!`-negated command, so a hit would print and the run would still end green. `absent` runs the
# command and exits loudly when it succeeds — that is, when the forbidden thing was found.
absent() { if "$@"; then echo "VIOLATION (matched above): $*" >&2; exit 1; fi; }

# Section-name renames: the "Movement" vocabulary was retired; it must not reappear in skill content.
absent grep -rn "Movement [0-9]\|## Movement" .claude/skills/

# Trace ID convention present in the producing templates (positive check).
grep -rn "\[F[0-9]\.AC[0-9]\]" .claude/skills/*/references/templates/

# Knowledge-backend portability: a real Notion page id must not appear in skill content
# (signup links, `my-integrations` and `<workspace>` placeholders are fine — this matches ids only).
absent grep -rnE "notion\.(so|site)/[0-9a-f]{16,}" .claude/skills/

# Pre-refactor "opinionated-profile" vocabulary must not appear anywhere in kit content (the
# constant + two axes refactor removed the concept); the pattern splits its literal so this
# line never matches itself.
absent grep -rn -i "opinionate[d] profile\|opinionated_profil[e]" .claude/ README.md .mcp.json.example

# CLAUDE.md points at this file as a backticked mention — deliberately NOT an `@` import,
# which would expand this whole file into every session at launch (memory docs).
grep -q "cbk-conventions" CLAUDE.md

# Producer templates emit the two-axis vocabulary (positive checks).
grep -n "Planning backend" .claude/skills/scaffold/references/scaffold_output_template.md
grep -n "Knowledge backend" .claude/skills/scaffold/references/scaffold_output_template.md
grep -rn "F<#> — M<#>" .claude/skills/framing/references/templates/

# Pre-refactor vocabulary must not appear anywhere in kit content (widened beyond skills).
# The regex splits its own literal so this line never matches itself or the reference half.
absent grep -rnE "github-only \| opinionate[d]|Profile.*github-onl[y]" .claude/
absent grep -rn "initiative\.md" .claude/ README.md

# Citations a skill makes to a section another template emits are pinned as pairs: the
# consumer keeps citing a heading only while the producer keeps emitting it.
grep -q "^## Rough-in events" .claude/skills/framing/references/templates/frame-output-template.md
grep -q "^## Pre-flight checks" .claude/skills/framing/references/templates/frame-output-template.md
grep -q "^## Assumptions" .claude/skills/rough-in/references/templates/rough-in-spec-template.md
# Deferred pair (known red until #37 lands): adr-new cites `docs/ARCHITECTURE.md § Configurability summary`
# and `§ Open questions`, which the architecture template does not emit. Do not add the pin before #37.

# Bundled starters stay byte-identical to their originals (the kit's root docs/adr/ is the source of
# truth) — kit tree only: a target project fills ADR-0000's header and adds ADRs, so its docs/adr
# legitimately differs from the starters. Loud on drift and on a missing docs/adr.
[ -f docs/cbk/scaffold.md ] || diff -rq docs/adr .claude/skills/scaffold/references/adr-starters || { echo "adr-starters drifted from docs/adr (or docs/adr is missing)"; exit 1; }

# The eight-section contract: the scaffold-shipped issue template, the spec template and the
# executor's parser agree on the heading list (the executor is the authority; the others are copies).
diff <(grep '^## ' .claude/skills/scaffold/references/issue-templates/cascade-rough-in.md) <(grep '^## ' .claude/skills/rough-in/references/templates/rough-in-spec-template.md)
for h in Context Assumptions Implementation "Acceptance criteria" "Test plan" "Done signal" Dependencies "PR contract"; do grep -q "\`## $h\`" .claude/commands/finish.md || { echo "finish.md does not name ## $h"; exit 1; }; done
# The prose restatements carry the executor's list verbatim, derived from the template (a renamed
# or added section fails here — not only the one stale phrase a prior drift left behind).
L=$(grep '^## ' .claude/skills/scaffold/references/issue-templates/cascade-rough-in.md | sed 's/^## //' | paste -sd '|' | sed 's/|/ \/ /g')
for f in .claude/skills/rough-in/references/handoff-to-finish.md .claude/skills/rough-in/references/plan-mode-prompts.md; do grep -qF "($L)" "$f" || { echo "$f does not carry the executor's section list ($L)"; exit 1; }; done

# Skill and command descriptions name cascade objects, never one backend's entity type
# (the phase skills below run on every planning axis).
absent grep -n "^description:.*\bLinear\b" .claude/skills/framing/SKILL.md .claude/skills/blueprint/SKILL.md
# Counts embedded in prose rot: test-case preambles and their index lines state no count.
absent grep -rnE "^(Three|Four|Five|Six|Seven|Eight) realistic" .claude/skills/*/references/test_cases.md
absent grep -rnE "test_cases\.md\` — (three|four|five|six|seven|eight) realistic" .claude/skills/*/SKILL.md

# The review floor: no surface frames the sweep as a substitute for the two skills (the pattern
# also catches the paraphrase the sweep's meta once carried); the `## Review gate` block has one
# home (pr-review.md § The floor) that the executor and its bundled template cite; the executor and
# the template body stay byte-parallel (the anchored awk is the extraction the template documents).
# The pattern splits its literals so this line never matches itself.
absent grep -rn "instead of a single direct dispatc[h]\|direct dispatch[^.]*is the fallbac[k]\|apply only after both the primary and the recorded fallbac[k]" .claude/
{ grep -q '^## Review gate' .claude/rules/pr-review.md && grep -q 'Review gate' .claude/commands/finish.md && grep -q 'Review gate' .claude/skills/rough-in/references/finish-command.md; } || { echo "the ## Review gate block is missing from its home, the executor, or the bundled template"; exit 1; }
diff <(awk '/^--- BEGIN TEMPLATE ---/{flag=1; next} flag' .claude/skills/rough-in/references/finish-command.md) .claude/commands/finish.md >/dev/null || { echo "commands/finish.md and the bundled template body have drifted"; exit 1; }

# The sweep: bounded (3 per dimension, 8 verified), roster read at runtime (no mirror), the
# planned count logged before the find stage, its own gate line returned — it parses (a workflow
# body carries a top-level return, so node --check runs on the body wrapped in a function) and
# its accounting holds under the stub harness (no agent is dispatched).
{ grep -q 'maxPerDimension ?? 3' .claude/workflows/review-sweep.js && grep -q 'maxVerify ?? 8' .claude/workflows/review-sweep.js && grep -q 'planned agents' .claude/workflows/review-sweep.js && grep -q 'gateLine' .claude/workflows/review-sweep.js; } || { echo "review-sweep.js lost a bound, the planned-count log, or its gate line"; exit 1; }
absent grep -n 'REVIEWER_TRIGGERS' .claude/workflows/review-sweep.js
{ awk '/^};$/ && !done {print; print "async function __workflow_body() {"; done=1; next} {print} END {print "}"}' .claude/workflows/review-sweep.js > "${TMPDIR:-/tmp}/review-sweep-check.mjs" && node --check "${TMPDIR:-/tmp}/review-sweep-check.mjs"; } || { echo "review-sweep.js does not parse (or node is missing — install it; do not soften this check)"; exit 1; }
node .claude/workflows/tests/review-sweep-accounting.mjs || { echo "review-sweep.js accounting regressed"; exit 1; }

# Context budget: every `.claude/rules/*.md` WITHOUT `paths:` frontmatter loads at launch,
# every session, and every non-fork subagent loads the set again. Print the always-loaded
# set and its size so the standing cost is a number, not a discovery.
total=0; for f in .claude/rules/*.md; do head -1 "$f" | grep -q '^---$' || { s=$(wc -c < "$f"); total=$((total+s)); echo "always-loaded: $f ($s bytes)"; }; done; echo "always-loaded total: $total bytes"

echo "verification: kit sub-block complete"

# ═══ PROJECT CHECKS — a filled-in target project only; skipped on the kit tree ═══
if [ -f docs/cbk/scaffold.md ]; then

  # Layout: the project's own artifacts follow the layout it chose. Flat is the default;
  # a project that chose the nested layout inverts this line.
  absent test -d docs/cbk/framings

  # Stub language: no stubs remain in the project's own artifacts ("fall back to manual"
  # is the kit's partial-failure doctrine and is allowed in skill content).
  absent grep -rni "v1 stub\|stub status" docs/

  # Portability: the project's REAL identifiers must not have leaked into portable skill content.
  # TEMPLATE LINE — substitute the two bracketed values with the project's issue-key prefix and
  # repo name before running; as shipped it is documentation, not a runnable check. Project-scoped
  # plugin directories under .claude/skills/ may legitimately name project paths — exclude them.
  # absent grep -rn "<TEAM-PREFIX>-[0-9]\|<repo-name>" .claude/skills/ --exclude-dir=<plugin-dir>

  # Axis record mirror: scaffold.md's Cascade metadata table is canonical and
  # .cascade/backends.toml is its machine-readable mirror; every value in the toml must appear in the table.
  if [ -f .cascade/backends.toml ]; then
    vals=$(grep -oE '"[a-z-]+"' .cascade/backends.toml | tr -d '"'); [ -n "$vals" ] || { echo "no axis values extracted from .cascade/backends.toml — check its format"; exit 1; }
    for v in $vals; do grep -q "$v" docs/cbk/scaffold.md || { echo "axis mismatch: $v in backends.toml is absent from scaffold.md § Cascade metadata"; exit 1; }; done
  fi

  # Path-scoped rules must carry stamped globs: a bracketed placeholder matches nothing,
  # so the rule would silently never load.
  for f in $(grep -l '^paths:' .claude/rules/*.md); do awk '/^---$/{c++; next} c==1' "$f" | grep -n '<' && { echo "unfilled paths placeholder in $f"; exit 1; }; done

  echo "verification: project sub-block complete"
fi
echo "verification: done"

```
