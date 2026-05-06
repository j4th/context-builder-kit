# Tooling template

Not a prose doc — a guide for what config artifacts to produce. Tooling is the **mechanical implementation** of decisions made in the prose docs (CLAUDE.md commands, STANDARDS.md CI gates, ARCHITECTURE.md tech stack). Never the other way around. If you find yourself making a tool decision in the tooling configs that wasn't already made in the prose docs, stop and add it to the right prose doc first.

## What to inherit before drafting

| From | What to extract | Where it goes |
|---|---|---|
| Stack decisions (this phase) — Language/framework | Runner choice (mise.toml, Makefile, justfile, package.json) | Task runner config |
| Stack decisions (this phase) — Testing/CI | Test framework, CI provider, CI gates | CI workflow file |
| CLAUDE.md (this phase) | Every command in CLAUDE.md must correspond to an actual task | Task runner config |
| STANDARDS.md (this phase) | CI Pipeline table | CI workflow file (one job per row) |
| `scaffold.md` quality bar | Strictness of pre-commit hooks (if any) | Optional pre-commit config |

**The "every CLAUDE.md command is an actual task" rule is non-negotiable.** If CLAUDE.md says `just check`, the justfile must define `check`. If CLAUDE.md says `mise run test`, the mise.toml must define `test`. Mismatch between CLAUDE.md commands and actual task definitions is a guaranteed failure mode — Claude Code will run a command that doesn't exist and the user will discover it during the first real session.

## Artifacts to produce

The set depends on stack decisions. Default set:

1. **Task runner config** (one of):
   - `mise.toml` — for projects using mise
   - `Makefile` — for traditional Unix projects
   - `justfile` — for projects using just
   - `package.json` scripts — for Node projects
   - `Cargo.toml` aliases or `xtask` — for Rust projects (or fall through to mise/just)
   - Whichever the user chose during stack decisions

   Must define at minimum: `setup`, `check`, `test`, `lint`, `dev` (or local equivalents).

2. **CI pipeline** at `.github/workflows/<name>.yml`:
   - One workflow file (or split if there's a clear reason)
   - Triggers: push to main, PR to main (default — confirm with user if differs)
   - Jobs match the rows of STANDARDS.md's CI Pipeline table — no surprise additions
   - The job that runs the equivalent of `check` locally **must produce identical results to running `check` locally**, otherwise local-vs-CI surprises become a recurring debug cost

3. **Env template** (`.env.example`):
   - Only if the project uses environment variables
   - All config keys with safe default values and one-line comments
   - Skip entirely if the project has no env config

4. **Optional**: review automation
   - `claude-code-action` workflow if scaffold.md's PR/review process said to use it (e.g., a "CI must trigger Claude code review on PRs" preference)
   - Skip if scaffold didn't ask for it

## Rules

- **Every command in CLAUDE.md = actual task definition.** No exceptions.
- **`check` locally = CI pipeline.** No surprises. If CI runs lint+typecheck+test, `check` runs lint+typecheck+test. If they diverge, local-vs-CI debugging becomes a recurring cost.
- **`mise install` (or equivalent) gets a new contributor everything.** Setup should be one command. If it's not, the README's "Install" section becomes a multi-step ordeal.
- **For pre-implementation projects**: produce config with placeholder tasks. Establishing the convention matters more than the implementation. A `test` task that runs `echo "no tests yet"` is fine for v0.1; the convention exists, the next phase fills it in.
- **No tooling that wasn't approved in stack decisions.** If stack decisions didn't pick a typechecker, the tooling configs don't add one. Surface the gap to the user instead of silently adding tools.

## CI workflow construction pattern

Build the CI workflow file by walking the STANDARDS.md CI Pipeline table top to bottom. For each row, add a job (or step within a job) that runs the corresponding command. The workflow's overall shape:

```yaml
name: <project-name> CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  <job-name-from-standards>:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: <language-setup-action@version>
      - run: <task-runner> <command-from-standards>
```

Repeat per job, or combine into a single job with multiple steps if the team prefers a flatter pipeline (faster signal but worse failure isolation). Default to one job per logical check unless the user has a preference.

## Pre-first-CI-run sanity pass

Before the HITL presentation, walk the user through a sanity pass on the tooling configs. This is **not** HITL clarification (those are in `references/hitl-question-bank.md`) — it's a pre-HITL quality gate that catches the "blueprint ships strict CI gates that fail on empty scaffolding" failure mode. The user's repo at this moment contains only scaffolding: no tests, no real code consuming workspace deps, no transitive dependency tree yet populated. Strict CI gates written for a mature repo will fail on first push against this state, and the user will spend an hour debugging gates instead of shipping.

The sanity pass asks eight questions. Each is **stack-agnostic**; the user brings the stack-specific answer. The goal is to either (a) pre-empt the failure with a documented workaround and a cleanup trip-wire, or (b) agree that the gate is aspirational and the user will fix at first CI run. Either outcome is fine — what's not fine is shipping a gate that will silently fail and pretending it's green.

**The eight questions**:

1. **Test runner on zero tests** — Will your test runner fail when zero test binaries exist? If yes, do you want to (a) configure the runner to pass on zero, (b) skip the test gate until your first real test, or (c) something else?
2. **Unused-dependency checker** — Will your unused-dependency checker flag the workspace dependencies we just added that no code consumes yet? If yes, how do you want to handle that — per-crate ignore lists, exclude rules, or something else?
3. **Linter on imported content** — Does your linter scan content imported via docstrings, `include_str!`, embedded READMEs, or similar? If yes, any rules that will hit on prose content (e.g., identifier casing lints on brand names)?
4. **License / advisory checker** — Will the license allowlist and advisory rules match what gets pulled transitively once dependencies are installed? Do you want to run the checker once now against a populated dependency tree and amend the allowlist, or ship defaults and fix at first CI run?
5. **Stack-decision contradictions** — Any tooling config rules we wrote that contradict stack decisions from earlier in this session? (Example: a ban on a system library that a storage decision requires.) This is a cross-check: read the bans / denies / allow-lists in the tooling configs and verify none contradict the stack decisions list.
6. **Automated review bot workflows** — **If we're committing an automated review bot as a merge gate** (claude-code-action, CodeRabbit, Copilot review, or equivalent): the out-of-the-box workflows these tools ship are usually wrong for any specific project. They over-review, under-review, comment on the wrong things, or apply generic rules that don't match your standards. Retuning them is a real authoring task — see the "Automated review bot prompt construction" section below for the full treatment. Sanity-pass-level decisions to make right now: (a) do you want the review bot to skip docs-only and template-only PRs to save tokens? (b) do you want concurrency cancellation so a burst of pushes only pays for the final review? (c) what wall-clock cap on the review job? (d) read-only tool permissions, or can the bot commit/push? (e) which PR authors should be skipped (drafts, dependabot, renovate, etc.)? **Also**: how will you verify the review bot actually ran and commented on your first post-blueprint PR? A bot gate that's silently broken is worse than no gate.
7. **Coupled dependency pairs** — Are there dependency pairs in your stack that are coupled upstream (library A caps library B's version, or they need to be bumped together)? If yes, your automated dependency bump config should group them so a single coordinated PR lands instead of two conflicting ones that can't both merge.
8. **Temporary workarounds and trip-wires** — Any workarounds we're shipping from questions 1–7 just to get CI green on empty scaffolding? For each, we'll capture it in a **Cleanup tracking** section in `blueprint.md` with an explicit trip-wire condition for removal. Example trip-wires: *"remove when the first real test binary lands"*, *"remove when each ignored dep gets actually wired up"*, *"remove when upstream library X drops dependency Y"*.

**How to run the sanity pass**: go through the eight questions one at a time. For questions where the user says "not relevant" or "my stack handles this differently," note it and move on — don't force a workaround where none is needed. For questions where the user names a workaround, record the workaround and the trip-wire together in the Cleanup tracking section of `blueprint.md`.

**The output of the sanity pass**:

- Updated tooling configs reflecting the workarounds the user agreed to
- A new **Cleanup tracking** section in `blueprint.md` with one row per workaround, each row containing: the item being worked around, the config file where the workaround lives, and the trip-wire condition for removal
- A note in the HITL gate about any aspirational gates the user explicitly chose to leave broken until first CI run (so it doesn't look like blueprint missed them)

**Example Cleanup tracking section** (stack-agnostic shape):

```markdown
## Cleanup tracking

| Item | Lives in | Remove when |
|---|---|---|
| [Workaround 1 from sanity pass question 1] | [config file] | [trip-wire condition] |
| [Workaround 2 from sanity pass question 2] | [config file] | [trip-wire condition] |
| [...] | [...] | [...] |
```

**Failure mode this section defends against**: shipping tooling configs that fail on first push because they were written for a mature repo but handed to empty scaffolding. The symptom is always the same ("my CI is red on day one and I spent an hour debugging instead of shipping"); the cause is blueprint being optimistic about the gate set. The sanity pass makes the optimism explicit and surfaces it as a user choice rather than a silent failure.

**What the sanity pass is NOT**: it's not blueprint second-guessing the user's stack. Blueprint doesn't know whether a given test runner fails on zero tests — it asks. It doesn't know whether the user's linter has a doc-comment mode — it asks. Every question is a prompt for the user's knowledge, not a claim of blueprint's knowledge. If the user says "my test runner doesn't have this problem," blueprint accepts it and moves on.

## Automated review bot prompt construction

**Run this only if** the user picked an automated review bot as a CI gate during stack decisions (claude-code-action, CodeRabbit, Copilot review, Sourcery, or equivalent). **Skip entirely** if no review bot is in scope — this section produces nothing for projects that rely solely on human review.

The pattern: review bot prompts are **content-authoring tasks**, not install steps. A default workflow file with a generic "review this PR" prompt produces noise and frustration. A useful review bot prompt is **synthesized** from two sources, in order:

**Phase 1 — Research practitioner best practices**. Before authoring anything, run web searches to find how experienced practitioners and engineering teams have configured the same tool. The goal is to surface conventions, gotchas, and prompt patterns the user hasn't invented yet. Sample queries (adapt to the actual tool the user picked):

- `"<tool name>" review prompt best practices`
- `"<tool name>" example workflow `<language/framework>`
- `"<tool name>" production usage <year>`
- Engineering blogs from companies known for this tool — Anthropic, Stripe, Shopify, Vercel, Cloudflare, etc. depending on what's relevant
- Example public repositories using the tool with non-trivial customization

Don't take the first generic tutorial — look for posts that discuss what *not* to have the bot do, how to scope reviews, how to control token cost, and how to integrate with existing CI gates. **Surface 3-5 patterns to the user with citations** — don't just dump links, present what each source recommends and why. The user picks which patterns to adopt.

**Phase 2 — Tune to the codebase by inheriting from cascade artifacts**. Once the patterns are picked, generate the project-specific prompt content by inheriting from blueprint's own outputs:

| Inherit from | What to extract | Where it lands in the prompt |
|---|---|---|
| `STANDARDS.md § CI Pipeline` | Every gate the matrix runs | "**Things CI already catches — DO NOT duplicate**" list |
| `STANDARDS.md § Unenforced invariants` | Every textual rule with no automated enforcement | "**Things CI CAN'T catch — focus your review HERE**" numbered list, severity-tagged |
| `ARCHITECTURE.md` Decisions Log | Architectural invariants worth flagging if violated | Specific rules in the can't-catch list |
| `CLAUDE.md` conventions | Patterns the codebase follows that aren't lints | Specific rules in the can't-catch list |
| `problem_brief.md § no-gos` | Things that must not enter the codebase | HIGH-severity rules in the can't-catch list |
| Tooling configs sanity pass output (questions 1-4) | Workarounds shipped to make CI green on empty scaffolding | "**Leave alone**" list — pre-v0.1 scaffold markers the bot must NOT flag as bugs |

The output is a workflow file (or config file, depending on the tool — `.github/workflows/<bot>.yml` for GitHub Actions, `.coderabbit.yaml` for CodeRabbit, etc.) populated with project-specific prompt content, not a generic install.

**The prompt structure** follows this skeleton, regardless of tool:

```
Repository context: <2-3 sentences about what this codebase is>

First: read <foundation docs> to understand the invariants this review enforces.

Things CI already catches — DO NOT duplicate:
- [List from STANDARDS.md § CI Pipeline, one bullet per gate]

Things CI CAN'T catch — focus your review HERE:
1. [Severity] [Invariant from Unenforced invariants table]. [Where it lives. Defense.]
2. [Severity] [Next invariant]. ...
[Continue for every Unenforced invariants row]

Leave alone:
- [Pre-v0.1 scaffold markers from sanity pass — empty main, machete ignores, --no-tests=pass equivalents]
- [Style/naming unless harmful]
- [Snapshot test content reviewed by humans]
- [PR description wording]

Output format:
- [Tool-specific output guidance from Phase 1 research]
- [Severity tags: HIGH/MEDIUM/LOW with separate sections]
- [Whether to use inline comments or top-level summary]
```

**Tool permissions and workflow-level config** (the question 6 sub-questions from the sanity pass) get baked into the workflow file alongside the prompt. For GitHub Actions specifically: `paths-ignore` for docs-only PRs, `concurrency` group with `cancel-in-progress`, `timeout-minutes` cap, `permissions:` block scoped to read-only contents + write pull-requests, `if:` filter for drafts/bots.

**HITL gate for the review bot prompt**: present the generated prompt content inline before committing the workflow file. Lead with: *"Here's the review bot prompt synthesized from <N> practitioner sources and your STANDARDS.md / ARCHITECTURE.md / CLAUDE.md. The 'do not duplicate' list mirrors your CI gates, the 'things CI can't catch' list mirrors your Unenforced invariants table, the 'leave alone' list mirrors the sanity pass workarounds. Read it as if you're the bot — anything it should be told that I missed? Anything it should ignore that's in the list?"*

Iterate until the user approves. Common revision requests:

- "Add a rule about <invariant>" → goes in Unenforced invariants table first, then propagates to the prompt
- "Don't have it flag <pattern>" → goes in the "leave alone" list with a one-line reason
- "Reduce the max-turns budget — review is bounded work" → workflow-level config, not prompt content
- "Use <model> instead of the default" → workflow-level config

**What this section does NOT do**: it does not pretend blueprint knows the user's tool surface in detail. The Phase 1 research is exactly because blueprint doesn't know the latest patterns for any given tool — it researches them fresh. The Phase 2 inheritance is the part blueprint owns: synthesizing from the cascade artifacts blueprint just produced.

**Failure modes specific to this sub-section**:

- **Skipping Phase 1 research** — produces a prompt that's cascade-aware but generic-feeling, missing the practitioner wisdom. Defense: research is mandatory whenever this sub-section runs. If token pressure is a concern, surface it explicitly per the research-depth-as-user-signal pattern.
- **Skipping Phase 2 inheritance** — produces a prompt that copies practitioner patterns without tying them to the actual project. Defense: every "things CI can't catch" rule must cite a specific row from STANDARDS.md § Unenforced invariants. If a row would be added to the prompt that doesn't exist in the table, it goes in the table first.
- **Authoring the prompt without the Unenforced invariants table existing** — happens when this sub-section runs before STANDARDS.md is finalized. Defense: this sub-section is gated on the foundation docs step being complete. The Unenforced invariants table must exist (even if empty with the note "no unenforced invariants — every rule has a CI gate") before review bot prompt construction starts.
- **Generating the prompt without the user reviewing it inline** — the HITL gate is non-negotiable. The prompt is content the bot will run against every PR; the user has to read it before commit.

## HITL presentation
Tooling configs are produced *after* all six prose docs have been approved. Present them as a batch: *"Here are the tooling configs derived from the docs we just approved: task runner (`<filename>`), CI workflow (`<path>`), env template (`<path>` or 'none needed'). Each command in CLAUDE.md maps to a task here, and each row in STANDARDS.md's CI Pipeline table maps to a CI job. Let me know if anything's missing or wrong."*

Common revision requests:
- "Add a task for X" → add to task runner config (and add to CLAUDE.md commands if it should be there)
- "CI is missing the security scan" → add to STANDARDS.md first, then add the CI job
- "Move from one job to multiple" → restructure the workflow file
- "Use a different language setup action" → swap

Iterate until approved. Then commit each config file via GitHub MCP to its target location.

## Light-mode behavior

If the user invoked light mode:

- **Task runner config has the minimum set**: setup, check, test. Skip lint/typecheck/dev/fix/etc. unless they were explicitly chosen during stack decisions.
- **CI workflow has 1–3 jobs** instead of 5+
- **Skip env template** unless the project clearly has env vars
- **Skip review automation** unless explicitly requested

Even in light mode, the "every CLAUDE.md command = actual task" rule still applies. Non-negotiable.
