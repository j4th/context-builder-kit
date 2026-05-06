---
name: adr-new
description: Create a new immutable ADR in docs/adr/, allocating the next sequence number, rendering from template.md, and updating the three indexes (docs/adr/README.md, docs/ARCHITECTURE.md § Decisions log + Configurability summary, docs/cbk/blueprint.md § Stack decisions). Use when the user wants to record a new architecture decision or supersede an existing one.
disable-model-invocation: true
---

# adr-new

Create a new ADR. ADRs are **immutable** (ADR-0000) — superseding writes a new ADR, never edits the old one.

## When to use

- The user has decided to record a new architecture decision.
- The user wants to supersede an existing ADR (the new one references the old one's number).
- A previously-deferred Open Question (in `docs/ARCHITECTURE.md` § Open questions or `docs/cbk/blueprint.md` § Open questions) has been resolved.

## When NOT to use

- For changes to the *architecture document* itself (`docs/ARCHITECTURE.md`) — that file is mutable; edit it directly. ADRs record *decisions*, not the resulting topology.
- For routine code changes that conform to existing ADRs.
- For changes to STANDARDS.md or workflow rules — those evolve in place.

## Inputs (interactive)

When invoked, ask the user (in this order, one question at a time — don't batch):

1. **Slug** — kebab-case noun phrase, max 8 words. Used in the filename. Example: `vector-store-as-anubis-tool`.
2. **Title** — full title for the ADR header, sentence case. Example: `Vector store as an Anubis tool, not an MCP server`.
3. **Supersedes?** — if yes, the ADR number being superseded (e.g., `0019`).
4. **Configurable / Hot-swappable** — for the Configurability summary table. Format: `yes (per-Pilot) | no (config-time)`. Use `n/a` for non-component decisions.
5. **One-line summary** — for the README index and the Decisions log table.

## Steps

1. **Allocate the next number.**
   ```bash
   ls docs/adr/ | grep -E '^[0-9]{4}-' | sort | tail -1 | cut -d- -f1
   ```
   Increment by 1, zero-pad to 4 digits.

2. **Render from template.**
   ```bash
   cp docs/adr/template.md "docs/adr/${NNNN}-${SLUG}.md"
   ```
   Then fill in: ADR number, title, status (`Accepted` for new decisions, `Proposed` if user wants HITL gate first), date (today, ISO format), deciders, related ADRs, supersedes (if any), context, options considered, decision, consequences.

3. **Update `docs/adr/README.md` index.**
   - Add the row to the index table in number order.
   - If superseding, mark the old ADR's status field in the index as `Superseded by ADR-${NNNN}` and add a backlink (don't edit the old ADR file itself; the index expresses supersession).

4. **Update `docs/ARCHITECTURE.md`.**
   - § Decisions log table: add the new row.
   - § Configurability summary table: add the new row with the configurable/hot-swappable values from input 4.
   - If the new ADR resolves an Open Question, remove the question from § Open questions.

5. **Update `docs/cbk/blueprint.md`.**
   - § Stack decisions table: add the new row (matches the ARCHITECTURE.md and README.md indexes).
   - If resolving an Open Question, remove from § Open questions there too.

6. **Verify cross-references match.**
   - All three indexes must agree on number, title, status, configurability.
   - Any cross-ADR references in the new ADR's `Related:` field must exist.

7. **Hand back to user.** Print the new file path and a one-line summary. Do not commit — the user runs `commit-commands:commit` separately.

## Constraints

- **Never edit an existing ADR file.** The PreToolUse hook (`.claude/hooks/protect-immutable-adrs.sh`) will block this. Supersession is index-level only.
- **Date is always today** in `YYYY-MM-DD` format. Use the `time` MCP if uncertain rather than guessing.
- **Title in the file header must match the title in all three indexes** — drift here is the most common mistake.
- The skill produces files only; it does not commit, push, or open PRs.
