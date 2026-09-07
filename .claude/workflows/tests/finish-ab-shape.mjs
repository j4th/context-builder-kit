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
  check(/planned agents: 2 executors \+ 4 judges = 6/.test(logs[0] ?? ""), `planned count is the first log line (got: ${logs[0]})`);
  check(calls.length === 6, `six agents dispatched (got ${calls.length})`);
  const exec = calls.filter((c) => c.opts.phase === "Execute");
  check(exec.every((c) => c.opts.isolation === "worktree"), "every executor runs in its own worktree");
  check(calls.every((c) => c.opts.model && c.opts.effort), "every dispatch names model and effort");
  const armB = exec.find((c) => c.opts.label.includes("Q"));
  check(armB && armB.prompt.includes("Do not open .claude/commands/finish-procedure.md"), "arm B is told not to open arm A's file");
  check(exec.every((c) => !/arm [AB]\b/.test(c.opts.label)), "labels carry the anonymised id, never the arm letter");
  check(calls.filter((c) => c.opts.phase === "Judge").every((c) => !c.prompt.includes("arm A") && !c.prompt.includes("arm B")), "judges never see arm letters");
  check(result.ranks.P.join(",") === "1,2,1,2" && result.ranks.Q.join(",") === "2,1,2,1", `ranks follow each judge's ranking (got ${JSON.stringify(result.ranks)})`);
  check(result.flags.P === 2 && result.flags.Q === 0, `flags summed per arm (got ${JSON.stringify(result.flags)})`);
  check(result.plannedAgents === 6, "plannedAgents returned");
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

// 4. A missing arm is logged as dropped and described to the judges as MISSING.
{
  const { logs, calls } = await run(base, { armResult: (opts) => (opts.label.includes("Q") ? null : armOk(opts)), judgeResult: judgeOk });
  check(logs.some((l) => /dropped arms/.test(l)), "a null arm result is logged as dropped");
  check(calls.filter((c) => c.opts.phase === "Judge").every((c) => c.prompt.includes("MISSING")), "judges are told which arm is missing");
}

check(meta.name === "finish-ab" && Array.isArray(meta.phases) && meta.phases.length === 2, "meta literal is well-formed");
if (failures) { console.error(`finish-ab-shape: ${failures} failure(s)`); process.exit(1); }
console.log("finish-ab-shape: 4 scenarios ok");
