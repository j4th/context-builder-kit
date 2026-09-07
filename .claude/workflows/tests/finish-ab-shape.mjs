#!/usr/bin/env node
// Stub harness for finish-ab.js. No agent is dispatched: the script is loaded through load-workflow.mjs and run
// with stubbed agent()/parallel()/log()/phase(); the panel guard, the planned-count log, the arm-isolation
// instruction and the rank arithmetic are asserted. Run: node .claude/workflows/tests/finish-ab-shape.mjs
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
  const parallel = async (thunks) => Promise.all(thunks.map((t) => t().catch(() => null)));
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

// 5. A judge whose ranking omits an arm is dropped by name and its votes are not counted; the surviving
//    panel's order balance is re-checked and reported.
{
  const { result, logs } = await run(base, { armResult: armOk, judgeResult: (opts, prompt) => { const j = judgeOk(opts, prompt); if (/judge:2@/.test(opts.label)) j.ranking = ["P"]; return j; } });
  check(logs.some((l) => /dropped judges .*judge 2 \(Q>P\): malformed ranking/.test(l)), `a malformed ranking is named with its judge index and order (got: ${logs.filter((l) => /dropped/.test(l)).join(" | ")})`);
  check(result.ranks.P.length === 3 && result.ranks.Q.length === 3, `the malformed judge's votes are excluded from both arms (got ${JSON.stringify(result.ranks)})`);
  check(logs.some((l) => /surviving panel is unbalanced/.test(l)), "an unbalanced surviving panel is reported");
  check(Array.isArray(result.droppedJudges) && result.droppedJudges.length === 1, "droppedJudges is returned");
}

check(meta.name === "finish-ab" && Array.isArray(meta.phases) && meta.phases.length === 2, "meta literal is well-formed");
if (failures) { console.error(`finish-ab-shape: ${failures} failure(s)`); process.exit(1); }
console.log("finish-ab-shape: 10 scenarios ok");
