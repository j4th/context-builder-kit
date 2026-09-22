#!/usr/bin/env bash
# Fixture for the kit's hooks: the two properties every hook must have regardless of what it
# guards (cbk-conventions-reference.md § Hook authoring › The stdin / exit contract), asserted
# structurally over every .claude/hooks/*.sh, plus behavioural probes: one over-buffer probe per
# decision site the kit ships, the fork detector's prune rules and degrade path, and the lock-file
# arms. Runs against throwaway `git init` trees under mktemp, never the real checkout, and never
# depends on the directory it is launched from. Run by the verification block; also:
# bash .claude/workflows/tests/hook-contract-fixture.sh
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
hooks="$here/../../hooks"
MAINBRANCH="$hooks/protect-main-branch.sh"
PRSTATE="$hooks/guard-pr-state.sh"
STOP="$hooks/detect-forked-agent-memory.sh"
LOCKFILES="$hooks/protect-lock-files.sh"
for h in "$MAINBRANCH" "$PRSTATE" "$STOP" "$LOCKFILES"; do [ -x "$h" ] || { echo "hook-contract-fixture: $h is missing or not executable"; exit 1; }; done
d=$(mktemp -d)
cleanup() { chmod -R u+rwX "$d" 2>/dev/null || true; rm -rf "$d"; }
trap cleanup EXIT

RC=0; ERR=""; OUT=""
want() { [ "$RC" -eq "$1" ] || { echo "FAIL: $2 (want exit $1, got $RC)"; [ -n "$ERR" ] && printf '  stderr: %s\n' "$ERR"; exit 1; }; }
says() { grep -q -- "$1" <<<"$ERR" || { echo "FAIL: $2 (stderr does not carry '$1')"; printf '  stderr: %s\n' "$ERR"; exit 1; }; }

# ── structural check 1: the drain is the first statement after `set -uo pipefail` ──
# Comment and blank lines are skipped; the first two statements must be exactly these.
want_drain_first="$(printf 'set -uo pipefail\ninput="$(cat)"')"
for h in "$hooks"/*.sh; do
  sig="$(awk '/^[[:space:]]*(#|$)/ { next } n < 2 { print; n++ }' "$h")"
  [ "$sig" = "$want_drain_first" ] || {
    echo "FAIL: $(basename "$h") does not drain stdin as its first statement"
    printf '%s\n' "$sig" | sed 's/^/  reads instead: /'
    exit 1
  }
done

# ── structural check 2: no hook decides on a pipeline whose reader can exit first ──
# A TRIPWIRE over known spellings (grep -q/-l/--quiet/--silent/-m N, head, read, sed …q, awk … exit
# after a `|`), not a proof; full-line comments are dropped (hooks quote the idiom while explaining
# it) and backslash/pipe continuations are joined first. A new hook still earns a behavioural case.
early_readers='[|][[:space:]]*(([{(]|timeout|xargs|env|stdbuf|while)[[:space:]]*[^|]*)?(grep[^|]*([[:space:]]-[A-Za-z]*[ql][A-Za-z]*([[:space:]]|$)|--quiet|--silent|--max-count|[[:space:]]-m[[:space:]]*[0-9])|head([[:space:]]|$)|read([[:space:]]|$)|sed[^|]*[[:space:]]['"'"'"]?[0-9$]*q|awk[^|]*exit)'
join_pipelines='
  { line = $0
    if (line ~ /^[[:space:]]*#/) line = ""
    buf = buf line
    if (buf ~ /[|\\][[:space:]]*$/) { sub(/\\[[:space:]]*$/, "", buf); next }
    print NR ": " buf; buf = ""
  }
  END { if (buf != "") print NR ": " buf }
'
for h in "$hooks"/*.sh; do
  hit="$(awk "$join_pipelines" "$h" | grep -E "$early_readers" || true)"
  [ -z "$hit" ] || {
    echo "FAIL: $(basename "$h") decides on a pipeline whose reader can exit first"
    printf '%s\n' "$hit" | sed 's/^/  /'
    exit 1
  }
done

# ── behavioural probes: a body of many lines, past any plausible reader ceiling ──
manybody='line of a long body wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww'
while [ ${#manybody} -lt 250000 ]; do manybody="$manybody
$manybody"; done
cmdpay() { jq -Rs --arg cwd "${2:-}" '{tool_name:"Bash",tool_input:{command:.},cwd:$cwd}' "$1"; }

# protect-main-branch is a HARD-DENY: a long commit body must not buy a bypass.
mainrepo="$d/mainrepo"; mkdir -p "$mainrepo"
git -c init.defaultBranch=main init -q "$mainrepo"
git -C "$mainrepo" -c user.email=f@x -c user.name=f commit -q --allow-empty -m init
printf "git commit -F - <<XEOF\n%s\nXEOF" "$manybody" > "$d/cmd-commit"
cmdpay "$d/cmd-commit" "$mainrepo" > "$d/pay-commit"
RC=0; ERR="$("$MAINBRANCH" < "$d/pay-commit" 2>&1 >/dev/null)" || RC=$?
want 2 "a commit on main is denied however long the command string is"
says "BLOCKED" "the long-command denial names itself"

# guard-pr-state is an ASK-GATE: its deliverable is the decision on STDOUT.
printf 'gh pr merge 5 --squash --body "%s"' "$manybody" > "$d/cmd-merge"
cmdpay "$d/cmd-merge" > "$d/pay-merge"
RC=0; ERR=""; OUT="$("$PRSTATE" < "$d/pay-merge" 2>/dev/null)" || RC=$?
want 0 "the PR-state ask-gate still exits 0 on a long command"
grep -q '"permissionDecision": "ask"' <<<"$OUT" || { echo "FAIL: gh pr merge with a long body did not raise the ask-gate"; exit 1; }

# The detector reads one field the same way; the cost there is the loop guard: a payload whose
# field sits early with the bulk after it must still be read as a second stop.
repo="$d/repo"; mkdir -p "$repo"; git -c init.defaultBranch=main init -q "$repo"
mkdir -p "$repo/pkg/a/.claude/agent-memory/reviewer"
printf '%s' "$manybody" > "$d/padfile"
jq -Rs '{stop_hook_active:true,pad:.}' "$d/padfile" > "$d/pay-stop"
RC=0; ERR="$(CLAUDE_PROJECT_DIR="$repo" "$STOP" < "$d/pay-stop" 2>&1 >/dev/null)" || RC=$?
want 0 "a second stop proceeds however long the payload is"
says "still present after one fix attempt" "and warns instead of blocking again"

# A first stop against the same tree exercises the prune's three safety rules and the review action's
# staging copy — branches a payload can reach, so they are asserted here, not only in a PR-body table.
# The tree adds: a memory tree under an ignored build directory (pruned — not a fork); the staging copy
# (pruned unconditionally); a directory literally named `*` that the ignore rules name (escaped, or
# `-path './*'` prunes the whole top level and the real fork is missed — rule 2); and the memory
# directory ignored by bare name (never pruned — rule 1; and its collapsed ancestors are filtered by
# check-ignore — rule 3). The real fork under pkg/a is named only when every rule holds: each rule
# removed exits 0 with empty stderr (measured 2026-09-21).
printf '/pkg/*/build/\n/\\*/\nagent-memory/\n' > "$repo/.gitignore"
mkdir -p "$repo/pkg/b/build/.claude/agent-memory/y" "$repo/.claude-pr/.claude/agent-memory/z" "$repo/*/.claude/agent-memory/w"
printf '{"stop_hook_active":false}' > "$d/pay-first"
RC=0; ERR="$(CLAUDE_PROJECT_DIR="$repo" "$STOP" < "$d/pay-first" 2>&1 >/dev/null)" || RC=$?
want 2 "a fork outside the root blocks the first stop"
says "  ./pkg/a/.claude/agent-memory" "the block names the forked tree"
! grep -q '^  \./pkg/b' <<<"$ERR" || { echo "FAIL: a tree under an ignored build directory was reported as a fork"; exit 1; }
! grep -q '^  \./\.claude-pr' <<<"$ERR" || { echo "FAIL: the review action's staging copy was reported as a fork"; exit 1; }
! grep -q '^  \./\*' <<<"$ERR" || { echo "FAIL: the ignored directory named * was reported as a fork"; exit 1; }
# No scratch file for the scan's stderr: the walk runs unmonitored and says so — never a clean report.
RC=0; ERR="$(TMPDIR=/nonexistent/x CLAUDE_PROJECT_DIR="$repo" "$STOP" < "$d/pay-first" 2>&1 >/dev/null)" || RC=$?
want 2 "an unwritable scratch path degrades the walk to unmonitored and the fork still blocks"
says "no scratch file" "and the degrade is named"

# protect-lock-files is a HARD-DENY whose two arm shapes are on the diff: the named list (pubspec.lock
# is its newest entry, with its own remediation) and the *.lock fallback; a non-lock edit passes.
lockpay() { jq -n --arg f "$repo/$1" '{tool_name:"Edit",tool_input:{file_path:$f}}' > "$d/pay-lock"; }
lockpay pubspec.lock;  RC=0; ERR="$(CLAUDE_PROJECT_DIR="$repo" "$LOCKFILES" < "$d/pay-lock" 2>&1 >/dev/null)" || RC=$?
want 2 "an edit to pubspec.lock is denied by the named arm"
says "dart pub get" "with the dart remediation"
lockpay deps/foo.lock; RC=0; ERR="$(CLAUDE_PROJECT_DIR="$repo" "$LOCKFILES" < "$d/pay-lock" 2>&1 >/dev/null)" || RC=$?
want 2 "an edit to an unlisted *.lock is denied by the fallback arm"
says "fallback arm" "and the arm names itself"
lockpay notes.md;      RC=0; ERR="$(CLAUDE_PROJECT_DIR="$repo" "$LOCKFILES" < "$d/pay-lock" 2>&1 >/dev/null)" || RC=$?
want 0 "an edit to a non-lock file passes"

echo "hook-contract-fixture: ok"
