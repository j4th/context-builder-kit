#!/usr/bin/env bash
# PreToolUse hook: block Claude Code edits to lock files.
#
# Lock files (uv.lock, pnpm-lock.yaml, package-lock.json, Cargo.lock, etc.)
# should only change via the corresponding package-manager command (uv sync,
# pnpm install, cargo update, ...) — never via manual editing. Direct edits
# silently de-sync the lockfile from the manifest and break reproducible builds.
#
# Allowed:
#   - Bash invocations of the package manager (the proper way to change locks)
#   - Reads of lock files (no Edit/Write involved)
# Blocked:
#   - Edit/Write/MultiEdit on lock files
#
# Hook receives JSON on stdin with the tool input. Exit 2 + stderr blocks.
#
# Fail-open on environment defects (missing jq, unset CLAUDE_PROJECT_DIR):
# exit 0 with a loud stderr warning. The alternative (failing closed) converts
# a targeted lock-file block into a universal Edit/Write/MultiEdit block, which
# is worse than allowing a lock-file edit to slip through. The operator notices
# the warning and fixes their environment.

set -uo pipefail
# Note: deliberately NOT using `set -e` — we want to exit 0 (fail-open) on
# environment defects rather than abort with cryptic stderr that blocks all
# tool calls.

# Defensive: hook may run without CLAUDE_PROJECT_DIR set; default to PWD.
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"

# jq is required for stdin parsing. Missing jq → fail-open with warning,
# NOT fail-closed (would block all Edit/Write/MultiEdit silently).
if ! command -v jq &>/dev/null; then
  echo "protect-lock-files: WARNING — jq not installed; lock-file protection DISABLED." >&2
  echo "                    Install jq to re-enable. Lock-file edits will NOT be caught until fixed." >&2
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

# Normalise to repo-relative for matching.
rel="${file_path#"$PROJECT_DIR/"}"

# Match the common lock file shapes anywhere in the repo.
case "$(basename "$rel")" in
  uv.lock|pnpm-lock.yaml|package-lock.json|yarn.lock|Cargo.lock|Gemfile.lock|poetry.lock|composer.lock|mix.lock)
    cat >&2 <<EOF
BLOCKED: Lock files are package-manager-managed.
File: $rel

To change a lock file, invoke the corresponding package manager:
  - uv.lock              →  uv lock  /  uv sync
  - pnpm-lock.yaml       →  pnpm install
  - package-lock.json    →  npm install
  - yarn.lock            →  yarn install
  - Cargo.lock           →  cargo update
  - etc.

Manual edits silently de-sync the lock file from the manifest and break
reproducible builds. If you genuinely need to bypass this hook (rare), do
it via a separate, explicit commit that the user has reviewed in advance.
EOF
    exit 2
    ;;
esac

exit 0
