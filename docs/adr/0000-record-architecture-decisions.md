# 0000. Record architecture decisions

- **Status:** Accepted
- **Date:** YYYY-MM-DD  *(replace with the date the project adopts the ADR pattern)*
- **Deciders:** <project owner / team>

## Context

This is a long-lived project, expected to outlive the active working memory of why specific decisions were made. The blueprint phase (and subsequent framing, rough-in, and implementation phases) generate architectural decisions over time. Without an explicit record of why decisions were made, future contributors — including future-you — will have to either re-derive the rationale (slow, error-prone, possibly arriving at different answers) or accept the existing code without understanding it (also slow, also error-prone).

Inline decisions logs in `docs/ARCHITECTURE.md` work for small projects but don't scale: the file grows large enough to push against context-window thresholds for AI-assisted development sessions, and the inline-log pattern makes it harder to track the lifecycle of a single decision (when it was made, when its status changed, what superseded it).

## Options Considered

1. **Inline log in `ARCHITECTURE.md`** — single file, lowest discovery cost. Doesn't scale with decision count; doesn't support per-decision status changes; pushes against context-window thresholds as the project grows.
2. **One-file-per-decision in `docs/adr/` (Nygard ADR pattern)** — proven pattern, standard layout, individual files stay small and focused, supports per-decision lifecycle tracking. Higher discovery cost mitigated by an index in the directory README and a mirrored index in `ARCHITECTURE.md`.
3. **External tool (e.g., Backstage, Notion ADR plugin)** — supports rich linking and search, but adds an external dependency and breaks "the docs travel with the code." Wrong fit for projects that want decisions versioned alongside the source.

## Decision

We adopt the **ADR pattern** (option 2). Decisions live as individual numbered files under `docs/adr/`. The format follows Michael Nygard's *Documenting Architecture Decisions* (2011), with light additions:

- **Status block** at the top with explicit fields (Status, Date, Deciders, Related).
- **Options Considered** as a first-class section. Most ADRs have non-trivial alternatives worth recording — the rationale for the chosen path is half the value, and rationale is hollow without the rejected alternatives.
- **Configurability evaluation** as an optional section for component-level decisions (a project that adopts a configurability-first principle records that as its own ADR and references it from this section in subsequent ADRs).
- **Cross-references** via `Related: ADR-NNNN` in the status block.

`docs/ARCHITECTURE.md` becomes the orientation document — system overview, component map, key flows, cross-cutting concerns, and an index of accepted ADRs — rather than the decisions log itself.

ADRs are **immutable once accepted**. To revise a decision, write a new ADR that supersedes the old one (the old one's status updates to `Superseded by ADR-NNNN` but its content stays as written). This preserves the history of "we tried this, then we tried that, here's why we ended up here" rather than papering over it.

Reference vocabulary throughout the codebase is `ADR-NNNN` (four digits, matching the file prefix).

Immutability is enforced two ways:

- **`.claude/hooks/protect-immutable-adrs.sh`** — PreToolUse hook blocks Claude Code edits to existing ADR files
- **`.github/workflows/adr-immutability-check.yml`** — CI lint diffs `docs/adr/[0-9]{4}-*.md` files in PRs and fails on changes to existing ADRs (closes the raw-git-access gap that the hook can't catch)

## Consequences

- Decision history becomes durable and grep-able. Future contributors can trace why any given choice was made by reading a single small file.
- `ARCHITECTURE.md` stays light — closer to ~10KB than ~50KB — and stays inside the AI-assisted-development context-friendly size band as the project grows.
- Adding a new ADR has a small process cost: copy `template.md`, fill in five sections, add to the indexes (the directory README and `ARCHITECTURE.md`), link from the relevant cascade artifact (`docs/cbk/frame-NN.md` etc.). The `adr-new` skill (`.claude/skills/adr-new/SKILL.md`) automates the cross-index sync. The friction is intentional — friction here is a feature, not a bug, because it forces the writer to think before recording.
- Decisions are append-only. Mistakes don't get rewritten; they get superseded.
- Cross-references between ADRs require manual maintenance. Tooling could automate this later if it becomes painful; for now, the manual links + index in two places is enough.

## References

- Michael Nygard, *Documenting Architecture Decisions* (2011): <https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions>
- ADR community resources: <https://adr.github.io/>
- The ADR index for this project: [docs/adr/README.md](README.md)
