# Kara — Cascade Conventions

Operational rules for kara's instantiation of the AI-assisted development cascade (consultation → scaffold → blueprint → framing → rough-in → `/finish`). The cbk-* skills under `.claude/skills/` provide the **portable** cascade tooling; this file records **kara-specific overrides and validated choices**. When the skills cite "see your project's `cbk-conventions.md`," this is what they're pointing at.

The principle:

- **Skills stay portable; project specifics live here.** The cbk-* skills can be installed in any project; they describe choice spaces and patterns generically. Kara's specific instantiation — flat layout vs nested, branch-naming pattern, label scheme, validated evidence — lives in this file.
- **Two-way reference.** Skills cite this file as the project-level override surface. This file cites skills as the upstream pattern source. No kara-specific identifiers (KAR-NN, frame-01.md, etc.) leak into skill content.
- **Validated, not provisional.** Every section here records a choice kara has actually exercised across F1–F4 cycles + the foundation workstream. Future projects may diverge; that's fine — they get their own `cbk-conventions.md`.

## Cascade artifact layout — flat, not nested

Kara uses **flat** layout under `docs/cbk/`:

```
docs/cbk/
├── README.md          ← chronological cascade-events index (status column)
├── blueprint.md       ← from blueprint phase
├── frame-01.md        ← first framing event (foundation workstream)
└── frame-NN.md        ← future framings, numbered chronologically across all workstreams
```

**Why flat**: each cascade event is a single document. Kara's framing events produce one `frame-NN.md` per event, not a multi-file bundle. The flat layout matches the [ADR pattern](../../docs/adr/) (immutable, sequentially numbered, append-only, README-indexed) — a closer analog to kara's artifact shape than spec-kit's "directory = feature bundle" pattern. Validated by 1 framing event + 4 rough-in cycles built against it.

**Chronological tracking lives in two places**:

1. **`docs/cbk/README.md`** — across-cascade timeline. Status column tracks Active / Completed / Superseded by frame-NN / Abandoned. Mirrors the shape of `docs/adr/README.md`.
2. **`## Rough-in events` section inside each frame-NN.md** — per-frame timeline of rough-in events that built against that framing. Append-only table within the frame document. Useful for "which milestones from this framing have been roughed-in, on what date, with what capstone PR" lookups without leaving the frame.

Both serve distinct jobs: README is the across-frames table of contents; in-frame events log is the per-frame log. Don't conflate.

**Project may override**: future projects whose framing events produce multi-file bundles (analogous to spec-kit's `specs/feature-X/{spec,plan,tasks}.md`) should override to nested layout in their own `cbk-conventions.md`. Kara's choice is flat because its events are single documents.

## Sub-issue hierarchy — three levels

Kara uses **three levels** of issue hierarchy, all on Linear:

```
Initiative                          (e.g. "Kara")
└── Project (one per phase)         (e.g. "Phase 1 — MVP")
    └── Workstream parent issue     (e.g. KAR-2 "[foundation] Foundation")
        └── Framing F sub-issue     (e.g. KAR-13 "[foundation:F4] Layered config + ...")
            └── Rough-in R sub-sub-issue   (e.g. KAR-27 "[foundation:F4:R3] foundation-close-...")
```

**Why three levels**: matches Linear's UX ceiling for sub-issue rollup rendering (4-level deep starts breaking project table view per Linear community discussion). Also matches Spec Kit's `Specify → Plan → Tasks` and Kiro's `Requirements → Design → Tasks` decomposition depth — 3 is the natural shape for spec-driven cascade work.

**Don't add a fourth tier.** If a rough-in R-issue is too large, decompose during `/finish`'s plan-mode (plan mode is the decomposition engine for sub-R work). Don't create R.M.K-style fourth-level sub-issues on Linear.

## Title-prefix scheme

Title prefixes are the structural identifier across the cascade. They survive the GitHub mirror, `gh` CLI output, and the Linear web UI:

| Level | Title prefix | Example |
|---|---|---|
| Workstream parent | `[<workstream-slug>]` | `[foundation] Foundation` |
| Framing F sub-issue | `[<workstream-slug>:F<#>]` | `[foundation:F4] Layered config + ExUnit harness + Ecto plumbing + CI green` |
| Rough-in R sub-sub-issue | `[<workstream-slug>:F<#>:R<#>]` | `[foundation:F4:R3] foundation-close-integration-capstone` |

**Workstream slugs** (locked at blueprint, immutable across the workstream's lifetime — see [`docs/cbk/blueprint.md`](../../docs/cbk/blueprint.md) § Workstreams):

- `foundation` — Mix umbrella, supervision tree, dev mocking, structured logging
- `memory` — Ecto schemas, repo, retrieval, voice-profile catalog
- `perception` — Camera + mic-array sidecars, perception event PubSub
- `cognition` — LLM backend, ASR/TTS/critic, Anubis tool registry, prompt assembly
- `behavior` — Body loop (60Hz), Arbiter (gen_statem), animation library
- `face` — State struct, expressions catalog, SVG renderer, animator
- `pilot` — Base persona, modifiers, three Bart Pilots
- `dashboard` — Phoenix LiveView, all panes, mocked-event injection

Slug stability is load-bearing: branches reference it (`<type>/kar-N-<slug>...`), labels reference it (`workstream:<slug>`), commit messages reference it. A workstream that needs renaming triggers a re-blueprint, not in-place mutation.

## Trace ID convention

Acceptance criteria in framing F-issues carry inline IDs of the form `[F<N>.AC<M>]`:

```markdown
### M3 acceptance criteria

- [F3.AC1] Boundary behaviours (UART, SPI, I2C, Sidecar.Adapter) defined ...
- [F3.AC2] Mock implementations conform to behaviours via Mox ...
- [F3.AC3] Full app idles on a laptop with no Pi attached ...
```

Rough-in R-issues then reference these IDs in their own `## Acceptance criteria` and `## Test plan` sections:

```markdown
## Acceptance criteria

- [F3.AC1] UART behaviour module + Hardware impl + Mock impl all present
- [F3.AC2] `mix test apps/kara/test/kara/hardware/uart_conformance_test.exs` passes
  (covers F3.AC2 — boundary impls conform to behaviour)
```

**Why trace IDs**: closes the framing → rough-in → test round-trip auditability. Without them, the link from "what M3 promised" → "what KAR-22 implemented" → "what test verifies it" is implicit. With them, `mix test --trace` output cites `F3.AC2` and the framing F-issue body shows where it landed. Adopted from [Kiro's `_Requirements: 1.1, 3.2_`](https://kiro.dev/docs/specs/feature-specs/) pattern, simplified to a single bracketed ID inline rather than a separate trailing field.

**Backfill on existing artifacts is optional**: frame-01.md predates this convention and won't be retroactively edited (per ADR-pattern append-only discipline applied to cascade events). Future framings adopt the convention from frame-02 forward.

## Branch naming

Pattern: `<type>/kar-<N>-<short-slug>`

- `<type>` is one of the [Conventional Commits](https://www.conventionalcommits.org/) types: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `perf`, `style`, `build`, `ci`
- `kar-<N>` is the Linear issue ID in lowercase (e.g. `kar-27`)
- `<short-slug>` is a kebab-case description of the work, ~3-6 words

Examples:
- `chore/kar-27-foundation-close-integration-capstone`
- `feat/kar-42-llm-backend-behaviour`
- `fix/kar-118-asr-buffer-overflow`

**Why include the issue ID**: Linear's GitHub integration auto-links branches to issues when the issue ID appears anywhere in the branch name (substring match, not full match — see [Linear's branch-naming announcement](https://linear.app/changelog/2020-04-13-branch-naming)). Including the ID eliminates the magic-word-in-PR-body fallback path. The body marker (`Closes KAR-27`) still works, but the branch-name path fires earlier and is more reliable.

`/finish` already creates branches in this shape; this convention codifies what was already happening.

## Closes-keyword conventions

PR body close markers:

- **Linear-tracked issues** (the typical case for kara, since Linear is the planning backend): `Closes KAR-N` in the PR **body** (not just the title — body is the durable surface; titles can be edited at squash-merge time without affecting the close marker)
- **GitHub-tracked issues** (rare for kara; would apply if some work was tracked only on GitHub): `Closes #N` in the PR body
- **Both can coexist** in the same PR body if the PR closes one of each.

Linear's recognized close-markers (case-insensitive): `close/closes/closed/closing`, `fix/fixes/fixed/fixing`, `resolve/resolves/resolved/resolving`, `complete/completes/completed/completing`, `implements`. See [Linear's GitHub integration docs](https://linear.app/docs/github-integration). Non-closing link-only markers: `ref`, `references`, `part of`, `related to`, `contributes to`, `towards`.

PR titles are Conventional Commits format (`<type>(<scope>)?: <subject>`), e.g. `chore(foundation): foundation-close integration capstone (closes KAR-13, KAR-2)`. The parenthetical issue mentions in titles are descriptive; the load-bearing close markers go in the body.

## Sub-issue rollup

Linear team setting (`Settings > Team > Workflow`, [Sept 2024 release](https://linear.app/changelog/2024-09-06-auto-close-parent-and-sub-issues)):

- **(a) Auto-complete parent when all sub-issues complete** — **enable** for kara. Matches cascade semantics: parent F-issue closes when all R-issues close; parent workstream issue closes when all F-issues close.
- **(b) Auto-complete sub-issues when parent completes** — **leave off**. Kara's cascade creates rough-in R-issues in advance with `blockedBy` chains; auto-completing them when the parent closes would prematurely close work that's still open.

Validated by F4: KAR-27 closing rolls up → KAR-13 (F4) closes → KAR-2 (foundation) closes. PR #25.

## `[skip ci]` rule

Permitted on:
- **Docs-only commits** — STANDARDS.md, CLAUDE.md, ARCHITECTURE.md, ADR additions, README updates
- **Planning-artifact commits** — `docs/cbk/*` updates (blueprint.md, frame-NN.md, README.md)
- **Cascade-event commits** — rough-in event-log entries appended to a frame, post-merge cascade-event records

Not permitted on:
- Code commits (anything under `apps/`, `lib/`, `priv/`, `cognition/`, `perception/`)
- Test commits (anything under `apps/*/test/`, `cognition/*/tests/`, etc.)
- `.github/workflows/*.yml` changes (CI workflows themselves — they need to verify they don't break the gates they install)
- `mise.toml` task changes (these can affect build behavior)
- `.claude/hooks/*` changes (hooks are operational; need verification they don't break)

**Squash-merge interaction**: kara squash-merges to main. The squashed commit message on `main` is what matters for `[skip ci]`; per-branch commits with `[skip ci]` skip the per-branch CI runs, but the squash commit's message determines whether `main`'s CI runs.

## Methodology — cycles disabled, Kanban-flow, Shape-Up appetite

Per blueprint:

- **Linear cycles**: disabled at the team level. Solo + AI-assisted work doesn't need sprint synchronization.
- **Issue execution**: Kanban-flow. Pick the next available issue (top of the Ready column), finish, merge, next.
- **No WIP limit beyond "one issue at a time"**: `/finish` enforces single-issue execution by virtue of the slash-command shape.
- **Appetite tag**: framings tag milestones with appetite (small ~1 week, medium ~3 weeks, big ~6 weeks) per [Shape Up](https://basecamp.com/shapeup). Calendar weeks are aspirational, not enforced.

This is the only methodology element borrowed from Shape Up; the rest of Shape Up's machinery (pitches, betting tables, cool-down) is not adopted.

## 3-index ADR sync

Every ADR addition (including post-blueprint additions like ADR-0026 through ADR-0030) updates **three indexes** in lockstep:

1. **`docs/adr/README.md`** — canonical ADR index with status, dates, and short descriptions
2. **`docs/ARCHITECTURE.md` § Decisions log** — orientation-level table mirroring the README
3. **`docs/ARCHITECTURE.md` § Configurability summary** — per-ADR configurability posture (per ADR-0025)
4. **`docs/cbk/blueprint.md` § Stack decisions** — also updated for post-blueprint ADRs (since blueprint.md is itself a cascade artifact)

The `/adr-new` skill (at `.claude/skills/adr-new/SKILL.md`) automates the cross-index sync. Manual ADR creation works but is error-prone (four indexes to keep in sync); use the skill.

ADR immutability is enforced two ways:
- **`.claude/hooks/protect-immutable-adrs.sh`** — PreToolUse hook blocks Claude Code edits to existing ADR files (per ADR-0026)
- **`.github/workflows/adr-immutability-check.yml`** — CI lint diffs `docs/adr/[0-9]{4}-*.md` files in PRs and fails on changes to existing ADRs (closes the raw-git-access gap that the hook can't catch)

## Spec-Kit vocabulary mapping

Kara's cascade phases align with the converging industry vocabulary from [GitHub Spec Kit](https://github.com/github/spec-kit) and [Amazon Kiro](https://kiro.dev/docs/specs/) (per [Martin Fowler / Birgitta Böckeler's SDD survey](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html)):

| Kara phase | Spec Kit equivalent | Kiro equivalent | Job |
|---|---|---|---|
| `cbk-consultation` + `cbk-blueprint` | `Specify` | `Requirements` | Capture problem, scope, success criteria |
| `cbk-blueprint` ADRs | `Constitution` | (no analog — Kiro lacks ADR layer) | Immutable architectural decisions |
| `cbk-framing` | `Plan` | `Design` | Decompose project into milestones |
| `cbk-rough-in` | `Tasks` | `Tasks` | Decompose milestones into ready-to-implement specs |
| `/finish` | `Implement` | (Kiro IDE) | Execute one task end-to-end |

Use this mapping when explaining kara's cascade to someone familiar with Spec Kit or Kiro. Don't rename kara's phases to match — kara's vocabulary (consultation / blueprint / framing / rough-in / finish) is established and load-bearing across the existing artifacts. The mapping is a Rosetta stone, not a rename.

## Mutation discipline

| Artifact | Mutation rule | Supersession pattern | Rationale |
|---|---|---|---|
| `docs/adr/[0-9]{4}-*.md` | **Immutable** | New ADR with `Supersedes: ADR-NNNN` field; old ADR's status changes to "Superseded by ADR-MMMM" | ADR-0000 immutability discipline + ADR-0026 hook enforcement + CI lint |
| `docs/cbk/blueprint.md` | **Append-only for new ADRs** (the Stack decisions table); otherwise immutable to preserve cascade history | Re-blueprint creates new file (not done yet for kara) | Blueprint is a cascade event; mutation breaks the audit trail |
| `docs/cbk/frame-NN.md` | **Append-only for `## Rough-in events` table**; otherwise immutable post-commit | Re-framing creates `frame-MM.md` with `Supersedes: frame-NN` field; old frame's status → "Superseded" | Frames are cascade events; rough-in events are the timeline log |
| `docs/cbk/README.md` | **Append-only for new entries**; status column updates allowed | Status updates are mutations to single column, not whole-file rewrites | Status changes (Active → Superseded → Completed) need to flow |
| `docs/STANDARDS.md`, `docs/ARCHITECTURE.md`, `CLAUDE.md` | **Freely mutable** | n/a — living docs | Project-context docs evolve with the project; git history is the version archive |
| `.claude/rules/*.md` | **Freely mutable** | n/a | Operational rules; mutations are routine |
| `.claude/skills/cbk-*/` | **Freely mutable** (this is the alignment-pass surface) | n/a | Tooling content; mutations refine the cascade |
| Code (`apps/`, `lib/`, etc.) | **Freely mutable** | n/a | Standard code evolution |

Cascade events being append-only is structurally important: the cascade IS the audit trail of decisions. A new framing supersedes an old one with a new file; the old one stays in `docs/cbk/` for future readers to understand "we used to think X, now we think Y."

## HITL gate load-bearing heuristics

When deciding whether a HITL gate in a cbk skill's standard mode should remain a gate, become a trip-wire (auto-checklist with no approval), or be removed entirely:

**Load-bearing if any of**:
- Next step writes outside the conversation (Linear `save_issue`, `git commit`, `git push`, `gh pr create` — Bezos one-way door)
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

**Standard-mode target**: 3 gates per cbk-* phase, with trip-wires filling the rest of the safety surface. Per the [Verschlimmbesserung](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html) / [Scott Logic "3.5 hours reviewing markdown"](https://blog.scottlogic.com/2025/) / [Digital Applied gate framework](https://www.digitalapplied.com/blog/agentic-workflow-approval-gate-framework-governance) consensus: 4+ gates per phase trains rubber-stamp culture, which silently degrades the load-bearing gates.

Validated by kara's framing experience: the Linear-write gates and the final-artifact gates were the ones that produced "edit" responses; the inheritance and research-findings gates were near-100% rubber-stamp.

## Trip-wire / phase-exit checklist pattern

Every cbk-* phase exits via a `## Phase exit checklist` — a short, auto-checkable list that fires before the next phase starts. The checklist is **not a gate** (no user approval) but is a **safety surface** (the cbk skill stops if any item fails).

Example shape (from `cbk-rough-in`'s checklist):

```markdown
## Phase exit checklist

- [ ] Frame-NN.md fully read; in-doc `## Rough-in events` table examined
- [ ] All `blockedBy` dependencies for the milestone being roughed-in are closed-completed
- [ ] Pre-flight checks (deferred meta-issues + blocking deps + per-workstream invariants) all green
- [ ] Idempotency check passed (no existing R-issues for this milestone)
- [ ] Spec-drafting movement produced 2-6 R-issue specs (per review-unit discipline)
- [ ] Each R-issue spec has all 8 sections present (Context, Assumptions, Implementation, AC, Test plan, Done signal, Dependencies, PR contract)
```

The checklist runs auto-checkable; surfacing only failures. Per [GitHub Spec Kit's `⚠️ CRITICAL: No user story work can begin until this phase is complete` pattern](https://github.com/github/spec-kit/blob/main/spec-driven.md), modified for kara's gate-trim posture.

## Recommended Linear team settings

Beyond what the cbk skills auto-configure, kara's team requires these settings (one-time setup per project):

1. **Cycles**: disabled
2. **Workflow > Auto-complete parent when all sub-issues complete**: ON (matches cascade rollup semantics)
3. **Workflow > Auto-complete sub-issues when parent completes**: OFF (preserves R-issue independence)
4. **Workflow > Sub-issue rollup display**: ON (renders the cascade-tree view in project tables)
5. **Branch name template** (in `Settings > Workspace > Branch names`): `{type}/{teamPrefix}-{issueIdNumber}-{title}` matches kara's `<type>/kar-N-<slug>` convention

These are user-actions, not auto-applied via MCP. Document the post-merge step in any PR that affects the cascade.

## Quick reference

| What you're doing | Where the convention lives |
|---|---|
| Naming a cascade event | Flat `docs/cbk/<artifact>.md`, sequential numbering |
| Updating the cascade-events index | `docs/cbk/README.md` (status column) |
| Naming a Linear issue | `[<workstream-slug>:F<#>:R<#>] <intent>` |
| Naming a branch | `<type>/kar-<N>-<short-slug>` |
| Closing a Linear issue from a PR | `Closes KAR-N` in PR body |
| Adding an ADR | `/adr-new` skill (auto-syncs 3 indexes) |
| Adding a `## Pre-flight checks` row to a frame | Append-only edit to the frame's `## Pre-flight checks` table |
| Skipping CI on a docs-only commit | Append `[skip ci]` to commit message subject |
| Mid-session gate trimming | See § HITL gate load-bearing heuristics |
| Phase exit | Run the `## Phase exit checklist` from the relevant cbk-* skill |

## Verification

After major edits to cbk-* skills or to this file, run these greps to confirm alignment:

```bash
# Path drift: skills should not reference nested layout
! grep -rn "framings/\|framing\.md\b" .claude/skills/cbk-*/

# Stub language: no stubs should remain
! grep -rni "v1 stub\|stub status\|Linear + Notion\|fall back to manual" .claude/skills/cbk-*/

# Movement → Step rename
! grep -rn "Movement [0-9]\|## Movement" .claude/skills/cbk-*/

# Deferred meta-issues → Pre-flight checks rename
! grep -rn "Deferred meta-issues" .claude/skills/cbk-*/

# Trace ID convention present in templates
grep -rn "\[F[0-9]\.AC[0-9]\]" .claude/skills/cbk-*/references/templates/

# Portability: kara-specific identifiers must NOT appear in skill content
! grep -rn "KAR-[0-9]\|frame-01\|kara-stack-spec\|kara-consultation-handoff" .claude/skills/cbk-*/

# This file is referenced from CLAUDE.md
grep "@.claude/rules/cbk-conventions.md" CLAUDE.md
```

## Future work

- **`paths:` frontmatter for conditional rule loading** — Claude Code's docs (per `code.claude.com/docs/en/skills.md`) suggest skills support a `paths:` frontmatter field that limits when the skill auto-loads based on file glob patterns (`**/*test*`, etc.). Whether `.claude/rules/*.md` files inherit this behavior is unverified at the time this file was written; behavior to test is whether adding `paths:` frontmatter to `.claude/rules/testing.md` causes Claude Code to load it only when editing test files, vs always-load. When verified, add `paths:` frontmatter to scope each rule file to its relevant glob (e.g. `paths: "**/*test*"` for testing.md, `paths: ".github/**"` for cbk-conventions.md, etc.). Adopting this brings kara in line with [Cursor's `.cursor/rules/*.mdc` `globs:` field](https://docs.cursor.com/) and [Kiro's steering inclusion modes](https://kiro.dev/docs/steering/).
- **Notion-free opinionated profile cleanup** — `cbk-scaffold/references/opinionated_profile.md` retains historical Notion mentions in the prose layer; full rewrite to drop Notion entirely is deferred. The opinionated profile is now Linear+GitHub.

## References

- Upstream cascade tooling: `.claude/skills/cbk-{consultation,scaffold,blueprint,framing,rough-in}/SKILL.md`
- Validated cascade events: `docs/cbk/README.md`, `docs/cbk/blueprint.md`, `docs/cbk/frame-01.md`
- Project docs: [`CLAUDE.md`](../../CLAUDE.md), [`docs/STANDARDS.md`](../../docs/STANDARDS.md), [`docs/ARCHITECTURE.md`](../../docs/ARCHITECTURE.md), [`docs/adr/`](../../docs/adr/)
- Industry references: [GitHub Spec Kit](https://github.com/github/spec-kit), [Amazon Kiro Specs](https://kiro.dev/docs/specs/), [Tessl SDD](https://docs.tessl.io/use/spec-driven-development-with-tessl), [Martin Fowler / Birgitta Böckeler — SDD survey](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html), [Addy Osmani — How to write a good spec for AI agents](https://addyosmani.com/blog/good-spec/), [Anthropic Claude Code best practices](https://code.claude.com/docs/en/best-practices)
- Linear references: [GitHub integration](https://linear.app/docs/github-integration), [Parent / sub-issue auto-complete](https://linear.app/changelog/2024-09-06-auto-close-parent-and-sub-issues), [Branch naming](https://linear.app/changelog/2020-04-13-branch-naming)
