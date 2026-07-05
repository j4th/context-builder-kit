#!/usr/bin/env bash
# EXEMPLAR — a project copies this hook, wires its own formatters into the case
# arms below, and registers it as a PostToolUse hook (matcher Edit|Write|MultiEdit)
# in settings.json. The load-bearing part is the exit-0 advisory contract, not the
# formatter choice: this hook auto-formats a file after Claude Code edits it and
# NEVER blocks the tool call, whatever formatter you drop in.
#
# PostToolUse hook: auto-format edited files by extension. Catches drift at
# Claude-edit-time — a different layer from a pre-commit hook (which catches
# developer-commit-time).
#
# Advisory-only contract: exit 0 ALWAYS. Formatting failures surface on stderr
# as non-fatal notes; they never block the tool call.

set -uo pipefail
# Note: deliberately NOT using `set -e` — see the advisory contract above.

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"

command -v jq &>/dev/null || { echo "format-on-edit: jq not installed; skipping (advisory)." >&2; exit 0; }

input="$(cat)"
tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty')"
file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"

case "$tool_name" in
  Edit|Write|MultiEdit) ;;
  *) exit 0 ;;
esac

[[ -z "$file_path" || ! -f "$file_path" ]] && exit 0

rel="${file_path#"$PROJECT_DIR/"}"

# Skip vendored / generated trees the formatters shouldn't touch.
case "$rel" in
  .venv/*|node_modules/*|dist/*|build/*|vendor/*) exit 0 ;;
esac

# Wire one arm per file type your project formats. Each arm should run your
# formatter and CAPTURE stderr, surfacing it non-fatally so the operator sees the
# real diagnostic. Example shapes (uncomment and fill in your commands):
#
#   *.py)
#     cd "$PROJECT_DIR" || exit 0
#     if ! out="$(YOUR_PYTHON_FORMATTER "$file_path" 2>&1)"; then
#       echo "format-on-edit: python formatter failed on $rel (non-fatal):" >&2
#       printf '%s\n' "$out" >&2
#     fi
#     ;;
#   *.ts|*.tsx|*.js|*.jsx|*.json)
#     cd "$PROJECT_DIR" || exit 0
#     if ! out="$(YOUR_JS_FORMATTER "$file_path" 2>&1)"; then
#       echo "format-on-edit: js/ts formatter failed on $rel (non-fatal):" >&2
#       printf '%s\n' "$out" >&2
#     fi
#     ;;
case "$file_path" in
  *) : ;;  # no formatter configured yet — no-op; add arms above
esac

exit 0
