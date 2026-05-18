---
name: consultation
description: Turn a raw idea into a bounded problem brief before any workspace, repo, or planning artifact exists. Use this skill whenever the user has an idea they want to build, even vaguely phrased — "I want to make X", "I've been thinking about building Y", "I have this idea but don't know where to start", "where do I begin with X", "is this even worth doing", "help me think through Z". Also use when the user asks to "shape", "scope", or "frame" a project, mentions the planning cascade, or describes a problem they want to solve without yet naming a solution. **Use this skill even when the user doesn't explicitly ask for "consultation" or "a problem brief" — most users at the consultation moment don't know the cascade exists, so the trigger is the shape of the conversation, not the vocabulary.** Phase 1 of the six-phase AI-assisted development cascade. HITL-heavy and produces no code, no repo, no tickets — only a structured problem brief.
---

# Consultation

Phase 1 of the six-phase AI-assisted development cascade. Transforms a raw idea into a bounded **problem brief** with explicit appetite, proposed approach, rabbit holes, and no-gos. Produces exactly one artifact: the brief. No Linear issues, no GitHub repos, no code — those come later. (If the operator brings existing Notion context as input to the cascade, see § Incoming context below — the brief can be informed by that material but stays the canonical output regardless.)

This skill is deliberately conversational and HITL-heavy. The human is the source of truth about what problem is worth solving; Claude's job is to interview well, reflect back honestly, and refuse to solutionize prematurely.

## Incoming context — Notion or other pre-cascade material (optional, runs first if applicable)

Before the four-step interview, check whether the operator is arriving with existing context worth ingesting as starting material — typically Notion pages they've curated, prior design docs, research from another tool. This is especially common for operators who picked the cascade to organize *existing* thinking, not to start from scratch.

**Opening question** (skip if the user's first message already provided rich context):

> *"Any existing context I should ingest as starting material? If you've connected a Notion MCP, I can: (a) search a subtree under a root page you designate, (b) search your whole workspace, or (c) fetch specific pages you list. Without MCP, paste content directly. Or skip if nothing existing applies."*

The four access modes (richest first) live in `references/notion_ingestion.md` along with the per-mode HITL discipline. Short version:

| Mode | Operator setup | What consultation does |
|---|---|---|
| **A — Designated root + MCP search** | "Use `<page URL>` as root." | Search within subtree on demand; walk to summarize |
| **B — Workspace + MCP search** | "Use my whole workspace." | Broader scope; selectively fetch with announcements |
| **C — Specific URLs + MCP fetch** | Operator pastes URLs | Fetch listed URLs only; no broader search |
| **D — Paste content directly** | No MCP configured | Standard inheritance from pasted content |

Every fetch and every search **announces before executing** per `.claude/rules/knowledge-backend.md` § "HITL announcement discipline." Operator can decline per-page or refine the query.

**Scope designation rolls forward to scaffold.** Whatever the operator designates here (root URL in Mode A, workspace in Mode B, specific URLs in Mode C) is recorded in the brief's `## Pre-cascade sources` section. Scaffold's backend selection reuses it rather than re-asking when knowledge backend = `notion`.

**What this DOES NOT change about consultation**:
- The four-step interview still runs (informed by ingested content, not replaced by it)
- The brief is still canonical, still committed to repo at scaffold time
- The brief is repo-bound; consultation's optional companion-page write to Notion (see closing HITL gate) is opt-in and defaults to SKIP

If MCP isn't connected, surface honestly and fall through to Mode D (paste). If the operator skips the incoming-context question entirely, proceed straight to the four-step interview as before.

## The two dials

Before running the interview, set two independent dials. Detect sensible defaults from the user's opening message, state your read out loud in one sentence, and let the user override in one word.

**Rigor dial** — how heavy the interview is:
- `light` — one batched question round, Claude drafts aggressively from whatever the user provides, user edits
- `standard` *(default)* — batched questions across all four steps, Claude reflects and extracts, user approves each step
- `full` — one question at a time, all four steps run in full, Claude refuses to skip ahead

**Prior-context dial** — how much the user already has:
- `greenfield` *(default for new ideas)* — no existing code, stack, or artifacts; full problem discovery
- `partial` — some decisions made (stack preference, rough sketch, prior attempt) but no committed system
- `brownfield` — significant existing codebase, system, or prior implementation; runs the brownfield addendum

These compose independently. `rigor=light, prior=brownfield` means "extract quickly from someone who already has a lot" — `rigor=full, prior=greenfield` means "full Shape Up-style shaping from a vague idea".

**Detect-then-confirm format:**
> "Sounds like you've got an existing implementation and clear stack choices — I'll run in **brownfield** mode at **standard** rigor. Say 'lighter', 'go full', or 'actually this is greenfield' to adjust, otherwise I'll start the interview."

If the opening message is one sentence with no context, default to `greenfield / standard` and confirm. If it mentions existing code, prior work, or a stack, lean `brownfield`. If it's a research-y "build something like X" reference, lean `partial`.

## The four-step interview

Full playbook with source prompts (Harper Reed, Claude Code, Shape Up) in `references/steps.md`. Read that file before starting the interview — it has the actual question banks and the one-at-a-time vs. batched phrasings.

The four steps, in strict order:

1. **Problem discovery** — who has what pain, how they handle it today, what makes the status quo unacceptable. Resist solutioning. If the user jumps to "I want to build an app that does X", redirect: *"Before the solution — help me understand the problem."*
2. **Appetite setting** — time, effort, and (for teams) headcount budget. Frame as a constraint, not an estimate: *"Is this a weekend hack, a two-week sprint, or a multi-month project?"* Appetite shapes the solution, not the other way around.
3. **Solution sketching** — only after problem and appetite are agreed, propose 2–3 rough approaches at different fidelities. Fat-marker-sketch level. Explicitly rough. Trade-offs explicit.
4. **Risks and rabbit holes** — probe for known unknowns, technical risks, third-party dependencies, skill gaps. Ask *"what could blow this up?"* directly.

At `standard` rigor, each step is one batched message with 3–5 related questions. At `full`, one question at a time, waiting for each answer. At `light`, one single batched message covering all four steps, then draft the brief from the response.

Between steps, reflect back what you heard in 1–2 sentences before asking the next batch. This catches misunderstandings early and gives the user a cheap correction point.

## Brownfield variant

If `prior=brownfield` or `prior=partial`, load `references/brownfield_addendum.md` before step 1. It adds a **current state assessment** step that runs first: what exists, what works, what's broken, what constraints the existing system imposes. The problem brief gets an extra `## Current state` section.

Do not run a codebase analysis in consultation — that belongs in blueprint. Note whether one is needed and flag it for the handoff.

## Methodology register

`references/methodology_register_excerpt.md` contains the consultation-relevant entries from the full methodology register: Shape Up (appetite, shaping, no-gos, pitch format), spike solutions, YAGNI, and pointers to the full register for later phases. Cite entries by name when recommending a pattern, surface the "fails when" conditions when they apply, and never enforce — the user always decides.

The full register lives outside this skill and is shared across all six cascade phases. If the user asks about patterns not in the excerpt, say so and offer to search.

## The problem brief — output contract

Exactly one artifact: a markdown problem brief. Template and worked example in `references/problem_brief_template.md`. Sections, in order:

1. **Problem statement** — one paragraph, one specific story about why the status quo fails
2. **Target users** — who this is for, specific enough to make design decisions
3. **Appetite** — explicit time/effort/headcount budget, e.g. *"Medium — 3 weeks, 1 developer"*
4. **Proposed approach** — 2–5 paragraphs at fat-marker-sketch fidelity; rough, not a spec
5. **Rabbit holes and risks** — known unknowns and things that could blow up the timeline
6. **No-gos** — explicit scope exclusions; at least one, required
7. **Success criteria** — 3–5 measurable outcomes that define "done" at the project level
8. **(Brownfield only) Current state** — what exists, what works, what constrains

### Example excerpt (what one section looks like in practice)

To make the output shape concrete: here's what the **No-gos** section looks like for a real consultation about a CLI tutorial tool. Note the specificity — each no-go names a thing, not a category, and each one explains *why* it's excluded so the next phase knows whether the no-go is a hard constraint or a soft preference.

**Input fragment** (user message during interview):
> "I don't want to teach SQL — that's a different pedagogy. And no web UI, this is terminal-native by definition. Probably no git lessons in v1, those are hard."

**Output fragment** (resulting brief excerpt):
```markdown
## No-gos

- **No SQL pack.** Different pedagogy (results-oriented). Deserves its own tool.
- **No web UI, no SaaS, no paywall.** Terminal-native by definition; can't train TUI proficiency from a browser.
- **No git lessons in v1.** Lessons are hard and the engine must mature first. Revisit at v0.8.
- **No deep conceptual teaching.** Brief framing in service of a drill is allowed; multi-paragraph "what is X" prose belongs in `see_also` links.
```

The full template with worked example for every section lives in `references/problem_brief_template.md`. Load it when drafting; the example above just shows what one section feels like.

### Delivery mechanism

Produce the brief as a **downloadable markdown artifact** the user can save or hand off. Pick the right mechanism for the surface you're running on:

- **If you have file creation + `present_files`** (claude.ai, desktop, most common case): create the file at a clear path (e.g. `problem_brief_<short-slug>.md`), then present it so the user can download.
- **If the user has filesystem MCP connected and has indicated a preferred location**: write there instead.
- **If neither is available**: emit the full brief as inline markdown in the chat and tell the user they can copy it.

In all cases, **also surface key points inline** — at minimum the problem statement, appetite, and no-gos — so the user can review and iterate without opening the file. Offer to revise the brief based on their inline feedback before treating it as final.

## The HITL gate

Before the skill considers itself done, explicitly ask for approval: *"Does this brief accurately capture the problem, appetite, and no-gos? Anything to revise before I mark consultation complete?"* Iterate until the user approves. Do not auto-close.

**If Notion content was ingested at § Incoming context**, the closing gate also asks the opt-in companion-page question:

> *"You brought in Notion context at the start. Want me to promote a companion page in Notion that links to the (about-to-be-committed) repo brief and includes longer-form research from the pages I read? Useful if Notion is your durable knowledge reference. Defaults to SKIP — your existing Notion structure stays untouched unless you opt in."*

Defaults to **SKIP**. If the operator opts in, surface the planned write per `.claude/rules/knowledge-backend.md` § "HITL announcement discipline" (announce title, parent, body preview before committing). Otherwise, proceed to the standard handoff.

Once approved, state clearly:
> "Consultation complete. The brief is ready for phase 2 (scaffold), which will provision the workspace — repo, planning tool, optional knowledge backend — based on what this brief says. You can hand the brief to the scaffold skill, or use it standalone."

**Required to be present at the gate**: problem statement, target users, appetite, proposed approach, at least one no-go, 2+ success criteria. Plus current-state section if brownfield.

**Must not be present at the gate**: technology stack decisions (those belong in blueprint), detailed feature lists (framing), task breakdowns (finish), any tool-specific artifacts. If you find yourself writing "we'll use Postgres" in the brief, move it to a note for blueprint instead.

## Failure modes to defend against

From `sdd.md` and Shape Up chapters 2–5. Watch for these actively during the interview and name them out loud when they happen.

- **Solutioning too early** — user jumps to "I want to build an app that does X". Redirect to problem space. Most common failure.
- **Unbounded appetite** — "I want to build everything". Force a choice. Shape Up: *"If we don't make trade-offs up front, the universe will force us to make them later in a mad rush."*
- **Missing no-gos** — every brief must have at least one explicit no-go. If the user can't name one, the scope is too ambiguous; keep probing.
- **Premature tool selection** — consultation does not pick frameworks, databases, or hosting. Note stack preferences as *constraints*, not decisions, and defer to blueprint.
- **Fake appetite** — user says "quick weekend thing" then describes a six-month project. Reflect the mismatch: *"That sounds bigger than a weekend — want to cut scope or grow the appetite?"*

## Solo vs. team notes

**Solo**: appetite simplifies to personal time; no stakeholder alignment; brief can be ~1 page. Skip team-coordination questions.

**Team (2–10)**: appetite includes headcount and role mix; brief is an alignment document the rest of the team will read; probe for opportunity cost (*"what are we not building while we build this?"*); appetite requires explicit discussion.

Ask which mode early if not obvious from the opening message.

## Handoff contract to scaffold

The scaffold phase consumes the approved brief and extracts: project name (for naming conventions), team size (for permission scoping), appetite (for cycle length estimates). It does *not* consume stack decisions — those don't exist yet. Make sure the brief is readable standalone and doesn't assume scaffold context.

**Do not run consultation if a brief already exists.** If the user arrives with a written problem brief and wants to move straight to scaffold, blueprint, or later phases, acknowledge the existing brief and hand off rather than re-running the interview. Re-running it would re-derive content the user already has and is the most common form of cascade-skill double-work.

## Reference files

- `references/steps.md` — the four-step interview playbook with source prompts from Harper Reed, Claude Code, and Shape Up; rigor-dial phrasings
- `references/problem_brief_template.md` — structured template with per-section prose guidance, including the optional `## Pre-cascade sources` section populated when Notion content was ingested
- `references/methodology_register_excerpt.md` — Shape Up, spikes, YAGNI entries plus pointers to the full register
- `references/brownfield_addendum.md` — current-state-assessment step and brownfield-specific brief additions
- `references/notion_ingestion.md` — operational reference for the Notion-as-input flow at § Incoming context: four access modes, MCP fetch dialogue, per-search HITL announcements, what to record in `## Pre-cascade sources`
- `references/test_cases.md` — three realistic test prompts (greenfield / brownfield / partial-context) with success criteria for verifying the skill still works after revisions

Kit-wide operational contracts (`.claude/rules/`):
- `knowledge-backend.md` — read patterns, write tiering, HITL discipline. Loaded when consultation actually consults Notion (Modes A/B/C) or considers the optional companion-page write at the closing HITL gate.

Read a reference when you need it; don't front-load them all.
