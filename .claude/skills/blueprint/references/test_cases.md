# Test cases for the blueprint skill

Three realistic test prompts that exercise blueprint's inheritance discipline, stack decisions step, methodology selection, foundation doc production, and the handoff issue creation. These are the contract for "blueprint works": when run on these prompts, the output should produce a faithful set of foundation docs plus `docs/cbk/blueprint.md` plus a handoff issue, and the conversation should hit the expected gates without skipping inheritance reads or producing generic / hallucinated content.

For Claude.ai's qualitative test loop (no subagents, no benchmarking): a real human runs the skill on each prompt as if they were the user, then judges the output against the success criteria below. Blueprint is the most complex skill in the cascade, so the test cases also exercise its specific failure modes — premature stack lock-in, methodology dogmatism, ephemeral steps in blueprint.md, and missing handoff issue.

## Test 1 — canonical run after a clean cascade pass

**Prompt** (user has both prior-phase artifacts in `docs/cbk/`):
> "Scaffold finished — let's do blueprint. Standard mode is fine."

**What success looks like:**
- Skill detects `standard mode` from the user's explicit request and confirms briefly
- **Inheritance check runs first and is verifiable**: skill reads both `docs/cbk/problem_brief.md` and `docs/cbk/scaffold.md` in full via GitHub MCP (or equivalent), produces an inheritance summary that quotes the brief's no-gos and the scaffold's quality bar verbatim, and gets explicit user approval before proceeding
- All deferred decisions from the brief's "Notes for blueprint" section are addressed in the stack decisions step — no silent omissions
- Methodology recommendation is tied to inherited context with a register citation (e.g., *"Given the bursty cadence and per-pack scope discipline from the brief, I'd recommend Shape Up appetite-based — Singer, Basecamp 2019"*)
- Foundation docs produced in the documented order: CLAUDE.md → docs/ARCHITECTURE.md → docs/STANDARDS.md → CONTRIBUTING.md (or deferred per the solo-pre-v1.0 rule) → README update → docs/cbk/blueprint.md
- ARCHITECTURE.md Decisions Log has one entry per stack decision with all four fields (Context, Options, Decision, Consequences) — alternatives are real, not strawmen
- Working conventions from `scaffold.md` (branch naming, commit format, label taxonomy) appear in CONTRIBUTING.md (or equivalent) verbatim — no re-deriving
- Tooling configs are produced: every command in CLAUDE.md maps to an actual task in the task runner config; every CI gate in STANDARDS.md maps to an actual job in the workflow file
- A handoff issue gets created with the version-pin inventory, the toolchain bootstrap command, and the bootstrap-exemption-end statement
- Standard mode runs four HITL gates total (post-stack, post-methodology, post-foundation-docs-batch, post-handoff-issue)

**What failure looks like:**
- Skill skips reading the inheritance files in full and produces generic foundation docs
- Stack decisions are committed without explicit user confirmation (premature stack lock-in)
- Methodology recommendation is "use Shape Up" without a citation or context tie
- The handoff issue is omitted
- blueprint.md contains a "Manual setup runlist" section with one-time setup commands (those go in the handoff issue, not blueprint.md)
- Working conventions in CONTRIBUTING.md drift from what scaffold.md said

## Test 2 — unusual stack where one decision category doesn't apply

**Prompt** (data analysis project where there's no distribution category):
> "I just finished scaffold for a personal data analysis project — Python, Jupyter notebooks, runs locally only, never going to be packaged or distributed. Skip the distribution decision since there isn't one. Run blueprint, full mode."

**What success looks like:**
- Skill respects the explicit `full mode` selection (seven gates)
- Stack decisions step runs four categories (language/framework, storage, external dependencies, testing/CI) and **explicitly omits distribution** with a one-line note: *"Skipping distribution per the brief — this project runs locally only and isn't being packaged."*
- Methodology selection acknowledges that personal analysis projects often don't need a formal methodology — the recommendation might be "no formal methodology, just discipline" with the brief's appetite as the constraint
- CLAUDE.md is appropriately lean — no Distribution section, no packaging guidance
- ARCHITECTURE.md does not invent a distribution decision; the Decisions Log starts with whichever category had the first real decision
- The handoff issue's version inventory walks the actual files committed (Python pyproject.toml deps, no Cargo.toml, no Dockerfile) without trying to enumerate categories that don't exist

**What failure looks like:**
- Skill insists on running the distribution category anyway and asks "how will users install this?" despite the explicit instruction not to
- Skill invents a distribution decision (e.g., "we'll publish to PyPI") without user confirmation
- ARCHITECTURE.md has a Decisions Log entry for distribution that says something vague like "no distribution needed"
- CLAUDE.md mentions distribution mechanisms that don't exist for the project

## Test 3 — conflicting constraints that force the resolve-deferrals work

**Prompt** (user has a brief with mutually-tense requirements):
> "Run blueprint. The brief says we want fast iteration AND production-grade reliability AND minimal CI. Scaffold's quality bar is 'tighten as we go' but the v1.0 ship date is in 8 weeks. Figure out how to reconcile these."

**What success looks like:**
- Skill detects the tension and surfaces it explicitly during inheritance check: *"I see three constraints in tension — fast iteration, production reliability, and minimal CI. Plus an 8-week deadline against a quality bar that says 'tighten as we go.' Before I produce stack decisions, let me make sure I understand how you want to resolve these. My reading is [proposal]. Sound right?"*
- Skill does NOT silently pick one constraint and ignore the others
- Stack decisions reflect the resolved tension explicitly — e.g., "minimal CI for first 4 weeks (lint + test only), then add typecheck + coverage gates from week 5" rather than picking one extreme
- STANDARDS.md's PR Review Checklist explicitly uses the [STRICT] annotation pattern for items that activate later in the v1.0 trajectory
- The Decisions Log entries for the contested categories explicitly state the trade-off in their Consequences fields ("This decision optimizes for iteration speed in the first month at the cost of catching bugs that the deferred typecheck would have caught earlier")
- Methodology selection prefers a methodology that accommodates the dial between iteration and reliability — Shape Up appetite-based is a reasonable fit (each pack has its own ship-bar)
- The handoff issue includes a specific milestone: "By end of week 4, return to STANDARDS.md and activate the [STRICT] items"

**What failure looks like:**
- Skill picks "fast iteration" as the dominant constraint and produces docs that ignore production reliability
- Skill picks "production reliability" and produces a heavyweight CI pipeline that contradicts "minimal CI"
- Skill never surfaces the tension and produces docs that contradict each other (e.g., STANDARDS.md says "tests required for every PR" but CLAUDE.md says "skip tests during prototyping")
- The handoff issue doesn't include the trip-wire for revisiting the dial

## Test 4 — pre-first-CI-run sanity pass catches empty-scaffold gate failures

**Prompt (what the user says)**:
> Blueprint is mostly done — we've landed stack decisions, methodology, and the foundation docs. Now you're producing the tooling configs. My stack has a strict CI gate set (formatter, linter with warnings-as-errors, test runner, unused-dep checker, license checker, and an automated review bot as a merge gate). The repo is currently pre-v0.1 scaffolding — no tests, no real code consuming the workspace deps yet.

**What blueprint should do**:

1. Produce the tooling configs as usual (task runner config, CI workflow, linter config, etc.)
2. **Before** the HITL presentation gate for tooling configs, run the pre-first-CI-run sanity pass from `references/templates/tooling.md`
3. Walk through all eight sanity-pass questions, capturing the user's stack-specific answers
4. Question 6 specifically: surface that the out-of-the-box automated review bot workflow is usually wrong for the specific project, and ask whether the user wants to retune now, retune after first PR, or skip the gate until retuning is done
5. Produce a **Cleanup tracking** section in `blueprint.md` listing every workaround shipped, with a trip-wire for each
6. Cross-check the tooling config rules against the stack decisions list and flag any contradictions (question 5)
7. Present the tooling configs + Cleanup tracking section at the HITL gate

**Success criteria**:
- All eight sanity-pass questions asked explicitly — none skipped, even if the answer is "not relevant to my stack"
- For questions where the user names a workaround, the workaround lands in the relevant config file AND gets a row in the Cleanup tracking table with a trip-wire
- Question 6 specifically prompts the user about review-bot workflow retuning and how they'll verify the bot ran on first PR
- Question 5's stack-decision cross-check surfaces any rules in the tooling configs that contradict earlier decisions
- The HITL gate presentation explicitly names any aspirational gates the user left broken until first CI run
- The Cleanup tracking section appears in `blueprint.md`, not in a separate file

**Failure signals**:
- Tooling configs committed without running the sanity pass at all
- Sanity pass questions asked in a way that requires stack-specific knowledge blueprint doesn't have ("I see you're using cargo, should we add `--no-tests=pass`?")
- No Cleanup tracking section produced, even when workarounds were agreed
- Trip-wires missing from Cleanup tracking rows (workarounds without removal conditions are silent staleness)
- Review bot workflow committed as a merge gate without the verification question being asked
- Stack-decision contradiction cross-check skipped or performed silently (contradictions found but not surfaced to the user)

## Test 5 — Unenforced invariants + review bot prompt construction end-to-end

**Prompt (what the user says)**:
> Continuing blueprint — we're past stack decisions and into foundation docs. My stack picks an automated review bot (whichever — claude-code-action, CodeRabbit, doesn't matter for this test) as a CI merge gate. ARCHITECTURE.md will have several architectural invariants (module dependency rules, sync-only constraint on the engine), CLAUDE.md will have some textual conventions (how tests are organized), and the brief had no-gos around system dependencies and async I/O. None of those are catchable by clippy or test runners. I want the review bot to enforce them.

**What blueprint should do**:

1. Produce ARCHITECTURE.md and CLAUDE.md as usual
2. **During the foundation docs HITL gate**, ask the Unenforced invariants prompt: *"Looking at the architectural decisions and conventions we just landed, are there textual rules in those docs that no CI gate catches? Let's list them in STANDARDS.md § Unenforced invariants — they're the source of truth for code review."*
3. Walk the user through populating the Unenforced invariants table — each row needs invariant text, source citation, severity, and "how it's caught" (human review or bot)
4. Produce STANDARDS.md with the populated Unenforced invariants section
5. Move into tooling configs step, run the sanity pass (Test 4 covers this)
6. After the sanity pass, **run the automated review bot prompt construction sub-section** because the user picked a review bot in stack decisions:
   - **Phase 1**: web search for practitioner best practices for the specific tool the user picked. Surface 3-5 patterns with citations. User picks which to adopt.
   - **Phase 2**: synthesize the prompt content by inheriting from STANDARDS.md § CI Pipeline (do-not-duplicate list), STANDARDS.md § Unenforced invariants (focus list), and the sanity pass workarounds (leave-alone list)
7. Present the generated prompt at the review bot HITL gate
8. Iterate until approved
9. Commit the workflow file with the populated prompt

**Success criteria**:
- Unenforced invariants section exists in STANDARDS.md and is populated (not left as an empty template)
- Each invariant row has all four columns filled: invariant, source, severity, how-caught
- Phase 1 web search runs explicitly and surfaces 3-5 practitioner patterns with citations
- Phase 2 inheritance is verifiable: every "things CI can't catch" rule in the generated prompt cites a specific row from the Unenforced invariants table by source
- The "do not duplicate" list in the prompt mirrors STANDARDS.md § CI Pipeline (no extras, no missing gates)
- The "leave alone" list includes the sanity pass workarounds from Test 4 (pre-v0.1 scaffold markers)
- HITL gate happens before commit; user reads the prompt content inline and can revise
- Workflow file gets committed with the populated prompt, not a generic install

**Failure signals**:
- Foundation docs HITL gate skips the Unenforced invariants prompt entirely
- Unenforced invariants table is empty or stub-filled despite ARCHITECTURE.md/CLAUDE.md/the brief clearly having such rules
- Review bot prompt construction skipped despite the user picking a review bot in stack decisions
- Phase 1 research skipped — prompt is generated from cascade only, missing practitioner wisdom
- Phase 2 inheritance skipped — prompt is generic, doesn't cite the Unenforced invariants table
- Generated prompt has rules that don't exist in the Unenforced invariants table (means rules were invented during prompt authoring instead of going through the table first)
- Workflow file committed without the inline HITL presentation of the prompt

## Test 6 — planning-backend commit (Milestone creation per workstream, atomic transition)

**Prompt (what the user says)**:
> Blueprint is producing the workstreams table now. My profile is github-only. The Projects v2 board exists with the four standard automation rules. There are 3 workstreams: regex-pack, tmux-pack, bash-pack. Run the planning-backend commit alongside the markdown commit.

**What blueprint should do**:

1. Validate slug uniqueness across the 3 workstreams in `blueprint.md` § Workstreams. No duplicates → proceed.
2. Query the Projects v2 board state via MCP, confirm it exists and has the four automation rules. If gap → pause and surface setup instructions.
3. Query existing repo Milestones for slug collisions with the 3 workstream slugs. None → proceed (greenfield path).
4. Present the final HITL gate listing both halves of the transition: the markdown commit (`blueprint.md` + any updated foundation docs) AND the 3 Milestones to be created (`regex-pack`, `tmux-pack`, `bash-pack`), each with its description preview.
5. On user approval: execute planning ops first, capturing each Milestone's `{id, url}` as it lands.
6. Execute markdown commit second.
7. On any failure during step 5 or 6: rollback by deleting captured Milestones, surface the rollback to the user, abort cleanly.
8. On full success: report both halves committed, including the 3 Milestone URLs and the markdown commit SHA.

**Success criteria**:
- Slug uniqueness check happens before any commit operation
- Project board state check happens before any commit operation
- Existing-Milestone collision check happens before any commit operation
- Both halves of the transition are presented at the HITL gate as one approval, not two
- Planning operations execute first; markdown commit executes second
- All 3 Milestones land in the planning backend with correct titles and descriptions
- The markdown commit lands with `blueprint.md` reflecting the same 3 workstreams
- Cascade is fully consistent after the transition (markdown matches Milestones)

**Failure signals**:
- Markdown committed without Milestones being created (transition not atomic)
- Milestones created without markdown commit (transition not atomic, no rollback)
- Slug collision silently produces a duplicate or shadows an existing Milestone
- Blueprint commits without checking the board state and the user discovers later that Milestones aren't on the board
- Rollback skipped on transition failure — leaving partial state without surfacing it
- Brownfield re-run creates duplicate Milestones instead of updating existing ones

## How to use these tests when revising the skill

1. Pick one or more tests to run (Test 1 is the canonical happy-path; Test 2 exercises selective decision-skipping; Test 3 exercises tension-resolution and the trip-wire pattern)
2. Run blueprint on the prompt in a real session — not synthetic
3. Compare the actual conversation flow and the produced foundation doc set against the success criteria
4. If a failure mode triggers, capture the specific failure as a post-mortem item
5. Apply targeted fixes to SKILL.md or the relevant reference file
6. Re-run the same test to verify the fix

The Claude.ai-appropriate variant of this loop (per `skill-creator`'s guidance for environments without subagents) is qualitative — there's no automated grader and no quantitative benchmark. The success criteria above are the rubric a human reviewer uses to judge whether the test passed. Blueprint is the most complex skill in the cascade, so the qualitative judgment matters more here than for the lighter-weight skills — the rubric focuses on **whether the produced docs are usable as inputs to the framing phase**, which is the ultimate "did blueprint work" test.
