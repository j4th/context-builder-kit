# Foundation document templates — overview

Blueprint produces six prose foundation documents plus tooling configs. This file is the overview — pointers to per-doc templates plus the production pattern that applies to all of them. Read this before producing any foundation doc, then read the individual template for the doc you're working on.

## The six docs and why they exist

| Order | Doc | Location | Audience | Lifecycle |
|---|---|---|---|---|
| 1 | CLAUDE.md | repo root | Claude Code in every session | Always-loaded; must be lean (<300 lines, <150 better) |
| 2 | docs/ARCHITECTURE.md | `docs/` | Humans + Claude on demand | On-demand reference; can be comprehensive |
| 3 | docs/STANDARDS.md | `docs/` | Humans + Claude during PRs/quality checks | On-demand reference; load via `@docs/STANDARDS.md` |
| 4 | CONTRIBUTING.md | repo root | New human contributors | Read once per contributor |
| 5 | README.md (update) | repo root | Anyone landing on the repo | Public-facing first impression |
| 6 | docs/cbk/blueprint.md | `docs/cbk/` | Cascade phases (framing → finish), future Claude sessions | Cascade artifact, mirrors scaffold.md shape |

**Why this order**: highest-leverage docs first, so user corrections at the top propagate down. CLAUDE.md is loaded every session and shapes every Claude Code interaction — get it right first. ARCHITECTURE.md is the canonical record of stack decisions that other docs reference. STANDARDS.md depends on the stack and methodology choices in ARCHITECTURE. CONTRIBUTING.md mostly inherits from scaffold.md so it's lighter lift. README is an update to existing content. blueprint.md ties everything together and is written last so it can reference all the others.

**Plus tooling configs** — not prose docs, real config files committed alongside the prose:
- `.github/workflows/*.yml` — CI workflow(s) matching STANDARDS.md's CI gates
- Task runner config: `mise.toml`, `Makefile`, `justfile`, or `package.json` scripts (depends on stack)
- `.env.example` if the project uses environment variables
- `.editorconfig` if the team has formatting preferences not covered by language tooling

Tooling configs are produced after all six prose docs because they encode decisions the prose docs already made. If `STANDARDS.md` says "lint, typecheck, and tests must pass before merge," the CI workflow file just executes those commands. If CLAUDE.md says `just check` is the quality gate command, the justfile must define that command. Tooling configs are mechanical implementations of prose decisions — never the other way around.

## Default locations and what gets where

Two location rules govern where each foundation doc lives. **Modern repo convention is to keep root clean** — only files that GitHub renders specially or that tooling expects at root should live there.

**Lives at root** (because GitHub or tooling expects it there):
- `README.md` — GitHub renders it as the repo landing page
- `LICENSE` — GitHub recognizes it for license badge and SPDX detection
- `CONTRIBUTING.md` — GitHub surfaces it in the issue/PR creation flow
- `CLAUDE.md` — Claude Code looks for it at root by default
- `CODE_OF_CONDUCT.md`, `SECURITY.md`, `FUNDING.yml` (if used) — GitHub recognizes them

**Lives in `docs/`** (everything else):
- `docs/ARCHITECTURE.md` — system design and decisions log
- `docs/STANDARDS.md` — quality bar, PR checklist, CI gates
- Any Tier 2-3 doc (`docs/SECURITY_MODEL.md`, `docs/DOMAIN_MODEL.md`, etc.)

**Lives in `docs/cbk/`** (cascade-internal artifacts only):
- `docs/cbk/problem_brief.md` (from consultation)
- `docs/cbk/scaffold.md` (from scaffold)
- `docs/cbk/blueprint.md` (this phase's output)
- `docs/cbk/<future phases>` as the cascade progresses

**Do not put cascade artifacts in `docs/`** — that pollutes the regular docs space with cascade-internal content humans shouldn't read day-to-day. The `cbk/` namespace exists to keep the cascade's footprint contained.

If the user has a strong preference (e.g., "I want STANDARDS.md at root"), honor it but note the trade-off once: *"Putting STANDARDS.md at root means it sits next to README and LICENSE in directory listings — fine for some workflows, less common in modern repos. Confirming you want it at root?"*

## Cross-reference convention

Cascade docs reference other docs frequently (CLAUDE.md @-references ARCHITECTURE.md, blueprint.md points to ARCHITECTURE.md DECISION-NNN entries, README's Documentation table lists every foundation doc). Pick one convention and stick to it across all produced docs.

**Default convention: inline code paths.**

```markdown
See `docs/ARCHITECTURE.md` § "Decisions Log" for the rationale.
See `docs/STANDARDS.md` § "PR Review Checklist".
The conventions live in `CONTRIBUTING.md` at the repo root.
```

**Why inline code over markdown links**: paths in inline code are *location-stable* — they read correctly even if the link breaks, even outside a markdown renderer, even when copy-pasted into a terminal or another document. Markdown links are navigable in rendered markdown but break silently when files move and look like junk in plain text. Cascade docs get read in many contexts (rendered on GitHub, raw in editors, in Claude Code's terminal, copy-pasted into chat) and inline code is the most robust across all of them.

**Exception**: README.md's Documentation table uses markdown links because the README's audience is GitHub's rendered view and the links are the whole point of the table. CLAUDE.md's @-references use the `@docs/file.md` syntax because Claude Code parses that specifically for context loading. Both exceptions are about target audience, not preference — only override the inline-code default when there's a real audience reason.

## Templates as checklists when conversation has shaped the doc

The default production pattern is: read the template, extract from inheritance, draft from the template structure. This works when the conversation hasn't yet shaped what the doc should look like — the template is a starting point.

But sometimes the conversation has *already* shaped a doc's content before blueprint reaches the production step. The user has been describing what they want CLAUDE.md to look like throughout the session: which commands matter, what patterns Claude should know, what's off-limits. By the time blueprint reaches Step 4 (draft the doc), the template would be redundant — the doc shape is already known.

**In that case, treat the template as a checklist instead of a starting point.** Walk the conversation, draft the doc from what's been established, then use the template to verify nothing was missed. If the conversation covered Stack, Commands, Testing, Boundaries, Status, and References but not Patterns or Gotchas, the checklist surfaces the gap: *"The conversation hasn't covered Patterns yet — does this project have any code patterns Claude Code should know about, or is that section empty for now?"*

Same template, different role. As a starting point it answers "what should this doc contain?" As a checklist it answers "did we cover everything the doc should contain?" Both are valid; pick based on whether the conversation has already done the structuring work.

## Sub-batching for token-budget pressure

Producing six foundation docs in a single session is token-heavy. SKILL.md describes sub-batching as a technique blueprint should reach for when budget is tight or when complexity warrants more attention per doc. The natural split:

**Stack-shaped batch** (produce first):
1. CLAUDE.md
2. docs/ARCHITECTURE.md
3. docs/STANDARDS.md

These three depend most directly on stack decisions and have the most technical content. Producing them first means the human-shaped batch can reference them with real pointers instead of placeholders.

**Human-shaped batch** (produce second):
4. CONTRIBUTING.md
5. README update
6. docs/cbk/blueprint.md

These three depend more on team shape, conventions, and strategic framing. They naturally reference the stack-shaped batch, which is why they're produced after.

In full mode, each batch gets its own HITL gate. In standard mode, both batches collapse into the single foundation-docs gate but the production order is preserved internally. In light mode, sub-batching may not be needed at all if the user only asked for two or three docs.

Sub-batching is orthogonal to the rigor mode dial — a user in any mode can request sub-batching, and a user in any mode can request "all six in one go" if their context allows it. Default behavior: **sub-batch when you have six docs to produce, batch all together when fewer than four**.

## The production pattern

For every doc, blueprint follows the same six-step pattern:

1. **Read the doc's template** (in `references/templates/`)
2. **Extract relevant inheritance** from `scaffold.md` and `problem_brief.md` (the inheritance map below tells you what to pull for each doc)
3. **Read existing content** if any exists in the repo (`README.md` always exists from scaffold; the rest may exist in brownfield mode)
4. **Draft the doc** by adapting existing content into the template structure, or writing fresh from inheritance + stack/methodology decisions
5. **Present inline for HITL review** — show the full draft, ask what's wrong or missing, iterate
6. **Commit via GitHub MCP** to the target location (or downloadable artifact fallback) only after approval

**Step 2 is the load-bearing step.** Doc production that doesn't pull from `scaffold.md` and `problem_brief.md` is doc production that invents context — and invented context contradicts the prior phases. Every template starts with an explicit "what to inherit" section so this step can't be skipped.

**Step 3 matters in brownfield mode.** If an existing CLAUDE.md or ARCHITECTURE.md is present in the repo, blueprint treats it as source material — adapting and standardizing rather than overwriting. Never silently replace existing developer-facing content. If existing content contradicts what blueprint would write fresh, surface the contradiction at the HITL gate and let the user decide.

## Inheritance map per doc

Quick reference for what each doc pulls from inherited context. Full detail in each template's "what to inherit" section.

| Doc | From `problem_brief.md` | From `scaffold.md` | From this phase's decisions |
|---|---|---|---|
| CLAUDE.md | Problem statement (1 line), target user (1 line), no-gos summary | Tool comfort, working conventions | Stack decisions (commands, tooling), methodology (workflow patterns) |
| ARCHITECTURE.md | Proposed approach, current state (brownfield), stack constraints | Quality bar (informs testing strategy section) | All stack decisions go here in full with alternatives, decisions log entries |
| STANDARDS.md | Appetite (informs cycle expectations), no-gos | Quality bar, testing philosophy, PR/review process, decision recording | Methodology (cycle structure), CI gates from stack decisions |
| CONTRIBUTING.md | Target user (informs tone — solo author vs external contributors) | Working conventions verbatim, team shape | Methodology (how to make a change walkthrough) |
| README.md | Problem statement, target user, success criteria summary | Profile (links to project board if any), license | Stack (what to install, how to run) |
| blueprint.md | All sections (carries the full strategic context forward) | All sections (the cascade chain stays unbroken) | Stack decisions, methodology selection, workstreams, dependencies, open questions |

**Working conventions are the strictest inheritance rule.** Branch naming, commit format, and label taxonomy from `scaffold.md` must appear in CONTRIBUTING.md verbatim — same format string, same examples, same wording where possible. Re-deriving them is the most common blueprint bug.

## Tier 2-3 docs (when warranted)

The existing initiative-planner identifies optional Tier 2-3 docs. Blueprint's posture: produce them only when the project genuinely needs them, never by default. The dial pattern applies — if the user wants light mode, six prose docs is already too many.

| Doc | Produce when | Skip otherwise |
|---|---|---|
| STRATEGIC_BRIEF.md | Novel/ambitious project, competitive positioning matters, raising funding | Almost always skip for solo and small-team |
| INTERFACE_DESIGN.md | Project has well-defined external-facing interfaces (APIs, CLI flags, file formats) | Skip if interfaces emerge from code |
| SERVICE_CONTRACTS.md | Project calls external APIs/services with explicit contracts | Skip if external calls are minimal |
| DESIGN_DECISIONS.md / docs/decisions/ | Team uses ADRs (per scaffold.md's decision recording field) | Skip if scaffold said "issue comments and PRs" |
| SECURITY_MODEL.md | User-facing, handles credentials, multi-tenant, compliance requirements | Skip for personal tools and internal experiments |
| DOMAIN_MODEL.md | Business logic is the hard part of the problem | Skip when the domain is mechanical |
| DATA_SOURCES.md | Multiple external data sources with schemas worth documenting | Skip otherwise |

If any of these get produced, they live under `docs/` (not `docs/cbk/` — `cbk/` is for cascade-internal artifacts only).

**ADRs as a special case.** If `scaffold.md`'s decision recording field said the team uses ADRs from day one, blueprint sets up `docs/decisions/` with an ADR template (Michael Nygard's format from the methodology register) and writes the first ADR for the most significant stack decision blueprint just made. If scaffold said "no ADRs yet," blueprint does not set up `docs/decisions/` — that's premature speculation.

## Per-template files

Each prose doc has its own template file in `references/templates/`. Read the template for the doc you're producing:

- `references/templates/claude-md.md` — CLAUDE.md (always-loaded session primer)
- `references/templates/architecture.md` — ARCHITECTURE.md (on-demand subsystem reference)
- `references/templates/standards.md` — STANDARDS.md (quality bar, PR process, CI)
- `references/templates/contributing.md` — CONTRIBUTING.md (new contributor walkthrough)
- `references/templates/readme.md` — README.md update guidance
- `references/templates/tooling.md` — tooling config production guide

Plus the cascade artifact template:

- `references/blueprint-output-template.md` — `docs/cbk/blueprint.md` template with cascade metadata top section

## Failure modes specific to doc production

- **Inventing context instead of inheriting.** Producing a CLAUDE.md that says "we use TypeScript with strict mode" when scaffold and the brief say nothing about TypeScript. Always pull from inheritance — if it's not in the prior-phase docs and not in this phase's decisions, it doesn't go in.
- **Doc bloat.** Producing a 600-line CLAUDE.md because "more context is better." Anthropic's research is clear: CLAUDE.md is always-loaded and competes for attention. <300 lines, <150 is better. Apply the test "would removing this cause Claude to make mistakes?" ruthlessly.
- **Re-deriving conventions.** Writing branch naming format in CONTRIBUTING.md from scratch instead of pulling verbatim from scaffold.md. Scaffold ran the conversation; blueprint just publishes the result.
- **Skipping HITL on individual docs in full mode.** Showing all six docs at once for batch review is light-mode behavior. In full mode, present each doc for review, get approval, then move to the next.
- **Committing before approval.** The MCP commit is one tool call away. That's exactly why the HITL gate must come first. Never commit a doc without explicit user approval at gate time.
- **Producing Tier 2-3 docs by default.** The six core docs are the upper limit unless the project explicitly needs more. Resist doc-creation reflex.

## Light-mode behavior

If the user invoked light mode:

- **Skip docs the user doesn't want.** "Just CLAUDE.md and blueprint.md" gets exactly those two.
- **Batch the HITL gates.** Present all chosen docs together for one combined review instead of per-doc gates.
- **Skip Tier 2-3 entirely** — the only way they appear in light mode is by explicit user request.
- **Tooling configs become opt-in.** Don't produce CI workflow + task runner config + .env.example by default; ask which the user wants.
- **README update is one line** by default — just add the stack info under the existing one-line description.

What light mode *cannot* skip: the inheritance read (every produced doc must still pull from scaffold.md and problem_brief.md), the HITL approval (batched is fine, skipped is not), and the commit-after-approval rule (the safety floor).
