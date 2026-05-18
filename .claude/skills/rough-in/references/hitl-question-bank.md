# Rough-in HITL question bank

This file is a categorized reference of questions rough-in can ask the user during HITL gates. It's organized by step so rough-in can look up phrasing when it needs to surface a clarification, decision, or correction request.

This isn't a script — rough-in doesn't ask every question in every run. It's a vocabulary that rough-in draws from when a specific situation needs a specific kind of question. The questions are phrased in user-facing language (no cascade jargon unless the user has already used it) and lean on the user's own context rather than asking for re-explanation.

## Step 1 — Inheritance and pre-flight checks

### Inheritance summary review

- *"Here's the inheritance summary plus the pre-flight checks result. Anything to correct before I proceed to milestone selection confirmation?"*
- *"I'm reading [milestone identifier] from [frame-NN.md]. Is that the right framing for this rough-in run, or do you want a different framing?"*
- *"The framing's open questions section has [N] entries with trip-wires mentioning rough-in or this milestone. Do you want me to plan to resolve them during the research phase, or are some of them outside this rough-in's scope?"*

### When inheritance reveals a gap

- *"STANDARDS.md doesn't have an Unenforced invariants section. Without it, the final pre-commit gate's invariants check will be a no-op. I can proceed without the check for this run and flag it as a Suggested foundation doc update at the end. Sound right, or do you want to add the section first?"*
- *"The framing's `frame-NN.md` doesn't have a Pre-flight checks section. This either means framing pre-dates the meta-issues feature or there genuinely are none. Which is it? If pre-dates, I'd recommend looping back to framing for a proper table. If genuinely none, I'll proceed and note in my output that I confirmed empty."*
- *"The parent framing sub-issue's title doesn't match the expected `[<slug>:F<#>] <capability>` format. It looks like '[exact title]'. Is this an older framing format, or was the issue created manually? I can't proceed with sub-sub-issue creation until the parent's title is fixed."*

### When the pre-flight checks finds blockers

- *"Meta-issue #<N> '<title>' blocks M<n>'s start and is still open. M<n> can't be roughed-in until it's resolved. Three options: (a) resolve the meta-issue first and resume rough-in, (b) explicitly clear it as no longer blocking M<n> and record the decision, or (c) abort this rough-in run. Which?"*
- *"Meta-issue #<N> is closed but with state_reason `not_planned`. Does this count as resolved for the purpose of M<n>'s preconditions, or is it still blocking? If still blocking, M<n> cannot be roughed-in until it lands."*
- *"Multiple meta-issues block M<n>: [list with issue numbers and subjects]. Do you want to resolve them in a specific order, or should I surface them one at a time?"*

## Step 2 — Milestone selection within framing

### Milestone identification

- *"Which milestone in [frame-NN.md] do you want to rough-in? The framing has [list of milestones with F-numbers and capabilities]."*
- *"You said 'rough in the next milestone'. The README.md index shows [last-roughed-in milestone] was the most recent. The next unroughed-in milestone is [name]. Confirm?"*
- *"You said 'rough in [partial name]'. Looking at [frame-NN.md]'s milestones list, that could match [milestone A] or [milestone B]. Which one?"*

### Slug + F-number inheritance confirmation

- *"Reading the parent framing sub-issue (#<N>): title is '[exact title]'. I'm inheriting slug `<slug>` and F-number F<#>. Sound right?"*
- *"The parent framing sub-issue's slug is `<slug>` but the workstream's row in blueprint.md says `<other-slug>`. Slug drift between blueprint and framing — which one is canonical? My recommendation is to use the parent issue's slug since framing committed it most recently."*

### Re-rough-in detection

- *"This milestone has been roughed-in before — `README.md` index shows a prior rough-in event on [date] that created R1 through R<N>. Are you re-rough-ining the milestone (which means I'll supersede the open prior R-issues and continue numbering from R<N+1>)?"*
- *"The prior rough-in's R1, R2, R3 are already closed-as-completed (the work landed). R4 is still open. Are you re-rough-ining because R4 didn't survive contact with code, or because something changed at the framing level that means R4-R<N> need to be redone?"*
- *"Re-rough-in confirmed. I'll supersede the open prior R-issues (R<X>, R<Y>, R<Z>) and leave the already-merged ones (R<A>, R<B>) as completed. New R-issues will start at R<N+1>. Sound right?"*

## Step 3 — Research phase

### Depth proposal

- *"Based on [signals from inheritance], I'd propose [shallow / standard / deep] research for this milestone. [Specific things I'd look up]. Sound right, or do you want to adjust depth or scope?"*
- *"M[n] looks like a direct extension of M[n-1] with no new dependencies, no open questions, and no new patterns. I'd propose **skipping the research phase entirely** and going straight to the issue plan. Sound right, or do you want me to do at least a shallow pass on something specific?"*

### Mid-research check-ins

- *"Before I dig deeper into [specific topic], the framing didn't mention [related concern]. Should I research that too, or is it out of scope for this milestone?"*
- *"The library [X] has changed significantly since the framing was written — the API I expected isn't there anymore. Want me to (a) research the current API and adapt the rough issues to match, (b) escalate back to framing because the change might affect the milestone's shape, or (c) accept the change and document the deviation in the spec?"*

### Token pressure honesty

- *"I'm running low on context budget for this turn. I've completed [the parts I've finished] but [the parts I haven't gotten to yet] are still pending. I can either: (a) finish what I have and present it as partial, leaving the rest for the next turn, (b) skim the remaining parts to fit them into this turn at lower depth, or (c) stop here and continue in a follow-up message. What's your preference?"*

### Resolving framing's open questions

- *"Framing's open question '[verbatim]' has a trip-wire saying 'revisit during rough-in'. The narrowed version is: [specific question]. What's your call?"*
- *"Framing's open question '[verbatim]' was supposed to be resolved during rough-in, but it's grown — resolving it now would require [specific architectural change or new constraint that wasn't in framing's scope]. I'd recommend either (a) re-framing this workstream to incorporate the new constraint, or (b) producing rough-in specs that explicitly defer the decision to execution time. Which do you prefer?"*

## Step 4 — Issue plan

### Plan presentation

- *"Here's the issue plan for M[n]: [numbered list with R-numbers, titles, one-sentence intents, dependency arrows, capstone marker]. Narrative arc: [one sentence]. Approve, or want me to iterate on any of it?"*
- *"The plan has [N] R-issues. That's [within / above / below] the typical 2-6 range for Claude-Code-executed workflows. [If above]: either the milestone is too big and should be split (escalate back to framing) or I'm pre-decomposing work that plan mode would handle internally — want me to apply the review-unit test and propose merges? [If below 2]: this might fold into [other milestone] — want me to escalate? [If within]: sound right?"*
- *"Review-unit check: does each proposed issue form a coherent review unit on its own, or are adjacent issues cheap enough to review together that the split is adding bureaucracy? Specifically: [for each adjacent pair, a one-line assessment of whether merging them would make the reviewer's job harder or easier]. My recommendation: [keep separate / merge these two / merge these three]."*
- *"R[i] and R[j] both touch the same files and each plan-modes into only 2-3 internal steps. By the review-unit test, they could be combined into one issue that plan-modes into ~5-7 steps — the 'why R[i] before R[j]' reasoning becomes internal step ordering in the merged issue. Combine, or keep separate?"*

### Dependency confirmation

- *"R[i] depends on R[j] being closed first. The dependency reason is [explanation]. Sound right, or is the dependency wrong?"*
- *"R[i] has no dependencies — it can be picked up first. R[j] depends on R[i]. R[k] depends on R[j]. The full chain is [sequence]. Confirm the chain?"*

### Capstone identification

- *"R[N] looks like the capstone — it's the last issue in the milestone and integrates the prior R-issues by [specific integration]. Confirm capstone status?"*
- *"This milestone doesn't seem to have a natural capstone — the work is more of a parallel set of additions than a building sequence. I won't mark a capstone. Sound right?"*

## Step 5 — Individual spec drafting

### Spec presentation (full mode, one at a time)

- *"Here's the spec for R[i]. Walk through the sections with me: Context [content], Implementation [content], Acceptance criteria [content], Done signal [content], Dependencies [content], PR contract [content]. Approve, or want me to iterate on any section?"*

### Spec presentation (standard/light mode, batched)

- *"Here are all [N] specs. The hottest section in each is Implementation — that's what `/finish` will anchor on. I'd suggest reviewing Implementation for each first, then the other sections second. Where do you want to start?"*

### Implementation section iteration

- *"R[i]'s Implementation section is [N] words — within the 300-800 target (or: short for the range but honest-brevity because the work is genuinely simple / at the high end but justified by cross-crate capstone scope). The eight properties check: [property check summary including property 8]. Sound right, or revise?"*
- *"R[i]'s Implementation section is over 1100 words. Three possible reasons: (a) the issue is too big and should be split, (b) the prompt includes non-essential context that belongs in the Context section or cited docs, or (c) the prompt has drifted into prescriptive 'how' prose — per property 8, convert inlined code blocks to constraint sentences. My diagnosis: [a/b/c]. Recommendation: [split / move context / convert code blocks]. Your call?"*
- *"R[i]'s Implementation section is under 250 words. Either the issue is too small (fold into another issue — review-unit test suggests merging with R[j]) or the spec is too vague (add specific files, constraints, and invariants per property 3). My diagnosis: [too small / too vague]. Your call?"*
- *"R[i]'s Implementation section has [N] fenced code blocks. [For each:] Block [n] is [verbatim from IC-[m] / NOT from a locked IC]. [If not from IC]: could this block be converted to a constraint sentence without losing information, or is there a specific reason to inline the code? Per property 8, non-IC code blocks are a failure mode unless they carry a decision that must be locked at the spec layer rather than the plan-mode layer."*
- *"R[i]'s Implementation section names the file path but not the function signature. The signature isn't pinned down by a locked IC — per property 3's delegation pattern, I'll leave it as 'plan mode's call, propose during plan and we'll lock it in' rather than guessing at it. Confirm, or do you want to pin the signature now?"*

### Acceptance criteria iteration

- *"R[i]'s acceptance criteria are: [list]. Each one is observable and verifiable. Anything missing, or anything too vague?"*
- *"The acceptance criterion 'tests pass' is too vague. The specific test that should pass is [test name]. Confirm I should rephrase it as 'running [exact command] produces [exact output]'?"*

## Step 6 — Final pre-commit

### Final pre-commit review

- *"About to commit rough-in for `<workstream-slug>:F<#>:M<#>`. Here's what will land: [N] sub-sub-issues parented under [parent framing sub-issue], plus a `README.md` index entry recording the rough-in event. Atomic transition — either both halves land or neither. Approve?"*
- *"For re-rough-in: I'll also supersede the prior R<X>, R<Y>, R<Z> (close + label `superseded`) as part of the same atomic transition. The already-merged R<A>, R<B> stay completed. Confirm?"*

### Idempotency edge cases

- *"I detected [N] sub-sub-issues that already exist under the parent framing sub-issue with R-numbers I was about to use. The most likely cause is a previous rough-in run that committed some sub-sub-issues before failing partway through. Three options: (a) skip duplicates and only commit the missing ones, (b) supersede the existing ones and commit a fresh set, or (c) abort and resolve the duplication manually. Which?"*

### Planning-axis-aware variants

- *"Planning backend = `in-repo-markdown` — no external planning backend half. Where do you want the rough-in specs to land? (a) appended to the existing `frame-NN.md` file as a new `## Rough-in M<#>` section, or (b) new per-milestone rough-in markdown file at `docs/cbk/frame-NN-M<#>-rough-in.md`. Default for [N] R-issues is [a/b]. Override?"*
- *"Planning backend = `linear` — I'll proceed cautiously and surface anything I'm uncertain about as I go. The Linear Milestone for this framing is [name]. Confirm I should create N Linear Issues under it?"*

## Cross-step: when rough-in needs to escalate

### Escalating to framing

- *"What I'm finding during research suggests the framing's M[n] capability statement is [too narrow / too broad / missing a constraint that matters at this layer]. I think this is bigger than rough-in can fix — recommend re-framing M[n]. Two options: (a) stop rough-in, you re-frame, then I resume against the new frame-NN+1.md, or (b) I produce specs that explicitly note the gap and you re-frame later. Which?"*
- *"The framing's interface commitment for [interface] doesn't match what I need to spec for R[i]. The mismatch is [specific]. I think this needs to be resolved at the framing layer before rough-in can produce a clean spec for R[i]. Stop and re-frame, or produce a deferred-decision spec?"*

### Escalating to blueprint

- *"R[i] would touch [stack component], but blueprint's stack decisions don't include it. This is bigger than rough-in or framing — it's a stack decision. Stop, loop back to blueprint, or produce a spec that flags the gap?"*

### Escalating to scaffold

- *"`.github/ISSUE_TEMPLATE/cascade-rough-in.md` is missing from the repo. This means scaffold's Stage 2.5 was never run. I can use the bundled fallback template for this rough-in run, but I'd recommend re-running scaffold's Stage 2.5 first to commit the cascade templates so future runs read from disk. Want me to (a) proceed with the fallback, (b) stop and re-run scaffold's Stage 2.5 first, or (c) commit just the rough-in template manually as a one-off?"*
