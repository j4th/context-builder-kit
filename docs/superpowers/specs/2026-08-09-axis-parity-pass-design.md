# Axis parity pass — reconciling the kit with its exercised reality

**Date:** 2026-08-09
**Status:** Approved for execution
**Type:** Design spec for evolving `context-builder-kit` itself
**Prior:** harvest 1 (`2026-07-04-…`, PR #4) · harvest 2 (`2026-08-09-cascade-kit-harvest-2-design.md`, PR #5)

## What this is

A four-configuration audit (one read-only auditor per configuration seat: github-issues,
linear, in-repo-markdown, and the knowledge axis) found the kit's execution depth uneven
across the choice matrix — and reconciliation with the reference instance inverted the
diagnosis. The reference instance ran the **entire cascade Linear-native** (the only
exercised full-cascade run in existence) with its knowledge backend configured but
near-dormant. So:

- The **Linear** path is *exercised but under-documented* — its operational answers exist
  in the reference instance and were simply never harvested (the one-way, sanitize-only
  discipline predictably left the operational port behind while the portable principles
  came over).
- The **GitHub Issues** path is *documented-deepest but never exercised* by a real run.
- The **in-repo-markdown** path is partial by design at phase 6, and the harvest-added
  bottom-up lane regressed it (hand-offs that dead-end into a command that config lacks).
- The **producer surfaces** (scaffold/blueprint output templates, `backends.md`'s
  interface half, `.mcp.json.example`) still speak the pre-refactor single-"Profile"
  vocabulary that every downstream *consumer* was already migrated off — each fresh run
  emits a handoff its own consumers classify as drift.

This pass fixes all four, in one PR.

## Governing constraints

Constraints 1 (portability), 3 (sanitized-only), 4 (one-way) carry from the harvests
unchanged. Constraint 2 remains the per-file merit test (harvest-2 revision). One added:

5. **Defer-to-exercised.** Where the kit's design and the reference instance's exercised
   form differ, the exercised form wins by default — it survived contact with reality.
   Escalate to the operator only when the exercised form conflicts with portability or
   best practice. (Operator-set, 2026-08-09.)

## Decisions (settled with the operator, 2026-08-09)

| # | Decision | Outcome |
|---|---|---|
| D12 | Issue-letter convention | **Letters reflect skills; M is frame-local, F is workstream-unique.** `M<#>` labels a milestone inside its frame (frame-local; re-cut milestones may sub-letter, e.g. M6a/M6b). `F<#>` numbers the framing capability issue and **continues across frames within a workstream** so trace IDs stay unique cascade-wide — never restarting per frame. Milestone headings carry both: `### F<#> — M<#>: <name>`. Trace IDs key to F (`[F8.AC1]`, nested `[F8.AC2.1]` permitted); R-issues stay `[<slug>:F<#>:R<#>]`. Exercised by the reference instance; also strictly better practice (uniqueness). |
| D13 | Axis-record canonicity | **scaffold.md's Cascade metadata table is the canonical axis record** (human-readable, exercised); the template also emits `.cascade/backends.toml` as the machine-readable mirror so existing toml-gated behavior keeps working. Consumers read scaffold.md first, toml as fallback. |
| D14 | Notion scope | **No expansion.** The Notion contract stays as designed, labeled honestly as lightly exercised (the reference instance configured it and rarely reached for it — which itself validates read-primary). Wiring gaps (MCP example stanza) are fixed; machinery is not grown. |
| D15 | Markdown positioning | **Design-doc mode, stated at the front door.** No executor parity is built. The no-`/finish` disclosure moves up to scaffold's confirmation gate (where the kit already claims it lives); `/intake` + `/enrich` hand-offs become axis-aware; the markdown issue-record convention they reference is actually defined. |
| D16 | Sequencing | **One PR** (`feat/axis-parity-pass`), atomic commits per cluster. |

## Exercised-vs-designed grid (to be stated in README per P7)

| Configuration | Documentation | Exercise status |
|---|---|---|
| Linear planning | brought to parity by this pass | **Exercised — full-cascade reference run** |
| GitHub Issues planning | deepest | Designed first-class; awaiting first real run |
| In-repo markdown planning | partial by design | Design-doc mode (no phase-6 executor) |
| Knowledge = none | clean everywhere | Effectively exercised (the reference run's daily reality) |
| Knowledge = Notion | complete contract | Configured in the reference run; lightly exercised |

## The clusters

### P1 · Port the Linear-operational executor

`/finish` becomes planning-axis-aware at its planning-backend touchpoints, sourcing the
reference instance's exercised specifics: Step 1 reads the issue via the axis's mechanism
(GitHub MCP / gh CLI on github-issues; the Linear MCP `get_issue` + comments on linear —
never a GitHub read against a Linear ID); Step 3 verifies dependencies the same way;
Step 4's idempotency check recognizes both close-marker families; Step 6 embeds the
planning-backend ID in the branch name (the substring is what fires Linear's auto-link);
Step 10 writes the axis's close marker per `cbk-conventions.md § Closes-keyword
conventions`. The argument convention is documented per axis (`/finish <N>` vs
`/finish <TEAM>-<N>`). The "surprises" section stops declaring the executor
GitHub-only. Bundled template stays byte-parallel. (Note: the reference instance's own
executor retained vestigial GitHub-read prose that its sessions routed around — this
pass finishes the port properly rather than copying the vestige.)

### P2 · Re-template the producers

`scaffold_output_template.md` + `blueprint-output-template.md` Cascade metadata sections
rewritten to the two-axis vocabulary, modeled on the reference instance's exercised
artifact shape: `Planning backend` / `Knowledge backend` / `Hierarchy levels` /
`Cascade artifact layout` rows, plus axis-conditional rows (workspace / initiative /
team key / project shell when linear; hub URL when notion). Worked examples and
light-mode collapses updated; `Profile:` and `initiative.md` vocabulary dies; the
template emits `.cascade/backends.toml` alongside (D13).

### P3 · Reconcile the Linear model + flesh the stubs

Blueprint's planning-backend matrix drops the Project-per-workstream model for the
exercised hierarchy (initiative → project shell per phase → **workstream parent issue**
→ F sub-issue → R sub-sub-issue; the planner's native milestones field deliberately
unused). `scaffold/references/linear_planning.md` and blueprint's Linear section absorb
the exercised provisioning recipe from the reference run's artifacts — initiative + team
+ project-shell creation, the team label set (cascade-depth + area labels), the workflow
settings — marked one-run-exercised and dated. Framing/rough-in commit references get
their Linear paragraphs corrected to the same model.

### P4 · Markdown honesty

Scaffold's in-repo-markdown confirmation gate gains the decisive bullet (no `/finish`
executor; `/intake`/`/enrich` degrade to markdown records; execution = manual Claude Code
against the spec). `/intake` + `/enrich` hand-offs become axis-aware instead of
unconditionally saying "run `/finish <id>`". The markdown issue-record convention is
defined in `cbk-conventions.md § Contribution intake` (location, the eight-section body,
the heading form that doubles as `/enrich`'s argument, a labels line carrying the same
tokens the backends use, graduation = editing that line). Spec/frame templates get
axis-variant lines for the fields that presume issue numbers (Dependencies, PR contract,
meta-issue table).

### P5 · Wiring + vocabulary sweep

`.mcp.json.example`: notion server stanza added (server key matching the shipped hook
matcher), stale "opinionated profile" comments replaced, `enabledMcpjsonServers`
reconciled with the README's claims. The Projects v2 board contract: one canonical setup
statement, internally consistent, honestly marked designed-unexercised where it is (and
dated per the dated-rails principle). `backends.md`'s interface half rewritten to the
two-axis model (malformed matrix fixed; the constant named as the home of cascade-artifact
operations). Stale vocabulary swept: framing's checklist "(Linear+GitHub profile only)",
`initiative.md` references, "Deferred meta-issues" strays in the shared backends.md
copies. Verification greps widened beyond `.claude/skills/` and taught the new
invariants.

### P6 · Lettering alignment (D12)

`cbk-conventions.md § Title-prefix scheme` + `§ Trace ID convention` state the M/F/R
convention canonically (M frame-local; F workstream-continuing; heading form
`### F<#> — M<#>: <name>`; trace IDs key to F). The frame template's milestone block and
the milestone template adopt the heading form and a workstream-F-sequence note; framing's
SKILL.md (numbering guidance, pattern E's retired-AC language) and rough-in's references
align. The existing verification grep for trace IDs keeps passing; a new one checks the
heading form in templates.

### P7 · Alignment sweep — README + kit CLAUDE.md + positioning

README: the pipeline diagram and when-to-use table gain axis caveats; a short
"exercised vs designed" statement per the grid above (dated). Kit CLAUDE.md: repo-layout
tree and § "When the user invokes a skill" already current from harvest 2 — this cluster
trues up the cascade description (M/F lettering, axis-record canonicity, the markdown
positioning) and anything the sweep surfaces. The kit's own docs must pass the same
vocabulary sweep as the skills.

## Verification — definition of done

1. The harvest battery: portability greps (now widened), word-boundary instance denylist,
   hooks `bash -n`, settings valid, `/finish` copies byte-parallel.
2. New positive greps: the scaffold template emits `Planning backend` + `Knowledge
   backend` rows; the frame template carries the `### F<#> — M<#>` heading form; no
   `Profile: <github-only | opinionated>` anywhere; no `initiative.md` references.
3. Reference-instance denylist clean (constraint 3) — the ported material is authored
   fresh and generic.
4. `test_cases.md` updated where behavior changed (finish argument forms per axis;
   template metadata shape; scaffold gate bullet).
5. Every axis-audit blocker resolved or explicitly repositioned (D15); rough edges either
   fixed here or carried to a listed follow-up with the reason.
