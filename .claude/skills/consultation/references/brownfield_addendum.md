# Brownfield addendum

Runs when `prior=brownfield` (significant existing codebase/system) or `prior=partial` (some prior decisions or attempts exist). Adds a **current-state assessment step** that runs *before* the four main steps, and adds section 8 (`Current state`) to the problem brief.

**Do not run a codebase analysis in consultation.** That belongs in blueprint. The addendum only captures what the user can tell you about the existing state from their head — it's a conversation, not an audit.

## Step 0 — Current state assessment

Runs first, before problem discovery. Goal: understand what exists so the rest of the interview can treat existing constraints as facts rather than open questions.

**Core questions** (batched at `standard`, one-at-a-time at `full`):

- What exists today that's relevant to this project? Repos, running services, prior attempts, data, documents?
- What works well in the existing system that you want to keep?
- What's broken or painful that you want to fix or replace?
- What constraints does the existing system impose on new work — interfaces, data formats, operational dependencies, team skills?
- Is there prior work (your own or others') that you're tempted to port forward? (Flag scope-gravity risk.)
- Would a codebase analysis in blueprint be useful, or do you already have a clear enough mental model?

**Scope-gravity flag**: brownfield projects have a strong pull toward "rebuild everything the old thing did, plus the new thing." Name it out loud: *"The old system did X, Y, Z — are any of those in scope for this project, or are they carried over from habit?"* This usually surfaces at least one no-go.

**Exit criteria**: you can describe the existing state in 3–5 sentences and the user agrees it's accurate. You know which parts are facts (immovable constraints) vs. which parts are decisions (can be changed).

## Section 8 — Current state (brief)

Add this section at the end of the problem brief, after success criteria. Structure:

```markdown
## 8. Current state

<2–4 sentences describing what exists today and the author's relationship
to it. Named components, not abstract categories.>

**What works / worth keeping**: <brief list>

**What's broken / worth replacing**: <brief list>

**Hard constraints from existing state**: <things the new work must
integrate with or preserve — data formats, interfaces, running services>

**Codebase analysis needed in blueprint**: <yes / no, with one-sentence
justification>
```

## Worked example — brownfield: replacing a crufty build script

`rigor=standard, prior=brownfield`. Abbreviated to show only sections 1 and 8 — the other sections follow the same shape as the greenfield examples in `problem_brief_template.md`.

```markdown
## 1. Problem statement

The team has a build script that started as 30 lines of bash three years ago
and has grown to 800 lines with nested conditionals, undocumented environment
variable dependencies, and at least two code paths nobody currently on the
team fully understands. It still works, but every change is scary and new
hires lose a full day to figuring out what it does. The pain isn't that it's
broken — it's that it's a source of fear and lost time on every change.

[... sections 2–7 ...]

## 8. Current state

The existing `build.sh` script is the single source of truth for how the
project builds, tests, packages, and deploys. It is called by CI, by a
Makefile wrapper, and directly by developers. Output paths and environment
variable names are load-bearing — other tooling depends on them.

**What works / worth keeping**:
- The actual build and test steps produce correct output
- CI integration is stable and nobody wants to touch it
- The Makefile wrapper is used by muscle memory across the team

**What's broken / worth replacing**:
- Control flow is unreadable; nested conditionals obscure what runs when
- Environment variable dependencies are undocumented
- No test coverage for the script itself

**Hard constraints from existing state**:
- Must produce the same output paths and artifact names (downstream
  consumers depend on them)
- Must remain callable from CI with the same invocation signature
- Must still work when called from the existing Makefile wrapper during
  the transition period

**Codebase analysis needed in blueprint**: yes — the script is small
enough to read fully but has enough load-bearing undocumented behavior
that blueprint should budget time for a full read-through before picking
a replacement approach.
```

Note how the example treats the existing script as a fact, not a thing to argue with. The brief preserves the constraints (output paths, CI signature, Makefile wrapper) without picking a replacement technology — that's blueprint's job.

## Brownfield-specific failure modes

Watch for these in addition to the standard failure modes from `SKILL.md`:

- **Scope gravity from prior work** — user wants to port every feature the old thing had. Force explicit "which of these are actually in scope for *this* project" conversation. Most end up as no-gos.
- **Treating the existing system as an open question** — user re-debates decisions that are already facts ("should we even use a build script?"). Redirect: *"That's a decision the existing system already made. For this project it's a constraint, not a choice. What are you changing?"*
- **Premature codebase diving** — user wants Claude to read the existing code during consultation. Refuse politely. *"Codebase analysis belongs in blueprint (phase 3). Consultation is about the problem and the shape of the change — let's stay at that level for now."*
- **Missing the "what works" list** — brownfield briefs often focus entirely on what's broken. The "worth keeping" list is how the brief protects the good parts of the existing system from being carelessly replaced. Insist on at least one item.
