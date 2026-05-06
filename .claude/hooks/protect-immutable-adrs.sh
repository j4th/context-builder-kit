#!/usr/bin/env bash
# PreToolUse hook: block edits/writes to existing immutable ADR files.
#
# ADRs in docs/adr/<NNNN>-*.md are immutable per ADR-0000.
# Superseding requires a NEW ADR (with a higher number that links to the old
# one as `Supersedes:`) — never an edit to the old one.
#
# Allowed:
#   - creating a new ADR file (NNNN doesn't exist yet)
#   - editing docs/adr/template.md
#   - editing docs/adr/README.md (the index)
# Blocked:
#   - any Edit/Write/MultiEdit on docs/adr/NNNN-*.md when that file already exists
#
# Hook receives JSON on stdin with the tool input. Exit 2 + stderr blocks.

set -euo pipefail

input="$(cat)"
tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty')"
file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"

# Only run for file-mutating tools.
case "$tool_name" in
  Edit|Write|MultiEdit) ;;
  *) exit 0 ;;
esac

[[ -z "$file_path" ]] && exit 0

# Normalise to repo-relative path for matching.
rel="${file_path#"$CLAUDE_PROJECT_DIR/"}"

# Match docs/adr/NNNN-*.md but NOT template.md, README.md.
if [[ "$rel" =~ ^docs/adr/[0-9]{4}-.*\.md$ ]]; then
  if [[ -f "$file_path" ]]; then
    if [[ "$tool_name" == "Write" ]]; then
      # Write to an existing ADR file — always block.
      cat >&2 <<EOF
BLOCKED: ADRs are immutable (per ADR-0000).
File: $rel

To change a decision, write a NEW ADR with the next number that supersedes
this one. Add 'Supersedes: ADR-NNNN' to the new ADR's frontmatter and update
the old one's status only via that new ADR's existence (do not edit the old
file's status field directly — the README index expresses supersession).

If you genuinely need to fix a typo, do it via a separate, explicit commit
that the user has reviewed in advance.
EOF
      exit 2
    fi
    # Edit/MultiEdit on existing ADR — also block.
    cat >&2 <<EOF
BLOCKED: ADRs are immutable (per ADR-0000).
File: $rel

Write a new ADR that supersedes this one instead of editing it.
EOF
    exit 2
  fi
fi

exit 0
