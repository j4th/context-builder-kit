# Notion ingestion

Operational reference for consultation's "incoming context" flow when the operator arrives with existing material to ingest. Runs **before** the four-step interview. The cross-cutting operational contract (read patterns, HITL discipline, inheritance discipline) lives at `.claude/rules/knowledge-backend.md` — this file covers the consultation-specific behavior on top of that contract.

## When to run this

Trigger when **any** of these is true:
- The operator's opening message references Notion content, pasted URLs, or existing research they want to base the brief on
- The operator says they have "a lot of context" / "prior work" / "research from another project"
- The operator explicitly asks to ingest pages, files, or URLs as starting material
- Consultation's opening question ("Any existing context I should ingest as starting material?") returns yes

If none of these is true, skip this file entirely and proceed to the four-step interview.

## The four access modes

Richest first. Pick based on what the operator has set up and how much scope they want consultation to range over.

### Mode A — Designated root + MCP search (richest)

**Operator setup**: Notion MCP is configured. Operator pastes one root page URL and says "use this as the root."

**What consultation does**:
1. Confirm the Notion MCP is connected. If not, fall through to Mode D.
2. Read the root page itself (single page fetch, announced per HITL discipline).
3. Walk the root page's subtree (one level deep at a time) and **summarize what's available** — child page titles, sizes, last-edited dates — without fetching their full bodies.
4. Present the inventory to the operator: "Found these pages under `<root>`: `<list>`. Want me to fetch all of them, a specific subset, or search within the subtree for relevant content?"
5. Per operator's response, fetch the confirmed pages and incorporate as inheritance for the four-step interview.

**Recording**: the brief's `## Pre-cascade sources` section records:
```
- **Notion scope**: <root URL> (Mode A, designated subtree)
- **<page title>** — <URL>. <1-2 line summary>
- ... (one bullet per actually-fetched page)
```

### Mode B — Workspace + MCP search

**Operator setup**: Notion MCP is configured. Operator says "use my whole Notion workspace as scope."

**What consultation does**:
Same as Mode A but with workspace-wide scope. Higher risk of pulling irrelevant content; consultation has to be **more selective**:
- Don't fetch indiscriminately. Use the operator's brief / opening message to drive specific searches: "Searching workspace for `<key term from opening message>`. OK?"
- Limit initial result sets to ~10 hits per search.
- Surface every search query before running ("About to search workspace for `<query>`. Refine, accept, or decline?").

**Recording**: same as Mode A. Mark the scope as `Mode B, whole workspace`.

### Mode C — Specific URLs + MCP fetch (no search)

**Operator setup**: Notion MCP is configured. Operator pastes a list of URLs (typically 1-5 pages).

**What consultation does**:
1. Confirm the list: "Fetching these N pages: `<list>`. OK?"
2. Fetch each URL (single-page reads, announced per HITL).
3. Use the content as inheritance for the four-step interview.

**Recording**: brief's `## Pre-cascade sources` lists each URL with summary. Mark scope as `Mode C, specific URLs`.

### Mode D — Paste content directly (no MCP)

**Operator setup**: No Notion MCP configured (or operator prefers not to use it). Operator pastes the relevant content directly into chat.

**What consultation does**:
1. Acknowledge the pasted material.
2. If the paste is large (>~3000 tokens), offer to summarize-and-confirm before continuing: "That's ~`<N>` tokens of context. Want me to summarize it back to confirm I caught the key points, or proceed straight to the interview informed by it?"
3. Use as inheritance.

**Recording**: brief's `## Pre-cascade sources` lists each pasted source. URL is "pasted inline." Summary is 1-2 lines on what was extracted. Mark scope as `Mode D, pasted content`.

## HITL announcement discipline

Per `.claude/rules/knowledge-backend.md` § "HITL announcement discipline." Every read and every search announces before executing.

**Single-page read**:
> *"About to fetch `<page title>` from `<root or workspace>`. OK?"*

**Search**:
> *"About to search `<scope>` for `<query>`. Refine, accept, or decline?"*

**Walk** (Mode A subtree listing):
> *"About to list pages under `<root>` (one level deep). This is a read-only walk — no content fetched yet. OK?"*

These announcements are non-negotiable. Bypassing them silently — even for "obvious" reads — trains the operator to ignore the next ad-hoc surfacing and breaks the cascade's HITL discipline.

**Operator override at any time**: "stop reading," "ignore that page," "actually use this other page instead." Consultation respects per-turn corrections without re-asking the mode/scope question from scratch.

## Scope designation rolls forward to scaffold

Whatever scope the operator designates at consultation (root URL in Mode A, workspace in Mode B, specific URLs in Mode C, pasted content in Mode D) is recorded in `problem_brief.md`'s `## Pre-cascade sources` section.

When scaffold runs and the operator picks knowledge backend = `notion` at backend selection, scaffold's Stage 2 follow-up **reads the brief's `## Pre-cascade sources` section** and reuses the scope designation rather than re-asking the operator cold. The handoff is smooth: consultation → brief → scaffold reads brief → scaffold proposes the same scope as the hub designation.

If the operator picks knowledge backend = `none` at scaffold, the brief's `## Pre-cascade sources` content is still preserved (informational; later phases can still cite the URLs for reference) but no Notion writes happen.

## Inheritance discipline at consultation

Per CLAUDE.md's "inheritance is verbatim, not paraphrased" principle:

- When the brief's logic depends on specific wording from a Notion source (a problem framing, a no-go, a user research quote), **quote it** in the brief rather than paraphrasing. Use blockquote format with the source URL on the line below.
- When the brief's logic only needs the *gist* of a source (background research, market context), a 1-2 line summary in `## Pre-cascade sources` is sufficient.
- When in doubt, quote. Future cascade phases that read the brief inherit the quoted material; paraphrased material loses fidelity.

Example of quoted content in §1 Problem statement:

```markdown
## 1. Problem statement

The author has been collecting research on this problem for six months. The
clearest articulation comes from the operator's own Notion note:

> "Every time I try to onboard a new collaborator, I rewrite the same
> three sections of context from scratch. The institutional memory exists
> but it's not portable."
> — [Onboarding pain log](https://notion.so/...)

This brief shapes that pain into a buildable scope.
```

## What this DOES NOT do

- **Does not write to Notion by default.** Consultation only *reads*; the optional companion-page write at the closing HITL gate is opt-in and defaults to SKIP.
- **Does not crawl/index the workspace uninvited.** Every read is explicitly confirmed.
- **Does not require Notion MCP.** Mode D (paste) is a first-class fallback path.
- **Does not skip the four-step interview** when Notion content is ingested. The interview still runs, informed by what was read. The operator's *content* may be richer; consultation's *process* is unchanged.

## Failure modes

| Failure | Surface |
|---|---|
| No Notion MCP configured but operator wanted Mode A/B/C | "Notion MCP not detected. Want to set it up [link to Notion docs] before continuing, or fall back to Mode D (paste content directly)?" |
| Operator pastes URL but it's behind permission | "Couldn't read `<URL>` — likely a permission issue. Share the Notion integration with that page from Notion settings, or paste the content directly?" |
| Search returns too many results to fetch | "Search returned `<N>` pages. Top relevance: `<list of titles>`. Want me to fetch the top 3, refine the query, or paste content directly?" |
| Operator changes mind mid-flow ("actually skip Notion") | Drop the ingestion and proceed straight to the four-step interview. Brief's `## Pre-cascade sources` becomes empty (omitted entirely). |
| Operator wants to fetch but later edits / withdraws a page mid-conversation | Note the withdrawal in `## Pre-cascade sources` — "originally consulted, withdrawn before commit" — so future cascade phases don't expect the page to still inform the brief. |

## When to update this file

Update when:
- A new access mode emerges from real usage (e.g., "designated database query" as a hybrid of B and C) — add to the four-mode table
- A new failure mode recurs across real consultations — add a row to § Failure modes
- The Notion MCP convention evolves (Notion ships new MCP capabilities) — update Mode A/B/C behaviors accordingly
- A second knowledge backend is supported (Confluence, Obsidian, etc.) — generalize the access-mode language or fork into per-backend variants

The principle (consultation is read-primary; HITL on every fetch; scope rolls forward to scaffold) is stable. Operational specifics evolve with usage.
