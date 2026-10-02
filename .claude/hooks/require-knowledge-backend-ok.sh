#!/usr/bin/env bash
# PreToolUse hook: force a per-action operator confirmation on every
# knowledge-backend WRITE tool call. The matcher in settings.json owns the
# tool-name pattern. The shipped regex covers the ten mutating verbs of Notion
# (the kit's v1 reference knowledge backend), across both the direct
# mcp__notion__* and plugin-namespaced tool names: create, update, move,
# duplicate, convert and delete, plus upload (upload-skill replaces a page's
# body), spawn and send (spawn-session and send-message-to-session drive an
# agent that writes) and stop (stop-session). The verb list is a dated
# observation of the vendor's tool names (2026-09-21; the verification block
# checks the matcher against the tool list as seen on 2026-10-01, writes in and
# reads out): re-verify it when the MCP's tool list changes, widen the matcher
# for a new mutating verb, and
# adjust it to your configured MCP's tool names if your knowledge backend
# differs. Reads (fetch/search) are unmatched and unaffected.
#
# Backstops .claude/rules/knowledge-backend.md § HITL announcement discipline;
# § When to write states the rule: "Every write requires explicit HITL approval.
# No cascade phase writes ... as a side effect." The rule is absolute (per-action approval, no judgment
# call), so a deterministic permissionDecision:"ask" is the right mechanism —
# it forces the operator prompt even when a broad permissions-allow entry
# would otherwise auto-approve the tool.
# Not seen: Notion attached as a claude.ai connector, whose tools are named
#           mcp__claude_ai_<server>__<tool> with a server name the kit cannot
#           know — add that form to the matcher if you connect Notion that way.
# Tier:     ASK-GATE (see the registry comment in .claude/settings.json).
# Depends:  nothing — the decision is unconditional for a matched tool, so the
#           payload is never parsed, and an unreadable one asks like any other
#           (cbk-conventions-reference.md § Hook authoring).
# Fixture:  .claude/workflows/tests/hook-guards-fixture.sh.

set -uo pipefail
# Drain stdin first (cbk-conventions-reference.md § Hook authoring › The stdin / exit contract);
# the decision is unconditional for matched tools, so the payload is read and not inspected.
input="$(cat)"
: "$input"
cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "ask",
    "permissionDecisionReason": "Knowledge-backend WRITE intercepted (knowledge-backend.md § HITL announcement discipline): every knowledge-backend write needs explicit per-action operator approval. Announce the write ('About to create/update <page>. OK?') and let the operator approve this permission prompt — or cancel if no approval was given."
  }
}
EOF
exit 0
