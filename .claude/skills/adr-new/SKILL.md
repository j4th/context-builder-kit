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

## Refines vs Supersedes

A new ADR connects to an existing one through one of two relationships. Both are recorded as header fields and both preserve the parent's immutability — neither ever edits the parent file.

- **`Supersedes: ADR-NNNN`** — the new ADR *replaces* the parent's decision. The parent's status becomes `Superseded by ADR-MMMM`; new code follows the new ADR. This is the relationship the interactive **Supersedes?** input captures, and the one Step 3's index-marking handles.
- **`Refines: ADR-NNNN (Dn, …)`** — the new ADR *clause-level-clarifies or narrows* a specific decision `Dn` in the parent **without invalidating it**. The parent stays `Accepted`; both parent and child are consulted when evaluating conformance. Use this when implementation reveals that an accepted clause was written too generally and needs a scoped reading (e.g. "this rule applies only to <entity-type>"), not a reversal.

**Clause-scoped supersession.** Supersession can also target a single clause rather than a whole ADR: `Supersedes: ADR-NNNN Dn` reverses only decision `Dn` of the parent while the parent's other clauses stand. The parent's status stays `Accepted` (it is not wholly superseded); the child's index row names the specific clause it replaces.

**How the skill handles each:**

- Add a **Refines?** input alongside the Supersedes? input (Inputs, above) — if yes, capture the parent number and the specific decision clauses in `ADR-NNNN (Dn, …)` form.
- In Step 2, fill the `Refines:` field (or the clause-scoped `Supersedes:` field) in the new ADR's header.
- In Step 3, add the child's index row naming its `Refines:` (or clause-scoped supersession) target. **A refined parent gains no back-pointer and no status change** — it stays `Accepted`, and discoverability comes from the child's header field plus the child's index row. Only a *whole-ADR* supersession flips the parent's index status to `Superseded by ADR-NNNN`; a pure refine (or a clause-scoped supersede) leaves the parent `Accepted`.

**Reviewers must follow the `Refines:` chain.** When an ADR-conformance check finds an ADR that intersects a diff, it also loads any ADR that names that ADR in a `Refines:` (or clause-scoped `Supersedes:`) field and applies the refiner's scoped clauses. A parent read in isolation — without its refiners — yields the pre-narrowing, too-general reading.

