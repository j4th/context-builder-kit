# Stack decisions step

The first substantive step after inheritance. Blueprint makes the technology stack decisions consultation explicitly deferred. The output of this step feeds directly into ARCHITECTURE.md (full justification with alternatives) and `docs/cbk/blueprint.md` (one-line decisions in the cascade metadata top section).

## Operating principles

Three rules govern how blueprint approaches stack decisions, in priority order:

1. **Constraints from the brief are facts, not questions.** If `problem_brief.md` says "Rust + Ratatui locked," do not re-ask whether to use Rust. Confirm the constraint in one sentence and move on to unconstrained categories. Re-litigating settled decisions wastes the user's time and erodes trust.

2. **Detect-then-confirm, never blank-slate.** For each unconstrained decision, infer a sensible default from inherited context (problem brief shape, scaffold's tool comfort, scaffold's quality bar) and propose it in one sentence. Never ask "what database should we use?" cold. Ask "given the local-only constraint and your stated tool comfort, I'd lean SQLite for the persistence layer — sound right, or do you have a preference I should know?"

3. **Decisions must have a one-sentence justification.** Every decision recorded in ARCHITECTURE.md needs a reason tied back to inherited context. Not "we use SQLite" — "we use SQLite because the brief requires local-only operation and the user has prior comfort with relational stores." If you can't articulate the reason in one sentence, you're guessing, and a guess in blueprint becomes a foundation in framing.

## The five categories

Stack decisions cluster into five categories. Not all apply to every project. Skip categories that don't apply rather than asking ceremonial questions.

### Category 1 — Language and framework

The most fundamental decision and usually the most constrained. The brief almost always names the language (and often the framework) explicitly. Confirm the constraint, then handle unconstrained sub-decisions:

- **Language version target.** "Rust" doesn't say which edition; "Python" doesn't say 3.11 vs 3.12; "Node" doesn't say LTS vs current. Pick a sensible default based on the appetite (newer for hobby/exploration, older LTS for production), confirm.
- **Framework choices** if the language has framework variation. Rust for a TUI is "Ratatui or Cursive or termion," confirm or override. Node for a web service is "Express or Fastify or Hono," etc.
- **Edition/major version commitment.** If the language has stability markers (Rust edition 2024, Python 3.12 type syntax), state which one you're targeting.

**Default question bank** (use 2–4 of these per project, not all):
- *"The brief says <language>. Target the latest stable edition, or do you have a version pin I should know?"*
- *"For <use case>, the obvious framework choices are <A> and <B>. <A> is more <trade-off>, <B> is more <trade-off>. Lean toward <default> based on <inherited context> — sound right?"*
- *"Are there any framework constraints I should know about — corporate-mandated, prior experience, performance requirements?"*

### Category 2 — Storage and persistence

Often the highest-leverage decision after language. Determines what code looks like throughout the project. Sub-decisions:

- **Storage backend.** SQLite, Postgres, JSON file, custom binary format, in-memory only with no persistence, etc.
- **Schema approach.** Migrations vs schema-on-read vs schemaless. ORM vs raw queries vs query builder.
- **Data location.** Local file (where?), user config dir, system service, network.

**Default question bank**:
- *"The brief implies <local-only | networked | embedded | etc.>. For storage I'd lean <default> because <reason from inherited context>. Sound right?"*
- *"Migrations or schema-on-read? Migrations are more rigorous, schema-on-read is faster to iterate. Given your <quality bar from scaffold.md>, I'd suggest <choice>."*
- *"For data location, the standard for <platform> is <XDG_DATA_HOME or ~/Library or %APPDATA% etc.>. Use the standard or override?"*

**Defer pattern**: if the user says "I haven't decided," propose deferring to first real run with a written-down trip-wire (e.g., "store as flat file for v0.1, revisit when corruption-on-crash becomes a real risk"). Defer is better than guess.

### Category 3 — Distribution and deployment

How the thing reaches users. Constrains everything from CI workflows to dependency choices.

- **Distribution mechanism.** Package manager (cargo install, pip, npm), binary download, hosted service, container image, embedded library, source-only.
- **Target platforms.** macOS only, Linux only, cross-platform, web, mobile, embedded.
- **Update mechanism.** Manual reinstall, auto-update, rolling deploy, immutable releases.
- **Versioning scheme.** SemVer, CalVer, ZeroVer, no versioning yet.

**Default question bank**:
- *"The brief says <`cargo install` is a v0.1 gate | hosted at <URL> | etc.>. Confirming distribution is <mechanism> — anything else I should know about target platforms or update behavior?"*
- *"For versioning, <SemVer | CalVer | ZeroVer> based on <appetite/quality bar>. Sound right?"*

**Common gotcha**: distribution decisions sometimes contradict storage decisions. A `cargo install` distribution with a SQLite dependency creates build complexity (system libraries, build scripts). Surface conflicts when you spot them.

### Category 4 — External dependencies

Third-party APIs, libraries, services. Often constrained by the brief but worth confirming explicitly because dependencies have lock-in cost.

- **Required external services.** APIs the project must call, services it must integrate with.
- **Optional external services.** Things that could be external but might be done locally.
- **Library dependency philosophy.** Minimal dependencies (Rust ecosystem common preference), dependency-rich (Node ecosystem common preference), or middle ground.
- **Update cadence.** How often dependencies get bumped — automated, manual, never.

**Default question bank**:
- *"The brief mentions <external dependency>. Confirming we're committing to that — any backup plan if it changes shape, or is the project hard-coupled?"*
- *"Dependency philosophy: minimal (resist additions), pragmatic (add when needed), or maximalist (use what's available)? Defaulting to <choice> based on <ecosystem norms + scaffold's quality bar>."*

### Category 5 — Testing and CI

The decisions that turn STANDARDS.md from a wish into a reality. Closely tied to scaffold's testing philosophy.

- **Test framework.** Usually language-default (cargo test for Rust, pytest for Python, vitest for Node), but check.
- **Coverage target.** From scaffold.md's testing philosophy. If scaffold said "~80% on engine code," that's the answer.
- **Test categories.** Unit only, unit + integration, unit + integration + e2e, property-based, fuzz, snapshot.
- **CI provider.** GitHub Actions (default for the cascade), but the user might have a reason for something else.
- **CI gates.** What blocks merge? Tests passing, lints passing, formatter clean, type check, security scan, docs build, all of the above.
- **Pre-commit hooks.** Yes/no, what they run.

**Default question bank**:
- *"Scaffold said <verbatim testing philosophy>. Translating that to: <test framework>, <coverage target>, <test categories>. Sound right?"*
- *"For CI, GitHub Actions with <gates list> based on your stated quality bar. Anything to add or drop?"*
- *"Pre-commit hooks: yes (catches issues before push) or no (lighter friction)? Defaulting to <choice> based on tool comfort."*

## Working through deferred decisions from the brief

The brief's "Notes for blueprint" section lists specific deferred items. Walk through each one explicitly during the stack decisions step. For each:

1. State the item out loud: *"The brief flagged <item> as a blueprint decision."*
2. Propose a default with justification.
3. Get user confirmation or override.
4. Record in ARCHITECTURE.md (with alternatives) and `blueprint.md` (one-liner).

If the user wants to defer further, propose a trip-wire: *"Defer until <observable condition>, then revisit."* Recorded deferrals are fine; silent omissions are bugs.

## The HITL gate (gate 2)

After all relevant categories have been worked through, present the full stack decision set inline before any docs get produced:

```
## Stack decisions

**Language/framework**:
- <decision> — <one-sentence justification>

**Storage and persistence**:
- <decision> — <one-sentence justification>

**Distribution and deployment**:
- <decision> — <one-sentence justification>

**External dependencies**:
- <decision> — <one-sentence justification>

**Testing and CI**:
- <decision> — <one-sentence justification>

**Deferred decisions** (with trip-wires):
- <item> — defer until <condition>

Anything to change before I move to methodology selection?
```

Iterate until the user approves. The stack decision set then becomes the input for: ARCHITECTURE.md (full content), CLAUDE.md (commands and gotchas section), STANDARDS.md (testing and CI sections), the tooling configs, and the cascade metadata top section of `blueprint.md`.

## Failure modes specific to stack decisions

- **Re-debating constraints from the brief.** If the brief says "Rust + Ratatui locked," asking "are you sure about Rust?" is a bug. Confirm constraints in one sentence, move on.
- **Blank-slate questioning.** Asking "what database should we use?" without proposing a default makes the user do blueprint's job. Always lead with a proposal tied to inherited context.
- **Deciding without a justification.** "We'll use SQLite" without "because <reason>" is a guess in formal clothing. Every decision needs a one-sentence justification or it doesn't get recorded.
- **Skipping deferred decisions from the brief.** If the brief's notes-for-blueprint section listed five items and blueprint addressed four, that's a bug. Walk all five, even if the answer is "defer further."
- **Decision creep.** Blueprint is not the place to pick which logging library to use or which JSON parser. Decisions at this stage are *load-bearing structural choices*. Library-level picks happen in framing or rough-in. If you find yourself asking "which CLI argument parser?" you've gone too deep.

## Light-mode behavior

If the user invoked light mode, collapse the stack decisions step:

- **One batched message** covering all relevant categories with proposed defaults
- **Skip the per-category walkthrough** — present the full decision set at once and let the user override
- **Skip the deferred-decisions walkthrough** — list any items from the brief's notes-for-blueprint section in the batched message, propose defaults, let the user pick
- **Still record every decision with a one-sentence justification** — that's safety, not preference

The format becomes: *"Quick stack pass. Defaults based on what I read: <bulleted list with proposed decision + justification per relevant category>. Anything to change?"* One message, one round, move on.
