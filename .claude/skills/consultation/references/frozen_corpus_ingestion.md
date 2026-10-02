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

- **A hook and a CI job on the corpus pattern**, each with a block message that names the errata companion as the place a correction goes. The hook is a guard over the corpus path that sources `.claude/hooks/lib/resolve-path.sh` in its root-scoped mode — the corpus under the hook's own checkout, the project dir's and a linked worktree of either, each path resolved lexically and physically (`cbk-conventions-reference.md` § Hook authoring, on sourced helpers). The CI job extends (or copies) the kit's ADR-immutability job with that job's parse-nothing body — a `:(glob)` pathspec, `--no-renames`, a three-dot diff from the merge base, `--diff-filter=a` only if additions pass, any output failing and any git error failing — never an awk match on parsed paths, which reads a quoted non-ASCII name or a spaced one as "no change".
- **The CI job's closures.** The hook sees only the agent's edit tools; the CI job is the backstop for a Bash write, a hand edit or a case-insensitive filesystem, and a job that compares the corpus with its base can be fooled more ways than a hook. Two targets red-teamed their corpus jobs. Both implement every closure below, and each is a fixture case in at least one of them — except clearing git's environment and ignoring grafts, which neither fixture drives yet. The kit ships no corpus job; this list is what the two measured:
  - the base resolves from fully qualified refs (`refs/remotes/origin/<default>`, then `refs/heads/<default>`) — a tag or local branch named `origin/main` would shadow the bare name, and `actions/checkout` with `fetch-depth: 0` fetches "all history for all branches and tags" (its README at the kit's pinned SHA, read 2026-09-30); no base fails, never skips;
  - on the default branch, or a branch with no commits of its own, the merge base is HEAD, so the last commit is compared with its parent;
  - `GIT_DIR`, `GIT_WORK_TREE`, `GIT_INDEX_FILE` and their kin are cleared, and replace refs and grafts ignored;
  - nothing is sourced from the tree under check — a PR-supplied helper could define a `git` function that silences every diff;
  - the commits, the index and the working tree are each compared with the base, so an edit staged or committed with the tree put back is caught;
  - the bytes on disk are hashed with `--no-filters` against the base blob — git's own diffs trust the index (assume-unchanged, skip-worktree) and apply checkout conversions (`core.autocrlf`, a `.gitattributes` eol, encoding or filter a PR can commit);
  - a path's type is compared before its content, so a symlink standing in for a file is a change even when what it reaches is identical; a failed `readlink` stops the job;
  - every path list is read NUL-separated (`-z`) — a quoted non-ASCII name otherwise reads as a missing file;
  - every git call fails the job on error; an error is never read as "unchanged".

  Whether an added file passes (a newly frozen document added by hand in a reviewed commit) is the target's call: of the two targets, one allows additions and the other freezes the directory whole.
- **`.gitattributes`**: `<corpus path>/** linguist-documentation=false` so the corpus counts as content, not vendored prose, in the host's language stats and diffs.
- **Editor settings**: trailing-whitespace trim and final-newline insertion unset for the corpus path (a byte-preserving read is the point of a freeze).
- **A formatter skip entry** for the corpus path in whatever the project's docs formatter reads.

Scaffold's brownfield audit and backend selection read the designated path from `## Pre-cascade sources`; the verification matrix of the scaffold skill's `references/bootstrap_checklist_template.md` carries one row per item above, so no item is ticked off with the others.

## What to record in the brief

- `## Pre-cascade sources`: the corpus path; one bullet per file consulted with its one-line contribution; the passages quoted where wording is inherited; the errata companion's path if one was created.
- `## Handoff notes for later phases`: what scaffold must land and register; what blueprint may promote (with the `Promotes:` form); what framing and rough-in should read before drafting.
