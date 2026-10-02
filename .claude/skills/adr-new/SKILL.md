---
name: adr-new
description: Create a new immutable ADR in docs/adr/, allocating the next sequence number, rendering from template.md, and updating every index the project's conventions name (`.claude/rules/cbk-conventions.md` § ADR index sync). Use when the user wants to record a new architecture decision, or supersede, refine or extend an existing one.
disable-model-invocation: true
---

# adr-new

Create a new ADR. ADRs are **immutable** (ADR-0000) — superseding writes a new ADR, never edits the old one.

## When to use

- The user has decided to record a new architecture decision.
- The user wants to supersede an existing ADR (the new one references the old one's number).
- A previously-deferred open question (in `docs/cbk/blueprint.md` § Open Questions, or wherever the project's indexes keep their open-questions list) has been resolved.

## When NOT to use

- For changes to the *architecture document* itself (`docs/ARCHITECTURE.md`) — that file is mutable; edit it directly. ADRs record *decisions*, not the resulting topology.
- For routine code changes that conform to existing ADRs.
- For changes to STANDARDS.md or workflow rules — those evolve in place.

## Inputs (interactive)

When invoked, **propose** every input below from what the operator already said and the tree (the conversation, the issue, the frame, the existing ADR index), present the filled set in one exchange, and ask only for what cannot be inferred — never one question at a time, and never a bare form. The operator corrects the proposal; the corrected set is the input.

1. **Slug** — kebab-case noun phrase, max 8 words. Used in the filename. Example: `vector-store-as-agent-tool`.
2. **Title** — full title for the ADR header, sentence case. Example: `Vector store as an agent tool, not an MCP server`.
3. **Supersedes?** — if yes, the ADR number being superseded (e.g., `0019`), or `ADR-NNNN Dn` for one clause.
   **Refines?** — if yes, the parent and the clauses narrowed, in `ADR-NNNN (Dn, …)` form.
   **Extends?** — if yes, the parent and the clauses an obligation is added beside, same form (`cbk-conventions-reference.md` § ADR relation grains has the disambiguation test).
   **Promotes?** — if the decision is lifted from a frozen pre-cascade corpus, the corpus path and heading.
4. **Configurable / Hot-swappable** — for the configurability index row, where the project keeps one. Format: `yes (per-tenant) | no (config-time)`. Use `n/a` for non-component decisions.
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
   Then fill in: ADR number, title, status (`Accepted` for new decisions, `Proposed` if user wants HITL gate first), date (today, ISO format), deciders, related ADRs, the relation slots the inputs filled (`Supersedes:` / `Refines:` / `Extends:` / `Promotes:` — delete the unused lines), context, options considered, decision, consequences.

3. **Update `docs/adr/README.md` index** — the canonical surface.
   - Add the row to the index table in number order — **in the form the existing rows already use.** Read them first: which cell carries the relation grain and the parent (the kit's starter index puts it in the Status cell — `Accepted · Refines ADR-0007 (D2)` — while an index that predates the starter may carry it as a Title-cell parenthetical, with another separator, or in prose), and write the new row exactly that way. The separator is the index's convention, not this skill's; two real indexes already contradicted the pinned form two different ways (context-builder-kit#58, 2026-09-07 comment).
   - If wholly superseding, mark the old ADR's status field in the index as `Superseded by ADR-${NNNN}` (don't edit the old ADR file itself; the index expresses supersession). A clause-scoped supersession annotates the parent's row in the form this index already uses for one — read the rows first; an index can hold more than one form (the starter's is `Accepted · Dn superseded by ADR-${NNNN}` in the Status cell; a parent whose title already carries a relation parenthetical may take it inside that parenthetical), and the separator is the index's. A refine or extend leaves the parent's row as it was.

4. **Update every other index the conventions name.** `.claude/rules/cbk-conventions.md` § ADR index sync is the one home for the target list — read it now and walk it; this skill states no count. The blueprint's § Stack decisions table is append-only and gets a one-line bullet **only when the ADR changes a stack decision**; a decision that is not about the stack does not touch it. Where a project keeps an open-questions list on an index surface, an ADR that resolves one removes it there.

5. **Verify cross-references match.**
   - Every index the conventions name agrees on number, title, status and grain; on drift the README row wins and the others are corrected to it.
   - Any ADR named in the new ADR's `Related:`, `Supersedes:`, `Refines:` or `Extends:` field exists; a `Promotes:` path resolves.

6. **Hand back to user.** Print the new file path and a one-line summary. Do not commit — the user runs `commit-commands:commit` separately.

## Constraints

- **Never edit an existing ADR file.** The PreToolUse hook (`.claude/hooks/protect-immutable-adrs.sh`) will block this. Supersession is index-level only.
- **Date is always today** in `YYYY-MM-DD` format. Use the `time` MCP if uncertain rather than guessing.
- **Title in the file header must match the title in every index the conventions name** — drift here is the most common mistake; the README row is canonical when they disagree.
- The skill produces files only; it does not commit, push, or open PRs.

## Relation grains

The grains — whole and clause-scoped Supersede, Refine, Extend, Promote — their disambiguation test, the refines that scope a non-decision clause or disclose a falsified pre-commitment, and the rule that reviewers follow the `Refines:` and `Extends:` chains are stated once, in `.claude/rules/cbk-conventions-reference.md` § ADR relation grains; read it before filling a relation slot. **See also** `docs/adr/corrections.md` — a wrong *claim* in an accepted ADR (a citation, a figure, an attribution, a formula) is none of these grains; it is an append-only register entry, and the ADR stays as written.

**Header narrative.** A `Refines:` or `Extends:` header carries more than the pointer: for each named parent clause, one or two sentences stating what is narrowed, added or additionally sanctioned and what stays binding, ending with an explicit "all parents stay Accepted and immutable" line. A bare `Refines: ADR-NNNN (D2)` forces every future reader to re-derive the delta; the clause-level narrative is what makes the chain readable at conformance-check speed.

**How the skill handles each:**

- The Inputs above name the parent: for **Refines?** and **Extends?** with its clauses in `ADR-NNNN (Dn, …)` form, for **Supersedes?** the whole ADR or one clause (`ADR-NNNN Dn`), and for **Promotes?** the corpus path and heading.
- Step 2 fills the matching header slot — `Supersedes:` (whole or clause-scoped), `Refines:`, `Extends:` or `Promotes:` — with the narrative above, and deletes the unused lines.
- Step 3 adds the child's index row naming its target. **A refined or extended parent gains no back-pointer and no status change** — it stays `Accepted`, and discoverability comes from the child's header field plus the child's index row. Only a *whole-ADR* supersession flips the parent's index status to `Superseded by ADR-NNNN`; a clause-scoped supersession annotates the parent's row in the index's own form (Step 3).

