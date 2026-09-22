# Harvest 4 design — the kit as applied: what syncing `e92e9c4` into real projects found

**Date:** 2026-09-21
**Status:** Approved for execution (operator, 2026-09-21)
**Type:** Design spec for evolving `context-builder-kit` itself
**Prior:** harvest 1 (`2026-07-04-…`, PR #4) · harvest 2 (`2026-08-09-cascade-kit-harvest-2-design.md`, PR #5) · axis parity (`2026-08-09-axis-parity-pass-design.md`, PR #7) · harvest 3 (`2026-09-06-cascade-kit-harvest-3-design.md`, PRs #54–#57)

## What this is

Harvest 3 landed on 2026-09-06 as `e92e9c4`. Within a week two projects applied that exact
commit to already-customized `.claude/` trees — `j4th/you-are-hear` (#42 → PR #43, github-issues
axis, 2026-09-07) and `j4th/echosphere` (ECH-40 → PR #37, Linear axis, 2026-09-13) — and a third,
private target wrote its own sync spec against the same sha. The syncs themselves were mechanical
where the kit intended them to be: byte-identical copies, the executor pair re-spliced, the
verification block adopted wholesale. What they found is recorded on issue #58 (the body plus five
dated comments) and in the post-merge fixes each project shipped on its own tree. None of it has
reached the kit: `main` is still `e92e9c4`, and #58 is open.

Three of those findings are not lint. A hook-shaped object at the top level of `settings.json` —
the shape the kit's two `_example_PostToolUse_*` stanzas ship in — makes Claude Code discard the
file's hook configuration; read against the installed 2.1.278 bundle, the parser marks the
diagnostic fatal and returns no settings at all, so `enabledMcpjsonServers` and `enabledPlugins` go
inert beside every guard, silently, with the verification block green (echosphere PR #38, #58's
2026-09-13 comment). Eight of the nine kit hooks check a dependency before draining stdin (the
knowledge-backend gate drains first and has none), and three sites decide with
`printf … | grep -q`, so a body past the pipe buffer turns a real match into a silent bypass of a
HARD-DENY guard (you-are-hear #81 → PR #82, measured 2026-09-18). And the Stop-tier
fork detector reads `claude-code-action`'s staging copy of a committed memory tree as a fork and
tells the reviewer to delete it (you-are-hear `39ed311`, #58's 2026-09-07 comment).

This pass lands, in the kit, every #58 finding that carries a proven fix — a patch already merged
on a public target, or a reproduction whose repair is one line — so the next sync of any target is
a merge against a kit that has already absorbed what applying it taught. It was preceded by a
64-agent read of the sources (seven sonnet readers over #58, #33, the two public syncs and their
follow-up PRs, the Claude Code changelog 2.1.215→2.1.278, and one target's tree; two opus verifiers
per plan-changing fact, refute-by-default; one opus completeness critic): 28 facts verified,
21 confirmed, 3 refuted, 4 contested and adjudicated by direct reads. The refutations matter as
much as the confirmations and are recorded in § Decisions where they changed the design.

## Governing constraints — all five carry

1. **Portability invariant.** No project-specific identifier in kit content; the two public runs
   are named only where #58 already names them; the private target is never named.
2. **Framework-not-tooling, per file on merits.** A fixture that makes a policy the kit already
   mandates runnable ships beside the existing ones.
3. **Sanitized only.** Every ported hunk is re-authored generic; project stack names (a Dart
   cache, a Rust workspace) survive only as the illustration the source comment carries.
4. **One-way.** The kit changes; no instance is modified by this pass.
5. **Defer-to-exercised.** Where two exercised forms differ, the later wins unless the earlier
   states why it must not generalize. One application here: echosphere's fork detector (kit base
   plus you-are-hear's hunks, no shared helper library) is the later form and is the one ported.

## Decisions (settled with the operator, 2026-09-21)

Numbering continues from harvest 3 (D17–D29).

| # | Decision | Outcome |
|---|---|---|
| D30 | Exemplar stanzas in `settings.json` | **Omit them; never a string.** #58's cheapest fix (stringify) is refuted for targets: a string still carries `hooks/<name>.sh`, which a target's raw-text registration count reads as a registration, and the loader's fatal diagnostic (2.1.278, read from the bundle) covers `matcher` *or* a non-empty `hooks` at depth ≤ 3 under any top-level key outside a nine-key allowlist. The stanza text lives in each hook's header. The block asserts no top-level key besides `hooks` holds such an object. |
| D31 | Verification block shape | **Fail-fast stays.** #58's shape 3 (collect, then exit non-zero) is not adopted; the two checks that were wrong on every real target are fixed in place — the advisory-exemplar arm becomes project-conditional, the `.mcp.json.example` operand is guarded — and the extraction gains two fail-loud rails (an empty extraction is red; exit 0 without the done sentinel is red). The conventions state that a target wires the block into its check task; the kit's own CI runs it. |
| D32 | Fork detector body | **echosphere's merged body**: ignore-driven prune from `git ls-files --others --ignored --exclude-standard --directory \| git check-ignore --stdin` with the three safety rules, the stderr writability probe, `# Depends:` in the header, `.claude-pr` pruned root-anchored, the "a tooling path is not a fork" remediation paragraph, and the residual (a tree under an ignored directory exits 0) named in the header, not only in a scenario table. |
| D33 | Hook stdin/exit contract | **Drain first and never decide on a pipe whose reader can exit first**, in every kit hook, stated once in § Hook authoring with you-are-hear's measured evidence, and enforced by a kit fixture carrying the two portable structural checks plus one over-buffer probe per decision site. The masking half needs a piping caller under `pipefail` (the block's dry-runs, the fixture) — the harness's registered call is not one — and the contract text says so rather than overclaiming. |
| D34 | Sequencing | **One PR**, atomic commits per item. These are defects in one commit's application, not new capability; four passes would be ceremony. |
| D35 | Meta-issue titles at the executor | `/finish` Step 1 admits `[<slug>:meta] …` beside the three existing forms. A meta reaches the executor either framed then roughed-in (`cascade-depth:roughed-in`, the § Contribution intake route) or as `[<slug>:<meta-tag>:R<#>]` children; the label the meta *template* applies at framing (`cascade-depth:framed`) is the pre-rough-in state and is not what the executor checks. |
| D36 | Cost reader pricing | Cache reads priced **per tier**: 0.025× for the top tier (Fable 5.1 / Mythos 5.1 — `platform.claude.com/docs/en/build-with-claude/prompt-caching` § Pricing, read 2026-09-07), 0.1× otherwise; the fixture gains a top-tier row. The reference half's quoted list-price row is unchanged (it carries input/output only), so the block's price diff is untouched. |
| D37 | Review-workflow templates | `checks: read` named twice (job `permissions:` and the action's `additional_permissions`, echosphere `93c450a`); the base branch fetched in the checkout step so `origin/main` exists (#58 addendum item 12); a degrade-explicitly clause in the prompt for a diff the turn cap cannot walk (item 11). A file-count-scaled `--max-turns` is **not** adopted — the label path stays the operator's. |
| D38 | Knowledge-backend matcher | Widened to the live Notion tool set: `create\|update\|move\|duplicate\|convert\|delete\|upload\|spawn\|send\|stop` (`upload-skill` replaces a page's body; `spawn-session` / `send-message-to-session` drive an agent that writes; `stop-session` is run-state), dated. A matcher is a dated observation of a vendor's tool names; the comment says so. |
| D39 | ADR index relation form | `adr-new` **reads the index's existing rows and matches their form** before writing one; the kit's own starter keeps the `·` separator as *its* convention with one sentence saying a target's index sets its own. Two targets already contradicted the pinned form in two different ways (#58, 2026-09-07 comment; 2026-09-13 comment item 1). |
| D40 | Record the sha, sync by merge | Scaffold's Cascade metadata table gains a **Kit commit** row; the conventions gain a short § Syncing the kit: three-way `git merge-file` against the recorded install sha (echosphere's method — 47 of 48 `copy` rows auto-resolved), the file-by-file table as the reusable artifact, and the note that a re-homed project sub-block must split its own literals. |

## What lands — cluster summary

Clusters are in the order the commits land; each edits surfaces the next assumes, and the block
must be green after every commit.

### H1 · Settings liveness — closes #58's 2026-09-13 comment (D30)

- `settings.json`: both `_example_PostToolUse_*` keys deleted; `_comment_hooks` rewritten so the
  ADVISORY tier points at the hook headers for the stanza and says why no exemplar object may
  sit in this file (mechanism, version, date); the STOP tier names both memory scopes
  (`agent-memory`, `agent-memory-local` — 2026-09-13 comment item 5).
- `analyze-on-edit.sh` and `format-on-edit.sh` headers carry the registration stanza verbatim
  as the one home ("copy this object into `hooks.PostToolUse` …").
- `cbk-conventions-reference.md § Hook authoring`: the "exemplar stanzas ship commented out"
  bullet replaced by the invariant — no top-level key in `settings.json` may hold an object
  carrying `matcher` or a non-empty `hooks`; JSON has no comments, so an exemplar lives in the
  hook's header. The evidence paragraph names the fatal diagnostic and the whole-file discard.
- Block: one `jq` line asserting the invariant with a vacuous-read rail; the registry loop's
  `..\|objects\|select(has("command"))` walk keeps working (fewer commands to check).

### H2 · The hook stdin/exit contract — closes #58 item 4 and the you-are-hear #81 class (D33)

- All nine hooks: `input="$(cat)"` is the first statement after `set -uo pipefail`, above the
  dependency check and every early exit; every `printf '%s' "$x" \| grep -Eq …` decision becomes
  `grep -Eq … <<<"$x"` with a one-line comment naming the reason; any report capped with
  `\| head -N` moves the cap into its producer. Patterns stay byte-identical.
- § Hook authoring gains **the stdin / exit contract** bullet (you-are-hear's text, generalized:
  who pays for the masking, why draining is the contract regardless, the here-string rule, the
  measured bypasses) and the header shape gains a `Depends:` line naming each dependency and
  what its absence costs (fail open, degrade unpruned, degrade unmonitored).
- `.claude/workflows/tests/hook-contract-fixture.sh`: the two structural checks (drain-first
  signature; no pipeline into an early-exiting reader, continuations joined, full-line comments
  dropped, stated as a tripwire over known spellings) over `.claude/hooks/*.sh`, plus one
  over-buffer multi-line payload per decision site against a throwaway `git init` tree on
  `main` — the deny must fire, the ask-gate must emit. Run from the block's kit sub-block; never
  dependent on the launch directory (#58 item 4's own caution).
- § Verify by payload: the fixture is the durable home; the PR-body table is for branches the
  fixture cannot reach (the mutation-only ones, named).

### H3 · The fork detector — closes #58 items 1, 2 and the 2026-09-07 comment's new defect (D32)

- `detect-forked-agent-memory.sh` replaced by the exercised body: the ignore-driven prune list
  with glob metacharacters escaped before splicing into `-path`, the three protected basenames
  never pruned, `git check-ignore` keeping a collapsed ancestor walkable; `find`'s stderr
  captured behind a writability probe, degrading to an unmonitored walk that says so; `.git`,
  the worktrees directory and `./.claude-pr` pruned unconditionally; the BLOCKED remediation
  saying that a harness staging copy, a container workspace or a vendored checkout is not a
  fork and nothing is moved or deleted; the header's `Depends:` line and the residual sentence.
- `github-starter-templates.md`: the `.gitignore` starter gains anchored `/.claude-pr/` beside
  the other harness transients; `cbk-conventions-reference.md § .gitignore anchoring` names it.
- Block: the Stop-hook live check keeps its stderr; the launch-root dry-runs stop discarding the
  hook's own diagnostic (#58 item 11) — stderr captured and printed on failure.

### H4 · The verification block as a target runs it — closes #58 item 5, the 2026-09-13 comment items 1 and 6 (D31)

- The advisory-exemplar arm moves to the **project** sub-block behind the target's stated
  disposition: the kit tree asserts the two exemplars unregistered; a target that wired one
  records `ADVISORY_WIRED="format-on-edit.sh"` (or both) at the top of its sub-block and the
  arm asserts exactly that set is registered, once each. A project that follows § Hook
  authoring no longer loses the back half of the suite.
- `absent grep … .mcp.json.example` guarded: the operand is included only when the file exists;
  a target that commits `.mcp.json` names that instead, and the re-homing note beside the
  check says a pre-split project sub-block's unsplit literal trips this very line.
- Two fail-loud rails documented in the block's preamble and shipped as the canonical
  extraction: an empty extraction is red; an exit 0 that never printed `verification: done` is
  red. The kit's own CI (`.github/workflows/verify.yml`, pinned action SHA, no path filter)
  runs the extraction on every PR to `main`; the conventions tell a target to wire the same
  extraction as a task its check command calls (echosphere's `cbk-verify` leg is the exemplar).
- Always-loaded budget: the printed total is unchanged in meaning; the README's customization
  list states the kit's own figure at this sha as the number a fresh target starts from.

### H5 · Harness and workflow defects — closes #58 items 6, 7, 8, 9, 10 and the 2026-09-13 comment items 3, 4 (D36)

- `agent-cost.py`: cache reads priced per tier (`CACHE_READ = {'fable': 0.025}` default 0.10),
  docstring corrected; the fixture gains a top-tier transcript row and keeps the opus row at
  `$14.25`; the `minutes=None` path, the empty-events transcript and the `--json`
  missing-argument exit gain assertions (the smaller-items test gaps).
- `review-sweep.js`: hint match is `f === h \|\| f.startsWith(h + "/")`; the roster prompt keeps
  asking for trailing-slash prefixes and the code stops stripping the boundary it needs; the
  roster `agent()` call takes `.catch(() => null)` so a throw degrades into the existing
  "roster read failed" branch rather than ending the run with no gate line. The design note
  records that a segment anchor cannot be expressed as a prefix — enumerate directories.
- `finish-ab.js`: `arm` labels checked distinct beside `anon`; `hallucinations ?? []` at both
  dereference sites; `j.effort ?? "high"` evaluated once; the reindex idiom converged with
  `review-sweep.js`'s and named once.
- The two stub harnesses stop swallowing exceptions from their own mocks: a thrown mock is a
  test failure, and only a *returned* `null` models the runtime's failed-agent path.
- `.claude/workflows/tests/*`: a scenario for `unattributedFlags`; the least-loaded-owner bound
  exercised with three reporters.

### H6 · Records, the executor, the small rot — closes #58's smaller items 1–4, 6, the 2026-09-07 comment's separator item, the 2026-09-13 comment items 1–5 (D35, D39)

- `commands/finish.md` Step 1 and the bundled `finish-command.md` (re-spliced byte-parallel):
  the title precondition admits `[<slug>:meta] …`, with the two routes a meta takes to the
  executor stated in one sentence; the procedure half unchanged.
- `adr-new/SKILL.md`: the row-writing step reads the index's existing rows and matches their
  relation form; the count in "one of two relationships" replaced by the list; `Promotes:`
  defined in the § it is filled from. `adr-starters/README.md` keeps its separator and says a
  target's index sets its own; `adr-conformance-reviewer.md` cites a correction "by the
  register's own id form".
- `framing/references/procedure.md`: "See rough-in's the rough-in skill's" → "See the rough-in
  skill's". `rough-in-spec-template.md`: one spelling of the measurement variant marker.
- `cbk-conventions.md`: the Quick-reference row that names a frame's `## Pre-flight checks`
  table as append-only is retired (the mutation row names `## Rough-in events` only; no skill
  appends to pre-flight). `logging.md` / `testing.md`: the path-scoping callout is written for
  the *stamped* state ("this rule loads on the globs above; a stack with inline unit tests
  stamps the test directories alone") and the bootstrap row says to rewrite it.
- `require-repo-root-for-agents.sh` header: the Timing paragraph carries both readings of the
  payload `cwd` (the header's dated observation; the hooks page's "cwd follows Claude") and
  names the disagreement as the re-verify trigger; the guard judges the `cwd` the payload
  carries under either.
- `protect-lock-files.sh`: `pubspec.lock` arm, and a `*.lock` fallback arm with a generic
  remediation so the next ecosystem is covered by construction.
- Scaffold's Cascade metadata table: a **Kit commit** row; `cbk-conventions-reference.md` gains
  § Syncing the kit (D40).

### H7 · The review-workflow templates and the matcher — closes #58 addendum items 11, 12; (D37, D38)

- `blueprint/references/templates/claude-review.yml` and `claude.yml`: `checks: read` in the job
  `permissions:` block and in `additional_permissions`, with the measured note that
  `statuses: read` is needed only when the rollup carries commit statuses; the checkout step
  fetches the base ref so `origin/<base>` resolves (or the prompt states that `gh pr diff` is
  the only diff source); the prompt's every-file contract gains a degrade clause: past N changed
  files, review the authored set the PR body names, post what was read, and say what was not.
- `settings.json` Notion matcher widened per D38, the comment dated; `knowledge-backend.md`'s
  hook-enforcement paragraph names the verb set once.

## Sequencing — one PR (D34)

Branch `feat/harvest-4-applied-defects`. Commit order: H4's extraction rails and the two check
repairs first (every later commit is verified by the block); H1; H2 (contract text, then hooks,
then the fixture, then the block invocation); H3; H5; H6; H7. Each commit: Conventional Commits
naming the #58 item; the block, the four stub fixtures and the new hook fixture green; `bash -n`
on every hook. One dogfooded review sweep before the draft, its triage in the PR body; the body
carries `Closes #58` and `Closes #33` (its remaining open items are #58's), and the PR-body
`## Verification` list records the before/after always-loaded total.

## Non-goals — explicitly NOT harvested

- The collect-then-exit block (shape 3) — fail-fast with repaired checks, per D31.
- A shared hook helper library (`lib/repo-root.sh`) — one target's refactor over three call
  sites the kit does not have; the kit's two root-resolving hooks inline it.
- Spellchecker configuration for the bracket-splitting idiom (`typos` and its `[type.*]` table)
  — a one-line note in § Verification's preamble names the idiom's cost; no config ships.
- A file-count-scaled `--max-turns` or auto-selected deep-review path in the review template.
- Any target's own fills (globs, roster prefixes, plugin lists, reviewer bodies).
- Any reference to the private target, anywhere in kit content.

## Verification — definition of done

1. The block is **green on the kit tree** under literal `bash -e` after every commit, both
   sentinels printed, and the CI workflow that runs it is green on the PR.
2. `settings.json` parses; `jq` finds no top-level hook-shaped object; every registered command
   is in placeholder form, exists and is executable; the registry comment names every hook
   under its tier and both memory scopes.
3. `hook-contract-fixture.sh` green: every hook drains first, no hook pipes into an
   early-exiting reader, the two over-buffer probes deny and ask respectively.
4. The four stub fixtures green; `agent-cost-fixture.sh` asserts the opus row at `$14.25` and
   the new top-tier row at its per-tier figure.
5. The executor pair byte-parallel with both bundled templates; `/finish` Step 1 names four title
   forms.
6. Every hunk ported from a public target is re-authored generic (no crate, package or path
   name survives except inside a quoted illustration), and the private-instance denylist grep
   is clean.
7. #58 and #33 closed by marker; every #58 item is either landed (named in the PR body by
   cluster) or explicitly repositioned as a non-goal above.
