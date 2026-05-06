# Rough-in failure modes

This file is the operational detail behind rough-in's failure modes section in SKILL.md. It expands each failure mode with the signal that surfaces it, the defense rough-in uses to prevent it, and the recovery pattern when prevention fails.

Failure modes are presented in rough order of frequency — the most common ones first. The first three (rough-in multiple milestones at once, skipping the pre-flight checks, drafting individual specs before the issue plan is approved) account for the majority of rough-in run failures in practice.

## 1. Rough-in multiple milestones at once

**Signal**: the user says *"rough in M1 and M2"* or *"rough in the whole framing"*, or rough-in's own output starts producing specs for milestones beyond the one it was asked to decompose.

**Why it's a failure mode**: rough-in is one-milestone-at-a-time-just-in-time **by design**. The same failure mode that motivates frame-one-workstream-at-a-time applies at the milestone level: rough-in M_n today produces specs that M_n-1's actual build will teach you to revise. If you rough-in M1 and M2 in the same session and then build M1, the M2 specs will reflect what you knew before M1's build taught you anything — and you'll throw away the M2 work.

**Defense**: SKILL.md names this as the first failure mode and the milestone selection step (Step 2) explicitly asks the user which **single** milestone they want to rough-in. If the user pushes back ("I want to do them all at once"), rough-in surfaces the cost: *"Rough-in M2 right now will produce specs based on what we know before M1 ships. Most rough-in M2 specs survive M1 contact, but the ones that don't will need re-rough-in later. The cost of doing them now is potential rework; the cost of waiting is one extra rough-in run after M1 lands. Which trade-off do you prefer?"* If the user still wants both, proceed but flag the cost in the inheritance summary so the user has a clear record of the decision.

**Recovery**: if rough-in catches itself producing specs for a second milestone after starting on the first, stop immediately, present what's been drafted so far, and ask the user whether to (a) finish the current milestone and abandon the second milestone's work, (b) split into two rough-in runs and start the second one fresh, or (c) commit the partial work to both milestones and accept the rework risk explicitly.

## 2. Skipping the pre-flight checks

**Signal**: rough-in proceeds to Step 2 (milestone selection) without having read the framing's Pre-flight checks section, or reads it but doesn't verify the issue states of the rows blocking the milestone.

**Why it's a failure mode**: meta-issues are where structural blockers between milestones live (the automation recommender that has to land between M2 and M3, the architectural decision that has to be made before M4 can start, etc.). Without the check, rough-in would happily produce sub-sub-issues for M3 even though M3's start depends on a meta-issue that's still open. The downstream `/finish` phase would then attempt to execute work that was always going to fail because its prerequisites weren't ready, and the failure would surface in a downstream PR that has to be aborted — much more expensive than catching the gap at rough-in time.

**Defense**: the pre-flight checks is **mandatory in every rigor mode**, including light mode. The pre-flight check protocol in `references/inheritance.md` § The mandatory deferred meta-issues pre-flight check has six steps, and the check must complete entirely before Step 2 runs. SKILL.md names the check as the most important non-skippable piece of rough-in's discipline.

**Recovery**: if rough-in catches itself proceeding past Step 1 without having run the check, stop immediately, run the check now, and either resume from where it stopped (if no blockers are found) or surface the blocker and ask the user to choose resolve/clear/abort (if blockers are found). Never proceed without the check having completed at least once.

## 3. Drafting individual specs before the issue plan is approved

**Signal**: rough-in produces full sub-sub-issue specs in Step 5 without first presenting the issue plan and getting explicit approval in Step 4.

**Why it's a failure mode**: drafting individual specs is expensive and wasteful if the plan is wrong. The issue plan is much cheaper to iterate on (4-7 lines per issue: title, intent, type, dependencies, capstone marker) than the full specs (300-800 words per issue's Implementation section, plus the other five sections). If the user approves the plan and then rough-in drafts the specs, the specs are likely to be approved with minor iteration. If rough-in skips the plan and drafts specs directly, the user often realizes during spec review that the granularity was wrong (too many issues, too few, wrong boundaries) — and now you have to re-draft most of the specs after the boundary correction.

**Defense**: SKILL.md lists Step 4 (issue plan) as a separate step from Step 5 (individual specs), with its own HITL gate. The skill explicitly forbids drafting specs before the plan is approved. The discipline test is structural: if rough-in is in Step 5 (drafting specs) without having heard explicit approval on Step 4 (issue plan), it's broken the rule.

**Recovery**: if rough-in catches itself drafting specs without plan approval, stop immediately, present the implicit plan (the titles and intents of the specs being drafted), ask the user to approve the plan as-is or to revise the boundaries before continuing. Drafted specs from before this catch can be salvaged if the plan is approved unchanged, or discarded if the plan is revised.

## 4. Vague acceptance criteria

**Signal**: a draft sub-sub-issue spec has acceptance criteria like *"the tests pass"* or *"the function works"* or *"no regressions"* without naming the specific test, command, or observable outcome.

**Why it's a failure mode**: vague acceptance criteria force `/finish` (or the human executor) to guess at "done." The guess is sometimes right, but when it's wrong the spec gets closed prematurely (work that wasn't actually done), or the spec stays open indefinitely (work that was done but the criteria weren't checkable), or the executor over-engineers to be safe. All three failure paths are downstream costs of vague acceptance criteria at rough-in time.

**Defense**: SKILL.md names this as a failure mode and `references/plan-mode-prompts.md` § Eight properties of a good plan-mode prompt (property 5: specifies the verification step) covers the discipline. The discipline test: every acceptance criterion should name a specific command, test, or observation that the executor can run and get a deterministic answer. *"`cargo run -- regex/lesson_01.toml` succeeds with output matching `expected.txt`"* is acceptance; *"the regex tests pass"* is not.

**Recovery**: when rough-in catches a vague acceptance criterion in a draft spec, surface it explicitly during the spec review HITL gate: *"R[i]'s acceptance criterion 'tests pass' is too vague. The specific test that should pass is [test name]. Confirm I should rephrase it as 'running [exact command] produces [exact output]'?"* The user can either name the specific test or ask rough-in to defer the question to the executor (in which case the spec gets a "TBD: name the specific test during plan mode" note in the acceptance criteria section).

## 5. Plan-mode prompts that require external context finish doesn't have

**Signal**: a draft Implementation section says *"follow the pattern from the previous issue"* or *"as we discussed during framing"* or *"use the same approach as R1"* without inlining the relevant pattern, decision, or approach.

**Why it's a failure mode**: `/finish` reads the issue body and hands it to plan mode. It doesn't have the chat history from rough-in's session. It doesn't have the framing's discussion. It doesn't even necessarily have the prior R-issues unless the executor explicitly fetches them. References to "the previous issue" or "the discussion during framing" force chasing context that may or may not be reachable, and even when reachable, force the executor to interrupt their plan-mode work to fetch external context that should have been inlined.

**Defense**: SKILL.md names this as a failure mode and `references/plan-mode-prompts.md` § Eight properties (property 2: self-contained without forced external context) covers the discipline in detail with a worked bad/good example. The discipline test: imagine reading the Implementation section as the first thing you see in the morning, with no memory of the prior cascade discussion. Can you start working from it? If the answer is "no, I'd need to first read [X]," the prompt has a forced external context dependency.

**Recovery**: when rough-in catches a forced-context phrase in a draft Implementation section, rewrite the section to inline the relevant pattern, decision, or approach. Citations to cascade docs are fine (those are pointers, not prerequisites), but references to "the previous issue" or "as we discussed" are not. The good worked example in `references/plan-mode-prompts.md` § Pitfall 2 shows the bad/good rewrite pattern.

## 6. Inventing acceptance signals or plan-mode prompts instead of deriving them from cascade context

**Signal**: a draft acceptance criterion or Implementation section names a tool, library, command, or pattern that wasn't established in any upstream cascade artifact (problem brief, scaffold output, blueprint, frame-NN.md, foundation docs).

**Why it's a failure mode**: rough-in is operational, not architectural. The architecture is settled by the time rough-in runs. If rough-in invents a tool or pattern that isn't in the cascade, either (a) the inventory is correct but should have been surfaced at the framing or blueprint layer, in which case the upstream phases were incomplete and the gap should be escalated, or (b) the invention is wrong and contradicts what the cascade actually said. Both paths produce specs that don't match the cascade's context, and downstream execution fails because the executor follows the spec but the spec disagrees with the docs.

**Defense**: rough-in's discipline of citing cascade docs by section name (property 4 in `plan-mode-prompts.md` § Eight properties) creates a structural pressure against invention — every constraint should have a citation. If a constraint doesn't have a citation, it's either obvious from the project's lint config (in which case it doesn't need to be stated) or it's invented (in which case it needs to be removed or escalated). Step 1's inheritance discipline (read all required inputs in full) builds the mental map of what the cascade has actually established, so rough-in can recognize when a draft is inventing rather than deriving.

**Recovery**: when rough-in catches an invention in a draft, ask: *"This says [invented thing]. I don't see it in any of the cascade docs I read. Is this established somewhere I missed, or is rough-in inventing it? If invented, I should either (a) escalate to framing/blueprint to establish it properly, or (b) remove it from the spec because rough-in shouldn't be making this decision."* The user can confirm where it came from (in which case rough-in adds a citation) or accept the escalation/removal.

## 7. Partial-state failures during the atomic transition

**Signal**: rough-in's Step 6 (planning-backend commit) hits an MCP error, hang, or unexpected response partway through the multi-operation transition. Some sub-sub-issues are committed; others aren't. The markdown commit may or may not have run.

**Why it's a failure mode**: real MCP operations can fail in ways that are indistinguishable from success at the protocol level. A `issue_write` call might hang with no response and have actually succeeded server-side. A `sub_issue_write` call might fail with a network error and have actually completed. Naive retry creates duplicates; naive rollback may close work that's actually still in flight. The cascade's atomic transition discipline depends on the user verifying state before any further action.

**Defense**: `references/planning-backend-commit.md` § Partial failure recovery covers the protocol in detail. The four steps: stop immediately, surface the partial state explicitly (with every operation's status named), ask the user to verify state against the actual planning backend, wait for explicit user confirmation before any further action. The cascade never retries blindly and never auto-rolls-back on hang.

**Recovery**: the recovery IS the protocol in `planning-backend-commit.md`. Rough-in surfaces the partial state with operation-by-operation status, names any orphan sub-sub-issues from `issue_write`-succeeded-`sub_issue_write`-failed splits, names any prior R-issues that were superseded before the failure (for re-rough-in transitions), and waits for the user to verify. The user picks the next step (rollback, retry, or abort) and rough-in executes whichever they chose.

## 8. Slug drift from the framing sub-issue

**Signal**: a draft sub-sub-issue title uses a slug or F-number that doesn't match the parent framing sub-issue's title. E.g., the parent says `[regex-pack:F1] ...` but the draft sub-sub-issue says `[regex_pack:F1:R1] ...` (underscore instead of dash) or `[regex-pack:F2:R1] ...` (wrong F-number).

**Why it's a failure mode**: the slug + F-number is the cascade's grep-able identifier. Drift breaks the ability to find all sub-sub-issues for a given milestone via title search, breaks the parent linking on the planning backend if the cascade tries to use the title as a join key (which it shouldn't but might in some failure modes), and creates inconsistent historical records that confuse re-rough-in detection later.

**Defense**: rough-in always inherits the slug AND the F-number from the parent framing sub-issue's title via `issue_read` parsing — see `references/inheritance.md` § Slug and F-number inheritance from the parent framing sub-issue. **Never re-derive** from the workstream name in blueprint.md or the capability name in frame-NN.md. The discipline is structural: the parent's existing title is the source of truth, and rough-in's role is to inherit it, not to reconstruct it.

**Recovery**: when rough-in catches slug drift in a draft, fix it immediately by re-reading the parent issue and extracting the slug + F-number again. If the parent's title itself has the wrong format (doesn't match `[<slug>:F<#>] <capability>`), surface as a framing-side gap and ask the user whether to fix the parent's title before proceeding (recommended) or to proceed with the wrong format and fix later (not recommended, creates downstream inconsistency).

## 9. Overwriting prior rough-in specs instead of creating new ones on re-rough-in

**Signal**: rough-in detects a re-rough-in case (the milestone has been roughed-in before) but proceeds by editing the existing sub-sub-issue bodies instead of creating new ones with higher R-numbers and superseding the old ones.

**Why it's a failure mode**: the cascade-event model is **append-only**. Re-rough-in creates new sub-sub-issues with higher R-numbers and supersedes the prior ones via close + label; it never overwrites. Overwriting destroys the historical record of what rough-in believed at the prior date, makes it impossible to compare prior and current specs side-by-side, and breaks the README.md index entries that point at the original sub-sub-issues.

**Defense**: SKILL.md names this as a failure mode and `references/planning-backend-commit.md` § Re-rough-in detection covers the supersede flow with the partial-supersede rule (only open or in-progress sub-sub-issues get superseded; already-merged ones stay completed). Step 2's re-rough-in detection in SKILL.md treats re-rough-in as a deliberate cascade event, not as an edit operation.

**Recovery**: if rough-in catches itself trying to edit existing sub-sub-issues during a re-rough-in run, stop, present the planned edits as a re-rough-in proposal instead, run the supersede flow (close prior open R-issues with `superseded` label, create new R-issues with continuing R-numbers), and update the README.md index with the re-rough-in event.

## 10. Missing Pre-flight checks table in the framing

**Signal**: the framing's `frame-NN.md` doesn't have a `## Pre-flight checks` section at all (not "section present but empty" — actually missing).

**Why it's a failure mode**: this is framing drift. Either the framing pre-dates the deferred-meta-issues feature (older framing skill version that didn't produce the section) or framing was run with a non-cascade tool that didn't follow the cascade-meta template. In either case, rough-in can't run the mandatory pre-flight check because there's nothing to check against.

**Defense**: rough-in's `references/inheritance.md` § Special case: the framing has no Pre-flight checks section covers this case explicitly. The check protocol's step 1 surfaces the gap to the user with three options: (a) loop back to framing to add the table, (b) confirm there are no meta-issues for this framing and proceed with explicit acknowledgment, or (c) abort the rough-in run.

**Recovery**: the user picks one of the three options. Option (a) is the cleanest — the user runs framing again with the current skill version, framing produces the table (empty or populated), and rough-in resumes. Option (b) is acceptable when the user is confident the framing genuinely has no meta-issues and wants to avoid the round-trip — rough-in records the explicit acknowledgment in its inheritance summary and proceeds. Option (c) is the safest when the user isn't sure — abort and address the gap before trying again.

## 11. Over-prescriptive Implementation sections that inline function bodies and sequence implementation steps

**Signal**: the draft Implementation section contains fenced code blocks (```rust, ```typescript, etc.) that are **not** verbatim from a locked interface commitment. Or: the spec prescribes exact test function names, step-by-step command sequences, or inlined function bodies for work that hasn't been locked by framing.

**Why it's a failure mode**: Claude Code plan mode is a decomposition engine. When it receives a well-shaped Implementation section it explores the real codebase, notices existing patterns, and proposes implementation details that are informed by context the rough-in author didn't have. Over-prescriptive Implementation sections force plan mode past its natural exploration phase, anchor it on decisions the rough-in author guessed at, and produce code strictly worse than what plan mode would draft from a cleaner prompt. The symptom: reviewing the spec feels like reviewing the code — if the rough-in HITL gate feels like a code review rather than a spec review, the Implementation section has drifted into prescription. See `references/plan-mode-prompts.md` § Property 8 for the full discipline and Pitfall 6 for a concrete CSV-loader worked example.

**Defense**: for each non-IC code block in the Implementation section, ask (a) would removing it force the executor to make a decision the rough-in author already made, and (b) does the decision belong in the spec as a **constraint sentence** or in plan mode's Plan phase as a proposal. If the decision belongs in the spec, convert the code block to prose naming the constraint without prescribing the implementation. If the decision belongs to plan mode, delete the block and trust plan mode. Code blocks that are verbatim from a locked IC-N stay inlined — that's the exception, not the rule.

**Recovery**: apply the Property 8 discipline test during the Step 5 HITL gate. For each non-IC code block, either convert to a constraint sentence or delete. The word count will often shift upward in the non-code portion (because constraints take prose to state where code packed multiple decisions into a few lines) — that's expected and matches the 300-800 word range property 6 was relaxed to.

## 12. Pre-decomposing work that plan mode would handle internally

**Signal**: the issue plan feels "atomic and linear" — R1 enables R2 enables R3 in a way that suggests the whole set was always going to land as a single plan-mode session. Each individual issue is tiny (well under 250 words in the Implementation section). The total issue count for the milestone is at the high end of the range or above it (6+, 8+ for human-executor workflows).

**Why it's a failure mode**: plan mode decomposes well-shaped issues into ~5-10 internal steps and executes them in sequence within one session. When rough-in pre-decomposes the same work into 4 tiny issues that each plan-mode into 2-3 steps, the decomposition happens twice — once in rough-in (without real code context) and once in plan mode (with real code context). The rough-in's atomic split is strictly coarser and strictly less informed than plan mode's would be, and each extra R-issue incurs real per-`/finish` overhead (plan mode warmup, context loading, review cycles, PR review latency, board-automation round trips). The net effect: the milestone takes 4 sessions where it should take 2, and each session's output is slightly worse than it would have been with better issue boundaries.

**Defense**: apply the review-unit test from Step 4. A "coherent review unit" is one reviewer reading the PR in one sitting and forming a complete opinion about it, scoped to a single cross-crate boundary or architectural concern. If two issues are each so small that reviewing them separately feels like reviewing the same code twice, they should merge — the "why R1 before R2" reasoning doesn't disappear when they merge, it becomes internal plan-mode step ordering, which is cheaper to revise than issue-boundary ordering.

**Recovery**: during the Step 4 HITL gate, scan for adjacent issues that each plan-mode into a small number of steps and ask whether the split is adding bureaucracy. Merge the pair, let the merged issue plan-mode into ~5-10 internal steps during `/finish`, and preserve the "R1 before R2" reasoning as internal step ordering in the merged Implementation section. The milestone's total issue count may drop from 5 to 3 — that's typical, not a signal of under-planning.

## Cross-failure-mode patterns

A few patterns recur across multiple failure modes:

**Pattern: "stop and surface, don't auto-recover"** — failure modes 7 (partial-state failures), 8 (slug drift), and 10 (missing meta-issues table) all use the same recovery pattern. Rough-in detects the gap, stops immediately, surfaces the state to the user with explicit options, and waits for the user to choose. The cascade is never silent about gaps and never auto-recovers from ambiguous states.

**Pattern: "the discipline test is structural"** — failure modes 1 (multiple milestones at once), 2 (skipping the meta-issues check), and 3 (drafting before plan approval) all have structural discipline tests rather than judgment-based ones. Rough-in doesn't decide whether it's drafting too soon — the rule is "if Step 5 starts before Step 4's gate has been approved, the rule is broken." Structural tests are easier to enforce and harder to rationalize past.

**Pattern: "escalation is a first-class option"** — failure modes 6 (inventing) and 8 (slug drift from framing) both have escalation paths back to upstream phases. Rough-in is operational, not architectural. When rough-in finds itself doing architectural work, the right move is to surface the gap and let the user decide whether to escalate or to proceed with the cascade-aware workaround.

**Pattern: "the historical record matters"** — failure modes 9 (overwriting on re-rough-in) and 10 (missing meta-issues table) both protect the cascade's append-only event log. The cascade-event model is load-bearing for re-runs, audits, and trust in the historical record. Failure modes that violate it produce silent inconsistencies that surface much later as trust erosion.
