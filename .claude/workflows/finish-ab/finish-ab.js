export const meta = {
  name: "finish-ab",
  description: "A/B/n of the /finish executor on one issue: two to four arms, each in its own git worktree at a named model and effort and under its own instruction files; a blind judge panel balanced so every arm is read in every position equally often, that verifies before it scores",
  phases: [
    { title: "Execute", detail: "two to four arms, each in its own git worktree, each reading its own instruction files and told not to open the others'" },
    { title: "Judge", detail: "blind judges reading the anonymised worktrees in balanced orders; ranks, contradicted claims, graft" },
  ],
}

// A worked exemplar of orchestration.md § The dispatch-mechanism decision (a Workflow: deterministic fan-out over
// the arms and a judge panel) and of § Fan-out discipline's judge-panel rule: every arm read in every position
// equally often (two arms: an even number, half per order), judges scoring dimensions and reporting contradicted
// claims before they rank. Every agent() names model and effort.
//
// args:
//   scratch — absolute path of the run's scratch directory; receives judges/judge-<n>.md, and holds
//             operator-brief.md and judge-rubric.md unless brief / rubric name them elsewhere
//   brief   — optional: absolute path of the operator brief (default <scratch>/operator-brief.md)
//   rubric  — optional: absolute path of the judge rubric (default <scratch>/judge-rubric.md)
//   repo    — "owner/name" the arms execute against (reads with gh only; the brief forbids remote writes)
//   issue   — the issue number every arm executes
//   base    — optional: the commit every arm starts from (a replay); omitted, an arm starts where its worktree does
//   arms    — two to four: [{ arm: "A", anon: "P", read: ".claude/commands/finish.md", verb: "satisfy it",
//                             also: [".claude/workflows/finish-ab/<run>/<extra>.md"], model: "opus", effort: "high" }, …]
//             `anon` is the only id a judge ever sees — but not the only thing that can name an arm: a rubric that
//             points at a file naming each arm's mode, or an arm's own untracked workspace (a subagent-driven arm's
//             `.sdd/`), reveals it too (context-builder-kit#69; judge-rubric.md lists what to strip).
//             `verb` is how the arm is told to use its files; `also` names
//             further instruction files that arm reads after `read`; `model` and `effort` override the run's defaults
//   judges  — [{ order: ["P","Q"], effort: "high" }, …] — every arm in every reading position equally often, so the
//             panel is a multiple of the arm count (two arms: an even count, half per order)
//   model   — optional, default "opus": the workhorse tier for executors and judges (never above the session's)
//   effort  — optional, default "high": the executors' effort unless an arm names its own; each judge carries its own
//   executed — optional: [{ anon, result }] for arms that already ran outside this workflow, then the Execute phase is
//             skipped and only the panel runs. A workflow agent has no Agent tool (.claude/rules/pr-review.md § The
//             floor records the probe, its Claude Code version and its date), so an arm that must dispatch subagents —
//             a subagent-driven arm, or a review floor with its fan-out — runs as a headless `claude -p` session
//             instead (`run-arms-headless.py`), and its structured result is handed in here

const S = args.scratch
const BRIEF = args.brief ?? `${S}/operator-brief.md`
const RUBRIC = args.rubric ?? `${S}/judge-rubric.md`
const MODEL = args.model ?? "opus"
const EFFORT = args.effort ?? "high"

// Every argument is validated before any dispatch: a run that pays for its executors and a judge panel
// and returns empty ranks because an id was mistyped is the silent failure this guard exists to stop.
for (const k of ["scratch", "repo", "issue"]) if (args[k] === undefined || args[k] === null || args[k] === "") throw new Error(`finish-ab: args.${k} is required`)
if (!Array.isArray(args.arms) || args.arms.length < 2 || args.arms.length > 4) throw new Error(`finish-ab: args.arms must name two to four arms (got ${Array.isArray(args.arms) ? args.arms.length : typeof args.arms})`)
args.arms.forEach((c) => { for (const k of ["arm", "anon", "read"]) if (!c || !c[k]) throw new Error(`finish-ab: every arm needs arm, anon and read (got ${JSON.stringify(c)})`) })
args.arms.forEach((c) => { if (c.also !== undefined && !(Array.isArray(c.also) && c.also.every((f) => typeof f === "string" && f))) throw new Error(`finish-ab: arm ${c.anon}'s also must be a list of file paths (got ${JSON.stringify(c.also)})`) })
const ids = args.arms.map((c) => c.anon)
if (new Set(ids).size !== ids.length) throw new Error(`finish-ab: anon ids must be distinct (got ${ids.join(", ")})`)
const armLabels = args.arms.map((c) => c.arm)
if (new Set(armLabels).size !== armLabels.length) throw new Error(`finish-ab: arm labels must be distinct — the returned record is the only map from each anon id back to its arm (got ${armLabels.join(", ")})`)
const N = ids.length
const judges = Array.isArray(args.judges) ? args.judges : []
if (judges.length === 0 || judges.length % N !== 0) throw new Error(N === 2
  ? `finish-ab: a two-arm panel needs an even number of judges, half per reading order (got ${judges.length})`
  : `finish-ab: a ${N}-arm panel needs a multiple of ${N} judges, so every arm can be read in every position equally often (got ${judges.length})`)
judges.forEach((j, i) => { if (!j || !Array.isArray(j.order) || j.order.length !== N || new Set(j.order).size !== N || !ids.every((id) => j.order.includes(id))) throw new Error(`finish-ab: judge ${i + 1}'s order must be a permutation of the arm ids ${ids.join(", ")} (got ${JSON.stringify(j && j.order)})`) })
const orderKey = (j) => j.order.join(">")
// Position balance: how often each arm is read at each position. Every cell equal is the Latin-square condition;
// for two arms it is the same thing as half the panel per order.
const positionCounts = (panel) => ids.map((id) => ids.map((_p, pos) => panel.filter((j) => j.order[pos] === id).length))
const balanced = (panel) => { const c = positionCounts(panel).flat(); return c.length > 0 && c.every((x) => x === c[0]) && c[0] > 0 }
if (!balanced(judges)) {
  const byOrder = {}
  judges.forEach((j) => { byOrder[orderKey(j)] = (byOrder[orderKey(j)] ?? 0) + 1 })
  throw new Error(N === 2
    ? `finish-ab: judges must split evenly across the two reading orders (got ${JSON.stringify(Object.entries(byOrder))})`
    : `finish-ab: every arm must be read in every position equally often (reads per arm per position: ${JSON.stringify(Object.fromEntries(ids.map((id, a) => [id, positionCounts(judges)[a]])))})`)
}

// executed, when given at all, must be the list the headless runner writes: a path or a map here would otherwise
// be ignored and the Execute phase would pay for workflow executors that cannot dispatch subagents.
if (args.executed !== undefined && args.executed !== null && !Array.isArray(args.executed)) throw new Error(`finish-ab: args.executed must be a list of { anon, result } (got ${typeof args.executed}); read the runner's executed.json and pass its contents`)
const EXECUTED = Array.isArray(args.executed) ? args.executed : null
if (EXECUTED) EXECUTED.forEach((e, i) => { if (!e || !ids.includes(e.anon)) throw new Error(`finish-ab: executed[${i}] must name one of the arm ids ${ids.join(", ")} (got ${JSON.stringify(e && e.anon)})`) })
if (EXECUTED && new Set(EXECUTED.map((e) => e.anon)).size !== EXECUTED.length) throw new Error(`finish-ab: executed names an arm more than once (got ${EXECUTED.map((e) => e.anon).join(", ")})`)
const plannedAgents = (EXECUTED ? 0 : N) + judges.length * 2
log(EXECUTED
  ? `finish-ab: planned agents: 0 executors (${EXECUTED.length} arms executed outside this workflow) + ${judges.length} judges + up to ${judges.length} judge retries = at most ${plannedAgents}`
  : `finish-ab: planned agents: ${N} executors + ${judges.length} judges + up to ${judges.length} judge retries = at most ${plannedAgents}, plus any subagents an arm dispatches itself`)

// run-arms-headless.py keeps a copy of this schema (a workflow script gets no fs to share a module). The copies differ
// in one field on purpose: `dispatched` is optional here, where the arm is a workflow agent and cannot dispatch, and
// required there, where a headless `claude -p` arm can. finish-ab-shape.mjs diffs the two.
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
    dispatched: { type: "array", items: { type: "object", required: ["role", "model", "effort"], properties: { role: { type: "string" }, model: { type: "string" }, effort: { type: "string" } } }, description: "every subagent you dispatched yourself, outside the review skills: its role, model and effort" },
    handoff: { type: "string" },
    notes: { type: "string" },
  },
}

const filesOf = (cell) => [cell.read, ...(cell.also ?? [])]
const othersFiles = (cell) => [...new Set(args.arms.filter((c) => c.anon !== cell.anon).flatMap(filesOf))].filter((f) => !filesOf(cell).includes(f))
const readLine = (cell) => (cell.also && cell.also.length ? `Then read ${cell.read} in full, then ${cell.also.join(", then ")} in full,` : `Then read ${cell.read} in your worktree in full`)
const baseLine = args.base ? ` Before anything else, create your branch at commit ${args.base} (\`git switch -c <branch> ${args.base}\`) — this run replays the issue from that commit, and nothing after it exists for you.` : ""
const armPrompt = (cell) => {
  const others = othersFiles(cell)
  const forbid = others.length ? `Do not open ${others.join(", ")} or anything under .claude/skills/` : "Do not open anything under .claude/skills/"
  return `You are executing issue #${args.issue} in the repository ${args.repo}, from inside a git worktree of your own — your current working directory. Read the operator brief at ${BRIEF} first; it states what non-interactive means for this run, the standing decisions, the hard limits and what to return.${baseLine}

${readLine(cell)} and ${cell.verb ?? "satisfy it"} for issue ${args.issue}, with the brief's non-interactive rules substituting only where the instructions would wait for the operator (the plan gate becomes PLAN.md, the push and PR become PR_BODY.md, operational criteria stay open). Read every input the instructions name, in full, before planning. ${forbid} — the files you were given, the issue and the inputs it names are your whole instruction. Invoke the skills it requires as skills. Return the structured result when the hand-off exists.`
}
const armModel = (cell) => cell.model ?? MODEL
const armEffort = (cell) => cell.effort ?? EFFORT

let arms
if (EXECUTED) {
  arms = args.arms.map((cell) => { const e = EXECUTED.find((x) => x.anon === cell.anon); return e ? { ...cell, result: e.result } : null })
} else {
  phase("Execute")
  arms = await parallel(args.arms.map((cell) => () =>
    agent(armPrompt(cell), {
      label: `arm:${cell.anon}@${armModel(cell)}/${armEffort(cell)}`,
      phase: "Execute",
      model: armModel(cell),
      effort: armEffort(cell),
      isolation: "worktree",
      agentType: "general-purpose",
      schema: ARM_SCHEMA,
    }).then((r) => ({ ...cell, result: r }))
  ))
}

// Junk structured output is a script-side problem: an arm result missing the fields the summary and the
// judges rely on is dropped and named, never dereferenced. Judging with an arm missing compares fewer arms
// than the panel was balanced for, so a dropped arm ends the run here with the record it has, and the judge
// panel is not paid for.
const wellFormedArm = (r) => r && Array.isArray(r.commits) && typeof r.worktree === "string" && typeof r.branch === "string" && Array.isArray(r.skills_invoked)
const done = arms.filter((a) => a && wellFormedArm(a.result))
const droppedArms = args.arms.filter((c) => !done.find((d) => d.anon === c.anon)).map((c) => { const got = arms.find((a) => a && a.anon === c.anon); return `${c.anon}: ${got && got.result ? "malformed result " + JSON.stringify(Object.keys(got.result)) : "no result"}` })
if (droppedArms.length) {
  log(`finish-ab: dropped arms (the judge panel is not dispatched; its balance assumed every arm): ${droppedArms.join("; ")}`)
  return { arms: done, droppedArms, judges: [], ranks: {}, flags: {}, panel: null, plannedAgents }
}
log(`finish-ab: ${done.length}/${N} arms returned: ${done.map((d) => `${d.anon}=${d.result.commits.length} commits, check exit ${d.result.check_exit}, skills [${d.result.skills_invoked.join(" ")}]${Array.isArray(d.result.dispatched) && d.result.dispatched.length ? `, ${d.result.dispatched.length} dispatched` : ""}`).join(" | ")}`)

const JUDGE_SCHEMA = {
  type: "object",
  required: ["scores", "ranking", "hallucinations", "graft", "word_counts", "notes"],
  properties: {
    measures: {
      type: "array",
      description: "only when the rubric defines them: the order-independent measures a run's verdict rule scores, one entry per arm, as observed facts",
      items: {
        type: "object",
        required: ["arm", "red_first", "commit_per_finding", "tags_resolve", "criteria_met", "contaminated_hunks"],
        properties: {
          arm: { type: "string" },
          red_first: { type: "boolean" }, commit_per_finding: { type: "boolean" }, tags_resolve: { type: "boolean" },
          criteria_met: { type: "array", items: { type: "string" } },
          contaminated_hunks: { type: "array", items: { type: "string" } },
        },
      },
    },
    scores: {
      type: "array",
      items: {
        type: "object",
        required: ["arm", "fidelity", "assumptions", "tests", "implementation", "gate_honesty", "reviewability", "prose", "overall", "check_exit_observed", "defects"],
        properties: {
          arm: { type: "string" },
          fidelity: { type: "number" }, assumptions: { type: "number" }, tests: { type: "number" }, implementation: { type: "number" },
          gate_honesty: { type: "number" }, reviewability: { type: "number" }, prose: { type: "number" }, overall: { type: "number" },
          check_exit_observed: { type: "integer", description: "exit status of the check task in that worktree: the runner's logged exit when your prompt names a log, else the exit when YOU ran it; -1 if neither" },
          defects: { type: "array", items: { type: "object", required: ["quote", "problem"], properties: { quote: { type: "string" }, problem: { type: "string" } } } },
        },
      },
    },
    ranking: { type: "array", items: { type: "string" }, minItems: N, maxItems: N, description: "every arm id, best to worst" },
    hallucinations: { type: "array", items: { type: "object", required: ["arm", "claim_verbatim", "contradicting_source"], properties: { arm: { type: "string" }, claim_verbatim: { type: "string" }, contradicting_source: { type: "string" } } } },
    graft: { type: "array", items: { type: "object", required: ["arm", "idea"], properties: { arm: { type: "string" }, idea: { type: "string" } } } },
    word_counts: { type: "array", items: { type: "object", required: ["arm", "pr_body", "plan", "added_lines"], properties: { arm: { type: "string" }, pr_body: { type: "integer" }, plan: { type: "integer" }, added_lines: { type: "integer" } } } },
    notes: { type: "string" },
  },
}

phase("Judge")
const byAnon = {}
done.forEach((d) => { byAnon[d.anon] = d.result })
// A headless run's runner ran the check task once per arm, after every arm finished (run-arms-headless.py
// run_checks): the judges read that log instead of each re-running the gate — eighteen parallel gates on one
// machine would have measured the machine, not the arms (context-builder-kit#69).
const gateOf = (id) => byAnon[id].runner_check
const describe = (id) => `${id}: worktree ${byAnon[id].worktree}, branch ${byAnon[id].branch}${gateOf(id) ? `, check task run once by the runner: exit ${gateOf(id).exit}, log ${gateOf(id).log}` : ""}`
const gateNote = done.some((d) => d.result.runner_check) ? " The runner ran the check task once in each worktree that names a log, after every arm finished: read that log and its exit — do not re-run the whole gate, since parallel gates on one machine measure the machine rather than the arms (re-running a single test file is fine) — and report that exit as check_exit_observed." : ""
// A judge reads; it never writes — the read-only rule for dispatched agents (orchestration.md § Fan-out discipline):
// an agent that edits a tracked file and restores it leaves a build tool judging a stale artifact fresh. Running the
// gate the rubric names is reading.
const READ_ONLY = "Never modify any worktree or the repository — not even to restore a file afterwards. Running the gate the rubric names is reading; to try anything else (a patch, a probe), copy what you need into a scratch directory and give it its own build cache."
const judgePrompt = (j, i) => `You are judge ${i + 1} of ${judges.length}. Read the rubric at ${RUBRIC} and apply it exactly. The ${N === 2 ? "two" : N} arms are, in the order you must read them: ${j.order.map(describe).join("; ")}.${gateNote} Read the operator brief at ${BRIEF} too, so you know what every arm was told. Verify against the sources the rubric names before scoring. Write your full report to ${S}/judges/judge-${i + 1}.md and return the structured result with one scores entry per arm named ${N === 2 ? j.order.join(" and ") : j.order.join(", ")}. Do not edit any file in any worktree or in the repository. ${READ_ONLY}`
const judgeOpts = (j, i, retry) => { const effort = j.effort ?? "high"; return { label: `judge:${i + 1}@${effort}${retry ? ":retry" : ""}`, phase: "Judge", model: MODEL, effort, agentType: "general-purpose", schema: JUDGE_SCHEMA } }

const judged = await parallel(judges.map((j, i) => () => agent(judgePrompt(j, i), judgeOpts(j, i, false))))
// A judge that returned nothing is retried once at the same order and effort — the retry pass, not the
// prompt, is the remedy (orchestration.md § Fan-out discipline).
const failedJudges = judges.map((_j, i) => i).filter((i) => !judged[i])
if (failedJudges.length) {
  log(`finish-ab: ${failedJudges.length} judge(s) returned nothing — retrying once: ${failedJudges.map((i) => `judge ${i + 1}`).join(", ")}`)
  const retried = await parallel(failedJudges.map((i) => () => agent(judgePrompt(judges[i], i), judgeOpts(judges[i], i, true))))
  failedJudges.forEach((i, k) => { judged[i] = retried[k] })
}

// A judge that returned nothing, or whose ranking is not exactly the arm ids, is dropped coverage:
// named by index and reading order, never a silent shrink of the panel (orchestration.md § Fan-out
// discipline — log what was dropped). The surviving panel is re-checked for position balance.
const wellFormed = (j) => j && Array.isArray(j.ranking) && j.ranking.length === N && ids.every((id) => j.ranking.includes(id))
const dropped = judges.map((j, i) => (wellFormed(judged[i]) ? null : `judge ${i + 1} (${j.order.join(">")}): ${judged[i] ? "malformed ranking " + JSON.stringify(judged[i].ranking) : "no result"}`)).filter(Boolean)
if (dropped.length) log(`finish-ab: dropped judges (no verdict counted): ${dropped.join("; ")}`)
const jok = judged.filter(wellFormed)
const survivors = judges.filter((_j, i) => wellFormed(judged[i]))
const survivingOrders = new Map()
survivors.forEach((j) => survivingOrders.set(orderKey(j), (survivingOrders.get(orderKey(j)) ?? 0) + 1))
if (jok.length < judges.length && !balanced(survivors)) log(`finish-ab: the surviving panel is unbalanced across reading orders (${[...survivingOrders.entries()].map(([k, v]) => `${k}: ${v}`).join(", ") || "none"}) — treat the ranks as advisory`)
// A well-formed ranking whose contradicted-claims list is missing or not a list counts zero flags rather than
// crashing after the panel is paid for (context-builder-kit#58 item 9) — but it is logged, because zero from a judge that reported
// nothing reads as a clean arm, and contradicted claims are the panel's first order-independent signal.
const claimsOf = (j) => (Array.isArray(j.hallucinations) ? j.hallucinations : [])
const noClaims = judges.map((j, i) => (wellFormed(judged[i]) && !Array.isArray(judged[i].hallucinations) ? `judge ${i + 1} (${j.order.join(">")})` : null)).filter(Boolean)
if (noClaims.length) log(`finish-ab: ${noClaims.join(", ")} returned no contradicted-claims list — counted as zero, so the arms' flags undercount`)
const ranks = {}
const flags = {}
ids.forEach((id) => {
  ranks[id] = jok.map((j) => j.ranking.indexOf(id) + 1)
  flags[id] = jok.reduce((n, j) => n + claimsOf(j).filter((h) => h.arm === id).length, 0)
})
const unattributed = jok.reduce((n, j) => n + claimsOf(j).filter((h) => !ids.includes(h.arm)).length, 0)
if (unattributed) log(`finish-ab: ${unattributed} contradicted-claim entr${unattributed === 1 ? "y" : "ies"} name no arm id and count for neither arm`)
log(`finish-ab: ranks: ${ids.map((id) => `${id}: ${ranks[id].join("/")}, flags ${flags[id]}`).join(" | ")}`)
return { arms: done, droppedArms: [], judges: jok, ranks, flags, droppedJudges: dropped, unattributedFlags: unattributed, panel: { planned: judges.length, returned: jok.length, byOrder: Object.fromEntries(survivingOrders) }, plannedAgents }
