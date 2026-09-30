# Harvest 5 — V7: Review conventions

**Scope.** This cluster lands the review conventions the targets settled after harvest 4: the D46 rewrite of
`.claude/workflows/review-sweep.js` (finders that carry a prompt, dedup on file and line carrying every title, a logged
roster throw, the read-only clause in every find and verify prompt, and — handed in from V5 — the Sonnet 5.5
think-first line that ends every finder's brief), each pinned red-first by a new scenario in
`.claude/workflows/tests/review-sweep-accounting.mjs`; the matching `pr-review.md` rule text (the finder shape,
invariant (3) with triage by the report the verifier named, invariant (2) for an interrupted run, § The floor › Once's
one-verification-workflow rule, the enumerate-a-family craft rule); the "Folding one review layer into another"
anti-pattern in `pr-review-reference.md`; rough-in's re-verify-a-consolidation rule with its contract pointer and test
criterion; `/pr-respond`'s NOT-list agreeing with its Step 7; the three unverified whole-kit review findings on
`pr-review.md` / `pr-review-reference.md`, each re-checked at planning time and still holding; and the two review-rule
citations of `STANDARDS.md` headings the blueprint template never emits (V7's part of `review/consistency/40`, handed
from V3). It closes the trace rows of #72 (items 1–5; item 4's rule bullet is V5's), #74 items 1–2 and its
cross-reference, #58 residue B and R10, #64, `critic/21`, `review/consistency/44`, `review/consistency/45` and
`review/claude-code/53`, plus V7's parts of `review/consistency/40` (`pr-review.md:3`, `pr-review-reference.md:142`),
`#69/c5881157875/1c` (the finder line) and `release/5` (bare kit-issue citations in the two workflow files). It
**consumes** from earlier clusters: V1's runner (unchanged behaviour on the kit tree); V5's `orchestration.md`
§ Fan-out discipline bullet "Read-only agents stay read-only" (cited by V7.4's comment — a precondition step checks
it landed); V5's edit of `pr-review.md` § The floor's Agent-tool sentence and of rough-in `research-phase.md`'s
grounding rules (V7's anchors avoid both); V3's `arguments:` frontmatter on `/finish` and its decision on
`--skip-review` (Review Focus 5 — V7.14 branches on it).

**Dry-run evidence.** Tasks V7.1–V7.14 were executed at planning time, in order, on a fresh clone of the kit at
`643f7ff` (scratch, not the real checkout): each Step 2 printed exactly the red line quoted, each Step 4 went green,
and the fourteen commits' net diff is 9 files, +194/−37. That replay necessarily took V7.14's branch C (no V3 in the
tree) and ran V7.4 past its Step 0 (no V5 bullet). V7.15 was added at reconciliation and dry-run on its own on a
`643f7ff` extract: its check, run alone, printed the quoted VIOLATION line against the unfixed files and passed after
Step 3's two edits, and `pr-review.md` shrank by 55 bytes. At execution V3.1 will already have wired `--skip-review`
into `/finish` (V3's plan, Task V3.1), so V7.14 is expected to take branch A: fourteen commits (V7.1–V7.13 and V7.15).
At execution the tree also carries V1–V6, so line numbers differ; every anchor is text no earlier cluster's task
changes (§ Ownership map). If an anchor is missing, stop and reconcile — never guess.

**Reading the runner.** After V1 the block's tail runs `run-verification-block-fixture.sh`, so its `ok:` lines and
`run-verification-block-fixture: 6 cases ok` sit between the always-loaded total and the sentinels. Every green gate
step therefore filters the output (`grep -E 'always-loaded total|WARN|VIOLATION|verification:'`) instead of reading it
by position. The red steps keep `| tail -2`: the new check sits last before the sentinel, so its failure message and
the runner's `verification: block exited 1` really are the last two lines.

**Always-loaded budget (D50/D59).** Only `pr-review.md` is always loaded among V7's files. Its growth, per task, measured
on the dry run: V7.2 +145, V7.3 +375, V7.6 +227, V7.7 +581, V7.9 +100, V7.12 +253, V7.13 +63, V7.14 +125 (only on
branch C), V7.15 −55 — **+1,689 bytes** on the expected branch A, **+1,814** on branch C. V5's `knowledge-backend.md` split pays for it under D59; the PR body's
before/after ledger records it.

## Plan decisions (for the PR body)

- **V7-D1 — docs-only PRs skip the sweep, never the floor** (`review/claude-code/53`). `pr-review.md` § What NOT to flag
  said "the simplify pass is enough" and the reference half called running the toolkit on a docs-only PR an
  anti-pattern, while § The floor admits no waiver but break-glass. The floor wins: a docs-only PR may record the
  sweep as `skipped — docs-only diff`; both floor skills still run. The review bot's own docs-only skip
  (`claude-review.yml`) is a separate layer and is untouched.
- **V7-D2 — "four-class" stays the rubric's name** (`review/consistency/44`). The fix names the four classes and calls
  Apply with care the flagged variant of Apply that the table and the counts keep apart; renaming to "five-class"
  would sweep some twenty sites across byte-parallel executor copies for no behavioural gain. The Defer and Reject
  triggers are made exclusive for an ADR conflict.
- **V7-D3 — the think-first line ends finder prompts only.** The Sonnet 5.5 guide's remedy is for Sonnet 5.5; the
  finders are pinned `sonnet`, the verifiers run at the session model.
- **V7-D4 — no issue citations inside always-loaded `pr-review.md` prose** (bytes); code comments and the path-scoped
  reference half cite `context-builder-kit#N` (D53).
- **V7-D5 — scenario labels continue at 25** (settled call: the harness's existing labels stay as they are); the
  harness prints its own total, 31 → 35.
- **V7-D6 — break-glass `--skip-review` is V3's call, V7 closes whatever is left** (Review Focus 5). V7.14 has three
  exact branches.

### Task V7.1: The roster read's throw is logged; bare kit-issue citations qualified (#72/body/3, release/5 part; D46, D53)

**Files:**
- Modify: `.claude/workflows/review-sweep.js` (the roster `.catch`; two comment citations)
- Modify: `.claude/workflows/tests/review-sweep-accounting.mjs` (scenario "15 — a roster read that THROWS"; one comment citation)

**Interfaces:**
- Consumes: nothing from earlier clusters.
- Produces: the log line prefix `review-sweep: the roster read threw — ` (a throwing roster read now leaves its reason in the run log). After this task neither file carries a bare `#N` kit-issue citation, so V9's kit-tree bare-citation check is green on them.

- [ ] **Step 1: Write the failing assertion (and qualify the harness's one bare citation)**

**Edit 1** — `.claude/workflows/tests/review-sweep-accounting.mjs`. Replace this exact text (verbatim at HEAD, unique in the file):

```js
  assert.ok(out.droppedCoverage.some((d) => d.includes("roster read failed")), "a throwing roster read is dropped coverage, not an aborted run");
```

with:

```js
  assert.ok(out.droppedCoverage.some((d) => d.includes("roster read failed")), "a throwing roster read is dropped coverage, not an aborted run");
  assert.ok(logs.some((l) => l.includes("budget ceiling")), "the degrade path logs WHY the roster read threw, not only that it degraded (context-builder-kit#72 item 3)");
```

**Edit 2** — `.claude/workflows/tests/review-sweep-accounting.mjs`. Replace this exact text (verbatim at HEAD, unique in the file):

```js
null is modelled by returning null (#58 item 10).
```

with:

```js
null is modelled by returning null (context-builder-kit#58 item 10).
```

- [ ] **Step 2: Run it against the unfixed script (red)**

Run: `node .claude/workflows/tests/review-sweep-accounting.mjs 2>&1 | grep -m1 AssertionError; echo "exit=${PIPESTATUS[0]}"`
Expected:

```
AssertionError [ERR_ASSERTION]: the degrade path logs WHY the roster read threw, not only that it degraded (context-builder-kit#72 item 3)
exit=1
```

Record the AssertionError line in the PR body's red-first table.

- [ ] **Step 3: The fix**

**Edit 1** — `.claude/workflows/review-sweep.js`. Replace this exact text (verbatim at HEAD, unique in the file):

```js
  ).catch(() => null); // a throw (a budget ceiling — orchestration.md § Fan-out discipline) degrades exactly like a null read below; every other agent() here sits inside a parallel() thunk, which the runtime catches (#58 item 8)
```

with:

```js
  ).catch((e) => {
    // A throw (a budget ceiling — orchestration.md § Fan-out discipline) degrades exactly like a null read below;
    // every other agent() here sits inside a parallel() thunk, which the runtime catches (context-builder-kit#58
    // item 8). The reason is logged first, so the degrade path keeps a record of why (context-builder-kit#72 item 3).
    log(`review-sweep: the roster read threw — ${e && e.message ? e.message : String(e)}`);
    return null;
  });
```

**Edit 2** — `.claude/workflows/review-sweep.js`. Replace this exact text (verbatim at HEAD, unique in the file):

```js
`src/schema-extra/x` (#58 item 7). A hint
```

with:

```js
`src/schema-extra/x` (context-builder-kit#58 item 7). A hint
```

**Edit 3** — `.claude/workflows/review-sweep.js`. Replace this exact text (verbatim at HEAD, unique in the file):

```js
shared with finish-ab.js (#58 smaller item 6)
```

with:

```js
shared with finish-ab.js (context-builder-kit#58 smaller item 6)
```

- [ ] **Step 4: Run the fixture and the gate**

Run: `node .claude/workflows/tests/review-sweep-accounting.mjs`
Expected: `review-sweep accounting: meta + body parse, 31 scenarios OK`, exit 0.

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`
Expected: `always-loaded total: <N> bytes` where N is the previous commit's total unchanged, then `verification: kit sub-block complete`, `verification: done`, `exit=0` — exactly these four lines, no `WARN` and no `VIOLATION` (the fixture lines V1 added to the block's tail are filtered out, so the check does not depend on their position).

No hook is touched by this task, so there is no `bash -n` step. Check the citations: `/usr/bin/grep -nE '(^|[[:space:](,;])#[0-9]{1,3}\b' .claude/workflows/review-sweep.js .claude/workflows/tests/review-sweep-accounting.mjs; echo "bare=$?"` → `bare=1` (no match).

- [ ] **Step 5: Commit**

```bash
git add .claude/workflows/tests/review-sweep-accounting.mjs \
  .claude/workflows/review-sweep.js
git commit -F - <<'EOF'
fix(review-sweep): V7 — log why the roster read threw

The roster read's catch returned null and kept no record of the reason; it now logs the
thrown message before degrading, and the throwing-roster scenario asserts the log line
(red first). Bare kit-issue citations in both workflow files become context-builder-kit#N.

Trace rows closed:
- #72/body/3 — the roster read's catch discards why it threw
- release/5 (V7 part: review-sweep.js, review-sweep-accounting.mjs)
- critic/21 (part: the logged-throw assertion)

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

### Task V7.2: A caller-named finder may carry a prompt (#72/body/1, critic/21 part; D46)

**Files:**
- Modify: `.claude/workflows/review-sweep.js` (`meta.whenToUse`; the finders construction; `findOnce`'s prompt and opts)
- Modify: `.claude/workflows/tests/review-sweep-accounting.mjs` (the stub records each call's prompt; scenario 25)
- Modify: `.claude/rules/pr-review.md` (§ The orchestrated sweep, the caller-named-finders parenthetical)
- Modify: `.claude/rules/cbk-conventions-reference.md` (§ Verification, one kit-sub-block check)

**Interfaces:**
- Consumes: V7.1's harness.
- Produces: the finder shape `{key, prompt?, agentType?}` — the caller's `prompt` reaches the find prompt as `Your review focus, from the caller: <prompt>`; `agentType` is passed only when named; a finder with neither is never dispatched and is pushed onto `droppedCoverage` as `<key> (caller finder with neither prompt nor agentType)`, so the gate line names it. The harness stub now records `{label, opts, prompt}` per call (V7.3–V7.5 rely on `prompt`). The master plan's F2 Step 3 uses this shape.

- [ ] **Step 1: Write the failing scenario, the stub's prompt capture and the block check**

**Edit 1** — `.claude/workflows/tests/review-sweep-accounting.mjs`. Replace this exact text (verbatim at HEAD, unique in the file):

```js
  const agent = async (_prompt, opts = {}) => {
    const label = opts.label ?? "";
    calls.push({ label, opts });
```

with:

```js
  const agent = async (prompt, opts = {}) => {
    const label = opts.label ?? "";
    calls.push({ label, opts, prompt });
```

**Edit 2** — `.claude/workflows/tests/review-sweep-accounting.mjs`. Replace this exact text (verbatim at HEAD, unique in the file):

```js
  assert.ok(out.confirmed.some((f) => f.title === "cr only") && out.confirmed.some((f) => f.title === "adr only"), "neither loaded reporter loses its own unique finding to the shared one");
  n++;
}
```

with:

```js
  assert.ok(out.confirmed.some((f) => f.title === "cr only") && out.confirmed.some((f) => f.title === "adr only"), "neither loaded reporter loses its own unique finding to the shared one");
  n++;
}

// 25 — a caller-named finder may carry its own prompt and no agentType: a targeted concern with no defined agent
//      rides in the sweep (context-builder-kit#72 item 1). A finder with neither is dropped coverage, never
//      dispatched blind.
{
  const { out, calls } = await scenario("prompt-carrying finder", {
    args: { files: ["a"], finders: [{ key: "ratio-bounds", prompt: "Check that every ratio the diff computes stays within [0, 1]." }, { key: "empty-finder" }] },
    roster: rosterOK, findings: { "ratio-bounds": { findings: [F("a", 4, "ratio above one", "high")] } }, verdict: real,
  });
  const c = calls.find((x) => x.label === "find:ratio-bounds");
  assert.ok(c, "the prompt-carrying finder is dispatched");
  assert.equal(c.opts.agentType, undefined, "no agentType: the default workflow agent runs it");
  assert.ok(c.prompt.includes("every ratio the diff computes"), "the caller's focus reaches the finder's prompt");
  assert.ok(out.confirmed.some((f) => f.title === "ratio above one" && f.dimension === "ratio-bounds"), "its finding is attributed to the finder");
  assert.ok(!calls.some((x) => x.label.startsWith("find:empty-finder")), "a finder with neither prompt nor agentType is not dispatched");
  assert.ok(out.droppedCoverage.some((d) => d.includes("empty-finder")), "and it is named as dropped coverage");
  assert.ok(out.gateLine.includes("empty-finder"), "so the gate line names it");
  n++;
}
```

**Edit 3** — `.claude/rules/cbk-conventions-reference.md` § Verification: insert these lines immediately before the line `echo "verification: kit sub-block complete"` (a kit-sub-block check at the sentinel; the sentinel line itself is unchanged):

```bash
# Review conventions (harvest 5, V7): a caller-named finder is {key, prompt?, agentType?} on both surfaces that state it,
# the rule and the workflow's meta (context-builder-kit#72 item 1).
for f in .claude/rules/pr-review.md .claude/workflows/review-sweep.js; do grep -qF '{key, prompt?, agentType?}' "$f" || { echo "$f does not state the caller-finder shape {key, prompt?, agentType?}"; exit 1; }; done
```

- [ ] **Step 2: Run it against the unfixed script (red)**

Run: `node .claude/workflows/tests/review-sweep-accounting.mjs 2>&1 | grep -m1 AssertionError; echo "exit=${PIPESTATUS[0]}"`
Expected:

```
AssertionError [ERR_ASSERTION]: the caller's focus reaches the finder's prompt
exit=1
```

Record the AssertionError line in the PR body's red-first table.

The new block check is red too, run on its own (the runner stops earlier, at the harness line):

Run: `bash -c "$(grep -F 'does not state the caller-finder shape' .claude/rules/cbk-conventions-reference.md)"; echo "rc=$?"`
Expected:

```
.claude/rules/pr-review.md does not state the caller-finder shape {key, prompt?, agentType?}
rc=1
```


- [ ] **Step 3: The fix** — first run `wc -c < .claude/rules/pr-review.md` and note the number.

**Edit 1** — `.claude/workflows/review-sweep.js`. Replace this exact text (verbatim at HEAD, unique in the file):

```js
reviewers?, finders?, maxPerDimension?
```

with:

```js
reviewers?, finders? ([{key, prompt?, agentType?}] — a defined agent, a targeted concern stated as a prompt, or both), maxPerDimension?
```

**Edit 2** — `.claude/workflows/review-sweep.js`. Replace this exact text (verbatim at HEAD, unique in the file):

```js
const finders = (params.finders ?? []).map((f) => ({ key: f.key, agentType: f.agentType }));
```

with:

```js
// A caller-named finder is {key, prompt?, agentType?}: a defined agent, a targeted concern stated as a prompt that
// the default workflow agent reviews against (a ratio bound, a timing invariant), or both. One with neither has
// nothing to review with: dropped coverage, named on the gate line, never dispatched blind (context-builder-kit#72
// item 1).
const finders = [];
for (const f of params.finders ?? []) {
  if (f && f.key && (f.prompt || f.agentType)) finders.push({ key: f.key, agentType: f.agentType, focus: f.prompt });
  else droppedCoverage.push(`${(f && f.key) || "(unnamed)"} (caller finder with neither prompt nor agentType)`);
}
```

**Edit 3** — `.claude/workflows/review-sweep.js`. Replace this exact text (verbatim at HEAD, unique in the file):

```js
restricted to these changed files:\n${fileList}\n\nApply your standard review discipline. Respect
```

with:

```js
restricted to these changed files:\n${fileList}\n\n${dim.focus ? `Your review focus, from the caller: ${dim.focus}\nReport findings on this focus only.\n\n` : "Apply your standard review discipline. "}Respect
```

**Edit 4** — `.claude/workflows/review-sweep.js`. Replace this exact text (verbatim at HEAD, unique in the file):

```js
phase: "Find", agentType: dim.agentType, model: "sonnet"
```

with:

```js
phase: "Find", ...(dim.agentType ? { agentType: dim.agentType } : {}), model: "sonnet"
```

**Edit 5** — `.claude/rules/pr-review.md`. Replace this exact text (verbatim at HEAD, unique in the file):

```markdown
a targeted concern such as a schema change, a timing invariant, a boundary contract)
```

with:

```markdown
a targeted concern such as a schema change, a timing invariant, a boundary contract — each named as `{key, prompt?, agentType?}`: a defined agent, a concern stated as a prompt, or both, and one with neither is dropped coverage)
```

- [ ] **Step 4: Run the fixture and the gate**

Run: `node .claude/workflows/tests/review-sweep-accounting.mjs`
Expected: `review-sweep accounting: meta + body parse, 32 scenarios OK`, exit 0.

Run: `wc -c < .claude/rules/pr-review.md` and subtract the Step 3 pre-change reading.
Expected: the file grew by exactly **145 bytes** (the always-loaded ledger, D50/D59; record it for the PR body).

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`
Expected: `always-loaded total: <N> bytes` where N is the previous commit's total plus 145, then `verification: kit sub-block complete`, `verification: done`, `exit=0` — exactly these four lines, no `WARN` and no `VIOLATION` (the fixture lines V1 added to the block's tail are filtered out, so the check does not depend on their position).

No hook is touched by this task, so there is no `bash -n` step.

- [ ] **Step 5: Commit**

```bash
git add .claude/workflows/tests/review-sweep-accounting.mjs \
  .claude/rules/cbk-conventions-reference.md \
  .claude/workflows/review-sweep.js \
  .claude/rules/pr-review.md
git commit -F - <<'EOF'
feat(review-sweep): V7 — caller-named finders carry a prompt

A finder is {key, prompt?, agentType?}: a defined agent, a targeted concern stated as a
prompt the default workflow agent reviews against, or both. agentType is passed only when
named; a finder with neither is dropped coverage, named on the gate line, never dispatched
blind. The harness stub records each call's prompt; scenario 25 was red first. pr-review.md
and the workflow's meta state the shape; a kit-sub-block check keeps both.

Trace rows closed:
- #72/body/1 — a caller-named finder cannot carry a prompt
- critic/21 (part: the stub records each call's prompt; scenario 25)

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

### Task V7.3: Dedup on file and line, every title carried, triage by the report the verifier named (#72/body/2, critic/21 part; D46)

**Files:**
- Modify: `.claude/workflows/review-sweep.js` (the dedup block; the verify prompt and the comment above it)
- Modify: `.claude/workflows/tests/review-sweep-accounting.mjs` (scenario 26)
- Modify: `.claude/rules/pr-review.md` (§ Three invariants, invariant (3))
- Modify: `.claude/rules/cbk-conventions-reference.md` (§ Verification, two kit-sub-block checks)

**Interfaces:**
- Consumes: V7.2's `prompt` capture in the stub.
- Produces: every deduplicated finding carries `titles: string[]` and `details: string[]` beside `title`/`detail`; `alsoFoundBy` holds each co-reporting dimension once, never the original. The dedup key is `file:line`, or `file:?:<normalized title>` when a finding names no line. The verify prompt reads `Finding (from D…) at <file>:<line>:` followed by one `- "<title>". Detail: …` bullet per report, and for a merged finding asks the verifier to "name in your reasoning which of the reports the evidence demonstrates". The invariant sentence `the caller triages that report, and the merged finding's other titles stand as unverified` is the triage rule `/finish`'s triage step and F2 Step 4 follow.

- [ ] **Step 1: Write the failing scenario and the block checks**

**Edit 1** — `.claude/workflows/tests/review-sweep-accounting.mjs`. Replace this exact text (created by V7.2; not at HEAD — verbatim and unique once that task has landed):

```js
  assert.ok(out.gateLine.includes("empty-finder"), "so the gate line names it");
  n++;
}
```

with:

```js
  assert.ok(out.gateLine.includes("empty-finder"), "so the gate line names it");
  n++;
}

// 26 — dedup keys on file + line: paraphrases of one defect from three dimensions share ONE verify slot, whose prompt
//      lists every title and asks the verifier to name the report its evidence proves; the strongest severity and
//      every co-reporter are kept (context-builder-kit#72 item 2). Line-less findings keep the title in the key, so
//      two different line-less findings in one file stay two.
{
  const { out, calls } = await scenario("paraphrased duplicates", {
    args: { files: ["a"], maxPerDimension: 3, maxVerify: 8 }, roster: rosterOK,
    findings: {
      "code-review": { findings: [F("a", 7, "Unknown config key is skipped, not refused", "medium")] },
      "silent-failures": { findings: [F("a", 7, "An unrecognised config key is silently ignored", "high")] },
      "adr-conformance-reviewer": { findings: [F("a", 7, "config key naming no setting is not rejected", "low"), F("a", undefined, "no line one", "low"), F("a", undefined, "no line two", "low")] },
    },
    verdict: real,
  });
  const onSeven = calls.filter((c) => c.label.startsWith("verify:") && c.prompt.includes("at a:7"));
  assert.equal(onSeven.length, 1, `paraphrases on one line take one verify slot (got ${onSeven.length})`);
  for (const t of ["Unknown config key is skipped", "An unrecognised config key", "config key naming no setting"]) {
    assert.ok(onSeven[0].prompt.includes(t), `the verify prompt lists every reported title: ${t}`);
  }
  assert.ok(/name[^.]*which of the reports/.test(onSeven[0].prompt), "a merged finding's verifier is asked to name the report its evidence demonstrates");
  const merged = out.confirmed.find((f) => f.line === 7);
  assert.equal(merged.severity, "high", "the strongest severity is kept");
  assert.equal(merged.titles.length, 3, "every distinct title is carried");
  assert.deepEqual(merged.alsoFoundBy.slice().sort(), ["adr-conformance-reviewer", "silent-failures"], "every co-reporter once, never the original");
  assert.equal(out.confirmed.filter((f) => f.line === undefined).length, 2, "two different line-less findings stay two");
  n++;
}
```

**Edit 2** — `.claude/rules/cbk-conventions-reference.md` § Verification: insert these lines immediately before the line `echo "verification: kit sub-block complete"` (a kit-sub-block check at the sentinel; the sentinel line itself is unchanged):

```bash
# Dedup keys on file and line, and a merged finding is triaged by the report its verifier named (context-builder-kit#72 item 2).
{ grep -qF 'keyed on file and line (and on the normalized title only when a finding names no line)' .claude/rules/pr-review.md && grep -qF 'the caller triages that report' .claude/rules/pr-review.md; } || { echo "pr-review.md invariant (3) does not key dedup on file and line, or does not triage a merged finding by the report its verifier named"; exit 1; }
absent grep -n "keyed on file, line and normalized titl[e]" .claude/rules/pr-review.md
```

- [ ] **Step 2: Run it against the unfixed script (red)**

Run: `node .claude/workflows/tests/review-sweep-accounting.mjs 2>&1 | grep -m1 AssertionError; echo "exit=${PIPESTATUS[0]}"`
Expected:

```
AssertionError [ERR_ASSERTION]: paraphrases on one line take one verify slot (got 3)
exit=1
```

Record the AssertionError line in the PR body's red-first table.

The new block check, run on its own:

Run: `bash -c "$(grep -F 'does not key dedup on file and line' .claude/rules/cbk-conventions-reference.md)"; echo "rc=$?"`
Expected:

```
pr-review.md invariant (3) does not key dedup on file and line, or does not triage a merged finding by the report its verifier named
rc=1
```


- [ ] **Step 3: The fix** — first run `wc -c < .claude/rules/pr-review.md` and note the number.

**Edit 1** — `.claude/workflows/review-sweep.js`. Replace this exact text (verbatim at HEAD, unique in the file):

```js
// Same file:line:title from more than one dimension is ONE finding that keeps
// the STRONGEST severity reported and records who converged — convergence is
// signal for triage, never a penalty (pr-review.md § Three invariants, (3)).
const seen = new Map();
for (const f of raw) {
  const key = `${f.file}:${f.line ?? "?"}:${(f.title ?? "").toLowerCase().replace(/[^a-z0-9]+/g, " ").trim()}`;
  const prior = seen.get(key);
  if (prior) {
    prior.alsoFoundBy.push(f.dimension);
    if ((rank[f.severity] ?? 3) < (rank[prior.severity] ?? 3)) prior.severity = f.severity;
  } else {
    seen.set(key, { ...f, alsoFoundBy: [] });
  }
}
```

with:

```js
// Findings on the same file:line are ONE finding that keeps the STRONGEST
// severity reported, every distinct title and detail, and who converged —
// convergence is signal for triage, never a penalty (pr-review.md § Three
// invariants, (3)). The key has no title: dimensions paraphrase one defect, and a
// title in the key spent a verify slot per paraphrase (a real sweep refuted one
// finding three times — context-builder-kit#72 item 2). A finding with no line
// keeps its title in the key, or every line-less finding in a file would merge.
const norm = (t) => (t ?? "").toLowerCase().replace(/[^a-z0-9]+/g, " ").trim();
const seen = new Map();
for (const f of raw) {
  const key = f.line != null ? `${f.file}:${f.line}` : `${f.file}:?:${norm(f.title)}`;
  const prior = seen.get(key);
  if (prior) {
    if (f.dimension !== prior.dimension && !prior.alsoFoundBy.includes(f.dimension)) prior.alsoFoundBy.push(f.dimension);
    if (!prior.titles.some((t) => norm(t) === norm(f.title))) { prior.titles.push(f.title); prior.details.push(f.detail); }
    if ((rank[f.severity] ?? 3) < (rank[prior.severity] ?? 3)) prior.severity = f.severity;
  } else {
    seen.set(key, { ...f, titles: [f.title], details: [f.detail], alsoFoundBy: [] });
  }
}
```

**Edit 2** — `.claude/workflows/review-sweep.js`. Replace this exact text (verbatim at HEAD, unique in the file):

```js
// Verify agents inherit the session model
```

with:

```js
// A merged finding's verifier sees every report on its line and, when it confirms, names the one its evidence
// demonstrates: one verdict now covers every paraphrase, and the caller triages by the report named, the others
// standing as unverified (pr-review.md § Three invariants, (3)).
// Verify agents inherit the session model
```

**Edit 3** — `.claude/workflows/review-sweep.js`. Replace this exact text (verbatim at HEAD, unique in the file):

```js
Finding (from ${finding.dimension}${finding.alsoFoundBy.length ? `, also flagged by ${finding.alsoFoundBy.join(", ")}` : ""}): "${finding.title}" at ${finding.file}${finding.line ? `:${finding.line}` : ""}. Detail: ${finding.detail}\n\nRead the actual code and any governing rule/ADR it cites. Default to real=false when the failure scenario cannot be demonstrated, an existing guard/test/CI check already covers it, or the finding misreads the code. Confirm real=true only with concrete evidence.`
```

with:

```js
Finding (from ${finding.dimension}${finding.alsoFoundBy.length ? `, also flagged by ${finding.alsoFoundBy.join(", ")}` : ""}) at ${finding.file}${finding.line ? `:${finding.line}` : ""}:\n${finding.titles.length > 1 ? `${finding.titles.length} reports on this line — paraphrases of one defect, or several defects:\n` : ""}${finding.titles.map((t, i) => `- "${t}". Detail: ${finding.details[i]}`).join("\n")}\n\nRead the actual code and any governing rule/ADR it cites. Default to real=false when the failure scenario cannot be demonstrated, an existing guard/test/CI check already covers it, or the finding misreads the code. Confirm real=true only with concrete evidence${finding.titles.length > 1 ? ", and when you do, name in your reasoning which of the reports the evidence demonstrates" : ""}.`
```

**Edit 4** — `.claude/rules/pr-review.md`. Replace this exact text (verbatim at HEAD, unique in the file):

```markdown
(3) **Every finding is deduplicated before it is verified**, keyed on file, line and normalized title, keeping the strongest severity reported and carrying the dimensions that independently converged — convergence is signal for triage, not a duplicate to pay for twice.
```

with:

```markdown
(3) **Every finding is deduplicated before it is verified**, keyed on file and line (and on the normalized title only when a finding names no line), keeping the strongest severity reported and carrying every distinct title and the dimensions that independently converged — convergence is signal for triage, not a duplicate to pay for twice; with the title in the key, every paraphrase paid for its own verification (a real sweep refuted one finding three times). A merged finding has one verdict: its verifier names the report its evidence demonstrates, the caller triages that report, and the merged finding's other titles stand as unverified.
```

- [ ] **Step 4: Run the fixture and the gate**

Run: `node .claude/workflows/tests/review-sweep-accounting.mjs`
Expected: `review-sweep accounting: meta + body parse, 33 scenarios OK`, exit 0.

Run: `wc -c < .claude/rules/pr-review.md` and subtract the Step 3 pre-change reading.
Expected: the file grew by exactly **375 bytes** (the always-loaded ledger, D50/D59; record it for the PR body).

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`
Expected: `always-loaded total: <N> bytes` where N is the previous commit's total plus 375, then `verification: kit sub-block complete`, `verification: done`, `exit=0` — exactly these four lines, no `WARN` and no `VIOLATION` (the fixture lines V1 added to the block's tail are filtered out, so the check does not depend on their position).

No hook is touched by this task, so there is no `bash -n` step. The existing bound scenarios (1, 10–12, 16) stay green: the reporter set a bound charges is unchanged.

- [ ] **Step 5: Commit**

```bash
git add .claude/workflows/tests/review-sweep-accounting.mjs \
  .claude/rules/cbk-conventions-reference.md \
  .claude/workflows/review-sweep.js \
  .claude/rules/pr-review.md
git commit -F - <<'EOF'
feat(review-sweep): V7 — dedup on file and line, carrying every title

Dedup keyed on file:line:title, so three dimensions paraphrasing one defect took three
verify slots. The key is now file:line (the normalized title only when a finding names no
line); a merged finding keeps the strongest severity, every distinct title and detail, and
each co-reporter once. Its verifier sees every report and names the one its evidence
demonstrates; invariant (3) says the caller triages that report and the other titles stand
as unverified. Scenario 26 was red first; two block checks keep the wording.

Trace rows closed:
- #72/body/2 — paraphrased duplicates each take a verify slot (dedup on file+line)
- critic/21 (part: scenario 26)

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

### Task V7.4: Finders and verifiers stay read-only (#72/body/4 code half, critic/21 part; D46)

**Files:**
- Modify: `.claude/workflows/review-sweep.js` (new `READ_ONLY` constant above `findOnce`; both prompts)
- Modify: `.claude/workflows/tests/review-sweep-accounting.mjs` (scenario 27)

**Interfaces:**
- Consumes: V5's `orchestration.md` § Fan-out discipline bullet that begins **"Read-only agents stay read-only."** (handed out from #72/body/4); the new comment cites that section.
- Produces: `const READ_ONLY` — the sentence `Never modify the working tree — not even to restore a file afterwards. To probe (run code, try a patch), copy what you need into a scratch directory and give it its own build cache.` — in every find prompt (after the focus or standard-discipline text) and at the end of every verify prompt.

- [ ] **Step 0: Precondition — V5's rule bullet has landed**

Run: `command grep -F -- '- **Read-only agents stay read-only.** A finder, verifier or judge never modifies the working tree, not even to restore a file afterwards' .claude/rules/orchestration.md | command grep -cF 'Every find, verify and judge prompt carries the clause.'`
Expected: `1` — one line of `orchestration.md` is V5.6's bullet exactly as V5 writes it (its opening and its closing sentence on the same line; V5's plan, Task V5.6, replacement 5). If `0`, stop: the comment below would cite a rule that is not there, or one worded differently; reconcile with V5 first.

- [ ] **Step 1: Write the failing scenario**

**Edit 1** — `.claude/workflows/tests/review-sweep-accounting.mjs`. Replace this exact text (created by V7.3; not at HEAD — verbatim and unique once that task has landed):

```js
  assert.equal(out.confirmed.filter((f) => f.line === undefined).length, 2, "two different line-less findings stay two");
  n++;
}
```

with:

```js
  assert.equal(out.confirmed.filter((f) => f.line === undefined).length, 2, "two different line-less findings stay two");
  n++;
}

// 27 — finders and verifiers are told never to modify the working tree: a probe runs on a copy (context-builder-kit#72
//      item 4 — an agent edited a tracked file in place and restored it with its old mtime, and a build tool then
//      judged a stale artifact fresh).
{
  const { calls } = await scenario("read-only prompts", {
    args: { files: ["a"], finders: [{ key: "ratio-bounds", prompt: "Check every ratio." }] }, roster: rosterOK,
    findings: { "code-review": { findings: [F("a", 1, "x", "high")] } }, verdict: real,
  });
  const dispatched = calls.filter((c) => c.label.startsWith("find:") || c.label.startsWith("verify:"));
  assert.ok(dispatched.some((c) => c.label.startsWith("verify:")) && dispatched.some((c) => c.label === "find:ratio-bounds"));
  for (const c of dispatched) assert.match(c.prompt, /never modify the working tree/i, `${c.label} carries the read-only clause`);
  n++;
}
```

- [ ] **Step 2: Run it against the unfixed script (red)**

Run: `node .claude/workflows/tests/review-sweep-accounting.mjs 2>&1 | grep -m1 AssertionError; echo "exit=${PIPESTATUS[0]}"`
Expected:

```
AssertionError [ERR_ASSERTION]: find:code-review carries the read-only clause
exit=1
```

Record the AssertionError line in the PR body's red-first table.

- [ ] **Step 3: The fix**

**Edit 1** — `.claude/workflows/review-sweep.js`. Replace this exact text (verbatim at HEAD, unique in the file):

```js
const findOnce = (dim, effort = FIND_EFFORT, retry = false) =>
```

with:

```js
// Read-only agents stay read-only (orchestration.md § Fan-out discipline): an agent that edited a tracked file and
// restored it with its old mtime left a build tool judging a stale artifact fresh, so a finder or verifier that wants
// to probe works on a copy (context-builder-kit#72 item 4). Every find and verify prompt carries the clause.
const READ_ONLY = "Never modify the working tree — not even to restore a file afterwards. To probe (run code, try a patch), copy what you need into a scratch directory and give it its own build cache.";

const findOnce = (dim, effort = FIND_EFFORT, retry = false) =>
```

**Edit 2** — `.claude/workflows/review-sweep.js`. Replace this exact text (created by V7.2's Edit 3; not at HEAD — verbatim and unique once that task has landed):

```js
: "Apply your standard review discipline. "}Respect the exclusion list
```

with:

```js
: "Apply your standard review discipline. "}${READ_ONLY} Respect the exclusion list
```

**Edit 3** — `.claude/workflows/review-sweep.js`. Replace this exact text (created by V7.3's Edit 3; not at HEAD — verbatim and unique once that task has landed):

```js
name in your reasoning which of the reports the evidence demonstrates" : ""}.`
```

with:

```js
name in your reasoning which of the reports the evidence demonstrates" : ""}. ${READ_ONLY}`
```

- [ ] **Step 4: Run the fixture and the gate**

Run: `node .claude/workflows/tests/review-sweep-accounting.mjs`
Expected: `review-sweep accounting: meta + body parse, 34 scenarios OK`, exit 0.

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`
Expected: `always-loaded total: <N> bytes` where N is the previous commit's total unchanged, then `verification: kit sub-block complete`, `verification: done`, `exit=0` — exactly these four lines, no `WARN` and no `VIOLATION` (the fixture lines V1 added to the block's tail are filtered out, so the check does not depend on their position).

No hook is touched by this task, so there is no `bash -n` step.

- [ ] **Step 5: Commit**

```bash
git add .claude/workflows/tests/review-sweep-accounting.mjs \
  .claude/workflows/review-sweep.js
git commit -F - <<'EOF'
feat(review-sweep): V7 — finders and verifiers never modify the working tree

Nothing told a finder or verifier not to touch the tree; an edit restored with its old
mtime once left a build tool judging a stale artifact fresh. Every find and verify prompt
now carries READ_ONLY: never modify the working tree, probe on a copy with its own build
cache. Scenario 27 was red first. The rule bullet itself is V5's (orchestration.md
§ Fan-out discipline), cited here.

Trace rows closed:
- #72/body/4 — nothing tells a finder or verifier not to touch the tree (read-only agents) (code half; rule half landed by V5)
- critic/21 (part: scenario 27)

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

### Task V7.5: Every finder's brief ends on the Sonnet 5.5 think-first line (#69/c5881157875/1c code half, critic/21 part; D46, D49)

**Files:**
- Modify: `.claude/workflows/review-sweep.js` (new `FIND_TAIL` constant above `findOnce`; the find prompt's end)
- Modify: `.claude/workflows/tests/review-sweep-accounting.mjs` (scenario 28)

**Interfaces:**
- Consumes: `.claude/rules/workflows.md` § Subagent dispatch (cited; V5 edits that section's body, not its heading). V5's `orchestration-reference.md` finder bullet, if it says the line rides `review-sweep.js`'s prompt, becomes true with this commit.
- Produces: `const FIND_TAIL` — `You cannot ask the caller anything, and nobody will answer a check-in: finish the review of every listed file before you return. Think the problem through before you answer.` — the last text of every find prompt, first pass and retry, toolkit, project-reviewer and caller finders alike. Verify prompts do not carry it (V7-D3).

- [ ] **Step 0: Preconditions — the cited heading exists, and the quotations are live today**

Run: `grep -c '^## Subagent dispatch$' .claude/rules/workflows.md`
Expected: `1`.

Run (the platform quotations, fetched raw and matched with `grep -F`, typographic apostrophes normalised):

```bash
u=https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5-5.md
page=$(curl -sL "$u" | sed "s/[’‘]/'/g")
for q in "At \`low\` and \`medium\`, on long agentic tasks, it's more likely to stop and check in with the user before it finishes" \
         "the model often answers without thinking first, particularly at \`low\` and \`medium\` effort" \
         "Think the problem through before you answer." \
         "With adaptive thinking, add this line to the end of your system prompt"; do
  printf '%s\n' "$page" | grep -cF -- "$q"
done
curl -sL https://code.claude.com/docs/en/model-config.md | grep -cF '| Anthropic API | Opus 5.5 | Sonnet 5.5 |'
```
Expected: five lines, each `1` (verified 2026-09-30 at planning time). If any of the first four prints `0`, the page
changed: re-read § Calibrate effort and § Reasoning tasks with JSON output, correct the quotation in the comment below
to the live text, and re-date it; if the remedy line itself is gone, stop and surface. If the fifth prints `0`, re-read
the model-config alias table and correct the comment's first sentence to what `sonnet` resolves to today.

- [ ] **Step 1: Write the failing scenario**

**Edit 1** — `.claude/workflows/tests/review-sweep-accounting.mjs`. Replace this exact text (created by V7.4; not at HEAD — verbatim and unique once that task has landed):

```js
  for (const c of dispatched) assert.match(c.prompt, /never modify the working tree/i, `${c.label} carries the read-only clause`);
  n++;
}
```

with:

```js
  for (const c of dispatched) assert.match(c.prompt, /never modify the working tree/i, `${c.label} carries the read-only clause`);
  n++;
}

// 28 — every finder's brief is complete and ends on the Sonnet 5.5 guide's think-first line: a finder at medium effort
//      cannot get an answer to a check-in, and on a JSON answer it may skip thinking (the guide's remedy line, verbatim).
{
  let attempt = 0;
  const { calls } = await scenario("finder tail", {
    args: { files: ["a"], finders: [{ key: "ratio-bounds", prompt: "Check every ratio." }] }, roster: rosterOK,
    findings: { "code-review": () => { attempt += 1; return attempt === 1 ? null : { findings: [] }; } }, verdict: () => null,
  });
  const finds = calls.filter((c) => c.label.startsWith("find:"));
  assert.ok(finds.some((c) => c.label.endsWith(":retry")) && finds.some((c) => c.label === "find:ratio-bounds"), "the scenario reaches a retry and a caller finder");
  for (const c of finds) {
    assert.ok(c.prompt.includes("nobody will answer a check-in"), `${c.label} says a check-in gets no answer`);
    assert.ok(c.prompt.endsWith("Think the problem through before you answer."), `${c.label} ends on the think-first line`);
  }
  n++;
}
```

- [ ] **Step 2: Run it against the unfixed script (red)**

Run: `node .claude/workflows/tests/review-sweep-accounting.mjs 2>&1 | grep -m1 AssertionError; echo "exit=${PIPESTATUS[0]}"`
Expected:

```
AssertionError [ERR_ASSERTION]: find:code-review says a check-in gets no answer
exit=1
```

Record the AssertionError line in the PR body's red-first table.

- [ ] **Step 3: The fix** — if Step 0 ran on a later day than 2026-09-30, change each `read 2026-09-30` below to that day.

**Edit 1** — `.claude/workflows/review-sweep.js`. Replace this exact text (verbatim at HEAD, unique in the file):

```js
const findOnce = (dim, effort = FIND_EFFORT, retry = false) =>
```

with:

```js
// A finder's brief is complete and ends on the think-first line. Finders are pinned `sonnet`, which resolves to
// Sonnet 5.5 on the Anthropic API and to an older Sonnet on some other providers
// (https://code.claude.com/docs/en/model-config, read 2026-09-30). The Sonnet 5.5 prompting guide
// (https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5-5, read
// 2026-09-30): "At `low` and `medium`, on long agentic tasks, it's more likely to stop and check in with the user
// before it finishes", and on a JSON answer to a task that needs working out "the model often answers without
// thinking first, particularly at `low` and `medium` effort". Finders run at FIND_EFFORT (`medium`) and answer in a
// schema. A subagent cannot get an answer to a check-in (workflows.md § Subagent dispatch), so the brief says so;
// with adaptive thinking the guide puts its remedy line at the end of a system prompt, and a finder's brief is the
// only prompt this script writes for it, so the line ends that brief.
const FIND_TAIL = "You cannot ask the caller anything, and nobody will answer a check-in: finish the review of every listed file before you return. Think the problem through before you answer.";

const findOnce = (dim, effort = FIND_EFFORT, retry = false) =>
```

**Edit 2** — `.claude/workflows/review-sweep.js`. Replace this exact text (verbatim at HEAD, unique in the file):

```js
do not classify. Rank most-severe first.`,
```

with:

```js
do not classify. Rank most-severe first. ${FIND_TAIL}`,
```

- [ ] **Step 4: Run the fixture and the gate**

Run: `node .claude/workflows/tests/review-sweep-accounting.mjs`
Expected: `review-sweep accounting: meta + body parse, 35 scenarios OK`, exit 0.

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`
Expected: `always-loaded total: <N> bytes` where N is the previous commit's total unchanged, then `verification: kit sub-block complete`, `verification: done`, `exit=0` — exactly these four lines, no `WARN` and no `VIOLATION` (the fixture lines V1 added to the block's tail are filtered out, so the check does not depend on their position).

No hook is touched by this task, so there is no `bash -n` step.

- [ ] **Step 5: Commit**

```bash
git add .claude/workflows/tests/review-sweep-accounting.mjs \
  .claude/workflows/review-sweep.js
git commit -F - <<'EOF'
feat(review-sweep): V7 — finder briefs end on the Sonnet 5.5 think-first line

Finders run on sonnet at medium and answer in a schema. The Sonnet 5.5 prompting guide
(read 2026-09-30) says that at low and medium the model is more likely to stop and check in
on long agentic tasks and often answers a JSON task without thinking first; its remedy is
"Think the problem through before you answer." A finder cannot get an answer to a check-in,
so every find prompt now ends on FIND_TAIL, which says so and closes on the guide's line.
Scenario 28 was red first.

Trace rows closed:
- #69/c5881157875/1c (code half: the finder prompt line; the rule text is V5's)
- critic/21 (part: scenario 28 — with V7.1–V7.4 the row is closed)

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

### Task V7.6: An interrupted floor or sweep is re-run fresh (#72/body/5; D46)

**Files:**
- Modify: `.claude/rules/pr-review.md` (§ Three invariants, invariant (2); § Reviewer precedent memory)
- Modify: `.claude/rules/cbk-conventions-reference.md` (§ Verification, one kit-sub-block check)

**Interfaces:**
- Consumes: V7.3's invariant (3) text follows the invariant (2) sentence; this task's anchor ends at `(3)` and does not include V7.3's words.
- Produces: the sentence `An interrupted or stopped floor or sweep is re-run fresh: none of its partial output is used, and reviewer memory it wrote is discarded, never committed.` and its pointer from § Reviewer precedent memory, `(§ Three invariants, (2))`. The three reviewers' `## Writing memory` copies are not touched (the block diffs them).

- [ ] **Step 1: Write the block check**

**Edit 1** — `.claude/rules/cbk-conventions-reference.md` § Verification: insert these lines immediately before the line `echo "verification: kit sub-block complete"` (a kit-sub-block check at the sentinel; the sentinel line itself is unchanged):

```bash
# An interrupted floor or sweep is re-run fresh, and reviewer memory it wrote is discarded (context-builder-kit#72 item 5).
{ grep -qF 'An interrupted or stopped floor or sweep is re-run fresh' .claude/rules/pr-review.md && grep -qF 'memory an interrupted run wrote is discarded' .claude/rules/pr-review.md; } || { echo "pr-review.md does not say an interrupted floor or sweep is re-run fresh with its reviewer memory discarded"; exit 1; }
```

- [ ] **Step 2: Run the gate against the unfixed text (red)**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`
Expected:

```
pr-review.md does not say an interrupted floor or sweep is re-run fresh with its reviewer memory discarded
verification: block exited 1
exit=1
```

Record the first line in the PR body's red-first table.

- [ ] **Step 3: The change** — first run `wc -c < .claude/rules/pr-review.md` and note the number.

**Edit 1** — `.claude/rules/pr-review.md`. Replace this exact text (verbatim at HEAD, unique in the file):

```markdown
is surfaced as unverified, not silently dropped — before the review pass is treated as complete. (3)
```

with:

```markdown
is surfaced as unverified, not silently dropped — before the review pass is treated as complete. An interrupted or stopped floor or sweep is re-run fresh: none of its partial output is used, and reviewer memory it wrote is discarded, never committed. (3)
```

**Edit 2** — `.claude/rules/pr-review.md`. Replace this exact text (verbatim at HEAD, unique in the file):

```markdown
Memory updates ride the commit the review produced, never a separate commit.
```

with:

```markdown
Memory updates ride the commit the review produced, never a separate commit; memory an interrupted run wrote is discarded (§ Three invariants, (2)).
```

- [ ] **Step 4: Run the fixture and the gate**

Run: `node .claude/workflows/tests/review-sweep-accounting.mjs`
Expected: `review-sweep accounting: meta + body parse, 35 scenarios OK`, exit 0.

Run: `wc -c < .claude/rules/pr-review.md` and subtract the Step 3 pre-change reading.
Expected: the file grew by exactly **227 bytes** (the always-loaded ledger, D50/D59; record it for the PR body).

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`
Expected: `always-loaded total: <N> bytes` where N is the previous commit's total plus 227, then `verification: kit sub-block complete`, `verification: done`, `exit=0` — exactly these four lines, no `WARN` and no `VIOLATION` (the fixture lines V1 added to the block's tail are filtered out, so the check does not depend on their position).

No hook is touched by this task, so there is no `bash -n` step.

- [ ] **Step 5: Commit**

```bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/rules/pr-review.md
git commit -F - <<'EOF'
docs(pr-review): V7 — an interrupted floor or sweep is re-run fresh

Invariant (2) covered a failed agent but not an interrupted or stopped run. It now says the
run is re-run fresh, none of its partial output is used, and reviewer memory it wrote is
discarded, never committed; § Reviewer precedent memory points at it. A block check keeps
both sentences.

Trace rows closed:
- #72/body/5 — an interrupted floor or sweep

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

### Task V7.7: A post-floor delta gets one verification workflow, never a second floor (#74/body/1)

**Files:**
- Modify: `.claude/rules/pr-review.md` (§ The floor, the **Once.** paragraph — appended after its parenthetical)
- Modify: `.claude/rules/cbk-conventions-reference.md` (§ Verification, one kit-sub-block check)

**Interfaces:**
- Consumes: `cbk-conventions.md` § Branch naming (cited by heading; V9 later rewrites the issue-less paragraph under it and keeps the heading).
- Produces: the rule text recorded on the existing `## Review gate` lines as *not a second floor* — no fourth gate line (settled call). V9's D54 rewrite of the issue-less paragraph reads consistently with it (see § Handed to other clusters).

- [ ] **Step 0: Precondition** — Run: `grep -c '^## Branch naming$' .claude/rules/cbk-conventions.md`. Expected: `1`.

- [ ] **Step 1: Write the block check**

**Edit 1** — `.claude/rules/cbk-conventions-reference.md` § Verification: insert these lines immediately before the line `echo "verification: kit sub-block complete"` (a kit-sub-block check at the sentinel; the sentinel line itself is unchanged):

```bash
# A post-floor delta is checked by one verification workflow, never a second floor (context-builder-kit#74 item 1).
{ grep -qF 'never a second floor and never a series of them' .claude/rules/pr-review.md && grep -qF '*not a second floor*' .claude/rules/pr-review.md; } || { echo "pr-review.md § The floor › Once lacks the one-verification-workflow rule"; exit 1; }
```

- [ ] **Step 2: Run the gate against the unfixed text (red)**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`
Expected:

```
pr-review.md § The floor › Once lacks the one-verification-workflow rule
verification: block exited 1
exit=1
```

Record the first line in the PR body's red-first table.

- [ ] **Step 3: The change** — first run `wc -c < .claude/rules/pr-review.md` and note the number. The appended sentences are the issue's rule text verbatim (context-builder-kit#74 item 1), without its citation (V7-D4).

**Edit 1** — `.claude/rules/pr-review.md`. Replace this exact text (verbatim at HEAD, unique in the file):

```markdown
saw the floor twice and four verification workflows on one drafted artifact; the operator's rule is once.)*
```

with:

```markdown
saw the floor twice and four verification workflows on one drafted artifact; the operator's rule is once.)* Short of asking for the floor again — which only an explicit request does — when the operator wants a delta checked before the flip, or an issue-less tooling PR has no floor to run (`cbk-conventions.md` § Branch naming), the check is **one** fresh-context verification workflow per delta, never a second floor and never a series of them (the 2026-09-04 run's four were the failure): read-only verifiers at the workhorse tier and `high`, one lens each, refute-by-default, with returned and dropped counts stated, recorded on the `## Review gate` lines as *not a second floor*.
```

- [ ] **Step 4: Run the fixture and the gate**

Run: `node .claude/workflows/tests/review-sweep-accounting.mjs`
Expected: `review-sweep accounting: meta + body parse, 35 scenarios OK`, exit 0.

Run: `wc -c < .claude/rules/pr-review.md` and subtract the Step 3 pre-change reading.
Expected: the file grew by exactly **581 bytes** (the always-loaded ledger, D50/D59; record it for the PR body).

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`
Expected: `always-loaded total: <N> bytes` where N is the previous commit's total plus 581, then `verification: kit sub-block complete`, `verification: done`, `exit=0` — exactly these four lines, no `WARN` and no `VIOLATION` (the fixture lines V1 added to the block's tail are filtered out, so the check does not depend on their position).

No hook is touched by this task, so there is no `bash -n` step.

- [ ] **Step 5: Commit**

```bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/rules/pr-review.md
git commit -F - <<'EOF'
docs(pr-review): V7 — one verification workflow per post-floor delta, never a second floor

§ The floor › Once left two cases open: an operator who wants a delta checked before the
flip, and an issue-less tooling PR with no floor to run. Either gets one fresh-context
verification workflow per delta — read-only verifiers at the workhorse tier and high, one
lens each, refute-by-default, counts stated — recorded on the existing Review gate lines as
"not a second floor". A block check keeps the rule.

Trace rows closed:
- #74/body/1 — a post-floor delta is checked by one verification workflow, never a second floor

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

### Task V7.8: The review layers stay independent (#58/c5901493591/B, #74/body/Cross-reference)

**Files:**
- Modify: `.claude/rules/pr-review-reference.md` (§ Anti-patterns, a new subsection before "Describing a review instead of running one")
- Modify: `.claude/rules/cbk-conventions-reference.md` (§ Verification, one kit-sub-block check)

**Interfaces:**
- Consumes: V7.7's rule (the new entry points at `pr-review.md` § The floor).
- Produces: the heading `### ❌ Folding one review layer into another`, stated once; `pr-review.md` § Anti-patterns is already a pointer to this section, so no heading changes there. Path-scoped: no always-loaded cost.

- [ ] **Step 0: The quotation is live** — Run: `gh issue view 33 --repo j4th/context-builder-kit --comments | grep -cF "none of them was the layer that found the previous layer's bug"`. Expected: `1` (a kit-issue comment, matched 2026-09-30).

- [ ] **Step 1: Write the block check**

**Edit 1** — `.claude/rules/cbk-conventions-reference.md` § Verification: insert these lines immediately before the line `echo "verification: kit sub-block complete"` (a kit-sub-block check at the sentinel; the sentinel line itself is unchanged):

```bash
# The review layers stay independent: the anti-pattern is recorded once, in the reference half (context-builder-kit#58 residue B).
grep -q '^### ❌ Folding one review layer into another$' .claude/rules/pr-review-reference.md || { echo "pr-review-reference.md § Anti-patterns lacks 'Folding one review layer into another'"; exit 1; }
```

- [ ] **Step 2: Run the gate against the unfixed text (red)**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`
Expected:

```
pr-review-reference.md § Anti-patterns lacks 'Folding one review layer into another'
verification: block exited 1
exit=1
```

Record the first line in the PR body's red-first table.

- [ ] **Step 3: The change**

**Edit 1** — `.claude/rules/pr-review-reference.md`. Replace this exact text (verbatim at HEAD, unique in the file):

```markdown
### ❌ Describing a review instead of running one
```

with:

```markdown
### ❌ Folding one review layer into another

The floor, the sweep, the flip's auto-review and each `/pr-respond` round are separate layers, and they catch different things because each reads the branch with its own context. On one real PR the floor caught kit-versus-project merge losses, the round-2 sweep caught a silent miss in the round-1 fix, and the flip's auto-review caught that the round-2 fixture never ran — "none of them was the layer that found the previous layer's bug" (context-builder-kit#33). Keep them separate: a bigger combined pass is not a substitute for any of them. It is the same principle as the floor running once with at most one verification workflow per delta (`pr-review.md` § The floor), seen from the other side.

### ❌ Describing a review instead of running one
```

- [ ] **Step 4: Run the fixture and the gate**

Run: `node .claude/workflows/tests/review-sweep-accounting.mjs`
Expected: `review-sweep accounting: meta + body parse, 35 scenarios OK`, exit 0.

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`
Expected: `always-loaded total: <N> bytes` where N is the previous commit's total unchanged, then `verification: kit sub-block complete`, `verification: done`, `exit=0` — exactly these four lines, no `WARN` and no `VIOLATION` (the fixture lines V1 added to the block's tail are filtered out, so the check does not depend on their position).

No hook is touched by this task, so there is no `bash -n` step.

- [ ] **Step 5: Commit**

```bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/rules/pr-review-reference.md
git commit -F - <<'EOF'
docs(pr-review): V7 — anti-pattern: folding one review layer into another

The note #33's closure dropped: the floor, the sweep, the flip's auto-review and each
/pr-respond round each caught what the previous layer missed, so they stay separate. Landed
once, in the reference half's § Anti-patterns, with a block check.

Trace rows closed:
- #58/c5901493591/B — #33's review-layer calibration note landed nowhere
- #74/body/Cross-reference — keep the review layers independent (duplicate of #58/c5901493591/B)

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

### Task V7.9: A family of directories is enumerated on the roster line (#58/c5901493591/R10)

**Files:**
- Modify: `.claude/rules/pr-review.md` (§ Reviewer craft rules, the path-matched-trigger bullet)
- Modify: `.claude/rules/pr-review-reference.md` (§ Authoring a project-local reviewer, the "Path-matched triggers come from usage" bullet)
- Modify: `.claude/rules/cbk-conventions-reference.md` (§ Verification, one kit-sub-block check)

**Interfaces:**
- Consumes: nothing.
- Produces: the rule a project reads when writing a domain reviewer's roster line; it matches the directory-boundary match `review-sweep.js` already does (`f === h || f.startsWith(h + "/")`), which the reference sentence now states.

- [ ] **Step 1: Write the block check**

**Edit 1** — `.claude/rules/cbk-conventions-reference.md` § Verification: insert these lines immediately before the line `echo "verification: kit sub-block complete"` (a kit-sub-block check at the sentinel; the sentinel line itself is unchanged):

```bash
# A family of directories has no prefix form: the rules a project reads when writing its roster line say to enumerate it (context-builder-kit#58 residue R10).
{ grep -qF 'has no prefix form: enumerate each one' .claude/rules/pr-review.md && grep -qF 'by prefix on a directory boundary' .claude/rules/pr-review-reference.md; } || { echo "the roster guidance for a family of directories is missing from pr-review.md's craft rule or pr-review-reference.md § Authoring"; exit 1; }
```

- [ ] **Step 2: Run the gate against the unfixed text (red)**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`
Expected:

```
the roster guidance for a family of directories is missing from pr-review.md's craft rule or pr-review-reference.md § Authoring
verification: block exited 1
exit=1
```

Record the first line in the PR body's red-first table.

- [ ] **Step 3: The change** — first run `wc -c < .claude/rules/pr-review.md` and note the number.

**Edit 1** — `.claude/rules/pr-review.md`. Replace this exact text (verbatim at HEAD, unique in the file):

```markdown
the sweep's roster read matches the changed paths against them, and an unmatchable hint is dropped coverage.
```

with:

```markdown
the sweep's roster read matches the changed paths against them, and an unmatchable hint is dropped coverage. A family of directories (every `<project>-*/` package, say) has no prefix form: enumerate each one.
```

**Edit 2** — `.claude/rules/pr-review-reference.md`. Replace this exact text (verbatim at HEAD, unique in the file):

```markdown
matches changed paths by prefix, and reports a glob or prose hint as dropped coverage.
```

with:

```markdown
matches changed paths by prefix on a directory boundary, and reports a glob or prose hint as dropped coverage. A segment or family pattern (`/^<project>-[^/]+\//`) cannot be written as a prefix, so enumerate every directory it would match, each with its slash — and add a directory to the line when the family grows (context-builder-kit#58).
```

- [ ] **Step 4: Run the fixture and the gate**

Run: `node .claude/workflows/tests/review-sweep-accounting.mjs`
Expected: `review-sweep accounting: meta + body parse, 35 scenarios OK`, exit 0.

Run: `wc -c < .claude/rules/pr-review.md` and subtract the Step 3 pre-change reading.
Expected: the file grew by exactly **100 bytes** (the always-loaded ledger, D50/D59; record it for the PR body).

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`
Expected: `always-loaded total: <N> bytes` where N is the previous commit's total plus 100, then `verification: kit sub-block complete`, `verification: done`, `exit=0` — exactly these four lines, no `WARN` and no `VIOLATION` (the fixture lines V1 added to the block's tail are filtered out, so the check does not depend on their position).

No hook is touched by this task, so there is no `bash -n` step.

- [ ] **Step 5: Commit**

```bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/rules/pr-review.md \
  .claude/rules/pr-review-reference.md
git commit -F - <<'EOF'
docs(pr-review): V7 — enumerate a family of directories on the roster line

The guidance lived only in a review-sweep.js comment. pr-review.md's craft rule now says a
family of directories has no prefix form, and the reference half says the match is on a
directory boundary and to enumerate every directory a family pattern would match, adding one
when the family grows. A block check keeps both.

Trace rows closed:
- #58/c5901493591/R10 — the roster-line 'enumerate a family of directories' guidance lives only in a code comment

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

### Task V7.10: Rough-in re-verifies a consolidation made at the gate (#74/body/2)

**Files:**
- Modify: `.claude/skills/rough-in/references/research-phase.md` (the **spec-verification stage** paragraph under § The verdict-first committed corpus)
- Modify: `.claude/skills/rough-in/references/contract.md` (§ Before the gate)
- Modify: `.claude/skills/rough-in/references/test_cases.md` (Test 9: one success criterion, one failure signal)
- Modify: `.claude/rules/cbk-conventions-reference.md` (§ Verification, one kit-sub-block check)

**Interfaces:**
- Consumes: V5's rule 4 in § Grounding existence claims of the same `research-phase.md` (a different paragraph; the anchor here is the spec-verification paragraph's last sentence, which V5 does not touch).
- Produces: the phrase `is a new draft` in all three rough-in files — the rule in the reference, the pointer in the drafting read (contract-first), the criterion in Test 9 (CLAUDE.md § Working in this repo: a contract edit updates its test cases). `SKILL.md` already routes to both reference files; no new file.

- [ ] **Step 1: Write the block check**

**Edit 1** — `.claude/rules/cbk-conventions-reference.md` § Verification: insert these lines immediately before the line `echo "verification: kit sub-block complete"` (a kit-sub-block check at the sentinel; the sentinel line itself is unchanged):

```bash
# Rough-in: a change made at the gate is a new draft, verified again — stated in research-phase.md, pointed at from the
# contract (the drafting read), and pinned by Test 9 (context-builder-kit#74 item 2).
for f in research-phase contract test_cases; do grep -qF 'is a new draft' .claude/skills/rough-in/references/$f.md || { echo "rough-in references/$f.md does not treat a change made at the gate as a new draft"; exit 1; }; done
```

- [ ] **Step 2: Run the gate against the unfixed text (red)**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`
Expected:

```
rough-in references/research-phase.md does not treat a change made at the gate as a new draft
verification: block exited 1
exit=1
```

Record the first line in the PR body's red-first table.

- [ ] **Step 3: The change** — the rule sentences are the issue's text (context-builder-kit#74 item 2); the evidence sentence is re-authored generic (no project, no commit).

**Edit 1** — `.claude/skills/rough-in/references/research-phase.md`. Replace this exact text (verbatim at HEAD, unique in the file):

```markdown
and **telemetry is verified at its sink** — the dashboard, the log store — never at the emitting call.
```

with:

```markdown
and **telemetry is verified at its sink** — the dashboard, the log store — never at the emitting call. **A change made at the gate is a new draft, and is verified again.** When the operator's review at the gate prompts a consolidation — issues merged, a criterion moved or dropped, counts reshaped — run one more fresh-context verifier on the consolidated set before the one-way commit; the consolidation introduces defects of its own. On a real rough-in, the verifier run on one operator-prompted consolidation found nine defects, and two mattered: counts left with no home, and probe trials mixed into a denominator (context-builder-kit#74 item 2).
```

**Edit 2** — `.claude/skills/rough-in/references/contract.md`. Replace this exact text (verbatim at HEAD, unique in the file):

```markdown
mechanically, and returns defects with a verbatim quote each. Fix, then present. For a high-stakes milestone, generate
two or three contract-first drafts, judge them blind, and synthesize from the winner.
```

with:

```markdown
mechanically, and returns defects with a verbatim quote each. Fix, then present. A change the operator makes at the
gate — issues merged, a criterion moved or dropped, counts reshaped — is a new draft: one more fresh-context verifier
attacks the consolidated set before the one-way commit (`references/research-phase.md` § The verdict-first committed
corpus, the spec-verification stage). For a high-stakes milestone, generate two or three contract-first drafts, judge
them blind, and synthesize from the winner.
```

**Edit 3** — `.claude/skills/rough-in/references/test_cases.md`. Replace this exact text (verbatim at HEAD, unique in the file):

```markdown
- No inheritance summary, gate-question list or provisioning diff appears inside any spec body
```

with:

```markdown
- No inheritance summary, gate-question list or provisioning diff appears inside any spec body
- When the operator's review at the gate reshapes the set (issues merged, a criterion moved or dropped, counts reshaped), the consolidated set is a new draft: one more fresh-context verifier attacks it, and its defects are fixed, before Step 6's one-way commit
```

**Edit 4** — `.claude/skills/rough-in/references/test_cases.md`. Replace this exact text (verbatim at HEAD, unique in the file):

```markdown
- The set is presented unverified, or "verification" is the drafter re-reading its own output
```

with:

```markdown
- The set is presented unverified, or "verification" is the drafter re-reading its own output
- A consolidation made at the gate is committed on the strength of the verifier that ran before it
```

- [ ] **Step 4: Run the fixture and the gate**

Run: `node .claude/workflows/tests/review-sweep-accounting.mjs`
Expected: `review-sweep accounting: meta + body parse, 35 scenarios OK`, exit 0.

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`
Expected: `always-loaded total: <N> bytes` where N is the previous commit's total unchanged, then `verification: kit sub-block complete`, `verification: done`, `exit=0` — exactly these four lines, no `WARN` and no `VIOLATION` (the fixture lines V1 added to the block's tail are filtered out, so the check does not depend on their position).

No hook is touched by this task, so there is no `bash -n` step. Rough-in `SKILL.md` is unchanged, so the 500-line check is unaffected.

- [ ] **Step 5: Commit**

```bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/skills/rough-in/references/research-phase.md \
  .claude/skills/rough-in/references/contract.md \
  .claude/skills/rough-in/references/test_cases.md
git commit -F - <<'EOF'
docs(rough-in): V7 — a change made at the gate is a new draft, verified again

Rough-in's spec-verification stage runs before the gate; an operator-prompted consolidation
at the gate came after it and introduced defects of its own. research-phase.md states the
rule, the contract (the drafting read) points at it, and Test 9 gains the criterion and its
failure signal. A block check keeps all three.

Trace rows closed:
- #74/body/2 — a consolidation the operator prompts at rough-in's gate is re-verified

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

### Task V7.11: `/pr-respond`'s NOT-list agrees with its Step 7 (#64/body)

**Files:**
- Modify: `.claude/commands/pr-respond.md` (§ What `/pr-respond` does NOT do, first bullet — body only; V3 owns the frontmatter and arguments)
- Modify: `.claude/rules/cbk-conventions-reference.md` (§ Verification, two kit-sub-block checks)

**Interfaces:**
- Consumes: V3's edits elsewhere in `pr-respond.md` (frontmatter, `$1` → named argument, the untrusted-input and reference-read lines); the anchored bullet contains no `$1`, so V3 does not change it.
- Produces: the bullet naming the one body edit Step 7 makes (`## Triage — round N`, appended).

- [ ] **Step 1: Write the block checks**

**Edit 1** — `.claude/rules/cbk-conventions-reference.md` § Verification: insert these lines immediately before the line `echo "verification: kit sub-block complete"` (a kit-sub-block check at the sentinel; the sentinel line itself is unchanged):

```bash
# /pr-respond's NOT-list agrees with its Step 7: the body is edited only by appending the round block (context-builder-kit#64).
grep -qF 'edits the description body only by appending the round block' .claude/commands/pr-respond.md || { echo "pr-respond.md's NOT-list contradicts Step 7's round-block append"; exit 1; }
absent grep -n "which is not an edit of the descriptio[n]" .claude/commands/pr-respond.md
```

- [ ] **Step 2: Run the gate against the unfixed text (red)**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`
Expected:

```
pr-respond.md's NOT-list contradicts Step 7's round-block append
verification: block exited 1
exit=1
```

Record the first line in the PR body's red-first table.

- [ ] **Step 3: The change**

**Edit 1** — `.claude/commands/pr-respond.md`. Replace this exact text (verbatim at HEAD, unique in the file):

```markdown
- **Does not modify the PR title or description body** (except by posting the NEW top-level summary comment in Step 7, which is not an edit of the description). If a reviewer asks for description changes, surface and ask whether to make them.
```

with:

```markdown
- **Does not modify the PR title, and edits the description body only by appending the round block** (`## Triage — round N`, Step 7). It never rewrites the original `## Review gate` and `## Triage` blocks, and Step 7's summary is a comment, not a description edit. If a reviewer asks for any other description change, surface and ask whether to make it.
```

- [ ] **Step 4: Run the fixture and the gate**

Run: `node .claude/workflows/tests/review-sweep-accounting.mjs`
Expected: `review-sweep accounting: meta + body parse, 35 scenarios OK`, exit 0.

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`
Expected: `always-loaded total: <N> bytes` where N is the previous commit's total unchanged, then `verification: kit sub-block complete`, `verification: done`, `exit=0` — exactly these four lines, no `WARN` and no `VIOLATION` (the fixture lines V1 added to the block's tail are filtered out, so the check does not depend on their position).

No hook is touched by this task, so there is no `bash -n` step. `pr-respond.md` is not one of the byte-parallel executor pairs, so no template sweep.

- [ ] **Step 5: Commit**

```bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/commands/pr-respond.md
git commit -F - <<'EOF'
fix(pr-respond): V7 — the NOT-list agrees with Step 7's round-block append

The bullet still said /pr-respond never edits the description body, while Step 7 appends a
## Triage — round N block to it. The bullet now says the body is edited only by that append,
never rewriting the original Review gate and Triage blocks. Two block checks keep it.

Trace rows closed:
- #64/body — pr-respond.md 'Does not modify the PR title or description body' contradicts Step 7's `## Triage — round N` append

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

### Task V7.12: The four-class rubric names its classes; an ADR conflict has one class (review/consistency/44; D56)

**Re-checked at planning time — holds.** `pr-review.md` said "exactly one of four classes" over a five-row table (the
gate line counts `A/AwC/S/D/R`), and the Defer row ("Conflicts with an ADR …") and the Reject row ("… contradicts
project rules or an existing ADR") both claimed an ADR-conflicting finding. Re-check once more at execution:
`grep -c "Every finding goes into exactly one of four classes. The Apply" .claude/rules/pr-review.md` → `1`. If `0`, the
finding no longer holds as written: record it under the PR body's "not holding at execution" and skip the task.

**Files:**
- Modify: `.claude/rules/pr-review.md` (§ Triage rubric — the four-class shape: the lead sentence, the Defer and Reject rows)
- Modify: `.claude/rules/cbk-conventions-reference.md` (§ Verification, two kit-sub-block checks)

**Interfaces:**
- Consumes: nothing. The heading `## Triage rubric — the four-class shape` is unchanged, so every "four-class rubric" citation (executor pair, `/pr-respond`, `workflows.md`, the cascade-rule reviewer) stays true (V7-D2).
- Produces: the exclusive split — a finding that asks for what an ADR forbids is **Reject**; a real finding whose fix an ADR or the issue places outside this PR is **Defer**.

- [ ] **Step 1: Write the block checks**

**Edit 1** — `.claude/rules/cbk-conventions-reference.md` § Verification: insert these lines immediately before the line `echo "verification: kit sub-block complete"` (a kit-sub-block check at the sentinel; the sentinel line itself is unchanged):

```bash
# The four-class rubric names its classes and its Apply variant, and an ADR conflict has one class, not two.
grep -qF 'exactly one of four classes — Apply, Surface, Defer, Reject' .claude/rules/pr-review.md || { echo "pr-review.md § Triage rubric does not name its four classes and the Apply-with-care variant"; exit 1; }
absent grep -n "Conflicts with an ADR or with the issue's intentional desig[n]" .claude/rules/pr-review.md
```

- [ ] **Step 2: Run the gate against the unfixed text (red)**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`
Expected:

```
pr-review.md § Triage rubric does not name its four classes and the Apply-with-care variant
verification: block exited 1
exit=1
```

Record the first line in the PR body's red-first table.

- [ ] **Step 3: The change** — first run `wc -c < .claude/rules/pr-review.md` and note the number.

**Edit 1** — `.claude/rules/pr-review.md`. Replace this exact text (verbatim at HEAD, unique in the file):

```markdown
Every finding goes into exactly one of four classes. The Apply class is narrow and substantive;
```

with:

```markdown
Every finding goes into exactly one of four classes — Apply, Surface, Defer, Reject — and an Apply finding is plain **Apply** or **Apply with care**, the variant flagged for scrutiny, which the table gives its own row and the counts (`A/AwC/S/D/R`) keep apart. The Apply class is narrow and substantive;
```

**Edit 2** — `.claude/rules/pr-review.md`. Replace this exact text (verbatim at HEAD, unique in the file):

```markdown
| Conflicts with an ADR or with the issue's intentional design; finding is explicitly listed under the issue's `## Out of scope`. |
```

with:

```markdown
| A real finding whose fix an ADR or the issue's intentional design places outside this PR; finding is explicitly listed under the issue's `## Out of scope`. |
```

**Edit 3** — `.claude/rules/pr-review.md`. Replace this exact text (verbatim at HEAD, unique in the file):

```markdown
| Agent factually misunderstood the codebase or the spec; finding contradicts project rules or an existing ADR. |
```

with:

```markdown
| Agent factually misunderstood the codebase or the spec; the finding asks for what project rules or an existing ADR forbid. |
```

- [ ] **Step 4: Run the fixture and the gate**

Run: `node .claude/workflows/tests/review-sweep-accounting.mjs`
Expected: `review-sweep accounting: meta + body parse, 35 scenarios OK`, exit 0.

Run: `wc -c < .claude/rules/pr-review.md` and subtract the Step 3 pre-change reading.
Expected: the file grew by exactly **253 bytes** (the always-loaded ledger, D50/D59; record it for the PR body).

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`
Expected: `always-loaded total: <N> bytes` where N is the previous commit's total plus 253, then `verification: kit sub-block complete`, `verification: done`, `exit=0` — exactly these four lines, no `WARN` and no `VIOLATION` (the fixture lines V1 added to the block's tail are filtered out, so the check does not depend on their position).

No hook is touched by this task, so there is no `bash -n` step.

- [ ] **Step 5: Commit**

```bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/rules/pr-review.md
git commit -F - <<'EOF'
docs(pr-review): V7 — the four-class rubric names its classes and its Apply variant

The rubric said four classes over five rows, and an ADR conflict matched both Defer and
Reject. The lead sentence now names Apply, Surface, Defer and Reject, with Apply with care
as Apply's flagged variant kept apart in the counts; Defer is a real finding an ADR or the
issue places outside this PR, Reject a finding that asks for what an ADR forbids. Two block
checks keep it.

Trace rows closed:
- review/consistency/44 — 'Four-class' rubric has five rows, and ADR conflicts land in both Defer and Reject

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

### Task V7.13: A docs-only PR may skip the sweep, never the floor (review/claude-code/53; D56, V7-D1)

**Re-checked at planning time — holds.** `pr-review-reference.md` § Anti-patterns was headed "Running review-toolkit on a
docs-only PR" and said "Skip the sweep; the simplify pass is sufficient", and `pr-review.md`'s docs-only exclusion said
"the simplify pass is enough", while § The floor admits no waiver of `pr-review-toolkit:review-pr` but break-glass.
Re-check at execution: `grep -c "the simplify pass is sufficient" .claude/rules/pr-review-reference.md` → `1`. If `0`,
record it as not holding at execution and skip the task.

**Files:**
- Modify: `.claude/rules/pr-review.md` (§ What NOT to flag, the **Docs-only PRs** bullet)
- Modify: `.claude/rules/pr-review-reference.md` (§ Anti-patterns, the docs-only subsection)
- Modify: `.claude/rules/cbk-conventions-reference.md` (§ Verification, two kit-sub-block checks)

**Interfaces:**
- Consumes: § The floor (unchanged).
- Produces: the gate-line form `skipped — docs-only diff` for the sweep; the floor's two lines on a docs-only PR read `ran`, never `waived` unless break-glass. `cbk-conventions.md`'s issue-less-branch "not run — docs-only sweep" example is a different case (no floor exists there) and is V9's region.

- [ ] **Step 1: Write the block checks**

**Edit 1** — `.claude/rules/cbk-conventions-reference.md` § Verification: insert these lines immediately before the line `echo "verification: kit sub-block complete"` (a kit-sub-block check at the sentinel; the sentinel line itself is unchanged):

```bash
# A docs-only PR may skip the sweep, never the floor: neither rule half says the simplify pass alone is enough.
absent grep -nE "the simplify pass is (enoug[h]|sufficien[t])" .claude/rules/pr-review.md .claude/rules/pr-review-reference.md
absent grep -n "Running review-toolkit on a docs-only P[R]" .claude/rules/pr-review-reference.md
```

- [ ] **Step 2: Run the gate against the unfixed text (red)**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`
Expected:

```
VIOLATION (matched above): grep -nE the simplify pass is (enoug[h]|sufficien[t]) .claude/rules/pr-review.md .claude/rules/pr-review-reference.md
verification: block exited 1
exit=1
```

Record the first line in the PR body's red-first table.

- [ ] **Step 3: The change** — first run `wc -c < .claude/rules/pr-review.md` and note the number.

**Edit 1** — `.claude/rules/pr-review.md`. Replace this exact text (verbatim at HEAD, unique in the file):

```markdown
- **Docs-only PRs** — if the diff is entirely under `docs/` or `*.md`, skip the heavy review sweep; the simplify pass is enough. **Not automatically light where the docs are one-way doors** — a cascade artifact, an ADR, the conventions, a rule file: those are reviewed by a human and by the project-local reviewers, and the floor still runs.
```

with:

```markdown
- **Docs-only PRs** — if the diff is entirely under `docs/` or `*.md`, the orchestrated sweep may be skipped, its gate line reading `skipped — docs-only diff`; the floor still runs, both skills invoked (§ The floor). **Not light where the docs are one-way doors** — a cascade artifact, an ADR, the conventions, a rule file: the sweep runs for its project-local reviewers, and a human reviews them too.
```

**Edit 2** — `.claude/rules/pr-review-reference.md`. Replace this exact text (verbatim at HEAD, unique in the file):

```markdown
### ❌ Running review-toolkit on a docs-only PR

If the diff is entirely under `docs/` or matches `*.md`, the toolkit's specialized agents have nothing to chew on. Skip the sweep; the simplify pass is sufficient. The exception — docs that are one-way doors — is stated once, in `pr-review.md` § What NOT to flag, and not restated here.
```

with:

```markdown
### ❌ Running the full sweep on a docs-only PR

If the diff is entirely under `docs/` or matches `*.md`, the sweep's toolkit dimensions and caller-named finders have little code to chew on: skip the sweep and record why on its gate line. The floor is not skipped — `/simplify` and `pr-review-toolkit:review-pr` both run, and waiving the toolkit is a break-glass call, never a docs-only default (`pr-review.md` § The floor). The exception — docs that are one-way doors — is stated once, in `pr-review.md` § What NOT to flag, and not restated here.
```

- [ ] **Step 4: Run the fixture and the gate**

Run: `node .claude/workflows/tests/review-sweep-accounting.mjs`
Expected: `review-sweep accounting: meta + body parse, 35 scenarios OK`, exit 0.

Run: `wc -c < .claude/rules/pr-review.md` and subtract the Step 3 pre-change reading.
Expected: the file grew by exactly **63 bytes** (the always-loaded ledger, D50/D59; record it for the PR body).

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`
Expected: `always-loaded total: <N> bytes` where N is the previous commit's total plus 63, then `verification: kit sub-block complete`, `verification: done`, `exit=0` — exactly these four lines, no `WARN` and no `VIOLATION` (the fixture lines V1 added to the block's tail are filtered out, so the check does not depend on their position).

No hook is touched by this task, so there is no `bash -n` step.

- [ ] **Step 5: Commit**

```bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/rules/pr-review.md \
  .claude/rules/pr-review-reference.md
git commit -F - <<'EOF'
docs(pr-review): V7 — a docs-only PR may skip the sweep, never the floor

The reference half called running the toolkit on a docs-only PR an anti-pattern and the
contract said the simplify pass was enough, contradicting § The floor. A docs-only PR may
skip the orchestrated sweep (gate line: skipped — docs-only diff); both floor skills still
run; one-way-door docs still get the sweep's project-local reviewers and a human. Two block
checks keep the old wording out.

Trace rows closed:
- review/claude-code/53 — Reference file lists 'running review-toolkit on a docs-only PR' as an anti-pattern and says to skip it, contradicting the two-skill floor

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

### Task V7.14: Break-glass documents no flag the executor does not declare (review/consistency/45; D56, D57, V7-D6)

**Re-checked at planning time — holds.** At `643f7ff`, `pr-review.md` § Break-glass override's mechanism 2 is
"`--skip-review` on the slash command. Same effect.", but `grep -rn -- --skip-review .claude` matches only that line:
`finish.md` declares one argument (`argument-hint: <issue-number-or-planner-id>`) and its Preconditions item 4 names
only the `<!-- skip-review-toolkit -->` marker. The master plan's Review Focus 5 gives V3 the decision; V3 runs first.
This task closes whatever V3 left. V3's plan (Task V3.1) makes `/finish` item 4 read `--skip-review` from `$ARGUMENTS`
and says mechanism 2 is then true as written, so **branch A is the expected outcome**; branches B and C stay because
V3's task may land differently from its plan.

**Files (branch C only):**
- Modify: `.claude/rules/pr-review.md` (§ Break-glass override)
- Modify: `.claude/rules/cbk-conventions-reference.md` (§ Verification, one kit-sub-block check)

**Interfaces:**
- Consumes: V3's `/finish` frontmatter (`arguments:`) and its Review Focus 5 test.
- Produces (branch C): one waiver mechanism, the marker, on two surfaces (the issue body or the operator's instructions), and a **Not a flag.** paragraph.

- [ ] **Step 0: Choose the branch**

Run:

```bash
grep -c -- '--skip-review' .claude/commands/finish.md
grep -cF -- '--skip-review` on the slash command. Same effect.' .claude/rules/pr-review.md
awk '/^---$/{c++; next} c==1' .claude/commands/finish.md | grep -E '^(arguments|argument-hint):'
```


- **Branch A** — the first count is ≥ 1: V3 made `/finish` read the flag. Mechanism 2 is now true. No commit: record
  `review/consistency/45` as closed by V3's commit (name its sha) in the PR body, and stop this task.
- **Branch B** — the first count is `0` and the second is `0`: V3 already rewrote mechanism 2 to the operator-instruction
  form. No commit: record it as closed by V3's commit, and stop.
- **Branch C** — the first count is `0` and the second is `1`: continue. The `arguments:` line must name exactly one
  argument (the issue); if it names more, stop and reconcile with V3 — the sentence below says `/finish` declares one.

- [ ] **Step 1 (branch C): Write the block check**

**Edit 1** — `.claude/rules/cbk-conventions-reference.md` § Verification: insert these lines immediately before the line `echo "verification: kit sub-block complete"` (a kit-sub-block check at the sentinel; the sentinel line itself is unchanged):

```bash
# Break-glass: pr-review.md documents no /finish flag the executor does not declare (the waiver is the marker).
if ! grep -qF -- '--skip-review' .claude/commands/finish.md; then absent grep -nF -- '--skip-review` on the slash command' .claude/rules/pr-review.md; fi
```

- [ ] **Step 2: Run the gate against the unfixed text (red)**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`
Expected:

```
VIOLATION (matched above): grep -nF -- --skip-review` on the slash command .claude/rules/pr-review.md
verification: block exited 1
exit=1
```

Record the first line in the PR body's red-first table.

(The line above the VIOLATION line is the matched mechanism-2 line, prefixed with its line number.)

- [ ] **Step 3 (branch C): The change** — first run `wc -c < .claude/rules/pr-review.md` and note the number.

**Edit 1** — `.claude/rules/pr-review.md`. Replace this exact text (verbatim at HEAD, unique in the file):

```markdown
Two mechanisms:

1. **Issue-body / operator-instruction marker**:
```

with:

```markdown
The mechanism:

- **Issue-body / operator-instruction marker**:
```

**Edit 2** — `.claude/rules/pr-review.md`. Replace this exact text (verbatim at HEAD, unique in the file):

```markdown
2. **`/finish` flag** (if the user invoked manually with extra args): `--skip-review` on the slash command. Same effect.

Either path produces the same record:
```

with:

```markdown

**Not a flag.** `/finish` declares one argument, the issue, and parses no option, so a `--skip-review` typed after it is not a mechanism of its own: put the marker, or the waiver and its reason in words, in the instructions beside the command.

Either surface produces the same record:
```

- [ ] **Step 4: Run the fixture and the gate**

Run: `node .claude/workflows/tests/review-sweep-accounting.mjs`
Expected: `review-sweep accounting: meta + body parse, 35 scenarios OK`, exit 0.

Run: `wc -c < .claude/rules/pr-review.md` and subtract the Step 3 pre-change reading.
Expected: the file grew by exactly **125 bytes** (the always-loaded ledger, D50/D59; record it for the PR body).

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`
Expected: `always-loaded total: <N> bytes` where N is the previous commit's total plus 125, then `verification: kit sub-block complete`, `verification: done`, `exit=0` — exactly these four lines, no `WARN` and no `VIOLATION` (the fixture lines V1 added to the block's tail are filtered out, so the check does not depend on their position).

No hook is touched by this task, so there is no `bash -n` step.

- [ ] **Step 5: Commit**

```bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/rules/pr-review.md
git commit -F - <<'EOF'
docs(pr-review): V7 — break-glass is the marker; /finish parses no flag

Mechanism 2 documented a --skip-review flag the executor never declared or read. The waiver
is one marker, in the issue body or the operator's instructions; a "Not a flag" paragraph
says a typed --skip-review is not a mechanism of its own. The block check fires only while
finish.md does not declare the flag.

Trace rows closed:
- review/consistency/45 — Break-glass documents a `/finish --skip-review` flag the executor does not parse

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

### Task V7.15: The review rule cites no STANDARDS heading the template does not emit (review/consistency/40, V7 part; D53, D56)

**Re-checked at planning time — holds.** At `643f7ff`, `pr-review.md:3` says "`docs/STANDARDS.md § Step 7` (or
wherever your project documents the equivalent gate) establishes that automated review runs before any PR moves draft →
ready", and `pr-review-reference.md:142` (§ When to update this file) says "The corresponding entry in
`docs/STANDARDS.md` § PR review process points here". The blueprint's `templates/standards.md` emits neither heading:
its `##` headings are Development Setup, Git Workflow, Code Conventions, Testing Requirements, PR Review Checklist, CI
Pipeline and Unenforced invariants, and none of its sections points at `pr-review.md`. V3's plan hands both lines to V7
(its Coverage row and § To V7: "Repoint both at `pr-review.md` § The floor, or drop them (D53)"). D53 says a citation
points at a heading every target has by construction, so both now name `pr-review.md` § The floor, the kit's own rule,
which every target carries.

V9.4 also lists `pr-review-reference.md:142` and skips it when `command grep -c '§ PR review process points here'
.claude/rules/pr-review-reference.md` prints `0`, which it does once this task lands; V9.4's `absent` check over
`.claude/` then stays green on this file. No V9 task touches `pr-review.md:3`. No other cluster's task changes either
anchor (§ Ownership map: `pr-review.md` outside § The floor's Agent-tool sentence is V7's; V7.8, V7.9 and V7.13 edit
`pr-review-reference.md` only in § Anti-patterns and § Authoring).

**Files:**
- Modify: `.claude/rules/pr-review.md` (line 3, the opening paragraph)
- Modify: `.claude/rules/pr-review-reference.md` (§ When to update this file, its closing sentence)
- Modify: `.claude/rules/cbk-conventions-reference.md` (§ Verification, one kit-sub-block check)

**Interfaces:**
- Consumes: V9.4's skip condition on `pr-review-reference.md:142` (above).
- Produces: neither review-rule half cites `STANDARDS.md § Step N` or `§ PR review process`; both point at
  `pr-review.md` § The floor. One `absent` check keeps them out.

- [ ] **Step 0: Re-check that it still holds (D56)**

Run:

```bash
command grep -cE '^#+ (Step 7|PR review process)' .claude/skills/blueprint/references/templates/standards.md
command grep -cE 'STANDARDS\.md`? § (Step 7|PR review process)' .claude/rules/pr-review.md .claude/rules/pr-review-reference.md
```

Expected:

```
0
.claude/rules/pr-review.md:1
.claude/rules/pr-review-reference.md:1
```

If the first count is not `0`, the template now emits the heading: stop and reconcile (the finding no longer holds as
written). If both of the second pair are `0`, another cluster already repointed them: no commit, record
`review/consistency/40 (pr-review halves)` as closed by that commit (name its sha) in the PR body, and stop this task.
If exactly one is `0`, apply only the other file's edit in Step 3 and adjust Step 4's byte expectation (`pr-review.md`'s
edit is the −55).

- [ ] **Step 1: Write the block check**

**Edit 1** — `.claude/rules/cbk-conventions-reference.md` § Verification: insert these lines immediately before the line `echo "verification: kit sub-block complete"` (a kit-sub-block check at the sentinel; the sentinel line itself is unchanged):

```bash
# The review rule's STANDARDS citations name no heading the blueprint template does not emit (D53): the gate is
# pr-review.md § The floor, which every target carries (review/consistency/40).
absent grep -nE 'STANDARDS\.md`? § (Step [0-9]|PR review proces[s])' .claude/rules/pr-review.md .claude/rules/pr-review-reference.md
```

- [ ] **Step 2: Run the gate against the unfixed text (red)**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`
Expected (the check is the last one before the sentinel, so its failure really is the last block output):

```
VIOLATION (matched above): grep -nE STANDARDS\.md`? § (Step [0-9]|PR review proces[s]) .claude/rules/pr-review.md .claude/rules/pr-review-reference.md
verification: block exited 1
exit=1
```

Record the first line in the PR body's red-first table.

(The two lines above the VIOLATION line are the matched `pr-review.md:3` and `pr-review-reference.md:142` lines, each
prefixed with its file and line number.)

- [ ] **Step 3: The change** — first run `wc -c < .claude/rules/pr-review.md` and note the number.

**Edit 1** — `.claude/rules/pr-review.md`. Replace this exact text (verbatim at HEAD, unique in the file):

```markdown
`docs/STANDARDS.md § Step 7` (or wherever your project documents the equivalent gate) establishes that automated review runs before any PR moves draft → ready; this file is the practical detail
```

with:

```markdown
Automated review runs before any PR moves draft → ready, and § The floor below is that gate; the rest of this file is the practical detail
```

**Edit 2** — `.claude/rules/pr-review-reference.md`. Replace this exact text (verbatim at HEAD, unique in the file):

```markdown
The corresponding entry in `docs/STANDARDS.md` § PR review process points here for the operational detail; that file states the principle, this file states the contract.
```

with:

```markdown
The gate's principle is stated in `pr-review.md` § The floor, a heading every target carries; this half holds the operational detail behind it.
```

- [ ] **Step 4: Run the gate**

Run: `wc -c < .claude/rules/pr-review.md` and subtract the Step 3 pre-change reading.
Expected: the file shrank by exactly **55 bytes** (−55; the always-loaded ledger, D50/D59; record it for the PR body).
`pr-review-reference.md` is path-scoped and does not count.

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|WARN|VIOLATION|verification:'; echo "exit=${PIPESTATUS[0]}"`
Expected: `always-loaded total: <N> bytes` where N is the previous commit's total minus 55, then `verification: kit sub-block complete`, `verification: done`, `exit=0` — exactly these four lines, no `WARN` and no `VIOLATION` (the fixture lines V1 added to the block's tail are filtered out, so the check does not depend on their position).

Run: `command grep -c '§ PR review process points here' .claude/rules/pr-review-reference.md`
Expected: `0` — V9.4's skip condition for this line now fires.

No harness scenario and no hook is touched by this task, so there is no fixture run and no `bash -n` step.

- [ ] **Step 5: Commit**

```bash
git add .claude/rules/cbk-conventions-reference.md \
  .claude/rules/pr-review.md \
  .claude/rules/pr-review-reference.md
git commit -F - <<'EOF'
docs(pr-review): V7 — the review rule cites its own floor, not STANDARDS headings

pr-review.md's opening cited docs/STANDARDS.md § Step 7 and the reference half cited
§ PR review process; the blueprint's STANDARDS template emits neither heading. Both now
point at pr-review.md § The floor, which every target carries (D53). An absent check keeps
the two retired headings out of both halves; it was red first. pr-review.md shrinks 55 bytes.

Trace rows closed:
- review/consistency/40 (V7 part: pr-review.md:3, pr-review-reference.md:142; handed from V3)

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

## Coverage

| Pack id | Kind | Lands in |
|---|---|---|
| `#72/body/1 — a caller-named finder cannot carry a prompt` | item | V7.2 |
| `#72/body/2 — paraphrased duplicates each take a verify slot (dedup on file+line)` | item | V7.3 |
| `#72/body/3 — the roster read's catch discards why it threw` | item | V7.1 |
| `#72/body/4 — nothing tells a finder or verifier not to touch the tree (read-only agents)` | item | V7.4 (the `READ_ONLY` clause in `review-sweep.js`, scenario 27); **handed to V5** (the `orchestration.md` § Fan-out discipline bullet "Read-only agents stay read-only") |
| `#72/body/5 — an interrupted floor or sweep` | item | V7.6 |
| `#74/body/1 — a post-floor delta is checked by one verification workflow, never a second floor` | item | V7.7 |
| `#74/body/2 — a consolidation the operator prompts at rough-in's gate is re-verified` | item | V7.10 |
| `#74/body/Cross-reference — keep the review layers independent (duplicate of #58/c5901493591/B)` | item | V7.8 (one entry, shared with B) |
| `#58/c5901493591/B — #33's review-layer calibration note landed nowhere` | item | V7.8 |
| `#58/c5901493591/R10 — the roster-line 'enumerate a family of directories' guidance lives only in a code comment` | item | V7.9 |
| ``#64/body — pr-respond.md 'Does not modify the PR title or description body' contradicts Step 7's `## Triage — round N` append`` | item | V7.11 |
| `#69/c5881157875/1c` | handedIn (home V5) | V7.5 — the finder prompt line; the rule and reference text are V5's |
| `release/5` | handedIn (home V10) | V7.1 — `review-sweep.js` (3 sites) and `review-sweep-accounting.mjs` (1 site); V7's other files carry no bare kit-issue citation (the `#42` hits in rough-in `test_cases.md` are illustrative examples, excluded by the item) |
| `critic/21` | critic | V7.1 (logged-throw assertion), V7.2 (stub records the prompt; scenario 25), V7.3 (26), V7.4 (27), V7.5 (28) — each red on its unfixed script, green with its fix |
| `review/consistency/44` | review (unverified) | V7.12 — holds at planning time |
| `review/consistency/45` | review (unverified) | V7.14 — holds at planning time; closed by V3 (branches A/B) or by V7.14 (branch C) |
| `review/claude-code/53` | review (unverified) | V7.13 — holds at planning time |
| `review/consistency/40` | review (handed from V3) | V7.15 — `pr-review.md:3` and `pr-review-reference.md:142` only; holds at planning time. V3.7 lands `simplification.md:3`, `:45` and the logging reviewer's cite; V9.1 the executor pair; V9.4 `testing.md:255` and `plan-mode-prompts.md:60` (and skips `pr-review-reference.md:142` once V7.15 has landed it); V10 `README.md:392` |

## Handed to other clusters

- **V5 — `#72/body/4`, the rule half.** `orchestration.md` § Fan-out discipline gains, after the "Ground existence
  claims" bullet (anchored on text, not a line number), a bullet beginning **"Read-only agents stay read-only."**: a
  finder, verifier or judge never modifies the working tree, not even to restore a file afterwards (an edit restored
  with its old mtime left a build tool judging a stale artifact fresh, and the next gate failed); a probe runs on a copy
  in a scratch directory with its own build cache; a content check cannot certify the tree afterwards (every tracked
  file matched HEAD by content hash while the build state was stale, and only a forced rebuild cleared it), so when an
  agent may have touched the tree, rebuild from clean before the next gate; `review-sweep.js` states the rule in every
  finder's and verifier's prompt. Cite `context-builder-kit#72` item 4, never a sibling issue. If the bullet says
  "judge", V6's judge prompt in `finish-ab.js` should carry the clause too (the settled call "Judges get the read-only
  clause"). V7.4's Step 0 checks the bullet exists.
- **V5 — timing note for `#69/c5881157875/1c`.** If V5's `orchestration-reference.md` "Sonnet 5.5 as a finder" bullet
  says the think-first line rides `review-sweep.js`'s prompt, that statement is true only from V7.5. Either word it as
  the rule ("a finder's brief carries the guide's remedy line") or accept that it runs ahead of the code by four
  clusters within the same PR.
- **V9 — consistency, optional.** `cbk-conventions.md` § Branch naming's issue-less paragraph (V9's D54 rewrite) records
  the floor as *not run*; after V7.7, the stand-in check on an issue-less tooling PR is one verification workflow
  recorded as *not a second floor* (`pr-review.md` § The floor › Once). A pointer from that paragraph to § The floor
  would state the fact once with its other location recorded (`cbk-conventions.md` § Multi-surface facts).
- **V9 — `review/consistency/40`, the overlap on `pr-review-reference.md:142`.** V7.15 lands that line (V3 handed it
  to V7). V9.4 already skips it when `command grep -c '§ PR review process points here'
  .claude/rules/pr-review-reference.md` prints `0`, so no V9 change is needed; V9.4's Step 2 note that lists the line
  among the offenders "at `643f7ff`" is still true of that commit, but at V9's execution the line is already gone.
- **V10 — `release/5`.** V7 qualified the four bare citations in its two workflow files (V7.1); the remaining sites
  belong to their files' owners, and V9's kit-tree check guards them all.

## Not holding at planning time

None. All three unverified review findings in the pack, and the handed-in `review/consistency/40`, were re-checked against the kit tree at `643f7ff` on
2026-09-30 and hold:

- `review/consistency/44` — `pr-review.md` reads "Every finding goes into exactly one of four classes." over a table of
  five rows, and the Defer row ("Conflicts with an ADR or with the issue's intentional design") overlaps the Reject row
  ("finding contradicts project rules or an existing ADR"). → V7.12.
- `review/consistency/45` — `grep -rn -- --skip-review .claude` matches only `pr-review.md`'s mechanism 2; `finish.md`'s
  `argument-hint` is `<issue-number-or-planner-id>` and its Preconditions item 4 names only the marker. → V7.14, which
  still re-checks at execution because V3 may close it first.
- `review/claude-code/53` — `pr-review-reference.md` § Anti-patterns is headed "Running review-toolkit on a docs-only
  PR" and says "Skip the sweep; the simplify pass is sufficient"; `pr-review.md` § The floor says a review pass is
  unsatisfied until both skills have run. → V7.13.
- `review/consistency/40` (V7 part) — `pr-review.md:3` cites `docs/STANDARDS.md § Step 7` and
  `pr-review-reference.md:142` cites `§ PR review process`; `command grep -cE '^#+ (Step 7|PR review process)'
  .claude/skills/blueprint/references/templates/standards.md` prints `0`. → V7.15.

Each is re-checked again at execution (the task's first step), and lands only if it still holds (D56).
