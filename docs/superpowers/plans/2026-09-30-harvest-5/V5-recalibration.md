# Harvest 5 — V5: Recalibration and the budget

**Scope.** This cluster recalibrates the orchestration rule pair, `workflows.md`, `simplification.md` and the floor's Agent-tool sentence for Opus 5.5, Sonnet 5.5 and Claude Code 2.1.284+ (D49), and pays for that growth by splitting `knowledge-backend.md` into an always-loaded contract and a path-scoped reference (D59, D50). It closes the rule items of #69 and its comment corrections (trace rows `#69/body/T1`–`T15`, `F1`–`F10`, `Fq`, `S1`–`S11`, `#69/c5859756889/3-C1`–`3-C5`, `#69/c5881157875/1a`–`5`, `#69/c5892402564/Q1`–`Q2`), all of #65, #74 item 3, #68 item 3 with its count sweep, the rule half of #58 R9, the critic rows `critic/10`, `critic/16`, `critic/17`, `critic/18`, and the review findings `review/portability/38` and `review/claude-code/57`. It lands the parts of other clusters' items that fall in files V5 owns: #67 item 3 and its comments (from V4), the finish-ab N-arm and H1–H4 rule text and the price-step rows (from V6), #72 item 4's read-only bullet (from V7), and the knowledge-backend pointer of #66 (from V9). It consumes V1's runner, sentinels and budget `WARN` line; V2's `hook-guards-fixture.sh`, which skips a knowledge-backend hook the axis deleted (Review Focus 3); V3's exec-form hook registrations; and V4's review-workflow templates, which the review-bot paragraph in V5.3 describes (D47). Probe P2 (does a workflow agent have an Agent tool) is Step 0 of V5.10 and runs in the main session.

## Conventions for this cluster

- **Owned files.** `.claude/rules/orchestration.md`, `orchestration-reference.md`, `knowledge-backend.md` and the new `knowledge-backend-reference.md` are edited by V5 alone. `workflows.md`, `simplification.md` § Plugin, `tooling.md`'s built-in-tools row, the rough-in and framing grounding sections, `cbk-conventions.md` § Rule loading, the bootstrap checklist's knowledge-backend row and `pr-review.md`'s Agent-tool sentence are V5's regions (master § Ownership map). Every edit below is an exact-string replacement whose old text was matched exactly once on a copy of `643f7ff` with the earlier V5 tasks applied. If an old string is missing when a task runs, stop and reconcile; never guess.
- **Checks.** Each task's check goes on the line(s) immediately before `echo "verification: kit sub-block complete"` in `.claude/rules/cbk-conventions-reference.md`, in task order, so the block grows in the order the tasks land. V5.13 also adds one line before `  echo "verification: project sub-block complete"`. Checks on `orchestration.md`, `orchestration-reference.md` and `knowledge-backend*.md` are guarded with `[ ! -f … ] ||`, because a target may delete the template or its knowledge axis.
- **Dry run.** Every task was run on `cp -a` copies of the kit at `643f7ff`, in order: the check was added, the runner went red with the line quoted in Step 2, the change was applied, and the runner went green with both sentinels. The byte figures in each **Budget** line come from that run; once V1–V4 have landed the absolute totals differ, and only the deltas carry over.
- **Platform facts.** Every quotation a task writes was fetched raw on 2026-09-30 (a docs page's `.md` form where the site serves one) and matched after straightening typographic quotes and stripping markdown links or HTML tags. Each task re-fetches its own quotations with `qf` on the day it lands. Paste this once into the shell the tasks run in:

```bash
qf() { # qf <url> <quote>: fetch raw, straighten typographic quotes, strip markdown links or HTML tags, collapse whitespace, grep -F
  local page q
  page=$(curl -sL --max-time 60 -A 'Mozilla/5.0' "$1" | python3 -c '
import sys, re, html
s = sys.stdin.read()
if "<html" in s[:3000].lower():
    s = re.sub(r"<script.*?</script>|<style.*?</style>", " ", s, flags=re.S)
    variants = [html.unescape(re.sub(r"<[^>]+>", "", s)), html.unescape(re.sub(r"<[^>]+>", " ", s))]
else:
    variants = [re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", s)]
for v in variants:
    v = v.translate({0x2019: 39, 0x2018: 39, 0x201c: 34, 0x201d: 34, 0xa0: 32})
    print(re.sub(r"\s+", " ", v))')
  q=$(printf '%s' "$2" | tr -s ' \n' '  ')
  if grep -qF -- "$q" <<<"$page"; then echo "OK   $1"; else echo "MISS $1 :: $2"; return 1; fi
}
```

- **Sanitization.** No task writes the private target's name, paths, keys, shas or stack into any file, and no task writes a public sibling's name into `.claude/`. The 2026-09-25 replay (V5.9) is "a sister project" in kit text, cited as `context-builder-kit#69`; its figures were read from `j4th/you-are-hear`'s committed `.claude/workflows/finish-ab/2026-09-25-replay-78/result.md` on 2026-09-30. Exercised wording was taken from the private target's merged rule files and re-authored onto the kit's text; its operator settings, reviewer rosters, server lists, ticket citations and project posture are not carried.
- **No hooks.** No V5 task edits a hook, so no task has a `bash -n` step.

## Budget ledger (D50, D59)

Measured on a copy of `643f7ff` with V5.1–V5.14 applied and nothing else:

| Always-loaded rule | At `643f7ff` | After V5 | Change |
|---|---|---|---|
| `cbk-conventions.md` | 30,058 | 30,181 | +123 |
| `knowledge-backend.md` | 20,336 | 9,513 | −10,823 |
| `orchestration.md` | 18,562 | 25,012 | +6,450 |
| `pr-review.md` | 28,281 | 28,522 | +241 |
| `simplification.md` | 3,213 | 3,721 | +508 |
| `tooling.md` | 12,416 | 12,507 | +91 |
| `workflows.md` | 17,762 | 19,813 | +2,051 |
| **Total** | **130,628** | **129,269** | **−1,359** |

The path-scoped halves grow instead: `orchestration-reference.md` 20,791 → 40,963 bytes, and the new `knowledge-backend-reference.md` is 15,961 bytes. V5 leaves **1,359 bytes** of headroom under the D59 target of 130,628 for the always-loaded growth of V2 (`cbk-conventions.md` § Mutation discipline), V3 and V4 (`tooling.md`), V7 (`pr-review.md`) and V9 (`cbk-conventions.md`). Task F1 measures the branch total.

### Task V5.1: Split `knowledge-backend.md` into an always-loaded contract and a path-scoped reference (review/claude-code/57; Review Focus 3; D59, D50)

**Files:**
- Create: `.claude/rules/knowledge-backend-reference.md`
- Modify: `.claude/rules/knowledge-backend.md` (whole-file rewrite: the moved sections become pointer headings)
- Modify: `.claude/rules/cbk-conventions.md` (§ Rule loading and the instruction budget, two bullets)
- Modify: `.claude/skills/scaffold/references/bootstrap_checklist_template.md` (§ 4. Rule-file disposition, the `knowledge-backend.md` row)
- Modify: `.claude/rules/workflows.md` (§ Index of `.claude/rules/*.md`, the `*-reference.md` row)
- Modify: `.claude/rules/cbk-conventions-reference.md` (§ Verification, three check lines at the kit sentinel)

**Interfaces:**
- Consumes: V1's kit sentinel and budget line; V3's exec-form hook registrations (the dry run removes the knowledge-backend stanza by `command`/`args`); V2's `hook-guards-fixture.sh`, which skips a knowledge-backend hook the axis deleted, reading the hook's name from the registry (Review Focus 3).
- Produces: `.claude/rules/knowledge-backend-reference.md` (frontmatter `paths:` `.claude/rules/knowledge-backend*.md`, `.claude/skills/**`, `.claude/commands/**`, `.claude/hooks/require-knowledge-backend-ok.sh`, `docs/cbk/**`). Thirteen pointer headings in `knowledge-backend.md`, each `→ *Moved to* \`knowledge-backend-reference.md\` § <heading> *(path-scoped; …)*`. The generic pointer check (every `*-reference.md` has its contract; every `Moved to` pointer sits under its own heading and resolves) — V5.5's rename relies on it. The five sections that stay in the contract, verbatim: § The code-adjacent split — canonical, § When to read, § When to write, § HITL announcement discipline, § Inheritance discipline. V10 names the new file in `README.md` and `CLAUDE.md` (handed).

**Budget:** always-loaded −10,622 bytes (measured on a copy of `643f7ff` with V5.1 applied: 120,006).

The moved sections are copied **byte-for-byte** from `git show 643f7ff:.claude/rules/knowledge-backend.md`; nothing inside them changes in this commit (V5.2 edits them). Step 4 proves it.

- [ ] **Step 0: Confirm the file is still the one this task splits.** Run: `git diff --quiet 643f7ff -- .claude/rules/knowledge-backend.md && echo unchanged`. Expected: `unchanged`. If it prints nothing, another commit edited the file: stop and reconcile the moved text before overwriting it.

- [ ] **Step 1: Write the failing block check.** In `.claude/rules/cbk-conventions-reference.md`, insert these lines immediately before the line `echo "verification: kit sub-block complete"`:

````bash
# Contract + reference pairs (cbk-conventions.md § Rule loading and the instruction budget): every reference half has its
# contract; the knowledge-backend contract ships with its reference half (a knowledge axis of none deletes both, D59); and
# every "Moved to" pointer sits under a heading of its own name that its reference half carries, so a heading renamed in
# one half only is red (context-builder-kit#65). A pair with no pointer is red, never a vacuous pass.
for r in .claude/rules/*-reference.md; do [ -f "${r%-reference.md}.md" ] || { echo "$r ships without its contract ${r%-reference.md}.md"; exit 1; }; done
[ ! -f .claude/rules/knowledge-backend.md ] || [ -f .claude/rules/knowledge-backend-reference.md ] || { echo "knowledge-backend.md ships without knowledge-backend-reference.md — the rule is a contract + reference pair, deleted together (D59)"; exit 1; }
for c in .claude/rules/*.md; do case "$c" in *-reference.md) continue;; esac; r="${c%.md}-reference.md"; [ -f "$r" ] || continue; p=$(awk '/^## /{h=substr($0,4)} /^→ \*Moved to\* `/{t=$0; sub(/^→ \*Moved to\* `[^`]*` § /,"",t); sub(/ \*\(path-scoped.*$/,"",t); print (t==h ? "ok" : "under " h) "\t" t}' "$c"); [ -n "$p" ] || { echo "$c carries no Moved-to pointer into $r"; exit 1; }; while IFS=$'\t' read -r st t; do [ "$st" = ok ] || { echo "$c: the pointer to § $t sits $st"; exit 1; }; grep -qxF "## $t" "$r" || { echo "$c points at § $t, which $r does not carry"; exit 1; }; done <<<"$p"; done
````

- [ ] **Step 2: Run it against the unfixed files.** Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`. Expected, red. The last two lines are:

````text
knowledge-backend.md ships without knowledge-backend-reference.md — the rule is a contract + reference pair, deleted together (D59)
verification: block exited 1
exit=1
````

Record the first of those lines in the PR body's red-first table.

- [ ] **Step 3: Make the change.**

Create `.claude/rules/knowledge-backend-reference.md` with exactly this content (it ends with a single newline):

````markdown
---
paths:
  - ".claude/rules/knowledge-backend*.md"
  - ".claude/skills/**"
  - ".claude/commands/**"
  - ".claude/hooks/require-knowledge-backend-ok.sh"
  - "docs/cbk/**"
---

# Knowledge Backend Patterns — the reference half

> **Path-scoped.** Loads when a cascade skill or command, the knowledge-backend ask-gate hook, a cascade artifact, or this rule pair is read — the moments a phase provisions, reads or writes the knowledge backend. `knowledge-backend.md` (always loaded) keeps the operative contract — when to read, when to write, the announcement discipline, inheritance — and a pointer heading for every section here. Sections were moved verbatim on 2026-09-30. See `cbk-conventions.md` § Rule loading and the instruction budget. When the knowledge axis is `none`, this file is deleted together with `knowledge-backend.md`, the hook and its settings stanza.

## The three surfaces

| Surface | Role | Where it lives | Why |
|---|---|---|---|
| **Code/repo** | Source of truth for code, immediate AI/dev context | git (always GitHub or other git host) | Versioned with code; Claude Code reads it as immediate context; can't be replaced by any external surface |
| **Planning backend** | Live work-tracking with status, parent/child, queryable state | GitHub Issues, Linear, or none (in-repo markdown) | Cascade hierarchy needs statused/queryable representation; markdown alone can't do that for active work |
| **Knowledge backend** | Durable longer-lived reference library | Notion (v1); future: Confluence, Obsidian | Holds context that *predates* the project or *spans* multiple repos |

The repo + core markdown docs are the **constant** — always present, always the immediate AI/dev context. Planning and knowledge are **independent axes** the operator picks separately.

Files that always live in the repo (never in the knowledge backend):

- `CLAUDE.md`, `ARCHITECTURE.md`, `STANDARDS.md`, `CONTRIBUTING.md`
- `docs/adr/*.md` (immutable architecture decisions)
- `docs/cbk/*.md` (cascade artifacts: problem_brief, blueprint, frame-NN, README index)
- All source code, tests, configs

Knowledge-backend writes are *companions* to these, never substitutes.

## The hub-as-database-row model

When knowledge backend is Notion, the project hub is a **row in a Projects database inside an Engineering teamspace**, not a top-level sidebar page. Three reasons:

- Enables roadmap and status views across projects
- Prevents sidebar bloat as the team grows
- Cross-project rollups (which projects are active, blocked, use vendor X) become DB queries

Recommended workspace shape:

```
Workspace
├── General teamspace          (company-wide; outside cascade scope)
└── Engineering teamspace
    ├── Engineering Wiki        (cross-project: standards, on-call,
    │                            vendor evaluations, shared runbooks)
    └── Projects                (database)
        └── [Project hub row]   ← what the kit provisions / links to
```

**Cross-project artifacts** (runbooks spanning repos, vendor evaluations, shared ADRs affecting multiple projects) live in the Engineering Wiki one level up, **never** inside a single project's hub. Forcing cross-project content into a single project's hub is the most common organizational drift.

If the operator's workspace doesn't have an Engineering teamspace or Projects database, surface what's missing and let them decide whether to create the recommended structure or use a flatter alternative. Respect existing workspace conventions; never restructure without permission.

## Hub sub-page convention — recommended vocabulary

The eight sub-pages below describe the **recommended vocabulary** — what the kit knows how to create and reference. The kit creates each one only when:

(a) a write actually targets it, AND
(b) the operator approves creation at the moment of that write

Scaffold provisions **only the hub row itself**. Everything else is lazy. The operator's existing workspace may already have some sub-pages under different names — surface those at brownfield detection and let the operator map them or accept the kit's naming.

| Sub-page | Type | Created when |
|---|---|---|
| Start here / Onboarding | Page | Operator opts in at scaffold |
| Decision Log | Database (Table) | First non-ADR decision write |
| Meeting Notes | Database (Table) | Operator opts in (no cascade phase auto-creates) |
| Research & Reference | Database (Gallery) | First consultation companion-page or research promotion |
| Runbooks & Playbooks | Database (Table) | First framing cross-project meta-issue or `/finish` learning promotion |
| Cascade Artifacts (mirror) | Page with sync blocks | Operator opts in at scaffold or any later phase |
| People & Context | Page | Operator opts in (no cascade phase auto-creates) |
| Archive | Page | First archive operation |

## Pages vs databases — the rule

**Database** when:
- More than ~5 instances of the same shape are likely, AND
- You want to filter, sort, or query

**Free-form page** when:
- Singleton or narrative content
- No need to query across instances

The cascade's planning backend (GitHub Issues / Linear) covers Projects + Tasks. Notion's job is to add Meetings + Decisions + Research + Runbooks as databases, related to the project via Notion's Relation property.

## Wiki pattern + Verification — rot prevention

Every database-backed page must have:

- **Owner property** — one person, not "the team"
- **Verification property with expiry** — 90 / 180 / 365 days based on volatility:
  - Runbooks & Playbooks: 90 days (operational accuracy decays fast)
  - Decision Log: 180 days (decisions decay slower but context shifts)
  - Research & Reference: 365 days (long-tail reference; verify annually)

Unverified pages are how Notion becomes a graveyard. The kit's hub provisioning sets these properties up when it creates the relevant DB; ongoing maintenance is the operator's responsibility.

If the operator's existing DB doesn't have these properties, surface the gap and offer to extend the schema — don't force it. Workspace conventions can deviate; the rot risk is the operator's call to manage.

## Brownfield detection at scaffold

When scaffold's backend selection picks knowledge backend = Notion, run **read-only** detection via the Notion MCP before any write:

```
Detect at scaffold time:
  - Engineering teamspace exists? (or General teamspace if no
    Engineering split)
  - Projects database exists in that teamspace? What properties does
    it have (Status, Owner, Tags, etc.)?
  - Engineering Wiki (cross-project) exists? Where?
  - Project hub matching this project's slug already in Projects DB?

Surface findings to operator:
  "Found: Engineering teamspace + Projects DB (with Status, Owner,
   Tags). No existing project named '<slug>' in Projects DB. No
   Engineering Wiki found.

   I can:
   (a) Create a new row in Projects DB for this project — designate
       as hub
   (b) Designate an existing page as the hub (paste URL)
   (c) Skip Notion provisioning entirely; wire up manually later"
```

Detection is read-only. No writes happen during detection. If MCP isn't connected or detection fails, surface honestly and fall back to "designate an existing URL" or "skip."

**What scaffold will create when given permission**: the hub row in Projects DB (or designation of an existing page). **Nothing else.** Sub-pages are NOT pre-created.

**What scaffold will not create unprompted**: Engineering teamspace, Projects DB, Engineering Wiki, or any of the eight sub-pages. If the operator's workspace is missing the Projects DB shape entirely, surface the gap and ask whether to create the recommended structure or adapt to a flatter hierarchy. The kit warns about rollup limitations but respects the choice.

## Lazy provisioning at write-back

When a later phase writes to Notion (consultation companion, blueprint strategy companion, framing meta-issue runbook, `/finish` learning runbook), the HITL gate has two layers:

```
Layer 1: "Promote this <content> to a Notion <destination type>?"
         → operator: yes / no / skip / later
         (default: SKIP)

Layer 2 (only if Layer 1 = yes):
  "Destination: <DB name> under <hub>. That database doesn't exist
   yet. Create it now (one-time), or pick a different destination?"
   → operator: create / pick destination / cancel write
```

The destination DB only materializes when a write actually lands there. If the operator writes a single decision log entry, only the Decision Log DB exists in Notion at that point — not the other seven sub-pages.

The eight-sub-page convention above is the **vocabulary the kit uses when offering destinations**, not the structure it pre-builds. Operators with existing workspaces often have their own DB names (e.g., "ADRs" instead of "Decision Log"). Lazy creation surfaces the mismatch at the moment it matters; operator can map their DB instead of creating a duplicate.

## Notion MCP convention

**Recommended MCP server**: Notion's official MCP (`notion.com/help/notion-mcp`).

The kit assumes this MCP is configured when knowledge backend = Notion. If not configured, surface honestly at consultation/scaffold and either:

- Walk the operator through MCP setup (per Notion's docs)
- Fall back to paste-mode operation (consultation only — lower phases require MCP for opt-in fetches)

**Why standardize**: Notion's official MCP is the reference implementation as of the v1 of this kit. It supports both read and write; integrates cleanly with Claude Code. Alternative Notion MCPs work, but the kit's recommended patterns reference behaviors that may differ. Note alternatives in the project's `cbk-conventions.md`.

## Notion 3.3+ awareness (Feb 2026)

Notion 3.3 introduced Custom Agents — agents that run 24/7 against workspace context. Implication for the kit: pages provisioned by the kit (and any companions later phases promote) should have:

- Clear, structured titles (no jargon-heavy or session-specific phrasing)
- Owner + Verification properties (already required by the Wiki pattern above)
- Explicit metadata on what the page is *for* (in the first paragraph, not just implied by location)

These properties were already load-bearing for the Wiki rot-prevention discipline; calling out the agentic dimension so future updates don't drift away from them.

## Failure modes

| Failure | Surface |
|---|---|
| No Notion MCP configured | "Notion MCP not detected. Want to set it up [link to Notion docs] or proceed without knowledge backend?" |
| MCP fetch fails | "Couldn't reach `<page>`. Retry, skip, or paste content directly?" |
| MCP write fails on permission | "Notion integration not shared with `<page>`. Share it from Notion settings [remediation steps], then I'll retry." |
| Notion page accessed by cascade was deleted/moved | "`<URL>` returns 404. Update `cbk-conventions.md` with the new URL, or designate a replacement?" |
| Operator-pasted content too large for context | "Pasted content is `<N>` tokens — summarize before continuing or proceed with full content?" |
| Brownfield detection finds non-canonical structure (e.g., no Engineering teamspace) | "Found: `<structure>`. Recommended structure is `<X>`. Adopt recommended, adapt to existing, or skip Notion provisioning?" |

Surface every failure with a concrete next action. Don't fail silently; don't retry blindly.

## What this doc deliberately doesn't cover

- **Specific Notion marketplace templates** — templates are starting points; the kit's hub structure IS the recommended template
- **Notion pricing tiers / plan-specific features** — operator's concern, not the kit's
- **Cross-knowledge-backend portability** (Confluence, Obsidian, etc.) — design once a second knowledge backend is actually supported, not before
- **Automated hub-page provisioning beyond the hub row** — sub-pages are lazy-provisioned only
- **Notion-side organization rules** — operator's call; the kit only needs the hub URL recorded in `cbk-conventions.md`
- **Bidirectional sync for cascade artifacts** — explicitly out of scope. Sync blocks are one-way (repo → Notion). Drift risk is the reason.

## Anti-patterns

1. **Database proliferation** — start with the four databases (Decisions, Meetings, Research, Runbooks); add a fifth only when an existing one has >50 rows AND a clear axis of separation. Most teams need 2-3 active databases, not 8.
2. **No Verification property** — every DB-backed page needs Owner + expiry, or it rots. Unverified pages are graveyards.
3. **Top-level project pages instead of DB rows** — kills cross-project rollups; bloats the sidebar; locks the team into a structure that doesn't scale beyond ~5 projects.
4. **Duplicating repo docs into Notion** — use sync/embed blocks. Manual copies guarantee drift. Single source of truth still applies; Notion just provides a different *view*.
5. **ADRs in Notion** — loses version control, PR review, code-coupled history, and immutability enforcement (the repo's CI lint can't reach Notion).
6. **Copying a marketplace template verbatim** — templates are starting points; the kit's structure IS the recommended default. Marketplace templates were designed for different team shapes and often include surface area the cascade doesn't use.
7. **No Archive page** — deletion is one-way; archive is cheap. Superseded research and abandoned approaches lose context when deleted.
8. **Skipping General teamspace** — non-engineers can't find anything; cross-team context (mission, handbook, company-wide decisions) doesn't belong in Engineering.
9. **Eager provisioning of all sub-pages at scaffold** — clutters the workspace with empty containers; doesn't respect existing conventions; creates abandonment-rot when projects wind down. Lazy creation per write is the discipline.

## When to update this file

This rules file is load-bearing the moment any cascade phase reads from or writes to the knowledge backend. Update it when:

- A new write pattern emerges that should be HITL-gated (and isn't yet) — add a row to § When to write
- A new failure mode recurs that should be surfaced consistently — add a row to § Failure modes
- A new anti-pattern surfaces from real cascade runs — add to § Anti-patterns
- A second knowledge backend is supported (Confluence, Obsidian) — generalize the Notion-specific sections or fork into per-backend operational notes
- A specific Notion-MCP behavior turns out to need calibration (search relevance, write idempotence) — add to § Notion MCP convention

The principle (knowledge backend as durable reference library, read-primary at lower phases, write-tiered with HITL) is stable. The operational specifics evolve with usage.
````

Overwrite `.claude/rules/knowledge-backend.md` with exactly this content (it ends with a single newline):

````markdown
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
````

1. In `.claude/rules/cbk-conventions.md`, replace

````text
- **Split into an always-loaded contract and a path-scoped reference** — `cbk-conventions.md` / `cbk-conventions-reference.md`, `orchestration.md` / `orchestration-reference.md`, `pr-review.md` / `pr-review-reference.md`. Every moved section keeps its heading in the contract with a one-line pointer, so `file § section` citations resolve unchanged.
- **Always loaded, on purpose** — `workflows.md` (a portable rule), `simplification.md`, `knowledge-backend.md` (deleted together with its hook and settings stanza when the knowledge axis is `none`), and the templates
````

   with

````text
- **Split into an always-loaded contract and a path-scoped reference** — `cbk-conventions.md` / `cbk-conventions-reference.md`, `orchestration.md` / `orchestration-reference.md`, `pr-review.md` / `pr-review-reference.md`, `knowledge-backend.md` / `knowledge-backend-reference.md` (both halves deleted together with the hook and its settings stanza when the knowledge axis is `none`). Every moved section keeps its heading in the contract with a one-line pointer, so `file § section` citations resolve unchanged; the verification block checks every pointer against its reference half.
- **Always loaded, on purpose** — `workflows.md` (a portable rule), `simplification.md`, and the templates
````

2. In `.claude/skills/scaffold/references/bootstrap_checklist_template.md`, replace

````text
| `knowledge-backend.md` | kept / deleted | <"deleted with its hook and settings stanza — knowledge axis is none"> |
````

   with

````text
| `knowledge-backend.md` + `knowledge-backend-reference.md` | kept / deleted | <"both halves deleted with the hook and its settings stanza — knowledge axis is none"> |
````

3. In `.claude/rules/workflows.md`, replace

````text
| `*-reference.md` | Only when a matching file is read | The path-scoped halves of the conventions, orchestration and review rules; every section has a pointer heading in its contract |
````

   with

````text
| `*-reference.md` | Only when a matching file is read | The path-scoped halves of the conventions, orchestration, review and knowledge-backend rules; every section has a pointer heading in its contract |
````

- [ ] **Step 4: Prove the move is verbatim.** Run:
```bash
python3 - <<'EOF'
import subprocess, re
head = subprocess.run(['git', 'show', '643f7ff:.claude/rules/knowledge-backend.md'], capture_output=True, text=True).stdout
def secs(s):
    parts = re.split(r'(?m)^(?=## )', s)
    return {p.split('\n', 1)[0]: p.rstrip('\n') for p in parts if p.startswith('## ')}
h = secs(head); c = secs(open('.claude/rules/knowledge-backend.md').read()); r = secs(open('.claude/rules/knowledge-backend-reference.md').read())
bad = [k for k in h if h[k] != (r.get(k) or c.get(k))]
print('sections', len(h), 'contract', len(c), 'reference', len(r), 'drifted', bad)
EOF
```
Expected: `sections 18 contract 18 reference 13 drifted []` — eighteen headings at HEAD; the contract still carries all eighteen (five kept whole, thirteen as pointers); the reference carries the thirteen moved ones; and none changed in transit.

- [ ] **Step 5: Review Focus 3 — a knowledge axis of `none` leaves the block green.** Run, from the repository root:
```bash
d=$(mktemp -d) && cp -a . "$d/t" && cd "$d/t" \
&& rm .claude/rules/knowledge-backend.md .claude/rules/knowledge-backend-reference.md .claude/hooks/require-knowledge-backend-ok.sh \
&& jq '.hooks |= with_entries(.value |= map(select([.hooks[] | (.command // ""), ((.args // [])[])] | any(endswith("require-knowledge-backend-ok.sh")) | not)))' .claude/settings.json > s.json && mv s.json .claude/settings.json \
&& jq -r '.. | objects | select(has("command")) | .command' .claude/settings.json | grep -c knowledge-backend; \
bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'SKIP: the knowledge-backend|^verification: '; echo "exit=${PIPESTATUS[0]}"; cd - >/dev/null; rm -rf "$d"
```
Expected: `0` (no registration left), then `SKIP: the knowledge-backend ask-gate (no mcp__ matcher in settings.json — the knowledge axis is none)` (V2's `hook-guards-fixture.sh`, run by the block, finds the ask-gate through the registry and skips it), `verification: kit sub-block complete`, `verification: done` and `exit=0`. Measured on a HEAD copy with this task applied: always-loaded 110,434 bytes and both sentinels. If the block goes red here, the fault is in whatever check or fixture assumes the knowledge axis: fix that, not this task.

- [ ] **Step 6: Run the block.** No hook is touched in this task, so there is no `bash -n` step. Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|verification:'; echo "exit=${PIPESTATUS[0]}"`. Expected: `always-loaded total:` down by 10,622 bytes against the previous commit's run, no `WARN`, `verification: kit sub-block complete`, `verification: done`, `exit=0`.

- [ ] **Step 7: Commit.**

````bash
git add .claude/rules/cbk-conventions-reference.md .claude/rules/cbk-conventions.md .claude/rules/knowledge-backend-reference.md .claude/rules/knowledge-backend.md .claude/rules/workflows.md .claude/skills/scaffold/references/bootstrap_checklist_template.md
git commit -F - <<'EOF'
refactor(rules): V5 — knowledge-backend.md splits into a contract and a path-scoped reference

The always-loaded knowledge-backend rule keeps its operative contract (when to read,
when to write, the announcement discipline, inheritance, the code-adjacent split); the
provisioning detail moves verbatim to knowledge-backend-reference.md, scoped to the
skills, commands, the ask-gate hook, cascade artifacts and the rule pair. § Rule loading,
the bootstrap disposition row and the rules index name the pair; a knowledge axis of none
deletes both halves. The block checks every Moved-to pointer against its reference half.

Always-loaded: -10,622 bytes (knowledge-backend.md 20,336 -> 9,513).

Closes trace rows: review/claude-code/57. Decisions: D59, D50.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
````

---

### Task V5.2: `knowledge-backend`: the ask-gate stated once; Notion's claims sourced and the plan-gated property named (#66/c5901495490 (handed from V9); review/portability/38; D50, D56)

**Files:**
- Modify: `.claude/rules/knowledge-backend.md` (§ HITL announcement discipline, the **Hook enforcement layer** paragraph)
- Modify: `.claude/rules/knowledge-backend-reference.md` (§ Wiki pattern + Verification, § Notion MCP convention, § Notion 3.3+ awareness (Feb 2026), § What this doc deliberately doesn't cover)
- Modify: `.claude/rules/cbk-conventions-reference.md` (§ Verification, one check at the kit sentinel)

**Interfaces:**
- Consumes: V5.1's reference file; `cbk-conventions-reference.md` § HITL gate load-bearing heuristics › Mechanize the gates (the pointer target, present at HEAD).
- Produces: The sentence `"This feature is available on Business and Enterprise Plans."` in `knowledge-backend-reference.md`, which the new check pins; the **Owner** + **Verify by** fallback. V9 need not land review/portability/38 or #66/c5901495490.

**Budget:** always-loaded −59 bytes (measured on a copy of `643f7ff` with V5.1–V5.2 applied: 119,947).

- [ ] **Step 0: Re-check the unverified finding (D56).** Run: `grep -n 'Verification property with expiry' .claude/rules/knowledge-backend-reference.md; grep -n 'plan-specific features' .claude/rules/knowledge-backend-reference.md; grep -c 'notion.com/releases' .claude/rules/knowledge-backend-reference.md`. Expected: one hit each for the first two and `0` for the third — the finding still holds.

- [ ] **Step 1: Write the failing block check.** In `.claude/rules/cbk-conventions-reference.md`, insert these lines immediately before the line `echo "verification: kit sub-block complete"`:

````bash
# Notion's native page verification is plan-gated, and the knowledge-backend rule says so where it requires the property
# (knowledge-backend-reference.md § Wiki pattern + Verification, with its fallback). A none-axis target deleted the file.
[ ! -f .claude/rules/knowledge-backend-reference.md ] || grep -q 'Business and Enterprise Plans' .claude/rules/knowledge-backend-reference.md || { echo "knowledge-backend-reference.md § Wiki pattern + Verification does not name Notion's plan-gated Verification property and its fallback"; exit 1; }
````

- [ ] **Step 2: Run it against the unfixed files.** Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`. Expected, red. The last two lines are:

````text
knowledge-backend-reference.md § Wiki pattern + Verification does not name Notion's plan-gated Verification property and its fallback
verification: block exited 1
exit=1
````

Record the first of those lines in the PR body's red-first table.

- [ ] **Step 3: Make the change.**

1. In `.claude/rules/knowledge-backend.md`, replace

````text
**Hook enforcement layer.** Prose alone cannot stop a session where a broad permissions allowlist would auto-approve the write tool. The kit ships `.claude/hooks/require-knowledge-backend-ok.sh` (registered in `settings.json` against the knowledge-backend MCP's mutating tool names — Notion's `create|update|move|duplicate|convert|delete|upload|spawn|send|stop` as the v1 reference, dated 2026-09-21; the matcher is a dated observation, re-verified when the MCP's tool list changes) which returns a deterministic permission "ask" on every matched write: the forced permission prompt is the per-action approval, and read tools stay unmatched so read-primary behavior is unaffected.
````

   with

````text
**Hook enforcement layer.** Every knowledge-backend write is an **ask-gate**; the tier, and why a forced prompt holds where prose does not, are stated once in `cbk-conventions-reference.md` § HITL gate load-bearing heuristics › Mechanize the gates. The kit's hook is `.claude/hooks/require-knowledge-backend-ok.sh`, registered in `settings.json` against the MCP's mutating tool names — Notion's `create|update|move|duplicate|convert|delete|upload|spawn|send|stop` as the v1 reference, dated 2026-09-21 and re-verified when the MCP's tool list changes. Read tools stay unmatched, so read-primary behavior is unaffected.
````

2. In `.claude/rules/knowledge-backend-reference.md`, replace

````text
Unverified pages are how Notion becomes a graveyard. The kit's hub provisioning sets these properties up when it creates the relevant DB; ongoing maintenance is the operator's responsibility.
````

   with

````text
Unverified pages are how Notion becomes a graveyard. The kit's hub provisioning sets these properties up when it creates the relevant DB; ongoing maintenance is the operator's responsibility.

**Notion's native Verification property is plan-gated.** Of verifying pages, Notion's help page says: "This feature is available on Business and Enterprise Plans." (`https://www.notion.com/help/wikis-and-verified-pages`, read 2026-09-30). On any other plan, carry the same two facts as ordinary properties: an **Owner** person property and a **Verify by** date property on the same 90 / 180 / 365-day cadence. Record which form the workspace uses in `cbk-conventions.md` § Knowledge backend — operator's specific choices.
````

3. In `.claude/rules/knowledge-backend-reference.md`, replace

````text
**Recommended MCP server**: Notion's official MCP (`notion.com/help/notion-mcp`).
````

   with

````text
**Recommended MCP server**: Notion's official MCP (`https://www.notion.com/help/notion-mcp`).
````

4. In `.claude/rules/knowledge-backend-reference.md`, replace

````text
**Why standardize**: Notion's official MCP is the reference implementation as of the v1 of this kit. It supports both read and write; integrates cleanly with Claude Code.
````

   with

````text
**Why standardize**: Notion's official MCP is the reference implementation as of the v1 of this kit. It reads and writes: Notion's help page describes connected AI apps that "create structured project pages in Notion" (`https://www.notion.com/help/notion-mcp`, read 2026-09-30), and the write tool names the kit's ask-gate matches are the dated observation in `knowledge-backend.md` § HITL announcement discipline.
````

5. In `.claude/rules/knowledge-backend-reference.md`, replace

````text
## Notion 3.3+ awareness (Feb 2026)

Notion 3.3 introduced Custom Agents — agents that run 24/7 against workspace context.
````

   with

````text
## Notion 3.3+ awareness (Feb 2026)

Notion 3.3 introduced Custom Agents — agents that run 24/7 against workspace context: "Just give them a job, set a trigger or schedule, and they'll get it done, 24/7." (`https://www.notion.com/releases/2026-02-24`, "Notion 3.3: Custom Agents", read 2026-09-30; re-read when a Notion release changes what an agent may do to a page).
````

6. In `.claude/rules/knowledge-backend-reference.md`, replace

````text
- **Notion pricing tiers / plan-specific features** — operator's concern, not the kit's
````

   with

````text
- **Notion pricing tiers / plan-specific features** — operator's concern, not the kit's, with one exception the kit prescribes: native page verification is Business/Enterprise-only, and § Wiki pattern + Verification names the fallback
````

- [ ] **Step 4: Re-fetch every quotation this task writes, raw, today.** With `qf` loaded (§ Conventions), run:

````bash
qf https://www.notion.com/help/wikis-and-verified-pages 'This feature is available on Business and Enterprise Plans.'
qf https://www.notion.com/help/notion-mcp 'create structured project pages in Notion'
qf https://www.notion.com/releases/2026-02-24 'Just give them a job, set a trigger or schedule, and they'\''ll get it done, 24/7.'
qf https://www.notion.com/releases/2026-02-24 'Notion 3.3: Custom Agents'
````

Expected: one `OK` line per call and no `MISS`. A `MISS` means the page moved since 2026-09-30: re-read it, correct the quotation and its date in the replacement text, and re-run.

- [ ] **Step 5: Run the block.** No hook is touched in this task, so there is no `bash -n` step. Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|verification:'; echo "exit=${PIPESTATUS[0]}"`. Expected: `always-loaded total:` down by 59 bytes against the previous commit's run, no `WARN`, `verification: kit sub-block complete`, `verification: done`, `exit=0`.

- [ ] **Step 6: Commit.**

````bash
git add .claude/rules/cbk-conventions-reference.md .claude/rules/knowledge-backend-reference.md .claude/rules/knowledge-backend.md
git commit -F - <<'EOF'
fix(rules): V5 — the knowledge-backend ask-gate points at its tier; Notion's claims sourced and the plan-gated property named

The hook-enforcement paragraph no longer restates why a forced prompt holds; it points at
§ HITL gate load-bearing heuristics › Mechanize the gates and keeps the hook, its dated
matcher and the unmatched reads. The Verification property the wiki pattern requires is
Business/Enterprise-only on Notion, so the rule names that and gives the Owner + Verify-by
fallback; the MCP's read/write claim and the 3.3 Custom Agents claim carry sources read
2026-09-30.

Closes trace rows: #66/c5901495490, review/portability/38. Decisions: D50, D56.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
````

---

### Task V5.3: The ladder from Opus 5.5, the aliases by provider, the price steps, the review bots, the mechanical row's trigger (#69/body/T1, #69/body/T7, #69/body/F4 (ladder and prices), #69/c5881157875/1a, #69/c5881157875/2a, #69/c5881157875/2b, #69/c5881157875/4, #69/c5881157875/2-steps, #69/c5881157875/2-sonnet5, #67/body/3, #67/c5901495773/5, #67/c5881158070/2c (reference half), #58/c5901493591/R9 (reference half), critic/18; D49, D47, D50, D51)

**Files:**
- Modify: `.claude/rules/orchestration.md` (§ The ceiling rule, § Generation notes)
- Modify: `.claude/rules/orchestration-reference.md` (§ Generation notes — the sources: the ladder bullet becomes four bullets — the ladder, which keeps its pricing-row sentence verbatim for V6, the price steps, the aliases, the mechanical tier's floor; § Applied instances, the 2026-09-01 framing bullet)
- Modify: `.claude/rules/cbk-conventions-reference.md` (§ Verification, one check at the kit sentinel)

**Interfaces:**
- Consumes: Nothing from other clusters. The block's existing list-price diff (`agent-cost.py` `PRICE` against the reference's pricing row) must stay green, so the row keeps the four family entries `PRICE` carries today.
- Produces: The ladder bullet keeps, byte for byte, the sentence `Pricing row, per MTok in/out: Fable 5.1 $10/$50, Opus 5 $5/$25, Sonnet 5 $2/$10, Haiku 4.5 $1/$5 (same page). ` (one trailing space) directly before `"You pay for completed tasks, though, …` — V6's anchor: V6's `agent-cost.py` commit deletes it and inserts its **Prices, per version** bullet with the cache-read quotation, so the list prices, `PRICE` and `CACHE_READ` change in one commit (V6 § Interfaces, handed). The new **Price steps** bullet carries only the steps and Sonnet 5's footnote, and no other `Word N.N $a/$b` string, since the list-price diff reads every one. The paragraphs **The effort column is an Opus 5 / Sonnet 5 calibration** and **The review bots are the one dispatch named by family alias**, which V4's templates agree with (D47).

**Budget:** always-loaded +1,576 bytes (measured on a copy of `643f7ff` with V5.1–V5.3 applied: 121,523).

**Budget.** `orchestration.md` grows by 1,576 bytes here. The review-bot paragraph states the `ANTHROPIC_MODEL` rule without a precedence reason: for the CLI, model-config § Setting your model ranks `--model` *above* `ANTHROPIC_MODEL`, but inside `claude-code-action` the reverse holds — `src/entrypoints/run.ts` passes `model: process.env.ANTHROPIC_MODEL` and `base-action/src/parse-sdk-options.ts` resolves `model: options.model || modelFromClaudeArgs` (both read at `v1.0.237` on 2026-09-30) — and V4's `claude-review.yml` header carries that sourced reason, so the contract does not restate it.

- [ ] **Step 1: Write the failing block check.** In `.claude/rules/cbk-conventions-reference.md`, insert these lines immediately before the line `echo "verification: kit sub-block complete"`:

````bash
# The ladder and the price steps follow the current lineup (orchestration.md § The ceiling rule, § Generation notes;
# context-builder-kit#69): the Opus 5 ladder or the old step order is red. A target that deleted the template skips it.
[ ! -f .claude/rules/orchestration.md ] || { grep -q 'Opus 5.5 first' .claude/rules/orchestration.md && grep -qF '2× / 2× / 2.5×' .claude/rules/orchestration.md; } || { echo "orchestration.md carries the Opus 5 ladder or the old price steps (§ The ceiling rule, § Generation notes)"; exit 1; }
````

- [ ] **Step 2: Run it against the unfixed files.** Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`. Expected, red. The last two lines are:

````text
orchestration.md carries the Opus 5 ladder or the old price steps (§ The ceiling rule, § Generation notes)
verification: block exited 1
exit=1
````

Record the first of those lines in the PR body's red-first table.

- [ ] **Step 3: Make the change.**

1. In `.claude/rules/orchestration.md`, replace

````text
the platform's own ladder runs the other way — Opus 5 first, then higher effort, then Fable 5.1 when evals still fall short
````

   with

````text
the platform's own ladder runs the other way — Opus 5.5 first, then higher effort, then Fable 5.1 when evals still fall short
````

2. In `.claude/rules/orchestration.md`, replace

````text
### Generation notes — verified 2026-09-05; re-verify before re-citing

The lineup this file was calibrated on and the per-role defaults the shipped exemplars carry, recorded once and re-swept on any model change (effort names do not carry across models — match by observed thinking length). The facts behind the table — the aliases, the documented ladder (Opus 5 → higher effort → Fable 5.1), the price steps (2× / 2.5× / 2×), the no-dial smallest tier, Fable 5.1 searching less at `low`, Opus 5 over-verifying on self-check prose — and their verbatim sources are `orchestration-reference.md` § Generation notes — the sources.
````

   with

````text
### Generation notes — verified 2026-09-30 (Opus 5.5, Sonnet 5.5, Claude Code 2.1.285); re-verify before re-citing

The lineup this file is calibrated on and the per-role defaults the shipped exemplars carry, recorded once and re-swept on any model change (effort names do not carry across models — match by observed thinking length). The facts behind the table — on the Anthropic API `opus` is Opus 5.5 from Claude Code 2.1.280 and `sonnet` is Sonnet 5.5 from 2.1.284, and other providers resolve both differently; the ladder Opus 5.5 → higher effort → Fable 5.1; the price steps **2× / 2× / 2.5×** (Haiku 4.5 → Sonnet 5.5 → Opus 5.5 → Fable 5.1); the per-model default effort (§ The effort axis); the no-dial smallest tier; Fable 5.1 searching less at `low`; over-verification on self-check prose — and their verbatim sources are `orchestration-reference.md` § Generation notes — the sources.
````

3. In `.claude/rules/orchestration.md`, replace

````text
| The synthesis slot (top-tier sessions only) | `fable` | `high` |
````

   with

````text
| The synthesis slot (top-tier sessions only) | `fable` | `high` |

**The effort column is an Opus 5 / Sonnet 5 calibration — pins pending a measured sweep, not the platform default.** Opus 5.5 and Sonnet 5.5 recalibrated their levels, so every `medium` and `high` above stays a pin until a sweep on the project's own work moves it (§ The effort axis). The synthesis slot's `high` is due the same sweep: on a research benchmark the cost page measured Fable 5.1 nearly flat across `low`, `medium` and `high` while its cost per task rose. **The mechanical row's re-check trigger** is Haiku 4.5's retirement floor: re-read the deprecations page on or after 2026-10-15; no successor Haiku is listed.

**The review bots are the one dispatch named by family alias.** Both review workflows pass `--model opus` or `sonnet`, and the alias resolves inside the Claude Code release the pinned `claude-code-action` installs, so the action's SHA is the model pin and Dependabot's action bump is the model bump. Default effort is per model, so both workflows pass `--effort` on every branch, and that bump re-checks the effort, the turn cap and the degrade clause's file count, which are sized together. Never set `ANTHROPIC_MODEL` on the action step; `--model` stays the one model setting a reviewer reads. Which action release moved which alias is dated in the reference half.
````

4. In `.claude/rules/orchestration-reference.md`, replace

````text
- **The ladder** — "start with Claude Opus 5 for most workloads. Use Claude Fable 5.1 for demanding reasoning and long-horizon agentic work, or when your evals on Claude Opus 5 at higher effort still fall short" (`platform.claude.com/docs/en/about-claude/models/overview` § Compare models). Pricing row, per MTok in/out: Fable 5.1 $10/$50, Opus 5 $5/$25, Sonnet 5 $2/$10, Haiku 4.5 $1/$5 (same page). "You pay for completed tasks, though, so compare models on cost per completed task" (`…/optimizing-for-cost-and-intelligence` § Compare models on cost per task).
````

   with

````text
- **The ladder** (fetched 2026-09-30) — "If you're unsure which model to use, start with Claude Opus 5.5 for most workloads. Use Claude Fable 5.1 for demanding reasoning and long-horizon agentic work, or when your evals on Claude Opus 5.5 at higher effort still fall short" (`platform.claude.com/docs/en/about-claude/models/overview` § Compare models); the same page lists Opus 5 under "Legacy models (still available)". Pricing row, per MTok in/out: Fable 5.1 $10/$50, Opus 5 $5/$25, Sonnet 5 $2/$10, Haiku 4.5 $1/$5 (same page). "You pay for completed tasks, though, so compare models on cost per completed task" (`platform.claude.com/docs/en/about-claude/models/optimizing-for-cost-and-intelligence` § Compare models on cost per task); the same section: "For most agent workloads, start with Claude Opus 5.5 at its default effort (`medium`)" and "On the SWE-bench Pro subset, Opus 5.5 at its default matched Fable 5.1 at its default for about a fifth of the cost per solved task". An advisor is no cheaper than effort: "a Claude Opus 5.5 executor at `high` with a Claude Fable 5.1 advisor scored 90.1% at $2.92 per attempt. That is 1.7 points over Opus 5.5 alone at `high`" and it came "for about 2.1 times the money"; "It lands about on Opus 5.5's own effort curve, so the advisor buys about what more effort does" (§ Advisor strategy: escalate hard decisions). On the synthesis slot's effort: "Claude Fable 5.1 scored nearly the same at `low`, `medium`, and `high` while the cost per task rose from $4.66 to $7.12" (§ Tune effort, on DeepResearch Bench II).
- **Price steps** (`platform.claude.com/docs/en/about-claude/pricing` § Model pricing, fetched 2026-09-30) — the steps up the ladder are 2× / 2× / 2.5×: per MTok of input, Haiku 4.5 at $1, Sonnet 5.5 at $2, Opus 5.5 at $4 and Fable 5.1 at $10. Sonnet 5's footnote: "The previously scheduled increase to $3/$15 per million input/output tokens on September 1, 2026 will not occur."
- **Aliases, by provider and by version** (`code.claude.com/docs/en/model-config`, fetched 2026-09-30) — "The version that the `opus` and `sonnet` aliases resolve to depends on the provider" (§ Model aliases): on the Anthropic API `opus` is Opus 5.5 and `sonnet` Sonnet 5.5; on Claude Platform on AWS, Opus 5.5 and Sonnet 4.6; on Amazon Bedrock and Google Cloud's Agent Platform, Opus 5.5 and Sonnet 4.5; on Microsoft Foundry, Opus 4.6 and Sonnet 4.5 (the table under that sentence). § Version history: "`sonnet` resolves to Sonnet 5.5 on the Anthropic API" at v2.1.284, and "`opus` resolves to Opus 5.5 on the Anthropic API, Claude Platform on AWS, Amazon Bedrock, and Google Cloud's Agent Platform" at v2.1.280. The review bots run the Claude Code their pinned `claude-code-action` installs: read off the action's `base-action/action.yml` at each tag on 2026-09-30, v1.0.232 is the first release to install 2.1.280 and v1.0.236 the first to install 2.1.284, so a target pinned below v1.0.232 still reviews on Opus 5.
- **The mechanical tier's retirement floor** (`platform.claude.com/docs/en/about-claude/model-deprecations` § Model status, fetched 2026-09-30) — `claude-haiku-4-5-20251001` is "Active", tentative retirement "Not sooner than October 15, 2026"; no later Haiku model is listed there, in the models overview, or on the pricing page.
````

5. In `.claude/rules/orchestration-reference.md`, replace

````text
for a top:workhorse cost ratio of 3.2× pooled;
````

   with

````text
for a top:workhorse cost ratio of 3.2× pooled (priced with the top tier's cache reads at 0.1×; Fable 5.1 — the model `fable` resolves to from Claude Code 2.1.257, published 2026-09-01T17:15Z, the day of this run — reads cache at 0.025×, so if the drafters ran on it the ratio is an upper bound; the transcripts' model ids settle which, context-builder-kit#58);
````

- [ ] **Step 4: Confirm the action releases named in the aliases bullet.** Run:
```bash
for t in v1.0.231 v1.0.232 v1.0.235 v1.0.236 v1.0.237; do printf '%s ' $t; curl -sL https://raw.githubusercontent.com/anthropics/claude-code-action/$t/base-action/action.yml | grep -o 'CLAUDE_CODE_VERSION="[0-9.]*"'; done
```
Expected: `v1.0.231 CLAUDE_CODE_VERSION="2.1.278"`, `v1.0.232 …"2.1.280"`, `v1.0.235 …"2.1.283"`, `v1.0.236 …"2.1.284"`, `v1.0.237 …"2.1.285"`. And `npm view @anthropic-ai/claude-code time --json | grep '"2.1.257"'` prints `"2.1.257": "2026-09-01T17:15:33.223Z"` (the R9 note's date).

- [ ] **Step 5: Re-fetch every quotation this task writes, raw, today.** With `qf` loaded (§ Conventions), run:

````bash
qf https://platform.claude.com/docs/en/about-claude/models/overview.md 'If you'\''re unsure which model to use, start with Claude Opus 5.5 for most workloads. Use Claude Fable 5.1 for demanding reasoning and long-horizon agentic work, or when your evals on Claude Opus 5.5 at higher effort still fall short'
qf https://platform.claude.com/docs/en/about-claude/models/overview.md 'Legacy models (still available)'
qf https://platform.claude.com/docs/en/about-claude/models/optimizing-for-cost-and-intelligence.md 'You pay for completed tasks, though, so compare models on cost per completed task'
qf https://platform.claude.com/docs/en/about-claude/models/optimizing-for-cost-and-intelligence.md 'For most agent workloads, start with Claude Opus 5.5 at its default effort (`medium`)'
qf https://platform.claude.com/docs/en/about-claude/models/optimizing-for-cost-and-intelligence.md 'On the SWE-bench Pro subset, Opus 5.5 at its default matched Fable 5.1 at its default for about a fifth of the cost per solved task'
qf https://platform.claude.com/docs/en/about-claude/models/optimizing-for-cost-and-intelligence.md 'a Claude Opus 5.5 executor at `high` with a Claude Fable 5.1 advisor scored 90.1% at $2.92 per attempt. That is 1.7 points over Opus 5.5 alone at `high`'
qf https://platform.claude.com/docs/en/about-claude/models/optimizing-for-cost-and-intelligence.md 'for about 2.1 times the money'
qf https://platform.claude.com/docs/en/about-claude/models/optimizing-for-cost-and-intelligence.md 'It lands about on Opus 5.5'\''s own effort curve, so the advisor buys about what more effort does'
qf https://platform.claude.com/docs/en/about-claude/models/optimizing-for-cost-and-intelligence.md 'Claude Fable 5.1 scored nearly the same at `low`, `medium`, and `high` while the cost per task rose from $4.66 to $7.12'
qf https://platform.claude.com/docs/en/about-claude/pricing.md 'The previously scheduled increase to $3/$15 per million input/output tokens on September 1, 2026 will not occur.'
qf https://code.claude.com/docs/en/model-config.md 'The version that the `opus` and `sonnet` aliases resolve to depends on the provider'
qf https://code.claude.com/docs/en/model-config.md '`sonnet` resolves to Sonnet 5.5 on the Anthropic API'
qf https://code.claude.com/docs/en/model-config.md '`opus` resolves to Opus 5.5 on the Anthropic API, Claude Platform on AWS, Amazon Bedrock, and Google Cloud'\''s Agent Platform'
qf https://platform.claude.com/docs/en/about-claude/model-deprecations.md 'Not sooner than October 15, 2026'
````

Expected: one `OK` line per call and no `MISS`. A `MISS` means the page moved since 2026-09-30: re-read it, correct the quotation and its date in the replacement text, and re-run.

- [ ] **Step 6: Run the block.** No hook is touched in this task, so there is no `bash -n` step. Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|verification:'; echo "exit=${PIPESTATUS[0]}"`. Expected: `always-loaded total:` up by 1,576 bytes against the previous commit's run, no `WARN`, `verification: kit sub-block complete`, `verification: done`, `exit=0`.

- [ ] **Step 7: Commit.**

````bash
git add .claude/rules/cbk-conventions-reference.md .claude/rules/orchestration-reference.md .claude/rules/orchestration.md
git commit -F - <<'EOF'
fix(rules): V5 — the ladder starts at Opus 5.5; aliases by provider, price steps 2x/2x/2.5x, the review-bot pin, Haiku 4.5's trigger

The ceiling rule and the generation notes follow the lineup Claude Code 2.1.280 and 2.1.284
installed: opus is Opus 5.5 and sonnet Sonnet 5.5 on the Anthropic API, other providers
differ, the documented ladder starts at Opus 5.5, and the price steps are 2x / 2x / 2.5x.
The effort column is labelled a set of pins pending a sweep; the mechanical row carries
Haiku 4.5's 2026-10-15 retirement floor. The review bots' paragraph states the alias pin,
the explicit --effort and what the action bump re-checks. The reference half quotes the
ladder, the advisor result, the price steps and Sonnet 5's cancelled increase, the alias
tables and the action releases, all read 2026-09-30, and the 3.2x ratio carries its
cache-rate condition. The family pricing row stays where it was for V6's per-version row.

Closes trace rows: #69/body/T1, #69/body/T7, #69/c5881157875/1a, #69/c5881157875/2a,
#69/c5881157875/2b, #69/c5881157875/4, #69/c5881157875/2-steps, #69/c5881157875/2-sonnet5,
#67/body/3, #67/c5901495773/5, critic/18 (in part); lands the V5 halves of #69/body/F4,
#67/c5881158070/2c and #58/c5901493591/R9. Decisions: D49, D47, D50.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
````

---

### Task V5.4: The effort axis per model and per surface; thinking by model; the Agent tool takes no effort (#69/body/T2, #69/body/T3, #69/body/T4, #69/body/T9, #69/body/F1, #69/body/F2, #69/body/F3, #69/c5881157875/1b, #69/c5881157875/1c (rule text), #69/c5881157875/1d, #74/body/3, #69/body/Fq (effort and re-run quotes), critic/18; D49, D50)

**Files:**
- Modify: `.claude/rules/orchestration.md` (§ The role ladder, the default paragraph; § The effort axis, three bullets and one new)
- Modify: `.claude/rules/orchestration-reference.md` (§ Generation notes — the sources: the `high`-default bullet becomes four bullets; the re-run figures)
- Modify: `.claude/rules/cbk-conventions-reference.md` (§ Verification, one check at the kit sentinel)

**Interfaces:**
- Consumes: V5.3's § Generation notes wording ("the per-model default effort (§ The effort axis)").
- Produces: The clause `the tool takes no effort parameter` (checked); the rule that a floor's toolkit agents record their effort on the `## Review gate` line — F2 (V7, Task F2 Step 5) reads it. The Sonnet 5.5 remedy line as a normative sentence; V7 puts it into `review-sweep.js`'s finder prompt (handed).

**Budget:** always-loaded +2,061 bytes (measured on a copy of `643f7ff` with V5.1–V5.4 applied: 123,584).

- [ ] **Step 0: Probe the Agent tool's parameters (the #74 §3 fact).** In the main session, read your own `Agent` tool definition and list its parameters. Expected on Claude Code 2.1.285: `description`, `prompt`, `subagent_type`, `model`, `run_in_background`, `name`, `isolation`, `cwd`, and no `effort`. Then run `grep -l '^effort:' ~/.claude/plugins/cache/*/pr-review-toolkit/*/agents/*.md; echo "exit=$?"`. Expected: no file names and `exit=1`. If either shows an effort setting, stop: the inserted sentence is false and must be reconciled first.

- [ ] **Step 1: Write the failing block check.** In `.claude/rules/cbk-conventions-reference.md`, insert these lines immediately before the line `echo "verification: kit sub-block complete"`:

````bash
# Effort defaults are per model and per surface, and the Agent tool takes no effort parameter (orchestration.md § The role
# ladder, § The effort axis; context-builder-kit#69, context-builder-kit#74): the retired "API default is high" claim is red.
[ ! -f .claude/rules/orchestration.md ] || { absent grep -n 'The API default is `hig[h]`' .claude/rules/orchestration.md; grep -q 'takes no effort parameter' .claude/rules/orchestration.md || { echo "orchestration.md § The role ladder does not say the Agent tool takes no effort parameter (context-builder-kit#74)"; exit 1; }; }
````

- [ ] **Step 2: Run it against the unfixed files.** Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`. Expected, red. The `absent` check first prints the line(s) it matched (line numbers may differ once V1–V4 have landed); the last two lines are:

````text
VIOLATION (matched above): grep -n The API default is `hig[h]` .claude/rules/orchestration.md
verification: block exited 1
exit=1
````

Record the first of those lines in the PR body's red-first table.

- [ ] **Step 3: Make the change.**

1. In `.claude/rules/orchestration.md`, replace

````text
its effort; a worker gets a chosen level, stated. Inherit is not neutral:
````

   with

````text
its effort; a worker gets a chosen level, stated. An Agent-tool call names its effort only through what it dispatches: the tool takes no effort parameter, so the level comes from the definition's `effort:` frontmatter or the skill it forked from, and a call to a definition that sets none — general-purpose, Plan, the review toolkit's agents — runs at the session's level. Dispatch through a definition that pins the level where it matters; where none can be chosen, as for the review floor's toolkit agents, record the effort they actually ran at on the `## Review gate` line. Inherit is not neutral:
````

2. In `.claude/rules/orchestration.md`, replace

````text
- **Omitting effort is not neutral.** The API default is `high` — omitting the parameter and setting `high` behave identically — and the page's first best practice is "Set effort explicitly" (the effort page § How effort works, § Best practices); a subagent's `effort:` frontmatter "inherits from session" when omitted (sub-agents § Supported frontmatter fields), so an unpinned worker under an `xhigh` session runs at `xhigh`. Name it. Every source in this section is quoted in `orchestration-reference.md` § Generation notes — the sources.
````

   with

````text
- **Omitting effort is not neutral, and the default is per model and per surface.** Omitting it behaves exactly like setting the model's default: through the API that is `medium` on Opus 5.5 and `high` on every other model with the dial, Sonnet 5.5 included; in Claude Code it is `medium` on Opus 5.5 and Sonnet 5.5, `xhigh` on Opus 4.7 and `high` elsewhere (the effort page § How effort works; model-config § Adjust effort level). So an omitted effort on Opus 5.5 runs one level lower than it did on Opus 5, and the same Sonnet 5.5 call runs at `high` through the API and at `medium` in a Claude Code session. The page's first best practice is "Set effort explicitly" (§ Best practices); which settings file binds which model is in the reference half. A subagent's `effort:` frontmatter "inherits from session" when omitted (sub-agents § Supported frontmatter fields), so an unpinned worker under an `xhigh` session runs at `xhigh`. Name it. Every source in this section is quoted in `orchestration-reference.md` § Generation notes — the sources.
````

3. In `.claude/rules/orchestration.md`, replace

````text
— a `low` worker needs a complete brief. Never `low` for search or research on Fable 5.1 (§ Generation notes).
````

   with

````text
— a `low` worker needs a complete brief. Never `low` for search or research on Fable 5.1 (§ Generation notes). A Sonnet 5.5 finder at `low` or `medium` is more likely to stop and check in on a long task and to answer a JSON request without thinking first (the Sonnet 5.5 guide), so its brief is complete and its prompt ends with the guide's remedy line: "Think the problem through before you answer."
````

4. In `.claude/rules/orchestration.md`, replace

````text
- `medium` / `high` — start at `high` and use `low` and `medium` liberally wherever evals show quality holds (the effort page § Recommended effort levels for Claude Opus 5). `high` is the level for a worker whose output nothing downstream checks and for drafting a long deliverable; `xhigh`/`max` can draft the deliverable in thinking and write it again (the Fable 5.1 guide § Leave room for long outputs at xhigh and max effort).
````

   with

````text
- `medium` / `high` — start at the model's default and sweep: `medium` on Opus 5.5, which at `medium` matches or exceeds Opus 5 at `high` and thinks more per turn at any given level (the Opus 5.5 guide § Calibrate effort); on Sonnet 5.5, `medium` for well-specified agentic work and `high` for harder or longer work (the effort page); on Opus 5 it was `high`. This file's `high` for a worker whose output nothing downstream checks, and for drafting a long deliverable, is an Opus 5 calibration — on Opus 5.5 a **pin above the default pending a sweep** (§ Generation notes), not a default. `xhigh`/`max` can draft the deliverable in thinking and write it again (the Fable 5.1 guide § Leave room for long outputs at xhigh and max effort); reserve them for work where a gain was measured.
- **Thinking is always on for Opus 5.5 and Fable 5.1, not for Sonnet 5.5** (the models overview's comparison table; the effort page § Recommended effort levels for Claude Opus 5.5), so on the workhorse, as on the top tier, effort is the only spend lever. Sonnet 5.5 has a second: `thinking: {"type": "between_tools"}` turns off up-front thinking at `low`, `medium` and `high`.
````

5. In `.claude/rules/orchestration-reference.md`, replace

````text
- **The `high` default** — "By default, Claude uses high effort, spending as many tokens as needed for excellent results"; "Setting `effort` to `"high"` produces exactly the same behavior as omitting the `effort` parameter entirely"; "**Set effort explicitly:** The API defaults to `high`, but the right starting point depends on your model and workload" (`platform.claude.com/docs/en/build-with-claude/effort` § How effort works, § Best practices). The `low` row: "Simpler tasks that need the best speed and lowest costs, such as subagents" (§ Effort levels). Opus 5: "use `low` and `medium` liberally as your primary control for token cost and response time wherever your evals show quality holds" (§ Recommended effort levels for Claude Opus 5). The supported-model list under § Compatibility carries no Haiku model.
````

   with

````text
- **The default effort is per model and per surface** (fetched 2026-09-30):
  - The API: "Most Claude models default to high effort, spending as many tokens as needed for excellent results; Claude Opus 5.5 defaults to medium."; "Setting `effort` to the model's default (`"medium"` on Claude Opus 5.5, `"high"` on other models) produces exactly the same behavior as omitting the `effort` parameter entirely."; "**Set effort explicitly:** The API defaults to `high` (`medium` on Claude Opus 5.5), but the right starting point depends on your model and workload." (`platform.claude.com/docs/en/build-with-claude/effort` § How effort works, § Best practices). The `low` row: "Simpler tasks that need the best speed and lowest costs, such as subagents" (§ Effort levels). Opus 5: "use `low` and `medium` liberally as your primary control for token cost and response time wherever your evals show quality holds" (§ Recommended effort levels for Claude Opus 5).
  - Opus 5.5: "Claude Opus 5.5 supports all five effort levels, and `medium` is the default (Claude Opus 5 and earlier Opus models default to `high`, so a request that omits `effort` runs one level lower than it did on Claude Opus 5). Adaptive thinking is always on and can't be turned off, so effort is the primary control for how much the model reasons and what a request costs." (§ Recommended effort levels for Claude Opus 5.5). Thinking by model: the models overview's comparison table lists "Adaptive (always on)" for Fable 5.1 and Opus 5.5, "Adaptive" for Sonnet 5.5 and "Extended" for Haiku 4.5.
  - Sonnet 5.5: "Claude Sonnet 5.5 supports all five effort levels, and `high` is the default on the Claude API. Its levels are recalibrated, so a level doesn't produce the same amount of thinking as the same level on Claude Sonnet 5. Run a fresh effort sweep on your evals rather than carrying over the setting you used on Claude Sonnet 5."; "For agentic coding and multistep tool use, start with `medium` for well-specified tasks and move to `high` for harder or longer ones."; "To turn off up-front thinking, send `thinking: {"type": "between_tools"}` instead of `"disabled"`.", and "it works at `low`, `medium`, and `high` effort" (§ Recommended effort levels for Claude Sonnet 5.5).
  - Claude Code: "The model's default effort: `high` on every model that supports effort, except that Opus 5.5 and Sonnet 5.5 default to `medium`, Opus 4.7 defaults to `xhigh`" (`code.claude.com/docs/en/model-config` § Adjust effort level). The dial: "The available effort levels depend on the model. Models not listed here do not support effort:", and the table under it lists no Haiku model (same section).
  - Which setting binds where (same section): "a top-level `effortLevel` in your user settings file doesn't count for Opus 5.5"; "Opus 5.5 and models released after it start at their own default until you choose a level for them with `/effort` or the `/model` picker. A top-level `effortLevel` in project, local, or managed settings, or one passed with `--settings`, applies to every model."; "Claude Code saves the level per model, under the `modelSettings` key in your user settings, so each model keeps its own saved level."; "Frontmatter effort applies when that skill or subagent is active, overriding the session level but not the environment variable."
- **Opus 5.5 against Opus 5** (`platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5`, fetched 2026-09-30) — the Opus 5 guide's patterns "remain a reasonable starting point" (introduction); "in Anthropic's testing, Claude Opus 5.5 at `medium` matches or exceeds Claude Opus 5 at `high` on coding and knowledge-work evaluations"; "At a given level, Claude Opus 5.5 tends to think more per turn than Claude Opus 5, especially at `xhigh` and `max`"; "Reserve `xhigh` and `max` for work where you've measured a quality gain." (§ Calibrate effort).
- **Sonnet 5.5 as a finder** (`platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5-5`, fetched 2026-09-30) — "At `low` and `medium`, on long agentic tasks, it's more likely to stop and check in with the user before it finishes." (§ Calibrate effort). On a JSON answer to a task that needs working out, "the model often answers without thinking first, particularly at `low` and `medium` effort"; the remedy is to "add this line to the end of your system prompt": "Think the problem through before you answer." (§ Reasoning tasks with JSON output). A workflow `agent()` takes a prompt, not a system prompt, so the line ends the prompt.
- **The Agent tool and effort** (fetched 2026-09-30) — the sub-agents page names one per-invocation setting: "When Claude invokes a subagent, it can also pass a `model` parameter for that specific invocation"; and `/tasks` "adds the effort level when the subagent's definition, or the skill it forked from, sets `effort`" (§ Choose a model). The review toolkit's agent files carry no `effort:` line (read in the installed plugin cache on 2026-09-30).
````

6. In `.claude/rules/orchestration-reference.md`, replace

````text
"With Claude Opus 5 at `low`, 16% of tasks failed; with those re-run at the default, about 93% passed for about $0.45 each" (`…/optimizing-for-cost-and-intelligence` § Re-run failures at higher effort).
````

   with

````text
"With Claude Opus 5.5 at `low`, 13% of tasks failed; with those re-run at `high`, about 97% passed for about $0.17 each, against 95.3% for $0.29 running everything at `high`" (`…/optimizing-for-cost-and-intelligence` § Re-run failures at higher effort, fetched 2026-09-30).
````

- [ ] **Step 4: Re-fetch every quotation this task writes, raw, today.** With `qf` loaded (§ Conventions), run:

````bash
qf https://platform.claude.com/docs/en/build-with-claude/effort.md 'Most Claude models default to high effort, spending as many tokens as needed for excellent results; Claude Opus 5.5 defaults to medium.'
qf https://platform.claude.com/docs/en/build-with-claude/effort.md 'Setting `effort` to the model'\''s default (`"medium"` on Claude Opus 5.5, `"high"` on other models) produces exactly the same behavior as omitting the `effort` parameter entirely.'
qf https://platform.claude.com/docs/en/build-with-claude/effort.md '**Set effort explicitly:** The API defaults to `high` (`medium` on Claude Opus 5.5), but the right starting point depends on your model and workload.'
qf https://platform.claude.com/docs/en/build-with-claude/effort.md 'Simpler tasks that need the best speed and lowest costs, such as subagents'
qf https://platform.claude.com/docs/en/build-with-claude/effort.md 'use `low` and `medium` liberally as your primary control for token cost and response time wherever your evals show quality holds'
qf https://platform.claude.com/docs/en/build-with-claude/effort.md 'Claude Opus 5.5 supports all five effort levels, and `medium` is the default (Claude Opus 5 and earlier Opus models default to `high`, so a request that omits `effort` runs one level lower than it did on Claude Opus 5). Adaptive thinking is always on and can'\''t be turned off, so effort is the primary control for how much the model reasons and what a request costs.'
qf https://platform.claude.com/docs/en/about-claude/models/overview.md 'Adaptive (always on)'
qf https://platform.claude.com/docs/en/about-claude/models/overview.md 'Extended'
qf https://platform.claude.com/docs/en/build-with-claude/effort.md 'Claude Sonnet 5.5 supports all five effort levels, and `high` is the default on the Claude API. Its levels are recalibrated, so a level doesn'\''t produce the same amount of thinking as the same level on Claude Sonnet 5. Run a fresh effort sweep on your evals rather than carrying over the setting you used on Claude Sonnet 5.'
qf https://platform.claude.com/docs/en/build-with-claude/effort.md 'For agentic coding and multistep tool use, start with `medium` for well-specified tasks and move to `high` for harder or longer ones.'
qf https://platform.claude.com/docs/en/build-with-claude/effort.md 'To turn off up-front thinking, send `thinking: {"type": "between_tools"}` instead of `"disabled"`.'
qf https://platform.claude.com/docs/en/build-with-claude/effort.md 'it works at `low`, `medium`, and `high` effort'
qf https://code.claude.com/docs/en/model-config.md 'The model'\''s default effort: `high` on every model that supports effort, except that Opus 5.5 and Sonnet 5.5 default to `medium`, Opus 4.7 defaults to `xhigh`'
qf https://code.claude.com/docs/en/model-config.md 'The available effort levels depend on the model. Models not listed here do not support effort:'
qf https://code.claude.com/docs/en/model-config.md 'a top-level `effortLevel` in your user settings file doesn'\''t count for Opus 5.5'
qf https://code.claude.com/docs/en/model-config.md 'Opus 5.5 and models released after it start at their own default until you choose a level for them with `/effort` or the `/model` picker. A top-level `effortLevel` in project, local, or managed settings, or one passed with `--settings`, applies to every model.'
qf https://code.claude.com/docs/en/model-config.md 'Claude Code saves the level per model, under the `modelSettings` key in your user settings, so each model keeps its own saved level.'
qf https://code.claude.com/docs/en/model-config.md 'Frontmatter effort applies when that skill or subagent is active, overriding the session level but not the environment variable.'
qf https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5.md 'remain a reasonable starting point'
qf https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5.md 'in Anthropic'\''s testing, Claude Opus 5.5 at `medium` matches or exceeds Claude Opus 5 at `high` on coding and knowledge-work evaluations'
qf https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5.md 'At a given level, Claude Opus 5.5 tends to think more per turn than Claude Opus 5, especially at `xhigh` and `max`'
qf https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5.md 'Reserve `xhigh` and `max` for work where you'\''ve measured a quality gain.'
qf https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5-5.md 'At `low` and `medium`, on long agentic tasks, it'\''s more likely to stop and check in with the user before it finishes.'
qf https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5-5.md 'the model often answers without thinking first, particularly at `low` and `medium` effort'
qf https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5-5.md 'add this line to the end of your system prompt'
qf https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5-5.md 'Think the problem through before you answer.'
qf https://code.claude.com/docs/en/sub-agents.md 'When Claude invokes a subagent, it can also pass a `model` parameter for that specific invocation'
qf https://code.claude.com/docs/en/sub-agents.md 'adds the effort level when the subagent'\''s definition, or the skill it forked from, sets `effort`'
qf https://code.claude.com/docs/en/sub-agents.md 'Effort level when this subagent is active. Overrides the session effort level. Default: inherits from session.'
qf https://platform.claude.com/docs/en/about-claude/models/optimizing-for-cost-and-intelligence.md 'With Claude Opus 5.5 at `low`, 13% of tasks failed; with those re-run at `high`, about 97% passed for about $0.17 each, against 95.3% for $0.29 running everything at `high`'
qf https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5.md 'If you observe shallow reasoning on complex problems, raise effort to `high` or `xhigh` rather than prompting around it'
qf https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5.md 'When benchmarking, match by observed thinking length rather than effort name.'
qf https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1.md 'Re-run the sweep even if you already ran one on Claude Fable 5: effort level names don'\''t correspond to the same amount of thinking across models.'
qf https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1.md 'The simplest approach is to run requests like these at `high`, the recommended starting point, and move to `xhigh` or `max` only where you'\''ve measured a quality gain'
qf https://platform.claude.com/docs/en/models/fable-5-1/whats-new-fable-5-1.md '**Answers from memory more often at `low` effort.** At the lowest effort level the model calls a search or retrieval tool less often.'
qf https://claude.com/blog/claude-model-and-effort-level-in-claude-code 'At lower effort, it would rather ask you for more context than spend tokens figuring something out on its own.'
qf https://claude.com/blog/claude-model-and-effort-level-in-claude-code 'did it not try hard enough, or did it not know enough?'
````

Expected: one `OK` line per call and no `MISS`. A `MISS` means the page moved since 2026-09-30: re-read it, correct the quotation and its date in the replacement text, and re-run.

- [ ] **Step 5: Run the block.** No hook is touched in this task, so there is no `bash -n` step. Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|verification:'; echo "exit=${PIPESTATUS[0]}"`. Expected: `always-loaded total:` up by 2,061 bytes against the previous commit's run, no `WARN`, `verification: kit sub-block complete`, `verification: done`, `exit=0`.

- [ ] **Step 6: Commit.**

````bash
git add .claude/rules/cbk-conventions-reference.md .claude/rules/orchestration-reference.md .claude/rules/orchestration.md
git commit -F - <<'EOF'
fix(rules): V5 — effort defaults are per model and per surface; thinking by model; the Agent tool takes no effort

The API default is medium on Opus 5.5 and high elsewhere; Claude Code starts Opus 5.5 and
Sonnet 5.5 at medium. The contract says so, says which settings bind where (quoted in the
reference half), calls the table's high a pin pending a sweep, names always-on thinking for
Opus 5.5 and Fable 5.1 and Sonnet 5.5's between_tools, and gives a Sonnet 5.5 finder its
complete brief and remedy line. An Agent-tool call cannot set effort, so a floor's toolkit
agents run at the session's level and the gate line records it. The reference quotes are
re-fetched raw 2026-09-30; the stale Opus 5 re-run figures are replaced.

Closes trace rows: #69/body/T2, #69/body/T3, #69/body/T4, #69/body/T9, #69/body/F1,
#69/body/F2, #69/body/F3, #69/c5881157875/1b, #69/c5881157875/1d, #74/body/3,
critic/18; lands the rule half of #69/c5881157875/1c and part of #69/body/Fq. Decisions: D49, D50.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
````

---

### Task V5.5: The dispatch surfaces: four named, the heading renamed in both halves, no exemplar count (#65/body/2, #65/body/3, #65/c5861166806/3b, #69/body/Fq (the skills quote); none (settled call, spec § Recalibration))

**Files:**
- Modify: `.claude/rules/orchestration.md` (the opening callout; the exemplars sentence; § The three surfaces + resolution order → § The dispatch surfaces + resolution order)
- Modify: `.claude/rules/orchestration-reference.md` (the same heading; its skills quote and date; § When to update this file, the citation)
- Modify: `.claude/rules/cbk-conventions-reference.md` (§ Verification, one check at the kit sentinel)

**Interfaces:**
- Consumes: V5.1's pointer check, which turns a one-sided rename red.
- Produces: The heading `## The dispatch surfaces + resolution order` in both halves. Nothing outside the pair cited the old heading (`grep -rn 'three surfaces' .claude README.md CLAUDE.md` at HEAD: the two headings, the pointer, one citation, and two unrelated knowledge-axis uses).

**Budget:** always-loaded +95 bytes (measured on a copy of `643f7ff` with V5.1–V5.5 applied: 123,679).

- [ ] **Step 1: Write the failing block check.** In `.claude/rules/cbk-conventions-reference.md`, insert these lines immediately before the line `echo "verification: kit sub-block complete"`:

````bash
# The dispatch surfaces carry no count their list can outgrow: the heading is "The dispatch surfaces + resolution order"
# in both halves and every citation follows it (context-builder-kit#65; the pointer check above catches a one-sided rename).
absent grep -rn 'three surfaces + resolution orde[r]\|§ The three surfaces an[d]' .claude/
````

- [ ] **Step 2: Run it against the unfixed files.** Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`. Expected, red. The `absent` check first prints the line(s) it matched (line numbers may differ once V1–V4 have landed); the last two lines are:

````text
VIOLATION (matched above): grep -rn three surfaces + resolution orde[r]\|§ The three surfaces an[d] .claude/
verification: block exited 1
exit=1
````

Record the first of those lines in the PR body's red-first table.

- [ ] **Step 3: Make the change.**

1. In `.claude/rules/orchestration.md`, replace

````text
on every dispatch surface — agent definitions (`.claude/agents/*.md`), ad-hoc Agent-tool subagents, and Workflow `agent()` stages.
````

   with

````text
on every dispatch surface — agent definitions (`.claude/agents/*.md`), ad-hoc Agent-tool subagents, Workflow `agent()` stages and skill frontmatter (`orchestration-reference.md` § The dispatch surfaces + resolution order).
````

2. In `.claude/rules/orchestration.md`, replace

````text
The kit ships two worked exemplars of the ladder:
````

   with

````text
The kit ships worked exemplars of the ladder:
````

3. In `.claude/rules/orchestration.md`, replace

````text
## The three surfaces + resolution order

→ *Moved to* `orchestration-reference.md` § The three surfaces + resolution order *(path-scoped
````

   with

````text
## The dispatch surfaces + resolution order

→ *Moved to* `orchestration-reference.md` § The dispatch surfaces + resolution order *(path-scoped
````

4. In `.claude/rules/orchestration-reference.md`, replace

````text
## The three surfaces + resolution order
````

   with

````text
## The dispatch surfaces + resolution order
````

5. In `.claude/rules/orchestration-reference.md`, replace

````text
("The override applies for the rest of the current turn and is not saved to settings"); `context: fork` runs the skill in a subagent (`agent:` picks the type); `${CLAUDE_EFFORT}` substitutes the active level into the skill body (`code.claude.com/docs/en/skills` § Frontmatter reference and its substitution table, fetched 2026-09-05).
````

   with

````text
("The override applies for the rest of the current turn and isn't saved to settings"); `context: fork` runs the skill in a subagent (`agent:` picks the type); `${CLAUDE_EFFORT}` substitutes the active level into the skill body (`code.claude.com/docs/en/skills` § Frontmatter reference and its substitution table, fetched 2026-09-30).
````

6. In `.claude/rules/orchestration-reference.md`, replace

````text
Resolution (highest wins) — **a dated rail, 2026-09-05**:
````

   with

````text
Resolution (highest wins) — **a dated rail, re-read 2026-09-30**:
````

7. In `.claude/rules/orchestration-reference.md`, replace

````text
re-read § The three surfaces and § Fan-out discipline against the current sub-agents doc after an upgrade.
````

   with

````text
re-read § The dispatch surfaces + resolution order and `orchestration.md` § Fan-out discipline against the current sub-agents doc after an upgrade.
````

- [ ] **Step 4: Re-fetch every quotation this task writes, raw, today.** With `qf` loaded (§ Conventions), run:

````bash
qf https://code.claude.com/docs/en/skills.md 'The override applies for the rest of the current turn and isn'\''t saved to settings'
qf https://code.claude.com/docs/en/sub-agents.md 'Before v2.1.251, `CLAUDE_CODE_SUBAGENT_MODEL` came first in this order and overrode both the per-invocation parameter and the frontmatter, including `model: inherit`'
qf https://code.claude.com/docs/en/sub-agents.md 'to every subagent, teammate, and workflow agent'
````

Expected: one `OK` line per call and no `MISS`. A `MISS` means the page moved since 2026-09-30: re-read it, correct the quotation and its date in the replacement text, and re-run.

- [ ] **Step 5: Run the block.** No hook is touched in this task, so there is no `bash -n` step. Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|verification:'; echo "exit=${PIPESTATUS[0]}"`. Expected: `always-loaded total:` up by 95 bytes against the previous commit's run, no `WARN`, `verification: kit sub-block complete`, `verification: done`, `exit=0`.

- [ ] **Step 6: Commit.**

````bash
git add .claude/rules/cbk-conventions-reference.md .claude/rules/orchestration-reference.md .claude/rules/orchestration.md
git commit -F - <<'EOF'
refactor(rules): V5 — the dispatch surfaces carry no count; skill frontmatter named; the heading renamed in both halves

The contract's opening names all four dispatch surfaces, skill frontmatter included; the
exemplars sentence drops a count its list outgrew; § The three surfaces + resolution order
becomes § The dispatch surfaces + resolution order in both halves with every citation swept,
and the pointer check pins the pair. The skills quote is re-read ("isn't saved").

Closes trace rows: #65/body/2, #65/body/3, #65/c5861166806/3b; part of #69/body/Fq.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
````

---

### Task V5.6: Caps and their changelog, the teammate trap, balanced judge panels, read-only agents (#69/body/T11, #69/body/T12, #69/body/T13, #69/body/F7, #69/body/F10 (rule text), #69/body/S10 (rule text), #69/c5881157875/3a (rule text), #69/c5881157875/3c, #69/c5881157875/3d, #69/c5892402564/Q1, #69/c5892402564/Q2, #69/body/finish-ab/N-arm (rule text, handed from V6), #72/body/4 (rule text, handed from V7), #69/body/Fq (the Opus 5 caps quote); D49, D50, D46)

**Files:**
- Modify: `.claude/rules/orchestration.md` (§ The dispatch-mechanism decision, the Agent team row; § Fan-out discipline, the caps and judge-panel bullets and one new bullet; the exemplars sentence)
- Modify: `.claude/rules/orchestration-reference.md` (§ Generation notes — the sources: the caps bullet and a new teams bullet; § Applied instances › Shipped exemplars, the finish-ab line)
- Modify: `.claude/rules/cbk-conventions-reference.md` (§ Verification, one check at the kit sentinel)

**Interfaces:**
- Consumes: Nothing from earlier clusters. The panel wording is written to hold for today's two-arm `finish-ab.js` (which refuses an unbalanced panel before dispatch, lines 42–48 at HEAD) and for V6's two-to-four-arm rewrite.
- Produces: The bullet `**Read-only agents stay read-only.**` ending `Every find, verify and judge prompt carries the clause.` — a rule V7 (`review-sweep.js` `READ_ONLY`) and V6 (the judges' clause) satisfy in code. The agent-team row keeps its `[record adoption status; …]` slot, which V5.13's project check covers.

**Budget:** always-loaded +1,933 bytes (measured on a copy of `643f7ff` with V5.1–V5.6 applied: 125,612).

The Opus 5 guide's deterministic-caps sentence changed since the kit quoted it: it now reads "…the SDK's `max_budget_usd` (python; typescript: `maxBudgetUsd`) option". The replacement text carries the live form (a stale quote the #69 sweep missed).

- [ ] **Step 1: Write the failing block check.** In `.claude/rules/cbk-conventions-reference.md`, insert these lines immediately before the line `echo "verification: kit sub-block complete"`:

````bash
# Fan-out discipline names the workflow concurrency variable, the teammate trap on the agent-team row, and read-only
# agents (orchestration.md § The dispatch-mechanism decision, § Fan-out discipline; context-builder-kit#69, context-builder-kit#72).
[ ! -f .claude/rules/orchestration.md ] || { grep -q 'CLAUDE_CODE_WORKFLOW_MAX_CONCURRENT_AGENTS' .claude/rules/orchestration.md && grep -q 'launches as a teammate' .claude/rules/orchestration.md && grep -q 'Read-only agents stay read-only' .claude/rules/orchestration.md; } || { echo "orchestration.md lacks the workflow concurrency variable, the teammate trap, or the read-only-agents bullet"; exit 1; }
````

- [ ] **Step 2: Run it against the unfixed files.** Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`. Expected, red. The last two lines are:

````text
orchestration.md lacks the workflow concurrency variable, the teammate trap, or the read-only-agents bullet
verification: block exited 1
exit=1
````

Record the first of those lines in the PR body's red-first table.

- [ ] **Step 3: Make the change.**

1. In `.claude/rules/orchestration.md`, replace

````text
| Agent team | A lead agent + teammates | Long-lived parallel collaborators — [record adoption status; experimental surfaces change fast] |
````

   with

````text
| Agent team | A lead agent + teammates | Long-lived parallel collaborators — [record adoption status; experimental surfaces change fast]. One trap either way: in an interactive session with teams enabled, a subagent spawned with a `name` launches as a teammate unless the call is a fork or passes `isolation` on the call itself — `isolation` in its frontmatter does not prevent it — so a plain subagent gets no `name` |
````

2. In `.claude/rules/orchestration.md`, replace

````text
at 20 concurrent subagents by default (sub-agents § Concurrent subagent limit, v2.1.217+; `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS` raises it). The Workflow runtime queues: up to 16 concurrent agents (fewer on a CPU-limited host), 4,096 items per call, 1,000 agents per run, and a `Large workflow` warning above 25 agents or 1.5M projected tokens (workflows § Behavior and limits, § Cost; the authored-size guideline is `workflowSizeGuideline`). The deterministic caps (`CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`, `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS`, the SDK's `max_budget_usd`; task budgets are not supported on Claude Code) are sourced in the reference half.
````

   with

````text
at 20 concurrent subagents by default (sub-agents § Concurrent subagent limit, v2.1.217+; `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS` raises it; an ultracode session is exempt). The Workflow runtime queues: up to 16 concurrent agents by default (fewer on a CPU-limited host; `CLAUDE_CODE_WORKFLOW_MAX_CONCURRENT_AGENTS` sets 1–256), 4,096 items per call, 1,000 agents per run, and a `Large workflow` warning above 25 agents or 1.5M projected tokens — a size guideline chosen by hand replaces the 25, and an ultracode session shows no warning (workflows § Behavior and limits, § Cost). The authored-size guideline is `workflowSizeGuideline`: `small` under 5 agents, `medium` under 10, `large` under 50. Ultracode changes what a session may launch, not how a dispatch is sized — every agent still names its model and effort — and from Claude Code 2.1.284 the `ultracode` setting leaves the effort level unchanged, so a surface that relied on it for `xhigh` passes `--effort xhigh` itself. The deterministic caps (`CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`, `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS`, the SDK's `max_budget_usd`; task budgets are not supported on Claude Code), the session's WebSearch cap and MCP auto-backgrounding, and the changelog entry behind each number are in the reference half.
````

3. In `.claude/rules/orchestration.md`, replace

````text
- **Judge panels: an even number, half per reading order, and never rank alone.** Measured 2026-09-03, each judge's first pick tracked its own reading order until the panel was balanced; judges score dimensions and report contradicted claims first, ranks are read beside those (`orchestration-reference.md` § Applied instances; `.claude/workflows/finish-ab/`).
````

   with

````text
- **Judge panels: every arm read in every position equally often, and never rank alone.** For two arms that is an even number of judges, half per reading order; for three or four it is a Latin square, so the panel is a multiple of the arm count. Measured 2026-09-03, each judge's first pick tracked its own reading order until the panel was balanced; judges score dimensions and report contradicted claims first, ranks are read beside those (`orchestration-reference.md` § Applied instances; `.claude/workflows/finish-ab/`). A rubric quotes the verdict rule's measure definitions verbatim — a stricter paraphrase split a sister project's panel three to three (context-builder-kit#69).
````

4. In `.claude/rules/orchestration.md`, replace

````text
an even judge panel split by reading order).
````

   with

````text
a judge panel that reads every arm in every position equally often).
````

5. In `.claude/rules/orchestration.md`, replace

````text
The canonical three-rule statement lives in the rough-in skill's `references/research-phase.md` § Grounding existence claims.
````

   with

````text
The canonical three-rule statement lives in the rough-in skill's `references/research-phase.md` § Grounding existence claims.
- **Read-only agents stay read-only.** A finder, verifier or judge never modifies the working tree, not even to restore a file afterwards: an edit restored with its old modification time left a build tool judging a stale artifact fresh, and the next gate failed (context-builder-kit#72). A probe runs on a copy in a scratch directory with its own build cache. A content check cannot certify the tree afterwards — in that incident every tracked file matched `HEAD` by content hash while the build state was stale — so when an agent may have touched the tree, rebuild from clean before the next gate. Every find, verify and judge prompt carries the clause.
````

6. In `.claude/rules/orchestration-reference.md`, replace

````text
"Up to 16 concurrent agents, fewer when Claude Code has fewer CPUs available, including inside a CPU-limited container" and "When a workflow schedules more than 25 agents, or its projected token total passes 1.5 million, its progress line in the task panel below the input box shows a `Large workflow` warning." (`code.claude.com/docs/en/workflows` § Behavior and limits, § Cost); "the deterministic caps are the `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` and `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS` environment variables and the SDK's `max_budget_usd` option. They require Claude Code 2.1.217 or later" (`…/prompting-claude-opus-5` § Controlling subagent spawning); "Task budgets are not supported on Claude Code or Cowork surfaces." (`platform.claude.com/docs/en/build-with-claude/task-budgets` § Feature support).
````

   with

````text
"Up to 16 concurrent agents by default, fewer when Claude Code has fewer CPUs available, including inside a CPU-limited container" and "When a workflow schedules more than 25 agents, or its projected token total passes 1.5 million, its progress line in the task panel below the input box shows a `Large workflow` warning." (`code.claude.com/docs/en/workflows` § Behavior and limits, § Cost, fetched 2026-09-30); "the deterministic caps are the `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` and `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS` environment variables and the SDK's `max_budget_usd` (python; typescript: `maxBudgetUsd`) option. They require Claude Code 2.1.217 or later" (`…/prompting-claude-opus-5` § Controlling subagent spawning, fetched 2026-09-30); "Task budgets are not supported on Claude Code or Cowork surfaces." (`platform.claude.com/docs/en/build-with-claude/task-budgets` § Feature support). Re-read 2026-09-30: "Sessions with ultracode active are exempt: the limit isn't enforced there." (sub-agents § Concurrent subagent limit); the workflow cap takes `CLAUDE_CODE_WORKFLOW_MAX_CONCURRENT_AGENTS` "to a value from 1 to 256, which requires Claude Code v2.1.269 or later" (workflows § Behavior and limits); "If you choose a size guideline yourself, its agent count replaces the 25-agent threshold." and "Sessions with ultracode on don't show the warning" (§ Cost); the size guideline's `small`, `medium` and `large` are "Fewer than 5 agents", "Fewer than 10 agents" and "Fewer than 50 agents", and "The default is `medium`, or `small` when you're signed in on a Pro plan with Claude Code v2.1.271 or later." (§ Set a size guideline). Ultracode and effort: "Turning ultracode on or off with `/effort` or the `ultracode` setting leaves the effort level unchanged. The `--effort ultracode` flag and the Agent SDK `effortLevel: "ultracode"` value turn it on and also set the level to `xhigh`." and "Before v2.1.284, turning on ultracode set the session to `xhigh` effort" (`code.claude.com/docs/en/model-config` § Adjust effort level). From the Claude Code changelog (`raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md`, read 2026-09-30):
  - 2.1.212: "Added a session-wide limit on WebSearch tool calls (default 200, tunable via `CLAUDE_CODE_MAX_WEB_SEARCHES_PER_SESSION`)" and "MCP tool calls running longer than 2 minutes now move to the background automatically" (`CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS`); no later entry through 2.1.285 names either variable. The same release added a 200-subagent-per-session cap, and 2.1.224 "Removed the 200-subagent-per-session spawn cap; long-running sessions no longer refuse new agents (concurrency and depth limits still apply)".
  - 2.1.269: "Added `CLAUDE_CODE_WORKFLOW_MAX_CONCURRENT_AGENTS` (1–256) to raise the Workflow tool's per-run concurrent agent limit for inference-bound fan-outs".
  - 2.1.271: "Changed the default dynamic workflow size to small on Pro plans and lowered the medium size guideline from 15 to 10 agents".
  - 2.1.283 and 2.1.284: interactive sessions start in auto mode when no permission mode is configured — first "on third-party providers or with telemetry off", then "on every plan and provider; `permissions.defaultMode` still overrides it" — and 2.1.284 "Changed Ultracode into its own toggle in `/effort` (Tab, or `/effort ultracode [on|off]`): it no longer forces xhigh effort and stays on at any effort level".
- **Agent teams and named subagents** (`code.claude.com/docs/en/sub-agents` § Subagent names, fetched 2026-09-30) — "In an interactive session with agent teams enabled, a subagent that Claude spawns from the main conversation with a `name` launches as a teammate instead, unless the call is a fork or passes `isolation` on the call itself. An `isolation` value in the subagent's frontmatter doesn't prevent it, and the teammate then runs in the main session's working directory." Teams themselves: "Agent teams are experimental and disabled by default." (`code.claude.com/docs/en/agent-teams`).
````

7. In `.claude/rules/orchestration-reference.md`, replace

````text
- `.claude/workflows/finish-ab/` — executors and judges at the workhorse tier, effort named per call; an even judge panel split by reading order.
````

   with

````text
- `.claude/workflows/finish-ab/` — executors and judges at the workhorse tier, effort named per call; the judge panel reads every arm in every position equally often, and the script refuses an unbalanced panel before dispatch.
````

- [ ] **Step 4: Re-fetch every quotation this task writes, raw, today.** With `qf` loaded (§ Conventions), run:

````bash
qf https://code.claude.com/docs/en/sub-agents.md 'By default, when 20 subagents are running in a session, spawning another with the Agent tool fails with `Concurrent subagent limit reached`, and the error tells Claude not to retry.'
qf https://code.claude.com/docs/en/workflows.md 'Up to 16 concurrent agents by default, fewer when Claude Code has fewer CPUs available, including inside a CPU-limited container'
qf https://code.claude.com/docs/en/workflows.md 'When a workflow schedules more than 25 agents, or its projected token total passes 1.5 million, its progress line in the task panel below the input box shows a `Large workflow` warning.'
qf https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5.md 'the deterministic caps are the `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` and `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS` environment variables and the SDK'\''s `max_budget_usd` (python; typescript: `maxBudgetUsd`) option. They require Claude Code 2.1.217 or later'
qf https://platform.claude.com/docs/en/build-with-claude/task-budgets.md 'Task budgets are not supported on Claude Code or Cowork surfaces.'
qf https://code.claude.com/docs/en/sub-agents.md 'Sessions with ultracode active are exempt: the limit isn'\''t enforced there.'
qf https://code.claude.com/docs/en/workflows.md 'to a value from 1 to 256, which requires Claude Code v2.1.269 or later'
qf https://code.claude.com/docs/en/workflows.md 'If you choose a size guideline yourself, its agent count replaces the 25-agent threshold.'
qf https://code.claude.com/docs/en/workflows.md 'Sessions with ultracode on don'\''t show the warning'
qf https://code.claude.com/docs/en/workflows.md 'Fewer than 5 agents'
qf https://code.claude.com/docs/en/workflows.md 'Fewer than 10 agents'
qf https://code.claude.com/docs/en/workflows.md 'Fewer than 50 agents'
qf https://code.claude.com/docs/en/workflows.md 'The default is `medium`, or `small` when you'\''re signed in on a Pro plan with Claude Code v2.1.271 or later.'
qf https://code.claude.com/docs/en/model-config.md 'Turning ultracode on or off with `/effort` or the `ultracode` setting leaves the effort level unchanged. The `--effort ultracode` flag and the Agent SDK `effortLevel: "ultracode"` value turn it on and also set the level to `xhigh`.'
qf https://code.claude.com/docs/en/model-config.md 'Before v2.1.284, turning on ultracode set the session to `xhigh` effort'
qf https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md 'Added a session-wide limit on WebSearch tool calls (default 200, tunable via `CLAUDE_CODE_MAX_WEB_SEARCHES_PER_SESSION`)'
qf https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md 'MCP tool calls running longer than 2 minutes now move to the background automatically'
qf https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md 'Removed the 200-subagent-per-session spawn cap; long-running sessions no longer refuse new agents (concurrency and depth limits still apply)'
qf https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md 'Added `CLAUDE_CODE_WORKFLOW_MAX_CONCURRENT_AGENTS` (1–256) to raise the Workflow tool'\''s per-run concurrent agent limit for inference-bound fan-outs'
qf https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md 'Changed the default dynamic workflow size to small on Pro plans and lowered the medium size guideline from 15 to 10 agents'
qf https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md 'on third-party providers or with telemetry off'
qf https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md 'on every plan and provider; `permissions.defaultMode` still overrides it'
qf https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md 'Changed Ultracode into its own toggle in `/effort` (Tab, or `/effort ultracode [on|off]`): it no longer forces xhigh effort and stays on at any effort level'
qf https://code.claude.com/docs/en/sub-agents.md 'In an interactive session with agent teams enabled, a subagent that Claude spawns from the main conversation with a `name` launches as a teammate instead, unless the call is a fork or passes `isolation` on the call itself. An `isolation` value in the subagent'\''s frontmatter doesn'\''t prevent it, and the teammate then runs in the main session'\''s working directory.'
qf https://code.claude.com/docs/en/agent-teams.md 'Agent teams are experimental and disabled by default.'
````

Expected: one `OK` line per call and no `MISS`. A `MISS` means the page moved since 2026-09-30: re-read it, correct the quotation and its date in the replacement text, and re-run.

- [ ] **Step 5: Run the block.** No hook is touched in this task, so there is no `bash -n` step. Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|verification:'; echo "exit=${PIPESTATUS[0]}"`. Expected: `always-loaded total:` up by 1,933 bytes against the previous commit's run, no `WARN`, `verification: kit sub-block complete`, `verification: done`, `exit=0`.

- [ ] **Step 6: Commit.**

````bash
git add .claude/rules/cbk-conventions-reference.md .claude/rules/orchestration-reference.md .claude/rules/orchestration.md
git commit -F - <<'EOF'
feat(rules): V5 — caps with their changelog, the teammate trap, panels balanced per position, read-only agents

Fan-out discipline records the workflow concurrency variable, the size guideline's values,
the ultracode exemptions and that ultracode no longer implies xhigh from 2.1.284; the
reference half quotes each and carries the dated changelog entries (2.1.212 rails,
2.1.224, 2.1.269, 2.1.271, the auto-mode default, 2.1.284). The agent-team row states the
named-subagent trap. Judge panels read every arm in every position equally often, and a
rubric quotes the verdict rule's measures verbatim. Read-only agents never touch the tree.

Closes trace rows: #69/body/T11, #69/body/T12, #69/body/T13, #69/body/F7,
#69/c5881157875/3c, #69/c5881157875/3d, #69/c5892402564/Q1, #69/c5892402564/Q2; lands the
rule halves of #69/body/F10, #69/body/S10, #69/c5881157875/3a, #69/body/finish-ab/N-arm
and #72/body/4, and part of #69/body/Fq. Decisions: D49, D50, D46.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
````

---

### Task V5.7: Anti-patterns: a text-only end of turn is a report; over-verification cites the Opus 5.5 guide (#69/body/T5, #69/body/T6, #69/body/F6, #69/body/S5, #69/body/H2 (rule row, handed from V6); D49, D50)

**Files:**
- Modify: `.claude/rules/orchestration.md` (§ Anti-patterns, one row reworded and one added)
- Modify: `.claude/rules/orchestration-reference.md` (§ Generation notes — the sources, the Opus 5.5 bullet)
- Modify: `.claude/rules/cbk-conventions-reference.md` (§ Verification, one check at the kit sentinel)

**Interfaces:**
- Consumes: V5.4's **Opus 5.5 against Opus 5** bullet (the anchor this task appends to).
- Produces: The anti-pattern row `Reading an agent's text-only end of turn as the work being done`, which `workflows.md`'s delegation rule 3 (V5.9) relies on.

**Budget:** always-loaded +589 bytes (measured on a copy of `643f7ff` with V5.1–V5.7 applied: 126,201).

- [ ] **Step 1: Write the failing block check.** In `.claude/rules/cbk-conventions-reference.md`, insert these lines immediately before the line `echo "verification: kit sub-block complete"`:

````bash
# A delegated agent's text-only end of turn is a report, never proof the work is done (orchestration.md § Anti-patterns;
# context-builder-kit#69).
[ ! -f .claude/rules/orchestration.md ] || grep -q 'text-only end of turn' .claude/rules/orchestration.md || { echo "orchestration.md § Anti-patterns lacks the text-only end-of-turn row (context-builder-kit#69)"; exit 1; }
````

- [ ] **Step 2: Run it against the unfixed files.** Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`. Expected, red. The last two lines are:

````text
orchestration.md § Anti-patterns lacks the text-only end-of-turn row (context-builder-kit#69)
verification: block exited 1
exit=1
````

Record the first of those lines in the PR body's red-first table.

- [ ] **Step 3: Make the change.**

1. In `.claude/rules/orchestration.md`, replace

````text
| Self-check prose in a worker prompt ("verify your work", "use a subagent to double-check") | Over-verification on Opus 5 (§ Generation notes); an independent verifier that sees only the artifact and the rubric is the kit's shape |
````

   with

````text
| Self-check prose in a worker prompt ("verify your work", "use a subagent to double-check") | Over-verification, per the Opus 5 guide, whose patterns the Opus 5.5 guide keeps as its starting point (§ Generation notes); an independent verifier that sees only the artifact and the rubric is the kit's shape |
| Reading an agent's text-only end of turn as the work being done | Treat it as a report (the Opus 5.5 guide § Unattended agentic runs): keep the task's parts in a checklist the agent updates, and check the artifact — commits, files, the check task's exit — against it before accepting a delegated result. An unattended run that stops with items open gets a short message naming them, at most two or three times; every headless `/finish` a sister project ran on Opus 5.5 needed one (context-builder-kit#69) |
````

2. In `.claude/rules/orchestration-reference.md`, replace

````text
"Reserve `xhigh` and `max` for work where you've measured a quality gain." (§ Calibrate effort).
````

   with

````text
"Reserve `xhigh` and `max` for work where you've measured a quality gain." (§ Calibrate effort); "Treat a text-only end of turn as a report rather than as proof the task is done. Keep the task's parts in a checklist the model updates, such as a to-do tool or a file" and "stop after two or three automatic continuations on the same task rather than repeating them indefinitely" (§ Unattended agentic runs).
````

- [ ] **Step 4: Re-fetch every quotation this task writes, raw, today.** With `qf` loaded (§ Conventions), run:

````bash
qf https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5.md 'Treat a text-only end of turn as a report rather than as proof the task is done. Keep the task'\''s parts in a checklist the model updates, such as a to-do tool or a file'
qf https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5.md 'stop after two or three automatic continuations on the same task rather than repeating them indefinitely'
````

Expected: one `OK` line per call and no `MISS`. A `MISS` means the page moved since 2026-09-30: re-read it, correct the quotation and its date in the replacement text, and re-run.

- [ ] **Step 5: Run the block.** No hook is touched in this task, so there is no `bash -n` step. Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|verification:'; echo "exit=${PIPESTATUS[0]}"`. Expected: `always-loaded total:` up by 589 bytes against the previous commit's run, no `WARN`, `verification: kit sub-block complete`, `verification: done`, `exit=0`.

- [ ] **Step 6: Commit.**

````bash
git add .claude/rules/cbk-conventions-reference.md .claude/rules/orchestration-reference.md .claude/rules/orchestration.md
git commit -F - <<'EOF'
feat(rules): V5 — a text-only end of turn is a report; over-verification cites the Opus 5.5 guide

The anti-pattern table gains the row for reading an agent's text-only end of turn as the
work done: check commits, files and the check task's exit against a checklist, and resume
an unattended run at most two or three times. The over-verification row notes the Opus 5.5
guide keeps the Opus 5 patterns. The reference half quotes § Unattended agentic runs.

Closes trace rows: #69/body/T5, #69/body/T6, #69/body/F6, #69/body/S5; the rule row of
#69/body/H2. Decisions: D49, D50.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
````

---

### Task V5.8: The triad's second leg is a tracked checklist (#69/body/F8, #69/body/T10, #69/c5859756889/3-C1; D49)

**Files:**
- Modify: `.claude/rules/workflows.md` (§ The triad heading and body; § Task-tracking vs in-head heading and last paragraph)
- Modify: `.claude/rules/tooling.md` (§ Built-in tools (first-line), the task-tracking row)
- Modify: `.claude/rules/orchestration-reference.md` (§ Generation notes — the sources, a new task-tools bullet)
- Modify: `.claude/rules/cbk-conventions-reference.md` (§ Verification, one check at the kit sentinel)

**Interfaces:**
- Consumes: Nothing from other clusters. `tooling.md`'s built-in-tools table is outside V3's and V4's regions.
- Produces: The headings `## The triad: plan mode + a tracked checklist + subagent dispatch` and `## A tracked checklist vs in-head` (no other file cited the old ones). The model scope stated once, in `workflows.md` (C1's corrected form); `tooling.md` points there.

**Budget:** always-loaded +502 bytes (measured on a copy of `643f7ff` with V5.1–V5.8 applied: 126,703).

- [ ] **Step 1: Write the failing block check.** In `.claude/rules/cbk-conventions-reference.md`, insert these lines immediately before the line `echo "verification: kit sub-block complete"`:

````bash
# The triad's second leg is a tracked checklist: the task tools are not offered on current models by default, so no rule
# leans on "the harness's task list" (workflows.md § The triad; context-builder-kit#69).
absent grep -n "the harness's task lis[t]" .claude/rules/workflows.md
````

- [ ] **Step 2: Run it against the unfixed files.** Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`. Expected, red. The `absent` check first prints the line(s) it matched (line numbers may differ once V1–V4 have landed); the last two lines are:

````text
VIOLATION (matched above): grep -n the harness's task lis[t] .claude/rules/workflows.md
verification: block exited 1
exit=1
````

Record the first of those lines in the PR body's red-first table.

- [ ] **Step 3: Make the change.**

1. In `.claude/rules/workflows.md`, replace

````text
## The triad: plan-mode + task-tracking + subagent dispatch
````

   with

````text
## The triad: plan mode + a tracked checklist + subagent dispatch
````

2. In `.claude/rules/workflows.md`, replace

````text
2. **Task-tracking** (the harness's task list) decomposes the plan into discrete trackable units. Each task is a step toward done. You can't add unbounded work — the task list IS the work surface.
````

   with

````text
2. **A tracked checklist** decomposes the plan into discrete trackable units: the harness's task tools where the model is offered them, otherwise the plan file or a checklist file the agent updates, as the Opus 5.5 guide suggests. Each item is a step toward done. You can't add unbounded work — the checklist IS the work surface. From Claude Code 2.1.233 the task tools are not offered on Opus 4.8, Sonnet 5, Fable 5, Mythos 5 or any newer model unless `CLAUDE_CODE_ENABLE_TODO_TOOLS=1` is set (`orchestration-reference.md` § Generation notes — the sources).
````

3. In `.claude/rules/workflows.md`, replace

````text
The triad works because: plan mode prevents wrong directions; task-tracking enforces discipline (visible scope, completion gating);
````

   with

````text
The triad works because: plan mode prevents wrong directions; the checklist enforces discipline (visible scope, completion gating);
````

4. In `.claude/rules/workflows.md`, replace

````text
the task list is the in-session decomposition;
````

   with

````text
the checklist is the in-session decomposition;
````

5. In `.claude/rules/workflows.md`, replace

````text
## Task-tracking vs in-head
````

   with

````text
## A tracked checklist vs in-head
````

6. In `.claude/rules/workflows.md`, replace

````text
After completing a tracked task, **mark it completed immediately**. Don't batch updates. The task list is a live status surface for the operator; lag = confusion.
````

   with

````text
After completing a tracked item, **mark it completed immediately**, in the task tools or in the file. Don't batch updates. The checklist is a live status surface for the operator; lag = confusion.
````

7. In `.claude/rules/tooling.md`, replace

````text
| Task-tracking tools | Track multi-step work — see [`workflows.md`](workflows.md) |
````

   with

````text
| Task-tracking tools, or a checklist file where the model is not offered them | Track multi-step work — see [`workflows.md`](workflows.md) § A tracked checklist vs in-head |
````

8. In `.claude/rules/orchestration-reference.md`, replace

````text
- **Subagent effort inheritance** —
````

   with

````text
- **The task tools** (the Claude Code changelog, `raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md`, read 2026-09-30) — 2.1.233: "Todo/task-tracking tools (TaskCreate/Get/Update/List, TodoWrite) are no longer available on Opus 4.8, Sonnet 5, Fable 5, Mythos 5, and newer models; set `CLAUDE_CODE_ENABLE_TODO_TOOLS=1` to bring them back"; 2.1.268 restated it as an allowlist: "offered only on Claude 3.x, Opus 4.0–4.7, Sonnet 4.0–4.6, Haiku 4.5".
- **Subagent effort inheritance** —
````

- [ ] **Step 4: Re-fetch every quotation this task writes, raw, today.** With `qf` loaded (§ Conventions), run:

````bash
qf https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md 'Todo/task-tracking tools (TaskCreate/Get/Update/List, TodoWrite) are no longer available on Opus 4.8, Sonnet 5, Fable 5, Mythos 5, and newer models; set `CLAUDE_CODE_ENABLE_TODO_TOOLS=1` to bring them back'
qf https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md 'offered only on Claude 3.x, Opus 4.0–4.7, Sonnet 4.0–4.6, Haiku 4.5'
````

Expected: one `OK` line per call and no `MISS`. A `MISS` means the page moved since 2026-09-30: re-read it, correct the quotation and its date in the replacement text, and re-run.

- [ ] **Step 5: Run the block.** No hook is touched in this task, so there is no `bash -n` step. Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|verification:'; echo "exit=${PIPESTATUS[0]}"`. Expected: `always-loaded total:` up by 502 bytes against the previous commit's run, no `WARN`, `verification: kit sub-block complete`, `verification: done`, `exit=0`.

- [ ] **Step 6: Commit.**

````bash
git add .claude/rules/cbk-conventions-reference.md .claude/rules/orchestration-reference.md .claude/rules/tooling.md .claude/rules/workflows.md
git commit -F - <<'EOF'
fix(rules): V5 — the triad's task-tracking leg is a tracked checklist

The task tools are not offered on Opus 4.8, Sonnet 5, Fable 5, Mythos 5 or newer models
since Claude Code 2.1.233, so the triad no longer leans on the harness's task list: its leg
is a tracked checklist — the tools where offered, else the plan file or a checklist file.
tooling.md's row points at the section; the reference half quotes 2.1.233 and 2.1.268.

Closes trace rows: #69/body/F8, #69/body/T10, #69/c5859756889/3-C1. Decision: D49.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
````

---

### Task V5.9: Delegating implementation: why `/finish` is inline, when delegation pays, six rules; the replay recorded (#69/body/S1, #69/body/S2, #69/body/S3, #69/body/S6 (rule text), #69/body/S7, #69/body/S8 (rule text), #69/body/S9, #69/body/S11, #69/body/T14, #69/c5881157875/5, #69/body/H3 (quote), #69/body/H4 (quote), critic/16, critic/17; D49, D50)

**Files:**
- Modify: `.claude/rules/workflows.md` (§ Subagent dispatch, a new paragraph after **Ground the fan-out.**)
- Modify: `.claude/rules/orchestration-reference.md` (§ Generation notes — the sources, three bullets; § Applied instances, a 2026-09-25 bullet)
- Modify: `.claude/rules/cbk-conventions-reference.md` (§ Verification, one check at the kit sentinel)

**Interfaces:**
- Consumes: V5.7's anti-pattern row (rule 3); V5.6's teammate trap (rule 6); V5.8's heading `## A tracked checklist vs in-head` (the insertion anchor).
- Produces: The paragraph `**Delegating implementation — \`/finish\` does not, and that is measured, not inherited.**`. The 2026-09-25 applied-instance bullet with its seven harness lessons — the rule text V6's runner implements (lessons 2–4).

**Budget:** always-loaded +1,523 bytes (measured on a copy of `643f7ff` with V5.1–V5.9 applied: 128,226).

**Sanitization.** The replay is a public sister project's; kit text calls it "a sister project" and cites `context-builder-kit#69`, never the repository, its issue number, its paths or its stack. The figures ($294.92 total, $52.44 against $47.70, 33 minutes against 18 on the first pass, −33% then +26% for `medium`) were read from that project's committed `result.md` on 2026-09-30. Per critic/16 the kit ships neither the replay records, the `/finish`-at-`medium` row, the arm protocol, the fixtures mise task nor the reviewer-memory retirement; per critic/17 every sentence is re-authored (no "measured here").

- [ ] **Step 1: Write the failing block check.** In `.claude/rules/cbk-conventions-reference.md`, insert these lines immediately before the line `echo "verification: kit sub-block complete"`:

````bash
# Why /finish implements inline, and the rules for anyone who delegates implementation, are stated where dispatch is
# decided (workflows.md § Subagent dispatch; context-builder-kit#69).
grep -q 'Delegating implementation' .claude/rules/workflows.md || { echo "workflows.md § Subagent dispatch lacks the delegating-implementation clause (context-builder-kit#69)"; exit 1; }
````

- [ ] **Step 2: Run it against the unfixed files.** Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`. Expected, red. The last two lines are:

````text
workflows.md § Subagent dispatch lacks the delegating-implementation clause (context-builder-kit#69)
verification: block exited 1
exit=1
````

Record the first of those lines in the PR body's red-first table.

- [ ] **Step 3: Make the change.**

1. In `.claude/rules/workflows.md`, replace

````text
the full three-rule statement lives in the rough-in skill's `references/research-phase.md` § Grounding existence claims.

## A tracked checklist vs in-head
````

   with

````text
the full three-rule statement lives in the rough-in skill's `references/research-phase.md` § Grounding existence claims.

**Delegating implementation — `/finish` does not, and that is measured, not inherited.** `/finish` implements inline and reviews the whole branch once. Anthropic's cost guide measured the general case: when the work is one dependent chain or fits in one context, an orchestrator pays for a plan, a handoff and a merge that a single model gets for free, and the coordinator's model alone at lower effort came out ahead. A sister project's replay of one `/finish` issue found subagent-driven execution better on no measure, for 10% more cost and nearly twice the time (context-builder-kit#69; both are quoted in `orchestration-reference.md`). Delegation pays when a long plan outlives a compacted context, when each task needs its own review gate, or when the main loop runs the expensive tier. Whoever delegates implementation keeps six rules: (1) every implementer names its model and effort; (2) never two writers on one tree, and a subagent's worktree branches from the default branch unless `worktree.baseRef` is `"head"`, so set it or the implementer builds on the wrong base; (3) an implementer's text-only end of turn is a report, checked against the checklist; (4) a task reviewer gets the task's brief as well as its diff; (5) rulings and triage stay in the main loop (never delegate the decision, above); (6) with agent teams enabled, a plain subagent gets no `name`. Borrow an execution plugin's mechanics where its measurements justify them; do not wrap a user plugin whose loop can change under the project.

## A tracked checklist vs in-head
````

2. In `.claude/rules/orchestration-reference.md`, replace

````text
- **Fable 5.1 at `low`** —
````

   with

````text
- **When delegation doesn't pay** (the cost page § Orchestrator strategy: delegate bulk work, the paragraph that opens "When delegation doesn't pay.", fetched 2026-09-30) — "When the work is one dependent chain, or fits in a single context, the orchestrator pays for a plan, a handoff, and a merge that a single model gets for free. In every such case measured, the coordinator's model alone at lower effort came out ahead." Anthropic's own measurement behind `/finish` implementing inline (`workflows.md` § Subagent dispatch).
- **Subagent-driven execution, measured elsewhere** — a practitioner's measurement, not guidance: "With a frontier model, Native Execution is about twice as fast and half as expensive as Subagent-Driven Development" (the Superpowers plugin's author, `https://blog.fsck.com/2026/09/21/superpowers-6.4/`, 2026-09-21, read 2026-09-30); the same paragraph finds builds without that plugin's implementation skills "significantly buggier", so the finding is about how a plan is executed, not whether one is kept. Of a separate evaluator, Anthropic: "It is worth the cost when the task sits beyond what the current model does reliably solo" (`https://www.anthropic.com/engineering/harness-design-long-running-apps`, 2026-03-24, read 2026-09-30).
- **Worktrees, headless runs and permission rules** (fetched 2026-09-30) — "Subagent worktrees use the same base branch as `--worktree`, so they branch from your repository's default branch unless `worktree.baseRef` is set to `"head"`." (`code.claude.com/docs/en/worktrees`); "When you continue an earlier conversation with `--continue` or `--resume`, the run reports the conversation's whole total, earlier runs' spend included" (`code.claude.com/docs/en/headless`); for `--max-budget-usd`, "When you return to a conversation with `--continue` or `--resume`, totals restored from earlier runs don't count toward it." (`code.claude.com/docs/en/cli-reference`); of a `Bash(git push *)` deny rule, "A push written another way, such as `git -C . push`, isn't matched" (`code.claude.com/docs/en/permissions`).
- **Fable 5.1 at `low`** —
````

3. In `.claude/rules/orchestration-reference.md`, replace

````text
Two harness lessons: an even panel split by reading order; the floor's real coverage is measurable only from a session that can dispatch agents.
````

   with

````text
Two harness lessons: an even panel split by reading order; the floor's real coverage is measurable only from a session that can dispatch agents.
- **2026-09-25 — a sister project's `/finish` dry fire: subagent-driven execution not adopted there** (harvested as context-builder-kit#69; not re-measured in the kit). A replay of one merged issue from the commit before it, in two replicates, every arm a headless `claude -p` session on the workhorse tier, the verdict rule committed before any arm ran. Replicate 1: inline at `high`, inline at `medium`, and subagent-driven at `high` (a brief per task, serial implementers, a task reviewer handed the brief as well as the diff, a rulings ledger, a capped fix loop), six workhorse judges in a Latin square; replicate 2: the two inline arms, four judges; $294.92 for the whole evaluation. Subagent-driven execution beat inline on no measure, cost 10% more ($52.44 against $47.70) and took nearly twice as long on its first pass; `medium` lost to `high` on nothing, its cost went both ways (33% less, then 26% more) and the ranks split — that project's data point, not a default here. Harness lessons: (1) every unattended arm ended early and needed one continuation; (2) a resumed `claude -p` run reports the conversation's whole total, so never sum totals across invocations; (3) `--max-budget-usd` does not count restored spend, so a continuation gets only what the cap has left; (4) deny every write-capable MCP server as well as `git push` and `gh` writes, and add `git * push` so `git -C . push` is caught; (5) read the arms' transcripts for reads past the base rather than diffing against a reference the same model wrote; (6) a rubric quotes the verdict rule's measure definitions verbatim; (7) a rubric reused across replicates does not state the arm count. The kit ships neither the run's records nor its subagent-driven arm protocol; the mechanics are the ones named here.
````

- [ ] **Step 4: Re-fetch every quotation this task writes, raw, today.** With `qf` loaded (§ Conventions), run:

````bash
qf https://platform.claude.com/docs/en/about-claude/models/optimizing-for-cost-and-intelligence.md 'When delegation doesn'\''t pay.'
qf https://platform.claude.com/docs/en/about-claude/models/optimizing-for-cost-and-intelligence.md 'When the work is one dependent chain, or fits in a single context, the orchestrator pays for a plan, a handoff, and a merge that a single model gets for free. In every such case measured, the coordinator'\''s model alone at lower effort came out ahead.'
qf https://blog.fsck.com/2026/09/21/superpowers-6.4/ 'With a frontier model, Native Execution is about twice as fast and half as expensive as Subagent-Driven Development'
qf https://blog.fsck.com/2026/09/21/superpowers-6.4/ 'significantly buggier'
qf https://www.anthropic.com/engineering/harness-design-long-running-apps 'It is worth the cost when the task sits beyond what the current model does reliably solo'
qf https://code.claude.com/docs/en/worktrees.md 'Subagent worktrees use the same base branch as `--worktree`, so they branch from your repository'\''s default branch unless `worktree.baseRef` is set to `"head"`.'
qf https://code.claude.com/docs/en/headless.md 'When you continue an earlier conversation with `--continue` or `--resume`, the run reports the conversation'\''s whole total, earlier runs'\'' spend included'
qf https://code.claude.com/docs/en/cli-reference.md 'When you return to a conversation with `--continue` or `--resume`, totals restored from earlier runs don'\''t count toward it.'
qf https://code.claude.com/docs/en/permissions.md 'A push written another way, such as `git -C . push`, isn'\''t matched'
````

Expected: one `OK` line per call and no `MISS`. A `MISS` means the page moved since 2026-09-30: re-read it, correct the quotation and its date in the replacement text, and re-run.

- [ ] **Step 5: Run the block.** No hook is touched in this task, so there is no `bash -n` step. Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|verification:'; echo "exit=${PIPESTATUS[0]}"`. Expected: `always-loaded total:` up by 1,523 bytes against the previous commit's run, no `WARN`, `verification: kit sub-block complete`, `verification: done`, `exit=0`.

- [ ] **Step 6: Commit.**

````bash
git add .claude/rules/cbk-conventions-reference.md .claude/rules/orchestration-reference.md .claude/rules/workflows.md
git commit -F - <<'EOF'
feat(rules): V5 — delegating implementation: /finish stays inline, measured; six rules for whoever delegates

workflows.md § Subagent dispatch records why /finish implements inline — Anthropic's cost
guide ("When delegation doesn't pay") and a sister project's replay (subagent-driven better
on no measure, 10% dearer, nearly twice as long) — when delegation pays, and six rules for
anyone who delegates implementation. The reference half quotes the cost page, the practitioner
measurement and Anthropic's evaluator note, the worktree, headless, cli and permission
sentences, and records the 2026-09-25 replay with its seven harness lessons. Nothing from
the replay ships but the description (critic/16, critic/17).

Closes trace rows: #69/body/S1, #69/body/S2, #69/body/S3, #69/body/S7, #69/body/S9,
#69/body/S11, #69/body/T14, #69/c5881157875/5, critic/16, critic/17; the rule halves of
#69/body/S6, #69/body/S8, #69/body/H3, #69/body/H4. Decisions: D49, D50.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
````

---

### Task V5.10: The floor: a workflow agent has no Agent tool (probe P2) (#69/body/T15, #69/body/S4, #69/c5859756889/3-C2, #69/c5859756889/3-C3, #69/body/H1 (rule text, handed from V6); D49, D45)

**Files:**
- Modify: `.claude/rules/pr-review.md` (§ The floor — two skills, actually invoked: the Agent-tool sentence only)
- Modify: `.claude/rules/orchestration-reference.md` (§ Generation notes — the sources, a new bullet before **Volume**)
- Modify: `.claude/rules/cbk-conventions-reference.md` (§ Verification, one check at the kit sentinel)

**Interfaces:**
- Consumes: Probe P2's result (Step 0). The sentence at HEAD is intact: V7 edits other parts of `pr-review.md` only after this cluster.
- Produces: The clause `a workflow agent has none at any depth` in § The floor, which V7's craft-rule pointer names (handed) and V6's `run-arms-headless.py` docstring cites.

**Budget:** always-loaded +241 bytes (measured on a copy of `643f7ff` with V5.1–V5.10 applied: 128,467).

- [ ] **Step 0: Run probe P2 from the MAIN session.** Write this script to a scratch path outside the repository — `p=$(mktemp -d)/probe-p2.js` — then call the **Workflow** tool with `scriptPath` set to that file, from the repository root (the launch-root guard requires it):
```js
export const meta = {
  name: "probe-p2",
  description: "Probe P2: does a workflow agent have an Agent tool, plain and worktree-isolated",
  phases: [{ title: "Probe", detail: "two agents list their own tools" }],
}

const SCHEMA = {
  type: "object",
  required: ["tools", "agent_tool"],
  properties: {
    tools: { type: "array", items: { type: "string" }, description: "the exact names of every tool you have, as your tool list names them" },
    agent_tool: { type: "boolean", description: "true if and only if a tool named Agent is in that list" },
  },
}
const ask = "List the exact name of every tool available to you, as your own tool list names them. Do not call any tool other than to read your tool list; do not modify any file. Report whether a tool named Agent is among them."
phase("Probe")
const [plain, isolated] = await parallel([
  () => agent(ask, { label: "p2:plain", phase: "Probe", model: "sonnet", effort: "low", schema: SCHEMA }),
  () => agent(ask, { label: "p2:worktree", phase: "Probe", model: "sonnet", effort: "low", isolation: "worktree", schema: SCHEMA }),
])
log(`probe-p2: plain agent_tool=${plain?.agent_tool} tools=${(plain?.tools ?? []).join(",")}`)
log(`probe-p2: worktree agent_tool=${isolated?.agent_tool} tools=${(isolated?.tools ?? []).join(",")}`)
return { plain, isolated }
```
Record `claude --version` beside the result. Expected (outcome A, what two targets observed on 2.1.282 and 2.1.284): both agents report `agent_tool=false` and no `Agent` in `tools`, on `2.1.285 (Claude Code)`. Then run Steps 1–6 as written. If the printed version is not 2.1.285, write the printed version wherever the sentences below say `2.1.285`. **Outcome B** (either agent reports an `Agent` tool): run Steps 1–6 with these four substitutions, and record the outcome in the PR body's probe table (P2).

  - Step 1's check line (keep its two comment lines) becomes:

    ````bash
    grep -q 'A workflow agent had an Agent tool' .claude/rules/orchestration-reference.md || { echo "orchestration-reference.md does not record probe P2"; exit 1; }
    ````

    and Step 2's expected first line is `orchestration-reference.md does not record probe P2`.
  - Step 3 edit 1 replaces only `verified 2026-09-06) — and its dropped dimensions` in `pr-review.md` with `read 2026-09-30) — and its dropped dimensions` (the date re-stamp; the workflow-agent clause is not written).
  - Step 3 edit 2 keeps its old text, `- **Volume** —`, and its new text becomes:

    ````text
    - **A workflow agent had an Agent tool** (a probe from the main session on Claude Code 2.1.285, 2026-09-30; context-builder-kit#69), so a floor inside a workflow agent can fan out. The sub-agents page withholds the tool from Agent-tool subagents only at the depth limit — "At the depth limit, Claude Code withholds the `Agent` tool from every subagent except a fork" (§ Let subagents spawn their own subagents) — and says of workflow agents only that "Agents that other features run, such as workflow agents and agent team teammates, follow their own limits instead." (§ Concurrent subagent limit). Two targets observed the opposite on 2.1.282 and 2.1.284. Re-probe after a harness upgrade.
    - **Volume** —
    ````
  - Step 6's commit subject becomes `fix(rules): V5 — probe P2 recorded: a workflow agent had an Agent tool on 2.1.285`, and its first paragraph says that probe P2 found an `Agent` tool, so § The floor gains no clause and only its depth source is re-dated. The trace rows it closes are unchanged.

- [ ] **Step 1: Write the failing block check.** In `.claude/rules/cbk-conventions-reference.md`, insert these lines immediately before the line `echo "verification: kit sub-block complete"`:

````bash
# The floor names every context without an Agent tool — the spawn-depth limit and a workflow agent at any depth (probe P2,
# 2026-09-30) — so a skill run there is recorded as invoked, not covered (pr-review.md § The floor; context-builder-kit#69).
grep -q 'a workflow agent has none at any depth' .claude/rules/pr-review.md || { echo "pr-review.md § The floor does not name the workflow agent among the contexts with no Agent tool (probe P2)"; exit 1; }
````

- [ ] **Step 2: Run it against the unfixed files.** Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`. Expected, red. The last two lines are:

````text
pr-review.md § The floor does not name the workflow agent among the contexts with no Agent tool (probe P2)
verification: block exited 1
exit=1
````

Record the first of those lines in the PR body's red-first table.

- [ ] **Step 3: Make the change.**

1. In `.claude/rules/pr-review.md`, replace

````text
— a subagent at the spawn-depth limit has no Agent tool (three layers below the main conversation by default; `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` — `https://code.claude.com/docs/en/sub-agents`, verified 2026-09-06) — and its dropped dimensions
````

   with

````text
— a subagent at the spawn-depth limit has no Agent tool (three layers below the main conversation by default; `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` — `https://code.claude.com/docs/en/sub-agents`, read 2026-09-30), and a workflow agent has none at any depth (a probe on Claude Code 2.1.285, 2026-09-30 — `orchestration-reference.md` § Generation notes — the sources), so a floor that must fan out from an unattended run is a headless `claude -p` session — and its dropped dimensions
````

2. In `.claude/rules/orchestration-reference.md`, replace

````text
- **Volume** —
````

   with

````text
- **A workflow agent has no Agent tool** (a probe from the main session on Claude Code 2.1.285, 2026-09-30; context-builder-kit#69). A plain and a worktree-isolated workflow agent each reported no `Agent` tool. The sub-agents page withholds the tool from Agent-tool subagents only at the depth limit — "At the depth limit, Claude Code withholds the `Agent` tool from every subagent except a fork" (§ Let subagents spawn their own subagents) — and says of workflow agents only that "Agents that other features run, such as workflow agents and agent team teammates, follow their own limits instead." (§ Concurrent subagent limit). So a review floor or an A/B arm that must dispatch runs as a headless `claude -p` session. Re-probe after a harness upgrade.
- **Volume** —
````

- [ ] **Step 4: Re-fetch every quotation this task writes, raw, today.** With `qf` loaded (§ Conventions), run:

````bash
qf https://code.claude.com/docs/en/sub-agents.md 'At the depth limit, Claude Code withholds the `Agent` tool from every subagent except a fork'
qf https://code.claude.com/docs/en/sub-agents.md 'Agents that other features run, such as workflow agents and agent team teammates, follow their own limits instead.'
qf https://code.claude.com/docs/en/sub-agents.md 'By default, a subagent can spawn subagents of its own, up to three layers below the main conversation.'
````

Expected: one `OK` line per call and no `MISS`. A `MISS` means the page moved since 2026-09-30: re-read it, correct the quotation and its date in the replacement text, and re-run.

- [ ] **Step 5: Run the block.** No hook is touched in this task, so there is no `bash -n` step. Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|verification:'; echo "exit=${PIPESTATUS[0]}"`. Expected: `always-loaded total:` up by 241 bytes against the previous commit's run, no `WARN`, `verification: kit sub-block complete`, `verification: done`, `exit=0`.

- [ ] **Step 6: Commit.**

````bash
git add .claude/rules/cbk-conventions-reference.md .claude/rules/orchestration-reference.md .claude/rules/pr-review.md
git commit -F - <<'EOF'
fix(rules): V5 — the floor names a workflow agent among the contexts without an Agent tool (probe P2)

Probe P2, run from the main session on Claude Code 2.1.285 on 2026-09-30, found no Agent
tool in a plain or a worktree-isolated workflow agent. pr-review.md § The floor adds that
context beside the spawn-depth limit — so a floor that must fan out from an unattended run
is a headless claude -p session — and re-dates the depth source. The reference half records
the probe and quotes the depth-limit sentence exactly (not the paraphrase an earlier draft
carried).

Closes trace rows: #69/body/T15, #69/body/S4, #69/c5859756889/3-C2, #69/c5859756889/3-C3;
the rule half of #69/body/H1. Decisions: D49, D45.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
````

---

### Task V5.11: `/simplify`'s history from the changelog replaces a local spot check (#69/body/F9 (rule half); D49)

**Files:**
- Modify: `.claude/rules/simplification.md` (§ Plugin, first paragraph)
- Modify: `.claude/rules/cbk-conventions-reference.md` (§ Verification, two check lines at the kit sentinel)

**Interfaces:**
- Consumes: V3's re-check of review/claude-code/60 edits `simplification.md` § What the simplification pass does, not § Plugin; if V3 touched § Plugin, reconcile before this edit.
- Produces: § Plugin as the one home of `/simplify`'s identity: V3's `settings.json` `_comment_enabledPlugins` and V10's `README.md` line point at it instead of restating the 2.1.263 spot check (handed).

**Budget:** always-loaded +508 bytes (measured on a copy of `643f7ff` with V5.1–V5.11 applied: 128,975).

- [ ] **Step 1: Write the failing block check.** In `.claude/rules/cbk-conventions-reference.md`, insert these lines immediately before the line `echo "verification: kit sub-block complete"`:

````bash
# /simplify's identity is its changelog history, not one machine's spot check (simplification.md § Plugin;
# context-builder-kit#69): the 2.1.154 cleanup-only entry is named and the old spot check is gone.
absent grep -n 'as of 2\.1\.26[3]' .claude/rules/simplification.md
grep -q '2\.1\.154' .claude/rules/simplification.md || { echo "simplification.md § Plugin does not carry /simplify's changelog history (2.1.63, 2.1.147, 2.1.152, 2.1.154)"; exit 1; }
````

- [ ] **Step 2: Run it against the unfixed files.** Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`. Expected, red. The `absent` check first prints the line(s) it matched (line numbers may differ once V1–V4 have landed); the last two lines are:

````text
VIOLATION (matched above): grep -n as of 2\.1\.26[3] .claude/rules/simplification.md
verification: block exited 1
exit=1
````

Record the first of those lines in the PR body's red-first table.

- [ ] **Step 3: Make the change.**

1. In `.claude/rules/simplification.md`, replace

````text
`/simplify` is a Claude Code skill, not a project dependency — bundled with Claude Code as of 2.1.263 (2026-09-06, verified against the installed CLI bundle; re-verify after harness upgrades), or plugin-installed if your harness ships it that way. The skill owns the actual simplification logic; this file documents how the project uses it.
````

   with

````text
`/simplify` is a Claude Code skill, not a project dependency — bundled with Claude Code, or plugin-installed if your harness ships it that way. The skill owns the actual simplification logic; this file documents how the project uses it. Its history, from the Claude Code changelog (`https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md`, read 2026-09-30): added as a bundled command in 2.1.63; in 2.1.147 "Renamed `/simplify` to `/code-review`", and "The old cleanup-and-fix behavior has been removed"; back in 2.1.152 as a call to `/code-review --fix`; and from 2.1.154 "`/simplify` now runs a cleanup-only review (reuse, simplification, efficiency, altitude) and applies the fixes". No entry through 2.1.285 changes it again. A harness whose `/simplify` differs is checked against this history before the floor relies on it.
````

- [ ] **Step 4: Re-fetch every quotation this task writes, raw, today.** With `qf` loaded (§ Conventions), run:

````bash
qf https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md 'Renamed `/simplify` to `/code-review`'
qf https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md 'The old cleanup-and-fix behavior has been removed'
qf https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md '`/simplify` now runs a cleanup-only review (reuse, simplification, efficiency, altitude) and applies the fixes'
qf https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md 'Added `/simplify` and `/batch` bundled slash commands'
qf https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md '`/simplify` now invokes `/code-review --fix`'
````

Expected: one `OK` line per call and no `MISS`. A `MISS` means the page moved since 2026-09-30: re-read it, correct the quotation and its date in the replacement text, and re-run.

- [ ] **Step 5: Run the block.** No hook is touched in this task, so there is no `bash -n` step. Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|verification:'; echo "exit=${PIPESTATUS[0]}"`. Expected: `always-loaded total:` up by 508 bytes against the previous commit's run, no `WARN`, `verification: kit sub-block complete`, `verification: done`, `exit=0`.

- [ ] **Step 6: Commit.**

````bash
git add .claude/rules/cbk-conventions-reference.md .claude/rules/simplification.md
git commit -F - <<'EOF'
fix(rules): V5 — /simplify's changelog history replaces a local 2.1.263 spot check

simplification.md § Plugin records /simplify from the Claude Code changelog — added in
2.1.63, renamed to /code-review in 2.1.147, back as /code-review --fix in 2.1.152,
cleanup-only since 2.1.154, unchanged through 2.1.285 — instead of one machine's bundle
check. The settings comment and the README point here (V3, V10).

Closes trace rows: the rule half of #69/body/F9. Decision: D49.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
````

---

### Task V5.12: Grounding rule 4: which binary a tool name resolves to; the rule count swept (#68/body/3, #68/c5892402074/3-count; none)

**Files:**
- Modify: `.claude/skills/rough-in/references/research-phase.md` (§ Grounding existence claims — the count and rule 4)
- Modify: `.claude/skills/rough-in/references/failure-modes.md` (§ 13, **Defense**)
- Modify: `.claude/skills/framing/references/research-phase.md` (§ Grounding existence claims, the closing parenthesis)
- Modify: `.claude/skills/rough-in/references/test_cases.md` (Test 8, one success criterion)
- Modify: `.claude/rules/orchestration.md` (§ Fan-out discipline, **Ground existence claims.**)
- Modify: `.claude/rules/workflows.md` (§ Subagent dispatch, **Ground the fan-out.**)
- Modify: `.claude/rules/cbk-conventions-reference.md` (§ Verification, two check lines at the kit sentinel)

**Interfaces:**
- Consumes: Nothing from other clusters. V7 later edits `research-phase.md` elsewhere (#74 item 2) and `test_cases.md` with its own criterion; this task's anchors are rule 3's closing sentence and Test 8's third criterion.
- Produces: Rule `4. **Check which binary a tool resolves …**` in rough-in's `research-phase.md`; no citing site states a count. Three unrelated "Three rules" hits (blueprint `stack-decisions.md`, `architecture.md`, `detect-forked-agent-memory.sh`) are untouched.

**Budget:** always-loaded +294 bytes (measured on a copy of `643f7ff` with V5.1–V5.12 applied: 129,269).

- [ ] **Step 0: Reproduce the failure the rule names.** Run: `bash -c 'help type' | grep -A1 -- '-P'` — expected `-P	force a PATH search for each NAME, even if it is an alias,` and the next line; then, in the interactive shell, `type -a grep | head -1` and `bash -c 'type -a grep' | head -1`. On the planning machine the first printed `grep is a function` and the second `grep is /usr/bin/grep` — the shadowing rule 4 exists for. Record both lines in the PR body.

- [ ] **Step 1: Write the failing block check.** In `.claude/rules/cbk-conventions-reference.md`, insert these lines immediately before the line `echo "verification: kit sub-block complete"`:

````bash
# Grounding existence claims has four rules; rule 4 checks a tool's behaviour against the binary the code's own context
# resolves (the rough-in skill's references/research-phase.md; context-builder-kit#68). No citing site restates a count.
grep -q '^4\. \*\*Check which binary a tool resolves' .claude/skills/rough-in/references/research-phase.md || { echo "rough-in research-phase.md § Grounding existence claims lacks rule 4 (which binary a tool resolves to)"; exit 1; }
absent grep -rn 'three-rule statemen[t]\|discipline has three rule[s]\|the three rules i[n]' .claude/rules .claude/skills
````

- [ ] **Step 2: Run it against the unfixed files.** Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`. Expected, red. The last two lines are:

````text
rough-in research-phase.md § Grounding existence claims lacks rule 4 (which binary a tool resolves to)
verification: block exited 1
exit=1
````

Record the first of those lines in the PR body's red-first table.

- [ ] **Step 3: Make the change.**

1. In `.claude/skills/rough-in/references/research-phase.md`, replace

````text
The discipline has three rules:
````

   with

````text
The discipline has four rules:
````

2. In `.claude/skills/rough-in/references/research-phase.md`, replace

````text
If a grounding document exists, drafts cite it for existence claims; a fresh grep is for facts the corpus doesn't cover.
````

   with

````text
If a grounding document exists, drafts cite it for existence claims; a fresh grep is for facts the corpus doesn't cover.
4. **Check which binary a tool resolves before accepting a claim about its behaviour — from inside the code's own execution context.** An interactive shell's function or alias can shadow the binary a child script runs, so a finding measured in the interactive shell can describe a tool the code never calls. Run `command -v <tool>` or `type -a <tool>` from a child script, compare it with the interactive shell, and re-measure where the code runs. `type -P` is the wrong probe: it forces a `PATH` search and skips the function, so it cannot show the difference. The observed failure: a refute-by-default verifier confirmed a wrong "flaky test" finding because both agents shared the premise of a binary the code never resolved.
````

3. In `.claude/skills/rough-in/references/failure-modes.md`, replace

````text
**Defense**: the three rules in `references/research-phase.md` § "Grounding existence claims — repo-wide or not at all": (1)
````

   with

````text
**Defense**: rules 1–3 in `references/research-phase.md` § "Grounding existence claims — repo-wide or not at all": (1)
````

4. In `.claude/skills/rough-in/references/failure-modes.md`, replace

````text
(3) drafts cite the run's grounding corpus for facts it already covers instead of re-deriving them.
````

   with

````text
(3) drafts cite the run's grounding corpus for facts it already covers instead of re-deriving them. Rule 4 there covers the neighbouring case, a claim about a tool's behaviour: it is checked against the binary the code's own execution context resolves.
````

5. In `.claude/skills/framing/references/research-phase.md`, replace

````text
(The rough-in skill's `references/research-phase.md` carries the full three-rule statement; the discipline is identical at both phases.)
````

   with

````text
(The rough-in skill's `references/research-phase.md` carries the full statement of the rules, including rule 4 on which binary a tool name resolves to; the discipline is identical at both phases.)
````

6. In `.claude/skills/rough-in/references/test_cases.md`, replace

````text
- Drafts cite the run's existing grounding output for facts it already covers instead of re-deriving them

**Failure signals**:
- A spec instructs the executor to *create* something whose absence evidence is a single-directory grep
````

   with

````text
- Drafts cite the run's existing grounding output for facts it already covers instead of re-deriving them
- A claim about a tool's behaviour names the binary it was checked against, resolved from inside the code's own execution context (`command -v` or `type -a` from a child script, never `type -P`)

**Failure signals**:
- A spec instructs the executor to *create* something whose absence evidence is a single-directory grep
````

7. In `.claude/rules/orchestration.md`, replace

````text
The canonical three-rule statement lives in the rough-in skill's `references/research-phase.md` § Grounding existence claims.
````

   with

````text
The canonical statement lives in the rough-in skill's `references/research-phase.md` § Grounding existence claims, whose rule 4 checks a claim about a tool's behaviour against the binary the code's own execution context resolves — `command -v` or `type -a` from a child script, never `type -P` (context-builder-kit#68).
````

8. In `.claude/rules/workflows.md`, replace

````text
and drafters cite the run's grounding corpus — the full three-rule statement lives in the rough-in skill's `references/research-phase.md` § Grounding existence claims.
````

   with

````text
and drafters cite the run's grounding corpus; a claim about a tool's behaviour is checked against the binary the code's own context resolves — the full statement of the rules lives in the rough-in skill's `references/research-phase.md` § Grounding existence claims.
````

- [ ] **Step 4: Run the block.** No hook is touched in this task, so there is no `bash -n` step. Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|verification:'; echo "exit=${PIPESTATUS[0]}"`. Expected: `always-loaded total:` up by 294 bytes against the previous commit's run, no `WARN`, `verification: kit sub-block complete`, `verification: done`, `exit=0`.

- [ ] **Step 5: Commit.**

````bash
git add .claude/rules/cbk-conventions-reference.md .claude/rules/orchestration.md .claude/rules/workflows.md .claude/skills/framing/references/research-phase.md .claude/skills/rough-in/references/failure-modes.md .claude/skills/rough-in/references/research-phase.md .claude/skills/rough-in/references/test_cases.md
git commit -F - <<'EOF'
feat(skills): V5 — grounding rule 4 checks which binary a tool name resolves to; the rule count swept

Rough-in's grounding discipline gains rule 4: a claim about a tool's behaviour is checked
against the binary the code's own execution context resolves (command -v or type -a from a
child script, never type -P, which skips a shadowing function). Test 8 gains the criterion;
failure-modes § 13, framing's research phase, orchestration.md and workflows.md cite the
rules without a count.

Closes trace rows: #68/body/3, #68/c5892402074/3-count.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
````

---

### Task V5.13: No template slot in a reference half; a filled target refuses an unfilled slot (#65/body/1, #65/c5861166806/1b, critic/10; none)

**Files:**
- Modify: `.claude/rules/orchestration-reference.md` (§ Applied instances, the pins paragraph)
- Modify: `.claude/rules/cbk-conventions-reference.md` (§ Verification, one kit-sub-block check at the kit sentinel and one project-sub-block check at the project sentinel)

**Interfaces:**
- Consumes: V1's project sentinel (indented two spaces). The contract's two slots — `**Posture.** [Record the project's posture: …]` and the Agent team row's `[record adoption status; …]` — stay: the kit ships them.
- Produces: The project-sub-block check `absent grep -n '\[[Rr]ecor[d] ' .claude/rules/*.md`, which Review Focus 4 (V1's fresh-scaffold task) meets: a fresh scaffold must fill or delete `orchestration.md` at the disposition pass before its block is green.

**Budget:** always-loaded +0 bytes (measured on a copy of `643f7ff` with V5.1–V5.13 applied: 129,269).

- [ ] **Step 1: Write the failing block check.** In `.claude/rules/cbk-conventions-reference.md`, insert these lines immediately before the line `echo "verification: kit sub-block complete"`:

````bash
# A path-scoped reference half ships no square-bracket template slot: the disposition pass never visits it, so a slot
# there is never filled (context-builder-kit#65). The contracts keep theirs; the project sub-block refuses them unfilled.
absent grep -n '\[[Rr]ecor[d] ' .claude/rules/orchestration-reference.md
````

And immediately before the line `  echo "verification: project sub-block complete"` (two-space indent), insert:

````bash
  # Template slots (context-builder-kit#65): no rule keeps an unfilled "Record …" slot — the orchestration posture, the
  # agent-team adoption row. Fill it or delete the rule at the disposition pass. The pattern splits its literal.
  absent grep -n '\[[Rr]ecor[d] ' .claude/rules/*.md
````

- [ ] **Step 2: Run it against the unfixed files.** Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`. Expected, red. The `absent` check first prints the line(s) it matched (line numbers may differ once V1–V4 have landed); the last two lines are:

````text
VIOLATION (matched above): grep -n \[[Rr]ecor[d]  .claude/rules/orchestration-reference.md
verification: block exited 1
exit=1
````

Record the first of those lines in the PR body's red-first table.

- [ ] **Step 3: Make the change.**

1. In `.claude/rules/orchestration-reference.md`, replace

````text
[Record the project's own pins here as they are made, with dates and the reason — e.g. "a reviewer promoted to the workhorse tier after observed misses on <date>". An empty list means no pins beyond the exemplars — a valid state, not a gap.]
````

   with

````text
A project records its own pins as dated bullets under a heading it adds below this paragraph, each with the date and the reason — for example, a reviewer promoted to the workhorse tier after observed misses. No such heading, or an empty one, means no pins beyond the exemplars: a valid state, not a gap.
````

- [ ] **Step 4: Show the project check catches the kit's own unfilled slots.** The project sub-block is skipped on the kit tree, so run its new line directly:
```bash
bash -c "$(grep '^absent() {' .claude/rules/cbk-conventions-reference.md); absent grep -n '\[[Rr]ecor[d] ' .claude/rules/*.md"; echo "exit=$?"
```
Expected: the two `orchestration.md` lines (`**Posture.** [Record the project's posture: …` and `| Agent team | … — [record adoption status; …`), then `VIOLATION (matched above): grep -n \[[Rr]ecor[d]  .claude/rules/…` and `exit=1`. That is what a filled target sees until the disposition pass fills or deletes the rule.

- [ ] **Step 5: Run the block.** No hook is touched in this task, so there is no `bash -n` step. Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|verification:'; echo "exit=${PIPESTATUS[0]}"`. Expected: `always-loaded total:` unchanged against the previous commit's run, no `WARN`, `verification: kit sub-block complete`, `verification: done`, `exit=0`.

- [ ] **Step 6: Commit.**

````bash
git add .claude/rules/cbk-conventions-reference.md .claude/rules/orchestration-reference.md
git commit -F - <<'EOF'
fix(rules): V5 — the reference half ships no template slot; a filled target refuses an unfilled one

The pins slot in orchestration-reference.md becomes prose (a reference half is never visited
by the disposition pass, so a slot there is never filled). The kit sub-block keeps it out;
the project sub-block refuses any unfilled "Record …" slot in a rule — the posture and the
agent-team row — with the bracket-split pattern so the check never matches itself.

Closes trace rows: #65/body/1, #65/c5861166806/1b, critic/10.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
````

---

### Task V5.14: The reference half restamped: every quotation re-read 2026-09-30, Primary sources rewritten, update triggers (#69/body/F4 (Primary sources), #69/body/Fq (remaining), #69/c5859756889/3-C5, #69/c5881157875/3b; D49)

**Files:**
- Modify: `.claude/rules/orchestration-reference.md` (the banner; § Generation notes — the sources and § Cost terms and run hygiene preambles; two Cost-terms bullets; § When to update this file; § Primary sources, whole section)
- Modify: `.claude/rules/cbk-conventions-reference.md` (§ Verification, one check at the kit sentinel)

**Interfaces:**
- Consumes: Every earlier V5 task's new quotations (the check fails until each quoted docs page has a row).
- Produces: § Primary sources with one row per quoted page, the changelog row labelled by the entries it cites (2.1.63 to 2.1.285), and the check that keeps rows and quotations in step.

**Budget:** always-loaded +0 bytes (measured on a copy of `643f7ff` with V5.1–V5.14 applied: 129,269).

Two paraphrases are corrected on re-reading: the workflows page now says a relaunch re-runs the failed agent and every agent started after it (not "completed agents return cached results"), and the `v2.1.211+` beside the hooks citation is the changelog fix for `ask` in auto mode, now quoted. The Workflow tool's `resumeFromRunId` stays dated 2026-09-06: it is read off the live tool description, which a planning subagent cannot see. Before Step 3, in the main session, read the Workflow tool's own parameter list. If it still offers `resumeFromRunId` beside `scriptPath`, also replace, in `.claude/rules/orchestration-reference.md` (it occurs once), `(read off the live tool description, 2026-09-06 — ` with `(read off the live tool description, <today's date, YYYY-MM-DD> — ` in this task's commit. If it no longer offers it, stop and reconcile § Cost terms and run hygiene's **A suspended host stalls a fan-out silently.** bullet before continuing.

- [ ] **Step 1: Write the failing block check.** In `.claude/rules/cbk-conventions-reference.md`, insert these lines immediately before the line `echo "verification: kit sub-block complete"`:

````bash
# Every docs page the orchestration reference quotes has a § Primary sources row — the rows are what "re-fetch before
# re-citing" walks (context-builder-kit#69). An empty page read is red, never a vacuous pass.
[ ! -f .claude/rules/orchestration-reference.md ] || { ps=$(awk '/^## Primary sources/{p=1} p' .claude/rules/orchestration-reference.md); body=$(awk '/^## Primary sources/{exit} {print}' .claude/rules/orchestration-reference.md); u=$(grep -oE '(code|platform)\.claude\.com/docs/en/[A-Za-z0-9/_.-]*[A-Za-z0-9_-]' <<<"$body" | sort -u); [ -n "$u" ] || { echo "no docs page read from orchestration-reference.md — the extraction broke"; exit 1; }; for x in $u; do grep -qF "| \`$x\`" <<<"$ps" || { echo "orchestration-reference.md quotes $x but § Primary sources has no row for it"; exit 1; }; done; }
````

- [ ] **Step 2: Run it against the unfixed files.** Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`. Expected, red. The last two lines are:

````text
orchestration-reference.md quotes code.claude.com/docs/en/agent-teams but § Primary sources has no row for it
verification: block exited 1
exit=1
````

Record the first of those lines in the PR body's red-first table.

- [ ] **Step 3: Make the change.**

1. In `.claude/rules/orchestration-reference.md`, replace

````text
Sections were moved verbatim on 2026-09-06. See
````

   with

````text
Sections were moved verbatim on 2026-09-06, and every quotation was re-fetched on 2026-09-30. See
````

2. In `.claude/rules/orchestration-reference.md`, replace

````text
The verbatim quotations behind `orchestration.md` § Generation notes and § The effort axis, fetched 2026-09-05 unless dated otherwise; re-fetch before re-citing.
````

   with

````text
The verbatim quotations behind `orchestration.md` § Generation notes, § The effort axis and § Fan-out discipline, re-fetched raw on 2026-09-30 (a docs page's `.md` form where the site serves one) and matched with `grep -F` after straightening typographic quotes and stripping markdown links (context-builder-kit#69); re-fetch before re-citing.
````

3. In `.claude/rules/orchestration-reference.md`, replace

````text
The terms the contract half's § Fan-out discipline points at; all fetched 2026-09-05.
````

   with

````text
The terms the contract half's § Fan-out discipline points at; all re-fetched 2026-09-30 unless dated otherwise.
````

4. In `.claude/rules/orchestration-reference.md`, replace

````text
select the run, press `p`, or ask for a relaunch of the same script; completed agents return cached results)
````

   with

````text
select the run, press `p`, or ask for a relaunch of the same script; on a relaunch, agents that finished before the failed one return cached results, and the failed agent and every agent started after it run again)
````

5. In `.claude/rules/orchestration-reference.md`, replace

````text
(`code.claude.com/docs/en/hooks` § PreToolUse decision control, v2.1.211+)
````

   with

````text
(`code.claude.com/docs/en/hooks` § PreToolUse decision control; the auto-mode floor is the 2.1.211 changelog fix, "a hook `ask` now floors the decision at a prompt")
````

6. In `.claude/rules/orchestration-reference.md`, replace

````text
including `~/.claude/CLAUDE.md`, project rules, `CLAUDE.local.md`, and managed policy files. The built-in Explore and Plan agents skip this"
````

   with

````text
including `~/.claude/CLAUDE.md`, project rules, `CLAUDE.local.md`, managed policy files, and any `AGENTS.md` files loaded as project instructions. The built-in Explore and Plan agents skip this"
````

7. In `.claude/rules/orchestration-reference.md`, replace

````text
against the current sub-agents doc after an upgrade.
````

   with

````text
against the current sub-agents doc after an upgrade. Recent ones: v2.1.271 lowered the `medium` workflow-size guideline from under 15 agents to under 10; v2.1.280 moved `opus` to Opus 5.5 (a new price, a `medium` default, thinking always on); v2.1.284 moved `sonnet` to Sonnet 5.5 (recalibrated levels, `medium` in Claude Code) and stopped ultracode forcing `xhigh`.
- Before a re-sweep after a model change, run `/doctor prompt-audit` (Claude Code 2.1.283 or later) over the rules, skills, agents and commands: the changelog says it audits "your CLAUDE.md files, skills, agents and commands for prompting patterns written for older models". Keep what it flags only where a measurement says the older pattern still wins.
````

8. In `.claude/rules/orchestration-reference.md`, replace

````text
## Primary sources

Verified 2026-09-05 by the harvest's research run; **re-fetch before re-citing** rather than trusting the summary. The contract half cites these pages by short name — the effort page, the models overview, the cost page (`optimizing-for-cost-and-intelligence`), the Opus 5 / Sonnet 5 / Fable 5.1 guides, sub-agents, workflows, costs, model-config, the model-and-effort blog — and each resolves to a row below.

| Source | What it grounds |
|---|---|
| `code.claude.com/docs/en/sub-agents` | Resolution order (v2.1.251), `CLAUDE_CODE_SUBAGENT_MODEL_FORCE` (v2.1.257), the Explore cap, `effort` frontmatter inheritance, the concurrent-subagent limit (v2.1.217), what loads at startup, background default (v2.1.232) |
| `code.claude.com/docs/en/workflows` | Workflow caps, the `Large workflow` warning, `workflowSizeGuideline`, prompt caching in a fan-out |
| `code.claude.com/docs/en/costs` | Agent-team token multiple |
| `code.claude.com/docs/en/skills` | Skill `model` / `effort` / `context: fork`, `${CLAUDE_EFFORT}` |
| `code.claude.com/docs/en/hooks` | `PreToolUse` decisions, `updatedInput`, `ask` in auto mode |
| `code.claude.com/docs/en/model-config` | Aliases (`opus`, `fable`) |
| `platform.claude.com/docs/en/build-with-claude/effort` | The `high` default, set-it-explicitly, the levels table, Opus 5 recommendations, the supported-model list |
| `platform.claude.com/docs/en/about-claude/models/overview` | The lineup, the pricing row, the documented ladder |
| `platform.claude.com/docs/en/about-claude/models/optimizing-for-cost-and-intelligence` | Cost per completed task; re-running failures at higher effort |
| `platform.claude.com/docs/en/build-with-claude/task-budgets` | Not supported on Claude Code |
| `platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5` | Over-verification; controlling subagent spawning; the deterministic caps |
| `platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5` | Raise effort before prompting around it; match by thinking length |
| `platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1` | Effort names across models; long outputs at `high` |
| `platform.claude.com/docs/en/models/fable-5-1/whats-new-fable-5-1` | Searches less at `low` |
| `platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices` | Specificity matched to fragility; 500-line SKILL.md; test with every model |
| `claude.com/blog/claude-model-and-effort-level-in-claude-code` (2026-07-07) | The effort-vs-model heuristic; asks rather than digs at lower effort |
| `anthropic.com/engineering/multi-agent-research-system` (2025-06-13, 4-series) | The lead-plus-cheaper-workers result (90.2%); the 4× and 15× multiples |
````

   with

````text
## Primary sources

Verified 2026-09-30 (context-builder-kit#69): every quotation in this file re-fetched raw that day and matched with `grep -F`. **Re-fetch before re-citing** rather than trusting the summary. The contract half cites these pages by short name — the effort page, the models overview, the pricing page, the cost page (`optimizing-for-cost-and-intelligence`), the deprecations page, the Opus 5 / Opus 5.5 / Sonnet 5 / Sonnet 5.5 / Fable 5.1 guides, sub-agents, workflows, costs, model-config, the model-and-effort blog — and each resolves to a row below.

| Source | What it grounds |
|---|---|
| `code.claude.com/docs/en/sub-agents` | Resolution order (v2.1.251), `CLAUDE_CODE_SUBAGENT_MODEL_FORCE` (v2.1.257), the Explore cap, `effort` frontmatter inheritance, the per-invocation `model` parameter, the concurrent-subagent limit (v2.1.217) and its ultracode exemption, the depth-limit sentence, a named subagent becoming a teammate, what loads at startup, background default (v2.1.232) |
| `code.claude.com/docs/en/workflows` | Workflow caps, `CLAUDE_CODE_WORKFLOW_MAX_CONCURRENT_AGENTS` (v2.1.269), the `Large workflow` warning and what replaces or hides it, `workflowSizeGuideline` and its sizes, prompt caching in a fan-out |
| `code.claude.com/docs/en/costs` | Agent-team token multiple |
| `code.claude.com/docs/en/agent-teams` | Teams experimental and off by default |
| `code.claude.com/docs/en/skills` | Skill `model` / `effort` / `context: fork`, `${CLAUDE_EFFORT}` |
| `code.claude.com/docs/en/hooks` | `PreToolUse` decisions, `updatedInput`, `ask` in auto mode |
| `code.claude.com/docs/en/model-config` | Aliases by provider and their version history (`opus` at v2.1.280, `sonnet` at v2.1.284); the Claude Code effort default per model; which settings scopes bind; the models with the dial; ultracode leaves the effort level unchanged |
| `code.claude.com/docs/en/worktrees` | Subagent worktrees branch from the default branch unless `worktree.baseRef` is `"head"` |
| `code.claude.com/docs/en/headless` | A resumed run reports the conversation's whole total |
| `code.claude.com/docs/en/cli-reference` | `--max-budget-usd` does not count restored spend |
| `code.claude.com/docs/en/permissions` | A `git push` deny rule does not match `git -C . push` |
| `platform.claude.com/docs/en/build-with-claude/effort` | The per-model API default, set-it-explicitly, the levels table, Opus 5, Opus 5.5 and Sonnet 5.5 recommendations, `between_tools` |
| `platform.claude.com/docs/en/about-claude/models/overview` | The lineup, the Opus 5.5-first ladder, Opus 5 as legacy, thinking by model |
| `platform.claude.com/docs/en/about-claude/pricing` | The list prices and cache-read rates `agent-cost.py` mirrors, the price steps, Sonnet 5's cancelled increase |
| `platform.claude.com/docs/en/about-claude/models/optimizing-for-cost-and-intelligence` | Cost per completed task; Opus 5.5 at its default against Fable 5.1; the advisor result; Fable 5.1 flat across effort on a research benchmark; re-running failures at higher effort; when delegation doesn't pay |
| `platform.claude.com/docs/en/about-claude/model-deprecations` | Haiku 4.5 not retired sooner than 2026-10-15 |
| `platform.claude.com/docs/en/build-with-claude/task-budgets` | Not supported on Claude Code |
| `platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5` | Over-verification; controlling subagent spawning; the deterministic caps |
| `platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5` | Opus 5 patterns remain the starting point; `medium` against Opus 5 at `high`; § Unattended agentic runs |
| `platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5` | Raise effort before prompting around it; match by thinking length |
| `platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5-5` | Check-ins at `low` and `medium`; JSON answers without thinking; the remedy line |
| `platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1` | Effort names across models; long outputs at `high` |
| `platform.claude.com/docs/en/models/fable-5-1/whats-new-fable-5-1` | Searches less at `low` |
| `platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices` | Specificity matched to fragility; 500-line SKILL.md; test with every model |
| The Claude Code changelog (`raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md`), the entries cited from 2.1.63 to 2.1.285 | The 2.1.212 rails and 2.1.224; the task tools (2.1.233, 2.1.268); workflows (2.1.269, 2.1.271); `/simplify`'s history (2.1.63, 2.1.147, 2.1.152, 2.1.154, in `simplification.md`); `/doctor prompt-audit` (2.1.283); the auto-mode default (2.1.283, 2.1.284); ultracode no longer `xhigh` (2.1.284) |
| `claude-code-action`'s `base-action/action.yml` at each release tag | Which action release installs which Claude Code, so which model an alias resolves to |
| `claude.com/blog/claude-model-and-effort-level-in-claude-code` (2026-07-07) | The effort-vs-model heuristic; asks rather than digs at lower effort |
| `anthropic.com/engineering/multi-agent-research-system` (2025-06-13, 4-series) | The lead-plus-cheaper-workers result (90.2%); the 4× and 15× multiples |
| `anthropic.com/engineering/harness-design-long-running-apps` (2026-03-24) | A separate evaluator is worth its cost only beyond what the model does reliably solo |
| `blog.fsck.com/2026/09/21/superpowers-6.4/` (2026-09-21; a practitioner's measurement) | Native execution against subagent-driven development |
````

- [ ] **Step 4: Re-fetch every quotation this task writes, raw, today.** With `qf` loaded (§ Conventions), run:

````bash
qf https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5.md 'remove them: instructions like these cause over-verification on Claude Opus 5'
qf https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5.md 'include a final verification step for any non-trivial task,'
qf https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5.md 'Do not delegate work you can finish yourself in a handful of tool calls, and do not use subagents to verify or double-check your own work. If one subagent can complete the task, use one rather than several'
qf https://www.anthropic.com/engineering/multi-agent-research-system 'In our data, agents typically use about 4× more tokens than chat interactions, and multi-agent systems use about 15× more tokens than chats.'
qf https://www.anthropic.com/engineering/multi-agent-research-system 'outperformed single-agent Claude Opus 4 by 90.2% on our internal research eval'
qf https://code.claude.com/docs/en/costs.md 'Agent teams use approximately 7x more tokens than standard sessions when teammates run in plan mode'
qf https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices.md 'Match the level of specificity to the task'\''s fragility and variability.'
qf https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices.md 'Keep SKILL.md body under 500 lines for optimal performance'
qf https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices.md 'Skills act as additions to models, so effectiveness depends on the underlying model. Test your Skill with all the models you plan to use it with.'
qf https://code.claude.com/docs/en/sub-agents.md 'every level of the CLAUDE.md hierarchy the main conversation loads, including `~/.claude/CLAUDE.md`, project rules, `CLAUDE.local.md`, managed policy files, and any `AGENTS.md` files loaded as project instructions. The built-in Explore and Plan agents skip this'
qf https://code.claude.com/docs/en/workflows.md 'Two agents that run with the same model, effort level, agent type, tools, output schema, and working directory build the same tools-and-system-prompt prefix, so an agent that starts after a matching sibling'\''s response has begun reads that sibling'\''s cache'
qf https://code.claude.com/docs/en/sub-agents.md 'Where fork mode is on, as it is by default in an interactive session, Claude Code runs the subagent in the background, forks and non-fork subagents alike, and Claude can'\''t ask for the foreground'
qf https://code.claude.com/docs/en/hooks.md 'Replaces the entire input object, so include unchanged fields alongside modified ones'
qf https://code.claude.com/docs/en/hooks.md 'also forces a permission prompt in auto mode'
qf https://code.claude.com/docs/en/sub-agents.md 'Before v2.1.251, `CLAUDE_CODE_SUBAGENT_MODEL` came first in this order and overrode both the per-invocation parameter and the frontmatter, including `model: inherit`'
qf https://code.claude.com/docs/en/sub-agents.md 'to every subagent, teammate, and workflow agent'
qf https://code.claude.com/docs/en/skills.md 'The override applies for the rest of the current turn and isn'\''t saved to settings'
qf https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md 'Added `/doctor prompt-audit` (also `/checkup prompt-audit`) to audit your CLAUDE.md files, skills, agents and commands for prompting patterns written for older models'
qf https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md 'your CLAUDE.md files, skills, agents and commands for prompting patterns written for older models'
qf https://code.claude.com/docs/en/workflows.md 'Resume a paused run from `/workflows` by selecting it and pressing `p`.'
qf https://code.claude.com/docs/en/workflows.md 'relaunching returns A from cache and runs B, C, and D again'
qf https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md 'a hook `ask` now floors the decision at a prompt'
````

Expected: one `OK` line per call and no `MISS`. A `MISS` means the page moved since 2026-09-30: re-read it, correct the quotation and its date in the replacement text, and re-run.

- [ ] **Step 5: Run the block.** No hook is touched in this task, so there is no `bash -n` step. Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|verification:'; echo "exit=${PIPESTATUS[0]}"`. Expected: `always-loaded total:` unchanged against the previous commit's run, no `WARN`, `verification: kit sub-block complete`, `verification: done`, `exit=0`.

- [ ] **Step 6: Commit.**

````bash
git add .claude/rules/cbk-conventions-reference.md .claude/rules/orchestration-reference.md
git commit -F - <<'EOF'
docs(rules): V5 — orchestration-reference.md restamped: quotations re-read 2026-09-30, one Primary-sources row per quoted page

Every quotation in the reference half was re-fetched raw on 2026-09-30 and matched with
grep -F; the preambles say so, the startup-context quote gains AGENTS.md, the relaunch
paraphrase and the hooks version are corrected. § Primary sources is rewritten in place with
a row per quoted page (pricing, deprecations, the Opus 5.5 and Sonnet 5.5 guides, worktrees,
headless, cli-reference, permissions, agent-teams, the changelog, the action releases); the
block checks that no quoted docs page lacks a row. § When to update names the recent alias
moves and /doctor prompt-audit.

Closes trace rows: #69/body/F4, #69/body/Fq, #69/c5859756889/3-C5, #69/c5881157875/3b.
Decision: D49.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
````

---
## Coverage

| Id | Source | Lands in |
|---|---|---|
| `#69/body/T1` | item | V5.3 |
| `#69/body/T2` | item | V5.4 |
| `#69/body/T3` | item | V5.4 |
| `#69/body/T4` | item | V5.4 |
| `#69/body/T5` | item | V5.7 |
| `#69/body/T6` | item | V5.7 |
| `#69/body/T7` | item | V5.3 |
| `#69/body/T8` | item | V5.3 lands the price steps; handed to V6 with the per-version pricing row and the cache-read quotation (Handed § 1) |
| `#69/body/T9` | item | V5.4 |
| `#69/body/T10` | item | V5.8 |
| `#69/body/T11` | item | V5.6 |
| `#69/body/T12` | item | V5.6 |
| `#69/body/T13` | item | V5.6 |
| `#69/body/T14` | item | V5.9 |
| `#69/body/T15` | item | V5.10 |
| `#69/body/F1` | item | V5.4 |
| `#69/body/F2` | item | V5.4 (and the pin label in V5.3) |
| `#69/body/F3` | item | V5.4 |
| `#69/body/F4` | item | V5.3 (ladder, prices) and V5.14 (Primary sources, restamp) |
| `#69/body/F5` | item | handed to V6 (`agent-cost.py` version keys, `<synthetic>`, fast mode) |
| `#69/body/F6` | item | V5.7 |
| `#69/body/F7` | item | V5.6 |
| `#69/body/F8` | item | V5.8 |
| `#69/body/F9` | item | V5.11 (rule); handed to V3 (`settings.json` comment) and V10 (`README.md`) |
| `#69/body/F10` | item | V5.6 (rule text); the code is V6 |
| `#69/body/Fq` | item | V5.3, V5.4, V5.5, V5.6, V5.14 |
| `#69/body/S1` | item | V5.9 |
| `#69/body/S2` | item | V5.9 |
| `#69/body/S3` | item | V5.9 |
| `#69/body/S4` | item | V5.10 |
| `#69/body/S5` | item | V5.7 (row) and V5.9 (lesson 1) |
| `#69/body/S6` | item | V5.9 (rule and quote); handed to V6 (runner `spend()`) |
| `#69/body/S7` | item | V5.9 |
| `#69/body/S8` | item | V5.9 (lesson and permissions quote); handed to V6 (the runner deny list) |
| `#69/body/S9` | item | V5.9 |
| `#69/body/S10` | item | V5.6 (panel bullet) and V5.9 (lesson 6); handed to V6 (`judge-rubric.md`) |
| `#69/body/S11` | item | V5.9 |
| `#69/body/CAP` | item | handed to V9 (`finish.md` item 8 and its bundled copy, § Sub-issue rollup — master § Ownership map gives V9 the capstone sentence) |
| `#69/c5859756889/3-C1` | item | V5.8 |
| `#69/c5859756889/3-C2` | item | V5.10 |
| `#69/c5859756889/3-C3` | item | V5.10 |
| `#69/c5859756889/3-C4` | item | handed to V4 (`claude.yml` `--effort high`, D47) |
| `#69/c5859756889/3-C5` | item | V5.14 |
| `#69/c5881157875/1a` | item | V5.3 |
| `#69/c5881157875/1b` | item | V5.4 |
| `#69/c5881157875/1c` | item | V5.4 (rule and quotes); handed to V7 (the remedy line in `review-sweep.js`) |
| `#69/c5881157875/1d` | item | V5.4 |
| `#69/c5881157875/2a` | item | V5.3 (the "2×-Opus" half: not holding) |
| `#69/c5881157875/2b` | item | V5.3 |
| `#69/c5881157875/2c` | item | handed to V6 (version-keyed `CACHE_READ`) |
| `#69/c5881157875/2d` | item | handed to V6 (the quoted cache-read sentence, in the commit that adds the `CACHE_READ` diff to the block) |
| `#69/c5881157875/3a` | item | V5.6 (rule and quotes); handed to V4 (the deep branch passes `--effort xhigh`) |
| `#69/c5881157875/3b` | item | V5.14 |
| `#69/c5881157875/3c` | item | V5.6 |
| `#69/c5881157875/3d` | item | V5.6 |
| `#69/c5881157875/4` | item | V5.3 |
| `#69/c5881157875/5` | item | V5.9 |
| `#69/c5892402564/Q1` | item | V5.6 |
| `#69/c5892402564/Q2` | item | V5.6 |
| `#65/body/1` | item | V5.13 |
| `#65/c5861166806/1b` | item | V5.13 |
| `#65/body/2` | item | V5.5 |
| `#65/body/3` | item | V5.5 |
| `#65/c5861166806/3b` | item | V5.5 (and the pointer check in V5.1) |
| `#74/body/3` | item | V5.4 |
| `#68/body/3` | item | V5.12 |
| `#68/c5892402074/3-count` | item | V5.12 |
| `#58/c5901493591/R9` | item | V5.3 (reference note); handed to V6 (`agent-cost.py` docstring) |
| `#67/body/3` | handedIn (V4) | V5.3 |
| `#67/c5881158070/2c` | handedIn (V4) | V5.3 (reference); the CHANGELOG Sync note is V10's |
| `#67/c5901495773/5` | handedIn (V4) | V5.3 |
| `#69/body/finish-ab/N-arm` | handedIn (V6) | V5.6 (panel wording in both halves); the script, README and CLAUDE.md lines are V6's and V10's |
| `#69/body/H1` | handedIn (V6) | V5.10 |
| `#69/body/H2` | handedIn (V6) | V5.7 |
| `#69/body/H3` | handedIn (V6) | V5.9 |
| `#69/body/H4` | handedIn (V6) | V5.9 |
| `#69/c5881157875/2-steps` | handedIn (V6) | V5.3 |
| `#69/c5881157875/2-sonnet5` | handedIn (V6) | V5.3 |
| `#72/body/4` | handedIn (V7) | V5.6 (the `orchestration.md` bullet); the prompts and scenario 27 are V7's |
| `#66/c5901495490` | handedIn (V9) | V5.2 |
| `critic/10` | critic | V5.13 (both slots; the optional ultracode posture note is the operator's fill, not kit text) |
| `critic/16` | critic | V5.9 (none of the six ships; the capstone sentence goes to V9 per the spec's settled call) |
| `critic/17` | critic | V5.9 (and every V5 task: re-authored, no "measured here") |
| `critic/18` | critic | V5.3 (pins labelled) and V5.4 (finder brief); the fast-review branch's effort is V4's |
| `review/portability/38` | review (verified) | V5.2 |
| `review/claude-code/57` | review (unverified; holds) | V5.1 (the split); the failing budget threshold is not taken — D50 makes it a non-failing `WARN`, V1's |

## Handed to other clusters

1. **To V6 — the per-version pricing row and the cache-read quotation, in the same commit as the version-keyed `PRICE` and `CACHE_READ` (#69/body/T8, #69/body/F5, #69/c5881157875/2c, 2d).** The block's list-price diff couples the reference's pricing row to `agent-cost.py`'s `PRICE`, and V6 lands after V5, so V5.3 leaves the ladder bullet's family sentence `Pricing row, per MTok in/out: Fable 5.1 $10/$50, Opus 5 $5/$25, Sonnet 5 $2/$10, Haiku 4.5 $1/$5 (same page). ` byte for byte (V6's edit (b) deletes it) and writes the cache-read quotation nowhere (V6's **Prices, per version** bullet carries it). V6's `agent-cost.py` commit therefore edits `.claude/rules/orchestration-reference.md` — an ownership exception this plan asks the orchestrator to accept, because a split would leave the block red between two commits. **V6 must re-anchor its insertion point:** V5.4 replaces the bullet that began `- **The `high` default** — ` with one that begins `- **The default effort is per model and per surface** (fetched 2026-09-30):`, so V6's Step 1 precondition on the old label and its edit (b) insertion anchor are gone after V5; V6 inserts its bullet immediately after V5.3's **Price steps** bullet (anchor `- **Aliases, by provider and by version**`, unique after V5) instead.
2. **To V6 — the headless runner's exemplar line (#69/body/F10, S4, S6, S8).** `run-arms-headless.py` does not exist until V6, so V6's runner commit appends one sub-bullet to `orchestration-reference.md` § Applied instances › Shipped exemplars (the same ownership exception). It goes directly under the line that V5.6 leaves as `` - `.claude/workflows/finish-ab/` — executors and judges at the workhorse tier, effort named per call; the judge panel reads every arm in every position equally often, and the script refuses an unbalanced panel before dispatch.``, and reads:

   ````markdown
     - **Headless arms.** `run-arms-headless.py` runs arms that must dispatch subagents, which a workflow agent cannot (§ Generation notes — the sources). Each is a `claude -p` session in its own worktree at the base commit, with `--strict-mcp-config` and an allowlist of read-only MCP servers, deny rules for `git push`, `git * push` and `gh` writes as the backstop, continuations bounded per runner pass, and each continuation given only the budget the arm has left; with `check_command` set, the runner runs the check task once per arm, serially, and the judges read that log. `tests/run-arms-headless-fixture.sh` covers it against a fake `claude`.
   ````

   V5.6's panel wording already holds for two to four arms, so V6 changes no other V5 text.
3. **To V6 — code halves.** `agent-cost.py`'s 3.2× docstring note (#58/c5901493591/R9), with the same condition V5.3 writes into the reference; the runner's `spend()`, deny list and continuation budget (S6, S8, H3, H4); the judges' read-only clause in `finish-ab.js` (#72/body/4, the rule V5.6 states); `judge-rubric.md` quoting the verdict rule's measures (S10).
4. **To V7 — `pr-review.md` craft rules.** V5.10 adds the workflow-agent fact to § The floor; the craft rule `**A skill that ran without its own fan-out counts as invoked, not covered** — § The floor states the spawn-depth fact and its source;` becomes `… — § The floor states the spawn-depth and workflow-agent facts and their sources;` (V7 owns that region). If probe P2 came out as outcome B (V5.10 Step 0), § The floor gains no workflow-agent clause and the craft rule is left as it is. Also to V7: the Sonnet 5.5 remedy line `Think the problem through before you answer.` at the end of `review-sweep.js`'s finder prompt (#69/c5881157875/1c), and `READ_ONLY` in every find and verify prompt (#72/body/4).
5. **To V3 — `settings.json`'s `_comment_enabledPlugins` (#69/body/F9).** Replace `bundled skill (verified against the installed CLI bundle, Claude Code 2.1.263, 2026-09-06; re-verify after harness upgrades)` with `bundled skill (its changelog history is in .claude/rules/simplification.md § Plugin)`, so the version is stated once.
6. **To V4 — templates (#69/c5859756889/3-C4, #69/c5881157875/3a, critic/18).** `claude.yml` passes `--effort high`; the deep branch passes `--effort xhigh` explicitly because the `ultracode` setting no longer implies it from Claude Code 2.1.284; the fast-review branch's effort is labelled a pin pending a sweep. V5.3's review-bot paragraph describes exactly D47's shape.
7. **To V9 — the capstone close marker (#69/body/CAP).** `finish.md` item 8, its bundled copy and § Sub-issue rollup are V9's by the ownership map; the sentence is a dated observation (GitHub's sub-issues page, read 2026-09-30, says nothing of parent closure).
8. **To V10 — indexes and sync notes.** Name `knowledge-backend-reference.md` in `README.md`'s tree (beside `knowledge-backend.md`, whose line becomes "Notion-axis contract + path-scoped reference (delete both with the hook when the axis is none)"), in its count of files under `.claude/rules/` (twelve becomes thirteen), and in `CLAUDE.md`'s rules list; point `README.md`'s `/simplify` line at `simplification.md` § Plugin instead of the 2.1.263 spot check (#69/body/F9). The v1.0.0 Sync notes list the orchestration pair, `workflows.md`, `simplification.md`, `tooling.md` and the knowledge-backend pair (a new file: add it; a filled target merges the contract), and the dated action-release facts of #67/c5881158070/2c (a target pinned below `claude-code-action` v1.0.232 still reviews on Opus 5).

## Not holding at planning time

Every item and finding was re-checked against `643f7ff` and the live pages on 2026-09-30. Each is re-checked again when its task runs (D56).

- **`review/claude-code/57` (unverified) — holds, with one correction.** The per-file line counts are right (`cbk-conventions.md` 253, `knowledge-backend.md` 308, `workflows.md` 189, `pr-review.md` 167, `tooling.md` 149, `orchestration.md` 122, `simplification.md` 45 at `643f7ff`), but they total 1,233, not 1,335; `knowledge-backend.md` is the largest and unsplit; memory § "Rules without `paths` frontmatter are loaded at launch with the same priority as `.claude/CLAUDE.md`" (`https://code.claude.com/docs/en/memory.md`, read 2026-09-30). Its proposed *failing* budget gate does not land: D50 settles a non-failing `WARN` above 140,000 bytes, which is V1's.
- **`review/portability/38` (verified) — holds.** The Verification-property requirement is at `knowledge-backend.md:92`, the plan-feature disclaimer at `:280`, and neither § Notion MCP convention nor § Notion 3.3+ carries a source. The finding's "cannot be created" is inference; V5.2 states only what the help page says ("This feature is available on Business and Enterprise Plans.").
- **`#69/c5881157875/2a`, second half — not holding.** The Fable "2×-Opus price" phrase is not in the kit at `643f7ff` (`grep -rniE 'opus price|2x-opus' .claude README.md CLAUDE.md` → no match); only the `(2× / 2.5× / 2×)` parenthetical was live, and V5.3 fixes it.
- **`#69/c5881157875/3a`, "docs lag" — no longer holds.** model-config now documents that the `ultracode` setting leaves the effort level unchanged (the Q2 quote V5.6 carries); the changelog is cited beside it.
- **"Fable 5.1 earns its price only at `low`" (the recalibration mapper's open question on the cost page) — not on the page today.** The cost page read 2026-09-30 carries instead "Claude Fable 5.1 scored nearly the same at `low`, `medium`, and `high` while the cost per task rose from $4.66 to $7.12" (§ Tune effort) and "Claude Fable 5.1 at `low` effort solved 88.6% of tasks for $0.54 per solved task" (§ Compare models on cost per task); V5.3's re-sweep note on the synthesis slot quotes the first.
- **The private target's reason for never setting `ANTHROPIC_MODEL` ("it wins over `--model`") — holds inside the action, not in the CLI.** model-config § Setting your model lists `claude --model` at priority 2 and `ANTHROPIC_MODEL` at priority 3, but `claude-code-action` hands `ANTHROPIC_MODEL` to the SDK as the explicit model (`model: options.model || modelFromClaudeArgs`, `base-action/src/parse-sdk-options.ts` at `v1.0.237`, read 2026-09-30), so on the action step it does win. V5.3 keeps D47's rule; the sourced reason lives in V4's template header, not in the always-loaded contract.
- **A stale quotation the #69 sweep missed — holds and is fixed.** The Opus 5 guide's deterministic-caps sentence now reads "…the SDK's `max_budget_usd` (python; typescript: `maxBudgetUsd`) option"; V5.6 carries the live form. Two cost-terms paraphrases (the relaunch cache, the `v2.1.211+` hooks date) are corrected in V5.14.
