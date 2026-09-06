#!/usr/bin/env bash
# Stop hook: refuse to finish while a reviewer's `memory: project` tree sits
# anywhere but the repository root.
#
# require-repo-root-for-agents.sh refuses the dispatch that causes a fork: a
# subagent starts in the main conversation's current working directory, and
# `memory: project` is the relative path `.claude/agent-memory/<name>/`
# (https://code.claude.com/docs/en/sub-agents, verified 2026-09-06). This hook
# catches the OUTCOME, whatever produced it — a second `.claude/agent-memory/`
# under a package, the shape a real run committed and repaired by hand. On the
# flip's auto-review it was found by a reviewer walking every changed file;
# here it is found before the hand-off, by the agent that made it.
#
# Blocked:  the main conversation's stop, once, while a stray agent-memory
#           directory exists (exit 2 + the remediation on stderr).
# Allowed:  a clean tree; a second stop after one block (`stop_hook_active`);
#           any environment defect (fail-open with a warning).
# Event:    Stop only. Not SubagentStop — a finishing subagent has no hand-off
#           to repair the tree in, and `stop_hook_active` is documented for
#           Stop; registering there would block every subagent of a review
#           pass while a stray tree exists (demonstrated 2026-09-06).
# Loop:     exit 2 on a Stop hook blocks the stop and feeds stderr to the
#           agent (https://code.claude.com/docs/en/hooks — exit-code table).
#           `stop_hook_active` is true when the agent is already continuing
#           from this hook: warn and let it stop. The harness overrides a Stop
#           hook after eight consecutive blocks without progress
#           (https://code.claude.com/docs/en/hooks-guide § Limitations and
#           troubleshooting › "Stop hook hits the block cap"; verified
#           2026-09-06, re-verify after upgrades), so this hook blocks at most
#           once per stop. A payload without the field is treated as the first
#           block (the assumption is stated, not silently defaulted).
# Path:     registered as ${CLAUDE_PROJECT_DIR}/.claude/hooks/… (handlers run
#           in the current directory — https://code.claude.com/docs/en/hooks).
# Tier:     STOP.
# Fail-open on environment defects (missing jq) with a stderr warning. No
# bash-4-only builtins (a stock macOS bash is 3.2): the directory list is read
# with a while loop, not mapfile.

set -uo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"

if ! command -v jq &>/dev/null; then
  echo "detect-forked-agent-memory: WARNING — jq not installed; fork detection DISABLED (advisory)." >&2
  echo "                            Backstop: the verification block's fork grep (cbk-conventions-reference.md § Verification)." >&2
  exit 0
fi

input="$(cat)"
# Absent field ⇒ first block. Present and true ⇒ the agent is already continuing from this hook.
active="$(printf '%s' "$input" | jq -r '.stop_hook_active // empty')"

cd "$PROJECT_DIR" || exit 0

# Every directory named agent-memory that is not the root's own. -prune stops
# descent into the root's own tree, worktrees (each is its own checkout with its
# own root tree), .git, and build output — add your stack's build directories to
# the list. No -mindepth: it would exempt depth-1 directories from the prune test,
# so a top-level node_modules would be walked and flagged.
forks=()
while IFS= read -r d; do forks+=("$d"); done < <(
  find . \( -path './.claude/agent-memory' -o -path './.claude/worktrees' -o -name .git \
         -o -name node_modules -o -name target -o -name build -o -name _build \
         -o -name dist -o -name .venv \) -prune -o -type d -name agent-memory -print 2>/dev/null | sort
)

[ "${#forks[@]}" -eq 0 ] && exit 0

if [ "$active" = "true" ]; then
  echo "detect-forked-agent-memory: WARNING — forked reviewer memory still present after one fix attempt; letting the stop proceed:" >&2
  printf '  %s\n' "${forks[@]}" >&2
  exit 0
fi

cat >&2 <<MSG
BLOCKED: a reviewer memory tree exists outside the repository root:
$(printf '  %s\n' "${forks[@]}")

Project-local reviewers declare \`memory: project\`; the only legitimate home
is $PROJECT_DIR/.claude/agent-memory/<reviewer>/ (pr-review.md § Reviewer
precedent memory). Before stopping: move each <reviewer>/ directory's files
into the root tree, append their pointer lines to the root MEMORY.md for that
reviewer, delete the forked tree, and say so in the hand-off.
MSG
exit 2
