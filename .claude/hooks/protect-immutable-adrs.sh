#!/usr/bin/env bash
# PreToolUse hook (Edit|Write|MultiEdit): block edits/writes to existing immutable ADR files.
#
# ADRs in docs/adr/<NNNN>-*.md are immutable per ADR-0000. Superseding requires a NEW ADR (with a higher number
# that links to the old one as `Supersedes:`) — never an edit to the old one.
#
# Allowed:  creating a new ADR file (NNNN doesn't exist yet — tested on the RESOLVED path, so creation stays
#           allowed); editing docs/adr/template.md, docs/adr/README.md (the index) and docs/adr/corrections.md
#           (the append-only claim register — where a wrong citation, figure, attribution or formula in an
#           accepted ADR is corrected); a file nested below docs/adr/, and a sibling directory that only shares
#           the prefix (docs/adr-old/); every other tool.
# Blocked:  any Edit/Write/MultiEdit whose target resolves — lexically or physically — to an existing
#           docs/adr/NNNN-*.md in ANY checkout: every target keeps its immutable ADRs at that path, and a session
#           in one target edits its siblings; the same ADR under another name in the hook's own checkout, the
#           project dir's, or a linked worktree of either (a hardlink to an ADR, a bind mount of docs/adr/ — same
#           device and inode); a path through /proc, a symlink that cannot be read, and a payload jq cannot read
#           — none of them can be checked, so each is refused.
# Path:     resolved by .claude/hooks/lib/resolve-path.sh (the recipe and the ten spellings it closes are in its
#           header; context-builder-kit#60). Registered as ${CLAUDE_PROJECT_DIR}/.claude/hooks/… — "Handlers run in
#           the current directory" (https://code.claude.com/docs/en/hooks, read 2026-09-30), so a bare relative
#           path would not resolve from a subdirectory.
# Not seen: a write through the Bash tool (the matcher is Edit|Write|MultiEdit), a case-insensitive filesystem, a
#           hand edit, and a symlink swapped between this check and the write. CI's ADR immutability job
#           (.github/workflows/adr-immutability-check.yml) refuses any of them that reaches a PR.
# Tier:     HARD-DENY (see the registry comment in .claude/settings.json).
# Depends:  jq (the payload) — absent, the guard fails open: exit 0 with a warning, shown as a systemMessage, naming CI's ADR
#           immutability job as the backstop. The sourced helper .claude/hooks/lib/resolve-path.sh — absent, the
#           same fail-open and the same backstop. readlink (a symlink's target) — absent, a path through a symlink
#           is refused. Nothing else: the device-and-inode check is bash's own `-ef`.
#
# Hook receives JSON on stdin with the tool input. Exit 2 + stderr blocks. Fixture:
# .claude/workflows/tests/protected-paths-hook-fixture.sh.

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
# Deliberately NOT `set -e`: on an environment defect an abort exits non-2, which the hook
# contract reads as NON-blocking — the ADR edit would go through with a cryptic error. Warn and
# fall open instead, naming the backstop.

if ! command -v jq &>/dev/null; then
  fail_open "protect-immutable-adrs: WARNING — jq not installed; ADR-immutability protection DISABLED." \
    "                        Install jq to re-enable. Backstop: CI's ADR immutability job (.github/workflows/adr-immutability-check.yml) still refuses the change at PR time."
fi

case "${BASH_SOURCE[0]}" in */*) here=${BASH_SOURCE[0]%/*} ;; *) here=. ;; esac
if [ ! -r "$here/lib/resolve-path.sh" ]; then
  fail_open "protect-immutable-adrs: WARNING — its path helper $here/lib/resolve-path.sh is missing; ADR-immutability protection DISABLED." \
    "                        Backstop: CI's ADR immutability job (.github/workflows/adr-immutability-check.yml) still refuses the change at PR time."
fi
# shellcheck source=lib/resolve-path.sh
. "$here/lib/resolve-path.sh"

# deny <why> <detail>: the one refusal, with the ADR's standing explanation.
deny() {
  cat >&2 <<EOF
BLOCKED: ${1:+$1 }ADRs are immutable (per ADR-0000).
$2

To change a decision, write a NEW ADR with the next number that supersedes
this one. Add 'Supersedes: ADR-NNNN' to the new ADR's frontmatter and update
the old one's status only via that new ADR's existence (do not edit the old
file's status field directly — the README index expresses supersession).

A wrong citation, figure, attribution or formula is not a decision revision:
record it as an entry in docs/adr/corrections.md (append-only) and leave this
file as written.
EOF
  exit 2
}

# This hook is registered for Edit|Write|MultiEdit only, so a payload it cannot read is still one of those — and
# its path cannot be checked, so it is refused rather than allowed.
rp_payload "$input" || deny "the tool payload could not be read (not parseable JSON, not an object, or a field that is not a string), so its path cannot be checked." \
  "(A lone UTF-16 surrogate escape in the tool input does this — jq refuses it. Remove it and retry.)"

case "$RP_TOOL" in
  Edit|Write|MultiEdit) ;;
  *) exit 0 ;;
esac
[[ -z "$RP_FILE" ]] && exit 0

rp_target "$RP_FILE" "$RP_CWD"
[ -z "$RP_THROUGH_PROC" ] || deny "the path goes through /proc ($RP_THROUGH_PROC), whose links resolve per process." \
  "File: $RP_FILE — this hook cannot see where the writer's /proc/self would land, so an edit through /proc is refused."
[ -z "$RP_UNREADABLE" ] || deny "a symlink on the path could not be read ($RP_UNREADABLE), so the path cannot be checked." \
  "File: $RP_FILE — is readlink installed?"

# An existing numbered ADR directly under docs/adr/, under either reading of the path, in any checkout.
adr_re='(^|/)docs/adr/[0-9]{4}-[^/]*\.md$'
for t in "$RP_T_LEXICAL" "$RP_T_PHYSICAL"; do
  if [[ "$t" =~ $adr_re ]] && [ -f "$t" ]; then
    deny "" "File: $RP_FILE
Resolves to: $t"
  fi
done

# The same ADR under another name — a hardlink to an ADR file, or a bind mount of docs/adr/ itself — in the hook's
# own checkout, the project dir's, or the linked worktree of either that the target lives in: another path, the
# same device and inode.
rp_roots "${BASH_SOURCE[0]}"
roots=("${RP_ROOTS[@]}")
rp_linked_worktree "$RP_T_PHYSICAL"
[ -z "$RP_WT" ] || roots+=("$RP_WT")
rp_nearest_dir "$RP_T_PHYSICAL"
base=${RP_T_PHYSICAL##*/}
file=''
[ -f "$RP_T_PHYSICAL" ] && file=$RP_T_PHYSICAL
for root in "${roots[@]}"; do
  adrs="${root%/}/docs/adr"
  [ -d "$adrs" ] || continue
  RP_HIT=''
  rp_same_entry "$adrs" "$RP_DIR" "$file" '[0-9][0-9][0-9][0-9]-*.md' || continue
  if [ -d "$RP_HIT" ]; then
    # docs/adr/ itself by another name: only an EXISTING numbered ADR is refused — a new one may still be created.
    { [[ "/docs/adr/$base" =~ $adr_re ]] && [ -f "$RP_DIR/$base" ]; } || continue
    deny "" "File: $RP_FILE
Its directory is $adrs by another name (same device and inode — a bind mount?)."
  fi
  deny "" "File: $RP_FILE
It is the ADR $RP_HIT by another name (same device and inode — a hardlink?)."
done

exit 0
