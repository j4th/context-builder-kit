# context-builder-kit

> Take an idea from *"I want to make X"* to a merged PR. Six Claude Code skills, one slash command, two reviewer agents, and a small set of rules — drop into any repo and pick the entry point that fits your moment.

The kit is the operational surface of an AI-assisted development cascade: a sequenced funnel from a vague problem statement, through architectural decisions, into milestone planning, all the way to Claude Code opening a draft PR for a single sub-sub-issue. Each phase produces a small, durable markdown artifact the next phase reads. No frameworks, no runtimes — just markdown, slash commands, hooks, and the discipline that holds them together.

```
   raw idea
       ↓
   consultation   →   docs/cbk/problem_brief.md          (chat-only, no repo yet)
       ↓
   scaffold       →   repo + docs/cbk/scaffold.md         (planning surface, conventions)
       ↓
   blueprint      →   docs/cbk/blueprint.md + foundation docs (stack, ADRs, workstreams)
       ↓
   framing        →   docs/cbk/frame-NN.md                (one workstream, sequenced milestones)
       ↓
   rough-in       →   ready-to-implement sub-sub-issues   (each with plan-mode prompt)
       ↓
   /finish <N>    →   draft PR                            (code, tests, simplify, review-toolkit triage)
```

The cascade is **a funnel, not a waterfall**: framing and rough-in run **one workstream / one milestone at a time, just-in-time**. Frame the next thing, build it, then frame the thing after — that's how each phase gets to learn from the previous.

## Quick start

The kit assumes [Claude Code](https://claude.com/claude-code), `git`, and ideally [`mise`](https://mise.jdx.dev/) installed.

```bash
# 1. Drop the kit into your repo
cd your-project
curl -L https://github.com/<your-fork>/context-builder-kit/archive/main.tar.gz \
  | tar xz --strip-components=1
# (Or git submodule, or just `cp -r` from a clone — pick what fits your repo.)

# 2. Customize the conventions file with your project's specifics
$EDITOR .claude/rules/cbk-conventions.md
# Fill in <TEAM>, <workstream-slug> placeholders and delete the
# "This file is a template" callout at the top once you're done.

# 3. Configure MCP servers (cascade reads from .mcp.json)
cp .mcp.json.example .mcp.json
$EDITOR .mcp.json   # fill in PATs, API keys

# 4. Install the Claude Code plugins the kit depends on
#    (See "Required dependencies" below for the canonical list.)

# 5. Open Claude Code in the repo and start. Pick an entry point — see below.
claude
```

That's it. The kit is in place; what you do next depends on where you are in the project.

## Pick your entry point

The full cascade is the rigorous path. Most adopters skip in. Match your situation:

| Where you are | Start at | Skip the cascade above? |
|---|---|---|
| **Vague idea, no repo** ("I want to build something that does X") | `consultation` | No — full cascade |
| **Clear-ish idea, no repo** (problem is shaped, you can describe it in a paragraph) | `scaffold` | Skip consultation; provide a verbal brief or paste one |
| **Existing repo, ready to set up workspace + architecture** | `blueprint` | Skip consultation + scaffold; commit a brief manually if you don't have one |
| **Architecture decided, ready to plan a specific workstream** | `framing` | Skip everything above; **needs `blueprint.md` § Workstreams** |
| **Small project — milestones obvious, just want issues** | `rough-in` ⚠️ *experimental* | Skip framing too; **brittle without a `frame-NN.md`** |
| **One concrete issue ready to implement** | `/finish <N>` | Issue must already have rough-in's seven-section body shape |

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

**Phase 2.** Sets up the infrastructure later phases will use: a code repo, a planning surface (GitHub Projects, Linear, or markdown-only), conventions for branches/commits/labels. Captures team shape and working preferences.

Three backend profiles:
- **github-only** *(default)* — GitHub repo + Projects v2 board + Issues with sub-issues + markdown in `docs/cbk/`. One tool. Recommended starting point.
- **opinionated** — Linear (planning) + GitHub (code) + markdown for cascade artifacts. Three tools, four-level hierarchy on the planning side.
- **markdown-only** — no planning backend, the cascade event log IS the entire artifact set. Use when audience for the cascade is non-technical, or it's documentation rather than active work tracking.

**Abbreviated example** of what scaffold produces (`docs/cbk/scaffold.md`):

```markdown
# Scaffold: Tuitor

## Cascade metadata
**Profile**: github-only
**Hierarchy levels**: 3
**Repo**: github.com/you/tuitor
**Project board**: github.com/you/tuitor/projects/4

## Working conventions
**Team identifier**: TUI
**Branch naming**: `<type>/tui-<N>-<short-slug>`
**Commit format**: Conventional Commits

## Quality bar
Move fast on packs; deliberate on engine. Tests for engine internals; smoke tests for packs.
```

**Skip when:** the repo already exists with conventions, you've picked your planning backend, and you can write a verbal `scaffold.md` from memory. Most experienced adopters skip — scaffold is heavier in chat than in a browser tab.

### 3. `blueprint` — make the strategic technical decisions

**Phase 3** — most complex of the cascade. Inherits the brief and the scaffold output, then makes the load-bearing calls: stack (language, framework, storage, testing), methodology (Shape Up, Kanban, Scrum), and produces six prose foundation docs plus tooling configs.

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

Each issue body has seven sections: Context, Implementation, Acceptance criteria, Test plan, Done signal, Dependencies, PR contract. The `## Implementation` section is the load-bearing input to Claude Code's plan mode in the next phase.

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

**Phase 6.** A Claude Code slash command (`.claude/commands/finish.md`), not a chat skill. Picks up a rough-in sub-sub-issue and runs it through to a draft PR:

1. Read the issue body (seven sections)
2. Verify dependencies (all listed prior-issues closed-completed)
3. Idempotency check (no existing PR / branch for this issue)
4. **Plan mode** anchored on the `## Implementation` section
5. Execute the plan (red tests → green → refactor → `mise run check`)
6. **`/simplify`** pass (per `.claude/rules/simplification.md`)
7. **`pr-review-toolkit:review-pr`** with auto-triage of findings (per `.claude/rules/pr-review.md`)
8. Open the PR as **draft** with the triage table in the body

The user then reviews the draft and flips it to ready when satisfied — that triggers any GitHub Action auto-review (e.g., `claude-review.yml`) and the merge is the user's call.

**`/finish` does NOT**: modify the issue body; handle re-rough-in; bypass dependencies; skip simplify or review-toolkit; mark the PR ready; merge. When the spec is wrong or something is missing, `/finish` surfaces and aborts rather than improvising.

## What the kit ships

```
.claude/
├── commands/
│   └── finish.md                      ← Phase 6 slash command
├── skills/
│   ├── consultation/                  ← Phase 1
│   ├── scaffold/                      ← Phase 2
│   ├── blueprint/                     ← Phase 3
│   ├── framing/                       ← Phase 4
│   ├── rough-in/                      ← Phase 5
│   └── adr-new/                       ← ADR scaffolder (used by blueprint and onward)
├── agents/
│   ├── adr-conformance-reviewer.md    ← /finish dispatches alongside review-toolkit
│   └── logging-discipline-reviewer.md ← same
├── rules/
│   ├── cbk-conventions.md             ← project-level overrides template (you edit this)
│   ├── testing.md                     ← three-regime test classification
│   ├── logging.md                     ← correlation IDs, level taxonomy, sensitive data
│   ├── simplification.md              ← /simplify plugin contract
│   └── pr-review.md                   ← review-toolkit triage rubric (Apply/Surface calibration)
├── hooks/
│   └── protect-immutable-adrs.sh      ← PreToolUse hook blocking ADR edits
└── settings.json                      ← hook registration + plugin/MCP manifest

docs/adr/
├── README.md                          ← ADR index (starter — just ADR-0000)
├── template.md                        ← ADR template
└── 0000-record-architecture-decisions.md  ← meta-ADR establishing immutability

.github/workflows/
└── adr-immutability-check.yml         ← CI gate enforcing ADR-0000 at raw-git level

CLAUDE.md                              ← kit-level instructions for Claude Code
.mcp.json.example                      ← MCP server config template
```

Each skill follows the same pattern: a `SKILL.md` entrypoint plus a `references/` directory with templates and operational reference docs (failure modes, question banks, profile-specific behavior, inheritance discipline). Skills load `references/*.md` lazily on demand.

## Required dependencies

The kit assumes a few things about the host project. None are kit-shipped because they're either external plugins, project-specific config, or things `blueprint` produces.

### Claude Code plugins

Listed declaratively in `.claude/settings.json` under `enabledPlugins`. Install each via Claude Code's plugin system before running `/finish`:

- **`pr-review-toolkit`** — `/finish` Step 7 dispatches `pr-review-toolkit:review-pr` for the auto-triage sweep
- **`simplify`** — `/finish` Step 6 invokes `/simplify` before the review pass
- **`commit-commands`** — convenient wrappers for staging + committing (used by examples in this kit's docs)

The slash commands and skills these provide are referenced by name in `/finish` and the rules files; if your install uses different identifiers, edit the references.

### MCP servers

Listed declaratively in `.claude/settings.json` under `enabledMcpjsonServers`. Configure in `.mcp.json` (copy from `.mcp.json.example`):

- **`github`** — required by every cascade phase that writes to a GitHub repo. PAT with repo + read:project scopes (classic) or fine-grained PAT with Contents/Metadata write + Issues/Pull-requests write per repo.
- **`linear`** — required only for the opinionated profile.
- **`context7`** — used by framing and rough-in research phases for library/framework doc lookups. Reduces stale-knowledge errors when the cascade picks dependencies.
- **`time`** — optional, used by skills that need ISO-8601 conversions or timezone math.

If an expected MCP is missing, the cascade falls back to manual / web-search paths and surfaces the gap.

### Project conventions

The kit's load-bearing assumption is that your project has — or will have, after `blueprint` runs — these surfaces:

- A task runner (`mise.toml` is what `/finish` references in `mise run check`; if you use `Makefile` or `justfile`, edit `/finish` to match)
- `docs/STANDARDS.md` with a quality bar and CI Pipeline table
- The four rules files we ship (testing, logging, simplification, pr-review) — these are referenced by `/finish` and the reviewer agents
- ADR scaffolding under `docs/adr/` (we ship the starter; `adr-new` skill maintains it)

If your project uses a different layout, the kit still works but `/finish` becomes the friction point — edit it after dropping the kit in. See "Customization" below.

## Customization

Three files reliably need editing per project:

1. **`.claude/rules/cbk-conventions.md`** — fill in `<TEAM>`, workstream slugs, branch-naming patterns, methodology choices. Delete the "this file is a template" callout at the top once you're done.

2. **`.claude/commands/finish.md`** — bakes in `mise run check`, `docs/STANDARDS.md § Step 4`, `.claude/rules/testing.md`, `.claude/rules/logging.md`, `pr-review-toolkit:review-pr`, `/simplify`. If your stack doesn't have one of these, edit the file. The seven-section spec contract that `/finish` reads from issue bodies is the stable interface; the tooling assumptions are the swap-out point.

3. **`.claude/settings.json`** — adjust `enabledPlugins` if your installed identifiers differ; adjust `enabledMcpjsonServers` if you don't use one of the four defaults or want to add others.

Optional further customization:
- Add project-local reviewer agents under `.claude/agents/` (the kit ships `adr-conformance-reviewer` and `logging-discipline-reviewer`; add your own for project-specific concerns).
- Tune `pr-review.md`'s Apply/Surface calibration as you learn what's noisy in your project's PRs.
- If you don't use ADRs, delete `docs/adr/` and remove the hook registration from `settings.json`.

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

**No upgrade mechanism yet.** When the kit revises, re-pull manually. A future addition might be a `mise run cbk:update` task that fetches from the public repo, but that's down the road.

## What this is not

- **Not a runtime or framework.** Just markdown, slash commands, hooks, and conventions.
- **Not a replacement for thinking.** The skills are HITL-heavy by design; they slow you down at one-way doors so you don't have to undo decisions later.
- **Not opinionated about your stack.** The cascade is stack-agnostic; `blueprint` makes the stack decisions per project, and `/finish` adapts to what blueprint chose (with the customization friction noted above).
- **Not finished.** The opinionated profile has documentation gaps in some places (the kit falls back to manual where Linear/Notion ops aren't fully documented). The kit is at evergreen v0 — usable, but expect rough edges and surface them.

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

See [LICENSE](LICENSE).

## Contributing

Issues and PRs welcome. The kit is itself a work-in-progress and rough edges are expected — surface them.
