# Cascade Conventions — Project Template

Operational rules for this project's instantiation of the AI-assisted development cascade (consultation → scaffold → blueprint → framing → rough-in → `/finish`). The cascade skills under `.claude/skills/` provide the **portable** cascade tooling; this file records **project-specific overrides and operational choices**. When the skills cite "see your project's `cbk-conventions.md`," this is what they're pointing at.

> **This file is a template.** Copy it into a target project's `.claude/rules/cbk-conventions.md` and fill in the bracketed placeholders (`<TEAM>`, `<workstream-slug>`, paths, etc.) with the project's actual choices. Each section describes a choice space; this template offers a sensible default plus the alternatives. The defaults reflect the patterns most projects converge on, but every section can be overridden.

The principle:

- **Skills stay portable; project specifics live here.** The cascade skills can be installed in any project; they describe choice spaces and patterns generically. The project's specific instantiation — flat layout vs nested, branch-naming pattern, label scheme, operational evidence — lives in this file.
- **Two-way reference.** Skills cite this file as the project-level override surface. This file cites skills as the upstream pattern source. No project-specific identifiers (issue keys, framing numbers, slug names) should leak into skill content.
- **Exercised, not provisional.** Sections in a project's filled-in copy of this file should record choices the project has actually exercised, not guesses. As the project runs cascade cycles, update this file with what proved out.
- **Empirical rails are dated measurements, not standing rules.** When operational evidence produces a constraint (a throughput cap, a workaround, a "don't exceed N"), record it with its date, the failure signature that motivated it, and an explicit re-check trigger — and when it lifts, note the retirement inline so it isn't reinstated from memory. A workaround written as a standing rule outlives its evidence. (Contractual limits read from a platform's live interface are the opposite case: re-verify against the source, don't re-measure.)

## Surface inventory

A single glanceable manifest of where every surface for this project actually lives, so any "see your project's `cbk-conventions.md`" pointer resolves in one place. Fill in the bracketed values (delete rows that don't apply):

- **Code + cascade artifacts (the constant):** `<repo URL>`
- **Planning backend (`<GitHub Issues | Linear | in-repo markdown>`):** `<workspace / initiative / team+key / project pointers, as applicable>`
- **Knowledge backend (`<Notion | none>`):** `<hub URL + MCP server, if configured>`
- **Upstream / pre-cascade docs:** `<path to any frozen reference material, or "none">`
- **Problem brief / scaffold output:** `docs/cbk/problem_brief.md` · `docs/cbk/scaffold.md`
- **Tooling conventions:** `<record any project-specific tool / MCP-selection conventions here — e.g. which code-intelligence or live-docs MCP to prefer over the built-ins, or the project's model/effort orchestration conventions for dispatched agents — or "defaults">`
- **Reviewer agent-memory (`<project | local>`):** `<".claude/agent-memory/ — committed; the kit's .gitignore line deleted" | ".claude/agent-memory-local/ — never committed">` — settled at scaffold's rule-file disposition pass (`pr-review.md` § Reviewer precedent memory)

## Rule loading and the instruction budget

Every file under `.claude/rules/` **without** `paths:` frontmatter loads into context at launch, every session, at the same priority as `CLAUDE.md` — and every non-fork custom subagent loads the same set again (`https://code.claude.com/docs/en/memory`, `https://code.claude.com/docs/en/sub-agents` § What loads at startup). A rule whose trigger is genuinely file-based carries a `paths:` block and loads only when a matching file is read. The kit ships:

- **Scoped by file type** — `logging.md`, `testing.md`. Their globs are bracketed placeholders the operator stamps at install; the verification block flags a placeholder left in.
- **Split into an always-loaded contract and a path-scoped reference** — `cbk-conventions.md` / `cbk-conventions-reference.md`, `orchestration.md` / `orchestration-reference.md`, `pr-review.md` / `pr-review-reference.md`. Every moved section keeps its heading in the contract with a one-line pointer, so `file § section` citations resolve unchanged.
- **Always loaded, on purpose** — `workflows.md` (a portable rule), `simplification.md`, `knowledge-backend.md` (deleted together with its hook and settings stanza when the knowledge axis is `none`), and the templates `tooling.md` and `orchestration.md` until the operator fills, path-scopes or deletes them — the bootstrap checklist's rule-file disposition pass decides each one.

Two rules keep scoping honest. **A section a task needs before it reads any trigger file is unreachable from a path-scoped rule** — restate the one line in the rule the task does load (the test-side trace-tag form lives in `testing.md` for this reason). **An `@path` line in `CLAUDE.md` is an import, not a mention** — it expands the target into every session at launch; write backticked paths. The verification block prints the always-loaded set with its byte count so the standing cost is a number, not a discovery; to measure a change rather than estimate it, the harness's `InstructionsLoaded` hook reports which instruction files loaded and why.

## Cascade artifact layout — flat (default) or nested

→ *Moved to* `cbk-conventions-reference.md` § Cascade artifact layout — flat (default) or nested *(path-scoped; see § Rule loading and the instruction budget).*

## Sub-issue hierarchy — three levels

→ *Moved to* `cbk-conventions-reference.md` § Sub-issue hierarchy — three levels *(path-scoped; see § Rule loading and the instruction budget).*

## Title-prefix scheme

→ *Moved to* `cbk-conventions-reference.md` § Title-prefix scheme *(path-scoped; see § Rule loading and the instruction budget).*

## Contribution intake — bug lane + enhancement lane

→ *Moved to* `cbk-conventions-reference.md` § Contribution intake — bug lane + enhancement lane *(path-scoped; see § Rule loading and the instruction budget).*

## Trace ID convention

→ *Moved to* `cbk-conventions-reference.md` § Trace ID convention *(path-scoped; see § Rule loading and the instruction budget).*

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

Create the branch and make the first commit in **separate tool calls**: the default-branch guard judges a compound command on the branch at entry, so `git switch -c … && git commit …` is blocked even though the commit would have been legal by the time it ran.

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

- **Linear-tracked issues** (linear planning): `Closes <TEAM>-N` in the PR **body** (not just the title — body is the durable surface; titles can be edited at squash-merge time without affecting the close marker)
- **GitHub-tracked issues** (github-issues planning, or any GitHub-tracked sub-issue): `Closes #N` in the PR body
- **Both can coexist** in the same PR body if the PR closes one of each.
- **Markdown-only projects**: there are no issue-tracker entities to close; the cascade-event log entries are updated by hand.

Linear's recognized close-markers (case-insensitive): `close/closes/closed/closing`, `fix/fixes/fixed/fixing`, `resolve/resolves/resolved/resolving`, `complete/completes/completed/completing`, `implements`. See [Linear's GitHub integration docs](https://linear.app/docs/github-integration). Non-closing link-only markers: `ref`, `references`, `part of`, `related to`, `contributes to`, `towards`. GitHub recognizes a similar but smaller set.

PR titles are Conventional Commits format (`<type>(<scope>)?: <subject>`). The parenthetical issue mentions in titles are descriptive; the load-bearing close markers go in the body.

## Sub-issue rollup

→ *Moved to* `cbk-conventions-reference.md` § Sub-issue rollup *(path-scoped; see § Rule loading and the instruction budget).*

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

**Deliverable trap — an unattended CI agent's deliverable is the posted artifact, not its exit code.** An auto-review workflow that runs green but posts no comment has failed silently: the run's success condition is its side-effect (the posted review), so the workflow should assert the artifact actually landed — and a green-run-no-comment symptom is investigated as a failure, not shrugged off.

**Exclusion is not exemption — linter-excluded surfaces get their own CI gate.** When a surface is deliberately excluded from the generic linter (a dialect the linter can't parse, generated-but-checked files, a DSL), it still gets a dedicated CI check of its own; otherwise the exclusion quietly becomes a standing exemption from all verification.

**Substring trap — quoting the literal marker token in a commit-message body re-triggers the matcher.** GitHub's match is a substring scan across the entire message, not anchored to the subject line or the end. A commit whose body explains *why* it's a fix for this trap, but quotes the literal token while explaining, is itself skipped. Use a paraphrase (e.g., "the CI-skip marker", "the conventional skip-tag") in prose; reserve the literal `[skip ci]` for the actual flag at the end of the subject line where you intend it to fire.

**Required-checks-block-merge trap — a skip-marked HEAD commit can't merge under strict branch protection.** When `main` requires status-check contexts with "require branches to be up to date" (strict), the CI-skip marker suppresses the CI workflow entirely, so those required contexts **never report** — the platform parks them as "Expected — Waiting for status to be reported" and the merge stays blocked indefinitely. (A separate always-on workflow can still run, making the PR *look* green while it stays unmergeable.) Net: `[skip ci]` saves nothing for a PR that has to merge through branch protection. For a docs-only PR bound for `main`, either (a) skip the marker on the final commit so CI runs and reports, or (b) keep the marker on the content commits but end the branch on a non-marker commit (`git commit --allow-empty -m "ci: run gates to satisfy required checks"`) before requesting merge. Same root cause and fix as the auto-review trap; the marker still earns its keep on intermediate WIP commits that don't open a PR to `main`.

## Dependency settle-window — supply-chain discipline

→ *Moved to* `cbk-conventions-reference.md` § Dependency settle-window — supply-chain discipline *(path-scoped; see § Rule loading and the instruction budget).*

## Methodology — choice space

→ *Moved to* `cbk-conventions-reference.md` § Methodology — choice space *(path-scoped; see § Rule loading and the instruction budget).*

## Verify-against-reality before a one-way door (optional practice)

→ *Moved to* `cbk-conventions-reference.md` § Verify-against-reality before a one-way door (optional practice) *(path-scoped; see § Rule loading and the instruction budget).*

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

→ *Moved to* `cbk-conventions-reference.md` § Spec-Kit vocabulary mapping *(path-scoped; see § Rule loading and the instruction budget).*

## Mutation discipline

| Artifact | Mutation rule | Supersession pattern | Rationale |
|---|---|---|---|
| `docs/adr/[0-9]{4}-*.md` | **Immutable** | New ADR with `Supersedes: ADR-NNNN` field; old ADR's status changes to "Superseded by ADR-MMMM" | ADR-0000 immutability discipline + hook enforcement + CI lint |
| `docs/cbk/blueprint.md` | **Append-only for new ADRs** (the Stack decisions table); otherwise immutable to preserve cascade history | Re-blueprint creates new file | Blueprint is a cascade event; mutation breaks the audit trail |
| `docs/cbk/frame-NN.md` | **Append-only for `## Rough-in events` table**; otherwise immutable post-commit | Re-framing creates `frame-MM.md` with `Supersedes: frame-NN` field; old frame's status → "Superseded" | Frames are cascade events; rough-in events are the timeline log |
| `docs/cbk/frame-MM.md` (additive increment) | **New file** (next sequential number); the prior frame is not mutated and stays `Active` | *No* supersession — an additive increment carries a `Builds on: frame-NN` header (not `Supersedes`); both frames stay `Active` and their open milestones coexist | Not every new framing replaces: an increment extends a workstream whose prior milestones are still valid and open, so the prior frame must not flip to `Superseded` (see the framing skill's `references/procedure.md` § Step 2 pattern D) |
| `docs/cbk/frame-MM.md` (milestone-scoped re-frame) | **New file** (next sequential number); the prior frame is not mutated | Header states `Supersedes only milestone M<N> of frame-NN`; the prior frame's index status is annotated `Active (M<N> superseded by frame-MM)` via the permitted status-column mutation; the retired milestone's acceptance-criteria set is recorded as retired-un-executed in the new frame | One milestone's shape can fail while its siblings are built and Done; whole-frame supersession would falsify the siblings' history (see the framing skill's `references/procedure.md` § Step 2 pattern E) |
| `docs/cbk/README.md` | **Append-only for new entries**; status column updates allowed | Status updates are mutations to single column, not whole-file rewrites | Status changes (Active → Superseded → Completed) need to flow |
| `docs/STANDARDS.md`, `docs/ARCHITECTURE.md`, `CLAUDE.md` | **Freely mutable** | n/a — living docs | Project-context docs evolve with the project; git history is the version archive |
| `.claude/rules/*.md` | **Freely mutable** | n/a | Operational rules; mutations are routine |
| `.claude/skills/*` | **Freely mutable** within the local copy | n/a | Tooling content; mutations refine the cascade |
| Code | **Freely mutable** | n/a | Standard code evolution |

Cascade events being append-only is structurally important: the cascade IS the audit trail of decisions. A new framing supersedes an old one with a new file; the old one stays in `docs/cbk/` for future readers to understand "we used to think X, now we think Y."

**The table and the hook registry are two views of one list.** A row enforced by a hook names it: ADRs → `protect-immutable-adrs.sh` (plus the CI lint); lock files → `protect-lock-files.sh`. A hook that enforces a rule clause rather than a table row names the clause: `protect-main-branch.sh` → § Branch naming; `require-repo-root-for-agents.sh` and `detect-forked-agent-memory.sh` → `pr-review.md` § Reviewer precedent memory (one home for the memory tree); `guard-pr-state.sh` → the PR-state one-way door in `cbk-conventions-reference.md` § HITL gate load-bearing heuristics; `require-knowledge-backend-ok.sh` → `knowledge-backend.md` § HITL announcement discipline. Rows with no hook (the append-only cascade artifacts, the index's status column) are instruction-enforced and carry a deferred-hardening note per § HITL gate load-bearing heuristics. The registry in `.claude/settings.json` lists the same hooks under their tiers, and the verification block checks the registry against the files. The authoring shape lives in `cbk-conventions-reference.md` § Hook authoring.
**ADR supersession has more than one grain.** The `docs/adr/*` row above shows whole-ADR supersession; two finer-grained relationships sit alongside it, both preserving the parent's immutability (neither edits the parent file):

- **Refine** — `Refines: ADR-NNNN (Dn, …)` in the child's header narrows or clause-level-clarifies a specific decision `Dn` in the parent **without invalidating it**. The parent stays **Accepted**; both parent and child are consulted for conformance. Use when implementation reveals an accepted clause was written too generally and needs a scoped reading, not a reversal. The parent gains **no back-pointer** (it is immutable) and **no status change** — discoverability comes from the child's `Refines:` field plus the child's ADR-index row.
- **Clause-scoped supersede** — `Supersedes: ADR-NNNN Dn` reverses only decision `Dn` of the parent while the parent's other clauses stand. The parent stays **Accepted** (it is not wholly superseded); the child's index row names the specific clause it replaces.

**Reviewers that check ADR conformance must follow the `Refines:` chain.** When an ADR intersecting a diff names a refiner (or a clause-scoped superseder), load that child too and apply its scoped clauses — a parent read in isolation yields the pre-narrowing reading. The kit's `adr-conformance-reviewer` agent (see `.claude/rules/pr-review.md` § Project-local agents to dispatch alongside) is where this chain-following lives.

## HITL gate load-bearing heuristics

→ *Moved to* `cbk-conventions-reference.md` § HITL gate load-bearing heuristics *(path-scoped; see § Rule loading and the instruction budget).*

## Trip-wire / phase-exit checklist pattern

→ *Moved to* `cbk-conventions-reference.md` § Trip-wire / phase-exit checklist pattern *(path-scoped; see § Rule loading and the instruction budget).*

## Recommended planning-backend settings

→ *Moved to* `cbk-conventions-reference.md` § Recommended planning-backend settings *(path-scoped; see § Rule loading and the instruction budget).*

## Knowledge backend — operator's specific choices

→ *Moved to* `cbk-conventions-reference.md` § Knowledge backend — operator's specific choices *(path-scoped; see § Rule loading and the instruction budget).*

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

→ *Moved to* `cbk-conventions-reference.md` § Verification *(path-scoped; see § Rule loading and the instruction budget).*

## References

- Upstream cascade tooling: `.claude/skills/{consultation,scaffold,blueprint,framing,rough-in}/SKILL.md`
- Cascade events for this project (once they exist): `docs/cbk/README.md`, `docs/cbk/blueprint.md`, `docs/cbk/frame-NN.md`
- Project docs (once they exist): `CLAUDE.md`, `docs/STANDARDS.md`, `docs/ARCHITECTURE.md`, `docs/adr/`
- Industry references: [GitHub Spec Kit](https://github.com/github/spec-kit), [Amazon Kiro Specs](https://kiro.dev/docs/specs/), [Tessl SDD](https://docs.tessl.io/use/spec-driven-development-with-tessl), [Martin Fowler / Birgitta Böckeler — SDD survey](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html), [Addy Osmani — How to write a good spec for AI agents](https://addyosmani.com/blog/good-spec/), [Anthropic Claude Code best practices](https://code.claude.com/docs/en/best-practices)
- Linear references: [GitHub integration](https://linear.app/docs/github-integration), [Parent / sub-issue auto-complete](https://linear.app/changelog/2024-09-06-auto-close-parent-and-sub-issues), [Branch naming](https://linear.app/changelog/2020-04-13-branch-naming)
