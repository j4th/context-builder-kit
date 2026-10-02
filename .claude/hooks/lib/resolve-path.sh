# shellcheck shell=bash
# Sourced by a path guard after it drains stdin — protect-immutable-adrs.sh in the kit, and a target's own guard
# over a frozen corpus (the consultation skill's references/frozen_corpus_ingestion.md § The enforcement set).
# Never run, never reads stdin, defines functions only: no top-level statement runs on source. It answers one
# question the guards share: where does an Edit/Write/MultiEdit's `file_path` really land?
#
# Why a resolver: a prefix or suffix match on the payload's path string is bypassed by every spelling that names
# the same file differently. context-builder-kit#60 measured ten against the ADR hook — a `..` segment, `.` and
# `//`, a trailing-slash CLAUDE_PROJECT_DIR, a relative path, a symlinked directory, a symlink to the file, a
# hardlink, /proc/self/root, an unparseable payload, a project dir pointing elsewhere — and a suffix match closes
# three of them. Taking the root from the file's own checkout (`git -C "$(dirname "$file")" rev-parse
# --show-toplevel`) closes none: git fails for a new file in a directory that does not exist yet, and the root it
# finds follows no symlink, hardlink or /proc link. The recipe, which closes all ten:
#   - the payload is read exactly, in one jq process (@sh-quoted, so a trailing newline survives), and a payload
#     jq cannot read is reported for the guard to refuse;
#   - the path is resolved two ways — lexically, collapsing `..` as a writer that normalizes the path would, and
#     physically, one component at a time through symlinks, `..` taken from the physical parent — and a guard
#     denies when either reading lands in its tree; an unreadable symlink and any path through /proc (whose magic
#     links resolve per process, so a readlink run here is not the writer) are flagged for the guard to refuse;
#   - the roots are the calling hook's own checkout, derived LEXICALLY from the hook's path (a symlinked
#     .claude/hooks must not move it), and CLAUDE_PROJECT_DIR; a linked worktree of either (its `.git` file's
#     gitdir resolves under the root's .git/worktrees/) is found on demand, in pure bash;
#   - the same file or directory under another name (a hardlink, a bind mount) is caught with bash's own `-ef`
#     over a glob walk: no stat or find, so no missing tool can switch the check off.
# Bash 3.2-safe (no mapfile, no associative arrays, no ${x,,}); pure bash plus jq and readlink. The contract a
# sourcing hook keeps is cbk-conventions-reference.md § Hook authoring (sourced helpers). Fixture:
# .claude/workflows/tests/protected-paths-hook-fixture.sh, which also drives the root-scoped functions through a
# corpus guard of its own.

# rp_payload <payload>: RP_TOOL, RP_FILE and RP_CWD from the hook payload, read exactly, in ONE jq process. jq's
# @sh single-quotes each value, so a trailing newline in a path survives the command substitution, and eval
# assigns the three at once. Returns 1 when jq cannot read the payload — not parseable (jq refuses a lone UTF-16
# surrogate escape anywhere in the input), empty (`-e` fails when jq prints nothing), not an object, or a field that
# is not a string or null — @sh would split an array into one word per element and eval would run them as a
# command — and the caller refuses.
rp_payload() {
  local fields
  fields=$(jq -er 'def s: if . == null then "" elif type == "string" then . else error("a field is not a string") end; if type == "object" then @sh "RP_TOOL=\(.tool_name | s) RP_FILE=\(.tool_input.file_path | s) RP_CWD=\(.cwd | s)" else error("not an object") end' <<<"$1" 2>/dev/null) || return 1
  eval "$fields"
}

# rp_lexnorm <path> <base>: <path> made absolute against <base>, with `.`, empty components and `..` collapsed
# LEXICALLY. Result in RP_LEX.
rp_lexnorm() {
  local rest=$1 out='' part
  [[ "$rest" == /* ]] || rest="$2/$rest"
  while [ -n "$rest" ]; do
    case "$rest" in */*) part=${rest%%/*}; rest=${rest#*/} ;; *) part=$rest; rest='' ;; esac
    case "$part" in
      ''|.) ;;
      ..) out=${out%/*} ;;
      *) out="$out/$part" ;;
    esac
  done
  RP_LEX=${out:-/}
}

# rp_canon <path> <base>: the physical path the kernel would open, component by component — every symlink followed
# where it is met (its exact text: a target may end in a newline), `..` from the PHYSICAL parent, components that
# do not exist kept as given. Result in RP_CANON. Flags, never guesses: RP_THROUGH_PROC (a path through /proc) and
# RP_UNREADABLE (a symlink it could not read). After 40 symlink hops the rest of the path is taken as given, so a
# symlink loop ends.
rp_canon() {
  local rest=$1 phys=/ part cand link hops=0
  [[ "$rest" == /* ]] || rest="$2/$rest"
  while [ -n "$rest" ]; do
    case "$rest" in */*) part=${rest%%/*}; rest=${rest#*/} ;; *) part=$rest; rest='' ;; esac
    case "$part" in
      ''|.) ;;
      ..) phys=${phys%/*}; [ -n "$phys" ] || phys=/ ;;
      *)
        if [ "$phys" = / ]; then cand="/$part"; else cand="$phys/$part"; fi
        case "$cand" in /proc|/proc/*) RP_THROUGH_PROC=$cand ;; esac
        if [ -L "$cand" ] && [ "$hops" -lt 40 ]; then
          hops=$((hops + 1))
          link=$(readlink -- "$cand" 2>/dev/null && printf x)
          case "$link" in
            *x) link=${link%x}; link=${link%$'\n'} ;;
            *) RP_UNREADABLE=$cand; phys=$cand; continue ;;
          esac
          [[ "$link" == /* ]] && phys=/
          rest="$link/$rest"
        else
          phys=$cand
        fi
        ;;
    esac
  done
  RP_CANON=$phys
}

# rp_target <file_path> <cwd>: RP_T_LEXICAL and RP_T_PHYSICAL — the target under both readings of `..` (lexical,
# as a writer that normalizes the path resolves it; physical, as the kernel resolves a raw path), a relative path
# resolved against the payload's cwd. Clears, then sets, RP_THROUGH_PROC and RP_UNREADABLE.
rp_target() {
  local base=${2:-$PWD}
  [[ "$base" == /* ]] || base="$PWD/$base"
  RP_THROUGH_PROC='' RP_UNREADABLE=''
  rp_lexnorm "$1" "$base"; rp_canon "$RP_LEX" /; RP_T_LEXICAL=$RP_CANON
  rp_canon "$1" "$base"; RP_T_PHYSICAL=$RP_CANON
}

# rp_roots <calling hook's path>: RP_ROOTS — the hook's own checkout (the hook is <root>/.claude/hooks/<name>.sh,
# taken lexically, then resolved physically like the target) and CLAUDE_PROJECT_DIR when it is set and names
# another directory, so a worktree session's hook also guards the checkout the session belongs to.
rp_roots() {
  local r
  rp_lexnorm "$1" "$PWD"
  r=${RP_LEX%/*}; r=${r%/*}; r=${r%/*}
  rp_canon "${r:-/}" /
  RP_ROOTS=("$RP_CANON")
  if [ -n "${CLAUDE_PROJECT_DIR:-}" ]; then
    rp_canon "$CLAUDE_PROJECT_DIR" "$PWD"
    # In an ordinary session the project dir IS the hook's checkout: one root, so no walk runs twice.
    [ "$RP_CANON" -ef "${RP_ROOTS[0]}" ] || RP_ROOTS+=("$RP_CANON")
  fi
}

# rp_linked_worktree <physical path>: RP_WT — the root of the checkout the path lives in when that checkout is a
# linked worktree of a root in RP_ROOTS (its `.git` is a file whose `gitdir:` resolves under
# <root>/.git/worktrees/), else empty. Pure bash: the `.git` file is read with the `read` builtin; no git runs.
rp_linked_worktree() {
  local d=$1 line gd r
  RP_WT=''
  while [ -n "$d" ] && [ "$d" != / ] && [ ! -d "$d" ]; do d=${d%/*}; done
  [ -n "$d" ] || d=/
  while :; do
    if [ -f "$d/.git" ]; then
      line=''
      IFS= read -r line < "$d/.git" || true
      case "$line" in "gitdir: "*) gd=${line#gitdir: } ;; *) return 0 ;; esac
      [[ "$gd" == /* ]] || gd="$d/$gd"
      rp_canon "$gd" /
      for r in "${RP_ROOTS[@]}"; do
        case "$RP_CANON" in "${r%/}/.git/worktrees/"*) RP_WT=$d; return 0 ;; esac
      done
      return 0
    fi
    [ -d "$d/.git" ] && return 0
    [ "$d" = / ] && return 0
    d=${d%/*}; [ -n "$d" ] || d=/
  done
}

# rp_nearest_dir <path>: RP_DIR — the path itself if it is a directory, else its nearest existing ancestor.
rp_nearest_dir() {
  RP_DIR=$1
  while [ ! -d "$RP_DIR" ]; do RP_DIR=${RP_DIR%/*}; [ -n "$RP_DIR" ] || RP_DIR=/; done
}

# rp_same_entry <guarded dir> <target dir> <target file, or empty> [<file glob>]: returns 0 and sets RP_HIT when
# <target file> is one of the guarded files (a hardlink) or <target dir> is the guarded dir under another name (a
# bind mount) — same device and inode, by bash's `-ef`, over a walk in bash globs. Without a glob the whole tree is
# guarded: every file, and every subdirectory as a directory too (a corpus). With one, only the files that glob
# names directly under the guarded dir, and the dir itself, with no recursion (the numbered ADRs); the files are
# compared first, so a hardlink is caught whatever directory it is reached through.
rp_same_entry() {
  local e
  if [ -n "${4:-}" ]; then
    if [ -n "$3" ]; then
      for e in "$1"/$4; do  # $4 unquoted on purpose: it is the glob
        if [ -f "$e" ] && [ ! -L "$e" ] && [ "$e" -ef "$3" ]; then RP_HIT=$e; return 0; fi
      done
    fi
    if [ "$1" -ef "$2" ]; then RP_HIT=$1; return 0; fi
    return 1
  fi
  if [ "$1" -ef "$2" ]; then RP_HIT=$1; return 0; fi
  for e in "$1"/* "$1"/.[!.]* "$1"/..?*; do
    if [ -d "$e" ] && [ ! -L "$e" ]; then
      rp_same_entry "$e" "$2" "$3" && return 0
    elif [ -n "$3" ] && [ -f "$e" ] && [ ! -L "$e" ] && [ "$e" -ef "$3" ]; then
      RP_HIT=$e; return 0
    fi
  done
  return 1
}
