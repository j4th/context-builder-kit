# Harvest 5 design — v1.0.0: what three targets running ahead of the kit settled

**Date:** 2026-09-30
**Status:** Draft for operator review
**Type:** Design spec for evolving `context-builder-kit` itself, and its first tagged release
**Prior:** harvest 1 (`2026-07-04-…`, PR #4) · harvest 2 (`2026-08-09-cascade-kit-harvest-2-design.md`, PR #5) · axis parity (`2026-08-09-axis-parity-pass-design.md`, PR #7) · harvest 3 (`2026-09-06-cascade-kit-harvest-3-design.md`, PRs #54–#57) · harvest 4 (`2026-09-21-cascade-kit-harvest-4-design.md`, PR #59)
**Trace:** `2026-09-30-harvest-5-trace.md` — one row per ask, with the ask's issue and comment id

## What this is

Harvest 4 landed on 2026-09-22 as `74edf84`. Within a week all three targets had synced it, and then
they ran ahead of the kit:

- `j4th/you-are-hear` PR #90 recalibrated for Opus 5.5, generalised `finish-ab` to two to four arms
  with a headless runner, and measured subagent-driven `/finish` (not adopted).
- `j4th/echosphere` #55 and #56 hardened a path guard against ten bypass spellings and rebuilt the
  review bot's "posted" assertion.
- A third, private target's harvest-5 PR (100 commits, merged 2026-09-30) absorbed both and added
  its own final check. It is the latest exercised form of nearly every item.

The findings sit in sixteen open issues: #58 (reopened 2026-09-30 with a residue audit, rows R1–R14
and B) and #60–#74.

This pass lands all of them, and releases the kit as **v1.0.0**. It is the first tag. The five
earlier harvests are back-tagged, and a `CHANGELOG.md` records each release with the sync notes a
target needs. The install and upgrade path now speaks in versions.

### The pre-spec pass

A 20-agent workflow (`wf_d6e0ae85-8be`, 2026-09-30) ran two branches.

**Map.** Eight cluster readers (Sonnet 5.5 at `high`) produced **281 items**. Each item records:
- where the change lands in the kit;
- whether the defect is still live at `74edf84`;
- the exercised fix it ports from;
- what to sanitize, and any merge hazard.

Two checks followed:
- A completeness critic found **22 asks** no item carried, and **6 misreads**. All are folded into
  the trace.
- A refute-by-default verifier re-tried the 15 "not live" claims. One was refuted: the ADR guard is
  also bypassed through a linked worktree today.

**Review.** Five lenses reviewed the whole kit at the operator's request: consistency, Claude Code
best practices against the live docs, security and shell safety, release readiness, and portability
with dated facts. They produced 80 raw findings, which file-and-line dedup cut to **68 findings**.
- 38 verified by one refute-by-default Opus verifier per lens. None refuted.
- 30 over the per-lens bound of 8, returned unverified.

The main loop re-checked the five highest-impact verified findings against the raw doc pages. All
five hold:

| Finding | Source |
|---|---|
| Commands use `$1`, which is the **second** argument; `/finish 42` leaves `$1` as literal text and works only through the appended `ARGUMENTS:` line | skills page: "`$0` for the first argument or `$1` for the second"; "An indexed placeholder with no argument at its position stays as literal text" |
| `enabledPlugins` ships bare names; keys are `<entry-name>@<marketplace>` | plugin-marketplaces page, § Entry name |
| Hook commands are shell form with an unquoted `${CLAUDE_PROJECT_DIR}`; a path with a space makes every guard fail open | hooks page: "Set `args` whenever the hook references a path placeholder" |
| `tooling.md` (always loaded) says a repeated list in local settings "silently replaces" the committed one | settings page heading: "Lists merge instead of overriding" |
| `.mcp.json.example` launches two npm packages that return 404 and one that is deprecated; its hosted entries lack `type` | `npm view` (2026-09-30); mcp page |

## Governing constraints — five carry, two are new

1. **Portability invariant.** No project-specific identifier in kit content. A public target is named
   only in this spec and the trace, never in shipped kit files. The private target is named nowhere.
2. **Framework-not-tooling, per file on merits.** A fixture that makes a policy the kit already
   mandates runnable ships beside the existing ones.
3. **Sanitized only.** Every ported hunk is re-authored onto the kit's own text. A raw merge of a
   target's file imports that project's prose. Echosphere's application of #69 found this: a naive
   merge of `agent-cost.py` produced two `CACHE_READ` dictionaries, and the second silently shadowed
   the first.
4. **One-way.** The kit changes; no target is modified by this pass.
5. **Defer-to-exercised.** The latest exercised form wins unless an earlier one says why it must not
   generalise. For most items that is the private target's merged PR, re-authored. Where the kit's
   application differs from a target's, the kit wins and the difference is a sync note.
6. **Traceability (R14).** Every ask has a trace row with its location, `#N/body` or `#N/c<comment
   id>`, and its item label. An issue closes only when every row for it is landed or a named
   non-goal. Before merge, a refute-by-default audit re-checks every row not marked landed.
7. **Verify at execution (D56).** An unverified review finding lands only if it still holds when its
   commit is made. A platform fact is re-fetched raw and matched with `grep -F` on the day it is
   written into kit text, and dated there.

## Decisions (settled with the operator, 2026-09-29/30)

Numbering continues from harvest 4 (D30–D40).

| # | Decision | Outcome |
|---|---|---|
| D41 | Release mechanics | After merge, annotated tags go on the five past harvest merges and on this one: **v0.1.0** `db0eac7` (harvest 1, with everything before it), **v0.2.0** `6560f72`, **v0.3.0** `88b1ede` (axis parity), **v0.4.0** `e92e9c4` (harvest 3's four PRs), **v0.5.0** `74edf84`, and **v1.0.0** on this PR. `CHANGELOG.md` has one section per tag, and each carries **Sync notes**: what a target does by hand. The GitHub Release text is the v1.0.0 section. SemVer is informal: a major bump means a sync needs hand reconciliation beyond `git merge-file`; a minor bump is a harvest; a patch is fixes only. Scaffold's Kit commit row records `vX.Y.Z (sha)`. |
| D42 | Shape | One PR. Atomic commits grouped by the item they close. The verification block is green after every commit. |
| D43 | Shared path resolver | **Ship `.claude/hooks/lib/resolve-path.sh`.** This reverses harvest 4's no-helper-library non-goal. The suffix match #60 proposed closes 3 of the 10 bypass spellings. The resolver closes all 10, plus a bind mount and a linked worktree. The frozen-corpus recipe gives it a second caller in any target with a corpus. With it comes the sourced-helper contract in § Hook authoring: source only after the stdin drain, fail open naming the backstop when the helper is missing, define functions only. The `!/.claude/hooks/lib/` gitignore trap is named too. |
| D44 | Behavioural hook fixtures | Ship all three: guards, payloads and protected paths. They need only bash, git and jq, and the block runs them. They close R1, R6 and R8. |
| D45 | finish-ab | Ship the 2–4-arm workflow and the headless runner `run-arms-headless.py`, with the latest hardening. A workflow agent has no Agent tool, so only the runner can measure a `/finish` whose review floor fans out. |
| D46 | review-sweep | Dedup keys on file and line, using the normalized title only when a finding names no line. A merged finding carries every distinct title, and the verify prompt asks which report the evidence proves. Also: finders can carry a prompt, a failed roster read logs why it threw, find and verify prompts carry a read-only clause, and an interrupted run is re-run fresh. |
| D47 | Review-bot model | Family aliases `opus` and `sonnet`, never `best`. An explicit `--effort` on every branch, including `claude.yml` at `high`. A step records the model that actually ran. `ANTHROPIC_MODEL` is never set. The action's pinned SHA is the model pin, and Dependabot bumps it. |
| D48 | Review-bot trigger | `paths:` with `!**/*.md`, then `.claude/**` and `docs/adr/**` re-included last, so rule and ADR markdown is reviewed. A trigger fixture in the kit sub-block pins the order. |
| D49 | Recalibration | Opus 5.5, Sonnet 5.5 and Claude Code 2.1.284+:<br>• effort defaults per model and per surface; the kit's `high` settings called pins that need a sweep;<br>• thinking named per model;<br>• the ladder from Opus 5.5; current prices and per-model cache-read rates;<br>• Haiku 4.5's re-check trigger at 2026-10-15;<br>• subagent-driven `/finish` recorded as measured and not adopted, citing Anthropic's own "When delegation doesn't pay";<br>• the triad's task-tracking leg becomes "a tracked checklist". |
| D50 | Instruction budget | Record always-loaded bytes before and after. The block prints a non-failing warning above 140,000 bytes. |
| D51 | Block as a gate | #73's two fixes. Templates wire the block into `check` (R4). A check that every CI workflow and script the rules name as a backstop exists. `CACHE_READ` diffed against the quoted pricing sentence. The retired-section check widened to any citation. The spellchecker note (R5). |
| D52 | Target hygiene | The anchored `.gitignore` harness block. Kit-owned code kept out of a target's formatter and linter, with the exclusion forced for explicit paths. What Dependabot really covers for container images, and its three gaps. mise inline tasks run under bash with pipefail. Pinned MCP servers. |
| D53 | Citation hygiene | Kit content cites its own issues as `context-builder-kit#N` or not at all; a bare `#58` links to the target's own #58. Citations point at headings every target has by construction, which means the conventions, never a CONTRIBUTING or STANDARDS heading a template does not emit. |
| D54 | Branch rule | A PR that closes any issue carries that issue's key in the branch. The issue-less form is only for work no issue tracks. The Quick reference names both forms, and names the github-issues key form. |
| D55 | Frozen-corpus backstop | Consultation's enforcement set gains the list of ways a corpus CI check is fooled, and each closure. The bootstrap checklist gets one row per enforcement item. The ADR job takes the `:(glob)` body, fails closed on any git error, and checks out blobless. No corpus CI script ships. |
| D56 | Review scope | The whole-kit review's 68 findings join v1.0.0. The 38 verified land as written. The 30 unverified are re-checked when their commit is made, and land only if they hold. |
| D57 | Commands | `disable-model-invocation: true` on `/finish`, `/enrich`, `/intake`, `/pr-respond` and `finish-procedure`. They open branches, issues and PRs, the same one-way doors the phase skills already guard. Arguments come from named `arguments:` frontmatter, never `$1`. |
| D58 | `.mcp.json.example` | Rebuilt. `${VAR}` references instead of literal secrets; `type: "http"` on hosted servers; Linear's hosted endpoint; `time` pinned through `uvx`. The GitHub MCP entry is dropped, since `gh` is the kit's GitHub interface (D22). `.mcp.json` is committed with references, the model `tooling.md` already states. |
| D59 | Budget lever | Split `knowledge-backend.md` (20,336 bytes, always loaded, the one rule not yet split) into an always-loaded contract and a path-scoped `knowledge-backend-reference.md`. The recalibration's growth is paid from it. **Target: no net growth over 130,628 bytes.** |
| D60 | Install and upgrade | The Quick start extracts only the drop-in set from a **tagged** tarball, never the whole repository over the target. The README's "no upgrade mechanism" becomes the `git merge-file` sync against the installed tag. |
| D61 | Unreadable payloads | A payload jq cannot parse makes a hard-deny hook refuse and an ask-gate ask, instead of failing open. A missing dependency still fails open, naming its backstop. Probed at `74edf84`: the lock-file, main-branch and PR-state guards all pass a lone-surrogate payload today. |
| D62 | Repo hygiene | At HEAD, bracket-split the private target's name in the harvest-4 plan's sanitization grep. History keeps the old text; a public history rewrite is not proposed. |

### Settled calls — the mappers' open questions, decided with their recommendations

**Guards**
- The helper ships whole. Its corpus-mode functions are tested through a corpus double local to the
  fixture. No corpus hook ships.
- `protect-lock-files.sh` keeps deciding on the path text, and gains a `Not seen:` line: an edit
  through a symlink under another name.
- The ADR deny is path-independent: an existing `docs/adr/NNNN-*.md` is denied in any checkout, and
  linked worktrees count as roots. The hook header states why: every target keeps ADRs at that
  path, and a session in one target edits its siblings.
- The ADR job uses a three-dot diff (from the merge base). A two-dot diff reports an ADR added on
  `main` as deleted when the PR branch is behind.
- The kit's own workflows get `defaults: run: shell: bash` and a named runner image, as the
  templates do.
- The backstop-exists check reads workflow and script paths in the kit sub-block. Task-runner names
  (`mise run X`, `just X`) are a templated project-sub-block line. The mutation table's ADR row names
  its workflow file.
- #62's backstop wording is a bracketed slot, filled at scaffold's rule-file disposition pass. The
  project sub-block refuses an unfilled slot.
- The corpus enforcement rows go into the bootstrap checklist's verification matrix, conditional on
  a designated corpus.

**Gate**
- Scaffold's disposition table gains a row for `cbk-conventions-reference.md`'s manifest and
  lockfile globs. Without it, a fresh scaffold fails its own block.
- Every fixture runs in the kit sub-block. `hook-guards-fixture.sh` skips a knowledge-backend hook the
  axis deleted, and reads the hook's name from the registry.
- A case that needs a tool the host lacks (`unshare`, GNU `stat`) prints an explicit `SKIP` line.
  Fixtures state the userland they assume. A skip is never silent.
- Light mode's minimum task set includes the verification task.
- The runner owes no rail for "kit sub-block complete" beyond #73's project rail.

**Review bot**
- The review-assert fixture ships with synthetic comment pages authored for the kit.
  `extract-run-block.sh` is shared by it and the ADR-job fixture.
- The template's default effort stays `high`.
- Template comments state the action-bump re-check duty themselves, and cite `orchestration.md` only
  secondarily.
- The record-model step runs with `continue-on-error: true`, because it is informational.
- Two issue quotes are reworded to the live page's text: the `fable` alias history, and the
  `paths-ignore` negation rule.
- The assert step's comment states its base-SHA limit for PRs into a non-default base.
- The trigger fixture passes, with a notice, a filled workflow that has no path filter.
- Dated alias facts (which action release moves `opus` and `sonnet`) live in
  `orchestration-reference.md` and the CHANGELOG, not in the templates.

**Recalibration**
- The contract keeps operative clauses. Quotations, per-model numbers and changelog sub-lists go to
  `orchestration-reference.md`.
- Alias wording names the provider and the version, e.g. "on the Anthropic API from Claude Code
  2.1.280".
- Probe P2 below settles "a workflow agent has no Agent tool" on the release CLI, dated, before
  `pr-review.md` states it.
- The capstone close-marker sentence goes into `finish.md` item 8 as a dated observation: GitHub
  rolls no closure up the sub-issue tree. This settles the critic's conflict flag.
- The subagent-driven arm protocol is not shipped. Its mechanics are described in prose.
- #65: the reference half's slot becomes prose, and the project sub-block refuses the contract's
  unfilled posture slot. `§ The three surfaces + resolution order` is renamed `§ The dispatch
  surfaces + resolution order` in both halves, with every citation swept.
- The synthesis-slot row gains a re-sweep note for the cost page's Fable 5.1-at-`low` result.

**Harness**
- Every file is ported from the private target's merged form (a strict superset of the others),
  sanitized.
- The runner's unconditional `mise trust` becomes an optional `worktree_setup` list.
- The MCP allowlist is a constant: `context7` and `time`.
- The runner's docstring names the environment it strips.
- The operator brief's review-workflow line becomes mode-aware.
- No verdict-rule template ships. The launching session adjudicates contamination.
- Judges get the read-only clause.

**Review conventions**
- A merged finding is triaged by the report its verifier named. Its other titles stand as
  unverified.
- No fourth `## Review gate` line. A post-floor verification workflow records on the existing lines,
  as "not a second floor". No saved script ships for it.
- #74 item 2 lands in rough-in's `research-phase.md`, with a pointer in `contract.md` and a test
  criterion.
- The accounting test's existing labels are left as they are.

**Hygiene**
- The `.mcp.json.example` rebuild follows D58.
- `.claude/workflows/*` joins `format-on-edit.sh`'s skip floor.
- The kit's own `.gitignore` carries the harness block, plus `/.claude/settings.local.json`.
- The Dependabot non-Docker-Hub cooldown wording is re-authored from a fresh read.
- `tooling.md` step 1 carries the mise version floor.
- The kit's `dependabot.yml.example` gains the docker stubs.

**Release**
- Tags as mapped in D41. Harvest 3's four PRs fold into v0.4.0. Tags are annotated.
- CHANGELOG headings carry the date and PR number. The squash sha is unknown until merge.
- The drop-in set:
  - `.claude/`
  - `.mcp.json.example`
  - `.github/dependabot.yml.example`
  - `.github/workflows/adr-immutability-check.yml`

  Never the README, LICENSE, CLAUDE.md, `.gitignore` or `docs/`. Scaffold instantiates the ADR
  starters from `references/adr-starters/`.
- #66's three restatements become pointers. Its heading is retitled `## Relation grains`.
- R14's audit method is codified in this repository's `CLAUDE.md` § Working in this repo, as the
  gate for every future harvest.
- The fail-fast residual stays recorded here only (D31).
- The Kit commit fallback for a target with an older, immutable `scaffold.md` goes in the reference
  half.
- The `STANDARDS.md` citations in the executor procedure are in scope under D53.
- No separate workflow-fixtures task ships: the block runs every fixture. This settles the critic's
  other conflict flag.

## What lands — ten clusters, in commit order

The block must be green after every commit, so each fixture lands in the same commit as the fix it
pins, and the gate lands first.

### V1 · The block as a gate — #73, #58 R4 R5 (D51)

- `run-verification-block.sh` gains a third rail. In a filled target, where `docs/cbk/scaffold.md`
  exists, the output must also contain `verification: project sub-block complete`. It lands with
  `run-verification-block-fixture.sh` (six cases), which the block runs.
- The Stop-hook check becomes `stop_hook_clean`. Exit 0 with a `WARNING` is "the hook could not
  look", and that is red in a gate. Its negative case (outside any checkout, under a git ceiling)
  lives in the block, so a regression is caught where the check runs.
- The blueprint `tooling.md` minimum task set, including light mode, gains a verification task that
  `check` depends on. The bootstrap checklist's verification matrix runs it and expects both
  sentinels.
- § Verification's preamble names the bracket idiom's cost for spellcheckers. It shows the `typos`
  `[type.<name>]` table with `extend-glob` naming the one file, never a repo-wide ignore.
- The budget line prints a non-failing warning above 140,000 bytes.

### V2 · Guards and their CI backstops — #60, #61, #62, #58 R1 R6 R8 R11 R13 (D43, D44, D55, D61)

- **Hook.** `lib/resolve-path.sh` ships.
  - It reads the payload exactly: one jq, and an unparseable payload returns an error.
  - It resolves each path twice, lexically and physically, one component at a time through
    symlinks.
  - It refuses `/proc` and unreadable symlinks.
  - It compares device and inode with bash's `-ef`.
  - Its roots are the hook's own checkout (derived lexically from `BASH_SOURCE`), linked worktrees,
    and `CLAUDE_PROJECT_DIR`.
- **ADR guard.** `protect-immutable-adrs.sh` is rewritten onto the helper. The existence test runs on
  the resolved path, so a new ADR stays creatable. Its header gains `Path:`, `Not seen:` and
  `Depends:` lines, naming the residuals: Bash-tool writes, case-insensitive filesystems, hand
  edits, and a symlink swapped between check and write.
- **D61.** Every hard-deny guard refuses an unreadable payload, and the ask-gate asks. § Hook
  authoring's fail-open bullet gains the distinction: an environment defect opens; unreadable input
  to a guard closes.
- **Main-branch guard.** `protect-main-branch.sh`'s `git commit` pattern stops matching only a
  bare leading `git`. `bash -c`, `sh -c`, quoting, `/usr/bin/git` and chained verbs are caught, and
  the same anchor in `guard-pr-state.sh` is fixed. The header states what a pattern guard cannot
  see.
- **#62.** Every fail-open warning names its surviving backstop, with a bracketed slot for the
  target's CI lockfile check and ruleset. The PR-state gate says honestly that no mechanical
  backstop exists. The ADR hook's jq warning is included; that one came from the audit, not #62.
- **R8.** The lock-file fallback's remediation says to give the file a case arm of its own above the
  `*.lock)` arm.
- **R13.** The fork detector's rule 1 states what it guarantees. The Residual line stays.
- **R11.** § Hook authoring and both advisory exemplars' `Register:` headers say that wiring one
  takes three edits, not one.
- **§ Hook authoring** gains the sourced-helper contract, and one sentence holding a target's own
  hooks to the same contract. `hook-contract-fixture.sh`'s early-reader tripwire reads `lib/*.sh`.
- **ADR job** (`adr-immutability-check.yml`):
  - the `:(glob)` pathspec body, which parses no paths;
  - `--diff-filter=a --no-renames`, three-dot from the merge base;
  - fails closed on any git error;
  - `filter: blob:none`, `shell: bash`, a named runner image.

  It lands with `adr-ci-body-fixture.sh`, which extracts the job's own `run:` body. The block pins
  `absent grep 'mapfile … <('`.
- **Consultation's frozen-corpus enforcement set.** It gains the red-team closure list, and says
  that whether an added file passes is the target's call. The recipe says to extend the ADR job
  with the parse-nothing body. The bootstrap checklist gets one row per enforcement item.
- **Backstop-exists check.** Every `.github/workflows/*.yml` and script path the mutation table or
  the hook registry names must exist. The checker is asked about bogus names first, so it cannot
  pass by matching nothing.
- **Fixtures, run by the block:**
  - `protected-paths-hook-fixture.sh`: the ADR half, the helper-missing and no-jq cases, and the
    corpus double;
  - `hook-guards-fixture.sh`: main-branch (including payload-cwd precedence both ways), PR-state,
    lock files (every arm plus the fallback), and the knowledge-backend ask-gate;
  - `hook-payloads-fixture.sh`: the launch-root guard and the fork detector, including the
    partial-scan case.

### V3 · Claude Code conformance — the whole-kit review (D56, D57)

- **Commands.** Every `$1` in `/finish`, `/enrich`, `/intake`, `/pr-respond`, `finish-procedure`
  and their bundled copies becomes a named argument declared in `arguments:` frontmatter. Each gets
  `disable-model-invocation: true`. `CLAUDE.md`'s invocation-posture paragraph names the commands.
- **Hooks.** Every registration in `settings.json`, and both advisory exemplars' `Register:`
  stanzas, move to exec form: `"args": []`. The registry check in the block accepts the form.
- **Plugins.** `enabledPlugins` keys become `pr-review-toolkit@claude-plugins-official` and
  `commit-commands@claude-plugins-official`, with the rule stated where the comment lists them.
- **Explore.** `Explore.md` gains `omitClaudeMd: true` (v2.1.271+, dated), and its description is
  trimmed to its routing sentence.
- **Settings merge.** `tooling.md` § MCP configuration's decision rule is rewritten to the
  documented behaviour. Lists merge across scopes; the four model-list keys are the stated
  exceptions.
- **Untrusted input.** `/intake` and `/pr-respond` state the research-phase rule: report and comment
  text is data, and an imperative inside it is surfaced, never acted on. `/intake` writes its own
  reproduction and never runs a reporter's command verbatim.
- **Unverified findings in this class**, re-checked at execution: `/pr-respond`'s triage citing
  path-scoped sections it never loads; the reviewer that flags logging `logging.md` permits; a
  cited `knowledge-backend.md` section that does not exist; `simplification.md`'s unsourced
  behaviour claims.

### V4 · Review-bot templates — #67, #68 §2, #70 §1–3, #58 R12 (D47, D48, D52)

- **Model and effort.** Aliases and explicit `--effort` on every branch, per D47. `claude.yml` gains
  `--effort high`. A `Record the resolved model` step goes on both templates, with an `id` on each
  action step. The prompt's `Model in use:` line says it shows the alias.
- **"Assert the review posted".** Pages are slurped and counted once. The summary's verdict marker
  is matched on `updated_at`, and the step runs on `!cancelled()`. The "no session" notice is keyed
  on an empty `execution_file` plus a diff of the workflow file; an unchanged file means an auth or
  setup failure. The template's "designed-unexercised" line is restamped with the exercised negative
  path. Lands with `review-assert-fixture.sh` on synthetic pages.
- **Trigger.** `paths:` in D48's order, with a fork guard in the job `if:`. `concurrency` moves to
  job level, so a skipped run cannot cancel a live review. The stale `track_progress`-on-`labeled`
  claim is dated or removed. Lands with `review-trigger-fixture.py` in the kit sub-block. The
  blueprint `tooling.md` review-bot paragraph names the `paths` shape.
- **Prompt:**
  - The base-branch restore: `.claude/`, `.mcp.json` and the root `CLAUDE.md` read as the base's,
    and the PR's copies are under `.claude-pr/`. A symlinked `CLAUDE.md` resolves through the PR's
    `AGENTS.md`, and a nested `CLAUDE.md` reads at the PR head. The review states which rule
    version it applied.
  - Report only commands actually run.
  - Read CI with `gh pr checks`.
  - A comment above `claude_args` says a gate in the prompt needs a matching `--allowedTools` entry.
  - N is sized against `--max-turns`: N = 40 against 60, re-measured on the pinned release.
  - The action-bump PR re-checks effort, the turn cap and N.
- **Shell safety (#70).** Here-strings for every label check; the label read captured before it is
  tested; `defaults: run: shell: bash`; `runs-on: ubuntu-24.04` with its reason. The kit sub-block
  carries #70's three assertions.
- **`tooling.md`.** § Automated review says a workflow "cannot review any PR that changes it". It
  also says a harness fact the bot asserts is checked against the operator's Claude Code version.

### V5 · Recalibration and the budget — #69 (rule items), #65, #74 §3, #68 §3, #58 R9 (D49, D50, D59)

- **`orchestration.md`, operative clauses only:**
  - effort defaults per model and surface; thinking per model;
  - `high` called a pin pending a sweep;
  - the ladder from Opus 5.5;
  - price steps 2× / 2× / 2.5×;
  - Haiku 4.5's re-check trigger;
  - caps recorded: `CLAUDE_CODE_WORKFLOW_MAX_CONCURRENT_AGENTS`, the size guideline, the ultracode
    exemptions;
  - the named-subagent-becomes-teammate trap;
  - a text-only end of turn is a report;
  - #74 §3: the Agent tool takes no effort, so a floor's effort is recorded, not pinned;
  - #72 §4: read-only agents.
- **`orchestration-reference.md`:** every quotation, re-fetched raw and dated on the day it is
  written; the price and cache-read table; the changelog rows; the dated alias facts.
- **Subagent-driven execution.** `workflows.md` § Subagent dispatch records why `/finish` is inline,
  when subagent-driven pays, and the rules for anyone who delegates implementation. The evidence
  cites `context-builder-kit#69` and Anthropic's "When delegation doesn't pay". The triad's
  task-tracking leg becomes "a tracked checklist".
- **`simplification.md`** records `/simplify`'s changelog history in place of a local spot check.
- **`pr-review.md` § The floor** adds a workflow agent to the reasons an Agent tool is absent (after
  probe P2).
- **#68 §3.** The grounding rules gain rule 4: check which binary a tool name resolves to from inside
  the code's own execution context, with `command -v` or `type -a`, never `type -P`. The "three
  rules" count is swept in `failure-modes.md` and framing's `research-phase.md`.
- **#65.** The three hygiene items, the heading rename, and the unfilled-posture check.
- **R9.** A conditional note on the 3.2× pooled cost ratio.
- **D59.** `knowledge-backend.md` splits into contract and reference. The block's always-loaded
  inventory and § Rule loading name the new pair. Scaffold's `none`-axis disposition, which deletes
  the rule, its hook and its settings stanza, now deletes both halves.

### V6 · Harness code — #69 (harness items and comments) (D45)

- **`finish-ab.js`:**
  - two to four arms, per-arm model and effort;
  - a Latin-square panel;
  - structured, order-independent judge measures;
  - `executed` mode, `base`/`brief`/`rubric` args;
  - `runner_check` logs named in the judge prompt;
  - blindness notes, and the read-only clause for judges.
- **`run-arms-headless.py`:**
  - worktree per arm, auto mode;
  - `--strict-mcp-config` with the allowlist constant;
  - the deny list, with the bare `git push` rule dropped because `git push *` covers it;
  - continuations that keep `--append-system-prompt`;
  - `--resume-existing` that survives an empty payload;
  - the continuation cap stated per pass;
  - `check_command` run once per arm, serially, logs beside `out_dir`;
  - `--dry-run`; closed files;
  - the optional `worktree_setup` list.
- **Rubric and brief** state no arm count. The brief gains "The issue, verbatim".
- **`agent-cost.py`:**
  - one version-keyed `PRICE` and one `CACHE_READ` (Fable 5.1 and Mythos 5.1 at 0.025×, Opus 5.5
    at 0.05×, default 0.1×), fixing the legacy Fable 5 misprice every target carries;
  - `tier()` matches a key whole;
  - `<synthetic>` messages and fast mode priced correctly.

  The block's price diff is re-keyed by version, and a `CACHE_READ` diff is added against the quoted
  sentence.
- **Fixtures:**
  - `agent-cost-fixture.sh` as a union of harvest 4's cases and #69's, run with `python3 -B`, with
    both mutants failing;
  - `finish-ab-shape.mjs` with the new scenarios, including the `ARM_SCHEMA` drift test between the
    two copies;
  - `run-arms-headless-fixture.sh` with a fake `claude`, failing on a `ResourceWarning`.
- **`.gitignore`** covers the runner's worktree root.

### V7 · Review conventions — #72, #74 §1–2, #58 B R10, #64 (D46)

- **`review-sweep.js`:**
  - prompt-carrying finders; a finder with neither prompt nor agent is dropped coverage, named on
    the gate line;
  - file-and-line dedup carrying every title;
  - the logged roster throw;
  - `READ_ONLY` in every find and verify prompt.

  `review-sweep-accounting.mjs` gains the scenarios, and its stub records each call's prompt.
- **`pr-review.md`:**
  - the finder shape;
  - invariant (3) reworded, including triage by the report the verifier named;
  - invariant (2) covers an interrupted floor or sweep: it is re-run fresh, and memory it wrote is
    discarded;
  - § The floor › Once gains the one-verification-workflow rule.
- **Rough-in's `research-phase.md`** gains the re-verify-a-consolidation-at-the-gate rule, with a
  contract pointer and a test criterion.
- **`pr-review-reference.md` § Anti-patterns** gains "Folding one review layer into another" (B).
- **R10.** The roster guidance: enumerate a family of directories, because a family has no prefix
  form.
- **#64.** `pr-respond.md`'s bullet agrees with Step 7.
- **Unverified findings in this class**, re-checked at execution: the "four-class" rubric with five
  rows; the break-glass `--skip-review` flag the executor does not parse; the reference half's
  docs-only anti-pattern that contradicts the floor.

### V8 · Target hygiene — #70 §4–6, #71, #58 R7 (D52, D58)

- **Dependabot.** A Dockerfile `FROM` and a compose `image:` are covered by the `docker` and
  `docker-compose` ecosystems. The three gaps are named, with the `COPY --from` remediation: route
  the image through a named stage. This is on all three surfaces that said "not covered by any bot".
  The Dependabot examples gain the stubs.
- **mise.** The tooling template's mise section carries
  `[task_config] shell = "bash -O inherit_errexit -c -o errexit -o pipefail"` with the version floor.
  A pin checks it.
- **Kit-owned code** stays out of a target's formatter and linter scope, forced for explicit paths.
  This is tool-neutral, with ruff's `--force-exclude` as the example. `format-on-edit.sh`'s arm
  comment says so, and its skip floor names `.claude/workflows/`. The bootstrap checklist gets a
  one-time row.
- **`.gitignore` harness block** in `github-starter-templates.md`. It is pinned by
  `git check-ignore` in a throwaway repo, and the kit's own `.gitignore` carries it. The unanchored
  `reference/` line in the kit's `.gitignore` is removed or anchored; that one is unverified,
  re-checked at execution. § `.gitignore` anchoring names worktrees and kit bytecode as harness
  transients.
- **D58.** `.mcp.json.example` is rebuilt. The pins are dated at least 7 days old on the release day.
  The settle-window section says an MCP server is a dependency. README, `tooling.md` and the
  example agree on how secrets are handled.

### V9 · Consistency, citations and small rot — #63, #66, #68 §1, #58 R2 R3, review findings (D53, D54, D62)

- **Citations.** The four executor citations of `CONTRIBUTING.md` § Branches, and the `STANDARDS.md`
  section citations, point at the conventions. The eight citations of the retired § Deferred
  meta-issues become § Pre-flight checks, and the block's check widens to any citation. The
  `cascade-rule-reviewer`'s "commit format" pointer is fixed. Bare kit-issue citations become
  `context-builder-kit#N` or the fact they stand for, and a kit-tree check keeps them out. The
  sibling name in `cbk-conventions-reference.md` is removed.
- **#66.** The three restatements become pointers.
- **D54.** The branch rule and the Quick reference row.
- **R2.** `/finish` Step 1 admits a meta's child title as a fifth form, in all four executor files.
- **R3.** `adr-new` reads the index's rows, including both forms a row can take, and pins no
  separator.
- **Verified review findings:**
  - "six" or "seven" issue sections become eight everywhere (scaffold, the four backends copies,
    `plan-mode-prompts.md`, test cases);
  - one AC-id form across the contract, both templates and the conventions;
  - blueprint's markdown-only acknowledgment rekeyed on `Planning backend = in-repo-markdown`;
  - the unshipped `methodology_register.md` and `sdd.md` citations repointed at the shipped excerpt;
  - the four `backends.md` copies dated and diffed by the block;
  - the CI-skip trap sourced, with all five marker spellings;
  - the Linear free-tier claim corrected;
  - Notion's plan-gated Verification property named.
- **Unverified findings in this class**, re-checked at execution: the gate and state counts in
  scaffold and blueprint; the rough-in 3–7 vs 2–6 count; the phase-exit claim; pointer headings in
  the reference halves; the label taxonomy's three missing labels; the in-repo-markdown issue-template
  claim; § Hook authoring's hook tally.
- **D62.**

### V10 · The release — D41, D60, R14, the release-lens findings

- **`README.md`:**
  - counts and inventory from the tree;
  - the Quick start per D60 (a tagged tarball, the drop-in set, the install tag recorded);
  - declared prerequisites with what each absence costs: jq, git, gh, bash, node and python3 for
    fixtures, and a Claude Code floor;
  - "how to start a phase", since four phase skills are invoke-only;
  - the "Exercised vs designed" table restamped, now that github-issues has been exercised;
  - the advisory-stanza line corrected;
  - the finish.md customisation paragraph rewritten.
- **`CHANGELOG.md`:** v0.1.0–v1.0.0, each with what landed and **Sync notes**. v1.0.0's notes list
  the files a target has filled and must hand-merge: both review workflows, `.mcp.json`, the
  orchestration pair, `tooling.md`, `settings.json`. They also say ahead-of-kit files merge against
  the kit commit that lands them, not the install sha.
- **`cbk-conventions-reference.md` § Syncing the kit** speaks in versions, and gains three notes:
  - after resolving `settings.json`, diff the `hooks` block's event keys against the pre-merge
    copy;
  - the Kit commit fallback for an older target;
  - ahead-of-kit files merge against the landing commit.

  Scaffold's Kit commit row records `vX.Y.Z (sha)`.
- **This repository's `CLAUDE.md`** gains the R14 audit method, and a correction: the kit ships
  hooks, JS and Python with fixtures, so "no code to verify" no longer holds.
- **`LICENSE`** gains a copyright line.
- **After merge, with the operator's confirmation:** annotated tags, then `gh release create v1.0.0`
  from the CHANGELOG section.

## Probes at execution — facts this spec does not assume

| # | Probe | Why | Decides |
|---|---|---|---|
| P1 | A hook payload's `cwd` after the Bash tool runs `cd`, on the release CLI | The hooks page now says `cwd` "follows Claude … after Claude runs `cd`". Harvest 3 measured the opposite, and `require-repo-root-for-agents.sh` rests on that measurement. | The guard's header and trigger description, and whether the guard now fires on a `cd` |
| P2 | Whether a workflow agent has an Agent tool (plain and worktree-isolated) | A two-target probe, not documentation | The `pr-review.md` § The floor sentence and its date |
| P3 | Whether the record-model step's job-summary line lands | Unexercised in every target | Stays "designed-unexercised", dated, if it cannot run |
| P4 | Unprivileged user namespaces on the CI image | The bind-mount cases need them | The cases print SKIP; the dated observation records which |
| P5 | The current hosted MCP endpoints (Linear, Notion, context7) and the pinned `time` server | D58 | `.mcp.json.example` |
| P6 | Every quotation, raw, with `grep -F`, typographic apostrophes normalised | Constraint 7 | Each quotation's date |

## Sequencing — one PR (D42)

Branch `feat/harvest-5-v1.0.0`. The spec and the trace are its first commit. Clusters land in order
V1 → V10. Each commit is Conventional Commits and names the trace ids it closes.

Every commit must be:
- green on the live block, extracted from the reference file on every run;
- green on every fixture;
- clean under `bash -n` for every hook.

The review floor runs **once**, when the known work is complete: `/simplify`, then
`pr-review-toolkit:review-pr`, with `review-sweep` beside it. That review sweep uses the D46
rewrite, which dogfoods it. Triage follows the four-class rubric, and the PR body carries
`## Review gate` and `## Triage`.

Before the trace audit, the PR body records:
- the always-loaded total before and after;
- the trace summary: landed, non-goal, and not holding at execution.

Tags and the GitHub Release follow the merge, after the operator confirms.

## Non-goals — explicitly NOT harvested

- The collect-then-exit block. D31's fail-fast stands, and a kit-side red still hides a target's
  project checks. Recorded here, not in kit text.
- A file-count-scaled `--max-turns`, or an auto-selected deep-review path. D37 stands.
- you-are-hear's `/finish`-at-`medium` choice as a default. It is one project's data point.
- Mirroring Claude Code's full runtime ignore list, which is version-specific and grows.
- A frozen-corpus CI script or corpus hook exemplar (D55). The recipe and the resolver's corpus mode
  are the kit's part.
- The subagent-driven arm protocol file, and a saved post-floor verification workflow.
- A public history rewrite (D62).
- Any target's own fills: globs, roster prefixes, plugin lists, reviewer bodies, recorded comment
  data.
- Any reference to the private target in shipped kit content.

## Verification — definition of done

1. The block is green on the kit tree under literal `bash -e` after every commit, all sentinels
   printed; `verify.yml` is green on the PR.
2. Every fixture is green and run by the block:
   - `hook-contract`, `hook-guards`, `hook-payloads`, `protected-paths`;
   - `adr-ci-body`, `review-assert`, `review-trigger`;
   - `run-verification-block`, `run-arms-headless`, `agent-cost`;
   - `finish-ab-shape`, `load-workflow-shape`, `review-sweep-accounting`.

   Each new fixture was shown red against the unfixed file before it went green. The plan records
   how, since D42 lands a fixture with its fix.
3. `settings.json` parses. Every hook registration is exec form. Every `enabledPlugins` key is
   `name@marketplace`. No top-level hook-shaped object.
4. No `$1`-style placeholder remains in a command. The four commands and `finish-procedure` carry
   `disable-model-invocation: true`. The executor pair is byte-parallel with its bundled copies.
   `/finish` Step 1 names five title forms.
5. The always-loaded total is at or below 130,628 bytes, or the PR body records the overage and why.
6. Sanitization: the private-target denylist grep is clean across the whole tree, including
   `docs/`. No sibling name appears in `.claude/`, `.github/`, `README.md` or `CLAUDE.md`. No bare
   kit-issue citation remains.
7. Trace audit: every row is landed, a named non-goal, or recorded as not holding at execution. A
   refute-by-default verifier checks each row not marked landed. #58 and #60–#74 close by marker.
8. The floor ran once and is recorded in `## Review gate`, with the sweep's line.
9. `CHANGELOG.md` covers v0.1.0–v1.0.0. The D60 Quick start is tested by extracting a local tag
   archive into a scratch repository, checking that only the drop-in set lands. After merge:
   - annotated tags pushed;
   - `gh release create v1.0.0` from the CHANGELOG section;
   - the README's install command resolved against the real tag.
