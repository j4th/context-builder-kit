#!/usr/bin/env node
// Exercises .claude/workflows/review-sweep.js under stub agent/parallel/log/phase
// (no agent is dispatched) and asserts the invariants pr-review.md states:
// every deduplicated finding lands in exactly one of confirmed/refuted/unverified;
// convergence keeps the strongest severity and is charged to the least-loaded
// reporter; a dropped reviewer is named in droppedCoverage, not only in a log line;
// a null verifier is "unverified", never a crash; a null or malformed roster degrades;
// the roster reader's dirty output is sanitized; a domain reviewer is dispatched when
// its prefix matches and is out of scope (not dropped) when it does not; the retry
// pass escalates effort once; caller-supplied reviewers and finders are honoured.
import assert from "node:assert/strict";
import { loadWorkflow } from "./load-workflow.mjs";

// The parse check lives in the loader (one extraction, not two): the meta literal is evaluated as an
// object and the body as an async function — either failing to parse fails this harness.
const { meta, run } = loadWorkflow(new URL("../review-sweep.js", import.meta.url));
assert.equal(meta.name, "review-sweep");
assert.ok(Array.isArray(meta.phases) && meta.phases.length === 3, "meta.phases declares Roster, Find, Verify");

// findings[key] may be an object ({findings: […]}), null (the finder fails every time),
// or a function of the call's opts (vary the response per call — e.g. fail once, then succeed).
async function scenario(name, { args, roster, findings, verdict }) {
  const logs = [];
  const calls = [];
  const agent = async (_prompt, opts = {}) => {
    const label = opts.label ?? "";
    calls.push({ label, opts });
    if (label.startsWith("roster:")) return roster;
    if (label.startsWith("find:")) {
      const key = label.slice(5).replace(/:retry$/, "");
      const r = findings[key];
      if (typeof r === "function") return r(opts);
      return r === undefined ? { findings: [] } : r;
    }
    if (label.startsWith("verify:")) return verdict(label.slice(7), opts);
    throw new Error(`unexpected label ${label}`);
  };
  // A thunk that THROWS is a bug in this harness's own mock and must fail the test; the runtime
  // resolves a failed agent to null without throwing, so null is modelled by returning null (#58 item 10).
  const parallel = async (thunks) => Promise.all(thunks.map((t) => t()));
  const out = await run(args, agent, parallel, (m) => logs.push(m), () => {});
  const buckets = [...out.confirmed, ...out.refuted, ...out.unverified].map((f) => `${f.file}:${f.line}:${f.title}`);
  assert.equal(new Set(buckets).size, buckets.length, `${name}: a finding landed in two buckets`);
  return { out, logs, calls };
}

const F = (file, line, title, severity) => ({ file, line, title, detail: "d", severity });
const rosterOK = { crossCutting: ["adr-conformance-reviewer"], domain: [{ name: "schema-reviewer", pathHints: ["src/schema/"] }], note: "" };
const real = () => ({ real: true, reasoning: "r" });
let n = 0;

// 1 — convergence keeps the strongest severity; on tied loads the shared finding is charged to the
//     idle co-reporter, so the original reporter's unique finding survives its own bound.
{
  const { out } = await scenario("convergence", {
    args: { files: ["src/schema/a.ts"], maxPerDimension: 1, maxVerify: 8 },
    roster: rosterOK,
    findings: {
      "code-review": { findings: [F("a.ts", 1, "unique cr", "medium"), F("a.ts", 9, "shared", "low")] },
      "adr-conformance-reviewer": { findings: [F("a.ts", 9, "shared", "high")] },
    },
    verdict: real,
  });
  const shared = [...out.confirmed, ...out.unverified].find((f) => f.line === 9);
  assert.equal(shared.severity, "high", "dedup must keep the strongest severity");
  assert.ok(out.confirmed.some((f) => f.line === 9), "the converged finding is verified");
  assert.ok(out.confirmed.some((f) => f.title === "unique cr"), "the shared finding was charged to the idle co-reporter, so code-review's own unique finding kept its slot");
  assert.equal(out.unverified.length, 0, "nothing overflowed: two reporters, two slots, two findings");
  n++;
}

// 2 — no changed-file list: unmatched domain reviewers are dropped coverage, on the gate line;
//     cross-cutting reviewers still run.
{
  const { out } = await scenario("no files", { args: {}, roster: rosterOK, findings: {}, verdict: () => null });
  assert.ok(out.droppedCoverage.some((d) => d.includes("schema-reviewer")), "an unmatched domain reviewer with no file list is dropped coverage");
  assert.ok(out.gateLine.includes("schema-reviewer"), "the gate line names the dropped reviewer");
  assert.ok(out.reviewers.includes("adr-conformance-reviewer"), "a cross-cutting reviewer runs regardless of the file list");
  n++;
}

// 3 — a glob or prose hint is unmatchable: dropped coverage even with files.
{
  const { out } = await scenario("unusable hints", {
    args: { files: ["src/x.ts"] },
    roster: { crossCutting: [], domain: [{ name: "glob-reviewer", pathHints: ["src/**/*.ts"] }, { name: "prose-reviewer", pathHints: ["logging and telemetry surfaces"] }], note: "" },
    findings: {}, verdict: () => null,
  });
  assert.ok(out.droppedCoverage.some((d) => d.includes("glob-reviewer") && d.includes("prose-reviewer")));
  n++;
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
  n++;
}

// 5 — a null or malformed roster degrades to the toolkit dimensions and says so.
for (const roster of [null, { crossCutting: "not-an-array" }]) {
  const { out, logs } = await scenario("degrade", { args: { files: ["a"] }, roster, findings: {}, verdict: () => null });
  assert.deepEqual(out.reviewers, []);
  assert.ok(out.droppedCoverage.some((d) => d.includes("roster read failed")));
  assert.ok(logs.some((l) => l.includes("DEGRADED")));
  assert.equal(out.plannedAgents.roster, 1, "the roster agent is counted");
  n++;
}

// 6 — the planned count includes the roster agent and is logged before any find agent.
{
  const { out, logs } = await scenario("planned", { args: { files: ["a"] }, roster: rosterOK, findings: {}, verdict: () => null });
  assert.equal(out.plannedAgents.max, 1 + out.dimensions.length * 2 + out.bounds.MAX_VERIFY);
  assert.ok(logs.findIndex((l) => l.includes("planned agents")) < logs.findIndex((l) => l.includes("carrying")));
  n++;
}

// 7 — a domain reviewer whose prefix matches a changed file is dispatched.
{
  const { out } = await scenario("domain reviewer matched", { args: { files: ["src/schema/a.ts"] }, roster: rosterOK, findings: {}, verdict: () => null });
  assert.deepEqual(out.reviewers.slice().sort(), ["adr-conformance-reviewer", "schema-reviewer"].sort(), "a domain reviewer whose pathHint matches a changed file must be dispatched");
  assert.ok(out.dimensions.includes("schema-reviewer"));
  n++;
}

// 8 — a domain reviewer legitimately out of scope (files given, no match) is not dropped coverage.
{
  const { out, logs } = await scenario("domain reviewer out of scope", { args: { files: ["src/other/a.ts"] }, roster: rosterOK, findings: {}, verdict: () => null });
  assert.ok(!out.droppedCoverage.some((d) => d.includes("schema-reviewer")), "out of scope is not dropped coverage");
  assert.ok(logs.some((l) => l.includes("not path-matched") && l.includes("schema-reviewer")));
  n++;
}

// 9 — the roster reader's dirty output (backticks, parenthetical suffixes, padding) is sanitized.
{
  const dirty = {
    crossCutting: ["`adr-conformance-reviewer`", "cascade-rule-reviewer (all rule files)"],
    domain: [{ name: "`schema-reviewer` (owns schema)", pathHints: ["`src/schema/`", "  src/schema2/  "] }],
    note: "",
  };
  const { out } = await scenario("dirty roster", { args: { files: ["src/schema/a.ts"] }, roster: dirty, findings: {}, verdict: () => null });
  assert.deepEqual(out.reviewers.slice().sort(), ["adr-conformance-reviewer", "cascade-rule-reviewer", "schema-reviewer"].sort(), "backticks and parenthetical suffixes are stripped from names; hints are trimmed");
  n++;
}

// 10 — the per-dimension bound charges a converged finding to the truly idle reporter.
{
  const { out } = await scenario("asymmetric least-loaded owner", {
    args: { files: ["a"], maxPerDimension: 2, maxVerify: 8 }, roster: rosterOK,
    findings: {
      "code-review": { findings: [F("a", 1, "u1", "high"), F("a", 2, "u2", "high"), F("a", 3, "shared", "low")] },
      "adr-conformance-reviewer": { findings: [F("a", 3, "shared", "low")] },
    },
    verdict: real,
  });
  assert.ok(out.confirmed.some((f) => f.line === 3) || out.refuted.some((f) => f.line === 3), "the converged finding must be charged to the idle reporter, not reflexively to the first");
  n++;
}

// 11 — when every converging reporter is at its bound, the finding overflows rather than stealing a slot.
{
  const { out } = await scenario("convergence exhausts both owners", {
    args: { files: ["a"], maxPerDimension: 1, maxVerify: 8 }, roster: rosterOK,
    findings: {
      "code-review": { findings: [F("a", 1, "A only bug", "high"), F("a", 3, "shared low", "low")] },
      "adr-conformance-reviewer": { findings: [F("a", 2, "B only bug", "high"), F("a", 3, "shared low", "low")] },
    },
    verdict: real,
  });
  const shared = out.unverified.find((f) => f.line === 3);
  assert.ok(shared && /per-dimension bound/.test(shared.reason));
  assert.equal(out.confirmed.length + out.refuted.length, 2);
  n++;
}

// 12 — at equal severity, the more-converged finding wins a scarce verify slot.
{
  const { out } = await scenario("alsoFoundBy tie-break", {
    args: { files: ["a"], maxPerDimension: 5, maxVerify: 1 }, roster: rosterOK,
    findings: {
      "code-review": { findings: [F("a", 1, "solo", "medium"), F("a", 2, "converged", "medium")] },
      "adr-conformance-reviewer": { findings: [F("a", 2, "converged", "medium")] },
    },
    verdict: real,
  });
  assert.equal(out.confirmed.length, 1);
  assert.equal(out.confirmed[0].line, 2, "the converged finding wins the sole verify slot over the equal-severity solo finding");
  n++;
}

// 13 — a finder that fails twice is a failed dimension and dropped coverage.
{
  const { out, logs } = await scenario("finder fails twice", { args: { files: ["a"] }, roster: rosterOK, findings: { "code-review": null }, verdict: () => null });
  assert.ok(out.failedDimensions.includes("code-review"));
  assert.ok(out.droppedCoverage.some((d) => d.includes("code-review") && d.includes("failed twice")));
  assert.ok(logs.some((l) => l.includes("WARNING") && l.includes("code-review")));
  n++;
}

// 14 — the retry pass runs once, labelled :retry, at the retry effort (first pass at the find effort), and its findings count.
{
  let attempt = 0;
  const { out, calls } = await scenario("retry succeeds", {
    args: { files: ["a"] }, roster: rosterOK,
    findings: { "code-review": () => { attempt += 1; return attempt === 1 ? null : { findings: [F("a", 1, "found on retry", "medium")] }; } },
    verdict: real,
  });
  const findCalls = calls.filter((c) => c.label.startsWith("find:code-review"));
  assert.equal(findCalls.length, 2);
  assert.equal(findCalls[0].opts.effort, "medium");
  assert.equal(findCalls[1].label, "find:code-review:retry");
  assert.equal(findCalls[1].opts.effort, "high");
  assert.ok(out.confirmed.some((f) => f.title === "found on retry"));
  assert.ok(!out.failedDimensions.includes("code-review"));
  n++;
}

// 14b — two dimensions fail the first pass with mixed retry outcomes: the retried finding lands on ITS
// dimension (the index-list reindex — results[i] from retried[k]), the still-failing one is dropped by
// name, and nothing is misattributed. One failure cannot tell i from k; two can.
{
  const attempts = { "code-review": 0, "test-coverage": 0 };
  const { out } = await scenario("mixed retry outcomes", {
    args: { files: ["a"] }, roster: rosterOK,
    findings: {
      "code-review": () => { attempts["code-review"] += 1; return null; },
      "test-coverage": () => { attempts["test-coverage"] += 1; return attempts["test-coverage"] === 1 ? null : { findings: [F("a", 2, "found on the second dimension's retry", "medium")] }; },
    },
    verdict: real,
  });
  assert.deepEqual(attempts, { "code-review": 2, "test-coverage": 2 });
  const f = out.confirmed.find((x) => x.title === "found on the second dimension's retry");
  assert.ok(f, "the retried finding is counted");
  assert.equal(f.dimension, "test-coverage", `the retried finding is attributed to its own dimension (got ${f.dimension})`);
  assert.deepEqual(out.failedDimensions, ["code-review"]);
  n++;
}

// 15 — caller-supplied reviewers skip the roster agent; an explicit empty list means "no project reviewers".
{
  const { out, logs } = await scenario("caller reviewers", { args: { files: ["a"], reviewers: ["custom-reviewer"] }, roster: null, findings: {}, verdict: () => null });
  assert.equal(out.plannedAgents.roster, 0);
  assert.deepEqual(out.reviewers, ["custom-reviewer"]);
  assert.ok(!logs.some((l) => l.includes("DEGRADED")), "the roster agent must not run when the caller supplied reviewers");
  n++;
}
{
  const { out, logs } = await scenario("empty caller reviewers", { args: { files: ["a"], reviewers: [] }, roster: null, findings: {}, verdict: () => null });
  assert.equal(out.plannedAgents.roster, 0);
  assert.deepEqual(out.dimensions, ["code-review", "silent-failures", "comments", "test-coverage", "type-design"]);
  assert.ok(!logs.some((l) => l.includes("DEGRADED")));
  n++;
}

// 16 — caller-supplied finders are dispatched and accounted like any other dimension.
{
  const { out } = await scenario("caller finders", {
    args: { files: ["a"], finders: [{ key: "schema-timing", agentType: "some-agent-type" }] },
    roster: rosterOK, findings: { "schema-timing": { findings: [F("a", 3, "timing bug", "high")] } }, verdict: real,
  });
  assert.ok(out.dimensions.includes("schema-timing"));
  assert.ok(out.confirmed.some((f) => f.title === "timing bug" && f.dimension === "schema-timing"));
  n++;
}

// 17 — args delivered as a JSON string are normalized (a stringified bound would otherwise fall back to the default).
{
  const argsObj = { files: ["a"], maxVerify: 1 };
  const findings = { "code-review": { findings: [F("a", 1, "x", "high")] } };
  const { out: outObj } = await scenario("args object", { args: argsObj, roster: rosterOK, findings, verdict: real });
  const { out: outStr } = await scenario("args json string", { args: JSON.stringify(argsObj), roster: rosterOK, findings, verdict: real });
  assert.deepEqual(outStr.confirmed.map((f) => f.title), outObj.confirmed.map((f) => f.title));
  assert.equal(outStr.bounds.MAX_VERIFY, 1);
  n++;
}

// 18 — the gate line has the shape pr-review.md § The floor states (a regex, not a frozen string).
{
  const { out } = await scenario("gate line shape", {
    args: { files: ["a"] }, roster: rosterOK, findings: { "code-review": { findings: [F("a", 1, "x", "high")] } }, verdict: real,
  });
  assert.match(out.gateLine, /^- `review-sweep` — ran: \d+ finders \+ \d+ verifiers, \d+ confirmed \/ \d+ refuted \/ \d+ unverified, dropped coverage: (none|.+), bounds \d+\/\d+$/);
  n++;
}

// 19 — verify agents inherit the session model unless verifyModel tiers them down.
{
  const mk = (extra) => scenario("verify model", {
    args: { files: ["a"], ...extra }, roster: rosterOK, findings: { "code-review": { findings: [F("a", 1, "x", "high")] } }, verdict: real,
  });
  const { calls: c1 } = await mk({});
  assert.equal(c1.find((c) => c.label.startsWith("verify:")).opts.model, undefined, "no model pin by default — the ceiling rule");
  const { calls: c2 } = await mk({ verifyModel: "haiku" });
  assert.equal(c2.find((c) => c.label.startsWith("verify:")).opts.model, "haiku");
  n++;
}

// 20 — an all-slash hint normalizes to nothing and is unusable, never a match-everything.
{
  const { out } = await scenario("empty hint", {
    args: { files: ["src/x.ts"] },
    roster: { crossCutting: [], domain: [{ name: "slash-reviewer", pathHints: ["/"] }], note: "" },
    findings: {}, verdict: () => null,
  });
  assert.ok(!out.reviewers.includes("slash-reviewer"), "a bare / must not match every file");
  assert.ok(out.droppedCoverage.some((d) => d.includes("slash-reviewer")), "an empty hint is dropped coverage");
  n++;
}

// 21 — a hint is a prefix: it does not claim a sibling path that merely contains it.
{
  const { out } = await scenario("anchored prefix", { args: { files: ["test/src/schema/x.ts"] }, roster: rosterOK, findings: {}, verdict: () => null });
  assert.ok(!out.reviewers.includes("schema-reviewer"), "src/schema/ must not match test/src/schema/x.ts");
  n++;
}

// 22 — a reviewer named in both roster halves is dispatched once.
{
  const { out } = await scenario("reviewer listed twice", {
    args: { files: ["src/schema/a.ts"] },
    roster: { crossCutting: ["schema-reviewer"], domain: [{ name: "schema-reviewer", pathHints: ["src/schema/"] }], note: "" },
    findings: {}, verdict: () => null,
  });
  assert.deepEqual(out.reviewers, ["schema-reviewer"]);
  assert.equal(out.dimensions.filter((d) => d === "schema-reviewer").length, 1);
  n++;
}

// 23 — the effort pins: every first-pass finder at the find effort, the haiku roster call with no effort
//      (no dial), every verifier at high.
{
  const { calls } = await scenario("effort pins", {
    args: { files: ["src/a.ts"] },
    roster: { crossCutting: ["cascade-rule-reviewer"], domain: [], note: "" },
    findings: { "code-review": { findings: [F("a", 1, "x", "high")] } },
    verdict: () => ({ real: true, reasoning: "" }),
  });
  const finds = calls.filter((c) => c.label.startsWith("find:") && !c.label.endsWith(":retry"));
  assert.ok(finds.length > 0 && finds.every((c) => c.opts.effort === "medium"), "first-pass finders run at medium");
  assert.equal(calls.find((c) => c.label.startsWith("roster:")).opts.effort, undefined, "the haiku roster call carries no effort");
  const verifies = calls.filter((c) => c.label.startsWith("verify:"));
  assert.ok(verifies.length > 0 && verifies.every((c) => c.opts.effort === "high"), "verifiers run at high");
  n++;
}

// 24 — findEffort and retryEffort overrides reach the calls.
{
  let attempt = 0;
  const { calls } = await scenario("effort overrides", {
    args: { files: ["src/a.ts"], findEffort: "low", retryEffort: "xhigh" },
    roster: { crossCutting: [], domain: [], note: "" },
    findings: { "code-review": () => { attempt += 1; return attempt === 1 ? null : { findings: [] }; } },
    verdict: () => null,
  });
  const cr = calls.filter((c) => c.label.startsWith("find:code-review"));
  assert.equal(cr[0].opts.effort, "low");
  assert.equal(cr[1].label, "find:code-review:retry");
  assert.equal(cr[1].opts.effort, "xhigh");
  n++;
}

// 14 — a hint matches on a directory boundary, never on a common prefix.
{
  const { out } = await scenario("boundary-safe hint", {
    args: { files: ["src/schema-extra/a.ts"] },
    roster: rosterOK, findings: {}, verdict: () => null,
  });
  assert.ok(!out.reviewers.includes("schema-reviewer"), "src/schema must not claim src/schema-extra/");
  const { out: exact } = await scenario("boundary-safe hint (exact)", { args: { files: ["src/schema"] }, roster: rosterOK, findings: {}, verdict: () => null });
  assert.ok(exact.reviewers.includes("schema-reviewer"), "a changed path equal to the hint matches");
  n += 2;
}

// 15 — a roster read that THROWS degrades like a null read: gate line, dropped coverage, no crash.
{
  const logs = [];
  const agent = async (_prompt, opts = {}) => { if ((opts.label ?? "").startsWith("roster:")) throw new Error("budget ceiling"); return (opts.label ?? "").startsWith("verify:") ? null : { findings: [] }; };
  const parallel = async (thunks) => Promise.all(thunks.map((t) => t()));
  const out = await run({ files: ["a"] }, agent, parallel, (m) => logs.push(m), () => {});
  assert.deepEqual(out.reviewers, []);
  assert.ok(out.droppedCoverage.some((d) => d.includes("roster read failed")), "a throwing roster read is dropped coverage, not an aborted run");
  assert.ok(typeof out.gateLine === "string" && out.gateLine.length > 0, "the run still returns its gate line");
  n++;
}

// 16 — the least-loaded-owner bound with THREE converging reporters charges the idle one.
{
  const three = { crossCutting: ["adr-conformance-reviewer", "cascade-rule-reviewer"], domain: [], note: "" };
  const { out } = await scenario("three converging reporters", {
    args: { files: ["a"], maxPerDimension: 1, maxVerify: 8 }, roster: three,
    findings: {
      "code-review": { findings: [F("a", 1, "cr only", "high"), F("a", 5, "shared", "low")] },
      "adr-conformance-reviewer": { findings: [F("a", 2, "adr only", "high"), F("a", 5, "shared", "low")] },
      "cascade-rule-reviewer": { findings: [F("a", 5, "shared", "low")] },
    },
    verdict: real,
  });
  assert.ok(out.confirmed.some((f) => f.line === 5), "the three-way shared finding is charged to the reporter with no other finding and verified");
  assert.ok(out.confirmed.some((f) => f.title === "cr only") && out.confirmed.some((f) => f.title === "adr only"), "neither loaded reporter loses its own unique finding to the shared one");
  n++;
}

console.log(`review-sweep accounting: meta + body parse, ${n} scenarios OK`);
