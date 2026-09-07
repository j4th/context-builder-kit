export const meta = {
  name: "finish-ab",
  description: "Two-arm A/B of the /finish executor on one issue: arm A follows the procedure, arm B the contract; each in its own git worktree at one named model and effort; a balanced blind judge panel (even count, half per reading order) that verifies before it scores",
  phases: [
    { title: "Execute", detail: "two arms, each in its own git worktree, each reading one instruction file and told not to open the other" },
    { title: "Judge", detail: "blind judges reading the anonymised worktrees in alternating orders; ranks, contradicted claims, graft" },
  ],
}

// A worked exemplar of orchestration.md § The dispatch-mechanism decision (a Workflow: deterministic fan-out over
// two arms and a judge panel) and of its judge-panel rule: an even number of judges, half per reading order,
// scoring dimensions and reporting contradicted claims before they rank. Every agent() names model and effort.
//
// args:
//   scratch — absolute path of the run's scratch directory; holds operator-brief.md and judge-rubric.md and
//             receives judges/judge-<n>.md
//   repo    — "owner/name" the arms execute against (reads with gh only; the brief forbids remote writes)
//   issue   — the issue number both arms execute
//   arms    — exactly two: [{ arm: "A", anon: "P", read: ".claude/commands/finish-procedure.md", verb: "follow it exactly as written, every step in order" },
//                          { arm: "B", anon: "Q", read: ".claude/commands/finish.md", verb: "satisfy it" }]
//             `anon` is the only id a judge ever sees; `verb` is how the arm is told to use its file
//   judges  — [{ order: ["P","Q"], effort: "high" }, { order: ["Q","P"], effort: "high" }, …] — even count, half per order
//   model   — optional, default "opus": the workhorse tier for executors and judges (never above the session's)
//   effort  — optional, default "high": the executors' effort; each judge carries its own

const S = args.scratch
const BRIEF = `${S}/operator-brief.md`
const RUBRIC = `${S}/judge-rubric.md`
const MODEL = args.model ?? "opus"
const EFFORT = args.effort ?? "high"

if (!Array.isArray(args.arms) || args.arms.length !== 2) throw new Error("finish-ab: args.arms must name exactly two arms")
const judges = Array.isArray(args.judges) ? args.judges : []
if (judges.length === 0 || judges.length % 2 !== 0) throw new Error(`finish-ab: a two-arm panel needs an even number of judges, half per reading order (got ${judges.length})`)
const orderKey = (j) => j.order.join(">")
const orders = new Map()
judges.forEach((j) => orders.set(orderKey(j), (orders.get(orderKey(j)) ?? 0) + 1))
const counts = [...orders.values()]
if (orders.size !== 2 || counts[0] !== counts[1]) throw new Error(`finish-ab: judges must split evenly across the two reading orders (got ${JSON.stringify([...orders.entries()])})`)

const plannedAgents = args.arms.length + judges.length
log(`finish-ab: planned agents: ${args.arms.length} executors + ${judges.length} judges = ${plannedAgents}`)

const ARM_SCHEMA = {
  type: "object",
  required: ["branch", "worktree", "commits", "plan_path", "pr_body_path", "check_command", "check_exit", "tests_written", "skills_invoked", "operational", "gate_calls", "handoff", "notes"],
  properties: {
    branch: { type: "string" },
    worktree: { type: "string", description: "absolute path of the worktree you worked in" },
    commits: { type: "array", items: { type: "object", required: ["sha", "subject"], properties: { sha: { type: "string" }, subject: { type: "string" } } }, description: "oldest first" },
    plan_path: { type: "string" },
    pr_body_path: { type: "string" },
    check_command: { type: "string" },
    check_exit: { type: "integer" },
    tests_written: { type: "array", items: { type: "string" } },
    skills_invoked: { type: "array", items: { type: "string" }, description: "exact skill names actually invoked via the Skill tool" },
    operational: { type: "array", items: { type: "string" }, description: "criteria left open because they need the operator or a device" },
    gate_calls: { type: "array", items: { type: "string" }, description: "every decision you made where the flow would have waited for the operator" },
    handoff: { type: "string" },
    notes: { type: "string" },
  },
}

const otherFile = (cell) => args.arms.find((c) => c.arm !== cell.arm).read
const armPrompt = (cell) => `You are executing issue #${args.issue} in the repository ${args.repo}, from inside a git worktree of your own — your current working directory. Read the operator brief at ${BRIEF} first; it states what non-interactive means for this run, the standing decisions, the hard limits and what to return.

Then read ${cell.read} in your worktree in full and ${cell.verb ?? "satisfy it"} for issue ${args.issue}, with the brief's non-interactive rules substituting only where the instructions would wait for the operator (the plan gate becomes PLAN.md, the push and PR become PR_BODY.md, operational criteria stay open). Read every input the instructions name, in full, before planning. Do not open ${otherFile(cell)} or anything under .claude/skills/ — the file you were given, the issue and the inputs it names are your whole instruction. Invoke the skills it requires as skills. Return the structured result when the hand-off exists.`

phase("Execute")
const arms = await parallel(args.arms.map((cell) => () =>
  agent(armPrompt(cell), {
    label: `arm:${cell.anon}@${MODEL}/${EFFORT}`,
    phase: "Execute",
    model: MODEL,
    effort: EFFORT,
    isolation: "worktree",
    agentType: "general-purpose",
    schema: ARM_SCHEMA,
  }).then((r) => ({ ...cell, result: r }))
))

const done = arms.filter((a) => a && a.result)
const missing = args.arms.filter((c) => !done.find((d) => d.anon === c.anon))
if (missing.length) log(`finish-ab: dropped arms (no result): ${missing.map((m) => m.anon).join(", ")}`)
log(`finish-ab: ${done.length}/${args.arms.length} arms returned: ${done.map((d) => `${d.anon}=${d.result.commits.length} commits, check exit ${d.result.check_exit}, skills [${d.result.skills_invoked.join(" ")}]`).join(" | ")}`)

const JUDGE_SCHEMA = {
  type: "object",
  required: ["scores", "ranking", "hallucinations", "graft", "word_counts", "notes"],
  properties: {
    scores: {
      type: "array",
      items: {
        type: "object",
        required: ["arm", "fidelity", "assumptions", "tests", "implementation", "gate_honesty", "reviewability", "prose", "overall", "check_exit_observed", "defects"],
        properties: {
          arm: { type: "string" },
          fidelity: { type: "number" }, assumptions: { type: "number" }, tests: { type: "number" }, implementation: { type: "number" },
          gate_honesty: { type: "number" }, reviewability: { type: "number" }, prose: { type: "number" }, overall: { type: "number" },
          check_exit_observed: { type: "integer", description: "exit status of the check task when YOU ran it in that worktree; -1 if you could not" },
          defects: { type: "array", items: { type: "object", required: ["quote", "problem"], properties: { quote: { type: "string" }, problem: { type: "string" } } } },
        },
      },
    },
    ranking: { type: "array", items: { type: "string" }, minItems: 2, maxItems: 2, description: "both arm ids, best to worst" },
    hallucinations: { type: "array", items: { type: "object", required: ["arm", "claim_verbatim", "contradicting_source"], properties: { arm: { type: "string" }, claim_verbatim: { type: "string" }, contradicting_source: { type: "string" } } } },
    graft: { type: "array", items: { type: "object", required: ["arm", "idea"], properties: { arm: { type: "string" }, idea: { type: "string" } } } },
    word_counts: { type: "array", items: { type: "object", required: ["arm", "pr_body", "plan", "added_lines"], properties: { arm: { type: "string" }, pr_body: { type: "integer" }, plan: { type: "integer" }, added_lines: { type: "integer" } } } },
    notes: { type: "string" },
  },
}

phase("Judge")
const byAnon = {}
done.forEach((d) => { byAnon[d.anon] = d.result })
const describe = (id) => byAnon[id]
  ? `${id}: worktree ${byAnon[id].worktree}, branch ${byAnon[id].branch}`
  : `${id}: MISSING — the arm returned nothing; score it 1 on every dimension and say so`

const judged = await parallel(judges.map((j, i) => () => agent(
  `You are judge ${i + 1} of ${judges.length}. Read the rubric at ${RUBRIC} and apply it exactly. The two arms are, in the order you must read them: ${j.order.map(describe).join("; ")}. Read the operator brief at ${BRIEF} too, so you know what both arms were told. Verify against the sources the rubric names before scoring. Write your full report to ${S}/judges/judge-${i + 1}.md and return the structured result with one scores entry per arm named ${j.order.join(" and ")}. Do not edit any file in either worktree or in the repository.`,
  { label: `judge:${i + 1}@${j.effort ?? "high"}`, phase: "Judge", model: MODEL, effort: j.effort ?? "high", agentType: "general-purpose", schema: JUDGE_SCHEMA },
)))

// A judge that returned nothing, or whose ranking is not exactly the two arm ids, is dropped coverage:
// named by index and reading order, never a silent shrink of the panel (orchestration.md § Fan-out
// discipline — log what was dropped). The surviving panel is re-checked for order balance.
const ids = args.arms.map((c) => c.anon)
const wellFormed = (j) => j && Array.isArray(j.ranking) && j.ranking.length === ids.length && ids.every((id) => j.ranking.includes(id))
const dropped = judges.map((j, i) => (wellFormed(judged[i]) ? null : `judge ${i + 1} (${j.order.join(">")}): ${judged[i] ? "malformed ranking " + JSON.stringify(judged[i].ranking) : "no result"}`)).filter(Boolean)
if (dropped.length) log(`finish-ab: dropped judges (no verdict counted): ${dropped.join("; ")}`)
const jok = judged.filter(wellFormed)
const survivingOrders = new Map()
judges.forEach((j, i) => { if (wellFormed(judged[i])) survivingOrders.set(orderKey(j), (survivingOrders.get(orderKey(j)) ?? 0) + 1) })
const perOrder = [...survivingOrders.values()]
if (jok.length < judges.length && (perOrder.length !== 2 || perOrder[0] !== perOrder[1])) log(`finish-ab: the surviving panel is unbalanced across reading orders (${[...survivingOrders.entries()].map(([k, v]) => `${k}: ${v}`).join(", ") || "none"}) — treat the ranks as advisory`)
const ranks = {}
const flags = {}
ids.forEach((id) => {
  ranks[id] = jok.map((j) => j.ranking.indexOf(id) + 1)
  flags[id] = jok.reduce((n, j) => n + j.hallucinations.filter((h) => h.arm === id).length, 0)
})
log(`finish-ab: ranks: ${ids.map((id) => `${id}: ${ranks[id].join("/")}, flags ${flags[id]}`).join(" | ")}`)
return { arms: done, judges: jok, ranks, flags, droppedJudges: dropped, plannedAgents }
