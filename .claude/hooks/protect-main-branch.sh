#!/usr/bin/env bash
# PreToolUse hook (Bash matcher): block `git commit` while on main/master.
#
# Branch-first is the cascade rule: /finish creates the feature branch before
# any code lands, and cbk-conventions.md § Branch naming defines the shape. A
# commit that lands on local main is expensive to unwind once the remote
# diverges (e.g. after a squash-merge) — and hooks enforce non-negotiables
# more reliably than instructions.
#
# Blocked:  Bash tool calls whose command contains a token-anchored
#           `git commit` while the repo's current branch is main or master.
# Allowed:  everything else — commits on feature branches, and all
#           non-commit git commands on main.
#
# Hook receives JSON on stdin with the tool input. Exit 2 + stderr blocks.
# Fail-open on environment defects (missing jq, non-repo cwd): exit 0 with a
# loud stderr warning, mirroring protect-lock-files.sh.

set -uo pipefail
# Deliberately NOT `set -e` — fail-open on environment defects rather than
# aborting with cryptic stderr that blocks all Bash calls.

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"

if ! command -v jq &>/dev/null; then
  echo "protect-main-branch: WARNING — jq not installed; main-branch commit protection DISABLED." >&2
  echo "                     Install jq to re-enable. Until then the only backstop is the operator" >&2
  echo "                     noticing a commit on main before pushing." >&2
  exit 0
fi

input="$(cat)"
tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty')"
command="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"

[[ "$tool_name" != "Bash" ]] && exit 0
[[ -z "$command" ]] && exit 0

# Only inspect commands containing a token-anchored `git commit` invocation
# (start-of-command or after ; & | whitespace) — avoids false-blocking text
# that merely contains the phrase. Known residuals: `git -C path commit`
# passes through; a quoted "git commit" inside another command still matches
# (cost: one wrongly blocked call on main, where legitimate ops are read-only
# anyway). Refine if one recurs.
if ! printf '%s' "$command" | grep -Eq '(^|[;&|[:space:]])git[[:space:]]+commit([[:space:]]|$)'; then
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
