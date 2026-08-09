#!/usr/bin/env bash
# PreToolUse hook: force a per-action operator confirmation on every
# knowledge-backend WRITE tool call. The matcher in settings.json owns the
# tool-name pattern — the shipped regex covers Notion (the kit's v1 reference
# knowledge backend) mutating verbs (create/update/move/duplicate/convert/
# delete) across both the direct mcp__notion__* and plugin-namespaced tool
# names; when the MCP grows a new mutating verb, widen the matcher — and
# adjust it to your configured MCP's tool names if your knowledge backend
# differs. Reads (fetch/search) are unmatched and unaffected.
#
# Backstops .claude/rules/knowledge-backend.md § HITL announcement discipline:
# "Every write requires explicit HITL approval. No cascade phase writes ...
# as a side effect." The rule is absolute (per-action approval, no judgment
# call), so a deterministic permissionDecision:"ask" is the right mechanism —
# it forces the operator prompt even when a broad permissions-allow entry
# would otherwise auto-approve the tool.

set -uo pipefail
cat > /dev/null # consume stdin; the decision is unconditional for matched tools
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
