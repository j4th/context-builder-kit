# Harvest 3 · P2 — The review gate is a floor, the sweep is bounded, memory does not fork — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship clusters C3 and C8 of harvest 3 as one draft PR: a `review-sweep.js` that reads its roster at runtime and bounds its fan-out at dedup and verify, the two-skill review floor with its auditable `## Review gate` block on every surface that restates it, two hooks that stop reviewer memory from forking, and the reviewer-memory and hook-authoring disciplines stated once and enforced by the verification block.

**Architecture:** Every change lands on a surface P1 already split (the `pr-review.md` contract keeps the floor; the reference half takes anti-patterns and authoring guidance) and is checked mechanically by the verification block in `cbk-conventions-reference.md § Verification`, which P1 repaired. The sweep is rewritten first (one file, one commit) so the floor commit that follows never describes a body that does not exist. The executor and its bundled template stay byte-parallel. Reviewer bodies gain one identical `## Writing memory` section whose copies are diffed against each other. A stub harness exercises the sweep's accounting without dispatching an agent.

**Tech Stack:** Markdown (skills, rules, agents), bash hooks (`jq`, `git`), a Claude Code Workflow script (plain JS; `node --check` after wrapping the body; a `node` stub harness), `settings.json`, `gh`.

**Spec:** `docs/superpowers/specs/2026-09-06-cascade-kit-harvest-3-design.md` — § C3 (lines 125–155), § C8 (lines 273–297), decisions D19 and D25, § Sequencing, § Verification. Closes #8 #9 #10 #11 #12 #25 #44 #48 #49; addresses #47 items 3–4 (items 1–2 are P4's).

## Global Constraints

- **Branch:** all work on `feat/harvest-3-p2-review-gate`, already created from the head of `feat/harvest-3-p1-self-consistency` (P1, draft PR #54, base `main`); this plan is its first commit. Never commit on `main`: `protect-main-branch.sh` blocks it and judges a compound command on the branch at entry, so `git switch` and a commit are always separate tool calls. If #54 merges while P2 is in progress, rebase (Task 0 Step 2); otherwise the draft PR opens against the P1 branch and is retargeted to `main` after #54 lands (Task 10).
- **Portability invariant:** no project-specific identifiers in `.claude/` content; placeholders stay bracketed (`<TEAM>`, `<ext>`, `YOUR_ANALYZER`).
- **Sanitized only:** the private reference instance is never named. The two public runs may be named only where the open issues already name them (`j4th/echosphere`, `j4th/you-are-hear`); ported material is re-authored generic ("a real github-issues run, 2026-09-05"), never quoted with its project's package paths, issue numbers or commit SHAs.
- **Framework-not-tooling, per file on merits:** the two hooks, the analyzer exemplar and the sweep's stub harness make policies the kit already mandates runnable; they ship beside the existing exemplars.
- **Defer-to-exercised:** where the kit's design and the exercised form differ, the exercised form wins by default; D19 fixes the two places the spec rules otherwise — bounds **3 per dimension / 8 verified**, and a roster-read failure **degrades to the toolkit dimensions and reports dropped coverage** (the exercised script returned an error instead). Two further departures from the exercised form are demonstrated defects, recorded in the PR body: the fork detector registers on `Stop` only (on `SubagentStop` it would block every finishing subagent, which has no hand-off and no `stop_hook_active`), and the verify stage inherits the session model instead of pinning one (the ceiling rule).
- **No unsourced platform claims:** every statement about Claude Code behaviour carries its page — `https://code.claude.com/docs/en/hooks-guide` (§ How hooks work: every event carries `cwd`; all matching hooks run in parallel · § Limitations and troubleshooting › "Stop hook hits the block cap": the eight-consecutive-blocks override and `stop_hook_active`), `https://code.claude.com/docs/en/hooks` ("Handlers run in the current directory with Claude Code's environment"; the `${CLAUDE_PROJECT_DIR}` placeholder references a hook script regardless of the working directory; `permissionDecision` values allow/deny/ask/defer; exit 2 blocks on Stop and SubagentStop; `Stop` takes no matcher, `SubagentStop` matches agent types), `https://code.claude.com/docs/en/sub-agents` (memory scopes `user`/`project`/`local` and their paths; "A subagent starts in the main conversation's current working directory"; the first 200 lines or 25 KB of `MEMORY.md` load into the prompt; the `memory` field has no effect when auto memory is off via `autoMemoryEnabled` or `CLAUDE_CODE_DISABLE_AUTO_MEMORY`; a subagent can spawn subagents up to three layers below the main conversation by default and the Agent tool is withheld at that limit, `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` — so "a dispatched agent cannot dispatch" is never stated as a blanket fact). All verified 2026-09-06; each claim in kit content carries that date and a re-verify note. Tool names a matcher can carry are not enumerated on the hooks pages: `Agent|Workflow` is a dated observation (2026-09-05, a real run), stated as such, and the matcher also carries `Task` so a renamed tool degrades to a false-positive-free no-op rather than silence.
- **Commits:** Conventional Commits, one per task (Task 2 is one commit across three prose surfaces, per the spec; the sweep's meta is the fourth surface and lands with the sweep in Task 1), subject naming the issue(s); trailer `Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>`. No CI-skip marker on any commit.
- **Byte-parallel pair:** `.claude/commands/finish.md` ⇔ the template body below `--- BEGIN TEMPLATE ---` in `.claude/skills/rough-in/references/finish-command.md`. Edit both in the same commit; Task 2 pins the pair in the verification block with the anchored awk the template documents.
- **Every replacement is scripted and asserted.** No hand edits: each edit is a Python `rep(old, new)` with `assert t.count(old) == 1`, or a line-prefix locator with an assertion. Where a replacement string contains backticks it is given inside a fenced block, never inline.
- **Verification-block insertions are plain lines inside the existing single fence.** `cbk-conventions-reference.md § Verification` is one ```` ```bash ```` fence; the extractor stops at the first closing fence, so a nested fence would silently truncate the suite. The blocks below are fenced for readability only — insert their lines without fences. Run the block after every task: extract it, `bash -e` must exit 0 and print `verification: done`. Must-be-absent checks use the block's `absent` helper; multi-command positive checks use `{ …; } || { echo …; exit 1; }` (a bare `a && b` is exempt from `set -e` when `a` fails).
- **The P2 review pass dogfoods the rewritten sweep** (Task 10): the floor (`/simplify`, `pr-review-toolkit:review-pr`, both as skills) plus `review-sweep.js` with its new bounds, project reviewers riding in it. Its `## Review gate` block is the PR's own evidence.

---

### Task 0: Branch, baseline, snapshots

**Files:**
- Read: `.claude/rules/cbk-conventions-reference.md § Verification`
- Snapshot: the surfaces P2 rewrites

- [ ] **Step 1: Be on the P2 branch, with nothing but the plan ahead of P1**

```bash
cd "$(git rev-parse --show-toplevel)"
git switch feat/harvest-3-p2-review-gate 2>/dev/null || git switch -c feat/harvest-3-p2-review-gate feat/harvest-3-p1-self-consistency
git status -sb | head -1
git log --oneline feat/harvest-3-p1-self-consistency..HEAD
```
Expected: `## feat/harvest-3-p2-review-gate…`; the log shows only the plan commit (`docs(plan): harvest 3 P2 …`) — anything else means the branch already has P2 work; stop and read it before continuing.

- [ ] **Step 2: If P1 has already merged, rebase now**

```bash
gh pr view 54 --json state,mergedAt --jq '"\(.state) merged=\(.mergedAt)"'
```
If it prints `MERGED …`: `git fetch origin main && git rebase --onto origin/main feat/harvest-3-p1-self-consistency feat/harvest-3-p2-review-gate`, then `git log --oneline -3` shows `main`'s squash commit beneath the plan commit. If `OPEN`, continue; Task 10 handles the base.

- [ ] **Step 3: Baseline — the suite is green from its P1 home**

```bash
awk '/^## Verification/{p=1} p' .claude/rules/cbk-conventions-reference.md | awk '/^```bash/{c=1;next} /^```/{c=0} c' > /tmp/p2-block.sh
[ -s /tmp/p2-block.sh ] && bash -e /tmp/p2-block.sh > /tmp/p2-baseline.txt 2>&1; echo "suite exit=$?"; grep 'always-loaded total\|verification: done' /tmp/p2-baseline.txt
```
Expected: `suite exit=0`, `always-loaded total: 103737 bytes` (measured at P1's end; record whatever prints), `verification: done`. A red suite here is a P1 regression: stop and surface.

- [ ] **Step 4: Snapshot the surfaces P2 rewrites; confirm the pair and the tools**

```bash
mkdir -p /tmp/p2-pre && cp .claude/rules/pr-review.md .claude/rules/pr-review-reference.md .claude/commands/finish.md .claude/workflows/review-sweep.js .claude/settings.json .claude/skills/rough-in/references/finish-command.md /tmp/p2-pre/ && ls /tmp/p2-pre
diff <(awk '/^--- BEGIN TEMPLATE ---/{flag=1; next} flag' .claude/skills/rough-in/references/finish-command.md) .claude/commands/finish.md && echo "finish copies byte-parallel at baseline"
node --version && jq --version
```
Expected: six files; `finish copies byte-parallel at baseline`; a `node` version (the sweep's checks need it — install it if absent; do not soften the checks) and `jq`.

---

### Task 1: The sweep, rewritten — roster read at runtime, dedup that keeps the strongest report, bounds charged fairly and logged, a returned record, exercised under stubs (#10 #11, #47 item 4)

**Files:**
- Rewrite: `.claude/workflows/review-sweep.js` (whole file, `meta` included)
- Create: `.claude/workflows/tests/review-sweep-accounting.mjs` (stub harness; no agents)
- Modify: `.claude/rules/orchestration.md` — the exemplar sentence in § The role ladder, one bullet in § Fan-out discipline
- Modify: `.claude/rules/cbk-conventions-reference.md § Verification` — the sweep's checks

**Interfaces:**
- Consumes: `params = {base?, files?, reviewers?, finders?: [{key, agentType}], maxPerDimension?, maxVerify?, verifyModel?}`.
- Produces: `{confirmed, refuted, unverified, failedDimensions, droppedCoverage, reviewers, dimensions, bounds, plannedAgents, gateLine}` — `gateLine` is the string `/finish` Step 10 transcribes onto the sweep's `## Review gate` line; `droppedCoverage` names every reviewer or dimension the run did not cover and why.

- [ ] **Step 1: Write the file**

Replace the whole of `.claude/workflows/review-sweep.js` with:

```js
export const meta = {
  name: "review-sweep",
  description: "The focused review that runs beside pr-review-toolkit:review-pr: project reviewers always, plus the finders this diff needs — deduplicated, bounded, adversarially verified. Supplements, never substitutes.",
  whenToUse:
    "Runs BESIDE pr-review-toolkit:review-pr, after /simplify, on a /finish review pass or an ad-hoc pre-PR review when a multi-agent orchestration surface is available (.claude/rules/pr-review.md § The orchestrated sweep supplements; it never substitutes). The floor is that /simplify and review-pr were each actually invoked as skills; this workflow carries any focused or specific review those two do not cover, or do not cover enough, for the diff at hand, and discharges neither. Size it to the diff, not to the session's effort setting: the project-local reviewers always ride in it and return a cheap clean verdict when nothing is in scope; the finders beyond them are named by the caller — none on a small single-surface change, several on a broad or cross-cutting one. The caller scouts the diff and passes {base, files, reviewers?, finders?, maxPerDimension?, maxVerify?, verifyModel?}; when reviewers is omitted the roster is read at runtime from pr-review.md § Project-local agents (never from a copy kept here) and intersected with the changed paths; if that read fails or returns an unusable shape the run degrades to the toolkit dimensions and reports the dropped coverage. Bounds are declared before any dispatch (3 per dimension, 8 verified by default), the planned agent count is logged before the find stage, and anything a bound drops is returned as unverified, never silently. Verify agents inherit the session model (the ceiling) unless verifyModel names a lower tier. Triage waits for the skill and this workflow both and stays with the caller — this workflow finds and verifies; it never classifies.",
  phases: [
    { title: "Roster", detail: "read the authoritative reviewer roster from pr-review.md (degrades on failure)", model: "haiku" },
    { title: "Find", detail: "toolkit dimensions + intersecting project reviewers + caller-named finders", model: "sonnet" },
    { title: "Verify", detail: "adversarial refute-by-default over the deduplicated, bounded set (session model, effort high)" },
  ],
};

const FINDINGS_SCHEMA = {
  type: "object",
  properties: {
    findings: {
      type: "array",
      items: {
        type: "object",
        properties: {
          file: { type: "string" },
          line: { type: "number" },
          title: { type: "string" },
          detail: { type: "string" },
          severity: { type: "string", enum: ["high", "medium", "low"] },
        },
        required: ["file", "title", "detail", "severity"],
      },
    },
  },
  required: ["findings"],
};

const VERDICT_SCHEMA = {
  type: "object",
  properties: {
    real: { type: "boolean" },
    reasoning: { type: "string" },
  },
  required: ["real", "reasoning"],
};

const ROSTER_SCHEMA = {
  type: "object",
  properties: {
    crossCutting: {
      type: "array",
      description: "Reviewer agent names the rule file says run UNCONDITIONALLY",
      items: { type: "string" },
    },
    domain: {
      type: "array",
      description: "Reviewer agent names the rule file says are PATH-MATCHED, with the directory prefixes it names for each (bare paths like src/schema/ — no globs, no prose)",
      items: {
        type: "object",
        properties: {
          name: { type: "string" },
          pathHints: { type: "array", items: { type: "string" } },
        },
        required: ["name", "pathHints"],
      },
    },
    note: { type: "string", description: "Anything ambiguous or missing in the rule file's roster section" },
  },
  required: ["crossCutting", "domain", "note"],
};

const TOOLKIT_DIMENSIONS = [
  { key: "code-review", agentType: "pr-review-toolkit:code-reviewer" },
  { key: "silent-failures", agentType: "pr-review-toolkit:silent-failure-hunter" },
  { key: "comments", agentType: "pr-review-toolkit:comment-analyzer" },
  { key: "test-coverage", agentType: "pr-review-toolkit:pr-test-analyzer" },
  { key: "type-design", agentType: "pr-review-toolkit:type-design-analyzer" },
];

// The runtime may deliver args as a JSON-encoded string; normalize before any
// access (a stringified files array would silently degrade auto-selection).
const params = typeof args === "string" ? JSON.parse(args) : (args ?? {});

const files = params.files ?? [];
const base = params.base ?? "main";
// Bounds are declared BEFORE any dispatch, and they bound the WORK carried into
// verification, not the concurrency the runtime governs (orchestration.md
// § Fan-out discipline). Unbounded per-finding fan-out makes cost a function of
// how noisy the finders were, which inverts the incentive the find stage should
// have (pr-review.md § Fan-outs are bounded). Defaults per the conventions: 3 / 8.
const MAX_PER_DIMENSION = params.maxPerDimension ?? 3;
const MAX_VERIFY = params.maxVerify ?? 8;
const rank = { high: 0, medium: 1, low: 2 };
const droppedCoverage = [];

if (files.length === 0) {
  log("review-sweep: WARNING — no files provided; domain reviewers cannot path-match (recorded as dropped coverage) and finders review the full base-diff");
}

// ---- Roster: read the authoritative list rather than mirroring it here. ----
// Workflow scripts have no filesystem access, so a hardcoded roster in this file
// can only ever be a hand-synced copy — and in real use that copy rotted (a
// reviewer added to pr-review.md went unmirrored for two days). One cheap agent
// reads the rule file at dispatch time instead, so the rule file stays the single
// source of truth it claims to be. A failed or malformed read DEGRADES — the
// toolkit dimensions still run — and the dropped coverage is reported, never hidden.
phase("Roster");
let reviewers = params.reviewers;
const rosterAgents = reviewers ? 0 : 1;
if (!reviewers) {
  const roster = await agent(
    `Read .claude/rules/pr-review.md, section "## Project-local agents to dispatch alongside". Return the reviewer roster EXACTLY as that section defines it — do not infer, do not add reviewers you notice elsewhere in the repo, and do not drop one because it looks irrelevant to the current diff.

Split them by the section's own dispatch rule: reviewers it says run UNCONDITIONALLY (cross-cutting) vs reviewers it says are PATH-MATCHED against changed files (domain). For each path-matched reviewer, return the directory prefixes the section names as its scope, as bare paths (e.g. src/schema/) — never globs, never prose.

If the section is ambiguous, missing, or names a reviewer whose agent file does not exist under .claude/agents/, say so in "note" rather than guessing.`,
    { label: "roster:read-rule-file", phase: "Roster", model: "haiku", schema: ROSTER_SCHEMA },
  );

  if (roster === null || !Array.isArray(roster.crossCutting) || !Array.isArray(roster.domain)) {
    log("review-sweep: DEGRADED — the reviewer roster could not be read from pr-review.md (null or malformed); running the toolkit dimensions only. Project-reviewer coverage is DROPPED for this run: record it on the sweep's `## Review gate` line and dispatch the project reviewers directly.");
    droppedCoverage.push("project-local reviewers (roster read failed)");
    reviewers = [];
  } else {
    if (roster.note) log(`review-sweep: roster note — ${roster.note}`);
    // The roster reader has returned `name (path)` for a name and backticked hints
    // (observed 2026-09-05); agentType and the substring match both need the bare
    // strings — the name is the token before whitespace or a parenthesis.
    const bare = (s) => String(s).replace(/`/g, "").trim().split(/[\s(]/)[0];
    const crossCutting = roster.crossCutting.map(bare);
    const domain = roster.domain.map((d) => ({
      name: bare(d.name),
      pathHints: (Array.isArray(d.pathHints) ? d.pathHints : []).map((h) => String(h).replace(/`/g, "").trim().replace(/^\/+|\/+$/g, "")),
    }));
    // A hint that is a glob or prose can never match a path: that reviewer is
    // dropped coverage, not "not in scope".
    const unusable = domain.filter((d) => !d.pathHints.length || d.pathHints.every((h) => /[*?]|\s/.test(h)));
    if (unusable.length) droppedCoverage.push(`domain reviewers with unmatchable pathHints (empty, glob or prose): ${unusable.map((d) => d.name).join(", ")}`);
    const usable = domain.filter((d) => !unusable.includes(d));
    const matched = usable.filter((d) => files.some((f) => d.pathHints.some((h) => f.includes(h)))).map((d) => d.name);
    const skipped = usable.filter((d) => !matched.includes(d.name)).map((d) => d.name);
    if (skipped.length) {
      log(`review-sweep: domain reviewers not path-matched by this diff: ${skipped.join(", ")}`);
      if (files.length === 0) droppedCoverage.push(`domain reviewers (no changed-file list to match): ${skipped.join(", ")}`);
    }
    reviewers = [...crossCutting, ...matched];
  }
}
log(`review-sweep: project reviewers — ${reviewers.join(", ") || "(none)"}`);

// ---- Find ----
phase("Find");
const finders = (params.finders ?? []).map((f) => ({ key: f.key, agentType: f.agentType }));
const dimensions = [...TOOLKIT_DIMENSIONS, ...reviewers.map((name) => ({ key: name, agentType: name })), ...finders];
const fileList = files.join("\n");
// The planned count is logged BEFORE the find stage (the one roster agent, when
// used, has already run and is counted), so the operator can stop a mis-sized
// run instead of discovering its size from the bill.
const plannedAgents = {
  roster: rosterAgents,
  finders: dimensions.length,
  retries: dimensions.length,
  verifiers: MAX_VERIFY,
  max: rosterAgents + dimensions.length * 2 + MAX_VERIFY,
};
log(`review-sweep: planned agents — ${plannedAgents.roster} roster + ${plannedAgents.finders} finders + up to ${plannedAgents.retries} retries + up to ${plannedAgents.verifiers} verifiers = at most ${plannedAgents.max} (bounds ${MAX_PER_DIMENSION}/dimension, ${MAX_VERIFY} verified)`);

const findOnce = (dim, effort) =>
  agent(
    `Review the branch diff (git diff ${base}...HEAD), restricted to these changed files:\n${fileList}\n\nApply your standard review discipline. Respect the exclusion list in .claude/rules/pr-review.md § "What NOT to flag" — findings only on changed code, no theoretical risks without concrete preconditions. Report every finding you would defend against a reviewer actively trying to refute it, including medium and low confidence — deduplication and a severity-ranked bound happen before verification, and triage happens in the caller: do not classify. Rank most-severe first.`,
    { label: `find:${dim.key}${effort ? ":retry" : ""}`, phase: "Find", agentType: dim.agentType, model: "sonnet", schema: FINDINGS_SCHEMA, ...(effort ? { effort } : {}) },
  );

const firstPass = await parallel(dimensions.map((dim) => () => findOnce(dim)));

// A failed find agent is dropped coverage, not zero findings (pr-review.md); a
// clean verdict ({findings: []}) is a valid result, not a failure. The retry
// pass escalates effort once — "did it not try hard enough?" is the question
// effort answers (orchestration.md § The effort axis).
const failedFirst = dimensions.filter((_d, i) => firstPass[i] === null);
if (failedFirst.length) log(`review-sweep: ${failedFirst.length} find agent(s) returned nothing — retrying once at effort high: ${failedFirst.map((d) => d.key).join(", ")}`);
const retried = await parallel(failedFirst.map((dim) => () => findOnce(dim, "high")));
const results = dimensions.map((dim, i) => firstPass[i] ?? retried[failedFirst.indexOf(dim)] ?? null);

const failedDimensions = dimensions.filter((_d, i) => results[i] === null).map((d) => d.key);
if (failedDimensions.length > 0) {
  log(`review-sweep: WARNING — find agent failed twice for: ${failedDimensions.join(", ")} (coverage DROPPED — record it on the gate line; dispatch these directly)`);
  droppedCoverage.push(...failedDimensions.map((k) => `${k} (find agent failed twice)`));
}

// ---- Dedup + bound: a genuine barrier — dedup needs every finder's output at
// once, and it must happen BEFORE the expensive verify stage. ----
const raw = [];
results.forEach((r, i) => {
  if (!r) return;
  for (const f of r.findings ?? []) raw.push({ ...f, dimension: dimensions[i].key });
});

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
const deduped = [...seen.values()].sort(
  (a, b) => (rank[a.severity] ?? 3) - (rank[b.severity] ?? 3) || b.alsoFoundBy.length - a.alsoFoundBy.length,
);
if (raw.length !== deduped.length) log(`review-sweep: deduplicated ${raw.length} findings to ${deduped.length} (convergence carried as alsoFoundBy; the strongest severity kept)`);

// Per-dimension bound first — a converged finding is charged to the LEAST-LOADED
// dimension that reported it, so convergence never starves the reviewer that
// raised it — then the overall verification bound. Anything a bound drops is
// returned as unverified with its reason — no silent caps (orchestration.md).
const perDim = new Map();
const kept = [];
const overflow = [];
for (const f of deduped) {
  const reporters = [f.dimension, ...f.alsoFoundBy];
  const owner = reporters.reduce((a, b) => ((perDim.get(a) ?? 0) <= (perDim.get(b) ?? 0) ? a : b));
  const n = perDim.get(owner) ?? 0;
  if (n < MAX_PER_DIMENSION) { kept.push(f); perDim.set(owner, n + 1); }
  else overflow.push({ ...f, reason: `over the ${MAX_PER_DIMENSION}-per-dimension bound (${reporters.join(" + ")})` });
}
const toVerify = kept.slice(0, MAX_VERIFY);
overflow.push(...kept.slice(MAX_VERIFY).map((f) => ({ ...f, reason: `over the ${MAX_VERIFY} verification bound` })));
if (overflow.length > 0) {
  log(`review-sweep: BOUND HIT — ${overflow.length} finding(s) returned unverified and NOT dropped: ${overflow.map((f) => `${f.file}:${f.line ?? "?"}`).join(", ")}`);
}
// The planned count above was a ceiling; this is the actual verify fan-out.
log(`review-sweep: carrying ${toVerify.length} of ${deduped.length} deduplicated finding(s) into verification (${dimensions.length} finders ran)`);

// ---- Verify ----
// Verify agents inherit the session model — the ceiling (orchestration.md § The
// ceiling rule: spawned agents match or tier down, never up). A caller in a
// top-tier session may pass verifyModel to tier the verifiers DOWN.
phase("Verify");
const judged = await parallel(
  toVerify.map((finding) => () =>
    agent(
      `Adversarially verify a review finding — your job is to REFUTE it. Finding (from ${finding.dimension}${finding.alsoFoundBy.length ? `, also flagged by ${finding.alsoFoundBy.join(", ")}` : ""}): "${finding.title}" at ${finding.file}${finding.line ? `:${finding.line}` : ""}. Detail: ${finding.detail}\n\nRead the actual code and any governing rule/ADR it cites. Default to real=false when the failure scenario cannot be demonstrated, an existing guard/test/CI check already covers it, or the finding misreads the code. Confirm real=true only with concrete evidence.`,
      { label: `verify:${finding.file}`, phase: "Verify", effort: "high", schema: VERDICT_SCHEMA, ...(params.verifyModel ? { model: params.verifyModel } : {}) },
    ).then((verdict) => ({ ...finding, verdict })),
  ),
);

// A verify agent that failed resolves its finding with a null verdict (the .then
// above still runs), so a null verdict is the failed case too: a half-filled
// record from a failed verifier is dropped coverage, reported as unverified.
const settled = judged.filter((f) => f && f.verdict);
const unverified = [
  ...judged.map((v, i) => (v === null || !v.verdict ? { ...toVerify[i], reason: "verify agent failed" } : null)).filter(Boolean),
  ...overflow,
];
const confirmed = settled.filter((f) => f.verdict.real);
const refuted = settled.filter((f) => !f.verdict.real);

// The run returns its own record so the caller transcribes the audit line
// rather than reconstructing it (pr-review.md § The floor — Record the invocation).
const gateLine = `- \`review-sweep\` — ran: ${dimensions.length} finders + ${toVerify.length} verifiers, ${confirmed.length} confirmed / ${refuted.length} refuted / ${unverified.length} unverified, dropped coverage: ${droppedCoverage.length ? droppedCoverage.join("; ") : "none"}, bounds ${MAX_PER_DIMENSION}/${MAX_VERIFY}`;
log(gateLine);
log("review-sweep: SUPPLEMENTS, NEVER SUBSTITUTES — this run does not satisfy /simplify or pr-review-toolkit:review-pr (pr-review.md § The floor)");

return {
  confirmed,
  refuted,
  unverified,
  failedDimensions,
  droppedCoverage,
  reviewers,
  dimensions: dimensions.map((d) => d.key),
  bounds: { MAX_PER_DIMENSION, MAX_VERIFY },
  plannedAgents,
  gateLine,
};
```

- [ ] **Step 2: Syntax-check with the body wrapped**

A workflow body has a top-level `return`, which `node --check` rejects unwrapped; the awk closes `meta` at the first line that is exactly `};` and wraps the rest:

```bash
awk '/^};$/ && !done {print; print "async function __workflow_body() {"; done=1; next} {print} END {print "}"}' .claude/workflows/review-sweep.js > /tmp/review-sweep-check.mjs && node --check /tmp/review-sweep-check.mjs && echo "parses"
grep -c 'REVIEWER_TRIGGERS' .claude/workflows/review-sweep.js; echo "(expect 0)"
grep -c 'maxPerDimension ?? 3\|maxVerify ?? 8\|planned agents\|gateLine' .claude/workflows/review-sweep.js; echo "(expect 6 — gateLine appears three times)"
```
Expected: `parses`; `0`; `6`.

- [ ] **Step 3: The stub harness — the accounting, exercised without an agent**

Create `.claude/workflows/tests/review-sweep-accounting.mjs`:

```js
#!/usr/bin/env node
// Exercises .claude/workflows/review-sweep.js under stub agent/parallel/log/phase
// (no agent is dispatched) and asserts the invariants pr-review.md states:
// every deduplicated finding lands in exactly one of confirmed/refuted/unverified;
// convergence keeps the strongest severity and is charged to the least-loaded
// reporter; a dropped reviewer is named in droppedCoverage, not only in a log line;
// a null verifier is "unverified", never a crash; a null or malformed roster degrades.
import { readFileSync } from "node:fs";
import assert from "node:assert/strict";

const src = readFileSync(new URL("../review-sweep.js", import.meta.url), "utf8");
const body = src.replace(/^export const meta = \{[\s\S]*?\n\};\n/, "");
const AsyncFunction = Object.getPrototypeOf(async function () {}).constructor;
const run = new AsyncFunction("args", "agent", "parallel", "log", "phase", body);

async function scenario(name, { args, roster, findings, verdict }) {
  const logs = [];
  const agent = async (_prompt, opts = {}) => {
    const label = opts.label ?? "";
    if (label.startsWith("roster:")) return roster;
    if (label.startsWith("find:")) { const key = label.slice(5).replace(/:retry$/, ""); const r = findings[key]; return r === undefined ? { findings: [] } : r; }
    if (label.startsWith("verify:")) return verdict(label.slice(7));
    throw new Error(`unexpected label ${label}`);
  };
  const parallel = async (thunks) => Promise.all(thunks.map(async (t) => { try { return await t(); } catch { return null; } }));
  const out = await run(args, agent, parallel, (m) => logs.push(m), () => {});
  const buckets = [...out.confirmed, ...out.refuted, ...out.unverified].map((f) => `${f.file}:${f.line}:${f.title}`);
  assert.equal(new Set(buckets).size, buckets.length, `${name}: a finding landed in two buckets`);
  return { out, logs };
}

const F = (file, line, title, severity) => ({ file, line, title, detail: "d", severity });
const rosterOK = { crossCutting: ["adr-conformance-reviewer"], domain: [{ name: "schema-reviewer", pathHints: ["src/schema/"] }], note: "" };

// 1 — convergence keeps the strongest severity and is charged to the least-loaded reporter.
{
  const { out } = await scenario("convergence", {
    args: { files: ["src/schema/a.ts"], maxPerDimension: 1, maxVerify: 8 },
    roster: rosterOK,
    findings: {
      "code-review": { findings: [F("a.ts", 1, "unique cr", "medium"), F("a.ts", 9, "shared", "low")] },
      "adr-conformance-reviewer": { findings: [F("a.ts", 9, "shared", "high")] },
    },
    verdict: () => ({ real: true, reasoning: "r" }),
  });
  const shared = [...out.confirmed, ...out.unverified].find((f) => f.line === 9);
  assert.equal(shared.severity, "high", "dedup must keep the strongest severity");
  assert.ok(out.confirmed.some((f) => f.line === 9), "the converged finding is charged to the idle reporter and verified, not dropped by the first reporter's bound");
  assert.equal(out.confirmed.length + out.unverified.length, 2);
}

// 2 — no changed-file list: unmatched domain reviewers are dropped coverage, on the gate line.
{
  const { out } = await scenario("no files", { args: {}, roster: rosterOK, findings: {}, verdict: () => null });
  assert.ok(out.droppedCoverage.some((d) => d.includes("schema-reviewer")), "an unmatched domain reviewer with no file list is dropped coverage");
  assert.ok(out.gateLine.includes("schema-reviewer"), "the gate line names the dropped reviewer");
}

// 3 — a glob or prose hint is unmatchable: dropped coverage even with files.
{
  const { out } = await scenario("unusable hints", {
    args: { files: ["src/x.ts"] },
    roster: { crossCutting: [], domain: [{ name: "glob-reviewer", pathHints: ["src/**/*.ts"] }, { name: "prose-reviewer", pathHints: ["logging and telemetry surfaces"] }], note: "" },
    findings: {}, verdict: () => null,
  });
  assert.ok(out.droppedCoverage.some((d) => d.includes("glob-reviewer") && d.includes("prose-reviewer")));
}

// 4 — a null verifier is unverified, not a crash; overflow is unverified with its reason.
{
  const { out } = await scenario("null verifier + overflow", {
    args: { files: ["a"], maxVerify: 1 },
    roster: rosterOK,
    findings: { "code-review": { findings: [F("a", 1, "one", "high"), F("a", 2, "two", "low")] } },
    verdict: () => null,
  });
  assert.equal(out.confirmed.length + out.refuted.length, 0);
  assert.equal(out.unverified.length, 2);
  assert.ok(out.unverified.some((f) => f.reason === "verify agent failed"));
  assert.ok(out.unverified.some((f) => f.reason.includes("verification bound")));
}

// 5 — a null or malformed roster degrades to the toolkit dimensions and says so.
for (const roster of [null, { crossCutting: "not-an-array" }]) {
  const { out, logs } = await scenario("degrade", { args: { files: ["a"] }, roster, findings: {}, verdict: () => null });
  assert.deepEqual(out.reviewers, []);
  assert.ok(out.droppedCoverage.some((d) => d.includes("roster read failed")));
  assert.ok(logs.some((l) => l.includes("DEGRADED")));
  assert.equal(out.plannedAgents.roster, 1, "the roster agent is counted");
}

// 6 — the planned count includes the roster agent and is logged before any find agent.
{
  const { out, logs } = await scenario("planned", { args: { files: ["a"] }, roster: rosterOK, findings: {}, verdict: () => null });
  assert.equal(out.plannedAgents.max, 1 + out.dimensions.length * 2 + out.bounds.MAX_VERIFY);
  assert.ok(logs.findIndex((l) => l.includes("planned agents")) < logs.findIndex((l) => l.includes("carrying")));
}

console.log("review-sweep accounting: 6 scenarios OK");
```

Run it: `node .claude/workflows/tests/review-sweep-accounting.mjs` — expected `review-sweep accounting: 6 scenarios OK`. Then a negative: temporarily change `if ((rank[f.severity] ?? 3) < (rank[prior.severity] ?? 3)) prior.severity = f.severity;` to a no-op comment, re-run — expected an assertion failure naming "strongest severity"; restore the line.

- [ ] **Step 4: `orchestration.md` — the exemplar names the shape; the work bound is distinct from the concurrency cap**

```python
import pathlib
p = pathlib.Path('.claude/rules/orchestration.md'); t = p.read_text()
def rep(old, new):
    global t
    assert t.count(old) == 1, (old[:60], t.count(old)); t = t.replace(old, new, 1)
rep("and `.claude/workflows/review-sweep.js` (mid-tier find stage → workhorse verify stage; triage stays in the main thread, because judgment belongs to the session model).",
    "and `.claude/workflows/review-sweep.js` (roster read at runtime → mid-tier find stage → dedup and a declared bound → verify stage at the session model, effort high; the run logs its planned agent count first and returns its own record; triage stays in the main thread, because judgment belongs to the session model).")
rep("- **Let the runtime's cap govern — don't author a lower one.**",
    "- **Bound the work, not the concurrency.** The cap below is about how many agents run at once; a *work* bound — how many deduplicated findings a review sweep carries into its verify stage, how many items a fan-out may act on — is a design decision every fan-out declares before it dispatches, logs as a planned count, and reports overflow from, never silently (`pr-review.md` § Fan-outs are bounded: the sweep's 3-per-dimension / 8-verified defaults). Naming the runtime's concurrency cap as a reason to skip a work bound is the mis-sizing this bullet exists to prevent.\n- **Let the runtime's cap govern — don't author a lower one.**")
p.write_text(t); print('orchestration.md edited')
```

- [ ] **Step 5: Verification block — the sweep's checks (plain lines, inside the fence, directly before the line beginning `# Context budget:`)**

```bash
# The sweep: bounded (3 per dimension, 8 verified), roster read at runtime (no mirror), the
# planned count logged before the find stage, its own gate line returned — it parses (a workflow
# body carries a top-level return, so node --check runs on the body wrapped in a function) and
# its accounting holds under the stub harness (no agent is dispatched).
{ grep -q 'maxPerDimension ?? 3' .claude/workflows/review-sweep.js && grep -q 'maxVerify ?? 8' .claude/workflows/review-sweep.js && grep -q 'planned agents' .claude/workflows/review-sweep.js && grep -q 'gateLine' .claude/workflows/review-sweep.js; } || { echo "review-sweep.js lost a bound, the planned-count log, or its gate line"; exit 1; }
absent grep -n 'REVIEWER_TRIGGERS' .claude/workflows/review-sweep.js
{ awk '/^};$/ && !done {print; print "async function __workflow_body() {"; done=1; next} {print} END {print "}"}' .claude/workflows/review-sweep.js > "${TMPDIR:-/tmp}/review-sweep-check.mjs" && node --check "${TMPDIR:-/tmp}/review-sweep-check.mjs"; } || { echo "review-sweep.js does not parse (or node is missing — install it; do not soften this check)"; exit 1; }
node .claude/workflows/tests/review-sweep-accounting.mjs || { echo "review-sweep.js accounting regressed"; exit 1; }

```

- [ ] **Step 6: Verify and commit**

```bash
awk '/^## Verification/{p=1} p' .claude/rules/cbk-conventions-reference.md | awk '/^```bash/{c=1;next} /^```/{c=0} c' > /tmp/p2-block.sh && bash -e /tmp/p2-block.sh > /tmp/p2-out.txt 2>&1 && grep -q 'verification: done' /tmp/p2-out.txt && echo GREEN
git add .claude/workflows/review-sweep.js .claude/workflows/tests/review-sweep-accounting.mjs .claude/rules/orchestration.md .claude/rules/cbk-conventions-reference.md
git commit -m "feat(review-sweep): roster read at runtime, dedup that keeps the strongest report, bounds 3/8 charged fairly and logged, the run returns its gate line (#10 #11)" -m "The hand-copied REVIEWER_TRIGGERS mirror is gone — a cheap structured agent reads pr-review.md § Project-local agents at dispatch, and a failed or malformed read degrades to the toolkit dimensions with the dropped coverage reported. Findings are deduplicated on file:line:normalized title keeping the strongest severity and the converging dimensions, bounded per dimension (charged to the least-loaded reporter) and overall, overflow returned unverified; an unmatched domain reviewer is dropped coverage, not silence. A null verdict from a killed verifier is unverified, not a crash (#47 item 4). Verify agents inherit the session model (the ceiling rule). A stub harness exercises the accounting without an agent and runs in the verification block. orchestration.md names the shape and distinguishes the work bound from the concurrency cap." -m "Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 2: The floor, on the three prose surfaces, one commit (#8 #9 #12 #44, #47 item 3)

**Files:**
- Modify: `.claude/rules/pr-review.md` § When to invoke (the three paragraphs from `**Orchestrated sweep (optional).**` through `If the toolkit isn't installed or fails to invoke`), § Break-glass override (two sentences)
- Modify: `.claude/rules/pr-review-reference.md` § Anti-patterns (two new entries), § When to update this file (one bullet)
- Modify: `.claude/commands/finish.md` Step 1 (two break-glass sentences), Step 8 item 1, Step 9 items 1–2, Step 10 (the `## Review gate` bullet), Step 11 (one bullet), `## What /finish does NOT do` (one bullet rewritten, one added)
- Modify: `.claude/skills/rough-in/references/finish-command.md` — the same edits in the template body (byte-parallel) plus one clause in its wrapper's provenance paragraph
- Modify: `.claude/rules/cbk-conventions-reference.md § Verification` — the floor's checks and the byte-parallel pin
- (The fourth surface the spec names, the sweep's `meta`, landed in Task 1; Step 7 verifies it says "supplements".)

**Interfaces:**
- Consumes: Task 1's `gateLine`.
- Produces: the `## Review gate` block shape, stated once in `pr-review.md § The floor` and cited (never copied) by `/finish` Step 10.

- [ ] **Step 1: `pr-review.md` — replace the substitution model with the floor**

Save the block below to `/tmp/p2-floor.md` verbatim (the outer ```` fence is not part of it), then run the script under it. It replaces, in `## When to invoke`, the run from the line beginning `**Orchestrated sweep (optional).**` through the line beginning `If the toolkit isn't installed or fails to invoke, **stop and surface**` (inclusive — three paragraphs).

````markdown
### The floor — two skills, actually invoked

**A review pass is unsatisfied until both of these have actually run, as skills, in this session:**

1. **`/simplify`** — the real skill, per [`simplification.md`](simplification.md).
2. **`pr-review-toolkit:review-pr`** — the real skill, no args.

This is a floor, not a menu. Neither is satisfied by an agent that read the diff and reported what those skills *would* have found, by a workflow that dispatched agents "covering the same dimensions," or by a summary asserting the pass was clean. **Reasoning about a gate is not passing it.** If either skill is uninstalled or errors, the pass **fails** — stop and surface; `/finish`'s "does not skip" rule makes it blocking. A skill that runs without its own agent fan-out because the Agent tool is unavailable in the calling context counts as **invoked, not covered** — a subagent at the spawn-depth limit has no Agent tool (three layers below the main conversation by default; `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` — `https://code.claude.com/docs/en/sub-agents`, verified 2026-09-06) — and its dropped dimensions are recorded as dropped coverage on the gate line, never described as equivalent.

**Once.** The floor runs once, when the known work is complete and just before the draft PR. It is not run again on a delta that lands after the draft — an operator's runs forcing fixes, a follow-up — and it is not a tool for checking a specific change: the reviewer round on the flip covers the delta, `/pr-respond` answers it, and a further floor pass happens only when the operator asks. *(A real run, 2026-09-04, saw the floor twice and four verification workflows on one drafted artifact; the operator's rule is once.)*

**Record the invocation — the `## Review gate` block.** The PR body carries a `## Review gate` block, written before `## Triage`, with one line each for `/simplify`, `pr-review-toolkit:review-pr` and the orchestrated sweep, each stating run-or-not with counts and any dropped coverage. This is the block's one home; `/finish` Step 10 cites it rather than restating it:

```markdown
## Review gate
- `/simplify` — ran: <N> cleanup agents, <N> findings, <N> applied · or: invoked, not covered — <dropped dimensions> · or: waived — <break-glass reason>
- `pr-review-toolkit:review-pr` — ran: <N> agents, <N> findings, triaged <A/AwC/S/D/R> · or: invoked, not covered — <dropped dimensions> · or: waived — <break-glass reason>
- `review-sweep` — ran: <N> finders + <N> verifiers, <N> confirmed / <N> refuted / <N> unverified, dropped coverage: <reviewers or dimensions, or none>, bounds <per-dimension>/<verified> · or: skipped — <reason>
```

A waived skill is recorded on its line with the break-glass reason, never omitted. **A PR body without this block is treated as un-reviewed, whatever the hand-off claims.** This is what makes the gate auditable rather than assertable — the failure mode it exists to stop is a confident hand-off summary describing a review that never happened.

### The orchestrated sweep supplements; it never substitutes

Where a multi-agent orchestration surface is available, `.claude/workflows/review-sweep.js` runs **beside** `pr-review-toolkit:review-pr`, after `/simplify`, and carries any focused or specific review the two skills do not cover, or do not cover enough, for the diff at hand — the project-local reviewers below always ride in it (the workflow reads § Project-local agents at dispatch time, never a copy kept in the script), and beyond them the caller names the finders this diff needs (a dimension the toolkit lacks; a targeted concern such as a schema change, a timing invariant, a boundary contract) — every finding through a refute-by-default **adversarial verification stage** before triage. Triage waits for the skill and the workflow both. The workflow widens coverage and pre-filters false positives. It is **never** an alternative to invoking the two skills, and a workflow that ran does not discharge either of them.

If the sweep is unavailable, its roster read fails, or its run fails, that is not a fallback event — the floor was always the requirement, and the sweep's absence costs only the extra coverage. Record that it was skipped, or what it dropped, on its gate line.

**Proportionality — size the sweep to the diff.** The floor is constant; the sweep's size is not. The project-local reviewers always run and cost nothing when nothing is in scope; the finders beyond them are chosen for this diff — none on a small single-surface change the two skills already cover, several on a broad or cross-cutting one (the vocabulary `/finish` Step 5a uses for research: a single-file change needs none of this; a cross-layer or multi-subsystem diff is where the fan-out earns its cost). **A session-level effort setting does not override this** — running an expensive orchestration because the session is set to a high tier is exactly the mis-sizing this clause exists to prevent. When in doubt, run the floor with the project-local reviewers and add no finder.

**Fan-outs are bounded — at dedup and verify, never in the finder prompt.** The finder prompt keeps asking for every finding the reviewer would defend (that is the docs' own review guidance); the sweep then deduplicates across dimensions and carries a bounded, severity-ranked set into verification — by default **3 per dimension and 8 verified** — logging the planned agent count before the find stage and returning anything a bound drops as unverified, never silently. Unbounded per-finding fan-out is forbidden: it makes cost a function of how noisy the finders were, which inverts the incentive the find stage should have.

**Three invariants, floor and supplement alike.** (1) **Triage judgment stays with the caller.** Dispatched review and verify agents report findings and verdicts; the executor holding this file's rubric classifies them — triage is never delegated downstream. (2) **A failed review agent is dropped coverage, not zero findings.** An agent that fails, times out, or returns nothing must be tracked as an uncovered dimension and retried — and a finding whose verification step failed is surfaced as unverified, not silently dropped — before the review pass is treated as complete. (3) **Every finding is deduplicated before it is verified**, keyed on file, line and normalized title, keeping the strongest severity reported and carrying the dimensions that independently converged — convergence is signal for triage, not a duplicate to pay for twice.

If the toolkit isn't installed or fails to invoke, **stop and surface** — do not silently skip. The "does not skip" rule in `/finish` makes a missing toolkit blocking.
````

```python
import pathlib
p = pathlib.Path('.claude/rules/pr-review.md'); lines = p.read_text().split('\n')
s = next(i for i,l in enumerate(lines) if l.startswith('**Orchestrated sweep (optional).**'))
e = next(i for i,l in enumerate(lines) if l.startswith("If the toolkit isn't installed or fails to invoke, **stop and surface**"))
assert e > s and lines[s+2].startswith('**Two invariants either way.**'), (s, e)
lines[s:e+1] = pathlib.Path('/tmp/p2-floor.md').read_text().rstrip('\n').split('\n')
p.write_text('\n'.join(lines)); print('floor written', s, e)
```

- [ ] **Step 2: `pr-review.md` § Break-glass override — the marker waives exactly one named half**

```python
import pathlib
p = pathlib.Path('.claude/rules/pr-review.md'); t = p.read_text()
def rep(old, new):
    global t
    assert t.count(old) == 1, (old[:60], t.count(old)); t = t.replace(old, new, 1)
rep("and skips the review pass's review-toolkit invocation.",
    "and waives **exactly one named half** of the floor — the `pr-review-toolkit:review-pr` invocation — for this run; `/simplify` is never waived, and the sweep needs no marker (its absence is recorded, not waived).")
rep('Either path produces the same hand-off summary line: "Review-toolkit explicitly skipped per <reason>." Don\'t silently skip; the audit trail is in the PR body.',
    "Either path produces the same record: the skill's line in the PR body's `## Review gate` block reads `waived — <reason>` (§ The floor), and the hand-off repeats it. Don't silently skip; the audit trail is the gate line, never an omitted one.")
p.write_text(t); print('break-glass edited')
```

- [ ] **Step 3: `pr-review-reference.md` — two anti-patterns, one update trigger**

```python
import pathlib
p = pathlib.Path('.claude/rules/pr-review-reference.md'); t = p.read_text()
def rep(old, new):
    global t
    assert t.count(old) == 1, (old[:60], t.count(old)); t = t.replace(old, new, 1)
rep("## When to update this file\n",
    "### ❌ Describing a review instead of running one\n\n\"The diff was reviewed for X, Y and Z\" by an agent that read the diff is not `/simplify` or `pr-review-toolkit:review-pr` having run. The floor is two skill invocations; a description of what they would have found is the failure mode the `## Review gate` block exists to catch (`pr-review.md` § The floor).\n\n### ❌ A PR body without a `## Review gate` block\n\nA body that carries `## Triage` but no `## Review gate` is treated as un-reviewed whatever the hand-off says — the block is the only auditable record that the two skills ran, and a waived skill is recorded on its line, never omitted.\n\n## When to update this file\n")
old = next(l for l in t.split('\n') if l.startswith('- The break-glass mechanism gets used more than ~5% of the time'))
rep(old + '\n', old + "\n- The `## Review gate` block's shape changes — edit its one home (`pr-review.md` § The floor) and check that `/finish` Step 10 still cites it rather than carrying a copy.\n")
p.write_text(t); print('reference edited')
```

- [ ] **Step 4: `finish.md` and the template body — the same edits, asserted once per file**

Save the Step 9 replacement (items 1–2) to `/tmp/p2-step9.md` verbatim:

```markdown
1. **Invoke `pr-review-toolkit:review-pr` as a skill** against the local branch — the real skill, no args; it auto-discovers the diff via `git diff` + `gh pr view` and, pre-PR, falls back to `git diff main...HEAD`. Do **not** pass the PR number as an argument. This is one half of the review floor (`.claude/rules/pr-review.md` § The floor); the other half ran in Step 8. **The floor runs once**, here, when the known work is complete — not again on a later delta.

   If `pr-review-toolkit:review-pr` is not installed or fails to invoke, stop and surface — do not silently skip. Tell the user: "install the `pr-review-toolkit` Claude plugin, or explicitly waive this run." A skill that runs without its own agent fan-out because the Agent tool is unavailable in your context counts as **invoked, not covered**: record its dropped dimensions on its `## Review gate` line (Step 10), never describe it as equivalent.

   **Break-glass**: the `<!-- skip-review-toolkit -->` marker found in Step 1 waives **this half only**; `/simplify` is never waived. Record `waived — <reason>` on this skill's `## Review gate` line (Step 10). Don't silently skip; the audit trail is the gate line.

2. **Run the orchestrated sweep beside it, sized to the diff — it supplements and never substitutes.** Where a multi-agent orchestration surface is available, dispatch `.claude/workflows/review-sweep.js` concurrently with item 1 (`Workflow` with `name: "review-sweep"` and `args: {base, files, finders?}`, `files` being the pre-filtered changed-path list from `pr-review.md` § Pre-filters — always pass it; without it the domain reviewers are dropped coverage). The sweep running does not discharge item 1. The project-local reviewers named in `pr-review.md` § Project-local agents always ride in it — the workflow reads that roster at runtime; this step keeps no copy — and beyond them you name the finders this diff needs: none on a small single-surface change the two skills already cover, several on a cross-layer or multi-subsystem one; never size it to the session's effort setting (`pr-review.md` § Proportionality). The workflow logs its planned agent count before it finds anything and returns its own gate line (`gateLine`), which Step 10 transcribes. Without an orchestration surface, dispatch the project-local reviewers directly, in parallel with item 1, and record `skipped — no orchestration surface` on the sweep's gate line.

   **A failed review agent is dropped coverage, not zero findings.** An agent that fails, times out, or returns nothing leaves its whole dimension unreviewed — track failed dimensions and unverified findings explicitly and retry them before treating the review pass as complete; the sweep reports both in its record. This generalizes the missing-toolkit rule above to every agent in the dispatch.
```

```python
import pathlib
for path in ['.claude/commands/finish.md', '.claude/skills/rough-in/references/finish-command.md']:
    p = pathlib.Path(path); t = p.read_text()
    def rep(old, new):
        global t
        assert t.count(old) == 1, (path, old[:60], t.count(old)); t = t.replace(old, new, 1)
    # Step 1 — the marker waives one half; the old whole-step sentence goes
    rep("If present, the review pass (Step 9) is skipped per `pr-review.md` § Break-glass, and the hand-off records the reason.",
        "If present, Step 9's `pr-review-toolkit:review-pr` invocation is waived per `pr-review.md` § Break-glass override — the rest of Step 9 still runs, `/simplify` is never waived — and the skill's `## Review gate` line (Step 10) records the reason.")
    # Step 8 item 1 — a skill invocation
    rep("1. **Run `/simplify`** in your Claude Code session. Project-mandatory per `docs/STANDARDS.md` § Step 4 and `.claude/rules/simplification.md`. Review the simplify diff before continuing.",
        "1. **Invoke `/simplify` as a skill** in your Claude Code session — the real skill, not an agent reasoning about what it would find (`.claude/rules/pr-review.md` § The floor). Project-mandatory per `docs/STANDARDS.md` § Step 4 and `.claude/rules/simplification.md`. Review the simplify diff before continuing. Its outcome is the first line of the `## Review gate` block (Step 10).")
    # Step 9 items 1–2 — replace from item 1's first line through the "failed review agent" paragraph
    lines = t.split('\n')
    s = next(k for k,l in enumerate(lines) if l.startswith('1. **Run `pr-review-toolkit:review-pr`** against the local branch.'))
    e = next(k for k,l in enumerate(lines) if l.startswith('   **A failed review agent is dropped coverage, not zero findings.**'))
    assert e > s and lines[e+1] == '' and lines[e+2].startswith('3. **Triage and auto-action findings'), (s, e)
    lines[s:e+1] = pathlib.Path('/tmp/p2-step9.md').read_text().rstrip('\n').split('\n')
    t = '\n'.join(lines)
    # Step 10 — the block, cited
    rep("   - A `## Triage` block listing every finding under its class.",
        "   - A **`## Review gate`** block, written before `## Triage`, in the shape `.claude/rules/pr-review.md` § The floor states — one line each for `/simplify`, `pr-review-toolkit:review-pr` and the sweep, stating run-or-not with counts and dropped coverage; a waived skill on its line with the break-glass reason; the sweep's line transcribed from the record the workflow returns. A body without this block is treated as un-reviewed.\n   - A `## Triage` block listing every finding under its class.")
    # Step 11 — the gate lines travel with the hand-off
    rep("- A one-line **triage count**: `Apply: N · Apply with care: N · Surface: N · Defer: N · Reject: N`.",
        "- A one-line **triage count**: `Apply: N · Apply with care: N · Surface: N · Defer: N · Reject: N`.\n- The three **`## Review gate` lines**, verbatim — an invocation the transcript does not show was not made.")
    # Does-not-do — one bullet rewritten, one added
    rep("The one exception is an explicit break-glass marker (Step 1), which is recorded in the hand-off.",
        "The one exception is an explicit break-glass marker (Step 1), which waives exactly the `pr-review-toolkit:review-pr` half and is recorded on that skill's `## Review gate` line. The orchestrated sweep supplements the two skills and never substitutes for either.\n- **Does not run the review floor twice.** The floor is the final gate before the draft; a delta that lands afterwards belongs to the reviewer round and `/pr-respond`, and a further floor pass happens only when the operator asks.")
    p.write_text(t); print('edited', path)
# the template's wrapper (above the marker; not part of the byte-parallel body)
p = pathlib.Path('.claude/skills/rough-in/references/finish-command.md'); t = p.read_text()
old = "(6) the PR opens as draft with a SHA-anchored triage audit in the body,"
assert t.count(old) == 1
p.write_text(t.replace(old, "(6) the PR opens as draft with a `## Review gate` block and a SHA-anchored triage audit in the body,", 1)); print('wrapper edited')
```

- [ ] **Step 5: Verification block — the floor's checks and the byte-parallel pin (plain lines, inside the fence, directly before the line beginning `# The sweep: bounded`)**

```bash
# The review floor: no surface frames the sweep as a substitute for the two skills (the pattern
# also catches the paraphrase the sweep's meta once carried); the `## Review gate` block has one
# home (pr-review.md § The floor) that the executor and its bundled template cite; the executor and
# the template body stay byte-parallel (the anchored awk is the extraction the template documents).
absent grep -rn "instead of a single direct dispatch\|direct dispatch[^.]*is the fallback\|apply only after both the primary and the recorded fallback" .claude/
{ grep -q '^## Review gate' .claude/rules/pr-review.md && grep -q 'Review gate' .claude/commands/finish.md && grep -q 'Review gate' .claude/skills/rough-in/references/finish-command.md; } || { echo "the ## Review gate block is missing from its home, the executor, or the bundled template"; exit 1; }
diff <(awk '/^--- BEGIN TEMPLATE ---/{flag=1; next} flag' .claude/skills/rough-in/references/finish-command.md) .claude/commands/finish.md >/dev/null || { echo "commands/finish.md and the bundled template body have drifted"; exit 1; }

```

- [ ] **Step 6: Verify**

```bash
diff <(awk '/^--- BEGIN TEMPLATE ---/{flag=1; next} flag' .claude/skills/rough-in/references/finish-command.md) .claude/commands/finish.md && echo "byte-parallel"
grep -c "supplements" .claude/rules/pr-review.md .claude/commands/finish.md .claude/workflows/review-sweep.js
grep -n "^### The floor\|^### The orchestrated sweep\|^## Review gate" .claude/rules/pr-review.md
awk '/^## Verification/{p=1} p' .claude/rules/cbk-conventions-reference.md | awk '/^```bash/{c=1;next} /^```/{c=0} c' > /tmp/p2-block.sh && bash -e /tmp/p2-block.sh > /tmp/p2-out.txt 2>&1 && grep -q 'verification: done' /tmp/p2-out.txt && echo GREEN
```
Expected: `byte-parallel`; each of the three files ≥ 1; the two `###` headings plus the `## Review gate` line inside the block's fenced example; `GREEN`.

- [ ] **Step 7: Commit**

```bash
git add .claude/rules/pr-review.md .claude/rules/pr-review-reference.md .claude/commands/finish.md .claude/skills/rough-in/references/finish-command.md .claude/rules/cbk-conventions-reference.md
git commit -m "feat(review): the two-skill floor, actually invoked and recorded — the sweep supplements, never substitutes (#8 #9 #12 #44)" -m "pr-review.md § When to invoke becomes § The floor (once; the \`## Review gate\` block stated once) and § The orchestrated sweep supplements (proportionality to the diff, bounds at dedup and verify, three invariants); the hard-fail carve-out goes; break-glass waives exactly one named half. Swept in the same commit: /finish Steps 1, 8, 9, 10, 11 and its does-not-do list, and the bundled template byte-parallel (pinned in the verification block). The sweep's meta, the fourth surface, landed with the sweep. Also closes #47 item 3 (the floor runs once)." -m "Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 3: Two hooks, four tiers, memory does not fork (#48; the hook half of D19)

**Files:**
- Create: `.claude/hooks/require-repo-root-for-agents.sh`, `.claude/hooks/detect-forked-agent-memory.sh` (executable)
- Modify: `.claude/settings.json` — `_comment_hooks` (four tiers), every hook command as `${CLAUDE_PROJECT_DIR}/.claude/hooks/<name>.sh`, a `PreToolUse` group for `Task|Agent|Workflow`, a `Stop` group
- Modify: `CLAUDE.md` (the hooks line), `README.md` (two hook rows), `.claude/rules/cbk-conventions-reference.md` (the "Mechanize the gates" paragraph — two tiers → four), `.claude/rules/pr-review.md` § Reviewer precedent memory (one sentence)
- Modify: `.claude/rules/cbk-conventions-reference.md § Verification` — the registry check, the launch-root payload checks, the fork grep

**Interfaces:**
- Produces: the tier vocabulary `HARD-DENY`, `ASK-GATE`, `ADVISORY`, `STOP` (asserted by the verification block); hook commands in placeholder form (the executable check expands it); the hook names Task 8's authoring section cites.

- [ ] **Step 1: The launch-root guard**

Create `.claude/hooks/require-repo-root-for-agents.sh`:

```bash
#!/usr/bin/env bash
# PreToolUse hook (Task|Agent|Workflow matcher): refuse to dispatch agents from
# anywhere but the repository root.
#
# The project-local reviewers declare `memory: project`, which the platform
# stores at the RELATIVE path `.claude/agent-memory/<name>/`, and a subagent
# "starts in the main conversation's current working directory"
# (https://code.claude.com/docs/en/sub-agents — verified 2026-09-06; re-verify
# after harness upgrades) — a directory that follows the session's own `cd`.
# So a sweep dispatched while the shell sat in a package directory wrote every
# reviewer's memory under that package: a real github-issues run committed the
# fork once (2026-09-05) and had to move it by hand twice. This guard refuses
# the dispatch at the cause. Hooks enforce non-negotiables more reliably than
# the "launch from the root" instruction that preceded them.
#
# Blocked:  Task, Agent and Workflow tool calls whose working directory is not
#           the git top-level of the checkout it sits in.
# Allowed:  everything else — including a launch from a worktree's own root,
#           which is that checkout's top-level.
# Matcher:  `Task|Agent|Workflow` — `Agent` and `Workflow` are the names the
#           harness reported in `tool_name` on a real run (dated observation,
#           2026-09-05; the hooks pages give examples, not an enumerated list —
#           re-verify after upgrades); `Task` is the older name, kept so a
#           rename degrades to a no-op rather than silence.
# Timing:   the guard reads the payload's `cwd` (a common field on every hook
#           event — https://code.claude.com/docs/en/hooks-guide § How hooks
#           work) BEFORE the tool runs, so a `cd` inside the same call does not
#           help: return to the root as its own command, then relaunch.
# Path:     registered as ${CLAUDE_PROJECT_DIR}/.claude/hooks/… — handlers run
#           in the current directory (https://code.claude.com/docs/en/hooks), so
#           a bare relative path would not resolve from the very subdirectory
#           this guard exists to block.
# Tier:     HARD-DENY.
#
# Hook receives JSON on stdin. Exit 2 + stderr blocks. Fail-open on
# environment defects (missing jq, not a git checkout): exit 0 with a loud
# stderr warning naming the surviving backstop, mirroring protect-main-branch.sh.

set -uo pipefail
# Deliberately NOT `set -e` — fail-open on environment defects rather than
# aborting with cryptic stderr that blocks every dispatch.

if ! command -v jq &>/dev/null; then
  echo "require-repo-root-for-agents: WARNING — jq not installed; the launch-directory guard is DISABLED." >&2
  echo "                              Backstop: detect-forked-agent-memory.sh (Stop tier) still catches a" >&2
  echo "                              stray .claude/agent-memory/ before the hand-off; git status shows it untracked." >&2
  exit 0
fi

input="$(cat)"
tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty')"
case "$tool_name" in
  Task|Agent|Workflow) ;;
  *) exit 0 ;;
esac

# The hook payload carries the call's working directory (`cwd`), the same
# field protect-main-branch.sh reads for Bash calls. Fall back to this
# process's own directory when it is absent.
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty')"
cwd="${cwd:-$PWD}"

root="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)" || {
  echo "require-repo-root-for-agents: WARNING — $cwd is not inside a git checkout; guard inactive for this call." >&2
  exit 0
}

# Canonical paths, so a symlinked or trailing-slash form is not a false mismatch.
cwd_real="$(cd "$cwd" 2>/dev/null && pwd -P)"
root_real="$(cd "$root" 2>/dev/null && pwd -P)"

if [[ "$cwd_real" != "$root_real" ]]; then
  cat >&2 <<MSG
BLOCKED: $tool_name launched from
  $cwd
which is not the repository root
  $root

Project-local reviewers declare \`memory: project\`; dispatched from a
subdirectory their memory forks under that directory's .claude/agent-memory/
(pr-review.md § Reviewer precedent memory). Return to the root as its own
command, then relaunch:
  cd "$root"

If this block is wrong for a deliberate reason (rare), run the dispatch from
a session whose working directory is the root.
MSG
  exit 2
fi

exit 0
```

- [ ] **Step 2: The fork detector**

Create `.claude/hooks/detect-forked-agent-memory.sh`:

```bash
#!/usr/bin/env bash
# Stop hook: refuse to finish while a reviewer's `memory: project` tree sits
# anywhere but the repository root.
#
# require-repo-root-for-agents.sh refuses the dispatch that causes a fork: a
# subagent starts in the main conversation's current working directory, and
# `memory: project` is the relative path `.claude/agent-memory/<name>/`
# (https://code.claude.com/docs/en/sub-agents, verified 2026-09-06). This hook
# catches the OUTCOME, whatever produced it — a second `.claude/agent-memory/`
# under a package, the shape a real run committed and repaired by hand. On the
# flip's auto-review it was found by a reviewer walking every changed file;
# here it is found before the hand-off, by the agent that made it.
#
# Blocked:  the main conversation's stop, once, while a stray agent-memory
#           directory exists (exit 2 + the remediation on stderr).
# Allowed:  a clean tree; a second stop after one block (`stop_hook_active`);
#           any environment defect (fail-open with a warning).
# Event:    Stop only. Not SubagentStop — a finishing subagent has no hand-off
#           to repair the tree in, and `stop_hook_active` is documented for
#           Stop; registering there would block every subagent of a review
#           pass while a stray tree exists (demonstrated 2026-09-06).
# Loop:     exit 2 on a Stop hook blocks the stop and feeds stderr to the
#           agent (https://code.claude.com/docs/en/hooks — exit-code table).
#           `stop_hook_active` is true when the agent is already continuing
#           from this hook: warn and let it stop. The harness overrides a Stop
#           hook after eight consecutive blocks without progress
#           (https://code.claude.com/docs/en/hooks-guide § Limitations and
#           troubleshooting › "Stop hook hits the block cap"; verified
#           2026-09-06, re-verify after upgrades), so this hook blocks at most
#           once per stop. A payload without the field is treated as the first
#           block (the assumption is stated, not silently defaulted).
# Path:     registered as ${CLAUDE_PROJECT_DIR}/.claude/hooks/… (handlers run
#           in the current directory — https://code.claude.com/docs/en/hooks).
# Tier:     STOP.
# Fail-open on environment defects (missing jq) with a stderr warning. No
# bash-4-only builtins (a stock macOS bash is 3.2): the directory list is read
# with a while loop, not mapfile.

set -uo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"

if ! command -v jq &>/dev/null; then
  echo "detect-forked-agent-memory: WARNING — jq not installed; fork detection DISABLED (advisory)." >&2
  echo "                            Backstop: the verification block's fork grep (cbk-conventions-reference.md § Verification)." >&2
  exit 0
fi

input="$(cat)"
# Absent field ⇒ first block. Present and true ⇒ the agent is already continuing from this hook.
active="$(printf '%s' "$input" | jq -r '.stop_hook_active // empty')"

cd "$PROJECT_DIR" || exit 0

# Every directory named agent-memory that is not the root's own. -prune stops
# descent into the root's own tree, worktrees (each is its own checkout with its
# own root tree), .git, and build output — add your stack's build directories to
# the list. No -mindepth: it would exempt depth-1 directories from the prune test,
# so a top-level node_modules would be walked and flagged.
forks=()
while IFS= read -r d; do forks+=("$d"); done < <(
  find . \( -path './.claude/agent-memory' -o -path './.claude/worktrees' -o -name .git \
         -o -name node_modules -o -name target -o -name build -o -name _build \
         -o -name dist -o -name .venv \) -prune -o -type d -name agent-memory -print 2>/dev/null | sort
)

[ "${#forks[@]}" -eq 0 ] && exit 0

if [ "$active" = "true" ]; then
  echo "detect-forked-agent-memory: WARNING — forked reviewer memory still present after one fix attempt; letting the stop proceed:" >&2
  printf '  %s\n' "${forks[@]}" >&2
  exit 0
fi

cat >&2 <<MSG
BLOCKED: a reviewer memory tree exists outside the repository root:
$(printf '  %s\n' "${forks[@]}")

Project-local reviewers declare \`memory: project\`; the only legitimate home
is $PROJECT_DIR/.claude/agent-memory/<reviewer>/ (pr-review.md § Reviewer
precedent memory). Before stopping: move each <reviewer>/ directory's files
into the root tree, append their pointer lines to the root MEMORY.md for that
reviewer, delete the forked tree, and say so in the hand-off.
MSG
exit 2
```

Then: `chmod +x .claude/hooks/require-repo-root-for-agents.sh .claude/hooks/detect-forked-agent-memory.sh && bash -n .claude/hooks/require-repo-root-for-agents.sh && bash -n .claude/hooks/detect-forked-agent-memory.sh && echo "syntax ok"`.

- [ ] **Step 3: Dry-run both hooks on every branch (record the table for the PR body)**

```bash
P="$PWD"; H=.claude/hooks
run() { printf '%s' "$2" | "$H/$1" >/dev/null 2>/tmp/err; echo "$1 :: $3 :: exit=$?"; }
run require-repo-root-for-agents.sh '{"tool_name":"Agent","tool_input":{},"cwd":"'"$P"'/docs"}' "Agent from docs/ → 2"
run require-repo-root-for-agents.sh '{"tool_name":"Task","tool_input":{},"cwd":"'"$P"'/docs"}' "Task from docs/ → 2"
run require-repo-root-for-agents.sh '{"tool_name":"Workflow","tool_input":{},"cwd":"'"$P"'"}' "Workflow from root → 0"
run require-repo-root-for-agents.sh '{"tool_name":"Bash","tool_input":{},"cwd":"'"$P"'/docs"}' "Bash from docs/ → 0 (unmatched)"
run require-repo-root-for-agents.sh '{"tool_name":"Agent","tool_input":{}}' "Agent, no cwd, process at root → 0"
run require-repo-root-for-agents.sh '{"tool_name":"Agent","tool_input":{},"cwd":"/tmp"}' "Agent from a non-repo dir → 0 + warning"
printf '{"tool_name":"Agent","tool_input":{}}' | env PATH=/nonexistent /bin/bash "$H/require-repo-root-for-agents.sh" 2>/tmp/err; echo "no jq → exit=$? (expect 0) :: $(head -c 80 /tmp/err)"
# The fork detector needs a stray tree: make one under a temp path inside the repo, run, remove, assert removed.
T=$(mktemp -d -p docs zz-neg.XXXX) && mkdir -p "$T/.claude/agent-memory"
printf '{"stop_hook_active":false}' | CLAUDE_PROJECT_DIR="$P" "$H/detect-forked-agent-memory.sh" >/dev/null 2>/tmp/err; echo "Stop with a stray tree → exit=$? (expect 2) :: $(grep -c "$(basename "$T")" /tmp/err) path(s) named"
printf '{}' | CLAUDE_PROJECT_DIR="$P" "$H/detect-forked-agent-memory.sh" >/dev/null 2>&1; echo "Stop, field absent, stray tree → exit=$? (expect 2: absent ⇒ first block)"
printf '{"stop_hook_active":true}' | CLAUDE_PROJECT_DIR="$P" "$H/detect-forked-agent-memory.sh" >/dev/null 2>/tmp/err; echo "Stop, stop_hook_active=true → exit=$? (expect 0 + warning)"
rm -r "$T"; test ! -d "$T" || { echo "stray-tree fixture not removed"; exit 1; }
printf '{"stop_hook_active":false}' | CLAUDE_PROJECT_DIR="$P" "$H/detect-forked-agent-memory.sh" >/dev/null 2>&1; echo "Stop, no stray tree → exit=$? (expect 0)"
git status --short | wc -l
```
Expected: every observed exit matches; the last line counts only this task's intended changes.

- [ ] **Step 3b: One real dispatch, end to end**

The piped payloads exercise the script, not the matcher. After Step 4 registers the hook, exercise the matcher once for real: in a Bash call, `cd docs` (the Bash tool's working directory persists); then invoke the Agent tool with a trivial haiku prompt ("reply ok"). Expected: the tool call is blocked with the hook's `BLOCKED: Agent launched from …/docs` message. Then `cd "$(git rev-parse --show-toplevel)"` in its own Bash call and re-invoke — expected: the agent runs. Record both outcomes, dated, in the PR body's dry-run table (this is the row that tells a future reader the matcher names were right on this harness).

- [ ] **Step 4: `settings.json` — placeholder paths for every hook, register, and state four tiers**

```python
import json, collections, pathlib
p = pathlib.Path('.claude/settings.json')
d = json.loads(p.read_text(), object_pairs_hook=collections.OrderedDict)
PFX = '${CLAUDE_PROJECT_DIR}/'
# Every registered command takes the placeholder form: handlers run in the current directory
# (code.claude.com/docs/en/hooks), so a bare relative path is not found from a subdirectory —
# which is exactly where the launch-root guard must fire. P1's five hooks had the same latent defect.
for ev, groups in d['hooks'].items():
    for g in groups:
        for h in g['hooks']:
            if h['command'].startswith('.claude/hooks/'): h['command'] = PFX + h['command']
d['_comment_hooks'] = (
 "Guards in FOUR tiers; each tier names its mechanism and its dated source; prerequisites and the canonical dry-run are stated once at the end (cbk-conventions-reference.md § HITL gate load-bearing heuristics › Mechanize the gates). Every command uses ${CLAUDE_PROJECT_DIR}/… — handlers run in the current directory (code.claude.com/docs/en/hooks, verified 2026-09-06), so a bare relative path is not found from a subdirectory. "
 "HARD-DENY (PreToolUse, exit 2) for actions never legitimate for the agent: protect-immutable-adrs.sh blocks Edit/Write/MultiEdit on existing docs/adr/NNNN-*.md; protect-lock-files.sh blocks edits to lock files (change them via the package manager); protect-main-branch.sh blocks `git commit` on main/master (branch-first per cbk-conventions.md § Branch naming; judged on the branch at entry, so branch creation and the first commit are separate calls); require-repo-root-for-agents.sh blocks Task/Agent/Workflow dispatch from any directory but the checkout's git top-level — a subagent starts in the main conversation's current working directory and `memory: project` is a relative path (code.claude.com/docs/en/sub-agents, verified 2026-09-06), so reviewer memory forked under a package directory on a real run (2026-09-05); the `Task|Agent|Workflow` matcher is a dated observation of the tool names the harness reports, with the older name kept so a rename degrades to a no-op. "
 "ASK-GATE (PreToolUse, permissionDecision \"ask\") for one-way doors legitimate only when operator-instructed — the permission prompt IS the per-action HITL approval, and it fires even when a broad allowlist entry would otherwise auto-approve: guard-pr-state.sh intercepts gh pr ready/merge/close/reopen; require-knowledge-backend-ok.sh intercepts knowledge-backend MCP writes (Notion matcher shipped as the v1 reference — adjust the regex to your MCP's tool names; when the knowledge axis is `none` the guard is inert because its tools are not connected, and it follows the rule file's disposition at bootstrap). "
 "ADVISORY (PostToolUse, exit 0 always) ships as unregistered exemplars: format-on-edit.sh (the `_example_PostToolUse_formatter` key below — copy it into hooks.PostToolUse after wiring the case arms to your stack). "
 "STOP (Stop, exit 2 blocks the stop once): detect-forked-agent-memory.sh exits 2 while a `.claude/agent-memory/` tree exists anywhere but the root, so the agent that forked it moves it before handing off; `stop_hook_active` prevents a loop, and the harness overrides a Stop hook after eight consecutive blocks (code.claude.com/docs/en/hooks-guide § Limitations and troubleshooting, verified 2026-09-06). Registered on Stop only: on SubagentStop it would block every finishing subagent, which has no hand-off. "
 "All guards fail open (exit 0 + stderr warning naming the surviving backstop) on environment defects, so a missing jq can't turn a targeted guard into a universal block. Prerequisites: jq, git, bash 3.2+. Canonical dry-run: pipe a crafted JSON payload into the script and assert the exit (the verification block runs the launch-root guard's payloads on every run; the Stop hook's fixture run is documented in the P2 plan).")
pre = d['hooks']['PreToolUse']
assert not any(g.get('matcher') == 'Task|Agent|Workflow' for g in pre)
pre.append(collections.OrderedDict([('matcher', 'Task|Agent|Workflow'), ('hooks', [collections.OrderedDict([('type','command'),('command', PFX + '.claude/hooks/require-repo-root-for-agents.sh')])])]))
assert 'Stop' not in d['hooks'] and 'SubagentStop' not in d['hooks']
d['hooks']['Stop'] = [collections.OrderedDict([('hooks', [collections.OrderedDict([('type','command'),('command', PFX + '.claude/hooks/detect-forked-agent-memory.sh')])])])]
p.write_text(json.dumps(d, indent=2, ensure_ascii=False) + '\n'); print('settings.json: four tiers, placeholder paths, two registrations')
```
Then `jq empty .claude/settings.json && jq -r '[.hooks[][] | .hooks[] | .command] | length, (unique | length)' .claude/settings.json` — expected: parses; `7` and `7` (five from P1 plus the two new ones, each registered once).

- [ ] **Step 5: The four tiers everywhere the two tiers were stated**

```python
import pathlib
def rep(path, pairs):
    p = pathlib.Path(path); t = p.read_text()
    for old, new in pairs:
        assert t.count(old) == 1, (path, old[:60], t.count(old)); t = t.replace(old, new, 1)
    p.write_text(t); print('edited', path)
rep('CLAUDE.md', [(
 "├── hooks/                         ← PreToolUse guards, two-tiered: hard-deny (protect-immutable-adrs, protect-lock-files, protect-main-branch) + ask-gate (guard-pr-state, require-knowledge-backend-ok) + format-on-edit exemplar",
 "├── hooks/                         ← guards in four tiers: hard-deny (protect-immutable-adrs, protect-lock-files, protect-main-branch, require-repo-root-for-agents) + ask-gate (guard-pr-state, require-knowledge-backend-ok) + advisory exemplar, unregistered (format-on-edit) + stop (detect-forked-agent-memory)")])
rep('README.md', [(
 "│   ├── protect-main-branch.sh         ← hard-deny: git commit on main\n│   ├── guard-pr-state.sh              ← ask-gate: gh pr ready/merge/close/reopen\n│   ├── require-knowledge-backend-ok.sh ← ask-gate: knowledge-backend MCP writes\n│   └── format-on-edit.sh              ← exemplar (unregistered; stanza in settings.json)",
 "│   ├── protect-main-branch.sh         ← hard-deny: git commit on main\n│   ├── require-repo-root-for-agents.sh ← hard-deny: Task/Agent/Workflow dispatch outside the repo root\n│   ├── guard-pr-state.sh              ← ask-gate: gh pr ready/merge/close/reopen\n│   ├── require-knowledge-backend-ok.sh ← ask-gate: knowledge-backend MCP writes\n│   ├── detect-forked-agent-memory.sh  ← stop: a reviewer-memory tree outside the root blocks the hand-off\n│   └── format-on-edit.sh              ← advisory exemplar (unregistered; stanza in settings.json)")])
rep('.claude/rules/cbk-conventions-reference.md', [(
 "instead of prose, in two tiers: **hard-deny** for actions never legitimate for the agent (editing immutable ADRs, hand-editing lock files, committing on main), **ask-gate** for one-way doors legitimate only when operator-instructed (PR-state changes, knowledge-backend writes) — where the forced permission prompt *is* the per-action HITL approval and fires even when a broad allowlist would otherwise auto-approve. See the hook registry in `.claude/settings.json`.",
 "instead of prose, in four tiers: **hard-deny** (PreToolUse, exit 2) for actions never legitimate for the agent (editing immutable ADRs, hand-editing lock files, committing on main, dispatching agents outside the repo root); **ask-gate** (PreToolUse, `permissionDecision: \"ask\"`) for one-way doors legitimate only when operator-instructed (PR-state changes, knowledge-backend writes) — where the forced permission prompt *is* the per-action HITL approval and fires even when a broad allowlist would otherwise auto-approve; **advisory** (PostToolUse, exit 0 always) for a formatter or analyzer that surfaces drift at edit time and never blocks; **stop** (Stop, exit 2) for a condition the agent must repair before it hands off (a forked reviewer-memory tree). See the hook registry in `.claude/settings.json`.")])
p = pathlib.Path('.claude/rules/pr-review.md'); lines = p.read_text().split('\n')
i = next(k for k,l in enumerate(lines) if l.startswith('**Reviewer precedent memory.**'))
lines[i] += " The memory root follows the directory the reviewer was dispatched from — `memory: project` is a relative path and a subagent starts in the main conversation's current working directory (`https://code.claude.com/docs/en/sub-agents`, verified 2026-09-06) — so every sweep is launched from the repository root; `require-repo-root-for-agents.sh` refuses any other launch and `detect-forked-agent-memory.sh` blocks a hand-off while a stray tree exists."
pathlib.Path('.claude/rules/pr-review.md').write_text('\n'.join(lines)); print('pr-review.md sentence appended')
```
(Task 6 rewrites that paragraph in full and keeps the sentence. Task 8 adds the analyzer to CLAUDE.md's line and the `§ Hook authoring` citations once the section exists — no forward reference lands here.)

- [ ] **Step 6: Verification block — registry ⇔ files, the launch-root payloads, the fork grep (plain lines, inside the fence, directly after the line beginning `node .claude/workflows/tests/review-sweep-accounting.mjs`)**

```bash
# Hook registry ⇔ files: every shipped guard is registered at least once, the advisory exemplars
# stay unregistered, every registered command (placeholder form) exists and is executable, and the
# registry comment names every hook and all four tiers (the mutation table and the registry are
# two views of one list).
for h in .claude/hooks/*.sh; do b=$(basename "$h"); n=$(jq -r '[.hooks[][] | .hooks[] | .command] | map(select(endswith("'"$b"'"))) | length' .claude/settings.json); case "$b" in format-on-edit.sh|analyze-on-edit.sh) [ "$n" -eq 0 ] || { echo "advisory exemplar $b is registered"; exit 1; };; *) [ "$n" -ge 1 ] || { echo "$b is not registered"; exit 1; };; esac; jq -r '._comment_hooks' .claude/settings.json | grep -q "$b" || { echo "registry comment does not name $b"; exit 1; }; done
jq -r '[.hooks[][] | .hooks[] | .command][]' .claude/settings.json | sort -u | while read -r c; do case "$c" in '${CLAUDE_PROJECT_DIR}/'*) ;; *) echo "registered hook is not in placeholder form (handlers run in the current directory): $c"; exit 1;; esac; c="${c/\$\{CLAUDE_PROJECT_DIR\}/.}"; [ -x "$c" ] || { echo "registered hook missing or not executable: $c"; exit 1; }; done
for t in HARD-DENY ASK-GATE ADVISORY STOP; do jq -r '._comment_hooks' .claude/settings.json | grep -q "$t" || { echo "registry comment lacks the $t tier"; exit 1; }; done
# The launch-root guard, on its branches (crafted payloads; read-only). Only exit 2 denies, so the
# blocking case asserts 2 exactly; `|| rc=$?` keeps -e satisfied while the status stays testable.
rc=0; printf '{"tool_name":"Agent","tool_input":{},"cwd":"%s/docs"}' "$PWD" | .claude/hooks/require-repo-root-for-agents.sh >/dev/null 2>&1 || rc=$?
[ "$rc" -eq 2 ] || { echo "launch-root guard did not DENY a subdirectory dispatch (exit $rc; only 2 blocks)"; exit 1; }
printf '{"tool_name":"Agent","tool_input":{},"cwd":"%s"}' "$PWD" | .claude/hooks/require-repo-root-for-agents.sh >/dev/null 2>&1 || { echo "launch-root guard blocked a root dispatch"; exit 1; }
# No reviewer-memory tree outside the root (the outcome the Stop hook repairs; the gate's own check).
absent sh -c "find . \( -path './.claude/agent-memory' -o -path './.claude/worktrees' -o -name .git -o -name node_modules -o -name target -o -name build -o -name _build -o -name dist -o -name .venv \) -prune -o -type d -name agent-memory -print 2>/dev/null | grep ."

```

- [ ] **Step 7: Verify and commit**

```bash
awk '/^## Verification/{p=1} p' .claude/rules/cbk-conventions-reference.md | awk '/^```bash/{c=1;next} /^```/{c=0} c' > /tmp/p2-block.sh && bash -e /tmp/p2-block.sh > /tmp/p2-out.txt 2>&1 && grep -q 'verification: done' /tmp/p2-out.txt && echo GREEN
git add .claude/hooks/require-repo-root-for-agents.sh .claude/hooks/detect-forked-agent-memory.sh .claude/settings.json CLAUDE.md README.md .claude/rules/cbk-conventions-reference.md .claude/rules/pr-review.md
git commit -m "feat(hooks): the launch-root guard and the forked-memory Stop hook; every hook in placeholder form; the registry states four tiers (#48)" -m "require-repo-root-for-agents.sh (PreToolUse on Task|Agent|Workflow, hard-deny) refuses a dispatch from any directory but the git top-level — memory: project is a relative path and a subagent starts in the main conversation's cwd, so a real run forked its reviewer memory under a package twice. detect-forked-agent-memory.sh (Stop only — on SubagentStop it would block every finishing subagent) blocks a hand-off once while a stray tree exists, loop-guarded by stop_hook_active, bash-3-safe, pruning build trees. Every registered command is \${CLAUDE_PROJECT_DIR}/… because handlers run in the current directory — P1's five hooks shared the latent defect. settings.json, CLAUDE.md, README and the conventions' mechanize-the-gates paragraph state the tiers as hard-deny / ask-gate / advisory / stop. The verification block checks the registry against the files, runs the launch-root guard's payloads asserting exit 2, and greps for a forked tree. Dry-run table (every branch, observed = expected, plus one real dispatch) in the PR body." -m "Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 4: Reviewer craft riders (C3, last bullet)

**Files:**
- Modify: `.claude/rules/pr-review.md` § Project-local agents to dispatch alongside — the `**Reviewer craft rules**` list

- [ ] **Step 1: Append four bullets**

```python
import pathlib
p = pathlib.Path('.claude/rules/pr-review.md'); t = p.read_text()
old = next(l for l in t.split('\n') if l.startswith('- **No unsourced claims about external-platform behavior.**'))
assert t.count(old) == 1
new = old + "\n" + "\n".join([
 "- **Hand-offs name the other owner inline.** When a finding sits on another reviewer's surface (an ADR clause, a log call, a rule file), the finding says so — \"→ `adr-conformance-reviewer`\" — in the finding itself, so triage dedups it against that reviewer's report instead of counting it twice.",
 "- **A reviewer lacking a tool reports *unverifiable*, never a confirmed absence.** Without the Skill tool, without a docs-expert skill, without `gh`: \"could not verify X (no `<tool>` in this context)\" is the output. \"X is absent\" from a reviewer that could not look is the most expensive false negative the gate produces.",
 "- **Path-matched trigger prefixes are derived from where the reviewed API is used**, not from where its owner thinks the code lives: grep the tree for the calls and types the contract governs, and list those directories as the reviewer's scope in this section as bare path prefixes (`src/schema/`, never a glob or prose) — the sweep's roster read matches the changed paths against them, and an unmatchable hint is dropped coverage.",
 "- **A skill that ran without its own fan-out counts as invoked, not covered.** A subagent at the spawn-depth limit has no Agent tool (three layers below the main conversation by default, `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`; `https://code.claude.com/docs/en/sub-agents`, verified 2026-09-06), so a review skill invoked there produced no fan-out; record its dimensions as dropped coverage on the gate line and dispatch them directly from the main session.",
])
p.write_text(t.replace(old, new, 1)); print('four craft riders appended')
```

- [ ] **Step 2: Verify and commit**

```bash
awk '/^\*\*Reviewer craft rules\*\*/{p=1} p&&/^## /{exit} p' .claude/rules/pr-review.md | grep -c '^- \*\*'; echo "(expect 8)"
bash -e /tmp/p2-block.sh > /dev/null 2>&1 && echo GREEN
git add .claude/rules/pr-review.md
git commit -m "docs(pr-review): four reviewer craft riders — hand-offs name the owner, unverifiable is not absent, trigger prefixes follow usage, invoked is not covered" -m "Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 5: `## Writing memory` in every shipped reviewer, copies diffed against each other (#25 #49, #48 item 3; C8 bullet 1)

**Files:**
- Modify: `.claude/agents/adr-conformance-reviewer.md`, `.claude/agents/logging-discipline-reviewer.md`, `.claude/agents/cascade-rule-reviewer.md` — one identical section appended as the last `## ` section of each
- Modify: `.claude/rules/cbk-conventions-reference.md § Verification` — the drift guard

**Interfaces:**
- Produces: the section text below, byte-identical in three files (the check extracts from `^## Writing memory` to end-of-file and diffs the copies pairwise); the seven typed filename prefixes Task 6's rule cites — `clean-baseline-`, `out-of-scope-`, `convention-`, `conforming-` (the four genres) and `dependency-`, `finding-`, `technique-` (the three further kinds).

- [ ] **Step 1: Save the section once, append it to each reviewer**

Write `/tmp/p2-writing-memory.md` with exactly:

```markdown
## Writing memory

Your memory directory is `<repo root>/.claude/agent-memory/<your name>/` (or `.claude/agent-memory-local/<your name>/` when the project chose `memory: local`). `memory: project` is a relative path resolved against the directory the session dispatched you from — a subagent starts in the main conversation's current working directory (`https://code.claude.com/docs/en/sub-agents`, verified 2026-09-06). **Tripwire:** if the directory you are about to write to is anywhere else, stop, write nothing, and report the path as a finding. If the directory does not exist and you have no memory instructions, auto memory is off for this project (`autoMemoryEnabled` / `CLAUDE_CODE_DISABLE_AUTO_MEMORY`) — say so in your output and do not create it.

What a review may write, and how:

- **Every claim about the tree is dated and branch-named** — "on `<branch>` at `<sha>`, `<date>`: …". An undated negative claim ("there is no X") is the most dangerous thing a reviewer records: it is true only at one commit.
- **Every entry names what would falsify it, as a runnable command** (a grep, a `git log`, a `diff`) — for example, under an out-of-scope ruling on a logging surface: `falsifier: grep -rn 'Logger.info' lib/ | grep -v _test prints nothing` — and a **retire condition** — "delete when the tree it calibrates is deleted"; "drop when the conventions formalize X"; "re-check when an ADR is added that governs this path". A baseline that cites a snapshot of a moving set (an ADR range, a rule section) names the change that invalidates it. (No exercised entry carried a runnable falsifier before this rule; it is a new bar, stated here so the next entry sets it.)
- **The index line never lags the body.** Every file has exactly one line in `MEMORY.md`, written in the same edit as the file. The prompt carries only the first 200 lines or 25 KB of `MEMORY.md` (`https://code.claude.com/docs/en/sub-agents`): one line per surface, not per run.
- **Repairing a false memory is part of the review that found it.** A memory the tree contradicts is corrected (dated) in the same run, and the correction is reported in the output.
- **A clean review earns a new file only when it adds a method.** Otherwise append one dated line to the existing baseline for that surface — `re-verified on <branch> <date>: delta only — <what changed, what was re-checked>` — and check whether a baseline for the surface exists before writing anything.
- **Entry shape.** Filename: a typed prefix plus the surface — one prefix per genre in `pr-review.md` § Reviewer precedent memory (`clean-baseline-`, `out-of-scope-`, `convention-`, `conforming-`) and one per further kind (`dependency-`, `finding-`, `technique-`). Frontmatter: `name`, a one-line `description` stating the fact, `metadata.type`. Body: the dated evidence (both polarities where available), **how to apply** next time, the **retire condition**, and `[[cross-links]]` to related entries.
- **Three kinds beyond the four genres**: a *dependency fact* (a pinned library's verified behavior, with its version — `dependency-`), a *finding with its disposition* (what was flagged, what the caller decided, why — `finding-`, so a settled call is not re-litigated), and a *technique* (a verification method worth reusing, with the command that runs it — `technique-`).
- **A living record per surface.** A record re-evaluated on every pass is appended, never rewritten: a dated `**Update (<date>, <branch>):**` block naming the bar it re-decides against and the verdict held after this pass — which may revert. **Compaction:** when a record carries more than three Update blocks, fold the older ones into the summary paragraph and keep the last two verbatim.
- **Promote a calibrating precedent back into the rule.** A memory cited on three reviews is rule material: report it as a proposed rule-text change in your output. A permanent deviation belongs in the rule, not in a memory.
- **Memory updates ride the commit the review produced** (when the project commits its memory) — never a separate "update reviewer memory" commit.
```

```bash
for a in adr-conformance-reviewer logging-discipline-reviewer cascade-rule-reviewer; do f=.claude/agents/$a.md; grep -q '^## Writing memory' "$f" && { echo "already present in $f"; exit 1; }; printf '\n' >> "$f"; cat /tmp/p2-writing-memory.md >> "$f"; done
for a in adr-conformance-reviewer logging-discipline-reviewer cascade-rule-reviewer; do tail -c 1 .claude/agents/$a.md | od -c | head -1; done
```
Expected: each file ends with a newline; no `already present`.

- [ ] **Step 2: The drift guard — the copies are one text (plain lines, inside the fence, directly after the fork grep line beginning `absent sh -c "find`)**

```bash
# Every shipped reviewer carries the same `## Writing memory` section (its one text); the copies are diffed.
for a in logging-discipline-reviewer cascade-rule-reviewer; do diff <(awk '/^## Writing memory/{p=1} p' .claude/agents/adr-conformance-reviewer.md) <(awk '/^## Writing memory/{p=1} p' .claude/agents/$a.md) || { echo "## Writing memory drifted in $a"; exit 1; }; done

```

- [ ] **Step 3: Verify, negative-test the guard from a backup, commit**

```bash
awk '/^## Verification/{p=1} p' .claude/rules/cbk-conventions-reference.md | awk '/^```bash/{c=1;next} /^```/{c=0} c' > /tmp/p2-block.sh && bash -e /tmp/p2-block.sh > /tmp/p2-out.txt 2>&1 && grep -q 'verification: done' /tmp/p2-out.txt && echo GREEN
cp .claude/agents/cascade-rule-reviewer.md /tmp/crr.bak && sed -i 's/^- \*\*Entry shape\.\*\*/- **Entry shape (drift-test).**/' .claude/agents/cascade-rule-reviewer.md && grep -c 'drift-test' .claude/agents/cascade-rule-reviewer.md
bash -e /tmp/p2-block.sh >/dev/null 2>&1 && echo "UNEXPECTED GREEN" || echo "red as expected"
cp /tmp/crr.bak .claude/agents/cascade-rule-reviewer.md && bash -e /tmp/p2-block.sh >/dev/null 2>&1 && echo "GREEN again"
git add .claude/agents/adr-conformance-reviewer.md .claude/agents/logging-discipline-reviewer.md .claude/agents/cascade-rule-reviewer.md .claude/rules/cbk-conventions-reference.md
git commit -m "feat(agents): ## Writing memory in every shipped reviewer — dated claims, a falsifier per entry, one baseline per surface, the entry shape, a drift guard across the copies (#25 #49)" -m "Also closes #48 item 3: the memory-directory tripwire." -m "Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```
Expected: `GREEN`, `1` (the perturbation landed), `red as expected`, `GREEN again`.

---

### Task 6: The precedent-memory rule, the Surface inventory row, the bootstrap prompt, the gitignore comment (#25, #48 rule half, D25; C8 bullet 2)

**Files:**
- Modify: `.claude/rules/pr-review.md` — the `**Reviewer precedent memory.**` paragraph (rewritten in full; keeps Task 3's sentence)
- Modify: `.claude/rules/cbk-conventions.md § Surface inventory` — one row
- Modify: `.claude/skills/scaffold/references/bootstrap_checklist_template.md § 4` — the reviewer agent-memory bullet
- Modify: `.claude/skills/scaffold/references/manual_steps.md § Repository administration` — one row
- Modify: `.gitignore` — the comment above `.claude/agent-memory/`
- Modify: `.claude/rules/cbk-conventions-reference.md § Verification` — one check

- [ ] **Step 1: Rewrite the paragraph**

Save the paragraph below (one line) to `/tmp/p2-precedent.md`, then replace the whole line beginning `**Reviewer precedent memory.**` in `pr-review.md` with it (line-prefix locator, one match asserted):

```markdown
**Reviewer precedent memory.** The shipped reviewers declare `memory: project` — the agent-frontmatter memory declaration (`https://code.claude.com/docs/en/sub-agents`, verified 2026-09-06; re-verify the field and its paths after harness upgrades). Three facts from that page shape everything below. **Scopes and paths:** `project` is `.claude/agent-memory/<name>/`, meant to be committed; `local` is `.claude/agent-memory-local/<name>/`, never committed; `user` (`~/.claude/agent-memory/<name>/`) is not for a reviewer, whose precedents are one project's. **The prompt budget:** the reviewer's system prompt carries only the first 200 lines or 25 KB of its `MEMORY.md`, so the index is one line per surface, not per run. **The dependency:** subagent memory is part of auto memory — with `autoMemoryEnabled` off or `CLAUDE_CODE_DISABLE_AUTO_MEMORY` set, the `memory` field has no effect and the reviewer runs without memory; a reviewer that finds no memory directory says so. The memory root follows the directory the reviewer was dispatched from — `memory: project` is a relative path and a subagent starts in the main conversation's current working directory — so every sweep is launched from the repository root; `require-repo-root-for-agents.sh` refuses any other launch and `detect-forked-agent-memory.sh` blocks a hand-off while a stray tree exists. **The commit-versus-local choice is a Surface inventory row** (`cbk-conventions.md` § Surface inventory, "Reviewer agent-memory"), settled at scaffold's rule-file disposition pass: `project` means the directory is committed — precedents survive clones and get PR-reviewed like any contract change (the exercised default; delete the kit's `.claude/agent-memory/` line from `.gitignore`, a kit-repo-only exception) — and `local` means session-local calibration only. Memory updates ride the commit the review produced, never a separate commit. Across runs a reviewer accumulates four genres of precedent, and consulting them before flagging is what stops re-litigation of settled calls: **out-of-scope precedents** (`out-of-scope-`; a token or surface ruled outside this reviewer's contract — recorded with the *surface split*, since the same token can be in-scope on one surface and out on another, e.g. a log field vs a persisted column); **clean-review calibration baselines** (`clean-baseline-`; a clean review is a calibration asset — record *why* it was clean, what was checked and by what method, so the next run inherits the method, not just the verdict; **one baseline per surface, appended to in place** — a further clean pass on the same surface adds a dated delta line, and a new file is earned only by a new method; a baseline for a tree the project marks throwaway carries the expiry "delete when the tree is deleted"); **de-facto-convention prior art** (`convention-`; an established local pattern that deviates from a documented rule; a deviation worth keeping permanently belongs in the rule, not the memory); and **conforming-pattern records** (`conforming-`; both-polarity evidence — verified-conformant and verified-violating instances — with dates). Three further kinds carry their own prefixes: dependency facts (`dependency-`), findings with their disposition (`finding-`), and reusable verification techniques (`technique-`). **Every genre carries a reconsider trigger** — not only the convention genre: a baseline scoped to a snapshot of a moving set (an ADR range, a rule section) names the change that invalidates it, and a static drop condition is only one form; a **living record** appended across passes, naming the bar it re-decides against and holding a verdict that may revert, is the other. The entry discipline itself — dated and branch-named claims, a runnable falsifier per entry, the index line written with the body, the entry shape, compaction of living records, promotion of a thrice-cited precedent into rule text — is stated once, in every shipped reviewer's `## Writing memory` section, and the verification block keeps those copies identical.
```

```python
import pathlib
p = pathlib.Path('.claude/rules/pr-review.md'); lines = p.read_text().split('\n')
idx = [i for i,l in enumerate(lines) if l.startswith('**Reviewer precedent memory.**')]
assert len(idx) == 1, idx
lines[idx[0]] = pathlib.Path('/tmp/p2-precedent.md').read_text().rstrip('\n')
p.write_text('\n'.join(lines)); print('precedent paragraph rewritten')
```

- [ ] **Step 2: The Surface inventory row, the bootstrap prompt, the manual-steps row, the gitignore comment**

```python
import pathlib
def rep(path, pairs):
    p = pathlib.Path(path); t = p.read_text()
    for old, new in pairs:
        assert t.count(old) == 1, (path, old[:60], t.count(old)); t = t.replace(old, new, 1)
    p.write_text(t); print('edited', path)
t = pathlib.Path('.claude/rules/cbk-conventions.md').read_text()
old = next(l for l in t.split('\n') if l.startswith('- **Tooling conventions:**'))
rep('.claude/rules/cbk-conventions.md', [(old + '\n', old + '\n- **Reviewer agent-memory (`<project | local>`):** `<".claude/agent-memory/ — committed; the kit\'s .gitignore line deleted" | ".claude/agent-memory-local/ — never committed">` — settled at scaffold\'s rule-file disposition pass (`pr-review.md` § Reviewer precedent memory)\n')])
rep('.claude/skills/scaffold/references/bootstrap_checklist_template.md', [(
 "- **Reviewer agent-memory**: `memory: project` (committed under `.claude/agent-memory/`, precedents survive clones and get PR-reviewed) or `memory: local` (`.claude/agent-memory-local/`, never committed). Decision: <project | local>. Recorded in `cbk-conventions.md` § Surface inventory.",
 "- **Reviewer agent-memory**: `memory: project` (committed under `.claude/agent-memory/`, precedents survive clones and get PR-reviewed) or `memory: local` (`.claude/agent-memory-local/`, never committed; set the field in each reviewer's frontmatter). Decision: <project | local>. With `project`, delete the kit's `.claude/agent-memory/` line from `.gitignore` — it is a kit-repo-only exception and nothing flips it for you. Recorded in the \"Reviewer agent-memory\" row of `cbk-conventions.md` § Surface inventory.")])
t = pathlib.Path('.claude/skills/scaffold/references/manual_steps.md').read_text()
old = next(l for l in t.split('\n') if l.startswith('- **Branch protection rules**:'))
rep('.claude/skills/scaffold/references/manual_steps.md', [(old + '\n', old + '\n- **Reviewer agent-memory**: decided in the bootstrap checklist § Rule-file disposition (`project` = committed, `local` = never committed) and recorded in `cbk-conventions.md` § Surface inventory; with `project`, delete the kit\'s `.claude/agent-memory/` line from `.gitignore`.\n')])
rep('.gitignore', [(
 "# Reviewer precedent memory stays session-local in THIS repo: pr-review.md\n# ships the memory mechanism empty, so kit-session calibration must not ride\n# along when a target project copies .claude/. Target projects default the\n# other way — commit the directory — per pr-review.md § Reviewer precedent\n# memory.\n",
 "# Reviewer precedent memory stays session-local in THIS repo: pr-review.md\n# ships the memory mechanism empty, so kit-session calibration must not ride\n# along when a target project copies .claude/. Target projects default the\n# other way — commit the directory — per pr-review.md § Reviewer precedent\n# memory: when your Surface inventory row says `project`, DELETE this line\n# (scaffold's rule-file disposition pass prompts the choice; nothing flips it\n# for you).\n")])
```

- [ ] **Step 3: Verification — the row and its prompt exist (plain line, inside the fence, directly after the `## Writing memory` drift guard); commit**

```bash
# The commit-versus-local memory choice has a Surface inventory row for the bootstrap prompt to fill.
{ grep -q 'Reviewer agent-memory' .claude/rules/cbk-conventions.md && grep -q 'Reviewer agent-memory' .claude/skills/scaffold/references/bootstrap_checklist_template.md; } || { echo "the Reviewer agent-memory row or its bootstrap prompt is missing"; exit 1; }
```

```bash
awk '/^## Verification/{p=1} p' .claude/rules/cbk-conventions-reference.md | awk '/^```bash/{c=1;next} /^```/{c=0} c' > /tmp/p2-block.sh && bash -e /tmp/p2-block.sh > /tmp/p2-out.txt 2>&1 && grep -q 'verification: done' /tmp/p2-out.txt && echo GREEN
git add .claude/rules/pr-review.md .claude/rules/cbk-conventions.md .claude/skills/scaffold/references/bootstrap_checklist_template.md .claude/skills/scaffold/references/manual_steps.md .gitignore .claude/rules/cbk-conventions-reference.md
git commit -m "feat(rules): reviewer precedent memory — scopes, budget and the auto-memory dependency sourced; the commit-versus-local choice is a Surface inventory row; every genre carries a reconsider trigger (#25 #48)" -m "Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 7: Authoring a project-local reviewer — the archetypes, stated in the reference half (C8 bullet 3)

**Files:**
- Modify: `.claude/rules/pr-review-reference.md` — new section `## Authoring a project-local reviewer` before `## When to update this file`
- Modify: `.claude/rules/pr-review.md` — one pointer sentence at the end of the `**Authoring a project-local reviewer.**` paragraph

- [ ] **Step 1: The reference section**

Save the section below to `/tmp/p2-authoring.md` and insert it (verbatim, followed by a blank line) directly before the line `## When to update this file`:

```markdown
## Authoring a project-local reviewer

The contract's paragraph (`pr-review.md` § Project-local agents › Authoring) gives the shape; this is the craft that real runs settled on.

- **Two archetypes.** A **decision-text reviewer** checks a diff against clauses in frozen decision records (ADRs, a design-decisions file): it follows `Refines:` chains, quotes the clause, and reports the violated clause with the rubric class. Beneath it sits the **laws reviewer**: a domain contract stated as a table of *laws* (invariants a subsystem must hold — a clock discipline, a purity boundary, a schema's byte-identity), each law one checklist item. The laws reviewer is the semantic complement of a CI grep — where `ci/check-<thing>.sh` greps tokens at fixed paths, the reviewer judges what the tokens mean, and its report says which of the two caught each finding.
- **The section skeleton** (the exercised laws reviewer's, generalized): `## Inputs` · `## Contract surface (frozen sources, in precedence order)` · `## Checklist (grep-first, then read context)` · `## Do-not-flag guard list` (each entry with its eviction condition) · `## Not covered` · `## Report` · `## Hand-offs` · `## Writing memory` (the kit's shared section, last). A checklist item reads: the law's name and its source clause; the grep that finds candidates; the sanctioned sites the grep will also hit; what a hit means.
- **Grep-first checklist items.** Every item begins with the grep that finds candidates (`rg -n '<pattern>' <paths>`), then the semantic check on what the grep returned. A checklist item without a grep is a reviewer reading the whole diff on every run.
- **Standing refusals with their sanctioned alternative.** State what this reviewer never does — never proposes a new ADR (`/adr-new` is the route), never edits the diff (report, never propose a patch), never re-litigates a memory-recorded disposition — each with the route the work takes instead.
- **Stated coverage gaps.** A `## Not covered` list: the surfaces adjacent to this reviewer's contract that it does not check and who does. A reviewer without one is assumed to cover what it does not.
- **Report, never propose.** Findings are `file:line` + the violated clause + the rubric class + a one-sentence fix direction. Patches, rewrites and "here is the corrected block" are the executor's job after triage.
- **Two drift tripwires, in the body.** (1) *Roster:* "my entry in `pr-review.md` § Project-local agents must exist with my dispatch condition; if it does not, report myself as unregistered before reviewing" — the sweep reads that roster at runtime, so an unregistered reviewer never runs in it. (2) *Memory:* the memory-directory tripwire in `## Writing memory`.
- **Eviction conditions for guard lists.** Every do-not-flag entry carries the condition under which it is removed ("until the conventions formalize X"; "while `<file>` still carries `<token>`"). A guard list without eviction conditions only ever grows, and the reviewer's silence stops meaning anything.
- **Path-matched triggers come from usage, and are written for the roster reader.** The scope this section lists for a domain reviewer is the set of directories where the governed API is *used* (grep the tree for its calls and types), written as bare path prefixes on the reviewer's own entry line — the sweep's roster agent parses this section into `pathHints`, matches changed paths by prefix, and reports a glob or prose hint as dropped coverage.
```

```python
import pathlib
p = pathlib.Path('.claude/rules/pr-review-reference.md'); t = p.read_text()
old = "## When to update this file\n"
assert t.count(old) == 1
p.write_text(t.replace(old, pathlib.Path('/tmp/p2-authoring.md').read_text().rstrip('\n') + "\n\n" + old, 1)); print('authoring section inserted')
```

- [ ] **Step 2: The contract points at it**

```python
import pathlib
p = pathlib.Path('.claude/rules/pr-review.md'); t = p.read_text()
old = "Distinguish idiom *correctness* (flag) from idiom *preference* (Surface at most)."
assert t.count(old) == 1
p.write_text(t.replace(old, old + " The two archetypes (decision-text, laws), the section skeleton, grep-first items, standing refusals, stated gaps, the two drift tripwires and guard-list eviction live in `pr-review-reference.md` § Authoring a project-local reviewer; write a domain reviewer's scope on its entry line here as bare path prefixes, because the sweep's roster reader parses this section.", 1)); print('pointer appended')
```

- [ ] **Step 3: Verify and commit**

```bash
grep -n '^## Authoring a project-local reviewer' .claude/rules/pr-review-reference.md && grep -c 'Authoring a project-local reviewer' .claude/rules/pr-review.md
bash -e /tmp/p2-block.sh > /dev/null 2>&1 && echo GREEN
git add .claude/rules/pr-review-reference.md .claude/rules/pr-review.md
git commit -m "docs(pr-review): authoring a project-local reviewer — the laws archetype beneath the decision-text one, the section skeleton, grep-first items, standing refusals, stated gaps, report-never-propose, two drift tripwires, guard-list eviction" -m "Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 8: Hook authoring stated once; the analyzer exemplar; the mutation table and the registry as two views (C8 bullet 4)

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md` — new section `## Hook authoring` before `## Recommended planning-backend settings`; the "Mechanize the gates" paragraph gains its pointer
- Modify: `.claude/rules/cbk-conventions.md § Mutation discipline` — one paragraph after the table's closing sentence
- Create: `.claude/hooks/analyze-on-edit.sh` (executable, advisory, unregistered)
- Modify: `.claude/settings.json` — `_example_PostToolUse_analyzer` key; the ADVISORY sentence and the opening of `_comment_hooks` name the analyzer and the section
- Modify: `CLAUDE.md` (the hooks line gains `analyze-on-edit`), `README.md` (the analyzer row)

- [ ] **Step 1: The section**

Save the section below to `/tmp/p2-hook-authoring.md` and insert it (verbatim, followed by a blank line) directly before the line `## Recommended planning-backend settings` in `cbk-conventions-reference.md`:

```markdown
## Hook authoring

The shape every shipped hook follows, stated once (the registry comment in `.claude/settings.json` and the hook headers cite this section; they do not restate it).

- **Header.** Event and matcher on line 2; *why* in one paragraph with its dated source (a platform page or a dated real-run observation, never memory); `Blocked:` / `Allowed:` lines; a `Timing:` line when the guard reads state before the tool runs (a compound command is judged on the state at entry — create the branch and make the first commit in separate calls; return to the root as its own command before a dispatch); `Path:` naming the placeholder registration; `Tier:` on every hook.
- **The stdin / exit contract.** JSON on stdin (`tool_name`, `tool_input`, and the common fields, `cwd` among them — `https://code.claude.com/docs/en/hooks-guide` § How hooks work). Exit 2 + stderr blocks (deny), exit 0 allows; an ask-gate prints `hookSpecificOutput.permissionDecision: "ask"` with a reason and exits 0 (`https://code.claude.com/docs/en/hooks`: allow / deny / ask / defer). Matching hooks in one group run in parallel — never rely on order between two hooks on the same event. `Stop` takes no matcher; `SubagentStop` matches agent types, and a finishing subagent has no hand-off — a repair-before-stop hook belongs on `Stop`. Verified 2026-09-06; re-verify after harness upgrades.
- **Fail-open, with its backstop named.** On an environment defect (no `jq`, not a git checkout, an unset variable) a guard exits 0 with a stderr warning that names the surviving backstop — the CI lint, the Stop-tier hook, the verification block — never fails closed into a universal block. `set -uo pipefail`, deliberately not `set -e`; no bash-4-only builtins (`mapfile`), because a stock macOS bash is 3.2 and a "command not found" there is a fail-closed.
- **Project-relative paths, in placeholder form.** The registry names `${CLAUDE_PROJECT_DIR}/.claude/hooks/<name>.sh` — handlers run in the current directory (`https://code.claude.com/docs/en/hooks`), so a bare relative path is not found from a subdirectory, which is where a launch-directory guard must fire. The script derives its root from `CLAUDE_PROJECT_DIR` (falling back to `$PWD`) or, for a file-scoped hook, from the edited file's checkout (`git -C "$(dirname "$file")" rev-parse --show-toplevel`) — inside a worktree the project dir stays where the session started while the file lives in the worktree.
- **Four tiers** — hard-deny, ask-gate, advisory, stop — per § HITL gate load-bearing heuristics › Mechanize the gates; the registry comment names every hook under its tier with its mechanism and dated source, and states prerequisites and the canonical dry-run once.
- **The mutation table and the hook registry are two views of one list.** A `cbk-conventions.md` § Mutation discipline row that says "hook-enforced" names its hook; a registered guard names the row or the rule clause it enforces; adding either without the other is the drift the verification block's registry check catches.
- **Exemplar stanzas ship commented out.** An advisory hook the project must wire to its stack (a formatter, an analyzer) ships unregistered with its registration as an `_example_PostToolUse_*` key beside `hooks` — copied in after the case arms are filled — so a fresh checkout never runs a formatter it does not have.
- **An axis-conditional guard stays registered and inert.** A guard whose matcher names tools of an axis the project turned off (the knowledge-backend ask-gate on a `none` project) never fires because those tools are not connected; it may stay registered — it costs nothing — and it follows its rule file's disposition at bootstrap (deleted together with the rule, or kept with it).
- **An edit-time analyzer under the advisory contract.** `analyze-on-edit.sh` runs the project's analyzer on the package of every edited file and prints only *errors* to stderr, exit 0 always — a boundary violation surfaces at the edit, not at the `check` task. Its case arms are the project's; the exemplar ships with them commented, inside the `case`, so uncommenting is the whole wiring; placeholders are bare `ALL_CAPS` words, never `<angle-bracketed>`, because `<` and `>` are shell syntax once the arm is live.
- **Verify by payload.** Every branch of every hook is exercised by piping a crafted JSON payload and asserting the exact exit (only 2 denies — a crash is not a block), plus one real dispatch for a guard whose matcher is a dated observation. The launch-root guard's payloads run inside the verification block; a state-mutating dry-run — a stray memory tree, a commit on `main` — runs against a fixture or a throwaway clone and is recorded as a table in the PR body.
```

```python
import pathlib
p = pathlib.Path('.claude/rules/cbk-conventions-reference.md'); t = p.read_text()
old = "## Recommended planning-backend settings\n"
assert t.count(old) == 1
t = t.replace(old, pathlib.Path('/tmp/p2-hook-authoring.md').read_text().rstrip('\n') + "\n\n" + old, 1)
old2 = "for a condition the agent must repair before it hands off (a forked reviewer-memory tree). See the hook registry in `.claude/settings.json`."
assert t.count(old2) == 1
t = t.replace(old2, "for a condition the agent must repair before it hands off (a forked reviewer-memory tree). See the hook registry in `.claude/settings.json` and § Hook authoring.", 1)
p.write_text(t); print('hook authoring inserted; mechanize paragraph points at it')
```

- [ ] **Step 2: The mutation table's other view**

```python
import pathlib
p = pathlib.Path('.claude/rules/cbk-conventions.md'); t = p.read_text()
old = 'Cascade events being append-only is structurally important: the cascade IS the audit trail of decisions. A new framing supersedes an old one with a new file; the old one stays in `docs/cbk/` for future readers to understand "we used to think X, now we think Y."'
assert t.count(old) == 1
new = old + "\n\n**The table and the hook registry are two views of one list.** A row enforced by a hook names it: ADRs → `protect-immutable-adrs.sh` (plus the CI lint); lock files → `protect-lock-files.sh`. A hook that enforces a rule clause rather than a table row names the clause: `protect-main-branch.sh` → § Branch naming; `require-repo-root-for-agents.sh` and `detect-forked-agent-memory.sh` → `pr-review.md` § Reviewer precedent memory (one home for the memory tree); `guard-pr-state.sh` → the PR-state one-way door in `cbk-conventions-reference.md` § HITL gate load-bearing heuristics; `require-knowledge-backend-ok.sh` → `knowledge-backend.md` § HITL announcement discipline. Rows with no hook (the append-only cascade artifacts, the index's status column) are instruction-enforced and carry a deferred-hardening note per § HITL gate load-bearing heuristics. The registry in `.claude/settings.json` lists the same hooks under their tiers, and the verification block checks the registry against the files. The authoring shape lives in `cbk-conventions-reference.md` § Hook authoring."
p.write_text(t.replace(old, new, 1)); print('two-views paragraph added')
```

- [ ] **Step 3: The analyzer exemplar**

Create `.claude/hooks/analyze-on-edit.sh`:

```bash
#!/usr/bin/env bash
# PostToolUse hook (Edit|Write|MultiEdit matcher) — EXEMPLAR: a project copies
# this hook, wires its analyzer into the case arms below, and registers it via
# the `_example_PostToolUse_analyzer` stanza in settings.json.
#
# Runs the project's analyzer on the PACKAGE of every edited source file and
# prints only its ERRORS, so a boundary violation surfaces at the edit rather
# than at the `check` task. A real run measured under a second per package for
# its analyzer (2026-09-05); size yours the same way before registering — an
# analyzer that takes ten seconds per edit is a gate, not an advisory, and
# belongs in the check task instead.
#
# The root is derived from the edited file, not from CLAUDE_PROJECT_DIR:
# inside a worktree the project dir stays where the session started while the
# file lives in the worktree. Hooks in one PostToolUse group run in parallel
# (https://code.claude.com/docs/en/hooks-guide § How hooks work), so this may
# read the file before format-on-edit.sh rewrites it; that affects line numbers
# in its output, nothing else.
#
# Blocked:  nothing — advisory-only contract, like format-on-edit.sh: exit 0
#           ALWAYS. Errors go to stderr as non-fatal notes; warnings and infos
#           stay the check task's business.
# Allowed:  everything.
# Path:     registered (once wired) as ${CLAUDE_PROJECT_DIR}/.claude/hooks/…
# Tier:     ADVISORY.

set -uo pipefail
# Deliberately NOT `set -e` — see the advisory contract above.

command -v jq &>/dev/null || { echo "analyze-on-edit: jq not installed; skipping (advisory)." >&2; exit 0; }

input="$(cat)"
tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty')"
file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty')"

case "$tool_name" in
  Edit|Write|MultiEdit) ;;
  *) exit 0 ;;
esac

[[ -n "$file_path" ]] || exit 0
[[ "$file_path" == /* ]] || file_path="${cwd:-${CLAUDE_PROJECT_DIR:-$PWD}}/$file_path"
[[ -f "$file_path" ]] || exit 0

# The checkout the file lives in; its root is where the analyzer runs.
root="$(git -C "$(dirname "$file_path")" rev-parse --show-toplevel 2>/dev/null)" || {
  echo "analyze-on-edit: $file_path is not inside a git checkout; skipping (advisory)." >&2
  exit 0
}
rel="${file_path#"$root/"}"
case "$rel" in
  .venv/*|node_modules/*|dist/*|build/*|target/*|_build/*|vendor/*) exit 0 ;;
esac
cd "$root" || exit 0

# Wire one arm per source type your project analyzes, INSIDE this case, above
# the catch-all. Each arm: find the package the file belongs to (the nearest
# manifest above it), run the analyzer on that package, print only the error
# lines. Uncomment and fill in the example arm to wire it.
case "$file_path" in
#  *.EXT)
#    command -v YOUR_ANALYZER &>/dev/null || { echo "analyze-on-edit: YOUR_ANALYZER not on PATH; skipping $rel (advisory)." >&2; exit 0; }
#    pkg_dir="$(dirname "$file_path")"
#    while [[ "$pkg_dir" != "/" && "$pkg_dir" != "$root" && ! -f "$pkg_dir/MANIFEST" ]]; do pkg_dir="$(dirname "$pkg_dir")"; done
#    [[ -f "$pkg_dir/MANIFEST" ]] || { echo "analyze-on-edit: no MANIFEST above $rel; skipping (advisory)." >&2; exit 0; }
#    out="$(YOUR_ANALYZER "${pkg_dir#"$root/"}" 2>&1)"
#    errors="$(printf '%s\n' "$out" | grep -E 'ERROR_LINE_PATTERN' || true)"
#    if [[ -n "$errors" ]]; then
#      echo "analyze-on-edit: YOUR_ANALYZER reports errors after editing $rel (non-fatal):" >&2
#      printf '%s\n' "$errors" >&2
#    fi
#    ;;
  *) : ;;  # no analyzer configured yet — no-op; add arms above this catch-all
esac

exit 0
```

```bash
chmod +x .claude/hooks/analyze-on-edit.sh && bash -n .claude/hooks/analyze-on-edit.sh && echo "syntax ok"
printf '{"tool_name":"Edit","tool_input":{"file_path":"%s/README.md"},"cwd":"%s"}' "$PWD" "$PWD" | .claude/hooks/analyze-on-edit.sh; echo "exemplar on a real file → exit=$? (expect 0, silent)"
# the uncommented arm must also parse — only the case's lines are uncommented; the placeholders are bare ALL_CAPS words because an angle-bracket placeholder is shell syntax once live
sed '/^case "\$file_path" in/,/^  \*) : ;;/ { s/^#  \*\.EXT)/  *.EXT)/; s/^#    /    /; }' .claude/hooks/analyze-on-edit.sh > /tmp/analyze-uncommented.sh && bash -n /tmp/analyze-uncommented.sh && echo "uncommented arm parses"
```

- [ ] **Step 4: The stanza, the registry sentences, the indexes**

```python
import json, collections, pathlib
p = pathlib.Path('.claude/settings.json'); d = json.loads(p.read_text(), object_pairs_hook=collections.OrderedDict)
assert '_example_PostToolUse_analyzer' not in d
out = collections.OrderedDict()
for k, v in d.items():
    out[k] = v
    if k == '_example_PostToolUse_formatter':
        out['_example_PostToolUse_analyzer'] = collections.OrderedDict([
            ('_comment', "Copy this object into hooks.PostToolUse after wiring .claude/hooks/analyze-on-edit.sh's case arm to your analyzer (measure it first: under a second per package, or it belongs in the check task). Advisory tier: exit 0 always; errors only."),
            ('matcher', 'Edit|Write|MultiEdit'),
            ('hooks', [collections.OrderedDict([('type','command'),('command','${CLAUDE_PROJECT_DIR}/.claude/hooks/analyze-on-edit.sh')])]),
        ])
assert '_example_PostToolUse_analyzer' in out
c = out['_comment_hooks']
old = "ADVISORY (PostToolUse, exit 0 always) ships as unregistered exemplars: format-on-edit.sh (the `_example_PostToolUse_formatter` key below — copy it into hooks.PostToolUse after wiring the case arms to your stack). "
assert c.count(old) == 1
c = c.replace(old, "ADVISORY (PostToolUse, exit 0 always) ships as unregistered exemplars with their stanzas beside `hooks`: format-on-edit.sh (`_example_PostToolUse_formatter`) and analyze-on-edit.sh (`_example_PostToolUse_analyzer` — the project's analyzer on the edited file's package, errors only; measured under a second per package on a real run, 2026-09-05) — copy a stanza into hooks.PostToolUse after wiring its case arms to your stack. ")
old2 = "(cbk-conventions-reference.md § HITL gate load-bearing heuristics › Mechanize the gates)."
assert c.count(old2) == 1
c = c.replace(old2, "(cbk-conventions-reference.md § HITL gate load-bearing heuristics › Mechanize the gates; the authoring shape is § Hook authoring).")
out['_comment_hooks'] = c
p.write_text(json.dumps(out, indent=2, ensure_ascii=False) + '\n'); print('analyzer stanza added')
def rep(path, pairs):
    p = pathlib.Path(path); t = p.read_text()
    for old, new in pairs:
        assert t.count(old) == 1, (path, old[:60], t.count(old)); t = t.replace(old, new, 1)
    p.write_text(t); print('edited', path)
rep('CLAUDE.md', [("+ advisory exemplar, unregistered (format-on-edit) + stop (detect-forked-agent-memory)", "+ advisory exemplars, unregistered (format-on-edit, analyze-on-edit) + stop (detect-forked-agent-memory)")])
rep('README.md', [("│   └── format-on-edit.sh              ← advisory exemplar (unregistered; stanza in settings.json)",
                   "│   ├── format-on-edit.sh              ← advisory exemplar (unregistered; stanza in settings.json)\n│   └── analyze-on-edit.sh             ← advisory exemplar (unregistered; stanza in settings.json)")])
```
Then `jq empty .claude/settings.json && echo ok`.

- [ ] **Step 5: Verify and commit**

```bash
awk '/^## Verification/{p=1} p' .claude/rules/cbk-conventions-reference.md | awk '/^```bash/{c=1;next} /^```/{c=0} c' > /tmp/p2-block.sh && bash -e /tmp/p2-block.sh > /tmp/p2-out.txt 2>&1 && grep -q 'verification: done' /tmp/p2-out.txt && echo GREEN
for h in .claude/hooks/*.sh; do bash -n "$h" || echo "SYNTAX $h"; done
git add .claude/rules/cbk-conventions-reference.md .claude/rules/cbk-conventions.md .claude/hooks/analyze-on-edit.sh .claude/settings.json CLAUDE.md README.md
git commit -m "docs(hooks): hook authoring stated once, the mutation table and the registry as two views, the edit-time analyzer exemplar with its stanza" -m "Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 9: Indexes, test cases, the full battery

**Files:**
- Modify: `CLAUDE.md` (the cascade table's `/finish` row; the `/finish is the executor` principle bullet), `README.md` (line 20's `/finish` summary), `.claude/rules/workflows.md` § Index (the `pr-review.md` row), `.claude/rules/tooling.md` § Plugins (two rows)
- Modify: `.claude/skills/rough-in/references/test_cases.md` (the canonical case), `.claude/skills/scaffold/references/test_cases.md` (the canonical case)

- [ ] **Step 1: The indexes say floor + sweep**

```python
import pathlib
def rep(path, pairs):
    p = pathlib.Path(path); t = p.read_text()
    for old, new in pairs:
        assert t.count(old) == 1, (path, old[:60], t.count(old)); t = t.replace(old, new, 1)
    p.write_text(t); print('edited', path)
rep('CLAUDE.md', [
 ("A draft PR with code, tests, and review-toolkit triage", "A draft PR with code, tests, a `## Review gate` block (the two-skill floor, actually invoked, plus the bounded sweep) and the `## Triage` block"),
 ("does not skip `/simplify` or `pr-review-toolkit:review-pr`", "does not skip `/simplify` or `pr-review-toolkit:review-pr` (the floor — two skills actually invoked, once, recorded in the PR body's `## Review gate` block; the orchestrated sweep supplements and never substitutes)"),
])
rep('README.md', [("(code, tests, simplify, review-toolkit triage)", "(code, tests, the review floor + bounded sweep, triage)")])
rep('.claude/rules/workflows.md', [("Four-class rubric; dispatch roster; adversarial-verify option", "The two-skill floor and its `## Review gate` record; the bounded sweep that supplements; four-class rubric; dispatch roster")])
rep('.claude/rules/tooling.md', [
 ("| `pr-review-toolkit:review-pr` | Invoked by `/finish`'s review pass (directly or via the `review-sweep` workflow); **non-skippable** |",
  "| `pr-review-toolkit:review-pr` | Invoked **as a skill** by `/finish`'s review pass — one half of the floor; the `review-sweep` workflow runs beside it and never substitutes; **non-skippable** |"),
 ("| `/simplify` | Invoked by `/finish`'s simplify pass; **non-skippable** |",
  "| `/simplify` | Invoked **as a skill** by `/finish`'s simplify pass — the other half of the floor; **non-skippable** |"),
])
```

- [ ] **Step 2: Test cases cover the new default paths**

```python
import pathlib
def add_bullet(path, case_heading, marker, bullet):
    p = pathlib.Path(path); t = p.read_text()
    s = t.index(case_heading); m = t.index(marker, s)
    assert t[m-2:m] == '\n\n', repr(t[m-4:m])
    p.write_text(t[:m-1] + bullet + '\n\n' + t[m:]); print('bullet added', path)
add_bullet('.claude/skills/rough-in/references/test_cases.md', '## Test 1', '**What failure looks like:**',
  "- The bundled `/finish` that Step 5.5 provisions carries the `## Review gate` bullet in its Step 10 body spec and the \"invoke as a skill\" wording in Steps 8–9; the repo copy is byte-parallel to the template body.")
add_bullet('.claude/skills/scaffold/references/test_cases.md', '## Test 1', '**What failure looks like:**',
  "- The bootstrap checklist's rule-file disposition pass settled the reviewer agent-memory choice, wrote it to the \"Reviewer agent-memory\" row of § Surface inventory, and — for `project` — deleted the kit's `.claude/agent-memory/` gitignore line.")
```

- [ ] **Step 3: The full battery**

```bash
awk '/^## Verification/{p=1} p' .claude/rules/cbk-conventions-reference.md | awk '/^```bash/{c=1;next} /^```/{c=0} c' > /tmp/p2-block.sh
[ -s /tmp/p2-block.sh ] && bash -e /tmp/p2-block.sh > /tmp/p2-final.txt 2>&1; echo "suite exit=$?"; grep 'always-loaded total\|verification: done' /tmp/p2-final.txt; grep 'always-loaded total' /tmp/p2-baseline.txt
for h in .claude/hooks/*.sh; do bash -n "$h" || echo "SYNTAX $h"; done; jq empty .claude/settings.json && echo "settings ok"
diff <(awk '/^--- BEGIN TEMPLATE ---/{flag=1; next} flag' .claude/skills/rough-in/references/finish-command.md) .claude/commands/finish.md && echo "finish copies byte-parallel"
diff -rq docs/adr .claude/skills/scaffold/references/adr-starters && echo "adr starters byte-parallel"
grep -rn '^- @\|^@docs/\|load via `@' .claude/ ; echo "no instruction-form @-import: exit=$?"
node .claude/workflows/tests/review-sweep-accounting.mjs
git status --short | wc -l
```
Expected: `suite exit=0` and `verification: done`; the always-loaded total up to about **8 KB** over the baseline (the floor's contract text in `pr-review.md`, the craft riders, the precedent paragraph and the Surface inventory row are always-loaded by design — record both numbers in the PR body as a budget decision, not a tolerance); no syntax errors; both byte-parallel lines; `exit=1`; `review-sweep accounting: 6 scenarios OK`; only this task's edits dirty.

- [ ] **Step 4: Commit**

```bash
git add CLAUDE.md README.md .claude/rules/workflows.md .claude/rules/tooling.md .claude/skills/rough-in/references/test_cases.md .claude/skills/scaffold/references/test_cases.md
git commit -m "docs: the indexes say floor + bounded sweep; test cases cover the review-gate body and the memory choice" -m "Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 10: The review pass — the floor, the dogfooded sweep, the draft PR

**Files:**
- Read: `/tmp/p2-baseline.txt`, `/tmp/p2-final.txt`, the Task 3 dry-run table (plus the real-dispatch row)

- [ ] **Step 1: The floor, as skills, once**

Invoke `/simplify` (the skill; four cleanup agents at the mid tier). Triage its findings by the four-class rubric; land Apply items one commit each; re-run the suite after each. Then invoke `pr-review-toolkit:review-pr` (the skill, no args) and, **concurrently**, the rewritten sweep:

```
Workflow({ name: "review-sweep", args: { base: "<base branch>", files: [<the pre-filtered changed-path list from git diff <base>...HEAD --name-only, minus docs/superpowers>] } })
```
Read the run's planned-agent log line before it finds anything. Expected: `1 roster + 8 finders + up to 8 retries + up to 8 verifiers = at most 25` (5 toolkit + 3 project reviewers), which is exactly this operator's per-workflow ceiling; if it reads larger, stop the run and fix the script — that is a Task 1 defect. When it returns, keep its `gateLine`. If the roster read degraded, the log says so and `droppedCoverage` names it — dispatch the three project reviewers directly and record the degradation on the gate line (that is the D19 behaviour under test).

- [ ] **Step 2: Triage**

Per `pr-review.md § Triage rubric`, read `pr-review-reference.md § Apply / Surface calibration` first. Apply items land as their own commits (suite green after each); Surface items are kept verbatim; the sweep's `confirmed` findings are triaged like any other, its `refuted` need no triage, its `unverified` are triaged as unverified (say so).

- [ ] **Step 3: The draft PR**

Base: if #54 has merged, rebase onto `origin/main` (Task 0 Step 2's command) and open against `main`; otherwise open with `--base feat/harvest-3-p1-self-consistency` and retarget with `gh pr edit <N> --base main` once #54 lands (the operator's call; say so in the hand-off).

```bash
git push -u origin feat/harvest-3-p2-review-gate
gh pr create --draft --base <main | feat/harvest-3-p1-self-consistency> --title "feat: harvest 3 P2 — the review gate is a floor, the sweep is bounded, memory does not fork" --body-file /tmp/p2-pr-body.md
```

`/tmp/p2-pr-body.md` carries, in this order:

1. A two-paragraph summary (the floor and its record; the bounded sweep, the two hooks, the memory and hook-authoring disciplines).
2. The close markers, each on its own line, verbatim:
   ```
   Closes #8
   Closes #9
   Closes #10
   Closes #11
   Closes #12
   Closes #25
   Closes #44
   Closes #48
   Closes #49
   Addresses #47 items 3 and 4 (items 1–2 are P4's)
   ```
3. **Basis and declined asks** (spec Verification item 7): which changes are issue-driven and which are spec-driven (D19: the 3/8 bounds, the planned-count log, the retry pass, the returned record, the four tiers, the crafted-payload verification, the craft riders; D25 and the harvest for C8's memory, authoring and hook-authoring disciplines); the literal asks not implemented, with the reason — #11's "fail loudly, never fall back" on a roster-read failure (D19: degrade to the toolkit dimensions and report the dropped coverage); #10's secondary proposal of a cap inside the finder prompt (the spec puts the bound at dedup and verify); #44's PR-template ask (the kit ships no PR template and `gh pr create --body-file` does not use one; the block's one home is the rule, cited by the executor); and the two departures from the exercised form — `Stop` only for the fork detector, and verify agents inheriting the session model — with the demonstration behind each.
4. The `## Review gate` block, in the shape `pr-review.md § The floor` states, filled from this run:
   ```
   ## Review gate
   - `/simplify` — ran: 4 cleanup agents, <N> findings, <N> applied
   - `pr-review-toolkit:review-pr` — ran: <N> agents, <N> findings, triaged <A/AwC/S/D/R>
   <the sweep's gateLine, transcribed verbatim>
   ```
5. An always-loaded bytes table (baseline / final, both from the suite's own line) with one sentence naming the growth as a budget decision.
6. The hook dry-run table from Task 3 Step 3 (every branch of both hooks, expected and observed) plus the real-dispatch row from Step 3b, dated.
7. The `## Triage` block with counts per class and the Surface items verbatim.
8. `Spec: docs/superpowers/specs/2026-09-06-cascade-kit-harvest-3-design.md · Plan: docs/superpowers/plans/2026-09-06-harvest-3-p2-review-gate.md` (both tracked; the plan is this branch's first commit).

Leave the PR in draft — the operator flips it.

---

## Self-review

**Spec coverage (C3, C8, D19, D25, § Verification):**
- C3 bullet 1 (rules rewrite, one commit, the prose surfaces swept; floor actually invoked; supplements never substitutes; hard-fail carve-out goes; `## Review gate` block; proportionality; once; break-glass waives one named half; finder prompt keeps asking for every finding, bound at dedup and verify) → Task 2 (the fourth surface, the sweep's meta, lands in Task 1 so no commit ships a meta describing a body that does not exist).
- C3 bullet 2 (script rewrite: Roster phase via a cheap structured agent, degrade on null or malformed with dropped coverage reported; collect, dedup on file:line:normalized title keeping the strongest severity and the converging dimensions, rank, bound 3 / 8 charged to the least-loaded reporter, overflow unverified, planned count including the roster agent logged before the find stage; half-filled verifier record is dropped coverage; retry escalates effort; the run returns its record; meta and final log say supplements never substitutes; the accounting exercised under stubs) → Task 1.
- C3 bullet 3 (two hooks + settings; four tiers; verified by crafted payloads asserting exit 2 plus one real dispatch; compound-command timing stated; placeholder paths because handlers run in the current directory) → Task 3.
- C3 bullet 4 (four craft riders) → Task 4.
- C8 bullet 1 (`## Writing memory` with a drift guard; every listed discipline item; prefixes matching the genres and kinds) → Task 5.
- C8 bullet 2 (`memory: project` vs `local`, the 200-line / 25 KB budget, the auto-memory dependency; the Surface inventory row prompted by the bootstrap checklist and echoed in the manual steps; updates ride the commit; throwaway baselines carry expiry) → Task 6.
- C8 bullet 3 (reviewer authoring: the two archetypes and the section skeleton, grep-first, standing refusals, CI-grep complement, stated gaps, report-never-propose, two tripwires, eviction; scopes written for the roster reader) → Task 7.
- C8 bullet 4 (hook authoring stated once; table and registry as two views with the clause map for hooks without a row; exemplar stanzas commented out inside the `case`; settings comments with mechanism and dated source per tier, prerequisites and the canonical command once; axis-conditional guard inert; edit-time analyzer) → Task 8.
- D19 (plain two-skill floor; bounds 3/8 with the planned count logged; roster failure degrades and reports; launch-root guard hard-deny) → Tasks 1, 2, 3. D25 (append-unless-new-method; the choice is a Surface inventory row) → Tasks 5, 6.
- Definition of done 1, 3, 4 → Task 9's battery (suite green from the reference half with the always-loaded count recorded; finish copies byte-parallel, now pinned in the block; hooks `bash -n`, payload dry-runs asserting the exact exit, `settings.json` valid, the four-tier comment matched against the array). Item 5 → Task 9 Step 2. Item 7 → Task 10's markers and its basis paragraph (nine closed, #47 repositioned with the reason, four literal asks declined with reasons).
- Issue asks outside a spec bullet: #48 item 4 (gate-side fork grep) → Task 3 Step 6; #9's anti-pattern → Task 2 Step 3; #9's hand-off echo → Task 2 Step 4; #10's `orchestration.md` exemplar sentence and #12's cross-reference → Task 1 Step 4; #11's "consumes § Project-local agents" claim → Task 2 Step 1 (stated true) and Task 1 (made true); #11's optional roster-prompt reference → Task 7 Step 2; #12's meta sizing → Task 1 (meta); #25's `manual_steps.md` companion → Task 6 Step 2.

**Placeholder scan:** every step carries its replacement text, its file content, or its command with an expected result; every edit is scripted with a single-match assertion. Bracketed tokens are the kit's template register (`<ext>`, `EXT`, `YOUR_ANALYZER`, `MANIFEST`, `ERROR_LINE_PATTERN`, `<project | local>`) or PR-body fields the executor fills from measured values.

**Consistency:** the bounds are `3` / `8` everywhere (`pr-review.md § Fan-outs are bounded`, the sweep's defaults and its verification greps, `orchestration.md`'s bullet, Task 10's expected ceiling of 25 including the roster agent); the gate-line shape in `pr-review.md § The floor`, the script's `gateLine`, `/finish` Step 10 and the PR body agree, and both floor lines carry the `invoked, not covered` alternative; the tier words `HARD-DENY`, `ASK-GATE`, `ADVISORY`, `STOP` in the registry comment are what the verification block asserts, and the prose forms are what CLAUDE.md, README and the conventions use; the seven typed filename prefixes in `## Writing memory` are the ones `pr-review.md § Reviewer precedent memory` cites, one per genre and one per further kind; the `## Writing memory` extraction in the drift guard reads from that heading to end-of-file, which is why the section is appended last in every reviewer; every hook command is `${CLAUDE_PROJECT_DIR}/…` and the executable check expands the placeholder; no task cites `§ Hook authoring` or names `analyze-on-edit` before Task 8 creates them; the `§` sigil is used for `##`/`###` headings and for bold lead-ins alike (the kit's existing convention).
