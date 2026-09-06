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
