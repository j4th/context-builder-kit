#!/usr/bin/env bash
# Fixture for the path guard that sources .claude/hooks/lib/resolve-path.sh — protect-immutable-adrs.sh, which
# denies an existing docs/adr/NNNN-*.md in ANY checkout — and for the helper's root-scoped functions, driven through
# a corpus guard the fixture writes for itself (the kit ships no corpus guard; a target with a frozen corpus writes
# its own on this helper). Deny cases are the spellings context-builder-kit#60 measured against the ADR hook: a `..`
# segment, `.` and a doubled slash, a trailing-slash project dir, a relative path from a subdirectory, a symlinked
# directory, a symlink to the file, a hardlink, a path through /proc, an unparseable payload (a lone UTF-16
# surrogate), and a project dir pointing at another checkout — plus the control, a project root containing a space,
# and a hardlink inside a linked worktree. Allow cases are the neighbours a looser match catches. The hooks run from
# a copy of the checkout's layout (.claude/hooks + lib) inside throwaway `git init` trees; the real checkout is never
# touched and the launch directory never matters. Only exit 2 denies, so every case asserts the exact exit. The
# guard's fail-open branches — no lib/ helper, and no jq on PATH — exit 0 and name the surviving backstop.
# Needs bash, git, jq, readlink (GNU or BSD). Four cases need more and print a SKIP line where the host lacks it:
# the /proc case needs /proc/self/root, and the three bind-mount cases need `unshare -rm` (an unprivileged user and
# mount namespace). Run by the verification block; also: bash .claude/workflows/tests/protected-paths-hook-fixture.sh
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
src="$here/../../hooks"
ADR=protect-immutable-adrs.sh; CORPUS=corpus-double.sh
[ -f "$src/$ADR" ] || { echo "protected-paths-hook-fixture: $src/$ADR is missing"; exit 1; }
command -v jq >/dev/null && command -v git >/dev/null || { echo "protected-paths-hook-fixture: needs jq and git"; exit 1; }
t=$(mktemp -d)
cleanup() { chmod -R u+rwX "$t" 2>/dev/null || true; rm -rf "$t"; }
trap cleanup EXIT

install_hooks() {  # install_hooks <checkout root>: the guard where settings.json registers it, lib beside it
  mkdir -p "$1/.claude/hooks"
  cp "$src/$ADR" "$1/.claude/hooks/"
  if [ -d "$src/lib" ]; then cp -R "$src/lib" "$1/.claude/hooks/"; fi  # absent, the deny cases below go red
  cat > "$1/.claude/hooks/$CORPUS" <<'EOF'
#!/usr/bin/env bash
# The fixture's root-scoped guard over docs/corpus/ — anything under it, additions too, in the hook's own checkout,
# the project dir's, or a linked worktree of either — in the shape a target's frozen-corpus guard takes.
set -uo pipefail
input="$(cat)"
here=${BASH_SOURCE[0]%/*}
. "$here/lib/resolve-path.sh"
deny() { echo "BLOCKED: $1" >&2; exit 2; }
rp_payload "$input" || deny "the payload could not be read"
case "$RP_TOOL" in Edit|Write|MultiEdit) ;; *) exit 0 ;; esac
[ -n "$RP_FILE" ] || exit 0
rp_target "$RP_FILE" "$RP_CWD"
[ -z "$RP_THROUGH_PROC" ] || deny "a path through /proc"
[ -z "$RP_UNREADABLE" ] || deny "an unreadable symlink"
rp_roots "${BASH_SOURCE[0]}"
roots=("${RP_ROOTS[@]}")
for t in "$RP_T_LEXICAL" "$RP_T_PHYSICAL"; do rp_linked_worktree "$t"; [ -z "$RP_WT" ] || roots+=("$RP_WT"); done
for root in "${roots[@]}"; do
  c="${root%/}/docs/corpus"
  for t in "$RP_T_LEXICAL" "$RP_T_PHYSICAL"; do case "$t" in "$c"|"$c/"*) deny "$t is in the corpus" ;; esac; done
done
rp_nearest_dir "$RP_T_PHYSICAL"
file=''; [ -f "$RP_T_PHYSICAL" ] && file=$RP_T_PHYSICAL
for root in "${roots[@]}"; do
  c="${root%/}/docs/corpus"; [ -d "$c" ] || continue
  RP_HIT=''; if rp_same_entry "$c" "$RP_DIR" "$file"; then deny "$RP_FILE is $RP_HIT by another name"; fi
done
exit 0
EOF
  chmod +x "$1/.claude/hooks/$ADR" "$1/.claude/hooks/$CORPUS"
}
make_root() {  # make_root <dir>: a committed checkout shaped like a target
  mkdir -p "$1/docs/adr/sub" "$1/docs/adr-old" "$1/docs/corpus" "$1/docs/sub"
  for f in 0001-x.md README.md template.md corrections.md sub/0001-x.md; do printf '# %s\n' "$f" > "$1/docs/adr/$f"; done
  printf 'old\n' > "$1/docs/adr-old/0001-x.md"
  printf 'frozen\n' > "$1/docs/corpus/00-overview.md"
  printf 'notes\n' > "$1/docs/corpus-notes.md"
  git -c init.defaultBranch=main init -q "$1"
  git -C "$1" add -A; git -C "$1" -c user.email=f@x -c user.name=f -c commit.gpgsign=false commit -q -m base
  install_hooks "$1"
}
root="$t/repo"; other="$t/other"; spaced="$t/a b/repo"
make_root "$root"; make_root "$other"; make_root "$spaced"
git -C "$root" worktree add -q --detach "$root/.claude/worktrees/wt" HEAD
git -C "$root" worktree add -q --detach "$t/wt-outside" HEAD
ln -s docs/adr "$root/adr-link"; ln -s docs/adr/0001-x.md "$root/adr-file-link.md"
ln -s docs/corpus "$root/corpus-link"; ln -s docs/corpus/00-overview.md "$root/corpus-file-link.md"
ln "$root/docs/adr/0001-x.md" "$root/adr-hard.md"; ln "$root/docs/corpus/00-overview.md" "$root/corpus-hard.md"
ln "$t/wt-outside/docs/adr/0001-x.md" "$t/wt-outside/notes-hard.md"
ln -s loop-b "$root/loop-a"; ln -s loop-a "$root/loop-b"
A="$root/docs/adr/0001-x.md"; C="$root/docs/corpus/00-overview.md"
# One spelling each that only ONE of the two path readings catches, so neither reading can be dropped unnoticed: a
# symlink to a directory outside the checkout, then `..` (only the lexical reading lands on the ADR); a symlink into
# another checkout's docs/adr, then `../adr` (only the physical reading does).
mkdir -p "$t/outside/deep"; ln -s "$t/outside/deep" "$root/out-link"; ln -s "$other/docs/adr" "$root/other-adr-link"

n=0
fail() { echo "FAIL [$1]: $2"; sed 's/^/  stderr: /' "$t/err"; exit 1; }
# probe <want> <description> <hook> <hook root> <cwd> <project dir or -> <tool> <file_path>
probe() {
  local want=$1 desc=$2 hook=$3 hroot=$4 cwd=$5 pd=$6 tool=$7 fp=$8 rc=0 payload
  payload=$(jq -cn --arg tool "$tool" --arg fp "$fp" --arg cwd "$cwd" '{tool_name: $tool, tool_input: {file_path: $fp}, cwd: $cwd}')
  if [ "$pd" = - ]; then
    (cd "$cwd" && printf '%s' "$payload" | env -u CLAUDE_PROJECT_DIR "$hroot/.claude/hooks/$hook") >/dev/null 2>"$t/err" || rc=$?
  else
    (cd "$cwd" && printf '%s' "$payload" | env CLAUDE_PROJECT_DIR="$pd" "$hroot/.claude/hooks/$hook") >/dev/null 2>"$t/err" || rc=$?
  fi
  n=$((n + 1))
  [ "$rc" -eq "$want" ] || fail "$hook" "$desc (want exit $want, got $rc)"
}
raw() {  # raw <want> <description> <hook> <raw payload>: the payload byte for byte
  local rc=0
  (cd "$root" && printf '%s' "$4" | env CLAUDE_PROJECT_DIR="$root" "$root/.claude/hooks/$3") >/dev/null 2>"$t/err" || rc=$?
  n=$((n + 1))
  [ "$rc" -eq "$1" ] || fail "$3" "$2 (want exit $1, got $rc)"
}

# ── protect-immutable-adrs.sh: deny every spelling of an existing numbered ADR ──
probe 2 "control: the absolute path"                          $ADR "$root" "$root" "$root" Edit "$A"
probe 2 "Write to an existing ADR"                             $ADR "$root" "$root" "$root" Write "$A"
probe 2 "MultiEdit on an existing ADR"                         $ADR "$root" "$root" "$root" MultiEdit "$A"
probe 2 "a .. segment (docs/sub/../adr/)"                      $ADR "$root" "$root" "$root" Edit "$root/docs/sub/../adr/0001-x.md"
probe 2 "a . segment and a doubled slash"                      $ADR "$root" "$root" "$root" Edit "$root/docs/./adr//0001-x.md"
probe 2 "CLAUDE_PROJECT_DIR with a trailing slash"             $ADR "$root" "$root" "$root/" Edit "$A"
probe 2 "a relative path from a subdirectory"                  $ADR "$root" "$root/docs/sub" "$root" Edit "../adr/0001-x.md"
probe 2 "a symlinked directory into docs/adr"                  $ADR "$root" "$root" "$root" Edit "$root/adr-link/0001-x.md"
probe 2 "a symlink to the ADR file"                            $ADR "$root" "$root" "$root" Edit "$root/adr-file-link.md"
probe 2 "a hardlink to the ADR file"                           $ADR "$root" "$root" "$root" Edit "$root/adr-hard.md"
if [ -e /proc/self/root ]; then
  probe 2 "a path through /proc/self/root"                     $ADR "$root" "$root" "$root" Edit "/proc/self/root$A"
else
  echo "SKIP: a path through /proc/self/root (/proc unavailable)"
fi
raw 2 "a lone UTF-16 surrogate makes the payload unparseable, and that is refused" $ADR \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$A\",\"content\":\"x\\ud800y\"},\"cwd\":\"$root\"}"
raw 2 "a file_path that is an object cannot be read, and is refused" $ADR '{"tool_name":"Edit","tool_input":{"file_path":{"x":1}}}'
probe 2 "CLAUDE_PROJECT_DIR set to another checkout"           $ADR "$root" "$root" "$other" Edit "$A"
probe 2 "CLAUDE_PROJECT_DIR unset, launched from a subdirectory" $ADR "$root" "$root/docs/sub" - Edit "$A"
probe 2 "another checkout's existing ADR (every target's ADRs are immutable)" $ADR "$root" "$root" "$root" Edit "$other/docs/adr/0001-x.md"
probe 2 "an existing ADR in a linked worktree"                 $ADR "$root" "$root" "$root" Edit "$t/wt-outside/docs/adr/0001-x.md"
probe 2 "a hardlink inside a linked worktree to that worktree's ADR" $ADR "$root" "$root" "$root" Edit "$t/wt-outside/notes-hard.md"
probe 2 "an outside symlink, then .. (the lexical reading)"     $ADR "$root" "$root" "$root" Edit "$root/out-link/../docs/adr/0001-x.md"
probe 2 "a symlink into another checkout, then ../adr (the physical reading)" $ADR "$root" "$root" "$root" Edit "$root/other-adr-link/../adr/0001-x.md"
probe 2 "a project root containing a space"                   $ADR "$spaced" "$spaced" "$spaced" Edit "$spaced/docs/adr/0001-x.md"
probe 2 "a relative path under a project root containing a space" $ADR "$spaced" "$spaced/docs/sub" "$spaced" Edit "../adr/0001-x.md"
rc=0; (cd "$root" && jq -cn --arg fp "$root/adr-hard.md" --arg cwd "$root" '{tool_name:"Edit",tool_input:{file_path:$fp},cwd:$cwd}' \
  | env -u CLAUDE_PROJECT_DIR .claude/hooks/$ADR) >/dev/null 2>"$t/err" || rc=$?
n=$((n + 1)); [ "$rc" -eq 2 ] || fail $ADR "a hardlink, with the hook launched by a relative path (want exit 2, got $rc)"
# ── protect-immutable-adrs.sh: allow the neighbours ──
probe 0 "a new ADR"                                            $ADR "$root" "$root" "$root" Write "$root/docs/adr/0099-new.md"
probe 0 "the README index"                                     $ADR "$root" "$root" "$root" Edit "$root/docs/adr/README.md"
probe 0 "the template"                                         $ADR "$root" "$root" "$root" Edit "$root/docs/adr/template.md"
probe 0 "the corrections register"                             $ADR "$root" "$root" "$root" Edit "$root/docs/adr/corrections.md"
probe 0 "a sibling directory sharing the prefix (docs/adr-old/)" $ADR "$root" "$root" "$root" Edit "$root/docs/adr-old/0001-x.md"
probe 0 "a nested file under docs/adr/sub/"                    $ADR "$root" "$root" "$root" Edit "$root/docs/adr/sub/0001-x.md"
probe 0 "a symlink loop ends, and is not an ADR"               $ADR "$root" "$root" "$root" Edit "$root/loop-a/x.md"
probe 0 "a Read of an ADR"                                     $ADR "$root" "$root" "$root" Read "$A"
probe 0 "a payload with no file_path"                          $ADR "$root" "$root" "$root" Edit ""
probe 0 "a path read exactly: an ADR name plus a trailing newline is another file" $ADR "$root" "$root" "$root" Write "$A"$'\n'

# ── the helper's root-scoped functions, through the fixture's corpus guard ──
probe 2 "corpus: control, the absolute path"                   $CORPUS "$root" "$root" "$root" Edit "$C"
probe 2 "corpus: a new file (additions are frozen too)"        $CORPUS "$root" "$root" "$root" Write "$root/docs/corpus/09-new.md"
probe 2 "corpus: a .. segment"                                 $CORPUS "$root" "$root" "$root" Edit "$root/docs/adr/../corpus/00-overview.md"
probe 2 "corpus: a symlinked directory"                        $CORPUS "$root" "$root" "$root" Write "$root/corpus-link/new.md"
probe 2 "corpus: a symlink to a corpus file"                   $CORPUS "$root" "$root" "$root" Edit "$root/corpus-file-link.md"
probe 2 "corpus: a hardlink to a corpus file"                  $CORPUS "$root" "$root" "$root" Edit "$root/corpus-hard.md"
probe 2 "corpus: a project dir pointing elsewhere (the hook's own checkout is guarded)" $CORPUS "$root" "$root" "$other" Edit "$C"
probe 2 "corpus: a linked worktree inside the checkout"        $CORPUS "$root" "$root" "$root" Edit "$root/.claude/worktrees/wt/docs/corpus/00-overview.md"
probe 2 "corpus: a linked worktree outside the checkout"       $CORPUS "$root" "$root" "$root" Write "$t/wt-outside/docs/corpus/new.md"
probe 0 "corpus: another repository's corpus is not this project's" $CORPUS "$root" "$root" "$root" Edit "$other/docs/corpus/00-overview.md"
probe 0 "corpus: a sibling that shares the name as a prefix"   $CORPUS "$root" "$root" "$root" Edit "$root/docs/corpus-notes.md"
probe 0 "corpus: a symlink loop ends, and is not the corpus"   $CORPUS "$root" "$root" "$root" Edit "$root/loop-a/x.md"

# ── a bind mount of the guarded directory (same device and inode, another path) — needs a user and mount namespace ──
if unshare -rm true 2>/dev/null; then
  mkdir -p "$t/alias-adr" "$t/alias-corpus"
  bind() {  # bind <want> <description> <hook> <guarded dir> <alias> <file_path>
    local rc=0
    unshare -rm bash -c 'mount --bind "$1" "$2" && cd "$3" && jq -cn --arg fp "$4" --arg cwd "$3" "{tool_name:\"Write\",tool_input:{file_path:\$fp},cwd:\$cwd}" | CLAUDE_PROJECT_DIR="$3" "$3/.claude/hooks/$5"' \
      _ "$4" "$5" "$root" "$6" "$3" >/dev/null 2>"$t/err" || rc=$?
    n=$((n + 1))
    [ "$rc" -eq "$1" ] || fail "$3" "$2 (want exit $1, got $rc)"
  }
  bind 2 "an existing ADR through a bind mount of docs/adr"    $ADR "$root/docs/adr" "$t/alias-adr" "$t/alias-adr/0001-x.md"
  bind 0 "a new ADR through a bind mount of docs/adr"          $ADR "$root/docs/adr" "$t/alias-adr" "$t/alias-adr/0099-new.md"
  bind 2 "corpus: a new file through a bind mount of the corpus" $CORPUS "$root/docs/corpus" "$t/alias-corpus" "$t/alias-corpus/new.md"
else
  echo "SKIP: three bind-mount cases (unshare -rm unavailable: no unprivileged user and mount namespace)"
fi

# ── a copy without its lib/ helper fails open, and says which backstop still stands ──
solo="$t/solo"; mkdir -p "$solo/.claude/hooks"; cp "$src/$ADR" "$solo/.claude/hooks/"; chmod +x "$solo/.claude/hooks/$ADR"
rc=0; (cd "$root" && jq -cn --arg fp "$A" '{tool_name:"Edit",tool_input:{file_path:$fp}}' | env CLAUDE_PROJECT_DIR="$root" "$solo/.claude/hooks/$ADR") >"$t/out" 2>"$t/err" || rc=$?
n=$((n + 1))
[ "$rc" -eq 0 ] || fail $ADR "a copy without lib/ must fail open (want exit 0, got $rc)"
{ grep -q 'helper' "$t/err" && grep -q 'Backstop' "$t/err" && grep -q 'adr-immutability-check.yml' "$t/err"; } || fail $ADR "the missing-helper warning must name the helper and the backstop's workflow"
# On exit 0 stderr reaches only the debug log, so the warning must also be the systemMessage on stdout.
jq -e '.systemMessage | contains("adr-immutability-check.yml")' "$t/out" >/dev/null 2>&1 || fail $ADR "the missing-helper warning is not shown to the user (no systemMessage on stdout)"
# ── with no jq on PATH the guard fails open, and says which backstop still stands (a PATH holding only what the
#    guard runs before its jq check) ──
nojq="$t/nojq"; mkdir -p "$nojq"
for tool in bash cat readlink; do p=$(type -P "$tool" || true); [ -n "$p" ] && ln -sf "$p" "$nojq/$tool"; done
rc=0; (cd "$root" && jq -cn --arg fp "$A" '{tool_name:"Edit",tool_input:{file_path:$fp}}' > "$t/pay-nojq" && env -i PATH="$nojq" HOME="$HOME" CLAUDE_PROJECT_DIR="$root" bash "$src/$ADR" < "$t/pay-nojq") >"$t/out" 2>"$t/err" || rc=$?
n=$((n + 1))
[ "$rc" -eq 0 ] || fail $ADR "with no jq the guard must fail open (want exit 0, got $rc)"
{ grep -q 'jq not installed' "$t/err" && grep -q 'Backstop' "$t/err"; } || fail $ADR "the no-jq warning must say jq is missing and name the backstop"
jq -e '.systemMessage | contains("jq not installed")' "$t/out" >/dev/null 2>&1 || fail $ADR "the no-jq warning is not shown to the user (no systemMessage on stdout)"
echo "protected-paths-hook-fixture: $n cases ok"
