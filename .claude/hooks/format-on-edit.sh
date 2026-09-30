#!/usr/bin/env bash
# PostToolUse hook (Edit|Write|MultiEdit matcher) — EXEMPLAR: a project copies this hook,
# wires its own formatters into the case arms below, and registers it with the `Register:`
# stanza in this header (never as a top-level settings.json key). The load-bearing part is
# the exit-0 advisory contract, not the formatter choice: this hook auto-formats a file after
# Claude Code edits it and NEVER blocks the tool call, whatever formatter you drop in.
#
# Catches drift at Claude-edit-time — a different layer from a pre-commit hook (which catches
# developer-commit-time).
#
# An edit-time hook hands the formatter the edited file's path explicitly, and a formatter
# may format an explicit path whatever its own exclude list says — for ruff, "Files that are
# passed to `ruff` directly are always analyzed", unless force-exclude is on
# (https://github.com/astral-sh/ruff/blob/main/docs/configuration.md § Python file
# discovery, read 2026-09-30). So each arm passes its formatter's forcing flag, and the floor
# below keeps the trees no formatter may touch out, whatever any config says.
#
# Blocked:  nothing — advisory-only contract: exit 0 ALWAYS. A formatter failure surfaces on
#           stderr as a non-fatal note; it never blocks the tool call.
# Allowed:  everything.
# Path:     registered (once wired) as ${CLAUDE_PROJECT_DIR}/.claude/hooks/format-on-edit.sh.
# Tier:     ADVISORY (see the registry comment in .claude/settings.json).
# Depends:  jq (the payload fields) and the project's formatters once the arms are wired —
#           absent, the hook skips: exit 0 with a stderr note; the check task is the backstop.
# Register: copy this object into hooks.PostToolUse in .claude/settings.json once the case
#           arms are wired — never as a top-level key (cbk-conventions-reference.md § Hook
#           authoring: a hook-shaped object outside `hooks` voids the whole settings file):
#           { "matcher": "Edit|Write|MultiEdit",
#             "hooks": [ { "type": "command",
#                          "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/format-on-edit.sh",
#                          "args": [] } ] }
#           Wiring is three edits, not one: the stanza, this hook's name in the project
#           sub-block's ADVISORY_WIRED, and its name in cbk-conventions.md § Mutation
#           discipline's two-views paragraph. The verification block reads all three, so a
#           registration alone turns it red.

set -uo pipefail

# Drain stdin before any early exit, or a piping caller's SIGPIPE masks this hook's own
# exit code (cbk-conventions-reference.md § Hook authoring › The stdin / exit contract).
input="$(cat)"
# Note: deliberately NOT using `set -e` — see the advisory contract above.

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"

command -v jq &>/dev/null || { echo "format-on-edit: jq not installed; skipping (advisory)." >&2; exit 0; }

tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty')"
file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"

case "$tool_name" in
  Edit|Write|MultiEdit) ;;
  *) exit 0 ;;
esac

[[ -z "$file_path" || ! -f "$file_path" ]] && exit 0

rel="${file_path#"$PROJECT_DIR/"}"

# The floor: trees no formatter may touch, whatever a config says. Which files a formatter
# formats is that formatter's own config, held for an explicit path by its forcing flag;
# this list sits under it and is not the exclude list. `.claude/workflows/` is the kit's
# code, kept byte-identical to its source (cbk-conventions-reference.md § Syncing the kit),
# in this checkout and in a worktree's copy of it (a path outside PROJECT_DIR keeps its
# absolute form, hence the second pattern).
case "$rel" in
  .venv/*|node_modules/*|dist/*|build/*|vendor/*|.claude/workflows/*|*/.claude/workflows/*) exit 0 ;;
esac

# Wire one arm per file type your project formats. Each arm runs the formatter with the flag
# that makes the project's own excludes hold for a path handed over explicitly, and CAPTURES
# stderr, surfacing it non-fatally so the operator sees the real diagnostic. Measured
# 2026-09-30 on an explicitly passed path the formatter's own config excludes (re-measure
# after upgrading a formatter):
#   ruff 0.16.9     formats it unless --force-exclude (or force-exclude = true); with it,
#                   exit 0 and the file untouched.
#   prettier 3.9.9  honours .prettierignore for it: exit 0, the file untouched.
#   biome 2.5.14    honours a files.includes negation for it, but exits 1 ("These paths
#                   were provided but ignored") unless --no-errors-on-unmatched.
# Any other formatter: check how it treats an explicitly passed excluded path before wiring
# its arm. Example shapes (uncomment and fill in your commands):
#
#   *.py)
#     cd "$PROJECT_DIR" || exit 0
#     # ruff: ruff format --force-exclude
#     if ! out="$(YOUR_PYTHON_FORMATTER YOUR_FORCE_EXCLUDE_FLAG "$file_path" 2>&1)"; then
#       echo "format-on-edit: python formatter failed on $rel (non-fatal):" >&2
#       printf '%s\n' "$out" >&2
#     fi
#     ;;
#   *.ts|*.tsx|*.js|*.jsx|*.json)
#     cd "$PROJECT_DIR" || exit 0
#     # prettier: prettier --write (no flag needed) · biome: biome format --write --no-errors-on-unmatched
#     if ! out="$(YOUR_JS_FORMATTER YOUR_FORCE_EXCLUDE_FLAG "$file_path" 2>&1)"; then
#       echo "format-on-edit: js/ts formatter failed on $rel (non-fatal):" >&2
#       printf '%s\n' "$out" >&2
#     fi
#     ;;
case "$file_path" in
  *) : ;;  # no formatter configured yet — no-op; add arms above
esac

exit 0
