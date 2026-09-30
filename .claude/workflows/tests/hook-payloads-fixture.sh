#!/usr/bin/env bash
# Behavioural cases for the two hooks hook-contract-fixture.sh covers only structurally or in part: the launch-root
# guard (require-repo-root-for-agents.sh, PreToolUse, HARD-DENY) and the forked-memory detector
# (detect-forked-agent-memory.sh, Stop). Every branch each documents in its `Blocked:` / `Allowed:` header is
# exercised with a crafted payload and an asserted exit — § Hook authoring › Verify by payload, made durable
# (context-builder-kit#58 items 1, 2 and 4). Neither hook sources a helper. Every could-not-look branch of the
# detector prints the literal WARNING the verification block's Stop-hook check reads; the cases assert it.
# Two fail-open branches are reachable only by mutation, not by payload (the guard's race between its git call and
# its `cd`; the detector's `cd` failure) — stated here rather than claimed as payload coverage.
# Every case runs against throwaway `git init` trees under mktemp, never the real repository, and never depends on
# the directory the fixture is launched from; the hooks run from their real path, so a change to either is caught.
# Needs bash, git and jq; `find`, `sed`, `sort` and `mktemp` for the detector. The partial-scan case needs a
# directory the walk cannot read, which root can read anyway: run as root it prints a SKIP line.
# Run by the verification block; also: bash .claude/workflows/tests/hook-payloads-fixture.sh
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
hooks="$here/../../hooks"
GUARD="$hooks/require-repo-root-for-agents.sh"
STOP="$hooks/detect-forked-agent-memory.sh"
[ -x "$GUARD" ] && [ -x "$STOP" ] || { echo "hook-payloads-fixture: a hook is missing or not executable"; exit 1; }
command -v jq >/dev/null && command -v git >/dev/null || { echo "hook-payloads-fixture: needs jq and git"; exit 1; }
d=$(mktemp -d)
cleanup() { chmod -R u+rwX "$d" 2>/dev/null || true; rm -rf "$d"; }
trap cleanup EXIT
# Git discovery stops at the throwaway root (the ceiling is its parent), so a TMPDIR inside a work tree cannot turn
# the outside-a-checkout cases into inside ones.
export GIT_CEILING_DIRECTORIES="${d%/*}"

# A throwaway checkout whose ignore rules name one build directory and one tool cache, so the ignore-driven prune has
# something to prune that is not hard-coded anywhere.
repo="$d/repo"; mkdir -p "$repo"
git -c init.defaultBranch=main init -q "$repo"
ignore() { printf '%b' "$1" > "$repo/.gitignore"; }
ignore '/pkg/*/build/\n/pkg/*/.cache/\n'
mkdir -p "$repo/pkg/a" "$repo/docs" "$repo/.claude/agent-memory/reviewer"
spaced="$d/a b"; mkdir -p "$spaced/docs"; git -c init.defaultBranch=main init -q "$spaced"

n=0; RC=0; ERR=""
guard() { RC=0; ERR="$(printf '%s' "$1" | "$GUARD" 2>&1 >/dev/null)" || RC=$?; n=$((n + 1)); }
guard_in() { RC=0; ERR="$(cd "$1" && printf '%s' "$2" | "$GUARD" 2>&1 >/dev/null)" || RC=$?; n=$((n + 1)); }
stop() { RC=0; ERR="$(printf '%s' "$2" | CLAUDE_PROJECT_DIR="$1" "$STOP" 2>&1 >/dev/null)" || RC=$?; n=$((n + 1)); }
want() { [ "$RC" -eq "$1" ] || { echo "FAIL: $2 (want exit $1, got $RC)"; [ -n "$ERR" ] && printf '  stderr: %s\n' "$ERR"; exit 1; }; }
says() { grep -q -- "$1" <<<"$ERR" || { echo "FAIL: $2 (stderr does not carry '$1')"; printf '  stderr: %s\n' "$ERR"; exit 1; }; }
payload() { jq -cn --arg t "$1" --arg cwd "$2" '{tool_name:$t, tool_input:{}, cwd:$cwd}'; }

# ── the launch-root guard ──
guard "$(payload Agent "$repo")";         want 0 "Agent from the checkout root is allowed"
guard "$(payload Agent "$repo/docs")";    want 2 "Agent from a subdirectory is denied"
guard "$(payload Task "$repo/docs")";     want 2 "Task (the older tool name) from a subdirectory is denied"
guard "$(payload Workflow "$repo/docs")"; want 2 "Workflow from a subdirectory is denied"
guard "$(payload Bash "$repo/docs")";     want 0 "a non-matching tool passes through"
guard "$(payload Agent "$repo/docs")";    says "BLOCKED" "the denial names itself"
says "$repo" "the denial names the root to return to"
guard "$(payload Agent "$spaced")";       want 0 "Agent from a root containing a space is allowed"
guard "$(payload Agent "$spaced/docs")";  want 2 "Agent from a subdirectory of a root containing a space is denied"
# Canonicalization: a symlinked or trailing-slash spelling of the root IS the root (a false HARD-DENY otherwise).
ln -s "$repo" "$d/rootlink"
guard "$(payload Agent "$d/rootlink")";      want 0 "a symlink to the root is not a false mismatch"
guard "$(payload Agent "$repo/")";           want 0 "a trailing slash on the root is not a false mismatch"
guard "$(payload Agent "$d/rootlink/docs")"; want 2 "a symlinked subdirectory is still denied"
# The cwd fallback resolves against the PROCESS's directory, asserted from a controlled directory both ways.
guard_in "$repo" '{"tool_name":"Agent","tool_input":{}}';      want 0 "no cwd field: falls back to \$PWD, allowed at the root"
guard_in "$repo/docs" '{"tool_name":"Agent","tool_input":{}}'; want 2 "no cwd field: falls back to \$PWD, denied in a subdirectory"
# Fail-open branches: each exits 0, warns, and names a surviving backstop.
guard "$(payload Agent "$d")"; want 0 "a cwd outside any checkout fails open"
says "WARNING" "the non-checkout warning is a WARNING"; says "not inside a git checkout" "the non-checkout warning says why"
says "Backstop:" "the non-checkout warning names a backstop"
bin="$d/bin"; mkdir -p "$bin"
for t in bash git cat printf sed dirname basename find grep sort head mktemp rm; do
  p=$(type -P "$t" || true); [ -n "$p" ] && ln -sf "$p" "$bin/$t"
done
RC=0; ERR="$(printf '%s' "$(payload Agent "$repo/docs")" | env -i PATH="$bin" HOME="$HOME" bash "$GUARD" 2>&1 >/dev/null)" || RC=$?; n=$((n + 1))
want 0 "the guard fails open when jq is absent"
says "jq not installed" "the jq warning says why"; says "Backstop:" "the jq warning names a backstop"
# Input it cannot read is refused: the guard cannot tell where the dispatch launches from.
guard "$(printf '{"tool_name":"Agent","tool_input":{"prompt":"x\\ud800y"},"cwd":"%s"}' "$repo")"; want 2 "a payload jq cannot parse is refused"
says "could not read the tool payload" "the refusal says why"
guard '["Agent"]';                        want 2 "a payload that is not an object is refused"

# ── the forked-memory detector ──
stop "$repo" '{"stop_hook_active":false}'; want 0 "a clean tree lets the stop proceed"
stop "$repo" '{}';                          want 0 "the root's own agent-memory tree is not a fork"
mkdir -p "$repo/pkg/a/.claude/agent-memory/reviewer"
stop "$repo" '{}';                          want 2 "a stray agent-memory under a package blocks the stop"
says "BLOCKED" "the block names itself"
says "pkg/a/.claude/agent-memory" "the block names the stray path"
stop "$repo" '{"stop_hook_active": true}';  want 0 "a second stop after one block proceeds"
says "still present after one fix attempt" "the second stop warns instead of blocking"
rm -rf "$repo/pkg/a/.claude"
mkdir -p "$repo/pkg/a/.claude/agent-memory-local/reviewer"
stop "$repo" '{}';                          want 2 "the local memory scope forks the same way"
says "agent-memory-local" "the block names the local-scope path"
rm -rf "$repo/pkg/a/.claude"
# A worktree is its own checkout with its own root tree, so its memory is not a fork.
mkdir -p "$repo/.claude/worktrees/wt/.claude/agent-memory/reviewer"
stop "$repo" '{}';                          want 0 "a worktree's own agent-memory tree is pruned"
rm -rf "$repo/.claude/worktrees"
# The prune list is the project's own ignore rules, read at run time: both ignored directories are pruned, an
# unignored one is not.
mkdir -p "$repo/pkg/a/build/agent-memory" "$repo/pkg/a/.cache/agent-memory"
stop "$repo" '{}';                          want 0 "trees under ignored directories are pruned"
mkdir -p "$repo/pkg/a/vendored/agent-memory"
stop "$repo" '{}';                          want 2 "a tree under an untracked but UNignored directory is still found"
says "vendored/agent-memory" "the block names the unignored stray path"
rm -rf "$repo/pkg/a/vendored" "$repo/pkg/a/build" "$repo/pkg/a/.cache"
# An ignore-driven prune list is attacker-shaped input; three rules keep it safe, each against a tree that would
# defeat a naive splice.
mkdir -p "$repo/pkg/a/.claude/agent-memory/reviewer"
( cd "$repo" && mkdir -p -- '*' )
ignore '\\*/\n'
stop "$repo" '{}';                          want 2 "an ignored directory named '*' prunes itself, not the whole walk"
rm -rf "${repo:?}/*"
ignore 'agent-memory/\n'
stop "$repo" '{}';                          want 2 "an ignore rule naming the memory tree never hides it"
ignore '.claude/\n'
stop "$repo" '{}';                          want 2 "an ignore rule naming .claude never hides a fork inside it"
ignore 'reviewer/\n'
stop "$repo" '{}';                          want 2 "a collapsed ancestor that no rule names is still walked"
ignore '/pkg/*/build/\n/pkg/*/.cache/\n'
rm -rf "$repo/pkg/a/.claude"
# The scan is rooted at the checkout's top level, so a project dir pointing at a subdirectory still finds a fork.
mkdir -p "$repo/pkg/a/.claude/agent-memory/reviewer"
stop "$repo/docs" '{}';                     want 2 "a subdirectory project dir still scans from the top level"
# No jq dependency: the detector backstops exactly the case where the jq-dependent guards have failed open.
RC=0; ERR="$(printf '{}' | env -i PATH="$bin" HOME="$HOME" CLAUDE_PROJECT_DIR="$repo" bash "$STOP" 2>&1 >/dev/null)" || RC=$?; n=$((n + 1))
want 2 "the detector blocks without jq on PATH"
rm -rf "$repo/pkg/a/.claude"
stop "$d" '{}';                             want 0 "a project dir outside any checkout fails open"
says "WARNING" "the non-checkout warning is a WARNING"; says "not inside a git checkout" "the non-checkout warning says why"
says "Backstop:" "the non-checkout warning names a backstop"
# A directory the walk cannot read makes the scan partial; reporting "clean" there is the silent miss the hook exists
# to stop, so it warns. Root ignores mode bits, so the case cannot be staged there.
if [ "$(id -u)" -ne 0 ]; then
  mkdir -p "$repo/pkg/a/sealed/inner"; chmod 000 "$repo/pkg/a/sealed"
  stop "$repo" '{}';                        want 0 "an unreadable directory does not fake a block"
  says "WARNING" "a partial scan is a WARNING"; says "the scan was partial" "a partial scan is reported, never silently clean"
  chmod 755 "$repo/pkg/a/sealed"; rm -rf "$repo/pkg/a/sealed"
else
  echo "SKIP: the detector's partial-scan case (an unreadable directory unavailable: running as root)"
fi
echo "hook-payloads-fixture: $n cases ok"
