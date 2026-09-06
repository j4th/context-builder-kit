# Harvest 3 design — three instances, forty-six issues, one posture

**Date:** 2026-09-06
**Status:** Approved for execution
**Type:** Design spec for evolving `context-builder-kit` itself
**Prior:** harvest 1 (`2026-07-04-cascade-kit-harvest-design.md`, PR #4) · harvest 2 (`2026-08-09-cascade-kit-harvest-2-design.md`, PR #5) · axis parity (`2026-08-09-axis-parity-pass-design.md`, PR #7)

## What this is

The kit last merged on 2026-08-09. Since then two real cascade runs on the two planning axes
the kit had not exercised together — `j4th/echosphere` on Linear (31 merged PRs, 29 ADRs, two
frames) and `j4th/you-are-hear` on github-issues (41 PRs; the first real run on that axis) —
filed every one of the kit's 46 open issues (#8–#53) and repaired the kit locally as they went.
you-are-hear's first PR was a semi-harvest: it fixed the review-gate contradiction, the
eager-import trap, the broken verification suite and the github-axis gaps before its cascade
ran; it then measured three contract-versus-procedure A/Bs and split framing, rough-in and
`/finish` on the strength of them, split three rules files into an always-loaded contract and
a path-scoped reference, and added a roadmap surface, three hooks and an A/B harness.
echosphere added the `/finish` backward sweep (later ported verbatim to you-are-hear), a
frozen-corpus hook, a laws-reviewer pattern, an ADR corrections register and the `Extends:`
relation grain. The private reference instance moved forty commits past the harvest-2 cutoff;
its `.claude/` barely changed beyond reviewer memory, and its cascade documents and two files
no prior pass examined hold the remaining process learnings.

The reading was a 24-agent fan-out (ten issue-cluster readers, fourteen sibling-delta readers)
whose verification stage was authored as one verifier per candidate — the exact defect issue
#10 describes — and was killed by the operator at roughly 15%. All 24 readers' output survived;
three of ten cluster verifications and 15 of 307 candidate verifications completed. The rest was
synthesized in the main session with spot re-checks against the kit tree. A separate
four-agent run fetched 24 first-party and practitioner pages on the Claude 5-series and
re-fetched 80 of its 128 quotes (61 exact, 19 near-verbatim, none absent); the posture in C11
rests on those pages, not on memory. The operator-private working map holds the per-candidate
source pointers; nothing in it is committed here.

## Governing constraints — all five carry

1. **Portability invariant.** No project-specific identifiers in skill, command, rule, hook,
   agent or workflow content; the conventions template carries bracketed placeholders.
2. **Framework-not-tooling, per file on merits** (harvest-2 revision). Configuration and
   scripts that make a policy the kit already mandates runnable ship as exemplars beside the
   existing ones (`.mcp.json.example`, `review-sweep.js`).
3. **Sanitized only.** The private reference instance is never named, linked, or reproduced.
   The two public runs may be named where the open issues already name them; every ported
   learning is re-authored generic, with a neutral illustration where one is needed.
4. **One-way.** The kit changes; no instance is modified.
5. **Defer-to-exercised.** Where the kit's design and an exercised form differ, the exercised
   form wins by default; the operator rules when it conflicts with portability or best
   practice. Where two exercised forms differ, the later one wins unless the earlier one
   states why it must not generalize.

## Decisions (settled with the operator, 2026-09-06)

Numbering continues from the axis-parity pass (D12–D16).

| # | Decision | Outcome |
|---|---|---|
| D17 | `workflows.md` template or portable rule; ADR-0000 placeholders | **Portable rule** — banner dropped, its one optional block stays bracketed. **Placeholders stay** in the shipped starter; scaffold fills Date and Deciders when it instantiates `docs/adr/` and greps for leftovers at its exit. |
| D18 | Instruction-budget split | **Ship pre-split** contract/reference halves for `cbk-conventions.md`, `orchestration.md`, `pr-review.md`. Nested `CLAUDE.md` per workspace tree stays guidance in the blueprint template. |
| D19 | Review gate | **Plain two-skill floor** that must be invoked, sweep supplements; sweep caps **3 per dimension / 8 verified** with the planned agent count logged before the find stage; roster-read failure **degrades to the toolkit dimensions and reports dropped coverage**; launch-root guard is **hard-deny**. |
| D20 | Contract-first split | **All three phases in one change**, weakest evidence last (framing → rough-in → `/finish`), one shared rationale; **ship the A/B harness and the per-agent cost reader** as sanitized exemplars beside `review-sweep.js`. |
| D21 | Orchestration vocabulary | **Tier roles in the contract**; one dated, page-cited generation subsection names the current lineup; the ladder becomes a **model × effort table per role**, and every dispatch names both. |
| D22 | github-issues axis | **`gh` is the documented default interface** (MCP the alternative); **ship the review-automation workflow pair as blueprint templates**; collaborator-facing starters (bug form, feature form, CODEOWNERS) **gated on the team-shape answer**. |
| D23 | After the draft | **No `/land`** (operator ruling, #50). Post-merge steps become an explicit **hand-off checklist** ending in the next runnable command; the measurement-issue variant lives **inside** the spec template. |
| D24 | ADR governance | **Ship a starter `docs/adr/corrections.md`**; fact-sync back-pointers are **asymmetric** (owner declares mirrors, mirrors point home); `adr-new` **defers in prose** to the conventions' sync-target list; **relation slots added** to the ADR template. |
| D25 | Reviewer memory | Clean-review baselines: **append to the existing per-surface baseline unless the review adds a method**; the commit-vs-local choice is a **Surface inventory row** prompted by the bootstrap checklist. |
| D26 | Supply chain & hygiene | **Ship `.github/dependabot.yml.example`**; the **issue-less branch form** `<type>/<short-slug>` with a required PR-body statement; **licence gets a HITL confirm** at scaffold, matching visibility. |
| D27 | Producers | **One "immutable source + append-only companion" vocabulary**; **both** the cascade-events index (scaffold) and the roadmap (blueprint, github-issues and markdown axes) ship; the blueprint critic is **conditional on a drafting fan-out**; the three exercised corrections that contradict kit sentences (milestone-grain charters, docs-only PRs are not automatically light, verdict-first committed corpus with unverifiable-kept) are **adopted**. |
| D28 | 5-series posture | **Adopted**: orchestration restated against the verified pages; the ceiling rule and one-top-tier-agent allowance **kept as labelled policy**; a **scoped prompt audit** over the kit's instruction surface runs inside C4. |
| D29 | Sequencing | **Four PRs**, each closing its issues by marker, atomic commits per item, one dogfooded review sweep per PR: **P1** = C1 + C2 · **P2** = C3 + C8 · **P3** = C4 + C11 · **P4** = C5 + C6 + C7 + C9 + C10. |

## What lands — cluster summary

Clusters are in dependency order; each edits surfaces the next assumes.

### C1 · The kit stops being wrong about itself — closes #13 #14 #15 #16 #30 #40 #45

- `cbk-conventions.md § Verification` rewritten as **two labelled sub-blocks** (kit-repo
  portability checks; target-project checks), every check with a one-line comment saying what
  it catches, a preamble stating that a red check is a defect in the check, a carve-out for
  project-scoped plugin directories under `.claude/skills/`, a **positive check that prints
  the always-loaded rule set and its byte count**, a check that `scaffold.md`'s axis rows
  agree with `.cascade/backends.toml`, and a positive check pinning every "§ Section" a skill
  cites to a heading its producing template emits (#13).
- Blueprint's templates replace every `@docs/…` import with a backticked mention plus a
  named warning quoting the memory docs (eager at launch), at all five sites including both
  in `foundation-doc-templates.md` (#14).
- `logging.md` and `testing.md` ship with bracketed `paths:` placeholder globs and the
  budget check catches a placeholder left in; the mechanism is documented in the conventions
  and the README's customization list (#15).
- Scaffold's bootstrap checklist gains a **fill-or-delete pass** over every template rule and
  every defaulted-but-decidable choice, printing the always-loaded size first; a filled
  template opens with a one-line provenance note and records choices by appending under the
  template prose (#16, with D17).
- Linear "individually unexercised" flags restamped generically ("a second real run,
  2026-08-12/13"); the write-into-existing-initiative flag stays; scaffold and blueprint gain
  the phase-exit checklists they lack, designed together with the fill-in prompt (#30).
- Scaffold gains an explicit "instantiate and fill the shipped `docs/adr/` starters" step
  with an exit grep (#40, D17).
- The scaffold-shipped rough-in issue template gains `## Assumptions`; the executor's
  parser is named the single authority for the heading list and every restatement is checked
  against it mechanically (#45).
- Four live framing-skill defects fixed in passing: the phase-exit checklist quotes the
  sentinel string rough-in matches on verbatim; the rigor-mode text that adds a research
  track the scope rule forbids is deleted (and its reference-index line); skill descriptions
  name cascade objects, never one backend's entity; stale counts in preambles replaced by
  count-free wording or a grep target. Test cases re-read for path coverage when a default
  path changes.
- An axis set to `none` is de-wired as a set — rule, hook, settings stanza, every index that
  lists them — with an inline note naming the restore condition.

### C2 · Route the instruction budget — closes #53 (D18)

- `cbk-conventions.md`, `orchestration.md`, `pr-review.md` ship as **contract + reference**
  pairs: the contract keeps what an agent must obey in ordinary work; the reference carries
  verification, calibration tables, traps and applied instances under a `paths:` block
  (bracketed globs). Every moved heading stays in the contract as a one-line pointer (file
  and section only); the reference half's load trigger is stated once.
- Split by **when the content is needed**, never by length; the two shapes of path-scoping
  (whole-file for one-trigger rules; contract/reference for mixed) are stated in the
  conventions. A short agent-facing rule may point at an operator runbook (C10).
- Rationale recorded with its verified basis: every non-fork custom subagent loads the full
  `CLAUDE.md` hierarchy and every unscoped rule, so a fan-out multiplies rule weight by its
  width.

### C3 · The review gate is a floor, the sweep is bounded, memory does not fork — closes #8 #9 #10 #11 #12 #44 #48, #47 items 3–4 (D19)

- **Rules rewrite, one commit, four surfaces swept** (`pr-review.md`, `commands/finish.md`,
  the bundled `finish-command.md`, the sweep's meta): the two skills are a floor that must
  actually be invoked; the sweep supplements and never substitutes; the hard-fail carve-out
  goes; a `## Review gate` PR-body block (one line per skill and for the sweep, run-or-not
  with counts, a waived skill recorded with its break-glass reason) — a body without it reads
  as un-reviewed; proportionality to the diff, session effort never overriding it; the floor
  runs once, before the draft, and later deltas belong to the reviewer round; the break-glass
  marker waives exactly one named half. The finder prompt keeps asking for every finding —
  the docs' own review guidance — and the bound lives at dedup and verify.
- **Script rewrite, one commit**: a Roster phase reads `pr-review.md`'s roster through a
  cheap structured agent (no mirror; fail → run the toolkit dimensions and report dropped
  coverage); collect across dimensions, dedup on file:line:normalized title carrying the
  corroborating dimensions, rank by severity, cap at 3 per dimension / 8 verified, return
  overflow as unverified, log the planned agent count before the find stage; a half-filled
  record from a failed verifier is dropped coverage; the retry pass escalates effort; the
  run returns its own record so the audit block is transcribed. Meta and final log line say
  "supplements, never substitutes".
- **Two hooks + settings**: `require-repo-root-for-agents.sh` (PreToolUse on Agent and
  Workflow, hard-deny outside the git top-level) and `detect-forked-agent-memory.sh` (Stop and
  SubagentStop, exit 2 while a stray tree exists, loop-guarded, header noting the harness
  overrides a Stop hook after eight consecutive blocks). The settings registry states **four
  enforcement tiers**: hard-deny, ask-gate, advisory, stop. Hooks are verified by piping
  crafted payloads and asserting every branch; a state-reading guard judges a compound
  command on the state at entry, so branch creation and first commit are separate calls.
- Reviewer craft riders: hand-offs name the other owner inline; a reviewer lacking a tool
  reports unverifiable, never a confirmed absence; path-matched trigger globs are derived
  from where the reviewed API is used; a skill that ran without its own fan-out counts as
  invoked, not covered (a dispatched agent cannot dispatch).

### C4 · Contract-first cascade, explicit orchestration defaults — closes #41 #42 #43 #34 (D20, D21)

- **Framing, rough-in and `/finish`** each become a `contract` (default read: what the
  artifact must contain and the tests it must pass) plus a `procedure` (the step-by-step, on
  demand), `SKILL.md` reduced to routing, inputs, rigor modes and the rules no mode may skip.
  The framing contract is lifted from the exercised copy (greps clean); the rough-in and
  executor contracts are de-projected at three hedged lines; the bundled executor template
  and the live command are edited in the same change with the drift check kept.
- Contract content the split carries: **verify before the gate** (one fresh-context verifier
  at the verify tier); the middle gate carries the whole verified set plus a **decision list**
  of every question a removed gate would have asked, paired with the draft's choice; the
  drafter returns a manifest besides the artifact; **the artifact carries no run material**; a
  **coverage map** proves every milestone criterion has one owning issue; criteria numbered
  `[R<#>.AC<m>]` citing `[F<#>.AC<n>]` with test tags keyed to them; the dependencies section
  carries identifiers only; one-way doors are held in the main loop after the gate; a
  project-level overrides section names the knobs a project may set; the executor names its
  inputs read-in-full, closes with the tests every finish must pass, and treats a claim the
  diff contradicts as a defect.
- **Orchestration**: every dispatched agent names its model tier **and** its effort; the
  default for a worker is a chosen level, stated (omitting effort is `high`); cascade-artifact
  drafting is workhorse-tier and the mid tier drafts only what a verifier checks before it
  lands; tier by who catches the agent's mistakes; generation-scoped advice lives in a fenced,
  dated subsection; "never delegate the decision" replaces the harvest-1 "gather, don't
  delegate" sentence; judge panels take an even number of judges, half per reading order, and
  never rank alone; junk structured output is a script-side validation problem; a suspended
  host stalls a fan-out silently, so runs record their id and resume.
- **Harness exemplars** beside `review-sweep.js`: a two-arm A/B workflow (worktree isolation,
  anonymised arms, balanced judges, an operator brief converting each gate into a recorded
  decision) and a per-agent cost reader that attributes spend to the answering model and never
  folds an unpriced model into a total as zero (price table self-dated in its header).
- **Prompt audit**, scoped: pressure language, step choreography for judgment tasks, blanket
  tool defaults and self-check prose across skills, commands, agents and rules — per-step
  calibration, not a blanket de-prescription (C11).
- Recorded honestly: #41's own decision rule required a rank win in both phases and `/finish`
  tied; the split is adopted on the order-independent measures and consistency.

### C5 · The github-issues axis — closes #19 #20 #21 #35 #36 #39 #46 #52, #50 (c) (D22)

- `scaffold/references/github-starter-templates.md` with the literal bodies: issue forms that
  apply provenance and holding labels at creation and tell the reporter the issue is not yet
  executable; a PR template carrying the review-gate and triage blocks empty; CODEOWNERS as a
  routing declaration; a CI stub with the promotion traps at its site; `config.yml` keeping
  blank issues enabled; `dependabot.yml` with the release-age floor per ecosystem (with C9).
- The required-checks trap rewritten as one symptom with three causes; the kit's
  ADR-immutability workflow ships without a path filter and with a pinned job name, reasons at
  the site; scaffold creates a ruleset over `gh api` when a scoped token exists and reads the
  check context off a real run; `manual_steps.md` scoped against tool availability and
  preference, never against detection state.
- `blueprint/references/templates/roadmap.md` emitted on the github-issues and markdown axes:
  dependency-ordered table, a *Now* paragraph, the `gh` queries, its mutation class stated in
  its first line (freely mutable, not the audit trail); framing reads it as input and writes
  rows in the same atomic commit as the frame; `/finish` flips the row on the PR's own branch
  as the last commit before the PR opens, predicting the number from the shared sequence and
  correcting on mismatch, with no CI-skip marker; the cascade-artifact ban carves out status
  surfaces.
- The label taxonomy scaffold creates in full, as an axis structure (cascade depth,
  awaiting-cascade-work, provenance, type, workstream, meta, review-control).
- Scaffold's PR/review question names its consequence and offers "solo-merge with automated
  review"; blueprint surfaces the skip as a notice; the handoff-issue line becomes conditional.
- A `gh` column at all three planning-backend commit phases with the create-then-edit
  placeholder pattern run as one script; phase skills read and write the working tree by
  default and treat a git-host MCP as one connection among several.
- `blueprint/references/templates/claude-review.yml` and `claude.yml` with the project block
  bracketed and seven authoring constraints at their sites: cannot review the PR that
  introduces it; no author-controlled input interpolated; a job timeout; the posted artifact
  is the deliverable in both directions; label-driven proportionality that does not re-fire on
  push; permissions scoped to the job; no orphanable sub-dispatch.

### C6 · After the draft opens — closes #47 items 1–2, #50 (a)(d), #51; adds the backward sweep (D23)

- `/finish` contract: an assumption about a mechanism is confirmed by exercising the mechanism
  the work will use; an environment blocker is reproduced outside the framework and reported,
  never worked around on the operator's machine; a spike-shaped issue's unit of work is the
  filled rows, with run-forced fixes on the same branch, one commit each; the PR body is the
  audit surface for the PR's whole life, with a delta-triage block appended by `/pr-respond`;
  close markers name every issue the run resolves.
- **Backward sweep** beside the roll-forward in both executor copies: after the landing,
  re-read the closed candidate set (open sibling issues under the milestone) for claims the
  landing falsified; each candidate is verified by running the body's own command, testing
  what the claim asserts, separating falsified-by-landing from false-when-written, and
  defaulting to not reporting; the repair is the in-place body refresh the kit already ships.
- A **measurement variant** inside the spec template: verdict rule committed before any
  number exists, findings table frozen against the base branch, rows as value / method / date,
  a by-hand completeness checker that never runs in the CI gate, commit order as evidence.
- The hand-off ends with a post-merge checklist (sync and prune, post the drafted
  roll-forwards, close the metas, append the frame's rough-in-events row) and the next
  runnable command; a research milestone's capstone is the verdict artifact, owned by name.

### C7 · Decision records, corrections, facts stated more than once — closes #17 #18 #29 #37 #26 (D24, D27)

Ordered: `Extends:` → corrections register → "blueprint.md is not an index" → configurable
sync targets → the general rule → the frozen-corpus pattern.

- `Extends: ADR-NNNN (Dn, …)` as a fourth grain (parent fully binding, child adds an
  obligation), with the disambiguation test; the conformance reviewer treats an extending
  child as an additional contract; the ADR template gains a slot per grain; the index status
  cell carries the grain and parent inline; a clause-scoped supersession annotates the
  parent's **index row** while the file stays untouched.
- **Starter `docs/adr/corrections.md`**: freely mutable, append-oriented, never touches a
  Decision, each entry typed by genre (wrong when written / right then stale / orphaned
  attribution / defective formula), evidence classed and annotated when its meaning goes
  stale, reachable from the index footer and the always-loaded file; the immutability hook's
  block message points at it.
- **One companion vocabulary** in the conventions — immutable source plus append-only
  companion — instantiated by ADR corrections, the frozen pre-cascade corpus with its errata
  (`consultation/references/frozen_corpus_ingestion.md`, a `Promotes:` field for decisions
  lifted from the corpus, the ADR-pattern enforcement: hook plus CI job with a block message
  naming the amendment surface), and companion design docs with dated correction blocks.
- `## Multi-surface facts` stated once, ADR index sync its first instance; asymmetric
  back-pointers; a re-check trigger reachable from the line that fires it; closed sets
  machine-maintained where the tree can; a drift-guard test whose subject is the consistency
  itself, named in `testing.md`.
- `adr-new` defers to the conventions for sync targets, states no count, names one surface
  canonical on drift, and stops treating the append-only blueprint stack table as an index.
- A reference-register row in the mutation table; a consultation-side phase-handoff-notes
  companion addressed to each later phase by name.

### C8 · What reviewers write down, and how hooks are authored — closes #25 #49, #48 rule half (D25)

- A `## Writing memory` section in every shipped reviewer, with a drift guard comparing the
  copies to each other: every claim about the tree dated and branch-named (an undated negative
  claim is the most dangerous thing a reviewer records); every entry names what would falsify
  it as a runnable command; the index line never lags the body; repairing a false memory is
  part of the review that found it; a clean review earns a new file only when it adds a
  method; the entry shape (typed filename prefix, frontmatter summary, how-to-apply, retire
  condition, cross-links); dependency facts and findings-with-dispositions as kinds; a
  per-surface living record with a compaction rule; a calibrating precedent promoted back into
  the rule.
- `pr-review.md § Reviewer precedent memory` says `memory: project` versus `memory: local`,
  the 200-line / 25KB prompt budget, and the auto-memory dependency; the choice is a Surface
  inventory row prompted by the bootstrap checklist; memory updates ride the commit the review
  produced; a throwaway tree's baseline carries its expiry.
- Reviewer authoring: the laws-reviewer archetype beneath the decision-text reviewer,
  grep-first checklist items, standing refusals with their sanctioned alternative, a reviewer
  as the complement of a CI grep, stated coverage gaps, report-never-propose, two drift
  tripwires (roster entry, memory directory), eviction conditions for guard lists.
- Hook authoring shape stated once (header, stdin/exit contract, fail-open clause with its
  backstop, project-relative paths); the mutation table and the hook registry as two views of
  one list; exemplar stanzas shipped commented out; settings comments carrying mechanism,
  dated source, prerequisites, canonical command; an axis-conditional guard stays registered
  and inert; an edit-time analyzer under the advisory contract.

### C9 · Supply chain, hygiene, the issue-less branch, the licence — closes #22 #23 #24 #31 #32 (D26)

- Settle-window: age is necessary, not sufficient; toolchain pins take the floor by hand with
  the settled age in the commit; inactive ecosystem stubs carry the floor; metadata-only
  lockfile diffs are discarded; a self-merge rule for bot PRs; behaviour deltas in security
  bumps accommodated narrowly. `.github/dependabot.yml.example` shipped.
- `.gitattributes` turns off the git host's generated-file collapse for every audited
  lockfile; anchored ignore patterns with any-depth entries marked deliberate; harness
  transients ignored by anchored path.
- `<type>/<short-slug>` with a required PR-body statement and a scope fence back to the intake
  lanes; what stands in for the floor on such a PR is written as "not run" in the gate block.
- Licensing section: a recorded choice including "none yet — all rights reserved", the
  relicensing constraint at the second contributor, third-party asset licences; scaffold
  confirms the licence the way it confirms visibility.
- MCP config committed with env-var references plus an example env file; servers wired by
  the phase that justifies them; list-valued keys never repeated in the local settings file;
  linter exclusions only where nothing could be actioned; money and agent-run quota named
  separately in the cost discipline.

### C10 · What the producing phases learned to emit — closes #27 #38 #28, template halves of #26 #35 (D27)

- `scaffold/references/templates/cascade-events-index-template.md` created by scaffold: table
  plus phase notes, a non-cascade-surfaces table, execution facts per phase note, the next
  runnable command; the two appenders' entry shapes reconciled.
- Blueprint: canonical home per shared artifact before drafting and a cross-document critic
  on five axes, conditional on a fan-out; an append-only amendments section; a
  retired-justifications table; the credential model extended to credentials not yet held; a
  numbered PR lifecycle; a newcomer-traps section gated on tool comfort; a source-precedence
  order over non-cascade documents; an operator-runbook directory as a fifth foundation
  surface for repo-executed procedures; a domain label with a body contract.
- Framing template: a status column separating deferred metas from framing-time checks;
  absorbed-issue disposition (completed, not cancelled); hard edges versus soft consumes-edges;
  prior verdicts bind; numbered rough issues naming their criterion; out-of-scope entries with
  reason and owner or reopen condition; re-sequencing pre-authorized; interface commitments
  numbered continuously and amendable with a dated note; findings marked as the grounding
  corpus with single-probe items flagged; deliberate non-decisions; a meta-issue names what
  does not land in it; orphaned obligations placed and recorded; **charters at two blast
  radii** (workstream-wide stays a pre-flight meta; milestone-wide becomes the first R-issue).
- Research phase: verdict-first committed corpus; three verdicts with unverifiable kept and
  labelled; verification targets the specifics (embellishment, not invention); a gaps block,
  attempted-URL log, refutations by consequence, usable-versus-raw counts, reproduction as the
  strongest check, interface over prose; a spec-verification stage (format, grounding,
  coverage) before the one-way commit; one research agent on the executor's own contract; a
  design doc's grounding line and anticipated-wrong-fix note; out-of-scope split into deferred
  and unverified; no-regression criteria name every reason; telemetry verified at its sink.
- Tooling: the built-in LSP tool first-line, wired by a project-scoped plugin where no official
  one exists; a section shape for automated review on the git host; a deferred-integrations
  table with trigger and expiry; a read-versus-write boundary per data integration; a fourth
  spike outcome (retired as unsatisfiable); a labour axis with the default lane unlabelled.
- Review of documents: a docs-only PR is not automatically light where the docs are one-way
  doors.

### C11 · The 5-series, per tier, without assuming Fable (D28)

Sources: Anthropic's platform docs (models overview, effort, cost optimization, model
choice, the Opus 5 / Sonnet 5 / Fable 5.1 prompting guides, skills best practices), Claude
Code docs (sub-agents, model config, memory, hooks, best practices, costs, workflows, skills),
the model-and-effort blog (July 2026) and three engineering posts; 39 practitioner findings
recorded as unverified. Verified deltas against the orchestration rule, each restated with a
dated citation to its page:

- Omitting effort is `high`; the docs say set it explicitly and name subagents as the
  canonical `low` use case; subagent effort frontmatter inherits the session. **Every dispatch
  names model and effort; a worker gets a chosen level.**
- The subagent model resolution order reversed in v2.1.251 (per-invocation → frontmatter →
  env var → main model); `CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1` (v2.1.257) applies one model
  everywhere — a structural lever for a tier ceiling. The order becomes a dated rail.
- The built-in Explore agent is capped at Opus on the Claude API; the kit's "no platform-side
  tier" parenthetical goes; the `model: haiku` override is endorsed by the page.
- The Agent tool fails at 20 concurrent subagents (configurable; ultracode exempt); the
  Workflow runtime allows 16 concurrent, 4,096 items per call, 1,000 agents per run, warns
  above 25 agents or 1.5M projected tokens, and honours `workflowSizeGuideline`; deterministic
  caps exist (`CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`, `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS`,
  `max_budget_usd`, 2.1.217+); task budgets are unsupported on Claude Code. "Let the runtime
  queue the excess" and "set a budget directive" go; the caps are named.
- Economics per completed task, not per token (prices step 2× / 2.5× / 2×; effort is often
  the better lever than switching models; the documented ladder is Opus 5 → higher effort →
  Fable 5.1; re-running failures at higher effort); the ladder's "large cost multiple" goes.
- Cost terms the rule lacked: every non-fork subagent loads the full `CLAUDE.md` hierarchy
  and every unscoped rule; fan-out cache sharing requires identical model, effort, agent type,
  tools, schema and working directory; a low-effort subagent cannot ask and prefers to; at low
  effort Fable searches less — search and research roles never run at `low` on it.
- Per-role standing defaults recorded once, re-swept on a model change (effort names do not
  correspond across models; match by observed thinking length).
- **The verification line**: self-check prose ("use a subagent to verify", "double-check")
  over-verifies on Opus 5 and is removed from the kit's commands; an independent agent that
  sees only the artifact and the rubric — find, then verify, then triage with the finder asked
  for everything — is the architecture the docs recommend, and is what the kit's verify stages
  are.
- Prescription calibrated: specificity matched to fragility and variability; `SKILL.md`
  bodies under 500 lines (kit maximum today 476); skills tested with every model they will run
  on; "If in doubt, use [tool]" defaults rewritten as conditions in `tooling.md`.
- Mechanisms recorded: memory scopes `user` / `project` / `local`; the 200-line / 25KB memory
  prompt budget; auto-memory dependency; skill frontmatter `model` / `effort` / `context: fork`
  with `${CLAUDE_EFFORT}`; PreToolUse on `Agent` and `Workflow` with allow / deny / ask /
  `defer` and `updatedInput`, `ask` forcing a prompt even in auto mode; Stop hooks overridden
  after eight consecutive blocks; background as the interactive default.
- The multi-agent research post is cited dated (June 2025, 4-series: 90.2%, 4× and 15×);
  agent teams add ~7× per Claude Code's cost page.
- The ceiling rule and the one-top-tier-agent allowance have no first-party support and stay
  as labelled policy with their reason; a per-task cost comparison sometimes argues the other
  way and is recorded beside them.

## Sequencing — four PRs (D29)

| PR | Clusters | Closes | Why this order |
|---|---|---|---|
| P1 `feat/harvest-3-p1-self-consistency` | C1, C2 | #13 #14 #15 #16 #30 #40 #45 #53 | Every later cluster edits the split surfaces and the repaired verification block |
| P2 `feat/harvest-3-p2-review-gate` | C3, C8 | #8 #9 #10 #11 #12 #25 #44 #48 #49, #47 (3–4) | The floor and the sweep are what P3's contracts cite; the reviewer bodies change once |
| P3 `feat/harvest-3-p3-contract-first` | C4, C11 | #34 #41 #42 #43 | The contracts point at the orchestration tiering; both land together |
| P4 `feat/harvest-3-p4-axes-and-producers` | C5, C6, C7, C9, C10 | #17–#24 #26–#29 #31 #32 #35–#39 #46 #47 (1–2) #50 #51 #52 | Independent of each other; each assumes P1–P3's surfaces |

Each PR: atomic commits per cluster item with Conventional Commits messages naming the
issue; the harvest battery (below) green before the draft; one dogfooded review sweep per PR
with its triage recorded in the PR body; `Closes #N` markers in the body.

## Non-goals — explicitly NOT harvested

- The demonstrable-output toolchain and its house-style craft (harvest-1 D5, re-confirmed
  twice); the per-milestone "demonstrable moment" field stays out with it.
- Domain reviewers and their content (the audio validity guard, the protocol laws, the data
  modelling reviewer) — only the reviewer *patterns* above.
- Any de-templating fill (a project's own globs, labels, package paths, stack sections).
- A `/land` command (D23).
- Nested `CLAUDE.md` files as shipped artifacts (guidance only, D18).
- Version-specific platform quirks beyond the dated rails C11 names.
- Any reference to the private reference instance, anywhere in kit content.

## Verification — definition of done

1. The repaired verification suite is **green on the kit's own tree** (both sub-blocks), and
   the always-loaded byte count it prints is lower than before P1.
2. Portability greps (C1's repaired set, with the plugin-directory carve-out) and the
   private-instance denylist are clean on every PR.
3. `/finish`'s command and the bundled `finish-command.md` byte-parallel after every PR; the
   executor's eight-heading list and every restatement agree by the mechanical check.
4. Hooks pass `bash -n` and the crafted-payload dry-run for every branch; `settings.json`
   valid; the four-tier registry comment matches the array.
5. `test_cases.md` updated wherever a skill's default path changed (framing, rough-in, the
   contract-first cases; scaffold's fill-in pass; blueprint's critic).
6. Every citation added by C11 resolves to a page that carries the quoted text; every
   generation-scoped claim carries its date and re-check trigger.
7. Each of the 46 issues is closed by a PR marker or explicitly repositioned in the PR body
   with the reason.
