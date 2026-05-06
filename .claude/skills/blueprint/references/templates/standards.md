# STANDARDS.md template

On-demand reference. Loaded when doing PRs, quality checks, or when the framing/rough-in/finish phases need to write acceptance criteria. **The PR review checklist is the single most important section** — every issue in the cascade inherits from it.

## What to inherit before drafting

STANDARDS.md is the foundation doc most heavily shaped by scaffold's discovery output. Pull these specifically:

| From | What to extract | Where it goes in STANDARDS.md |
|---|---|---|
| `scaffold.md` quality bar | The whole entry, verbatim | Header note about expected rigor; informs PR review checklist strictness |
| `scaffold.md` PR/review process | Verbatim — do not paraphrase | Git Workflow → PRs section, PR Review Checklist process |
| `scaffold.md` testing philosophy | Verbatim | Testing Requirements section |
| `scaffold.md` decision recording | Whether ADRs are required for stack changes | PR Review Checklist (Docs section) |
| `scaffold.md` working conventions | Branch and commit format | Git Workflow → Branches and Commits |
| `problem_brief.md` appetite | Cycle expectations | Header note about cadence |
| Stack decisions (this phase) | Test framework, CI provider, CI gates | Testing Requirements, CI Pipeline |
| Methodology (this phase) | Cycle structure, workflow rhythm | Git Workflow header note (Shape Up = appetite-bounded; Kanban = continuous flow; Scrum = sprint-bounded) |

**Quality bar is the single most important inheritance.** Scaffold's discovery captured the user's actual posture on quality (looser-during-WIP-tighter-at-public, or strict-from-day-one, or move-fast-and-iterate). STANDARDS.md must reflect that posture, not impose a generic best-practice quality bar that contradicts what the user actually wants.

**Working conventions get carried verbatim.** If scaffold.md says branch naming is `tui-<issue-number>-<short-description>`, STANDARDS.md says branch naming is `tui-<issue-number>-<short-description>` with the same examples. Same rule as CONTRIBUTING.md — re-deriving conventions is the most common bug.

## The template

```markdown
# [Project Name] — Standards

> Load via `@docs/STANDARDS.md` for PRs and quality checks.
> Quality bar: [verbatim from scaffold.md quality bar field — keep this at the top so every reader knows the posture]

## Development Setup

\```bash
[exact commands: clone → install → verify]
\```

## Git Workflow

[Methodology context — one sentence. Examples:
- "Work is shaped per-feature with fixed scope (Shape Up appetite-based)."
- "Continuous flow with WIP limit of N (Kanban)."
- "Two-week sprints (Scrum)."]

- **Branches:** [verbatim from scaffold.md working conventions — naming format with examples]
- **Commits:** [verbatim from scaffold.md — convention name plus scopes if any]
- **PRs:** [verbatim from scaffold.md PR/review process]
- **Main:** [protection — never push directly, CI must pass]

## Code Conventions

[ONLY what linters and formatters don't cover. Show code examples.
For pre-implementation projects, this section may be empty or contain
1–2 conventions inherited from the brief or stack decisions.]

\```[language]
// Preferred pattern
[example]

// Avoid
[counter-example]
\```

## Testing Requirements

**Testing philosophy** (from scaffold.md, verbatim):
> [scaffold.md testing philosophy entry]

- **Coverage target:** [from scaffold.md if specified, otherwise from this phase's stack decisions]
- **New code:** [must have tests? what kind? — derived from quality bar]
- **What goes where:** [unit vs integration vs e2e criteria — derived from stack decisions]
- **What's excluded from testing:** [if scaffold's testing philosophy carved out exclusions, e.g. "lessons are not unit tested — the verifier IS their test", state them explicitly here]

## PR Review Checklist

[**THE enforcement loop.** Every change must satisfy these. The strictness of
this list should match scaffold.md's quality bar — looser quality bar means
fewer required boxes, stricter quality bar means more.]

**Code:**
- [ ] Tests cover new/changed functionality (per testing philosophy above)
- [ ] Error handling follows conventions
- [ ] No broad exception catching
- [ ] [Project-specific code check based on stack decisions]

**Docs:**
- [ ] README updated if user-facing behavior changed
- [ ] ARCHITECTURE.md updated if structure changed (Decisions Log entry for stack changes)
- [ ] CLAUDE.md updated if commands/patterns/gotchas changed
- [ ] [If scaffold said ADRs from day one] ADR written for any architectural decision

**Infra:**
- [ ] CI passes (all gates from CI Pipeline section)
- [ ] No new dependencies without justification (per ARCHITECTURE.md dependency philosophy)
- [ ] CHANGELOG updated for user-facing changes [if the project has a CHANGELOG]

[Add project-specific checks as they emerge. The cascade's framing/rough-in/finish phases will add to this list as they discover patterns.]

## CI Pipeline

[Each row represents one CI job/check. The set of rows comes from the stack
decisions step's Testing and CI category — do not invent CI gates here
that weren't approved during stack decisions.]

| Check | Trigger | What |
|-------|---------|------|
| Tests | push, PR | [test runner command] |
| Lint | push, PR | [lint command] |
| Typecheck | push, PR | [typecheck command if applicable] |
| Build | push, PR | [build command if applicable] |
| [Other gates] | ... | ... |

## Unenforced invariants

[Textual rules from `ARCHITECTURE.md`, `CLAUDE.md`, and the brief that no CI gate
mechanically enforces. Every project has these — invariants that exceed what the
toolchain can check. They live in foundation docs as prose, but humans and automated
review bots are the only thing enforcing them. Listing them here makes them
discoverable and gives any review bot (claude-code-action, CodeRabbit, Copilot
review) a single source of truth to inherit from.]

| Invariant | Source | Severity if violated | How it's caught |
|---|---|---|---|
| [Architectural rule from ARCHITECTURE.md, e.g. "module X depends on nothing in the workspace"] | `ARCHITECTURE.md § Y` | HIGH | Human review or automated review bot |
| [Convention from CLAUDE.md, e.g. "lesson content is not unit-tested; the verifier running the lesson is its test"] | `CLAUDE.md § Z` | MEDIUM | Human review or automated review bot |
| [Rule from the brief's no-gos, e.g. "the engine is sync and offline — no tokio/reqwest/.await"] | `problem_brief.md § no-gos` | HIGH | Human review or automated review bot |
| [Per-pack appetite or scope rule] | `STANDARDS.md § ...` | MEDIUM | Human review or automated review bot |

**Why this section exists**: CI catches mechanical things (formatting, lints,
test failures, dependency advisories). It does not catch architectural intent
or semantic invariants. The Unenforced invariants table is the bridge —
**every row is something a human reviewer or a review bot has to check**.
When the user adds an automated review bot in the tooling configs step,
the bot's review prompt inherits from this table directly. When the user
reviews a PR by hand, this is the checklist.

**HITL prompt during foundation docs step**: after producing
ARCHITECTURE.md and CLAUDE.md, blueprint asks: *"Looking at the architectural
decisions and conventions we just landed, are there textual rules in those
docs that no CI gate catches? Let's list them in STANDARDS.md § Unenforced
invariants — they're the source of truth for code review (human or bot)."*
The user's answers populate the table.

## Decision recording

[From scaffold.md decision recording field, verbatim. If scaffold said ADRs
from day one, this section explains where ADRs live (`docs/decisions/`) and
links to the Nygard format. If scaffold said issue comments and PRs, this
section just says so and notes the trip-wire for revisiting.]
```

## What does NOT belong here

- **Stack decision rationale** — that's ARCHITECTURE.md Decisions Log
- **How to make a change tutorial** — that's CONTRIBUTING.md
- **Commands and tools used daily** — that's CLAUDE.md
- **Initiative scope** — that's `docs/cbk/blueprint.md`
- **Marketing or product positioning** — that's README.md or STRATEGIC_BRIEF.md
- **Detailed test case examples** — STANDARDS.md describes the standard, individual tests live in code

## Bootstrap exemptions

Sometimes the cascade adds CI infrastructure that gates future PRs — for example, a `claude-code-action` workflow that reviews every PR. The chicken-and-egg problem: **the commits that *install* that infrastructure cannot themselves be gated by it**, because the infrastructure doesn't exist on the repo until those commits land.

Document any such exemptions explicitly in STANDARDS.md so contributors don't trip over the apparent contradiction. The format:

```markdown
### Bootstrap exemptions

The following commits are exempt from the standard PR review gate because the
gate itself was not yet installed when they were made:

- **<sub-batch identifier or commit range>**: The commits that installed
  `<gate name>` are exempt from `<gate name>` review. Documented at
  `<PR or issue link>`. Every commit after `<first post-bootstrap commit>`
  goes through the full gate.
```

The exemption must be specific: name the gate, name the commits or sub-batch, and explicitly say when the post-bootstrap regime starts. Vague exemptions ("blueprint-phase commits are exempt") invite scope creep.

**When this section appears**: only when blueprint's stack decisions or scaffold's setup added a CI gate that didn't exist on day one of the repo. If the repo had its full CI from the first commit, no bootstrap exemption section is needed.

**Surface this proactively**: if blueprint's stack decisions include adding a new gate during this phase (new CI workflow, new pre-commit hook, new required check), the skill should explicitly tell the user at the relevant HITL gate: *"This means the commit that adds <gate name> can't itself be reviewed by <gate name> — that's a known bootstrap exemption. I'll document it in STANDARDS.md so it doesn't surprise anyone later."*

## Quality bar calibration

The strictness of STANDARDS.md should match scaffold.md's quality bar entry. Concrete examples:

**Loose during WIP, tighter at public release** (Tinct's pattern): PR review checklist has the structural items (tests, CI passing) but skips items that would slow iteration (no broad exception catching, CHANGELOG updates). Add a header note: *"Standards tighten as the project approaches v1.0 / public release. Items marked [STRICT] become required at that threshold."*

**Strict from day one** (production system, regulatory environment): PR review checklist has every item, CI gates are comprehensive, ADR-required-for-stack-changes is enforced, no exceptions.

**Move fast and iterate** (research prototype, weekend hack): minimal checklist (CI passes, no obvious bugs), no ADR requirement, no CHANGELOG. May not even have a STANDARDS.md — ask whether the user wants one.

When in doubt, lean toward the looser interpretation. STANDARDS.md is easier to tighten over time than to loosen.

## HITL presentation

When presenting STANDARDS.md for review, lead with the quality bar header note: *"Here's the draft STANDARDS.md. I've calibrated the strictness to match what scaffold captured: [one-sentence summary]. The PR Review Checklist is the most important section — let me know if any items should be added, removed, or marked as 'tighten later'."*

Common revision requests:
- "Remove the CHANGELOG check" → drop the row
- "Add a security review item" → add to PR Review Checklist
- "The testing exclusion isn't quite right" → fix the Testing Requirements section
- "Add a [STRICT] marker on the broad exception check" → annotate with the threshold

Iterate until approved. Then commit via GitHub MCP to `docs/STANDARDS.md`.

## Light-mode behavior

If the user invoked light mode:

- **PR Review Checklist becomes 5–7 items** instead of 10+
- **Code Conventions section is skipped** (use linters)
- **CI Pipeline table has only 2–3 rows** (test, lint, maybe build)
- **Decision recording section is one line**

Target: 1 page for light mode, 2–3 pages for default. Skip the doc entirely if the user said "no standards doc" — but flag once that this means framing/rough-in/finish will have to derive quality expectations from elsewhere.
