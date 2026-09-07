# Corrections register

A register of **claims** inside accepted decision records that later proved wrong, stale, orphaned or miscomputed — and the correct reading. It exists because ADRs are immutable ([ADR-0000](0000-record-architecture-decisions.md)): a *decision* is revised by a superseding, refining or extending ADR, but a *claim* inside one — a cited figure, an attributed source, a formula, a fact about a dependency — is not a decision, and re-issuing a whole ADR to fix a citation would bury the decision history under errata. This file is the append-only companion to the immutable source; the source never points here, the entry points back (`cbk-conventions.md` § Multi-surface facts).

## What it is not

- **Not a place to revise a decision.** If the correct reading changes what the ADR decided, the consequence line says so and a refining or superseding ADR is filed; the entry here records only the claim.
- **Not a changelog of the ADR set** — the index in `README.md` is that.
- **Not a discussion surface.** An entry states the claim, the correct reading and the evidence; disagreement goes to a PR review or an ADR.

## Mutation discipline

Append-only. Entries are dated and never edited after they land — a correction to a correction is a new entry naming the old one. An entry's *evidence* may itself go stale; when its meaning changes, annotate under it (dated), never rewrite it. The immutability hook (`.claude/hooks/protect-immutable-adrs.sh`) leaves this file editable by design.

## The four genres

| Genre | What it is | Typical evidence |
|---|---|---|
| **Wrong when written** | The claim was false at the time the ADR was accepted — a misread source, a wrong figure | The primary source, quoted |
| **Right then stale** | The claim was true at acceptance and the world moved — a dependency's behaviour, a platform limit, a price | A dated re-check against the live source |
| **Orphaned attribution** | The claim is attributed to a source that does not say it, or no longer exists | The source as it reads today, or its absence |
| **Defective formula** | A calculation, threshold or derivation in the ADR does not produce what it claims | A reproduction with the inputs and the corrected result |

## Entry shape

```markdown
### C-NNN — <the claim in one line> · <genre> · <YYYY-MM-DD>

- **Where:** ADR-NNNN § <section> — the sentence, quoted verbatim
- **Claim as written:** "…"
- **Correct reading:** …
- **Evidence:** <class — primary source | reproduction | measurement | dated observation> — <citation or command>
- **Consequence:** none for the decision · the decision stands with a scoped reading · escalate — a refining or superseding ADR is warranted (name it once filed)
- **Annotations:** _(dated; appended only when the evidence's meaning goes stale)_
```

## How to add an entry

1. Confirm the claim is not a decision — if fixing it changes what was decided, file an ADR instead and record only the claim here.
2. Take the next `C-` number; numbers are append-only.
3. Quote the sentence verbatim, with its ADR and section, so the entry is findable from the ADR without the ADR pointing here.
4. Class the evidence and cite it — a corrected claim with no evidence is a new unsupported claim.
5. Decide the consequence line honestly; *escalate* is a valid outcome.
6. Land the entry in the PR that found the defect, not a separate one.
7. Reviewers consult this register before flagging: a claim already recorded here is cited, never restated as a finding.

## Entries

_(none yet)_
