#!/usr/bin/env bash
# PreToolUse hook (Bash matcher): block `git commit` while on main/master.
#
# Branch-first is the cascade rule: /finish creates the feature branch before
# any code lands, and cbk-conventions.md § Branch naming defines the shape. A
# commit that lands on local main is expensive to unwind once the remote
# diverges (e.g. after a squash-merge) — and hooks enforce non-negotiables
# more reliably than instructions.
#
# Blocked:  Bash tool calls whose command contains a token-anchored `git`
#           followed (any number of option tokens later) by a `commit` token,
#           while the call's working directory is on main or master.
# Allowed:  everything else — commits on feature branches, and all
#           non-commit git commands on main.
# Timing:   the guard reads the branch BEFORE the command runs, so a compound
#           command that creates a branch and commits in one call is judged on
#           main and blocked. Create the branch and make the first commit in
#           separate tool calls (stated for agents in cbk-conventions.md
#           § Branch naming — keep the two in step).
#
# Hook receives JSON on stdin with the tool input. Exit 2 + stderr blocks.
# Fail-open on environment defects (missing jq, non-repo cwd): exit 0 with a
# loud stderr warning, mirroring protect-lock-files.sh.
# Tier:     HARD-DENY (see the registry comment in .claude/settings.json).

set -uo pipefail
# Deliberately NOT `set -e` — fail-open on environment defects rather than
# aborting with cryptic stderr that blocks all Bash calls.

if ! command -v jq &>/dev/null; then
  echo "protect-main-branch: WARNING — jq not installed; main-branch commit protection DISABLED." >&2
  echo "                     Install jq to re-enable. Until then the only backstop is the operator" >&2
  echo "                     noticing a commit on main before pushing." >&2
  exit 0
fi

input="$(cat)"
tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty')"
command="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"
# The Bash tool's payload carries the call's working directory; the branch
# check must use it (not a fixed project dir), or a commit run from a
# worktree / nested repo is judged against the wrong repo's branch.
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty')"
PROJECT_DIR="${cwd:-${CLAUDE_PROJECT_DIR:-$PWD}}"

[[ "$tool_name" != "Bash" ]] && exit 0
[[ -z "$command" ]] && exit 0

# Token-anchored and flag-tolerant: `commit` may appear any number of tokens
# after a token-anchored `git` (so global options like `-c k=v`, `--no-pager`,
# or `-C path` don't silently defeat a hard-deny guard). Over-matching — a
# quoted "git … commit" phrase inside another command, a `commit` token in an
# unrelated git call, or a `git -C <other-repo> commit` judged against this
# repo's branch — costs one wrongly BLOCKED call with a loud message the
# operator can override by running the commit themselves; under-matching
# would be a silent bypass, which is worse for a deny-tier guard.
if ! printf '%s' "$command" | grep -Eq '(^|[;&|[:space:]])git([[:space:]]+[^[:space:]]+)*[[:space:]]+commit([[:space:]]|$)'; then
  exit 0
fi

branch="$(git -C "$PROJECT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null)" || {
  echo "protect-main-branch: WARNING — $PROJECT_DIR is not a git repo; guard inactive for this call." >&2
  exit 0
}

if [[ "$branch" == "main" || "$branch" == "master" ]]; then
  cat >&2 <<EOF
BLOCKED: git commit on '$branch'.

Branch-first is the rule (cbk-conventions.md § Branch naming; /finish creates
the branch before any code lands). Create the feature branch, then re-run the
commit:
  git switch -c <type>/<team>-<n>-<short-slug>

If this block is genuinely wrong (rare), the operator can run the commit
themselves outside Claude Code.
EOF
  exit 2
fi

exit 0
