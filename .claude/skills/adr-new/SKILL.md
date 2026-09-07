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

1. **Slug** — kebab-case noun phrase, max 8 words. Used in the filename. Example: `vector-store-as-anubis-tool`.
2. **Title** — full title for the ADR header, sentence case. Example: `Vector store as an Anubis tool, not an MCP server`.
3. **Supersedes?** — if yes, the ADR number being superseded (e.g., `0019`), or `ADR-NNNN Dn` for one clause.
   **Refines?** — if yes, the parent and the clauses narrowed, in `ADR-NNNN (Dn, …)` form.
   **Extends?** — if yes, the parent and the clauses an obligation is added beside, same form (§ Refines vs Supersedes has the disambiguation test).
   **Promotes?** — if the decision is lifted from a frozen pre-cascade corpus, the corpus path and heading.
4. **Configurable / Hot-swappable** — for the configurability index row, where the project keeps one. Format: `yes (per-Pilot) | no (config-time)`. Use `n/a` for non-component decisions.
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
   - Add the row to the index table in number order; the status cell carries the grain and the parent inline (`Accepted · Refines ADR-0007 (D2)`, `Accepted · Extends ADR-0003 (D1)`).
   - If wholly superseding, mark the old ADR's status field in the index as `Superseded by ADR-${NNNN}` (don't edit the old ADR file itself; the index expresses supersession). A clause-scoped supersession annotates the parent's row (`Accepted · Dn superseded by ADR-${NNNN}`); a refine or extend leaves the parent's row as it was.

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

## Refines vs Supersedes vs Extends

**See also** `docs/adr/corrections.md` — a wrong *claim* in an accepted ADR (a citation, a figure, an attribution, a formula) is none of these grains; it is an append-only register entry, and the ADR stays as written.

A new ADR connects to an existing one through one of two relationships. Both are recorded as header fields and both preserve the parent's immutability — neither ever edits the parent file.

- **`Supersedes: ADR-NNNN`** — the new ADR *replaces* the parent's decision. The parent's status becomes `Superseded by ADR-MMMM`; new code follows the new ADR. This is the relationship the interactive **Supersedes?** input captures, and the one Step 3's index-marking handles.
- **`Refines: ADR-NNNN (Dn, …)`** — the new ADR *clause-level-clarifies or narrows* a specific decision `Dn` in the parent **without invalidating it**. The parent stays `Accepted`; both parent and child are consulted when evaluating conformance. Use this when implementation reveals that an accepted clause was written too generally and needs a scoped reading (e.g. "this rule applies only to <entity-type>"), not a reversal.

**Clause-scoped supersession.** Supersession can also target a single clause rather than a whole ADR: `Supersedes: ADR-NNNN Dn` reverses only decision `Dn` of the parent while the parent's other clauses stand. The parent's status stays `Accepted` (it is not wholly superseded); the child's index row names the specific clause it replaces.

**Header narrative.** A `Refines:` header carries more than the pointer: for each named parent clause, one or two sentences stating what is narrowed or additionally sanctioned and what stays binding, ending with an explicit "all parents stay Accepted and immutable" line. A bare `Refines: ADR-NNNN (D2)` forces every future reader to re-derive the delta; the clause-level narrative is what makes the chain readable at conformance-check speed.

**`Extends: ADR-NNNN (Dn, …)`** — the new ADR *adds an obligation beside* a parent clause that stays satisfied as written; the parent is not narrowed and stays `Accepted`. **The disambiguation test:** a child that removes a permitted reading of the parent clause is a Refine; one that adds an obligation beside a clause that stays satisfied is an Extend. The header narrative is the same as a refine's — per clause, what is added and what stays binding — and the asymmetry is the same: no back-pointer on the parent.

**Refines may target non-decision clauses.** The over-general text isn't always a `Dn` decision — a refine can scope a parent's `§ Consequences` (or another named section) when that's where the statement being narrowed lives: `Refines: ADR-NNNN (§ Consequences — <what>)`. The same rules apply: parent untouched, both consulted.

**Honest-disclosure refines.** When execution falsifies a rule an earlier ADR pre-committed to (a threshold, a protocol, an expected outcome), the deviation lands as a refining ADR whose body discloses all three parts — what was pre-committed, what reality showed, and what changes — never as a silent re-interpretation. The disclosure is the point: a pre-commitment only disciplines future decisions if deviations from it are visibly recorded.

**How the skill handles each:**

- Add a **Refines?** input alongside the Supersedes? input (Inputs, above) — if yes, capture the parent number and the specific decision clauses in `ADR-NNNN (Dn, …)` form.
- In Step 2, fill the `Refines:` field (or the clause-scoped `Supersedes:` field) in the new ADR's header.
- In Step 3, add the child's index row naming its `Refines:`, `Extends:` (or clause-scoped supersession) target. **A refined parent gains no back-pointer and no status change** — it stays `Accepted`, and discoverability comes from the child's header field plus the child's index row. Only a *whole-ADR* supersession flips the parent's index status to `Superseded by ADR-NNNN`; a pure refine (or a clause-scoped supersede) leaves the parent `Accepted`.

**Reviewers must follow the `Refines:` and `Extends:` chains.** When an ADR-conformance check finds an ADR that intersects a diff, it also loads any ADR that names that ADR in a `Refines:`, `Extends:` (or clause-scoped `Supersedes:`) field and applies the child's clauses — an extender can fail a diff the parent passes. A parent read in isolation — without its refiners — yields the pre-narrowing, too-general reading.

