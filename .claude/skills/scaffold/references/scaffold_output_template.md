# Scaffold output template

The persistent artifact scaffold produces. Lives at `docs/cbk/scaffold.md` in the repo. Read by blueprint and all later phases. Contains everything scaffold learned about the team and workspace — the raw material blueprint uses to write standards.md, contributing.md, and calibrate the initiative spec.

## Template

```markdown
# Scaffold: <project name>

*Produced by scaffold (phase 2). Read by blueprint and all later phases.
This file captures the working context for this project — team shape,
conventions, preferences, and cascade metadata. Blueprint will formalize
the developer-facing parts into standards.md and contributing.md.*

## Cascade metadata

**Profile**: <github-only | opinionated>
**Hierarchy levels**: <3 | 4>
**Knowledge surface**: docs/cbk/
**Repo**: <URL>
**Project board**: <URL or "not yet created">
**Provisioned**: <date>

<For github-only: "Three-level mode. Blueprint will produce
docs/cbk/initiative.md as a markdown document, not a GitHub planning entity.">

## Team shape

<Solo or team. If solo, one sentence is fine: "Solo developer, evenings
and weekends." If team: size, roles, who makes the call when there's a
disagreement, sync or async, timezone spread. Answer "who is working on
this and how do they coordinate?">

## Working conventions

**Team identifier**: <SHORT_UPPERCASE>

**Branch naming**: `<team-id>-<issue-number>-<short-description>`
Examples:
- `<example-1>`
- `<example-2>`

**Commit format**: <Conventional Commits | project-specific format>
<If Conventional Commits: type prefixes are feat, fix, chore, docs,
refactor, test, style. Scope is optional.>

**Label taxonomy**:
- Type labels (one per issue): bug, feature, improvement, tech-debt,
  documentation
- Area labels (zero or more): <derived from problem brief>

## Development preferences

**Quality bar**: <user's stated preference. Examples: "Move fast, tests
for critical paths only." "Deliberate — full test coverage, no merging
without review." "Somewhere in between — tests for public interfaces,
review on non-trivial PRs.">

**PR/review process**: <How PRs work. Examples: "Solo-merge, no review."
"Self-review before merge." "Reviewed by at least one other person, 24hr
turnaround." "Round-robin review across the team.">

**Testing philosophy**: <Not framework-specific — the ethos. Examples:
"TDD for core logic, integration tests for happy paths." "Tests for
regressions only." "Comprehensive coverage is a goal.">

**Pace**: <Full-time | Part-time | Evenings and weekends | Specific
time blocks>

**Decision recording**: <How decisions get captured. Examples: "ADRs for
significant choices." "PR descriptions." "Issue comments." "Verbal and
move on — this is a solo project.">

## Tool landscape

**Detection state**: <1 (MCP + write) | 2 (MCP + read-only) | 3 (no MCP)>
**Connected MCPs**: <what was available in the scaffold session>
**Manual operations completed**: <what the user did by hand — labels,
project board, branch protection, etc.>
**Integration status**: <what's verified working>
**Tool comfort**: <user's self-assessed familiarity — first-timer,
comfortable, veteran>
```

## Per-section guidance

**Cascade metadata**: the most-read section by Claude in future sessions. The `Profile` and `Hierarchy levels` lines must be unambiguous — later phases branch on them. Keep the three-level note for GitHub-only mode as a one-liner.

**Team shape**: answers "who is working on this and how." Solo is one sentence. Team needs enough detail that blueprint can decide whether to recommend pair programming, what review process to propose, and whether async coordination needs tooling support.

**Working conventions**: the mechanical agreements — branch format, commit format, labels. These were confirmed with the user during provisioning. Blueprint will reference them in contributing.md rather than re-deriving them.

**Development preferences**: the human judgment calls that shape standards.md. Quality bar is the most important field — it determines whether blueprint proposes comprehensive test coverage or tests-for-critical-paths-only, strict PR review or self-merge, aggressive CI or a stub. These are the user's *stated preferences*, not finalized standards. Blueprint may push back or refine them based on stack decisions.

**Tool landscape**: what's actually available. Useful for blueprint when deciding how much to automate (CI, deployment, testing) and for future phases when they need to know what MCP state to expect.

## Worked example — solo CLI project

```markdown
# Scaffold: notes-cli

## Cascade metadata

**Profile**: github-only
**Hierarchy levels**: 3
**Knowledge surface**: docs/cbk/
**Repo**: https://github.com/jforth/notes-cli
**Project board**: https://github.com/users/jforth/projects/4
**Provisioned**: 2026-04-11

Three-level mode. Blueprint will produce docs/cbk/initiative.md as a
markdown document, not a GitHub planning entity.

## Team shape

Solo developer, evenings and weekends. No coordination overhead.

## Working conventions

**Team identifier**: NOTES

**Branch naming**: `notes-<issue-number>-<short-description>`
Examples:
- `notes-1-capture-prototype`
- `notes-2-search-interface`

**Commit format**: Conventional Commits. Scopes: capture, search, storage.

**Label taxonomy**:
- Type: bug, feature, improvement, tech-debt, documentation
- Area: area:capture, area:search, area:storage

## Development preferences

**Quality bar**: Move fast, tests for critical paths. Not TDD — write
tests after the implementation stabilizes. Refactor when it hurts.

**PR/review process**: Solo-merge. No formal review. Glance at the diff
before merging as a sanity check.

**Testing philosophy**: Integration tests for the happy path of each
major feature. Unit tests for tricky logic. No coverage target.

**Pace**: Evenings and weekends, roughly 8–10 hours/week.

**Decision recording**: Issue comments for anything non-obvious.
No ADRs — project is small enough that architecture fits in one head.

## Tool landscape

**Detection state**: 1 (MCP + write)
**Connected MCPs**: GitHub MCP (write scopes via fine-grained PAT)
**Manual operations completed**: labels created, project board created
(Board template), branch protection on main (require PR)
**Integration status**: repo accessible, labels verified, project board
linked, docs/cbk/ committed
**Tool comfort**: comfortable — not first time with GitHub, first time
with GitHub Projects v2
```

## Minimum-mode collapse

If the user invoked light mode, the scaffold output doc collapses to essentials:

```markdown
# Scaffold: <project name>

**Profile**: github-only | **Levels**: 3 | **Knowledge**: docs/cbk/
**Repo**: <URL> | **Board**: <URL>

**Team**: <solo | team of N>
**Quality bar**: <one sentence>
**Branches**: `<team>-<issue>-<desc>`
**Labels**: bug, feature, improvement, tech-debt, documentation
```

Eight lines. Captures the minimum blueprint needs to operate: profile, hierarchy levels, team shape, quality bar, and branch/label conventions. Everything else gets re-derived in blueprint if needed.
