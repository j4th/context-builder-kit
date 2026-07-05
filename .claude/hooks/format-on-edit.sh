#!/usr/bin/env bash
# EXEMPLAR — a project copies this hook, wires its own formatters into the case
# arms, and registers it as a PostToolUse hook (matcher Edit|Write|MultiEdit) in
# settings.json. The load-bearing part is the exit-0 advisory contract, not the
# formatter choice: this hook auto-formats a file after Claude Code edits it and
# NEVER blocks the tool call, whatever formatter you drop in.
#
# PostToolUse hook: auto-format edited files by extension.
#
# Catches drift before commit — a different layer from any pre-commit hook
# (which catches developer-commit-time; this catches Claude-edit-time).
#
# Fast-path: only runs on file types you format. No-op for everything else.
# Failures are surfaced as advisory (exit 0 with stderr) — formatting drift
# shouldn't block Claude's tool call, but the operator gets a heads-up.
#
# Hook receives JSON on stdin with the tool input. Exit 0 always (advisory).

set -uo pipefail
# Note: deliberately NOT using `set -e` — this hook's advisory-only contract
# requires exit 0 even when individual operations fail. Check exit codes
# explicitly where it matters.

# Defensive: hook may run without CLAUDE_PROJECT_DIR set in some harness
# contexts; default to PWD so the unbound-variable abort doesn't break the
# "exit 0 always" contract.
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"

# jq is required for stdin parsing. Missing jq → advisory exit, not abort.
if ! command -v jq &>/dev/null; then
  echo "format-on-edit: jq not installed; skipping format pass." >&2
  exit 0
fi

input="$(cat)"
tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty')"
file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"

# Only run for file-mutating tools.
case "$tool_name" in
  Edit|Write|MultiEdit) ;;
  *) exit 0 ;;
esac

[[ -z "$file_path" ]] && exit 0
[[ ! -f "$file_path" ]] && exit 0

# Normalise to repo-relative for matching.
rel="${file_path#"$PROJECT_DIR/"}"

# Skip files in directories the formatters shouldn't touch.
# Add any project-specific vendored/generated dirs here.
case "$rel" in
  .venv/*|node_modules/*) exit 0 ;;
esac

# Pick formatter by extension. Replace each arm with your project's formatter
# for that file type, gated on whatever tells you it's safe to run (the
# formatter binary being installed, a config file existing, deps present, …).
# Capture stderr and surface it non-fatally so the operator sees the real
# diagnostic (syntax error, etc.) — not just "format failed."
case "$file_path" in
  *.<ext>)
    # if <formatter is available for this file type>; then
    #   cd "$PROJECT_DIR" || exit 0
    #   if ! out="$(<your project formatter for this type> "$file_path" 2>&1)"; then
    #     echo "format-on-edit: <formatter> failed on $rel (non-fatal):" >&2
    #     printf '%s\n' "$out" >&2
    #   fi
    # fi
    ;;
  *.<other-ext>)
    # <your project formatter for this type> ;;
    ;;
esac

exit 0
