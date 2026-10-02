# Changelog

Every release of the kit, newest first. A release is an annotated tag `vX.Y.Z` on `main`. The versioning is informal SemVer: a major bump means a sync needs hand reconciliation beyond `git merge-file`, a minor bump is a harvest, and a patch is fixes only. Numbers such as #59 are this repository's pull requests and issues.

Each release's **Sync notes** say what a target does by hand when its sync crosses that release. Read the notes of every release after the one your **Kit commit** row records, then follow `.claude/rules/cbk-conventions-reference.md` § Syncing the kit. Each harvest's design is under `docs/superpowers/specs/`.

## [Unreleased]

Nothing yet.

## [1.0.0] — 2026-09-30 — harvest 5 (PR #75)

The first release to be tagged; the five before it are tagged on their merge commits after the fact. It closes #58 and #60–#74, and the findings of a review of the whole kit. Design: `docs/superpowers/specs/2026-09-30-cascade-kit-harvest-5-design.md`, with one trace row per ask beside it.

### What landed

- **The verification block as a gate.** `run-verification-block.sh` gains a third rail: in a filled target, where `docs/cbk/scaffold.md` exists, the output must also carry `verification: project sub-block complete`. The Stop-hook check reds a hook that could not look. Blueprint's tooling template gives `check` a verification task, light mode included. The budget line warns above 140,000 bytes.
- **Guards that resolve the path they guard.** `.claude/hooks/lib/resolve-path.sh`, a sourced helper, resolves a path lexically and physically and compares device and inode. The ADR guard is rewritten onto it. A hard-deny guard refuses a payload `jq` cannot parse, and an ask-gate asks. The main-branch and PR-state guards match a command behind `bash -c`, quoting, a full path or a chained verb. Every fail-open warning names its surviving backstop. The ADR CI job reads a `:(glob)` pathspec, diffs three-dot from the merge base and fails closed on any git error. Three behavioural hook fixtures run in the block.
- **Claude Code conformance.** The commands declare named `arguments:` and carry `disable-model-invocation: true`. Every hook registration is exec form (`"args": []`). `enabledPlugins` keys read `<plugin>@claude-plugins-official`. `tooling.md` states how settings lists merge across scopes. `/intake` and `/pr-respond` treat report and comment text as data.
- **Review-bot templates.** The family aliases `opus` and `sonnet`, with an explicit `--effort` on every branch. A step records the model that ran. The "Assert the review posted" step is rebuilt and has a fixture. A `paths:` trigger still reviews markdown under `.claude/` and `docs/adr/`, and has a fixture. A fork guard, concurrency at job level, a prompt that applies the base branch's rules, and label checks fed as here-strings.
- **Recalibration for Opus 5.5 and Sonnet 5.5.** `orchestration.md` carries effort defaults per model and surface and the ladder from Opus 5.5; its reference half, `orchestration-reference.md`, carries the current prices and cache-read rates. `§ The three surfaces + resolution order` is now `§ The dispatch surfaces + resolution order` in both halves. `knowledge-backend.md` splits into a contract and a path-scoped `knowledge-backend-reference.md`. `workflows.md` records why `/finish` runs inline.
- **Harness.** `finish-ab.js` runs two to four arms, each with its own model and effort, under a balanced judge panel. `run-arms-headless.py` runs each arm as a headless session in its own worktree. `agent-cost.py` keys its prices and cache-read rates by model version.
- **Review conventions.** `review-sweep.js` deduplicates on file and line and carries every title, takes finders that bring their own prompt, and tells every find and verify agent to stay read-only.
- **Target hygiene.** A `.gitignore` harness block for targets. What Dependabot covers for container images, and its three gaps. mise tasks run under bash with `pipefail`. Kit-owned code stays out of a target's formatter and linter. `.mcp.json.example` is rebuilt: `${VAR}` references, `type: "http"` on hosted servers, Linear's hosted endpoint, `time` pinned through `uvx`, and no GitHub server, because `gh` is the kit's GitHub interface. #70's mise and MCP rows land in blueprint's tooling template and in `.mcp.json.example`; no `mise.toml` template ships.
- **Consistency.** Citations point at headings every target has. Kit issues are cited `context-builder-kit#N`. `/finish` Step 1 admits five title forms. `adr-new` reads the index's rows in both of their forms.
- **The whole-kit review.** The floor and a bounded sweep read the branch before it opened, and every finding was triaged. What it changed: a guard's fail-open warning reaches the user as a `systemMessage`, since stderr on exit 0 goes only to the debug log; the advisory hooks exit 2 on a finding, the one PostToolUse exit Claude sees; the review assertion lands on a bold verdict or a bold `**SKIPPED**` skip line; each review path's prompt states the dispatch rule its tool list allows; `claude.yml` gates bots in its job `if:`; the blueprint template emits the § Workstreams and § Manual setup sections the cascade cites; the Linear label taxonomy creates what the Linear flows apply; `agent-cost.py` bills each response once — one line per response, and once across a directory, so a fork no longer pays again for its parent's history — prices 1-hour cache writes at 2x, and names a row whose output is a streaming snapshot as a floor, with the kit's own dated cost figures re-derived from their original transcripts; the experiment runners refuse a malformed config before they spend; and four platform claims were re-read at their sources and corrected.
- **The release.** This changelog. `README.md`'s Quick start installs the drop-in set from a tagged archive and prints the release to record. § Syncing the kit speaks in versions, and scaffold's **Kit commit** row reads `vX.Y.Z (sha)`.
- Always-loaded rules: 130,628 bytes at v0.5.0, 132,803 bytes at v1.0.0. Checked on Claude Code 2.1.286 and 2.1.287.

### Sync notes

- **Hand-merge these files.** This release rewrites text a filled target changes in each of them. Merge each three ways from the release your Kit commit row records, and keep what the project filled:
  - `.github/workflows/claude-review.yml` and `.github/workflows/claude.yml`, your copies of blueprint's review templates. Keep your label names, turn cap, sizing, allowed tools and the filled `REVIEW_LOGIN`. Take the model and effort lines (`claude.yml` now runs `--effort high`), the `Record the resolved model` step, the rebuilt "Assert the review posted" step, the fork guard, `concurrency` moved into the job, `defaults: run: shell: bash`, `runs-on: ubuntu-24.04`, the step ids `review` and `claude`, the prompt's restore section with its two new bracketed fills, the notes above `claude_args`, the label step's `dispatch_rule` output with the two prompt lines that read it, the assertion's bold verdict marker and the prompt's `**SKIPPED**` docs-only line, and in `claude.yml` the bot and `skip-claude` gates moved into the job `if:` (the gate step is gone). The `paths:` filter replaces `paths-ignore`: put your own prose-only negations above the re-includes of `.claude/**` and `docs/adr/**`. The kit sub-block now runs `review-trigger-fixture.py` and `review-assert-fixture.sh` against your filled `.github/workflows/claude-review.yml`, so a target that syncs the rules before merging this workflow is red until it does.
  - The CI workflow blueprint generated from its skeleton (usually `.github/workflows/ci.yml`). It was never a kit copy, so there is nothing to merge: edit it to match the skeleton. That means `defaults: run: shell: bash`, `runs-on: ubuntu-24.04`, and every `uses:` pinned to a full commit SHA with a trailing version comment, in place of a tag such as `actions/checkout@v4`.
  - `.mcp.json`, your copy of `.mcp.json.example`. Keep the servers your axes use. The kit ships no GitHub entry, hosted entries carry `"type": "http"`, and `time` runs pinned through `uvx`. Turn every literal credential into a `${VAR}` reference, export the variable before launching `claude`, and commit the file. The kit sub-block now checks the committed file's shape: a url entry without a type, an unpinned `npx`, `uvx` or `bunx` server, or a literal credential turns it red.
  - `.claude/rules/orchestration.md` and `.claude/rules/orchestration-reference.md`. Keep your posture row and your dated applied instances; take the kit's text for its own kit-shipped observations, whose cost figures are re-derived. Re-point any citation of `§ The three surfaces + resolution order` to `§ The dispatch surfaces + resolution order`.
  - `.claude/rules/tooling.md`. Keep your filled stack sections; take § MCP configuration's merge rule and § Automated review on the git host.
  - `.claude/settings.json`. Keep your own hooks' registrations, rewritten in exec form, and re-add their names and tiers to `_comment_hooks`. Then diff the hook event keys against your pre-merge copy (§ Syncing the kit).
  - `.claude/rules/cbk-conventions.md` and `.claude/rules/cbk-conventions-reference.md`. Keep your filled values and your project sub-block; take everything in the block above it. In `cbk-conventions.md`, take § Branch naming's rule that any issue a PR closes, cascade or not, puts its key in the branch (the bare issue number on the `github-issues` axis; `<type>/<short-slug>` only for work no issue tracks) with its Quick reference row, and the reworded substring trap in the CI-skip rule's section, which names all five skip tokens and GitHub's skip trailer and cites GitHub's page. The kit sub-block pins both, so a copy that keeps the old wording is red.
  - `.claude/rules/pr-review.md` and `.claude/rules/pr-review-reference.md`. Keep your roster entries; take the floor, the sweep and the invariants.
  - `.claude/rules/simplification.md` and `.claude/rules/workflows.md`. Take the kit's text; keep a filled § Cost+scope-explicit.
  - `.claude/rules/knowledge-backend.md`. It is now two halves. On the `notion` axis, take both, `knowledge-backend.md` and `.claude/rules/knowledge-backend-reference.md`, and move each filled value under its heading. On the `none` axis, where the rule was deleted, add neither half.
  - `.claude/commands/finish-procedure.md` and `.claude/skills/rough-in/references/finish-procedure.md`. Their citations now point at the conventions: a copy whose `CONTRIBUTING.md` citation was filled by hand takes the kit's text.
  - `.claude/skills/adr-new/SKILL.md`. Take the kit's text: it reads the index's rows in both forms, and its `## Refines vs Supersedes vs Extends` section is now `## Relation grains`, a pointer to `.claude/rules/cbk-conventions-reference.md` § ADR relation grains. Repoint any citation of "adr-new § Refines vs Supersedes" in your filled rules, reviewers or docs at `adr-new` § Relation grains or § ADR relation grains; an ADR that cites it stays as written, and the correction goes in `docs/adr/corrections.md`.
  - `.claude/hooks/format-on-edit.sh` and `.claude/hooks/analyze-on-edit.sh`. Keep your filled case arms; take the exec-form `Register:` stanza and the exit 2 on a formatter failure or an analyzer error (exit 0 hid it in the debug log), and in `format-on-edit.sh` the skip floor, which now names `.claude/workflows/` (an analyzer only reads, so `analyze-on-edit.sh` has no floor).
  - `.github/workflows/adr-immutability-check.yml`. Re-copy it from the kit, then restore only your comments and the pinned job name: the job body is replaced. It reads a `:(glob)` pathspec, diffs three-dot from the merge base with `--no-renames`, checks out blobless, runs under `shell: bash` on a named runner image, and fails closed on any git error.
- **Files a target may already run ahead of the kit.** These carry this release's harness and guard ports: `.claude/workflows/agent-cost.py`, `.claude/workflows/tests/agent-cost-fixture.sh`, `.claude/workflows/finish-ab/finish-ab.js`, `.claude/workflows/tests/finish-ab-shape.mjs`, `.claude/workflows/finish-ab/run-arms-headless.py`, `.claude/workflows/tests/run-arms-headless-fixture.sh`, `.claude/workflows/review-sweep.js`, `.claude/workflows/tests/review-sweep-accounting.mjs`, `.claude/hooks/protect-immutable-adrs.sh` and `.claude/hooks/lib/resolve-path.sh`. For each one your target already carries, diff your copy against v1.0.0's. Where the kit's application differs from yours, take the kit's, and keep only your project's own fills. From this sync on, v1.0.0 is these files' merge base, not your install (§ Syncing the kit).
- **New files.** Add `.claude/hooks/lib/resolve-path.sh`, which is sourced, never run. A `.gitignore` with an unanchored `lib/` line hides it from `git add` without a word: add `!/.claude/hooks/lib/` after that line, and after the sync commits check that `git ls-files .claude/hooks/lib/` names the helper (if it does not, `git check-ignore -v .claude/hooks/lib/resolve-path.sh` names the line that hides it). Add the new fixtures under `.claude/workflows/tests/`, each an `add` row: the three hook fixtures `protected-paths-hook-fixture.sh`, `hook-guards-fixture.sh` and `hook-payloads-fixture.sh`; `adr-ci-body-fixture.sh`; `review-assert-fixture.sh` and `review-trigger-fixture.py`; `run-verification-block-fixture.sh`; `extract-run-block.sh`, which the ADR and review-assert fixtures source; and, unless your target already runs them ahead (above), `.claude/workflows/finish-ab/run-arms-headless.py` and `run-arms-headless-fixture.sh`, which are required, because the block runs the fixture and the fixture fails without the runner. The block runs every one of them but the sourced helper. Append the harness block from scaffold's `references/github-starter-templates.md` § `.gitignore` to your `.gitignore`, below every stack section, and state its pin assertions in the commit body; the kit's own `.gitignore` is not in the drop-in set.
- **Kit-owned code stays out of your formatters.** Exclude `.claude/workflows/**` from every repo-wide formatter and linter, forced for explicit paths (§ Syncing the kit). A wired `format-on-edit.sh` merges the new skip-floor line.
- **mise runs tasks under bash with `pipefail`.** A target on mise adds the `[task_config]` block from blueprint's `templates/tooling.md` step 1 to its `mise.toml` and pins mise ≥ 2026.7.15 wherever tasks run, CI's setup action included. Nothing in the kit checks a target's `mise.toml`.
- **Dependabot covers more than the settle-window said.** `rust-toolchain.toml` is covered by Dependabot's `rust-toolchain` ecosystem, and so is a container base-image tag; a target whose filled § Dependency settle-window lists either as uncovered corrects that section, which now names the three image gaps.
- **The cost reader keys by model version.** A target synced at v0.5.0 prices legacy Fable 5 cache reads at Fable 5.1's 0.025x until it takes v1.0.0's `agent-cost.py`, which reads them at the standard 0.1x. A target that runs `run-arms-headless.py` sets its config's `worktree_setup` to its own per-worktree step, and adds any write-capable MCP server it wires beyond the kit's `github`, `linear` and `notion` to `WRITE_SERVERS`, which makes the file a `merge` row in its sync table.
- **A filled target owes both sentinels.** `.claude/workflows/tests/run-verification-block.sh` is a `copy` row with a third rail: it fails a target whose output lacks `verification: project sub-block complete`. `.claude/workflows/tests/run-verification-block-fixture.sh`, which the block runs against the runner, is an `add` row. Wire the runner as a verification task your `check` depends on, per blueprint's `templates/tooling.md`. If you never stamped the bracketed manifest-and-lockfile globs in `cbk-conventions-reference.md`'s `paths:`, stamp them now (the bootstrap checklist's disposition pass has the row), or the project sub-block is red. The block's `CLAUDE.md` check now fires in a target only once `docs/cbk/blueprint.md` exists: from then on your `CLAUDE.md` must mention `cbk-conventions` as a backticked path, never an `@` import.
- **Fill the three hook backstop slots.** A guard's fail-open warning names the backstop that still stands, and three of them are the project's to name: `[the project's CI lockfile check — …]` in `protect-lock-files.sh`, and `[the base branch's ruleset — pull requests only — where one exists]` in both warnings of `protect-main-branch.sh`. The bootstrap checklist's disposition pass gains a **Hook backstop slots** row: replace each bracket with the real check or ruleset, or with `none` and the reason. The project sub-block refuses a slot left bracketed. A filled slot makes those two hooks `merge` rows in your sync table.
- **The commands no longer start from a description.** `/finish`, `/intake`, `/enrich`, `/pr-respond` and `finish-procedure` carry `disable-model-invocation: true`: type them.
- **Kit issue citations are qualified.** Kit text cites its own issues as `context-builder-kit#N`, because a bare number links to the target's own issue. The rewrite touches about thirteen files a target copies byte for byte, among them the hooks, the workflow scripts and their tests, the executor pair and `adr-new`: take the kit's side of every such hunk. A copy you patched by hand takes the kit's form. The kit sub-block's bare-citation check runs on the kit's own tree only; in yours a bare number is your own issue.
- **Re-copy the issue templates.** `.github/ISSUE_TEMPLATE/cascade-meta.md` and `.github/ISSUE_TEMPLATE/cascade-rough-in.md` are byte copies of scaffold's `references/issue-templates/`, and both changed: re-copy them. The project sub-block is red while your `cascade-meta.md` still cites the retired § Deferred meta-issues.
- **An unreadable payload now denies.** A hard-deny guard refuses a payload `jq` cannot parse, and an ask-gate asks. A missing `jq` still fails open, naming its backstop.
- **The ADR guard judges what a path is, not how it is spelled.** `protect-immutable-adrs.sh` sources `lib/resolve-path.sh`, resolves the path lexically and physically, and denies an Edit, Write or MultiEdit to an existing numbered ADR in any checkout, whatever spelling, relative path or symlink names it; its `Not seen:` line lists what it cannot see (a Bash write, a case-insensitive filesystem, a hand edit, a symlink swapped between check and write), which the ADR CI job refuses at the pull request. A target that customized its ADR hook takes the kit's hook (a `copy` row) plus the helper (an `add` row), carries anything it still needs as a named exception (§ Syncing the kit), and checks the helper is tracked (**New files**, above).
- **A dispatch after a `cd` is judged where the shell is.** A hook payload's `cwd` follows the Bash tool's `cd` (the probe is recorded in `require-repo-root-for-agents.sh`'s `Timing:` paragraph). So the launch-root guard now denies an Agent, Task or Workflow dispatch made after a `cd` into a subdirectory, and `protect-main-branch.sh` judges a commit against the checkout the shell is in. Return to the repository root, as its own command, before dispatching.
- **The review model is the action's pin.** The templates name the family aliases, so a review runs whatever model the pinned `anthropics/claude-code-action` release's Claude Code resolves them to. `opus` resolves to Opus 5.5 on the Anthropic API from Claude Code v2.1.280, and `sonnet` to Sonnet 5.5 from v2.1.284 (`https://code.claude.com/docs/en/model-config` § Version history, read 2026-09-30). The action installs Claude Code 2.1.280 from its v1.0.232 and 2.1.284 from its v1.0.236 (`src/entrypoints/run.ts`, `claudeCodeVersion`, read 2026-09-30). A workflow pinned below v1.0.232 still reviews on the previous model under `opus` (Opus 5 from Claude Code v2.1.219), and below v1.0.236 on Sonnet 5 under `sonnet`: bump the pinned SHA.
- **A guard's fail-open warning is now shown.** Every guard prints its fail-open warning as a `systemMessage` on stdout as well as on stderr, which on exit 0 reaches only the debug log; the Stop hook gathers its notes the same way. The guards are `copy` rows: take the kit's. A hook of your own follows § Hook authoring's fail-open bullet. Beside it, the main-branch guard allows the root commit of an unborn branch and reads a command continued with a backslash-newline, and the lock-file guard names `npm-shrinkwrap.json` and `bun.lockb`.
- **A blueprint written before this release has no § Workstreams table.** `/finish`, `/intake` and framing look a workstream slug up there. `blueprint.md` is immutable, so append the table — workstream, slug, layer — under its append-only `## Amendments`, from the slugs its slug gate confirmed. On the `in-repo-markdown` axis, setup progress belongs on the roadmap's step-0 row, never in commits to `blueprint.md`.
- **A Linear target relabels its workstreams.** Scaffold used to create one `area:<slug>` label per workstream; every Linear flow applies `workstream:<slug>`. Rename them, and create the `enhancement`, `source:<name>`, `triage` and `appetite:small` / `medium` / `big` labels the flows apply.
- **The experiment runners refuse before they spend.** `run-arms-headless.py` refuses a config with an unknown key, a budget or continuation count out of range, or a dry run combined with resume, and records each arm in `executed.json` as `{anon, cell, result}`. `finish-ab.js` refuses an unknown argument or effort and an executed record whose cell does not match, and drops a judge whose scores do not cover every arm. `review-sweep.js` refuses malformed arguments: a list that is not a list, a bound that is not a whole number, a `verifyModel` other than `opus`, `sonnet` or `haiku`. A saved config or call that relied on the old leniency fails loudly; fix it rather than the check.
- **Cost figures read before this release overstate.** `agent-cost.py` summed every transcript line, and Claude Code writes one response as several; it billed a fork again for the parent history its transcript opens with; and it priced every cache write at the 5-minute rate, where a 1-hour write bills at 2x. The kit's own dated figures were re-derived from their original transcripts: they ran 1.5x to about 2.2x high, all from the per-line count (`orchestration-reference.md` § Applied instances). Re-run a figure of your own on its original transcripts before comparing it across releases. From Claude Code 2.1.278 a subagent's responses are mostly recorded mid-stream, so a figure read from a current transcript is a floor on output and cost; the reader names the rows it applies to.
- **The `## Review gate` block has a "not run" form.** An issue-less branch writes its `/simplify` and toolkit lines `not run — <reason>`; a cascade PR's docs-only diff still runs the floor (`pr-review.md` § What NOT to flag).

## [0.5.0] — 2026-09-22 — harvest 4 (PR #59)

The kit as applied: what two targets' syncs of v0.4.0 found. It closes #33 and lands every finding on #58 that had a proven fix; #58 stays open for its residue, which v1.0.0 closes. Design: `docs/superpowers/specs/2026-09-21-cascade-kit-harvest-4-design.md`.

### What landed

- **Settings liveness.** The two `_example_PostToolUse_*` objects are deleted from `settings.json`; an advisory hook's registration stanza lives in its header's `Register:` line. The block asserts that no top-level key holds a hook-shaped object.
- **The hook stdin/exit contract.** Every hook drains stdin first and decides on here-strings, never on a pipeline whose reader can exit first. `hook-contract-fixture.sh` checks both structurally over every hook and probes the decision sites past the pipe buffer.
- **The exercised fork detector**, with its prune rules, its staging-copy prune and its degrade path under a fixture probe.
- **The verification block's runner**, `run-verification-block.sh`, with two fail-loud rails, and the kit's own CI, `verify.yml`, which runs it on every pull request to main. `ADVISORY_WIRED` declares a target's wired advisory hooks.
- **Harness fixes.** Per-tier cache reads in `agent-cost.py`; `review-sweep.js`'s boundary-safe hint match, roster-read `.catch` and retry reindex; `finish-ab.js`'s distinct arm labels.
- **Records.** `/finish` Step 1 admits `[<slug>:meta]`. `adr-new` writes the index row in the index's own form. Scaffold's **Kit commit** row and § Syncing the kit.
- **Templates.** Both review workflows grant `checks: read` twice, fetch the base ref after the head checkout, and degrade explicitly past the turn cap. The knowledge-backend matcher is widened to the live tool set.

### Sync notes

- Delete any `_example_*` key, and any other hook-shaped top-level key, from `settings.json`. An advisory hook's stanza is copied from its header's `Register:` line into `hooks.PostToolUse`.
- After resolving `settings.json`, diff its hook event keys against the pre-merge copy (`jq -r '.hooks | keys[]'` on both). A registration inside a conflict hunk is lost when the kit's side is taken.
- A `docs/cbk/scaffold.md` committed before this release has no Kit commit row, and it is immutable. Record the release in your copy of § Syncing the kit instead.
- Your own hooks are held to the stdin/exit contract too. `hook-contract-fixture.sh` reads every `.claude/hooks/*.sh`, so a project hook that exits before draining stdin turns the block red: make `input="$(cat)"` its first statement.
- Wire the runner, not an inline copy of the extraction: the task your `check` depends on runs `bash .claude/workflows/tests/run-verification-block.sh`.
- Name every advisory hook you wired in the project sub-block's `ADVISORY_WIRED`.
- A review workflow that already grants `checks: read` (to the job and to the action's token) and already runs `gh pr diff` merges only the degrade clause. Size its N against `--max-turns`.

## [0.4.0] — 2026-09-07 — harvest 3 (PRs #54–#57)

Four PRs: the kit stops being wrong about itself (#54); the review gate is a floor (#55); the producing phases become contract-first (#56); the github-issues axis, the records and the hygiene (#57). Design: `docs/superpowers/specs/2026-09-06-cascade-kit-harvest-3-design.md`.

### What landed

- **The instruction budget.** `cbk-conventions.md`, `orchestration.md` and `pr-review.md` each split into an always-loaded contract and a path-scoped `-reference.md` half, and every moved section keeps a pointer heading. `logging.md` and `testing.md` carry `paths:` globs to stamp. Scaffold's bootstrap checklist gains a rule-file disposition pass.
- **The review floor.** `/simplify` and `pr-review-toolkit:review-pr` must both run, once, as skills, recorded in the PR body's `## Review gate` block. The sweep beside them is bounded and reads its reviewer roster at run time.
- **Reviewer memory does not fork.** A hard-deny hook refuses an agent dispatch from outside the repository root, and a Stop hook blocks the hand-off while a stray memory tree exists. Every hook registration takes the `${CLAUDE_PROJECT_DIR}` form.
- **Contract-first phases.** Framing, rough-in and `/finish` each split into a contract and a procedure. `/finish` gains `finish-procedure.md`, and rough-in bundles the pair. `orchestration.md` states its default tier and effort. `finish-ab` and `agent-cost.py` land with stub tests.
- **The github-issues axis and the records.** The `.github` starter bodies, blueprint's two review-workflow templates, `docs/cbk/ROADMAP.md`, `docs/adr/corrections.md`, the `Extends:` grain, § Multi-surface facts, frozen-corpus ingestion, the issue-less branch, licensing, and `.github/dependabot.yml.example`.

### Sync notes

- The three split rules move sections. Text you filled under a heading that moved goes into the `-reference.md` half, under the same heading; the contract keeps only the pointer.
- Stamp the `paths:` globs in `logging.md` and `testing.md`: a placeholder glob loads nothing. Then run the bootstrap checklist's rule-file disposition pass.
- `/finish` is now a contract and a procedure: install `finish-procedure.md` beside `finish.md`, and rough-in's bundled pair beside them.
- Take the kit's `hooks` block: every command becomes `${CLAUDE_PROJECT_DIR}/.claude/hooks/<name>.sh`, the launch-root guard registers on `PreToolUse`, and the fork detector registers on `Stop`.
- Record the reviewer agent-memory choice, `project` or `local`, in § Surface inventory.
- Do not take the two `_example_PostToolUse_*` keys this release adds to `settings.json`. A hook-shaped top-level key makes Claude Code discard the whole settings file (`.claude/rules/cbk-conventions-reference.md` § Hook authoring), and v0.5.0 removes them.

## [0.3.0] — 2026-08-09 — axis parity (PRs #6, #7)

The kit reconciled with its exercised reality, one configuration at a time. Design: `docs/superpowers/specs/2026-08-09-axis-parity-pass-design.md`.

### What landed

- **An axis-aware `/finish`.** Step 1 reads the planning backend from `docs/cbk/scaffold.md` § Cascade metadata, falling back to `.cascade/backends.toml`, and reads each axis its own way.
- **Two-axis producers.** Scaffold's and blueprint's templates emit `Planning backend` and `Knowledge backend` rows, the axis-conditional rows, and the `.cascade/backends.toml` mirror.
- **One Linear model.** Initiative, then a project shell, then the workstream as a parent issue, then F, then R; the milestones field stays unused.
- **Markdown honesty.** In-repo-markdown planning is design-doc mode, disclosed at scaffold's confirmation gate, with a defined markdown issue record.
- **Wiring and vocabulary.** A `notion` stanza in `.mcp.json.example`. The Projects v2 board contract, marked designed-unexercised. Frame headings of the form `### F<#> — M<#>: <name>`, with F continuing across a workstream's frames.
- The kit repository ignores its own reviewer memory (#6).

### Sync notes

- `/finish` reads the planning backend from `docs/cbk/scaffold.md` § Cascade metadata. A target whose scaffold.md has no `Planning backend` row writes `.cascade/backends.toml` as the mirror it falls back to.
- The Notion server's key in `.mcp.json` must be `notion`: the knowledge-backend ask-gate's matcher names that server's tools.
- Frames already committed are immutable and keep their headings. The `### F<#> — M<#>: <name>` form starts at the next frame, with F continuing the workstream's sequence.
- On Linear, the workstream is a parent issue under the project shell, and the milestones field is not used.

## [0.2.0] — 2026-08-09 — harvest 2 (PR #5)

A second harvest of real-run learnings. Design: `docs/superpowers/specs/2026-08-09-cascade-kit-harvest-2-design.md`.

### What landed

- **`/finish` Step 5 split.** Research runs executably before plan mode, which then gates the plan.
- **Research grounding.** Existence and absence claims are verified repo-wide.
- **The review sweep**, `.claude/workflows/review-sweep.js`: find, then verify adversarially.
- **Three hooks.** `protect-main-branch.sh` hard-denies a commit on `main`; `guard-pr-state.sh` and `require-knowledge-backend-ok.sh` are ask-gates.
- **Reviewer memory.** `memory: project` on the three shipped reviewers.
- **Invocation posture.** `scaffold`, `blueprint`, `framing` and `rough-in` carry `disable-model-invocation: true`; `consultation` stays model-invocable.
- **Rule templates** `workflows.md`, `tooling.md` and `orchestration.md`, and the `Explore` exemplar.
- Frame lifecycle, decision governance, testing cadence and CI supply-chain discipline.

### Sync notes

- Register the three new hooks: take the kit's entries in `settings.json`'s `hooks`.
- `tooling.md` and `orchestration.md` are templates: fill them or delete them. `workflows.md` is kept as shipped.
- `scaffold`, `blueprint`, `framing` and `rough-in` no longer start from a description: type `/scaffold`, `/blueprint`, `/framing` or `/rough-in`.
- The reviewers write precedent memory under `.claude/agent-memory/<name>/`. Decide whether your repository commits it.
- `.claude/agents/Explore.md` overrides the built-in Explore agent. Delete it to keep the built-in.

## [0.1.0] — 2026-08-09 — harvest 1 (PR #4) and everything before it

The kit as first exported (#1–#3) and its first harvest of real-run learnings (#4). Design: `docs/superpowers/specs/2026-07-04-cascade-kit-harvest-design.md`.

### What landed

- **The first export.** The cascade skills, `/finish`, the rules and the ADR scaffolding, with the README (#1).
- **Calibration** (#2). `## Assumptions` becomes the eighth issue section, and the Apply class takes small, low-risk changes.
- **The constant plus two independent axes** (#3). A planning backend and a knowledge backend replace the bundled profiles; `knowledge-backend.md` is new.
- **Harvest 1** (#4). `/finish` in eleven gated steps, reading its break-glass marker from the issue body. The bottom-up lane: `/intake`, `/enrich`, `/pr-respond` and § Contribution intake. The `cascade-rule-reviewer`. The lock-file guard. The `format-on-edit.sh` exemplar. ADR `Refines:`. Additive-increment frames. The dependency settle-window.

### Sync notes

- This is the earliest release with a tag, set on its merge commit after the fact with the four after it (v1.0.0 is the first tagged when it shipped). A copy of the kit taken before any tag records the commit it copied, as § Syncing the kit says, and reads the Sync notes from this release on.
- The bundled profiles are gone. `profile_selection.md` and `opinionated_profile.md` are removed from scaffold, and each skill's `github-only-vs-opinionated.md` is replaced by `planning-backend-matrix.md`. Record the planning and knowledge axes instead.
- The break-glass marker `<!-- skip-review-toolkit -->` goes in the issue body or in the operator's instructions to `/finish`, never in the PR body.
- `format-on-edit.sh` ships unregistered. Wire it only after its case arms are filled.
