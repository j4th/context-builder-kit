# HITL question bank — framing phase

Categorized questions for HITL clarification rounds during framing. Pick the ones where inheritance leaves genuine ambiguity. Aim for 3–5 questions per gate, covering at least 2 categories per round. Adapted from blueprint's hitl-question-bank.md with framing-specific sections for project selection, milestone shape, interface commitments, and acceptance criteria.

**Citation discipline**: where a question references a specific pattern, name the source. Pattern names come from `methodology_register.md`; cite vertical slicing as Patton, walking skeleton as Cockburn, tracer bullets as Hunt & Thomas, spike solutions as Beck. Unsourced pattern recommendations are a bug.

## Inheritance verification (Step 1, before any decisions)

Used during the inheritance check. The goal is to confirm framing understood what the prior phases produced — not to make new decisions yet.

- I read the brief as: <one-sentence summary>. Is that an accurate compression?
- Scaffold's quality bar entry was: <verbatim>. Should I treat that as still-current, or has anything shifted?
- The blueprint workstream I'm framing is: <verbatim row>. Is that the right project to frame now, or did you want a different one?
- Blueprint picked <methodology> with the justification <verbatim>. Confirming that methodology still applies to this specific project.
- Blueprint's deferred decisions relevant to this project are: <list>. Any of these that got resolved outside the cascade I should know about?
- ARCHITECTURE.md DECISION-NNN entries that constrain this project: <list>. Are any of these under reconsideration?

**For re-framings specifically**:
- I see frame-<N> as the prior framing of this project. Confirming you want me to treat it as superseded, and the new framing captures the changes.
- Interface commitments from frame-<N> that carry forward unchanged: <list>. Any of these that should be removed?
- Interface commitments from frame-<N> that are no longer valid: <list>. Confirming these get explicitly removed in the new framing.

**For subsequent framings (not frame-01)**:
- I see <N> prior framings in `docs/cbk/`. The ones with interface commitments relevant to this project are <list>. Confirming I should read these in full.
- Any prior framings I should re-read because their status changed recently?

These are verification questions, not decision questions. The user's answer is usually "yes accurate" or "no, X has changed." Move on quickly once inheritance is confirmed.

## Project selection (Step 2)

Used when the user hasn't explicitly named which workstream to frame, or when the pick needs confirmation.

- You've got <N> workstreams in blueprint. Based on <signal — dependency order, prior framings completed, user's opening message>, my read is you want to frame **<project name>** next. Sound right?
- Looking at `docs/cbk/README.md`, I see frame-<N> just completed. The natural next project per blueprint's sequence is **<project name>**. Confirming.
- You mentioned wanting to frame <project X>, but blueprint's dependency graph says <project Y> needs to come first because <reason>. Want to reorder, or frame Y first?
- This would be frame-<NN+1> based on the chronological index. Confirming the framing number.

**For edge cases**:
- This project isn't in blueprint's workstreams table — it was added later. Want me to (a) frame it directly and note the out-of-blueprint status in the header, or (b) loop back to blueprint to add it first?
- This is a re-framing of <project name>. Confirming the prior framing was frame-<N> and this becomes frame-<NN+1> with a `Supersedes: frame-<N>` entry.

## Research depth (Step 3, always the first question)

Research depth is a user signal, not a framing judgment. This is the first question of the research phase, before any research runs.

- Looking at this project, the signals say <signal A: greenfield or building-on-existing>, <signal B: deferred decisions from blueprint>, <signal C: user expertise>. My read is **<light | medium | deep>** research depth. Sound right, or do you want me to go deeper or lighter?
- For sub-track 3a (implementation patterns): <my proposal — light because patterns are established from frame-N, OR heavy because this is genuinely new technical territory>. Agreed?
- For sub-track 3c (open technical questions): blueprint deferred <N> questions relevant to this project. Want me to resolve all of them now, or defer some to rough-in?

**Token-pressure questions (if context is filling up)**:
- I'm at <N>% of context budget. To finish this research phase at the depth we agreed on, I'd need to <skim X / drop Y / ask you to continue in a follow-up>. Which do you prefer?
- I can finish sub-track 3a at the depth we agreed but I'll need to compress 3c to fit. Want me to do that, or reduce 3a to make room for a full 3c pass?

## Scope and boundaries (Step 4 — refined definition)

Used when drafting the refined project definition, especially the Boundaries and Interface Commitments sections.

- I'm proposing the project's in-scope list as <list> and out-of-scope list as <list>. Anything I have on the wrong side?
- The brief's no-gos for this project are <verbatim list>. Confirming I should treat all of these as hard constraints in framing.
- This project's relationship to <prior framing / sibling project> is: <my read>. Is that the boundary agreement you want, or should it move?
- Are there scope items from blueprint that should get deferred to a future framing instead of being in scope for this one?

**Interface Commitments specifically** (the highest-leverage section):
- I see <N> downstream consumers for this project's work — <list with prior framings and future framings>. Confirming the list is complete.
- For each interface commitment, I'm proposing stability by <M#>. Here's the table: <draft table>. Any commitments that should stabilize earlier or later?
- This project has no downstream consumers that I can see — its interfaces are internal-only. Confirming that's correct, or am I missing a future framing that will consume these?
- Should any of these commitments be time-bound (stable by a specific date) rather than milestone-bound (stable by a specific M#)?

## Milestone shape and sequencing (Step 5)

Used when drafting milestones. These are the most common questions framing asks because milestone shape is the most judgment-dependent decision.

**Shape questions**:
- My default for this project is **vertical slicing** (Patton, *User Story Mapping*) — each milestone delivers end-to-end functionality for a narrow subset. Sound right, or does this project warrant a different shape?
- For M1 specifically, I'm proposing <walking skeleton | tracer bullet | spike | infrastructure> because <reason>. Agreed? *(Walking skeleton: Cockburn, *Crystal Clear*. Tracer bullets: Hunt & Thomas, *Pragmatic Programmer*. Spike: Beck, *XP Explained*.)*
- This project has a real architectural risk around <X>. Want an explicit spike milestone (M0 or M1) to resolve it before feature work, or fold the risk-reduction into M1's vertical slice?
- The workspace doesn't have <tooling need> for this project. Options: (a) infrastructure milestone as M1, (b) Suggested foundation doc update looping back to blueprint/scaffold, (c) assume you'll set it up manually. Which?

**Unenforced invariants check** (always run during milestone HITL gate, before the user approves the milestone list):
- Walking through STANDARDS.md § Unenforced invariants row by row against the proposed milestones: <list>. For each invariant, I'm checking that no proposed milestone violates it. Here's my pass: <per-row pass/fail/uncertain analysis>. Any I should reconsider, or any invariants I'm reading too strictly?
- Milestone M<#> looks like it might brush against the "<invariant>" rule because <specific concern>. Do I have that right, and if so, how do you want to resolve it — revise the milestone, revise the invariant (Suggested foundation doc update to STANDARDS.md), or accept the risk?
- I don't see any milestones that violate the Unenforced invariants table. Confirming you read the same way, or am I missing something?

**Sequencing questions**:
- I'm proposing this milestone order: <list>. Are there dependencies I'm missing, or milestones that could be parallelized?
- M<#> depends on M<#-1> because <reason>. Confirming, or is that dependency actually looser than I think?
- Are there milestones from <prior framing> that need to be completed before this project's M1 starts?

**Granularity questions**:
- I'm landing on <N> milestones for this project. The typical range is 3-5. Does <N> feel right for this project's appetite, or should I merge/split?
- M<#> is doing a lot — <summary>. Want to split it into two milestones, or is the size deliberate?
- M<#> is very small — <summary>. Want to merge it with M<#+1>, or keep it separate because <reason>?

## Acceptance criteria and done signals (Step 5)

Used when the user has described a milestone's capability but the "done" signal isn't yet explicit.

- For M<#>, the capability is <verb phrase>. The done signal I'd propose is <user-visible outcome — not a test, a demo>. Agreed?
- You said M<#> is "done when the tests pass." That's a test description, not a done signal. Can you name the *user-visible* outcome — what can someone see, run, or demo at milestone close?
- M<#>'s done signal as proposed is <signal>. That's test-shaped. Want to replace it with something more demo-shaped, like <alternative>?

## Rough issues (Step 5)

Used when decomposing milestones into rough issues.

- For M<#>, I'm proposing <N> rough issues: <list with one-sentence intents>. Any missing? Any that feel wrong-sized?
- Issue <#> sounds like it's actually two issues to me — <sub-issue A> and <sub-issue B>. Want to split, or is it really one issue?
- Issue <#> needs <user-managed work / hybrid work>. Flagging as <user-managed | hybrid>. Agreed?
- Issues <#, #, #> have a natural order within the milestone. Want me to note the sub-sequence in the Issue notes section, or leave rough-in to figure it out?

## Foundation doc update suggestions (Step 4 section)

Used when framing notices the project would benefit from foundation doc changes.

- During research, I noticed <gap in CLAUDE.md / missing DECISION in ARCHITECTURE.md / STANDARDS.md doesn't cover X>. I'll flag this in the Suggested foundation doc updates section — you review and apply manually if you agree. Sound right?
- This project will introduce a new pattern (<pattern>) that every future framing will also use. Options: (a) flag it as a Suggested ARCHITECTURE.md DECISION entry now, (b) let it emerge organically, (c) something else. Which?
- You mentioned wanting to add <tooling> for this project. My suggestion: flag as a Suggested CLAUDE.md update rather than adding it unilaterally. Confirming.

## Open question framing

When the user can't or doesn't want to resolve something during framing, frame it as an explicit open question with a trip-wire:

- This sounds like something to defer to rough-in — want to add it as an open question with the trip-wire being <observable condition>?
- We could spike this in a subsequent framing instead of deciding now. Want to leave it open and revisit at frame-<N+1>?
- Park this as an open question for rough-in? It would carry forward in the Handoff Context so rough-in sees it.

## Anti-questions (do not ask)

- "How should I frame this project?" cold — always lead with a proposal from inherited context
- "Which milestones should we have?" — propose a set, let the user refine
- "Is vertical slicing the right shape?" without a default — always propose vertical slicing as the default and ask whether the project warrants something else
- "Do you want this to be an infrastructure milestone?" without explaining the trade-off — always surface the not-when-to-use conditions so the user can check against them
- Yes/no questions without a default — always include the default in the question itself
- Questions that relitigate stack decisions blueprint already made — treat those as facts, not questions

## How many questions per round

Default: 3–5 questions per gate, batched. At `light` rigor, collapse to 1–3 per gate. At `full` rigor, 5–8 per gate with one-question-at-a-time variant available for steps where it makes sense (milestone shape sometimes benefits from going one at a time).

Round structure for framing:
- **Round 1 — inheritance verification** (no new decisions)
- **Round 2 — project selection** (often just one confirmation question)
- **Round 3 — research depth proposal** (always; user signal, not framing judgment)
- **Round 4 — research findings + approach landing** (full mode only; collapsed into gate 2 in standard mode)
- **Round 5 — refined definition review** (scope, boundaries, interface commitments)
- **Round 6 — milestone review** (shape, sequencing, granularity, acceptance, rough issues)

Most framing sessions land at 4-5 rounds total. Sessions that need 7+ rounds usually mean inheritance was incomplete and framing is doing blueprint's job — stop and check whether the user wants to loop back to blueprint.
