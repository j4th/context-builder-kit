---
name: blueprint
description: Make stack and methodology decisions, produce the foundation doc set, and define the initiative for an AI-assisted development project. Use this skill whenever the user has a problem brief and scaffold output and is ready to make strategic technical decisions. Triggers include "let's blueprint this", "time for stack decisions", "set up CLAUDE.md and standards", "what stack should I use", "I need a CLAUDE.md", "how should I architect this", "I have my repo set up, what's next", "define the initiative", or any reference to the cascade at the blueprint level. Also use when a user skipped earlier phases — the skill will note missing inputs and offer to run them. **Use this skill even when the user doesn't explicitly say "blueprint" — the trigger is the moment of "I have a workspace and need to decide how to actually build this", not the vocabulary.** Phase 3 of the cascade. Produces six prose docs plus tooling configs and a handoff issue, and either creates a Linear initiative or commits blueprint.md to the repo.
---

# Blueprint

Phase 3 of the six-phase AI-assisted development cascade. Inherits from consultation (the problem brief) and scaffold (the workspace, conventions, and team context). Makes the strategic technical decisions — stack, architecture, methodology, AI agent configuration — and produces the foundation documents that the rest of the cascade and any human contributors will read.

Blueprint is the most complex phase in the cascade because it has the widest scope: stack decisions, methodology selection, six prose foundation documents, tooling configs, and the initiative spec itself. To keep this manageable, it uses the same rigor dial pattern as consultation and scaffold (light / standard / full) and routes operational detail into reference files rather than inlining everything.

## Required inputs and how to read them

Blueprint requires two prior-phase artifacts as inputs:

- `docs/cbk/problem_brief.md` — from consultation
- `docs/cbk/scaffold.md` — from scaffold

If either is missing, **do not silently proceed**. Either run the missing phase first, accept an uploaded file or verbal equivalent (and flag that the input is informal), or — if the user is starting blueprint cold without the prior phases — ask what's available and adapt.

**Reading the inputs**. If the repo is connected via GitHub MCP, read both files via the MCP. If not, ask the user to upload them or paste them. Do not proceed until you have read both files in full — blueprint depends on inheriting from them, and skimming or guessing at their content is the most common blueprint failure mode.

## Three rigor modes — light, standard, full

Blueprint's full flow (inheritance check → stack decisions → methodology selection → foundation docs → initiative content → HITL gates between each) is the **full mode**, not a requirement. There are three rigor modes the user can pick from, each appropriate for different contexts:

**Full mode** — six HITL gates (one per doc plus the inheritance, stack, and methodology gates). Maximum review surface, slowest pace. Best for: first-time blueprint runs, complex projects, projects with multiple stakeholders, anyone who wants every decision reviewed before commit.

**Standard mode** — three HITL gates batched at step boundaries: (1) after stack decisions, (2) after methodology selection, (3) after all foundation docs as a single batch. Same five steps, real interaction at each gate, but no per-doc interruptions. Best for: users who have done the cascade once and want the discipline without the friction of per-doc review. **This is the right default for users who say "I want the full cascade but don't make me click through six docs."**

**Light mode** — one combined up-front confirmation listing what blueprint will produce, then run-to-completion with no further gates until presentation. Best for: users who say *"just give me a CLAUDE.md and a stack decision"*, *"keep it minimal"*, *"I know what I'm doing"*, or *"I just want the initiative spec, skip the rest"*.

**Detect-then-confirm**: at session start, propose a mode in one sentence based on the user's opening message. *"Sounds like you want the full cascade but want to keep the review pace tight — I'll run in **standard mode**, three gates total. Say 'full' for per-doc gates or 'light' for one combined confirmation."* Let the user override in one word. If their opening message gives no signal, default to **standard mode** for first-time users since per-doc review is heavy and most users don't need it on the first pass; offer to switch to **full mode** if they want every decision reviewed.

The mode dial can be tuned mid-session — if the user says *"actually let's batch these docs"* during full mode, switch to standard for the remaining docs without restarting.

Light-mode patterns to honor (also apply to standard mode where relevant):

- **Skip foundation docs the user doesn't want**. Six docs is the upper limit, not a requirement. A user who just wants CLAUDE.md and an initiative spec should get those two and nothing else.
- **Collapse stack decisions into a single batched message** if the user has clear preferences and just wants confirmation. The detailed stack-decisions step (`references/stack-decisions.md`) is the default; collapse is allowed.
- **Skip methodology selection** if the user names a methodology directly. "Use Shape Up" doesn't need a register walkthrough.
- **Combine HITL gates** into a single up-front "here's what I'll do, ok?" confirmation if the user explicitly asks for light mode.

What blueprint should *not* skip even in light mode: **reading the inputs in full** (skipping inheritance is the failure mode light mode is most likely to cause), **at least one explicit stack decision** (otherwise the cascade has no technical anchor), **the initiative content** in `docs/cbk/blueprint.md` (the cascade's core artifact for this phase), and **the handoff issue** (the cascade's transition from bootstrap to normal development — see Step 6 below).

## Step 6 — handoff issue creation

After all foundation docs are committed, all tooling configs are committed, and `docs/cbk/blueprint.md` is committed, blueprint creates **one issue** in the project's tracker that serves as the human's first-build runlist. This is the cascade's transition from "blueprint-controlled bootstrap" to "normal development."

The issue contains: a one-line statement that closing it ends the bootstrap exemption, the toolchain bootstrap command, a verbose version-pin inventory (every dep blueprint pinned, listed verbatim, grouped by file), the manual setup steps that couldn't be automated, a definition-of-done checklist, and a "what's next" pointer to the framing phase. Title: `Blueprint handoff: bootstrap and validate pins` (greenfield) or `Blueprint bootstrap: validate pins and complete setup` (brownfield). Label: `chore` (never `tech-debt`).

**Non-negotiable in any rigor mode** — light mode included. The cost of skipping is "user returns to repo cold and hits build failures with no context"; the cost of doing it is one tool call. Always create. Only opt-out is explicit user override.

Full template, version inventory subroutine, brownfield variant, and profile differences live in `references/handoff-issue.md`.

## Sub-batching for token-budget pressure

Producing six foundation documents in a single session is token-heavy. For complex projects or sessions where token budget is tight, blueprint should explicitly **sub-batch foundation doc production** into two groups rather than producing all six in one mega-message:

- **Stack-shaped batch**: CLAUDE.md, ARCHITECTURE.md, STANDARDS.md — the docs that depend most directly on stack decisions and have the most technical content
- **Human-shaped batch**: CONTRIBUTING.md, README update, blueprint.md — the docs that depend more on team shape, conventions, and strategic framing

Each batch gets its own HITL gate (in full mode) or collapses into the foundation-docs gate (in standard mode). The split is natural because the human-shaped batch can reference the stack-shaped batch — CONTRIBUTING.md mentions setup commands from CLAUDE.md, README links to ARCHITECTURE.md, blueprint.md references DECISION-NNN entries from ARCHITECTURE.md. Producing the stack batch first means the human batch has real references to point at instead of placeholders.

**When to sub-batch explicitly**: when token budget feels pressured (long inheritance summary, dense stack decisions, complex methodology section), when the user has signaled they want pace, or when you're approaching context limits and want to ensure each doc gets full attention. Don't sub-batch by default in light-touch projects where six concise docs fit comfortably in one session.

Sub-batching is orthogonal to mode — it's a token-management technique, not a rigor choice. A user in standard mode might still ask for sub-batching if their project is complex; a user in full mode might explicitly say "no sub-batching, do all six in one go" if they want the full set in front of them at once.

## Inheritance from scaffold and consultation

Before any decisions, blueprint reads both prior-phase outputs and explicitly states what it inherited. This is not optional and not skippable — it's the foundation for everything blueprint produces.

**From `problem_brief.md` (consultation)** blueprint extracts:
- The problem statement and target users (informs README, CLAUDE.md context section)
- Appetite (informs methodology selection — Small/Medium appetites suit Shape Up, ongoing work suits Kanban, etc.)
- Proposed approach (informs architecture sketch — what gets built)
- No-gos (must be preserved in blueprint.md and respected in stack decisions)
- Success criteria (carries forward into blueprint.md success criteria, possibly refined)
- Stack constraints noted as "for blueprint" in the brief — these are the user's pre-decided parts of the stack that blueprint must respect

**From `scaffold.md` (scaffold)** blueprint extracts:
- Profile and hierarchy levels (determines whether blueprint creates a Linear initiative or commits `blueprint.md` to `docs/cbk/`)
- Team shape (informs PR review process in STANDARDS.md, CONTRIBUTING.md tone)
- Quality bar (the single highest-leverage piece — informs testing philosophy in STANDARDS.md, CI strictness in tooling, code review norms)
- Working conventions (branch naming, commit format, label taxonomy — these go into CONTRIBUTING.md verbatim, do not re-derive)
- Development preferences (testing philosophy, decision recording, PR/review process — these become the seed for STANDARDS.md)
- Tool landscape (informs CLAUDE.md's commands section and tooling configs)
- Tool comfort (informs how much explanation CLAUDE.md needs)

After reading both files, **state inheritance explicitly to the user**: *"Reading what I've inherited: from the problem brief, [one-sentence summary of problem + appetite + key constraint]. From the scaffold output, [one-sentence summary of profile + team shape + quality bar]. The stack decisions you flagged for blueprint are: [list]. Anything to correct before I proceed?"*

This is the first HITL gate. The user's correction here prevents downstream rework.

### Markdown-only profile acknowledgment (runs only if scaffold landed in markdown-only mode)

If scaffold's profile field is `markdown-only`, blueprint adds a one-line acknowledgment to the inheritance gate before proceeding. The user already confirmed markdown-only at scaffold's full HITL gate, so this is not a re-litigation — it's a "I see what scaffold did, here's what it means for blueprint specifically" sanity check at the moment blueprint takes the baton:

> "I see scaffold landed in **markdown-only** profile. That means for blueprint specifically: I'll produce every foundation doc and `blueprint.md` as normal, but I'll **skip the planning-backend half of every commit** — no parent Issues get created on GitHub, the atomic transition collapses to just the markdown commit, and the workstream slug confirmation gate (which still runs because slugs appear in `blueprint.md` headings and downstream `frame-NN.md` references) is locking in identifiers that will exist only in markdown. Setup steps that would normally go into a GitHub handoff issue will stay in `blueprint.md` § Manual setup instead. Sound right, or do you want to revisit the profile choice before I commit anything?"

If the user wants to revisit the profile, blueprint pauses and tells them to re-run scaffold with the new profile choice — blueprint cannot change the profile mid-session because the profile is committed in `scaffold.md` and changing it requires re-running scaffold's confirmation gate. This is intentional: profile is a one-way door at the cascade level, set once at scaffold time.

If the user confirms, blueprint proceeds normally — the markdown-only behavior is already plumbed through every downstream step (see `references/planning-backend-commit.md` for the per-step skip pattern). This acknowledgment exists so the user gets one explicit reminder at the moment blueprint takes over, not for the user to make a new decision.

This sub-gate runs in every rigor mode. Light mode doesn't collapse it because it's a one-line acknowledgment, not a heavy gate, and the explicit reminder is the whole point.

Full inheritance details and edge cases in `references/inheritance.md`.

## Stack decisions step

The first substantive step of blueprint. The user's problem brief deferred stack decisions to this phase; now blueprint makes them. Stack decisions cluster into five categories — not all apply to every project, and the skill should ask only the relevant ones:

1. **Language and framework**: which language, which framework if any, version targets
2. **Storage and persistence**: database, file format, in-memory vs disk, schema approach
3. **Distribution and deployment**: how the thing gets to users (cargo install, npm package, docker image, hosted service, etc.)
4. **External dependencies**: third-party APIs, libraries, services the project relies on
5. **Testing and CI**: test framework, coverage targets, CI provider, what gates the build

For each relevant category, blueprint runs a detect-then-confirm pattern (same as consultation/scaffold): infer a default from the problem brief and scaffold context, propose it in one sentence, let the user confirm or override. Do not present a blank slate of options — that wastes the user's time.

**Stack constraints from the brief are facts, not questions.** If the brief says "Rust + Ratatui locked," do not re-ask whether to use Rust. Confirm the constraint and move on to the unconstrained categories.

**Decisions get recorded in two places**: ARCHITECTURE.md (technical justification, alternatives considered, trade-offs) and blueprint.md (the decision itself, one line per decision, in the cascade metadata top section).

### Example excerpt (what one decision looks like in practice)

To make the output shape concrete: here's what one stack decision looks like when it lands in ARCHITECTURE.md's Decisions Log. Note the specificity — alternatives are real (not strawmen), the justification ties to inherited context from the brief, and consequences are stated even when they're trade-offs the team accepts.

**Input fragment** (user during stack decisions step):
> "I want progress to persist across sessions but I don't want to introduce a system dependency. Probably SQLite if I can find a way that doesn't need libsqlite3 installed system-wide."

**Output fragment** (resulting ARCHITECTURE.md Decisions Log entry):
```markdown
### DECISION-001: Use SQLite via rusqlite with the `bundled` feature for progress persistence

**Status**: Accepted
**Date**: 2026-04-11

**Context**: The brief requires persistent progress across sessions and prohibits system-level dependencies (the `cargo install` ergonomics are a v0.1 ship gate). Options considered:

1. **JSON file via serde_json** — simple, no deps, but no query capability for spaced-repetition scheduling
2. **SQLite via rusqlite (default)** — full SQL, but links against system libsqlite3 → violates the no-system-deps rule
3. **SQLite via rusqlite + `bundled` feature** — full SQL, libsqlite3 compiled and linked statically inside the binary, no system dep
4. **sled (embedded KV)** — pure Rust, no system deps, but immature and lacks SQL query support

**Decision**: Option 3. Rusqlite with the `bundled` feature gives us SQL queryability for SRS scheduling without violating the no-system-deps rule from the brief. The cost is a slightly larger binary and a marginally longer build time on first compile.

**Consequences**:
- Binary size increases by ~1.5MB (acceptable; the brief tolerates a single-binary distribution model)
- Cross-compilation requires a C compiler in the build environment (acceptable for CI; documented in CLAUDE.md)
- Future migrations use sqlx-style migration files committed to the repo (separate decision DECISION-004)
```

The full ARCHITECTURE.md template, including the Decisions Log structure and the discipline rules around it, lives in `references/templates/architecture.md`. The example above just shows what one decision feels like in practice.

Detailed question banks, failure modes, and the detect-then-confirm phrasings are in `references/stack-decisions.md`.

**HITL gate**: present the full stack decision set inline before producing any docs. Iterate until the user approves.

## Methodology selection step

The second substantive step. Pick a methodology from the register based on team shape, appetite, and quality bar — all of which blueprint inherited from scaffold.

The methodology register lives outside this skill (it's shared across all six cascade phases). The blueprint-relevant entries are summarized in `references/methodology-selection.md`, which contains:

- The decision tree for picking a default based on inherited context
- Per-methodology pros/cons relative to the project at hand
- How the methodology choice influences each foundation doc (e.g., Shape Up changes how STANDARDS.md frames PR cycles)

**Detect-then-confirm**: propose a methodology in one sentence with a one-sentence justification tied to inherited context. Example: *"Given the bursty solo cadence and the per-pack scope discipline you mentioned in the brief, I'd recommend Shape Up's appetite-based scoping — fixed scope per pack, variable calendar between packs. Sound right, or would you rather use something else?"*

**Citation discipline**: when proposing a methodology, name the source from the register. *"Shape Up — Singer, Basecamp, 2019"*. Same rule as consultation. Don't recommend without a citation.

**HITL gate**: user confirms methodology before blueprint moves to producing foundation docs.

## Foundation document production

Blueprint produces six prose foundation docs plus tooling configs. The order is **most critical first**, so the user can correct the highest-leverage docs before lower-leverage ones inherit from them.

| Order | Doc | Location | Why this order |
|---|---|---|---|
| 1 | CLAUDE.md | root | Shapes every future Claude Code session — get this right first |
| 2 | docs/ARCHITECTURE.md | docs/ | Stack decisions and system structure — every other doc references this |
| 3 | docs/STANDARDS.md | docs/ | Quality bar, testing, CI — depends on stack and methodology |
| 4 | CONTRIBUTING.md | root | Branch/commit/PR norms — mostly inherits from scaffold.md, lighter lift |
| 5 | README.md update | root | Updates the existing README with stack info; do not rewrite from scratch |
| 6 | docs/cbk/blueprint.md | docs/cbk/ | The cascade artifact — written last so it can reference all the others |

**Plus tooling configs** (not prose docs, real config files):
- CI workflow files in `.github/workflows/`
- Task runner config (mise.toml, Makefile, justfile, package.json scripts — depends on stack)
- `.env.example` if applicable

Each doc has its own template in `references/templates/`. Each template starts with a "what to inherit from scaffold.md and problem_brief.md" section so the doc-production process is grounded in the prior phases, not invented fresh.

**For each doc, the production pattern is**:
1. Read the template
2. Extract relevant inheritance from scaffold.md and problem_brief.md
3. Draft the doc
4. Present inline for HITL review and iteration
5. Commit via GitHub MCP (or downloadable artifact fallback) only after approval

**Same MCP-then-fallback pattern as scaffold**: try to commit each doc to its target location via GitHub MCP, fall back to downloadable artifacts if MCP isn't available. Do not commit before HITL approval — the MCP commit is one tool call away, which is exactly why the gate must be explicit.

### Workstream slug confirmation gate (mandatory inside `blueprint.md` production)

When producing `blueprint.md` (doc #6, the cascade artifact), the workstreams table contains both human-readable workstream names AND the slugs derived from them. **Slugs are the cascade's longest-lived identifier** — they appear in every parent Issue title (`[regex-pack] Regex pack`), every framing sub-issue title (`[regex-pack:F1] ...`), every rough-in sub-sub-issue title (`[regex-pack:F1:R1] ...`), every PR title that closes a downstream Issue, every `frame-NN.md` reference, every `README.md` index row, and every commit message that references work on the workstream. They're also visible in markdown-only mode (in `blueprint.md` headings and `frame-NN.md` references) so this gate runs in every profile.

**Run an explicit slug-confirmation gate as a sub-step of step 4** (Present inline for HITL review). After drafting `blueprint.md`'s workstreams table, surface the slugs separately from the rest of the doc:

> "Before I commit `blueprint.md`, I want to lock in the workstream slugs because they're permanent and visible everywhere downstream. Each workstream's name is human-readable, but the slug is what shows up in every Issue title, every PR title, and every cascade reference from now on. Here's what I derived from the workstream names:
>
> | Workstream name | Proposed slug |
> |---|---|
> | Regex pack | `regex-pack` |
> | Tmux pack | `tmux-pack` |
> | Bash pack | `bash-pack` |
>
> Each slug is short, lowercased, dash-separated, no special chars, and unique. They'll appear in every downstream Issue as `[regex-pack:F1] ...` and `[regex-pack:F1:R1] ...` patterns.
>
> Confirm or override each slug. **Be deliberate** — once parent Issues exist with these slugs, renaming requires re-creating the Issues by hand. If any of these feel wrong, this is the moment to change them."

The user can confirm the full set, override individual slugs, or rename workstream names entirely (which re-derives the slugs). Iterate until the user explicitly approves the slug set. **Do not proceed past this gate to the parent Issue commit** without explicit slug approval.

This gate runs in every rigor mode, including light mode. The one-way-door property — slugs are permanent and visible — is too strong to leave to inference. Light mode collapses other gates but not this one.

Detailed templates and production guidance:
- `references/foundation-doc-templates.md` — overview and per-doc guidance
- `references/templates/claude-md.md`, `architecture.md`, `standards.md`, `contributing.md`, `readme.md`, `tooling.md` — the templates themselves

## Profile-aware behavior

Blueprint's behavior differs between the GitHub-only and opinionated profiles. The differences are documented in `references/github-only-vs-opinionated.md`. Short version:

**GitHub-only profile**:
- All foundation docs commit to the GitHub repo via MCP
- `blueprint.md` commits to `docs/cbk/blueprint.md` — there is no Linear initiative entity
- The initiative content (goal, success criteria, workstreams, dependencies) lives inside `blueprint.md`, not in any planning tool
- Methodology selection is informational only; no Linear cycle configuration

**Opinionated profile**:
- Foundation docs still commit to GitHub
- `blueprint.md` still commits to `docs/cbk/blueprint.md` *and* the initiative gets created as a Linear entity with the same content
- Linear initiative is created via Linear MCP in planned/draft state
- Methodology selection may inform Linear cycle length

Read `references/github-only-vs-opinionated.md` for the per-operation differences. The opinionated profile is partially validated — same status as in scaffold — walk through what's documented, fall back to manual where it isn't.

## HITL gates summary

Blueprint has seven HITL gates in **full mode**, four in **standard mode**, and two in **light mode**. Pick the mode at session start (or let the user override mid-session).

**Full mode — seven gates** (per-doc review):

1. **After inheritance check** — user confirms the inheritance summary is accurate
2. **After stack decisions** — user approves the full stack decision set
3. **After methodology selection** — user confirms the methodology choice
4. **After each foundation doc** — user reviews and approves before commit (six iterations through this gate, one per doc)
5. **After tooling configs** — user reviews CI workflow, task runner config, .env.example
6. **After blueprint.md** — user approves the cascade artifact
7. **After handoff issue draft** — user reviews the version-pin inventory and checklist before blueprint creates the issue in the tracker

**Standard mode — four gates** (step-boundary review):

1. **After stack decisions** — user approves the full stack decision set (inheritance check happens silently before this gate, with the inheritance summary included in the gate's review material)
2. **After methodology selection** — user confirms the methodology choice
3. **After all foundation docs + tooling configs + blueprint.md as a single batch** — user reviews everything together and approves the full output
4. **After handoff issue draft** — same as gate 7 in full mode; the handoff issue is reviewed separately because the user needs to verify the version inventory before it gets created

**Light mode — two gates**: a single up-front confirmation listing what blueprint will produce, then run-to-completion until the handoff issue draft is presented for final review. The handoff issue gate cannot collapse into the up-front confirmation because the version inventory doesn't exist until after the configs are committed.

Each gate is an explicit "approve to proceed" moment. Iterate within a gate as many times as needed. The mode dial can be tuned mid-session — switching from full to standard partway through is fine; switching from standard to full is fine; switching to light requires the user to acknowledge what they're skipping. The handoff issue gate exists in all three modes — it's the one gate that doesn't collapse.

## Handoff contract to framing

When blueprint is complete, framing inherits:

- **Six foundation docs** at known locations, all reviewed and committed
- **Tooling configs** in `.github/workflows/` and the appropriate task runner location
- **`docs/cbk/blueprint.md`** containing stack decisions, methodology selection, success criteria, workstreams, dependencies, not-in-scope, and open questions
- **All prior cascade artifacts** still readable: `problem_brief.md`, `scaffold.md`

**What blueprint must not pass to framing**: actual project plans (that's framing), milestones (rough-in), issues (finish), or implementation code. Blueprint stops at "workstreams with one-sentence purpose each" — turning workstreams into project plans is framing's job.

Framing must read `blueprint.md` at the start of its session (along with the prior-phase docs).

## Failure modes to defend against

Detailed in `references/failure-modes.md`. Highlights:

- **Skipping inheritance** — light mode's biggest risk. Even in light mode, blueprint must read both prior-phase files in full.
- **Premature stack lock-in** — committing to a stack decision the user hasn't actually agreed to because the brief mentioned it once. Confirm constraints, don't assume them.
- **Methodology dogmatism** — recommending Shape Up because the cascade uses it, not because it fits. The register is a menu, not a prescription.
- **Foundation doc bloat** — producing all six docs even when the user wants three. Honor the dial.
- **Inventing conventions blueprint should inherit** — re-deriving branch naming or label taxonomy in CONTRIBUTING.md instead of pulling from scaffold.md verbatim.
- **Stack decisions without architecture context** — deciding "use SQLite" without explaining why in ARCHITECTURE.md. Every decision needs a one-sentence justification at minimum.
- **CLAUDE.md sprawl** — including everything Claude Code might need. The Anthropic best practice is "would removing this cause Claude to make mistakes? If not, cut it." Apply ruthlessly.
- **Bootstrap-gate paradoxes** — if the cascade is creating CI infrastructure that will gate future PRs (e.g., installing claude-code-action), the commits that *install* that infrastructure cannot themselves be gated by it. Surface this exemption explicitly during stack decisions when applicable; document it in STANDARDS.md so the user doesn't trip over it later. Detail in `references/failure-modes.md`.

## Solo vs. team notes

**Solo**: foundation docs can be lighter (CONTRIBUTING.md is largely for the user's future self, STANDARDS.md is a personal quality bar). Methodology selection often defaults to Shape Up appetite-based or "no formal methodology, just discipline." Stack decisions are personal preferences; trust them.

**Team (2–10)**: foundation docs become real coordination artifacts. CONTRIBUTING.md is read by every new team member. STANDARDS.md is the team's quality agreement. Methodology selection should be a team decision — if the user is the lead but the team hasn't agreed, surface that as an open question for the team to discuss before framing.

## Reference files

- `references/planning-backend-commit.md` — the Milestone-per-workstream creation step, atomic transition pattern with the markdown commit, slug collision handling, profile-aware behavior (read this in tandem with `backends.md` from the cascade meta-doc set)

- `references/inheritance.md` — how to read scaffold.md and problem_brief.md, what to extract, edge cases
- `references/stack-decisions.md` — the stack decisions step: question banks, detect-then-confirm phrasings, failure modes
- `references/methodology-selection.md` — how to pick from the methodology register based on inherited context
- `references/foundation-doc-templates.md` — overview of all six foundation docs and the production pattern
- `references/templates/claude-md.md` — CLAUDE.md template
- `references/templates/architecture.md` — ARCHITECTURE.md template
- `references/templates/standards.md` — STANDARDS.md template
- `references/templates/contributing.md` — CONTRIBUTING.md template (new in cascade, not in initiative-planner)
- `references/templates/readme.md` — README update template
- `references/templates/tooling.md` — tooling config production guidance
- `references/blueprint-output-template.md` — the docs/cbk/blueprint.md template with cascade metadata top section
- `references/hitl-question-bank.md` — clarifying questions for inheritance, stack, methodology, and project-grouping rounds
- `references/github-only-vs-opinionated.md` — profile-aware behavior differences
- `references/failure-modes.md` — blueprint-specific failure modes with examples
- `references/test_cases.md` — three realistic test prompts (canonical run / unusual stack / conflicting constraints) with success criteria for verifying the skill still works after revisions

Read references on demand, not all at once. The SKILL.md is a routing document; the heavy operational content lives in the references.
