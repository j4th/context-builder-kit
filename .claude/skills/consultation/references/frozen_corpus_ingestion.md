# Frozen-corpus ingestion

Operational reference for consultation's incoming-context flow when the operator points at a **directory of pre-existing planning material on disk** — design notes, a prior team's decision log, a research corpus, an exported wiki — rather than Notion pages (`references/notion_ingestion.md` covers that sibling flow). Runs before the four-step interview, like the Notion flow.

## When to run this

Trigger when the operator names a path ("everything under `planning/`", "the docs in `~/notes/<project>`") or drops a directory of files as the starting material. A handful of pasted paragraphs is Mode D of the Notion flow, not this.

## The freeze discipline

The corpus is **frozen** the moment consultation reads it: a source of truth that is read in full and never edited by any cascade phase.

- **Read in full.** Every file, not a sample; a corpus that is too large to read in full is split by the operator into the part that governs this cascade and the part that does not, and only the first is designated.
- **Cite verbatim.** The brief's `## Pre-cascade sources` names the corpus path and lists each file that informed a section, with the quoted passage where the brief's wording depends on it. Paraphrased inheritance is the cascade's most common failure mode.
- **Never edit the source.** A defect in the corpus — a wrong figure, a superseded claim, a broken link — is recorded in the errata companion, never fixed in place.

## The errata companion

`<corpus path>/<slug>-errata.md` is created **lazily**, at the first defect, never as setup. It is append-only and dated; each entry names the file and the passage, quotes it, states the correct reading and the evidence, and opens with the line *amends; never edits*. The companion points at the corpus; the corpus never points at the companion (`cbk-conventions.md` § Multi-surface facts). The shape is the ADR corrections register's (`docs/adr/corrections.md` in a scaffolded project), with the corpus file in place of the ADR.

## `Promotes:` — a decision lifted from the corpus

When a later phase turns a decision the corpus already made into an ADR, the ADR's header carries `Promotes: <corpus path>/<file> § <heading>` — the corpus is the provenance, the ADR the binding form. The ADR restates the decision in its own words and quotes the passage it promotes; the corpus file is not edited to point at the ADR.

## The enforcement set scaffold registers

Consultation records the designated path in the brief; **scaffold** lands the corpus in the repo (or records its external location) and registers the guards, in one commit, when the corpus lives in the tree:

- **A hook and a CI job on the corpus pattern** — the immutability hook and the ADR-immutability CI job extended (or copied) to match the corpus path, with a block message that names the errata companion as the place a correction goes.
- **`.gitattributes`**: `<corpus path>/** linguist-documentation=false` so the corpus counts as content, not vendored prose, in the host's language stats and diffs.
- **Editor settings**: trailing-whitespace trim and final-newline insertion unset for the corpus path (a byte-preserving read is the point of a freeze).
- **A formatter skip entry** for the corpus path in whatever the project's docs formatter reads.

Scaffold's brownfield audit and backend selection read the designated path from `## Pre-cascade sources`; the bootstrap checklist carries the four items as one row.

## What to record in the brief

- `## Pre-cascade sources`: the corpus path; one bullet per file consulted with its one-line contribution; the passages quoted where wording is inherited; the errata companion's path if one was created.
- `## Handoff notes for later phases`: what scaffold must land and register; what blueprint may promote (with the `Promotes:` form); what framing and rough-in should read before drafting.
