# CONTRIBUTING.md template

The new-contributor walkthrough. Lives at the repo root because GitHub natively recognizes it and surfaces it in the PR/issue creation flow. Read once per contributor (and by the author themselves as a memory aid). New to the cascade — the existing initiative-planner skill folded contributing content into STANDARDS.md, but blueprint splits them because scaffold's discovery captured both quality-bar and onboarding-flow information separately and they serve different audiences.

## Audience and tone

**For solo projects**: the audience is the author's future self plus any external contributor who might appear later. Tone is informal but specific — "here's how I work in this repo" rather than "here's how the team works." Length is short (1–2 pages).

**For team projects**: the audience is every new team member. Tone is welcoming and concrete. Length is longer (2–4 pages) because new members need more context. Include explicit pointers to people, channels, and decision-makers when relevant.

**For public/open-source projects**: the audience is anyone landing on the repo from the internet. Tone is welcoming, friction-low, with explicit "here's how to ask for help" guidance. Length is whatever it takes to get a stranger to a working PR.

Determine which audience you're writing for from `scaffold.md`'s team shape and the problem brief's target users. Default to "solo / future self" unless the brief explicitly indicates external contributors are in scope.

## What to inherit before drafting

CONTRIBUTING.md is mostly a verbatim publication of scaffold's working conventions, plus a methodology-shaped walkthrough of how to make a change. Inheritance is heavier than for any other foundation doc:

| From | What to extract | Where it goes in CONTRIBUTING.md |
|---|---|---|
| `scaffold.md` working conventions | Branch naming format with examples — verbatim | "Branch naming" section |
| `scaffold.md` working conventions | Commit message format with scopes — verbatim | "Commits" section |
| `scaffold.md` working conventions | Label taxonomy with meanings — verbatim | "Labels" section |
| `scaffold.md` working conventions | Team identifier | Used throughout in branch examples |
| `scaffold.md` PR/review process | The whole entry — verbatim | "How a change gets reviewed" section |
| `scaffold.md` team shape | Who reviews, who merges, decision-maker | "How a change gets reviewed" section, who-to-ask sidebar |
| `problem_brief.md` target users | Solo vs external — informs tone | Whole doc |
| Methodology (this phase) | Workflow rhythm | "How to make a change" walkthrough — Shape Up reads differently than Kanban reads differently than Scrum |
| Stack decisions (this phase) | Setup commands, language version | "Get the project running" section |

**The verbatim rule is strictest here.** If scaffold.md's branch naming format is `tui-<issue-number>-<short-description>` with examples `tui-12-verifier-trait` and `tui-34-regex-lesson-anchors`, CONTRIBUTING.md uses those exact examples. Do not invent new examples, do not "improve" the format, do not convert the wording from "issue-number" to "ticket-number." Scaffold ran the discovery conversation; blueprint just publishes the result for human readers.

## The template

```markdown
# Contributing to [Project Name]

[One-paragraph welcome. For solo: "This is a personal project — these notes
are mostly for my future self, but if you're an external contributor, the
basics below apply." For team: "Welcome! Here's how we work in this repo."
For public: "Thanks for considering a contribution. This guide will get you
from a fresh clone to a merged PR."]

## Get the project running

\```bash
[exact commands from stack decisions: clone → install → verify]
\```

If something doesn't work, [where to ask — issue, discussion, contact info if public; nothing if solo].

## How to make a change

[Methodology-shaped walkthrough. Examples:

For Shape Up appetite-based:
1. Pick a pack/feature with a defined appetite from `docs/cbk/blueprint.md` or open issues
2. Create a branch following the format below
3. Work within the appetite — if scope grows, cut something rather than extending
4. Open a PR when the appetite is hit, even if not "complete"
5. Review per the process below

For Kanban:
1. Pull the next item from the WIP-limited queue
2. Create a branch following the format below
3. Work to completion before pulling another item
4. Open a PR when done
5. Review per the process below

For Scrum:
1. Pick an issue from the current sprint
2. Create a branch following the format below
3. Work within the sprint
4. Open a PR for review before the sprint ends

For "no formal methodology, just discipline":
1. Pick something to work on
2. Create a branch
3. Open a PR when ready
4. Review per the process below
]

## Branches

[Verbatim from scaffold.md.]

**Format**: `<format string>`

Examples:
- `<example 1 from scaffold.md>`
- `<example 2 from scaffold.md>`

[Any additional notes about branch lifetimes, when to delete, etc.]

## Commits

[Verbatim from scaffold.md.]

**Style**: <Conventional Commits | project-specific>

[If Conventional Commits, list the scopes from scaffold.md verbatim.]

Examples:
- `feat(engine): add verifier trait skeleton`
- `fix(packs): handle missing lesson metadata`

## Labels

[Verbatim from scaffold.md label taxonomy.]

**Type labels** (every issue gets one):
- `bug` — [from scaffold.md]
- `feature` — [from scaffold.md]
- [etc., verbatim]

**Area labels** (zero or more):
- [verbatim from scaffold.md]

## How a change gets reviewed

[Verbatim from scaffold.md PR/review process. Solo example:

> Solo-merge with self-review. CI must trigger Claude code review on PRs
> (claude-code-action) so every PR gets a second set of eyes even though
> there's no human reviewer. Self-merge after addressing Claude's review.

For teams, list reviewers, expected turnaround, decision-maker for disagreements.]

## Where things live

[Quick orientation map for the repo. Examples:

- `src/` — source code
- `tests/` — test code
- `docs/cbk/` — cascade planning artifacts (problem brief, scaffold output, blueprint)
- `docs/ARCHITECTURE.md` — system design and decisions log
- `docs/STANDARDS.md` — quality gates and PR checklist
- `CLAUDE.md` — Claude Code session primer
- This file — contributor walkthrough]

## Asking questions

[For solo: skip or just say "open an issue."
For team: name channels, on-call rotation, async vs sync expectations.
For public: link to discussions, issue templates, contact info.]
```

## What does NOT belong here

- **Stack decision rationale** — that's ARCHITECTURE.md Decisions Log
- **Quality bar specifics and PR review checklist** — that's STANDARDS.md
- **Cascade-internal metadata** — that's `docs/cbk/blueprint.md`
- **Project marketing or positioning** — that's README.md
- **Architecture diagrams or system descriptions** — that's ARCHITECTURE.md
- **Code style rules** — that's STANDARDS.md (and ideally, the linter)

CONTRIBUTING.md is a **walkthrough**, not a specification. If a contributor finishes reading it and knows what to do next without flipping to other docs, the walkthrough succeeded.

## Solo-specific notes

For solo projects, CONTRIBUTING.md is mostly a memory aid for the author. Three specific behaviors blueprint should adopt for solo:

1. **Default to deferring CONTRIBUTING.md when the project is private + solo + pre-v1.0.** This is the canonical case where producing the doc at blueprint time is premature: the author is the only contributor, the repo isn't public so external contributors can't even see it, and the conventions captured in scaffold.md are still in flux as the project finds its shape. Generating a CONTRIBUTING.md now means it stales for months until v1.0 — and a stale contributing doc is worse than none at all because it sets wrong expectations for the first external contributor when they finally arrive.

   Instead, blueprint should ask: *"This project is private, solo, and pre-v1.0. The standard recommendation is to defer CONTRIBUTING.md until you're prepping for the v1.0 public release — at that point the conventions will be settled and the doc reflects how things actually work, not how you thought they'd work at blueprint time. Skip CONTRIBUTING.md for now? (You can always run blueprint's CONTRIBUTING template later as a one-off.)"*

   Record the deferral as a trip-wire in `docs/cbk/blueprint.md`: *"CONTRIBUTING.md deferred until v1.0 release prep."* The trip-wire ensures the doc gets revisited at the right moment instead of silently forgotten.

2. **Skip the doc entirely if the user asks**, regardless of v1.0 status. Solo authors who don't expect external contributors and don't want a memory aid should not be forced to have a CONTRIBUTING.md. Ask once: *"For solo projects, CONTRIBUTING.md is optional — it's mostly a memory aid for your future self. Want me to produce it, or skip it?"*

3. **If produced, keep it short.** 1–2 pages max. The whole doc can be 5 short sections plus the boilerplate setup commands.

## HITL presentation

When presenting CONTRIBUTING.md for review, lead with: *"Here's the draft CONTRIBUTING.md. The branch/commit/label sections are pulled verbatim from scaffold.md — check that I copied them faithfully. The 'how to make a change' walkthrough is shaped by the [methodology] choice — let me know if it doesn't match how you actually want work to flow."*

Common revision requests:
- "The walkthrough doesn't mention X step" → add to the workflow walkthrough
- "I don't want a 'Asking questions' section" (solo) → drop it
- "The branch examples should use real recent issues" → update the examples
- "Add a 'first contribution' easier path" (public) → add a section

Iterate until approved. Then commit via GitHub MCP to repo root as `CONTRIBUTING.md`.

## Light-mode behavior

If the user invoked light mode:

- **Skip the doc entirely** for solo projects unless the user explicitly asks for it
- **For team projects**, produce a 1-page version with: Get running, Branches, Commits, How review works
- **Skip the methodology walkthrough** in light mode — assume the contributor will figure it out from issues and PR process
- **Skip the labels section** if the project's label taxonomy is the cascade default

What light mode *cannot* skip: the verbatim inheritance of branch naming, commit format, and labels from scaffold.md. Even a 1-page CONTRIBUTING.md must publish those faithfully.
