export const meta = {
  name: "review-sweep",
  description: "Fan-out branch review: pr-review-toolkit dimensions + project reviewers, adversarially verified",
  whenToUse:
    "Dispatched by /finish's review pass (or ad-hoc pre-PR) when a multi-agent orchestration surface is available; direct dispatch of pr-review-toolkit:review-pr is the fallback (pr-review.md § When to invoke). The caller scouts the diff and passes {base, files, reviewers?}; when reviewers is omitted the workflow auto-selects the intersecting project reviewers from the changed paths (REVIEWER_TRIGGERS). Triage of the returned findings stays with the caller per .claude/rules/pr-review.md — this workflow finds and verifies; it never classifies.",
  phases: [
    { title: "Find", detail: "toolkit dimensions + intersecting project reviewers" },
    { title: "Verify", detail: "adversarial refute-by-default per finding", model: "opus" },
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

const TOOLKIT_DIMENSIONS = [
  { key: "code-review", agentType: "pr-review-toolkit:code-reviewer" },
  { key: "silent-failures", agentType: "pr-review-toolkit:silent-failure-hunter" },
  { key: "comments", agentType: "pr-review-toolkit:comment-analyzer" },
  { key: "test-coverage", agentType: "pr-review-toolkit:pr-test-analyzer" },
  { key: "type-design", agentType: "pr-review-toolkit:type-design-analyzer" },
];

// globs: null → always dispatched; otherwise dispatched when any changed file matches.
// This mirrors the authoritative roster in pr-review.md § Project-local agents
// (cross-cutting reviewers unconditional; domain reviewers path-matched) — when
// that section changes, update this map in the same change.
const REVIEWER_TRIGGERS = [
  { name: "adr-conformance-reviewer", globs: null },
  { name: "logging-discipline-reviewer", globs: null },
  { name: "cascade-rule-reviewer", globs: null },
  // Add project-authored domain reviewers with their path triggers, e.g.:
  // { name: "<your-domain>-reviewer", globs: [/^src\/<area>\//, /^lib\/<area>\//] },
];

// The runtime may deliver args as a JSON-encoded string; normalize before any
// access (a stringified files array would silently degrade auto-selection to
// the always-on reviewers).
const params = typeof args === "string" ? JSON.parse(args) : (args ?? {});

const files = params.files ?? [];
if (files.length === 0) {
  log(
    "review-sweep: WARNING — no files provided; conditional reviewers cannot auto-select and finders review the full base-diff",
  );
}
const autoReviewers = REVIEWER_TRIGGERS.filter(
  (r) => r.globs === null || files.some((f) => r.globs.some((g) => g.test(f))),
).map((r) => r.name);
const reviewers = params.reviewers ?? autoReviewers;
log(`review-sweep: project reviewers ${reviewers.join(", ") || "(none)"}`);

const dimensions = [
  ...TOOLKIT_DIMENSIONS,
  ...reviewers.map((name) => ({ key: name, agentType: name })),
];
const fileList = files.join("\n");
const base = params.base ?? "main";

const results = await pipeline(
  dimensions,
  (dim) =>
    agent(
      `Review the branch diff (git diff ${base}...HEAD), restricted to these changed files:\n${fileList}\n\nApply your standard review discipline. Respect the exclusion list in .claude/rules/pr-review.md § "What NOT to flag" — findings only on changed code, no theoretical risks without concrete preconditions. Report every surviving finding including medium/low confidence; adversarial verification happens downstream and triage happens in the caller.`,
      { label: `find:${dim.key}`, phase: "Find", agentType: dim.agentType, model: "sonnet", schema: FINDINGS_SCHEMA },
    ),
  (review, dim) =>
    review === null
      ? null
      : parallel(
          (review.findings ?? []).map((finding) => () =>
            agent(
              `Adversarially verify a review finding — your job is to REFUTE it. Finding (from ${dim.key}): "${finding.title}" at ${finding.file}${finding.line ? `:${finding.line}` : ""}. Detail: ${finding.detail}\n\nRead the actual code and any governing rule/ADR it cites. Default to real=false when the failure scenario cannot be demonstrated, an existing guard/test/CI check already covers it, or the finding misreads the code. Confirm real=true only with concrete evidence.`,
              { label: `verify:${finding.file}`, phase: "Verify", model: "opus", effort: "high", schema: VERDICT_SCHEMA },
            ).then((verdict) => ({ ...finding, dimension: dim.key, verdict })),
          ),
        ),
);

// A failed find agent is dropped coverage, not zero findings; a failed verify
// leaves a finding unverified, not dropped (pr-review.md § When to invoke).
const failedDimensions = dimensions.filter((_dim, i) => results[i] === null).map((d) => d.key);
if (failedDimensions.length > 0) {
  log(`review-sweep: WARNING — find agent failed for: ${failedDimensions.join(", ")} (coverage dropped; retry these)`);
}
const flat = results.filter(Boolean).flat().filter(Boolean);
const verified = flat.filter((f) => f.verdict);
const unverified = flat.filter((f) => !f.verdict);
const confirmed = verified.filter((f) => f.verdict.real);
const refuted = verified.filter((f) => !f.verdict.real);
log(
  `review-sweep: ${confirmed.length} confirmed, ${refuted.length} refuted, ${unverified.length} unverified (verify agent failed) across ${dimensions.length} dimensions (${failedDimensions.length} dropped)`,
);
return { confirmed, refuted, unverified, failedDimensions };
