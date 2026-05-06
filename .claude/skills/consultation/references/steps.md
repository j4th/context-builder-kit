# The four-step interview playbook

Full question banks and rigor-dial phrasings for the consultation interview. Read this before starting the interview. The four steps run in strict order — do not skip ahead even if the user pushes.

## Source prompts (authoritative)

These are the practitioner prompts the cascade is grounded in. Reference them when shaping your own phrasing.

**Harper Reed's brainstorming prompt** (one-at-a-time, from *"My LLM codegen workflow atm"*, Feb 2025):
> "Ask me one question at a time so we can develop a thorough, step-by-step spec for this idea. Each question should build on my previous answers, and our end goal is to have a detailed specification I can hand off to a developer. Let's do this iteratively and dig into every relevant detail. Remember, only one question at a time."

Use this phrasing at `rigor=full`. Source: harper.blog, Feb 16 2025.

**Claude Code's interview technique** (batched, from Anthropic's best practices):
> "I want to build [brief description]. Interview me in detail. Ask about technical implementation, UI/UX, edge cases, concerns, and tradeoffs. Don't ask obvious questions, dig into the hard parts I might not have considered. Keep interviewing until we've covered everything, then write a complete spec."

Use the *spirit* of this (batched, skip-obvious, dig-into-hard-parts) at `rigor=standard`. Source: code.claude.com/docs/en/best-practices.

**Shape Up's shaping steps** (Singer, *Shape Up* chapters 2–5): set boundaries (appetite) → rough out elements (fat-marker sketch) → address risks and rabbit holes → write the pitch. The pitch has five parts: Problem, Appetite, Solution, Rabbit Holes, **No-Gos**. The problem brief mirrors this structure — the five Shape Up sections map directly onto sections 1, 3, 4, 5, 6 of the brief. Source: basecamp.com/shapeup.

## Step 1 — Problem discovery

**Goal**: understand the pain, not the solution. Resist solutioning even when the user pushes.

Shape Up's dictum: *"The best problem definition consists of a single specific story that shows why the status quo doesn't work."* You're hunting for that story.

**Core questions** (batch 3–5 at `standard`, one-at-a-time at `full`):
- Who has this problem? Be specific — a named user, a team, yourself?
- How do they handle it today? Walk me through the current workaround.
- What specifically makes the current situation unacceptable — time, cost, error rate, frustration?
- When does the problem bite hardest? Is it constant, or triggered by specific moments?
- If this problem disappeared tomorrow, what would change for the user?

**Redirect phrases** when the user solutions too early:
- "Hold that solution for a minute — before we design it, help me understand the problem it's solving."
- "That's a solution shape. What's the underlying pain it addresses?"
- "Got it, parking that. Back to the problem — who's hurting today?"

**Exit criteria**: you can state the problem in one sentence and the user agrees it's accurate.

## Step 2 — Appetite setting

**Goal**: establish a fixed time/effort/headcount budget *before* discussing solutions. Appetite shapes the solution, not the other way around.

Shape Up: *"How much time do we want to spend? How much is this idea worth?"* Appetite is not an estimate. It is a constraint the solution must fit into.

**Core questions**:
- Is this a weekend hack, a one-to-two week sprint, or a multi-week/multi-month project?
- For teams: how many people, at what roles? Full-time or partial?
- What's the opportunity cost — what are you *not* doing while you work on this?
- What happens if it takes 2x longer than you hoped? Does the project die, or does scope shrink?

**Pushback phrases** when appetite is fake or fuzzy:
- "That sounds bigger than a weekend — want to cut scope or grow the appetite?"
- "'As long as it takes' isn't an appetite. Pick a ceiling and we'll design to fit."
- "If you found out this would take six months, would you still start it today?"

**Exit criteria**: explicit appetite in the form `[Small/Medium/Large] — [timeframe] with [team size]`. E.g. `Medium — 3 weeks with 1 developer`.

## Step 3 — Solution sketching

**Goal**: propose 2–3 rough solution approaches at fat-marker-sketch fidelity. Explicitly rough. Trade-offs explicit. The user picks a direction (or says "none of these" and you iterate).

Shape Up's rough/solved/bounded framing: solutions should be **rough** (obviously unfinished), **solved** (main elements connected), and **bounded** (clear about what's excluded).

**Phrasing**: start with *"Given the problem and the [appetite] appetite, here are 2–3 rough directions. These are fat-marker sketches, not specs — tell me which direction feels right and we'll refine."*

For each sketch, cover:
- The core approach in 2–3 sentences
- What's in scope, what's out
- The main trade-off vs. the other sketches
- Roughly where the risk lives

**Do not** commit to technology, framework, database, or hosting. If a sketch requires naming a tool to make sense, name it as *"something like X"* and note it as a constraint for blueprint.

**Exit criteria**: the user picks one direction (possibly with edits) and agrees it fits the appetite.

## Step 4 — Risks and rabbit holes

**Goal**: surface known unknowns and things that could blow up the timeline *before* committing to the direction. Shape Up chapter 5: *"Emphasize that you're looking for risks that could blow up the project."*

**Core questions**:
- What part of this are you least sure how to build?
- Are there third-party dependencies — APIs, data sources, integrations — that could fail or change?
- Any skill gaps on the team/yourself that matter here?
- What's the most likely reason this project gets abandoned mid-way?
- Is there anything about the domain (regulatory, legal, data privacy) that could derail this?

**Rabbit hole detection**: if the user says *"we could handle X with Y"* and Y is vague, that's a rabbit hole candidate. Name it: *"Y feels like it could go deep — want to mark it as a rabbit hole and either spike it early or cut it?"*

**No-gos**: before closing the step, explicitly ask: *"What is this project deliberately **not** doing? Give me at least one no-go."* If the user can't name one, the scope is too ambiguous — probe harder. No-gos are the most underrated section of the brief.

**Exit criteria**: rabbit holes named, at least one explicit no-go captured, top risks listed.

## Between-step reflection

After each step, reflect back what you heard in 1–2 sentences before starting the next. Format:

> "So: [one-sentence summary of what the user said]. Moving on to [next step name] — [transition question]."

This catches misunderstandings cheaply and gives the user a natural correction point. Do not skip reflections even at `rigor=light` — they're the main HITL mechanism during the interview itself.

## Rigor-dial cheat sheet

| Step | `light` | `standard` *(default)* | `full` |
|---|---|---|---|
| 1 Problem | 1 question, accept whatever | 3–5 batched questions, reflect | One-at-a-time, dig on every answer |
| 2 Appetite | 1 question, accept | 2–3 batched, push on vagueness | One-at-a-time, force explicit number |
| 3 Sketching | Skill drafts 1–2 sketches from context | 2–3 sketches, user picks | 3 sketches, user walks through trade-offs |
| 4 Risks | 1 "what could blow up" + no-go ask | 3–5 batched risk questions + no-go | One-at-a-time, adversarial probing |

At `light`, the whole interview can be a single batched message. At `full`, expect 15+ turns. `standard` typically lands around 6–10 turns total.
