# Blueprint failure modes

The adversarial check. Read this list as "things that go wrong in blueprint sessions and how to defend against them." Each failure mode has a defense already encoded in the SKILL.md or one of the reference files — this file collects them in one place so you can review them before any blueprint session and after any failed one.

## The big six

The failure modes that cause the most damage when they happen.

### 1. Skipping inheritance

**What it looks like**: blueprint starts producing foundation docs without reading `docs/cbk/problem_brief.md` and `docs/cbk/scaffold.md` in full. The result is docs that contradict the brief or duplicate decisions scaffold already made. The worst version is a CLAUDE.md that says "we use TypeScript with strict mode" when the brief and scaffold say nothing about TypeScript.

**Why it happens**: light mode pressure ("just give me the docs"), context window pressure ("the files are long, let me just sample"), or impatience ("I can guess what's in them from the conversation").

**Defense**: the inheritance check is the one HITL gate that cannot be collapsed even in light mode. Read both files in full, present an inheritance summary, get user approval before proceeding. Documented in `references/inheritance.md`.

**Recovery if it happens mid-session**: stop, read both files now, present a delayed inheritance summary, ask the user to confirm or correct before proceeding. Any docs produced before reading inheritance must be re-checked against the inherited content and likely rewritten.

### 2. Premature stack lock-in

**What it looks like**: blueprint commits to a stack decision the user hasn't actually agreed to because the brief mentioned it once. The brief said "something like SQLite" as a fat-marker sketch; blueprint reads it as "use SQLite" and writes ARCHITECTURE.md as if the decision was final.

**Why it happens**: brief sketches are easy to mistake for decisions. Detect-then-confirm requires explicit confirmation, but it's tempting to skip the confirmation when the brief seemed clear.

**Defense**: the stack-decisions step requires explicit user confirmation before any decision gets recorded. Constraints from the brief are facts, but **proposals from the brief are still proposals** — they need confirmation. The phrasing "confirming we're going with X based on the brief — sound right?" is mandatory, not optional. Documented in `references/stack-decisions.md`.

**Recovery**: re-open the locked-in decision at the next HITL gate. *"I committed to X earlier without explicit confirmation — want to keep it or reconsider?"* Most users say "keep it" but the explicit reopening is what builds trust.

### 3. Methodology dogmatism

**What it looks like**: blueprint recommends Shape Up because the cascade examples use it, not because it actually fits the user's project. Or recommends Scrum because the team is "agile" without checking whether they want sprint ceremonies.

**Why it happens**: the methodology register is opinionated, and Shape Up appetite-based for solo bursty work is the canonical example. It's easy to default-recommend Shape Up for everything because it's the pattern blueprint sees most often in its own training material.

**Defense**: the methodology selection step requires the recommendation to be tied to *inherited context* with a citation. "Given the bursty solo cadence and per-pack scope discipline you mentioned in the brief, I'd recommend Shape Up appetite-based" is grounded. "I'd recommend Shape Up" is dogmatism. Documented in `references/methodology-selection.md`.

**Recovery**: if the user pushes back on the recommendation, take the pushback seriously. Don't argue for Shape Up; ask what about the user's context made the recommendation feel wrong, and propose an alternative from the register.

### 4. Foundation doc bloat

**What it looks like**: blueprint produces all six foundation docs even when the user only wanted three. Or each doc is 3x longer than it needs to be because "more context is better." The CLAUDE.md is 600 lines and gets ignored after the first session because it's overwhelming.

**Why it happens**: producing docs feels productive. Bloat looks like thoroughness. The temptation to "just add one more section" applies to every doc.

**Defense**: the dial pattern. Light mode is a real mode that should be honored — six docs is the upper limit, not a requirement. Each template has an explicit light-mode section with target line counts. CLAUDE.md specifically has a hard rule: <300 lines, <150 better. Apply the test "would removing this cause Claude to make mistakes? If not, cut it." Documented in `references/foundation-doc-templates.md` and per-template files.

**Recovery**: if a doc is bloated, cut it down. Don't apologize or defend the bloat — just produce a tighter version and present it for review.

### 5. Inventing conventions blueprint should inherit

**What it looks like**: CONTRIBUTING.md has a branch naming format that's slightly different from what scaffold.md said. The format works, but it's been "improved" — `tui-{issue}-{description}` became `TUI-{issue}-{description}`, or the team identifier changed casing, or the example issue numbers got swapped for different ones.

**Why it happens**: when copying from one doc to another, it's tempting to "improve" the copy. Small improvements compound into drift between docs.

**Defense**: the verbatim rule for working conventions. Branch naming, commit format, label taxonomy from scaffold.md must appear in CONTRIBUTING.md (and STANDARDS.md's git workflow section) with the exact same wording, format strings, and examples. Re-deriving them is the most common bug. Documented in `references/templates/contributing.md` and `references/templates/standards.md`.

**Recovery**: if drift is detected, fix the drifted doc to match scaffold.md exactly. Don't fix scaffold.md to match the drifted doc — scaffold is the source of truth for conventions.

### 6. Stack decisions without architecture context

**What it looks like**: ARCHITECTURE.md's Decisions Log says "DECISION-001: Use SQLite. Status: Accepted." with no Context, Options, or Consequences fields. The decision is recorded but the *why* isn't, so future readers (and Claude in future sessions) can't tell whether the decision was deliberate or arbitrary.

**Why it happens**: the Decisions Log format takes effort to fill in properly. Skipping the Context/Options/Consequences fields feels efficient.

**Defense**: every Decisions Log entry needs all four fields filled in. The justification must tie to inherited context (the brief's constraints, scaffold's quality bar, the team's stated needs). Documented in `references/templates/architecture.md`.

**Recovery**: backfill. If a decision was recorded without context, re-open it at the HITL gate, add the fields, and present the corrected entry for approval.

## Minor failure modes

The smaller bugs that don't break the cascade but accumulate friction.

### Decision creep into library-level picks

**What it looks like**: the stack decisions step asks "which logging library?" or "which JSON parser?" Blueprint should pick load-bearing structural choices (database, framework, distribution mechanism), not library-level picks. Library-level picks happen during framing or rough-in.

**Defense**: documented as a failure mode in `references/stack-decisions.md`. If you find yourself reaching for "which library?" questions, you've gone too deep — pull back to the next level up.

### Skipping deferred decisions from the brief

**What it looks like**: the brief's "Notes for blueprint" section listed five deferred decisions; blueprint addressed four and silently dropped the fifth.

**Defense**: the inheritance check explicitly extracts the full deferred-decisions list and the stack-decisions step walks all of them. If any get deferred *further*, they get a trip-wire. Silent omissions are bugs. Documented in `references/inheritance.md` and `references/stack-decisions.md`.

### Producing docs in the wrong order

**What it looks like**: blueprint produces README.md before CLAUDE.md, then has to update the README's Documentation table when CLAUDE.md gets produced later.

**Defense**: the production order in `references/foundation-doc-templates.md` is fixed: CLAUDE → ARCHITECTURE → STANDARDS → CONTRIBUTING → README → blueprint.md. Highest-leverage docs first. Don't reorder without explicit reason.

### Committing before HITL approval

**What it looks like**: blueprint drafts CLAUDE.md, presents it inline, and then commits it to the repo before the user has actually approved. The user reads the inline preview and says "wait, change X" but the commit has already happened.

**Defense**: the commit-after-approval rule, stated explicitly in SKILL.md and every per-doc template. The MCP commit is one tool call away — that's exactly why the gate must come first. Never auto-advance from "presented" to "committed."

**Recovery**: if a premature commit happens, acknowledge it, ask for the requested change, push the corrected version as a new commit. Don't try to amend or rewrite history — a clean correction commit is simpler.

### Fabricating CLAUDE.md commands

**What it looks like**: CLAUDE.md says `just check` is the quality gate command, but the justfile (or whatever task runner the project uses) doesn't define `check`. The first time Claude Code tries to run the command, it fails.

**Defense**: the "every command in CLAUDE.md = actual task definition" rule from `references/templates/tooling.md`. Tooling configs are produced after CLAUDE.md, and they must implement every command CLAUDE.md mentions. If CLAUDE.md mentions a command that the chosen task runner can't reasonably implement, change CLAUDE.md, not the task runner.

### Producing Tier 2-3 docs by default

**What it looks like**: blueprint produces STRATEGIC_BRIEF.md, SECURITY_MODEL.md, and DOMAIN_MODEL.md "for completeness" even though the project doesn't need them.

**Defense**: the "six docs is the upper limit unless explicitly needed" posture in `references/foundation-doc-templates.md`. Tier 2-3 docs are opt-in, not default.

### Ephemeral setup steps in blueprint.md

**What it looks like**: blueprint produces a `docs/cbk/blueprint.md` with a section called "Manual setup runlist" or similar containing the full first-build command sequence — `mise install`, `cargo update`, `gh auth login`, paste the PAT, run setup script, etc. The user completes the steps two days after blueprint runs. Six months later, the section is still there, still says "run these steps to bootstrap" — but the bootstrap is long done. The doc lies; the user has to remember which sections are evergreen and which are stale-ephemeral.

**Why it happens**: the natural place to put "things the user needs to do" feels like the doc the user just produced. Resisting that feels artificial until you've watched a doc go stale.

**Defense**: the seventh-step pattern. Ephemeral one-time setup work goes in the **handoff issue**, which closes naturally when the work is done. blueprint.md gets the **evergreen credential model** (what credentials exist, how they rotate, what scopes they need) — reference content that doesn't go stale because it's not describing actions, it's describing state. Documented in `references/handoff-issue.md` and `references/blueprint-output-template.md` § "Credential model (evergreen)".

**Recovery**: if a blueprint.md run produced a "Manual setup runlist" section before this pattern was in place, restructure it: extract the commands into a handoff issue (post-hoc is fine — same template), and rewrite the blueprint.md section as "Credential model" with the evergreen content only. Don't try to delete the section silently — the user may have already linked to it.

### Missing handoff issue

**What it looks like**: blueprint completes all six prose docs and commits blueprint.md, then ends the session. No handoff issue gets created. The user comes back two weeks later, doesn't remember what they need to do, has to read three foundation docs to reconstruct the runlist — exactly the failure mode the handoff issue exists to prevent.

**Why it happens**: light mode pressure (the user said "keep it light" and the seventh step got collapsed away), or treating Step 6 as optional ceremony rather than as a safety floor.

**Defense**: the handoff issue is non-negotiable in any rigor mode. SKILL.md's "What blueprint should not skip even in light mode" list includes it explicitly. The only valid skip is an explicit user override (*"don't create a handoff issue, I'll manage my own runlist"*) — silent omission is a bug. Documented in `references/handoff-issue.md` § "Safety floor".

**Recovery**: if a session ended without the handoff issue, create it post-hoc as soon as the omission is noticed. The version inventory can still be reconstructed from the committed config files; the body template still applies. Better late than never — the issue's value is "the user has a single surface to come back to" and that value still applies even if the issue is created days after blueprint finishes.

### Bootstrap-gate paradoxes

**What it looks like**: blueprint's stack decisions include installing a CI gate (e.g., `claude-code-action` for PR review). The user later tries to make the commits that *install* the gate go through the gate itself — and discovers it can't, because the gate doesn't exist on the repo until those commits land. Confusion follows: "is the cascade broken? did the skill produce the wrong workflow file?"

The actual situation: the bootstrap commits are correctly exempt from the gate they install. But if the skill didn't surface the exemption at blueprint time, the user has to figure it out under pressure.

**Defense**: when blueprint's stack decisions include adding a new CI gate that didn't exist on day one of the repo, surface the exemption proactively at the relevant HITL gate: *"Installing `<gate name>` means the commits that install it can't themselves be reviewed by it. I'll document this bootstrap exemption in STANDARDS.md so it doesn't surprise anyone later."* Then the STANDARDS.md template includes a "Bootstrap exemptions" section that names the gate, names the commits or sub-batch range, and explicitly says when the post-bootstrap regime starts. Documented in `references/templates/standards.md`.

**Recovery**: if the exemption wasn't documented at blueprint time and the user runs into the chicken-and-egg, write a brief STANDARDS.md update that adds the bootstrap exemption section with the actual commit range. Don't try to retroactively run the bootstrap commits through the gate — they're correctly exempt.

**Common variants**:
- `claude-code-action` review gate: the workflow file install commits can't be reviewed by the action
- New required CI check: PRs that add the check can't be blocked by the check
- New pre-commit hook: the commit that adds the hook can't run the hook
- Branch protection rule: enabling protection means the protection-enabling commit landed without protection

All four follow the same pattern: a gate is installed by a commit; that commit can't be subject to the gate it installs; document the exemption explicitly.

## Planning-backend transition failure modes

These emerged with the github-only commit step (creating Milestones per workstream atomically with the markdown commit). They're specific to the planning-backend half of the cascade transition.

**Partial state on transition failure** — Milestones got created on the planning backend but the markdown commit failed (or vice versa), leaving the cascade in an inconsistent state. Defense: the atomic transition pattern in `references/planning-backend-commit.md` — capture every created Milestone's id during the planning ops, roll back via delete on any failure during either half. Skills implement the transition as one logical operation with explicit rollback paths.

**Slug collisions across workstreams** — two different workstream names that slugify to the same string. The cascade silently creates one Milestone and overwrites or shadows the other. Defense: blueprint validates slug uniqueness in the workstreams table before the transition runs. If two workstreams collide, blueprint refuses to commit and asks the user to disambiguate.

**Slug collisions with existing Milestones (brownfield)** — a re-run of blueprint produces duplicate Milestones because the slug-existence check was skipped. Defense: every workstream's slug is checked against existing Milestones before the create call; existing Milestones get an update (description refresh from blueprint.md), not a create. Brownfield runs are idempotent.

**Project board missing or misconfigured** — blueprint commits Milestones but the Projects v2 board doesn't exist, or its automation rules aren't set up, so the Milestones never appear on the board with proper Status fields. Defense: blueprint queries the board state before the transition runs. If the board is missing or the four standard automation rules aren't configured, blueprint pauses and surfaces the gap with setup instructions instead of silently proceeding.

**Rollback failure** — the rollback itself fails (e.g., MCP returns success on the create but the subsequent delete fails because of a permissions edge case). The cascade is left in a state that the automatic rollback couldn't repair. Defense: blueprint surfaces the inconsistent state explicitly with a manual recovery checklist — exactly which Milestones exist, exactly which markdown is committed, exactly which to delete or commit by hand. The user gets honest information, not silent partial state.

## The general defense

Most blueprint failure modes share a common cause: blueprint doing more than it was asked to do, in the name of completeness or thoroughness. The general defense is **honoring the dial** — light mode means light mode, default means default, and the user's stated preferences override blueprint's defaults.

The exceptions are the safety floors:
- Inheritance must be read in full, even in light mode
- Working conventions must be carried forward verbatim, even in light mode
- Decisions must have justifications, even if the justifications are short
- Commits must follow HITL approval, always
- The three-level constraint (in github-only mode) must be acknowledged at least once

These safety floors are non-negotiable. Everything else is dial-able.

## Pre-session checklist

Before starting a blueprint session, walk through this list mentally:

- [ ] I will read both inheritance files in full before producing anything
- [ ] I will lead with proposals tied to inherited context, not blank-slate questions
- [ ] I will record decisions with justifications, not just decisions
- [ ] I will carry working conventions forward verbatim
- [ ] I will produce only the docs the user asks for, in the documented order
- [ ] I will commit only after explicit HITL approval
- [ ] I will surface gaps in the opinionated profile honestly if that's the profile
- [ ] I will resist doc bloat — every line earns its place

If any item feels uncertain, pause and re-read the relevant reference file before starting.
