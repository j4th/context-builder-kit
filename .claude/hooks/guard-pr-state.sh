#!/usr/bin/env bash
# PreToolUse hook (Bash matcher): force a per-action operator confirmation on
# PR-state-changing gh commands — gh pr ready / merge / close / reopen.
#
# The cascade already states the discipline in prose: /finish opens a *draft*
# PR and the operator flips it to ready (the slash command never does), and
# /pr-respond likewise never changes PR state. Draft<->ready flips, merges,
# closes and reopens are one-way doors that must carry an explicit per-action
# operator OK. permissionDecision:"ask" (not a hard deny) because
# operator-instructed state changes are legitimate — the permission prompt IS
# the per-action OK. `git push` and `gh pr create` are deliberately unmatched
# (/finish legitimately runs both).
#
# Tier:     ASK-GATE (see the registry comment in .claude/settings.json).
# Depends:  jq (the payload) — absent, the guard fails open: exit 0 with a stderr
#           warning that says no mechanical backstop exists. A payload jq cannot
#           read is not an environment defect: it gets the prompt
#           (cbk-conventions-reference.md § Hook authoring).
# Fixture:  .claude/workflows/tests/hook-guards-fixture.sh.

set -uo pipefail

# Drain stdin before any early exit, or a piping caller's SIGPIPE masks this hook's own
# exit code (cbk-conventions-reference.md § Hook authoring › The stdin / exit contract).
input="$(cat)"

if ! command -v jq &>/dev/null; then
  echo "guard-pr-state: WARNING — jq not installed; PR-state guard DISABLED." >&2
  echo "                Install jq to re-enable. Backstop until then: none mechanical — every" >&2
  echo "                gh pr ready/merge/close/reopen needs the operator's explicit per-action OK." >&2
  exit 0
fi

# A payload jq cannot read gets the prompt, never a pass: its command cannot be checked, so the
# operator decides.
if ! jq -e 'type == "object"' >/dev/null 2>&1 <<<"$input"; then
  cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "ask",
    "permissionDecisionReason": "guard-pr-state could not read this tool payload (not parseable JSON, or not an object), so it cannot tell whether the command changes a PR's state. Approve only if the operator asked for exactly this command."
  }
}
EOF
  exit 0
fi

tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty')"
command="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"

[[ "$tool_name" != "Bash" ]] && exit 0
[[ -z "$command" ]] && exit 0

# Token-anchored + flag-tolerant: matches `gh pr merge`, `gh -R o/r pr ready`,
# `gh pr -R o/r close 5`, etc. Over-matching (the phrase quoted inside another
# command) costs one extra confirmation — acceptable for an ask-gate.
# A here-string, never `printf … | grep`: a reader that exits on its first match makes
# pipefail read a real match as NO MATCH (cbk-conventions-reference.md § Hook authoring).
if grep -Eq '(^|[;&|[:space:]])gh([[:space:]]+[^[:space:]]+)*[[:space:]]+pr([[:space:]]+[^[:space:]]+)*[[:space:]]+(ready|merge|close|reopen)([[:space:]]|$|[;&|])' <<<"$command"; then
  cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "ask",
    "permissionDecisionReason": "PR-state change intercepted: draft/ready flips, merges, closes and reopens are the operator's calls (/finish and /pr-respond never change PR state) and require an explicit per-action OK — this permission prompt is that OK. If the operator has not asked for this exact state change, cancel."
  }
}
EOF
  exit 0
fi

exit 0
