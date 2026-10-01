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
#           the git top-level of the checkout it sits in; and a payload jq cannot
#           read, whose working directory cannot be checked.
# Allowed:  everything else — including a launch from a worktree's own root,
#           which is that checkout's top-level.
# Matcher:  `Task|Agent|Workflow` — `Agent` and `Workflow` are the names the
#           harness reported in `tool_name` on a real run (dated observation,
#           2026-09-05; the hooks pages give examples, not an enumerated list —
#           re-verify after upgrades); `Task` is the older name, kept so a
#           rename degrades to a no-op rather than silence.
# Timing:   the guard reads the payload's `cwd` (a common field on every hook
#           event — https://code.claude.com/docs/en/hooks-guide § How hooks
#           work) BEFORE the tool runs. That field follows the Bash tool's `cd`
#           — "the new directory after Claude runs `cd`"
#           (https://code.claude.com/docs/en/hooks § Reference scripts by path,
#           read 2026-09-30) — and a logging-hook probe on Claude Code 2.1.286
#           showed it (2026-09-30): a Bash call and an Agent dispatch made after
#           `cd docs` both carried <root>/docs. So a dispatch made after a `cd`
#           into a subdirectory is denied, and the remedy is to `cd` back to the
#           root as its own command. The 2026-09-07 observation that the field
#           stayed at the session's launch directory is retired
#           (context-builder-kit#58, S3). RE-VERIFY TRIGGER: a dispatch made after
#           `cd <subdir>` that is allowed means the field stopped following `cd` —
#           re-run the probe and update this paragraph.
# Path:     registered as ${CLAUDE_PROJECT_DIR}/.claude/hooks/… — handlers run
#           in the current directory (https://code.claude.com/docs/en/hooks), so
#           a bare relative path would not resolve from the very subdirectory
#           this guard exists to block.
# Tier:     HARD-DENY.
# Depends:  jq (the payload's tool_name and cwd) and git (the top-level of that
#           cwd) — absent, the guard fails open: exit 0 with a stderr warning
#           naming the backstop, detect-forked-agent-memory.sh (Stop tier,
#           needs no jq). A payload jq cannot read is not an environment defect:
#           it is refused (cbk-conventions-reference.md § Hook authoring).
#           Fixture: .claude/workflows/tests/hook-payloads-fixture.sh.
#
# Hook receives JSON on stdin. Exit 2 + stderr blocks. Fail-open on
# environment defects (missing jq, not a git checkout): exit 0 with a loud
# stderr warning naming the surviving backstop, mirroring protect-main-branch.sh.

set -uo pipefail

# Drain stdin before any early exit, or a piping caller's SIGPIPE masks this hook's own
# exit code (cbk-conventions-reference.md § Hook authoring › The stdin / exit contract).
input="$(cat)"
# Deliberately NOT `set -e` — fail-open on environment defects rather than
# aborting with cryptic stderr that blocks every dispatch.

if ! command -v jq &>/dev/null; then
  echo "require-repo-root-for-agents: WARNING — jq not installed; the launch-directory guard is DISABLED." >&2
  echo "                              Backstop: detect-forked-agent-memory.sh (Stop tier) needs no jq and still" >&2
  echo "                              catches a stray agent-memory tree before the hand-off; git status shows it untracked." >&2
  exit 0
fi

# A payload jq cannot read is refused: this hook runs on Task|Agent|Workflow only, so the call is
# still a dispatch, and where it launches from cannot be checked.
if ! fields=$(jq -er 'def s: if . == null then "" elif type == "string" then . else error("a field is not a string") end; if type == "object" then @sh "tool_name=\(.tool_name | s) cwd=\(.cwd | s)" else error("not an object") end' <<<"$input" 2>/dev/null); then
  echo "BLOCKED: require-repo-root-for-agents could not read the tool payload (not parseable JSON, not an object, or a field that is not a string)," >&2
  echo "so it cannot tell where this dispatch launches from. A lone UTF-16 surrogate escape in the tool input does this — remove it and retry." >&2
  exit 2
fi

eval "$fields"
case "$tool_name" in
  Task|Agent|Workflow) ;;
  *) exit 0 ;;
esac

# The hook payload carries the call's working directory (`cwd`), the same
# field protect-main-branch.sh reads for Bash calls. Fall back to this
# process's own directory when it is absent.
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
