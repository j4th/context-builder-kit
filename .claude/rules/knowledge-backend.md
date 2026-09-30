# Knowledge Backend Patterns

Operational rules for how cascade phases interact with the knowledge backend — a durable, longer-lived reference library that sits alongside (not replacing) the repo's markdown docs and the planning backend. Notion is the v1 reference implementation; the patterns here are written to generalize to other backends (Confluence, Obsidian) when a second one is supported.

The principle:

- **The knowledge backend is the durable reference library, not the cascade's source of truth.** Cascade artifacts (`docs/cbk/*`) always live in the repo. The knowledge backend holds *different* content: pre-cascade research, cross-project decisions, durable runbooks, things that outlive any single project.
- **Read-primary at lower phases.** Cascade phases default to repo + inheritance. The knowledge backend is consulted on demand when richer context than the repo carries is needed.
- **Writes are tiered.** Consultation and scaffold may write routinely when promoting structured context. Lower phases (blueprint, framing, rough-in, `/finish`) write only when HITL explicitly OKs it — never as a side effect of primary work.
- **Brownfield-first, lazy provisioning.** Detect what exists in the operator's workspace before creating anything. Create sub-pages only when an actual write targets them — never as a "set up the recommended structure" pre-step.

The provisioning detail — the workspace shape, the hub and its sub-pages, brownfield detection, lazy provisioning, the Notion specifics, the failure modes and the anti-patterns — lives in `knowledge-backend-reference.md`, which loads only when a cascade skill or command, the ask-gate hook, a cascade artifact or this rule pair is read; every moved section keeps its heading here with a pointer. When the knowledge axis is `none`, both halves are deleted together with the hook and its settings stanza.

## The three surfaces

→ *Moved to* `knowledge-backend-reference.md` § The three surfaces *(path-scoped; see `cbk-conventions.md` § Rule loading and the instruction budget).*

## The hub-as-database-row model

→ *Moved to* `knowledge-backend-reference.md` § The hub-as-database-row model *(path-scoped; see `cbk-conventions.md` § Rule loading and the instruction budget).*

## Hub sub-page convention — recommended vocabulary

→ *Moved to* `knowledge-backend-reference.md` § Hub sub-page convention — recommended vocabulary *(path-scoped; see `cbk-conventions.md` § Rule loading and the instruction budget).*

## Pages vs databases — the rule

→ *Moved to* `knowledge-backend-reference.md` § Pages vs databases — the rule *(path-scoped; see `cbk-conventions.md` § Rule loading and the instruction budget).*

## Wiki pattern + Verification — rot prevention

→ *Moved to* `knowledge-backend-reference.md` § Wiki pattern + Verification — rot prevention *(path-scoped; see `cbk-conventions.md` § Rule loading and the instruction budget).*

## The code-adjacent split — canonical

| Artifact | Lives in | Why |
|---|---|---|
| ADRs | **Repo** (`docs/adr/`) | Versioned, immutable, PR-reviewable; the kit's `adr-new` skill assumes this |
| CLAUDE.md, ARCHITECTURE.md, STANDARDS.md, CONTRIBUTING.md | **Repo** | Claude Code reads them as immediate context; coupling to code is the point |
| `docs/cbk/*` cascade artifacts | **Repo** (source) + optionally **Notion** (read-only sync block) | Append-only audit trail belongs with code; Notion mirror is for stakeholder readability when wanted |
| Architecture diagrams | **Notion** (embedded via Figma / Excalidraw) | Visual artifacts benefit from Notion's rendering; bidirectional links between Notion and repo |
| Decision logs (non-architectural) | **Notion DB** | Cross-functional contribution; non-engineers participate |
| Meeting notes, runbooks, research | **Notion DB** | Outlive any single repo |

**Never**:
- Copy repo docs into Notion. Use sync/embed blocks instead. Manual copies guarantee drift.
- Put ADRs in Notion. Loses version control, PR review, and code-coupled history.
- Make the project hub a top-level sidebar page. Kills cross-project rollups.

## When to read

Default behavior: rely on the repo + inheritance from prior cascade artifacts.

Reach to the knowledge backend only when:

- The operator explicitly designates Notion content to consult (consultation Mode A/B/C from `consultation/references/notion_ingestion.md`)
- The current phase's inheritance step surfaces relevant Notion pages and the operator opts to fetch
- A prior cascade artifact cites a Notion URL the current phase needs to resolve (e.g., `problem_brief.md` listed pages in `## Pre-cascade sources`)

Reading is always opt-in at lower phases. Surface what's available; let the operator decide what's worth pulling.

## When to write

Tiered by phase, default by HITL:

| Phase | Write default | Common reason |
|---|---|---|
| Consultation | Opt-in | Promote companion page from incoming context |
| Scaffold | Opt-in | Establish project hub row in Projects DB |
| Blueprint | Opt-in (rare) | Cross-project strategy companion |
| Framing | Opt-in (rare) | Cross-project meta-issue runbook |
| Rough-in | Never | Out of scope by design |
| `/finish` | Opt-in (rare) | Cross-project learning runbook |

Every write requires explicit HITL approval. No cascade phase writes to the knowledge backend as a side effect of its primary work.

When writing, write **companion** material that *adds to* the repo artifact, not a copy of it — the companion vocabulary of `cbk-conventions.md` § Multi-surface facts: the repo artifact is the immutable source, the page its append-only companion, pointing back and never pointed at:
- Repo holds the structured cascade artifact (immediate context)
- Notion holds longer-form supporting material, decision threads, cross-project links, durable runbooks

The companion always **links back** to the repo artifact by URL. Never mirror cascade artifacts verbatim into Notion — that's drift bait.

## Brownfield detection at scaffold

→ *Moved to* `knowledge-backend-reference.md` § Brownfield detection at scaffold *(path-scoped; see `cbk-conventions.md` § Rule loading and the instruction budget).*

## Lazy provisioning at write-back

→ *Moved to* `knowledge-backend-reference.md` § Lazy provisioning at write-back *(path-scoped; see `cbk-conventions.md` § Rule loading and the instruction budget).*

## HITL announcement discipline

Every read, search, and write to the knowledge backend announces before executing.

**Read** (single page):
```
"About to fetch <page title> from <hub scope>. OK?"
```
Operator can decline per-page.

**Search**:
```
"About to search <hub scope> for <query>. OK?"
```
Operator can refine the query or decline.

**Write** (page create):
```
"About to create a new page <title> under <parent>. Body preview:
 <first 200 chars>. OK?"
```
Operator can edit, decline, or commit.

**Write** (page update):
```
"About to update <page title>. Diff preview: <summary>. OK?"
```

These announcements are non-negotiable. Bypassing them silently — even for "obvious" reads or "trivial" writes — trains the operator to ignore the next ad-hoc surfacing, which is the next failure mode.

**Hook enforcement layer.** Prose alone cannot stop a session where a broad permissions allowlist would auto-approve the write tool. The kit ships `.claude/hooks/require-knowledge-backend-ok.sh` (registered in `settings.json` against the knowledge-backend MCP's mutating tool names — Notion's `create|update|move|duplicate|convert|delete|upload|spawn|send|stop` as the v1 reference, dated 2026-09-21; the matcher is a dated observation, re-verified when the MCP's tool list changes) which returns a deterministic permission "ask" on every matched write: the forced permission prompt is the per-action approval, and read tools stay unmatched so read-primary behavior is unaffected.

## Inheritance discipline

When a cascade phase consumes knowledge-backend content, its inheritance summary records:

- The hub scope or specific URL consulted
- The page title
- A 1-2 line summary of what was extracted
- Quoted content (verbatim) where the phase's logic depends on specific wording

This keeps the chain auditable when later phases or future readers trace why a decision was made. Paraphrased inheritance is the cascade's most common failure mode; quote, don't summarize, when the wording matters.

## Notion MCP convention

→ *Moved to* `knowledge-backend-reference.md` § Notion MCP convention *(path-scoped; see `cbk-conventions.md` § Rule loading and the instruction budget).*

## Notion 3.3+ awareness (Feb 2026)

→ *Moved to* `knowledge-backend-reference.md` § Notion 3.3+ awareness (Feb 2026) *(path-scoped; see `cbk-conventions.md` § Rule loading and the instruction budget).*

## Failure modes

→ *Moved to* `knowledge-backend-reference.md` § Failure modes *(path-scoped; see `cbk-conventions.md` § Rule loading and the instruction budget).*

## What this doc deliberately doesn't cover

→ *Moved to* `knowledge-backend-reference.md` § What this doc deliberately doesn't cover *(path-scoped; see `cbk-conventions.md` § Rule loading and the instruction budget).*

## Anti-patterns

→ *Moved to* `knowledge-backend-reference.md` § Anti-patterns *(path-scoped; see `cbk-conventions.md` § Rule loading and the instruction budget).*

## When to update this file

→ *Moved to* `knowledge-backend-reference.md` § When to update this file *(path-scoped; see `cbk-conventions.md` § Rule loading and the instruction budget).*
