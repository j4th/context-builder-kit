# Rough-in research phase

This file is the operational detail behind rough-in's Step 3 (Research phase). It covers the depth-as-user-signal pattern, the two research sub-tracks, what rough-in researches versus what upstream phases already covered, and when the research phase can be skipped entirely.

Research is the most variable step in rough-in. Some milestones need zero research because they're straightforward extensions of prior work; some need substantial research because they introduce a new pattern, library, or technique. Getting the depth right is the difference between a 4-turn rough-in and a 12-turn rough-in.

## Depth is a user signal, not a rough-in judgment

The cardinal discipline of the research phase is that **research depth is a user signal**, not something rough-in decides on its own. Rough-in surfaces the signals that suggest a depth (the complexity of the rough issues list, the framing's open questions, the user's expertise, whether the stack has been exercised by prior rough-in runs) and proposes a depth in one sentence. The user confirms or overrides.

This is the same pattern framing uses for its research phase, and it exists for the same reason: the model has a strong tendency to default to "more research is safer," which produces 8-turn research phases for milestones that only needed 30 seconds of pattern lookup. Pushing depth onto the user as an explicit signal short-circuits that default.

**The proposal sentence template**:

> "Based on [signals from inheritance], I'd propose [shallow / standard / deep] research for this milestone. [Specific things I'd look up]. Sound right, or do you want to adjust depth or scope?"

Examples:

> "This is the second rough-in in the regex-pack workstream and M2 builds directly on M1's trait infrastructure with no new external dependencies. I'd propose **shallow** research — just verifying the `regex` crate's API hasn't changed since M1 and confirming the test fixture format. Sound right?"

> "M3 introduces tmux as a new external dependency and the verifier shape (subprocess-driven verification via format strings) hasn't been used in this codebase before. I'd propose **deep** research — looking up tmux's display-message API in detail, finding canonical patterns for spawning sessions in test environments, and checking whether the existing verifier trait needs any extensions to accommodate the new shape. Sound right?"

> "M1 of a new workstream with no prior cascade work in this codebase. I'd propose **standard** research — the rough issues list mentions a specific library and a specific test pattern, so I want to look up the idiomatic shape for both, but I don't need to do an architectural deep-dive. Sound right?"

The user can accept (one word: "yes" or "go"), adjust depth ("go shallower" or "deeper"), or scope-edit ("skip the test pattern lookup, I'll handle that later"). Don't ask for justification when the user adjusts — the user knows their context better than rough-in does.

## Token pressure honesty

When rough-in hits token pressure during the research phase, **surface it explicitly and give the user the choice** between (a) finishing partial work, (b) skimming to fit, or (c) continuing in a follow-up message.

The phrasing:

> "I'm running low on context budget for this turn. I've completed [the parts I've finished] but [the parts I haven't gotten to yet] are still pending. I can either: (a) finish what I have and present it as partial, leaving the rest for the next turn, (b) skim the remaining parts to fit them into this turn at lower depth, or (c) stop here and continue in a follow-up message. What's your preference?"

**Never silently produce partial work and present it as complete.** The most insidious failure mode is the model rushing through the last 30% of research because it sensed token pressure and didn't say so — what shows up downstream is a spec missing a critical detail that would have surfaced if the research had been complete.

## The two research sub-tracks

Rough-in has two distinct research sub-tracks. Either, both, or neither may apply to a given milestone depending on what the milestone needs.

### Sub-track 3a: Implementation patterns

**Goal**: resolve technical approach questions that would otherwise block issue spec drafting or force Claude Code to relitigate them during execution.

**What this looks like in practice**:

- Looking up the idiomatic shape of a specific operation in the chosen language/framework (e.g., "what's the canonical async pattern for spawning a child process with a PTY in Rust 2021?")
- Verifying that a library's public API matches what the rough issues list assumes (e.g., "does `regex 1.10` still expose `Regex::new` returning `Result`?")
- Finding canonical examples of a pattern from authoritative sources (the language's standard library docs, the framework's official guides, well-known reference implementations)
- Checking whether a library has known gotchas or version-specific behavior changes that would affect the spec
- Reading the specific section of `docs/ARCHITECTURE.md` or `docs/STANDARDS.md` that constrains how this milestone is allowed to be implemented

**What this does NOT look like**:

- Architectural decisions (those belong in blueprint or framing, not rough-in)
- Choosing between competing libraries (that's blueprint's stack decisions step)
- Inventing patterns from scratch (rough-in either finds canonical patterns or escalates to framing if the pattern isn't established)
- Deep-diving into theory or computer science (rough-in is operational, not academic)

**Sources to prefer** (in priority order):

1. The cascade docs themselves (CLAUDE.md, ARCHITECTURE.md, STANDARDS.md, blueprint.md, frame-NN.md) — these are authoritative and already-approved
2. The official documentation of the language, framework, or library being used
3. Source code of the libraries themselves when their docs are sparse
4. Well-known reference implementations and canonical examples
5. **Last resort**: blog posts, Stack Overflow, AI-generated tutorials — these can mislead, so cite them only when nothing more authoritative exists, and explicitly mark them as "secondary source" in the spec

**When to use a search tool**: when the question is "what's the current state of X" or "did X change in version Y," the cascade docs and library source code can't answer that — search is the right tool. When the question is "how does X work in our codebase," the cascade docs and source code ARE the answer — search would be wasteful and potentially misleading.

### Sub-track 3c: Resolve open questions from framing

**Goal**: clear any framing-level open questions that have a trip-wire mentioning rough-in or this specific milestone.

**Process**:

1. Read the Open questions section of frame-NN.md
2. Filter to questions whose trip-wire says "revisit during rough-in" or "revisit at M_n" where M_n is the milestone being roughed-in
3. For each question, **either resolve it with the user or escalate it back to framing**:
   - **Resolvable in rough-in**: the question has narrowed enough during framing that a quick user decision settles it. Examples: "Should the loader cache parsed lessons in-process or re-parse on each invocation?" "Which assertion library should the unit tests use?"
   - **Escalation to framing**: the question has gotten bigger or revealed a structural issue that wasn't obvious at framing time. The right move is to stop rough-in, surface the escalation, and ask the user to either re-frame the workstream (cascade event, new frame-NN+1.md) or accept that the question stays open and the milestone's specs will have explicit "decision deferred to execution" placeholders.

**The escalation phrasing**:

> "Framing's open question '[verbatim]' was supposed to be resolved during rough-in, but it's grown — resolving it now would require [specific architectural change or new constraint that wasn't in framing's scope]. I'd recommend either (a) re-framing this workstream to incorporate the new constraint, or (b) producing rough-in specs that explicitly defer the decision to execution time. Which do you prefer?"

Don't try to resolve escalation-worthy questions silently. The cost of getting it wrong is high (downstream specs based on a decision the user wouldn't have made if asked) and the user is usually happy to make the call when prompted.

### Why there's no sub-track 3b

Framing has three sub-tracks (3a implementation patterns, 3b architectural patterns, 3c open questions). Rough-in only has two — implementation patterns (3a, same as framing) and open questions (3c, same as framing) — but no architectural patterns sub-track.

The reason: architectural decisions belong in blueprint and framing. By the time rough-in runs, the architecture is settled. If rough-in finds itself wanting to do architectural research, that's a signal that something wasn't pinned down at the right layer and the right move is to escalate (sub-track 3c style) rather than to do the architectural work in rough-in.

This is a deliberate constraint — rough-in is operational, not architectural. The skill enforces it by not having a 3b sub-track.

## What rough-in does NOT research

- **Stack decisions** (which language, framework, runtime, libraries) — those are blueprint's layer
- **Methodology selection** (Shape Up vs Scrum vs Kanban) — blueprint's layer
- **Workstream-level interface commitments** (what trait/API/vocabulary the workstream commits to) — framing's layer
- **MCP server selection or cascade-level conventions** — scaffold/blueprint's layer
- **Anything in the problem brief** — that's consultation's layer and is read as inheritance, not researched
- **Cross-workstream concerns** — those surface in framing's cross-framing commitments table, not in rough-in's research

If rough-in finds itself wanting to research any of these, it's a signal that an upstream phase was incomplete. The right move is to surface the gap and either (a) loop back to the upstream phase or (b) explicitly accept the gap and note it in rough-in's output as a "Suggested upstream revision" item.

## When to skip the research phase entirely

The research phase is **skippable** when all of the following are true:

1. The milestone is a direct extension of an immediately prior milestone in the same workstream (e.g., M2 extends M1's trait with one more concrete impl)
2. The rough issues list contains no new external dependencies, no new patterns, and no new API surfaces
3. The framing's open questions section has no entries with trip-wires mentioning this milestone
4. The user explicitly says "skip research" or "go straight to issue plan"

If all four conditions hold, rough-in can move directly from Step 2 (milestone selection) to Step 4 (issue plan) without producing any research output. Note in the inheritance summary that research was skipped and why: *"Research phase skipped — M2 is a direct extension of M1, no new dependencies, no open questions on this milestone, and the user explicitly chose to skip."*

The first three conditions are objective and rough-in can detect them; the fourth is the user's signal. Rough-in proposes the skip if the first three hold:

> "M2 looks like a direct extension of M1 with no new dependencies, no open questions, and no new patterns. I'd propose **skipping the research phase entirely** and going straight to the issue plan. Sound right, or do you want me to do at least a shallow pass on something specific?"

Skipping research is the right call more often than the model's instincts suggest. When in doubt, propose the skip and let the user override if they want depth.

## Research output format

Whatever depth rough-in lands on, the research output is presented to the user in a structured form before Step 4 (issue plan) starts. The format:

```markdown
## Research findings

### Implementation patterns

- **<pattern name>**: <one-paragraph summary, with citation>
- **<pattern name>**: <one-paragraph summary, with citation>

### Open questions resolved

- **"<verbatim question from frame-NN.md>"**: <user's decision and the
  reasoning, in one sentence>

### Open questions escalated

- **"<verbatim question>"**: escalated to framing because <reason>.
  Status: <user's decision — re-frame or defer to execution>

### Citations

- [link to source 1]
- [link to source 2]

### Skipped (and why)

- [Anything the user asked rough-in to skip during research, with the reason]
```

The findings section is reused later when drafting the individual specs — each pattern from research becomes a "follow this pattern" reference in the relevant spec's Implementation section. Resolved questions become explicit decisions in the specs' Context sections. Escalated questions either trigger a re-framing (and rough-in stops) or become explicit "decision deferred" placeholders in the specs.

## HITL gate after research (full mode only)

In full mode, the research findings are presented as a separate HITL gate before Step 4 starts. The gate language: *"Here are the research findings plus the resolved/escalated questions. Anything to correct or expand before I draft the issue plan?"*

In standard mode, this gate is collapsed into the next gate (Step 4's issue plan review) — the research findings are presented inline at the top of the issue plan presentation, and the user reviews both at once.

In light mode, neither this gate nor the issue plan gate runs separately — the user's up-front combined confirmation covers both, and rough-in proceeds from research directly to spec drafting.
