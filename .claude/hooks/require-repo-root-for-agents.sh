#!/usr/bin/env bash
# PreToolUse hook (Task|Agent|Workflow matcher): refuse to dispatch agents from
# anywhere but the repository root.
#
# The project-local reviewers declare `memory: project`, which the platform
# stores at the RELATIVE path `.claude/agent-memory/<name>/`, and a subagent
# "starts in the main conversation's current working directory"
# (https://code.claude.com/docs/en/sub-agents — verified 2026-09-06; re-verify
# after harness upgrades) — a directory that follows the session's own `cd`.
# So a sweep dispatched while the shell sat in a package directory wrote every
# reviewer's memory under that package: a real github-issues run committed the
# fork once (2026-09-05) and had to move it by hand twice. This guard refuses
# the dispatch at the cause. Hooks enforce non-negotiables more reliably than
# the "launch from the root" instruction that preceded them.
#
# Blocked:  Task, Agent and Workflow tool calls whose working directory is not
#           the git top-level of the checkout it sits in.
# Allowed:  everything else — including a launch from a worktree's own root,
#           which is that checkout's top-level.
# Matcher:  `Task|Agent|Workflow` — `Agent` and `Workflow` are the names the
#           harness reported in `tool_name` on a real run (dated observation,
#           2026-09-05; the hooks pages give examples, not an enumerated list —
#           re-verify after upgrades); `Task` is the older name, kept so a
#           rename degrades to a no-op rather than silence.
# Timing:   the guard reads the payload's `cwd` (a common field on every hook
#           event — https://code.claude.com/docs/en/hooks-guide § How hooks
#           work) BEFORE the tool runs. That field is the SESSION's working
#           directory — where Claude Code was launched — not the Bash tool's
#           persisted shell directory: a real dispatch made after `cd docs` in
#           the shell was allowed, with the payload cwd still at the root (dated
#           observation, 2026-09-07). The confirmed deny is a session launched
#           from a subdirectory (the verification block's payload dry-run); the
#           remedy there is to relaunch the session from the root.
# Path:     registered as ${CLAUDE_PROJECT_DIR}/.claude/hooks/… — handlers run
#           in the current directory (https://code.claude.com/docs/en/hooks), so
#           a bare relative path would not resolve from the very subdirectory
#           this guard exists to block.
# Tier:     HARD-DENY.
#
# Hook receives JSON on stdin. Exit 2 + stderr blocks. Fail-open on
# environment defects (missing jq, not a git checkout): exit 0 with a loud
# stderr warning naming the surviving backstop, mirroring protect-main-branch.sh.

set -uo pipefail
# Deliberately NOT `set -e` — fail-open on environment defects rather than
# aborting with cryptic stderr that blocks every dispatch.

if ! command -v jq &>/dev/null; then
  echo "require-repo-root-for-agents: WARNING — jq not installed; the launch-directory guard is DISABLED." >&2
  echo "                              Backstop: detect-forked-agent-memory.sh (Stop tier) needs no jq and still" >&2
  echo "                              catches a stray agent-memory tree before the hand-off; git status shows it untracked." >&2
  exit 0
fi

input="$(cat)"
tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty')"
case "$tool_name" in
  Task|Agent|Workflow) ;;
  *) exit 0 ;;
esac

# The hook payload carries the call's working directory (`cwd`), the same
# field protect-main-branch.sh reads for Bash calls. Fall back to this
# process's own directory when it is absent.
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty')"
cwd="${cwd:-$PWD}"

root="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)" || {
  echo "require-repo-root-for-agents: WARNING — $cwd is not inside a git checkout; guard inactive for this call." >&2
  echo "                              Backstop: detect-forked-agent-memory.sh (Stop tier) catches a stray tree before the hand-off." >&2
  exit 0
}

# Canonical paths, so a symlinked or trailing-slash form is not a false mismatch.
cwd_real="$(cd "$cwd" 2>/dev/null && pwd -P)"
root_real="$(cd "$root" 2>/dev/null && pwd -P)"

if [[ "$cwd_real" != "$root_real" ]]; then
  cat >&2 <<MSG
BLOCKED: $tool_name launched from
  $cwd
which is not the repository root
  $root

Project-local reviewers declare \`memory: project\`; dispatched from a
subdirectory their memory forks under that directory's .claude/agent-memory/
(pr-review.md § Reviewer precedent memory). Return to the root as its own
command, then relaunch:
  cd "$root"

If this block is wrong for a deliberate reason (rare), run the dispatch from
a session whose working directory is the root.
MSG
  exit 2
fi

exit 0
