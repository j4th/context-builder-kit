# Planning-backend matrix for blueprint

How blueprint's behavior differs across the planning backend axis (`github-issues` / `linear` / `in-repo-markdown`). Knowledge backend concerns are **orthogonal** to this file — those live in `.claude/rules/knowledge-backend.md`.

The planning backend is determined by `scaffold.md`'s Cascade metadata section. **Read it before doing anything planning-axis-specific.** Do not guess from context — every later phase trusts that blueprint correctly routed based on the scaffold output.

## Quick reference matrix

| Operation | `github-issues` | `linear` | `in-repo-markdown` |
|---|---|---|---|
| Read inheritance | `docs/cbk/problem_brief.md` + `docs/cbk/scaffold.md` via GitHub MCP | Same path, same MCP | Same |
| Stack decisions | Recorded in ARCHITECTURE.md + blueprint.md | Same | Same |
| Methodology selection | Recorded in blueprint.md | Same, plus may inform Linear cycle length | Same |
| Foundation docs (CLAUDE.md, ARCHITECTURE.md, STANDARDS.md, CONTRIBUTING.md, README.md) | Commit to repo via GitHub MCP | Same | Same |
| `blueprint.md` | Commit to `docs/cbk/blueprint.md` via GitHub MCP | Same, plus write the initiative content into the planner's initiative entity (provisioned at scaffold) | Same; planning-side setup steps land in § Manual setup |
| Initiative content destination | Lives only in `docs/cbk/blueprint.md` | Lives in `docs/cbk/blueprint.md` AND mirrored into the existing initiative entity's description | Lives only in `docs/cbk/blueprint.md`; no external initiative |
| Workstream parent Issues | Create one per workstream via GitHub MCP `issue_write` | Create one **parent issue** per workstream via `mcp__linear__save_issue` (titled `[<slug>] <Workstream name>`, in the project shell) — workstreams are issues, never Projects | Recorded as rows in `blueprint.md` Workstreams table only |
| Tooling configs | Commit to repo (`.github/workflows/`, task runner config, .env.example) | Same | Same |
| Linear MCP needed? | No | Yes | No |
| HITL gate count | 6 default | 6 default + 1 extra for Linear initiative confirmation | 6 default; planning-write gates collapse |

## `github-issues` planning behavior

**The most common case.** If scaffold picked `github-issues`, blueprint operates entirely against the GitHub repo for planning. There is no Linear, no external project tool.

The structural fact that shapes everything: **`github-issues` is three-level** (project board → sub-issue → sub-sub-issue, via GitHub's native sub-issue API), with no native concept of "initiative." This was surfaced and explicitly acknowledged in scaffold's backend selection. Blueprint's job under this constraint is to produce the initiative content **as a markdown document at `docs/cbk/blueprint.md`** rather than as a planning entity. Framing then reads that document as context for project decomposition.

Concretely:

1. **Read inheritance** via GitHub MCP file-read against the repo URL from scaffold.md
2. **Run all five steps** (inheritance → stack decisions → methodology → foundation docs → blueprint.md content) inside chat with HITL gates
3. **Commit each foundation doc** to its target location via GitHub MCP file-write after HITL approval
4. **Commit `blueprint.md`** to `docs/cbk/blueprint.md` after the final HITL gate
5. **Create workstream parent Issues** via GitHub MCP `issue_write` (one per workstream from the blueprint.md table)
6. **Tell the user** that blueprint is complete and framing inherits from the committed file

**No Linear operations**, ever, in `github-issues` mode. If the user asks "where do I see this in Linear?" the answer is "Linear isn't in scope for this planning backend — switching means re-running scaffold."

## `linear` planning behavior

*One-run-exercised (verified against a full real cascade run; recorded 2026-08-09 — per the dated-empirical-rails principle, re-verify the MCP tool surface before re-citing).* The structural model below is the exercised one; the individually-unexercised call shapes are flagged inline.

**The exercised hierarchy** — the planner's entities map to the cascade like this, and the exercised run proved the shape:

```
Initiative                          (provisioned at scaffold — workspace infrastructure)
└── Project shell (one per phase/release, with target date + status; provisioned at scaffold)
    └── Workstream parent ISSUE     (created by blueprint; title `[<slug>] <Workstream name>`)
        └── Framing F sub-issue     (created by framing via parentId)
            └── Rough-in R sub-sub-issue  (created by rough-in via parentId)
```

Two load-bearing negatives from the exercised run: **workstreams are parent issues, never planner Projects** (one-Project-per-workstream fragments the roll-up and breaks framing's parent-issue expectation), and **the Project's native milestones field is deliberately unused** (framing capabilities live as sub-issues, not planner milestones).

If scaffold picked `linear`, blueprint should:

1. **Verify the shell scaffold provisioned**: read scaffold.md's Cascade metadata rows (workspace, initiative, team + issue-key prefix, project shell) and probe them via the planner MCP (`mcp__linear__list_teams`, `get_initiative`/`get_project` reads). If any is missing, surface — the shell is scaffold's job; offer to loop back rather than improvising it here.
2. **Run the axis-common parts**: inheritance read, stack decisions, methodology selection, foundation doc production, blueprint.md commit — identical to `github-issues`.
3. **Write the initiative content into the existing initiative entity** (Goal, Success criteria, Not in scope, Dependencies — mirroring blueprint.md, which stays the source of truth; the entity is the queryable mirror). *Call shape individually unexercised — the exercised run authored the description at provisioning time; disclose and fall back to a manual paste into the planner UI if the update call misbehaves.*
4. **Create one workstream parent issue per Workstreams-table row** via `mcp__linear__save_issue`: `team` = the scaffold-recorded team, `title` = `[<slug>] <Workstream name>`, `description` = the workstream row content + a link back to `docs/cbk/blueprint.md § Workstreams`, `labels` = the workstream area label + `cascade-depth:rough`, project = the project shell. Framing's pre-flight expects these parents to exist.
5. **At the final HITL gate**, record in blueprint.md which planner entities now exist (with URLs) so framing inherits the state instead of re-detecting it.

### When to fall back mid-session

If a specific planner call misbehaves, offer: *(a)* do that one operation manually in the planner UI and continue (the markdown record stays authoritative), or *(b)* drop to `github-issues` semantics for this phase — the cascade still works; the planner-side aggregation is what's lost. Most operators pick (a).

## `in-repo-markdown` planning behavior

If scaffold picked `in-repo-markdown` (the operator opted out of an external planning backend after going through the confirmation gate), blueprint's planning-side writes collapse:

- No workstream parent Issues created on any external backend
- The `blueprint.md` Workstreams table becomes the authoritative workstream list (queried via grep)
- Setup steps that would normally land in a GitHub handoff issue (or Linear initiative description) land in `blueprint.md` § Manual setup instead
- The atomic transition collapses to a single half (just the markdown commit) — no planning-backend rollback needed

The foundation doc production and stack decisions are unchanged — those still produce CLAUDE.md, ARCHITECTURE.md, etc. in the repo. Only the *planning* half is collapsed.

## Exercise status

The `linear` structural model above is **one-run-exercised** (a full real cascade ran on it; recorded 2026-08-09). Individually-unexercised call shapes are flagged inline where they appear — disclose and fall back per operation, never per axis. When a second real run exercises a flagged call, drop its flag and restamp the date.

## Planning-axis detection failure modes

- **Guessing the planning backend from context.** Always read `scaffold.md` first. The Cascade metadata section names the planning axis explicitly — there's no excuse for inferring it from the user's word choice.
- **Assuming Linear MCP is connected when planning = `linear`.** It might not be. Probe early; if missing, fall back to manual Linear operations or offer to switch to `github-issues` fallback.
- **Committing blueprint.md to a different location based on planning axis.** Don't. Blueprint.md is always at `docs/cbk/blueprint.md`. The planning axis determines what *additional* artifacts get created (Linear initiative entity when `linear`, workstream parent Issues when `github-issues`), never where the markdown lives.
- **Skipping the gap-honesty disclosure for `linear`.** Documentation gaps are bugs only if blueprint pretends they aren't. Disclose, fall back, document.

## Light-mode behavior

Planning-axis detection and routing is non-negotiable in light mode. The light-mode collapses apply to *what blueprint produces* (fewer foundation docs, batched HITL gates, etc.), not to which planning backend the operations target.

For `linear` planning + light mode: still verify the scaffold-provisioned shell and still flag any individually-unexercised call before attempting it. *"Linear planning, light mode. I'll produce the docs you asked for, commit them via GitHub MCP, commit blueprint.md to `docs/cbk/`, then verify the planner shell and create the workstream parent issues. If a specific planner call misbehaves I'll hand you the one-step manual fallback rather than improvising. Sound okay?"*

## Knowledge backend interactions

The knowledge backend axis (`notion` / `none`) is orthogonal to this file. When knowledge = `notion`:

- Blueprint's optional inheritance fetch (read patterns from Notion at the inheritance step) is governed by `.claude/rules/knowledge-backend.md` § "When to read" — read-primary, opt-in, no default fetches
- Blueprint's optional Notion-write gate (promoting strategy content to a companion page when blueprint identifies genuinely cross-project material) is governed by `.claude/rules/knowledge-backend.md` § "When to write" — default-SKIP, HITL-gated

Neither knowledge-backend interaction affects the planning-axis behavior documented above. The two axes can be mixed freely.
