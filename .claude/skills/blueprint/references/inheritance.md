# Inheritance from prior phases

The first thing blueprint does in any session. Reads `docs/cbk/problem_brief.md` and `docs/cbk/scaffold.md` in full, extracts what it needs, states the inheritance summary explicitly to the user, and gets approval before proceeding. This is the foundation for everything blueprint produces — getting it wrong propagates errors through six prose docs and the initiative spec.

## How to find the input files

Three sources, in priority order:

1. **GitHub MCP**: if the repo is connected and you know the repo URL, fetch both files via the MCP file-read tool. This is the preferred path because it guarantees you're reading the canonical version.
2. **Uploaded files in chat**: if the user has uploaded `problem_brief.md` and `scaffold.md` directly, read them from the upload context.
3. **Inline paste**: if the user pastes the content into chat, work from the pasted text but ask explicitly *"is this the full content?"* — pastes are more likely to be partial than uploads.

If both files cannot be found via any of these paths, **stop and ask**. Do not proceed without them. Acceptable responses: "let me upload them," "the repo is at <URL>," "I never ran consultation/scaffold — let's do it informally now." Unacceptable: guessing what the files might contain.

## What to extract from `problem_brief.md`

Read the full file. The brief has a known structure (problem statement, target users, appetite, proposed approach, rabbit holes, no-gos, success criteria, optional current state). Extract these specific things into your working memory:

| Brief section | What blueprint uses it for |
|---|---|
| Problem statement | README context section, CLAUDE.md "what is this" intro, ARCHITECTURE.md problem framing |
| Target users | README audience section, CONTRIBUTING.md tone (is this for the author only, or for outside contributors?) |
| Appetite | Methodology selection (Small/Medium → Shape Up appetite-based; ongoing → Kanban; etc.), CI strictness |
| Proposed approach | ARCHITECTURE.md sketch — *the shape* of the system, not a spec |
| Rabbit holes / risks | Open questions in `blueprint.md`, ADR triggers in STANDARDS.md if relevant |
| No-gos | **Carry forward verbatim into blueprint.md no-gos section** — these are user-set constraints blueprint must not relax |
| Success criteria | Carry forward into blueprint.md success criteria, possibly refined or expanded |
| Stack constraints flagged for blueprint | Pre-decided stack pieces — confirm them, do not re-debate them |
| Notes for blueprint section | The user's deferred decisions list — blueprint must address each one |
| Current state (brownfield only) | ARCHITECTURE.md must respect existing code, CLAUDE.md must reference existing patterns |

**The "Notes for blueprint" section is the highest-leverage extract.** Consultation deferred specific decisions to blueprint with named items (e.g., "progress store format, lesson discovery mechanism, SRS schedule schema"). Blueprint must address each one explicitly during stack decisions, even if the answer is "defer further to first real run." Silent omission of a deferred decision is a blueprint bug.

## What to extract from `scaffold.md`

Read the full file. Scaffold's output has five sections (cascade metadata, team shape, working conventions, development preferences, tool landscape). Extract:

| Scaffold section | What blueprint uses it for |
|---|---|
| **Planning backend** | Determines whether blueprint creates a Linear initiative + Linear Projects, or GitHub workstream parent Issues, or commits only to markdown. **Critical** — gets the wrong planning backend and the whole production flow misroutes. See `planning-backend-matrix.md`. |
| **Knowledge backend** | Determines whether blueprint may optionally read from Notion at inheritance and may optionally promote cross-project strategy companion pages to Notion. Default behavior: rely on repo + inheritance. Per `.claude/rules/knowledge-backend.md`. |
| **Hierarchy levels** | Sanity check — should match planning backend (3 for `github-issues`, 4 for `linear`) |
| **In-repo cascade artifacts surface** | Where to commit `blueprint.md` and other cascade artifacts (always `docs/cbk/`) |
| **Team shape** | CONTRIBUTING.md tone, STANDARDS.md PR review process, methodology selection (solo vs team changes the appropriate methodology) |
| **Working conventions** (branch naming, commit format, label taxonomy, team identifier) | **Carry into CONTRIBUTING.md verbatim**. Do not re-derive. The whole point of scaffold capturing these was so blueprint doesn't have to invent them. |
| **Quality bar** | The single highest-leverage piece. Drives STANDARDS.md testing rigor, CI strictness in tooling configs, code review norms, methodology selection. *Read this section twice.* |
| **PR/review process** | STANDARDS.md PR review section, CONTRIBUTING.md "how to make a change" |
| **Testing philosophy** | STANDARDS.md testing section, CLAUDE.md test commands, CI workflow scope |
| **Pace** | Methodology selection, expected milestone cadence in blueprint.md workstreams |
| **Decision recording** | Whether to set up ADRs in `docs/decisions/` (if scaffold.md said "ADRs from day one") or skip them (if scaffold.md said "issue comments and PR descriptions for now") |
| **Tool landscape** | CLAUDE.md commands section, CI workflow choices, `.env.example` content |
| **Tool comfort** | How much explanation to put in CLAUDE.md — first-timers need more, veterans need less |

**Carrying conventions verbatim is non-negotiable.** If scaffold.md says branch naming is `tui-<issue-number>-<short-description>`, CONTRIBUTING.md says branch naming is `tui-<issue-number>-<short-description>` with the exact same examples. No paraphrasing, no "improving" the format. Scaffold already ran the conversation; blueprint just publishes the result in developer-facing form.

## Edge cases

**Brief and scaffold disagree.** If the brief says the appetite is "Large — 6 weeks" and scaffold's discovery captured "bursty, evenings only, no deadline pressure," surface the tension to the user: *"The brief said large/6 weeks but the scaffold output says bursty no-deadline. Which framing should I use for methodology selection — fixed-window or open-ended?"* Do not silently pick one.

**Brief is missing entirely.** Run consultation first, or ask the user to paste a one-paragraph problem statement and treat it as an informal brief. Note in the inheritance summary that the brief is informal.

**Scaffold is missing entirely.** Same pattern — either run scaffold first or ask the user to provide profile, team shape, and working conventions verbally and treat them as informal. Note that the scaffold context is informal.

**Brownfield project with no consultation/scaffold history.** The user has an existing repo and wants blueprint to make stack/methodology decisions for new work in it. Treat the existing repo as the implicit scaffold (profile is whatever the existing repo uses, conventions are whatever the existing branches/labels/commits show), and ask the user for the problem brief verbally. State explicitly that this is brownfield-mode blueprint and the inheritance is being inferred from the existing repo.

**Conflicting "for blueprint" notes.** The brief might list "progress store format" as a deferred decision while the user has since decided informally in chat ("I'm going with SQLite"). Ask: *"The brief flagged progress store format as a blueprint decision, but I think you mentioned SQLite in our scaffold conversation. Should I treat that as decided, or do you want to reopen it?"*

**The user wants to skip inheritance.** Don't. This is the one light-mode override floor. Even at light rigor, blueprint must read both files. If the user pushes back, explain once: *"Skipping inheritance is the most common way blueprint produces docs that contradict the brief or duplicate what scaffold already decided. It takes me 30 seconds to read both files — please let me do it."* If they still refuse, note the override in `blueprint.md` and proceed, but expect rework.

## Optional knowledge-backend fetch (when knowledge backend = `notion`)

If `scaffold.md` records knowledge backend = `notion`, blueprint may **optionally** consult the project's Notion hub for richer context than the brief carries. The brief's `## Pre-cascade sources` section lists what was already consulted at consultation — blueprint surfaces those sources to the operator and asks if any should be re-read for blueprint context:

> *"The brief cites these Notion sources: `<list with titles>`. Want me to re-read any of them for blueprint context (e.g., stack-decision background, cross-project constraints), or proceed with the brief as inherited?"*

Defaults to **proceed without fetching**. Operator opts in to specific re-reads. Every fetch announces per `.claude/rules/knowledge-backend.md` § "HITL announcement discipline."

If the brief has no `## Pre-cascade sources` section (consultation didn't ingest Notion), blueprint can still offer an ad-hoc read: *"Knowledge backend = Notion is configured but the brief doesn't cite any Notion sources. Want to designate Notion content for blueprint context, or proceed with the brief as inherited?"* — again, defaults to proceed.

This step is **always opt-in**; blueprint never auto-fetches from Notion. If knowledge backend = `none`, skip this step entirely.

## The inheritance summary (HITL gate 1)

After reading both files (and optionally re-reading any Notion content the operator confirmed), present a summary in this exact shape:

```
## Inheritance summary

**From the problem brief:**
- Problem: <one-sentence summary>
- Target user: <one-sentence summary>
- Appetite: <verbatim from brief>
- Approach shape: <one-sentence summary>
- No-gos (carrying forward): <bulleted list, verbatim from brief>
- Success criteria (carrying forward): <bulleted list, possibly summarized>
- Deferred decisions for blueprint: <bulleted list from "notes for blueprint">
- Pre-cascade sources (if any): <bulleted list from brief's § Pre-cascade sources>

**From the scaffold output:**
- Planning backend: <github-issues | linear | in-repo-markdown>
- Knowledge backend: <notion | none> (if notion: hub URL)
- Team shape: <one-sentence summary>
- Quality bar: <verbatim from scaffold.md — do not paraphrase>
- Working conventions: <one-line summary, full details preserved for CONTRIBUTING.md>
- Testing philosophy: <verbatim from scaffold.md>
- Decision recording: <verbatim from scaffold.md>
- Tool comfort: <verbatim from scaffold.md>

**Knowledge backend reads (if any):**
- <page title> — <URL>. <1-2 line summary of what was extracted, quoted where the wording matters>

**My read of the scope:** <one paragraph stating what blueprint will produce — which foundation docs, which stack categories need decisions, which methodology you'll propose, planning-axis behavior, whether any Notion companion writes are likely. This is the "are we on the same page?" check.>

Anything to correct before I proceed?
```

The user reads this and either approves or corrects. Iterate until they approve. Only then proceed to the stack decisions step.

**Why this gate is strict.** Every other gate in blueprint can be collapsed in light mode. This one cannot, because it's not asking the user to make a decision — it's verifying that blueprint understood the inputs correctly. A blueprint that misunderstood the inputs will produce six wrong docs. Thirty seconds of inheritance summary prevents an hour of rework.

## Light-mode behavior

Even in light mode, blueprint must:

- Read both files in full (not skim, not sample)
- Extract the load-bearing items (profile, no-gos, deferred decisions, quality bar, working conventions, success criteria)
- Present an abbreviated inheritance summary (the bullet lists above can collapse to one paragraph each, but the summary must exist)
- Get explicit approval before proceeding

What light mode *can* skip in inheritance: the per-section detail (just hit the load-bearing items), the deferred-decision walkthrough (mention them and proceed; user can flag if any need attention), the brownfield edge-case handling (assume greenfield unless told otherwise).

What light mode *cannot* skip in inheritance: reading the files, presenting any summary at all, getting user approval. This is the safety floor.
