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
- **Upstream / pre-cascade docs:** `<path to any frozen reference material, or "none">` — a designated corpus follows the consultation skill's `references/frozen_corpus_ingestion.md` (read in full, never edited; its `<slug>-errata.md` companion amends)
- **Problem brief / scaffold output:** `docs/cbk/problem_brief.md` · `docs/cbk/scaffold.md`
- **Tooling conventions:** `<record any project-specific tool / MCP-selection conventions here — the code-intelligence route (the built-in LSP tool via the language plugin, or an MCP for a language without one), which live-docs MCP to prefer, or the project's model/effort orchestration conventions for dispatched agents — or "defaults">`
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

**The issue-less branch.** Operator-directed maintenance that no cascade issue tracks — a dependency bump the bot did not open, a docs sweep, a hook fix — takes the form `<type>/<short-slug>` with no issue segment, and its PR body carries the statement **"operator-directed maintenance; no cascade issue"** as its first line. The scope fence is § Contribution intake: anything that adds behaviour, fixes a reported bug, or touches a workstream's code is a cascade issue (`/intake`, `/enrich`, or framing), never an issue-less branch. Such a PR still carries the `## Review gate` block; what stands in for the floor is written as *not run* with the reason ("not run — docs-only sweep, no code changed"), never left blank and never described as run.

Create the branch and make the first commit in **separate tool calls**: the default-branch guard judges a compound command on the branch at entry, so `git switch -c … && git commit …` is blocked even though the commit would have been legal by the time it ran.

### Linear `{type}` placeholder — set the type label at issue creation (Linear only)

*Applies only when the planning backend is Linear.* Linear's branch-name template (`Settings > Workspace > Branch names`) resolves `{type}` from the issue's built-in **Feature / Bug / Improvement** type label — and **caches the resolved value into the issue's `gitBranchName` at creation time**. Relabeling afterward does *not* update the suggested branch name, and an issue with no type label defaults to `Feature`, producing `feature/…` branches for `chore`/`docs`/`refactor` work that aren't in the Conventional Commits type list. So the type label must be set in the **initial** `save_issue` call, not retroactively. Mapping from the Conventional Commits type to Linear's coarser taxonomy:

| Conventional Commits type | Linear type label |
|---|---|
| `feat` | Feature |
| `fix` | Bug |
| everything else (`chore`, `docs`, `refactor`, `test`, `perf`, `style`, `build`, `ci`) | Improvement |

The rough-in / `/intake` / `/enrich` flows set this at issue-creation time — see the rough-in skill's planning-backend matrix.

## Licensing

→ *Moved to* `cbk-conventions-reference.md` § Licensing *(path-scoped; see § Rule loading and the instruction budget).*

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

**Deliverable trap — an unattended CI agent's deliverable is the posted artifact, not its exit code, in both directions.** An auto-review workflow that runs green but posts no comment has failed silently: the run's success condition is its side-effect (the posted review), so the workflow should assert the artifact actually landed — and a green-run-no-comment symptom is investigated as a failure, not shrugged off. The converse holds too: a run that ends red *after* posting its complete review has succeeded — an exercised run did exactly that. The artifact decides; the exit code is evidence, not the verdict.

**Exclusion is not exemption — linter-excluded surfaces get their own CI gate.** When a surface is deliberately excluded from the generic linter (a dialect the linter can't parse, generated-but-checked files, a DSL), it still gets a dedicated CI check of its own; otherwise the exclusion quietly becomes a standing exemption from all verification.

**Substring trap — quoting the literal marker token in a commit-message body re-triggers the matcher.** GitHub's match is a substring scan across the entire message, not anchored to the subject line or the end. A commit whose body explains *why* it's a fix for this trap, but quotes the literal token while explaining, is itself skipped. Use a paraphrase (e.g., "the CI-skip marker", "the conventional skip-tag") in prose; reserve the literal `[skip ci]` for the actual flag at the end of the subject line where you intend it to fire.

**Required-checks-block-merge trap — one symptom, three causes.** Under strict branch protection or a ruleset that requires status-check contexts, a PR parks on "Expected — Waiting for status to be reported" and stays unmergeable indefinitely (a separate always-on workflow can still run, making the PR *look* green). GitHub names the family in its troubleshooting page for required checks — a required check "skipped by path filtering, branch filtering, or a commit message" never reports (`docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/troubleshooting-required-status-checks`, read 2026-09-06). The three causes, with the fix at each:

1. **The CI-skip marker on the HEAD commit** suppresses the workflow, so its required contexts never report. For a docs-only PR bound for `main`, either drop the marker on the final commit so CI runs, or end the branch on a non-marker commit (`git commit --allow-empty -m "ci: run gates to satisfy required checks"`). The marker still earns its keep on intermediate commits that open no PR to `main`.
2. **A `paths:`-filtered workflow backing a required check** does not run on a diff that matches nothing, so its context never reports. A required-check workflow carries **no trigger filter**; any narrowing happens inside the job as a fast no-op exit — § Exclusion is not exemption, applied to trigger filters. The kit's own ADR-immutability lint is written this way for that reason.
3. **A promoted check-run's name changes.** Matching is by name: a job renamed after promotion, or a job with no explicit `name:` whose default shifts, orphans the required context under its old name (a dated field observation, 2026-09-06, from two exercised runs — not a documented platform claim; re-verify against the page above before relying on the exact wording). A job destined for promotion carries an explicit, stable `name:` set *before* promotion; after it, the name is immutable API — rename the workflow, never the job.

## Dependency settle-window — supply-chain discipline

→ *Moved to* `cbk-conventions-reference.md` § Dependency settle-window — supply-chain discipline *(path-scoped; see § Rule loading and the instruction budget).*

## Methodology — choice space

→ *Moved to* `cbk-conventions-reference.md` § Methodology — choice space *(path-scoped; see § Rule loading and the instruction budget).*

## Verify-against-reality before a one-way door (optional practice)

→ *Moved to* `cbk-conventions-reference.md` § Verify-against-reality before a one-way door (optional practice) *(path-scoped; see § Rule loading and the instruction budget).*

## Multi-surface facts

Some facts are stated in more than one place by design — an ADR and its index rows, a rule and the reviewer that enforces it, a template and the executor that parses it, a repo artifact and its knowledge-backend companion. Stated once, the discipline is:

- **Every restatement records where the fact's other statements live**, and an edit sweeps every recorded location in one commit — never "update the index later".
- **Back-pointers are asymmetric.** The immutable source never points forward — an ADR gains no link to its refiners, its extenders, its corrections or its companion page; the companion points back. Discoverability is the companion's job plus the index row.
- **A re-check trigger is reachable from the line that fires it** — a dated rail names what re-verifies it *at the rail*, not in a separate list.
- **Closed sets are machine-maintained where the tree can** — the verification block diffs the copies it can reach (the bundled executor templates, the reviewers' `## Writing memory`, the adr-starters, the price table); a set the tree cannot diff carries its other locations in prose, at each copy.

**The companion vocabulary** — an *immutable source* plus an *append-only companion* — has three instances: `docs/adr/NNNN-*.md` + `docs/adr/corrections.md` (claims that proved wrong); a frozen pre-cascade corpus + its `<slug>-errata.md` (consultation's `references/frozen_corpus_ingestion.md`); a repo artifact + its knowledge-backend companion page (`knowledge-backend.md` § When to write). The four rules apply to each. § ADR index sync below is the first instance of this discipline, and a drift-guard test whose subject is the consistency itself is the fourth test shape (`testing.md` § Quick reference).

## ADR index sync

Every ADR addition (and every supersession) updates **multiple indexes** in lockstep:

1. **`docs/adr/README.md`** — canonical ADR index with status, dates, and short descriptions
2. **`docs/ARCHITECTURE.md` § Decisions log** — orientation-level table mirroring the README
3. **`docs/ARCHITECTURE.md` § Configurability summary** (if the project uses a configurability-first principle)
4. **`docs/cbk/blueprint.md` § Stack decisions** — also updated for post-blueprint ADRs (since blueprint.md is itself a cascade artifact)

This list is the one home for the sync targets: `adr-new` reads it and states no count of its own; on drift the README index row is canonical and the other surfaces are corrected to it. The blueprint's § Stack decisions table is append-only and gains a one-line bullet only when the ADR changes a *stack* decision — it is a cascade artifact, not an index. The `adr-new` skill (at `.claude/skills/adr-new/SKILL.md`) automates the cross-index sync. Manual ADR creation works but is error-prone (multiple indexes to keep in sync); use the skill.

ADR immutability should be enforced two ways:
- **A PreToolUse hook** at `.claude/hooks/protect-immutable-adrs.sh` blocks Claude Code edits to existing ADR files
- **A CI lint** at `.github/workflows/adr-immutability-check.yml` diffs `docs/adr/[0-9]{4}-*.md` files in PRs and fails on changes to existing ADRs (closes the raw-git-access gap that the hook can't catch). It carries no `paths:` filter and a pinned job name, so it can be a required check — § `[skip ci]` rule, the required-checks trap, causes 2 and 3

Both belong in any project that takes ADRs seriously; the kit's `adr-new` skill assumes both exist.

## Spec-Kit vocabulary mapping

→ *Moved to* `cbk-conventions-reference.md` § Spec-Kit vocabulary mapping *(path-scoped; see § Rule loading and the instruction budget).*

## Mutation discipline

| Artifact | Mutation rule | Supersession pattern | Rationale |
|---|---|---|---|
| `docs/adr/[0-9]{4}-*.md` | **Immutable** | New ADR with `Supersedes: ADR-NNNN` field; old ADR's status changes to "Superseded by ADR-MMMM" | ADR-0000 immutability discipline + hook enforcement + CI lint |
| `docs/adr/corrections.md` | **Append-only**; dated entries never edited — a correction to a correction is a new entry; evidence annotated under the entry when its meaning goes stale | n/a | The claim companion to the immutable ADRs (§ Multi-surface facts); `protect-immutable-adrs.sh` leaves it editable by design |
| A designated frozen pre-cascade corpus + `<slug>-errata.md` | Corpus **frozen** — read in full, never edited by any phase; the errata companion **append-only** and dated ("amends; never edits") | n/a — a superseded reading is a new errata entry | The reference material the cascade inherits verbatim (consultation's `references/frozen_corpus_ingestion.md`); scaffold registers the hook, CI job, `.gitattributes` and editor entries that keep it byte-stable |
| `docs/cbk/blueprint.md` | **Append-only in three sections** — the Stack decisions table (new ADRs), `## Amendments`, `## Retired justifications`; otherwise immutable to preserve cascade history | Re-blueprint creates new file | Blueprint is a cascade event; mutation breaks the audit trail |
| `docs/cbk/frame-NN.md` | **Append-only for `## Rough-in events` table**; otherwise immutable post-commit | Re-framing creates `frame-MM.md` with `Supersedes: frame-NN` field; old frame's status → "Superseded" | Frames are cascade events; rough-in events are the timeline log |
| `docs/cbk/frame-MM.md` (additive increment) | **New file** (next sequential number); the prior frame is not mutated and stays `Active` | *No* supersession — an additive increment carries a `Builds on: frame-NN` header (not `Supersedes`); both frames stay `Active` and their open milestones coexist | Not every new framing replaces: an increment extends a workstream whose prior milestones are still valid and open, so the prior frame must not flip to `Superseded` (see the framing skill's `references/procedure.md` § Step 2 pattern D) |
| `docs/cbk/frame-MM.md` (milestone-scoped re-frame) | **New file** (next sequential number); the prior frame is not mutated | Header states `Supersedes only milestone M<N> of frame-NN`; the prior frame's index status is annotated `Active (M<N> superseded by frame-MM)` via the permitted status-column mutation; the retired milestone's acceptance-criteria set is recorded as retired-un-executed in the new frame | One milestone's shape can fail while its siblings are built and Done; whole-frame supersession would falsify the siblings' history (see the framing skill's `references/procedure.md` § Step 2 pattern E) |
| `docs/cbk/ROADMAP.md` (github-issues and in-repo-markdown axes) | **Freely mutable** — a status surface, not a cascade event | n/a — a wrong row is fixed in place; a superseded row reads *retired* | Where we are and what is next; blueprint writes it, framing appends rows in the frame's commit, rough-in flips to *roughed-in*, `/finish` flips to *done* on the PR's own branch or the post-merge checklist does (`commands/finish.md` item 8). The audit trail is the index and git history, never this file |
| `docs/cbk/README.md` | **Append-only for new entries**; status column updates allowed. Scaffold creates it (from its index template); blueprint, framing and rough-in append a row and a phase note each | Status updates are mutations to single column, not whole-file rewrites | Status changes (Active → Superseded → Completed) need to flow |
| `docs/STANDARDS.md`, `docs/ARCHITECTURE.md`, `CLAUDE.md` | **Freely mutable** | n/a — living docs | Project-context docs evolve with the project; git history is the version archive |
| `.claude/rules/*.md` | **Freely mutable** | n/a | Operational rules; mutations are routine |
| `.claude/skills/*` | **Freely mutable** within the local copy | n/a | Tooling content; mutations refine the cascade |
| Code | **Freely mutable** | n/a | Standard code evolution |

Cascade events being append-only is structurally important: the cascade IS the audit trail of decisions. **Two status surfaces are carved out of the executor's cascade-artifact ban** — the roadmap row and a frame's `## Rough-in events` table — because they record state, not decisions; the row above and `commands/finish.md` item 8 say who flips them and when. A new framing supersedes an old one with a new file; the old one stays in `docs/cbk/` for future readers to understand "we used to think X, now we think Y."

**The table and the hook registry are two views of one list.** A row enforced by a hook names it: ADRs → `protect-immutable-adrs.sh` (plus the CI lint); lock files → `protect-lock-files.sh`. A hook that enforces a rule clause rather than a table row names the clause: `protect-main-branch.sh` → § Branch naming; `require-repo-root-for-agents.sh` and `detect-forked-agent-memory.sh` → `pr-review.md` § Reviewer precedent memory (one home for the memory tree); `guard-pr-state.sh` → the PR-state one-way door in `cbk-conventions-reference.md` § HITL gate load-bearing heuristics; `require-knowledge-backend-ok.sh` → `knowledge-backend.md` § HITL announcement discipline. Rows with no hook (the append-only cascade artifacts, the index's status column) are instruction-enforced and carry a deferred-hardening note per § HITL gate load-bearing heuristics. The registry in `.claude/settings.json` lists the same hooks under their tiers, and the verification block checks the registry against the files. The authoring shape lives in `cbk-conventions-reference.md` § Hook authoring.
**ADR supersession has more than one grain.** The `docs/adr/*` row above shows whole-ADR supersession; two finer-grained relationships sit alongside it, both preserving the parent's immutability (neither edits the parent file):

- **Refine** — `Refines: ADR-NNNN (Dn, …)` in the child's header narrows or clause-level-clarifies a specific decision `Dn` in the parent **without invalidating it**. The parent stays **Accepted**; both parent and child are consulted for conformance. Use when implementation reveals an accepted clause was written too generally and needs a scoped reading, not a reversal. The parent gains **no back-pointer** (it is immutable) and **no status change** — discoverability comes from the child's `Refines:` field plus the child's ADR-index row.
- **Clause-scoped supersede** — `Supersedes: ADR-NNNN Dn` reverses only decision `Dn` of the parent while the parent's other clauses stand. The parent stays **Accepted** (it is not wholly superseded); the child's index row names the specific clause it replaces, and the parent's index row is annotated (`Accepted · Dn superseded by ADR-MMMM`) while the parent file stays untouched.
- **Extend** — `Extends: ADR-NNNN (Dn, …)` adds an obligation beside a parent clause that **stays satisfied as written**. The parent stays **Accepted** and is not narrowed; the child adds a check the parent alone would not raise. **The disambiguation test:** a child that *removes a permitted reading* of the parent clause is a Refine; one that *adds an obligation beside a clause that stays satisfied* is an Extend. Both are asymmetric — the parent gains no back-pointer; the child's header field and its index row carry the relation, and the status cell carries grain and parent inline (`Accepted · Extends ADR-0003 (D1)`).
- **Promote** — `Promotes: <corpus path> § <heading>` records a decision lifted from a frozen pre-cascade corpus (the consultation skill's `references/frozen_corpus_ingestion.md`); the corpus is the provenance, the ADR the binding form.

A wrong **claim** inside an accepted ADR — a citation, a figure, an attribution, a formula — is none of these grains: it goes to `docs/adr/corrections.md`, the append-only register, and the ADR stays as written.

**Reviewers that check ADR conformance must follow the `Refines:` and `Extends:` chains.** When an ADR intersecting a diff names a refiner (or a clause-scoped superseder), load that child too and apply its scoped clauses — a parent read in isolation yields the pre-narrowing reading. An extender is the asymmetric case: the parent passes unchanged while the child can fail, so a diff clean against the parent is not clean until every extender is checked. A reviewer consults `docs/adr/corrections.md` before flagging a claim, and cites an entry rather than restating it. The kit's `adr-conformance-reviewer` agent (see `.claude/rules/pr-review.md` § Project-local agents to dispatch alongside) is where this chain-following lives.

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
| Updating the cascade-events index | `docs/cbk/README.md` — see § Mutation discipline (its row names the creator and the appenders) |
| Flipping the roadmap row | `docs/cbk/ROADMAP.md` — see § Mutation discipline (its row names who flips it and when) |
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
