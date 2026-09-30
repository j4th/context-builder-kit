#!/usr/bin/env bash
# Behavioural cases for the four guards no other fixture drives by payload: the main-branch deny
# (protect-main-branch.sh), the PR-state ask-gate (guard-pr-state.sh), the lock-file deny (protect-lock-files.sh) and
# the knowledge-backend ask-gate — every branch each documents in its header gets a crafted payload and an asserted
# exit or decision (§ Hook authoring › Verify by payload, made durable; context-builder-kit#58 item 4). A payload jq
# cannot read is refused by each deny and asked by each ask-gate; each fail-open warning names what still stands; one
# case per deny runs from a project root containing a space. hook-contract-fixture.sh checks every hook's structure
# and one over-buffer probe per decision site; hook-payloads-fixture.sh drives the launch-root guard and the fork
# detector; protected-paths-hook-fixture.sh drives the path guard. The two advisory exemplars (format-on-edit.sh,
# analyze-on-edit.sh) ship with no live case arm, so there is no branch to drive until a target fills one.
# The knowledge-backend guard is found by the registry, not by name: the script (the `command`, or an `args` element,
# ending in .sh) of the settings.json entry whose matcher names a knowledge-backend MCP tool (mcp__…), so shell form
# and exec form both resolve. A target whose knowledge axis is `none` deletes that guard and its stanza at the
# bootstrap disposition pass, and its cases then print a SKIP line.
# Every case runs against throwaway `git init` trees under mktemp, never the real repository; the hooks run from their
# real path, so a change to any of them is caught. Needs bash, git and jq; runs in throwaway trees.
# Run by the verification block; also: bash .claude/workflows/tests/hook-guards-fixture.sh
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
hooks="$here/../../hooks"
settings="$here/../../settings.json"
MAIN="$hooks/protect-main-branch.sh"; PRS="$hooks/guard-pr-state.sh"; LOCK="$hooks/protect-lock-files.sh"
for h in "$MAIN" "$PRS" "$LOCK"; do [ -x "$h" ] || { echo "hook-guards-fixture: $h is missing or not executable"; exit 1; }; done
command -v jq >/dev/null && command -v git >/dev/null || { echo "hook-guards-fixture: needs jq and git"; exit 1; }
[ -f "$settings" ] || { echo "hook-guards-fixture: $settings is missing"; exit 1; }
kbname=$(jq -r '[.hooks.PreToolUse[]? | select((.matcher // "") | test("^mcp__")) | .hooks[] | [.command] + (.args // []) | map(select(type == "string" and endswith(".sh"))) | .[0] // empty] | first // empty' "$settings")
KB=""; [ -z "$kbname" ] || KB="$hooks/${kbname##*/}"
d=$(mktemp -d)
trap 'rm -rf "$d"' EXIT
# Git discovery stops at the throwaway root (the ceiling is its parent), so a TMPDIR inside a work tree cannot turn
# the non-checkout case into a checkout.
export GIT_CEILING_DIRECTORIES="${d%/*}"

repo_on() {  # repo_on <dir> <branch>: a throwaway checkout with one commit, on <branch>
  git -c init.defaultBranch=main init -q "$1"
  git -C "$1" -c user.email=t@t -c user.name=t -c commit.gpgsign=false commit -q --allow-empty -m x
  [ "$2" = main ] || git -C "$1" switch -q -c "$2"
}
repo_on "$d/on-main" main; repo_on "$d/on-master" main; git -C "$d/on-master" branch -q -m master; repo_on "$d/on-feat" feat/x
repo_on "$d/a b" main
mkdir -p "$d/plain"

n=0; RC=0; OUT=""; ERR=""
run() {  # run <hook> <payload> [env args…]: RC, OUT (stdout), ERR (stderr); runs in $RUN_CWD when it is set
  local hook=$1 payload=$2; shift 2
  RC=0; OUT="$(cd "${RUN_CWD:-$PWD}" && printf '%s' "$payload" | env "$@" "$hook" 2>"$d/err")" || RC=$?; ERR="$(cat "$d/err")"; n=$((n + 1))
}
want() { [ "$RC" -eq "$1" ] || { echo "FAIL: $2 (want exit $1, got $RC)"; [ -n "$ERR" ] && printf '  stderr: %s\n' "$ERR"; exit 1; }; }
says() { grep -q -- "$1" <<<"$ERR" || { echo "FAIL: $2 (stderr lacks '$1')"; printf '  stderr: %s\n' "$ERR"; exit 1; }; }
asks() { [ "$RC" -eq 0 ] && jq -e '.hookSpecificOutput.permissionDecision == "ask"' >/dev/null 2>&1 <<<"$OUT" \
  || { echo "FAIL: $1 (want an ask decision on stdout, exit 0; got exit $RC)"; printf '  stdout: %s\n' "$OUT"; exit 1; }; }
silent() { [ "$RC" -eq 0 ] && [ -z "$OUT" ] || { echo "FAIL: $1 (want exit 0 and no decision; got exit $RC)"; printf '  stdout: %s\n' "$OUT"; exit 1; }; }
bash_payload() { jq -cn --arg c "$1" --arg cwd "$2" '{tool_name:"Bash", tool_input:{command:$c}, cwd:$cwd}'; }
edit_payload() { jq -cn --arg t "$1" --arg f "$2" '{tool_name:$t, tool_input:{file_path:$f}}'; }
surrogate() { printf '{"tool_name":"%s","tool_input":{"%s":"%s","content":"x\\ud800y"},"cwd":"%s"}' "$1" "$2" "$3" "$4"; }
nojq="$d/nojq"; mkdir -p "$nojq"
for t in bash cat git basename dirname; do p=$(type -P "$t" || true); [ -n "$p" ] && ln -sf "$p" "$nojq/$t"; done

# ── protect-main-branch.sh (HARD-DENY: a `git commit` on main or master) ──
run "$MAIN" "$(bash_payload 'git commit -m x' "$d/on-main")";        want 2 "a commit on main is denied"
says "BLOCKED" "the denial names itself"; says "git switch -c" "the denial gives the branch-first remediation"
run "$MAIN" "$(bash_payload 'git commit -m x' "$d/on-master")";      want 2 "a commit on master is denied"
run "$MAIN" "$(bash_payload 'git commit -m x' "$d/on-feat")";        want 0 "a commit on a feature branch is allowed"
run "$MAIN" "$(bash_payload 'git -C . commit -m x' "$d/on-main")";   want 2 "options between git and commit are still a commit"
run "$MAIN" "$(bash_payload 'git add -A && git commit -m x' "$d/on-main")"; want 2 "a commit after && is still a commit"
run "$MAIN" "$(bash_payload 'echo legit commitment' "$d/on-main")";  want 0 "text merely containing the phrase is allowed"
run "$MAIN" "$(bash_payload 'git status' "$d/on-main")";             want 0 "a non-commit git command is allowed"
run "$MAIN" "$(jq -cn --arg cwd "$d/on-main" '{tool_name:"Edit", tool_input:{file_path:"x"}, cwd:$cwd}')"; want 0 "a non-Bash tool passes through"
run "$MAIN" "$(bash_payload '' "$d/on-main")";                       want 0 "an empty command passes through"
run "$MAIN" "$(bash_payload 'git commit -m x' "$d/a b")";            want 2 "a commit on main under a project root containing a space is denied"
# The payload's cwd wins over CLAUDE_PROJECT_DIR, both ways (the two disagree in a worktree session).
run "$MAIN" "$(bash_payload 'git commit -m x' "$d/on-feat")" CLAUDE_PROJECT_DIR="$d/on-main"; want 0 "payload cwd on a feature branch wins over a project dir on main"
run "$MAIN" "$(bash_payload 'git commit -m x' "$d/on-main")" CLAUDE_PROJECT_DIR="$d/on-feat"; want 2 "payload cwd on main wins over a project dir on a feature branch"
run "$MAIN" "$(jq -cn '{tool_name:"Bash", tool_input:{command:"git commit -m x"}}')" CLAUDE_PROJECT_DIR="$d/on-main"; want 2 "with no payload cwd, the project dir decides"
# With neither a payload cwd nor CLAUDE_PROJECT_DIR, the hook's own working directory decides ($PWD, the last fallback).
RUN_CWD="$d/on-main" run "$MAIN" "$(jq -cn '{tool_name:"Bash", tool_input:{command:"git commit -m x"}}')" -u CLAUDE_PROJECT_DIR; want 2 "with no cwd and no project dir, \$PWD on main is denied"
RUN_CWD="$d/on-feat" run "$MAIN" "$(jq -cn '{tool_name:"Bash", tool_input:{command:"git commit -m x"}}')" -u CLAUDE_PROJECT_DIR; want 0 "with no cwd and no project dir, \$PWD on a feature branch is allowed"
# A commit with nothing after it — the end-of-command form, reached after && or alone.
run "$MAIN" "$(bash_payload 'git add -A && git commit' "$d/on-main")"; want 2 "a bare commit at the end of the command is still a commit"
run "$MAIN" "$(bash_payload 'git commit' "$d/on-main")";             want 2 "a bare commit alone is a commit"
# Fail-open branches name what still stands.
run "$MAIN" "$(bash_payload 'git commit -m x' "$d/plain")";          want 0 "a directory that is not a checkout fails open"
says "not a git repo" "the non-checkout warning says why"; says "Backstop" "the non-checkout warning names a backstop"
run "$MAIN" "$(bash_payload 'git commit -m x' "$d/on-main")" -i PATH="$nojq" HOME="$HOME"; want 0 "no jq fails open"
says "jq not installed" "the no-jq warning says why"; says "Backstops" "the no-jq warning names the backstops"
# Input it cannot read is refused, on any branch: the guard cannot tell what it is.
run "$MAIN" "$(surrogate Bash command 'git commit -m x' "$d/on-feat")"; want 2 "a payload jq cannot parse is refused"
says "could not read the tool payload" "the refusal says why"
run "$MAIN" '["not", "an", "object"]';                               want 2 "a payload that is not an object is refused"

# ── guard-pr-state.sh (ASK-GATE: a PR-state change) ──
for c in 'gh pr merge 7 --squash' 'gh pr ready 7' 'gh pr close 7' 'gh pr reopen 7' \
         'gh -R o/r pr merge 7' 'gh pr --repo o/r ready 7' 'git push && gh pr merge 7' \
         'gh pr merge' 'gh pr ready' 'git push && gh pr merge'; do  # the bare forms act on the current branch's PR
  run "$PRS" "$(bash_payload "$c" "$d/on-feat")"; asks "a PR-state change asks: $c"
done
for c in 'gh pr create --draft' 'gh pr view 7' 'gh pr list' 'gh pr checks 7' 'gh issue close 7'; do
  run "$PRS" "$(bash_payload "$c" "$d/on-feat")"; silent "no decision for: $c"
done
run "$PRS" "$(jq -cn '{tool_name:"Edit", tool_input:{file_path:"x"}}')"; silent "a non-Bash tool passes through"
run "$PRS" "$(bash_payload 'gh pr merge 7' "$d/on-feat")" -i PATH="$nojq" HOME="$HOME"; want 0 "no jq fails open"
says "jq not installed" "the no-jq warning says why"; says "Backstop" "the no-jq warning names what still stands"
run "$PRS" "$(surrogate Bash command 'gh pr merge 7' "$d/on-feat")"; asks "a payload jq cannot parse gets the prompt"
run "$PRS" 'not json at all';                                        asks "a payload that is not JSON gets the prompt"

# ── protect-lock-files.sh (HARD-DENY: a hand edit to a lock file) ──
for f in uv.lock pnpm-lock.yaml package-lock.json yarn.lock Cargo.lock Gemfile.lock poetry.lock composer.lock mix.lock pubspec.lock; do
  run "$LOCK" "$(edit_payload Edit "$d/on-feat/$f")"; want 2 "a hand edit to $f is denied"
  says "package-manager-managed" "$f is denied by its named arm, not the fallback"
done
run "$LOCK" "$(edit_payload Write "$d/on-feat/frontend/pnpm-lock.yaml")"; want 2 "a nested lock file is denied too"
says "pnpm install" "the named arm gives its package manager"
run "$LOCK" "$(edit_payload Edit "$d/a b/uv.lock")";                want 2 "a lock file under a project root containing a space is denied"
run "$LOCK" "$(edit_payload MultiEdit "$d/on-feat/flake.lock")"; want 2 "an unnamed *.lock is denied by the fallback arm"
says "fallback arm" "the fallback denial names itself"
says "above the \`\*.lock)\` arm" "the fallback gives the real route for a non-lock file: a case arm above it"
! grep -q "exemption comment" <<<"$ERR" || { echo "FAIL: the fallback still points at an exemption comment the hook does not have"; exit 1; }
for f in pyproject.toml lockfile.md uv.lock.md docs/locking.lock.txt; do
  run "$LOCK" "$(edit_payload Edit "$d/on-feat/$f")"; want 0 "a non-lock file is allowed: $f"
done
run "$LOCK" "$(edit_payload Read "$d/on-feat/uv.lock")"; want 0 "a read of a lock file is allowed"
run "$LOCK" "$(jq -cn '{tool_name:"Edit", tool_input:{}}')";   want 0 "an empty file_path passes through"
run "$LOCK" "$(edit_payload Edit "$d/on-feat/uv.lock")" -i PATH="$nojq" HOME="$HOME"; want 0 "no jq fails open"
says "jq not installed" "the no-jq warning says why"; says "Backstop" "the no-jq warning names what still stands"
run "$LOCK" "$(surrogate Write file_path "$d/on-feat/uv.lock" "$d/on-feat")"; want 2 "a payload jq cannot parse is refused"
says "could not read the tool payload" "the refusal says why"

# ── the knowledge-backend ask-gate (ASK-GATE: every knowledge-backend write) — asks whatever the payload ──
if [ -n "$KB" ]; then
  [ -x "$KB" ] || { echo "FAIL: settings.json registers ${kbname##*/}, which is missing or not executable"; exit 1; }
  run "$KB" '{"tool_name":"mcp__notion__notion-update-page","tool_input":{"page_id":"x"}}'; asks "a knowledge-backend write asks"
  run "$KB" 'not json at all';                                                           asks "an unparseable payload still asks (no parse, no fail-open)"
  run "$KB" '';                                                                          asks "an empty payload still asks"
else
  echo "SKIP: the knowledge-backend ask-gate (no mcp__ matcher in settings.json — the knowledge axis is none)"
fi

echo "hook-guards-fixture: $n cases ok"
