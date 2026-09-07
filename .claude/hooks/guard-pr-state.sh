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
# Fail-open on environment defects (missing jq), mirroring
# protect-lock-files.sh.
# Tier:     ASK-GATE (see the registry comment in .claude/settings.json).

set -uo pipefail

if ! command -v jq &>/dev/null; then
  echo "guard-pr-state: WARNING — jq not installed; PR-state guard DISABLED." >&2
  echo "                Until fixed, the only backstop is the prose rule in /finish and" >&2
  echo "                /pr-respond that PR-state changes are the operator's calls." >&2
  exit 0
fi

input="$(cat)"
tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty')"
command="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"

[[ "$tool_name" != "Bash" ]] && exit 0
[[ -z "$command" ]] && exit 0

# Token-anchored + flag-tolerant: matches `gh pr merge`, `gh -R o/r pr ready`,
# `gh pr -R o/r close 5`, etc. Over-matching (the phrase quoted inside another
# command) costs one extra confirmation — acceptable for an ask-gate.
if printf '%s' "$command" | grep -Eq '(^|[;&|[:space:]])gh([[:space:]]+[^[:space:]]+)*[[:space:]]+pr([[:space:]]+[^[:space:]]+)*[[:space:]]+(ready|merge|close|reopen)([[:space:]]|$|[;&|])'; then
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
