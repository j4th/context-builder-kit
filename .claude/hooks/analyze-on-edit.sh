#!/usr/bin/env bash
# PostToolUse hook (Edit|Write|MultiEdit matcher) — EXEMPLAR: a project copies
# this hook, wires its analyzer into the case arms below, and registers it via
# the `_example_PostToolUse_analyzer` stanza in settings.json.
#
# Runs the project's analyzer on the PACKAGE of every edited source file and
# prints only its ERRORS, so a boundary violation surfaces at the edit rather
# than at the `check` task. A real run measured under a second per package for
# its analyzer (2026-09-05); size yours the same way before registering — an
# analyzer that takes ten seconds per edit is a gate, not an advisory, and
# belongs in the check task instead.
#
# The root is derived from the edited file, not from CLAUDE_PROJECT_DIR:
# inside a worktree the project dir stays where the session started while the
# file lives in the worktree. Hooks in one PostToolUse group run in parallel
# (https://code.claude.com/docs/en/hooks-guide § How hooks work), so this may
# read the file before format-on-edit.sh rewrites it; that affects line numbers
# in its output, nothing else.
#
# Blocked:  nothing — advisory-only contract, like format-on-edit.sh: exit 0
#           ALWAYS. Errors go to stderr as non-fatal notes; warnings and infos
#           stay the check task's business.
# Allowed:  everything.
# Path:     registered (once wired) as ${CLAUDE_PROJECT_DIR}/.claude/hooks/…
# Tier:     ADVISORY.

set -uo pipefail
# Deliberately NOT `set -e` — see the advisory contract above.

command -v jq &>/dev/null || { echo "analyze-on-edit: jq not installed; skipping (advisory)." >&2; exit 0; }

input="$(cat)"
tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty')"
file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty')"

case "$tool_name" in
  Edit|Write|MultiEdit) ;;
  *) exit 0 ;;
esac

[[ -n "$file_path" ]] || exit 0
[[ "$file_path" == /* ]] || file_path="${cwd:-${CLAUDE_PROJECT_DIR:-$PWD}}/$file_path"
[[ -f "$file_path" ]] || exit 0

# The checkout the file lives in; its root is where the analyzer runs.
root="$(git -C "$(dirname "$file_path")" rev-parse --show-toplevel 2>/dev/null)" || {
  echo "analyze-on-edit: $file_path is not inside a git checkout; skipping (advisory)." >&2
  exit 0
}
rel="${file_path#"$root/"}"
case "$rel" in
  .venv/*|node_modules/*|dist/*|build/*|target/*|_build/*|vendor/*) exit 0 ;;
esac
cd "$root" || exit 0

# Wire one arm per source type your project analyzes, INSIDE this case, above
# the catch-all. Each arm: find the package the file belongs to (the nearest
# manifest above it), run the analyzer on that package, print only the error
# lines. Uncomment and fill in the example arm to wire it.
case "$file_path" in
#  *.EXT)
#    command -v YOUR_ANALYZER &>/dev/null || { echo "analyze-on-edit: YOUR_ANALYZER not on PATH; skipping $rel (advisory)." >&2; exit 0; }
#    pkg_dir="$(dirname "$file_path")"
#    while [[ "$pkg_dir" != "/" && "$pkg_dir" != "$root" && ! -f "$pkg_dir/MANIFEST" ]]; do pkg_dir="$(dirname "$pkg_dir")"; done
#    [[ -f "$pkg_dir/MANIFEST" ]] || { echo "analyze-on-edit: no MANIFEST above $rel; skipping (advisory)." >&2; exit 0; }
#    out="$(YOUR_ANALYZER "${pkg_dir#"$root/"}" 2>&1)"
#    errors="$(printf '%s\n' "$out" | grep -E 'ERROR_LINE_PATTERN' || true)"
#    if [[ -n "$errors" ]]; then
#      echo "analyze-on-edit: YOUR_ANALYZER reports errors after editing $rel (non-fatal):" >&2
#      printf '%s\n' "$errors" >&2
#    fi
#    ;;
  *) : ;;  # no analyzer configured yet — no-op; add arms above this catch-all
esac

exit 0
