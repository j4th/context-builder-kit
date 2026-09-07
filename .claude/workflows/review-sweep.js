export const meta = {
  name: "review-sweep",
  description: "The focused review that runs beside pr-review-toolkit:review-pr: project reviewers always, plus the finders this diff needs — deduplicated, bounded, adversarially verified. Supplements, never substitutes.",
  whenToUse:
    "Runs BESIDE pr-review-toolkit:review-pr, after /simplify, when a multi-agent orchestration surface is available. The governing rule is .claude/rules/pr-review.md § The orchestrated sweep supplements; it never substitutes: the floor is the two skills actually invoked and this workflow discharges neither; it is sized to the diff, never to the session's effort setting; it reads the reviewer roster from pr-review.md at runtime and degrades to the toolkit dimensions when that read fails; it bounds at dedup and verify (3 per dimension, 8 verified by default), logs the planned agent count before the find stage, returns anything a bound drops as unverified, and returns its own gate line. The caller scouts the diff and passes {base, files, reviewers?, finders?, maxPerDimension?, maxVerify?, verifyModel?} — always pass files; verify agents inherit the session model unless verifyModel names a lower tier. Triage stays with the caller: this workflow finds and verifies; it never classifies.",
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
      pathHints: (Array.isArray(d.pathHints) ? d.pathHints : []).map((h) => String(h).replace(/`/g, "").trim().replace(/^\/+|\/+$/g, "")).filter((h) => h !== ""),
    }));
    // A hint that is a glob or prose can never match a path, and an empty one
    // (a bare "/") was filtered above: that reviewer is dropped coverage, not
    // "not in scope".
    const unusable = domain.filter((d) => !d.pathHints.length || d.pathHints.every((h) => /[*?]|\s/.test(h)));
    if (unusable.length) droppedCoverage.push(`domain reviewers with unmatchable pathHints (empty, glob or prose): ${unusable.map((d) => d.name).join(", ")}`);
    const usable = domain.filter((d) => !unusable.includes(d));
    // Hints are directory prefixes (pr-review.md § Reviewer craft rules), so the match is anchored
    // at the path's start — a substring match would let src/schema/ claim test/src/schema/x.
    const matched = usable.filter((d) => files.some((f) => d.pathHints.some((h) => f.startsWith(h)))).map((d) => d.name);
    const skipped = usable.filter((d) => !matched.includes(d.name)).map((d) => d.name);
    if (skipped.length) {
      log(`review-sweep: domain reviewers not path-matched by this diff: ${skipped.join(", ")}`);
      if (files.length === 0) droppedCoverage.push(`domain reviewers (no changed-file list to match): ${skipped.join(", ")}`);
    }
    reviewers = [...new Set([...crossCutting, ...matched])];
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
// dimension that reported it, and on a tie to a CO-reporter rather than the
// original (a shared finding should not consume the slot the original needs for
// what only it found) — then the overall verification bound. Anything a bound drops is
// returned as unverified with its reason — no silent caps (orchestration.md).
const perDim = new Map();
const kept = [];
const overflow = [];
for (const f of deduped) {
  const reporters = [f.dimension, ...f.alsoFoundBy];
  const owner = reporters.reduce((a, b) => ((perDim.get(b) ?? 0) <= (perDim.get(a) ?? 0) ? b : a));
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
