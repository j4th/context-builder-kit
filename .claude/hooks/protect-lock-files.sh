#!/usr/bin/env bash
# PreToolUse hook: block Claude Code edits to lock files.
#
# Lock files (uv.lock, pnpm-lock.yaml, package-lock.json, Cargo.lock, etc.)
# should only change via the corresponding package-manager command (uv sync,
# pnpm install, cargo update, ...) — never via manual editing. Direct edits
# silently de-sync the lockfile from the manifest and break reproducible builds.
#
# Allowed:  Bash invocations of the package manager (the proper way to change locks); reads of lock
#           files (no Edit/Write involved); a file with a case arm of its own above the `*.lock)` arm.
# Blocked:  Edit/Write/MultiEdit on a lock file — a named ecosystem's, or any other `*.lock` by the
#           fallback arm; and a payload jq cannot read, whose path cannot be checked.
# Not seen: an edit through a symlink under another name (the guard decides on the path text, so a
#           link named deps.txt that points at uv.lock passes), and a write through the Bash tool
#           (unmatched on purpose: the package manager is the route). The project's CI lockfile
#           check, where one exists, refuses a drifted lock at PR time.
# Tier:     HARD-DENY (see the registry comment in .claude/settings.json).
# Depends:  jq (the payload) — absent, the guard fails open: exit 0 with a stderr warning naming the
#           project's CI lockfile check as the backstop (a bracketed slot the project fills).
#
# Hook receives JSON on stdin with the tool input. Exit 2 + stderr blocks. Fail-open on environment
# defects (missing jq, unset CLAUDE_PROJECT_DIR): exit 0 with a loud stderr warning — failing closed
# would turn a targeted lock-file block into a universal Edit/Write/MultiEdit block. Input the guard
# cannot read is not an environment defect, and is refused (cbk-conventions-reference.md § Hook
# authoring). Fixture: .claude/workflows/tests/hook-guards-fixture.sh.

set -uo pipefail

# Drain stdin before any early exit, or a piping caller's SIGPIPE masks this hook's own
# exit code (cbk-conventions-reference.md § Hook authoring › The stdin / exit contract).
input="$(cat)"
# Note: deliberately NOT using `set -e` — we want to exit 0 (fail-open) on
# environment defects rather than abort with cryptic stderr that blocks all
# tool calls.

# Defensive: hook may run without CLAUDE_PROJECT_DIR set; default to PWD.
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"

# jq is required for stdin parsing. Missing jq → fail-open with warning,
# NOT fail-closed (would block all Edit/Write/MultiEdit silently).
if ! command -v jq &>/dev/null; then
  echo "protect-lock-files: WARNING — jq not installed; lock-file protection DISABLED." >&2
  echo "                    Install jq to re-enable. Backstop until then: [the project's CI lockfile check — a" >&2
  echo "                    locked or frozen-lockfile install that fails when the lock file and its manifest disagree]." >&2
  exit 0
fi

# A payload jq cannot read is refused, never waved through: this hook runs on Edit|Write|MultiEdit only,
# so the call is still a file write, and its path cannot be checked (a lone UTF-16 surrogate escape
# anywhere in the tool input does this).
if ! jq -e 'type == "object"' >/dev/null 2>&1 <<<"$input"; then
  echo "BLOCKED: protect-lock-files could not read the tool payload (not parseable JSON, or not an object)," >&2
  echo "so its path cannot be checked. A lone UTF-16 surrogate escape in the tool input does this — remove it and retry." >&2
  exit 2
fi

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
  uv.lock|pnpm-lock.yaml|package-lock.json|yarn.lock|Cargo.lock|Gemfile.lock|poetry.lock|composer.lock|mix.lock|pubspec.lock)
    cat >&2 <<EOF
BLOCKED: Lock files are package-manager-managed.
File: $rel

To change a lock file, invoke the corresponding package manager:
  - uv.lock              →  uv lock  /  uv sync
  - pnpm-lock.yaml       →  pnpm install
  - package-lock.json    →  npm install
  - yarn.lock            →  yarn install
  - Cargo.lock           →  cargo update
  - pubspec.lock         →  dart pub get  /  flutter pub get  (pub upgrade to move a resolution)
  - etc.

Manual edits silently de-sync the lock file from the manifest and break
reproducible builds. If you genuinely need to bypass this hook (rare), do
it via a separate, explicit commit that the user has reviewed in advance.
EOF
    exit 2
    ;;
  *.lock)
    cat >&2 <<EOF
BLOCKED: $rel looks like a package-manager lock file (the *.lock fallback arm — the
named ecosystems are listed above this arm in the hook; the next ecosystem is covered
by construction rather than by an edit, context-builder-kit#58 item 3).
Run the package manager that owns it instead of editing it by hand. If this file is
NOT a lock file, give it a case arm of its own above the \`*.lock)\` arm in this hook
(an arm that exits 0), and say so in the PR.
EOF
    exit 2
    ;;
esac

exit 0
