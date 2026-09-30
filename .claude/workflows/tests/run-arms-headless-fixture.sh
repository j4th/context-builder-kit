#!/usr/bin/env bash
# Fixture for finish-ab/run-arms-headless.py, hermetic: a throwaway `git init` repository under mktemp, and a fake
# `claude` first on PATH. The fake reads a per-arm plan — one step per invocation: `done:<cost>` writes PR_BODY.md and
# returns a structured result, `slowdone:<cost>` does the same after a pause, `early:<cost>` returns none (a turn that
# ended early), `fail:<cost>` exits 1 with an error_max_budget_usd payload, `donefail:<cost>` does what `done` does and
# then exits 1 — and logs every argv it was given, the CLAUDE* names in its environment, and whether every arm's
# worktree_setup had run before it started. Asserts the refusals made before anything is created, the first
# invocation's recorded --session-id, the strict MCP default and the deny list, cost as the latest cumulative total
# (never a sum), a failed invocation not continued, resume past an empty payload and past a killed first invocation,
# the floor label, the budget and continuation caps, and the worktree the judges are given; `--dry-run` prints each
# arm's argv, which carries the deny list and a strict MCP config naming no server; an `mcp_config` naming any server
# but context7 and time — one with a write tool, or one the runner does not know — is refused before any worktree is
# created; every config refusal — a missing key, an arm count outside two to four or an arm that is not an object, a
# shared anon id, an arm lacking a field, a malformed `also`, an mcp_config that is not JSON, a malformed
# check_command or worktree_setup, no `claude` on PATH — exits 2 creating nothing; an arm complete by its artifacts
# whose last invocation failed is judged with the failure in its notes; an arm with no recoverable session id is not
# resumed; no CLAUDE* variable of the launching session reaches an arm; no run leaves a file open (a ResourceWarning
# in the runner's output fails); a `check_command` runs once per complete arm, one at a time, after every arm has
# finished — its log and exit reach the result the judges read, and an incomplete arm is not checked; and
# `worktree_setup` runs in every new worktree before any arm starts, a failing command stopping the run before any
# arm is paid for (context-builder-kit#69). Needs bash, git and python3; spends nothing.
# Run: bash .claude/workflows/tests/run-arms-headless-fixture.sh
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
runner="$here/../finish-ab/run-arms-headless.py"
[ -f "$runner" ] || { echo "FAIL: .claude/workflows/finish-ab/run-arms-headless.py is missing (python3 would exit 2 on it, which case 1 would read as a refusal)"; exit 1; }
t=$(mktemp -d)
trap 'rm -rf "$t"' EXIT
mkdir -p "$t/bin" "$t/fake"
cat > "$t/bin/claude" <<'EOF'
#!/usr/bin/env python3
import glob, json, os, sys, time
d = os.environ['FAKE_DIR']
anon = os.path.basename(os.getcwd())[len('eval-'):]
with open(f'{d}/argv-{anon}.jsonl', 'a') as f:
    f.write(json.dumps(sys.argv[1:]) + '\n')
with open(f'{d}/env-{anon}.json', 'w') as f:  # what reached the arm: every CLAUDE* name in its environment
    json.dump(sorted(k for k in os.environ if k.startswith('CLAUDE')), f)
with open(f'{d}/setup-seen-{anon}', 'w') as f:  # had worktree_setup run in EVERY arm's worktree before this arm started?
    f.write('yes' if all(os.path.exists(os.path.join(w, '.setup-ran')) for w in glob.glob('../eval-*')) else 'no')
with open(f'{d}/plan-{anon}') as f:
    plan = f.read().split()
step, rest = plan[0], plan[1:]
with open(f'{d}/plan-{anon}', 'w') as f:
    f.write('\n'.join(rest))
kind, cost = step.split(':')
if kind == 'slowdone':  # finishes after the other arm has, so a check run per arm as it finishes would see it unfinished
    time.sleep(1.5)
    kind = 'done'
a = sys.argv
sid = a[a.index('--resume') + 1] if '--resume' in a else a[a.index('--session-id') + 1]
p = {'session_id': sid, 'total_cost_usd': float(cost), 'is_error': False, 'subtype': 'success', 'result': 'ok'}
if kind in ('done', 'donefail'):
    with open('PR_BODY.md', 'w') as f:
        f.write('body\n')
    p['structured_output'] = {'branch': 'b', 'worktree': '/elsewhere' if anon == 'P' else '.', 'commits': [], 'plan_path': 'PLAN.md',
                              'pr_body_path': 'PR_BODY.md', 'check_command': 'c', 'check_exit': 0, 'tests_written': [],
                              'skills_invoked': [], 'operational': [], 'gate_calls': [], 'dispatched': [],
                              'handoff': 'h', 'notes': ''}
elif kind == 'fail':
    p.update(is_error=True, subtype='error_max_budget_usd', result='Reached the maximum budget')
    print(json.dumps(p))
    sys.exit(1)
print(json.dumps(p))
sys.exit(1 if kind == 'donefail' else 0)
EOF
chmod +x "$t/bin/claude"
export PATH="$t/bin:$PATH" FAKE_DIR="$t/fake"

repo="$t/repo"
git init -q -b main "$repo"
git -C "$repo" -c user.email=f@x -c user.name=f commit -q --allow-empty -m base
base=$(git -C "$repo" rev-parse HEAD)
cfg() {  # cfg <name> <out_dir> [max_budget] [max_continuations]
  printf '{"repo":"o/r","issue":1,"base":"%s","brief":"/b.md","worktree_root":"%s/.wt","out_dir":"%s","max_budget_usd":%s,"max_continuations":%s,"arms":[{"anon":"P","read":"f.md","model":"opus","effort":"high"},{"anon":"Q","read":"f.md","model":"opus","effort":"medium"}]}' \
    "$base" "$repo" "$2" "${3:-10}" "${4:-3}" > "$t/$1.json"
}
fail() { echo "FAIL: $1"; printf '%s\n' "$out" | sed 's/^/  | /'; exit 1; }
# Every run also watches for an unclosed file: with ResourceWarning enabled, a file the runner opened and
# never closed shows in its output, and fails the fixture (a code-quality review found the config, mcp_config and
# payload reads unclosed; context-builder-kit#69).
run() {
  rc=0; out=$(cd "$repo" && PYTHONWARNINGS=always::ResourceWarning python3 -B "$runner" "$@" 2>&1) || rc=$?
  ! grep -q 'ResourceWarning' <<<"$out" || fail "the runner left a file open (ResourceWarning in its output)"
}
argv() { sed -n "${2}p" "$t/fake/argv-$1.jsonl"; }
reset() { rm -rf "$t/fake"/* "$repo/.wt"; git -C "$repo" worktree prune; }

# 1. A mistyped flag is refused before anything is created.
cfg c1 "$t/out1"
run "$t/c1.json" --dryrun
[ "$rc" -eq 2 ] && [ ! -e "$repo/.wt" ] || fail "an unknown flag must exit 2 and create no worktree (rc=$rc)"

# 2. A fresh run: P finishes first time; Q ends early, then finishes on its one continuation.
printf 'done:2.00\n' > "$t/fake/plan-P"; printf 'early:1.00\ndone:2.50\n' > "$t/fake/plan-Q"
run "$t/c1.json"
[ "$rc" -eq 0 ] || fail "two arms that finish must exit 0 (rc=$rc)"
python3 - "$t/out1" "$repo/.wt" "$t/fake" <<'EOF' || exit 1
import json, os, sys
out, wtroot, fake = sys.argv[1:]
ex = {e['anon']: e['result'] for e in json.load(open(f'{out}/executed.json'))}
bad = []
if sorted(ex) != ['P', 'Q']: bad.append(f'executed.json holds {sorted(ex)}, not P and Q')
for anon in ('P', 'Q'):
    calls = [json.loads(l) for l in open(f'{fake}/argv-{anon}.jsonl')]
    sid = json.load(open(f'{out}/{anon}.cmd'))['session_id']
    first = calls[0]
    if first[first.index('--session-id') + 1] != sid: bad.append(f'{anon}: the first invocation is not given the recorded --session-id')
    for c in calls:
        if '--strict-mcp-config' not in c or not os.path.exists(c[c.index('--mcp-config') + 1]):
            bad.append(f'{anon}: an invocation ran without --strict-mcp-config and an existing --mcp-config')
        if 'mcp__linear__*' not in c or 'Bash(git * push)' not in c: bad.append(f'{anon}: the deny list lost a rule')
    if ex[anon]['worktree'] != os.path.join(wtroot, f'eval-{anon}'):
        bad.append(f"{anon}: the judges would read worktree {ex[anon]['worktree']!r}, not the runner's own path")
q = [json.loads(l) for l in open(f'{fake}/argv-Q.jsonl')]
if len(q) != 2 or q[1][q[1].index('--resume') + 1] != json.load(open(f'{out}/Q.cmd'))['session_id']:
    bad.append('Q: the continuation does not resume the recorded session')
if '--append-system-prompt' not in q[1]: bad.append('Q: the continuation dropped the turn-ending paragraph')
if 'total_cost_usd $2.5 for' not in ex['Q']['notes']: bad.append(f"Q: cost must be the latest total ($2.5), never a sum ($3.5): {ex['Q']['notes']!r}")
if "reported worktree '/elsewhere'" not in ex['P']['notes']: bad.append('P: a worktree the arm reported elsewhere is not noted')
if 'reported worktree' in ex['Q']['notes']: bad.append("Q: '.' is the arm's own worktree and must not be noted as different")
if bad:
    print('FAIL: ' + '\n  '.join(bad)); sys.exit(1)
EOF

# 3. A reused out_dir and an existing worktree are both refused, and nothing new is created.
run "$t/c1.json"
[ "$rc" -eq 1 ] && grep -q "refusing to write into" <<<"$out" && grep -q "refusing to reuse" <<<"$out" || fail "a stale out_dir and worktree must both be named and refused (rc=$rc)"
reset  # the stale out_dir alone, with no worktree left, is still refused
run "$t/c1.json"
[ "$rc" -eq 1 ] && grep -q "refusing to write into" <<<"$out" && [ ! -e "$repo/.wt" ] || fail "a stale out_dir alone must be refused before any worktree is created (rc=$rc)"

# 4. A failed invocation is reported with its subtype and not continued.
reset; cfg c4 "$t/out4"
printf 'fail:1.00\n' > "$t/fake/plan-P"; printf 'done:1.00\n' > "$t/fake/plan-Q"
run "$t/c4.json"
[ "$rc" -eq 1 ] || fail "a dropped arm must exit 1 (rc=$rc)"
[ "$(wc -l < "$t/fake/argv-P.jsonl")" -eq 1 ] || fail "a failed invocation was continued"
grep -q "P: incomplete .*error_max_budget_usd (exit 1)" <<<"$out" || fail "the drop line does not name the failure"

# 5. Resume past a killed first invocation (empty P.json: the recorded --session-id) and past an empty continuation
#    (Q.cont1.json: numbered after it, never overwritten); the spend before each is labelled a floor.
: > "$t/out4/P.json"; printf 'done:3.00\n' > "$t/fake/plan-P"
rm -f "$repo/.wt/eval-Q/PR_BODY.md"
printf '{"session_id":"sQ","total_cost_usd":1.0,"is_error":false}\n' > "$t/out4/Q.json"; : > "$t/out4/Q.cont1.json"
printf 'done:2.00\n' > "$t/fake/plan-Q"; : > "$t/fake/argv-P.jsonl"; : > "$t/fake/argv-Q.jsonl"
run "$t/c4.json" --resume-existing
[ "$rc" -eq 0 ] || fail "both arms must finish on resume (rc=$rc)"
grep -q -- "\"--resume\", \"$(python3 -c "import json;print(json.load(open('$t/out4/P.cmd'))['session_id'])")\"" "$t/fake/argv-P.jsonl" || fail "P did not resume the session recorded before its killed first invocation"
[ -s "$t/out4/P.cont1.json" ] || fail "P's continuation is not numbered 1"
grep -q -- '"--resume", "sQ"' "$t/fake/argv-Q.jsonl" && [ -s "$t/out4/Q.cont2.json" ] && [ ! -s "$t/out4/Q.cont1.json" ] || fail "Q did not resume past its empty cont1 as cont2"
grep -q "Q: an earlier invocation left no payload, so \$1.00 spent is a floor" <<<"$out" || fail "the floor is not announced"

# 6. An arm that has spent its cap is not continued, and says why.
reset; cfg c6 "$t/out6" 10
mkdir -p "$repo/.wt/eval-P" "$repo/.wt/eval-Q" "$t/out6"
for a in P Q; do printf '{"session_id":"s%s"}\n' "$a" > "$t/out6/$a.cmd"; printf '{"session_id":"s%s","total_cost_usd":10.0,"is_error":false}\n' "$a" > "$t/out6/$a.json"; done
run "$t/c6.json" --resume-existing
[ ! -e "$t/fake/argv-P.jsonl" ] && grep -q "P: incomplete .*spent its cap (\$10.00)" <<<"$out" || fail "an arm at its cap must not be continued, and must say so"

# 7. max_continuations bounds a pass, and the drop line says so.
reset; rm -rf "$t/out6"; cfg c7 "$t/out7" 10 1
printf 'early:1.00\nearly:2.00\n' > "$t/fake/plan-P"; printf 'done:1.00\n' > "$t/fake/plan-Q"
run "$t/c7.json"
[ "$(wc -l < "$t/fake/argv-P.jsonl")" -eq 2 ] && grep -q "P: incomplete .*reached max_continuations (1)" <<<"$out" || fail "the continuation cap is not applied or not reported"

# 8. --dry-run prints each arm's first argv: the deny list, --strict-mcp-config, and a default MCP config that names no
#    server, with the arm's worktree_setup (none here). Nothing is created and nothing is spent.
reset; rm -rf "$t/out7"; cfg c8 "$t/out8"
run "$t/c8.json" --dry-run
[ "$rc" -eq 0 ] && [ ! -e "$repo/.wt" ] || fail "--dry-run must exit 0 and create no worktree (rc=$rc)"
[ ! -e "$t/fake/argv-P.jsonl" ] || fail "--dry-run invoked claude"
python3 - "$out" <<'EOF' || exit 1
import json, sys
lines = [json.loads(l) for l in sys.argv[1].splitlines() if l.startswith('{"anon"')]
bad = []
if sorted(l['anon'] for l in lines) != ['P', 'Q']: bad.append(f'expected one argv line per arm, got {[l.get("anon") for l in lines]}')
want = ['Bash(git push *)', 'Bash(git * push *)', 'Bash(git * push)', 'mcp__github__*', 'mcp__plugin_github_github__*',
        'mcp__linear__*', 'mcp__plugin_linear_linear__*', 'mcp__notion__*', 'mcp__plugin_Notion_notion__*',
        'mcp__claude_ai_*', 'Bash(gh api *)', 'Bash(gh pr merge *)', 'Bash(gh issue comment *)']
for l in lines:
    a = l['argv']
    if a[:2] != ['claude', '-p']: bad.append(f"{l['anon']}: argv does not start with claude -p")
    if '--strict-mcp-config' not in a: bad.append(f"{l['anon']}: no --strict-mcp-config")
    with open(a[a.index('--mcp-config') + 1]) as f:
        servers = json.load(f).get('mcpServers')
    if servers != {}: bad.append(f"{l['anon']}: the default MCP config must name no server, got {servers!r}")
    deny = a[a.index('--disallowedTools') + 1:]
    missing = [w for w in want if w not in deny]
    if missing: bad.append(f"{l['anon']}: the deny list lacks {missing}")
    # `git push *` is a sole trailing wildcard, so it already denies the bare `git push`; `git * push *` has two, so it
    # needs `git * push` beside it. The pair is pinned above, and the redundant bare rule stays out.
    if 'Bash(git push)' in deny: bad.append(f"{l['anon']}: the deny list carries the redundant bare Bash(git push)")
    if '--permission-mode' not in a or a[a.index('--permission-mode') + 1] != 'auto': bad.append(f"{l['anon']}: not in auto mode")
    if l.get('setup') != []: bad.append(f"{l['anon']}: a config with no worktree_setup must print setup [], got {l.get('setup')!r}")
if bad:
    print('FAIL: ' + '\n  '.join(bad)); sys.exit(1)
EOF

# 9. An mcp_config naming a server with a write tool is refused before anything is created; context7 and time are not.
printf '{"mcpServers":{"context7":{"command":"npx"},"github":{"command":"npx"}}}' > "$t/mcp-write.json"
printf '{"mcpServers":{"context7":{"command":"npx"},"time":{"command":"uvx"}}}' > "$t/mcp-read.json"
python3 -c "import json,sys; c=json.load(open(sys.argv[1])); c['mcp_config']=sys.argv[2]; json.dump(c, open(sys.argv[3],'w'))" "$t/c8.json" "$t/mcp-write.json" "$t/c9w.json"
python3 -c "import json,sys; c=json.load(open(sys.argv[1])); c['mcp_config']=sys.argv[2]; c['out_dir']=sys.argv[4]; json.dump(c, open(sys.argv[3],'w'))" "$t/c8.json" "$t/mcp-read.json" "$t/c9r.json" "$t/out9r"
run "$t/c9w.json" --dry-run
[ "$rc" -eq 2 ] && grep -q "github" <<<"$out" && [ ! -e "$repo/.wt" ] || fail "an mcp_config naming github must be refused with exit 2, naming it (rc=$rc)"
run "$t/c9r.json" --dry-run
[ "$rc" -eq 0 ] || fail "an mcp_config naming only context7 and time must be accepted (rc=$rc)"
# The gate is an allowlist: a read-only server outside it, and one this runner has never heard of, are refused too.
for srv in fetch my-own-server; do
  printf '{"mcpServers":{"context7":{"command":"npx"},"%s":{"command":"npx"}}}' "$srv" > "$t/mcp-$srv.json"
  python3 -c "import json,sys; c=json.load(open(sys.argv[1])); c['mcp_config']=sys.argv[2]; json.dump(c, open(sys.argv[3],'w'))" "$t/c8.json" "$t/mcp-$srv.json" "$t/c9-$srv.json"
  run "$t/c9-$srv.json" --dry-run
  [ "$rc" -eq 2 ] && grep -q -- "$srv" <<<"$out" && [ ! -e "$repo/.wt" ] || fail "an mcp_config naming $srv must be refused with exit 2, naming it (rc=$rc)"
done

# 10. An arm that is not an object is refused as a config error, before anything is created — never a traceback.
python3 -c "import json,sys; c=json.load(open(sys.argv[1])); c['arms'][0]='P'; json.dump(c, open(sys.argv[2],'w'))" "$t/c8.json" "$t/c10.json"
run "$t/c10.json" --dry-run
[ "$rc" -eq 2 ] && grep -q "^config: arms is a list of two to four objects" <<<"$out" && [ ! -e "$repo/.wt" ] || fail "an arm that is not an object must be refused with exit 2 and the config message (rc=$rc)"

# 11. Every other config refusal, made before anything is created: a missing key, one or five arms, a shared anon id,
#     an arm lacking a field or holding a malformed `also`, an mcp_config that is not JSON, and no `claude` on PATH.
bad_cfg() {  # bad_cfg <name> <a python statement on the config c>
  python3 -c "import json,sys; c=json.load(open(sys.argv[1])); $2; json.dump(c, open(sys.argv[2],'w'))" "$t/c8.json" "$t/$1.json"
}
refused() {  # refused <name> <an ERE the message matches> [a runner flag]
  run "$t/$1.json" ${3:-}
  [ "$rc" -eq 2 ] && grep -qE -- "$2" <<<"$out" && [ ! -e "$repo/.wt" ] || fail "$1: must be refused with exit 2 and /$2/, creating nothing (rc=$rc)"
}
bad_cfg c11a "del c['brief']"; refused c11a '^config: brief is required' --dry-run
bad_cfg c11b "c['arms']=c['arms'][:1]"; refused c11b '^config: arms is a list of two to four objects' --dry-run
bad_cfg c11c "c['arms']=[dict(c['arms'][0], anon=a) for a in 'PQRST']"; refused c11c '^config: arms is a list of two to four objects' --dry-run
bad_cfg c11d "c['arms'][1]['anon']='P'"; refused c11d '^config: the arms need distinct anon ids' --dry-run
bad_cfg c11e "del c['arms'][1]['model']"; refused c11e "^config: arm 'Q' lacks model" --dry-run
bad_cfg c11f "c['arms'][1]['also']='x.md'"; refused c11f "^config: arm 'Q' lacks also" --dry-run
printf 'not json' > "$t/mcp-bad.json"
bad_cfg c11g "c['mcp_config']='$t/mcp-bad.json'"; refused c11g '^config: mcp_config .* could not be read as an MCP config' --dry-run
bad_cfg c11h "c['check_command']=3"; refused c11h '^config: check_command is a shell command string' --dry-run
bad_cfg c11i "c['worktree_setup']='mise trust'"; refused c11i '^config: worktree_setup is a list of shell commands' --dry-run
mkdir -p "$t/pyonly"; ln -sf "$(command -v python3)" "$t/pyonly/python3"
rc=0; out=$(cd "$repo" && PATH="$t/pyonly" python3 -B "$runner" "$t/c8.json" 2>&1) || rc=$?
[ "$rc" -eq 2 ] && grep -q '^claude is not on PATH' <<<"$out" && [ ! -e "$repo/.wt" ] || fail "no claude on PATH must be refused with exit 2 before anything is created (rc=$rc)"

# 12. An arm whose last invocation failed after meeting the completion condition (PR_BODY.md and a structured result)
#     is judged, and the failure travels with it: into its notes, which the judges read, and onto the runner's line.
reset; cfg c12 "$t/out12"
printf 'donefail:2.00\n' > "$t/fake/plan-P"; printf 'done:1.00\n' > "$t/fake/plan-Q"
run "$t/c12.json"
[ "$rc" -eq 0 ] && grep -q "P: complete .*its last invocation failed: success (exit 1)" <<<"$out" || fail "an arm complete by its artifacts but whose last invocation failed must be judged, its line naming the failure (rc=$rc)"
python3 -c "import json,sys; ex={e['anon']: e['result'] for e in json.load(open(sys.argv[1]))}; sys.exit(0 if 'its last invocation failed' in ex['P']['notes'] and 'failed' not in ex['Q']['notes'] else 1)" "$t/out12/executed.json" \
  || fail "P's notes must carry its last invocation's failure, and Q's must not"

# 13. On --resume-existing, an arm with no recoverable session id — an empty <anon>.cmd, and no payload that parsed — is
#     not continued, and the drop line says why.
reset; cfg c13 "$t/out13"
mkdir -p "$repo/.wt/eval-P" "$repo/.wt/eval-Q" "$t/out13"
for a in P Q; do : > "$t/out13/$a.cmd"; : > "$t/out13/$a.json"; done
run "$t/c13.json" --resume-existing
[ "$rc" -eq 1 ] && [ ! -e "$t/fake/argv-P.jsonl" ] && grep -q "P: incomplete .*no session id is recoverable" <<<"$out" \
  || fail "an arm with no recoverable session id must not be continued, and must say so (rc=$rc)"

# 14. The launching session's CLAUDE* environment never reaches an arm, and the runner names what it stripped; the rest
#     of the environment does (the fake reads FAKE_DIR from it).
reset; cfg c14 "$t/out14"
printf 'done:1.00\n' > "$t/fake/plan-P"; printf 'done:1.00\n' > "$t/fake/plan-Q"
rc=0; out=$(cd "$repo" && CLAUDE_PROBE=leaked python3 -B "$runner" "$t/c14.json" 2>&1) || rc=$?
[ "$rc" -eq 0 ] && grep -q "stripped from the arms' environment: .*CLAUDE_PROBE" <<<"$out" \
  && [ "$(cat "$t/fake/env-P.json")" = "[]" ] && [ "$(cat "$t/fake/env-Q.json")" = "[]" ] \
  || fail "no CLAUDE* variable may reach an arm, and the stripped ones are named (rc=$rc; P saw $(cat "$t/fake/env-P.json" 2>/dev/null))"

# 15. check_command: run once per complete arm, one at a time (a lock the check takes would collide), after EVERY arm has
#     finished (Q's payload is non-empty when P's check runs, though P finished first), and after executed.json is
#     written (a hung or interrupted check must not lose the paid arms' record), into <anon>.check.log, with the exit on
#     the runner's line and in the result's runner_check and notes.
reset; cfg c15 "$t/out15"
chk='echo "gate in ${PWD##*/}"; echo "${PWD##*/}" >> "$FAKE_DIR/checks"; mkdir "$FAKE_DIR/lock" || exit 8; sleep 0.3; rmdir "$FAKE_DIR/lock"; [ -s "'"$t/out15"'/Q.json" ] || { echo "Q had not finished"; exit 9; }; [ -s "'"$t/out15"'/executed.json" ] || { echo "executed.json not written before the checks"; exit 7; }; [ "${PWD##*/}" = eval-P ] && exit 3; exit 0'
python3 -c "import json,sys; c=json.load(open(sys.argv[1])); c['check_command']=sys.argv[2]; json.dump(c, open(sys.argv[1],'w'))" "$t/c15.json" "$chk"
printf 'done:1.00\n' > "$t/fake/plan-P"; printf 'slowdone:1.00\n' > "$t/fake/plan-Q"
run "$t/c15.json"
[ "$rc" -eq 0 ] && grep -q "^P: check task exit 3" <<<"$out" && grep -q "^Q: check task exit 0" <<<"$out" \
  || fail "each complete arm's check task runs after every arm finished, one at a time, its exit on the runner's line (rc=$rc)"
[ "$(wc -l < "$t/fake/checks")" -eq 2 ] || fail "the check task must run exactly once per complete arm (ran $(wc -l < "$t/fake/checks") times)"
grep -q 'gate in eval-P' "$t/out15.checks/P.check.log" && grep -q 'gate in eval-Q' "$t/out15.checks/Q.check.log" || fail "each arm's check output must land in <out_dir>.checks/<anon>.check.log"
# The log directory is the one path a judge is given; it must hold nothing but the logs — never an arm's .cmd (its argv
# names the arm's instruction files and effort), payload or executed.json, which would unblind the panel.
[ "$(ls "$t/out15.checks" | sort | tr '\n' ' ')" = "P.check.log Q.check.log " ] || fail "the check-log directory must hold only the check logs (got: $(ls "$t/out15.checks" 2>&1 | tr '\n' ' '))"
python3 - "$t/out15" <<'EOF' || exit 1
import json, sys
out = sys.argv[1]
ex = {e['anon']: e['result'] for e in json.load(open(f'{out}/executed.json'))}
bad = []
for anon, want in (('P', 3), ('Q', 0)):
    got = ex[anon].get('runner_check') or {}
    if got.get('exit') != want or got.get('log') != f'{out}.checks/{anon}.check.log' or not got.get('command'):
        bad.append(f'{anon}: runner_check is {got!r}')
    if f'exit {want}' not in ex[anon]['notes']: bad.append(f'{anon}: the notes do not carry the check exit')
if bad:
    print('FAIL: ' + '\n  '.join(bad)); sys.exit(1)
EOF
# ... and an incomplete arm is not checked.
reset; cfg c15b "$t/out15b" 10 0
python3 -c "import json,sys; c=json.load(open(sys.argv[1])); c['check_command']='echo x >> \"\$FAKE_DIR/checks\"'; json.dump(c, open(sys.argv[1],'w'))" "$t/c15b.json"
printf 'done:1.00\n' > "$t/fake/plan-P"; printf 'early:1.00\n' > "$t/fake/plan-Q"
run "$t/c15b.json"
[ "$rc" -eq 1 ] && [ "$(wc -l < "$t/fake/checks")" -eq 1 ] && [ ! -e "$t/out15b.checks/Q.check.log" ] \
  || fail "an incomplete arm must not be checked; the complete one must (rc=$rc)"

# 16. worktree_setup runs in each new worktree, in order, before ANY arm starts (every arm saw every worktree set up).
reset; cfg c16 "$t/out16"
python3 -c "import json,sys; c=json.load(open(sys.argv[1])); c['worktree_setup']=['touch .setup-ran', 'echo \"\${PWD##*/}\" >> \"\$FAKE_DIR/setup\"']; json.dump(c, open(sys.argv[1],'w'))" "$t/c16.json"
printf 'done:1.00\n' > "$t/fake/plan-P"; printf 'done:1.00\n' > "$t/fake/plan-Q"
run "$t/c16.json"
[ "$rc" -eq 0 ] && [ "$(sort "$t/fake/setup" | tr '\n' ' ')" = "eval-P eval-Q " ] \
  && [ "$(cat "$t/fake/setup-seen-P")" = yes ] && [ "$(cat "$t/fake/setup-seen-Q")" = yes ] \
  || fail "worktree_setup must run once in each new worktree, in order, before any arm starts (rc=$rc)"

# 17. A worktree_setup command that fails stops the run before any arm is started, naming the command and the
#     worktrees already created.
reset; cfg c17 "$t/out17"
python3 -c "import json,sys; c=json.load(open(sys.argv[1])); c['worktree_setup']=['exit 5']; json.dump(c, open(sys.argv[1],'w'))" "$t/c17.json"
printf 'done:1.00\n' > "$t/fake/plan-P"; printf 'done:1.00\n' > "$t/fake/plan-Q"
run "$t/c17.json"
[ "$rc" -eq 1 ] && grep -q 'worktree_setup: `exit 5` exited 5 in' <<<"$out" && grep -q "$repo/.wt/eval-P" <<<"$out" \
  && [ ! -e "$t/fake/argv-P.jsonl" ] && [ ! -e "$t/fake/argv-Q.jsonl" ] \
  || fail "a failing worktree_setup command must stop the run before any arm starts, naming it and the worktrees created (rc=$rc)"

echo "run-arms-headless-fixture: ok"
