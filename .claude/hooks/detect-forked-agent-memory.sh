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
#           a working directory that is not a git checkout (fail-open with a warning);
#           a tree under a directory the project's own ignore rules exclude, or under
#           `./.claude-pr` — see Residual below.
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
# Residual: the walk prunes every directory the project's ignore rules exclude, so
#           a tree placed by hand or by tooling UNDER an ignored directory (a build
#           output, a tool cache) exits 0 — the dispatch that would create one is
#           refused by require-repo-root-for-agents.sh, which is the guard for that
#           case (#58 item 1's scenario table, reproduced independently 2026-09-13).
#           `./.claude-pr` is pruned unconditionally: it is the staging copy a
#           hosted review action makes of the branch's `.claude/` tree, committed
#           memory included — a copy, not a fork (#58, 2026-09-07 comment).
# Path:     registered as ${CLAUDE_PROJECT_DIR}/.claude/hooks/… (handlers run
#           in the current directory — https://code.claude.com/docs/en/hooks).
# Tier:     STOP.
# Depends:  NO jq — the one field this hook reads (`stop_hook_active`) is matched
#           with grep, so this backstop works exactly when the jq-dependent guards
#           have failed open. `git` is required for the root and used for the prune
#           list: without it the guard above fails open, and a failing `git
#           ls-files`/`check-ignore` leaves the prune list empty, so the scan runs
#           unpruned — slower, never blinder. `mktemp` is optional: it holds the
#           scan's stderr, and when no scratch file can be created the walk still
#           runs and says so rather than reporting a clean tree it could not have
#           verified. No bash-4-only builtins (a stock macOS bash is 3.2): the
#           directory list is read with a while loop, not mapfile.

set -uo pipefail

# Drain stdin before any early exit, or a piping caller's SIGPIPE masks this hook's own
# exit code (cbk-conventions-reference.md § Hook authoring › The stdin / exit contract).
input="$(cat)"

# The scan runs from the checkout's git top-level. CLAUDE_PROJECT_DIR is exported to the hook
# process (https://code.claude.com/docs/en/hooks — the same page documents the placeholder);
# when it is absent the process's own $PWD may be a subdirectory — the drift case — and a scan
# rooted there would treat <subdir>/.claude/agent-memory as the canonical tree and miss the fork.
PROJECT_DIR="$(git -C "${CLAUDE_PROJECT_DIR:-$PWD}" rev-parse --show-toplevel 2>/dev/null)" || {
  echo "detect-forked-agent-memory: WARNING — ${CLAUDE_PROJECT_DIR:-$PWD} is not inside a git checkout; fork detection inactive for this stop." >&2
  echo "                            Backstop: the verification block's Stop-hook check (cbk-conventions-reference.md § Verification)." >&2
  exit 0
}

# Absent field ⇒ first block. Present and true ⇒ the agent is already continuing from this hook.
# Matched with grep, not jq, so fork detection has no environment dependency to fail open on.
# A here-string, never `printf … | grep`: a reader that exits on its first match makes
# pipefail read a real match as NO MATCH (cbk-conventions-reference.md § Hook authoring).
active=""
grep -Eq '"stop_hook_active"[[:space:]]*:[[:space:]]*true' <<<"$input" && active="true"

cd "$PROJECT_DIR" || {
  echo "detect-forked-agent-memory: WARNING — cannot enter $PROJECT_DIR; fork detection inactive for this stop." >&2
  echo "                            Backstop: the verification block's Stop-hook check (cbk-conventions-reference.md § Verification)." >&2
  exit 0
}

# Every directory named agent-memory or agent-memory-local that is not the root's
# own (the `project` and `local` scopes fork identically). The walk prunes the root's
# own two trees, worktrees (each is its own checkout with its own root tree), .git,
# the hosted review action's staging copy (`./.claude-pr`), and every directory the
# project's own ignore rules exclude — `git ls-files --others --ignored
# --exclude-standard --directory` names them (build output, tool caches, vendored
# trees), so the skip list is .gitignore's, read at run time, never a hand-kept list
# of stack names (the hand-kept list missed a second project's tool cache on its first
# real application — #58 item 1). No -mindepth: as first written, -mindepth 2
# exempted depth-1 directories from the prune test, so a top-level node_modules was
# walked and its contents flagged (reproduced 2026-09-06). A stray tree under an
# untracked but unignored directory is still found — that is the fork case.
#
# Three rules make an ignore-driven list safe (#58 item 1):
#   1. Never prune a path that could BE or CONTAIN the tree this hook hunts for. A
#      project that ignores the memory directory by an unanchored name (`agent-memory/`
#      — the natural spelling for the `local` scope) or ignores `.claude/` wholesale
#      would otherwise have its own ignore rules hide the fork.
#   2. `-path` takes a glob, and `*`/`?` in it cross `/`. An ignored directory named
#      `*` (a legal Unix name) would splice in as `-path './*'`, prune the first
#      top-level entry the walk reaches, and report a clean tree with no stderr —
#      the silent miss this hook exists to stop. Metacharacters are escaped so an
#      entry prunes itself and nothing else.
#   3. `--directory` collapses a directory whose whole subtree is ignored into its
#      topmost ancestor, and in a repo with nothing committed yet that ancestor can
#      be `packages/` — a directory no ignore rule names. `git check-ignore` keeps
#      only the paths the rules actually exclude, so a collapsed ancestor is walked.
prunes=()
while IFS= read -r d; do
  d="${d%/}"
  [ -n "$d" ] || continue
  case "${d##*/}" in .claude|agent-memory|agent-memory-local) continue ;; esac
  prunes+=(-o -path "./$(printf '%s' "$d" | sed 's/[][*?\\]/\\&/g')")
done < <(
  git ls-files --others --ignored --exclude-standard --directory 2>/dev/null \
    | sed -n 's:/$::p' | git check-ignore --stdin 2>/dev/null || true
)
# find's stderr is kept, not discarded: an unreadable directory makes the scan partial,
# and a partial scan that reports "clean" is the silent miss this hook exists to stop
# (#58 item 2). A redirection to an uncreatable path would abort the walk before find
# ran, leaving forks empty and the tree reported clean — so the path is tested first
# and the walk degrades to unmonitored with a warning (#58, 2026-09-07 comment).
scan_err="$(mktemp 2>/dev/null || printf '%s/.detect-forked-agent-memory.%s.err' "${TMPDIR:-/tmp}" "$$")"
if ! : 2>/dev/null >"$scan_err"; then
  echo "detect-forked-agent-memory: WARNING — no scratch file for the scan's stderr ($scan_err); the walk runs unmonitored, so a partial scan cannot be reported." >&2
  scan_err=/dev/null
fi
forks=()
while IFS= read -r d; do forks+=("$d"); done < <(
  find . \( -path './.claude/agent-memory' -o -path './.claude/agent-memory-local' -o -path './.claude/worktrees' -o -path './.claude-pr' -o -name .git \
         ${prunes[@]+"${prunes[@]}"} \) -prune -o -type d \( -name agent-memory -o -name agent-memory-local \) -print 2>"$scan_err" | sort
)
if [ -s "$scan_err" ]; then
  echo "detect-forked-agent-memory: WARNING — the scan was partial; find could not read:" >&2
  head -n 5 "$scan_err" >&2
  echo "                            A stray tree under an unreadable directory is missed; fix the permissions and stop again." >&2
fi
[ "$scan_err" = /dev/null ] || rm -f "$scan_err"

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

If the path above belongs to tooling rather than to a dispatched agent — a harness
staging copy, a container's workspace, a vendored checkout — it is not a fork and
nothing should be moved or deleted. Add it to .gitignore, anchored, and this scan
prunes it from then on (the review action's \`.claude-pr/\` staging copy is the
exercised case and is pruned unconditionally).
MSG
exit 2
