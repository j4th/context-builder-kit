# Harvest 3 — P3: contract-first cascade, explicit orchestration defaults — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Land P3 of harvest 3 — cluster C4 (the three producing phases become contract-first; every dispatch names its model and its effort; the A/B harness and the cost reader ship as exemplars; a scoped prompt audit) and cluster C11 (the orchestration rule restated against the verified 5-series pages, dated) — as one draft PR that closes #34 #41 #42 #43.

**Architecture:** Framing, rough-in and `/finish` each split into a **contract** (`references/contract.md`; for the executor, `.claude/commands/finish.md` itself), a **procedure** on demand (`references/procedure.md`; `.claude/commands/finish-procedure.md`), and a `SKILL.md` reduced to routing, inputs, rigor modes and the rules no mode may skip. The procedure is the current step-by-step text **moved**, not rewritten; the contract is lifted from the exercised copy and de-projected at the lines this plan names. The orchestration rule's contract half gains the explicit workhorse default, the cascade-drafting row, the delineation test, the explicit-effort rule and a dated generation subsection; its reference half gains the reversed resolution order, the dated applied instances, the cost terms and the re-verified sources. Two harness exemplars land beside `review-sweep.js`. Every platform claim carries a dated page citation; every fan-out in this plan is bounded and its count logged first.

**Tech Stack:** Markdown (skills, commands, rules), one ES-module workflow script plus a stub harness (`node`), one Python script plus a fixture (`python3`), `bash`, `git`, `gh`. The verification suite is the bash block in `cbk-conventions-reference.md § Verification`.

**Spec:** `docs/superpowers/specs/2026-09-06-cascade-kit-harvest-3-design.md` — § C4 and § C11 (both read in full before Task 1), § Governing constraints, § Sequencing (D29), § Verification.

## Global Constraints

Copied from the spec and the standing decisions; every task's requirements include this section.

- **Sanitized, one-way.** The private reference instance is never named, linked or reproduced (its directory name starts with "cre"); the two public runs are not named in kit content; no absolute `/home/…` path lands in a committed file. Sibling repositories under `../` are read, never modified. Every A/B rationale that lands in the kit carries **dates, counts and measures only** — never a repository name, an issue number, a workstream name, a package name or a run id.
- **Portability greps are the hard gate.** The verification block in `cbk-conventions-reference.md § Verification` (kit sub-block) must be green after every task; run it with the extraction below. No project-specific identifier leaks into skill content; rule files stay in the template register (bracketed placeholders, dated observations for platform claims, no cost tables).
- **Never commit on `main`; branch and first commit in separate tool calls** (the default-branch guard judges a compound command on the branch at entry). No `[skip ci]` on any commit. One atomic commit per task; Conventional Commits messages; `Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>` trailer.
- **Bounded fan-outs.** Any agent dispatch in this plan logs its planned count first; never one verifier per item; ≤ 25 agents per workflow for this operator; the review pass reuses P2's shape (the floor's two skills, once, plus the bounded sweep).
- **No unsourced platform claims.** Every normative statement about Claude Code or the Claude API added by this plan cites its page and section with the fetch date (`2026-09-05` for the harvest's research run). Claims the research could **not** quote verbatim are omitted, not paraphrased: the ultracode exemption from the Agent tool's concurrency limit; a first-party endorsement sentence for the fresh-context-verifier architecture (only a section heading and a caution exist — cite the shape as the kit's, not as a page's recommendation).
- **The verification suite.** Extract and run it from the repo root:

  ```bash
  awk '/^## Verification/{p=1} p' .claude/rules/cbk-conventions-reference.md \
    | awk '/^```bash/{c=1;next} /^```/{c=0} c' > /tmp/claude-1000/cbk-verify.sh
  bash -e /tmp/claude-1000/cbk-verify.sh
  ```

  It must print `verification: kit sub-block complete` and `verification: done`. New checks are plain lines inside the single fence; must-be-absent checks use the `absent` helper (line ~414) and split their own literal (`fallbac[k]`) so the check never matches itself; positive chains are wrapped `{ a && b; } || { echo …; exit 1; }` because a bare `a && b` is exempt under `set -e`.
- **Line-number anchors** in this plan were read on 2026-09-06 at the P2 head (`a3dfd2a`). Before every `sed -n` extraction, confirm the heading at the range's first line with `grep -n '^## '`; if the tree moved, re-derive the range from the headings named, never from the numbers.
- **Every `SKILL.md` body ends under 500 lines** (`platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices` § Progressive disclosure patterns, fetched 2026-09-05); the kit's largest today is rough-in at 476.

## Decisions taken while planning (recorded for the PR body)

- **D-P3-1 — the executor pair is provisioned together.** The exercised copy's bundled template carries the contract only ("a fresh repo … can fetch the procedure from the kit"); its contract then points at a `finish-procedure.md` the target project does not have. The kit provisions **both** halves from two bundled templates (`references/finish-command.md`, `references/finish-procedure.md`), each byte-parallel with its command, with drift judged per file. A departure from the exercised form, for portability; recorded in the PR body.
- **D-P3-2 — where the A/B evidence lives.** The three A/B observations (framing 2026-09-01, rough-in 2026-09-02, `/finish` 2026-09-03) and the all-top-tier measurement (2026-09-01) land in `orchestration-reference.md § Applied instances` as *kit-shipped dated observations* above the project's own bracketed placeholder — sanitized per the constraints — and every "why contract-first" paragraph in a skill cites that section, not a repository.
- **D-P3-3 — the generation subsection is short and lives in the contract half.** `orchestration.md` gains `### Generation notes — verified 2026-09-05` (the lineup, the aliases, the documented ladder, the price steps as ratios, the no-dial model, the two 5-series behaviours that change tiering, and the per-role standing defaults table). Depth — the cost terms, the sources table — lives in `orchestration-reference.md`. Always-loaded growth is budgeted at ≤ 4 KB and printed by the block.
- **D-P3-4 — effort per role.** Finders in the sweep run at `medium` and retry at `high` (the Opus 5 recommendation to "use `low` and `medium` liberally … wherever your evals show quality holds", `effort` § Recommended effort levels for Claude Opus 5; the verify stage is what catches a finder's misses); verify stays `high`; the roster reader is Haiku and states that it has no dial; the three shipped reviewers pin `effort: high` because a direct dispatch (no orchestration surface) has no verify stage behind it.
- **D-P3-5 — the ceiling rule and the one-top-tier slot stay, labelled.** No first-party page supports either; the platform's own ladder runs the other way (Opus 5 → higher effort → Fable 5.1). Both are kept as project policy with the reason and the counter-argument beside them; the slot may be the main loop or one fresh-context agent; `workflows.md` says "never delegate the decision".
- **D-P3-6 — the roadmap clause waits for P4.** The exercised executor contract's item 8 flips a roadmap row on the branch; the kit ships no roadmap until C10 (P4). The clause is dropped here and P4 adds it when the roadmap lands (hand-off note in the PR body).
- **D-P3-7 — `tooling.md` has no "if in doubt" defaults today.** The spec's rewrite is already true (every section ends in a conditional decision rule); the plan adds the guard and records the finding.
- **D-P3-8 — the worked examples stay.** The regex/tmux framing fixture and the Rust rough-in fixture are kit-native (byte-identical in the kit before this PR); they move into the procedures unchanged. Not new debt from the split.
- **D-P3-9 — the prompt audit runs at execution time**, through the bundled `claude-api` skill's `prompt-audit` subcommand, on the scope and calibration Task 7 fixes; the plan cannot pre-compute its findings, so it fixes the decision rule per pattern and the exclusions instead.

---

### Task 0: Branch from the P2 head; commit this plan; baseline

**Files:**
- Create: `docs/superpowers/plans/2026-09-06-harvest-3-p3-contract-first.md` (this file)

**Interfaces:**
- Produces: the branch `feat/harvest-3-p3-contract-first`, stacked on `feat/harvest-3-p2-review-gate` (PR #55); the baseline always-loaded byte count for the PR body.

- [ ] **Step 1: Confirm the base**

Run: `git switch feat/harvest-3-p2-review-gate && git log --oneline -1`
Expected: the P2 head (`a3dfd2a …` at planning time; if PR #55 gained commits, the newer head — note it).

- [ ] **Step 2: Create the branch (its own tool call)**

Run: `git switch -c feat/harvest-3-p3-contract-first`

- [ ] **Step 3: Baseline the suite**

Run the verification block per Global Constraints.
Expected: green; note the `always-loaded total:` line (113,263 bytes at planning time) for the PR body's budget table.

- [ ] **Step 4: Commit the plan (separate tool call from Step 2)**

```bash
git add docs/superpowers/plans/2026-09-06-harvest-3-p3-contract-first.md
git commit -m "docs(plan): harvest 3 P3 — contract-first cascade, explicit orchestration defaults (C4 + C11)

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 1: Framing — contract, procedure, compact SKILL.md, test case 7

**Files:**
- Create: `.claude/skills/framing/references/contract.md`
- Create: `.claude/skills/framing/references/procedure.md`
- Modify: `.claude/skills/framing/SKILL.md` (396 lines → ~120; frontmatter unchanged)
- Modify: `.claude/skills/framing/references/test_cases.md` (append Test 7; touch § How to run)

**Interfaces:**
- Consumes: the current `SKILL.md` heading map — `## Cascade events` 15 · `## Required inputs` 52 · `## Three rigor modes` 70 · `## Step 1` 86 · `## Step 2` 96 · `## Step 3` 119 · `## Step 4` 137 · `## Step 5` 157 (six `###` subsections) · `## Producing the frame-NN.md file` 270 · `## Phase exit checklist` 280 · `## Backend-axis-aware behavior` 293 · `## HITL gates summary` 318 · `## Handoff contract to rough-in` 340 · `## Failure modes` 357 · `## Solo vs. team notes` 370 · `## Project-level overrides` 376 · `## Reference files` 380.
- Produces: `references/contract.md` with the five headings `## Read in full before writing` · `## What the file must contain` · `## The tests every milestone must pass` · `## What the drafter returns` · `## Before the gate`; `references/procedure.md` carrying Steps 1–5, the long-form axis section, the HITL gates summary, the failure modes and the solo/team notes; the phrase `references/contract.md` and `references/procedure.md` in `SKILL.md` (Task 8's check greps for both).

- [ ] **Step 1: Build `references/procedure.md` from the current text (move, don't rewrite)**

Confirm the anchors, then cut:

```bash
S=.claude/skills/framing/SKILL.md
grep -n '^## ' $S | sed -n '4,9p;11,13p'   # expect Step 1 @86 … Step 5 @157, Producing @270, Backend-axis @293, HITL @318, Handoff @340, Failure @357, Solo @370, Project-level @376
{ cat <<'HDR'
# Framing — the procedure

Read this only when running framing in **full mode**, or when the contract-first draft (`contract.md`) leaves you unsure how a step is meant to go. In light and standard modes the contract, the two templates and the inputs are the whole read; `SKILL.md` routes. Nothing here overrides the contract: where the two differ, the contract governs and the difference is a defect to report.

The five steps below are the exercised procedure with their per-step gates. The HITL gates summary, the long-form backend-axis behaviour, the failure modes and the solo-versus-team notes follow them.

HDR
sed -n '86,269p' $S; echo; sed -n '293,317p' $S; echo; sed -n '318,339p' $S; echo; sed -n '357,375p' $S; } > .claude/skills/framing/references/procedure.md
```

Then fix intra-file pointers in the new file: `grep -n "above\|below\|this SKILL\|SKILL.md §\|§ Step" .claude/skills/framing/references/procedure.md`. Every hit that pointed at a section now in `SKILL.md` or `contract.md` is rewritten to name the file (`SKILL.md § Three rigor modes`, `contract.md § The tests every milestone must pass`); hits that point within the procedure keep `§ Step N`.

- [ ] **Step 2: Write `references/contract.md`**

The exercised contract, lifted; two lines generalized (the ledger example, the roadmap hedge) and the evidence pointer moved to the reference half:

```markdown
# The framing contract — what the frame must contain and the tests it must pass

This is the default read for producing `docs/cbk/frame-NN.md`. It states *what* the artifact is, not *how* to
arrive at it. A drafter — the main loop or a dispatched agent — reads this, the two templates, and the inputs
below, and writes the whole frame. The step-by-step procedure with its per-step gates lives in `procedure.md`
and is read on demand (full mode, or when a step is unclear).

Why contract-first: on 2026-09-01 an A/B on a real workstream gave six drafters identical inputs at three model
tiers; three read the skill's procedure and its references, three read a 61-line ancestor of this file and the
template. At the workhorse tier and at the top tier, blind workhorse-tier judges ranked the contract-only drafts
first and second with no flagged false claims; the procedure-following drafts ranked third and fourth with three
flags each and prescriptive rough issues. The mid tier ranked last either way. Recorded in
`.claude/rules/orchestration-reference.md` § Applied instances.

## Read in full before writing

- `docs/cbk/problem_brief.md`, `docs/cbk/scaffold.md`, `docs/cbk/blueprint.md` (all of it; § Workstreams, the
  workstream's project entry, and any § Notes for framing bind), the roadmap surface if the project keeps one,
  `docs/cbk/README.md`, and every prior `docs/cbk/frame-NN.md` — prior frames' interface commitments are inherited
  verbatim.
- The project's decision records: `docs/adr/` and its index, and any design-decision ledger the project keeps.
- `docs/ARCHITECTURE.md`, `CLAUDE.md`, and `.claude/rules/cbk-conventions.md` (title prefixes, trace IDs,
  methodology, grain, layout, mutation discipline).
- `references/templates/frame-output-template.md` (the shape of the file) and
  `references/templates/milestone-template.md` (the shape of a milestone).
- The workstream's parent issue body on the planning backend, and any intake candidates filed under it.

Inherit; do not re-derive. Decisions and ADRs are fixed constraints: cite them where they bind and never
contradict them; where two immutable records disagree, say so and route the choice to a pre-flight decision.
Verify any claim about the codebase by reading or grepping the repo. If a foundation doc is wrong or missing
something, say so under "Suggested foundation doc updates"; never apply the change.

## What the file must contain

1. Every section of the template, in its order: the header (which blueprint workstream row this frames, the frame
   number, what it builds on or supersedes), Purpose, Approach, Resolved during this framing, Components (each with
   the milestone that builds it), Boundaries (in scope, out of scope, agreements with prior framings or sibling
   workstreams), Interface Commitments (a table: interface, consumer, stable by which milestone, shape, brief —
   first-class even if empty, with the non-API prompt answered), Key Constraints, Milestones, Narrative arc,
   Suggested foundation doc updates (suggestions only), Open questions (each with a revisit trigger), Pre-flight
   checks (a table; if none, the exact text "No deferred meta-issues from this framing" — rough-in matches on it),
   Rough-in events (an empty table), Handoff context (about 150 words, with the parent-pointer sentence).
2. Each milestone: heading `### F<N> — M<N>: <name>`; one Capability sentence of the form "After this, the system can
   …"; Depends on; an appetite as its own field where the methodology is appetite-based; acceptance criteria carrying
   `[F<N>.AC<M>]` trace IDs; rough issues, each a one-sentence intent (what it exists to do, never how — no file
   paths, no signatures, no implementation sequences); issue-type flags (Claude-Code-implementable or user-managed);
   issue notes with the milestone's done-signal.
3. F numbers are workstream-unique and never restart across frames. M numbers are frame-local.

## The tests every milestone must pass

- **Demonstrable capability**: "can I show this to someone and have them see a meaningful change in what the
  system can do?" A milestone is a verb the system can do, not a noun describing what was built and not an
  implementation step. Adjacent milestones that cannot each pass this test are one milestone pre-decomposed.
- **Count**: as many as the workstream genuinely has, typically 3–6, 2–7 at the outside. Where the project's
  conventions set a grain (fewer, larger), that grain binds.
- **Rough issues**: 2–6 intents per milestone is the neighbourhood; rough-in shapes them into review units later,
  so do not pre-decompose. When unsure between more-smaller and fewer-larger, choose fewer.
- **Pre-flight meta-issues**: a decision or de-risk unit that gates a milestone — a charter, a governing ADR, a
  throwaway spike whose verdict alone survives — goes in the Pre-flight checks table with `Blocks: M<n> start`, never
  as a milestone. If the concept and its buildable spec are both settled upstream, there is nothing to ratify;
  skip the ceremony. A project instruction that names a spike as the first milestone beats this generic rule; say
  so in Resolved. A spike gating a risky adoption pre-declares promote / named fallback / documented drop before
  the numbers arrive.
- **Methodology**: honour what blueprint chose (Shape Up appetite, Kanban flow, Scrum sprints); never impose
  another.
- **Scope of the phase**: framing does not choose MCP servers, plugins, stack, methodology or CI gates; those were
  blueprint's and are inherited as constraints. Flag a tooling gap as a suggested foundation doc update.
- **Appetite re-estimate**: where blueprint or the design ledger asks framing to re-estimate, state the arithmetic
  and the options for the operator; never absorb it into milestone sizing.

## What the drafter returns

Alongside the draft: the milestone count; the F-issue titles the commit will create (`[<slug>:F<N>] <intent>`,
one per milestone) and any meta-issue titles for pre-flight rows; the questions it would have put to the operator
had the run been interactive — these become the gate's decision list; and brief notes on what was verified in the
repo and what was resolved during drafting.

## Before the gate

The draft is verified before it is shown: one fresh-context verifier at the project's verify tier attacks every
citation and every claim about the repo against the sources, runs the phase exit checklist mechanically, and
returns defects with a verbatim quote each. Fix, then present. For a high-stakes frame, generate two or three
contract-first drafts, judge them blind, and synthesize from the winner. Tiering per the project's
`.claude/rules/orchestration.md`: drafters and verifiers at the workhorse tier, effort `high`, never a finder tier
for anything that lands in the artifact.
```

- [ ] **Step 3: Rewrite `SKILL.md` to the compact form**

Keep lines 1–5 (frontmatter) and the three intro paragraphs (lines 7–13) verbatim. Replace everything from `## Cascade events, not project slots` to the end with:

```markdown
## This skill is contract-first

The artifact is defined by **`references/contract.md`** — what `frame-NN.md` must contain and the tests every milestone must pass — together with the two templates. That is the whole read for drafting. The step-by-step procedure with its per-step gates (`references/procedure.md`) is on demand: full mode, or when a step is unclear.

Why: on 2026-09-01 an A/B on a real workstream gave six drafters identical inputs, three reading the procedure and three reading the contract, at three model tiers. At the workhorse tier and at the top tier the contract-only drafts ranked first and second with no flagged false claims; the procedure-following drafts ranked third and fourth with three flags each and prescriptive rough issues. The mid tier ranked last either way. Procedure written for earlier models is prescriptive in ways that now cost quality (`.claude/rules/orchestration-reference.md` § Applied instances). Nothing was retired — it moved.

## Cascade events, not project slots

Each framing produces a **numbered** file: `frame-01.md` is the first framing the user did, `frame-02.md` the second, and so on. The number is the framing's identity in the cascade timeline, not the project's. Re-framing a project after code is built produces a new file with the next number; the prior framing stays in the history. The `docs/cbk/README.md` index tracks the timeline with a status column (Active / Completed / Superseded by frame-NN / Abandoned), and **rough-in always picks up the highest-numbered Active framing as "what's next."** Layout (flat by default, nested by override) comes from the project's `cbk-conventions.md`.

Five selection patterns exist — named explicitly, picked from sequence, whole-frame re-framing, additive increment (`Builds on:`, both frames stay Active), and milestone-scoped re-framing (`Supersedes only milestone M<N>`). The last three carry header and index-status rules; they are spelled out in `references/procedure.md` § Step 2 and in `cbk-conventions.md` § Mutation discipline.

## Required inputs and how to read them

- `docs/cbk/problem_brief.md` — from consultation
- `docs/cbk/scaffold.md` — from scaffold
- `docs/cbk/blueprint.md` — from blueprint, especially § "Workstreams" and any § "Notes for framing"
- `docs/cbk/frame-NN.md` — every prior framing (their interface commitments are inherited verbatim)
- `docs/cbk/README.md` — the cascade-events index, for the next frame number
- the project's decision records (ADRs, any design-decision ledger), `docs/ARCHITECTURE.md`, `CLAUDE.md`, `.claude/rules/cbk-conventions.md`
- the workstream's parent issue on the planning backend, and any intake candidates filed under it

Read them from the repo (or via the git-host MCP when that is how the repo is connected); if the files are not reachable, ask the user to upload or paste them. If any of the first three is missing, **do not silently proceed**: run the missing phase, accept an uploaded or verbal equivalent (and flag that the input is informal), or ask what is available. Read every input **in full** before drafting — skimming or guessing at their content is the most common framing failure, and it is the one light mode is most likely to cause. `references/inheritance.md` holds the verbatim-summary discipline for the modes that present one.

## Three rigor modes — light, standard, full

**Detect-then-confirm** at session start: propose a mode in one sentence from the user's opening message and let them override in one word. Default to **standard** for a first-time user. The dial can be turned mid-session.

- **Light mode — one gate.** One up-front confirmation (workstream, frame number, mode, anything the operator already knows the answer to), then run to completion: draft contract-first, verify, present the frame with the decision list, commit on approval. Best for "just give me the milestones" and workstreams whose shape is nearly self-evident.
- **Standard mode — three gates.** (1) inheritance + project selection; (2) the verified draft — refined definition and milestones together, with the decision list; (3) the final `frame-NN.md` before commit.
- **Full mode — five gates**, one per step, following `references/procedure.md`. The contract still governs the output. (Tooling research — MCP servers, plugins — is blueprint's in every mode.)

What no mode skips: reading the inputs in full, at least one milestone with a demonstrable capability, the `frame-NN.md` file, and the verification pass below.

## How the draft is produced

1. **Read** the inputs above, `references/contract.md`, `references/templates/frame-output-template.md` and `references/templates/milestone-template.md`.
2. **Draft the whole frame** against the contract. Where a step would have stopped for a gate in a mode that has none, decide, proceed, and carry the question into the decision list the gate presents. Rough issues are intents; milestones are capabilities; pre-flight units go in the table; interface commitments are first-class; appetite is re-estimated where the project asks, never absorbed.
3. **Verify before the gate.** One fresh-context verifier at the project's verify tier reads the draft and the sources, attacks every citation and every claim about the repo, runs the phase exit checklist mechanically, and returns defects with a verbatim quote each. Fix them. For a high-stakes frame, produce two or three contract-first drafts, judge them blind, and synthesize from the winner. Tiering is the project's `.claude/rules/orchestration.md`: drafters and verifiers at the workhorse tier, effort `high`, never a finder tier for anything that lands in the artifact.
4. **Present** the frame with the decision list — the questions the draft would have asked — and the narrative arc ("After M1 you can X … by MN the project delivers Z"), and the structural tests stated plainly: each milestone's "show this to someone" moment, each rough issue an intent, rough-issue counts per milestone.

Depth of research is a user signal: when the project is greenfield or entering new technical territory, propose a depth and let the user confirm; never silently scale it down, and never present partial work as complete. `references/research-phase.md` has the depth patterns and what framing does **not** research (MCP servers, plugins, stack, methodology, CI gates — all blueprint's, inherited as constraints).

If the project runs a contribution-intake lane, candidates filed under the workstream are **inputs, not greenfield**: fold each into the milestone it informs and reconcile it at the commit (promote to its F-issue, or close as superseded). `cbk-conventions.md` names the concrete op.

## Producing the frame-NN.md file and committing

Write `docs/cbk/frame-NN.md` (path per the project's layout) from the approved draft and append a row to `docs/cbk/README.md` with the framing number, the workstream, the date and status `Active`. On a backend planning axis, create one F-sub-issue per milestone (and one meta-issue per pre-flight row) parented under the workstream's parent issue — the two-step create-then-link pattern, the atomic transition with the markdown commit, the rollback rules and the partial-failure protocol are in `references/planning-backend-commit.md`; the issue bodies come from the repo's `.github/ISSUE_TEMPLATE/cascade-framing.md` and `cascade-meta.md`, disk first. Where the project keeps a roadmap surface, add its rows in the same commit. If no commit path is available, hand the files to the operator as downloadable artifacts rather than leaving the frame in the conversation.

**HITL gate (final)**: present the file and the list of issues to be created; get explicit approval before any write. The gate wording is in `references/planning-backend-commit.md` § HITL gate update.

## Phase exit checklist

Auto-checkable list that fires after the final gate, before declaring framing complete. Not a gate; a safety surface (the skill stops if any item fails), per `cbk-conventions.md` § Trip-wire pattern:

- [ ] `frame-NN.md` content includes all required sections: Purpose, Approach, Components, Boundaries, Interface Commitments, **Pre-flight checks** table (with the empty-default text `"No deferred meta-issues from this framing"` if none — the string rough-in matches on), Open questions, Milestones (each with `[F<N>.AC<M>]` trace IDs in acceptance criteria)
- [ ] Frame-NN's number was correctly identified (highest existing in `docs/cbk/README.md` + 1)
- [ ] Workstream parent issue exists (github-issues and linear planning; n/a on in-repo-markdown) and matches the workstream slug
- [ ] No prior F-issue exists for this milestone (idempotency)
- [ ] Markdown commit and (on backend planning axes) F-issue creation atomic transition succeeded, or partial state surfaced cleanly
- [ ] `docs/cbk/README.md` updated with new entry + status `Active`
- [ ] If the project runs a contribution-intake lane (cbk-conventions): no candidate it filed under this workstream remains un-reconciled — each was promoted to an F-issue or closed as superseded
- [ ] The verification pass ran and its defects were fixed or consciously kept (recorded in the gate)

## Backend-axis-aware behavior

Two independent axes set by scaffold. **Planning**: `github-issues` creates F-sub-issues via issue-write plus sub-issue-link, atomic with the markdown commit; `linear` creates F-issues parented under the workstream issue via `save_issue`; `in-repo-markdown` has no external entities and the transition collapses to the markdown commit. **Knowledge**: `notion` permits optional reads at inheritance and a promote-to-runbook offer for genuinely cross-project meta-issues — reads and writes both HITL-gated and default-skip, never for normal milestone-blocking meta-issues, and every planned write announced before it is committed; `none` means no Notion interaction. The long form of both axes is `references/procedure.md` § Backend-axis-aware behavior; the operational detail is `references/planning-backend-matrix.md`, `references/backends.md`, and the project's `cbk-conventions.md` for the identifiers.

## Handoff contract to rough-in

When framing is complete, rough-in inherits:

- **The latest frame-NN.md** — refined definition, milestones, rough issues, interface commitments, **and the Pre-flight checks table**
- **The cascade-events index** at `docs/cbk/README.md` — for finding the latest framing (highest-numbered Active row)
- **All prior framings** — for cross-framing interface commitments
- **Planning-backend issues created by framing** — F-level sub-issues (labeled `cascade-depth:framed`) and any pre-flight meta-issues (`cascade-depth:framed` + `meta`), all parented under the workstream parent issue

**What rough-in does with this**: reads the latest frame-NN.md (the highest-numbered one), picks one milestone from it, and decomposes that milestone's rough issues into ready-to-implement issues (with acceptance criteria, technical detail, and Claude Code plan-mode prompts). Rough-in does not need prior framings except as historical context for interface commitments.

**Mandatory pre-flight check**: before decomposing milestone M_n, rough-in MUST read the Pre-flight checks table from the latest frame-NN.md and verify any row with `Blocks: M_n start` is resolved (closed) or explicitly cleared by the user. If unresolved rows block M_n, **rough-in stops and surfaces the gap**. The check obligation lives on rough-in; the table existing — with its explicit "none" when empty — is framing's responsibility.

**What framing must not pass to rough-in**: implementation code, detailed issue specs, production deployment decisions, test specifications below the milestone-acceptance level.

**The latest framing is always the answer to "what's next."**

## Project-level overrides

Project-specific overrides (workstream slugs, team key, branch naming, layout, operational evidence) live in the project's `.claude/rules/cbk-conventions.md`. Read it at session start; treat its content as overrides on this skill's defaults. If no `cbk-conventions.md` exists, framing operates with the defaults documented here.

## Reference files

- `references/contract.md` — **the default read**: what the frame must contain, the tests each milestone must pass, what the drafter returns, the verify-before-gate step
- `references/procedure.md` — the full step-by-step procedure (Steps 1–5, the long-form backend-axis behaviour, the five-gate summary, failure modes, solo vs. team); full mode, or on demand
- `references/templates/frame-output-template.md` — the frame-NN.md template with worked example
- `references/templates/milestone-template.md` — milestone shapes and the per-milestone template
- `references/planning-backend-commit.md` — the F-issue creation step, atomic transition, rollback, partial-failure recovery, brownfield recovery
- `references/inheritance.md` — reading prior artifacts, the verbatim summary template, the "builds on" pattern
- `references/research-phase.md` — depth patterns, what framing does not research
- `references/hitl-question-bank.md` — clarifying questions per round (full and standard modes)
- `references/planning-backend-matrix.md`, `references/backends.md` — planning-axis behavior
- `references/failure-modes.md` — framing-specific failure modes with recovery patterns
- `references/test_cases.md` — realistic test prompts with success criteria for verifying the skill after revisions; the last case walks the contract-first default and its verification pass

Read references on demand, not all at once. SKILL.md routes; the contract and the templates are the drafting read; the procedure is the on-demand read.
```

Then check: `grep -c '' .claude/skills/framing/SKILL.md` well under 500; `grep -n "Linear team key" .claude/skills/framing/SKILL.md` → none; every `references/<file>` the new text names exists (`for f in $(grep -o 'references/[a-z_/-]*\.md' .claude/skills/framing/SKILL.md | sort -u); do [ -f .claude/skills/framing/$f ] || echo MISSING $f; done`).

- [ ] **Step 4: Append Test 7 to `references/test_cases.md`**

Insert before `## How to run these test cases` (line 173):

```markdown
## Test 7 — Contract-first draft with the verification pass

**Prompt**: *"Frame the next workstream — light mode, just give me the milestones."* on a repo whose blueprint has one unframed workstream and whose `docs/cbk/README.md` has two prior frames.

**Success criteria**:
- The skill reads the inputs in full and `references/contract.md`; it does not open `references/procedure.md` (light mode, no unclear step)
- The whole frame is drafted before anything is shown; one fresh-context verifier at the project's verify tier attacks the citations and the repo claims and returns defects with a verbatim quote each, which are fixed before the gate
- The one gate presents the frame with a **decision list** — every question a standard-mode gate would have asked, paired with the draft's choice — and the narrative arc
- The drafter's return carries the milestone count, the F-issue titles the commit will create, the decision-list questions and the notes on what was verified; none of that material appears inside `frame-NN.md`
- Every milestone passes the contract's tests (demonstrable capability; intents not prescriptions; a pre-flight row, not a milestone, for a gating decision)

**Failure signals**:
- The frame is presented unverified, or the "verification" is the drafter re-reading its own draft
- The gate asks questions the draft could have decided and carried into the decision list
- The procedure is read wholesale in light mode; or the contract is skipped because the procedure "has it all"
- An inheritance summary or a gate-question list lands inside the frame file
```

In § How to run, after "Test cases 1 and 2 should pass cleanly on any commit to the skill.", add the sentence: *Run every case at the project's worker tier and again at its escalation tier — a skill's effectiveness depends on the model under it (`platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices` § Test with all models you plan to use, fetched 2026-09-05).*

- [ ] **Step 5: Verify and commit**

Run the verification block (green; the test-case count guards at lines ~471–472 stay green because no count word precedes "realistic"). Then:

```bash
git add .claude/skills/framing
git commit -m "feat(framing): contract-first — references/contract.md is the drafting read, the procedure moves to references/procedure.md, SKILL.md routes; test case 7

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 2: Rough-in — contract, procedure, compact SKILL.md, test case 9

**Files:**
- Create: `.claude/skills/rough-in/references/contract.md`
- Create: `.claude/skills/rough-in/references/procedure.md`
- Modify: `.claude/skills/rough-in/SKILL.md` (476 lines → ~160; frontmatter unchanged)
- Modify: `.claude/skills/rough-in/references/test_cases.md` (insert Test 9 before § Cross-test invariants; drop the count in "across all eight tests")

**Interfaces:**
- Consumes: the current `SKILL.md` heading map — `## What rough-in reads` 15 · `## Required pre-flight check` 33 · `## Three rigor modes` 49 · `## Step 1` 63 · `## Step 2` 73 · `## Step 3` 88 · `## Step 4` 106 · `## Step 5` 126 (fenced worked example 153–200) · `## Step 5.5` 204 (subsections 210–300) · `## Step 6` 302 · `## Step 7` 312 (subsections 318–379) · `## Backend-axis-aware behavior` 381 · `## The capstone pattern` 399 · `## Handoff contract to finish` 410 · `## HITL gates summary` 426 · `## Failure modes` 434 · `## Solo vs. team notes` 452 · `## Reference files` 458. (The `## Intent` … `## Done signal` lines at 160–195 are inside the fenced example, not headings.)
- Consumes from Task 3: the executor pair's names (`references/finish-command.md` for the contract, `references/finish-procedure.md` for the procedure) — the compact SKILL.md and the moved Step 5.5 name both.
- Produces: `references/contract.md` (headings `## Read in full before writing` · `## What the output must contain` · `## The tests every spec must pass` · `## What the drafter returns` · `## Before the gate`); `references/procedure.md`; `SKILL.md` naming both.

- [ ] **Step 1: Build `references/procedure.md` (move)**

```bash
S=.claude/skills/rough-in/SKILL.md
grep -n '^## ' $S | grep -v '^1[6-9][0-9]:' | sed -n '4,12p;14,17p'   # Step 1 @63 … Step 7 @312, Backend-axis @381, capstone @399, Handoff @410, HITL @426, Failure @434, Solo @452
{ cat <<'HDR'
# Rough-in — the procedure

Read this only when running rough-in in **full mode** or **standard mode**, or when the contract-first draft (`contract.md`) leaves you unsure how a step is meant to go. In light mode the contract, the spec template and the executor's parser are the whole read; `SKILL.md` routes. Nothing here overrides the contract: where the two differ, the contract governs and the difference is a defect to report.

The one-way doors — Step 5.5's provisioning and Step 6's atomic transition — are run by the main loop after the gate in every mode, never by a dispatched drafter.

HDR
sed -n '63,380p' $S; echo; sed -n '399,409p' $S; echo; sed -n '426,457p' $S; } > .claude/skills/rough-in/references/procedure.md
```

Then two edits inside the moved text:

1. **Step 5.5 names the pair.** In the moved `### Step protocol`, the sentence beginning `2. **Compare against the bundled template** at \`references/finish-command.md\`` becomes: `2. **Compare against the bundled templates** at \`references/finish-command.md\` (the contract — its body below the \`--- BEGIN TEMPLATE ---\` marker is the canonical \`.claude/commands/finish.md\`) and \`references/finish-procedure.md\` (the procedure — its body is the canonical \`.claude/commands/finish-procedure.md\`), judged per file:` — and every later "the template"/"the file" in that step reads "each template"/"each file"; the drift diff is presented per file; a cold start commits both files in one atomic transition. The same wording lands wherever the moved text says `references/finish-command.md` alone in the sense of "what Step 5.5 provisions" (`grep -n 'finish-command' references/procedure.md`).
2. **Pointers.** `grep -n "above\|below\|this SKILL\|SKILL.md §\|§ Step" .claude/skills/rough-in/references/procedure.md`; hits that point at a section now in `SKILL.md` or `contract.md` are rewritten to name the file; in-procedure `§ Step N` pointers stay.

- [ ] **Step 2: Write `references/contract.md`**

The exercised contract, lifted; the type-flag line generalized, the evidence pointer moved to the reference half:

```markdown
# The rough-in contract — what one milestone's R-issue set must contain and the tests each spec must pass

This is the default read for producing the sub-sub-issues of one framing milestone. It states *what* the artifact
is, not *how* to arrive at it. A drafter — the main loop or a dispatched agent — reads this, the spec template, the
executor's body parser, and the inputs below, and writes the whole set: the issue plan, the coverage map, every spec
body and the commit-time text. The step-by-step procedure with its per-step gates lives in `procedure.md` and is read
on demand (full mode, or when a step is unclear). The two one-way doors — provisioning the executor pair and the
planning-backend commit — belong to the main loop after the gate, never to a drafter.

Why contract-first: on 2026-09-02 an A/B on a real milestone gave four drafters identical inputs at two model tiers;
two read the skill's procedure and its references, two read a 109-line ancestor of this file plus the spec template.
Two of three blind workhorse-tier judges ranked a contract draft first and the procedure's workhorse-tier draft last;
every output in both arms carried the executor's headings and put no code in an Implementation section, so what
separated the arms was noise the procedure invited (a 150-line re-quoted inheritance block, fabricated line counts
from a template diff) and gaps this contract has since closed (numbered R-level criteria; the frame's open questions
cited as the frame's). Recorded in `.claude/rules/orchestration-reference.md` § Applied instances.

## Read in full before writing

- The highest-numbered **active** `docs/cbk/frame-NN.md` for the workstream — all of it. The milestone's own section
  (its capability, acceptance criteria, rough issues, issue notes and acceptance signal), § Interface Commitments,
  § Pre-flight checks, § Resolved during this framing, § Key Constraints, § Open questions and § Handoff context bind.
- The framing sub-issue for the milestone and every pre-flight meta-issue the frame names (state and body);
  `docs/cbk/README.md`; the roadmap surface if the project keeps one.
- `docs/cbk/problem_brief.md` (the no-gos), `docs/cbk/scaffold.md` (the quality bar, the cascade grain),
  `docs/cbk/blueprint.md` (stack decisions, methodology, the workstream's entry, notes for framing, amendments).
- The project's decision records — `docs/adr/` and its index, and any design-decision ledger — in full for every
  clause the milestone's criteria or the frame's § Resolved cite.
- `docs/ARCHITECTURE.md`, `docs/STANDARDS.md`, `CLAUDE.md`, `.claude/rules/cbk-conventions.md` (title prefixes, the
  trace-ID convention **including the project's test-side tag form**, branch naming, mutation discipline),
  `.claude/rules/testing.md`.
- The executor's body parser — `.claude/commands/finish.md`'s preconditions (the eight headings), or whatever the
  project's `cbk-conventions.md` names as the executor — and the disk issue template
  `.github/ISSUE_TEMPLATE/cascade-rough-in.md`. The executor's heading list wins where the two differ; record the
  drift, never fix the template from here.
- `references/templates/rough-in-spec-template.md` — the shape of one spec body.
- The repository itself: the task-runner config, the package manifests, the trees the milestone touches. Verify every
  claim about the codebase by reading or grepping; existence and absence claims are verified repo-wide from the root,
  never from one package. Never assert a package API from memory — read the pinned source.

Inherit; do not re-derive. Decisions, ADRs and the frame's § Resolved are fixed constraints: cite them where they bind
and never contradict them. The frame's rough issues are intents; you shape them into review units. The frame's open
questions are the frame's: cite them as `frame-NN § Open questions <n>`; a foundation doc that keeps its own
open-questions list is a different list with its own numbering, cited by its own document.

## What the output must contain

1. **The pre-flight result.** For every row of the frame's Pre-flight checks table: the issue's state and what it
   means for this milestone. A row that blocks the milestone's start and is open stops the run. A row that blocks one
   criterion becomes a dependency of the R-issue that owns that criterion. If the table reads "No deferred meta-issues
   from this framing", say so and proceed.
2. **An issue plan** before the specs: an ordered list, each entry with the title `[<slug>:F<#>:R<#>] <intent>` (slug
   and F-number inherited from the framing sub-issue's title, never re-derived), a one-sentence intent, a type flag
   (Claude-Code-implementable | user-managed | hybrid), its dependencies on prior R-issues, and a capstone marker. A
   spike milestone's capstone is the artifact that carries its verdict; say which R-issue owns it. A milestone with no
   capstone says why.
3. **A coverage map**: every acceptance criterion of the milestone (`[F<#>.AC<n>]`) owned by exactly one R-issue — a
   criterion two issues share names the owner and the contributor — and every R-issue owning at least one. The map
   must agree with the bodies.
4. **One full spec per R-issue**, with exactly the executor's headings, in its order, named exactly. Under the
   cascade's own `/finish` these are eight: `## Context`, `## Assumptions`, `## Implementation`, `## Acceptance
   criteria`, `## Test plan`, `## Done signal`, `## Dependencies`, `## PR contract`.
   - **Context**: one paragraph — where the issue sits ("You are implementing R<#> of M<#> under the **<slug>**
     workstream's framing capability F<#> (#<framing sub-issue>)"), what it enables, what it deliberately does not do.
   - **Assumptions**: every gap you filled, one `[ASSUMPTION: …]` line each with why it was made and what changes if it
     is wrong; or exactly `- None — all parameters explicit from the framing intent and acceptance criteria.` Never
     empty.
   - **Implementation**: the plan-mode prompt — see the tests below.
   - **Acceptance criteria**: numbered `[R<#>.AC<m>]`, as checkboxes, each an observable or test-visible outcome that
     names what proves it and cites the `[F<#>.AC<n>]` it discharges. "The tests pass" is not a criterion.
   - **Test plan**: the regime named (logic | conformance | tests-as-shape-of-done); one named test per criterion in the
     project's test-side tag form from `cbk-conventions.md` § Trace ID convention, keyed to the R-level number (the
     issue number is a placeholder until the commit). A tag that resolves to no numbered criterion is a defect. Where a
     criterion is a physical measurement no test can perform, name the mechanical stand-in (a record's completeness, a
     parsed value present) and flag the rest as operational, in an explicit list.
   - **Done signal**: one command or observation; an operational signal flagged as such. For a spike-shaped
     R-issue — one whose criteria are the operator's runs — the signal names the run-and-revise loop (the rows
     filled from the runs, with the harness fixed on the same branch until they are), not the draft PR.
   - **Dependencies**: identifiers only — `#N` for existing issues, `R<#>` placeholders for sibling R-issues, which the
     commit resolves — with one line on what each is *for*; or `None`. Never name an open issue in prose here unless it
     is a dependency: the executor refuses to proceed on any open issue it finds listed.
   - **PR contract**: the planning axis's close marker for this issue, a Conventional Commits title with the
     workstream's scope, the branch pattern, the project's review-gate floor, and the project's validity-style label
     wherever the diff touches a guard the project names.
5. **The labels** each issue gets and **the parent** it is linked under (the framing sub-issue).
6. **The commit-time text**: the row for the frame's `## Rough-in events` table (date, milestone, sub-sub-issues
   created, notes), the roadmap row's status flip if the project keeps a roadmap, and the one-line cascade-index note.
7. **Loose threads**: observations that belong to no spec — template drift, skill drift, repo state the operator
   should track — one line each. The seven-heading disk template beside an eight-heading executor is the canonical one.

## The tests every spec must pass

- **Review units, not work units.** 2–6 R-issues; each one a coherent review unit — one reviewer reads the PR in one
  sitting, one architectural concern, revertible as a unit. Where the project's conventions set a grain (fewer,
  larger; sized to what one `/finish` lands as one reviewable PR), that grain binds. The frame's intents are inputs,
  not the answer: merge or split them and say why. Two issues that would be reviewed as the same code twice are one
  issue. Outside 2–6, say so and why.
- **Implementation is a plan-mode prompt, not a recipe.** Second person, every sentence a verb the executor can act
  on. Self-contained: readable cold; citations are pointers, not prerequisites. Names specific files, constraints and
  invariants; inlines code only when verbatim from a locked Interface Commitment of the frame, prefaced "the IC-N shape
  is verbatim and not negotiable — any deviation is a re-framing trigger". Cites foundation docs by section name where
  a rule binds. Embeds the verification step in the work. Names what NOT to do — the scope creep a helpful executor
  would attempt. About 300–800 words, up to ~1000 for a capstone. States intent and constraints, never implementation
  sequences, function bodies, prescribed test-function names or step-by-step commands. If reviewing the spec would
  feel like reviewing code, it has failed. The full eight properties and their worked examples are in
  `references/plan-mode-prompts.md`.
- **Acceptance is observable and traceable.** Every criterion names the command, test or artifact that proves it and
  the F-level criterion it discharges; every test tag resolves to one numbered criterion; a measurement is a number in
  a committed artifact, and "it runs" proves nothing.
- **Grounding.** Every claim about the repo, a package API or a document is true and was checked; nothing re-decides
  what an ADR, a design-ledger entry or the frame's § Resolved fixes; platform, routes, paths and throwaway-versus-
  durable status come from the frame, not from the drafter.
- **The framing's judgment calls are honoured.** Where the milestone's issue notes invite a rough-in-time decision —
  a merge, an ordering, a dependency, what stands in for a test — make it and record the reason. Where the frame
  states a rule ("nothing in this milestone is a CI gate"), no spec re-decides it.
- **Honest type flags.** Physical runs, hardware, purchases and the operator's own observations are user-managed;
  harnesses, analysis and records are Claude-Code-implementable; a mixed issue is hybrid and says which half is which.
- **Scope of the phase.** Rough-in does not choose stack, methodology, MCP servers or CI gates; does not rough-in the
  next milestone; does not edit the frame beyond its events row; does not fix the issue template.
- **The artifact carries no run material.** No re-quoted brief, scaffold or blueprint text, no inheritance summary,
  no gate-question list, no provisioning diff inside a spec body or the set — those belong to the drafter's return and
  the gate presentation.

## What the drafter returns

Alongside the output: the R-issue count and titles in order; which is the capstone; the coverage map; the milestone's
capability sentence, rough-issue list and acceptance signal **quoted verbatim** from the frame (the gate's inheritance
check — quoted, never paraphrased); the questions it would have put to the operator had the run been interactive —
these become the gate's decision list; the repo claims it verified; and brief notes.

## Before the gate

The set is verified before it is shown: one fresh-context verifier at the project's verify tier attacks every
citation and every claim about the repo or a package API against the sources, checks the coverage map against the
bodies and every test tag against a numbered criterion, attacks absence claims hardest, runs the phase exit checklist
mechanically, and returns defects with a verbatim quote each. Fix, then present. For a high-stakes milestone, generate
two or three contract-first drafts, judge them blind, and synthesize from the winner. Tiering per the project's
`.claude/rules/orchestration.md`: drafters and verifiers at the workhorse tier, effort `high`, never a finder tier for
anything that lands in an issue body.
```

- [ ] **Step 3: Rewrite `SKILL.md` to the compact form**

Keep lines 1–13 (frontmatter and the three intro paragraphs) verbatim. Replace everything from `## What rough-in reads and what it produces` to the end with the text below. The `## What rough-in reads and what it produces`, `## Required pre-flight check`, `## Backend-axis-aware behavior` and `## Handoff contract to finish` sections are the current text moved up unchanged except where marked; the new sections are `## This skill is contract-first`, `## How the specs are produced`, `## The two one-way doors`, `## Completion summary`, `## Phase exit checklist`, `## Project-level overrides`.

```markdown
## This skill is contract-first

The artifact is defined by **`references/contract.md`** — what one milestone's R-issue set must contain and the tests every spec must pass — together with the spec template and the executor's body parser. That is the whole read for drafting. The step-by-step procedure with its per-step gates (`references/procedure.md`) is on demand: full mode, or when a step is unclear.

Why: on 2026-09-02 an A/B on a real milestone gave four drafters identical inputs at two model tiers, two reading the procedure and two reading the contract. Two of three blind workhorse-tier judges ranked a contract draft first and the procedure's workhorse-tier draft last. Every output in both arms carried the executor's headings and put no code in an Implementation section — the artifact contract held either way — and what separated the arms was noise the procedure invited: a re-quoted inheritance block inside the artifact, fabricated line counts from Step 5.5's template diff, one frame rule re-decided. The contract's own gaps (unnumbered R-level criteria, a foundation doc's open questions cited for the frame's) are closed in the contract. Recorded in `.claude/rules/orchestration-reference.md` § Applied instances. Nothing was retired — it moved.

## What rough-in reads and what it produces

[current lines 15–31, verbatim]

## Required pre-flight check: deferred meta-issues

[current lines 33–47, verbatim]

## Three rigor modes — light, standard, full

**Detect-then-confirm** at session start: propose a mode in one sentence from the user's opening message and any prior rough-in rows in the frame's `## Rough-in events` table; let the user override in one word. Default to **standard** for a first-time user.

- **Light mode — one gate.** One up-front confirmation (the milestone, the pre-flight result, anything the operator already knows the answer to), then run to completion: draft contract-first, verify, present the set with the issue plan and the decision list, provision and commit on approval.
- **Standard mode — three gates.** (1) inheritance + pre-flight; (2) the verified set — issue plan, coverage map and specs together, with the decision list; (3) the final pre-commit review, which also carries Step 5.5's provisioning state.
- **Full mode — up to nine gates**, one per step, following `references/procedure.md`. The contract still governs the output.

What no mode skips: reading every required input in full, the deferred-meta-issue pre-flight check, the **framing-invited judgment calls** (when a milestone's issue notes say "may compress 1+2" or "rough-in shapes the final boundaries", that decision is made explicitly and its reason recorded, in every mode), at least one gate on the final set before any planning-backend write, Step 5.5's provisioning gate when it fires, the atomic-transition discipline, and the verification pass below.

## How the specs are produced

1. **Read** the inputs above, `references/contract.md`, `references/templates/rough-in-spec-template.md`, and the executor's body parser (`.claude/commands/finish.md`'s preconditions, or the project's equivalent) — the parser's heading list is what every spec must carry, and where the disk issue template differs the parser wins and the drift is recorded.
2. **Draft the whole set** against the contract: the pre-flight result, the issue plan, the coverage map, every spec body, the commit-time text. Where a step would have stopped for a gate in a mode that has none, decide, proceed, and carry the question into the decision list. R-issues are review units, not work units; the frame's intents are inputs; criteria are numbered and traced; the artifact carries no run material.
3. **Verify before the gate.** One fresh-context verifier at the project's verify tier reads the set and the sources, attacks every citation, every repo claim and every package-API claim, checks the coverage map against the bodies and every test tag against a numbered criterion, runs the phase exit checklist mechanically, and returns defects with a verbatim quote each. Fix them. For a high-stakes milestone, produce two or three contract-first drafts, judge them blind, and synthesize from the winner. Tiering is the project's `.claude/rules/orchestration.md`: drafters and verifiers at the workhorse tier, effort `high`, never a finder tier for anything that lands in an issue body.
4. **Present** the set: the issue plan with its narrative arc ("R1 stands the harness up, R2 …, R4 is the capstone"), the milestone's capability, rough issues and acceptance signal quoted verbatim from the frame, the coverage map, each spec, and the decision list — the questions the draft would have asked.

Depth of research is a user signal: when the milestone's rough issues enter territory no prior rough-in has exercised, propose a depth and let the user confirm; never silently scale it down, and never present partial work as complete. `references/research-phase.md` has the depth patterns, what rough-in does **not** research, and the grounding rules for existence claims.

## The two one-way doors: provisioning the executor pair and the commit

Both run in the main loop after the gate, in every mode — never inside a dispatched drafter.

**Step 5.5 — provision the executor pair.** `/finish` is two files: `.claude/commands/finish.md` (the contract) and `.claude/commands/finish-procedure.md` (the procedure, read on demand). Idempotent, judged per file: if a file matches its bundled template — the body below the `--- BEGIN TEMPLATE ---` marker of `references/finish-command.md` for the contract, of `references/finish-procedure.md` for the procedure — it is a silent no-op; if it differs, present the **diff** (changed hunks only, never both files) with three options — leave in place, overwrite, abort — and wait; if it is missing, present the structured summary and get explicit approval before committing it. A cold start commits both files in one atomic transition. On any failure, stop and surface; never retry blindly. The full protocol is `references/procedure.md` § Step 5.5.

**Step 6 — the planning-backend commit.** One sub-sub-issue per spec, parented under the framing sub-issue, labelled `cascade-depth:roughed-in` (plus the workstream and validity-style labels the project uses), R-placeholders in dependencies and test tags resolved to numbers as the issues land; then the markdown half — the frame's events row, the index note, the roadmap flip where the project keeps one. Planning ops first, markdown second, capture-execute-rollback, and on partial failure stop and surface state to the user. The operational detail, slug inheritance, the re-rough-in and additive-pass patterns and the partial-failure protocol are `references/planning-backend-commit.md` and `references/procedure.md` § Step 6.

## Completion summary

The run's final deliverable, in every mode: **Commits** (SHAs with one-line summaries), **Sub-sub-issues** (a table of number, title, dependencies, capstone), **Handoff** (the exact next `/finish <N>` to run and what to expect; if the first R-issue has open dependencies, say so and name the soonest-runnable issue), and **Loose threads** (observations that might become skill revisions, repo state to track, cascade-level drift). Light mode may trim the prose, never a section; "No loose threads from this run" is a valid one-liner. `references/procedure.md` § Step 7 has the full shape.

## Phase exit checklist

Auto-checkable list that fires after the final gate, before declaring rough-in complete. Not a gate; a safety surface (the skill stops if any item fails), per `cbk-conventions.md` § Trip-wire pattern:

- [ ] The frame read in full; its `## Rough-in events` table examined; the milestone named and its slug + F-number inherited from the framing sub-issue's title
- [ ] Pre-flight rows checked: every row blocking this milestone's start is closed-completed or explicitly cleared and recorded; a row blocking one criterion is a dependency of the R-issue that owns it
- [ ] Idempotency: no R-issues exist for this milestone, or this is a declared re-rough-in, additive completeness pass or in-place refresh with its ledger row
- [ ] 2–6 R-issue specs (a departure stated and approved), each a coherent review unit; every F-level criterion owned by exactly one R-issue; the capstone named or its absence explained
- [ ] Every spec carries the executor's required headings in order; Implementation passes the eight properties with no non-IC code; R-level criteria numbered and cited; every test tag resolves; Assumptions present
- [ ] The executor pair's provisioning state known: present and matching, drift resolved by the operator, or cold-start committed
- [ ] Planning ops and the markdown half landed atomically, or partial state was surfaced cleanly; the frame's events row and the index note are in (and the roadmap flip, where the project keeps one)
- [ ] The verification pass ran and its defects were fixed or consciously kept (recorded in the gate)

## Backend-axis-aware behavior

[current lines 381–397, verbatim]

## Handoff contract to finish

[current lines 410–424, verbatim, with two edits: the bullet "**The `/finish` slash command** exists on disk at `.claude/commands/finish.md`…" becomes "**The executor pair** exists on disk — `.claude/commands/finish.md` (the contract) and `.claude/commands/finish-procedure.md` (the procedure) — committed by Step 5.5 during the first rough-in run against the repo"; and the "**Slash command revision path**" paragraph's "updates `references/finish-command.md` in this skill bundle" becomes "updates `references/finish-command.md` and `references/finish-procedure.md` in this skill bundle".]

## Project-level overrides

Project-specific overrides (workstream slugs, the executor and its heading list, the test-side trace-tag form, branch naming, layout, operational evidence) live in the project's `.claude/rules/cbk-conventions.md`. Read it at session start; treat its content as overrides on this skill's defaults.

## Reference files

- `references/contract.md` — **the default read**: what the R-issue set must contain, the tests each spec must pass, what the drafter returns, the verify-before-gate step
- `references/procedure.md` — the full step-by-step procedure (Steps 1–7 with their gates, Step 5.5's provisioning protocol, the capstone pattern, the HITL gates summary, failure modes, solo vs. team); full mode, or on demand
- `references/templates/rough-in-spec-template.md` — the full sub-sub-issue spec template with worked example
- `references/plan-mode-prompts.md` — the eight properties of a plan-mode prompt, the pitfalls with worked examples, the section-anchoring discipline
- `references/planning-backend-commit.md` — atomic transition pattern for rough-in, two-step `issue_write` + `sub_issue_write`, slug inheritance from parent, partial failure recovery, profile-aware behavior
- `references/finish-command.md` — bundled template for `.claude/commands/finish.md` (the executor's contract), committed by Step 5.5 during the first rough-in run in a repo
- `references/finish-procedure.md` — bundled template for `.claude/commands/finish-procedure.md` (the executor's procedure), provisioned beside the contract
- `references/inheritance.md` — how to read the required inputs, the verbatim summary template, the pre-flight protocol in detail
- `references/research-phase.md` — implementation-patterns research, open-question resolution, depth-as-user-signal, grounding existence claims
- `references/hitl-question-bank.md` — categorized questions per step (full and standard modes)
- `references/planning-backend-matrix.md`, `references/backends.md` — planning-axis behavior; the explicit "rough-in never writes to the knowledge backend" policy
- `references/failure-modes.md` — rough-in-specific failure modes with recovery patterns
- `references/handoff-to-finish.md` — the handoff contract to Claude Code's finish phase and the executor pair's revision path
- `references/test_cases.md` — realistic test prompts with success/failure criteria; the last case walks the contract-first default and its verification pass

Kit-wide operational contracts (`.claude/rules/`):
- `knowledge-backend.md` — knowledge-axis behavior (rough-in's read-only opt-in pattern; no writes). Loaded when scaffold.md records knowledge backend = `notion`.

Read references on demand, not all at once. SKILL.md routes; the contract, the template and the executor's parser are the drafting read; the procedure is the on-demand read.
```

The bracketed "[current lines …, verbatim]" markers are instructions to the executor, not text to land: paste the named ranges. Then: `grep -c '' .claude/skills/rough-in/SKILL.md` under 500; every `references/<file>` named exists (same loop as Task 1, against the rough-in directory — `finish-procedure.md` will exist after Task 3; run the loop again at Task 8).

- [ ] **Step 4: Test case 9 and the count word**

Insert before `## Cross-test invariants` (line 215):

```markdown
## Test 9 — Contract-first draft with the verification pass

**Prompt**: *"Rough in M2 — light mode."* on a repo whose active frame has M1 roughed-in and built, M2 with four rough issues and one pre-flight row blocking one criterion, and an executor pair on disk that matches the bundle.

**Success criteria**:
- The skill reads the inputs and `references/contract.md`; `references/procedure.md` is not opened (light mode, no unclear step)
- The whole set is drafted before anything is shown: pre-flight result, issue plan, coverage map (every `[F<#>.AC<n>]` owned by exactly one R-issue), every spec body with numbered `[R<#>.AC<m>]` criteria and test tags keyed to them, the commit-time text
- One fresh-context verifier at the verify tier attacks citations, repo claims, package-API claims, the coverage map and the test tags, and its defects are fixed before the gate
- The one gate carries the decision list; the framing-invited judgment call (which R-issue the blocking row becomes a dependency of) is made and its reason recorded
- Step 5.5 reports "present and matching" for both files of the pair without a gate; Step 6 runs in the main loop after the gate
- No inheritance summary, gate-question list or provisioning diff appears inside any spec body

**Failure signals**:
- A spec's Dependencies section names an open issue in prose that is not a dependency (the executor would refuse it)
- A test tag that resolves to no numbered criterion
- The drafter, not the main loop, attempts Step 5.5 or Step 6
- The set is presented unverified, or "verification" is the drafter re-reading its own output
```

In § Cross-test invariants, change "A few things should be true across all eight tests:" to "A few things should be true across all tests:". In § How to run (if the file has one) or at the end of § When to add a new test case, add the same test-with-every-model sentence as Task 1 Step 4.

- [ ] **Step 5: Verify and commit**

Run the verification block (green; the handoff-to-finish and plan-mode-prompts section-list check at line ~465 is untouched). Then:

```bash
git add .claude/skills/rough-in
git commit -m "feat(rough-in): contract-first — references/contract.md is the drafting read, the procedure moves to references/procedure.md, the one-way doors stay in the main loop; test case 9

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 3: `/finish` — the contract command, the procedure beside it, the bundled pair

**Files:**
- Modify: `.claude/commands/finish.md` (243 lines → the contract, ~70 lines)
- Create: `.claude/commands/finish-procedure.md` (the current body, moved)
- Modify: `.claude/skills/rough-in/references/finish-command.md` (wrapper edits; body below the marker = the new contract, byte-identical)
- Create: `.claude/skills/rough-in/references/finish-procedure.md` (short wrapper + marker + body = `commands/finish-procedure.md`, byte-identical)
- Modify: `.claude/skills/rough-in/references/handoff-to-finish.md` (lines 27, 45, 113: the pair)

**Interfaces:**
- Consumes: the current `finish.md` (Steps 1–11, § What `/finish` does NOT do, § Partial failure handling, § When something surprises you) — moved whole into the procedure.
- Produces: `commands/finish.md` naming all eight headings in backticks (the block's line ~461 greps `` `## Context` `` … in this file), the phrase `Review gate` (line ~480), the phrase `finish-procedure.md` (Task 8's new check); `references/finish-procedure.md` with a `--- BEGIN TEMPLATE ---` marker (Task 8's byte-parallel check).

- [ ] **Step 1: Create `commands/finish-procedure.md` from the current command**

```bash
{ cat <<'HDR'
---
description: The step-by-step procedure behind `/finish` — Steps 1–11 with their rationale, the partial-failure protocol and the surprises worth flagging. Read on demand when a step of `.claude/commands/finish.md` (the contract) is unclear; never a substitute for it. Invoked as a command this file runs nothing — it is the reference the executor consults.
---

This is the procedure `.claude/commands/finish.md` was extracted from. The contract states what a finished issue is and the tests the result must pass; this file states how each step was run when the executor was procedure-shaped, and it is kept beside the contract so that "consult the procedure when a step is unclear" resolves in the same repo. Where the two differ, the contract governs and the difference is a defect to report.

HDR
sed -n '10,243p' .claude/commands/finish.md; } > .claude/commands/finish-procedure.md
```

Line 10 is "The shape of a run: read and validate the issue (Steps 1–4) …"; keep it — it is the procedure's own map. Nothing else in the moved text changes.

- [ ] **Step 2: Rewrite `commands/finish.md` as the contract**

The whole file:

```markdown
---
description: Pick up a rough-in sub-sub-issue and turn it into a draft PR — contract-first. The contract below states what a finished issue is and the tests the result must pass; the step-by-step procedure (`.claude/commands/finish-procedure.md`) is read on demand when a step is unclear. Verifies dependencies, researches executably, gates the plan in plan mode, executes on a fresh branch red-first, runs `/simplify` then `pr-review-toolkit:review-pr` with the bounded review sweep beside it, triages by the four-class rubric, and opens a draft PR carrying the `## Review gate` and `## Triage` blocks. Expects one positional argument — the issue number (github-issues planning) or planner issue ID like TEAM-42 (linear planning).
argument-hint: <issue-number-or-planner-id>
---

You are being asked to execute the rough-in sub-sub-issue **#$1** in this repository.

This command is contract-first. On 2026-09-03 an A/B gave two workhorse-tier executors the same real issue in separate worktrees, one following the step-by-step procedure and one this contract's ancestor; four blind judges tied the two on rank — each judge's pick tracked its own reading order — while the contract's branch carried fewer claims its own code contradicted and one commit per review finding, at equal cost (`.claude/rules/orchestration-reference.md` § Applied instances). So the contract is the whole read; the procedure it was extracted from lives at `.claude/commands/finish-procedure.md` and is consulted when a step below is unclear, never as a substitute for judgement. If the issue does not match what this contract expects, or you hit friction it does not anticipate, **surface the gap** rather than improvising past it — the gap you surface is data for the next revision; the improvisation is data that gets lost.

## Read in full before planning

- **The planning backend**, resolved first from `docs/cbk/scaffold.md` § Cascade metadata (falling back to `.cascade/backends.toml`). On `github-issues`, `$1` is the issue number and the read is `gh issue view $1 --json number,title,body,labels,state,comments` (or the github MCP); on `linear`, `$1` is the planner ID and every read goes through the planner's MCP — never a GitHub read against a planner ID; on `in-repo-markdown` there is no `/finish` (design-doc mode; the scaffold gate disclosed it) — stop and say so.
- **The issue** — its body and every comment. The body is the contract; comments are context (provenance, roll-forward notes from earlier runs, corrections the operator posted).
- **The parent framing sub-issue** and its frame (`docs/cbk/frame-NN.md`): the milestone's criteria, § Interface Commitments, § Resolved during this framing, § Key Constraints. Rough-in inherited them; you honour them. An intake-lane issue (`[<slug>:bug]`, `[<slug>:enh]`) has no frame; its provenance comment stands in.
- **Every decision record the issue cites** — the ADRs in `docs/adr/` (follow each `Refines:` chain) and any design-decision ledger the project keeps — in full for every clause cited.
- `docs/ARCHITECTURE.md`, `docs/STANDARDS.md`, `CLAUDE.md`, and the rules that bind the diff: `.claude/rules/testing.md`, `.claude/rules/logging.md`, `.claude/rules/pr-review.md`, `.claude/rules/simplification.md`, `.claude/rules/cbk-conventions.md`; at triage, `.claude/rules/pr-review-reference.md` § Apply / Surface calibration and § Path-conditional aggressiveness — a triage is not a file read, so the path-scoped half does not load on its own.
- **The repository itself**: the task-runner config, the package manifests and lockfiles, the trees the issue names, and the pinned sources of any package the issue's assumptions cite. Verify every claim you act on by reading or running; existence and absence claims are checked repo-wide from the root. Never assert a package API from memory. A knowledge-backend URL the body cites is resolved only through the configured MCP, with the announcement `.claude/rules/knowledge-backend.md` § HITL announcement discipline requires; without the MCP, surface and proceed.

## Preconditions — checked before anything is planned

1. **State and shape.** The issue is open — a closed one stops the run: say so and ask whether it was closed by mistake. The title is `[<slug>:F<#>:R<#>] …`, `[<slug>:bug] …` or `[<slug>:enh] …` with `<slug>` a workstream locked in `docs/cbk/blueprint.md` § Workstreams; the issue carries `cascade-depth:roughed-in`; and the body has exactly these eight headings, in this order: `## Context`, `## Assumptions` (present even when it reads `- None — …`), `## Implementation`, `## Acceptance criteria`, `## Test plan`, `## Done signal`, `## Dependencies`, `## PR contract`. Anything else is surfaced, never normalised away.
2. **Dependencies.** Every identifier under `## Dependencies` is a closed issue whose state reason is *completed* (a Done-type state on linear, never Canceled or Duplicate). One open or otherwise-closed dependency stops the run: name it and its state, and do not offer to proceed anyway — a bypass is a deliberate rough-in revision, not a runtime patch. A cross-axis identifier (a planner ID on github-issues, a bare `#N` on linear) is surfaced, never bridged.
3. **Idempotency.** No open PR carries this issue's close marker (either family) and no branch exists for it. If either does, stop and ask whether to continue there or start fresh.
4. **Break-glass.** A `<!-- skip-review-toolkit -->` marker in the body or the operator's instructions waives the `pr-review-toolkit:review-pr` half of the floor for this run and is recorded on its `## Review gate` line, in the PR body and the hand-off. `/simplify` is never waived; nothing else waives anything.

## What the finished issue is

1. **A plan, gated before code.** Research the `## Implementation` section executably in your current permission mode — read the cited docs, run the probe a probe-pending `[ASSUMPTION:]` names, spike throwaways in the scratchpad — without editing the repo; scale the research to the work, and ground any fan-out (`finish-procedure.md` § Step 5a names the fan-out shape and the grounding rules). Then **enter plan mode** and write the plan: every `[ASSUMPTION:]` line of the body as a *confirm or correct* item with your resolution and evidence — an assumption about a mechanism is confirmed by **exercising the mechanism the harness will use**, never by a listing seen through another layer (a device inventory that "confirms" a target the runtime has no node for is the exercised failure); the files you will create or change; the regime each test falls under; the verification you end on. Surface, do not resolve, any conflict between the spec and an ADR, the frame or existing code — a wrong spec goes back to rough-in. **Present the plan and wait for approval**; entering plan mode is the disarm. An environment fact that blocks the work (a toolchain that cannot link, a missing system library) is reproduced outside the framework, reported as a blocker with the reproduction, and never worked around by installing packages or changing the machine.
2. **A branch from the base branch**, named `<type>/<TEAM>-<N>-<short-slug>` per `cbk-conventions.md` § Branch naming (the issue ID embedded in lowercase — on linear the substring fires the planner's auto-link), created in its own tool call before any code lands — the default-branch guard judges a compound command on the branch at entry. Nothing is ever committed to the base branch.
3. **Tests that document the contract, in the order the regime dictates.** Every named test in `## Test plan` exists with its tag in the project's test-side form (`cbk-conventions-reference.md` § Trace ID convention) verbatim, quotable from the runner; every test you add beyond the plan carries a tag too, or a comment stating why it has none. Logic-regime tests are committed **red before the implementation that turns them green** — commit order is the evidence, and a runner that reports no tests when red was expected is a stop-and-surface. Conformance-regime code declares the interface, then the conformance loop, then the implementation; shape-of-done surfaces are built, then asserted. No test is skipped, muted or commented out to pass.
4. **An implementation that satisfies every acceptance criterion the run can satisfy**, and says plainly which it cannot. A criterion marked operational in the spec — a physical run, an operator's measurement — is left open in the hand-off with what the operator must do, never reported as done. For a spike-shaped issue the unit of work is not the draft PR but the filled rows: the operator's runs come back with fixes the harness needs, those land on the same branch one commit each (red-first where they are logic), and the `## Done signal` names that loop, so nobody reads the draft as the end. The diff stays inside the files the spec names plus what the approved plan justified; the scope creep the spec forbids is not attempted. Nothing under `docs/cbk/`, `docs/adr/`, or an issue body changes in this run. A claim in a comment, a commit message or the PR body about what the code does is checked against the diff before it is written — "named at every call site" means every call site.
5. **Atomic commits** in Conventional Commits form with the workstream's scope: the red tests, the implementation, each simplify Apply, each review Apply — one focused commit each, never amended across a logical boundary, never squashed on the branch. The squash happens at merge on the base branch. No code or test commit carries the CI-skip marker (`cbk-conventions.md` § `[skip ci]` rule).
6. **The gate, green.** The project's `check` task passes before simplify and review run, and again after every applied finding. Unrelated red is surfaced, not muted — never skipped, expected-failed or commented out to pass.
7. **The review floor, actually run, with the bounded sweep beside it, then triage — once.** First **`/simplify`**, as a skill invocation; triage its findings by the four-class rubric and land its Apply items one commit each with `check` re-run after each. Then, **concurrently**: **`pr-review-toolkit:review-pr`** with no arguments, as a skill invocation, and — where a multi-agent orchestration surface exists — **the review workflow** (`.claude/workflows/review-sweep.js`), sized to the diff and never to the session's effort setting, with the pre-filtered changed-path list passed as `files`. The project-local reviewers ride in it from the roster the workflow reads at runtime (`.claude/rules/pr-review.md` § Project-local agents); beyond them you name the finders this diff needs — none on a small single-surface change the two skills already cover, several on a cross-layer one — and the workflow logs its planned agent count before it finds anything and returns its own gate line. Without an orchestration surface, dispatch the project-local reviewers directly and record `skipped — no orchestration surface` on the sweep's line. The sweep supplements the two skills and never substitutes for either. Triage waits for both to return and stays with you (`pr-review.md` § Triage rubric; the reference half's calibration read at triage): Apply and Apply-with-care land as their own commits with `check` re-run; Surface, Defer and Reject are recorded, never applied. A skill that is uninstalled or errors is a stop-and-surface. A skill that runs without its agent fan-out because the Agent tool is unavailable in your context counts as invoked, and its dropped dimensions are recorded on its `## Review gate` line — never described as equivalent. A failed review agent is dropped coverage, not zero findings. **Describing a review is not running one**: a claimed invocation that did not happen fails this contract outright. The floor runs when the known work is complete and is not run again on a later delta — the reviewer round on the flip covers that, and `/pr-respond` answers it.
8. **A draft PR** on the pushed branch: title in Conventional Commits with the workstream's scope; body with the planning axis's close marker (`Closes #$1` on github-issues, `Closes $1` on linear — in the body, not only the title; `cbk-conventions.md` § Closes-keyword conventions); a summary of what changed and why, with the ADRs, frame milestone and rules it relies on; a **`## Review gate`** block, written before `## Triage`, in the shape `.claude/rules/pr-review.md` § The floor states — one line each for `/simplify`, `pr-review-toolkit:review-pr` and the sweep, each stating run-or-not with counts and dropped coverage, a waived skill on its line with the break-glass reason, the sweep's line transcribed from the record the workflow returns; a **`## Triage`** block listing every finding under its class — Apply and Apply-with-care as `SHA: fix`, Surface and Defer with the agent's verbatim rationale, Reject with a one-line dismissal; and any review block or label the project's conventions require when the diff touches a surface they guard. A docs commit that would be HEAD at the flip carries no CI-skip marker (`cbk-conventions.md` § Auto-review trap). The body's close markers name every issue the run resolves — a pre-flight meta-issue the work settles as well as `$1`. The PR is never flipped to ready and never merged by this run; both are the operator's.
9. **A hand-off** that stands on its own: the PR URL; the triage counts in one line; the three `## Review gate` lines verbatim — an invocation the transcript does not show was not made; the Surface and Defer entries verbatim; every operational criterion still open with what the operator must do; the one next action; an offer to post roll-forward context wherever it is relevant — the next issue, a sibling, a meta-issue, a new follow-up — post-merge unless it blocks another issue's start; an offer to sweep the open sibling issues for absence claims this run made false. Deferred conflicts with an ADR lead the hand-off. A learning that should outlive the PR is offered to the knowledge backend only where one is configured, HITL-gated and default-skip (`.claude/rules/knowledge-backend.md` § When to write); otherwise it goes into a rule file or an ADR.

## The tests every finish must pass

- **Fidelity.** Each `[R<#>.AC<m>]` criterion is either satisfied with the named proof on the branch, or stated open as operational with the reason, in both the PR body and the hand-off. None is silently dropped or quietly reinterpreted.
- **Assumptions.** Every `[ASSUMPTION:]` line has a recorded confirm-or-correct outcome in the plan; a corrected assumption's consequence is visible in the diff.
- **Red-first evidence.** For logic-regime tests, `git log --reverse` on the branch shows the test commit before the implementation commit, and the test's first committed body fails. A test written after the answer was known is the post-hoc anti-pattern.
- **Tags resolve.** Every test-side tag in the test tree names a criterion in the issue, every named test in `## Test plan` exists, and every untagged test says why.
- **Scope.** No file outside the spec's named files and the plan's justified additions changes; no cascade artifact, ADR, issue body, CI workflow or `check`-task dependency list changes unless the spec says so.
- **Claims match code.** No comment, commit message or PR-body sentence asserts something the diff contradicts.
- **Honesty of the gate.** The three `## Review gate` lines are literally true — an invocation the transcript does not show was not made — and every Apply commit named in `## Triage` exists on the branch with the stated SHA, one finding per commit.
- **Green.** The project's `check` task passes at the branch head.
- **No improvisation past the spec.** A spec defect — unverifiable criterion, ADR conflict, missing dependency, drifted doc — is surfaced and the run stops; it is not patched in flight.
- **Partial failure surfaces.** A failed external call — `git`, `gh`, an MCP call, the check task, a skill — stops the run, and the hand-off states what reached the remote and what did not, with the choices and their consequences. No blind retry.

## What this command does not do

It does not modify the issue body, re-rough-in, create dependent issues, bypass dependencies, modify cascade artifacts or ADRs, make workstream- or framing-level decisions, skip either skill of the floor (the break-glass marker waives exactly the toolkit half, recorded), run the floor twice, flip the PR to ready, merge, or respond to auto-review comments (that is `/pr-respond`). It does not write to the knowledge backend as a side effect of anything above.
```

- [ ] **Step 3: The bundled pair**

`references/finish-command.md`: keep the wrapper (lines 1–81) with these edits — line 1 title stays; in § How Step 5.5 consumes this file, Case A/B/C sentences say "each file of the pair" and name `references/finish-procedure.md` as the procedure's template; the extraction snippet gains a second line for the procedure:

```bash
awk '/^--- BEGIN TEMPLATE ---/{flag=1; next} flag' .claude/skills/rough-in/references/finish-command.md > /tmp/bundled-finish.md
awk '/^--- BEGIN TEMPLATE ---/{flag=1; next} flag' .claude/skills/rough-in/references/finish-procedure.md > /tmp/bundled-finish-procedure.md
```

§ Provenance and revision path gains one paragraph: *"**2026-09-06 — contract-first.** The template below is the executor's contract: what a finished issue is and the tests the result must pass. The step-by-step procedure it was extracted from ships as a second template, `references/finish-procedure.md`, provisioned beside it as `.claude/commands/finish-procedure.md` and read on demand; both halves are judged for drift per file. Adopted on the `/finish` A/B recorded in `.claude/rules/orchestration-reference.md` § Applied instances."* The § Structured summary's **Structure** line becomes the contract's five headings with one-liners. Then replace everything below `--- BEGIN TEMPLATE ---` with the exact bytes of the new `commands/finish.md`:

```bash
F=.claude/skills/rough-in/references/finish-command.md
{ awk '/^--- BEGIN TEMPLATE ---/{print; exit} {print}' $F; cat .claude/commands/finish.md; } > /tmp/claude-1000/fc.md && mv /tmp/claude-1000/fc.md $F
diff <(awk '/^--- BEGIN TEMPLATE ---/{flag=1; next} flag' $F) .claude/commands/finish.md && echo byte-parallel
```

`references/finish-procedure.md` (new):

```markdown
# Bundled template for `.claude/commands/finish-procedure.md`

**This file contains the canonical content of the executor's procedure**, provisioned by rough-in's Step 5.5 beside the contract (`references/finish-command.md` → `.claude/commands/finish.md`). It is template content to be written to disk, not instructions for the skill session; do not execute the steps inside it. Step 5.5 extracts everything below the `--- BEGIN TEMPLATE ---` marker and commits it verbatim to `.claude/commands/finish-procedure.md`, judging drift for this file separately from the contract's.

Extract it via:

```bash
awk '/^--- BEGIN TEMPLATE ---/{flag=1; next} flag' .claude/skills/rough-in/references/finish-procedure.md > /tmp/bundled-finish-procedure.md
```

--- BEGIN TEMPLATE ---
```

followed by the exact bytes of `commands/finish-procedure.md` (same `cat` pattern as above; then `diff` the extraction against the command and expect no output).

- [ ] **Step 4: `handoff-to-finish.md`**

Lines 27, 45 and 113 name `references/finish-command.md` as the one bundled file; each gains "and `references/finish-procedure.md` (the procedure half, provisioned beside it)". The section list the verification block greps (line ~465) is not touched.

- [ ] **Step 5: Verify and commit**

Run the verification block — the eight-heading check (line ~461) and the byte-parallel check (line ~481) must be green on the new contract. Then:

```bash
git add .claude/commands/finish.md .claude/commands/finish-procedure.md .claude/skills/rough-in/references/finish-command.md .claude/skills/rough-in/references/finish-procedure.md .claude/skills/rough-in/references/handoff-to-finish.md
git commit -m "feat(finish): contract-first — commands/finish.md is the contract, the procedure moves beside it, the bundled template becomes a pair judged per file

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 4: Harness exemplars — the two-arm A/B workflow and the per-agent cost reader

**Files:**
- Create: `.claude/workflows/finish-ab/finish-ab.js`
- Create: `.claude/workflows/finish-ab/operator-brief.md` (template, bracketed)
- Create: `.claude/workflows/finish-ab/judge-rubric.md` (template, bracketed)
- Create: `.claude/workflows/tests/finish-ab-shape.mjs` (stub harness; no agent dispatched)
- Create: `.claude/workflows/agent-cost.py`
- Create: `.claude/workflows/tests/agent-cost-fixture.sh`

**Interfaces:**
- Produces: `node .claude/workflows/tests/finish-ab-shape.mjs` and `bash .claude/workflows/tests/agent-cost-fixture.sh`, both exit 0 — Task 8 adds them to the verification block. Every `agent()` call in `finish-ab.js` names `model` and `effort` (Task 5's rule; Task 8's grep).
- Consumes from Task 3: `.claude/commands/finish-procedure.md` and `.claude/commands/finish.md` as the default arm files.

- [ ] **Step 1: Write the harness test first (it fails until the script exists)**

`.claude/workflows/tests/finish-ab-shape.mjs`:

```js
#!/usr/bin/env node
// Stub harness for finish-ab.js. No agent is dispatched: the meta literal and the body are evaluated with
// stubbed agent()/parallel()/log()/phase(), and the panel guard, the planned-count log, the arm-isolation
// instruction and the rank arithmetic are asserted. Run: node .claude/workflows/tests/finish-ab-shape.mjs
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";

const here = path.dirname(fileURLToPath(import.meta.url));
const src = readFileSync(path.join(here, "..", "finish-ab", "finish-ab.js"), "utf8");
const metaMatch = src.match(/export const meta = (\{[\s\S]*?\n\})\n/);
if (!metaMatch) { console.error("finish-ab-shape: meta literal not found"); process.exit(1); }
const meta = new Function(`return (${metaMatch[1]})`)();
const body = src.slice(metaMatch.index + metaMatch[0].length);
const AsyncFunction = Object.getPrototypeOf(async function () {}).constructor;

let failures = 0;
const check = (cond, msg) => { if (!cond) { failures += 1; console.error(`FAIL: ${msg}`); } };

async function run(args, { armResult, judgeResult }) {
  const logs = [];
  const calls = [];
  const agent = async (prompt, opts) => {
    calls.push({ prompt, opts });
    return opts.phase === "Execute" ? armResult(opts, prompt) : judgeResult(opts, prompt);
  };
  const parallel = async (thunks) => Promise.all(thunks.map((t) => t().catch(() => null)));
  const fn = new AsyncFunction("args", "agent", "parallel", "log", "phase", body);
  const result = await fn(args, agent, parallel, (m) => logs.push(String(m)), () => {});
  return { result, logs, calls };
}

const arms = [
  { arm: "A", anon: "P", read: ".claude/commands/finish-procedure.md", verb: "follow it exactly as written, every step in order" },
  { arm: "B", anon: "Q", read: ".claude/commands/finish.md", verb: "satisfy it" },
];
const balanced = [
  { order: ["P", "Q"], effort: "high" }, { order: ["Q", "P"], effort: "high" },
  { order: ["P", "Q"], effort: "xhigh" }, { order: ["Q", "P"], effort: "xhigh" },
];
const base = { scratch: "/tmp/ab", repo: "owner/name", issue: 7, arms, judges: balanced };
const armOk = (opts) => ({ branch: `b-${opts.label}`, worktree: `/wt/${opts.label}`, commits: [{ sha: "abc", subject: "test: red" }], plan_path: "PLAN.md", pr_body_path: "PR_BODY.md", check_command: "mise run check", check_exit: 0, tests_written: ["t"], skills_invoked: ["simplify"], operational: [], gate_calls: [], handoff: "h", notes: "" });
const judgeOk = (opts) => {
  const order = balanced[Number(opts.label.match(/judge:(\d+)/)[1]) - 1].order;
  return { scores: order.map((arm) => ({ arm, fidelity: 4, assumptions: 4, tests: 4, implementation: 4, gate_honesty: 4, reviewability: 4, prose: 4, overall: 4, check_exit_observed: 0, defects: [] })), ranking: [...order], hallucinations: order[0] === "P" ? [{ arm: "P", claim_verbatim: "x", contradicting_source: "y" }] : [], graft: [], word_counts: [], notes: "" };
};

// 1. Balanced panel: planned count logged first, six calls, worktree isolation, model+effort on every call,
//    arm isolation instruction, ranks and flags computed.
{
  const { result, logs, calls } = await run(base, { armResult: armOk, judgeResult: judgeOk });
  check(/planned agents: 2 executors \+ 4 judges = 6/.test(logs[0] ?? ""), `planned count is the first log line (got: ${logs[0]})`);
  check(calls.length === 6, `six agents dispatched (got ${calls.length})`);
  const exec = calls.filter((c) => c.opts.phase === "Execute");
  check(exec.every((c) => c.opts.isolation === "worktree"), "every executor runs in its own worktree");
  check(calls.every((c) => c.opts.model && c.opts.effort), "every dispatch names model and effort");
  const armB = exec.find((c) => c.opts.label.includes("Q"));
  check(armB && armB.prompt.includes("Do not open .claude/commands/finish-procedure.md"), "arm B is told not to open arm A's file");
  check(exec.every((c) => !/arm [AB]\b/.test(c.opts.label)), "labels carry the anonymised id, never the arm letter");
  check(calls.filter((c) => c.opts.phase === "Judge").every((c) => !c.prompt.includes("arm A") && !c.prompt.includes("arm B")), "judges never see arm letters");
  check(result.ranks.P.join(",") === "1,2,1,2" && result.ranks.Q.join(",") === "2,1,2,1", `ranks follow each judge's ranking (got ${JSON.stringify(result.ranks)})`);
  check(result.flags.P === 2 && result.flags.Q === 0, `flags summed per arm (got ${JSON.stringify(result.flags)})`);
  check(result.plannedAgents === 6, "plannedAgents returned");
}

// 2. Odd panel refused before any dispatch.
{
  let err = null; let dispatched = 0;
  try { await run({ ...base, judges: balanced.slice(0, 3) }, { armResult: () => { dispatched += 1; return armOk({ label: "x" }); }, judgeResult: judgeOk }); } catch (e) { err = e; }
  check(err && /even number of judges/.test(err.message), `odd panel throws the even-number message (got: ${err && err.message})`);
  check(dispatched === 0, "nothing dispatched on an odd panel");
}

// 3. Even but unbalanced orders refused.
{
  let err = null;
  try { await run({ ...base, judges: [balanced[0], balanced[0], balanced[0], balanced[1]] }, { armResult: armOk, judgeResult: judgeOk }); } catch (e) { err = e; }
  check(err && /split evenly/.test(err.message), `unbalanced orders throw the split-evenly message (got: ${err && err.message})`);
}

// 4. A missing arm is logged as dropped and described to the judges as MISSING.
{
  const { logs, calls } = await run(base, { armResult: (opts) => (opts.label.includes("Q") ? null : armOk(opts)), judgeResult: judgeOk });
  check(logs.some((l) => /dropped arms/.test(l)), "a null arm result is logged as dropped");
  check(calls.filter((c) => c.opts.phase === "Judge").every((c) => c.prompt.includes("MISSING")), "judges are told which arm is missing");
}

check(meta.name === "finish-ab" && Array.isArray(meta.phases) && meta.phases.length === 2, "meta literal is well-formed");
if (failures) { console.error(`finish-ab-shape: ${failures} failure(s)`); process.exit(1); }
console.log("finish-ab-shape: 4 scenarios ok");
```

Run: `node .claude/workflows/tests/finish-ab-shape.mjs`
Expected: fails with `ENOENT … finish-ab/finish-ab.js` (the script does not exist yet).

- [ ] **Step 2: Write `finish-ab/finish-ab.js`**

```js
export const meta = {
  name: "finish-ab",
  description: "Two-arm A/B of the /finish executor on one issue: arm A follows the procedure, arm B the contract; each in its own git worktree at one named model and effort; a balanced blind judge panel (even count, half per reading order) that verifies before it scores",
  phases: [
    { title: "Execute", detail: "two arms, each in its own git worktree, each reading one instruction file and told not to open the other" },
    { title: "Judge", detail: "blind judges reading the anonymised worktrees in alternating orders; ranks, contradicted claims, graft" },
  ],
}

// A worked exemplar of orchestration.md § The dispatch-mechanism decision (a Workflow: deterministic fan-out over
// two arms and a judge panel) and of its judge-panel rule: an even number of judges, half per reading order,
// scoring dimensions and reporting contradicted claims before they rank. Every agent() names model and effort.
//
// args:
//   scratch — absolute path of the run's scratch directory; holds operator-brief.md and judge-rubric.md and
//             receives judges/judge-<n>.md
//   repo    — "owner/name" the arms execute against (reads with gh only; the brief forbids remote writes)
//   issue   — the issue number both arms execute
//   arms    — exactly two: [{ arm: "A", anon: "P", read: ".claude/commands/finish-procedure.md", verb: "follow it exactly as written, every step in order" },
//                          { arm: "B", anon: "Q", read: ".claude/commands/finish.md", verb: "satisfy it" }]
//             `anon` is the only id a judge ever sees; `verb` is how the arm is told to use its file
//   judges  — [{ order: ["P","Q"], effort: "high" }, { order: ["Q","P"], effort: "high" }, …] — even count, half per order
//   model   — optional, default "opus": the workhorse tier for executors and judges (never above the session's)
//   effort  — optional, default "high": the executors' effort; each judge carries its own

const S = args.scratch
const BRIEF = `${S}/operator-brief.md`
const RUBRIC = `${S}/judge-rubric.md`
const MODEL = args.model ?? "opus"
const EFFORT = args.effort ?? "high"

if (!Array.isArray(args.arms) || args.arms.length !== 2) throw new Error("finish-ab: args.arms must name exactly two arms")
const judges = Array.isArray(args.judges) ? args.judges : []
if (judges.length === 0 || judges.length % 2 !== 0) throw new Error(`finish-ab: a two-arm panel needs an even number of judges, half per reading order (got ${judges.length})`)
const orderKey = (j) => j.order.join(">")
const orders = new Map()
judges.forEach((j) => orders.set(orderKey(j), (orders.get(orderKey(j)) ?? 0) + 1))
const counts = [...orders.values()]
if (orders.size !== 2 || counts[0] !== counts[1]) throw new Error(`finish-ab: judges must split evenly across the two reading orders (got ${JSON.stringify([...orders.entries()])})`)

const plannedAgents = args.arms.length + judges.length
log(`finish-ab: planned agents: ${args.arms.length} executors + ${judges.length} judges = ${plannedAgents}`)

const ARM_SCHEMA = {
  type: "object",
  required: ["branch", "worktree", "commits", "plan_path", "pr_body_path", "check_command", "check_exit", "tests_written", "skills_invoked", "operational", "gate_calls", "handoff", "notes"],
  properties: {
    branch: { type: "string" },
    worktree: { type: "string", description: "absolute path of the worktree you worked in" },
    commits: { type: "array", items: { type: "object", required: ["sha", "subject"], properties: { sha: { type: "string" }, subject: { type: "string" } } }, description: "oldest first" },
    plan_path: { type: "string" },
    pr_body_path: { type: "string" },
    check_command: { type: "string" },
    check_exit: { type: "integer" },
    tests_written: { type: "array", items: { type: "string" } },
    skills_invoked: { type: "array", items: { type: "string" }, description: "exact skill names actually invoked via the Skill tool" },
    operational: { type: "array", items: { type: "string" }, description: "criteria left open because they need the operator or a device" },
    gate_calls: { type: "array", items: { type: "string" }, description: "every decision you made where the flow would have waited for the operator" },
    handoff: { type: "string" },
    notes: { type: "string" },
  },
}

const otherFile = (cell) => args.arms.find((c) => c.arm !== cell.arm).read
const armPrompt = (cell) => `You are executing issue #${args.issue} in the repository ${args.repo}, from inside a git worktree of your own — your current working directory. Read the operator brief at ${BRIEF} first; it states what non-interactive means for this run, the standing decisions, the hard limits and what to return.

Then read ${cell.read} in your worktree in full and ${cell.verb ?? "satisfy it"} for issue ${args.issue}, with the brief's non-interactive rules substituting only where the instructions would wait for the operator (the plan gate becomes PLAN.md, the push and PR become PR_BODY.md, operational criteria stay open). Read every input the instructions name, in full, before planning. Do not open ${otherFile(cell)} or anything under .claude/skills/ — the file you were given, the issue and the inputs it names are your whole instruction. Invoke the skills it requires as skills. Return the structured result when the hand-off exists.`

phase("Execute")
const arms = await parallel(args.arms.map((cell) => () =>
  agent(armPrompt(cell), {
    label: `arm:${cell.anon}@${MODEL}/${EFFORT}`,
    phase: "Execute",
    model: MODEL,
    effort: EFFORT,
    isolation: "worktree",
    agentType: "general-purpose",
    schema: ARM_SCHEMA,
  }).then((r) => ({ ...cell, result: r }))
))

const done = arms.filter(Boolean).filter((a) => a.result)
const missing = args.arms.filter((c) => !done.find((d) => d.anon === c.anon))
if (missing.length) log(`finish-ab: dropped arms (no result): ${missing.map((m) => m.anon).join(", ")}`)
log(`finish-ab: ${done.length}/${args.arms.length} arms returned: ${done.map((d) => `${d.anon}=${d.result.commits.length} commits, check exit ${d.result.check_exit}, skills [${d.result.skills_invoked.join(" ")}]`).join(" | ")}`)

const JUDGE_SCHEMA = {
  type: "object",
  required: ["scores", "ranking", "hallucinations", "graft", "word_counts", "notes"],
  properties: {
    scores: {
      type: "array",
      items: {
        type: "object",
        required: ["arm", "fidelity", "assumptions", "tests", "implementation", "gate_honesty", "reviewability", "prose", "overall", "check_exit_observed", "defects"],
        properties: {
          arm: { type: "string" },
          fidelity: { type: "number" }, assumptions: { type: "number" }, tests: { type: "number" }, implementation: { type: "number" },
          gate_honesty: { type: "number" }, reviewability: { type: "number" }, prose: { type: "number" }, overall: { type: "number" },
          check_exit_observed: { type: "integer", description: "exit status of the check task when YOU ran it in that worktree; -1 if you could not" },
          defects: { type: "array", items: { type: "object", required: ["quote", "problem"], properties: { quote: { type: "string" }, problem: { type: "string" } } } },
        },
      },
    },
    ranking: { type: "array", items: { type: "string" }, description: "arm ids best to worst" },
    hallucinations: { type: "array", items: { type: "object", required: ["arm", "claim_verbatim", "contradicting_source"], properties: { arm: { type: "string" }, claim_verbatim: { type: "string" }, contradicting_source: { type: "string" } } } },
    graft: { type: "array", items: { type: "object", required: ["arm", "idea"], properties: { arm: { type: "string" }, idea: { type: "string" } } } },
    word_counts: { type: "array", items: { type: "object", required: ["arm", "pr_body", "plan", "added_lines"], properties: { arm: { type: "string" }, pr_body: { type: "integer" }, plan: { type: "integer" }, added_lines: { type: "integer" } } } },
    notes: { type: "string" },
  },
}

phase("Judge")
const byAnon = {}
done.forEach((d) => { byAnon[d.anon] = d.result })
const describe = (id) => byAnon[id]
  ? `${id}: worktree ${byAnon[id].worktree}, branch ${byAnon[id].branch}`
  : `${id}: MISSING — the arm returned nothing; score it 1 on every dimension and say so`

const jok = (await parallel(judges.map((j, i) => () => agent(
  `You are judge ${i + 1} of ${judges.length}. Read the rubric at ${RUBRIC} and apply it exactly. The two arms are, in the order you must read them: ${j.order.map(describe).join("; ")}. Read the operator brief at ${BRIEF} too, so you know what both arms were told. Verify against the sources the rubric names before scoring. Write your full report to ${S}/judges/judge-${i + 1}.md and return the structured result with one scores entry per arm named ${j.order.join(" and ")}. Do not edit any file in either worktree or in the repository.`,
  { label: `judge:${i + 1}@${j.effort ?? "high"}`, phase: "Judge", model: MODEL, effort: j.effort ?? "high", agentType: "general-purpose", schema: JUDGE_SCHEMA },
)))).filter(Boolean)

if (jok.length < judges.length) log(`finish-ab: judges returned: ${jok.length}/${judges.length} — an incomplete panel is unbalanced; treat the ranks as advisory`)
const ids = args.arms.map((c) => c.anon)
const ranks = {}
const flags = {}
ids.forEach((id) => {
  ranks[id] = jok.map((j) => j.ranking.indexOf(id) + 1).filter((r) => r > 0)
  flags[id] = jok.reduce((n, j) => n + j.hallucinations.filter((h) => h.arm === id).length, 0)
})
log(`finish-ab: ranks: ${ids.map((id) => `${id}: ${ranks[id].join("/")}, flags ${flags[id]}`).join(" | ")}`)
return { arms: done, judges: jok, ranks, flags, plannedAgents }
```

Run: `node .claude/workflows/tests/finish-ab-shape.mjs`
Expected: `finish-ab-shape: 4 scenarios ok`. If scenario 1's rank assertion fails, the judge stub's order lookup (`balanced[n-1].order`) and the script's `judges` order must agree — the harness feeds the same array.

- [ ] **Step 3: The operator brief and the judge rubric, as templates**

`finish-ab/operator-brief.md`:

```markdown
# Operator brief — the `/finish` A/B on [#<N>] (non-interactive, throwaway)

> **Template.** Fill the bracketed spots for the run and pass this file's directory as `args.scratch`. Every gate the executor would stop at is converted here into a recorded decision — never removed.

You are executing issue **[#<N>]** — `[<title>]` — in the repository `[<owner/name>]`, **inside a git worktree of your own** (your current working directory). This is one arm of a two-arm experiment; the branch you produce is throwaway and will never merge. Work exactly as if it were real, except for the rules below.

## What non-interactive means here

- **No human answers you.** Where the flow stops for the operator (the plan gate, a question, a permission), make the call you would propose, write it down, and continue. Record every such call in your final return under `gate_calls`.
- **The plan gate is a file.** Plan mode is unavailable to you. Write the plan to `PLAN.md` at the worktree root, treat it as approved, and proceed. The plan must still carry every `[ASSUMPTION:]` line of the issue as a confirm-or-correct item with your resolution.
- **Never run the product.** [Name the commands that would touch shared hardware, a device, a live service or the network — two arms share one machine.] Building and testing (`[the project's build command]`, `[the project's test command]`, `[the check task]`) are allowed and expected. Every acceptance criterion that needs a real run is **operational** for this experiment: leave it honestly open in the PR body and hand-off, with what the operator must do.
- **No remote writes.** Do not push, do not open a PR, do not create, edit, comment on or label any issue, do not run any `gh` write command. Reading with `gh` is fine. Write the PR body you would have submitted, complete, to `PR_BODY.md` at the worktree root.
- **The review floor is available to you** — invoke `/simplify` and `pr-review-toolkit:review-pr` as skills, exactly as the instructions you were given require, and triage their findings. The project's review **workflow** cannot run from inside a dispatched agent; record that on the sweep's line of the `## Review gate` block as skipped, with that reason. Do not claim any invocation you did not make.
- **Stay in your worktree.** Do not edit, create or delete anything outside your current working directory. Do not touch the main checkout, the scratch directory of the session that launched you, or the other arm.
- **Commit on your own branch** (create it from the worktree's current commit, named per the project's convention), never on the base branch.

## Standing decisions you inherit (do not re-decide)

- Everything in the issue body's `## Assumptions` stands unless your research proves a line false; then correct it in `PLAN.md` and say why.
- [One line per decision the gate would otherwise re-open — a path the operator approved, a rule the frame states, a dependency the operator supplies from outside the repo.]

## Hard limits

- Do not modify `docs/cbk/*`, `docs/adr/*`, `.claude/*`, the check task's dependency list, [or the product packages the issue does not name].
- Do not install system packages or change the machine's configuration.
- Stop when the branch, `PLAN.md`, `PR_BODY.md` and the hand-off exist; do not wait for anything.

## What to return

The structured result: your branch name, the worktree path, the ordered commit list (SHA and subject), the paths of `PLAN.md` and `PR_BODY.md`, the exact `check`-task command you ran last and its exit status, the test names you wrote, which skills you actually invoked (by name), the criteria you left operational, every gate call you made, and brief notes. The hand-off text goes in `handoff`.
```

`finish-ab/judge-rubric.md`:

```markdown
# Judge rubric — the `/finish` A/B on [#<N>]

> **Template.** Fill the bracketed spots; the dimensions and the verify-before-you-score discipline are the exemplar. Judges score the **work on the branch**, run the mechanical gate themselves, and report contradicted claims before they rank.

Two executors implemented issue [#<N>] (`[<title prefix>]`, repository `[<owner/name>]`) non-interactively, each in its own git worktree, under different instructions. You do not know which arm is which. Judge the **work on the branch**, not the instructions. Verify before you score: read the issue (`gh issue view [<N>] --json title,body`), the frame's milestone section (`docs/cbk/frame-[NN].md` § Milestones › [F<#> — M<#>]), the decision records the issue cites ([`docs/adr/….md` clauses]), and the rules that bind (`.claude/rules/testing.md`, `.claude/rules/pr-review.md` § The floor and § Triage rubric, `.claude/rules/simplification.md`, [the project's test-naming and label sections in `docs/STANDARDS.md`]). Then, for each worktree, run and read:

- `git log --reverse --format='%h %s' <base>..HEAD` — the commit order is the red-first evidence
- `git diff --stat <base>...HEAD` and `git diff <base>...HEAD` — the whole change
- `PLAN.md` and `PR_BODY.md` at the worktree root
- the tests under [`<the test tree the issue names>`]
- `cd <worktree> && [the check task]; echo exit=$?` — the mechanical gate (run it; do not trust the claim)
- [any second gate the issue's test plan names, run the same way]

Score each dimension 1–5 with a one-sentence reason, then rank the two. Ties are allowed only with a reason.

1. **Spec fidelity.** Each `[R<#>.AC<m>]` criterion is either implemented with the named proof present, or honestly left operational with the reason. Penalise silent drops, quiet reinterpretation, and criteria claimed done that need the operator or a device.
2. **Assumptions.** `PLAN.md` carries every `[ASSUMPTION:]` line of the issue as confirm-or-correct with a resolution; corrected ones show in the diff.
3. **Test quality and red-first evidence.** The named tests exist with their tags verbatim; logic-regime tests were committed red before the implementation (commit order and the first committed body); no muted or skipped tests; assertions test properties, not snapshots.
4. **Implementation quality within scope.** [The issue's own shape, stated as checks: the named files, the constraints the frame fixes, what the spec forbids.] No cascade-artifact, ADR or check-task edits; lockfiles changed through the tool, never by hand.
5. **Review-gate honesty and triage quality.** The `## Review gate` lines in `PR_BODY.md` are literally true against the arm's self-report (the launching session cross-checks transcripts); triage classes follow the rubric; Apply items exist as their own commits with the SHAs the body names; Surface entries carry verbatim rationale.
6. **Diff size and reviewability.** Could one reviewer read this PR in one sitting? Penalise bulk beyond the spec and files the spec forbade; reward a diff whose shape follows the spec.
7. **Hand-off and PR body prose.** Standing on its own, honest about what is open, no re-quoted spec, no narration, [any project-required block present with the right citations].

Also report:

- **hallucinations** — any claim in `PR_BODY.md`, `PLAN.md`, commit messages or code comments that the repository, the pinned package source, or the issue contradicts. Quote the claim verbatim and name the contradicting source with a path and line.
- **graft** — ideas from the loser worth carrying into the winner.
- **word counts** — `PR_BODY.md` and `PLAN.md`, and the diff's added-line count.

Write your full report to the path you are given, and return the structured result. Do not edit any file in either worktree or in the repository.
```

- [ ] **Step 4: The cost reader's fixture first, then the reader**

`.claude/workflows/tests/agent-cost-fixture.sh`:

```bash
#!/usr/bin/env bash
# Fixture for agent-cost.py: two synthetic transcripts — one on a priced model, one on a model the table
# does not know. Asserts per-model pricing, the named-and-excluded unpriced row, and the exit codes.
# Run: bash .claude/workflows/tests/agent-cost-fixture.sh
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
script="$here/../agent-cost.py"
d=$(mktemp -d); e=$(mktemp -d)
trap 'rm -rf "$d" "$e"' EXIT
printf '%s\n' \
  '{"type":"user","timestamp":"2026-09-06T00:00:00Z","message":{"content":"arm one prompt"}}' \
  '{"type":"assistant","timestamp":"2026-09-06T00:01:00Z","message":{"model":"claude-opus-5","usage":{"input_tokens":1000000,"output_tokens":100000,"cache_creation_input_tokens":0,"cache_read_input_tokens":0}}}' \
  > "$d/agent-aaa.jsonl"
printf '%s\n' \
  '{"type":"user","timestamp":"2026-09-06T00:00:00Z","message":{"content":"arm two prompt"}}' \
  '{"type":"assistant","timestamp":"2026-09-06T00:02:00Z","message":{"model":"claude-future-9","usage":{"input_tokens":5,"output_tokens":5}}}' \
  > "$d/agent-bbb.jsonl"
out=$(python3 "$script" "$d")
grep -q 'total list-price cost: \$7.50' <<<"$out" || { echo "expected a \$7.50 total (1,000,000 in @ \$5 + 100,000 out @ \$25); got:"; echo "$out"; exit 1; }
grep -q '1 of 2 agents priced' <<<"$out" || { echo "the priced/unpriced split is not printed"; echo "$out"; exit 1; }
grep -q 'unpriced.*bbb' <<<"$out" || { echo "the unpriced agent is not named"; echo "$out"; exit 1; }
rc=0; python3 "$script" >/dev/null 2>&1 || rc=$?
[ "$rc" -eq 2 ] || { echo "no arguments should exit 2 (got $rc)"; exit 1; }
rc=0; python3 "$script" "$e" >/dev/null 2>&1 || rc=$?
[ "$rc" -eq 1 ] || { echo "an empty directory should exit 1 (got $rc)"; exit 1; }
echo "agent-cost-fixture: ok"
```

Run: `bash .claude/workflows/tests/agent-cost-fixture.sh` → fails (`can't open file … agent-cost.py`).

`.claude/workflows/agent-cost.py`:

```python
#!/usr/bin/env python3
"""Per-agent tokens, list-price cost, minutes and turns from a workflow run's transcripts.

Usage: python3 .claude/workflows/agent-cost.py <transcript-dir> [--json out.json]

<transcript-dir> is the directory the Workflow tool names in its result ("Transcript dir: …"); it holds one
agent-<id>.jsonl per agent. Each assistant message carries `message.usage` and `message.model`, so cost is
attributed to the model that actually answered, not to the label the script asked for. A transcript that
mixes models is priced per model; one unpriced model leaves that agent's row unpriced, and the row is named
and excluded from the total — never folded in as zero.

PRICE is list price per MTok as of 2026-09-05 (platform.claude.com/docs/en/about-claude/models/overview
§ Compare models, Pricing row: Fable 5.1 $10/$50, Opus 5 $5/$25, Sonnet 5 $2/$10, Haiku 4.5 $1/$5), with
cache writes at 1.25x input (5-minute TTL) and cache reads at 0.1x input. A 1-hour cache TTL prices writes
at 2x; because the cache-write share differs by tier, that widens a write-heavy tier's ratio rather than
cancelling out (on one measured run, 2026-09-01, it moved a pooled top-tier:workhorse ratio from 3.2x to
3.6x). Re-verify the table against the models page before quoting absolute dollars.
"""
import datetime as dt
import glob
import json
import os
import sys

PRICE = {  # substring of the model id -> (input $/MTok, output $/MTok); verified 2026-09-05
    'fable': (10.0, 50.0),
    'opus': (5.0, 25.0),
    'sonnet': (2.0, 10.0),
    'haiku': (1.0, 5.0),
}


def tier(model):
    for key in PRICE:
        if key in model:
            return key
    return None


def first_prompt(events):
    """First 90 chars of the first user message — the only label the transcript itself carries."""
    for e in events:
        if e.get('type') != 'user':
            continue
        c = (e.get('message') or {}).get('content')
        text = c if isinstance(c, str) else ' '.join(x.get('text', '') for x in (c or []) if isinstance(x, dict))
        text = ' '.join(text.split())
        return text[:90]
    return '?'


def parse_iso(s):
    return dt.datetime.fromisoformat(s.replace('Z', '+00:00'))


def summarise(path):
    events = []
    with open(path) as f:
        for line in f:
            try:
                events.append(json.loads(line))
            except json.JSONDecodeError:
                continue
    per_model = {}  # model id -> token counts; priced per model, so a mixed transcript is never billed at one tier
    stamps = []
    for e in events:
        if e.get('timestamp'):
            stamps.append(e['timestamp'])
        m = e.get('message') or {}
        u = m.get('usage')
        if not u:
            continue
        t = per_model.setdefault(m.get('model', '?'), dict(turns=0, inp=0, out=0, cw=0, cr=0))
        t['turns'] += 1
        t['inp'] += u.get('input_tokens', 0)
        t['out'] += u.get('output_tokens', 0)
        t['cw'] += u.get('cache_creation_input_tokens', 0)
        t['cr'] += u.get('cache_read_input_tokens', 0)
    model = ','.join(sorted(per_model)) or '?'
    turns = sum(t['turns'] for t in per_model.values())
    inp = sum(t['inp'] for t in per_model.values())
    out = sum(t['out'] for t in per_model.values())
    cw = sum(t['cw'] for t in per_model.values())
    cr = sum(t['cr'] for t in per_model.values())
    cost = 0.0
    for name, t in per_model.items():
        k = tier(name)
        if k is None:
            cost = None  # one unpriced model leaves the whole row unpriced rather than partially counted
            break
        pi, po = PRICE[k]
        cost += (t['inp'] * pi + t['cw'] * pi * 1.25 + t['cr'] * pi * 0.10 + t['out'] * po) / 1e6
    minutes = None
    if len(stamps) >= 2:
        minutes = round((parse_iso(max(stamps)) - parse_iso(min(stamps))).total_seconds() / 60, 1)
    return dict(agent=os.path.basename(path)[6:-6], label=first_prompt(events), model=model, turns=turns,
                input=inp, cache_write=cw, cache_read=cr, output=out, cost_usd=cost, minutes=minutes)


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    d = argv[1]
    rows = [summarise(f) for f in sorted(glob.glob(os.path.join(d, 'agent-*.jsonl')))]
    if not rows:
        print(f'no agent-*.jsonl under {d}')
        return 1
    cols = ['label', 'model', 'turns', 'input', 'cache_write', 'cache_read', 'output', 'cost_usd', 'minutes']
    print('\t'.join(cols))
    for r in rows:
        print('\t'.join(f'{r[c]:.2f}' if isinstance(r[c], float) else str(r[c]) for c in cols))
    priced = [r for r in rows if r['cost_usd'] is not None]
    unpriced = [r['agent'] for r in rows if r['cost_usd'] is None]
    total = sum(r['cost_usd'] for r in priced)
    split = f' ({len(priced)} of {len(rows)} agents priced)' if unpriced else ''
    print(f'\nagents: {len(rows)}\ttotal list-price cost: ${total:.2f}{split}')
    if unpriced:
        print(f'unpriced (model not in PRICE, named here and excluded from the total): {", ".join(unpriced)}')
    if '--json' in argv:
        i = argv.index('--json') + 1
        if i >= len(argv):
            print('--json needs an output path')
            return 2
        outp = argv[i]
        with open(outp, 'w') as f:
            json.dump(rows, f, indent=1)
        print(f'wrote {outp}')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
```

Run: `chmod +x .claude/workflows/agent-cost.py .claude/workflows/tests/agent-cost-fixture.sh && bash .claude/workflows/tests/agent-cost-fixture.sh`
Expected: `agent-cost-fixture: ok`.

- [ ] **Step 5: Sanitization and commit**

`grep -rnE "wf_[0-9a-f]{6,}|#[0-9]{2,}\b|/home/" .claude/workflows/` → no hits (no run id, no issue number, no absolute path), and the same grep for the source runs' repository, package and device-stack names from the operator's private list (never written into kit content) → no hits. Then:

```bash
git add .claude/workflows
git commit -m "feat(workflows): two harness exemplars — finish-ab (worktree-isolated arms, anonymised, balanced blind judges, gate-to-decision brief) and agent-cost.py (priced per answering model; unpriced rows named, never zeroed) with their tests

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 5: `orchestration.md` — explicit defaults, the drafting row, the effort rule, the caps, the generation notes (C4 orchestration bullets + C11)

**Files:**
- Modify: `.claude/rules/orchestration.md` (96 lines; always loaded — budget the growth at ≤ 6 KB and print it)

**Interfaces:**
- Consumes: the current anchors — line 9 (the "no platform-side tier" parenthetical), line 11 (the one-top-tier-agent allowance), line 13 (the bracketed posture placeholder), line 21 (the Mechanical row, "large cost multiple"), line 26 (`**Default is inherit (omit the model).**`), line 28 (the exemplar sentence), lines 34–38 (§ The effort axis bullets; line 32 is the paragraph that stays), line 58 (`**Let the runtime's cap govern — don't author a lower one.**`), line 78 (the anti-pattern row `Pilot on a slice and set a budget directive`), line 76 (`Pinning models on every agent() call by reflex`).
- Produces: the section `### Generation notes — verified 2026-09-05` with the per-role defaults table (Task 6's agents and sweep carry those values; Task 8 greps `Generation notes`); the sentence `The default is the workhorse tier, stated explicitly` (Task 8 greps it); every citation in the form `` `<host>/docs/…` § <section> `` with the fetch date stated once per subsection.

Every quotation below is verbatim from the page named, fetched 2026-09-05 by the harvest's research run (`claude.com/blog/…` dated 2026-07-07; the multi-agent post dated 2025-06-13). Do not paraphrase a quotation into a stronger claim; do not add a claim this task does not list.

- [ ] **Step 1: § The ceiling rule**

Replace the paragraph at line 9 with:

> **Labelled policy, not platform guidance.** Nothing stops an agent definition from naming a higher tier; the platform-side ceilings are an org's model allowlist and, for the built-in Explore agent only, a cap at Opus on the Claude API (`code.claude.com/docs/en/sub-agents` § Built-in subagents › Explore, fetched 2026-09-05). No first-party page states this rule or the allowance below, and the platform's own ladder runs the other way — "start with Claude Opus 5 for most workloads. Use Claude Fable 5.1 for demanding reasoning and long-horizon agentic work, or when your evals on Claude Opus 5 at higher effort still fall short" (`platform.claude.com/docs/en/about-claude/models/overview` § Compare models, fetched 2026-09-05) — while a per-completed-task comparison sometimes argues for the higher tier on the hard step (`platform.claude.com/docs/en/about-claude/models/optimizing-for-cost-and-intelligence` § Compare models on cost per task). The rule stays because escalation should be a deliberate *session-level* choice the operator makes, not something a subagent definition smuggles in; when the comparison says otherwise, escalate the session.

Append to the allowance paragraph (line 11), before its last sentence ("Under a mid-tier main loop…"):

> **The slot is either the main loop or one fresh-context agent**, a per-task call: an agent when the inputs are bulky, the session is long, or the synthesizer should be independent of whoever wrote the prompts; the main loop when the step needs what only the conversation holds or the operator's gate follows immediately. Either way the main loop reads the *product*, verifies the claims it carries forward, and owns triage (`workflows.md` § Subagent dispatch — never delegate the decision). The slot's effort is explicit — `high` for synthesis — never above the session's.

Replace the bracketed posture placeholder (line 13) with:

> **Posture.** [Record the project's posture: which row the main loop runs by default and what a deliberate escalation looks like — dated, with the reason.] The exercised default:
>
> | Main loop | Top-tier agents | Verify / judge | Default worker | Mechanical |
> |---|---|---|---|---|
> | workhorse tier — the baseline | never | workhorse | mid tier | smallest tier |
> | top tier — deliberate escalation, recorded with its date and reason | at most one, per the allowance | workhorse | mid tier | smallest tier |

- [ ] **Step 2: § The role ladder**

Mechanical row's Why (line 21): replace `The "sub-agent tasks" tier; large cost multiple below the workhorse tiers` with `The tier the platform names for "simpler tasks that need the best speed and lowest costs, such as subagents" (`platform.claude.com/docs/en/build-with-claude/effort` § Effort levels, fetched 2026-09-05); volume is the larger lever (§ Fan-out discipline)`.

Insert after the Finders row:

> | Drafting a persistent cascade artifact — a frame, an R-issue set, an ADR, a PR body — or any output nothing downstream checks before it lands | workhorse tier (e.g. Opus) | Measured 2026-09-01: mid-tier drafts ranked last with the most false claims, procedure or contract (`orchestration-reference.md` § Applied instances). The mid tier drafts only what a verifier checks before it lands |

Insert after the table, before the paragraph that begins `**Default is inherit`:

> **The delineation test: tier by who catches the agent's mistakes.** If a verify stage or a judge reads the output before it persists, the mid tier is safe there; if nothing downstream checks it, the workhorse tier drafts it.

Replace the paragraph at line 26 with:

> **The default is the workhorse tier, stated explicitly — not inherit.** Every dispatch — an agent definition's frontmatter, an Agent-tool call, a workflow `agent()` — names its model tier **and** its effort; a worker gets a chosen level, stated. Inherit is not neutral: under a top-tier main loop an unpinned fan-out is a top-tier fan-out (measured 2026-09-01: eleven unpinned drafters consumed half a session's limit with two finished; the tiered re-run finished ten of eleven on a tenth of it — `orchestration-reference.md` § Applied instances). Never pin *above* the session model. A mid-tier finder feeding a workhorse-tier verifier beats an all-workhorse fan-out on cost with negligible quality loss — the verify stage is what makes the cheap finder safe. Anthropic's published multi-agent result is the precedent for that shape: a lead agent over cheaper workers "outperformed single-agent Claude Opus 4 by 90.2% on our internal research eval" — a 4-series result, dated 2025-06-13 ([multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system) § Benefits of multi-agent systems) — not a uniform-strong fan-out.

Line 28: in the sweep parenthetical replace `mid-tier find stage` with `mid-tier find stage at \`medium\`, retried at \`high\`` and `roster read at runtime` with `roster read at runtime on the smallest tier`; append a third exemplar: `; and \`.claude/workflows/finish-ab/finish-ab.js\` (executors and judges at the workhorse tier, model and effort named on every call, an even judge panel split by reading order).`

- [ ] **Step 3: `### Generation notes — verified 2026-09-05; re-verify before re-citing`**

Insert as a subsection at the end of § The role ladder (before `## The effort axis`):

```markdown
### Generation notes — verified 2026-09-05; re-verify before re-citing

Everything here is scoped to the lineup on the fetch date and rots with it. Aliases and prices move; the tier *names* above are stable.

- **Lineup and aliases.** Fable 5.1 (top tier), Opus 5 (workhorse), Sonnet 5 (mid), Haiku 4.5 (smallest) — `platform.claude.com/docs/en/about-claude/models/overview` § Compare models. In Claude Code `opus` resolves to Opus 5 and `fable` to Fable 5.1 (`code.claude.com/docs/en/model-config`).
- **The documented ladder** is Opus 5 → higher effort → Fable 5.1 (overview § Compare models, quoted in § The ceiling rule). Price steps by list price: smallest→mid 2×, mid→workhorse 2.5×, workhorse→top 2× (overview, Pricing row) — "compare models on cost per completed task" (`…/optimizing-for-cost-and-intelligence` § Compare models on cost per task), not per token.
- **No dial on the smallest tier.** The effort page's supported-model list carries no Haiku model (`…/build-with-claude/effort` § Compatibility); an `effort:` pin on Haiku 4.5 is inert.
- **Two 5-series behaviours that change tiering.** Fable 5.1 "calls a search or retrieval tool less often" at `low` (`platform.claude.com/docs/en/models/fable-5-1/whats-new-fable-5-1` § Changed from Claude Fable 5) — search and research roles never run at `low` on it. Opus 5 over-verifies on self-check prose — "If your prompt contains explicit verification instructions ("include a final verification step for any non-trivial task," "use a subagent to verify"), remove them" (`…/prompt-engineering/prompting-claude-opus-5` § Task scope and over-verification) and "do not use subagents to verify or double-check your own work" (§ Controlling subagent spawning). An independent verifier that sees only the artifact and the rubric is a different thing; it is what this kit's verify stages are.
- **Effort names do not carry across models** — "effort level names don't correspond to the same amount of thinking across models" (`…/prompt-engineering/prompting-claude-fable-5-1` § Consider all effort levels); "match by observed thinking length rather than effort name" (`…/prompt-engineering/prompting-claude-sonnet-5` § Calibrating effort and thinking depth). Re-sweep the table below on any model change.
- **Per-role standing defaults**, recorded once; the shipped exemplars carry them:

  | Role | Model | Effort |
  |---|---|---|
  | Mechanical (roster read, inventory, format sweep) | `haiku` | no dial — say so where a pin would go |
  | Finder / gatherer (review finding, research reading) | `sonnet` | `medium`; retry at `high` |
  | Drafter of a persistent artifact | `opus` | `high` |
  | Verify / judge | the session model (workhorse by default) | `high`; `xhigh` for the hardest |
  | The synthesis slot (top-tier sessions only) | `fable` | `high` |
```

- [ ] **Step 4: § The effort axis**

Keep the section's first paragraph (the co-equal dial, the blog's diagnostic question and its citation). Replace the bullet list with:

```markdown
- **Omitting effort is not neutral.** The API default is `high` — "Setting `effort` to `"high"` produces exactly the same behavior as omitting the `effort` parameter entirely" (`platform.claude.com/docs/en/build-with-claude/effort` § How effort works, fetched 2026-09-05) — and the page's first best practice is "Set effort explicitly"; a subagent's `effort:` frontmatter reads "Default: inherits from session" (`code.claude.com/docs/en/sub-agents` § Supported frontmatter fields), so an unpinned worker under an `xhigh` session runs at `xhigh`. Name it.
- `low` — mechanical stages; the platform's own example of the level is "such as subagents" (`effort` § Effort levels). At lower effort the model "would rather ask you for more context than spend tokens figuring something out on its own" (`claude.com/blog/claude-model-and-effort-level-in-claude-code`, 2026-07-07), and a subagent cannot ask (`workflows.md` § Subagent dispatch) — a `low` worker needs a complete brief. Never `low` for search or research on Fable 5.1 (§ Generation notes).
- `medium` / `high` — "use `low` and `medium` liberally as your primary control for token cost and response time wherever your evals show quality holds" (`effort` § Recommended effort levels for Claude Opus 5, whose stated starting point is `high`). `high` is the level for a worker whose output nothing downstream checks, and for drafting a long deliverable: at the top levels a model can draft the whole deliverable in thinking and write it again — "run requests like these at `high`, the recommended starting point, and move to `xhigh` or `max` only where you've measured a quality gain" (`…/prompting-claude-fable-5-1` § Leave room for long outputs at xhigh and max effort).
- `xhigh` / `max` — verify and judge stages only; try `high` before `max`.
- **Not monotonic on agentic work** — keep the current bullet verbatim (higher effort up front often reduces turn count and total cost; some routes do as well at a middle setting; sweep per role).
- **Raise effort before adding prompt scaffolding; re-run failures at higher effort before switching model.** "If you observe shallow reasoning on complex problems, raise effort to `high` or `xhigh` rather than prompting around it" (`…/prompting-claude-sonnet-5` § Calibrating effort and thinking depth). "With Claude Opus 5 at `low`, 16% of tasks failed; with those re-run at the default, about 93% passed for about $0.45 each" (`…/optimizing-for-cost-and-intelligence` § Re-run failures at higher effort).
- **Not every model has the dial** — Haiku 4.5 has none (§ Generation notes). An `effort:` pin on a model without the dial is inert: it advertises a dial that never turns. Tier the model, not the dial.
```

- [ ] **Step 5: § Fan-out discipline and § Anti-patterns**

Replace the first bullet (line 58, `**Let the runtime's cap govern — don't author a lower one.**`) with:

```markdown
- **Know the caps; they differ by surface, and one fails rather than queues.** The Agent tool fails at 20 concurrent subagents by default — "spawning another with the Agent tool fails with `Concurrent subagent limit reached`, and the error tells Claude not to retry" (`code.claude.com/docs/en/sub-agents` § Concurrent subagent limit, v2.1.217+; `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS` raises it). The Workflow runtime queues: "Up to 16 concurrent agents, fewer when Claude Code has fewer CPUs available", 4,096 items per call, 1,000 agents per run, and a `Large workflow` warning "when a workflow schedules more than 25 agents, or its projected token total passes 1.5 million" (`code.claude.com/docs/en/workflows` § Behavior and limits and § Cost, fetched 2026-09-05; the authored-size guideline is `workflowSizeGuideline`). The deterministic caps are `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`, `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS` and the SDK's `max_budget_usd` (2.1.217+; `…/prompting-claude-opus-5` § Controlling subagent spawning); task budgets "are not supported on Claude Code" (`platform.claude.com/docs/en/build-with-claude/task-budgets` § Feature support). Size the fan-out to the work inside those numbers; a throttling observation is a dated rail with its failure signature and a re-check trigger, never a standing cap (`cbk-conventions.md`, dated-empirical-rails).
- **Volume before tier.** "agents typically use about 4× more tokens than chat interactions, and multi-agent systems use about 15× more tokens than chats" (multi-agent research system § Benefits, 2025-06-13); "Agent teams use approximately 7x more tokens than standard sessions when teammates run in plan mode" (`code.claude.com/docs/en/costs` § Manage agent team costs). A price step between tiers is 2–2.5×; a width step is worse. Bound the fan-out first, then tier. What every subagent pays and what a wave shares is `orchestration-reference.md` § Cost terms and run hygiene.
- **Judge panels: an even number, half per reading order, and never rank alone.** Measured 2026-09-03: each judge's first pick tracked its own reading order, so a two-arm rank carried no signal until the panel was balanced; judges score dimensions and report contradicted claims first, and ranks are read beside those (`orchestration-reference.md` § Applied instances; `.claude/workflows/finish-ab/`).
```

Keep the remaining bullets (contractual limits off the live tool description; keep the retry pass; no silent caps; pilot on a slice; ground existence claims). In § Anti-patterns, replace the row `Pinning models on every \`agent()\` call by reflex | Default is inherit; …` with `Omitting the model and effort on every \`agent()\` call ("inherit is safe") | The default is the workhorse tier, stated, and effort named; under a top-tier main loop an unpinned fan-out is a top-tier fan-out`; replace the row `Fan-out sized by reflex rather than by the work | Pilot on a slice and set a budget directive — the runtime queues the excess, but the tokens are still spent` with `Fan-out sized by reflex rather than by the work | Pilot on a slice; the Agent tool fails past its cap and the workflow runtime queues past its — either way the tokens are spent`; add two rows:

```markdown
| Self-check prose in a worker prompt ("verify your work", "use a subagent to double-check") | Over-verification on Opus 5 (§ Generation notes); an independent verifier that sees only the artifact and the rubric is the kit's shape |
| Reusing an effort table after a model change | Effort names do not carry across models; re-sweep and match by observed thinking length (§ Generation notes) |
```

- [ ] **Step 6: Budget, verify, commit**

Run the verification block; read the `always-loaded:` line for `orchestration.md` and the total. If `orchestration.md` grew by more than 6 KB, move the § Generation notes' per-role table's surrounding bullets (not the table) to `orchestration-reference.md` under a pointer heading — the table and the rules stay in the contract. Then:

```bash
git add .claude/rules/orchestration.md
git commit -m "feat(orchestration): the workhorse tier is the stated default, every dispatch names model and effort, the cascade-drafting row and the delineation test, the caps by surface, dated generation notes with per-role defaults (C11)

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 6: The reference half, the sister rules, the agents and the sweep

**Files:**
- Modify: `.claude/rules/orchestration-reference.md` (resolution order as a dated rail; § Cost terms and run hygiene; § Applied instances with the four dated observations; § When to update; § Primary sources re-verified)
- Modify: `.claude/rules/workflows.md:105` ("Never delegate the decision")
- Modify: `.claude/agents/Explore.md` (description; the no-dial sentence)
- Modify: `.claude/agents/adr-conformance-reviewer.md`, `logging-discipline-reviewer.md`, `cascade-rule-reviewer.md` (`effort: high` in frontmatter)
- Modify: `.claude/rules/pr-review.md:63` (the authoring frontmatter shape names `effort: high`)
- Modify: `.claude/workflows/review-sweep.js` (`FIND_EFFORT` / `RETRY_EFFORT`; the roster agent's no-dial comment; the meta Find line)
- Modify: `.claude/rules/tooling.md` — **no edit**; recorded in the PR body (D-P3-7)

**Interfaces:**
- Consumes: Task 5's § Generation notes table (the values pinned here must match it).
- Produces: `grep -q 'FIND_EFFORT' review-sweep.js && grep -q 'RETRY_EFFORT' review-sweep.js`; `effort: high` in all three reviewers and none in `Explore.md`; the section heading `## Cost terms and run hygiene` and the phrase `Never delegate the decision` (Task 8 greps).

- [ ] **Step 1: `orchestration-reference.md`**

§ The three surfaces + resolution order: add a fourth surface and replace the resolution paragraph:

```markdown
4. **Skills** — `model:` and `effort:` frontmatter, honoured for the rest of the turn ("The override applies for the rest of the current turn and is not saved to settings"); `context: fork` runs the skill in a subagent (`agent:` picks the type); `${CLAUDE_EFFORT}` substitutes the active level into the skill body (`code.claude.com/docs/en/skills` § Frontmatter reference and its substitution table, fetched 2026-09-05).

Resolution (highest wins) — **a dated rail, 2026-09-05**: the per-invocation param → the definition's frontmatter → `CLAUDE_CODE_SUBAGENT_MODEL` → the main-conversation model, all checked against the org's model allowlist (an excluded value is skipped and the agent runs on the inherited model). This order dates from v2.1.251 — "Before v2.1.251, `CLAUDE_CODE_SUBAGENT_MODEL` came first in this order and overrode both the per-invocation parameter and the frontmatter, including `model: inherit`" (`code.claude.com/docs/en/sub-agents` § Choose a model) — and third-party guides still print the old order; verify against the version you run. `CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1` (v2.1.257+) applies one model "to every subagent, teammate, and workflow agent" (§ Run every subagent on one model) — the structural lever when the ceiling rule must be enforced rather than followed. The per-invocation override is the escape hatch: a frontmatter-pinned cheap agent can be promoted for one hard call without editing its definition. Re-verify this order against the platform's current [sub-agents doc](https://code.claude.com/docs/en/sub-agents) after harness upgrades — subagent defaults have moved across versions (this order, the background-vs-foreground default, thinking inheritance, override persistence).
```

New section after it:

```markdown
## Cost terms and run hygiene

The terms the contract half's § Fan-out discipline points at; all fetched 2026-09-05.

- **What every subagent pays.** A non-fork subagent loads "every level of the CLAUDE.md hierarchy the main conversation loads, including `~/.claude/CLAUDE.md`, project rules, `CLAUDE.local.md`, and managed policy files. The built-in Explore and Plan agents skip this" (`code.claude.com/docs/en/sub-agents` § What loads at startup). The always-loaded byte count the conventions' verification block prints is paid per agent launched.
- **What a wave shares.** "Two agents that run with the same model, effort level, agent type, tools, output schema, and working directory build the same tools-and-system-prompt prefix, so an agent that starts after a matching sibling's response has begun reads that sibling's cache" (`code.claude.com/docs/en/workflows` § Prompt caching in a fan-out). Vary the prompt across a wave, not the pins.
- **Background is the interactive default.** "Where fork mode is on, as it is by default in an interactive session, Claude Code runs the subagent in the background, forks and non-fork subagents alike, and Claude can't ask for the foreground" (`sub-agents` § Run subagents in foreground or background, v2.1.198+). Request every independent dispatch in one turn.
- **Junk structured output is a script-side problem.** A schema-bound agent that returns nothing, or a shape the script did not expect, is filtered and logged by the script — `review-sweep.js`'s roster degrade and `finish-ab.js`'s dropped-arm log are the exemplars; the retry pass, not the prompt, is the remedy.
- **A suspended host stalls a fan-out silently.** Record the run id from the tool result; after a sleep or a kill resume with `resumeFromRunId` (unchanged agents replay from cache); a run that cannot be resumed is re-launched on the unfinished slice, never on the whole set.
- **Hooks see dispatches.** `PreToolUse` matches `Agent` and `Workflow` and can `allow` / `deny` / `ask` / `defer`, or rewrite the call through `updatedInput` ("Replaces the entire input object, so include unchanged fields alongside modified ones"); a hook's `ask` "also forces a permission prompt in auto mode" (`code.claude.com/docs/en/hooks` § PreToolUse decision control, v2.1.211+). The kit's launch-root guard is the exemplar.
```

§ Applied instances: keep the heading; replace the body with a lead-in, four dated bullets, the exemplar bullets and the placeholder. Every bullet below is sanitized — dates, counts and measures; no repository, issue, workstream, package or run id — and is not to be "improved" with any of those:

```markdown
**Kit-shipped dated observations** — from the exercised runs the kit harvested (the tiers named by role, never by repository); re-verify on your own runs and restamp:

- **2026-09-01 — the measurement behind the explicit default.** A foundation-doc workflow launched with `model` omitted on every agent under a top-tier main loop ran eleven top-tier drafters. Same workflow, same eleven prompts, same inherited `xhigh` effort, two configurations, read off the session-usage meter: all top-tier — **50% of the session limit consumed at 2 of 11 finished** (killed by hand); tiered, six workhorse + five mid-tier + one top-tier critic — **10% at 10 of 11 finished**. About 5× per agent launched, more per finished draft. Parallel drafting at the top tier at escalated effort was session-ending, not a cost trade-off. Untested: the top tier at `low`.
- **2026-09-01 — framing A/B: the contract beat the procedure at the workhorse and top tiers; the mid tier cannot draft.** Six drafters, identical inputs and brief, two arms (the procedure with its references vs a 61-line contract plus the template) at three tiers; three blind workhorse judges at `high` read the six anonymised in three orders and verified claims against the sources. Mean rank: contract·workhorse@high **1.3**, contract·top@low **1.7**, procedure·workhorse@high 3.3, procedure·top@low 3.7, procedure·mid@high 5.3, contract·mid@high 5.7; flagged false claims summed over three judges 0, 0, 3, 3, 8, 8. The arm signature was prescriptive rough issues (every procedure draft 3.3 on the intents dimension vs 5.0 / 3.7 / 4.7). Output was under 0.5% of every drafter's tokens; the top tier's bill was 78% cache writes — fewer, larger turns (34 vs 52) — for a top:workhorse cost ratio of 3.2× pooled; the drafter handed the references read 2.7× the cached tokens of the one handed the contract and ranked worse. Consequences: the cascade-drafting ladder row, the contract/procedure split, the drafter reads the contract.
- **2026-09-02 — rough-in A/B: the contract won narrowly; the artifact contract held in both arms.** Four drafters (workhorse@high and top@low per arm; the mid tier dropped on the framing evidence), three blind workhorse judges (two `high`, one `xhigh`), three reading orders. Mean rank: contract·top@low **2.0**, contract·workhorse@high 2.3, procedure·top@low 2.7, procedure·workhorse@high 3.0; flagged claims equal at six per arm. Every output carried the executor's eight headings and no code in an Implementation section — what separated the arms was run material inside the artifact (a ~150-line re-quoted inheritance block), one frame rule re-decided, and fabricated quantities from a template diff. The `xhigh` judge found the most flagged claims (9 vs 6 and 5) for 15% more cost and dissented on ranking — thorough on verification, not a tie-breaker on rank. Consequences: numbered `[R<#>.AC<m>]` criteria with tags keyed to them, the no-run-material test, the one-way doors held in the main loop. Seven agents, 29 minutes.
- **2026-09-03 — `/finish` A/B: a tie on rank that reading order decided, a win for the contract on contradicted claims and commit discipline, equal cost.** Two workhorse executors at `high`, each in its own git worktree, identical inputs and brief; arm A the procedure, arm B a 112-line contract, told not to open the command or the skills; no device runs, no push, no PR (the plan gate became `PLAN.md`, the PR `PR_BODY.md`). Four blind workhorse judges, two `high` and two `xhigh`, two per reading order, ran the check task in both worktrees themselves and verified red-first from the committed test bodies. Mean rank 1.50 for both — **each judge's first pick tracked its own reading order** (the `high` pair preferred the arm read second, the `xhigh` pair the arm read first); the first three judges were unbalanced two-to-one and the fourth exposed the effect. Order-independent measures: contradicted claims A 12 / B 7 (distinct about 5 / 3); commits A 8 with review Applies batched / B 13, one per finding; untagged tests A 0 (two mis-tagged) / B 4; PR-body words A 2,422 / B 1,899; cost equal (about $50 each in about 30 minutes; judges $18–23 each). Both arms committed the red tests first, invoked both floor skills without their fan-out — the Agent tool is unavailable inside a dispatched agent — and recorded the dropped coverage. Decision: contract-first on the order-independent measures and for consistency with the two phases above, the pre-registered "rank win in both phases" rule notwithstanding. Two harness lessons: an even panel split by reading order; the floor's real coverage is measurable only from a session that can dispatch agents.

**Shipped exemplars:**

- `.claude/agents/Explore.md` — the mechanical tier (`haiku`, no effort dial); promote per-invocation for a genuinely hard scan.
- `.claude/workflows/review-sweep.js` — roster on `haiku`; finders `sonnet` at `medium`, retried at `high`; verify at the session model, `high`.
- `.claude/workflows/finish-ab/` — executors and judges at the workhorse tier, effort named per call; an even judge panel split by reading order.
- `.claude/workflows/agent-cost.py` — per-agent tokens and list-price cost from a run's transcripts, priced per answering model; the source of every cost figure above from 2026-09-02 on.

[Record the project's own pins here as they are made, with dates and the reason — e.g. "a reviewer promoted to the workhorse tier after observed misses on <date>". An empty list means no pins beyond the exemplars — a valid state, not a gap.]
```

§ When to update this file: add `- A model change — re-sweep the per-role table in \`orchestration.md\` § Generation notes, matched by observed thinking length, and restamp its date.`

§ Primary sources: change the lead sentence to "Verified 2026-09-05 by the harvest's research run; **re-fetch before re-citing** rather than trusting the summary." and replace the table with rows for every page the two halves now cite:

| Source | What it grounds |
|---|---|
| `code.claude.com/docs/en/sub-agents` | Resolution order (v2.1.251), `CLAUDE_CODE_SUBAGENT_MODEL_FORCE` (v2.1.257), the Explore cap, `effort` frontmatter inheritance, the concurrent-subagent limit (v2.1.217), what loads at startup, background default (v2.1.198) |
| `code.claude.com/docs/en/workflows` | Workflow caps, the `Large workflow` warning, `workflowSizeGuideline`, prompt caching in a fan-out |
| `code.claude.com/docs/en/costs` | Agent-team token multiple |
| `code.claude.com/docs/en/skills` | Skill `model` / `effort` / `context: fork`, `${CLAUDE_EFFORT}` |
| `code.claude.com/docs/en/hooks` | `PreToolUse` decisions, `updatedInput`, `ask` in auto mode |
| `code.claude.com/docs/en/model-config` | Aliases (`opus`, `fable`) |
| `platform.claude.com/docs/en/build-with-claude/effort` | The `high` default, set-it-explicitly, the levels table, Opus 5 recommendations, the supported-model list |
| `platform.claude.com/docs/en/about-claude/models/overview` | The lineup, the pricing row, the documented ladder |
| `platform.claude.com/docs/en/about-claude/models/optimizing-for-cost-and-intelligence` | Cost per completed task; re-running failures at higher effort |
| `platform.claude.com/docs/en/build-with-claude/task-budgets` | Not supported on Claude Code |
| `platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5` | Over-verification; controlling subagent spawning; the deterministic caps |
| `platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5` | Raise effort before prompting around it; match by thinking length |
| `platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1` | Effort names across models; long outputs at `high` |
| `platform.claude.com/docs/en/models/fable-5-1/whats-new-fable-5-1` | Searches less at `low` |
| `platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices` | Specificity matched to fragility; 500-line SKILL.md; test with every model |
| `claude.com/blog/claude-model-and-effort-level-in-claude-code` (2026-07-07) | The effort-vs-model heuristic; asks rather than digs at lower effort |
| `anthropic.com/engineering/multi-agent-research-system` (2025-06-13, 4-series) | The lead-plus-cheaper-workers result (90.2%); the 4× and 15× multiples |

- [ ] **Step 2: `workflows.md`, `Explore.md`, the reviewers, `pr-review.md`**

`workflows.md:105` — replace the paragraph with:

> **Never delegate the decision.** The subagent gathers — or, under a top-tier session, one fresh-context synthesis agent may assemble the product (the permitted slot, `orchestration.md` § The ceiling rule); you read the product rather than the raw inputs, verify the claims you carry forward, and own triage. Don't write "based on your findings, fix the bug" — write "Read `<file>:<line>`. The bug is that X happens when Y. Fix it by changing Z." If you can't write that specific instruction, the subagent hasn't given you enough — read the findings, then write the instruction.

`Explore.md` — the description's parenthetical `the built-in otherwise inherits the session model, overpaying for scans in high-tier sessions` becomes `the built-in inherits the session model capped at Opus on the Claude API (code.claude.com/docs/en/sub-agents § Built-in subagents, 2026-09-05), so a top-tier session still pays the workhorse rate for scans; this override keeps them on the smallest tier, which that page endorses`. Append to the body: `No \`effort:\` pin: Haiku 4.5 has no effort dial (\`.claude/rules/orchestration.md\` § Generation notes).`

The three reviewers: insert `effort: high` on the line after `model: sonnet`. `pr-review.md:63`: the frontmatter shape `(\`tools: Read, Glob, Grep, Bash\` [+ \`Skill\` if it invokes one], \`model: sonnet\`, \`memory: project\`)` gains `, \`effort: high\` — a direct dispatch has no verify stage behind it (\`orchestration.md\` § The role ladder)` before the closing parenthesis.

- [ ] **Step 3: `review-sweep.js`**

Near the top, after `MAX_VERIFY`: `const FIND_EFFORT = params.findEffort ?? "medium"; // finders are verified downstream (orchestration.md § Generation notes)` and `const RETRY_EFFORT = params.retryEffort ?? "high";`. Change `findOnce` to `(dim, effort = FIND_EFFORT, retry = false)` with `label: \`find:${dim.key}${retry ? ":retry" : ""}\`` and an unconditional `effort` in its opts (drop the `...(effort ? { effort } : {})` spread); the retry call becomes `findOnce(d, RETRY_EFFORT, true)` and its log line reads `retrying once at effort ${RETRY_EFFORT}`. On the roster `agent()` call add the comment `// haiku: no effort dial — orchestration.md § Generation notes`. In `meta.phases`, the Find entry's detail gains `; effort medium, retry high`. Then `node .claude/workflows/tests/review-sweep-accounting.mjs` — if a scenario pinned the old retry label or log text, update that scenario to the new strings (the accounting must not change).

- [ ] **Step 4: Verify and commit**

Run the verification block. Confirm `orchestration.md` and `orchestration-reference.md` cite no page this task did not list (`grep -o 'code.claude.com/docs/en/[a-z-]*\|platform.claude.com/docs/en/[a-z/-]*' .claude/rules/orchestration*.md | sort -u` matches the sources table). Then:

```bash
git add .claude/rules/orchestration-reference.md .claude/rules/workflows.md .claude/rules/pr-review.md .claude/agents .claude/workflows/review-sweep.js .claude/workflows/tests/review-sweep-accounting.mjs
git commit -m "feat(orchestration): the reference half — resolution order as a dated rail, cost terms and run hygiene, four dated applied instances, sources re-verified; 'never delegate the decision'; every agent names its effort; sweep finders at medium, retry high

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 7: The scoped prompt audit — per-step calibration, not a blanket de-prescription

**Files:**
- Modify: whichever of `.claude/skills/*/SKILL.md`, `.claude/skills/*/references/{contract,procedure}.md`, `.claude/commands/*.md`, `.claude/agents/*.md`, `.claude/rules/*.md` the audit's applied edits touch (one commit)
- Create (scratchpad, not committed): `<scratchpad>/p3-prompt-audit.md` — the audit report and proposed diff

**Interfaces:**
- Consumes: the bundled `claude-api` skill's `prompt-audit` subcommand (non-interactive; Step 0 states its scope and target assumptions in the report).
- Produces: the § Prompt audit section of the PR body (counts kept / softened / removed per pattern, every kept ALL-CAPS class with its reason); the guard lines Task 8 adds stay green.

**Baseline (grep, 2026-09-06, before Tasks 1–6 — re-run after them):** self-check phrases (`double-check`, `verify your work`, `use a subagent to verify`, `check your work`) — **none** in skills, commands, agents or rules (one adjacent hit, `scaffold/references/brownfield_audit.md:82` "re-check or …", is an instruction to re-read a claimed resource, not self-verification — keep); "if/when in doubt" tool defaults — **none** in `tooling.md`; the ALL-CAPS pressure tokens (`MUST|NEVER|ALWAYS|CRITICAL|IMPORTANT`) per file: finish.md 20, framing/SKILL.md 25, rough-in/SKILL.md 27, cbk-conventions-reference.md 36, pr-review.md 19, knowledge-backend.md 14, blueprint 12, scaffold 12, adr-new 9, the rest ≤ 8.

- [ ] **Step 1: Run the audit**

Invoke the `claude-api` skill with the argument string:

`prompt-audit — scope: .claude/skills (SKILL.md and references/contract.md, references/procedure.md), .claude/commands, .claude/agents, .claude/rules; target model: Claude Opus 5 as the worker and main-loop default with Claude Fable 5.1 as the escalation tier (.claude/rules/orchestration.md § Generation notes); produce the report and the proposed diff only — apply nothing.`

Save the report to `<scratchpad>/p3-prompt-audit.md`. The report must list every finding as `file:line`, the pattern, why it is obsolete for the target, and a confidence.

- [ ] **Step 2: Apply by the calibration below — never the whole diff**

| Pattern the audit flags | Decision | Why |
|---|---|---|
| Self-check prose ("double-check", "verify your work", "use a subagent to verify", "include a final verification step") | **Remove**; where the sentence carried a real check, point at the independent verifier the phase already has (`references/contract.md` § Before the gate; the sweep's verify stage) | Opus 5 over-verifies on these (`prompting-claude-opus-5` § Task scope and over-verification, 2026-09-05); the kit's verification is an independent agent that sees only the artifact and the rubric |
| Pressure language (ALL-CAPS `MUST` / `NEVER` / `ALWAYS` / `CRITICAL` / `IMPORTANT`) | **Keep** where the token marks a hook-enforced invariant, a one-way door (a planning-backend write, a commit, a push), the review floor's "actually run", or a must-be-absent portability rule; **soften** to a plain imperative everywhere else. Each kept token is listed in the report with its reason | Specificity is matched to fragility and variability (`agent-skills/best-practices` § Set appropriate degrees of freedom); a one-way door is fragile, a preference is not |
| Step choreography for a judgment task (a numbered "first X, then Y, then Z" that orders *deciding*, not *mechanics*) | The three contract-first phases are re-shaped by Tasks 1–3. For the remaining skills (consultation, scaffold, blueprint, adr-new) and commands (intake, enrich, pr-respond): **restate** a sequence that orders judgment as intent + constraints + the tests the output must pass; **keep** the order of mechanics (gates, commits, provisioning, atomic transitions, hook-guarded steps) | The measured effect (2026-09-01: procedure-following drafts ranked third and fourth with prescriptive output) is on judgment, not on mechanics; the one-way doors are mechanics |
| Blanket tool defaults ("if in doubt use X", "always reach for X") | **Rewrite** as a condition. Baseline: none in `tooling.md`; "the rules file is authoritative when in doubt" (finish, pr-respond) and "configure pre-filters … when in doubt" (`pr-review.md:88`) are precedence statements, not tool defaults — keep | C11's tooling bullet; a condition tells the model *when*, a default tells it *always* |
| Length / verbosity instructions tuned for an earlier generation | **Surface** in the PR body, do not edit, unless the audit shows a concrete regression | `models/opus-5/migration-guide` § Re-tune length and verbosity prompts (2026-09-05) says re-tune after measuring, not pre-emptively |

Out of scope for edits, whatever the audit says: quotations inside rule files (a citation is not a prompt); `references/templates/*` (artifact templates, not prompts — note, don't edit); `.claude/hooks/*`; the verification block; the frontmatter `description:` fields (their triggers are deliberate — see `CLAUDE.md` § When the user invokes a skill).

- [ ] **Step 3: Re-run the baseline greps, verify, commit**

```bash
grep -rniE "double-chec[k]|use a subagent to verif[y]|verify your (own )?wor[k]" .claude/skills .claude/commands .claude/agents   # expect none
for f in .claude/skills/*/SKILL.md .claude/commands/*.md .claude/rules/*.md; do printf '%-60s %s\n' "$f" "$(grep -cE '\b(MUST|NEVER|ALWAYS|CRITICAL|IMPORTANT)\b' "$f")"; done   # the after-counts for the PR body
```

Run the verification block (green). Commit the applied edits as one commit:

```bash
git add -A .claude
git commit -m "refactor(prompts): scoped audit for the 5-series — self-check prose removed, pressure language kept only on one-way doors and hook-enforced invariants, judgment choreography restated as intent and tests (report in the PR body)

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

If the audit applied nothing (every finding kept), commit nothing and say so in the PR body — a clean audit is a valid result.

---

### Task 8: Verification block, indexes, the bootstrap posture row

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md` § Verification (new plain lines inside the fence)
- Modify: `CLAUDE.md` (§ Repo layout tree, the skill-pattern paragraph, § Architectural principles, § Working in this repo)
- Modify: `README.md` (lines 269, 289, 295–298, 344)
- Modify: `.claude/skills/scaffold/references/bootstrap_checklist_template.md` (one row: the orchestration posture)

**Interfaces:**
- Consumes: every artifact of Tasks 1–7 by the exact names above.
- Produces: a green block that fails if any of them regresses; the always-loaded total for the PR body.

- [ ] **Step 1: The block — contract-first checks**

Insert immediately after the line beginning `diff <(awk '/^--- BEGIN TEMPLATE ---/` (the executor byte-parallel check, ~481):

```bash
# Contract-first phases (P3): the contract and the procedure exist and SKILL.md routes to both; every
# SKILL.md body stays under 500 lines (agent-skills best-practices § Progressive disclosure, 2026-09-05);
# the executor's contract names its procedure and the procedure is byte-parallel with its bundled template.
for s in framing rough-in; do for f in contract procedure; do [ -f .claude/skills/$s/references/$f.md ] || { echo "$s lacks references/$f.md"; exit 1; }; grep -q "references/$f.md" .claude/skills/$s/SKILL.md || { echo "$s/SKILL.md does not route to references/$f.md"; exit 1; }; done; done
for f in .claude/skills/*/SKILL.md; do n=$(wc -l < "$f"); [ "$n" -lt 500 ] || { echo "$f is $n lines (the 500-line limit)"; exit 1; }; done
grep -q 'finish-procedure.md' .claude/commands/finish.md || { echo "commands/finish.md does not name its procedure"; exit 1; }
diff <(awk '/^--- BEGIN TEMPLATE ---/{flag=1; next} flag' .claude/skills/rough-in/references/finish-procedure.md) .claude/commands/finish-procedure.md >/dev/null || { echo "commands/finish-procedure.md and its bundled template have drifted"; exit 1; }
```

- [ ] **Step 2: The block — harness, dispatch and prompt guards**

Insert immediately after the line `node .claude/workflows/tests/review-sweep-accounting.mjs || …` (~489):

```bash
# The harness exemplars: the A/B script parses and refuses an unbalanced panel; the cost reader prices per
# answering model and names an unpriced row instead of zeroing it. Node and python3 are required.
node .claude/workflows/tests/finish-ab-shape.mjs || { echo "finish-ab.js does not parse or its panel guard regressed"; exit 1; }
bash .claude/workflows/tests/agent-cost-fixture.sh || { echo "agent-cost.py regressed on the fixture"; exit 1; }
# Every dispatch names its model and its effort (orchestration.md § The role ladder): agent definitions
# carry both, except a model without the dial, which carries none; the sweep names both effort constants;
# the orchestration contract keeps its P3 sections.
for a in .claude/agents/*.md; do grep -q '^model:' "$a" || { echo "$a names no model"; exit 1; }; if grep -q '^model: haiku' "$a"; then absent grep -n '^effort:' "$a"; else grep -q '^effort:' "$a" || { echo "$a names no effort (orchestration.md § The role ladder)"; exit 1; }; fi; done
{ grep -q 'FIND_EFFORT' .claude/workflows/review-sweep.js && grep -q 'RETRY_EFFORT' .claude/workflows/review-sweep.js; } || { echo "review-sweep.js does not name its finders' effort"; exit 1; }
{ grep -q 'The default is the workhorse tier, stated explicitly' .claude/rules/orchestration.md && grep -q '^### Generation notes' .claude/rules/orchestration.md && grep -q '^## Cost terms and run hygiene' .claude/rules/orchestration-reference.md && grep -q 'Never delegate the decision' .claude/rules/workflows.md; } || { echo "the orchestration rule lost a P3 section"; exit 1; }
# No self-check prose on a prompt surface (rules are excluded: they quote the pattern as a citation) and no
# blanket tool default in tooling.md (C11). The literals split themselves so this line never matches.
absent grep -rniE "double-chec[k]|use a subagent to verif[y]|verify your (own )?wor[k]" .claude/skills .claude/commands .claude/agents
absent grep -niE "(if|when) in doub[t],? (use|reach for)" .claude/rules/tooling.md
# The bootstrap checklist prompts for the orchestration posture (#34).
grep -q 'Orchestration posture' .claude/skills/scaffold/references/bootstrap_checklist_template.md || { echo "the bootstrap checklist lacks the orchestration-posture row"; exit 1; }
```

Negative-test two of them before moving on: temporarily remove `effort: high` from one reviewer → the block must fail with `names no effort`; restore. Append a 500-line filler to a SKILL.md → must fail with `the 500-line limit`; restore (`git checkout -- <file>`).

- [ ] **Step 3: The bootstrap row**

In `.claude/skills/scaffold/references/bootstrap_checklist_template.md`, beside the existing rule-file disposition items (the P1/P2 rows — find them with `grep -n "Reviewer agent-memory\|rule-file disposition\|orchestration" …`), add: `- [ ] **Orchestration posture** recorded in \`.claude/rules/orchestration.md\` § The ceiling rule — which row the main loop runs by default and what a deliberate escalation looks like, dated with the reason.`

- [ ] **Step 4: `CLAUDE.md` and `README.md`**

`CLAUDE.md`:
- § Repo layout tree: after `│   ├── finish.md …` add `│   ├── finish-procedure.md        ← the executor's procedure, read on demand (finish.md is the contract)`; change `framing/SKILL.md + references/` and `rough-in/SKILL.md + references/` to `+ references/ (contract.md, procedure.md, …)`; the `workflows/` line becomes `workflows/ ← saved orchestrations (review-sweep) and harness exemplars (finish-ab/ two-arm A/B, agent-cost.py) with their stub tests`.
- The paragraph "Each skill follows the same pattern…" gains: *The three producing phases — framing, rough-in and `/finish` — are **contract-first**: `references/contract.md` (for the executor, `commands/finish.md` itself) is the drafting read, stating what the artifact must contain and the tests it must pass; `references/procedure.md` (`commands/finish-procedure.md`) is the step-by-step on demand; `SKILL.md` routes.*
- § Architectural principles, after the "Rough-in's specs target Claude Code plan mode" bullet: `- **Contract-first for the producing phases.** A drafter reads the contract, drafts the whole artifact, and one fresh-context verifier attacks it before the gate; the gate carries a decision list. The one-way doors stay in the main loop. The evidence is dated in \`.claude/rules/orchestration-reference.md\` § Applied instances. Edits to a contract change every future artifact — treat them as the contract they are.`
- § Working in this repo, first bullet: "When editing a `SKILL.md`" → "When editing a `SKILL.md`, a `references/contract.md` or a `references/procedure.md`".

`README.md`: line 269's Phase 6 sentence gains "— contract-first: `finish.md` is the contract, `finish-procedure.md` the procedure on demand"; the tree at 289 and 295–298 mirrors the CLAUDE.md edits; line 344's pattern sentence gains the same contract-first clause.

- [ ] **Step 5: Verify, budget, commit**

Run the verification block; record `always-loaded total:` for the PR body. Run the reference-existence loop from Task 1 Step 3 against both skills once more (Task 3's `finish-procedure.md` now exists). Then:

```bash
git add .claude/rules/cbk-conventions-reference.md .claude/skills/scaffold/references/bootstrap_checklist_template.md CLAUDE.md README.md
git commit -m "chore(kit): verification pins for the contract-first phases, the harness exemplars and the effort rule; index and README sweep; bootstrap posture row

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 9: Review pass (the floor, once, with the bounded sweep) and the draft PR

**Files:**
- Modify: whatever the triage applies (one commit per finding, or a focused group commit named in the PR body)
- Create (scratchpad): `<scratchpad>/p3-pr-body.md`

**Interfaces:**
- Consumes: `pr-review.md § The floor` (the `## Review gate` shape), `review-sweep.js` (`args: {base, files, finders}`), P2's PR body as the shape to mirror.

- [ ] **Step 1: `/simplify`, as a skill invocation, on `git diff feat/harvest-3-p2-review-gate...HEAD`**

Triage by the four-class rubric; Apply items one commit each (or one focused group commit per surface, listed by SHA); re-run the verification block after each.

- [ ] **Step 2: `pr-review-toolkit:review-pr` (no args) and the sweep, concurrently**

The sweep's planned count must stay ≤ 25: `1 roster + 8 finders + up to 8 retries + up to 8 verifiers`. Finders = the three roster reviewers + the four toolkit dimensions the workflow carries + **one** caller finder: *citation fidelity* — "every quoted string in `.claude/rules/orchestration.md` and `orchestration-reference.md` appears verbatim in the harvest's research digest (`<scratchpad>/research-digest.md`) or the saved pages beside it, and every cited section heading exists on the page; report a paraphrase presented as a quote, a wrong section, or a claim the digest marks unquoted (the ultracode exemption; a first-party 'independent verifier' endorsement)". Pass `files` as the pre-filtered changed-path list (`git diff --name-only feat/harvest-3-p2-review-gate...HEAD` minus nothing — no generated or lock files on this diff). Record the `gateLine` the workflow returns.

- [ ] **Step 3: Triage, then the PR body**

Write `<scratchpad>/p3-pr-body.md` in P2's shape: a two-paragraph summary; `Closes #34`, `Closes #41`, `Closes #42`, `Closes #43`; **Basis and declined asks** — issue-driven vs spec-driven, then the literal asks not implemented with the reason: #43's cost-reference section (the kit ships no cost table; the reader's header carries dated prices), #34's "every `agent()` call pins `opus`" (the rule states the default and the shipped exemplars pin; the block greps the shipped surfaces, a project's future workflows are its own), the exercised template excluding the procedure (D-P3-1), the exercised roadmap clause (D-P3-6), the `tooling.md` rewrite (D-P3-7: already conditions; guard added); the four departures from the spec's C11 wording where a claim could not be quoted (the ultracode exemption omitted; the verifier architecture cited as the kit's shape, not a page's recommendation; `~7×` cited to `costs.md` § Manage agent team costs, verified in the saved page; the skill `effort` / `context: fork` / `${CLAUDE_EFFORT}` rows verified in the saved skills page); **Review gate** (three lines; the sweep's transcribed); **Instruction budget** (before / after, from the block's `always-loaded total:` — Task 5's growth is a budget decision, recorded); **Prompt audit** (Task 7's counts and kept-token classes); **Triage** (counts per class; headline Apply items; every non-actioned finding with its reason); **Hand-off to P4**: add the roadmap-row clause to `commands/finish.md` item 8 and to the rough-in contract's item 6 when C10 lands the roadmap; P2's open real-dispatch row is unchanged by this PR. Spec and plan paths at the foot.

- [ ] **Step 4: Push and open the draft PR against the P2 branch**

```bash
git push -u origin feat/harvest-3-p3-contract-first
gh pr create --draft --base feat/harvest-3-p2-review-gate --title "feat: harvest 3 P3 — contract-first cascade, explicit orchestration defaults (C4 + C11)" --body-file <scratchpad>/p3-pr-body.md
```

Retarget to `main` after #54 and #55 merge (`gh pr edit <N> --base main`). Hand off with the PR URL, the triage counts in one line, the three `## Review gate` lines verbatim, the Surface and Defer entries verbatim, and the one next action (the operator flips #54, then #55, then this).

---

## Self-review against the spec

**Spec coverage — C4:**

| Spec sentence | Task |
|---|---|
| Framing, rough-in, `/finish` each become a contract + a procedure; `SKILL.md` reduced to routing, inputs, rigor modes, the rules no mode may skip | 1, 2, 3 |
| The framing contract lifted from the exercised copy (greps clean) | 1 Step 2 |
| The rough-in and executor contracts de-projected at three hedged lines | 2 Step 2 (the type-flag line); 3 Step 2 (the mechanism-verification anecdote, the roadmap carve-out, the A/B narrative) |
| The bundled executor template and the live command edited in the same change with the drift check kept | 3 Steps 3 and 5; 8 Step 1 |
| Verify before the gate; the decision list; the drafter's manifest; no run material; the coverage map; `[R<#>.AC<m>]` citing `[F<#>.AC<n>]` with tags keyed to them; dependencies identifiers only; one-way doors in the main loop; project-level overrides; the executor's inputs read-in-full, its closing tests, claims-match-code | 1 (contract § Before the gate, § What the drafter returns); 2 (contract items 3, 4, 7, § The tests…, SKILL.md § two one-way doors, § Project-level overrides); 3 (contract § Read in full…, § The tests every finish must pass) |
| Every dispatch names model and effort; a worker's default stated (omitting effort is `high`); cascade drafting workhorse-tier; the mid tier drafts only what a verifier checks; tier by who catches the mistakes; generation-scoped advice in a dated subsection; "never delegate the decision"; even judge panels that never rank alone; junk structured output script-side; suspended host / resume | 5 (Steps 2–5); 6 (Step 1 § Cost terms, Step 2 `workflows.md`) |
| Harness exemplars: the two-arm A/B (worktree isolation, anonymised arms, balanced judges, gate-to-decision brief) and the cost reader (per answering model; unpriced never zeroed; self-dated prices) | 4 |
| Prompt audit, scoped, per-step calibration | 7 |
| Recorded honestly: #41's decision rule and the `/finish` tie | 6 Step 1 (the 2026-09-03 bullet) |

**Spec coverage — C11:** effort default and explicit naming (5 Steps 3–4); resolution order v2.1.251 and `FORCE` as a dated rail (6 Step 1); the Explore cap and the `model: haiku` endorsement, the "no platform-side tier" parenthetical gone (5 Step 1; 6 Step 2); the caps named, "let the runtime queue the excess" and "set a budget directive" gone (5 Step 5); economics per completed task, the ladder's "large cost multiple" gone (5 Steps 2–3); the cost terms (6 Step 1); per-role standing defaults re-swept on a model change (5 Step 3; 6 Step 1 § When to update); the verification line — self-check prose removed, the independent verifier as the kit's shape (5 Step 3; 7); specificity to fragility, `SKILL.md` < 500, test with every model (1 Step 4; 2 Step 4; 7; 8 Step 1); mechanisms recorded (6 Step 1; the memory scopes and Stop-hook facts landed in P2); the multi-agent post dated with its figures, agent teams ~7× (5 Steps 2 and 5); the ceiling rule and the slot as labelled policy with the counter-argument beside them (5 Step 1).

**Placeholder scan:** none of the four placeholder forms the writing-plans skill forbids appears; every bracketed "[current lines …, verbatim]" in Task 2 Step 3 names an exact range and is an instruction to paste, not text to land; every code step carries its code.

**Name consistency:** `references/contract.md` / `references/procedure.md` (Tasks 1, 2, 8); `commands/finish-procedure.md` and `references/finish-procedure.md` (Tasks 2, 3, 8); `FIND_EFFORT` / `RETRY_EFFORT` (Tasks 6, 8); `### Generation notes` and `## Cost terms and run hygiene` (Tasks 5, 6, 8); `finish-ab-shape.mjs` and `agent-cost-fixture.sh` (Tasks 4, 8); the per-role table's values (5) match the pins (6: reviewers `high`, sweep `medium`/`high`, Explore none, finish-ab `opus`/`high`).
