# Harvest 5 — V1: The block as a gate

**Scope.** This cluster makes the verification block a gate that cannot pass on nothing, and wires it into
every target's `check`. It closes the trace rows `#73/body/1`, `#73/body/2` (the block's half; the hook's
half is V2's), `#58/c5901493591/R4`, `#58/c5901493591/R5` and `critic/22`. It implements D51 (the block as a
gate), D50 (a non-failing warning above 140,000 always-loaded bytes) and D52's clause for the kit's own
`verify.yml`. It also lands two things the gate cannot be true without. The first is the scaffold
disposition row for `cbk-conventions-reference.md`'s manifest-and-lockfile glob: the spec's settled call under
**Gate**, and the same defect as V9's unverified review row `review/portability/68`. The second is a repair the
planning dry run found. A freshly scaffolded target has no `CLAUDE.md` until blueprint writes it, and the kit
sub-block's `CLAUDE.md` check is red there before the glob check is ever reached; the check now keys on
`docs/cbk/blueprint.md` in a target. V1 runs first and consumes nothing from earlier clusters. Every later
cluster's commit is gated by the runner this cluster strengthens. Review Focus 4 (a freshly scaffolded
target) is pinned in Task V1.4.

## Before you start

- Work from the repository root on `feat/harvest-5-v1.0.0`. Line numbers below are "at `643f7ff`", for
  orientation only; every edit is an exact-string replacement anchored on text.
- **Replacement format.** "**Replace** in `<path>`" is followed by two fenced blocks, the existing text and its
  replacement. A block marked *(whole lines)* replaces complete lines; *(inline)* replaces a span inside one line.
  Use the Edit tool with the first block as `old_string` and the second as `new_string`. If an anchor is not
  found exactly once, stop and reconcile; never guess.
- The gate after every commit: `bash .claude/workflows/tests/run-verification-block.sh`. It must end with
  `verification: kit sub-block complete` and `verification: done`, and exit 0.
- **Planning dry run.** Every step below was executed on a scratch clone at `643f7ff` on 2026-09-30, in task
  order, and each "Expected" block is the observed output. The red lines go into the PR body's red-first
  table.
- New kit-sub-block checks go immediately before `echo "verification: kit sub-block complete"` (the master
  plan's sentinel rule). The tasks below therefore stack their checks in task order after the budget line.
- No hook is touched in this cluster. `bash -n` runs on the two scripts it edits.

---

### Task V1.1: The runner's third rail and its fixture (#73/body/1, critic/22; D51)

**Files:**
- Create: `.claude/workflows/tests/run-verification-block-fixture.sh` (mode 755)
- Modify: `.claude/workflows/tests/run-verification-block.sh`, the header comment (lines 2–7) and after the
  done-sentinel check (line 20)
- Modify: `.claude/rules/cbk-conventions-reference.md`, § Verification › Run it (line 476) and the kit
  sub-block at its sentinel (line 690)

**Interfaces:**
- Consumes: the runner at `643f7ff` (two rails) and the block's sentinel strings `verification: kit sub-block
  complete`, `verification: project sub-block complete`, `verification: done`.
- Produces: the runner's third rail. When `docs/cbk/scaffold.md` exists and the output lacks the project
  sentinel, it prints `verification: a filled target's project sub-block never completed — …` and exits 1.
- Produces: `.claude/workflows/tests/run-verification-block-fixture.sh`. It prints one `ok: <case>` line per case
  and ends `run-verification-block-fixture: 6 cases ok`; on a failed case it prints `FAIL: <case> (…)` and exits 1.
- Produces: the kit-sub-block line `bash .claude/workflows/tests/run-verification-block-fixture.sh || { echo
  "run-verification-block.sh lost a rail (the fixture names the case)"; exit 1; }`, so the block guards the
  script that runs it.
- Produces: § Verification › Run it says "three fail-loud rails" and names the residual (a deleted or renamed
  scaffold file). Task V1.5 extends the same paragraph.

- [ ] **Step 1: Write the fixture**

**Create** `.claude/workflows/tests/run-verification-block-fixture.sh` with this content, then
`chmod +x .claude/workflows/tests/run-verification-block-fixture.sh`:

````bash
#!/usr/bin/env bash
# Fixture for the verification-block runner (run-verification-block.sh): its fail-loud rails, driven
# against synthetic blocks in throwaway checkouts. The runner is copied in at its real relative path,
# so the runner tested is the runner the gate runs, and the block runs this fixture (the block guards
# the script that runs it).
#   green: a kit tree (no docs/cbk/scaffold.md) that prints `verification: done`; a filled target that
#          prints the project sentinel and `verification: done`.
#   red:   a filled target whose project sub-block never ran (only `verification: done` printed: a guard
#          that stops firing turns every project check off with the gate green, context-builder-kit#73);
#          an empty extraction; an exit 0 without the done sentinel; a block that exits non-zero.
# Not modelled: a deleted or renamed scaffold.md. The rail keys on the same file as the block's guard, so
# such a target looks like the kit's own tree, which owes only the done sentinel.
# Needs bash, git, awk and mktemp (the runner's own set); no network, no jq.
# Run: bash .claude/workflows/tests/run-verification-block-fixture.sh
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
runner="$here/run-verification-block.sh"
[ -f "$runner" ] || { echo "run-verification-block-fixture: the runner is missing ($runner)"; exit 1; }
d=$(mktemp -d)
trap 'rm -rf "$d"' EXIT

n=0
case_() {  # case_ <name> <want exit> <filled target? yes|no> <block body, or NONE for no fence> [text the output must carry]
  local name=$1 want=$2 target=$3 body=$4 says=${5:-}
  local c="$d/c$n"; n=$((n + 1))
  git -c init.defaultBranch=main init -q "$c"
  mkdir -p "$c/.claude/workflows/tests" "$c/.claude/rules"
  cp "$runner" "$c/.claude/workflows/tests/"
  if [ "$target" = yes ]; then mkdir -p "$c/docs/cbk"; : > "$c/docs/cbk/scaffold.md"; fi
  if [ "$body" = NONE ]; then
    printf '## Verification\n\nNo fence here.\n' > "$c/.claude/rules/cbk-conventions-reference.md"
  else
    printf '## Verification\n\n```bash\n%s\n```\n' "$body" > "$c/.claude/rules/cbk-conventions-reference.md"
  fi
  local rc=0 out
  out=$(bash "$c/.claude/workflows/tests/run-verification-block.sh" 2>&1) || rc=$?
  [ "$rc" -eq "$want" ] || { echo "FAIL: $name (want exit $want, got $rc)"; printf '%s\n' "$out" | sed 's/^/  | /'; exit 1; }
  [ -z "$says" ] || grep -qF -- "$says" <<<"$out" || { echo "FAIL: $name (output lacks '$says')"; printf '%s\n' "$out" | sed 's/^/  | /'; exit 1; }
  echo "ok: $name"
}

KIT='echo "verification: kit sub-block complete"'
PROJ='if [ -f docs/cbk/scaffold.md ]; then echo "verification: project sub-block complete"; fi'
SKIPPED='if [ -f docs/cbk/scaffold-moved.md ]; then echo "verification: project sub-block complete"; fi'
DONE='echo "verification: done"'

case_ "a kit tree that prints the done sentinel passes"          0 no  "$KIT
$PROJ
$DONE"
case_ "a filled target that prints both sentinels passes"        0 yes "$KIT
$PROJ
$DONE"
case_ "a filled target whose project sub-block never ran fails"  1 yes "$KIT
$SKIPPED
$DONE" "project sub-block complete"
case_ "an empty extraction fails"                                1 no  NONE "EMPTY EXTRACTION"
case_ "an exit 0 without the done sentinel fails"                1 no  "$KIT" "WITHOUT the done sentinel"
case_ "a block that exits non-zero fails"                        1 yes "$KIT
false
$DONE" "block exited 1"

echo "run-verification-block-fixture: $n cases ok"
````

- [ ] **Step 2: Run it against the unfixed runner — it must fail on the filled-target case**

Run: `bash -n .claude/workflows/tests/run-verification-block-fixture.sh && bash .claude/workflows/tests/run-verification-block-fixture.sh; echo "exit=$?"`

Expected:
```
ok: a kit tree that prints the done sentinel passes
ok: a filled target that prints both sentinels passes
FAIL: a filled target whose project sub-block never ran fails (want exit 1, got 0)
  | verification: kit sub-block complete
  | verification: done
exit=1
```
Record `FAIL: a filled target whose project sub-block never ran fails (want exit 1, got 0)` in the red-first
table.

- [ ] **Step 3: Add the rail, and say "three rails" everywhere the runner is described**

**Replace** in `.claude/workflows/tests/run-verification-block.sh` *(whole lines)*:
````text
# Runs the verification block (cbk-conventions-reference.md § Verification) with two fail-loud
# rails the block cannot carry itself: an EMPTY extraction is red (the heading or the fence
# moved — a plain `bash -e` on an empty file exits 0), and an exit 0 that never printed the
# closing sentinel is red (the block ended early). The kit's CI calls this; a target project
# copies it as the body of the task its check command runs (cbk-conventions-reference.md
# § Verification › Run it). Run from anywhere inside the checkout:
````
with:
````text
# Runs the verification block (cbk-conventions-reference.md § Verification) with three fail-loud
# rails the block cannot carry itself: an EMPTY extraction is red (the heading or the fence
# moved — a plain `bash -e` on an empty file exits 0); an exit 0 that never printed the
# closing sentinel is red (the block ended early); and in a filled target (docs/cbk/scaffold.md
# exists) an exit 0 that never printed the project sentinel is red (the project sub-block was
# skipped). Fixture: run-verification-block-fixture.sh, which the block itself runs. The kit's CI
# calls this; a target project copies it as the body of the task its check command depends on
# (cbk-conventions-reference.md § Verification › Run it). Run from anywhere inside the checkout:
````

**Replace** in `.claude/workflows/tests/run-verification-block.sh` *(whole lines)*:
````text
grep -q '^verification: done$' <<<"$out" || { echo "verification: exit 0 WITHOUT the done sentinel — the block ended early"; exit 1; }
````
with:
````text
grep -q '^verification: done$' <<<"$out" || { echo "verification: exit 0 WITHOUT the done sentinel — the block ended early"; exit 1; }
# A filled target also owes the project sentinel. `verification: done` prints whether or not the project
# sub-block ran, so a guard that stops firing (moved, edited, pointed at another file) would turn every
# project check off with the gate green (context-builder-kit#73). The rail keys on the same file as the
# guard, so a deleted or renamed scaffold.md makes a target look like the kit's own tree, which owes only
# the done sentinel; that case is not caught here.
if [ -f docs/cbk/scaffold.md ]; then
  grep -q '^verification: project sub-block complete$' <<<"$out" \
    || { echo "verification: a filled target's project sub-block never completed — docs/cbk/scaffold.md exists but 'verification: project sub-block complete' was not printed"; exit 1; }
fi
````

**Replace** in `.claude/rules/cbk-conventions-reference.md` *(whole lines; the § Verification › Run it paragraph.
The bare `#58` becomes `context-builder-kit#58` (D53), because this task owns the paragraph)*:
````text
**Run it** through `.claude/workflows/tests/run-verification-block.sh`: it performs the documented extraction and adds two fail-loud rails the block cannot carry for itself — an empty extraction is red (a plain `bash -e` on an empty file exits 0), and an exit 0 that never printed `verification: done` is red. The kit's CI runs it on every pull request; a target wires the same script as the body of a task its check command depends on (a check nobody re-runs is a belief with a date on it — #58, second application, item 7). The block stays fail-fast: every red is fixed, or the check is narrowed in the project's own copy with an inline comment saying why — a "recorded" red cannot reach the sentinels.
````
with:
````text
**Run it** through `.claude/workflows/tests/run-verification-block.sh`: it performs the documented extraction and adds three fail-loud rails the block cannot carry for itself — an empty extraction is red (a plain `bash -e` on an empty file exits 0); an exit 0 that never printed `verification: done` is red; and in a filled target (`docs/cbk/scaffold.md` exists) an exit 0 that never printed `verification: project sub-block complete` is red, because the done sentinel prints whether or not the project sub-block ran. The third rail keys on the same `docs/cbk/scaffold.md` as the project sub-block's guard, so a deleted or renamed scaffold file makes a target look like the kit's own tree, and that is not caught. `run-verification-block-fixture.sh` drives the three rails on synthetic blocks, and the block runs it, so the block guards the script that runs it. The kit's CI runs the runner on every pull request; a target wires the same script as the body of a task its check command depends on (a check nobody re-runs is a belief with a date on it — context-builder-kit#58, second application, item 7). The block stays fail-fast: every red is fixed, or the check is narrowed in the project's own copy with an inline comment saying why — a "recorded" red cannot reach the sentinels.
````

**Replace** in `.claude/rules/cbk-conventions-reference.md` *(whole lines; the kit sub-block's sentinel)*:
````text
echo "verification: kit sub-block complete"
````
with:
````text
# The runner's three rails hold on synthetic blocks, the runner copied into throwaway checkouts at its real
# path (§ Verification › Run it): the block guards the script that runs it.
bash .claude/workflows/tests/run-verification-block-fixture.sh || { echo "run-verification-block.sh lost a rail (the fixture names the case)"; exit 1; }

echo "verification: kit sub-block complete"
````

- [ ] **Step 4: The fixture is green, and the runner runs it inside the block**

Run: `bash -n .claude/workflows/tests/run-verification-block.sh && bash .claude/workflows/tests/run-verification-block-fixture.sh; echo "exit=$?"`

Expected:
```
ok: a kit tree that prints the done sentinel passes
ok: a filled target that prints both sentinels passes
ok: a filled target whose project sub-block never ran fails
ok: an empty extraction fails
ok: an exit 0 without the done sentinel fails
ok: a block that exits non-zero fails
run-verification-block-fixture: 6 cases ok
exit=0
```

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -10; echo "exit=${PIPESTATUS[0]}"`

Expected:
```
always-loaded total: 130628 bytes
ok: a kit tree that prints the done sentinel passes
ok: a filled target that prints both sentinels passes
ok: a filled target whose project sub-block never ran fails
ok: an empty extraction fails
ok: an exit 0 without the done sentinel fails
ok: a block that exits non-zero fails
run-verification-block-fixture: 6 cases ok
verification: kit sub-block complete
verification: done
exit=0
```

Run: `grep -c 'two fail-loud' .claude/rules/cbk-conventions-reference.md .claude/workflows/tests/run-verification-block.sh`
Expected: both counts `0`.

- [ ] **Step 5: Commit**

```bash
git add .claude/workflows/tests/run-verification-block-fixture.sh .claude/workflows/tests/run-verification-block.sh .claude/rules/cbk-conventions-reference.md
git commit -F - <<'EOF'
feat(verification): V1 — the runner's third rail, pinned by a fixture the block runs

A filled target (docs/cbk/scaffold.md exists) now also owes `verification:
project sub-block complete`: the done sentinel prints whether or not the
project sub-block ran, so a guard that stopped firing turned every project
check off with the gate green. run-verification-block-fixture.sh drives the
three rails in six cases on synthetic blocks, and the kit sub-block runs it.
§ Verification › Run it says three rails, names the residual (a deleted or
renamed scaffold.md), and cites context-builder-kit#58 instead of a bare #58.

Trace: #73/body/1, critic/22 (D51).

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

---

### Task V1.2: A Stop hook that could not look is red in the gate (#73/body/2; D51)

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md`, the § Verification preamble (line 474) and the kit
  sub-block's Stop-hook check (lines 636–638)

**Interfaces:**
- Consumes: `detect-forked-agent-memory.sh`'s contract that every could-not-look path (no checkout, an
  unenterable root, a partial scan, an unmonitored walk) exits 0 and prints the literal word `WARNING` on
  stderr. V2 owns the hook, keeps that literal, and pins the partial-scan path in `hook-payloads-fixture.sh`
  (handed out, see § Handed to other clusters).
- Produces: the block function `stop_hook_clean <project dir> [git ceiling]`. It returns 0 only when the
  hook exited 0 with no `WARNING`. Its red messages are `a reviewer-memory tree exists outside the root
  (detect-forked-agent-memory.sh exit N). The hook said:` and `the Stop hook could not look (exit 0 with a
  WARNING). The hook said:`.
- Produces: the in-block negative case. Outside any checkout, under a git ceiling, the check must return 1;
  otherwise the block prints `the Stop-hook check passed a hook that could not look (exit 0 with a WARNING) —
  in a gate that is red`.
- Produces: the preamble sentence "a check that could not look is red".

- [ ] **Step 1: Write the negative case first, around the check's current semantics (exit code only)**

**Replace** in `.claude/rules/cbk-conventions-reference.md` *(whole lines)*:
````text
printf '{"stop_hook_active":false}' | CLAUDE_PROJECT_DIR="$PWD" .claude/hooks/detect-forked-agent-memory.sh || { echo "a reviewer-memory tree exists outside the root (detect-forked-agent-memory.sh blocked; its stderr above names the paths)"; exit 1; }
````
with:
````text
stop_hook_clean() {  # stop_hook_clean <project dir> [git ceiling]: 0 only when the hook looked and found nothing
  local rc=0 err
  err=$(printf '{"stop_hook_active":false}' | CLAUDE_PROJECT_DIR="$1" GIT_CEILING_DIRECTORIES="${2:-${GIT_CEILING_DIRECTORIES:-}}" .claude/hooks/detect-forked-agent-memory.sh 2>&1 >/dev/null) || rc=$?
  [ "$rc" -eq 0 ] || { echo "a reviewer-memory tree exists outside the root (detect-forked-agent-memory.sh exit $rc). The hook said:"; printf '  %s\n' "$err"; return 1; }
}
stop_hook_clean "$PWD" || exit 1
# The check bites on a hook that could not look: outside a checkout the hook exits 0 with a WARNING. The
# ceiling at the temp dir's parent keeps git from finding a checkout above it (a TMPDIR inside a work tree
# would otherwise).
nc=$(mktemp -d); if stop_hook_clean "$nc" "${nc%/*}" >/dev/null; then rmdir "$nc"; echo "the Stop-hook check passed a hook that could not look (exit 0 with a WARNING) — in a gate that is red"; exit 1; fi; rmdir "$nc"
````

The function keeps the two comment lines above it (`# No reviewer-memory tree outside the root — …` and
`# so the exclusion list has one home …`) unchanged. `local rc=0 err` and the `2>&1 >/dev/null` capture order
are bash 3.2 safe and keep only the hook's stderr.

- [ ] **Step 2: Run the block — the negative case must turn it red**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -3; echo "exit=${PIPESTATUS[0]}"`

Expected:
```
hook-contract-fixture: ok
the Stop-hook check passed a hook that could not look (exit 0 with a WARNING) — in a gate that is red
verification: block exited 1
exit=1
```
Record `the Stop-hook check passed a hook that could not look (exit 0 with a WARNING) — in a gate that is red`
in the red-first table. This is the state at `643f7ff`: the hook names the block as its backstop, and the
block accepted the hook's could-not-look exit.

- [ ] **Step 3: Read the hook's stderr, and state the rule in the preamble**

**Replace** in `.claude/rules/cbk-conventions-reference.md` *(whole lines)*:
````text
  [ "$rc" -eq 0 ] || { echo "a reviewer-memory tree exists outside the root (detect-forked-agent-memory.sh exit $rc). The hook said:"; printf '  %s\n' "$err"; return 1; }
}
````
with:
````text
  [ "$rc" -eq 0 ] || { echo "a reviewer-memory tree exists outside the root (detect-forked-agent-memory.sh exit $rc). The hook said:"; printf '  %s\n' "$err"; return 1; }
  # Exit 0 with a WARNING is a hook that could not look: no checkout, an unenterable root, a partial scan, an
  # unmonitored walk. A Stop hook fails open by design, so a stop is never blocked on a check it could not
  # make; in a gate that state is red (context-builder-kit#73).
  if grep -q 'WARNING' <<<"$err"; then echo "the Stop hook could not look (exit 0 with a WARNING). The hook said:"; printf '  %s\n' "$err"; return 1; fi
}
````

**Replace** in `.claude/rules/cbk-conventions-reference.md` *(inline; the § Verification preamble, line 474)*:
````text
Every check says what it catches. Run the block after
````
with:
````text
Every check says what it catches, and a check that could not look is red: a hook fails open by design when it cannot see, so a gate that reads only its exit code passes on nothing (the Stop-hook check reads the hook's stderr for that reason). Run the block after
````

- [ ] **Step 4: Green on the tree; red on a partial scan**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected:
```
verification: kit sub-block complete
verification: done
exit=0
```

Mutation probe, a partial scan. `chmod 000` is ignored for root, so as root this prints the SKIP line. Record
which line printed.

```bash
if [ "$(id -u)" -eq 0 ]; then echo "SKIP: partial-scan probe (running as root; chmod 000 is ignored)"; else
  mkdir -p v1-unreadable-probe/x && chmod 000 v1-unreadable-probe
  bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'could not look|scan was partial|block exited'; echo "exit=${PIPESTATUS[0]}"
  chmod 755 v1-unreadable-probe && rm -rf v1-unreadable-probe
fi
git status --short
```

Expected (non-root):
```
the Stop hook could not look (exit 0 with a WARNING). The hook said:
  detect-forked-agent-memory: WARNING — the scan was partial; find could not read:
verification: block exited 1
exit=1
```
followed by a `git status --short` that prints only ` M .claude/rules/cbk-conventions-reference.md`: this task's
edit, not yet committed. The probe directory is gone. As root, the SKIP line is followed by the same status line.

- [ ] **Step 5: Commit**

```bash
git add .claude/rules/cbk-conventions-reference.md
git commit -F - <<'EOF'
fix(verification): V1 — a Stop hook that could not look is red in the gate

detect-forked-agent-memory.sh fails open by design (exit 0 with a WARNING)
when it could not look: no checkout, an unenterable root, a partial scan, an
unmonitored walk. The block's check read only the exit code, so it passed on
nothing while the hook named the block as its backstop. stop_hook_clean reads
the hook's stderr; an in-block negative case, outside any checkout under a git
ceiling, must itself come back red, so a regression is caught where the check
runs. The preamble states the rule.

Trace: #73/body/2, the block's half (D51). The hook's WARNING contract and
the partial-scan fixture case are V2's.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

---

### Task V1.3: The budget line warns above 140,000 bytes (D50)

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md`, the kit sub-block's always-loaded budget line (line 688)

**Interfaces:**
- Consumes: the budget loop's `$total`.
- Produces: a non-failing line `WARN: always-loaded total N bytes is above the 140000-byte budget line — …`,
  printed only when N > 140000. Task F1 greps `always-loaded total|WARN`. V5's D59 split works against
  130,628 and never needs this line to fire.

- [ ] **Step 1: The failing check — a padded always-loaded rule must produce a WARN line**

The check is a dry run in a throwaway clone. It copies the working tree's reference file in, then pads
`workflows.md`, an always-loaded rule, by 10,002 bytes:

```bash
d=$(mktemp -d) && git clone -q . "$d/k" && cp .claude/rules/cbk-conventions-reference.md "$d/k/.claude/rules/" \
  && ( cd "$d/k" && { printf '\n'; head -c 10000 /dev/zero | tr '\0' 'x'; printf '\n'; } >> .claude/rules/workflows.md \
       && bash .claude/workflows/tests/run-verification-block.sh > "$d/out" 2>&1; echo "exit=$?"; grep -E '^always-loaded total|^WARN' "$d/out"; echo "warn-lines=$(grep -c '^WARN' "$d/out")" )
rm -rf "$d"
```

- [ ] **Step 2: Run it before the change — no WARN line**

Expected:
```
exit=0
always-loaded total: 140630 bytes
warn-lines=0
```
Record `always-loaded total: 140630 bytes` with `warn-lines=0` in the red-first table.

- [ ] **Step 3: Add the warning**

**Replace** in `.claude/rules/cbk-conventions-reference.md` *(whole lines)*:
````text
total=0; for f in .claude/rules/*.md; do head -1 "$f" | grep -q '^---$' || { s=$(wc -c < "$f"); total=$((total+s)); echo "always-loaded: $f ($s bytes)"; }; done; echo "always-loaded total: $total bytes"
````
with:
````text
total=0; for f in .claude/rules/*.md; do head -1 "$f" | grep -q '^---$' || { s=$(wc -c < "$f"); total=$((total+s)); echo "always-loaded: $f ($s bytes)"; }; done; echo "always-loaded total: $total bytes"
# Above 140,000 bytes the budget line warns and never fails: the number is a signal to path-scope, split or delete
# a rule, not a gate (cbk-conventions.md § Rule loading and the instruction budget). The WARN prefix is what a
# release's budget check greps for.
[ "$total" -le 140000 ] || echo "WARN: always-loaded total $total bytes is above the 140000-byte budget line — path-scope, split or delete a rule (cbk-conventions.md § Rule loading and the instruction budget)"
````

- [ ] **Step 4: The padded tree warns and stays green; the real tree does not warn**

Re-run Step 1's commands. Expected:
```
exit=0
always-loaded total: 140630 bytes
WARN: always-loaded total 140630 bytes is above the 140000-byte budget line — path-scope, split or delete a rule (cbk-conventions.md § Rule loading and the instruction budget)
warn-lines=1
```

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|^verification: (kit|done)'; echo "exit=${PIPESTATUS[0]}"`

Expected:
```
always-loaded total: 130628 bytes
verification: kit sub-block complete
verification: done
exit=0
```

- [ ] **Step 5: Commit**

```bash
git add .claude/rules/cbk-conventions-reference.md
git commit -F - <<'EOF'
feat(verification): V1 — the budget line warns above 140,000 always-loaded bytes

The always-loaded loop printed the standing cost but nothing flagged growth.
Above 140,000 bytes it now prints a WARN line and the run goes on: the number
is a signal to path-scope, split or delete a rule, not a gate. Shown by
padding an always-loaded rule to 140,630 bytes in a throwaway clone: no WARN
before, one WARN after, exit 0 both times.

Decision: D50 (no trace row of its own).

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

---

### Task V1.4: A freshly scaffolded target passes its own block (Review Focus 4; the Gate settled call; review/portability/68)

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md`, the kit sub-block's `CLAUDE.md` check (lines 506–508),
  plus a new check at the kit sub-block's sentinel
- Modify: `.claude/skills/scaffold/references/bootstrap_checklist_template.md`, § 4 Rule-file disposition's first
  sentence (line 77) and its table (after line 91)
- Modify: `.claude/skills/scaffold/SKILL.md`, the Phase exit checklist's disposition item (line 315)
- Modify: `.claude/skills/scaffold/references/test_cases.md`, Test 1's bootstrap-checklist criterion (line 22)

**Interfaces:**
- Consumes: the project sub-block's stamped-globs check (`unfilled paths placeholder in <file>`), unchanged.
- Produces: the disposition row `| \`cbk-conventions-reference.md\` | stamped | … |`. V5's D59 split, V8's one-time
  choices and V10's Kit commit row edit the same checklist in other rows. V5 must add a row if
  `knowledge-backend-reference.md` ships a `paths:` placeholder, because the pin below fails otherwise.
- Produces: a kit-sub-block pin. Every rule whose `paths:` block ships a `<` placeholder must have a
  `| \`<basename>\` |` row in the disposition table; otherwise the block prints `<file> ships a paths: placeholder,
  but scaffold's rule-file disposition table has no row for it`.
- Produces: the rule that a scaffolded target owes the `CLAUDE.md` mention once `docs/cbk/blueprint.md` exists,
  while the kit tree always owes it. Red message: `CLAUDE.md is missing or does not mention cbk-conventions (a
  backticked mention, never an @ import)`.
- Produces: the helper `${TMPDIR:-/tmp}/v1-fresh-scaffold.sh`, used for this task's test and re-run in V1.5 Step 4. It
  is not committed.

- [ ] **Step 1: Write the pin and the fresh-scaffold test**

**Replace** in `.claude/rules/cbk-conventions-reference.md` *(whole lines; the kit sub-block's sentinel)*:
````text
echo "verification: kit sub-block complete"
````
with:
````text
# Every rule whose `paths:` block ships a placeholder has a row in scaffold's rule-file disposition table, so the
# pass that stamps it asks about it: a placeholder no row names reaches a target unstamped and fails the project
# sub-block's stamped-globs check on the target's first run. The closed set is diffed here because the tree can.
for f in $(grep -l '^paths:' .claude/rules/*.md); do awk '/^---$/{c++; next} c==1' "$f" | grep -q '<' || continue; grep -q "^| \`$(basename "$f")\` |" .claude/skills/scaffold/references/bootstrap_checklist_template.md || { echo "$f ships a paths: placeholder, but scaffold's rule-file disposition table has no row for it"; exit 1; }; done

echo "verification: kit sub-block complete"
````

Write the Review Focus 4 test to `${TMPDIR:-/tmp}/v1-fresh-scaffold.sh`. It lives outside the repository and is
not committed. It builds a target as it stands at scaffold's end, before blueprint: the drop-in set from this
working tree, the ADR starters instantiated, `docs/cbk/scaffold.md` and the problem brief committed, a README, no
`CLAUDE.md`. It then performs the rule-file disposition pass's stamping and runs the real runner:

```bash
cat > "${TMPDIR:-/tmp}/v1-fresh-scaffold.sh" <<'EOF'
fresh_scaffold() {  # fresh_scaffold <stamp the reference glob? yes|no> [blueprint]: a target at scaffold's end (with "blueprint", past blueprint with no CLAUDE.md)
  local t; t=$(mktemp -d)
  git -c init.defaultBranch=main init -q "$t"
  git ls-files -z .claude .mcp.json.example .github/dependabot.yml.example .github/workflows/adr-immutability-check.yml | xargs -0 cp --parents -t "$t"
  mkdir -p "$t/docs/cbk" "$t/docs/adr"
  cp -a .claude/skills/scaffold/references/adr-starters/. "$t/docs/adr/"
  printf '# Scaffold output\n' > "$t/docs/cbk/scaffold.md"
  printf '# Problem brief\n' > "$t/docs/cbk/problem_brief.md"
  printf '# demo\n' > "$t/README.md"
  [ "${2:-}" = blueprint ] && printf "# Blueprint\n" > "$t/docs/cbk/blueprint.md"
  # The rule-file disposition pass (bootstrap checklist section 4) stamps every paths: placeholder.
  sed -i 's|"\*\*/\*\.<ext>"|"**/*.py"|' "$t/.claude/rules/logging.md"
  sed -i 's|<ext>|py|g' "$t/.claude/rules/testing.md"
  [ "$1" = yes ] && sed -i 's|^  - "<manifest-and-lockfile-globs.*>"$|  - "**/pyproject.toml"\n  - "**/uv.lock"|' "$t/.claude/rules/cbk-conventions-reference.md"
  ( cd "$t" && git add -A && git -c user.name=t -c user.email=t@t commit -qm scaffold && bash .claude/workflows/tests/run-verification-block.sh > "$t.out" 2>&1; echo "exit=$?"; grep -E '^verification: |unfilled paths placeholder|^CLAUDE.md is missing|^grep: ' "$t.out" )
  rm -rf "$t" "$t.out"
}
EOF
```

`cp --parents` and `sed -i` are GNU forms; the executing host is Linux (Task 0 Step 3 records GNU grep). The
copy uses `git ls-files`, so it takes tracked paths with their working-tree content, V1.1's fixture included.

- [ ] **Step 2: Run both — the pin and the fresh scaffold must be red**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected:
```
.claude/rules/cbk-conventions-reference.md ships a paths: placeholder, but scaffold's rule-file disposition table has no row for it
verification: block exited 1
exit=1
```

Run: `. "${TMPDIR:-/tmp}/v1-fresh-scaffold.sh"; fresh_scaffold yes`

Expected:
```
exit=2
grep: CLAUDE.md: No such file or directory
verification: block exited 2
```

Record both red lines in the red-first table. The second line is the planning-time finding. At `643f7ff`, even a
target that stamped every glob fails its own block at scaffold's end, because `grep -q "cbk-conventions"
CLAUDE.md` runs before blueprint has written `CLAUDE.md`. Scaffold never commits `CLAUDE.md`, per
`github_only_profile.md`: "Does not commit `CLAUDE.md`, `AGENTS.md`, `.claude/`, or `.mcp.json`".

- [ ] **Step 3: The disposition row, the key on blueprint, and their restatements**

**Replace** in `.claude/rules/cbk-conventions-reference.md` *(whole lines)*:
````text
# CLAUDE.md points at this file as a backticked mention — deliberately NOT an `@` import,
# which would expand this whole file into every session at launch (memory docs).
grep -q "cbk-conventions" CLAUDE.md
````
with:
````text
# CLAUDE.md points at this file as a backticked mention — deliberately NOT an `@` import,
# which would expand this whole file into every session at launch (memory docs). Blueprint writes a target's
# CLAUDE.md, so a scaffolded target owes the mention once docs/cbk/blueprint.md exists; the kit tree always does.
if [ ! -f docs/cbk/scaffold.md ] || [ -f docs/cbk/blueprint.md ]; then grep -q "cbk-conventions" CLAUDE.md || { echo "CLAUDE.md is missing or does not mention cbk-conventions (a backticked mention, never an @ import)"; exit 1; }; fi
````

**Replace** in `.claude/skills/scaffold/references/bootstrap_checklist_template.md` *(inline; § 4's first sentence)*:
````text
and two path-scoped rules whose `paths:` globs are placeholders (`logging.md`, `testing.md`).
````
with:
````text
and three path-scoped rules whose `paths:` block carries a placeholder glob (`logging.md`, `testing.md`, and the manifest-and-lockfile entry in `cbk-conventions-reference.md`).
````

**Replace** in `.claude/skills/scaffold/references/bootstrap_checklist_template.md` *(whole lines; the disposition
table)*:
````text
| `testing.md` | stamped | `paths:` set to the project's test globs and directories (inline-test stacks: directories alone) |
````
with:
````text
| `testing.md` | stamped | `paths:` set to the project's test globs and directories (inline-test stacks: directories alone) |
| `cbk-conventions-reference.md` | stamped | the bracketed `paths:` entry replaced with the project's manifest and lockfile globs (e.g. `**/pyproject.toml`, `**/uv.lock`); left bracketed, it fails the verification block's stamped-globs check |
````

**Replace** in `.claude/skills/scaffold/SKILL.md` *(inline; the Phase exit checklist)*:
````text
`logging.md` and `testing.md` carry stamped globs (no `<ext>` left)
````
with:
````text
`logging.md`, `testing.md` and `cbk-conventions-reference.md` carry stamped globs (no `<ext>` and no bracketed manifest entry left)
````

**Replace** in `.claude/skills/scaffold/references/test_cases.md` *(inline; Test 1)*:
````text
section 4 lists every shipped template and path-scoped rule with a disposition, and prints the always-loaded set first.
````
with:
````text
section 4 lists every shipped template and path-scoped rule with a disposition (the manifest-and-lockfile entry in `cbk-conventions-reference.md`'s `paths:` included), and prints the always-loaded set first.
````

- [ ] **Step 4: Green on the kit tree; the fresh scaffold prints all three sentinels, and each failure names its file**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected:
```
verification: kit sub-block complete
verification: done
exit=0
```

Run: `. "${TMPDIR:-/tmp}/v1-fresh-scaffold.sh"; fresh_scaffold yes; echo ---; fresh_scaffold no; echo ---; fresh_scaffold yes blueprint`

Expected:
```
exit=0
verification: kit sub-block complete
verification: project sub-block complete
verification: done
---
exit=1
verification: kit sub-block complete
unfilled paths placeholder in .claude/rules/cbk-conventions-reference.md
verification: block exited 1
---
exit=1
grep: CLAUDE.md: No such file or directory
CLAUDE.md is missing or does not mention cbk-conventions (a backticked mention, never an @ import)
verification: block exited 1
```

These are Review Focus 4's three assertions. With the globs stamped, the runner prints all three sentinels. An
unstamped reference-half glob turns it red and names the file. A target past blueprint still owes `CLAUDE.md`.
This test is deliberately not a block check. Running the real block from inside the block would recurse through
`run-verification-block-fixture.sh`.

- [ ] **Step 5: Commit**

```bash
git add .claude/rules/cbk-conventions-reference.md .claude/skills/scaffold/references/bootstrap_checklist_template.md .claude/skills/scaffold/SKILL.md .claude/skills/scaffold/references/test_cases.md
git commit -F - <<'EOF'
fix(scaffold): V1 — a freshly scaffolded target passes its own verification block

Two causes kept a fresh scaffold red. The disposition pass never asked about
cbk-conventions-reference.md's bracketed manifest-and-lockfile glob, which the
project sub-block's stamped-globs check rejects: the table gains the row, § 4's
first sentence counts three path-scoped placeholders, and the phase-exit item
and Test 1 name it. And the kit sub-block required a CLAUDE.md mention that
blueprint, not scaffold, writes: a scaffolded target now owes it once
docs/cbk/blueprint.md exists, and the kit tree always does. A kit-sub-block pin
fails when a rule ships a paths: placeholder the disposition table has no row
for. Shown on a simulated scaffold (drop-in set, ADR starters, scaffold.md,
globs stamped): all three sentinels; unstamped, red naming the file.

Trace: Review Focus 4; the Gate settled call (disposition row); the defect
behind review/portability/68 (V9's row, landed here).

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

---

### Task V1.5: The templates wire the block into `check` (#58/c5901493591/R4; D51)

**Files:**
- Modify: `.claude/skills/blueprint/references/templates/tooling.md`: step 1's minimum task set (line 29), the
  § Rules list (after line 48), and § Light-mode behavior (line 211)
- Modify: `.claude/skills/blueprint/SKILL.md`, the Phase exit checklist (after line 324)
- Modify: `.claude/skills/blueprint/references/test_cases.md`, Test 1's tooling criterion (line 20)
- Modify: `.claude/skills/scaffold/references/bootstrap_checklist_template.md`, the verification matrix (after
  line 70)
- Modify: `.claude/skills/scaffold/references/test_cases.md`, Test 1's bootstrap-checklist criterion (line 22,
  as V1.4 left it)
- Modify: `.claude/rules/cbk-conventions-reference.md`, § Verification › Run it (as V1.1 left it) plus a new check at
  the kit sub-block's sentinel

**Interfaces:**
- Consumes: V1.1's Run it paragraph; V1.4's disposition row and its Test 1 sentence; V1.4's fresh-scaffold helper.
- Produces: the tooling template's **verification task** that `check` depends on, whose body is `bash
  .claude/workflows/tests/run-verification-block.sh`, and which light mode keeps. V4 (the CI skeleton at lines
  58–74, the review-bot paragraph) and V8 (the `mise` note under step 1's `mise.toml` bullet, a Rules line on
  pipefail discipline, sanity 6b) edit the same file at other anchors. Line 29 and the first Rules bullet are
  this task's.
- Produces: the bootstrap checklist's matrix row `| Verification block runs | … |`, the matrix's last row at this
  commit. V2's conditional corpus rows and V10's Kit commit row are added beside it.
- Produces: a kit-sub-block pin. Both templates must name `run-verification-block.sh`; otherwise the block prints `<file>
  does not name .claude/workflows/tests/run-verification-block.sh (the template that wires the block into
  check)`.

- [ ] **Step 1: Write the pin**

**Replace** in `.claude/rules/cbk-conventions-reference.md` *(whole lines; the kit sub-block's sentinel)*:
````text
echo "verification: kit sub-block complete"
````
with:
````text
# The templates wire the block into `check`: blueprint's tooling template names the runner as the body of the
# verification task `check` depends on, and scaffold's bootstrap checklist runs it once (§ Verification › Run it).
for f in .claude/skills/blueprint/references/templates/tooling.md .claude/skills/scaffold/references/bootstrap_checklist_template.md; do grep -q 'run-verification-block\.sh' "$f" || { echo "$f does not name .claude/workflows/tests/run-verification-block.sh (the template that wires the block into check)"; exit 1; }; done

echo "verification: kit sub-block complete"
````

- [ ] **Step 2: Run the block — the pin must be red**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected:
```
.claude/skills/blueprint/references/templates/tooling.md does not name .claude/workflows/tests/run-verification-block.sh (the template that wires the block into check)
verification: block exited 1
exit=1
```
Record the first line in the red-first table.

- [ ] **Step 3: The verification task, its rule, light mode, the matrix row, and the restatements**

Two corrections to the exercised text this ports. First, the block needs `node` and `python3` as well as `jq`,
because the kit sub-block runs the `.mjs` and Python fixtures. Second, the ported sentence "on a fresh scaffold it
is green" is not carried: V1.4 made it true, but the claim belongs to the checklist row, which states its
precondition.

**Replace** in `.claude/skills/blueprint/references/templates/tooling.md` *(whole lines)*:
````text
   Must define at minimum: `setup`, `check`, `test`, `lint`, `dev` (or local equivalents).
````
with:
````text
   Must define at minimum: `setup`, `check`, `test`, `lint`, `dev` (or local equivalents), and a **verification task** that `check` depends on, whose body is `bash .claude/workflows/tests/run-verification-block.sh` (`cbk-conventions-reference.md` § Verification › Run it). The runner needs `bash`, `git`, `awk` and `mktemp`; the block it runs also needs `jq`, `node` and `python3`, because it runs the kit's fixtures, so `setup` installs them or the stack decisions say where they come from. A host missing one of them runs the block red. In a filled target the runner requires both `verification: project sub-block complete` and `verification: done`. Name the task in CLAUDE.md's command list like every other.
````

**Replace** in `.claude/skills/blueprint/references/templates/tooling.md` *(whole lines; § Rules)*:
````text
- **Every command in CLAUDE.md = actual task definition.** No exceptions.
````
with:
````text
- **Every command in CLAUDE.md = actual task definition.** No exceptions.
- **The verification block is a leg of `check`, never a command someone remembers.** It holds the `.claude/` tooling contract (the hook registry, the byte-parallel copies, the always-loaded budget, the project sub-block), and a check nobody re-runs is a belief with a date on it. Because `check` locally = the CI pipeline (the next rule), the CI job that runs `check` runs the block too. Run the task once before the HITL presentation; a red line is fixed before hand-off, not recorded.
````

**Replace** in `.claude/skills/blueprint/references/templates/tooling.md` *(whole lines; § Light-mode behavior)*:
````text
- **Task runner config has the minimum set**: setup, check, test. Skip lint/typecheck/dev/fix/etc. unless they were explicitly chosen during stack decisions.
````
with:
````text
- **Task runner config has the minimum set**: setup, check, test, and the verification task `check` depends on (it keeps the `.claude/` contract checked, so light mode keeps it too). Skip lint/typecheck/dev/fix/etc. unless they were explicitly chosen during stack decisions.
````

**Replace** in `.claude/skills/blueprint/SKILL.md` *(whole lines; the Phase exit checklist)*:
````text
- [ ] `CLAUDE.md` mentions the other docs as backticked paths: `grep -n "^- @\|@docs/" CLAUDE.md` prints nothing
````
with:
````text
- [ ] `CLAUDE.md` mentions the other docs as backticked paths: `grep -n "^- @\|@docs/" CLAUDE.md` prints nothing
- [ ] The task runner defines the verification task that `check` depends on, and `bash .claude/workflows/tests/run-verification-block.sh` exits 0 with `verification: project sub-block complete` and `verification: done` as its last two lines
````

**Replace** in `.claude/skills/blueprint/references/test_cases.md` *(inline; Test 1)*:
````text
every CI gate in STANDARDS.md maps to an actual job in the workflow file
````
with:
````text
every CI gate in STANDARDS.md maps to an actual job in the workflow file; the task runner defines a verification task that `check` depends on, running `.claude/workflows/tests/run-verification-block.sh`, and it ran once before the HITL presentation with both sentinels printed
````

**Replace** in `.claude/skills/scaffold/references/bootstrap_checklist_template.md` *(whole lines; § 3 Verification
matrix)*:
````text
| Branch protection (if configured) | Try to push directly to main from a clone | Push is rejected | ☐ |
````
with:
````text
| Branch protection (if configured) | Try to push directly to main from a clone | Push is rejected | ☐ |
| Verification block runs | With the kit's `.claude/` in the clone and the rule-file disposition below done, from the clone's root: `bash .claude/workflows/tests/run-verification-block.sh` | Exits 0; the last two lines are `verification: project sub-block complete` and `verification: done` (a filled target owes both — `cbk-conventions-reference.md` § Verification › Run it). Blueprint wires the same script into `check`. | ☐ |
````

**Replace** in `.claude/skills/scaffold/references/test_cases.md` *(inline; Test 1, as V1.4 left it)*:
````text
and prints the always-loaded set first.
````
with:
````text
and prints the always-loaded set first; the verification matrix's last row ran the runner after that pass and read both sentinels.
````

**Replace** in `.claude/rules/cbk-conventions-reference.md` *(inline; § Verification › Run it, as V1.1 left it)*:
````text
a target wires the same script as the body of a task its check command depends on (a check nobody re-runs
````
with:
````text
a target wires the same script as the body of a task its check command depends on — blueprint's `templates/tooling.md` names that task, and scaffold's bootstrap checklist runs the script once in its verification matrix (a check nobody re-runs
````

- [ ] **Step 4: Green; the matrix row's claim holds on the fresh scaffold; SKILL.md stays under 500 lines**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected:
```
verification: kit sub-block complete
verification: done
exit=0
```

Run: `. "${TMPDIR:-/tmp}/v1-fresh-scaffold.sh"; fresh_scaffold yes`

Expected (the row's "last two lines" claim):
```
exit=0
verification: kit sub-block complete
verification: project sub-block complete
verification: done
```

Run: `wc -l < .claude/skills/blueprint/SKILL.md; grep -c 'run-verification-block.sh' .claude/skills/blueprint/references/templates/tooling.md .claude/skills/scaffold/references/bootstrap_checklist_template.md`
Expected: `355`, then counts `1` and `1`.

- [ ] **Step 5: Commit**

```bash
git add .claude/skills/blueprint/references/templates/tooling.md .claude/skills/blueprint/SKILL.md .claude/skills/blueprint/references/test_cases.md .claude/skills/scaffold/references/bootstrap_checklist_template.md .claude/skills/scaffold/references/test_cases.md .claude/rules/cbk-conventions-reference.md
git commit -F - <<'EOF'
feat(blueprint): V1 — the templates wire the verification block into check

Nothing in the templates ran the block, so a target ran it only if someone
remembered. Blueprint's tooling template: the minimum task set, light mode
included, gains a verification task that check depends on, whose body is the
runner, with the tools it needs (bash, git, awk, mktemp; jq, node, python3
for the block's fixtures); § Rules makes it a leg of check, run in CI through
check and once before the HITL presentation. The phase-exit checklist and Test
1 assert it. Scaffold's verification matrix runs the runner after the
disposition pass and expects both sentinels. Run it names the two homes, and a
kit-sub-block pin keeps both templates naming the runner.

Trace: #58/c5901493591/R4 (D51).

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

---

### Task V1.6: The bracket idiom's cost for a spellchecker, scoped to one file (#58/c5901493591/R5; D51)

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md`: § Verification, a paragraph after Run it, plus a new check
  at the kit sub-block's sentinel

**Interfaces:**
- Consumes: V1.5's Run it paragraph, which ends `a "recorded" red cannot reach the sentinels.` and is followed by the
  block's fence.
- Produces: § Verification's second fenced block, a ` ```toml ` fence placed before the ` ```bash ` fence. The runner's
  extraction takes only ` ```bash ` fences, so the toml fence is never executed; the Step 4 run shows it. Nothing else
  may add a fence to § Verification without re-running that proof.
- Produces: a kit-sub-block pin, red as `§ Verification lacks the bracket idiom's file-scoped spellchecker exemption`.
  The paragraph deliberately does not enumerate the bracketed letters, because later clusters' `absent` lines
  enlarge the set.

- [ ] **Step 1: Re-fetch the typos reference and write the pin**

The quotation and the table shape are platform facts, re-read raw on the day they are written:

```bash
curl -sL https://raw.githubusercontent.com/crate-ci/typos/master/docs/reference.md -o "${TMPDIR:-/tmp}/typos-reference.md"
grep -cF 'File globs for matching `NAME`. This is required when defining new file types.' "${TMPDIR:-/tmp}/typos-reference.md"
grep -cF '# ... see `default`' "${TMPDIR:-/tmp}/typos-reference.md"
grep -cF 'extend-ignore-re = []' "${TMPDIR:-/tmp}/typos-reference.md"
curl -sL -o /dev/null -w '%{http_code}\n' https://github.com/crate-ci/typos/blob/master/docs/reference.md
```
Expected: `1`, `1`, `1`, `200` (observed 2026-09-30). If a count is `0`, stop and reconcile the paragraph with the
live page. If the execution date is not 2026-09-30, change `read 2026-09-30` in Step 3's paragraph to that date.

**Replace** in `.claude/rules/cbk-conventions-reference.md` *(whole lines; the kit sub-block's sentinel)*:
````text
echo "verification: kit sub-block complete"
````
with:
````text
# The bracket idiom's cost is stated where the idiom lives (§ Verification): the spellchecker exemption scoped to
# this one file. The pattern brackets its own letter so this line never matches itself.
grep -q 'extend-glo[b] = \["cbk-conventions-reference.md"\]' .claude/rules/cbk-conventions-reference.md || { echo "§ Verification lacks the bracket idiom's file-scoped spellchecker exemption"; exit 1; }

echo "verification: kit sub-block complete"
````

- [ ] **Step 2: Run the block — the pin must be red**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected:
```
§ Verification lacks the bracket idiom's file-scoped spellchecker exemption
verification: block exited 1
exit=1
```
Record the first line in the red-first table.

- [ ] **Step 3: The paragraph**

**Replace** in `.claude/rules/cbk-conventions-reference.md` *(inline; from the end of Run it's last sentence,
through the blank line, to the block's opening fence)*:
````text
a "recorded" red cannot reach the sentinels.

```bash
````
with:
````text
a "recorded" red cannot reach the sentinels.

**The bracket idiom has a cost.** An `absent` check writes the phrase it hunts with one letter bracketed (`opinionate[d] profile`), so the grep never matches its own line. A target that spellchecks `.claude/` reads each bracketed fragment as a typo. Exempt the idiom in this one file, never repo-wide: a blanket ignore pattern would also hide a real misspelling written the same way. In `typos` that is a `[type.<name>]` table whose `extend-glob` names this file and whose `extend-ignore-re` matches the idiom:

```toml
[type.cbk-block]
extend-glob = ["cbk-conventions-reference.md"]
extend-ignore-re = ["[A-Za-z_-]*\\[[A-Za-z]\\][A-Za-z]*"]
```

`extend-glob` is "File globs for matching `NAME`. This is required when defining new file types.", and a type table takes the `[default]` keys, `extend-ignore-re` among them (`https://github.com/crate-ci/typos/blob/master/docs/reference.md`, read 2026-09-30; the table above exercised against typos 1.50.3, which then still reports an idiom-shaped misspelling in any other file). The skills' other bracket uses (`R[i]`, `M[n]`) are index notation, not the idiom, and need no exemption (context-builder-kit#58, the declined spellchecker item's promised note).

```bash
````

- [ ] **Step 4: Green; the toml fence is not extracted; the table does what the paragraph says**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected:
```
verification: kit sub-block complete
verification: done
exit=0
```

Run: `awk '/^## Verification/{p=1} p' .claude/rules/cbk-conventions-reference.md | awk '/^```bash/{c=1;next} /^```/{c=0} c' | grep -c 'type.cbk-block'`
Expected: `0`. The runner's extraction does not carry the toml fence.

Probe, an optional tool. It exercises the documented table against a real `typos`, with the file at its real path,
plus a second file whose idiom-shaped misspelling must still be reported:

```bash
if command -v typos >/dev/null; then
  t=$(mktemp -d); git -C "$t" init -q
  awk '/^```toml/{c=1;next} /^```/{c=0} c' .claude/rules/cbk-conventions-reference.md > "$t/_typos.toml"
  mkdir -p "$t/.claude/rules" "$t/docs"; cp .claude/rules/cbk-conventions-reference.md "$t/.claude/rules/"
  printf 'github-onl[y] recieve[d]\n' > "$t/docs/other.md"
  ( cd "$t" && typos --version && typos --format brief .claude docs; echo "rc=$?" ); rm -rf "$t"
else echo "SKIP: typos probe (typos unavailable)"; fi
```
Expected with typos installed (observed with typos-cli 1.50.3):
```
typos-cli 1.50.3
docs/other.md:1:8: error: `onl` should be `only`
docs/other.md:1:15: error: `recieve` should be `receive`
rc=2
```
No line names `.claude/rules/cbk-conventions-reference.md`; without the table the same run reports four bracketed
fragments there (`onl`, `summar`, `chec`, `doub`). Without typos, record the SKIP line in the PR body.

- [ ] **Step 5: Commit**

```bash
git add .claude/rules/cbk-conventions-reference.md
git commit -F - <<'EOF'
docs(verification): V1 — name the bracket idiom's cost for a spellchecker, scoped to one file

An absent check brackets one letter of the phrase it hunts so the grep never
matches its own line; a target that spellchecks .claude/ reads each fragment
as a typo. § Verification now says to exempt the idiom in this one file, never
repo-wide, and shows the typos form: a [type.<name>] table whose extend-glob
names cbk-conventions-reference.md and whose extend-ignore-re matches the
idiom, quoted from typos' reference (read 2026-09-30) and exercised against
typos 1.50.3. A kit-sub-block pin keeps the note.

Trace: #58/c5901493591/R5 (D51).

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

---

### Task V1.7: The kit's verify job runs an explicit bash on a named image (D52, the kit-workflows settled call)

At this commit no workflow template carries these two pins yet. V4 adds them to the review-workflow templates and
V2 adds them to the ADR job, so the pin's comment gives its own reasons and does not lean on the templates.

**Files:**
- Modify: `.github/workflows/verify.yml` (full content below)
- Modify: `.claude/rules/cbk-conventions-reference.md`, a new check at the kit sub-block's sentinel

**Interfaces:**
- Consumes: the job name `Verification block`, a required check matched by name, unchanged.
- Produces: `verify.yml` with `defaults: run: shell: bash` and `runs-on: ubuntu-24.04`, each with its sourced reason.
- Produces: a kit-tree-only pin (`[ -f docs/cbk/scaffold.md ] || …`). It is red as `.github/workflows/verify.yml lacks
  defaults.run.shell: bash or runs-on: ubuntu-24.04`. V2 pins `adr-immutability-check.yml` the same way when it
  rewrites that job, and extends this line's file list (handed out).

- [ ] **Step 1: Re-fetch the three facts and write the pin**

```bash
curl -sL https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax | sed 's/<[^>]*>//g' > "${TMPDIR:-/tmp}/gh-wsyntax.txt"
grep -cF 'bash -e {0}' "${TMPDIR:-/tmp}/gh-wsyntax.txt"
grep -cF 'bash --noprofile --norc -eo pipefail {0}' "${TMPDIR:-/tmp}/gh-wsyntax.txt"
curl -sL https://raw.githubusercontent.com/actions/runner-images/main/README.md -o "${TMPDIR:-/tmp}/ri-readme.md"
grep -cF 'may see changes in the OS version' "${TMPDIR:-/tmp}/ri-readme.md"
grep -c '^#### Latest Migration Process' "${TMPDIR:-/tmp}/ri-readme.md"
curl -sL https://raw.githubusercontent.com/actions/runner-images/main/images/ubuntu/Ubuntu2404-Readme.md -o "${TMPDIR:-/tmp}/u2404.md"
for t in '- Bash 5' '- Git 2' '- jq 1' '- Node.js 2' '- Python 3'; do printf '%s: ' "$t"; grep -cF -- "$t" "${TMPDIR:-/tmp}/u2404.md"; done
```
Expected: two non-zero counts (observed `4` and `4`: the page renders the shell table more than once), then `1`, `1`, and five
lines each ending `1`. If any count is `0`, stop and reconcile the comment. If the execution date is not 2026-09-30,
change every `read 2026-09-30` in Step 3's file to that date.

**Replace** in `.claude/rules/cbk-conventions-reference.md` *(whole lines; the kit sub-block's sentinel)*:
````text
echo "verification: kit sub-block complete"
````
with:
````text
# The kit's own CI pins an explicit bash (pipefail, where GitHub's unset shell runs `bash -e` without it) and a
# named runner image (a -latest label moves under the gate). Kit tree only: a target does not install verify.yml.
[ -f docs/cbk/scaffold.md ] || { grep -qx '    shell: bash' .github/workflows/verify.yml && grep -qx '    runs-on: ubuntu-24.04' .github/workflows/verify.yml; } || { echo ".github/workflows/verify.yml lacks defaults.run.shell: bash or runs-on: ubuntu-24.04"; exit 1; }

echo "verification: kit sub-block complete"
````

- [ ] **Step 2: Run the block — the pin must be red**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected:
```
.github/workflows/verify.yml lacks defaults.run.shell: bash or runs-on: ubuntu-24.04
verification: block exited 1
exit=1
```
Record the first line in the red-first table.

- [ ] **Step 3: Rewrite `verify.yml`**

**Overwrite** `.github/workflows/verify.yml` with this content. The trigger, job name, timeout, permissions, pinned
checkout and step are unchanged. The old header's "ubuntu-latest ships bash, jq, git, node and python3 (dated
observation, 2026-09-21 …)" sentence is replaced by the image's own readme:

```yaml
name: Verification block

# Runs cbk-conventions-reference.md § Verification through its runner on every pull request to
# main — no path filter, so it can be a required check (the required-checks trap in
# cbk-conventions.md § `[skip ci]` rule).

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

# An explicit bash runs `bash --noprofile --norc -eo pipefail {0}`; an unset shell runs `bash -e {0}`,
# with no pipefail (https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax
# § jobs.<job_id>.steps[*].shell, read 2026-09-30).
defaults:
  run:
    shell: bash

jobs:
  verify:
    name: Verification block
    # A named image, because a -latest label "may see changes in the OS version" while GitHub migrates it
    # (https://github.com/actions/runner-images README § Latest Migration Process, read 2026-09-30); bump
    # it in a reviewed PR. Ubuntu 24.04 ships bash, git, jq, node and python3 (that repository's
    # images/ubuntu/Ubuntu2404-Readme.md, read 2026-09-30); a missing tool prints `command not found`
    # and turns the run red.
    runs-on: ubuntu-24.04
    timeout-minutes: 10
    permissions:
      contents: read
    steps:
      - name: Checkout
        uses: actions/checkout@11d5960a326750d5838078e36cf38b85af677262 # v4.4.0
      - name: Run the block through its runner
        run: bash .claude/workflows/tests/run-verification-block.sh
```

- [ ] **Step 4: Green, and the workflow parses**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected:
```
verification: kit sub-block complete
verification: done
exit=0
```

Run: `python3 -c "import yaml; d=yaml.safe_load(open('.github/workflows/verify.yml')); print(d['defaults'], d['jobs']['verify']['runs-on'], d['jobs']['verify']['name'])" 2>/dev/null || echo "SKIP: YAML parse (PyYAML unavailable)"`
Expected: `{'run': {'shell': 'bash'}} ubuntu-24.04 Verification block`, or the SKIP line recorded in the PR body. On the
PR, the `Verification block` check is the live proof (Task F4 Step 3).

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -20` and confirm the kit-sub-block tail of this
cluster, in order: `always-loaded total: 130628 bytes`, the six `ok:` lines, `run-verification-block-fixture: 6 cases ok`,
`verification: kit sub-block complete`, `verification: done`. The four new V1 checks print nothing when green.

- [ ] **Step 5: Commit**

```bash
git add .github/workflows/verify.yml .claude/rules/cbk-conventions-reference.md
git commit -F - <<'EOF'
ci: V1 — the kit's verify job runs an explicit bash on a named image

The kit's own verify.yml ran with GitHub's unset shell (bash -e, no pipefail)
on ubuntu-latest, a label that moves under the gate; its workflow templates
take the same two pins later in this PR. verify.yml gains
defaults.run.shell: bash and runs-on: ubuntu-24.04, each with its source read
2026-09-30 (the workflow-syntax shell table; the runner-images migration note
and the 24.04 image readme). A kit-tree-only
check in the block pins both lines. The job name, the required check, is
unchanged.

Decision: D52, the kit's-own-workflows settled call (no trace row of its own).

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

---

## Coverage

Every id in the V1 work pack (items, critic; the pack has no handed-in ids and no review findings). Below them, the
other clusters' ids and the spec items this cluster also lands, so their owners' trace audit can mark them.

| Id | Source | Lands in | What |
|---|---|---|---|
| `#73/body/1` | item | **V1.1** | The runner's third rail; `run-verification-block-fixture.sh` (six cases), run by the block; Run it says three rails and names the residual |
| `#73/body/2` | item | **V1.2**, and handed to V2 | V1.2: `stop_hook_clean`, red on exit 0 with a `WARNING`; the in-block negative case outside a checkout under a git ceiling; the preamble sentence. V2: the hook keeps the literal `WARNING` on every could-not-look path, and `hook-payloads-fixture.sh` carries the partial-scan case |
| `#58/c5901493591/R4` | item | **V1.5** (its precondition in **V1.4**) | Tooling template: the verification task (light mode included), the Rules bullet; blueprint's phase-exit item and Test 1; scaffold's matrix row and Test 1; Run it names both homes; a pin |
| `#58/c5901493591/R5` | item | **V1.6** | The bracket-idiom paragraph with the file-scoped `typos` `[type.<name>]` table, sourced and exercised; a pin |
| `critic/22` | critic | **V1.1** | The block runs `run-verification-block-fixture.sh`; Run it says "three fail-loud rails" |
| `#73/body/2` (handed out) | handedOut → V2 | handed to V2 | See § Handed to other clusters, item 1 |
| `review/portability/68` | V9's review row (unverified) | **V1.4** | Holds at `643f7ff` (the dry run's `unfilled paths placeholder in .claude/rules/cbk-conventions-reference.md`). V1.4 adds the disposition row and the sentence count; V9 marks the row landed by V1.4 and does not re-land it |
| `#69/c5859756889/apply-h4/6` | V9's item | **V1.5** (template half) | The tooling template and checklist now name the runner. The CHANGELOG sync note ("call the runner, never an inline extraction") stays with V9/V10 |
| `#69/c5859470658/1` | V6's item | **V1.5** (the overlap it names) | R4's wiring lands here; V6 adds only its own fixture line to the block |
| `release/5` | V10's item (handed to V2, V4, V6, V7, V9) | **V1.1** (partial) | The bare `#58` in Run it becomes `context-builder-kit#58`. Four bare citations remain in § Verification's block comments, handed to V9 |
| D50 | decision | **V1.3** | The non-failing `WARN:` line above 140,000 bytes |
| D52, the kit's-own-workflows settled call | decision | **V1.7** (`verify.yml`), and handed to V2 (`adr-immutability-check.yml`) | `defaults: run: shell: bash`, `runs-on: ubuntu-24.04`, each sourced; a kit-tree pin |
| Review Focus 4 | master plan | **V1.4** | The fresh-scaffold test: three sentinels when stamped; red naming the file when not; red past blueprint without `CLAUDE.md` |
| Gate settled calls | spec | **V1.1**, **V1.4**, **V1.5** | Disposition row (V1.4). The runner fixture runs in the kit sub-block (V1.1). Light mode keeps the verification task (V1.5). No rail beyond #73's project rail (V1.1 adds exactly one). Explicit `SKIP` for a missing tool (V1.2's root probe, V1.6's typos probe, V1.7's YAML parse) |

## Handed to other clusters

1. **V2, `#73/body/2` (the hook's half).** `stop_hook_clean` reads `detect-forked-agent-memory.sh`'s stderr for the
   literal `WARNING`. Any V2 rewrite of that hook (D61, #62's backstop wording) must keep the literal on every
   could-not-look path, and keep the `Backstop:` line naming "the verification block's Stop-hook check".
   `hook-payloads-fixture.sh` carries the partial-scan case (an unreadable directory: exit 0 with a `WARNING`),
   printing `SKIP` as root.
2. **V2, D52 for the ADR job.** When V2 gives `adr-immutability-check.yml` `defaults: run: shell: bash` and
   `runs-on: ubuntu-24.04`, extend V1.7's pin to it. The ADR job is in the drop-in set, so decide whether its pin is
   kit-tree-only like `verify.yml`'s or unconditional.
3. **V2, #62's bracketed backstop slot.** The spec's Guards settled call has the project sub-block refuse an unfilled
   slot, filled at scaffold's rule-file disposition pass. Add the slot to that pass (§ 4 of
   `bootstrap_checklist_template.md`), and re-run V1.4's `fresh_scaffold yes` with the slot filled in the helper's
   stamping block. Otherwise Review Focus 4 silently stops holding. The helper is not committed: if
   `${TMPDIR:-/tmp}/v1-fresh-scaffold.sh` is gone, re-create it from V1.4 Step 1's `cat > … <<'EOF'` block first.
4. **V5, D59 and #65.** If `knowledge-backend-reference.md` ships a `paths:` block with a `<` placeholder, V1.4's pin
   needs a disposition row for it. The knowledge-axis-`none` row deletes both halves. #65's unfilled-posture refusal
   means a fresh scaffold passes only once `orchestration.md` is filled or deleted: extend V1.4's helper with that
   disposition, and re-run it (re-creating it from V1.4 Step 1 if it is gone, as in item 3).
5. **V8, the tooling template and the checklist.** V1.5 owns line 29 (the minimum task set), the first § Rules bullet
   and § Light-mode behavior's first bullet. Anchor V8's `mise` note under the `mise.toml` bullet, and its pipefail
   Rules line, elsewhere. V1.4 and V1.5 edited scaffold `test_cases.md` line 22; V8's edit is line 23.
6. **V9, D53.** Four bare kit-issue citations remain in § Verification's block comments. They are `(#58, second
   application, item 1)` in the retired-vocabulary comment, `Resolved pair (#37)`, `(#34)` on the
   orchestration-posture row check, and `(#58 item 11)` on the launch-root guard. V1 leaves them because their lines
   belong to checks other clusters may rewrite. V9's keep-out check must not pass before they are rewritten.
   `review/portability/68` and the template half of `#69/c5859756889/apply-h4/6` are landed by V1.4 and V1.5.
7. **V10, README and CHANGELOG.**
   - README Quick start step 2 names only the `logging.md` and `testing.md` globs. It should also name the bracketed
     manifest-and-lockfile entry in `cbk-conventions-reference.md` (Customization item 4 already does).
   - The v1.0.0 Sync notes should say three things. `run-verification-block.sh` is a copy row with a third rail, and
     `run-verification-block-fixture.sh` is an add row. A target wires a verification task into `check`, and stamps
     the reference half's glob if it never did. The block's `CLAUDE.md` check now keys on `docs/cbk/blueprint.md`
     in a target.
   - The `CLAUDE.md` correction (`review/release/65`) should name the runner's fixture among the kit's tests.

## Not holding at planning time

The pack carries no unverified review findings. These claims from the pack's exercised sources and the master plan
did not hold at `643f7ff`, and the plan does not carry them as written. Re-check each at execution.

- **"On a fresh scaffold it is green"** (the ported tooling-template sentence, R4). It did not hold, for two causes the
  dry run showed. `cbk-conventions-reference.md`'s `paths:` placeholder fails the project sub-block (`unfilled paths
  placeholder in .claude/rules/cbk-conventions-reference.md`). With every glob stamped, the kit sub-block still stops
  at `grep: CLAUDE.md: No such file or directory` / `verification: block exited 2`, because scaffold never commits
  `CLAUDE.md`. V1.4 fixes both causes. V1.5 puts the claim on the checklist row with its precondition, not in the
  tooling template.
- **Master plan, Review Focus 4's premise** that with `scaffold.md` present and the globs stamped the runner prints
  all three sentinels. It fails at `643f7ff` on the `CLAUDE.md` cause above, and holds from V1.4 on. The master
  plan's wording can stand after V1.4 lands.
- **"The script needs bash, git and awk, and the block needs jq"** (the ported tool list). It is incomplete. The kit
  sub-block runs `node` (`review-sweep-accounting.mjs`, `finish-ab-shape.mjs`, `load-workflow-shape.mjs`) and
  `python3` (`agent-cost-fixture.sh`), and the runner uses `mktemp`. V1.5 states the full set.
- **"verify.yml needs no change"** (the pack's `#73/body/1` hazard). It is true for #73's rail alone. D52's
  kit's-own-workflows settled call changes the file, and V1.7 does it.
