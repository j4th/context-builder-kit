# Cascade-events index — template for `docs/cbk/README.md`

Scaffold creates `docs/cbk/README.md` from this template **beside `problem_brief.md` and `scaffold.md`, in the same commit**, seeded with those two rows. Blueprint, framing and rough-in **append** — a row in `## Index` and a note in `## Phase notes`, in the commit that lands their artifact — and the only in-place edit anyone makes is a row's Status cell (`cbk-conventions.md` § Mutation discipline). Framing creates the file from this template only as a brownfield fallback, when the project predates scaffold's provisioning of it.

--- BEGIN TEMPLATE ---
# Cascade events

Chronological index of this project's cascade artifacts (`.claude/rules/cbk-conventions.md` § Cascade artifact layout). **Append-only**: new rows go at the bottom, newest last; the one in-place edit is a row's Status cell (Active → Completed · Superseded by frame-NN · Abandoned). Every phase that lands an artifact appends its row *and* its phase note in the same commit.

## Index

| # | Date | Phase | Artifact | Status |
|---|---|---|---|---|
| 1 | <YYYY-MM-DD> | consultation | [problem_brief.md](problem_brief.md) | Approved |
| 2 | <YYYY-MM-DD> | scaffold | [scaffold.md](scaffold.md) | Completed |

## Phase notes

One note per row, newest last. A note records the **execution facts** a later reader cannot recover from the artifact itself: what was created outside the repo (issue numbers, board, hub — by id or URL), what departed from the default and why (the discipline that justified it, never the skill version), the research provenance where there was any (agent counts, live probes, the grounding corpus), and **the next runnable command**.

### 1 — consultation, <YYYY-MM-DD>

- Sources ingested: <none | the `## Pre-cascade sources` list, with any frozen corpus path>
- Next: `scaffold`

### 2 — scaffold, <YYYY-MM-DD>

- Planning backend: <axis value> — <what was provisioned, by id or URL>
- Knowledge backend: <axis value> — <hub URL, or "none">
- Bootstrap checklist: <path> — <N> manual steps open
- Next: `blueprint`

## Non-cascade surfaces

Freely mutable status surfaces that live beside the cascade events and are **not** events (`cbk-conventions.md` § Mutation discipline carves them out):

| Surface | Path | Who writes it |
|---|---|---|
| Roadmap | `ROADMAP.md` | blueprint seeds it; framing adds rows; rough-in and `/finish` flip status |
| Bootstrap checklist | <path> | scaffold writes it; the operator ticks it |
| Issue records *(in-repo-markdown planning only)* | `issues/` | `/intake` and `/enrich` write them; the operator flips `status:` |
