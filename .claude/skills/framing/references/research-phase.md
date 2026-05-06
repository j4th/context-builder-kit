# Research phase — depth confirmed by user

Step 3 of framing. Two sub-tracks, each running in every rigor mode but with **depth confirmed by the user, not chosen by framing**. The goal is to resolve genuine uncertainty before producing milestones, not to redo work that blueprint already did.

The most common failure mode is over-research: spending an hour searching for library options when the architecture docs already specify the choice. The second most common is under-research: producing milestones without resolving a load-bearing technical question, which then forces the rough-in phase to relitigate it. **Framing does not get to silently decide which mode to be in** — it surfaces the signals and lets the user pick.

## Research depth is a user signal, not a framing judgment

This is load-bearing and worth stating explicitly: framing **never decides on its own** to skip research, scale down, or stop early. The reason is that the user can't tell from the milestone output whether framing did a thorough research pass or a shallow one — the milestones look the same either way. If framing silently scales down, the user assumes they got the full pass and acts on milestones that may have unresolved questions baked in.

The right shape: framing **surfaces the signals** that suggest research depth and **proposes a depth in one sentence**, then lets the user confirm or override. Same shape as the rigor dial, not a hidden default.

**The proposal pattern**:

> "Looking at this project, the signals say [signal A: greenfield, no prior framings to inherit from], [signal B: blueprint's stack decisions resolved most of the open questions], [signal C: you mentioned in scaffold that you've done this kind of work before]. Based on these, my read is **medium research depth** — sub-track 3a (implementation patterns) is light because patterns are well-established, sub-track 3c (open questions) is the main work because there are 3 deferred decisions from blueprint. Sound right, or do you want me to go deeper or lighter?"

The user confirms or overrides in one word. *"Go deeper"* / *"that's about right"* / *"actually skip 3a entirely, I know the patterns"* / *"do the full thing"* — all valid one-word overrides.

**When framing hits token pressure**: surface it explicitly. *"I'm hitting token budget pressure reading the prior framings in full. I've finished frame-01 and frame-02; frame-03 still to go. I can either (a) finish frame-03 and produce shallower research, (b) skim frame-03 and produce full research, or (c) you can ask me to continue in a follow-up message after I produce the shallower version. Which?"* The user needs to know that token limits stopped the work, not assume the work is complete. **Never silently produce partial work and present it as complete.**

## Sub-track 3a — Implementation patterns

When the project has no code in the area or is building something new:
- Search for **reference implementations** in the target language/framework
- Look for **library options and tradeoffs** — present 2-3 options with trade-offs, not exhaustive surveys
- Find **established patterns** for the component types in this project
- Validate findings against the user's actual context — *"the standard pattern is X, but your scaffold says you're using Y, do you want to follow X or extend Y?"*

When the architecture docs already specify the approach:
- **Validate** that the specified approach is still current as of framing time
- Search for **gotchas or known issues** with the approach that have surfaced since blueprint ran
- Find **concrete code examples** that demonstrate the pattern — these become reference material in the milestone descriptions

**Cite from `methodology_register.md` where relevant — at the per-milestone level**, not at the project-level. Blueprint already cited the register when it picked the **project-level methodology** (Shape Up, Kanban, Scrum). Framing's citations are at a different layer: the **per-milestone planning patterns** like vertical slicing (Patton, *User Story Mapping*), walking skeleton (Cockburn, *Crystal Clear*), tracer bullets (Hunt & Thomas, *The Pragmatic Programmer*), spike solutions (Beck, *XP Explained*), and YAGNI (Fowler). When the research surfaces a pattern question that the register has an answer for, cite the register entry by name and quote its "fails when" conditions. The two layers are complementary — blueprint picks the methodology that governs the whole project, framing picks the shape of individual milestones within that methodology, and both cite the register at their own layer.

**Skip carefully, never silently.** If frame-01 already established a pattern that frame-02 can inherit, surface this explicitly: *"frame-01 already established the verifier trait pattern, so I'm not researching it from scratch — let me know if you'd rather I start fresh."* The user gets to choose whether the inherited pattern should be re-researched.

## Sub-track 3c — Resolve open technical questions

The questions to resolve:

- **Library choices that affect milestone boundaries** — if "we'll use library X" means M2 looks completely different than if "we'll use library Y," resolve before producing milestones
- **Pattern choices that affect build sequence** — if pattern A means M1 is "build the schema" and pattern B means M1 is "build the API endpoint," resolve before sequencing
- **Interface decisions that affect downstream consumers** — if this project has Interface Commitments to make, what those commitments commit to is a load-bearing decision that the next framing depends on
- **Methodology-specific decisions** — if blueprint picked Shape Up, what's the appetite for this project? If blueprint picked Kanban, what's the WIP limit during this project? These flow from blueprint but get instantiated here.

**The presentation pattern**: surface each unresolved question as a discrete decision the user makes, with 2-3 options and the trade-offs of each. Do not present a blank slate ("how should we handle X?") — propose a default with justification and let the user override.

```
Three open technical questions for this framing:

1. **TOML library choice** — `toml` (de facto standard, derive support)
   vs `toml_edit` (preserves formatting, slower). My lean: `toml` because
   the lessons are read-only and we don't need round-tripping. Sound right?

2. **Lesson schema versioning** — embed a `version` field in each lesson
   (loose, easy) vs use a content-addressed hash (strict, hard to migrate).
   My lean: `version` field, defer hashing to v2. Sound right?

3. **Verifier error format** — structured (`Result<Pass, VerifyError>`
   with typed errors) vs string-based. My lean: structured, because
   future packs will need to introspect failures. Sound right?
```

The user can confirm all three in one message, or push back on individual ones. Either way, the answers feed directly into the refined definition (Step 4) as Approach decisions.

## What framing does NOT research

Some things look like they belong in framing's research phase but actually belong elsewhere in the cascade. **Cross-reference `backends.md` for the interface contract between phases — framing operates at the project level, blueprint operates at the workspace level, and the boundary matters.**

- **MCP server selection** — belongs in **blueprint**'s stack decisions and tooling configs step. Blueprint commits `.mcp.json`. Framing inherits whatever MCP servers blueprint set up and uses them; it does not select new ones. If framing notices the project would benefit from an MCP server that isn't in the current setup, flag it as a **Suggested foundation doc update** in Step 4 — never silently add it.
- **Claude Code plugin selection** — same pattern as MCP servers. Belongs in blueprint, surfaced by framing only as a flagged suggestion.
- **Stack decisions** (language, framework, storage, distribution) — belong in blueprint. Framing inherits them and treats them as constraints, never relitigates.
- **Methodology selection** — belongs in blueprint. Framing inherits the methodology and applies it (e.g., Shape Up means appetite-based milestones; Scrum means sprint-bounded milestones).
- **CI gate decisions** — belong in blueprint's STANDARDS.md PR review checklist. Framing inherits the gates and ensures milestone completion criteria respect them.

**The shared pattern**: framing operates at the **project level**, not the **workspace level**. Workspace-level decisions belong to phases that ran before framing. Framing's research phase only covers project-level questions — patterns, libraries, interfaces, sequencing — that blueprint deliberately deferred to project-level resolution.

## How research findings flow into the refined definition

After the research phase completes:

- **Implementation patterns research** → feeds into the Approach section of the refined definition
- **Open question resolution** → feeds into Approach (for resolved questions) or Open questions (for questions deliberately deferred to rough-in)
- **Suggested tooling additions** (if any) → feeds into the Suggested foundation doc updates section, never directly applied

## HITL gate

In **full mode**, present the research findings inline before moving to Step 4. The gate question:

> "Here's what the research surfaced. The technical approach I'd take based on these findings is [proposal]. Anything I should reconsider, or are we good to produce the refined project definition?"

In **standard mode**, this gate is collapsed into the gate-2 review (refined definition + milestones combined). The depth proposal still happens explicitly, but the research findings are presented together with the refined definition.

In **light mode**, the depth proposal still happens (because that's a user signal, not a default), but the depth gets confirmed in the up-front confirmation rather than as a separate gate, and the actual research runs without further interruption.

## Failure modes specific to this step

- **Silently scaling down research** — most dangerous. The user can't tell from the output whether framing did a deep or shallow pass. Defense: depth is a user signal, never a framing judgment.
- **Hitting token pressure and stopping silently** — second most dangerous. The skill stops mid-research when context fills up and produces milestones based on the partial research. Defense: surface token pressure explicitly, give the user the choice of finishing partial work vs doing a follow-up message.
- **Over-researching when the user already knows the answer** — common in greenfield projects when the user has done similar work before. Defense: ask about user expertise as part of the depth proposal.
- **Researching things that belong in blueprint** — the "what framing does NOT research" list above. Defense: when in doubt about whether something is project-level or workspace-level, err toward "this is blueprint's job" and flag suggestions instead of acting unilaterally.
- **Recommending patterns without citing `methodology_register.md`** — happens when sub-track 3a finds a pattern but doesn't tie it back to the cascade's shared knowledge. Defense: every pattern recommendation cites the register entry by name when one exists.
- **Inheriting prior framing patterns silently** — frame-02 reuses a pattern from frame-01 without telling the user. The user assumes the pattern got fresh research. Defense: explicit surfacing — *"frame-01 already established X, so I'm inheriting it; say so if you'd rather I research from scratch."*
