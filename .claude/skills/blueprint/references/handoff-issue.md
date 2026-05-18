# Handoff issue — the seventh step

After all foundation docs are committed, all tooling configs are committed, and `docs/cbk/blueprint.md` is committed, blueprint creates **one issue** in the project's tracker (GitHub issue in github-only mode, Linear issue in opinionated mode) that serves as the human's runlist for getting the repo functional. This is the cascade's transition from "blueprint-controlled bootstrap with exempted gates" to "normal development with full gates applied."

## Why an issue and not a doc section

Blueprint's outputs are docs the human reads when they want to understand the project. The first-build runlist is *work* the human does once and then never again. Work belongs in the tracker, not in a doc that has to be edited to remove it. The issue closes when the bootstrap is done; a doc section either goes stale or requires a follow-up commit to delete.

The version-pin warning is the strongest single reason this exists. Blueprint writes pinned versions based on what was current in training data, but between the blueprint session and the user's first real build (often days or weeks later) any number of upstream releases may have happened. Without a runlist surface, the user comes back cold and hits build failures with no context.

## Issue title

Stable across projects so it's recognizable in cascade history three months later:

- **Greenfield**: `Blueprint handoff: bootstrap and validate pins`
- **Brownfield**: `Blueprint bootstrap: validate pins and complete setup`

The word "blueprint" in the title is what makes it greppable. Use the project's `chore` label (or equivalent — never `tech-debt`, this is bootstrap by design, not accumulated shortcut).

## Issue body template

```markdown
This issue marks the end of the bootstrap exemption. Closing it transitions
the repo from blueprint-controlled setup (where the commits installing CI
gates were exempt from those gates) to normal development (where every PR
runs through `<gate name>`). Work through the checklist below before closing.

## 1. Toolchain bootstrap

\```bash
<first-time setup command — typically `mise trust && mise install` or
project equivalent>
\```

## 2. Validate version pins ⚠️

Blueprint drafted version strings without verifying current upstream
releases. Expect to bump several before the build is clean. Run
`<update command — typically `cargo update`>` and verify each of the
following:

<If `.github/dependabot.yml`, `renovate.json`, `.github/renovate.json`,
or `.renovaterc` exists in the committed configs, insert this paragraph
before the file inventory:>

> **Auto-update bot detected**: this repo has `<Dependabot | Renovate>`
> configured (`<config file path>`). Check open PRs from `<dependabot[bot]
> | renovate[bot]>` first — they may already cover several of the bumps
> below. Merge those, then verify the inventory against what's left.

**`Cargo.toml`** (or language equivalent):
- `<dep name> = "<version>"`
- `<dep name> = "<version>"`
- [list every dep blueprint pinned, grouped by file]

**`mise.toml`**:
- `<tool> = "<version>"`
- [list every tool version]

**`.github/workflows/*.yml`**:
- `<action>@<version>`
- [list every action ref]

The full inventory above is intentional — you should not have to grep to
find what to check.

## 3. Manual setup steps

The cascade cannot automate these. See `docs/cbk/blueprint.md` § "Credential
model" for background on why each is needed.

- [ ] Run `/install-github-app` inside Claude Code (or equivalent for
      whatever review automation was chosen)
- [ ] Create the local PAT and run `<setup script>` to wire up MCP access
- [ ] [Any other manual steps from blueprint's stack decisions]

## 4. Definition of done

- [ ] `<setup command>` completes cleanly
- [ ] `<full-check command>` (e.g., `mise run check`) passes locally
- [ ] CI is green on all matrix OSes
- [ ] `<setup script>` runs clean
- [ ] This issue closed

## 5. What's next

Once this issue closes, the next cascade phase is **framing**. Read
`docs/cbk/blueprint.md` § "Workstreams" and pick the first project
to framing-decompose. The recommended starting point is `<first project
from blueprint.md, typically the one stress-testing the load-bearing
abstraction>`.
```

## Version inventory subroutine

When generating section 2, blueprint walks every config file it just committed and lists every pinned version verbatim. Group by file. Do not filter to "risky" pins — the verbosity is the feature. The user should see every name without grep.

Files to walk for the inventory:
- The language-specific manifest (Cargo.toml workspace deps, package.json deps, pyproject.toml deps, etc.)
- Toolchain pinning (mise.toml, .tool-versions, .nvmrc, rust-toolchain.toml, etc.)
- CI workflow files for action refs (`.github/workflows/*.yml`, `.gitlab-ci.yml`, etc.)
- Any other config file blueprint committed that contains version strings

If blueprint committed a Dockerfile, base image tags count too.

### Auto-update bot detection

Before generating the inventory, check whether the committed configs include an auto-update bot. If so, the inventory section gets a header paragraph that cross-references the bot's open PRs — without it, the user does the update work twice (once via the inventory, once via merging the bot's PRs).

Detection rules:

| File present | Bot | Reference in issue body |
|---|---|---|
| `.github/dependabot.yml` (or `.yaml`) | Dependabot | `dependabot[bot]` PRs |
| `renovate.json`, `.github/renovate.json`, or `.renovaterc(.json)` | Renovate (hosted) | `renovate[bot]` PRs |
| `.github/workflows/*.yml` containing `renovate` action | Renovate (self-hosted) | `<custom bot account>` PRs |
| None of the above | (no auto-update bot) | Skip the cross-reference paragraph entirely |

If multiple are detected (rare but possible — some teams run Renovate alongside Dependabot for different ecosystems), reference both in the cross-reference paragraph and let the user know which bot covers which file.

The cross-reference paragraph is informational — it does not change the inventory itself. The full file-by-file list still gets emitted. The paragraph just tells the user "merge the bot PRs first, then walk the inventory for what's left." The inventory remains the source of truth for "what was pinned"; the bot PRs are the source of truth for "what's already been bumped since."

## Brownfield variant

For brownfield blueprint runs (existing repo, existing history), the issue still applies but the framing shifts:

- Title: `Blueprint bootstrap: validate pins and complete setup` (no "First")
- Body opening line: drop "marks the end of the bootstrap exemption" *unless* the run actually installed a new gate; brownfield runs that didn't install gates should say *"This issue tracks the validation work for the build-system files blueprint just committed."* instead.
- Section 5 ("What's next") may point to whatever phase the user wants next, not necessarily framing — brownfield users sometimes run blueprint as a one-off without continuing the cascade.

## Planning-axis differences

**`github-issues` planning**: create the issue via GitHub MCP. Use `chore` and any area labels that match the bootstrap work.

**`linear` planning**: create the issue in the project's Linear team via Linear MCP. Use whatever Linear label the project uses for chore-equivalent. The issue should link to the GitHub repo so the user can navigate from Linear to the actual setup commands.

**`in-repo-markdown` planning**: there is no external planning backend; the handoff content lives in `blueprint.md` § Manual setup instead of as a separate tracker entity.

In `github-issues` and `linear`, the issue is **non-optional** and **uniform in shape** — same body template, same checklist structure. The only axis-dependent piece is which tracker it lives in.

## Issue numbering edge case

If the repo already has issues from scaffold or pre-existing setup, the handoff issue won't be #1. Don't try to make it #1 by closing other issues; the symbolic moment is less important than the issue existing at all. The greppable title is what makes it findable later, not the number.

## Safety floor — non-negotiable in any rigor mode

The handoff issue is one of blueprint's hard safety floors. Even in light mode (where the user has explicitly asked for the lightest possible flow), the handoff issue gets created. The cost of skipping is "user returns to repo in two weeks, can't remember what to do, has to read three foundation docs to reconstruct"; the cost of doing it is one tool call. Asymmetric — always create.

The only exception: if the user explicitly says *"don't create a handoff issue, I'll do my own runlist"*, honor that and note in the final blueprint message that the handoff issue was skipped per user request. This is the same opt-out pattern as CONTRIBUTING.md for solo projects — explicit user override is allowed; silent omission is not.

## Failure mode: ephemeral steps in blueprint.md

Before this pattern existed, the natural place for first-build setup steps was a "Manual setup runlist" section in blueprint.md. That's now wrong — those steps belong in the handoff issue. blueprint.md should contain the **evergreen credential model** (what credentials exist, why, how they rotate) and *not* the **ephemeral setup commands** (run this, then run that). See `references/blueprint-output-template.md` for the restructured § "Credential model" section.

If you find yourself drafting blueprint.md content that reads like a "do these steps once" runlist, stop — that content goes in the handoff issue instead.

## Failure mode: editing the handoff issue body instead of commenting

When updating the handoff issue *after* creation (to record progress, note completion of items, capture decisions made during the work), use **comments**, not body edits. The body is the original handoff record — its history is hard to inspect on GitHub, and edits silently overwrite the original content. Comments are append-only, timestamped, threaded into the issue history, and visible to anyone reading the issue later.

Specifically: when an item from the handoff checklist gets done, add a comment like *"Completed: <item>, see commit/PR #N"*, do not check off the item by editing the body. When a decision gets made that wasn't in the original handoff, add a comment with the decision and rationale. The body stays as the historical record of what blueprint produced; comments accumulate as the runtime log of what happened against it.

The exception is the cascade itself updating the handoff during a known transition point (e.g., framing closing out the relevant handoff items as part of its commit). Those edits are programmatic, traceable, and happen at well-defined moments. Manual or ad-hoc updates by humans during the work should be comments.
