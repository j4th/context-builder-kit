# context-builder-kit

> Take an idea from *"I want to make X"* to a merged PR. Claude Code skills for each phase, slash commands that execute and feed them, reviewer agents, guard hooks and a small set of rules — install them into any repo and pick the entry point that fits your moment.

The kit is the operational surface of an AI-assisted development cascade: a sequenced funnel from a vague problem statement, through architectural decisions, into milestone planning, all the way to Claude Code opening a draft PR for a single sub-sub-issue. Each phase produces a small, durable markdown artifact the next phase reads. No frameworks, no runtimes — just markdown, slash commands, hooks, and the discipline that holds them together.

```
   raw idea
       ↓
   consultation   →   docs/cbk/problem_brief.md          (chat-only, no repo yet)
       ↓
   scaffold       →   repo + docs/cbk/scaffold.md         (planning surface, conventions, the events index, the .github starters)
       ↓
   blueprint      →   docs/cbk/blueprint.md + foundation docs (stack, ADRs, workstreams, the roadmap, the review workflows)
       ↓
   framing        →   docs/cbk/frame-NN.md                (one workstream, sequenced milestones)
       ↓
   rough-in       →   ready-to-implement sub-sub-issues   (each with plan-mode prompt)
       ↓
   /finish <N>    →   draft PR                            (code, tests, the review floor + bounded sweep, triage)
```

The cascade is **a funnel, not a waterfall**: framing and rough-in run **one workstream / one milestone at a time, just-in-time**. Frame the next thing, build it, then frame the thing after — that's how each phase gets to learn from the previous.

> **Planning-axis note**: `/finish` (and the `/intake` → `/enrich` hand-offs into it) run on the backend planning axes (`github-issues` / `linear`). `in-repo-markdown` planning is **design-doc mode** — no executor; rough-in specs are executed by running Claude Code against the markdown directly (scaffold's confirmation gate discloses this before the choice is made).

## Quick start

### Prerequisites

| Tool | Used by | Without it |
|---|---|---|
| [Claude Code](https://claude.com/claude-code) 2.1.284 or later | Everything. The kit's model defaults name Opus 5.5 and Sonnet 5.5, and "Sonnet 5.5 requires Claude Code v2.1.284 or later, and Opus 5.5 requires v2.1.280 or later" (`https://code.claude.com/docs/en/model-config`, read 2026-09-30) | A request for either model fails |
| `git` | Every phase, every hook, the install and the sync | Nothing runs |
| `bash` 3.2 or later | The hooks, the fixtures and the verification block; the hooks use no bash-4 builtins, so a stock macOS bash runs them | The hooks cannot run |
| `jq` | Every hook whose header's `Depends:` line names it, and the verification block | Each of those guards fails open, allowing the action with a warning that names its backstop, and the block exits non-zero |
| `gh`, authenticated | `/finish`, `/intake`, `/enrich`, `/pr-respond` and the phases' issue writes on the `github-issues` axis; `gh` is the kit's GitHub interface | The `github-issues` axis cannot write issues or pull requests |
| `node` | The verification block's `.mjs` fixtures, the workflow scripts, and any `npx`-launched server in `.mcp.json` | The block exits non-zero |
| `python3` | `agent-cost.py`, `run-arms-headless.py`, and the fixtures the block runs for them | The block exits non-zero |
| `uv` | The `time` MCP server, which `.mcp.json.example` launches through `uvx` | The optional `time` server does not start |
| [`mise`](https://mise.jdx.dev/), optional | The task runner blueprint's tooling template defaults to | Nothing: any runner that defines a `check` task works |
| A `CLAUDE_CODE_OAUTH_TOKEN` Actions secret | The review workflows blueprint emits when scaffold's PR question chose automated review | Those workflows fail at their action step |

v1.0.0 was checked on Claude Code 2.1.286. To list what is missing on a machine: `for t in git jq gh node python3 uv; do command -v "$t" >/dev/null || echo "missing: $t"; done`.

### 1. Install the drop-in set from a tagged release

Run this at your repository's root. It copies only the drop-in set — `.claude/`, `.mcp.json.example`, `.github/dependabot.yml.example` and `.github/workflows/adr-immutability-check.yml` — and never touches your `README.md`, `LICENSE`, `CLAUDE.md`, `.gitignore` or `docs/`. A `.claude/` you already have (settings Claude Code wrote, your own agents) is kept: no file is overwritten, and each file the kit also ships is listed for you to merge by hand. A repository that already carries the kit is refused and sent to Upgrading. It prints the release to record. To install from a fork, change the owner in the URL.

```bash
KIT_VERSION=v1.0.0
kit_tmp=$(mktemp -d)
curl -fsSL -o "$kit_tmp/kit.tar.gz" "https://github.com/j4th/context-builder-kit/archive/refs/tags/$KIT_VERSION.tar.gz"
tar -xzf "$kit_tmp/kit.tar.gz" -C "$kit_tmp" --strip-components=1
if [ -e .claude/rules/cbk-conventions.md ]; then
  echo "The kit is already installed here, so nothing was copied: upgrade it instead (see Upgrading)."
else
  while IFS= read -r f; do
    if [ -e "$f" ]; then echo "exists, not copied (merge by hand): $f"
    else mkdir -p "$(dirname "$f")" && cp "$kit_tmp/$f" "$f"; fi
  done < <(cd "$kit_tmp" && find .claude .mcp.json.example .github/dependabot.yml.example .github/workflows/adr-immutability-check.yml -type f)
  echo "Kit commit: $KIT_VERSION ($(gunzip -c "$kit_tmp/kit.tar.gz" | git get-tar-commit-id | cut -c1-7))"
fi
rm -rf "$kit_tmp"
```

The printed `Kit commit:` line is the release you installed, and the base of every later sync. Scaffold records it as the **Kit commit** row of `docs/cbk/scaffold.md`. If you start at blueprint or later, record it yourself in `.claude/rules/cbk-conventions-reference.md` § Syncing the kit, and create `docs/adr/` from the starters that scaffold would have copied: `mkdir -p docs/adr && cp .claude/skills/scaffold/references/adr-starters/*.md docs/adr/`. Then fill ADR-0000's `Date:` and `Deciders:` by hand, because the ADR guard denies the agent's edits to an existing ADR.

The install leaves your `.gitignore` alone: add the harness block from `.claude/skills/scaffold/references/github-starter-templates.md` § `.gitignore` to it yourself.

### 2. Fill the conventions

```bash
$EDITOR .claude/rules/cbk-conventions.md
```

Fill in the `<TEAM>` and `<workstream-slug>` placeholders, stamp the `paths:` globs in `logging.md` and `testing.md` and the bracketed manifest-and-lockfile entry in `cbk-conventions-reference.md`'s `paths:`, and delete the template callouts once you're done. Scaffold's bootstrap checklist walks the rest of the rule files; in a filled target, an unstamped glob turns the verification block red.

### 3. Configure the MCP servers

```bash
cp .mcp.json.example .mcp.json
$EDITOR .mcp.json   # delete the servers your axes do not use
git add .mcp.json
```

`.mcp.json` is committed, because it holds `${VAR}` references and never a secret. The mcp page says "`${VAR}`: expands to the value of environment variable `VAR`", and "Check `.mcp.json` into version control so everyone on your team gets the same MCP tools and services" (`https://code.claude.com/docs/en/mcp`, read 2026-09-30). Export each variable the file references before launching `claude`, and name them in a committed `.env.example`. A hosted server that requires OAuth signs in through `/mcp`.

### 4. Install the plugins

In a Claude Code session:

```
/plugin install pr-review-toolkit@claude-plugins-official
/plugin install commit-commands@claude-plugins-official
```

These are the two `enabledPlugins` keys in `.claude/settings.json` (`https://code.claude.com/docs/en/discover-plugins`, read 2026-09-30). `/simplify` ships with Claude Code and needs no install.

### 5. Open Claude Code and start a phase

```bash
claude
```

On the first launch, accept the workspace trust dialog. "A cloned repository can't approve its own servers": until the workspace is trusted, the `enabledMcpjsonServers` list committed in `.claude/settings.json` is ignored and each server waits at `⏸ Pending approval` (`https://code.claude.com/docs/en/mcp`, read 2026-09-30). Once it is trusted, the servers that list names are approved; approve any other server in `.mcp.json` when Claude Code asks. Then start from where you are (next section).

That's it. The kit is in place; what you do next depends on where you are in the project.

## Upgrading

A repository that carries the kit upgrades by release, never by re-extracting over its filled files. Read the `CHANGELOG.md` entry of every release after the one your **Kit commit** row names, up to and including the one you are moving to: each release's **Sync notes** say what to do by hand. Then follow `.claude/rules/cbk-conventions-reference.md` § Syncing the kit — a file-by-file table first, then a three-way `git merge-file` per file, with the kit at your recorded release as the base. Record the new release when the sync merges.

## Pick your entry point

The full cascade is the rigorous path. Most adopters skip in. Match your situation:

| Where you are | Start at | Run | Skip the cascade above? |
|---|---|---|---|
| **Vague idea, no repo** ("I want to build something that does X") | `consultation` | Describe the idea in chat | No — full cascade |
| **Clear-ish idea, no repo** (problem is shaped, you can describe it in a paragraph) | `scaffold` | `/scaffold` | Skip consultation; provide a verbal brief or paste one |
| **Existing repo, ready to set up workspace + architecture** | `blueprint` | `/blueprint` | Skip consultation + scaffold; commit a brief manually if you don't have one |
| **Architecture decided, ready to plan a specific workstream** | `framing` | `/framing` | Skip everything above; **needs `blueprint.md` § Workstreams** |
| **Small project — milestones obvious, just want issues** | `rough-in` ⚠️ *experimental* | `/rough-in` | Skip framing too; **brittle without a `frame-NN.md`** |
| **One concrete issue ready to implement** | `/finish <N>` | `/finish <N>` | Issue must already have rough-in's eight-section body shape; backend planning axes only |

**How a phase starts.** `consultation` is the one skill Claude invokes on its own: describing an idea is enough. `scaffold`, `blueprint`, `framing`, `rough-in` and `adr-new`, and the commands `/finish`, `/intake`, `/enrich` and `/pr-respond`, carry `disable-model-invocation: true`. The skills page describes that setting as "Use for workflows you want to trigger manually with `/name`" (`https://code.claude.com/docs/en/skills`, read 2026-09-30): describing the intent does not start them, so type the command.

**Most users start at `blueprint`.** Consultation is HITL-heavy and works fine in plain Claude.ai chat; scaffold is mostly provisioning that's faster to do in a browser tab. The cascade's value compounds from `blueprint` forward, where the artifacts start versioning into your repo and the next phase actually inherits from disk.

⚠️ **Skipping into framing or rough-in is experimental.** The skills are designed assuming the prior-phase artifact exists on disk; they'll work without it but you'll lose the "Builds on" inheritance and some of the gates (workstream slug confirmation, milestone re-framing detection, etc.) become hand-waved. Fine for small one-off projects; not recommended for anything you'll iterate on for months.

## The six phases — what each does

Every phase has the same shape: read prior-phase artifacts, run a HITL-gated interview / decision pass, commit a single markdown artifact (and optionally a planning-backend object), hand off to the next.

### 1. `consultation` — turn an idea into a bounded problem brief

**Phase 1 of the cascade.** Conversational and HITL-heavy. Produces exactly one artifact: a markdown problem brief. No code, no repo, no tickets — those come later.

The skill runs a four-step interview: problem discovery → appetite → solution sketching → risks/rabbit-holes. Two dials let you tune the rigor (`light` / `standard` / `full`) and prior context (`greenfield` / `partial` / `brownfield`).

**Abbreviated example** of what comes out (one section of the brief):

```markdown
## No-gos
- **No SQL pack.** Different pedagogy (results-oriented). Deserves its own tool.
- **No web UI, no SaaS, no paywall.** Terminal-native by definition.
- **No git lessons in v1.** Lessons are hard and the engine must mature first.

## Appetite
Medium — 3 weeks, solo developer.

## Success criteria
1. A learner can complete a regex lesson and have spaced-repetition track it
2. New packs can be added without changing the engine
3. Total install footprint is one binary + zero system deps
```

**Skip when:** you can already describe the problem, target users, appetite, no-gos, and success criteria in a paragraph. Just write the brief by hand and start at scaffold.

### 2. `scaffold` — provision the workspace where work will live

**Phase 2.** Sets up the infrastructure later phases will use: a code repo, a planning surface (GitHub Issues, Linear, or in-repo markdown), an optional knowledge-base surface (Notion or none), conventions for branches/commits/labels. Captures team shape and working preferences.

The kit composes three independent surfaces — one constant, two axes the operator picks:

- **Constant: a GitHub repo (or other git host)** containing the core markdown docs (`CLAUDE.md`, `ARCHITECTURE.md`, `STANDARDS.md`, `CONTRIBUTING.md`, `docs/adr/*`, `docs/cbk/*`). Always present, always immediate AI/dev context.
- **Axis 1 — Planning backend** (where live work-tracking happens): `GitHub Issues` (sub-issues + Projects v2 board) / `Linear` (initiatives + projects + milestones + issues) / `in-repo markdown` (status tracked in `docs/cbk/README.md`; no external board).
- **Axis 2 — Knowledge backend** (durable longer-lived reference library): `Notion` (with hub-as-DB-row pattern) / `none`.

These compose into 3 × 2 = 6 configurations. See `.claude/rules/knowledge-backend.md` for the knowledge-backend operational contract. Common shapes:

- `GitHub Issues + none` — solo / small team, default starting point
- `GitHub Issues + Notion` — solo / small team with existing Notion reference content
- `Linear + Notion` — larger team with planning-tool standardization and durable knowledge curation
- `In-repo markdown + none` — design-doc mode (no `/finish` executor); audience for the cascade is non-technical, or the project is small enough that markdown alone suffices

**Exercised vs designed** (restamped 2026-09-30 — the honest status per configuration, per the kit's exercised-not-provisional principle): `Linear` planning is exercised end-to-end by more than one real cascade run. `GitHub Issues` planning is exercised by a real run through issues, native sub-issues, labels and the review workflows; that run chose no Projects v2 board, so the board contract stays marked designed-unexercised inline. `In-repo markdown` is design-doc mode by design. On the knowledge axis, `none` is effectively exercised daily; `Notion` is a complete contract, configured in a real run and lightly exercised.

**Abbreviated example** of what scaffold produces (`docs/cbk/scaffold.md`):

```markdown
# Scaffold: Tuitor

## Cascade metadata
**Planning backend**: GitHub Issues (3-level hierarchy)
**Knowledge backend**: none
**Repo**: github.com/you/tuitor
**Project board**: github.com/you/tuitor/projects/4
**Kit commit**: v0.5.0 (74edf84)

## Working conventions
**Team identifier**: TUI
**Branch naming**: `<type>/tui-<N>-<short-slug>`
**Commit format**: Conventional Commits

## Quality bar
Move fast on packs; deliberate on engine. Tests for engine internals; smoke tests for packs.
```

A different shape — `GitHub Issues + Notion`:

```markdown
# Scaffold: ProjectX

## Cascade metadata
**Planning backend**: GitHub Issues (3-level hierarchy)
**Knowledge backend**: Notion
**Notion hub**: notion.so/yourworkspace/projects-db/projectx
**Engineering Wiki** (cross-project, optional): notion.so/yourworkspace/eng-wiki
**Repo**: github.com/you/projectx
```

**Skip when:** the repo already exists with conventions, you've picked your planning backend, and you can write a verbal `scaffold.md` from memory. Most experienced adopters skip — scaffold is heavier in chat than in a browser tab.

### 3. `blueprint` — make the strategic technical decisions

**Phase 3** — most complex of the cascade. Inherits the brief and the scaffold output, then makes the load-bearing calls: stack (language, framework, storage, testing), methodology (Shape Up, Kanban, Scrum), and produces six prose foundation docs — seven on the `github-issues` and `in-repo-markdown` axes, where `docs/cbk/ROADMAP.md` joins them — plus tooling configs. `ROADMAP.md` is the freely mutable status surface that framing, rough-in and `/finish` update.

Foundation doc set (in production order — most-critical first):

1. `CLAUDE.md` (root) — shapes every future Claude Code session
2. `docs/ARCHITECTURE.md` — stack decisions and system structure
3. `docs/STANDARDS.md` — quality bar, testing, CI gates
4. `CONTRIBUTING.md` — branch/commit/PR norms
5. `README.md` (update) — stack info added to existing README
6. `docs/cbk/blueprint.md` — the cascade artifact (initiative + workstreams)

Plus tooling configs: `mise.toml` / `Makefile` / `package.json` scripts, `.github/workflows/`, `.env.example` if applicable.

**Abbreviated example** of one stack decision landing in `ARCHITECTURE.md`:

```markdown
### DECISION-001: Use SQLite via rusqlite with the `bundled` feature

**Status**: Accepted | **Date**: 2026-04-11

**Context**: The brief requires persistent progress across sessions and
prohibits system-level dependencies (the cargo install ergonomics are
a v0.1 ship gate).

**Decision**: rusqlite with the `bundled` feature. Full SQL
queryability without a system libsqlite3 dependency.

**Consequences**:
- Binary size +~1.5MB (acceptable per the brief)
- Cross-compilation requires a C compiler (documented in CLAUDE.md)
```

Three rigor modes (`light` / `standard` / `full`) trade gate count against pace. Standard mode batches HITL gates at meaningful boundaries; full mode reviews each foundation doc individually.

**Skip when:** the foundation docs already exist and you just want to plan the next workstream. Start at framing.

### 4. `framing` — decompose one workstream into milestones

**Phase 4.** Takes one row from `blueprint.md § Workstreams` and produces a refined project specification with sequenced milestones — each one a **demonstrable capability**, not just "we built module X."

The output is a numbered cascade-event file: `docs/cbk/frame-01.md`, `frame-02.md`, etc. The number is the framing's identity in the cascade timeline, not the project's identity. Re-framing produces a new file (`frame-NN.md` with `Supersedes: frame-MM`); the old one stays in history.

**Abbreviated example** (one milestone from a `frame-NN.md`):

```markdown
### M1: Regex pure-function verifier

**Capability**: After this, the system can verify one TOML-defined
regex lesson against the user's input and report pass/fail.

**Acceptance criteria**:
- [F1.AC1] `cargo run -- regex/lesson_01.toml` succeeds with output matching `expected.txt`
- [F1.AC2] `cargo check --workspace` passes
- [F1.AC3] Trait has associated types (Input, Context, Error)

**Rough issues** (intents — rough-in shapes these into review units):
- Define the Verifier trait per IC-1
- Implement the regex verifier (concrete impl)
- Wire the lesson loader for TOML
- Capstone: end-to-end verification on `lesson_01.toml`

**Internal dependencies**: M1 has no internal predecessors. Required for M2.
```

The skill produces an Interface Commitments table — what stable interfaces the framing commits to and by which milestone they're locked. Future framings inherit these as constraints.

**One project at a time, just-in-time, by design** — don't frame v0.4 today; frame v0.1, build it, then frame v0.2.

### 5. `rough-in` — decompose one milestone into ready-to-implement issues

**Phase 5.** Takes one milestone from a `frame-NN.md` and produces a set of **sub-sub-issues** under the framing F-issue. Each issue is sized as a **coherent review unit** — typically 2–6 issues per milestone for Claude-Code-executed work.

Each issue body has eight sections: Context, Assumptions, Implementation, Acceptance criteria, Test plan, Done signal, Dependencies, PR contract. The `## Implementation` section is the load-bearing input to Claude Code's plan mode in the next phase.

**Abbreviated example** of one rough-in issue body:

```markdown
[regex-pack:F1:R1] Define Verifier trait

## Implementation
Define the `Verifier` trait as the load-bearing abstraction every pack
implements. Stack-decision context: see ARCHITECTURE.md DECISION-001
for the trait location. The associated types come from IC-1 in
frame-01.md (verbatim, not negotiable).

## Acceptance criteria
- [F1.AC1] `crates/tuitor-engine/src/verifier.rs` exists and compiles
- [F1.AC2] Trait has associated types Input, Context, Error
- [F1.AC3] `cargo doc --no-deps` renders the trait with rustdoc

## Test plan
- `tuitor_engine::verifier::input_associated_type_compiles`
- `tuitor_engine::verifier::context_associated_type_compiles`
- `tuitor_engine::verifier::error_associated_type_compiles`

## Done signal
`cargo check --workspace && cargo doc --no-deps` both succeed.

## Dependencies
None.

## PR contract
Closes [TUI-42]. Conventional Commits title.
```

**Rough-in's Implementation section is the contract Claude Code plan mode reads.** The skill writes intent and constraints, not implementation sequences — plan mode is a decomposition engine and over-prescribing "how" overrides its priors.

**One milestone at a time, just-in-time** — same discipline as framing.

### 6. `/finish <issue-number>` — execute one sub-sub-issue end-to-end

**Phase 6.** A Claude Code slash command (`.claude/commands/finish.md`), not a chat skill — contract-first: `finish.md` is the contract (what a finished issue is and the tests the result must pass), `finish-procedure.md` beside it is the step-by-step read on demand. Picks up a rough-in sub-sub-issue and runs it through to a draft PR:

1. Read the issue body and its comments (eight sections), the frame, the decision records and the rules that bind
2. Preconditions: state and shape, dependencies closed-completed, idempotency, break-glass
3. Research the `## Implementation` section executably, then gate the plan in **plan mode**
4. Branch first, then execute (red tests → green → refactor → the project's `check` task)
5. **`/simplify`** as a skill (per `.claude/rules/simplification.md`)
6. **`pr-review-toolkit:review-pr`** as a skill, with the bounded review sweep beside it, then four-class triage (per `.claude/rules/pr-review.md`) — the floor, once
7. Open the PR as **draft** carrying the `## Review gate` and `## Triage` blocks

The user then reviews the draft and flips it to ready when satisfied — that triggers any GitHub Action auto-review (e.g., `claude-review.yml`) and the merge is the user's call.

**`/finish` does NOT**: modify the issue body; handle re-rough-in; bypass dependencies; skip either half of the review floor (`/simplify`, `pr-review-toolkit:review-pr` — both as skills, recorded in the `## Review gate` block); mark the PR ready; merge. When the spec is wrong or something is missing, `/finish` surfaces and aborts rather than improvising.

### The bottom-up lane — `/intake`, `/enrich`, `/pr-respond`

The cascade runs top-down; externally sourced work comes in from the side. `/intake <ref>` turns a bug report or feature request into a shaped, `/finish`-able issue: it investigates, reproduces, classifies and shapes, and never lands code. `/enrich <N>` is rough-in for a single small capability, skipping the framing milestone. `/pr-respond <N>` closes the review loop on a PR: it triages every comment, applies what the rubric says to apply, and answers every thread. Which work skips framing and which stays framed is `cbk-conventions.md` § Contribution intake.

## What the kit ships

```
.claude/
├── commands/
│   ├── finish.md                      ← Phase 6 executor slash command (the contract)
│   ├── finish-procedure.md            ← its procedure, read on demand
│   ├── intake.md                      ← bottom-up entry: external report → /finish-able issue
│   ├── enrich.md                      ← rough-in for one small capability
│   └── pr-respond.md                  ← the PR feedback-loop executor
├── skills/
│   ├── consultation/                  ← Phase 1
│   ├── scaffold/                      ← Phase 2 (+ references/adr-starters/, the docs/adr/ starters incl. corrections.md; references/issue-templates/, the .github starter bodies, the cascade-events index template)
│   ├── blueprint/                     ← Phase 3 (+ references/templates/: the foundation docs, roadmap.md, the review workflows claude-review.yml + claude.yml)
│   ├── framing/                       ← Phase 4 (+ references/contract.md, references/procedure.md)
│   ├── rough-in/                      ← Phase 5 (+ references/contract.md, references/procedure.md; references/finish-command.md + finish-procedure.md, the bundled executor pair)
│   └── adr-new/                       ← ADR scaffolder (used by blueprint and onward)
├── agents/
│   ├── adr-conformance-reviewer.md    ← dispatched on every review pass
│   ├── logging-discipline-reviewer.md ← same
│   ├── cascade-rule-reviewer.md       ← same
│   └── Explore.md                     ← a Haiku-pinned override of the built-in Explore, with omitClaudeMd (delete it to keep the built-in)
├── hooks/
│   ├── protect-immutable-adrs.sh      ← hard-deny: edits to existing ADRs, however the path is spelled
│   ├── protect-lock-files.sh          ← hard-deny: hand edits to lock files
│   ├── protect-main-branch.sh         ← hard-deny: git commit on main
│   ├── require-repo-root-for-agents.sh ← hard-deny: Task/Agent/Workflow dispatch outside the repo root
│   ├── guard-pr-state.sh              ← ask-gate: gh pr ready/merge/close/reopen
│   ├── require-knowledge-backend-ok.sh ← ask-gate: knowledge-backend MCP writes
│   ├── detect-forked-agent-memory.sh  ← stop: a reviewer-memory tree outside the root blocks the hand-off
│   ├── format-on-edit.sh              ← advisory exemplar (unregistered; its Register: stanza is in its header)
│   ├── analyze-on-edit.sh             ← advisory exemplar (unregistered; its Register: stanza is in its header)
│   └── lib/
│       └── resolve-path.sh            ← the path resolver the ADR guard sources (sourced, never run)
├── rules/
│   ├── cbk-conventions.md             ← project conventions — contract half (template; you fill this)
│   ├── cbk-conventions-reference.md   ← its path-scoped reference half
│   ├── orchestration.md               ← model × effort tiering — contract half (template)
│   ├── orchestration-reference.md     ← its path-scoped reference half
│   ├── pr-review.md                   ← review floor, roster, rubric — contract half
│   ├── pr-review-reference.md         ← its path-scoped reference half (calibration tables)
│   ├── knowledge-backend.md           ← Notion-axis contract — contract half (delete both halves with its hook when the axis is none)
│   ├── knowledge-backend-reference.md ← its path-scoped reference half
│   ├── testing.md                     ← three-regime testing (path-scoped; stamp the globs)
│   ├── logging.md                     ← structured logging (path-scoped; stamp the glob)
│   ├── simplification.md              ← /simplify contract
│   ├── workflows.md                   ← agent workflow patterns (portable)
│   └── tooling.md                     ← tool-selection skeleton (template)
├── workflows/
│   ├── review-sweep.js                ← find-then-verify review orchestration
│   ├── finish-ab/                     ← A/B harness exemplar: two to four worktree-isolated arms, a balanced blind judge panel, and run-arms-headless.py, which runs each arm as a headless session
│   ├── agent-cost.py                  ← per-agent cost reader for a run's transcripts
│   └── tests/                         ← the verification runner and every fixture the block runs (hooks, CI job bodies, review-bot templates, workflow scripts, run-arms-headless-fixture.sh among them)
└── settings.json                      ← hook registration + plugin/MCP manifest

.github/
├── dependabot.yml.example             ← Dependabot configuration to copy, with the settle-window floor
└── workflows/
    └── adr-immutability-check.yml     ← CI gate enforcing ADR-0000 at raw-git level

.mcp.json.example                      ← MCP server config template
```

That is the drop-in set the Quick start installs; scaffold then writes `docs/adr/` from `references/adr-starters/`. The rest of this repository is the kit's own and is never installed: `README.md`, `CHANGELOG.md`, `CLAUDE.md` (instructions for working on the kit), `LICENSE`, `.gitignore`, `.github/workflows/verify.yml` (the kit's CI) and `docs/` (`docs/adr/`, the ADR starters scaffold copies, byte-identical to its `references/adr-starters/`, and `docs/superpowers/`, each harvest's design, trace and plans).

Each skill follows the same pattern: a `SKILL.md` entrypoint plus a `references/` directory with templates and operational reference docs (failure modes, question banks, axis-specific behavior, inheritance discipline). The three producing phases — framing, rough-in and `/finish` — are contract-first: `references/contract.md` (for the executor, `commands/finish.md` itself) is the drafting read, `references/procedure.md` (`commands/finish-procedure.md`) the step-by-step on demand, and `SKILL.md` routes. Skills load `references/*.md` lazily on demand.

## Required dependencies

The kit assumes a few things about the host project. None are kit-shipped because they're either external plugins, project-specific config, or things `blueprint` produces.

### Claude Code plugins

Listed in `.claude/settings.json` under `enabledPlugins`, keyed `<plugin>@<marketplace>`. Install each in a Claude Code session before running `/finish` (Quick start, step 4):

- **`pr-review-toolkit@claude-plugins-official`** — `/finish`'s review pass invokes `pr-review-toolkit:review-pr`, one half of the review floor
- **`/simplify`** — `/finish`'s simplify pass invokes it before the review pass; it is the other half of the floor. It is a skill bundled with Claude Code, not a plugin, so it is deliberately absent from `enabledPlugins`. Its version history is recorded once, in `.claude/rules/simplification.md` § Plugin
- **`commit-commands@claude-plugins-official`** — convenient wrappers for staging and committing (used by examples in this kit's docs)

The slash commands and skills these provide are referenced by name in `/finish` and the rules files; if your install uses different identifiers, edit the references.

### MCP servers

`.mcp.json.example` lists each server with a comment on what uses it; `enabledMcpjsonServers` in `.claude/settings.json` names the ones approved for the project. Copy the example to `.mcp.json` and commit it (Quick start, step 3):

- **`linear`** (hosted; sign in through `/mcp`, OAuth in the browser) — required only when the planning backend is Linear.
- **`notion`** (Notion's official MCP, `notion.com/help/notion-mcp`) — required only when the knowledge backend is Notion. Used by every phase that reads from or writes to the knowledge backend. Keep the key `notion`: the knowledge-backend ask-gate matches that server's tool names.
- **`context7`** — used by framing and rough-in research phases for library/framework doc lookups. Reduces stale-knowledge errors when the cascade picks dependencies.
- **`time`** (launched through `uvx` at the version `.mcp.json.example` pins; needs `uv`) — optional, used by skills that need ISO-8601 conversions or timezone math.

There is no GitHub server: the kit's GitHub interface is the `gh` CLI (`.claude/rules/tooling.md` § Planning backend). If an expected MCP is missing, the cascade falls back to manual / web-search paths and surfaces the gap.

### Project conventions

The kit's load-bearing assumption is that your project has — or will have, after `blueprint` runs — these surfaces:

- A `check` task in whatever task runner the project uses: `/finish` runs "the project's `check` task", and blueprint's tooling template defaults to `mise` and makes the verification runner a task `check` depends on
- `docs/STANDARDS.md` with a quality bar and CI Pipeline table
- The files under `.claude/rules/`: the contract and reference pairs for conventions, orchestration, review and the knowledge backend; `testing.md` and `logging.md` (path-scoped — stamp their globs); `simplification.md`; `workflows.md` (portable); and `tooling.md` (a template). `/finish` and the reviewer agents reference them by name.
- ADR scaffolding under `docs/adr/` (scaffold writes it from the starters; the `adr-new` skill maintains it)

If your project uses a different layout, record it in `cbk-conventions.md`: `/finish` reads the conventions and needs no edit of its own. See "Customization" below.

## Customization

Four surfaces are settled per project — three edited, and `finish.md` understood and left as shipped — and scaffold's bootstrap checklist walks the decisions:

1. **`.claude/rules/cbk-conventions.md`** — fill in `<TEAM>`, workstream slugs, branch-naming patterns, methodology choices. Delete the "this file is a template" callout at the top once you're done.

2. **`.claude/commands/finish.md`** — needs no edit. It runs the project's `check` task in whatever runner defines it, and reads the foundation docs and the rules that bind the diff. What a project customizes is what those name: the `check` task, the foundation docs blueprint writes, and the `paths:` globs in `testing.md` and `logging.md`. The eight-section spec contract that `/finish` reads from issue bodies is the stable interface. A project that must diverge carries the change as a named exception (`.claude/rules/cbk-conventions-reference.md` § Syncing the kit) and edits the bundled copy, `.claude/skills/rough-in/references/finish-command.md`, in the same commit, because the verification block diffs the pair.

3. **`.claude/settings.json`** — adjust `enabledPlugins` if your installed identifiers differ (keys are `<plugin>@<marketplace>`); adjust `enabledMcpjsonServers` to the servers your `.mcp.json` keeps. Never add a hook-shaped object as a top-level key while doing so — the advisory hooks' registration stanzas live in their headers (see `.claude/rules/cbk-conventions-reference.md` § Hook authoring).

4. **`.claude/rules/logging.md` and `.claude/rules/testing.md`** — stamp the `paths:` globs at the top with your project's real extensions; they ship as placeholders and a placeholder glob loads nothing. The verification block prints the always-loaded rule set and its total (`always-loaded total: … bytes`): the number a fresh target starts from before path-scoping its own rules, which `CHANGELOG.md` records per release. Then settle a disposition for each template rule (`orchestration.md`, `tooling.md`, and the bracketed entry in `cbk-conventions-reference.md`'s `paths:`): fill, path-scope, or delete — see `cbk-conventions.md` § Rule loading and the instruction budget.

Optional further customization:
- Add project-local reviewer agents under `.claude/agents/` (the kit ships `adr-conformance-reviewer`, `logging-discipline-reviewer` and `cascade-rule-reviewer`; add your own for project-specific concerns).
- Keep or delete `.claude/agents/Explore.md`. It overrides Claude Code's built-in Explore agent — "A user or project subagent named `Explore` overrides the built-in and keeps its own `model` field" — with one pinned to `model: haiku` and set to `omitClaudeMd: true`, which launches it "without the user, project, and local CLAUDE.md files" (`https://code.claude.com/docs/en/sub-agents`, read 2026-09-30). Delete it to keep the built-in.
- Tune `pr-review.md`'s Apply/Surface calibration as you learn what's noisy in your project's PRs.
- If you don't use ADRs, keep the ADR guard and its CI job: with no numbered ADR in `docs/adr/` neither ever fires, and the verification block checks both. Removing them means deleting `protect-immutable-adrs.sh` with its `settings.json` stanza and its name in `cbk-conventions.md` § Mutation discipline, `.github/workflows/adr-immutability-check.yml`, and the block lines that check them — a named exception (`.claude/rules/cbk-conventions-reference.md` § Syncing the kit).

## How phases inherit from each other

Each phase reads prior-phase artifacts in full and quotes the relevant content into its inheritance summary. **Paraphrasing is the most common cascade failure mode.** The skill descriptions enforce this at session start.

```
consultation: (no inputs)
scaffold:     reads problem_brief.md
blueprint:    reads problem_brief.md + scaffold.md
framing:      reads problem_brief.md + scaffold.md + blueprint.md + prior frame-NN.md (if any)
rough-in:     reads everything above + the specific frame-NN.md being roughed-in + the framing F-issue + foundation docs
/finish:      reads the rough-in sub-sub-issue body + foundation docs + .claude/rules/*
```

`framing` is unique in that it also inherits from prior framings at its own level — frame-03 reads frame-01 and frame-02 to know which interface commitments already exist and which milestones already shipped. This is the cascade-event model: framings build on each other, not just on the phases above.

## Common gotchas

**Cascade events are append-only.** Re-framing produces `frame-02.md` that supersedes `frame-01.md` via a status field — it does not overwrite. Same for re-rough-in and re-blueprint. The cascade IS the audit trail of decisions; preserving the history is the point.

**ADRs are immutable.** The PreToolUse hook (`.claude/hooks/protect-immutable-adrs.sh`) blocks Claude Code edits to existing ADR files; the CI workflow (`.github/workflows/adr-immutability-check.yml`) blocks raw-git edits in PRs. Supersession writes a new ADR with `Supersedes: ADR-NNNN`.

**Workstream slugs are permanent.** Once `blueprint` commits a slug, it's load-bearing across every Issue title, branch name, label, and PR. The skill runs an explicit slug-confirmation gate at commit time — don't skip past it.

**The `[skip ci]` markers have two traps.** Auto-review workflows run on the HEAD commit at flip-time; if your branch ends with a docs commit carrying `[skip ci]`, your auto-review is also skipped. Quoting the literal token in a commit body re-triggers the matcher. See `.claude/rules/cbk-conventions.md` § `[skip ci]` rule for both gotchas with workarounds.

**Plan mode is non-negotiable in `/finish`.** Even on small-looking issues. The user's review of the plan is the last HITL gate before code lands.

**Upgrade by release, never by re-extracting.** Re-running the install over a repository that carries the kit would replace your filled files; the sync keeps them. See Upgrading.

## What this is not

- **Not a runtime or framework.** Just markdown, slash commands, hooks, and conventions.
- **Not a replacement for thinking.** The skills are HITL-heavy by design; they slow you down at one-way doors so you don't have to undo decisions later.
- **Not opinionated about your stack.** The cascade is stack-agnostic; `blueprint` makes the stack decisions per project, and `/finish` adapts to what blueprint chose (with the customization friction noted above).
- **Not finished.** Some operations along the Linear-planning and Notion-knowledge paths have documentation gaps (the kit falls back to manual where MCP-based ops aren't fully documented). The kit is at v1.0.0 — versioned, with a sync path between releases in `CHANGELOG.md` — and still has rough edges; surface them.

## Influences and related work

The cascade vocabulary is the kit's own (consultation / scaffold / blueprint / framing / rough-in / finish), but the underlying patterns are well-established:

- **[Shape Up](https://basecamp.com/shapeup) (Singer / Basecamp, 2019)** — appetite-based scoping, no-gos, fat-marker sketches. Consultation borrows the appetite dial.
- **[GitHub Spec Kit](https://github.com/github/spec-kit)** — converging vocabulary (Specify / Plan / Tasks / Implement). The mapping to cascade phases is in `cbk-conventions.md` § Spec-Kit vocabulary mapping.
- **[Amazon Kiro Specs](https://kiro.dev/docs/specs/)** — Requirements / Design / Tasks decomposition. Trace IDs (`[F<N>.AC<M>]`) are adopted from Kiro's `_Requirements: 1.1, 3.2_` pattern.
- **[Tessl](https://docs.tessl.io/use/spec-driven-development-with-tessl)** — spec-driven development as an emerging discipline.
- **[Anthropic — Claude Code best practices](https://code.claude.com/docs/en/best-practices)** — plan mode as a decomposition engine; "separate research and planning from implementation."
- **[Martin Fowler / Birgitta Böckeler — SDD survey](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html)** — comparative analysis of spec-driven tools and the gates-vs-noise tradeoff.

Cascade-events-not-overwrites is borrowed from the [ADR pattern](https://adr.github.io/) (Nygard, 2011): immutable, sequentially numbered, supersedes-via-new-document.

## License

Apache License 2.0 — see [LICENSE](LICENSE). The files you install from the kit stay under it; its section 4 sets what redistributing them requires, starting with "You must give any other recipients of the Work or Derivative Works a copy of this License". The kit's licence does not choose your project's own: scaffold asks for that separately (`.claude/rules/cbk-conventions-reference.md` § Licensing).

## Contributing

Issues and PRs welcome. The kit is itself a work-in-progress and rough edges are expected — surface them. A change that alters what a target syncs adds its entry, with its Sync notes, under `CHANGELOG.md`'s `## [Unreleased]` heading.
