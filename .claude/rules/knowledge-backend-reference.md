---
paths:
  - ".claude/rules/knowledge-backend*.md"
  - ".claude/skills/**"
  - ".claude/commands/**"
  - ".claude/hooks/require-knowledge-backend-ok.sh"
  - "docs/cbk/**"
---

# Knowledge Backend Patterns — the reference half

> **Path-scoped.** Loads when a cascade skill or command, the knowledge-backend ask-gate hook, a cascade artifact, or this rule pair is read — the moments a phase provisions, reads or writes the knowledge backend. `knowledge-backend.md` (always loaded) keeps the operative contract — when to read, when to write, the announcement discipline, inheritance — and a pointer heading for every section here. Sections were moved on 2026-09-30 and re-sourced in the same change. See `cbk-conventions.md` § Rule loading and the instruction budget. When the knowledge axis is `none`, this file is deleted together with `knowledge-backend.md`, the hook and its settings stanza.

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

**Notion's native Verification property is plan-gated.** Of verifying pages, Notion's help page says: "This feature is available on Business and Enterprise Plans." (`https://www.notion.com/help/wikis-and-verified-pages`, read 2026-09-30). On any other plan, carry the same two facts as ordinary properties: an **Owner** person property and a **Verify by** date property on the same 90 / 180 / 365-day cadence. Record which form the workspace uses in `cbk-conventions.md` § Knowledge backend — operator's specific choices.

If the operator's existing DB doesn't have these properties, surface the gap and offer to extend the schema — don't force it. Workspace conventions can deviate; the rot risk is the operator's call to manage.

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

## Notion MCP convention

**Recommended MCP server**: Notion's official MCP (`https://www.notion.com/help/notion-mcp`).

The kit assumes this MCP is configured when knowledge backend = Notion. If not configured, surface honestly at consultation/scaffold and either:

- Walk the operator through MCP setup (per Notion's docs)
- Fall back to paste-mode operation (consultation only — lower phases require MCP for opt-in fetches)

**Why standardize**: Notion's official MCP is the reference implementation as of the v1 of this kit. It reads and writes: Notion's help page describes connected AI apps that "create structured project pages in Notion" (`https://www.notion.com/help/notion-mcp`, read 2026-09-30), and the write tool names the kit's ask-gate matches are the dated observation in `knowledge-backend.md` § HITL announcement discipline. Alternative Notion MCPs work, but the kit's recommended patterns reference behaviors that may differ. Note alternatives in the project's `cbk-conventions.md`.

## Notion 3.3+ awareness (Feb 2026)

Notion 3.3 introduced Custom Agents — agents that run 24/7 against workspace context: "Just give them a job, set a trigger or schedule, and they'll get it done, 24/7." (`https://www.notion.com/releases/2026-02-24`, "Notion 3.3: Custom Agents", read 2026-09-30; re-read when a Notion release changes what an agent may do to a page). Implication for the kit: pages provisioned by the kit (and any companions later phases promote) should have:

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
- **Notion pricing tiers / plan-specific features** — operator's concern, not the kit's, with one exception the kit prescribes: native page verification is Business/Enterprise-only, and § Wiki pattern + Verification names the fallback
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
