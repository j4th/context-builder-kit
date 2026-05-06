# Profile-aware behavior — GitHub-only vs opinionated

How blueprint's behavior differs between the two backend profiles. Read this once at session start to understand the routing, then refer back when an operation is profile-specific.

The profile is determined by `scaffold.md`'s Cascade metadata section. **Read it before doing anything profile-dependent.** Do not guess the profile from context — every later phase trusts that blueprint correctly routed based on the scaffold output.

## Quick reference matrix

| Operation | GitHub-only | Opinionated (Linear+GitHub) |
|---|---|---|
| Read inheritance | `docs/cbk/problem_brief.md` + `docs/cbk/scaffold.md` via GitHub MCP | Same path, same MCP |
| Stack decisions | Recorded in ARCHITECTURE.md + blueprint.md | Same |
| Methodology selection | Recorded in blueprint.md | Same, plus may inform Linear cycle length |
| Foundation docs (CLAUDE, ARCHITECTURE, STANDARDS, CONTRIBUTING, README) | Commit to repo via GitHub MCP | Same |
| `blueprint.md` | Commit to `docs/cbk/blueprint.md` via GitHub MCP | Same, plus create Linear initiative entity |
| Initiative content destination | Lives only in `docs/cbk/blueprint.md` | Lives in `docs/cbk/blueprint.md` AND mirrored as a Linear initiative |
| Tooling configs | Commit to repo (`.github/workflows/`, task runner config, .env.example) | Same |
| Linear MCP needed? | No | Yes |
| Notion MCP needed? | No | Yes (for the kara-validated: surface gap, fall back to manual) |
| HITL gate count | 6 default | 6 default + 1 extra for Linear initiative confirmation |

## GitHub-only profile behavior

**The default and most common case** — also the only profile that's fully fleshed out in v1. If the user picked github-only in scaffold, blueprint operates entirely against the GitHub repo. There is no Linear, no Notion, no cross-tool integration.

The structural fact that shapes everything: **GitHub-only is three-level** (project board → milestone → issue), with no native concept of "initiative." This was surfaced and explicitly acknowledged in scaffold's profile selection. Blueprint's job under this constraint is to produce the initiative content **as a markdown document at `docs/cbk/blueprint.md`** rather than as a planning entity. Framing then reads that document as context for project decomposition.

Concretely:

1. **Read inheritance** via GitHub MCP file-read against the repo URL from scaffold.md
2. **Run all five steps** (inheritance → stack decisions → methodology → foundation docs → blueprint.md content) inside chat with HITL gates
3. **Commit each foundation doc** to its target location via GitHub MCP file-write after HITL approval
4. **Commit `blueprint.md`** to `docs/cbk/blueprint.md` after the final HITL gate
5. **Tell the user** that blueprint is complete and framing inherits from the committed file

**No Linear operations**, ever, in github-only mode. If the user asks "where do I see this in Linear?" the answer is "Linear isn't in scope for this profile — the cascade is in github-only mode, so initiatives live as markdown documents in `docs/cbk/`. If you want Linear, that would mean switching profiles, which is a scaffold-level decision."

## Opinionated profile behavior — kara-validated

**Status: stub.** Same as in scaffold's `references/opinionated_profile.md`. The opinionated profile is structurally supported in blueprint's SKILL.md but the operational detail for Linear and Notion operations is deferred to a follow-up after one full cascade run through github-only mode validates the patterns.

If the user picked opinionated in scaffold, blueprint should:

1. **Tell the user honestly** that the opinionated profile is a kara-validated: *"Heads up — the opinionated profile is structurally supported but the detailed Linear/Notion operations for blueprint are a stub in v1. I'll walk through what's documented and flag gaps as we hit them. If we hit something I don't have a clean answer for, I'll either fall back to manual instructions or offer to switch to github-only mode for this phase. Sound okay to start?"*
2. **Run the parts that are documented**: inheritance read (same as github-only), stack decisions (same), methodology selection (same), foundation doc production (same — commit to GitHub repo), blueprint.md commit (same — commit to `docs/cbk/blueprint.md` via GitHub MCP).
3. **For the Linear initiative creation step**: walk through what should happen at a high level, ask if the user wants to attempt it via Linear MCP (with the caveat that exact tool names and inputs aren't documented in this stub) or do it manually in Linear's UI.
4. **Flag every gap as it happens**. Do not pretend coverage that doesn't exist.
5. **At the final HITL gate**, mark blueprint as "complete-with-gaps" and document which Linear operations the user did manually so framing knows the state.

### What's documented enough to attempt in opinionated mode

- **GitHub repo operations**: same as github-only — file commits via GitHub MCP work identically
- **`docs/cbk/blueprint.md` commit**: same path, same mechanism
- **Linear team verification**: a read-only check via Linear MCP that the team exists and the user has permission to create initiatives under it
- **Linear initiative entity creation**: high-level outline only — propose creating it via Linear MCP, fall back to manual Linear UI if MCP calls fail or the tool surface doesn't match

### What's deferred (gaps to flag honestly)

- **Linear initiative entity creation via MCP**: the operations exist but the exact tool names and input shapes aren't documented in this stub
- **Notion long-form spec creation**: deferred entirely — for now, the cascade artifact lives in `docs/cbk/blueprint.md` regardless of profile, and Notion isn't used in v1
- **Cross-tool integration verification** (Linear↔GitHub branch linking, Linear↔Notion live previews): not validated end-to-end in this stub

### When to fall back to github-only mid-session

If a user picked opinionated in scaffold and blueprint hits a gap they can't work around, offer a fallback: *"This Linear operation isn't documented in the kara-validated. We have two options: (a) you do the Linear initiative creation manually in the UI after we finish, and I just commit blueprint.md to `docs/cbk/`; or (b) we treat this phase as github-only, which means no Linear initiative gets created at all — the cascade still works, you just lose the Linear-side aggregation. Which do you prefer?"*

Most users hitting a stub gap pick (a) — manual Linear creation is fine, and blueprint.md still serves as the cascade record. The (b) option exists for users who don't want to maintain a Linear entity at all.

## When this file should be fleshed out

The opinionated profile reference should get its full treatment **after one real run through github-only mode produces a working cascade end-to-end and one real run through opinionated mode validates the Linear MCP patterns**. Premature documentation of operations that haven't been validated against real sessions is exactly the kind of speculative work the cascade is supposed to avoid.

When that real opinionated run happens, this file gets:

- Exact Linear MCP tool names and input shapes for initiative creation
- Verified handling of Linear initiative state (planned/active/completed) at blueprint time
- The initiative description format for Linear that mirrors blueprint.md content
- Linear-side label taxonomy alignment with the cascade labels from scaffold
- A verification matrix entry for "the Linear initiative was created and is queryable"

Until then, opinionated mode in blueprint is honest-and-stub.

## Profile detection failure modes

- **Guessing the profile from context.** Always read `scaffold.md` first. The Cascade metadata section names the profile explicitly — there's no excuse for inferring it from the user's word choice.
- **Assuming Linear MCP is connected in opinionated mode.** It might not be. Probe early; if missing, fall back to manual Linear operations or offer to switch to github-only fallback.
- **Committing blueprint.md to a different location based on profile.** Don't. Blueprint.md is always at `docs/cbk/blueprint.md`. The profile determines what *additional* artifacts get created (Linear initiative entity in opinionated mode), never where the markdown lives.
- **Skipping the gap-honesty disclosure in opinionated mode.** kara-validateds are bugs only if blueprint pretends they aren't. Disclose, fall back, document.

## Light-mode behavior

Profile detection and routing is non-negotiable in light mode. The light-mode collapses apply to *what blueprint produces* (fewer foundation docs, batched HITL gates, etc.), not to which profile the operations target.

For opinionated profile + light mode: still disclose the kara-validated status. *"Opinionated profile, light mode. I'll produce the docs you asked for, commit them via GitHub MCP, and commit blueprint.md to `docs/cbk/`. Linear initiative creation is a kara-validated — I'll generate manual instructions for you to run after we finish. Sound okay?"*
