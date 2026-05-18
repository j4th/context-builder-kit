# Knowledge Backend Patterns

Operational rules for how cascade phases interact with the knowledge backend — a durable, longer-lived reference library that sits alongside (not replacing) the repo's markdown docs and the planning backend. Notion is the v1 reference implementation; the patterns here are written to generalize to other backends (Confluence, Obsidian) when a second one is supported.

The principle:

- **The knowledge backend is the durable reference library, not the cascade's source of truth.** Cascade artifacts (`docs/cbk/*`) always live in the repo. The knowledge backend holds *different* content: pre-cascade research, cross-project decisions, durable runbooks, things that outlive any single project.
- **Read-primary at lower phases.** Cascade phases default to repo + inheritance. The knowledge backend is consulted on demand when richer context than the repo carries is needed.
- **Writes are tiered.** Consultation and scaffold may write routinely when promoting structured context. Lower phases (blueprint, framing, rough-in, `/finish`) write only when HITL explicitly OKs it — never as a side effect of primary work.
- **Brownfield-first, lazy provisioning.** Detect what exists in the operator's workspace before creating anything. Create sub-pages only when an actual write targets them — never as a "set up the recommended structure" pre-step.

## The three surfaces

| Surface | Role | Where it lives | Why |
|---|---|---|---|
| **Code/repo** | Source of truth for code, immediate AI/dev context | git (always GitHub or other git host) | Versioned with code; Claude Code reads it as immediate context; can't be replaced by any external surface |
| **Planning backend** | Live work-tracking with status, parent/child, queryable state | GitHub Issues, Linear, or none (in-repo markdown) | Cascade hierarchy needs statused/queryable representation; markdown alone can't do that for active work |
| **Knowledge backend** | Durable longer-lived reference library | Notion (v1); future: Confluence, Obsidian | Holds context that *predates* the project or *spans* multiple repos |

The repo + core markdown docs are the **constant** — always present, always the immediate AI/dev context. Planning and knowledge are **independent axes** the operator picks separately.

Files that always live in the repo (never in the knowledge backend):

- `CLAUDE.md`, `ARCHITECTURE.md`, `STANDARDS.md`, `CONTRIBUTING.md`
- `docs/adr/*.md` (immutable architecture decisions)
- `docs/cbk/*.md` (cascade artifacts: problem_brief, blueprint, frame-NN, README index)
- All source code, tests, configs

Knowledge-backend writes are *companions* to these, never substitutes.

## The hub-as-database-row model

When knowledge backend is Notion, the project hub is a **row in a Projects database inside an Engineering teamspace**, not a top-level sidebar page. Three reasons:

- Enables roadmap and status views across projects
- Prevents sidebar bloat as the team grows
- Cross-project rollups (which projects are active, blocked, use vendor X) become DB queries

Recommended workspace shape:

```
Workspace
├── General teamspace          (company-wide; outside cascade scope)
└── Engineering teamspace
    ├── Engineering Wiki        (cross-project: standards, on-call,
    │                            vendor evaluations, shared runbooks)
    └── Projects                (database)
        └── [Project hub row]   ← what the kit provisions / links to
```

**Cross-project artifacts** (runbooks spanning repos, vendor evaluations, shared ADRs affecting multiple projects) live in the Engineering Wiki one level up, **never** inside a single project's hub. Forcing cross-project content into a single project's hub is the most common organizational drift.

If the operator's workspace doesn't have an Engineering teamspace or Projects database, surface what's missing and let them decide whether to create the recommended structure or use a flatter alternative. Respect existing workspace conventions; never restructure without permission.

## Hub sub-page convention — recommended vocabulary

The eight sub-pages below describe the **recommended vocabulary** — what the kit knows how to create and reference. The kit creates each one only when:

(a) a write actually targets it, AND
(b) the operator approves creation at the moment of that write

Scaffold provisions **only the hub row itself**. Everything else is lazy. The operator's existing workspace may already have some sub-pages under different names — surface those at brownfield detection and let the operator map them or accept the kit's naming.

| Sub-page | Type | Created when |
|---|---|---|
| Start here / Onboarding | Page | Operator opts in at scaffold |
| Decision Log | Database (Table) | First non-ADR decision write |
| Meeting Notes | Database (Table) | Operator opts in (no cascade phase auto-creates) |
| Research & Reference | Database (Gallery) | First consultation companion-page or research promotion |
| Runbooks & Playbooks | Database (Table) | First framing cross-project meta-issue or `/finish` learning promotion |
| Cascade Artifacts (mirror) | Page with sync blocks | Operator opts in at scaffold or any later phase |
| People & Context | Page | Operator opts in (no cascade phase auto-creates) |
| Archive | Page | First archive operation |

## Pages vs databases — the rule

**Database** when:
- More than ~5 instances of the same shape are likely, AND
- You want to filter, sort, or query

**Free-form page** when:
- Singleton or narrative content
- No need to query across instances

The cascade's planning backend (GitHub Issues / Linear) covers Projects + Tasks. Notion's job is to add Meetings + Decisions + Research + Runbooks as databases, related to the project via Notion's Relation property.

## Wiki pattern + Verification — rot prevention

Every database-backed page must have:

- **Owner property** — one person, not "the team"
- **Verification property with expiry** — 90 / 180 / 365 days based on volatility:
  - Runbooks & Playbooks: 90 days (operational accuracy decays fast)
  - Decision Log: 180 days (decisions decay slower but context shifts)
  - Research & Reference: 365 days (long-tail reference; verify annually)

Unverified pages are how Notion becomes a graveyard. The kit's hub provisioning sets these properties up when it creates the relevant DB; ongoing maintenance is the operator's responsibility.

If the operator's existing DB doesn't have these properties, surface the gap and offer to extend the schema — don't force it. Workspace conventions can deviate; the rot risk is the operator's call to manage.

## The code-adjacent split — canonical

| Artifact | Lives in | Why |
|---|---|---|
| ADRs | **Repo** (`docs/adr/`) | Versioned, immutable, PR-reviewable; the kit's `adr-new` skill assumes this |
| CLAUDE.md, ARCHITECTURE.md, STANDARDS.md, CONTRIBUTING.md | **Repo** | Claude Code reads them as immediate context; coupling to code is the point |
| `docs/cbk/*` cascade artifacts | **Repo** (source) + optionally **Notion** (read-only sync block) | Append-only audit trail belongs with code; Notion mirror is for stakeholder readability when wanted |
| Architecture diagrams | **Notion** (embedded via Figma / Excalidraw) | Visual artifacts benefit from Notion's rendering; bidirectional links between Notion and repo |
| Decision logs (non-architectural) | **Notion DB** | Cross-functional contribution; non-engineers participate |
| Meeting notes, runbooks, research | **Notion DB** | Outlive any single repo |

**Never**:
- Copy repo docs into Notion. Use sync/embed blocks instead. Manual copies guarantee drift.
- Put ADRs in Notion. Loses version control, PR review, and code-coupled history.
- Make the project hub a top-level sidebar page. Kills cross-project rollups.

## When to read

Default behavior: rely on the repo + inheritance from prior cascade artifacts.

Reach to the knowledge backend only when:

- The operator explicitly designates Notion content to consult (consultation Mode A/B/C from `consultation/references/notion_ingestion.md`)
- The current phase's inheritance step surfaces relevant Notion pages and the operator opts to fetch
- A prior cascade artifact cites a Notion URL the current phase needs to resolve (e.g., `problem_brief.md` listed pages in `## Pre-cascade sources`)

Reading is always opt-in at lower phases. Surface what's available; let the operator decide what's worth pulling.

## When to write

Tiered by phase, default by HITL:

| Phase | Write default | Common reason |
|---|---|---|
| Consultation | Opt-in | Promote companion page from incoming context |
| Scaffold | Opt-in | Establish project hub row in Projects DB |
| Blueprint | Opt-in (rare) | Cross-project strategy companion |
| Framing | Opt-in (rare) | Cross-project meta-issue runbook |
| Rough-in | Never | Out of scope by design |
| `/finish` | Opt-in (rare) | Cross-project learning runbook |

Every write requires explicit HITL approval. No cascade phase writes to the knowledge backend as a side effect of its primary work.

When writing, write **companion** material that *adds to* the repo artifact, not a copy of it:
- Repo holds the structured cascade artifact (immediate context)
- Notion holds longer-form supporting material, decision threads, cross-project links, durable runbooks

The companion always **links back** to the repo artifact by URL. Never mirror cascade artifacts verbatim into Notion — that's drift bait.

## Brownfield detection at scaffold

When scaffold's backend selection picks knowledge backend = Notion, run **read-only** detection via the Notion MCP before any write:

```
Detect at scaffold time:
  - Engineering teamspace exists? (or General teamspace if no
    Engineering split)
  - Projects database exists in that teamspace? What properties does
    it have (Status, Owner, Tags, etc.)?
  - Engineering Wiki (cross-project) exists? Where?
  - Project hub matching this project's slug already in Projects DB?

Surface findings to operator:
  "Found: Engineering teamspace + Projects DB (with Status, Owner,
   Tags). No existing project named '<slug>' in Projects DB. No
   Engineering Wiki found.

   I can:
   (a) Create a new row in Projects DB for this project — designate
       as hub
   (b) Designate an existing page as the hub (paste URL)
   (c) Skip Notion provisioning entirely; wire up manually later"
```

Detection is read-only. No writes happen during detection. If MCP isn't connected or detection fails, surface honestly and fall back to "designate an existing URL" or "skip."

**What scaffold will create when given permission**: the hub row in Projects DB (or designation of an existing page). **Nothing else.** Sub-pages are NOT pre-created.

**What scaffold will not create unprompted**: Engineering teamspace, Projects DB, Engineering Wiki, or any of the eight sub-pages. If the operator's workspace is missing the Projects DB shape entirely, surface the gap and ask whether to create the recommended structure or adapt to a flatter hierarchy. The kit warns about rollup limitations but respects the choice.

## Lazy provisioning at write-back

When a later phase writes to Notion (consultation companion, blueprint strategy companion, framing meta-issue runbook, `/finish` learning runbook), the HITL gate has two layers:

```
Layer 1: "Promote this <content> to a Notion <destination type>?"
         → operator: yes / no / skip / later
         (default: SKIP)

Layer 2 (only if Layer 1 = yes):
  "Destination: <DB name> under <hub>. That database doesn't exist
   yet. Create it now (one-time), or pick a different destination?"
   → operator: create / pick destination / cancel write
```

The destination DB only materializes when a write actually lands there. If the operator writes a single decision log entry, only the Decision Log DB exists in Notion at that point — not the other seven sub-pages.

The eight-sub-page convention above is the **vocabulary the kit uses when offering destinations**, not the structure it pre-builds. Operators with existing workspaces often have their own DB names (e.g., "ADRs" instead of "Decision Log"). Lazy creation surfaces the mismatch at the moment it matters; operator can map their DB instead of creating a duplicate.

## HITL announcement discipline

Every read, search, and write to the knowledge backend announces before executing.

**Read** (single page):
```
"About to fetch <page title> from <hub scope>. OK?"
```
Operator can decline per-page.

**Search**:
```
"About to search <hub scope> for <query>. OK?"
```
Operator can refine the query or decline.

**Write** (page create):
```
"About to create a new page <title> under <parent>. Body preview:
 <first 200 chars>. OK?"
```
Operator can edit, decline, or commit.

**Write** (page update):
```
"About to update <page title>. Diff preview: <summary>. OK?"
```

These announcements are non-negotiable. Bypassing them silently — even for "obvious" reads or "trivial" writes — trains the operator to ignore the next ad-hoc surfacing, which is the next failure mode.

## Inheritance discipline

When a cascade phase consumes knowledge-backend content, its inheritance summary records:

- The hub scope or specific URL consulted
- The page title
- A 1-2 line summary of what was extracted
- Quoted content (verbatim) where the phase's logic depends on specific wording

This keeps the chain auditable when later phases or future readers trace why a decision was made. Paraphrased inheritance is the cascade's most common failure mode; quote, don't summarize, when the wording matters.

## Notion MCP convention

**Recommended MCP server**: Notion's official MCP (`notion.com/help/notion-mcp`).

The kit assumes this MCP is configured when knowledge backend = Notion. If not configured, surface honestly at consultation/scaffold and either:

- Walk the operator through MCP setup (per Notion's docs)
- Fall back to paste-mode operation (consultation only — lower phases require MCP for opt-in fetches)

**Why standardize**: Notion's official MCP is the reference implementation as of the v1 of this kit. It supports both read and write; integrates cleanly with Claude Code. Alternative Notion MCPs work, but the kit's recommended patterns reference behaviors that may differ. Note alternatives in the project's `cbk-conventions.md`.

## Notion 3.3+ awareness (Feb 2026)

Notion 3.3 introduced Custom Agents — agents that run 24/7 against workspace context. Implication for the kit: pages provisioned by the kit (and any companions later phases promote) should have:

- Clear, structured titles (no jargon-heavy or session-specific phrasing)
- Owner + Verification properties (already required by the Wiki pattern above)
- Explicit metadata on what the page is *for* (in the first paragraph, not just implied by location)

These properties were already load-bearing for the Wiki rot-prevention discipline; calling out the agentic dimension so future updates don't drift away from them.

## Failure modes

| Failure | Surface |
|---|---|
| No Notion MCP configured | "Notion MCP not detected. Want to set it up [link to Notion docs] or proceed without knowledge backend?" |
| MCP fetch fails | "Couldn't reach `<page>`. Retry, skip, or paste content directly?" |
| MCP write fails on permission | "Notion integration not shared with `<page>`. Share it from Notion settings [remediation steps], then I'll retry." |
| Notion page accessed by cascade was deleted/moved | "`<URL>` returns 404. Update `cbk-conventions.md` with the new URL, or designate a replacement?" |
| Operator-pasted content too large for context | "Pasted content is `<N>` tokens — summarize before continuing or proceed with full content?" |
| Brownfield detection finds non-canonical structure (e.g., no Engineering teamspace) | "Found: `<structure>`. Recommended structure is `<X>`. Adopt recommended, adapt to existing, or skip Notion provisioning?" |

Surface every failure with a concrete next action. Don't fail silently; don't retry blindly.

## What this doc deliberately doesn't cover

- **Specific Notion marketplace templates** — templates are starting points; the kit's hub structure IS the recommended template
- **Notion pricing tiers / plan-specific features** — operator's concern, not the kit's
- **Cross-knowledge-backend portability** (Confluence, Obsidian, etc.) — design once a second knowledge backend is actually supported, not before
- **Automated hub-page provisioning beyond the hub row** — sub-pages are lazy-provisioned only
- **Notion-side organization rules** — operator's call; the kit only needs the hub URL recorded in `cbk-conventions.md`
- **Bidirectional sync for cascade artifacts** — explicitly out of scope. Sync blocks are one-way (repo → Notion). Drift risk is the reason.

## Anti-patterns

1. **Database proliferation** — start with the four databases (Decisions, Meetings, Research, Runbooks); add a fifth only when an existing one has >50 rows AND a clear axis of separation. Most teams need 2-3 active databases, not 8.
2. **No Verification property** — every DB-backed page needs Owner + expiry, or it rots. Unverified pages are graveyards.
3. **Top-level project pages instead of DB rows** — kills cross-project rollups; bloats the sidebar; locks the team into a structure that doesn't scale beyond ~5 projects.
4. **Duplicating repo docs into Notion** — use sync/embed blocks. Manual copies guarantee drift. Single source of truth still applies; Notion just provides a different *view*.
5. **ADRs in Notion** — loses version control, PR review, code-coupled history, and immutability enforcement (the repo's CI lint can't reach Notion).
6. **Copying a marketplace template verbatim** — templates are starting points; the kit's structure IS the recommended default. Marketplace templates were designed for different team shapes and often include surface area the cascade doesn't use.
7. **No Archive page** — deletion is one-way; archive is cheap. Superseded research and abandoned approaches lose context when deleted.
8. **Skipping General teamspace** — non-engineers can't find anything; cross-team context (mission, handbook, company-wide decisions) doesn't belong in Engineering.
9. **Eager provisioning of all sub-pages at scaffold** — clutters the workspace with empty containers; doesn't respect existing conventions; creates abandonment-rot when projects wind down. Lazy creation per write is the discipline.

## When to update this file

This rules file is load-bearing the moment any cascade phase reads from or writes to the knowledge backend. Update it when:

- A new write pattern emerges that should be HITL-gated (and isn't yet) — add a row to § When to write
- A new failure mode recurs that should be surfaced consistently — add a row to § Failure modes
- A new anti-pattern surfaces from real cascade runs — add to § Anti-patterns
- A second knowledge backend is supported (Confluence, Obsidian) — generalize the Notion-specific sections or fork into per-backend operational notes
- A specific Notion-MCP behavior turns out to need calibration (search relevance, write idempotence) — add to § Notion MCP convention

The principle (knowledge backend as durable reference library, read-primary at lower phases, write-tiered with HITL) is stable. The operational specifics evolve with usage.
