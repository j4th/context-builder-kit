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
  const agent = async (prompt, opts = {}) => {
    const label = opts.label ?? "";
    calls.push({ label, opts, prompt });
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
  // resolves a failed agent to null without throwing, so null is modelled by returning null (context-builder-kit#58 item 10).
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
  assert.ok(logs.some((l) => l.includes("budget ceiling")), "the degrade path logs WHY the roster read threw, not only that it degraded (context-builder-kit#72 item 3)");
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

// 29 — the bounds' defaults are 3 per dimension and 8 verified, and a bound of 0 is a bound (verifies nothing), never a
//      default: pinned by behaviour, not by the source text.
{
  const { out } = await scenario("default bounds", { args: { files: ["a"] }, roster: rosterOK, findings: {}, verdict: real });
  assert.deepEqual(out.bounds, { MAX_PER_DIMENSION: 3, MAX_VERIFY: 8 }, "the default bounds are 3 and 8");
  const { calls } = await scenario("zero verify", {
    args: { files: ["a"], maxVerify: 0 }, roster: rosterOK, findings: { "code-review": { findings: [F("a", 1, "x", "high")] } }, verdict: real,
  });
  assert.equal(calls.filter((c) => c.label.startsWith("verify:")).length, 0, "maxVerify 0 verifies nothing");
  n++;
}

// 30 — malformed arguments are refused before any agent runs: a bound that is not a whole number (−1 disabled the cost
//      guard; "8" became the string "138" in the planned count), a list argument that is not a list, and a verify
//      model above the workhorse tier.
for (const [args, re] of [
  [{ files: ["a"], maxVerify: -1 }, /maxVerify must be a whole number/],
  [{ files: ["a"], maxPerDimension: "3" }, /maxPerDimension must be a whole number/],
  [{ files: ["a"], finders: { key: "x" } }, /finders must be a list/],
  [{ files: "a.ts" }, /files must be a list/],
  [{ files: ["a"], verifyModel: "fable" }, /verifyModel must be/],
]) {
  let dispatched = 0;
  await assert.rejects(run(args, async () => { dispatched += 1; return null; }, async (t) => Promise.all(t.map((f) => f())), () => {}, () => {}), re);
  assert.equal(dispatched, 0, `${JSON.stringify(args)} is refused before any agent runs`);
}
n++;

// 31 — a caller finder whose key is already a dimension or a reviewer would share its per-dimension bound and hide their
//      convergence: it is dropped coverage with the reason, never dispatched; duplicate caller reviewers run once.
{
  const { out, calls } = await scenario("key collision", {
    args: { files: ["a"], reviewers: ["r1", "r1"], finders: [{ key: "code-review", prompt: "ratios" }, { key: "r1", prompt: "x" }] },
    roster: rosterOK, findings: {}, verdict: real,
  });
  assert.equal(calls.filter((c) => c.label === "find:r1").length, 1, "a duplicate caller reviewer runs once");
  assert.equal(calls.filter((c) => c.label === "find:code-review").length, 1, "the colliding finder is not dispatched beside the toolkit's code-review");
  assert.ok(out.droppedCoverage.some((d) => d.startsWith("code-review (caller finder whose key is already")) && out.droppedCoverage.some((d) => d.startsWith("r1 (caller finder whose key is already")), "each collision is dropped coverage, named");
  n++;
}

// 32 — a finding's path is normalised before the dedup key: `./src/a.ts`, `src/a.ts` and the repository-absolute spelling of
//      one changed file are one defect, one verify slot; and the schema asks for a line number from 1.
{
  const { calls } = await scenario("path spellings", {
    args: { files: ["src/a.ts"] }, roster: rosterOK,
    findings: { "code-review": { findings: [F("./src/a.ts", 3, "x", "high")] }, "comments": { findings: [F("src/a.ts", 3, "y", "high")] },
                "silent-failures": { findings: [F("/home/u/repo/src/a.ts", 3, "z", "high")] } },
    verdict: real,
  });
  assert.equal(calls.filter((c) => c.label.startsWith("verify:")).length, 1, "three spellings of one file:line take one verify slot");
  const schema = calls.find((c) => c.label.startsWith("find:")).opts.schema;
  assert.equal(schema.properties.findings.items.properties.line.type, "integer");
  assert.equal(schema.properties.findings.items.properties.line.minimum, 1);
  n++;
}

// 33 — a roster read that returns no reviewer at all (a renamed section, an empty reply) is dropped coverage, never a clean
//      "dropped coverage: none" — pr-review.md's reviewers run on every sweep.
{
  const { out } = await scenario("empty roster", { args: { files: ["a"] }, roster: { crossCutting: [], domain: [], note: "section not found" }, findings: {}, verdict: real });
  assert.ok(out.droppedCoverage.some((d) => d.startsWith("project-local reviewers (the roster read returned none")), `an empty roster is dropped coverage (got ${JSON.stringify(out.droppedCoverage)})`);
  n++;
}

// 34 — a caller finder with a prompt but no key is dropped for having no key, not for "neither prompt nor agentType".
{
  const { out } = await scenario("keyless finder", { args: { files: ["a"], finders: [{ prompt: "ratios" }] }, roster: rosterOK, findings: {}, verdict: real });
  assert.ok(out.droppedCoverage.some((d) => /^\(unnamed\) \(caller finder with no key\)$/.test(d)), `a keyless finder is dropped for its missing key (got ${JSON.stringify(out.droppedCoverage)})`);
  n++;
}

console.log(`review-sweep accounting: meta + body parse, ${n} scenarios OK`);
