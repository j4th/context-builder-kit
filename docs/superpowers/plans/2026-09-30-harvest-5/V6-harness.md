# Harvest 5 — V6: Harness code

**Scope.** This cluster closes issue #69's harness items and comments (D45), with the harness halves of D49's cost items and D51's two table diffs. It lands, in four commits: `agent-cost.py` keyed by model version, with the verification block's price diff re-keyed and a new `CACHE_READ` diff (V6.1); `finish-ab.js` generalised to two to four arms, with a Latin-square panel, `executed` mode, the `base`/`brief`/`rubric` arguments, the runner's check log in the judges' prompt and the judges' read-only clause (V6.2); the headless runner `run-arms-headless.py` and its hermetic fixture, with the optional `worktree_setup` list in place of an unconditional trust step (V6.3); and the rubric and brief with no arm count (V6.4). Every file is ported from the private target's merged form — a strict superset of `j4th/echosphere`'s, which supersets `j4th/you-are-hear` PR #90's — and re-authored onto the kit's text: no project task names, no project MCP servers beyond the allowlist constant (`context7`, `time`), no project ticket or PR mentions, every kit self-citation in the `context-builder-kit#N` form. The trace rows closed are the `V6` rows of `docs/superpowers/specs/2026-09-30-harvest-5-trace.md` (`#69/body/finish-ab/*`, `#69/body/cost/*`, `#69/body/H1`–`H7`, the `#69/c…` comment rows, `critic/19`, `critic/20`) and the V6-owned parts of V5's `#69/body/T8`, `F5`, `S6`, `S8`, `S10`, `#69/c5881157875/2c`, `#58/c5901493591/R9` and V10's `release/5`; § Coverage maps every one. **Consumes from earlier clusters:** V1's sentinel line `echo "verification: kit sub-block complete"` (new kit-sub-block checks go immediately before it); V5's probe P2 result in `.claude/rules/pr-review.md` § The floor (a workflow agent has no Agent tool); V5's read-only-agents rule in `.claude/rules/orchestration.md` § Fan-out discipline; and V5's two hand-offs into `orchestration-reference.md` (V5 § Handed to other clusters, items 1 and 2): the per-version prices bullet, which V6.1 inserts directly after V5.3's **Price steps** bullet (V6.1's Interfaces say exactly how), and the headless runner's exemplar sub-bullet, which V6.3 inserts under the `finish-ab/` line V5.6 leaves in § Applied instances › Shipped exemplars. It also lands `review/portability/67` (handed from V9): the re-keyed list-price diff lowercases with `tr`, never `sed`'s GNU-only `\L`. V6 adds **no always-loaded bytes**: every rule text it edits is a path-scoped reference half, so each task's runner output shows the same `always-loaded total` it showed before the task.

Every task here was dry-run on a scratch copy of the kit at `643f7ff` in order (V6.1 → V6.4): each red run printed the line quoted in its step, and the block was green after each. Paths are relative to `/home/j4th/Code/create/context-builder-kit`; run every command from there. Line numbers are orientation only; every edit anchors on text.

---

### Task V6.1: `agent-cost.py` prices by model version; the block diffs `PRICE` and `CACHE_READ` (#69/body/cost/{version-keys, cache-read, block-diff, fixture-rows, synthetic, fast-mode}, #69/c5859756889/{1a, 1b, 2d, 2g}, #69/c5881157875/{2-fable5-misprice, 2-version-keys-fix}, #69/c5892402564/{cost-1, cost-2, cost-3, cost-4, transcripts}, #69/c5901496433/6, critic/19, critic/20; D49, D51)

**Closes (trace rows, in full):** `#69/body/cost/version-keys`, `#69/body/cost/cache-read`, `#69/body/cost/block-diff`, `#69/body/cost/fixture-rows`, `#69/body/cost/synthetic`, `#69/body/cost/fast-mode`, `#69/c5859756889/1a`, `#69/c5859756889/1b` (the agent-cost half), `#69/c5859756889/2d`, `#69/c5859756889/2g`, `#69/c5881157875/2-fable5-misprice`, `#69/c5881157875/2-version-keys-fix`, `#69/c5892402564/cost-1`, `#69/c5892402564/cost-2`, `#69/c5892402564/cost-3`, `#69/c5892402564/cost-4`, `#69/c5892402564/transcripts`, `#69/c5901496433/6`, `critic/19`, `critic/20`; and the parts in V6's files of `#69/body/T8` (code, and the bullet on V5's behalf), `#69/body/F5`, `#69/c5881157875/2c`, `#69/c5881157875/2d` (V5's trace row for the version keys and the `CACHE_READ` drift check, whose landing V5 hands here with `#69/body/T8` — see Interfaces), `#58/c5901493591/R9` (the docstring half), `release/5` (`agent-cost.py`'s bare citation); `review/portability/67` (handed from V9: the price diff's lowercasing, made portable).

**Files:**
- Modify: `.claude/workflows/agent-cost.py` (whole file rewritten)
- Modify: `.claude/workflows/tests/agent-cost-fixture.sh` (whole file rewritten)
- Modify: `.claude/rules/cbk-conventions-reference.md` — § Verification: the list-price diff (replaced in place, lowercasing portably) and the new cache-read diff (appended at the kit sentinel)
- Modify: `.claude/rules/orchestration-reference.md` — § Generation notes — the sources: the ladder bullet's family pricing sentence is deleted and a new **Prices, per version** bullet goes directly after V5.3's **Price steps** bullet (V5's region, landed here on V5's behalf — V5 § Handed to other clusters, item 1; see Interfaces)

**Interfaces:**
- **Consumes (from V5, hand-off in).** `PRICE`, `CACHE_READ` and the reference half's quoted prices are one fact with three copies, and the block diffs them, so all three change in one commit (`#69/body/T8`'s hazard) — this one. V6 runs after V5, so this task anchors on § Generation notes — the sources as V5 leaves it (V5 § Handed to other clusters, item 1). V5.3 rewrites the ladder bullet but keeps, byte for byte, its family sentence `Pricing row, per MTok in/out: Fable 5.1 $10/$50, Opus 5 $5/$25, Sonnet 5 $2/$10, Haiku 4.5 $1/$5 (same page). ` (one trailing space) directly before `"You pay for completed tasks, though, …`, and adds three bullets after the ladder: **Price steps** (the steps and Sonnet 5's footnote, `#69/c5881157875/2-steps`, `2-sonnet5`), **Aliases, by provider and by version**, and the mechanical tier's floor. V5.4 replaces the bullet that began `` - **The `high` default** — `` with one that begins `- **The default effort is per model and per surface** (fetched 2026-09-30):`, so that old label is gone and is no anchor. This task deletes the family sentence and inserts the **Prices, per version** bullet written below directly after the **Price steps** bullet — that is, immediately before the line beginning `- **Aliases, by provider and by version** (`, which is unique after V5. The bullet is V5's content for `#69/body/T8` and `#69/c5881157875/2d`, which V5 writes nowhere itself (it writes the cache-read quotation nowhere, and its **Price steps** bullet states only the step ratios and the input price at each rung, not the per-version in/out table): the prices are the pricing page's model table and the cache sentences are a verbatim quotation of it, so any verbatim rendering is byte-identical. V5 writes no other `Word N.N $a/$b` string in `orchestration-reference.md` (the list-price diff reads every one; V5.3's steps read `Haiku 4.5 at $1`, and its footnote quotes `$3/$15` after `increase to`, neither of which the diff's pattern matches). If Step 1 finds the text in any other state, stop and reconcile with V5's landed text (master plan § Global Constraints, anchor rule); do not guess.
- **Consumes (from V1).** The line `echo "verification: kit sub-block complete"` in `cbk-conventions-reference.md` § Verification; the cache-read diff goes on the lines immediately before it.
- **Produces.** In `agent-cost.py`: `PRICE` keyed by the eight version ids `claude-fable-5-1`, `claude-fable-5`, `claude-mythos-5-1`, `claude-opus-5-5`, `claude-opus-5`, `claude-sonnet-5-5`, `claude-sonnet-5`, `claude-haiku-4-5`; `CACHE_READ` keyed `claude-fable-5-1: 0.025`, `claude-mythos-5-1: 0.025`, `claude-opus-5-5: 0.05`; `CACHE_READ_DEFAULT = 0.1`; `tier(model)` matching a key whole (optional `-YYYYMMDD` and `[variant]` suffixes; `[speed=…]` never matches). In the reference half: the bullet starting `- **Prices, per version**`, which the block's `pr=` and `cr=` extractions parse. In the block: the variables `pk`, `pr`, `ck`, `cr` and their two diffs. V10's CHANGELOG sync note consumes the fact that every target synced at `74edf84` prices legacy Fable 5 cache reads at 0.025x (`#69/c5881157875/2-fable5-misprice`).

- [ ] **Step 1: Preconditions — the anchors this task edits are present and unchanged**

Run:
```bash
grep -cF 'Pricing row, per MTok in/out: Fable 5.1 $10/$50, Opus 5 $5/$25, Sonnet 5 $2/$10, Haiku 4.5 $1/$5 (same page). ' .claude/rules/orchestration-reference.md
grep -cF 'Pricing row, per MTok in/out: Fable 5.1 $10/$50, Opus 5 $5/$25, Sonnet 5 $2/$10, Haiku 4.5 $1/$5 (same page). "You pay for completed tasks, though, ' .claude/rules/orchestration-reference.md
grep -cF -- '- **Prices, per version**' .claude/rules/orchestration-reference.md
grep -cF -- '- **Price steps** (`platform.claude.com/docs/en/about-claude/pricing` § Model pricing, fetched 2026-09-30) — ' .claude/rules/orchestration-reference.md
grep -cF -- '- **Aliases, by provider and by version** (' .claude/rules/orchestration-reference.md
grep -cF -- '- **The `high` default** — ' .claude/rules/orchestration-reference.md
grep -cF -- '- **The default effort is per model and per surface** (fetched 2026-09-30):' .claude/rules/orchestration-reference.md
grep -cF 'cache hit costs' .claude/rules/orchestration-reference.md
grep -cF "# The list-price table has two copies — the cost reader's PRICE and the reference half's quoted pricing" .claude/rules/cbk-conventions-reference.md
grep -cxF 'echo "verification: kit sub-block complete"' .claude/rules/cbk-conventions-reference.md
bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep 'always-loaded total'
```
Expected: `1`, `1`, `0`, `1`, `1`, `0`, `1`, `0`, `1`, `1`, then `always-loaded total: N bytes` — record N; Step 7 expects the same N. (The first two lines: the family sentence is present, and still directly before the cost-per-task quotation.) Any other count: stop and reconcile (Interfaces).

- [ ] **Step 2: Write the failing fixture**

Replace the whole of `.claude/workflows/tests/agent-cost-fixture.sh` with (the mode stays `100755`):

```bash
#!/usr/bin/env bash
# Fixture for agent-cost.py: seventeen synthetic transcripts, one case each — the set that shipped before
# context-builder-kit#69 and that issue's, unioned under distinct names. Priced: Opus 5 with cache tokens (aaa); a
# transcript mixing two priced models (ddd); Fable 5.1 at its 0.025x cache-read rate (eee); Opus 5.5 with cache tokens
# at its 0.05x rate (fff); Opus 5.5 beside a zero-usage <synthetic> message, which is skipped (ggg); a dated Haiku 4.5
# id with no timestamps, so minutes is null (jjj); Sonnet 5.5 (lll); legacy Fable 5 at the standard 0.1x, where a
# family key would bill it at Fable 5.1's 0.025x (mmm); Mythos 5.1 at 0.025x (nnn); an Opus 5.5 id with a [1m] suffix
# (ooo); an undated Haiku 4.5 id with no timestamps (qqq). Unpriced and named: a model the table does not know (bbb);
# no usage events and a truncated line (ccc); fast mode (hhh); a lone truncated line (iii); an unknown point release,
# never priced as its predecessor (kkk); a <synthetic> message that carries usage (ppp). Asserts the cache
# multipliers, per-model pricing of a mixed transcript, per-row facts read from the --json output (never two
# independent greps, which pass on any row carrying the value), that tier() matches a PRICE key whole whatever the
# dict order, that CACHE_READ is defined once, the skipped-line count and the exit codes. Every python3 call runs
# with -B, so no bytecode lands in the tree. Needs bash and python3.
# Run: bash .claude/workflows/tests/agent-cost-fixture.sh
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
script="$here/../agent-cost.py"
d=$(mktemp -d); e=$(mktemp -d)
trap 'rm -rf "$d" "$e"' EXIT
row() {  # row <agent> <json line>… — one transcript per agent
  local a=$1; shift
  printf '%s\n' "$@" > "$d/agent-$a.jsonl"
}
u() { printf '{"type":"user","timestamp":"2026-09-30T00:00:00Z","message":{"content":"%s prompt"}}' "$1"; }
m() { printf '{"type":"assistant","timestamp":"2026-09-30T00:0%s:00Z","message":{"model":"%s","usage":%s}}' "$1" "$2" "$3"; }
row aaa "$(u aaa)" "$(m 1 claude-opus-5 '{"input_tokens":1000000,"output_tokens":100000,"cache_creation_input_tokens":1000000,"cache_read_input_tokens":1000000}')"
row bbb "$(u bbb)" "$(m 2 claude-future-9 '{"input_tokens":5,"output_tokens":5}')"
row ccc "$(u ccc)" '{"type":"assistant","timestamp":"2026-09-30T00:0'
row ddd "$(u ddd)" "$(m 1 claude-opus-5 '{"input_tokens":1000000,"output_tokens":0}')" "$(m 2 claude-sonnet-5 '{"input_tokens":1000000,"output_tokens":0}')"
row eee "$(u eee)" "$(m 3 claude-fable-5-1 '{"input_tokens":1000000,"output_tokens":0,"cache_read_input_tokens":1000000}')"
row fff "$(u fff)" "$(m 1 claude-opus-5-5 '{"input_tokens":1000000,"output_tokens":100000,"cache_creation_input_tokens":1000000,"cache_read_input_tokens":1000000}')"
row ggg "$(u ggg)" "$(m 1 claude-opus-5-5 '{"input_tokens":1000000,"output_tokens":0,"speed":"standard"}')" \
  "$(m 2 '<synthetic>' '{"input_tokens":0,"output_tokens":0,"cache_creation_input_tokens":0,"cache_read_input_tokens":0}')"
row hhh "$(u hhh)" "$(m 1 claude-opus-5-5 '{"input_tokens":1000000,"output_tokens":0,"speed":"fast"}')"
row iii '{"type":"assistant","timestamp":"2026-09-30T00:0'
row jjj '{"type":"assistant","message":{"model":"claude-haiku-4-5-20251001","usage":{"input_tokens":1000,"output_tokens":0}}}'
row kkk "$(u kkk)" "$(m 1 claude-opus-5-6 '{"input_tokens":1000000,"output_tokens":0}')"
row lll "$(u lll)" "$(m 1 claude-sonnet-5-5 '{"input_tokens":1000000,"output_tokens":100000,"cache_read_input_tokens":1000000}')"
row mmm "$(u mmm)" "$(m 1 claude-fable-5 '{"input_tokens":1000000,"output_tokens":0,"cache_read_input_tokens":1000000}')"
row nnn "$(u nnn)" "$(m 1 claude-mythos-5-1 '{"input_tokens":0,"output_tokens":0,"cache_read_input_tokens":1000000}')"
row ooo "$(u ooo)" "$(m 1 'claude-opus-5-5[1m]' '{"input_tokens":1000000,"output_tokens":0}')"
row ppp "$(u ppp)" "$(m 1 claude-opus-5-5 '{"input_tokens":1000000,"output_tokens":0}')" "$(m 2 '<synthetic>' '{"input_tokens":5,"output_tokens":0}')"
row qqq '{"type":"assistant","message":{"model":"claude-haiku-4-5","usage":{"input_tokens":1000,"output_tokens":0}}}'
out=$(python3 -B "$script" "$d" --json "$d/out.json")
# Per-row facts, read from the JSON by agent: two independent greps would pass on any row carrying the value.
python3 -B - "$d/out.json" <<'EOF' || { echo "$out"; exit 1; }
import json, sys
with open(sys.argv[1]) as f:
    rows = {r['agent']: r for r in json.load(f)}
want_cost = {
    'aaa': (14.25, '1M in @ $5 + 1M cache write @ 1.25x + 1M cache read @ 0.1x + 100k out @ $25'),
    'ddd': (7.00, 'a mixed transcript priced per model: 1M Opus 5 in + 1M Sonnet 5 in'),
    'eee': (10.25, 'Fable 5.1: 1M in @ $10 + 1M cache read @ 0.025x'),
    'fff': (11.20, 'Opus 5.5: 1M in @ $4 + 1M cache write @ 1.25x + 1M cache read @ 0.05x + 100k out @ $20 — never Opus 5'),
    'ggg': (4.00, 'a zero-usage <synthetic> message must not unprice its row'),
    'jjj': (0.001, 'a dated Haiku 4.5 id (claude-haiku-4-5-20251001) prices as Haiku 4.5'),
    'lll': (3.20, 'Sonnet 5.5: 1M in @ $2 + 1M cache read @ 0.1x + 100k out @ $10'),
    'mmm': (11.00, 'legacy Fable 5: 1M in @ $10 + 1M cache read @ the standard 0.1x — not 0.025x, which is Fable 5.1 only'),
    'nnn': (0.25, 'Mythos 5.1: 1M cache read @ 0.025x of $10'),
    'ooo': (4.00, 'an Opus 5.5 id with a [1m] suffix prices as Opus 5.5'),
    'qqq': (0.001, 'an undated Haiku 4.5 id prices as Haiku 4.5'),
}
bad = []
for a, (cost, why) in want_cost.items():
    got = rows[a]['cost_usd']
    if got is None or abs(got - cost) > 1e-9:
        bad.append(f'{a}: cost {got!r}, want {cost} ({why})')
for a in ('bbb', 'ccc', 'hhh', 'iii', 'kkk', 'ppp'):  # unknown model; no usage; fast mode; truncated; unknown point release; <synthetic> with usage
    if rows[a]['cost_usd'] is not None:
        bad.append(f'{a}: must be unpriced (null cost), got {rows[a]["cost_usd"]!r}')
for a in ('ccc', 'iii', 'jjj', 'qqq'):  # one timestamp, then none at all
    if rows[a]['minutes'] is not None:
        bad.append(f'{a}: fewer than two timestamps must report minutes null, not {rows[a]["minutes"]!r}')
if rows['ooo']['model'] != 'claude-opus-5-5[1m]':
    bad.append(f"ooo: the model column must carry the id as recorded, got {rows['ooo']['model']!r}")
if bad:
    print('FAIL: ' + '\n  '.join(bad))
    sys.exit(1)
EOF
grep -q 'total list-price cost: \$65.15' <<<"$out" || { echo "FAIL: expected a \$65.15 total (14.25 + 7.00 + 10.25 + 11.20 + 4.00 + 0.001 + 3.20 + 11.00 + 0.25 + 4.00 + 0.001); got:"; echo "$out"; exit 1; }
grep -q '11 of 17 agents priced' <<<"$out" || { echo "FAIL: the priced/unpriced split is not printed"; echo "$out"; exit 1; }
grep -q 'unpriced.*bbb, ccc, hhh, iii, kkk, ppp' <<<"$out" || { echo "FAIL: the unpriced agents are not named"; echo "$out"; exit 1; }
grep -q 'unparsable lines skipped.*ccc (1), iii (1)' <<<"$out" || { echo "FAIL: the truncated transcripts are not named with their skipped-line counts"; echo "$out"; exit 1; }
# tier() must match a PRICE key WHOLE whatever the dict order. With a family key listed first, a first-match (or
# substring) rule prices Opus 5.5 as Opus 5 and Fable 5.1 as Fable 5 — the rows above cannot see that, because PRICE
# happens to list the longer key first.
python3 -B - "$script" <<'EOF' || { echo "FAIL: tier() does not match a PRICE key whole: a longer id, or one a shorter key prefixes, was priced as that key"; exit 1; }
import importlib.util, sys
spec = importlib.util.spec_from_file_location('agent_cost', sys.argv[1])
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
m.PRICE = {'claude-opus-5': (5.0, 25.0), 'claude-opus-5-5': (4.0, 20.0), 'claude-fable-5': (10.0, 50.0), 'claude-fable-5-1': (10.0, 50.0)}
for model, key in (('claude-opus-5-5-20260922', 'claude-opus-5-5'), ('claude-opus-5', 'claude-opus-5'),
                   ('claude-opus-5-5[1m]', 'claude-opus-5-5'), ('claude-fable-5-1', 'claude-fable-5-1'),
                   ('claude-fable-5', 'claude-fable-5')):
    assert m.tier(model) == key, (model, m.tier(model), key)
for unknown in ('claude-opus-5-6', 'claude-sonnet-5-5', 'claude-opus-50', 'claude-opus-5-5 [speed=fast]'):
    assert m.tier(unknown) is None, (unknown, m.tier(unknown))
EOF
# One CACHE_READ: a second definition silently shadows the first (the hazard a merge of two copies creates).
[ "$(grep -c '^CACHE_READ =' "$script")" -eq 1 ] || { echo "FAIL: agent-cost.py must define CACHE_READ exactly once"; exit 1; }
assert_exit() { local want=$1 desc=$2; shift 2; local rc=0; python3 -B "$script" "$@" >/dev/null 2>&1 || rc=$?; [ "$rc" -eq "$want" ] || { echo "FAIL: $desc (got $rc)"; exit 1; }; }
assert_exit 2 "no arguments should exit 2"
assert_exit 1 "an empty directory should exit 1" "$e"
assert_exit 2 "--json without a path should exit 2" "$d" --json
echo "agent-cost-fixture: ok"
```

- [ ] **Step 3: Run it against the unfixed `agent-cost.py`**

Run: `bash -n .claude/workflows/tests/agent-cost-fixture.sh && { rc=0; out=$(bash .claude/workflows/tests/agent-cost-fixture.sh 2>&1) || rc=$?; head -8 <<<"$out"; echo "exit=$rc"; }`
(The output is captured before `head` reads it: piping the fixture straight into `head -8` lets `head` exit while the fixture is still writing, and the fixture then dies of SIGPIPE and reports `exit=141` on some runs.)
Expected (the family-keyed `PRICE` bills Opus 5.5 as Opus 5, Fable 5 at Fable 5.1's cache rate, and has no `<synthetic>`, fast-mode or Mythos handling):
```
FAIL: fff: cost 14.25, want 11.2 (Opus 5.5: 1M in @ $4 + 1M cache write @ 1.25x + 1M cache read @ 0.05x + 100k out @ $20 — never Opus 5)
  ggg: cost None, want 4.0 (a zero-usage <synthetic> message must not unprice its row)
  mmm: cost 10.25, want 11.0 (legacy Fable 5: 1M in @ $10 + 1M cache read @ the standard 0.1x — not 0.025x, which is Fable 5.1 only)
  nnn: cost None, want 0.25 (Mythos 5.1: 1M cache read @ 0.025x of $10)
  ooo: cost 5.0, want 4.0 (an Opus 5.5 id with a [1m] suffix prices as Opus 5.5)
  hhh: must be unpriced (null cost), got 5.0
  kkk: must be unpriced (null cost), got 5.0
agent	label	model	turns	input	cache_write	cache_read	output	cost_usd	minutes
exit=1
```
Record for the PR body's red-first table: `V6.1 agent-cost-fixture.sh — FAIL: fff: cost 14.25, want 11.2 (…)`.

- [ ] **Step 4: Write the two block checks and run them red against the unfixed files**

First, the portability red (`review/portability/67`): run the block's **existing** list-price diff with busybox's `sed`, `tr`, `grep` and `sort` first on `PATH` (a host without busybox prints the `SKIP:` line and the case is recorded as skipped, never as passed):
```bash
if command -v busybox >/dev/null; then bb=$(mktemp -d); t=$(mktemp); for x in sed tr grep sort; do ln -s "$(command -v busybox)" "$bb/$x"; done; awk '/^## Verification/{p=1} p' .claude/rules/cbk-conventions-reference.md | awk '/^```bash/{c=1;next} /^```/{c=0} c' | awk '/^# The list-price table has two copies/{p=1} /^# No self-check prose/{p=0} p' > "$t"; rc=0; PATH="$bb:$PATH" bash -e "$t" || rc=$?; rm -rf "$bb" "$t"; echo "busybox price exit=$rc"; else echo "SKIP: busybox price diff (busybox unavailable)"; fi
```
Expected (GNU `sed` passes this same line; busybox's has no `\L`):
```
1,4c1,4
< fable 10 50
< haiku 1 5
< opus 5 25
< sonnet 2 10
---
> LFable 10 50
> LHaiku 1 5
> LOpus 5 25
> LSonnet 2 10
the list-price table drifted between agent-cost.py PRICE and orchestration-reference.md § Generation notes — the sources (every model the quoted row names must be a PRICE key with the same numbers)
busybox price exit=1
```
Record: `V6.1 block list-price diff under busybox — > LOpus 5 25 (review/portability/67)`.

The list-price diff, re-keyed by version, replaces the existing three lines in § Verification. The existing line lowercases with `sed`'s `\L`, a GNU extension: busybox `sed` prints `LOpus 5 25` for `Opus 5 $5/$25` (`review/portability/67`), so the new `pr=` lowercases with `tr '[:upper:]' '[:lower:]'` after `sed` (every other character it reads is a digit, a dash or a space). The new `cr=` lowercases in Python (`str.lower`), which is portable. Replace (exact, unique):

```bash
# The list-price table has two copies — the cost reader's PRICE and the reference half's quoted pricing
# row — and they must agree (both are dated; a price edit lands in both or fails here).
diff <(grep -oE "'[a-z]+': \([0-9.]+, [0-9.]+\)" .claude/workflows/agent-cost.py | sed -E "s/'([a-z]+)': \(([0-9]+)\.0, ([0-9]+)\.0\)/\1 \2 \3/" | sort) <(grep -oE '[A-Z][a-z]+ [0-9.]+ \$[0-9]+/\$[0-9]+' .claude/rules/orchestration-reference.md | sed -E 's/^([A-Z][a-z]+) [0-9.]+ \$([0-9]+)\/\$([0-9]+)/\L\1 \2 \3/' | sort) || { echo "the list-price table drifted between agent-cost.py PRICE and orchestration-reference.md § Generation notes — the sources (every model the quoted row names must be a PRICE key with the same numbers)"; exit 1; }
```

with:

```bash
# The list-price table has two copies — the cost reader's PRICE and the reference half's quoted pricing
# bullet — and they must agree (both are dated; a price edit lands in both or fails here). Both are keyed by
# model version ("Opus 5.5" ↔ 'claude-opus-5-5'), because a version can reprice its family
# (context-builder-kit#69). An empty read on either side is red, never a vacuous pass. Lowercased with tr: sed's \L
# is GNU-only (busybox sed prints "LOpus 5 25").
pk=$(grep -oE "'claude-[a-z]+-[0-9-]+': \([0-9.]+, [0-9.]+\)" .claude/workflows/agent-cost.py | sed -E "s/'claude-([a-z]+-[0-9-]+)': \(([0-9]+)\.0, ([0-9]+)\.0\)/\1 \2 \3/" | sort -u)
pr=$(grep -oE '[A-Z][a-z]+ [0-9.]+ \$[0-9]+/\$[0-9]+' .claude/rules/orchestration-reference.md | sed -E 's/^([A-Z][a-z]+) ([0-9.]+) \$([0-9]+)\/\$([0-9]+)/\1-\2 \3 \4/; s/\./-/g' | tr '[:upper:]' '[:lower:]' | sort -u)
{ [ -n "$pk" ] && [ -n "$pr" ]; } || { echo "the list-price diff read nothing (PRICE: $(grep -c . <<<"$pk" || true) keys; quoted bullet: $(grep -c . <<<"$pr" || true) models) — a format changed; update this extraction"; exit 1; }
diff <(printf '%s\n' "$pk") <(printf '%s\n' "$pr") || { echo "the list-price table drifted between agent-cost.py PRICE and orchestration-reference.md § Generation notes — the sources (every model version the quoted bullet names must be a PRICE key with the same numbers)"; exit 1; }
```

The cache-read diff is new; it goes immediately before the kit sentinel. Replace (exact, unique, the whole line):

```bash
echo "verification: kit sub-block complete"
```

with:

```bash
# The cache-read multipliers have two copies too: CACHE_READ (per version, beside CACHE_READ_DEFAULT) and the pricing
# page's cache sentence quoted in the reference half ("On Claude <X> …, a cache hit costs N% of the standard input
# price"; "A cache hit costs 10% …"). A family key once billed legacy Fable 5 at Fable 5.1's rate (context-builder-kit#69).
ck=$(python3 -B -c "import re; s=open('.claude/workflows/agent-cost.py').read(); m=re.search(r'^CACHE_READ = \{(.*?)^\}', s, re.S | re.M); [print(k, float(v)) for k, v in sorted(re.findall(r\"'claude-([a-z]+-[0-9-]+)': ([0-9.]+)\", m.group(1) if m else ''))]; d=re.search(r'^CACHE_READ_DEFAULT = ([0-9.]+)', s, re.M); print('default', float(d.group(1))) if d else None") || { echo "the cache-read diff could not read agent-cost.py"; exit 1; }
cr=$(python3 -B -c "import re; s=open('.claude/rules/orchestration-reference.md').read(); o={f\"{n.lower()}-{v.replace('.', '-')} {float(p)/100}\" for ms, p in re.findall(r'On ((?:Claude [A-Z][a-z]+ [0-9.]+(?:,? and |, )?)+), a cache hit costs ([0-9.]+)% of the standard input price', s) for n, v in re.findall(r'Claude ([A-Z][a-z]+) ([0-9.]+)', ms)}; m=re.search(r'A cache hit costs ([0-9.]+)% of the standard input price', s); o |= {f'default {float(m.group(1))/100}'} if m else set(); [print(x) for x in sorted(o)]") || { echo "the cache-read diff could not read orchestration-reference.md"; exit 1; }
{ [ "$(grep -c . <<<"$ck" || true)" -ge 2 ] && [ "$(grep -c . <<<"$cr" || true)" -ge 2 ]; } || { echo "the cache-read diff read too little (CACHE_READ: $(tr '\n' ';' <<<"$ck") | quoted sentence: $(tr '\n' ';' <<<"$cr")) — a format changed; update this extraction"; exit 1; }
diff <(printf '%s\n' "$ck" | sort) <(printf '%s\n' "$cr" | sort) || { echo "the cache-read multipliers drifted between agent-cost.py CACHE_READ and the pricing sentence quoted in orchestration-reference.md § Generation notes — the sources"; exit 1; }
echo "verification: kit sub-block complete"
```

Run the two checks alone, against the unfixed `agent-cost.py` and reference half (`agent-cost.py` has no version keys yet, and its `CACHE_READ` is a one-line family dict):
```bash
t=$(mktemp); awk '/^## Verification/{p=1} p' .claude/rules/cbk-conventions-reference.md | awk '/^```bash/{c=1;next} /^```/{c=0} c' | awk '/^# The list-price table has two copies/{p=1} /^# No self-check prose/{p=0} p' > "$t"; bash -e "$t"; echo "price exit=$?"
awk '/^## Verification/{p=1} p' .claude/rules/cbk-conventions-reference.md | awk '/^```bash/{c=1;next} /^```/{c=0} c' | awk '/^# The cache-read multipliers have two copies too/{p=1} /^echo "verification: kit sub-block complete"/{p=0} p' > "$t"; bash -e "$t"; echo "cache exit=$?"; rm -f "$t"
```
Expected:
```
the list-price diff read nothing (PRICE: 0 keys; quoted bullet: 4 models) — a format changed; update this extraction
price exit=1
the cache-read diff read too little (CACHE_READ: default 0.1; | quoted sentence: ;) — a format changed; update this extraction
cache exit=1
```
Record: `V6.1 block list-price diff — the list-price diff read nothing (PRICE: 0 keys; …)` and `V6.1 block cache-read diff — the cache-read diff read too little (…)`.

- [ ] **Step 5: The change**

(a) Replace the whole of `.claude/workflows/agent-cost.py` with (the mode stays `100755`):

```python
#!/usr/bin/env python3
"""Per-agent tokens, list-price cost, minutes and turns from a workflow run's transcripts.

Usage: python3 .claude/workflows/agent-cost.py <transcript-dir> [--json out.json]

<transcript-dir> is the directory the Workflow tool names in its result ("Transcript dir: …"); it holds one
agent-<id>.jsonl per agent. Each assistant message carries `message.usage` and `message.model`, so cost is
attributed to the model that actually answered, not to the label the script asked for. A transcript that
mixes models is priced per model; one unpriced model leaves that agent's row unpriced, and the row is named
and excluded from the total — never folded in as zero.

PRICE below is list price per MTok as of 2026-09-30 (platform.claude.com/docs/en/about-claude/pricing, the model
pricing table — quoted in .claude/rules/orchestration-reference.md § Generation notes — the sources, which the kit's
verification block diffs against PRICE). It is keyed by model version, not family, because a version can reprice its
family: Opus 5.5 is $4/$20 where Opus 5 is $5/$25, and Opus 5 stays priced for transcripts recorded before Opus 5.5.
Cache writes are 1.25x input (5-minute TTL) on every model. Cache reads are 0.1x input (CACHE_READ_DEFAULT) except
where CACHE_READ says otherwise: 0.05x on Opus 5.5 and 0.025x on Fable 5.1 and Mythos 5.1 — legacy Fable 5 stays at
0.1x (the same page's cache sentence, which the block diffs against CACHE_READ). Every cache write is priced at the
5-minute rate — the per-TTL breakdown inside `cache_creation` is not read. A 1-hour cache TTL prices writes at 2x;
because the cache-write share differs by tier, that widens a write-heavy tier's ratio rather than cancelling out (on
one measured run, 2026-09-01, it moved a pooled top-tier:workhorse ratio from 3.2x to 3.6x — both priced with the top
tier's cache reads at 0.1x, so both are upper bounds if that run's top tier was Fable 5.1, which reads cache at
0.025x; the transcripts' model ids settle it, context-builder-kit#58 item 6). A model id no PRICE key matches whole is
unpriced and named, never guessed at; so is a message whose `usage.speed` is not "standard" — fast mode bills at a
premium (the pricing page's § Fast mode pricing; "The response `usage` object includes a `speed` field",
platform.claude.com/docs/en/build-with-claude/fast-mode, read 2026-09-30). A `<synthetic>` message the harness writes
itself with zero usage is skipped rather than left to unprice its agent's row; one that carries usage is not
(observed in Claude Code transcripts, context-builder-kit#69). Re-verify the table against the pricing page before
quoting absolute dollars.
"""
import datetime as dt
import glob
import json
import os
import re
import sys

PRICE = {  # model version -> (input $/MTok, output $/MTok); verified 2026-09-30
    'claude-fable-5-1': (10.0, 50.0),
    'claude-fable-5': (10.0, 50.0),
    'claude-mythos-5-1': (10.0, 50.0),
    'claude-opus-5-5': (4.0, 20.0),
    'claude-opus-5': (5.0, 25.0),
    'claude-sonnet-5-5': (2.0, 10.0),
    'claude-sonnet-5': (2.0, 10.0),
    'claude-haiku-4-5': (1.0, 5.0),
}
CACHE_READ = {  # PRICE key -> cache-read multiplier where it is not CACHE_READ_DEFAULT; verified 2026-09-30
    'claude-fable-5-1': 0.025,
    'claude-mythos-5-1': 0.025,
    'claude-opus-5-5': 0.05,
}
CACHE_READ_DEFAULT = 0.1  # every other model, legacy Fable 5 included: the standard 0.1x
# Keyed by version like PRICE. Until v1.0.0 a family key ('fable') billed legacy Fable 5 at Fable 5.1's 0.025x, and a
# second, version-keyed dict merged in beside it would silently shadow the first (context-builder-kit#69) — so there is
# one dict, and the fixture counts its definitions. The per-tier rule landed with context-builder-kit#58 item 6; the
# per-version rates are the pricing page's cache sentence, read 2026-09-30.


def tier(model):
    """The PRICE key the model id names whole: the key itself, optionally followed by a -YYYYMMDD snapshot date (the
    dated form transcripts record for Haiku 4.5, claude-haiku-4-5-20251001) and a bracketed variant such as [1m]. So
    `claude-opus-5-5` never prices as `claude-opus-5`, and a point release the table does not know yet
    (`claude-opus-5-6`) is unpriced and named rather than priced as its predecessor, which is the mispricing a version
    key exists to prevent. A speed-marked id (fast mode) matches no key: its rate is not list."""
    if '[speed=' in model:
        return None
    return next((key for key in PRICE if re.fullmatch(rf'{re.escape(key)}(-\d{{8}})?(\[[^\]]*\])?', model)), None)


def first_prompt(events):
    """First 90 chars of the first user message — the only label the transcript itself carries."""
    for e in events:
        if e.get('type') != 'user':
            continue
        c = (e.get('message') or {}).get('content')
        text = c if isinstance(c, str) else ' '.join(x.get('text', '') for x in (c or []) if isinstance(x, dict))
        text = ' '.join(text.split())
        return text[:90]
    return '?'


def parse_iso(s):
    return dt.datetime.fromisoformat(s.replace('Z', '+00:00'))


def summarise(path):
    events = []
    skipped = 0  # unparsable lines (a transcript truncated by a killed agent) are counted, never silently dropped
    with open(path) as f:
        for line in f:
            try:
                events.append(json.loads(line))
            except json.JSONDecodeError:
                skipped += 1
    per_model = {}  # model id -> token counts; priced per model, so a mixed transcript is never billed at one tier
    stamps = []
    for e in events:
        if e.get('timestamp'):
            stamps.append(e['timestamp'])
        m = e.get('message') or {}
        u = m.get('usage')
        if not u:
            continue
        model = m.get('model', '?')
        if model == '<synthetic>' and not any(u.get(f) for f in ('input_tokens', 'output_tokens',
                                                                   'cache_creation_input_tokens', 'cache_read_input_tokens')):
            continue  # a harness-written message with zero usage: nothing to price. One that ever carried usage stays,
            # so its row is unpriced and named rather than silently undercounted
        if u.get('speed') not in (None, 'standard'):
            model = f"{model} [speed={u['speed']}]"  # fast mode bills at another rate: named as unpriced, never guessed at
        t = per_model.setdefault(model, dict(turns=0, inp=0, out=0, cw=0, cr=0))
        t['turns'] += 1
        t['inp'] += u.get('input_tokens', 0)
        t['out'] += u.get('output_tokens', 0)
        t['cw'] += u.get('cache_creation_input_tokens', 0)
        t['cr'] += u.get('cache_read_input_tokens', 0)
    model = ','.join(sorted(per_model)) or '?'
    turns, inp, out, cw, cr = (sum(t[k] for t in per_model.values()) for k in ('turns', 'inp', 'out', 'cw', 'cr'))
    cost = None if not per_model else 0.0  # no usage events at all: unpriced and named, never a free row
    for name, t in per_model.items():
        k = tier(name)
        if k is None:
            cost = None  # one unpriced model leaves the whole row unpriced rather than partially counted
            break
        pi, po = PRICE[k]
        cost += (t['inp'] * pi + t['cw'] * pi * 1.25 + t['cr'] * pi * CACHE_READ.get(k, CACHE_READ_DEFAULT) + t['out'] * po) / 1e6
    minutes = None
    if len(stamps) >= 2:
        minutes = round((parse_iso(max(stamps)) - parse_iso(min(stamps))).total_seconds() / 60, 1)
    return dict(agent=os.path.basename(path)[6:-6], label=first_prompt(events), model=model, turns=turns,
                input=inp, cache_write=cw, cache_read=cr, output=out, cost_usd=cost, minutes=minutes, skipped_lines=skipped)


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    d = argv[1]
    rows = [summarise(f) for f in sorted(glob.glob(os.path.join(d, 'agent-*.jsonl')))]
    if not rows:
        print(f'no agent-*.jsonl under {d}')
        return 1
    cols = ['agent', 'label', 'model', 'turns', 'input', 'cache_write', 'cache_read', 'output', 'cost_usd', 'minutes']
    print('\t'.join(cols))
    for r in rows:
        print('\t'.join(f'{r[c]:.2f}' if isinstance(r[c], float) else str(r[c]) for c in cols))
    priced = [r for r in rows if r['cost_usd'] is not None]
    unpriced = [r['agent'] for r in rows if r['cost_usd'] is None]
    total = sum(r['cost_usd'] for r in priced)
    split = f' ({len(priced)} of {len(rows)} agents priced)' if unpriced else ''
    print(f'\nagents: {len(rows)}\ttotal list-price cost: ${total:.2f}{split}')
    if unpriced:
        print(f'unpriced (model not in PRICE, a fast-mode message, or no usage events; named here and excluded from the total): {", ".join(unpriced)}')
    truncated = [f"{r['agent']} ({r['skipped_lines']})" for r in rows if r['skipped_lines']]
    if truncated:
        print(f'unparsable lines skipped (a truncated transcript undercounts its agent): {", ".join(truncated)}')
    if '--json' in argv:
        i = argv.index('--json') + 1
        if i >= len(argv):
            print('--json needs an output path')
            return 2
        outp = argv[i]
        with open(outp, 'w') as f:
            json.dump(rows, f, indent=1)
        print(f'wrote {outp}')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
```

(b) In `.claude/rules/orchestration-reference.md` § Generation notes — the sources, delete this exact text from the ladder bullet (it is followed by the sentence `"You pay for completed tasks, though, …`, which stays):

```
Pricing row, per MTok in/out: Fable 5.1 $10/$50, Opus 5 $5/$25, Sonnet 5 $2/$10, Haiku 4.5 $1/$5 (same page). 
```

(the deleted text ends with one trailing space; V5.3 left it byte for byte for this edit — V5 § Handed to other clusters, item 1). Then insert the new bullet directly after V5.3's **Price steps** bullet: replace (exact, unique after V5 — Step 1 counted it)

```
- **Aliases, by provider and by version** (
```

with the new bullet on its own line, followed by that same text:

```
- **Prices, per version** (`platform.claude.com/docs/en/about-claude/pricing`, the model pricing table, read 2026-09-30) — per MTok in/out: Fable 5.1 $10/$50, Fable 5 $10/$50, Mythos 5.1 $10/$50, Opus 5.5 $4/$20, Opus 5 $5/$25, Sonnet 5.5 $2/$10, Sonnet 5 $2/$10, Haiku 4.5 $1/$5. Opus 5 and Fable 5 are legacy but still priced, for transcripts recorded before the newer versions. Cache reads, from the same page: "A cache hit costs 10% of the standard input price, which means caching pays off after one cache read for the 5-minute duration (1.25x write), or after two cache reads for the 1-hour duration (2x write). On Claude Fable 5.1 and Claude Mythos 5.1, a cache hit costs 2.5% of the standard input price ($0.25 USD per million tokens). On Claude Opus 5.5, a cache hit costs 5% of the standard input price ($0.20 USD per million tokens)." Legacy Fable 5 is therefore at the standard 10%. `agent-cost.py`'s `PRICE` and `CACHE_READ` mirror this bullet, and the verification block diffs both.
- **Aliases, by provider and by version** (
```

The bullet cites the pricing page, which V5.14's § Primary sources already carries as a row (`| \`platform.claude.com/docs/en/about-claude/pricing\` | The list prices and cache-read rates \`agent-cost.py\` mirrors, …`), so V5.14's primary-sources check stays green, and it contains no square-bracket slot (V5.13's check).

- [ ] **Step 6: Re-verify every quotation and price this task writes, raw, today**

Run (from the repository root; needs `curl`):
```bash
bash -s <<'QUOTES'
#!/usr/bin/env bash
# V6.1 quotations: fetch raw, normalise typographic apostrophes, match with grep -F.
set -uo pipefail
q=$(mktemp -d); trap 'rm -rf "$q"' EXIT
fetch() { curl -sL "$1" | sed "s/’/'/g" > "$q/$2"; [ -s "$q/$2" ] || { echo "FETCH FAILED: $1"; exit 1; }; }
fetch https://platform.claude.com/docs/en/about-claude/pricing.md pricing
fetch https://platform.claude.com/docs/en/build-with-claude/fast-mode.md fast
ok=0
has() { grep -qF -- "$2" "$q/$1" && echo "ok   $1: $2" || { echo "MISS $1: $2"; ok=1; }; }
has pricing 'A cache hit costs 10% of the standard input price, which means caching pays off after one cache read for the 5-minute duration (1.25x write), or after two cache reads for the 1-hour duration (2x write). On Claude Fable 5.1 and Claude Mythos 5.1, a cache hit costs 2.5% of the standard input price ($0.25 USD per million tokens). On Claude Opus 5.5, a cache hit costs 5% of the standard input price ($0.20 USD per million tokens).'
has pricing '### Fast mode pricing'
has fast 'The response `usage` object includes a `speed` field'
for row in 'Claude Fable 5.1 |$10 / MTok|$50 / MTok' 'Claude Mythos 5.1 |$10 / MTok|$50 / MTok' 'Claude Fable 5 |$10 / MTok|$50 / MTok' 'Claude Opus 5.5 |$4 / MTok|$20 / MTok' 'Claude Opus 5 |$5 / MTok|$25 / MTok' 'Claude Sonnet 5.5 |$2 / MTok|$10 / MTok' 'Claude Sonnet 5 |$2 / MTok|$10 / MTok' 'Claude Haiku 4.5 |$1 / MTok|$5 / MTok'; do
  IFS='|' read -r name inp outp <<<"$row"
  line=$(grep -F "| $name" "$q/pricing" | head -1)
  { grep -qF -- "$inp" <<<"$line" && grep -qF -- "$outp" <<<"$line"; } && echo "ok   pricing row: $name$inp in, $outp out" || { echo "MISS pricing row: $name"; ok=1; }
done
exit $ok
QUOTES
echo "quotes exit=$?"
```
Expected: eleven `ok` lines and `quotes exit=0`. A `MISS` line means the page changed since 2026-09-30: stop, re-read the page, and correct the prices, the bullet and the date together (the block diffs will then say what to align).

- [ ] **Step 7: Run the fixture, both mutants, and the block**

Run:
```bash
bash -n .claude/workflows/tests/agent-cost-fixture.sh && bash .claude/workflows/tests/agent-cost-fixture.sh
f=.claude/workflows/agent-cost.py; keep=$(mktemp); cp "$f" "$keep"
sed -i 's/^    return next((key for key in PRICE if re\.fullmatch.*$/    return next((key for key in PRICE if key in model), None)/' "$f"
rc=0; out=$(bash .claude/workflows/tests/agent-cost-fixture.sh 2>&1) || rc=$?; echo "mutant 1 (first-match tier): rc=$rc; $(head -1 <<<"$out")"; cp "$keep" "$f"
sed -i 's/^    if len(stamps) >= 2:$/    if len(stamps) >= 1:/' "$f"
rc=0; out=$(bash .claude/workflows/tests/agent-cost-fixture.sh 2>&1) || rc=$?; echo "mutant 2 (one-timestamp minutes): rc=$rc; $(head -1 <<<"$out")"; cp "$keep" "$f"; rm -f "$keep"
bash .claude/workflows/tests/agent-cost-fixture.sh
find .claude -name __pycache__
grep -nE '(^|[[:space:](,;])#[0-9]{1,3}\b' .claude/workflows/agent-cost.py .claude/workflows/tests/agent-cost-fixture.sh; echo "bare=$?"
grep -n '^[^#]*sed [^#]*\\L' .claude/rules/cbk-conventions-reference.md; echo "gnu-sed-L=$?"
if command -v busybox >/dev/null; then bb=$(mktemp -d); t=$(mktemp); for x in sed tr grep sort; do ln -s "$(command -v busybox)" "$bb/$x"; done; awk '/^## Verification/{p=1} p' .claude/rules/cbk-conventions-reference.md | awk '/^```bash/{c=1;next} /^```/{c=0} c' | awk '/^# The list-price table has two copies/{p=1} /^# No self-check prose/{p=0} p' > "$t"; rc=0; PATH="$bb:$PATH" bash -e "$t" || rc=$?; rm -rf "$bb" "$t"; echo "busybox price exit=$rc"; else echo "SKIP: busybox price diff (busybox unavailable)"; fi
bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E '^(agent-cost-fixture|always-loaded total|verification: )'; echo "exit=${PIPESTATUS[0]}"
```
Expected:
```
agent-cost-fixture: ok
mutant 1 (first-match tier): rc=1; FAIL: kkk: must be unpriced (null cost), got 5.0
mutant 2 (one-timestamp minutes): rc=1; FAIL: ccc: fewer than two timestamps must report minutes null, not 0.0
agent-cost-fixture: ok
agent-cost-fixture: ok
bare=1
gnu-sed-L=1
busybox price exit=0
always-loaded total: N bytes
verification: kit sub-block complete
verification: done
exit=0
```
with nothing printed by `find` (every `python3` call ran with `-B`) and `N` the value recorded in Step 1. `bare=1`: no bare kit-issue citation in either file (`release/5`; the fixed `agent-cost.py` cites `context-builder-kit#58 item 6` where the old one cited `#58 item 6`). `gnu-sed-L=1`: no uncommented `sed` in the block lowercases with `\L` (`review/portability/67`; the new check's comment names `\L`, which the `^[^#]*` prefix skips). A host without busybox prints the `SKIP:` line in place of `busybox price exit=0`; record it as skipped. No hook is touched by this task.

- [ ] **Step 8: Commit**

```bash
git add .claude/workflows/agent-cost.py .claude/workflows/tests/agent-cost-fixture.sh .claude/rules/cbk-conventions-reference.md .claude/rules/orchestration-reference.md
git commit -F- <<'EOF'
feat(workflows): V6 — agent-cost prices by model version, and the block diffs both price tables

agent-cost.py keys PRICE and CACHE_READ by model version: Opus 5.5 at $4/$20 with
0.05x cache reads, Fable 5.1 and Mythos 5.1 at 0.025x, and legacy Fable 5 back at the
standard 0.1x (the family key billed it at 0.025x on every target synced at 74edf84).
tier() matches a key whole, so an unknown point release is unpriced rather than priced
as its predecessor; a zero-usage <synthetic> message is skipped and a fast-mode message
is unpriced and named. The fixture is the union of both case sets under distinct names,
reads per-row facts from --json, pins one CACHE_READ definition and fails both mutants.
The block's list-price diff is re-keyed by version and lowercases with tr, since sed's
\L is GNU-only and busybox read every row as "LOpus"; a CACHE_READ diff joins it,
against a per-version prices bullet in the reference half, after the price steps, that
quotes the pricing page's cache sentence (V5's text, landed here because the three
copies are one fact). Every citation in both files is context-builder-kit#N.

Trace rows closed: #69/body/cost/version-keys, #69/body/cost/cache-read,
#69/body/cost/block-diff, #69/body/cost/fixture-rows, #69/body/cost/synthetic,
#69/body/cost/fast-mode, #69/c5859756889/1a, #69/c5859756889/1b (agent-cost half),
#69/c5859756889/2d, #69/c5859756889/2g, #69/c5881157875/2-fable5-misprice,
#69/c5881157875/2-version-keys-fix, #69/c5892402564/cost-1, #69/c5892402564/cost-2,
#69/c5892402564/cost-3, #69/c5892402564/cost-4, #69/c5892402564/transcripts,
#69/c5901496433/6, critic/19, critic/20; V6's parts of #69/body/T8, #69/body/F5,
#69/c5881157875/2c, #69/c5881157875/2d (landed for V5), #58/c5901493591/R9 (docstring)
and release/5 (agent-cost.py); review/portability/67 (handed from V9).

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

---

### Task V6.2: `finish-ab.js` — two to four arms, a Latin-square panel, `executed` mode, the replay arguments, the runner's log and the judges' read-only clause (#69/body/finish-ab/{N-arm, latin-square, measures, executed, replay-args}, #69/body/H1, #69/c5859756889/{1b, 1c, 2e}, #69/c5892402564/probe, #69/c5901496433/{1b, 5}; D45)

**Closes (trace rows, in full):** `#69/body/finish-ab/N-arm` (the code), `#69/body/finish-ab/latin-square`, `#69/body/finish-ab/measures` (the schema), `#69/body/finish-ab/executed`, `#69/body/finish-ab/replay-args`, `#69/body/H1` (the code side: the `executed` argument and its rationale), `#69/c5859756889/1b` (the shape-test half), `#69/c5859756889/1c`, `#69/c5859756889/2e`, `#69/c5892402564/probe` (the citation, by pointer), `#69/c5901496433/1b`, `#69/c5901496433/5` (the args comment); `release/5`'s parts in `finish-ab.js` and `finish-ab-shape.mjs`.

**Files:**
- Modify: `.claude/workflows/finish-ab/finish-ab.js` (whole file rewritten)
- Modify: `.claude/workflows/tests/finish-ab-shape.mjs` (whole file rewritten; V6.3 adds scenario 19)

**Interfaces:**
- **Consumes (from V5).** Probe P2's result as V5.10 writes it (outcome A): `.claude/rules/pr-review.md` § The floor gains the clause `` , and a workflow agent has none at any depth (a probe on Claude Code 2.1.285, 2026-09-30 — `orchestration-reference.md` § Generation notes — the sources) `` — V5.10 writes the version its probe printed where this says `2.1.285` — and `orchestration-reference.md` § Generation notes — the sources gains the bullet beginning `- **A workflow agent has no Agent tool** (a probe from the main session on Claude Code `. `finish-ab.js`'s `executed` comment points at § The floor, which records the probe's Claude Code version and date, instead of restating them (one fact, one home). V5.6's bullet in `.claude/rules/orchestration.md` § Fan-out discipline, which begins `- **Read-only agents stay read-only.** A finder, verifier or judge never modifies the working tree, not even to restore a file afterwards:` and ends `Every find, verify and judge prompt carries the clause.` — the judges' `READ_ONLY` comment cites that section, and `READ_ONLY` is the clause it requires.
- **Produces.** `args.arms` of two to four `{ arm, anon, read, verb?, also?, model?, effort? }`; `args.judges` balanced so every arm is read in every position equally often (the functions `positionCounts` and `balanced`); `args.executed` (a list of `{ anon, result }`, which V6.3's runner writes as `executed.json`); `args.base`, `args.brief`, `args.rubric`; `ARM_SCHEMA` with an optional `dispatched` property (V6.3's copy requires it; scenario 19 diffs them); `JUDGE_SCHEMA.measures`, optional (V6.4's rubric fills it); a result's `runner_check: { command, exit, log }`, named in every judge's prompt (V6.3's runner writes it); the constant `READ_ONLY` in every judge prompt, whose sentence contains `not even to restore a file afterwards`. The comments in this file name `run-arms-headless.py`, which V6.3 creates in the next commit.

- [ ] **Step 1: Preconditions**

Run:
```bash
grep -cF ', and a workflow agent has none at any depth (a probe on Claude Code ' .claude/rules/pr-review.md
grep -cF -- '- **A workflow agent has no Agent tool** (a probe from the main session on Claude Code ' .claude/rules/orchestration-reference.md
grep -cF -- '- **A workflow agent had an Agent tool**' .claude/rules/orchestration-reference.md
grep -cF -- '- **Read-only agents stay read-only.** A finder, verifier or judge never modifies the working tree, not even to restore a file afterwards:' .claude/rules/orchestration.md
grep -cF 'Every find, verify and judge prompt carries the clause.' .claude/rules/orchestration.md
grep -c 'const armLabels' .claude/workflows/finish-ab/finish-ab.js
```
Expected: `1`, `1`, `0`, `1`, `1`, `1`. The first three are probe P2 as V5.10 records it, outcome A (§ The floor's clause, and the reference half's probe bullet; no outcome-B bullet). The next two are V5.6's read-only-agents bullet (`#72/body/4`), which `READ_ONLY`'s comment cites — if either is `0`, stop and reconcile. If the third line is `1` and the first two are `0`, P2 recorded the opposite (V5.10's outcome B: a workflow agent **has** an Agent tool) — stop: the `executed` rationale in this task and V6.3's "Why headless" are false as written, and D45's premise changes; surface it to the operator.

- [ ] **Step 2: Write the failing shape test**

Replace the whole of `.claude/workflows/tests/finish-ab-shape.mjs` with:

```js
#!/usr/bin/env node
// Stub harness for finish-ab.js. No agent is dispatched: the script is loaded through load-workflow.mjs and run
// with stubbed agent()/parallel()/log()/phase(); the panel guard (two to four arms, a Latin square), the planned-count
// log, the arm-isolation instruction, executed mode, the base/brief/rubric arguments, the runner's check log in the
// judges' prompt, the judges' read-only clause and the rank arithmetic are asserted — the scenarios that shipped
// before context-builder-kit#69 and that issue's, unioned and renumbered so no two share a number.
// Run: node .claude/workflows/tests/finish-ab-shape.mjs
import { loadWorkflow } from "./load-workflow.mjs";

const { meta, run: runWorkflow } = loadWorkflow(new URL("../finish-ab/finish-ab.js", import.meta.url));

let failures = 0;
const check = (cond, msg) => { if (!cond) { failures += 1; console.error(`FAIL: ${msg}`); } };

async function run(args, { armResult, judgeResult }) {
  const logs = [];
  const calls = [];
  const agent = async (prompt, opts) => {
    calls.push({ prompt, opts });
    return opts.phase === "Execute" ? armResult(opts, prompt) : judgeResult(opts, prompt);
  };
  const parallel = async (thunks) => Promise.all(thunks.map((t) => t())); // a throwing mock is a harness bug, not a "null agent" (context-builder-kit#58 item 10)
  const result = await runWorkflow(args, agent, parallel, (m) => logs.push(String(m)), () => {});
  return { result, logs, calls };
}

const arms = [
  { arm: "A", anon: "P", read: ".claude/commands/finish-procedure.md", verb: "follow it exactly as written, every step in order" },
  { arm: "B", anon: "Q", read: ".claude/commands/finish.md", verb: "satisfy it" },
];
const balanced = [
  { order: ["P", "Q"], effort: "high" }, { order: ["Q", "P"], effort: "high" },
  { order: ["P", "Q"], effort: "xhigh" }, { order: ["Q", "P"], effort: "xhigh" },
];
const base = { scratch: "/tmp/ab", repo: "owner/name", issue: 7, arms, judges: balanced };
const armOk = (opts) => ({ branch: `b-${opts.label}`, worktree: `/wt/${opts.label}`, commits: [{ sha: "abc", subject: "test: red" }], plan_path: "PLAN.md", pr_body_path: "PR_BODY.md", check_command: "mise run check", check_exit: 0, tests_written: ["t"], skills_invoked: ["simplify"], operational: [], gate_calls: [], handoff: "h", notes: "" });
const judgeOk = (opts) => {
  const order = balanced[Number(opts.label.match(/judge:(\d+)/)[1]) - 1].order;
  return { scores: order.map((arm) => ({ arm, fidelity: 4, assumptions: 4, tests: 4, implementation: 4, gate_honesty: 4, reviewability: 4, prose: 4, overall: 4, check_exit_observed: 0, defects: [] })), ranking: [...order], hallucinations: order[0] === "P" ? [{ arm: "P", claim_verbatim: "x", contradicting_source: "y" }] : [], graft: [], word_counts: [], notes: "" };
};

// 1. Balanced panel: planned count logged first, six calls, worktree isolation, model+effort on every call,
//    arm isolation instruction, ranks and flags computed.
{
  const { result, logs, calls } = await run(base, { armResult: armOk, judgeResult: judgeOk });
  check(/planned agents: 2 executors \+ 4 judges \+ up to 4 judge retries = at most 10/.test(logs[0] ?? ""), `planned count is the first log line (got: ${logs[0]})`);
  check(calls.length === 6, `six agents dispatched (got ${calls.length})`);
  const exec = calls.filter((c) => c.opts.phase === "Execute");
  check(exec.every((c) => c.opts.isolation === "worktree"), "every executor runs in its own worktree");
  check(calls.every((c) => c.opts.model && c.opts.effort), "every dispatch names model and effort");
  const armB = exec.find((c) => c.opts.label.includes("Q"));
  check(armB && armB.prompt.includes("Do not open .claude/commands/finish-procedure.md"), "arm B is told not to open arm A's file");
  check(exec.every((c) => /^arm:[PQ]@/.test(c.opts.label)) && exec.every((c) => !/^arm:[AB]@/.test(c.opts.label)), "labels carry the anonymised id (P/Q), never the arm letter");
  check(calls.filter((c) => c.opts.phase === "Judge").every((c) => /\b[PQ]: worktree/.test(c.prompt) && !/\b[AB]: worktree/.test(c.prompt)), "judges are told the arms by anonymised id, never by arm letter");
  check(result.ranks.P.join(",") === "1,2,1,2" && result.ranks.Q.join(",") === "2,1,2,1", `ranks follow each judge's ranking (got ${JSON.stringify(result.ranks)})`);
  check(result.flags.P === 2 && result.flags.Q === 0, `flags summed per arm (got ${JSON.stringify(result.flags)})`);
  check(result.plannedAgents === 10, "plannedAgents returned (2 executors + 4 judges + 4 retries)");
}

// 2. Odd panel refused before any dispatch.
{
  let err = null; let dispatched = 0;
  try { await run({ ...base, judges: balanced.slice(0, 3) }, { armResult: () => { dispatched += 1; return armOk({ label: "x" }); }, judgeResult: judgeOk }); } catch (e) { err = e; }
  check(err && /even number of judges/.test(err.message), `odd panel throws the even-number message (got: ${err && err.message})`);
  check(dispatched === 0, "nothing dispatched on an odd panel");
}

// 3. Even but unbalanced orders refused.
{
  let err = null;
  try { await run({ ...base, judges: [balanced[0], balanced[0], balanced[0], balanced[1]] }, { armResult: armOk, judgeResult: judgeOk }); } catch (e) { err = e; }
  check(err && /split evenly/.test(err.message), `unbalanced orders throw the split-evenly message (got: ${err && err.message})`);
}

// 4. A missing arm is logged as dropped by name and the judge panel is not dispatched; the run returns its record.
{
  const { result, logs, calls } = await run(base, { armResult: (opts) => (opts.label.includes("Q") ? null : armOk(opts)), judgeResult: judgeOk });
  check(logs.some((l) => /dropped arms .*Q: no result/.test(l)), `a null arm result is logged as dropped by anon id (got: ${logs.filter((l) => /dropped/.test(l)).join(" | ")})`);
  check(calls.filter((c) => c.opts.phase === "Judge").length === 0, "no judge is dispatched for a one-arm run");
  check(result.droppedArms.length === 1 && result.judges.length === 0 && result.panel === null, "the record names the dropped arm and carries no ranks");
}

// 4b. An arm result missing the fields the summary needs is malformed: dropped and named, never dereferenced.
{
  const { result, logs, calls } = await run(base, { armResult: (opts) => (opts.label.includes("Q") ? { branch: "b", worktree: "/w" } : armOk(opts)), judgeResult: judgeOk });
  check(logs.some((l) => /dropped arms .*Q: malformed result/.test(l)), "a malformed arm result is logged as dropped with its keys");
  check(calls.filter((c) => c.opts.phase === "Judge").length === 0 && result.droppedArms.length === 1, "no crash, no judging");
}

// 6. Unknown judge ids and missing arguments are refused before any dispatch.
{
  let err = null; let dispatched = 0;
  const count = (opts) => { dispatched += 1; return armOk(opts); };
  try { await run({ ...base, judges: [{ order: ["X", "Y"], effort: "high" }, { order: ["Y", "X"], effort: "high" }] }, { armResult: count, judgeResult: judgeOk }); } catch (e) { err = e; }
  check(err && /permutation of the arm ids P, Q/.test(err.message) && dispatched === 0, `unknown judge ids throw before dispatch (got: ${err && err.message})`);
  err = null;
  try { await run({ ...base, issue: undefined }, { armResult: count, judgeResult: judgeOk }); } catch (e) { err = e; }
  check(err && /args\.issue is required/.test(err.message) && dispatched === 0, `a missing argument throws before dispatch (got: ${err && err.message})`);
  err = null;
  try { await run({ ...base, arms: [arms[0], { ...arms[1], anon: "P" }] }, { armResult: count, judgeResult: judgeOk }); } catch (e) { err = e; }
  check(err && /anon ids must be distinct/.test(err.message) && dispatched === 0, `duplicate anon ids throw before dispatch (got: ${err && err.message})`);
}

// 7. Defaults and overrides reach every call: opus/high by default; a caller's model and effort on the executors,
//    the model on the judges, each judge keeping its own effort.
{
  const { calls } = await run(base, { armResult: armOk, judgeResult: judgeOk });
  check(calls.every((c) => c.opts.model === "opus"), "the default model is opus on every call");
  const ex = calls.filter((c) => c.opts.phase === "Execute");
  check(ex.every((c) => c.opts.effort === "high") && ex.some((c) => c.opts.label === "arm:P@opus/high"), "executors default to high with the label naming both");
  check(calls.some((c) => c.opts.label === "judge:3@xhigh") && calls.some((c) => c.opts.label === "judge:1@high"), "each judge carries its own effort in its label");
  const o = await run({ ...base, model: "sonnet", effort: "medium" }, { armResult: armOk, judgeResult: judgeOk });
  check(o.calls.every((c) => c.opts.model === "sonnet"), "an override model reaches every call");
  check(o.calls.filter((c) => c.opts.phase === "Execute").every((c) => c.opts.effort === "medium"), "an override effort reaches the executors");
  check(o.calls.some((c) => c.opts.label === "judge:3@xhigh" && c.opts.effort === "xhigh"), "a judge keeps its own effort under an executor override");
  const q = o.calls.find((c) => c.opts.label.startsWith("judge:2@"));
  check(q && q.prompt.indexOf("Q: worktree") < q.prompt.indexOf("P: worktree"), "judge 2 reads the arms in its own order (Q before P)");
}

// 8. A judge that returned nothing is retried once, labelled :retry; a retried verdict counts and nothing is dropped.
{
  let second = 0;
  const { result, logs, calls } = await run(base, { armResult: armOk, judgeResult: (opts, prompt) => { if (/judge:2@high$/.test(opts.label)) { second += 1; return null; } return judgeOk(opts, prompt); } });
  check(calls.some((c) => c.opts.label === "judge:2@high:retry"), "the failed judge is retried once with the :retry label");
  check(logs.some((l) => /retrying once: judge 2/.test(l)), "the retry names the judge");
  check(result.panel && result.panel.returned === 4 && !logs.some((l) => /dropped judges/.test(l)), `a retried verdict counts (got panel ${JSON.stringify(result.panel)})`);
}

// 8b. Two judges return nothing with mixed retry outcomes: the retried verdict lands on ITS judge index
//     (the index-list reindex — judged[i] from retried[k]), the still-failing judge is dropped by name,
//     and the panel counts three. One failure cannot tell i from k; two can.
{
  const seen = { 2: 0, 4: 0 };
  const { result, logs, calls } = await run(base, { armResult: armOk, judgeResult: (opts, prompt) => {
    const m = opts.label.match(/^judge:(\d+)@\w+(:retry)?$/); const j = Number(m[1]);
    if (j === 2) { seen[2] += 1; return null; }
    if (j === 4) { seen[4] += 1; return m[2] ? judgeOk(opts, prompt) : null; }
    return judgeOk(opts, prompt);
  } });
  check(seen[2] === 2 && seen[4] === 2, `both failed judges are retried once (got ${JSON.stringify(seen)})`);
  check(calls.some((c) => c.opts.label === "judge:4@xhigh:retry"), "the retry keeps judge 4's own order and effort");
  check(result.panel && result.panel.returned === 3, `the retried verdict counts on its own index and the failed one does not (got panel ${JSON.stringify(result.panel)})`);
  check(logs.some((l) => /dropped judges .*judge 2 \(Q>P\): no result/.test(l)) && !logs.some((l) => /dropped judges .*judge 4/.test(l)), `judge 2 is dropped by name and judge 4 is not (got: ${logs.filter((l) => /dropped/.test(l)).join(" | ")})`);
}

// 5. A judge whose ranking omits an arm is dropped by name and its votes are not counted; the surviving
//    panel's order balance is re-checked and reported.
{
  const { result, logs } = await run(base, { armResult: armOk, judgeResult: (opts, prompt) => { const j = judgeOk(opts, prompt); if (/judge:2@/.test(opts.label)) j.ranking = ["P"]; return j; } });
  check(logs.some((l) => /dropped judges .*judge 2 \(Q>P\): malformed ranking/.test(l)), `a malformed ranking is named with its judge index and order (got: ${logs.filter((l) => /dropped/.test(l)).join(" | ")})`);
  check(result.ranks.P.length === 3 && result.ranks.Q.length === 3, `the malformed judge's votes are excluded from both arms (got ${JSON.stringify(result.ranks)})`);
  check(logs.some((l) => /surviving panel is unbalanced/.test(l)), "an unbalanced surviving panel is reported");
  check(Array.isArray(result.droppedJudges) && result.droppedJudges.length === 1, "droppedJudges is returned");
}

// 9. Three arms: a cyclic Latin square (every arm read in every position once) is accepted; per-arm model and
//    effort reach each executor; an arm's `also` files are read by it and forbidden to the others, while a file
//    every arm shares is forbidden to none.
const three = [
  { arm: "A", anon: "P", read: ".claude/commands/finish.md", verb: "satisfy it", effort: "high" },
  { arm: "B", anon: "Q", read: ".claude/commands/finish.md", verb: "satisfy it", effort: "medium" },
  { arm: "C", anon: "R", read: ".claude/commands/finish.md", verb: "satisfy it", also: ["x/subagent-driven-arm.md"], model: "sonnet", effort: "high" },
];
const latin = [{ order: ["P", "Q", "R"] }, { order: ["Q", "R", "P"] }, { order: ["R", "P", "Q"] }];
const judgeFor = (panel) => (opts) => { const order = panel[Number(opts.label.match(/judge:(\d+)/)[1]) - 1].order; return { scores: [], measures: [], ranking: [...order], hallucinations: [], graft: [], word_counts: [], notes: "" }; };
{
  const { result, logs, calls } = await run({ ...base, arms: three, judges: latin }, { armResult: armOk, judgeResult: judgeFor(latin) });
  check(/planned agents: 3 executors \+ 3 judges \+ up to 3 judge retries = at most 9/.test(logs[0] ?? ""), `three-arm planned count (got: ${logs[0]})`);
  const ex = calls.filter((c) => c.opts.phase === "Execute");
  check(ex.length === 3 && ex.find((c) => c.opts.label === "arm:Q@opus/medium" && c.opts.effort === "medium"), "an arm's own effort reaches its executor");
  const r = ex.find((c) => c.opts.label.startsWith("arm:R@"));
  // R's model differs from the run default (opus), so this proves the per-arm override reaches agent(); P keeps the default.
  check(r && r.opts.label === "arm:R@sonnet/high" && r.opts.model === "sonnet" && ex.find((c) => c.opts.label.startsWith("arm:P@")).opts.model === "opus", "an arm's own model reaches its executor, and an arm without one keeps the run's");
  check(r && r.prompt.includes("then x/subagent-driven-arm.md in full") && !/Do not open [^.]*\.claude\/commands\/finish\.md/.test(r.prompt), "arm R reads its extra file, and the shared file is forbidden to no one");
  const p = ex.find((c) => c.opts.label.startsWith("arm:P@"));
  check(p && p.prompt.includes("Do not open x/subagent-driven-arm.md"), "arm P is told not to open arm R's extra file");
  check(result.ranks.P.join(",") === "1,3,2" && result.ranks.R.join(",") === "3,2,1", `three-arm ranks follow each judge (got ${JSON.stringify(result.ranks)})`);
}

// 10. Three arms: a panel that is not a multiple of three, or that reads one arm first more often, is refused
//     before any dispatch.
{
  let err = null; let dispatched = 0;
  const count = (opts) => { dispatched += 1; return armOk(opts); };
  try { await run({ ...base, arms: three, judges: latin.slice(0, 2) }, { armResult: count, judgeResult: judgeFor(latin) }); } catch (e) { err = e; }
  check(err && /multiple of 3 judges/.test(err.message) && dispatched === 0, `a two-judge panel over three arms throws before dispatch (got: ${err && err.message})`);
  err = null;
  const skewed = [{ order: ["P", "Q", "R"] }, { order: ["P", "R", "Q"] }, { order: ["Q", "P", "R"] }];
  try { await run({ ...base, arms: three, judges: skewed }, { armResult: count, judgeResult: judgeFor(skewed) }); } catch (e) { err = e; }
  check(err && /every position equally often/.test(err.message) && dispatched === 0, `a position-skewed panel throws before dispatch (got: ${err && err.message})`);
}

// 11. Executed mode: arms that ran outside the workflow are judged without an Execute phase; an executed entry
//     naming no arm is refused before any dispatch.
{
  const executed = three.map((c) => ({ anon: c.anon, result: armOk({ label: c.anon }) }));
  const { result, logs, calls } = await run({ ...base, arms: three, judges: latin, executed }, { armResult: armOk, judgeResult: judgeFor(latin) });
  check(calls.every((c) => c.opts.phase === "Judge") && calls.length === 3, `only the judges are dispatched (got ${calls.map((c) => c.opts.label).join(", ")})`);
  check(/0 executors \(3 arms executed outside this workflow\)/.test(logs[0] ?? "") && result.plannedAgents === 6, `the planned count excludes the executed arms (got: ${logs[0]}, ${result.plannedAgents})`);
  let err = null;
  try { await run({ ...base, arms: three, judges: latin, executed: [{ anon: "Z", result: {} }] }, { armResult: armOk, judgeResult: judgeFor(latin) }); } catch (e) { err = e; }
  check(err && /executed\[0\] must name one of the arm ids/.test(err.message), `an unknown executed arm throws (got: ${err && err.message})`);
  err = null; let dispatched = 0;
  try { await run({ ...base, arms: three, judges: latin, executed: "/tmp/executed.json" }, { armResult: (o) => { dispatched += 1; return armOk(o); }, judgeResult: judgeFor(latin) }); } catch (e) { err = e; }
  check(err && /args\.executed must be a list/.test(err.message) && dispatched === 0, `a non-list executed throws before any executor is paid for (got: ${err && err.message})`);
  err = null;
  try { await run({ ...base, arms: three, judges: latin, executed: [executed[0], executed[0], executed[1]] }, { armResult: armOk, judgeResult: judgeFor(latin) }); } catch (e) { err = e; }
  check(err && /names an arm more than once/.test(err.message), `a duplicate executed arm throws (got: ${err && err.message})`);
}

// 12. Duplicate arm labels are refused before any dispatch (the returned record maps each anon id back to its arm).
{
  let err = null; let dispatched = 0;
  const count = (opts) => { dispatched += 1; return armOk(opts); };
  try { await run({ ...base, arms: [arms[0], { ...arms[1], arm: "A" }] }, { armResult: count, judgeResult: judgeOk }); } catch (e) { err = e; }
  check(err && /arm labels must be distinct/.test(err.message), "duplicate arm labels throw");
  check(dispatched === 0, "and nothing was dispatched first");
}

// 13. A well-formed judge with no `hallucinations` list — missing, or not a list — counts zero flags instead of
//     crashing, and is logged as undercounting.
{
  const noHall = (opts, prompt) => { const j = judgeOk(opts, prompt); delete j.hallucinations; return j; };
  const { result, logs } = await run(base, { armResult: armOk, judgeResult: noHall });
  check(result.flags.P === 0 && result.flags.Q === 0, `missing hallucinations counts zero (got ${JSON.stringify(result.flags)})`);
  check(logs.some((l) => /judge 1 \(P>Q\).*returned no contradicted-claims list/.test(l)), "a judge with no contradicted-claims list is logged");
  const strHall = (opts, prompt) => { const j = judgeOk(opts, prompt); j.hallucinations = "none"; return j; };
  const { result: r2 } = await run(base, { armResult: armOk, judgeResult: strHall });
  check(r2.flags.P === 0 && r2.flags.Q === 0, "a non-list hallucinations value counts zero instead of throwing");
}

// 14. A contradicted claim naming no arm id is counted as unattributed, for neither arm.
{
  const stray = (opts, prompt) => { const j = judgeOk(opts, prompt); j.hallucinations = [{ arm: "Z", claim_verbatim: "x", contradicting_source: "y" }]; return j; };
  const { result, logs } = await run(base, { armResult: armOk, judgeResult: stray });
  check(result.unattributedFlags === 4, `four judges × one stray entry = 4 unattributed (got ${result.unattributedFlags})`);
  check(result.flags.P === 0 && result.flags.Q === 0, "stray entries count for neither arm");
  check(logs.some((l) => /name no arm id/.test(l)), "the stray entries are logged");
}

// 15. Five arms are refused before any dispatch — the two-to-four ceiling bounds panel size and cost.
{
  let err = null; let dispatched = 0;
  const five = ["P", "Q", "R", "S", "T"].map((anon, i) => ({ arm: String.fromCharCode(65 + i), anon, read: ".claude/commands/finish.md" }));
  try { await run({ ...base, arms: five, judges: [] }, { armResult: (o) => { dispatched += 1; return armOk(o); }, judgeResult: judgeOk }); } catch (e) { err = e; }
  check(err && /two to four arms \(got 5\)/.test(err.message) && dispatched === 0, `five arms throw before dispatch (got: ${err && err.message})`);
}

// 16. A replay's base commit reaches every executor, and is absent when no base is given.
{
  const { calls } = await run({ ...base, base: "abc1234" }, { armResult: armOk, judgeResult: judgeOk });
  const ex = calls.filter((c) => c.opts.phase === "Execute");
  check(ex.length === 2 && ex.every((c) => c.prompt.includes("git switch -c <branch> abc1234")), "every executor is told to branch at the replay's base commit");
  const { calls: plain } = await run(base, { armResult: armOk, judgeResult: judgeOk });
  check(plain.filter((c) => c.opts.phase === "Execute").every((c) => !c.prompt.includes("git switch -c")), "no base, no branch-at-commit instruction");
}

// 17. brief and rubric override the scratch defaults in every arm and judge prompt.
{
  const { calls } = await run({ ...base, brief: "/x/brief.md", rubric: "/x/rubric.md" }, { armResult: armOk, judgeResult: judgeOk });
  const ex = calls.filter((c) => c.opts.phase === "Execute"); const jd = calls.filter((c) => c.opts.phase === "Judge");
  check(ex.every((c) => c.prompt.includes("/x/brief.md") && !c.prompt.includes("/tmp/ab/operator-brief.md")), "arms read the named brief, not the scratch default");
  check(jd.length === 4 && jd.every((c) => c.prompt.includes("/x/rubric.md") && c.prompt.includes("/x/brief.md") && !c.prompt.includes("/tmp/ab/judge-rubric.md")), "judges read the named rubric and brief, not the scratch defaults");
}

// 18. A malformed `also` — not a list, or holding an empty path — is refused before any dispatch.
{
  for (const also of ["x.md", ["", "x.md"], [3]]) {
    let err = null; let dispatched = 0;
    try { await run({ ...base, arms: [arms[0], { ...arms[1], also }] }, { armResult: (o) => { dispatched += 1; return armOk(o); }, judgeResult: judgeOk }); } catch (e) { err = e; }
    check(err && /also must be a list of file paths/.test(err.message) && dispatched === 0, `also ${JSON.stringify(also)} throws before dispatch (got: ${err && err.message})`);
  }
}

// 20. Headless arms whose runner ran the check task once: every judge is given each arm's log and exit and told to read
//     it, not re-run the whole gate — eighteen parallel per-judge gates on one machine would have measured the machine
//     (context-builder-kit#69). With no runner log the judge runs the gate itself, as the rubric says.
{
  const withLog = arms.map((c) => ({ anon: c.anon, result: { ...armOk({ label: c.anon }), runner_check: { command: "mise run check", exit: c.anon === "P" ? 3 : 0, log: `/out/${c.anon}.check.log` } } }));
  const { calls } = await run({ ...base, executed: withLog }, { armResult: armOk, judgeResult: judgeOk });
  const jd = calls.filter((c) => c.opts.phase === "Judge");
  check(jd.length === 4 && jd.every((c) => c.prompt.includes("/out/P.check.log") && c.prompt.includes("/out/Q.check.log") && /P: [^;]*exit 3/.test(c.prompt)), "each judge is given every arm's runner check log and its exit");
  check(jd.every((c) => /do not re-run the whole gate/i.test(c.prompt)), "judges are told to read the runner's log, not re-run the whole gate");
  const without = arms.map((c) => ({ anon: c.anon, result: armOk({ label: c.anon }) }));
  const { calls: c2 } = await run({ ...base, executed: without }, { armResult: armOk, judgeResult: judgeOk });
  check(c2.filter((c) => c.opts.phase === "Judge").every((c) => !/do not re-run the whole gate/i.test(c.prompt)), "with no runner log, the judge is not told to skip the gate");
}

// 21. Every judge's prompt carries the read-only clause — a judge never modifies a worktree, not even to restore a
//     file — and no executor's does (an arm must write); the judges' `measures` stay optional, so a rubric with no
//     verdict rule leaves them out.
{
  const { calls } = await run(base, { armResult: armOk, judgeResult: judgeOk });
  const jd = calls.filter((c) => c.opts.phase === "Judge"); const ex = calls.filter((c) => c.opts.phase === "Execute");
  check(jd.length === 4 && jd.every((c) => c.prompt.includes("not even to restore a file afterwards")), "every judge is given the read-only clause");
  check(ex.length === 2 && ex.every((c) => !c.prompt.includes("not even to restore a file afterwards")), "no executor is given the judges' read-only clause");
  const js = jd[0].opts.schema;
  check(Boolean(js.properties.measures) && !js.required.includes("measures"), "measures is a JUDGE_SCHEMA property, and optional");
}

check(meta.name === "finish-ab" && Array.isArray(meta.phases) && meta.phases.length === 2, "meta literal is well-formed");
if (failures) { console.error(`finish-ab-shape: ${failures} failure(s)`); process.exit(1); }
console.log("finish-ab-shape: 23 scenarios ok");
```

- [ ] **Step 3: Run it against the unfixed `finish-ab.js`**

Run: `rc=0; out=$(node .claude/workflows/tests/finish-ab-shape.mjs 2>&1) || rc=$?; grep -m1 '^Error' <<<"$out"; echo "exit=$rc"` (captured first, so `grep -m1` exiting early cannot turn node's exit into a SIGPIPE)
Expected:
```
Error: finish-ab: args.arms must name exactly two arms
exit=1
```
(scenario 9, the first three-arm run, reaches the two-arm guard, which throws out of the harness). Record: `V6.2 finish-ab-shape.mjs — Error: finish-ab: args.arms must name exactly two arms`.

- [ ] **Step 4: The change**

Replace the whole of `.claude/workflows/finish-ab/finish-ab.js` with:

```js
export const meta = {
  name: "finish-ab",
  description: "A/B/n of the /finish executor on one issue: two to four arms, each in its own git worktree at a named model and effort and under its own instruction files; a blind judge panel balanced so every arm is read in every position equally often, that verifies before it scores",
  phases: [
    { title: "Execute", detail: "two to four arms, each in its own git worktree, each reading its own instruction files and told not to open the others'" },
    { title: "Judge", detail: "blind judges reading the anonymised worktrees in balanced orders; ranks, contradicted claims, graft" },
  ],
}

// A worked exemplar of orchestration.md § The dispatch-mechanism decision (a Workflow: deterministic fan-out over
// the arms and a judge panel) and of § Fan-out discipline's judge-panel rule: every arm read in every position
// equally often (two arms: an even number, half per order), judges scoring dimensions and reporting contradicted
// claims before they rank. Every agent() names model and effort.
//
// args:
//   scratch — absolute path of the run's scratch directory; receives judges/judge-<n>.md, and holds
//             operator-brief.md and judge-rubric.md unless brief / rubric name them elsewhere
//   brief   — optional: absolute path of the operator brief (default <scratch>/operator-brief.md)
//   rubric  — optional: absolute path of the judge rubric (default <scratch>/judge-rubric.md)
//   repo    — "owner/name" the arms execute against (reads with gh only; the brief forbids remote writes)
//   issue   — the issue number every arm executes
//   base    — optional: the commit every arm starts from (a replay); omitted, an arm starts where its worktree does
//   arms    — two to four: [{ arm: "A", anon: "P", read: ".claude/commands/finish.md", verb: "satisfy it",
//                             also: [".claude/workflows/finish-ab/<run>/<extra>.md"], model: "opus", effort: "high" }, …]
//             `anon` is the only id a judge ever sees — but not the only thing that can name an arm: a rubric that
//             points at a file naming each arm's mode, or an arm's own untracked workspace (a subagent-driven arm's
//             `.sdd/`), reveals it too (context-builder-kit#69; judge-rubric.md lists what to strip).
//             `verb` is how the arm is told to use its files; `also` names
//             further instruction files that arm reads after `read`; `model` and `effort` override the run's defaults
//   judges  — [{ order: ["P","Q"], effort: "high" }, …] — every arm in every reading position equally often, so the
//             panel is a multiple of the arm count (two arms: an even count, half per order)
//   model   — optional, default "opus": the workhorse tier for executors and judges (never above the session's)
//   effort  — optional, default "high": the executors' effort unless an arm names its own; each judge carries its own
//   executed — optional: [{ anon, result }] for arms that already ran outside this workflow, then the Execute phase is
//             skipped and only the panel runs. A workflow agent has no Agent tool (.claude/rules/pr-review.md § The
//             floor records the probe, its Claude Code version and its date), so an arm that must dispatch subagents —
//             a subagent-driven arm, or a review floor with its fan-out — runs as a headless `claude -p` session
//             instead (`run-arms-headless.py`), and its structured result is handed in here

const S = args.scratch
const BRIEF = args.brief ?? `${S}/operator-brief.md`
const RUBRIC = args.rubric ?? `${S}/judge-rubric.md`
const MODEL = args.model ?? "opus"
const EFFORT = args.effort ?? "high"

// Every argument is validated before any dispatch: a run that pays for its executors and a judge panel
// and returns empty ranks because an id was mistyped is the silent failure this guard exists to stop.
for (const k of ["scratch", "repo", "issue"]) if (args[k] === undefined || args[k] === null || args[k] === "") throw new Error(`finish-ab: args.${k} is required`)
if (!Array.isArray(args.arms) || args.arms.length < 2 || args.arms.length > 4) throw new Error(`finish-ab: args.arms must name two to four arms (got ${Array.isArray(args.arms) ? args.arms.length : typeof args.arms})`)
args.arms.forEach((c) => { for (const k of ["arm", "anon", "read"]) if (!c || !c[k]) throw new Error(`finish-ab: every arm needs arm, anon and read (got ${JSON.stringify(c)})`) })
args.arms.forEach((c) => { if (c.also !== undefined && !(Array.isArray(c.also) && c.also.every((f) => typeof f === "string" && f))) throw new Error(`finish-ab: arm ${c.anon}'s also must be a list of file paths (got ${JSON.stringify(c.also)})`) })
const ids = args.arms.map((c) => c.anon)
if (new Set(ids).size !== ids.length) throw new Error(`finish-ab: anon ids must be distinct (got ${ids.join(", ")})`)
const armLabels = args.arms.map((c) => c.arm)
if (new Set(armLabels).size !== armLabels.length) throw new Error(`finish-ab: arm labels must be distinct — the returned record is the only map from each anon id back to its arm (got ${armLabels.join(", ")})`)
const N = ids.length
const judges = Array.isArray(args.judges) ? args.judges : []
if (judges.length === 0 || judges.length % N !== 0) throw new Error(N === 2
  ? `finish-ab: a two-arm panel needs an even number of judges, half per reading order (got ${judges.length})`
  : `finish-ab: a ${N}-arm panel needs a multiple of ${N} judges, so every arm can be read in every position equally often (got ${judges.length})`)
judges.forEach((j, i) => { if (!j || !Array.isArray(j.order) || j.order.length !== N || new Set(j.order).size !== N || !ids.every((id) => j.order.includes(id))) throw new Error(`finish-ab: judge ${i + 1}'s order must be a permutation of the arm ids ${ids.join(", ")} (got ${JSON.stringify(j && j.order)})`) })
const orderKey = (j) => j.order.join(">")
// Position balance: how often each arm is read at each position. Every cell equal is the Latin-square condition;
// for two arms it is the same thing as half the panel per order.
const positionCounts = (panel) => ids.map((id) => ids.map((_p, pos) => panel.filter((j) => j.order[pos] === id).length))
const balanced = (panel) => { const c = positionCounts(panel).flat(); return c.length > 0 && c.every((x) => x === c[0]) && c[0] > 0 }
if (!balanced(judges)) {
  const byOrder = {}
  judges.forEach((j) => { byOrder[orderKey(j)] = (byOrder[orderKey(j)] ?? 0) + 1 })
  throw new Error(N === 2
    ? `finish-ab: judges must split evenly across the two reading orders (got ${JSON.stringify(Object.entries(byOrder))})`
    : `finish-ab: every arm must be read in every position equally often (reads per arm per position: ${JSON.stringify(Object.fromEntries(ids.map((id, a) => [id, positionCounts(judges)[a]])))})`)
}

// executed, when given at all, must be the list the headless runner writes: a path or a map here would otherwise
// be ignored and the Execute phase would pay for workflow executors that cannot dispatch subagents.
if (args.executed !== undefined && args.executed !== null && !Array.isArray(args.executed)) throw new Error(`finish-ab: args.executed must be a list of { anon, result } (got ${typeof args.executed}); read the runner's executed.json and pass its contents`)
const EXECUTED = Array.isArray(args.executed) ? args.executed : null
if (EXECUTED) EXECUTED.forEach((e, i) => { if (!e || !ids.includes(e.anon)) throw new Error(`finish-ab: executed[${i}] must name one of the arm ids ${ids.join(", ")} (got ${JSON.stringify(e && e.anon)})`) })
if (EXECUTED && new Set(EXECUTED.map((e) => e.anon)).size !== EXECUTED.length) throw new Error(`finish-ab: executed names an arm more than once (got ${EXECUTED.map((e) => e.anon).join(", ")})`)
const plannedAgents = (EXECUTED ? 0 : N) + judges.length * 2
log(EXECUTED
  ? `finish-ab: planned agents: 0 executors (${EXECUTED.length} arms executed outside this workflow) + ${judges.length} judges + up to ${judges.length} judge retries = at most ${plannedAgents}`
  : `finish-ab: planned agents: ${N} executors + ${judges.length} judges + up to ${judges.length} judge retries = at most ${plannedAgents}, plus any subagents an arm dispatches itself`)

// run-arms-headless.py keeps a copy of this schema (a workflow script gets no fs to share a module). The copies differ
// in one field on purpose: `dispatched` is optional here, where the arm is a workflow agent and cannot dispatch, and
// required there, where a headless `claude -p` arm can. finish-ab-shape.mjs diffs the two.
const ARM_SCHEMA = {
  type: "object",
  required: ["branch", "worktree", "commits", "plan_path", "pr_body_path", "check_command", "check_exit", "tests_written", "skills_invoked", "operational", "gate_calls", "handoff", "notes"],
  properties: {
    branch: { type: "string" },
    worktree: { type: "string", description: "absolute path of the worktree you worked in" },
    commits: { type: "array", items: { type: "object", required: ["sha", "subject"], properties: { sha: { type: "string" }, subject: { type: "string" } } }, description: "oldest first" },
    plan_path: { type: "string" },
    pr_body_path: { type: "string" },
    check_command: { type: "string" },
    check_exit: { type: "integer" },
    tests_written: { type: "array", items: { type: "string" } },
    skills_invoked: { type: "array", items: { type: "string" }, description: "exact skill names actually invoked via the Skill tool" },
    operational: { type: "array", items: { type: "string" }, description: "criteria left open because they need the operator or a device" },
    gate_calls: { type: "array", items: { type: "string" }, description: "every decision you made where the flow would have waited for the operator" },
    dispatched: { type: "array", items: { type: "object", required: ["role", "model", "effort"], properties: { role: { type: "string" }, model: { type: "string" }, effort: { type: "string" } } }, description: "every subagent you dispatched yourself, outside the review skills: its role, model and effort" },
    handoff: { type: "string" },
    notes: { type: "string" },
  },
}

const filesOf = (cell) => [cell.read, ...(cell.also ?? [])]
const othersFiles = (cell) => [...new Set(args.arms.filter((c) => c.anon !== cell.anon).flatMap(filesOf))].filter((f) => !filesOf(cell).includes(f))
const readLine = (cell) => (cell.also && cell.also.length ? `Then read ${cell.read} in full, then ${cell.also.join(", then ")} in full,` : `Then read ${cell.read} in your worktree in full`)
const baseLine = args.base ? ` Before anything else, create your branch at commit ${args.base} (\`git switch -c <branch> ${args.base}\`) — this run replays the issue from that commit, and nothing after it exists for you.` : ""
const armPrompt = (cell) => {
  const others = othersFiles(cell)
  const forbid = others.length ? `Do not open ${others.join(", ")} or anything under .claude/skills/` : "Do not open anything under .claude/skills/"
  return `You are executing issue #${args.issue} in the repository ${args.repo}, from inside a git worktree of your own — your current working directory. Read the operator brief at ${BRIEF} first; it states what non-interactive means for this run, the standing decisions, the hard limits and what to return.${baseLine}

${readLine(cell)} and ${cell.verb ?? "satisfy it"} for issue ${args.issue}, with the brief's non-interactive rules substituting only where the instructions would wait for the operator (the plan gate becomes PLAN.md, the push and PR become PR_BODY.md, operational criteria stay open). Read every input the instructions name, in full, before planning. ${forbid} — the files you were given, the issue and the inputs it names are your whole instruction. Invoke the skills it requires as skills. Return the structured result when the hand-off exists.`
}
const armModel = (cell) => cell.model ?? MODEL
const armEffort = (cell) => cell.effort ?? EFFORT

let arms
if (EXECUTED) {
  arms = args.arms.map((cell) => { const e = EXECUTED.find((x) => x.anon === cell.anon); return e ? { ...cell, result: e.result } : null })
} else {
  phase("Execute")
  arms = await parallel(args.arms.map((cell) => () =>
    agent(armPrompt(cell), {
      label: `arm:${cell.anon}@${armModel(cell)}/${armEffort(cell)}`,
      phase: "Execute",
      model: armModel(cell),
      effort: armEffort(cell),
      isolation: "worktree",
      agentType: "general-purpose",
      schema: ARM_SCHEMA,
    }).then((r) => ({ ...cell, result: r }))
  ))
}

// Junk structured output is a script-side problem: an arm result missing the fields the summary and the
// judges rely on is dropped and named, never dereferenced. Judging with an arm missing compares fewer arms
// than the panel was balanced for, so a dropped arm ends the run here with the record it has, and the judge
// panel is not paid for.
const wellFormedArm = (r) => r && Array.isArray(r.commits) && typeof r.worktree === "string" && typeof r.branch === "string" && Array.isArray(r.skills_invoked)
const done = arms.filter((a) => a && wellFormedArm(a.result))
const droppedArms = args.arms.filter((c) => !done.find((d) => d.anon === c.anon)).map((c) => { const got = arms.find((a) => a && a.anon === c.anon); return `${c.anon}: ${got && got.result ? "malformed result " + JSON.stringify(Object.keys(got.result)) : "no result"}` })
if (droppedArms.length) {
  log(`finish-ab: dropped arms (the judge panel is not dispatched; its balance assumed every arm): ${droppedArms.join("; ")}`)
  return { arms: done, droppedArms, judges: [], ranks: {}, flags: {}, panel: null, plannedAgents }
}
log(`finish-ab: ${done.length}/${N} arms returned: ${done.map((d) => `${d.anon}=${d.result.commits.length} commits, check exit ${d.result.check_exit}, skills [${d.result.skills_invoked.join(" ")}]${Array.isArray(d.result.dispatched) && d.result.dispatched.length ? `, ${d.result.dispatched.length} dispatched` : ""}`).join(" | ")}`)

const JUDGE_SCHEMA = {
  type: "object",
  required: ["scores", "ranking", "hallucinations", "graft", "word_counts", "notes"],
  properties: {
    measures: {
      type: "array",
      description: "only when the rubric defines them: the order-independent measures a run's verdict rule scores, one entry per arm, as observed facts",
      items: {
        type: "object",
        required: ["arm", "red_first", "commit_per_finding", "tags_resolve", "criteria_met", "contaminated_hunks"],
        properties: {
          arm: { type: "string" },
          red_first: { type: "boolean" }, commit_per_finding: { type: "boolean" }, tags_resolve: { type: "boolean" },
          criteria_met: { type: "array", items: { type: "string" } },
          contaminated_hunks: { type: "array", items: { type: "string" } },
        },
      },
    },
    scores: {
      type: "array",
      items: {
        type: "object",
        required: ["arm", "fidelity", "assumptions", "tests", "implementation", "gate_honesty", "reviewability", "prose", "overall", "check_exit_observed", "defects"],
        properties: {
          arm: { type: "string" },
          fidelity: { type: "number" }, assumptions: { type: "number" }, tests: { type: "number" }, implementation: { type: "number" },
          gate_honesty: { type: "number" }, reviewability: { type: "number" }, prose: { type: "number" }, overall: { type: "number" },
          check_exit_observed: { type: "integer", description: "exit status of the check task in that worktree: the runner's logged exit when your prompt names a log, else the exit when YOU ran it; -1 if neither" },
          defects: { type: "array", items: { type: "object", required: ["quote", "problem"], properties: { quote: { type: "string" }, problem: { type: "string" } } } },
        },
      },
    },
    ranking: { type: "array", items: { type: "string" }, minItems: N, maxItems: N, description: "every arm id, best to worst" },
    hallucinations: { type: "array", items: { type: "object", required: ["arm", "claim_verbatim", "contradicting_source"], properties: { arm: { type: "string" }, claim_verbatim: { type: "string" }, contradicting_source: { type: "string" } } } },
    graft: { type: "array", items: { type: "object", required: ["arm", "idea"], properties: { arm: { type: "string" }, idea: { type: "string" } } } },
    word_counts: { type: "array", items: { type: "object", required: ["arm", "pr_body", "plan", "added_lines"], properties: { arm: { type: "string" }, pr_body: { type: "integer" }, plan: { type: "integer" }, added_lines: { type: "integer" } } } },
    notes: { type: "string" },
  },
}

phase("Judge")
const byAnon = {}
done.forEach((d) => { byAnon[d.anon] = d.result })
// A headless run's runner ran the check task once per arm, after every arm finished (run-arms-headless.py
// run_checks): the judges read that log instead of each re-running the gate — eighteen parallel gates on one
// machine would have measured the machine, not the arms (context-builder-kit#69).
const gateOf = (id) => byAnon[id].runner_check
const describe = (id) => `${id}: worktree ${byAnon[id].worktree}, branch ${byAnon[id].branch}${gateOf(id) ? `, check task run once by the runner: exit ${gateOf(id).exit}, log ${gateOf(id).log}` : ""}`
const gateNote = done.some((d) => d.result.runner_check) ? " The runner ran the check task once in each worktree that names a log, after every arm finished: read that log and its exit — do not re-run the whole gate, since parallel gates on one machine measure the machine rather than the arms (re-running a single test file is fine) — and report that exit as check_exit_observed." : ""
// A judge reads; it never writes — the read-only rule for dispatched agents (orchestration.md § Fan-out discipline):
// an agent that edits a tracked file and restores it leaves a build tool judging a stale artifact fresh. Running the
// gate the rubric names is reading.
const READ_ONLY = "Never modify any worktree or the repository — not even to restore a file afterwards. Running the gate the rubric names is reading; to try anything else (a patch, a probe), copy what you need into a scratch directory and give it its own build cache."
const judgePrompt = (j, i) => `You are judge ${i + 1} of ${judges.length}. Read the rubric at ${RUBRIC} and apply it exactly. The ${N === 2 ? "two" : N} arms are, in the order you must read them: ${j.order.map(describe).join("; ")}.${gateNote} Read the operator brief at ${BRIEF} too, so you know what every arm was told. Verify against the sources the rubric names before scoring. Write your full report to ${S}/judges/judge-${i + 1}.md and return the structured result with one scores entry per arm named ${N === 2 ? j.order.join(" and ") : j.order.join(", ")}. Do not edit any file in any worktree or in the repository. ${READ_ONLY}`
const judgeOpts = (j, i, retry) => { const effort = j.effort ?? "high"; return { label: `judge:${i + 1}@${effort}${retry ? ":retry" : ""}`, phase: "Judge", model: MODEL, effort, agentType: "general-purpose", schema: JUDGE_SCHEMA } }

const judged = await parallel(judges.map((j, i) => () => agent(judgePrompt(j, i), judgeOpts(j, i, false))))
// A judge that returned nothing is retried once at the same order and effort — the retry pass, not the
// prompt, is the remedy (orchestration.md § Fan-out discipline).
const failedJudges = judges.map((_j, i) => i).filter((i) => !judged[i])
if (failedJudges.length) {
  log(`finish-ab: ${failedJudges.length} judge(s) returned nothing — retrying once: ${failedJudges.map((i) => `judge ${i + 1}`).join(", ")}`)
  const retried = await parallel(failedJudges.map((i) => () => agent(judgePrompt(judges[i], i), judgeOpts(judges[i], i, true))))
  failedJudges.forEach((i, k) => { judged[i] = retried[k] })
}

// A judge that returned nothing, or whose ranking is not exactly the arm ids, is dropped coverage:
// named by index and reading order, never a silent shrink of the panel (orchestration.md § Fan-out
// discipline — log what was dropped). The surviving panel is re-checked for position balance.
const wellFormed = (j) => j && Array.isArray(j.ranking) && j.ranking.length === N && ids.every((id) => j.ranking.includes(id))
const dropped = judges.map((j, i) => (wellFormed(judged[i]) ? null : `judge ${i + 1} (${j.order.join(">")}): ${judged[i] ? "malformed ranking " + JSON.stringify(judged[i].ranking) : "no result"}`)).filter(Boolean)
if (dropped.length) log(`finish-ab: dropped judges (no verdict counted): ${dropped.join("; ")}`)
const jok = judged.filter(wellFormed)
const survivors = judges.filter((_j, i) => wellFormed(judged[i]))
const survivingOrders = new Map()
survivors.forEach((j) => survivingOrders.set(orderKey(j), (survivingOrders.get(orderKey(j)) ?? 0) + 1))
if (jok.length < judges.length && !balanced(survivors)) log(`finish-ab: the surviving panel is unbalanced across reading orders (${[...survivingOrders.entries()].map(([k, v]) => `${k}: ${v}`).join(", ") || "none"}) — treat the ranks as advisory`)
// A well-formed ranking whose contradicted-claims list is missing or not a list counts zero flags rather than
// crashing after the panel is paid for (context-builder-kit#58 item 9) — but it is logged, because zero from a judge that reported
// nothing reads as a clean arm, and contradicted claims are the panel's first order-independent signal.
const claimsOf = (j) => (Array.isArray(j.hallucinations) ? j.hallucinations : [])
const noClaims = judges.map((j, i) => (wellFormed(judged[i]) && !Array.isArray(judged[i].hallucinations) ? `judge ${i + 1} (${j.order.join(">")})` : null)).filter(Boolean)
if (noClaims.length) log(`finish-ab: ${noClaims.join(", ")} returned no contradicted-claims list — counted as zero, so the arms' flags undercount`)
const ranks = {}
const flags = {}
ids.forEach((id) => {
  ranks[id] = jok.map((j) => j.ranking.indexOf(id) + 1)
  flags[id] = jok.reduce((n, j) => n + claimsOf(j).filter((h) => h.arm === id).length, 0)
})
const unattributed = jok.reduce((n, j) => n + claimsOf(j).filter((h) => !ids.includes(h.arm)).length, 0)
if (unattributed) log(`finish-ab: ${unattributed} contradicted-claim entr${unattributed === 1 ? "y" : "ies"} name no arm id and count for neither arm`)
log(`finish-ab: ranks: ${ids.map((id) => `${id}: ${ranks[id].join("/")}, flags ${flags[id]}`).join(" | ")}`)
return { arms: done, droppedArms: [], judges: jok, ranks, flags, droppedJudges: dropped, unattributedFlags: unattributed, panel: { planned: judges.length, returned: jok.length, byOrder: Object.fromEntries(survivingOrders) }, plannedAgents }
```

- [ ] **Step 5: Run the shape test, the loader test and the block**

Run:
```bash
node .claude/workflows/tests/finish-ab-shape.mjs && node .claude/workflows/tests/load-workflow-shape.mjs
grep -nE '(^|[[:space:](,;])#[0-9]{1,3}\b' .claude/workflows/finish-ab/finish-ab.js .claude/workflows/tests/finish-ab-shape.mjs; echo "bare=$?"
bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E '^(finish-ab-shape|always-loaded total|verification: )'; echo "exit=${PIPESTATUS[0]}"
```
Expected:
```
finish-ab-shape: 23 scenarios ok
load-workflow-shape: 3 cases ok
bare=1
finish-ab-shape: 23 scenarios ok
always-loaded total: N bytes
verification: kit sub-block complete
verification: done
exit=0
```
with `N` unchanged from before this task. No hook is touched.

- [ ] **Step 6: Commit**

```bash
git add .claude/workflows/finish-ab/finish-ab.js .claude/workflows/tests/finish-ab-shape.mjs
git commit -F- <<'EOF'
feat(workflows): V6 — finish-ab runs two to four arms under a Latin-square panel, and judges arms run elsewhere

finish-ab.js takes two to four arms, each with its own model, effort and extra
instruction files (an arm's `also` files are forbidden to the others; a file every arm
shares is forbidden to none). The panel guard is the Latin-square condition — every arm
read in every position equally often — which for two arms is the old half-per-order
rule, and the surviving panel is re-checked the same way. `executed` judges arms that
ran outside the workflow (a workflow agent has no Agent tool, so an arm that dispatches
runs headless); `base`, `brief` and `rubric` serve replays. Judges return optional,
order-independent measures, read the runner's check log instead of re-running the gate,
and carry a read-only clause; the arm-label guard names its real reason; a judge with
no contradicted-claims list is logged as undercounting. The shape test is the union of
both scenario sets, renumbered without collisions.

Trace rows closed: #69/body/finish-ab/N-arm (code), #69/body/finish-ab/latin-square,
#69/body/finish-ab/measures (schema), #69/body/finish-ab/executed,
#69/body/finish-ab/replay-args, #69/body/H1 (code), #69/c5859756889/1b (shape half),
#69/c5859756889/1c, #69/c5859756889/2e, #69/c5892402564/probe (pointer),
#69/c5901496433/1b, #69/c5901496433/5 (args comment); release/5 (finish-ab.js,
finish-ab-shape.mjs).

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

---

### Task V6.3: `run-arms-headless.py` and its fixture — headless arms in their own worktrees, a strict MCP allowlist, the continuation cap, the once-per-arm check task, and an optional `worktree_setup` (#69/body/finish-ab/{runner, runner-fixture}, #69/body/{H2, H3, H4, H5}, #69/c5859470658/{1, 2}, #69/c5859756889/{2a, 2b, 2c, 2f}, #69/c5859811353/{H1, H2, H3}, #69/c5881157875/6, #69/c5892402564/{finish-ab-drift, finish-ab-dryrun, finish-ab-allowlist, finish-ab-nonobject, finish-ab-failcarried, finish-ab-closedfiles, finish-ab-deny, finish-ab-cap}, #69/c5901496433/{1a, 2, 3}; D45)

**Closes (trace rows, in full):** `#69/body/finish-ab/runner`, `#69/body/finish-ab/runner-fixture`, `#69/body/H2` (the runner), `#69/body/H3` (`spend()`), `#69/body/H4`, `#69/body/H5`, `#69/c5859470658/1`, `#69/c5859470658/2` (the docstring), `#69/c5859756889/2a`, `#69/c5859756889/2b`, `#69/c5859756889/2c`, `#69/c5859756889/2f`, `#69/c5859811353/H1` (the comment; the finding itself does not hold — § Not holding), `#69/c5859811353/H2`, `#69/c5859811353/H3`, `#69/c5881157875/6`, `#69/c5892402564/finish-ab-drift`, `#69/c5892402564/finish-ab-dryrun`, `#69/c5892402564/finish-ab-allowlist`, `#69/c5892402564/finish-ab-nonobject`, `#69/c5892402564/finish-ab-failcarried`, `#69/c5892402564/finish-ab-closedfiles`, `#69/c5892402564/finish-ab-deny` (as the kit's list), `#69/c5892402564/finish-ab-cap`, `#69/c5901496433/1a`, `#69/c5901496433/2` (the docstring), `#69/c5901496433/3`; the runner's parts of V5's `#69/body/S6` and `#69/body/S8`; and the headless runner's exemplar line that V5 hands here for `#69/body/F10`, `#69/body/S4`, `#69/body/S6` and `#69/body/S8` (V5 § Handed to other clusters, item 2).

**Files:**
- Create: `.claude/workflows/finish-ab/run-arms-headless.py` (mode `100755`)
- Create: `.claude/workflows/tests/run-arms-headless-fixture.sh` (mode `100755`)
- Modify: `.claude/workflows/tests/finish-ab-shape.mjs` — the header, scenario 19 (the `ARM_SCHEMA` drift test), the scenario count
- Modify: `.claude/rules/cbk-conventions-reference.md` — § Verification: the runner fixture's line, at the kit sentinel
- Modify: `.claude/rules/orchestration-reference.md` — § Applied instances › Shipped exemplars: one sub-bullet under the `finish-ab/` line (V5's region, landed here on V5's behalf — V5 § Handed to other clusters, item 2: the runner does not exist until this commit)

**Interfaces:**
- **Consumes.** V6.2's `finish-ab.js` (`ARM_SCHEMA`, `args.executed`, `runner_check` in the judge prompt); V5's P2 record in `pr-review.md` § The floor (the docstring's "Why headless" points there); V5.6's `finish-ab/` exemplar line in `orchestration-reference.md` § Applied instances › Shipped exemplars, exactly `` - `.claude/workflows/finish-ab/` — executors and judges at the workhorse tier, effort named per call; the judge panel reads every arm in every position equally often, and the script refuses an unbalanced panel before dispatch. `` (Step 5 anchors the runner's sub-bullet under it; V5's panel wording already holds for two to four arms, so V6 changes no other V5 text); `cbk-conventions-reference.md` § .gitignore anchoring (exists at `74edf84`; V8 adds the worktrees entry to it and to the harness block — the docstring cites the section, not V8's new text); the kit sentinel line (V1).
- **Produces.** The runner's CLI `python3 .claude/workflows/finish-ab/run-arms-headless.py <config.json> [--dry-run | --resume-existing]`; the config keys `repo`, `issue`, `base`, `brief`, `worktree_root`, `out_dir`, `max_budget_usd`, `max_continuations`, `arms`, `worktree_setup`, `check_command`, `mcp_config`; the constants `UNATTENDED`, `WRITE_SERVERS = ('github', 'linear', 'notion')`, `MCP_ALLOWED = ('context7', 'time')`, `DENY`, `ARM_SCHEMA` (with `dispatched` required); the outputs `<out_dir>/<anon>.json|.err|.cmd|.cont<k>.json`, `<out_dir>/executed.json`, `<out_dir>.checks/<anon>.check.log`. V8 consumes the worktree root's name, `/.claude/worktrees/`, for the kit's `.gitignore` and the starter harness block (handed to V8). V10's README tree names the runner (handed to V10). The block line `bash .claude/workflows/tests/run-arms-headless-fixture.sh || { echo "run-arms-headless.py regressed on its fixture"; exit 1; }`.

- [ ] **Step 1: Write the failing fixture**

Create `.claude/workflows/tests/run-arms-headless-fixture.sh` with:

```bash
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
```

Then `chmod +x .claude/workflows/tests/run-arms-headless-fixture.sh`.

- [ ] **Step 2: Add scenario 19 to the shape test**

In `.claude/workflows/tests/finish-ab-shape.mjs`, replace (exact, unique):

```js
// judges' prompt, the judges' read-only clause and the rank arithmetic are asserted — the scenarios that shipped
// before context-builder-kit#69 and that issue's, unioned and renumbered so no two share a number.
// Run: node .claude/workflows/tests/finish-ab-shape.mjs
import { loadWorkflow } from "./load-workflow.mjs";
```

with:

```js
// judges' prompt, the judges' read-only clause, the rank arithmetic and the arm schema's agreement with
// run-arms-headless.py are asserted — the scenarios that shipped before context-builder-kit#69 and that issue's,
// unioned and renumbered so no two share a number. Run: node .claude/workflows/tests/finish-ab-shape.mjs
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { loadWorkflow } from "./load-workflow.mjs";
```

Replace (exact, unique):

```js
// 20. Headless arms whose runner ran the check task once: every judge is given each arm's log and exit and told to read
```

with:

```js
// 19. The arm schema has two hand-kept copies — finish-ab.js's ARM_SCHEMA (a workflow arm) and run-arms-headless.py's
//     (a headless arm) — because a workflow script gets no fs to share a module. They must describe the same result:
//     the same properties, and the same required list except `dispatched`, which the headless copy requires (a
//     headless arm can dispatch subagents) and the workflow copy does not (a workflow agent has no Agent tool).
{
  const { calls } = await run(base, { armResult: armOk, judgeResult: judgeOk });
  const js = calls.find((c) => c.opts.phase === "Execute").opts.schema;
  // fileURLToPath, never URL.pathname: .pathname percent-encodes a space in the checkout's path, and python3 then opens
  // a file that does not exist (a kit installed under "…/a b/…" would go red here).
  const pyPath = fileURLToPath(new URL("../finish-ab/run-arms-headless.py", import.meta.url));
  let py = null;
  try {
    py = JSON.parse(execFileSync("python3", ["-B", "-c", "import importlib.util, json, sys\nspec = importlib.util.spec_from_file_location('r', sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)\nprint(json.dumps(m.ARM_SCHEMA))", pyPath], { encoding: "utf8" }));
  } catch (e) { check(false, `run-arms-headless.py's ARM_SCHEMA could not be read (${e.message.split("\n")[0]})`); }
  if (py) {
    const keys = (o) => Object.keys(o.properties).sort().join(",");
    check(keys(js) === keys(py), `the two ARM_SCHEMA copies name the same properties (js: ${keys(js)} | py: ${keys(py)})`);
    const req = (o) => o.required.filter((k) => k !== "dispatched").sort().join(",");
    check(req(js) === req(py), `the two ARM_SCHEMA copies require the same fields apart from dispatched (js: ${req(js)} | py: ${req(py)})`);
    check(py.required.includes("dispatched") && !js.required.includes("dispatched"), "dispatched is required by the headless copy only, as both copies' comments say");
  }
}

// 20. Headless arms whose runner ran the check task once: every judge is given each arm's log and exit and told to read
```

Replace (exact, unique):

```js
console.log("finish-ab-shape: 23 scenarios ok");
```

with:

```js
console.log("finish-ab-shape: 24 scenarios ok");
```

- [ ] **Step 3: Run both against the tree without the runner**

Run:
```bash
bash -n .claude/workflows/tests/run-arms-headless-fixture.sh && bash .claude/workflows/tests/run-arms-headless-fixture.sh; echo "fixture exit=$?"
node .claude/workflows/tests/finish-ab-shape.mjs 2>&1 | grep -E '^(FAIL|finish-ab-shape)'; echo "shape exit=${PIPESTATUS[0]}"
```
Expected:
```
FAIL: .claude/workflows/finish-ab/run-arms-headless.py is missing (python3 would exit 2 on it, which case 1 would read as a refusal)
fixture exit=1
FAIL: run-arms-headless.py's ARM_SCHEMA could not be read (Command failed: python3 -B -c import importlib.util, json, sys)
finish-ab-shape: 1 failure(s)
shape exit=1
```
Record: `V6.3 run-arms-headless-fixture.sh — FAIL: …run-arms-headless.py is missing…` and `V6.3 finish-ab-shape.mjs scenario 19 — FAIL: run-arms-headless.py's ARM_SCHEMA could not be read (…)`.

- [ ] **Step 4: The change — the runner**

Create `.claude/workflows/finish-ab/run-arms-headless.py` with:

```python
#!/usr/bin/env python3
"""Run finish-ab's arms as headless `claude -p` sessions, each alone in its own git worktree, in parallel.

Why headless: a workflow agent has no Agent tool (.claude/rules/pr-review.md § The floor records the probe, its Claude
Code version and its date), so an arm run as a workflow agent can dispatch no subagents — neither a subagent-driven
arm's implementers nor the review floor's own fan-out. A top-level `claude -p` session can. The judge panel still runs
as the finish-ab workflow, handed this script's `executed.json` (finish-ab.js § args.executed).

Usage: python3 .claude/workflows/finish-ab/run-arms-headless.py <config.json> [--dry-run | --resume-existing]

--dry-run creates no worktree and runs nothing (it writes only out_dir's empty MCP config, the one an arm would get): it
prints, per arm, one JSON line {"anon", "cwd", "argv", "setup"} with the first invocation's argv and the worktree_setup
commands, so the deny list and the MCP config an arm would run under can be read before any money is spent.

An arm is complete when its session returned a structured result and PR_BODY.md exists in its worktree. An
unattended Opus 5.5 session ends turns with text while work is still owed: on this runner's first measured run
(2026-09-25, context-builder-kit#69) all three arms stopped before the end of /finish, one of them forced to return its
result while its own subagent was still running. So, as the Opus 5.5 guide prescribes
(platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5 § Unattended agentic runs,
read 2026-09-30):
- every new session gets the guide's standing paragraph on turn endings, appended to its system prompt from the
  first request (UNATTENDED below, verbatim);
- an incomplete arm is resumed in the same session with a message naming what is still open, at most
  max_continuations times per runner pass (default 3: "stop after two or three automatic continuations on the same
  task"); a later --resume-existing pass is the operator's deliberate choice and gets its own count, so only
  max_budget_usd bounds an arm's total across passes.
--resume-existing skips creating worktrees and continues each arm from the session its <anon>.json recorded.

config.json:
  repo, issue            — as finish-ab.js takes them
  base                   — the commit every arm starts from; each worktree is added there, detached
  brief                  — absolute path of the operator brief
  worktree_root          — directory the arm worktrees are created under (inside the repository, so the arms'
                           edits stay inside a working directory the session's permissions already cover). It must
                           be a gitignored path, such as .claude/worktrees/ — ignored by an anchored entry,
                           /.claude/worktrees/ (cbk-conventions-reference.md § .gitignore anchoring): an arm's
                           reviewers write .claude/agent-memory/ inside its worktree, and
                           detect-forked-agent-memory.sh blocks the launching session's hand-off on any such tree
                           outside the root that .gitignore does not exclude
  out_dir                — receives <anon>.json (the `claude -p --output-format json` payload), <anon>.err,
                           <anon>.cmd (the argv, for the record) and executed.json
  max_budget_usd         — per-arm spend cap across all its invocations (`--max-budget-usd`, given each
                           continuation as what is left), a runaway guard rather than a budget
  arms                   — [{anon, read, also?, verb?, model, effort}], as finish-ab.js's arms
  worktree_setup         — optional: shell commands run with `bash -c` in each new worktree, in order, right after it
                           is created and before any arm starts (a tool's trust step such as `mise trust`, or a
                           dependency install). One that exits non-zero stops the run before any arm is paid for,
                           naming the worktrees already created. --resume-existing does not re-run them
  check_command          — optional: the project's check task as one shell command (<the check task>). After every
                           arm has finished, the runner runs it once in each complete arm's worktree, one arm at a
                           time, into <out_dir>.checks/<anon>.check.log (beside out_dir, never in it: a judge is given
                           that path, and out_dir's records name each arm's mode), and adds {command, exit, log} to
                           the arm's result as runner_check, so the judges read one measured gate instead of each
                           re-running it: parallel gates on one machine measure the machine, not the arms
                           (context-builder-kit#69). It runs with no timeout: a hung check hangs the runner, which
                           is why executed.json is written before the checks and again after them
  mcp_config             — optional: a `--mcp-config` file naming the read-only MCP servers the arms may use (at most
                           context7 and time, MCP_ALLOWED). Absent, the arms get none: every arm runs with
                           `--strict-mcp-config`. One that names any other server — a write-capable one, or one this
                           runner does not know — is refused before any worktree is created. So an arm cannot read an
                           issue that lives behind an MCP server (a Linear planning backend), and has no docs server
                           unless this file names context7: the operator brief carries the issue's body and comments
                           verbatim (operator-brief.md § The issue, verbatim)

Every arm runs in `auto` permission mode, where a classifier reviews each action, and a `-p` run with no permission
host denies whatever would prompt ("In a `-p` run with no host, these requests are denied either way",
code.claude.com/docs/en/headless, read 2026-09-30). It runs with `--strict-mcp-config` and deny rules for the remote
writes DENY names ("Deny rules block in every mode", code.claude.com/docs/en/permission-modes, read 2026-09-30). The
launching session's environment variables whose names start with CLAUDE are stripped, and named on stdout, so each arm
starts as a fresh top-level session: a Claude Code 2.1.285 session sets CLAUDECODE, CLAUDE_CODE_SESSION_ID and
CLAUDE_EFFORT among others (observed 2026-09-30), and CLAUDE_CONFIG_DIR goes with them, so an arm reads the default
configuration directory. The settings files' own `env` blocks re-apply whatever they set. A fresh run refuses an
existing worktree or an out_dir holding an earlier run's files before creating anything; --resume-existing needs each
arm's worktree and its recorded <anon>.cmd. Stdlib only: needs python3 and git, and `claude` on PATH for a real run.
"""
import json
import os
import re
import shutil
import subprocess
import sys
import threading
import time
import uuid

# Verbatim from platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5
# § Unattended agentic runs (read 2026-09-30): "one example of such an addition, written for agents that run
# fully unattended … Add it at the end of your system prompt from the first request of the session".
UNATTENDED = (
    "A standing instruction from the user, the person you are working for. It is about how your turns end. A message "
    "with no tool call in it ends your turn, and the work stops there until you are asked to continue. The user has "
    "seen you end turns in four ways while work they asked for was still owed, and does not want any of them. One: a "
    "long summary of what was done that closes by announcing the next step and has no tool call, so the next thing "
    "never starts. Two: an offer to carry on with something unless the user would prefer otherwise, which stops to "
    "wait for an answer the user was not going to give. Three: a list of decisions for the user when, by your own "
    "account, none of them blocks the rest of the work. Four: deciding that this is a good place to report, because "
    "the turn has been long or a milestone is done. Status notes are welcome, and so are your recommendations on open "
    "decisions, but put them in the same message as your next tool call and carry on with whatever does not depend on "
    "the user's answer. If you notice yourself inviting the user to redirect you or offering to wait, delete it and "
    "do the next thing. The stops the user does want are the ones where nothing can move without them, or where the "
    "thing blocking you is deliberately protected from you. This does not override the need for confirmation on "
    "risky or destructive actions."
)

# Remote writes an arm must never make. `*` can stand anywhere in a rule (code.claude.com/docs/en/permissions
# § Wildcard patterns, read 2026-09-30), but a trailing wildcard also matches the bare command only when it is the rule's
# sole wildcard ("That holds only when the trailing `*` is the rule's only wildcard", the same page): `git * push *`
# needs text after `push`, so the bare `git -C . push` and `git -c k=v push` are caught by `git * push`, listed beside
# it — keep both. `git push *` is a sole trailing wildcard, so it already matches the bare `git push` ("`Bash(git log *)`
# matches `git log`", the same page) and needs no rule of its own. An arm reads GitHub through `gh`; reads stay open:
# `gh issue view`, `gh pr list`, `gh label list`, `gh release view`. `gh api` is denied whole, because its method is a
# flag (`-X`, or implied by `-f`), so no glob can let its reads through and stop its writes — an arm reads with
# `gh issue view` and `gh pr view` instead.
#
# The deny list is a backstop, not the boundary: a non-bare `claude -p` loads every MCP server the user's own settings
# add, and a machine can carry write-capable ones this list cannot enumerate. So every arm runs with
# `--strict-mcp-config`: only the servers the config's `mcp_config` file names load, and with none named, none do (fail
# closed). WRITE_SERVERS names the write-capable servers the kit's own axes wire — the git host (`github`), the
# planning backend (`linear`) and the knowledge backend (`notion`) — each denied whole, under its configured name and
# its plugin form (`mcp__plugin_<plugin>_<server>__*`, the names a Claude Code 2.1.285 session showed on 2026-09-30).
# A target adds every other write-capable server its own .mcp.json wires. Connectors Claude Code fetches from claude.ai
# are denied whole too ("Tools from connectors Claude Code fetches itself appear as `mcp__claude_ai_<server>__<tool>`";
# a deny rule's tool name may be a glob — code.claude.com/docs/en/permissions § MCP and § Tool name wildcards, read
# 2026-09-30): an arm reads its issue through the brief and edits files with its own tools.
WRITE_SERVERS = ('github', 'linear', 'notion')
# The only servers an arm's mcp_config may name. An allowlist, not WRITE_SERVERS turned around: a server this file does
# not know — one added to .mcp.json later, or a machine's own — is refused rather than let through (fail closed).
MCP_ALLOWED = ('context7', 'time')
DENY = [
    'Bash(git push *)', 'Bash(git * push *)', 'Bash(git * push)',
    *[f'mcp__{srv}__*' for srv in WRITE_SERVERS],
    'mcp__plugin_github_github__*', 'mcp__plugin_linear_linear__*', 'mcp__plugin_Notion_notion__*', 'mcp__claude_ai_*',
    'Bash(gh api *)',
    *[f'Bash(gh pr {c} *)' for c in ('create', 'edit', 'merge', 'comment', 'ready', 'close', 'reopen', 'review',
                                      'update-branch', 'lock', 'unlock')],
    *[f'Bash(gh issue {c} *)' for c in ('create', 'edit', 'comment', 'close', 'reopen', 'delete', 'transfer',
                                         'develop', 'pin', 'unpin', 'lock', 'unlock')],
    *[f'Bash(gh label {c} *)' for c in ('create', 'edit', 'delete', 'clone')],
    *[f'Bash(gh release {c} *)' for c in ('create', 'edit', 'delete', 'upload', 'delete-asset')],
    *[f'Bash(gh repo {c} *)' for c in ('create', 'delete', 'edit', 'fork', 'rename', 'archive', 'unarchive', 'sync')],
    *[f'Bash(gh workflow {c} *)' for c in ('run', 'enable', 'disable')],
    *[f'Bash(gh run {c} *)' for c in ('rerun', 'cancel', 'delete')],
    'Bash(gh secret *)', 'Bash(gh variable *)', 'Bash(gh gist *)',
]

# The arm's structured return: finish-ab.js's ARM_SCHEMA, with its descriptions. One difference, on purpose:
# `dispatched` is required here, because a headless arm can dispatch subagents, and optional there, where a workflow
# agent cannot (it has no Agent tool).
ARM_SCHEMA = {
    'type': 'object',
    'required': ['branch', 'worktree', 'commits', 'plan_path', 'pr_body_path', 'check_command', 'check_exit',
                 'tests_written', 'skills_invoked', 'operational', 'gate_calls', 'dispatched', 'handoff', 'notes'],
    'properties': {
        'branch': {'type': 'string'},
        'worktree': {'type': 'string', 'description': 'absolute path of the worktree you worked in'},
        'commits': {'type': 'array', 'items': {'type': 'object', 'required': ['sha', 'subject'],
                                                'properties': {'sha': {'type': 'string'}, 'subject': {'type': 'string'}}},
                    'description': 'oldest first'},
        'plan_path': {'type': 'string'},
        'pr_body_path': {'type': 'string'},
        'check_command': {'type': 'string'},
        'check_exit': {'type': 'integer'},
        'tests_written': {'type': 'array', 'items': {'type': 'string'}},
        'skills_invoked': {'type': 'array', 'items': {'type': 'string'},
                           'description': 'exact skill names actually invoked via the Skill tool'},
        'operational': {'type': 'array', 'items': {'type': 'string'},
                        'description': 'criteria left open because they need the operator or a device'},
        'gate_calls': {'type': 'array', 'items': {'type': 'string'},
                       'description': 'every decision you made where the flow would have waited for the operator'},
        'dispatched': {'type': 'array', 'items': {'type': 'object', 'required': ['role', 'model', 'effort'],
                                                   'properties': {'role': {'type': 'string'}, 'model': {'type': 'string'},
                                                                  'effort': {'type': 'string'}}},
                       'description': 'every subagent you dispatched yourself, outside the review skills: its role, model and effort'},
        'handoff': {'type': 'string'},
        'notes': {'type': 'string'},
    },
}


def arm_prompt(cfg, cell, arms):
    """The same instruction finish-ab.js's armPrompt gives a workflow arm, for a headless session."""
    files = [cell['read'], *cell.get('also', [])]
    others = sorted({f for c in arms if c['anon'] != cell['anon'] for f in [c['read'], *c.get('also', [])]} - set(files))
    forbid = (f"Do not open {', '.join(others)} or anything under .claude/skills/" if others
              else 'Do not open anything under .claude/skills/')
    read = (f"Then read {cell['read']} in full, then {', then '.join(cell['also'])} in full,"
            if cell.get('also') else f"Then read {cell['read']} in your worktree in full")
    return (f"You are executing issue #{cfg['issue']} in the repository {cfg['repo']}, from inside a git worktree of "
            f"your own — your current working directory. Read the operator brief at {cfg['brief']} first; it states "
            f"what non-interactive means for this run, the standing decisions, the hard limits and what to return. "
            f"Your worktree is checked out, detached, at commit {cfg['base']}: create your branch there before your "
            f"first commit — this run replays the issue from that commit, and nothing after it exists for you.\n\n"
            f"{read} and {cell.get('verb', 'satisfy it')} for issue {cfg['issue']}, with the brief's non-interactive "
            f"rules substituting only where the instructions would wait for the operator (the plan gate becomes "
            f"PLAN.md, the push and PR become PR_BODY.md, operational criteria stay open). Read every input the "
            f"instructions name, in full, before planning. {forbid} — the files you were given, the issue and the "
            f"inputs it names are your whole instruction. Invoke the skills it requires as skills. Return the "
            f"structured result when the hand-off exists.")


def common_flags(cfg, cell, budget=None):
    return ['--model', cell['model'], '--effort', cell['effort'], '--permission-mode', 'auto',
            '--output-format', 'json', '--json-schema', json.dumps(ARM_SCHEMA),
            '--strict-mcp-config', '--mcp-config', cfg['mcp_config'],
            '--max-budget-usd', f"{cfg['max_budget_usd'] if budget is None else budget:.2f}",
            # `--disallowedTools` is variadic (`<tools...>`, "Comma or space-separated list of tool names to deny" in
            # `claude --help` on 2.1.285, read 2026-09-30), so the spread applies every rule: a live probe with a
            # positive control denied both of two space-separated rules, and the next flag ends the list
            # (context-builder-kit#69, 2026-09-28). Do not comma-join it on a reviewer's word; re-probe. `--mcp-config`
            # is variadic too (`<configs...>`) and ends only because `--max-budget-usd` follows it: keep that order.
            '--disallowedTools', *DENY]


def open_items(wt, payload):
    """What the arm still owes, by the completion condition: a structured result and PR_BODY.md."""
    items = []
    if not os.path.exists(os.path.join(wt, 'PR_BODY.md')):
        items.append('PR_BODY.md does not exist in your worktree yet')
    if not isinstance((payload or {}).get('structured_output'), dict):
        items.append('your last turn returned no structured result')
    return items


def continuation(items):
    return ('Your run of the instructions is not complete: ' + '; '.join(items) + '. Continue from where you stopped '
            'and finish every step your instructions still require — the review floor as they require it, the triage '
            'and its commits, PR_BODY.md with its "## Review gate" and "## Triage" blocks, and the hand-off — then '
            'return the structured result, with the commit list as it stands at that moment. Before you end a turn, '
            'wait for every subagent you started to return; do not end a turn while one is still running. If a step '
            'is blocked, say what is blocking it.')


def run_arm(cfg, cell, arms, env, resume, record):
    anon = cell['anon']
    wt = os.path.join(cfg['worktree_root'], f'eval-{anon}')
    out = cfg['out_dir']
    runs, t0 = [], time.time()  # one {payload, rc, err} per invocation; rc is None for one an earlier pass made
    first = 1  # the next continuation's number
    cmd_path = os.path.join(out, f'{anon}.cmd')
    if resume:
        # Continue from the latest payload an earlier pass left, and number new continuations after it, so an
        # earlier pass's cont<k> files are never overwritten and a stale first-pass result is never taken as final.
        cont = re.compile(rf'{re.escape(anon)}\.cont(\d+)\.json')
        done = sorted(int(m.group(1)) for f in os.listdir(out) if (m := cont.fullmatch(f)))
        # A killed invocation leaves its payload empty or truncated (invoke() opens the file before the child runs),
        # so every recorded payload is loaded oldest first and an unparsable one stays as None: the session-id and
        # cost lookups below skip None, so the arm resumes from the newest payload that parsed.
        for name in [f'{anon}.json', *(f'{anon}.cont{k}.json' for k in done)]:
            runs.append({'payload': load_payload(os.path.join(out, name)), 'rc': None,
                         'err': os.path.join(out, name[:-len('.json')] + '.err')})
        first = (done[-1] + 1) if done else 1
        recorded_sid = (load_payload(cmd_path) or {}).get('session_id')
    else:
        # The session id is chosen here and recorded before the first invocation, so a first invocation killed before
        # it wrote any payload can still be resumed by --resume-existing.
        recorded_sid = str(uuid.uuid4())
        argv_ = ['claude', '-p', arm_prompt(cfg, cell, arms), '--session-id', recorded_sid, *common_flags(cfg, cell),
                 '--append-system-prompt', UNATTENDED]
        with open(cmd_path, 'w') as f:
            json.dump({'cwd': wt, 'session_id': recorded_sid, 'argv': argv_}, f, indent=1)
        runs.append(invoke(argv_, wt, env, os.path.join(out, f'{anon}.json'), os.path.join(out, f'{anon}.err')))
    stop = None
    for k in range(first, first + int(cfg.get('max_continuations', 3))):
        last = runs[-1]
        # An invocation this pass made that failed — no parsable payload, a non-zero exit, or an error subtype such as
        # error_max_budget_usd or an auth failure — is reported and not continued: a continuation would fail the same
        # way, and after a killed one the spend is unknown. An operator who fixes the cause resumes with
        # --resume-existing.
        if last['rc'] is not None and failure_of(last):
            stop = f"its last invocation failed: {failure_of(last)}"
            break
        items = open_items(wt, last['payload'])
        if not items:
            break
        # The session id from the latest payload that parsed, else the one recorded before the first invocation.
        sid = next((r['payload'].get('session_id') for r in reversed(runs) if r['payload'] and r['payload'].get('session_id')),
                   None) or recorded_sid
        if not sid:
            stop = 'no session id is recoverable (no payload parsed, and <anon>.cmd records none)'
            break
        # --max-budget-usd does not count spend restored from earlier runs: restored totals "don't count toward it"
        # (code.claude.com/docs/en/cli-reference, read 2026-09-30), so each continuation gets only what the arm's cap
        # has left, never the whole cap again.
        spent, floor = spend(runs)
        left = float(cfg['max_budget_usd']) - spent
        if left <= 0:
            stop = f"it has spent its cap (${spent:.2f}{' or more' if floor else ''})"
            break
        if floor:
            print(f'{anon}: an earlier invocation left no payload, so ${spent:.2f} spent is a floor and the '
                  f'${left:.2f} left may overstate the cap', flush=True)
        # With --system-prompt-snapshot on ("on (the default)", `claude --help` on 2.1.285, read 2026-09-30), the first
        # request's prompt — this paragraph included — is recorded and reused on resume until the conversation is
        # compacted; passing it again is a no-op until then and restores it after a compaction, or where recording is
        # off. So it is passed on every continuation.
        argv_ = ['claude', '-p', continuation(items), '--resume', sid, '--append-system-prompt', UNATTENDED,
                 *common_flags(cfg, cell, budget=left)]
        print(f'{anon}: continuation {k} — {"; ".join(items)}', flush=True)
        runs.append(invoke(argv_, wt, env, os.path.join(out, f'{anon}.cont{k}.json'), os.path.join(out, f'{anon}.cont{k}.err')))
    else:
        if open_items(wt, runs[-1]['payload']):
            stop = f"this pass reached max_continuations ({int(cfg.get('max_continuations', 3))}); --resume-existing continues it"
    # A resumed invocation reports the conversation's whole total, earlier runs included ("the run reports the
    # conversation's whole total", code.claude.com/docs/en/headless, read 2026-09-30), so the arm's cost is the latest
    # parsed payload's total, never a sum — and a floor when a later invocation left no payload.
    cost, floor = spend(runs)
    final = runs[-1]['payload'] or {}
    record[anon] = dict(wt=wt, final=final, cost=round(cost, 2), floor=floor, invocations=len(runs),
                        items=open_items(wt, final), stop=stop, minutes=round((time.time() - t0) / 60, 1))


def spend(runs):
    """(the conversation's spend so far, whether that figure is only a floor) — the latest parsed payload's total;
    a floor when an invocation after it, or every invocation, left no payload."""
    parsed = [i for i, r in enumerate(runs) if r['payload']]
    if not parsed:
        return 0.0, bool(runs)
    last = parsed[-1]
    return float(runs[last]['payload'].get('total_cost_usd') or 0), last < len(runs) - 1


def failure_of(run):
    """Why an invocation failed, in one line naming its stderr file — or None if it did not."""
    p, rc = run['payload'], run['rc']
    if p is None:
        return f"no parsable payload (exit {rc}; see {run['err']})"
    if p.get('is_error') or rc not in (None, 0):
        text = str(p.get('result') or '').strip().splitlines()
        return f"{p.get('subtype') or 'error'} (exit {rc}): {text[0][:160] if text else 'no result text'}; see {run['err']}"
    return None


def run_checks(cfg, executed, env):
    """The check task, once per complete arm, one arm at a time, after every arm has finished: the judges read this log
    rather than each re-running the gate, which on one machine measures the machine (context-builder-kit#69). No
    timeout: a hung check hangs the runner (main writes executed.json before the checks for that reason)."""
    cmd = cfg.get('check_command')
    if not cmd:
        return
    # Beside out_dir, never inside it: the log path goes into every judge's prompt, and out_dir holds each arm's
    # <anon>.cmd (its argv names the arm's instruction files and effort), payloads and executed.json — a judge sent
    # there could read which arm is which.
    log_dir = os.path.abspath(cfg['out_dir']).rstrip(os.sep) + '.checks'
    os.makedirs(log_dir, exist_ok=True)
    for e in executed:
        anon, result = e['anon'], e['result']
        log = os.path.join(log_dir, f'{anon}.check.log')
        with open(log, 'w') as f:
            try:
                rc = subprocess.run(['bash', '-c', cmd], cwd=result['worktree'], env=env, stdout=f,
                                    stderr=subprocess.STDOUT, stdin=subprocess.DEVNULL).returncode
            except OSError as ex:
                f.write(f'[runner] the check task could not start: {ex}\n')
                rc = -1
        result['runner_check'] = {'command': cmd, 'exit': rc, 'log': log}
        result['notes'] = (result.get('notes') or '') + (
            f"\n[runner] check task run once by the runner after every arm finished: `{cmd}` exit {rc}; log {log}")
        print(f'{anon}: check task exit {rc} ({log})', flush=True)


def load_payload(path):
    """A recorded `claude -p --output-format json` payload, or None when it is missing, empty or truncated."""
    try:
        with open(path) as f:
            return json.load(f)
    except (OSError, json.JSONDecodeError):
        return None


def invoke(argv_, wt, env, out_path, err_path):
    with open(out_path, 'w') as out, open(err_path, 'w') as err:
        rc = subprocess.run(argv_, cwd=wt, env=env, stdout=out, stderr=err, stdin=subprocess.DEVNULL).returncode
    return {'payload': load_payload(out_path), 'rc': rc, 'err': err_path}


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    # A mistyped flag must not fall through to a real, paid run.
    unknown = [a for a in argv[2:] if a not in ('--dry-run', '--resume-existing')]
    if unknown:
        print(f"unknown argument(s): {' '.join(unknown)} (expected --dry-run or --resume-existing)")
        return 2
    with open(argv[1]) as f:
        cfg = json.load(f)
    dry, resume = '--dry-run' in argv, '--resume-existing' in argv
    for k in ('repo', 'issue', 'base', 'brief', 'worktree_root', 'out_dir', 'max_budget_usd', 'arms'):
        if cfg.get(k) in (None, ''):
            print(f'config: {k} is required')
            return 2
    arms = cfg['arms']
    if not isinstance(arms, list) or not 2 <= len(arms) <= 4 or not all(isinstance(a, dict) for a in arms):
        print('config: arms is a list of two to four objects')
        return 2
    # Every arm is checked before any worktree exists: a missing key inside a runner thread would otherwise surface
    # only as "the thread recorded nothing", after the worktrees that block a re-run were already created.
    for cell in arms:
        bad = [k for k in ('anon', 'read', 'model', 'effort') if not isinstance(cell.get(k), str) or not cell.get(k)]
        if cell.get('also') is not None and not (isinstance(cell['also'], list) and all(isinstance(f, str) and f for f in cell['also'])):
            bad.append('also (a list of file paths)')
        if bad:
            print(f"config: arm {cell.get('anon')!r} lacks {', '.join(bad)}")
            return 2
    if len({cell['anon'] for cell in arms}) != len(arms):  # every anon is a non-empty string by now
        print('config: the arms need distinct anon ids')
        return 2
    if cfg.get('check_command') is not None and not (isinstance(cfg['check_command'], str) and cfg['check_command'].strip()):
        print('config: check_command is a shell command string, run once in each complete arm\'s worktree')
        return 2
    setup = cfg.get('worktree_setup')
    if setup is not None and not (isinstance(setup, list) and all(isinstance(c, str) and c.strip() for c in setup)):
        print('config: worktree_setup is a list of shell commands, run in each new worktree before any arm starts')
        return 2
    if not dry and shutil.which('claude') is None:
        print('claude is not on PATH')
        return 2
    cfg['worktree_root'] = os.path.abspath(cfg['worktree_root'])  # the judges read result.worktree from any cwd
    os.makedirs(cfg['out_dir'], exist_ok=True)
    stripped = sorted(k for k in os.environ if k.startswith('CLAUDE'))
    env = {k: v for k, v in os.environ.items() if k not in stripped}
    print(f"stripped from the arms' environment: {', '.join(stripped) or 'nothing'}", flush=True)
    if cfg.get('mcp_config'):
        cfg['mcp_config'] = os.path.abspath(cfg['mcp_config'])
        try:
            with open(cfg['mcp_config']) as f:
                named = sorted((json.load(f).get('mcpServers') or {}).keys())
        except (OSError, json.JSONDecodeError, AttributeError) as e:
            print(f"config: mcp_config {cfg['mcp_config']} could not be read as an MCP config ({e})")
            return 2
        others = [srv for srv in named if srv not in MCP_ALLOWED]
        if others:
            print(f"config: mcp_config names servers outside {' and '.join(MCP_ALLOWED)} ({', '.join(others)}), the only "
                  f"ones an arm may load — refusing before any worktree is created")
            return 2
    else:
        cfg['mcp_config'] = os.path.join(os.path.abspath(cfg['out_dir']), 'no-mcp-servers.json')
        with open(cfg['mcp_config'], 'w') as f:
            json.dump({'mcpServers': {}}, f)
    wts = {cell['anon']: os.path.join(cfg['worktree_root'], f"eval-{cell['anon']}") for cell in arms}
    if resume:
        for cell in arms:
            if not (os.path.isdir(wts[cell['anon']]) and os.path.exists(os.path.join(cfg['out_dir'], f"{cell['anon']}.cmd"))):
                print(f"--resume-existing: {cell['anon']} has no worktree or no recorded first invocation to continue")
                return 1
    else:
        # Refuse every conflict before creating anything, so a refusal never leaves half the worktrees behind; and
        # refuse an out_dir an earlier run wrote into, or a later --resume-existing would pick up its stale payloads.
        taken = [wt for wt in wts.values() if os.path.exists(wt)]
        stale = sorted(f for f in os.listdir(cfg['out_dir']) for cell in arms if f.startswith(f"{cell['anon']}."))
        if taken or stale:
            for wt in taken:
                print(f'refusing to reuse {wt}: remove it first (git worktree remove {wt})')
            if stale:
                print(f"refusing to write into {cfg['out_dir']}: it holds an earlier run's files ({', '.join(stale)})")
            return 1
        created = []
        for cell in arms:
            wt = wts[cell['anon']]
            if dry:
                argv_ = ['claude', '-p', arm_prompt(cfg, cell, arms), '--session-id', '<chosen at run time>',
                         *common_flags(cfg, cell), '--append-system-prompt', UNATTENDED]
                print(json.dumps({'anon': cell['anon'], 'cwd': wt, 'argv': argv_, 'setup': setup or []}), flush=True)
                continue
            subprocess.run(['git', 'worktree', 'add', '--detach', wt, cfg['base']], check=True)
            created.append(wt)
            # A project's own per-worktree step (a tool's trust prompt, a dependency install), from the config rather
            # than hard-coded: a target without the tool would otherwise fail here after the first worktree exists.
            for cmd in setup or []:
                rc = subprocess.run(['bash', '-c', cmd], cwd=wt, env=env, stdin=subprocess.DEVNULL).returncode
                if rc != 0:
                    print(f"worktree_setup: `{cmd}` exited {rc} in {wt}; no arm was started. Fix it, then remove the "
                          f"worktrees this run created before running again (git worktree remove <path>): {' '.join(created)}")
                    return 1
    if dry:
        return 0
    record, threads = {}, []
    for cell in arms:
        th = threading.Thread(target=run_arm, args=(cfg, cell, arms, env, resume, record))
        th.start()
        threads.append(th)
        print(f"{cell['anon']}: {'resumed' if resume else 'started'} (model {cell['model']}, effort {cell['effort']})", flush=True)
    for th in threads:
        th.join()
    executed = []
    for cell in arms:
        r = record.get(cell['anon'])
        if r is None:
            print(f"{cell['anon']}: the runner thread recorded nothing")
            continue
        result = r['final'].get('structured_output')
        cost = f"${r['cost']}{' (a floor)' if r['floor'] else ''}"
        if r['items'] or not isinstance(result, dict):
            why = '; '.join(filter(None, [r['stop'], *r['items']]))
            print(f"{cell['anon']}: incomplete after {r['invocations']} invocation(s), {cost}: {why}; "
                  f"the arm is dropped, never guessed at")
            continue
        # The runner knows where the arm ran; the judges locate it by this field, so the arm's own report never wins.
        if result.get('worktree') and os.path.abspath(os.path.join(r['wt'], result['worktree'])) != r['wt']:
            result['notes'] = (result.get('notes') or '') + f"\n[runner] the arm reported worktree {result['worktree']!r}"
        result['worktree'] = r['wt']
        result['notes'] = (result.get('notes') or '') + (
            f"\n[runner] {r['invocations']} invocation(s) ({r['invocations'] - 1} continuation(s)), "
            f"{r['minutes']} min this runner pass, total_cost_usd {cost} for the whole conversation, "
            f"session {r['final'].get('session_id')}")
        # Complete by its artifacts, yet its last invocation reported a failure (an error subtype or a non-zero exit
        # after the result was written): the arm is judged on what it produced, and the failure travels with it.
        failed = f" — {r['stop']}" if r['stop'] else ''
        if failed:
            result['notes'] += f"\n[runner] {r['stop']}"
        executed.append({'anon': cell['anon'], 'result': result})
        print(f"{cell['anon']}: complete after {r['invocations']} invocation(s), {cost}, "
              f"{len(result.get('commits', []))} commits, check exit {result.get('check_exit')}{failed}", flush=True)
    # Written before the checks and again after them: the checks run one at a time with no timeout, so a hung check or
    # an interrupt must not lose the record of arms already paid for (a later --resume-existing rewrites it anyway).
    with open(os.path.join(cfg['out_dir'], 'executed.json'), 'w') as f:
        json.dump(executed, f, indent=1)
    if cfg.get('check_command'):
        run_checks(cfg, executed, env)
        with open(os.path.join(cfg['out_dir'], 'executed.json'), 'w') as f:
            json.dump(executed, f, indent=1)
    missing = [c['anon'] for c in arms if c['anon'] not in {e['anon'] for e in executed}]
    if missing:
        print(f"dropped arms (incomplete or no well-formed result): {', '.join(missing)}")
    return 0 if not missing else 1


if __name__ == '__main__':
    sys.exit(main(sys.argv))
```

Then `chmod +x .claude/workflows/finish-ab/run-arms-headless.py`.

- [ ] **Step 5: The block runs the fixture; the reference half names the runner**

Preconditions, run first:
```bash
grep -cxF -- '- `.claude/workflows/finish-ab/` — executors and judges at the workhorse tier, effort named per call; the judge panel reads every arm in every position equally often, and the script refuses an unbalanced panel before dispatch.' .claude/rules/orchestration-reference.md
grep -cF 'run-arms-headless' .claude/rules/orchestration-reference.md
```
Expected: `1`, `0`. Any other count: stop and reconcile with V5.6's landed text (master plan § Global Constraints, anchor rule).

(a) In `.claude/rules/orchestration-reference.md` § Applied instances › Shipped exemplars, replace (exact, unique, the whole line):

```
- `.claude/workflows/finish-ab/` — executors and judges at the workhorse tier, effort named per call; the judge panel reads every arm in every position equally often, and the script refuses an unbalanced panel before dispatch.
```

with that line followed by the sub-bullet V5 wrote for it (V5 § Handed to other clusters, item 2), verbatim, indented two spaces:

```
- `.claude/workflows/finish-ab/` — executors and judges at the workhorse tier, effort named per call; the judge panel reads every arm in every position equally often, and the script refuses an unbalanced panel before dispatch.
  - **Headless arms.** `run-arms-headless.py` runs arms that must dispatch subagents, which a workflow agent cannot (§ Generation notes — the sources). Each is a `claude -p` session in its own worktree at the base commit, with `--strict-mcp-config` and an allowlist of read-only MCP servers, deny rules for `git push`, `git * push` and `gh` writes as the backstop, continuations bounded per runner pass, and each continuation given only the budget the arm has left; with `check_command` set, the runner runs the check task once per arm, serially, and the judges read that log. `tests/run-arms-headless-fixture.sh` covers it against a fake `claude`.
```

The sub-bullet cites no docs page and carries no square-bracket slot, so V5.14's primary-sources check and V5.13's slot check are unaffected, and it adds no always-loaded byte (the reference half is path-scoped).

(b) In `.claude/rules/cbk-conventions-reference.md` § Verification, replace (exact, unique, the whole line):

```bash
echo "verification: kit sub-block complete"
```

with:

```bash
# The headless finish-ab runner (run-arms-headless.py): refusals before anything is created, the recorded session,
# cost as the latest total, the failure, resume and cap paths, the dry-run argv (deny list, strict MCP config naming no
# server), the MCP allowlist, the per-worktree setup and the once-per-arm check task, against a fake `claude` in a
# throwaway repository; a ResourceWarning in the runner's output fails it. Needs git and python3; spends nothing.
bash .claude/workflows/tests/run-arms-headless-fixture.sh || { echo "run-arms-headless.py regressed on its fixture"; exit 1; }
echo "verification: kit sub-block complete"
```

- [ ] **Step 6: Re-verify every quotation the runner carries, raw, today**

Run (from the repository root; needs `curl` and the installed `claude`):
```bash
bash -s <<'QUOTES'
#!/usr/bin/env bash
# V6.3 quotations: fetch raw (the .md form for code.claude.com), normalise typographic apostrophes, match with grep -F;
# the CLI's own help is read from the installed claude, whitespace-normalised because it wraps.
set -uo pipefail
q=$(mktemp -d); trap 'rm -rf "$q"' EXIT
fetch() { curl -sL "$1" | sed "s/’/'/g" > "$q/$2"; [ -s "$q/$2" ] || { echo "FETCH FAILED: $1"; exit 1; }; }
fetch https://code.claude.com/docs/en/headless.md headless
fetch https://code.claude.com/docs/en/permission-modes.md modes
fetch https://code.claude.com/docs/en/permissions.md permissions
fetch https://code.claude.com/docs/en/cli-reference.md cli
fetch https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5.md opus55
claude --version </dev/null > "$q/version"; claude --help </dev/null | tr -s ' \n' '  ' > "$q/help"
ok=0
has() { grep -qF -- "$2" "$q/$1" && echo "ok   $1: $2" || { echo "MISS $1: $2"; ok=1; }; }
has headless 'In a `-p` run with no host, these requests are denied either way'
has headless "the run reports the conversation's whole total"
has modes 'Deny rules block in every mode'
has permissions "That holds only when the trailing \`*\` is the rule's only wildcard"
has permissions '`Bash(git log *)` matches `git log`'
has permissions 'Tools from connectors Claude Code fetches itself appear as `mcp__claude_ai_<server>__<tool>`'
has permissions '### Wildcard patterns'
has permissions '### Tool name wildcards'
has cli "don't count toward it"
has opus55 '## Unattended agentic runs'
has opus55 'stop after two or three automatic continuations on the same task'
has opus55 'one example of such an addition, written for agents that run fully unattended'
has opus55 'Add it at the end of your system prompt from the first request of the session'
has help 'Comma or space-separated list of tool names to deny'
has help 'on (the default)'
has help '--mcp-config <configs...>'
has help '--disallowedTools, --disallowed-tools <tools...>'
has version '2.1.285'
# The UNATTENDED paragraph, verbatim: every string literal of the constant, joined, is on the page.
python3 -B - "$q/opus55" .claude/workflows/finish-ab/run-arms-headless.py <<'PY' || ok=1
import re, sys
with open(sys.argv[1]) as f:
    page = f.read()
with open(sys.argv[2]) as f:
    src = f.read()
para = ''.join(re.findall(r'"((?:[^"\\]|\\.)*)"', re.search(r'UNATTENDED = \((.*?)\n\)', src, re.S).group(1)))
print(('ok   opus55: UNATTENDED verbatim (%d chars)' if para in page else 'MISS opus55: UNATTENDED (%d chars)') % len(para))
sys.exit(0 if para in page else 1)
PY
exit $ok
QUOTES
echo "quotes exit=$?"
```
Expected: nineteen `ok` lines — the last `ok   opus55: UNATTENDED verbatim (1359 chars)` — and `quotes exit=0`. The `version` line expects `2.1.285`, the CLI the help quotations were read from; on a newer CLI, the help lines must still match, and the comments' "2.1.285, read 2026-09-30" stamps are updated to the version and date actually read. A `MISS` elsewhere: stop and correct the quotation and its date together.

- [ ] **Step 7: Run the fixture, a mutant, the shape test and the block**

Run:
```bash
bash .claude/workflows/tests/run-arms-headless-fixture.sh
r=.claude/workflows/finish-ab/run-arms-headless.py; keep=$(mktemp); cp "$r" "$keep"
sed -i 's/^            for cmd in setup or \[\]:$/            for cmd in []:/' "$r"
rc=0; out=$(bash .claude/workflows/tests/run-arms-headless-fixture.sh 2>&1) || rc=$?; echo "mutant (setup skipped): rc=$rc; $(grep -m1 '^FAIL' <<<"$out")"; cp "$keep" "$r"; rm -f "$keep"
node .claude/workflows/tests/finish-ab-shape.mjs
sp=$(mktemp -d); mkdir -p "$sp/a b"; cp -r .claude "$sp/a b/"; node "$sp/a b/.claude/workflows/tests/finish-ab-shape.mjs"; rm -rf "$sp"  # Review Focus 2: a checkout path with a space
find .claude -name __pycache__
grep -nE '(^|[[:space:](,;])#[0-9]{1,3}\b' .claude/workflows/finish-ab/run-arms-headless.py .claude/workflows/tests/run-arms-headless-fixture.sh; echo "bare=$?"
grep -cF '  - **Headless arms.** `run-arms-headless.py` runs arms that must dispatch subagents' .claude/rules/orchestration-reference.md
bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E '^(finish-ab-shape|always-loaded total|run-arms-headless-fixture|verification: )'; echo "exit=${PIPESTATUS[0]}"
```
Expected:
```
run-arms-headless-fixture: ok
mutant (setup skipped): rc=1; FAIL: worktree_setup must run once in each new worktree, in order, before any arm starts (rc=0)
finish-ab-shape: 24 scenarios ok
finish-ab-shape: 24 scenarios ok
bare=1
1
finish-ab-shape: 24 scenarios ok
always-loaded total: N bytes
run-arms-headless-fixture: ok
verification: kit sub-block complete
verification: done
exit=0
```
with nothing printed by `find` and `N` unchanged. The fixture takes about six seconds (its `slowdone` step sleeps 1.5 s by design). No hook is touched.

- [ ] **Step 8: Commit**

```bash
git add .claude/workflows/finish-ab/run-arms-headless.py .claude/workflows/tests/run-arms-headless-fixture.sh .claude/workflows/tests/finish-ab-shape.mjs .claude/rules/cbk-conventions-reference.md .claude/rules/orchestration-reference.md
git commit -F- <<'EOF'
feat(workflows): V6 — run-arms-headless.py runs finish-ab arms as headless sessions, with its fixture

A workflow agent has no Agent tool, so an arm that dispatches subagents — a
subagent-driven arm, or a review floor with its fan-out — runs as a headless
`claude -p` session, each in its own detached worktree, in auto mode, under
--strict-mcp-config with an allowlist of context7 and time and a deny list for remote
writes (the kit's git host, planning and knowledge servers in both spellings, and
claude.ai connectors). Every session carries the Opus 5.5 guide's turn-ending paragraph
from its first request and on every continuation; an incomplete arm is resumed at most
max_continuations times per pass, each continuation given only what the cap has left,
and cost is the latest total, never a sum. The check task runs once per complete arm
after every arm finished, its log beside out_dir; an optional worktree_setup list
replaces a hard-coded trust step. The fixture drives it hermetically against a fake
claude and fails on a ResourceWarning; the shape test diffs the two ARM_SCHEMA copies.
The orchestration reference's shipped exemplars name the runner under the finish-ab
line (V5's sub-bullet, landed with the file it names).

Trace rows closed: #69/body/finish-ab/runner, #69/body/finish-ab/runner-fixture,
#69/body/H2 (runner), #69/body/H3 (spend), #69/body/H4, #69/body/H5,
#69/c5859470658/1, #69/c5859470658/2 (docstring), #69/c5859756889/2a,
#69/c5859756889/2b, #69/c5859756889/2c, #69/c5859756889/2f, #69/c5859811353/H1
(comment), #69/c5859811353/H2, #69/c5859811353/H3, #69/c5881157875/6,
#69/c5892402564/finish-ab-drift, #69/c5892402564/finish-ab-dryrun,
#69/c5892402564/finish-ab-allowlist, #69/c5892402564/finish-ab-nonobject,
#69/c5892402564/finish-ab-failcarried, #69/c5892402564/finish-ab-closedfiles,
#69/c5892402564/finish-ab-deny (the kit's list), #69/c5892402564/finish-ab-cap,
#69/c5901496433/1a, #69/c5901496433/2 (docstring), #69/c5901496433/3; the runner's
parts of #69/body/S6 and #69/body/S8; the exemplar line of #69/body/F10, #69/body/S4,
#69/body/S6 and #69/body/S8 (landed for V5).

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

---

### Task V6.4: The rubric and the brief state no arm count, read the runner's log, and carry the replay and measures clauses (#69/c5859470658/3, #69/c5901496433/{1c, 2, 4, 5}, #69/body/{H6, H7}, #69/body/finish-ab/measures; D45)

**Closes (trace rows, in full):** `#69/c5859470658/3`, `#69/c5901496433/1c`, `#69/c5901496433/2` (the brief's section), `#69/c5901496433/4`, `#69/c5901496433/5` (the rubric's callout), `#69/body/H6`, `#69/body/H7`, `#69/body/finish-ab/measures` (the rubric's section); the rubric part of V5's `#69/body/S10`.

**Files:**
- Modify: `.claude/workflows/finish-ab/judge-rubric.md` (whole file rewritten)
- Modify: `.claude/workflows/finish-ab/operator-brief.md` (whole file rewritten)
- Modify: `.claude/rules/cbk-conventions-reference.md` — § Verification: one check, at the kit sentinel

**Interfaces:**
- **Consumes.** V6.2's `JUDGE_SCHEMA.measures` and the judge prompt's runner-log sentence; V6.3's `<out_dir>.checks/` and `mcp_config` behaviour; `.claude/rules/pr-review.md` § The floor ("invoked, not covered"); the rough-in spec template's measurement variant (its first criterion is the verdict rule).
- **Produces.** The rubric's bracketed sections **The measures, per arm** and **Replay runs**; the brief's `## The issue, verbatim` and its mode-aware review line; the block check that keeps arm counts out of both files. V5's `orchestration.md` judge-panel bullet (`#69/body/S10`, "a rubric quotes the verdict rule's measure definitions verbatim") points at this rubric section.

- [ ] **Step 1: Write the failing block check**

In `.claude/rules/cbk-conventions-reference.md` § Verification, replace (exact, unique, the whole line):

```bash
echo "verification: kit sub-block complete"
```

with:

```bash
# The A/B's rubric and brief state no arm count — finish-ab takes two to four arms, and one filled rubric serves
# replicates of different widths (context-builder-kit#69) — and they carry the headless run's pieces: the rubric reads
# the runner's check log, quotes a verdict rule's measures verbatim and leaves contamination to the launching session;
# the brief carries the issue verbatim for arms that cannot reach an MCP-hosted issue.
absent grep -nE "[Tt]wo executor[s]|two-ar[m]|rank the tw[o]|either worktre[e]|two arms shar[e]" .claude/workflows/finish-ab/judge-rubric.md .claude/workflows/finish-ab/operator-brief.md
{ grep -q "runner's log" .claude/workflows/finish-ab/judge-rubric.md && grep -q 'The measures, per arm' .claude/workflows/finish-ab/judge-rubric.md && grep -q 'Replay runs' .claude/workflows/finish-ab/judge-rubric.md && grep -q '^## The issue, verbatim' .claude/workflows/finish-ab/operator-brief.md; } || { echo "the finish-ab rubric or brief lost the runner's log, the measures section, the replay clause or § The issue, verbatim"; exit 1; }
echo "verification: kit sub-block complete"
```

- [ ] **Step 2: Run the block against the unfixed rubric and brief**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E '^VIOLATION|^verification: block exited'; echo "exit=${PIPESTATUS[0]}"`
Expected:
```
VIOLATION (matched above): grep -nE [Tt]wo executor[s]|two-ar[m]|rank the tw[o]|either worktre[e]|two arms shar[e] .claude/workflows/finish-ab/judge-rubric.md .claude/workflows/finish-ab/operator-brief.md
verification: block exited 1
exit=1
```
(above the violation, the block prints the five matching lines: the rubric's `Two executors implemented`, `then rank the two`, `either worktree`, and the brief's `two-arm experiment` and `two arms share one machine`). Record: `V6.4 block arm-count check — VIOLATION (matched above): grep -nE [Tt]wo executor[s]|…`.

- [ ] **Step 3: The change**

Replace the whole of `.claude/workflows/finish-ab/judge-rubric.md` with:

```markdown
# Judge rubric — the `/finish` A/B on [#<N>]

> **Template.** Fill the bracketed spots; the dimensions and the verify-before-you-score discipline are the exemplar. **Blindness leaks past the arm ids** (context-builder-kit#69): the filled rubric names no arm's mode and points the judges at no file that does (a verdict-rule file naming what each arm is), and before the panel runs the launching session records and moves out of each worktree any untracked artifact that reveals a mode (a subagent-driven arm's `.sdd/` workspace, a ledger, a brief copy). What an arm committed stays and is judged. Never point a judge at the headless runner's `out_dir`: each `<anon>.cmd` there holds the arm's argv, which names its instruction files and effort, and `executed.json` lists what each arm dispatched — so the runner writes the check logs beside it, in `<out_dir>.checks/`, and only that directory reaches a judge's prompt. Judges score the **work on the branch**, take the mechanical gate from the runner's log where the headless runner ran it (else run it themselves), and report contradicted claims before they rank.

Several executors implemented issue [#<N>] (`[<title prefix>]`, repository `[<owner/name>]`) non-interactively, each in its own git worktree, under different instructions. You do not know which arm is which. Judge the **work on the branch**, not the instructions. Verify before you score: read the issue (`gh issue view [<N>] --json title,body`), the frame's milestone section (`docs/cbk/frame-[NN].md` § Milestones › [F<#> — M<#>]), the decision records the issue cites ([`docs/adr/….md` clauses]), and the rules that bind (`.claude/rules/testing.md`, `.claude/rules/pr-review.md` § The floor and § Triage rubric, `.claude/rules/simplification.md`, [the project's test-naming and label sections in `docs/STANDARDS.md`]). Then, for each worktree, run and read:

- `git log --reverse --format='%h %s' <base>..HEAD` — the commit order is the red-first evidence
- `git diff --stat <base>...HEAD` and `git diff <base>...HEAD` — the whole change
- `PLAN.md` and `PR_BODY.md` at the worktree root
- the tests under [`<the test tree the issue names>`]
- the mechanical gate. When your prompt names the runner's log for a worktree (headless arms: `run-arms-headless.py` ran the check task once per arm, after every arm finished), read that log and its exit, and do not re-run the whole gate — parallel gates on one machine measure the machine, not the arms (re-running a single test file is fine). Otherwise run `cd <worktree> && [the check task]; echo exit=$?` yourself. Never trust the arm's own claim
- [any second gate the issue's test plan names, run the same way]

Score each dimension 1–5 with a one-sentence reason, then rank the arms your prompt names. Ties are allowed only with a reason.

1. **Spec fidelity.** Each `[R<#>.AC<m>]` criterion is either implemented with the named proof present, or honestly left operational with the reason. Penalise silent drops, quiet reinterpretation, and criteria claimed done that need the operator or a device.
2. **Assumptions.** `PLAN.md` carries every `[ASSUMPTION:]` line of the issue as confirm-or-correct with a resolution; corrected ones show in the diff.
3. **Test quality and red-first evidence.** The named tests exist with their tags verbatim; logic-regime tests were committed red before the implementation (commit order and the first committed body); no muted or skipped tests; assertions test properties, not snapshots.
4. **Implementation quality within scope.** [The issue's own shape, stated as checks: the named files, the constraints the frame fixes, what the spec forbids.] No cascade-artifact, ADR or check-task edits; lockfiles changed through the tool, never by hand.
5. **Review-gate honesty and triage quality.** The `## Review gate` lines in `PR_BODY.md` are literally true against the arm's self-report (the launching session cross-checks transcripts); triage classes follow the rubric; Apply items exist as their own commits with the SHAs the body names; Surface entries carry verbatim rationale.
6. **Diff size and reviewability.** Could one reviewer read this PR in one sitting? Penalise bulk beyond the spec and files the spec forbade; reward a diff whose shape follows the spec.
7. **Hand-off and PR body prose.** Standing on its own, honest about what is open, no re-quoted spec, no narration, [any project-required block present with the right citations].

Also report:

- **hallucinations** — any claim in `PR_BODY.md`, `PLAN.md`, commit messages or code comments that the repository, the pinned package source, or the issue contradicts. Quote the claim verbatim and name the contradicting source with a path and line.
- **graft** — ideas from the loser worth carrying into the winner.
- **word counts** — `PR_BODY.md` and `PLAN.md`, and the diff's added-line count.

[**The measures, per arm.** Keep this section only when the run has a verdict rule — a measurement issue's first criterion (the rough-in spec template's measurement variant) — and delete it otherwise. Paste each measure's definition here **verbatim** from the verdict rule; never restate it: a stricter paraphrase of one definition split a panel three to three (context-builder-kit#69). Report each measure per arm, as an observed fact, in the structured result's `measures`. `red_first`, `commit_per_finding`, `tags_resolve`, `criteria_met` and `contaminated_hunks` are the exemplar's names; a run's verdict rule names its own.]

[**Replay runs.** Keep this paragraph only when the arms replay an issue already implemented on the base branch. A hunk verbatim-identical to the merged implementation is a **candidate** for contamination, never a finding: the same model converges on the same code without having seen it, so a diff against a reference it wrote over-flags. List the candidates in `measures.contaminated_hunks`. You do not decide contamination: the launching session does, from each arm's transcript (any read of a commit, ref or PR past the replay's base), and a judge reads no transcript and nothing in the runner's `out_dir`.]

Write your full report to the path you are given, and return the structured result. Do not edit any file in any worktree or in the repository.
```

Replace the whole of `.claude/workflows/finish-ab/operator-brief.md` with:

```markdown
# Operator brief — the `/finish` A/B on [#<N>] (non-interactive, throwaway)

> **Template.** Fill the bracketed spots for the run and pass this file's directory as `args.scratch`. Every gate the executor would stop at is converted here into a recorded decision — never removed.

You are executing issue **[#<N>]** — `[<title>]` — in the repository `[<owner/name>]`, **inside a git worktree of your own** (your current working directory). This is one arm of an experiment with two to four arms; the branch you produce is throwaway and will never merge. Work exactly as if it were real, except for the rules below.

## What non-interactive means here

- **No human answers you.** Where the flow stops for the operator (the plan gate, a question, a permission), make the call you would propose, write it down, and continue. Record every such call in your final return under `gate_calls`.
- **The plan gate is a file.** Plan mode is unavailable to you. Write the plan to `PLAN.md` at the worktree root, treat it as approved, and proceed. The plan must still carry every `[ASSUMPTION:]` line of the issue as a confirm-or-correct item with your resolution.
- **Never run the product.** [Name the commands that would touch shared hardware, a device, a live service or the network — the arms share one machine.] Building and testing (`[the project's build command]`, `[the project's test command]`, `[the check task]`) are allowed and expected. Every acceptance criterion that needs a real run is **operational** for this experiment: leave it honestly open in the PR body and hand-off, with what the operator must do.
- **No remote writes.** Do not push, do not open a PR, do not create, edit, comment on or label any issue, do not run any `gh` write command. Reading with `gh` is fine. Write the PR body you would have submitted, complete, to `PR_BODY.md` at the worktree root.
- **The review floor is available to you** — invoke `/simplify` and `pr-review-toolkit:review-pr` as skills, exactly as the instructions you were given require, and triage their findings. Do not claim any invocation you did not make. [Keep the sentence for this run's mode and delete the other.] [**A workflow arm** (the finish-ab workflow dispatched you as an agent): you have no Agent tool, so each skill runs without its own agent fan-out — record it as invoked, not covered, naming the dimensions it dropped (`.claude/rules/pr-review.md` § The floor) — and the project's review **workflow** cannot run from inside a dispatched agent: record that on the sweep's line of the `## Review gate` block as skipped, with that reason.] [**A headless arm** (`run-arms-headless.py` started you as a top-level `claude -p` session): the skills fan out as they normally do; run the project's review workflow as the instructions require if this session can launch it, and if it cannot, record it on the sweep's line as skipped, with the reason the attempt gave.]
- **Stay in your worktree.** Do not edit, create or delete anything outside your current working directory. Do not touch the main checkout, the scratch directory of the session that launched you, or any other arm.
- **Commit on your own branch** (create it from the worktree's current commit, named per the project's convention), never on the base branch.

## The issue, verbatim

[Headless arms run under `--strict-mcp-config` (`run-arms-headless.py`): no MCP server loads unless the run's `mcp_config` names a read-only one, so an arm cannot read an issue that lives behind one — a Linear planning backend, say. Paste the issue's body and every comment here, verbatim, and the arms read it here. On a github-issues project `gh issue view` still works and this section can go.]

## Standing decisions you inherit (do not re-decide)

- Everything in the issue body's `## Assumptions` stands unless your research proves a line false; then correct it in `PLAN.md` and say why.
- [One line per decision the gate would otherwise re-open — a path the operator approved, a rule the frame states, a dependency the operator supplies from outside the repo.]

## Hard limits

- Do not modify `docs/cbk/*`, `docs/adr/*`, `.claude/*`, the check task's dependency list, [or the product packages the issue does not name].
- Do not install system packages or change the machine's configuration.
- Stop when the branch, `PLAN.md`, `PR_BODY.md` and the hand-off exist; do not wait for anything.

## What to return

The structured result: your branch name, the worktree path, the ordered commit list (SHA and subject), the paths of `PLAN.md` and `PR_BODY.md`, the exact `check`-task command you ran last and its exit status, the test names you wrote, which skills you actually invoked (by name), the criteria you left operational, every gate call you made, and brief notes. The hand-off text goes in `handoff`.
```

- [ ] **Step 4: Run the harness tests and the block**

Run:
```bash
node .claude/workflows/tests/finish-ab-shape.mjs
grep -nE '(^|[[:space:](,;])#[0-9]{1,3}\b' .claude/workflows/finish-ab/judge-rubric.md .claude/workflows/finish-ab/operator-brief.md; echo "bare=$?"
bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E '^(finish-ab-shape|always-loaded total|run-arms-headless-fixture|verification: )'; echo "exit=${PIPESTATUS[0]}"
```
Expected:
```
finish-ab-shape: 24 scenarios ok
bare=1
finish-ab-shape: 24 scenarios ok
always-loaded total: N bytes
run-arms-headless-fixture: ok
verification: kit sub-block complete
verification: done
exit=0
```
with `N` unchanged. No hook is touched.

- [ ] **Step 5: Commit**

```bash
git add .claude/workflows/finish-ab/judge-rubric.md .claude/workflows/finish-ab/operator-brief.md .claude/rules/cbk-conventions-reference.md
git commit -F- <<'EOF'
feat(workflows): V6 — the finish-ab rubric and brief state no arm count, and carry the headless run's pieces

The rubric and the brief are reused across replicates of two to four arms, so neither
states a count. The rubric lists what leaks blindness past the arm ids and never points
a judge at the runner's out_dir; judges read the runner's check log where one exists
instead of re-running the gate; a run with a verdict rule quotes each measure's
definition verbatim; and on a replay a hunk identical to the merged implementation is a
candidate, with contamination decided by the launching session from the transcripts.
The brief carries the issue verbatim for arms that cannot reach an MCP-hosted issue,
and its review-floor line says what each arm mode can and cannot run. A block check
keeps arm counts out of both files.

Trace rows closed: #69/c5859470658/3, #69/c5901496433/1c, #69/c5901496433/2 (brief),
#69/c5901496433/4, #69/c5901496433/5 (rubric), #69/body/H6, #69/body/H7,
#69/body/finish-ab/measures (rubric); the rubric part of #69/body/S10.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

---

## Coverage

Every id in the V6 pack — items, handed-in, critic and review — and where it lands. "Handed to" names what the other cluster lands; V6's own part, where there is one, is in the task named.

| Id | Lands in | Notes |
|---|---|---|
| `#69/body/finish-ab/N-arm` | V6.2 | the code; the orchestration wording handed to V5, the README and CLAUDE.md one-liners to V10 |
| `#69/body/finish-ab/latin-square` | V6.2 | `positionCounts`/`balanced`; scenarios 3, 9, 10 |
| `#69/body/finish-ab/measures` | V6.2, V6.4 | the optional schema property (V6.2, scenario 21); the rubric section (V6.4) |
| `#69/body/finish-ab/executed` | V6.2 | scenario 11 |
| `#69/body/finish-ab/replay-args` | V6.2 | `base`, `brief`, `rubric`; scenarios 15–18 |
| `#69/body/finish-ab/runner` | V6.3 | the README tree line handed to V10 |
| `#69/body/finish-ab/runner-fixture` | V6.3 | run by the block in the kit sub-block |
| `#69/body/cost/version-keys` | V6.1 |  |
| `#69/body/cost/cache-read` | V6.1 |  |
| `#69/body/cost/block-diff` | V6.1 | `pk`/`pr`, version-keyed, with the empty-read guard |
| `#69/body/cost/fixture-rows` | V6.1 | rows `eee` (Fable 5.1) and `fff` (Opus 5.5), in the 17-row union |
| `#69/body/cost/synthetic` | V6.1 | rows `ggg` and `ppp` |
| `#69/body/cost/fast-mode` | V6.1 | row `hhh` |
| `#69/body/H1` | V6.2, V6.3; handed to V5 | `executed` and the runner are the code side; the `pr-review.md` sentence and probe P2 are V5's |
| `#69/body/H2` | V6.3; handed to V5 | `UNATTENDED` on every call, `continuation()`, the per-pass cap; the anti-pattern row is V5's |
| `#69/body/H3` | V6.3; handed to V5 | `spend()`; the reference quotation is V5's |
| `#69/body/H4` | V6.3; handed to V5 | `budget=left`; fixture case 6; the cost-terms text is V5's |
| `#69/body/H5` | V6.3 | `DENY`, `WRITE_SERVERS`; fixture case 8 |
| `#69/body/H6` | V6.4 | the rubric's **Replay runs** paragraph |
| `#69/body/H7` | V6.4 | the rubric's **The measures, per arm** section |
| `#69/c5859470658/1` | V6.3 | the runner fixture joins the four already in the block; no `workflow-fixtures` task is ported |
| `#69/c5859470658/2` | V6.3; handed to V8 | the docstring names the anchored entry; the `.gitignore` lines are V8's |
| `#69/c5859470658/3` | V6.4 | with the block's arm-count check |
| `#69/c5859756889/1a` | V6.1 | regression guard only (§ Not holding) |
| `#69/c5859756889/1b` | V6.1, V6.2 | both unions, renamed and renumbered (§ Not holding) |
| `#69/c5859756889/1c` | V6.2 | scenario 12 |
| `#69/c5859756889/2a` | V6.3 | `load_payload`; fixture case 5 |
| `#69/c5859756889/2b` | V6.3 | fixture case 2 asserts it on Q's continuation |
| `#69/c5859756889/2c` | V6.3 | the docstring and the `WRITE_SERVERS` comment |
| `#69/c5859756889/2d` | V6.1 | per-row JSON reads; the `importlib` tier check under `python3 -B` |
| `#69/c5859756889/2e` | V6.2 | scenarios 15, 16, 17 |
| `#69/c5859756889/2f` | V6.2, V6.3 | `dispatched` optional in V6.2's copy, required in V6.3's; scenario 19 |
| `#69/c5859756889/2g` | V6.1 | `ck`/`cr` |
| `#69/c5859811353/H1` | V6.3 (comment) | the finding does not hold (§ Not holding) |
| `#69/c5859811353/H2` | V6.3 | the docstring states the cap per runner pass |
| `#69/c5859811353/H3` | V6.3 | the `gh api` comment |
| `#69/c5881157875/2-steps` | handed to V5 | the price steps, outside the sentence V6.1 replaces |
| `#69/c5881157875/2-sonnet5` | handed to V5 | the footnote, never as a `Sonnet 5 $3/$15` string |
| `#69/c5881157875/2-fable5-misprice` | V6.1 | row `mmm`; the sync note handed to V10 |
| `#69/c5881157875/2-version-keys-fix` | V6.1 |  |
| `#69/c5881157875/6` | V6.3 | the variadic comment |
| `#69/c5892402564/cost-1` | V6.1 |  |
| `#69/c5892402564/cost-2` | V6.1 |  |
| `#69/c5892402564/cost-3` | V6.1 |  |
| `#69/c5892402564/cost-4` | V6.1 | Step 7 runs both mutants |
| `#69/c5892402564/transcripts` | V6.1 | `tier()` docstring; row `jjj` |
| `#69/c5892402564/probe` | V6.2, V6.3 (pointer); handed to V5 | P2 is re-run by V5 on the release CLI; V6 points at its record |
| `#69/c5892402564/finish-ab-drift` | V6.3 | scenario 19 |
| `#69/c5892402564/finish-ab-dryrun` | V6.3 | fixture case 8 |
| `#69/c5892402564/finish-ab-allowlist` | V6.3 | fixture case 9 |
| `#69/c5892402564/finish-ab-nonobject` | V6.3 | fixture case 10 |
| `#69/c5892402564/finish-ab-failcarried` | V6.3 | fixture case 12 |
| `#69/c5892402564/finish-ab-closedfiles` | V6.3 | context managers; the fixture's `ResourceWarning` watch |
| `#69/c5892402564/finish-ab-deny` | V6.3 (the kit's list) | the project's list is not portable (§ Not holding) |
| `#69/c5892402564/finish-ab-cap` | V6.3 |  |
| `#69/c5901496433/1a` | V6.3 | `run_checks`; fixture cases 15, 15b, 11h |
| `#69/c5901496433/1b` | V6.2 | `gateOf`, `describe`, `gateNote`; scenario 20 |
| `#69/c5901496433/1c` | V6.4 |  |
| `#69/c5901496433/2` | V6.3, V6.4 | the docstring (V6.3) and § The issue, verbatim (V6.4) |
| `#69/c5901496433/3` | V6.3 | fixture case 8 refuses the bare rule |
| `#69/c5901496433/4` | V6.4 |  |
| `#69/c5901496433/5` | V6.2, V6.4 | the args comment (V6.2) and the rubric callout (V6.4) |
| `#69/c5901496433/6` | V6.1 | the `importlib` check |
| `#69/c5901496433/measurement` | handed to V10 (F1's ledger) | V6 adds 0 always-loaded bytes; each task's runner run confirms it |
| `#69/body/T8` (handed in) | V6.1 | the code and, on V5's behalf, the prices bullet (one commit for three copies) |
| `#69/body/F5` (handed in) | V6.1 |  |
| `#69/body/S6` (handed in) | V6.3; rest V5 | `spend()` and the exemplar sub-bullet (landed for V5, V5 § Handed item 2); the lesson text is V5's |
| `#69/body/S8` (handed in) | V6.3; rest V5 | `DENY` and the exemplar sub-bullet (landed for V5); the lesson text is V5's |
| `#69/body/F10`, `#69/body/S4` (V5's rows, not in the V6 pack) | V6.3 (the exemplar sub-bullet) | V5 lands the rule text and hands the `run-arms-headless.py` exemplar line here (V5 § Handed to other clusters, item 2), because the file it names first exists in V6.3's commit; V6.3's commit names both for the trace audit |
| `#69/body/S10` (handed in) | V6.4; rest V5 | the rubric section; the rule sentence is V5's |
| `#69/c5881157875/2c` (handed in) | V6.1 |  |
| `#69/c5881157875/2d` (V5's row, not in the V6 pack) | V6.1 | V5 hands its landing here with `#69/body/T8` (Interfaces; § Handed to other clusters), so V6.1's commit names it for the trace audit |
| `#58/c5901493591/R9` (handed in) | V6.1; rest V5 | the docstring's conditional; the reference note is V5's |
| `release/5` (handed in) | V6.1, V6.2 | `agent-cost.py` (`#58 item 6` → `context-builder-kit#58 item 6`), `finish-ab.js` (`#58 item 9`), `finish-ab-shape.mjs` (`#58 item 10`) — each whole-file rewrite carries the `context-builder-kit#N` form, and V6.1 Step 7, V6.2 Step 5, V6.3 Step 7 and V6.4 Step 4 each print `bare=1`; the check is V9's |
| `review/portability/67` (handed in from V9) | V6.1 | the re-keyed `pr=` lowercases with `tr '[:upper:]' '[:lower:]'`, not `sed`'s GNU-only `\L`; Step 4 runs the old line red under busybox (`> LOpus 5 25`), Step 7 runs the new one green under busybox and confirms no uncommented `sed … \L` is left in the block; `cr=` lowercases in Python |
| `critic/19` | V6.1 | the bullet lists all eight versions; both diffs read them |
| `critic/20` | V6.1 | every `python3` call in the fixture runs with `-B` |

The pack's own `review` list is empty; `review/portability/67` is handed in from V9 (V9 § Handed to other clusters › V6) and lands in V6.1.

## Handed to other clusters

- **V5 — rule text about the harness** (`orchestration.md`, `orchestration-reference.md`, `pr-review.md`, all V5's files):
  - `#69/body/finish-ab/N-arm` and `#69/body/F10`: `orchestration.md` line 36's exemplar sentence and line 82's judge-panel bullet, and `orchestration-reference.md`'s `finish-ab/` exemplar line, say "every arm read in every position equally often (two arms: an even count, half per order)" in place of "an even judge panel split by reading order" (V5.6 lands the reference line as "the judge panel reads every arm in every position equally often, and the script refuses an unbalanced panel before dispatch"). The headless-runner exemplar line naming `run-arms-headless.py` came back: V5 wrote it and handed its landing to V6.3 (V5 § Handed to other clusters, item 2), because the file it names first exists in V6.3's commit; V6.3 Step 5 (a) inserts it verbatim.
  - `#69/body/H1` and `#69/c5892402564/probe`: probe P2 on the release CLI, recorded by V5.10 in `pr-review.md` § The floor (the clause `a workflow agent has none at any depth`, with the Claude Code version and date) and in `orchestration-reference.md`'s **A workflow agent has no Agent tool** bullet; V6.2 and V6.3 point at § The floor, and V6.2 Step 1 greps both exact texts.
  - `#69/body/H2`: the anti-pattern row "reading a text-only end of turn as the work being done" in `orchestration.md`.
  - `#69/body/H3` (`#69/body/S6`) and `#69/body/H4`: the cost-terms lessons and their quotations in `orchestration-reference.md` — "the run reports the conversation's whole total" (`code.claude.com/docs/en/headless`) and "don't count toward it" (`code.claude.com/docs/en/cli-reference`); both verified raw on 2026-09-30 by V6.3 Step 6.
  - `#69/body/S8`: the rule-text lesson for the deny list, generic ("every write-capable server your project wires"); the list itself is V6.3's `WRITE_SERVERS`.
  - `#69/body/S10`: the judge-panel bullet's sentence "a rubric quotes the verdict rule's measure definitions verbatim", pointing at V6.4's rubric section.
  - `#69/c5881157875/2-steps` and `#69/c5881157875/2-sonnet5`: the price steps (2× / 2× / 2.5×) and the Sonnet 5 footnote, placed outside the sentence V6.1 replaces (neither may be written as `Sonnet 5 $3/$15`, which the list-price diff would read as a row).
  - `#69/body/T8` and `#69/c5881157875/2d`: V5 supplies the wording and hands the landing to V6.1 (the three copies are one fact); V5 keeps the ladder bullet's pricing sentence untouched until V6.1 runs, and V6.1 inserts the **Prices, per version** bullet directly after V5.3's **Price steps** bullet, anchored on the line beginning `- **Aliases, by provider and by version** (` (V5 § Handed to other clusters, item 1: V5.4 retires the old `` - **The `high` default** — `` anchor).
  - `#58/c5901493591/R9`: the reference half's conditional note on the 3.2× pooled ratio (V6.1 lands the docstring half).
- **V8 — `.gitignore`** (`#69/c5859470658/2`): the kit's own `.gitignore` gains `/.claude/worktrees/` (the runner's `worktree_root`) and the bytecode pair `/.claude/workflows/**/__pycache__/` and `/.claude/workflows/**/*.py[cod]`, and the starter harness block carries the same lines. V6's fixtures run every `python3` with `-B`, so no V6 commit writes bytecode meanwhile.
- **V10 — README and CLAUDE.md** (`#69/body/finish-ab/N-arm`, `#69/body/finish-ab/runner`): `README.md` line 330 ("two-arm A/B harness exemplar") and `CLAUDE.md` line 43 ("finish-ab/ two-arm A/B") become "A/B/n (two to four arms)", and the README tree lists `run-arms-headless.py` and `tests/run-arms-headless-fixture.sh`. The CHANGELOG's v1.0.0 sync notes say that every target synced at `74edf84` prices legacy Fable 5 cache reads at 0.025x until it takes V6.1, and that a target copying the runner fills `WRITE_SERVERS` with its own write-capable servers and `worktree_setup` with its own per-worktree step. The always-loaded before-and-after ledger (`#69/c5901496433/measurement`): V6 adds 0 bytes.
- **V9 — the bare-citation check** (`release/5`): V6's files carry only `context-builder-kit#N` citations (every task's Step checks `bare=1`); V9 lands the block check that keeps them out. `review/portability/67` comes the other way (V9 → V6) and lands in V6.1.

## Not holding at planning time

- **`#69/c5859811353/H1` — "`--disallowedTools *DENY` may apply only the first rule; comma-join it."** Does not hold. `claude --help` on Claude Code 2.1.285 (read 2026-09-30) prints `--disallowedTools, --disallowed-tools <tools...>` and "Comma or space-separated list of tool names to deny": the flag is variadic, so the spread passes every rule, and the next flag ends the list. A live probe with a positive control on 2.1.284 (context-builder-kit#69, 2026-09-28) denied both of two space-separated rules. V6.3 keeps the spread and lands the comment that stops the finding being re-raised (`#69/c5881157875/6`); V6.3 Step 6 re-reads the help text at execution.
- **`#69/c5892402564/finish-ab-deny` — "DENY covers every write-capable server the private target wires."** Holds only for that project's list, which is not portable. The kit ships its own axes' servers (`github`, `linear`, `notion`, in configured and plugin form) plus the claude.ai connector glob, and the docstring tells a target to add its own; the boundary is `--strict-mcp-config` with the allowlist, which the fixture's case 9 pins.
- **`#69/c5859756889/1a` and `1b` — duplicate `CACHE_READ` definitions and colliding case names.** Live only when a target's file is merged in; the kit re-authors, so neither defect exists at `74edf84`. They land as regression guards (the fixture's `grep -c '^CACHE_READ ='` and the unioned, renamed case and scenario sets), re-checked at execution by V6.1 Step 7 and V6.2 Step 5.
