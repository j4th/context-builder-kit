# Rough-in test cases

This file contains five realistic test prompts for verifying that rough-in still works after revisions. Each test names the setup conditions, the user prompt, the expected behaviors at each step, and the success criteria.

These tests are not exhaustive — they cover the canonical happy path and four important edge cases. Add new tests when revisions introduce new behavior or fix bugs that should be regression-tested.

## Test 1 — Canonical first rough-in (regex-pack M1)

**Setup**:
- A repo that has scaffold's Stage 2.5 templates committed (`.github/ISSUE_TEMPLATE/cascade-rough-in.md` exists)
- A workstream parent issue created by blueprint (`[regex-pack] Regex pack`) with `cascade-depth:rough` label
- A framing capability sub-issue created by framing (`[regex-pack:F1] Verify one regex lesson end-to-end`) parented under the workstream issue, with `cascade-depth:framed` label
- A `frame-01.md` in `docs/cbk/` with the F1 capability defined, the M1 milestone listed, and a Pre-flight checks section that's empty (says "No deferred meta-issues from this framing")
- All upstream artifacts present and well-formed (problem brief, scaffold output, blueprint, foundation docs)
- The user has not previously roughed-in this workstream

**Prompt**: *"Rough in M1 of the regex pack."*

**Expected behaviors**:

- **Step 1 (Inheritance + meta-issues check)**: rough-in reads all required inputs, presents a verbatim inheritance summary including the parent issue's slug + F-number inherited from `[regex-pack:F1]`. Runs the pre-flight checks, finds the empty section, treats as passed. HITL gate before proceeding.
- **Step 2 (Milestone selection)**: confirms the user wants M1 specifically, not M2 or any other milestone in F1. Detects this as a first rough-in (no prior rough-in events for this milestone in `README.md` index), proceeds without re-rough-in flow.
- **Step 3 (Research)**: proposes a research depth based on inheritance signals — likely "shallow" or "standard" since regex-pack is the first cascade workstream and there's no prior cascade work to extend. Presents findings if any sub-tracks ran.
- **Step 4 (Issue plan)**: produces 3-7 R-issues with titles, intents, dependencies, and a capstone marker if applicable. HITL gate.
- **Step 5 (Spec drafting)**: drafts each spec individually using `cascade-rough-in.md` (read from disk first), populates the six sections, ensures each Implementation section meets the eight properties.
- **Step 6 (Commit)**: presents the atomic transition (sub-sub-issues + framing.md index update), HITL gate, executes the two-step `issue_write` + `sub_issue_write` for each spec, commits the framing.md index entry, completes successfully.

**Success criteria**:

- All R-issues land on the planning backend with `cascade-depth:roughed-in` label, parented under the framing sub-issue
- Each R-issue's body has the six standard sections with heading names preserved verbatim
- Each Implementation section is in the 300-800 word range, second person, names specific files/signatures, cites cascade docs by section name
- The slug + F-number in each R-issue title matches the parent framing sub-issue's title
- The framing.md index has an entry recording the rough-in event with the R-number range
- The board automation moves each R-issue to Status = Ready (verified after a brief delay)
- No HITL gate was skipped, no step was conflated, no MCP call failed
- The total turn count is reasonable (4-8 turns for standard mode, 1-2 turns for light mode)

## Test 2 — Subsequent rough-in (regex-pack M2 after M1 is done)

**Setup**:
- All of Test 1's setup, plus:
- M1 has been roughed-in successfully (Test 1 has run)
- M1's R-issues have been executed via `/finish` (or manually) and merged
- `README.md` index has an entry for the prior M1 rough-in event
- The user has not started M2 yet

**Prompt**: *"Rough in M2."*

**Expected behaviors**:

- **Step 1**: reads all inputs, recognizes M2 builds on M1's infrastructure (which is now in the codebase), inheritance summary mentions the M1 patterns that M2 will extend.
- **Step 2**: confirms M2 specifically. Detects this as M2's first rough-in (not a re-rough-in of M1) by checking `README.md` index — the prior entry was for M1, not M2.
- **Step 3**: proposes shallower research than Test 1 because M2 is a direct extension of M1 with established patterns. Likely proposes "shallow" or "skip research entirely" if all four skip-conditions hold.
- **Step 4-6**: same as Test 1 but the specs are shaped to extend M1's work rather than build from scratch. Cite M1's R-issues for context where useful (with full inlined detail, not "see R1").

**Success criteria**:

- All of Test 1's success criteria, plus:
- The Step 3 proposal correctly identifies this as a low-research case
- The R-issue specs reference M1's established patterns by inlining them, not by requiring `/finish` to chase context
- The R-numbering continues sequentially (e.g., if M1 created R1-R4, M2 might start at R5 or restart at R1 depending on how rough-in handles cross-milestone R-numbering — the discipline is per-milestone, so M2 starts at R1)

## Test 3 — Markdown-only profile rough-in

**Setup**:
- A repo where scaffold landed in markdown-only profile (`scaffold.md` has `profile: markdown-only`)
- No GitHub Project board, no parent Issues on the planning backend, no framing sub-issues — the cascade lives entirely as markdown in `docs/cbk/`
- A `frame-01.md` exists at `docs/cbk/` with the milestones list, including the M1 to be roughed-in
- `.github/ISSUE_TEMPLATE/cascade-rough-in.md` exists (scaffold commits the templates regardless of profile)
- The user has explicitly chosen markdown-only at scaffold's confirmation gate

**Prompt**: *"Rough in M1 of the regex pack."*

**Expected behaviors**:

- **Step 1**: reads scaffold.md, detects `profile: markdown-only`, surfaces the markdown-only acknowledgment in the inheritance gate (parallel to blueprint's markdown-only acknowledgment): *"This is markdown-only profile — I'll skip the planning-backend half of every commit. The rough-in specs will land as markdown content rather than as GitHub sub-sub-issues. Sound right?"*
- **Step 2**: inherits the slug + F-number from the framing's milestone entry in `frame-01.md` directly (not from a parent issue title because there isn't one).
- **Steps 3-5**: same as Test 1 — research, issue plan, spec drafting all profile-agnostic.
- **Step 6**: presents the markdown-only commit gate with the file location choice (append to frame-01.md vs new per-milestone rough-in markdown file). User picks. Rough-in commits the markdown content and the framing.md index entry. No planning-backend operations.

**Success criteria**:

- The markdown-only acknowledgment fires correctly
- The slug + F-number inheritance works without a parent issue
- The user is offered the file-location choice and rough-in respects the choice
- The rough-in spec content lands in the chosen location with the six-section structure preserved
- The framing.md index has an entry recording the rough-in event
- No planning-backend MCP operations were attempted
- The pre-flight checks still ran (it's profile-agnostic)
- No `/finish` references appear in the output without explicit caveats (markdown-only mode has no `/finish` slash command, the user executes manually)

## Test 4 — Deferred meta-issue blocker hit

**Setup**:
- All of Test 1's setup, except:
- The framing's `frame-01.md` Pre-flight checks section has one row: *"#42 — Decide PTY library before M3 — Depends on: nothing — Blocks: M3 start — Type: decision"*
- Issue #42 exists on the planning backend, parented under the workstream parent Issue with the `meta` label, and is currently **open**
- The user wants to rough-in M3, not M1

**Prompt**: *"Rough in M3."*

**Expected behaviors**:

- **Step 1**: reads all inputs, runs the pre-flight checks, identifies #42 as blocking M3 start, queries #42's state via `issue_read`, finds it open. Stops immediately and surfaces the gap with the three options (resolve and resume, explicitly clear, abort).
- **No further steps run** until the user picks an option.
- **If user picks (a) resolve and resume**: rough-in waits, the user resolves #42 (probably by making the decision and closing the issue with `state_reason: completed`), the user tells rough-in to resume, rough-in re-runs the check from step 3, finds #42 closed-as-completed, proceeds to Step 2.
- **If user picks (b) explicitly clear**: rough-in records the decision in its inheritance summary as *"Meta-issue #42 was explicitly cleared by user as no longer blocking M3. Reason: <user's words>"* and proceeds to Step 2.
- **If user picks (c) abort**: rough-in stops cleanly without producing any specs or making any commits.

**Success criteria**:

- The check fires correctly and identifies #42 as a blocker
- Rough-in stops immediately upon detecting the blocker — does NOT proceed to Step 2 with the blocker unresolved
- The three options are presented clearly and in plain language
- Rough-in waits for explicit user choice — does not auto-pick any option
- If the user picks resolve-and-resume, rough-in correctly re-runs the check (does not skip it on resume)
- If the user picks clear, the explicit clearing is recorded in the inheritance summary verbatim
- If the user picks abort, no markdown commits or planning-backend operations happen

## Test 5 — Partial failure recovery during planning-backend commit

**Setup**:
- All of Test 1's setup
- The user runs rough-in normally up through Step 5 (specs drafted, all approved at HITL)
- During Step 6 (commit), the github MCP hangs on the third `sub_issue_write` call (the second sub-sub-issue's parent linking) — `issue_write` for sub-sub-issue #2 succeeded but `sub_issue_write add` to link it to the parent never returned

**Setup (continued)**:
- This is a simulated failure — in a real test, you'd need to actually trigger the hang via network manipulation or mocked tool. For documentation purposes, assume the failure can be triggered.

**Prompt**: (no new prompt — the failure happens during execution)

**Expected behaviors**:

- Rough-in's atomic transition is partway through Step 6. The captured operation list is something like:
  - R1: `issue_write` ✅ created, `sub_issue_write` ✅ linked
  - R2: `issue_write` ✅ created (returned id 12345), `sub_issue_write` ❌ HUNG (no response)
  - R3: queued, not attempted
  - R4: queued, not attempted
  - markdown commit: queued, not attempted
- Rough-in stops immediately on the hang. Does NOT retry, does NOT auto-rollback.
- Surfaces the partial state explicitly:
  > "Planning-backend commit failed partway through. Here's what I have:
  >
  > **Successfully committed**:
  > - R1: created and linked under the parent framing sub-issue (#<N>)
  >
  > **Partial - orphan**:
  > - R2: `issue_write` returned issue id 12345 successfully, but `sub_issue_write` to link it to the parent never responded. R2 may exist as an orphan issue without a parent link, OR may have actually linked successfully and the response was lost. **Please verify R2's state on GitHub before I do anything else.**
  >
  > **Queued, not attempted**:
  > - R3, R4, and the framing.md index update
  >
  > Once you've verified R2's state, tell me one of:
  > (a) R2 is correctly linked, proceed with creating R3 and R4 and the markdown commit
  > (b) R2 exists as an orphan, you've manually linked it, proceed with R3+
  > (c) R2 exists as an orphan, you want me to rollback (close R1 and R2 with `transition-rollback` label) and abort
  > (d) R2 doesn't exist (the issue_write actually failed too), you want me to rollback R1 and abort
  > (e) Something else — please describe and I'll figure out the right next step"
- Rough-in waits for explicit user confirmation. Does not auto-recover.
- After the user verifies state and picks an option, rough-in executes the chosen recovery path.

**Success criteria**:

- Rough-in stops immediately on the hang
- The partial state is surfaced with operation-by-operation status
- The orphan case is named explicitly (R2's `issue_write` succeeded, `sub_issue_write` is unknown)
- The user is given specific options (not just "what do you want me to do?")
- Rough-in waits for explicit user confirmation before any further action
- Whichever option the user picks, rough-in executes it correctly without trying to be clever

## Cross-test invariants

A few things should be true across all five tests:

- **The pre-flight checks runs in every test**, even Test 3 (markdown-only) where the planning backend doesn't exist
- **No HITL gate is skipped silently** — if a gate is collapsed (in light mode), the user explicitly chose light mode
- **Token pressure honesty** — if any test hits token pressure during research or spec drafting, rough-in surfaces it explicitly and offers the three options (finish partial, skim, continue in follow-up)
- **The cascade event log is append-only** — no test should result in an overwritten or deleted markdown file or planning-backend object
- **Inherit-from-disk discipline** — every test reads `cascade-rough-in.md` from disk first, falling back to bundle only if the disk copy is missing

## When to add a new test case

Add a new test when:

- A revision introduces a new behavior that should be regression-tested
- A bug surfaces that the existing tests didn't catch
- A failure mode in `references/failure-modes.md` doesn't have a corresponding test
- A new profile is added (e.g., when the opinionated profile graduates from partially-validated to fully validated)
- The cascade adds a new phase that changes rough-in's handoff contract

Tests are intentionally minimal — they're not a comprehensive coverage matrix, they're a smoke test set that catches the most common regressions. The full coverage comes from real cascade runs against dogfooded projects.
