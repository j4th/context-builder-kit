#!/usr/bin/env bash
# PreToolUse hook (Bash matcher): block `git commit` while on main/master.
#
# Branch-first is the cascade rule: /finish creates the feature branch before
# any code lands, and cbk-conventions.md § Branch naming defines the shape. A
# commit that lands on local main is expensive to unwind once the remote
# diverges (e.g. after a squash-merge) — and hooks enforce non-negotiables
# more reliably than instructions.
#
# Blocked:  Bash tool calls whose command contains `git` — at the start, or
#           after any character that cannot continue a word (a space, `;`, `&`,
#           `|`, `(`, `$(`, a backtick, a quote, the `/` of /usr/bin/git) —
#           followed, any number of option tokens later, by a `commit` token that
#           no word character, `.` or `-` continues, while the call's working
#           directory is on main or master; and a payload jq cannot read.
# Allowed:  everything else — commits on feature branches, non-commit git
#           commands on main, `git commit-tree`, and a `commit.*` config key.
# Not seen: a commit the command spells indirectly — `eval`, a variable holding
#           `git`, a git alias, a script that commits — and a commit into another
#           checkout the command reaches itself (`cd <dir> && git commit`,
#           `git -C <dir> commit`): the branch judged is the one at the payload's
#           cwd. A pattern guard reads the text, not what runs; the base branch's
#           ruleset, where one exists, refuses such a commit when it is pushed.
# Timing:   the guard reads the branch BEFORE the command runs, so a compound
#           command that creates a branch and commits in one call is judged on
#           main and blocked. Create the branch and make the first commit in
#           separate tool calls (stated for agents in cbk-conventions.md
#           § Branch naming — keep the two in step).
#
# Hook receives JSON on stdin with the tool input. Exit 2 + stderr blocks.
# Fail-open on environment defects (missing jq, non-repo cwd): exit 0 with a
# loud warning naming the backstops, shown as a systemMessage, mirroring protect-lock-files.sh.
# A payload jq cannot read is refused (cbk-conventions-reference.md § Hook
# authoring). Fixture: .claude/workflows/tests/hook-guards-fixture.sh.
# Tier:     HARD-DENY (see the registry comment in .claude/settings.json).
# Depends:  jq (the payload) and git (the branch) — absent jq, the guard fails
#           open: exit 0 with a warning, shown as a systemMessage, naming the backstops; absent git,
#           or a working directory that is not a checkout, the same.

set -uo pipefail

# Drain stdin before any early exit, or a piping caller's SIGPIPE masks this hook's own
# exit code (cbk-conventions-reference.md § Hook authoring › The stdin / exit contract).
input="$(cat)"
# A fail-open warning goes to stderr, which on exit 0 reaches only the debug log, and to the user as the systemMessage
# on stdout (https://code.claude.com/docs/en/hooks § Exit code 0 and § JSON output, read 2026-10-01). Pure bash, so it
# works on the minimal PATH the fail-open cases run with.
fail_open() {
  printf '%s\n' "$@" >&2
  local m="$*"; while [[ $m == *"  "* ]]; do m=${m//  / }; done
  m=${m//\\/\\\\}; m=${m//\"/\\\"}
  printf '{"systemMessage":"%s"}\n' "$m"
  exit 0
}
# Deliberately NOT `set -e` — fail-open on environment defects rather than
# aborting with cryptic stderr that blocks all Bash calls.

if ! command -v jq &>/dev/null; then
  fail_open "protect-main-branch: WARNING — jq not installed; main-branch commit protection DISABLED." \
    "                     Install jq to re-enable. Backstops until then: [the base branch's ruleset —" \
    "                     pull requests only — where one exists], and the operator noticing a commit" \
    "                     on local main before branching."
fi

# A payload jq cannot read is refused: its command and working directory cannot be checked, and a
# guard that waved it through would fall to one lone UTF-16 surrogate escape in the command.
if ! fields=$(jq -er 'def s: if . == null then "" elif type == "string" then . else error("a field is not a string") end; if type == "object" then @sh "tool_name=\(.tool_name | s) command=\(.tool_input.command | s) cwd=\(.cwd | s)" else error("not an object") end' <<<"$input" 2>/dev/null); then
  echo "BLOCKED: protect-main-branch could not read the tool payload (not parseable JSON, not an object, or a field that is not a string)," >&2
  echo "so it cannot tell whether this is a commit on main. A lone UTF-16 surrogate escape in the command does this — remove it and retry." >&2
  exit 2
fi

eval "$fields"
# The payload's `cwd` is the directory the Bash tool is in — it follows `cd`
# (probe, 2026-09-30; require-repo-root-for-agents.sh § Timing) — so a commit
# run from a worktree or a nested repo is judged against that checkout's
# branch, not a fixed project dir. Precedence: cwd, CLAUDE_PROJECT_DIR, $PWD.
PROJECT_DIR="${cwd:-${CLAUDE_PROJECT_DIR:-$PWD}}"

[[ "$tool_name" != "Bash" ]] && exit 0
[[ -z "$command" ]] && exit 0
# A line continuation (backslash-newline) joins one command across lines, and grep matches one line at a time: fold
# each into a space first, so `git \<newline> commit` is judged as the commit it runs as.
command=${command//$'\\\n'/ }

# Token-anchored and flag-tolerant: `commit` may appear any number of tokens
# after a token-anchored `git` (so global options like `-c k=v`, `--no-pager`,
# or `-C path` don't silently defeat a hard-deny guard). Over-matching — a
# quoted "git … commit" phrase inside another command, a `commit` token in an
# unrelated git call, or a `git -C <other-repo> commit` judged against this
# repo's branch — costs one wrongly BLOCKED call with a loud message the
# operator can override by running the commit themselves; under-matching
# would be a silent bypass, which is worse for a deny-tier guard. Both anchors
# are negated classes: `git` may follow anything that cannot continue a word,
# so `bash -c "git commit …"`, `(git commit …)`, `$(git commit …)` and
# `/usr/bin/git commit` are caught; `commit` may be followed by anything but a
# word character, `.` or `-`, so `git commit;` and `git commit&&…` are caught
# while `git commit-tree` and `git config commit.gpgsign …` are not (each
# measured 2026-09-30; the fixture holds the cases).
# A here-string, never `printf … | grep`: a reader that exits on its first match makes
# pipefail read a real match as NO MATCH (cbk-conventions-reference.md § Hook authoring).
if ! grep -Eq '(^|[^[:alnum:]_.-])git([[:space:]]+[^[:space:]]+)*[[:space:]]+commit([^[:alnum:]_.-]|$)' <<<"$command"; then
  exit 0
fi

branch="$(git -C "$PROJECT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null)" || {
  fail_open "protect-main-branch: WARNING — $PROJECT_DIR is not a git repo; guard inactive for this call." \
    "                     Backstop: [the base branch's ruleset — pull requests only — where one exists]."
}

if [[ "$branch" == "main" || "$branch" == "master" ]]; then
  cat >&2 <<EOF
BLOCKED: git commit on '$branch'.

Branch-first is the rule (cbk-conventions.md § Branch naming; /finish creates
the branch before any code lands). Create the feature branch, then re-run the
commit:
  git switch -c <type>/<team>-<n>-<short-slug>        # an issue this PR closes
  git switch -c <type>/<short-slug>                   # work no issue tracks

If this block is genuinely wrong (rare), the operator can run the commit
themselves outside Claude Code.
EOF
  exit 2
fi

exit 0
