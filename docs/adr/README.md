# Architecture Decision Records (ADRs)

This directory holds Architecture Decision Records — small, immutable documents that capture significant technical and architectural decisions, the context that motivated them, the alternatives considered, and the consequences accepted.

The format follows Michael Nygard's *Documenting Architecture Decisions* (2011), with light additions for cross-references and an optional configurability evaluation section. The pattern itself is established by [ADR-0000](0000-record-architecture-decisions.md).

## How to add a new ADR

The `/adr-new` Claude Code skill (`.claude/skills/adr-new/SKILL.md`) automates this. Manual process if needed:

1. Copy `template.md` to `NNNN-kebab-title.md`, where `NNNN` is the next four-digit number.
2. Fill in the Status block, Context, Options Considered, Decision, and Consequences. Add a Configurability evaluation if it's a component-level decision and the project has a configurability-first principle.
3. Add cross-references in `Related` if the new ADR connects to existing ones.
4. Add a row to the Index in this README and to the Decisions log in `docs/ARCHITECTURE.md`. If the project tracks stack decisions in `docs/cbk/blueprint.md`, mirror there too.
5. Open a PR. ADR text changes through normal review.
6. After merge, an accepted ADR is **immutable** — its content is not edited again. Updates happen via new ADRs that supersede the old (Status: `Superseded by ADR-NNNN`). The PreToolUse hook in `.claude/hooks/protect-immutable-adrs.sh` enforces this at the Claude Code tool level; the `.github/workflows/adr-immutability-check.yml` CI workflow enforces it at the raw-git level.

## Status legend

| Status | Meaning |
|---|---|
| `Proposed` | Drafted, not yet accepted |
| `Accepted` | Active and binding |
| `Deprecated` | No longer recommended, but still in effect; new code should not assume it |
| `Superseded by ADR-NNNN` | Replaced by a newer decision |

## Numbering convention

- Four-digit prefix, zero-padded: `0001`, `0002`, ..., `0099`, `0100`
- Kebab-case slug describing the decision in 3–7 words
- One ADR per file
- Numbers are append-only — superseded ADRs keep their original number, with status updated to point at their successor
- The reference vocabulary in prose and code comments is `ADR-NNNN` (matching the file prefix)

## Index

| # | Title | Status |
|---|---|---|
| [0000](0000-record-architecture-decisions.md) | Record architecture decisions | Accepted |
