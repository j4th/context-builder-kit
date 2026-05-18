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
| `blueprint.md` | Commit to `docs/cbk/blueprint.md` via GitHub MCP | Same, plus create Linear initiative entity | Same; planning-side setup steps land in § Manual setup |
| Initiative content destination | Lives only in `docs/cbk/blueprint.md` | Lives in `docs/cbk/blueprint.md` AND mirrored as a Linear initiative | Lives only in `docs/cbk/blueprint.md`; no external initiative |
| Workstream parent Issues | Create one per workstream via GitHub MCP `issue_write` | Create one Project per workstream via Linear MCP | Recorded as rows in `blueprint.md` Workstreams table only |
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

The `linear` planning path is structurally supported in blueprint's SKILL.md but the operational detail for some Linear operations isn't fully documented; gaps are flagged inline where they apply. (This honesty is per-operation, not per-profile — the old "opinionated profile stub" framing is gone; specific Linear MCP calls are documented or not, individually.)

If scaffold picked `linear`, blueprint should:

1. **Tell the user honestly** about the documented vs deferred operations: *"Linear-planning is structurally supported but the detailed Linear MCP operations for blueprint aren't all documented. I'll walk through what's documented and flag gaps as we hit them. If we hit something I don't have a clean answer for, I'll either fall back to manual instructions or offer to switch to `github-issues` mode for this phase. Sound okay to start?"*
2. **Run the parts that are documented**: inheritance read (same as `github-issues`), stack decisions (same), methodology selection (same), foundation doc production (same — commit to GitHub repo), blueprint.md commit (same — commit to `docs/cbk/blueprint.md` via GitHub MCP).
3. **For the Linear initiative creation step**: walk through what should happen at a high level, ask if the user wants to attempt it via Linear MCP (with the caveat that exact tool names and inputs aren't fully documented here) or do it manually in Linear's UI.
4. **Flag every gap as it happens**. Do not pretend coverage that doesn't exist.
5. **At the final HITL gate**, mark blueprint as "complete-with-gaps" and document which Linear operations the user did manually so framing knows the state.

### What's documented enough to attempt in `linear` mode

- **GitHub repo operations**: same as `github-issues` — file commits via GitHub MCP work identically
- **`docs/cbk/blueprint.md` commit**: same path, same mechanism
- **Linear team verification**: a read-only check via Linear MCP that the team exists and the user has permission to create initiatives under it
- **Linear initiative entity creation**: high-level outline only — propose creating it via Linear MCP, fall back to manual Linear UI if MCP calls fail or the tool surface doesn't match

### What's deferred (gaps to flag honestly)

- **Linear initiative entity creation via MCP**: the operations exist but the exact tool names and input shapes aren't fully documented here
- **Linear Project creation per workstream**: the cascade's parent-Issue equivalent is a Linear Project; MCP-driven creation isn't fully documented for this case
- **Linear label taxonomy alignment**: applying the cascade-standard label set to a Linear workspace via MCP isn't documented in detail

### When to fall back to `github-issues` mid-session

If the operator picked `linear` in scaffold and blueprint hits a gap they can't work around, offer a fallback: *"This Linear operation isn't documented yet. We have two options: (a) you do the Linear initiative creation manually in the UI after we finish, and I just commit blueprint.md to `docs/cbk/`; or (b) we treat this phase as `github-issues`, which means no Linear initiative gets created at all — the cascade still works, you just lose the Linear-side aggregation. Which do you prefer?"*

Most operators hitting a documentation gap pick (a) — manual Linear creation is fine, and blueprint.md still serves as the cascade record. The (b) option exists for operators who don't want to maintain a Linear entity at all.

## `in-repo-markdown` planning behavior

If scaffold picked `in-repo-markdown` (the operator opted out of an external planning backend after going through the confirmation gate), blueprint's planning-side writes collapse:

- No workstream parent Issues created on any external backend
- The `blueprint.md` Workstreams table becomes the authoritative workstream list (queried via grep)
- Setup steps that would normally land in a GitHub handoff issue (or Linear initiative description) land in `blueprint.md` § Manual setup instead
- The atomic transition collapses to a single half (just the markdown commit) — no planning-backend rollback needed

The foundation doc production and stack decisions are unchanged — those still produce CLAUDE.md, ARCHITECTURE.md, etc. in the repo. Only the *planning* half is collapsed.

## When this file should be fleshed out

The `linear` planning operations should get their full operational detail (Linear MCP tool names per operation, label-taxonomy alignment script, cross-tool verification matrix) after one real run through `linear` mode exercises the patterns. Premature documentation of operations that haven't been exercised against real sessions is exactly the kind of speculative work the cascade is supposed to avoid.

When that real `linear` run happens, this file gets:

- Exact Linear MCP tool names and input shapes for initiative + Project creation
- Verified handling of Linear initiative state (planned/active/completed) at blueprint time
- The initiative description format for Linear that mirrors blueprint.md content
- Linear-side label taxonomy alignment with the cascade labels from scaffold
- A verification matrix entry for "the Linear initiative was created and is queryable"

Until then, `linear` mode in blueprint operates with the documented operations and discloses gaps honestly.

## Planning-axis detection failure modes

- **Guessing the planning backend from context.** Always read `scaffold.md` first. The Cascade metadata section names the planning axis explicitly — there's no excuse for inferring it from the user's word choice.
- **Assuming Linear MCP is connected when planning = `linear`.** It might not be. Probe early; if missing, fall back to manual Linear operations or offer to switch to `github-issues` fallback.
- **Committing blueprint.md to a different location based on planning axis.** Don't. Blueprint.md is always at `docs/cbk/blueprint.md`. The planning axis determines what *additional* artifacts get created (Linear initiative entity when `linear`, workstream parent Issues when `github-issues`), never where the markdown lives.
- **Skipping the gap-honesty disclosure for `linear`.** Documentation gaps are bugs only if blueprint pretends they aren't. Disclose, fall back, document.

## Light-mode behavior

Planning-axis detection and routing is non-negotiable in light mode. The light-mode collapses apply to *what blueprint produces* (fewer foundation docs, batched HITL gates, etc.), not to which planning backend the operations target.

For `linear` planning + light mode: still disclose the documentation gaps. *"Linear planning, light mode. I'll produce the docs you asked for, commit them via GitHub MCP, and commit blueprint.md to `docs/cbk/`. Linear initiative creation isn't fully documented — I'll generate manual instructions for you to run after we finish. Sound okay?"*

## Knowledge backend interactions

The knowledge backend axis (`notion` / `none`) is orthogonal to this file. When knowledge = `notion`:

- Blueprint's optional inheritance fetch (read patterns from Notion at the inheritance step) is governed by `.claude/rules/knowledge-backend.md` § "When to read" — read-primary, opt-in, no default fetches
- Blueprint's optional Notion-write gate (promoting strategy content to a companion page when blueprint identifies genuinely cross-project material) is governed by `.claude/rules/knowledge-backend.md` § "When to write" — default-SKIP, HITL-gated

Neither knowledge-backend interaction affects the planning-axis behavior documented above. The two axes can be mixed freely.
