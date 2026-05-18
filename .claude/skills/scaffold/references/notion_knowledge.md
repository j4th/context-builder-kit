# Notion knowledge

Operational reference for scaffold's provisioning when the knowledge backend axis is `notion`. The cross-cutting operational contract (read patterns, write tiering, HITL discipline, lazy provisioning, anti-patterns) lives at `.claude/rules/knowledge-backend.md` — this file covers the scaffold-specific provisioning behavior on top of that contract.

This file is **orthogonal to the planning backend axis**. Notion knowledge works alongside any planning backend (`github-issues`, `linear`, or `in-repo-markdown`). The combinations are documented in `backend_selection.md`.

## What this configuration provisions

**At scaffold time, only the project hub row.** No sub-pages. The hub-page convention from `.claude/rules/knowledge-backend.md` describes the *recommended vocabulary* (eight sub-pages); the actual sub-pages are lazy-provisioned by later phases as actual writes target them.

The hub is a **row in a Projects database** inside an Engineering teamspace (per the hub-as-database-row model in `knowledge-backend.md`), not a top-level sidebar page. Scaffold will either:

- (a) **Create a new row** in an existing Projects DB, designating it as the project hub
- (b) **Designate an existing page** as the hub (operator pastes URL)
- (c) **Skip Notion provisioning** entirely — operator wires it up manually later

The choice is operator-driven via the brownfield detection script (next section).

## Brownfield detection at scaffold (read-only)

When the operator picks `notion` for knowledge, run the brownfield detection script from `knowledge-backend.md` § "Brownfield detection at scaffold." Read-only — no writes during detection.

Detection surfaces:

- Does an Engineering teamspace exist? (Or General teamspace if no Engineering split.)
- Does a Projects database exist in that teamspace? What properties does it have (Status, Owner, Tags, Verification, etc.)?
- Does an Engineering Wiki (cross-project artifacts) exist? Where?
- Is there an existing project hub row matching this project's slug?

Present findings to the operator with the three-option choice from above (create new row / designate existing / skip).

**If the operator's workspace is missing structural pieces** (e.g., no Engineering teamspace, no Projects DB), surface the gap and ask whether to:

- Adopt the recommended structure (operator creates the missing pieces in Notion UI before scaffold proceeds — this is a manual step, scaffold doesn't auto-create teamspaces or databases unprompted)
- Adapt to a flatter hierarchy (operator's choice; scaffold warns about rollup limitations)
- Skip Notion knowledge backend (fall back to `none`)

**If consultation already designated a Notion scope** (Mode A/B from `consultation/references/notion_ingestion.md`), the scope is recorded in `problem_brief.md`'s `## Pre-cascade sources` section. Read it before running brownfield detection — the designation may already match a real Notion structure that detection can verify rather than re-asking the operator from scratch.

## What scaffold writes (when permission given)

- The **hub row** in the Projects DB (or a hub page if the operator picked option (b) with an existing page)
- The **`.cascade/backends.toml`** `[knowledge]` block with `backend = "notion"` and the hub URL (see `backends.md` § Configuration)
- The **`cbk-conventions.md`** § "Knowledge backend" section (per the project template) with the operator's specific choices: hub URL, Engineering Wiki URL (if exists), MCP server reference, any workspace deviations

**That's it.** Scaffold does not create:
- Any of the eight recommended sub-pages (lazy — created when actual writes target them)
- The Engineering teamspace (surfaces gap; manual creation required if missing)
- The Projects database (surfaces gap; manual creation required if missing)
- The Engineering Wiki (surfaces gap; manual creation required if missing)
- Verification properties on existing databases (offered to operator if missing; never forced)

The "minimum hub footprint" discipline is load-bearing — eager provisioning would clutter the workspace with empty containers and disrespect operators' existing conventions.

## What's deferred (gaps to flag honestly)

- **Specific Notion MCP server enforcement** — `knowledge-backend.md` recommends Notion's official MCP but allows alternatives. Scaffold detects whichever is configured and surfaces if none is.
- **Hub-page sub-page provisioning automation** — sub-pages are lazy-provisioned by later phases, not by scaffold. The first cascade run that promotes a write to Notion is the first time any sub-page materializes.
- **Cross-MCP integration verification** — if the operator also picked Linear for planning, Notion's Linear integration is a manual step (operator enables it in Linear settings). Scaffold flags but doesn't automate.

## Behavior when the operator picks `notion` for knowledge

1. Confirm Notion MCP is configured. If not, surface honestly: setup link, or fall back to designating an existing URL manually (operator provides the URL; scaffold records it without verifying).
2. Run brownfield detection (read-only).
3. Present detection findings + three-option choice.
4. If operator picks (a) create new row or (b) designate existing:
   - Announce the planned write (per `knowledge-backend.md` § "HITL announcement discipline")
   - Commit the hub row / hub designation via Notion MCP
   - Verify by reading back (per the same atomic-transition discipline applied to GitHub MCP operations)
5. Update `.cascade/backends.toml` and `cbk-conventions.md` with the hub URL and any operator-stated deviations.
6. If operator picks (c) skip, record `knowledge.backend = "none"` in `.cascade/backends.toml` and surface "Notion knowledge backend skipped per operator choice — wire up manually later if needed."

## Failure modes specific to this configuration

- **No Notion MCP configured** — surface link to Notion's MCP docs; offer manual designation as fallback.
- **MCP write fails on permission** — Notion integration not shared with target page/teamspace. Surface remediation: "Share the Notion integration with `<target>` from Notion settings, then I'll retry." (Per `knowledge-backend.md` failure modes.)
- **Operator's workspace has non-canonical structure** — flat hierarchy, no Projects DB, different sub-page names. Surface what's found; let operator decide whether to adapt or restructure.
- **Hub designation URL is invalid or inaccessible** — scaffold can't read the page. Surface and ask for a different URL or a structure detection re-run.

## When to flesh this out

After the first real cascade run on a `notion`-knowledge project lands its first lazy-provisioned sub-page, capture the pattern that worked (which sub-page first, what HITL phrasing, what gaps the brownfield detection missed) and fold it back into this file plus `knowledge-backend.md`. The first run informs the operational specifics; pre-documenting before exercising is the failure mode this file's existence in v1-stub form would have created.
