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
# Blocked:  the main conversation's stop, once, while a stray agent-memory or
#           agent-memory-local directory exists — both memory scopes fork the same
#           way (exit 2 + the remediation on stderr).
# Allowed:  a clean tree; a second stop after one block (`stop_hook_active`);
#           a working directory that is not a git checkout (fail-open with a warning).
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
# No jq dependency: the scan needs none, and the one field this hook reads
# (`stop_hook_active`) is matched with grep — so this backstop works exactly when
# the jq-dependent guards have failed open. No bash-4-only builtins (a stock
# macOS bash is 3.2): the directory list is read with a while loop, not mapfile.

set -uo pipefail

# The scan runs from the checkout's git top-level. CLAUDE_PROJECT_DIR is exported to the hook
# process (https://code.claude.com/docs/en/hooks — the same page documents the placeholder);
# when it is absent the process's own $PWD may be a subdirectory — the drift case — and a scan
# rooted there would treat <subdir>/.claude/agent-memory as the canonical tree and miss the fork.
PROJECT_DIR="$(git -C "${CLAUDE_PROJECT_DIR:-$PWD}" rev-parse --show-toplevel 2>/dev/null)" || {
  echo "detect-forked-agent-memory: WARNING — ${CLAUDE_PROJECT_DIR:-$PWD} is not inside a git checkout; fork detection inactive for this stop." >&2
  echo "                            Backstop: the verification block's Stop-hook check (cbk-conventions-reference.md § Verification)." >&2
  exit 0
}

input="$(cat)"
# Absent field ⇒ first block. Present and true ⇒ the agent is already continuing from this hook.
# Matched with grep, not jq, so fork detection has no environment dependency to fail open on.
active=""
printf '%s' "$input" | grep -Eq '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && active="true"

cd "$PROJECT_DIR" || exit 0

# Every directory named agent-memory or agent-memory-local that is not the root's
# own (the `project` and `local` scopes fork identically). -prune stops
# descent into the root's own tree, worktrees (each is its own checkout with its
# own root tree), .git, and build output — add your stack's build directories to
# the list. No -mindepth: as first written, -mindepth 2 exempted depth-1 directories
# from the prune test, so a top-level node_modules was walked and its contents flagged
# (reproduced 2026-09-06; -mindepth 1 would not have, but the option buys nothing here).
forks=()
while IFS= read -r d; do forks+=("$d"); done < <(
  find . \( -path './.claude/agent-memory' -o -path './.claude/agent-memory-local' -o -path './.claude/worktrees' -o -name .git \
         -o -name node_modules -o -name target -o -name build -o -name _build \
         -o -name dist -o -name .venv \) -prune -o -type d \( -name agent-memory -o -name agent-memory-local \) -print 2>/dev/null | sort
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

Project-local reviewers declare \`memory: project\` or \`memory: local\`; the only
legitimate homes are $PROJECT_DIR/.claude/agent-memory/<reviewer>/ and
$PROJECT_DIR/.claude/agent-memory-local/<reviewer>/ (pr-review.md § Reviewer
precedent memory). Before stopping: move each <reviewer>/ directory's files
into the root tree, append their pointer lines to the root MEMORY.md for that
reviewer, delete the forked tree, and say so in the hand-off.
MSG
exit 2
