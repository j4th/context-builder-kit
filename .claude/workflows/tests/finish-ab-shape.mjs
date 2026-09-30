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
