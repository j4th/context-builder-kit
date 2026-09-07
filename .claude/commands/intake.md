---
description: Turn a raw, externally-sourced report — a GitHub issue, a planning-backend issue, or pasted text — into a fully-specified, `/finish`-able issue. Resolve the source, investigate to a root-cause hypothesis with file:line evidence, replicate with a verified failing test or deterministic repro, classify (bug → bug lane / small capability → enhancement lane via `/enrich` / large capability → framing / tooling → cascade), and generate the shaped issue (or, for the enhancement lane, a thin candidate) behind a HITL gate. Writes an issue to your planning backend by default; emits a GitHub issue body with --github. Does not land code — `/finish` is the sole code-writer. Expects one positional argument — the source reference.
argument-hint: <github-#> | <KEY>-N | "<pasted text>" [--github]
---

You are being asked to turn an externally-sourced report into a fully-specified, `/finish`-able issue. The argument **$1** is the source: a GitHub issue number (`123` or `#123`), a planning-backend issue identifier (`<KEY>-N`), or a quoted freeform description. An optional `--github` flag switches the output from an issue in your planning backend (default) to a GitHub issue body.

`/intake` is **rough-in for externally-sourced work** — the bottom-up entry to the cascade. It investigates and reproduces, then produces a spec; it does **not** implement the fix (that's `/finish`) and it **never lands code**. The routing and label conventions it follows are the ones your project records in `.claude/rules/cbk-conventions.md`.

This `/intake` command is a living document — revised as real runs surface gaps. If the instructions below don't match what you're seeing, **surface the gap to the user** rather than improvising past it. Improvisation is what causes the cascade specs and the executor to drift apart over time.

## Step 1: Resolve the source

Parse `$ARGUMENTS`. Detect a trailing `--github` flag (output mode). Determine the source type and fetch it:

- **GitHub issue** (`#?\d+`): `github:issue_read` with `method: get`, or `gh issue view <N> --json number,title,body,labels,state,author,url`.
- **Planning-backend issue** (`<KEY>-N`): fetch it via your planning backend's MCP/CLI (a Linear MCP `get_issue`, the GitHub issue if GitHub Issues is your planning backend, or the in-repo markdown issue file for a markdown-only backend).
- **Freeform text**: use the quoted argument as the report.

Extract and note: the **reporter** (issue author / creator), a **one-line symptom**, **repro steps** (if given), **expected vs actual**, the **affected area** (from the report form's area field, if it has one), and **environment / commit SHA**.

If the reference can't be resolved (issue not found, ambiguous, resolves to a PR or discussion), stop and surface: *"I couldn't resolve `<ref>` to a GitHub issue, a planning-backend issue, or usable text. Paste the report or give me a valid issue reference."* If the source issue is already **closed**, ask whether to proceed (it may be getting re-triaged) before continuing.

## Step 2: Pre-flight + duplicate check

- **Clean baseline:** verify the working tree is clean (`git status --short`) and the project's `check` task is currently green. Step 4 may run a scratch reproduction; you want a known-good baseline and an uncluttered tree. If dirty or red, surface and ask (don't silently fix).
- **Duplicate check:** search your planning backend for an existing issue that references the same source `#N` or describes the same defect. If a likely duplicate exists, stop and ask: *"`<KEY>-N` already tracks this report. Continue and link to it, update it in place, or create a new issue anyway?"* Wait for direction.

## Step 3: Investigate — root-cause hypothesis (read-only)

A read-only investigation, like plan mode — **do not write code here**. Trace the code paths implicated by the symptom:

- `Grep` / `Glob` for the symptom's surface; the built-in `LSP` tool (via the language plugin; an MCP only for a language without one) for find-references / symbol info / call sites; a library-docs source to confirm a dependency's actual behavior before blaming it; read-only query tooling to inspect the data store's shape when the bug is data-shaped.

**Scale the investigation to the bug's surface — when the tooling is available:**

- **Fan out subagents in parallel** when the implicated surface is broad or the root cause has more than one candidate location: dispatch 2–3 `Explore` / general-purpose agents, one per hypothesis or code-area, then **synthesize their findings yourself** — gather with subagents, never delegate the synthesis.
- **When a workflow/orchestration tool is available, run a short investigation workflow:** parallel finders across *distinct angles* (by-symbol, by-data-shape, by-recent-change-to-the-area, by-existing-test), then an **adversarial verifier that tries to refute** the leading root-cause hypothesis before you commit to it — the multi-angle sweep plus the refutation pass catches failure modes a single trace misses.
- **Match the effort to the bug.** A one-file typo needs neither subagents nor a workflow — trace it directly. A cross-layer data bug (a value wrong across several data layers) is exactly where the fan-out earns its cost.

Produce a **root-cause hypothesis** stated with `file:line` evidence. For a feature request, instead characterize where the capability would live and what it touches.

**HITL:** present the hypothesis. *"Root-cause hypothesis: <statement> (evidence: `path:line`, …). Does this match your read before I reproduce it?"* Proceed on acknowledgement; revise if corrected. Don't fetch context speculatively — only what the current step needs.

## Step 4: Replicate — prove it's real

For a **bug**, construct the minimal reproduction and **run it** to confirm it fails for the hypothesized reason; capture the failure output as evidence.

- The reproduction is a failing test **or** a deterministic repro (a query, a CLI invocation, a small script).
- Do this **without landing code**: use a scratch test file under your scratch/temp directory, a throwaway uncommitted test you delete, or an `Explore` / general-purpose subagent that writes + runs + reports. `/intake` never commits; `/finish` is the sole code-writer.
- **When a workflow/orchestration tool is available**, run the reproduction and an independent attempt to *disprove* it concurrently — a defect only one of several agents can reproduce is a flaky / environment-dependent signal worth surfacing rather than a clean bug.
- Embed the verified failing test's **code + its failure output** into the generated issue — the `## Test plan` names the test (quotable from the runner), and `## Context` / `## Implementation` cite the confirmed reproduction.
- **If the bug cannot be reproduced, STOP and surface honestly:** *"I couldn't reproduce `<symptom>` from the information given. To shape a `/finish`-able issue I need: `<specific missing info>`."* An unreproducible report goes back to the reporter — **do not fabricate a test or guess a fix.**

For a **feature / capability**, define the acceptance shape (what observable behavior means "done"); note there is no failing test yet — a capability needs framing.

## Step 5: Classify + route (the discriminator)

Route per the intake conventions your project records in `.claude/rules/cbk-conventions.md`. The label and title-prefix names below are the recommended defaults; a project may rename them (the concrete values live in `cbk-conventions.md`, not here). The four lanes:

- **Bug in existing code → bug lane.** Target the relevant workstream slug (from the affected-area field + your investigation). Title `[<slug>:bug] <intent>`; parent = the workstream `[<slug>]` issue; apply the project's bug-type label + a `source:<origin>` label + `cascade-depth:roughed-in` + `workstream:<slug>`. Skips framing; `/finish`-able.
- **Small net-new capability → enhancement lane.** A capability one `/finish` can fully cover (no multi-R decomposition, no sub-dependencies, single workstream). File a **thin candidate** under the workstream: title `[<slug>:enh] <intent>` (or a plain `[<slug>]` to be renamed at enrich time); apply the work-matching type label (feature / improvement) + an `enhancement` label + `source:<origin>`; do **not** apply `cascade-depth:roughed-in` yet. Then surface: *"run `/enrich <KEY>-N` to brainstorm + investigate it into a `/finish`-ready `[<slug>:enh]` issue."* `/enrich` (not `/intake`) does the spec work; `/intake` only classifies + files the candidate.
- **Large net-new capability / idea → framing candidate.** **Not** `/finish`-able yet — say so. File under the workstream with `enhancement` + `source:<origin>`; do **not** apply `cascade-depth:roughed-in`. Surface that the operator must run `framing` → `rough-in` before `/finish`.
- **Cascade / tooling gap → the cascade/meta workstream** (usually filed as a meta issue, or roughed-in directly).

If the affected workstream is genuinely ambiguous (bug vs missing feature, or which slug), present your best read + the alternatives and ask.

## Step 6: Generate the shaped issue

**Enhancement-lane (small-capability) route:** *skip* the eight-section build below — file a **thin candidate** (the report + affected area; title `[<slug>:enh]` or `[<slug>]`; the work-matching type + `enhancement` + `source:<origin>` labels; **no** `cascade-depth:roughed-in`) and hand off to `/enrich`, which does the brainstorm + investigation + the eight sections + the relabel to roughed-in. The eight-section build below is for the **bug lane** (and the `--github` output).

Build the issue body using the **exact eight `##` headings `/finish` Step 2 requires**, verbatim, in this order: `## Context`, `## Assumptions`, `## Implementation`, `## Acceptance criteria`, `## Test plan`, `## Done signal`, `## Dependencies`, `## PR contract`. Follow the authoring guidance in the rough-in spec template (`.claude/skills/rough-in/references/templates/rough-in-spec-template.md`, or your repo's committed `.github/ISSUE_TEMPLATE/cascade-rough-in.md`): state intent + constraints, don't over-prescribe; the verified failing test goes in `## Test plan`, named; a bug-fix's `## Dependencies` is usually `None`; `## PR contract` carries the close marker (`Closes <KEY>-N` for a planning-backend-tracked issue, `Closes #N` for a GitHub issue). Put `- None — …` in `## Assumptions` if you made none (the section must be present even when empty).

Then, by output mode:

- **Planning backend (default) — HITL-gated.** Draft the title + body + labels + parent and **show the full draft**: *"Here's the shaped issue I'll create: `<title>` under `<parent>`, labels `<…>`. Body below. Create it?"* On approval, write it to your planning backend — parent = the workstream issue (bug lane), labels per Step 5, the body. Apply the type label **at creation** (on Linear this is what caches the suggested branch-name; see your `cbk-conventions.md` for backend-specific write notes). For a markdown-only planning backend, write the shaped issue as the in-repo issue entry rather than an MCP write.
  - **Cross-link provenance.** If the source was a **GitHub issue**: comment back on it (`gh issue comment <N> --body "Tracked as <KEY>-N — <issue-url>"`) and record the GitHub URL in the issue body. If the source was a **triage/inbox issue in the planning backend**: prefer updating it in place (set title/body/labels/parent and move it out of triage) rather than creating a duplicate.
- **GitHub (`--github`)** — for a reporter who isn't a planning-backend user. Emit a clean GitHub issue body (same eight sections, or a lighter bug-report shape for an external contributor). HITL before any `gh issue create`; default to **printing the body** for the operator to place.

## Step 7: Hand off

End the turn with:

1. The created / updated issue — `<KEY>-N` (URL) or `#N`.
2. The classification + route — bug lane / enhancement-lane candidate / framing candidate / cascade-tooling.
3. The verified reproduction — the failing test name + one-line failure.
4. The next action — for a bug-lane issue: *"`/finish <KEY>-N` when ready."* For a **small capability** (enhancement lane): *"run `/enrich <KEY>-N`, then `/finish`."* For a **large capability**: *"this needs `framing` → `rough-in` before `/finish` — return to chat for the framing skill."* On **`in-repo-markdown` planning** there is no `/finish`: the next action is opening a Claude Code session against the shaped markdown issue record (see `cbk-conventions.md` § Contribution intake, the markdown issue record) — say that instead.
5. Provenance — source (`#N` / reporter), label applied.

## What `/intake` does NOT do

- **Does not implement the fix or land code.** `/finish` is the sole code-writer; `/intake` ends at a shaped issue.
- **Does not write to the planning backend or GitHub silently.** Every issue create / update is drafted, shown, and approved first — a planning-backend or GitHub write is state outside the local repo, so it announces before it commits.
- **Does not create duplicate tracking issues.** It checks first and asks.
- **Does not bypass framing for *large* capabilities.** Large capabilities route to the framing backlog; only *small* capabilities take the enhancement lane (`/enrich` → `/finish`), and `/intake` only files the thin candidate — `/enrich` does the enrichment.
- **Does not fabricate a reproduction.** An unreproducible report is surfaced back, not forced into a spec.
- **Does not flip, merge, or label PRs; does not edit ADRs or other cascade artifacts** beyond converting the triage source it was handed.

## Output modes

- **Default** → an issue in your planning backend (bug-lane, enhancement-lane candidate, or framing candidate), HITL-gated, provenance cross-linked.
- **`--github`** → a GitHub issue body for a non-planning-backend reporter (printed for placement unless you're told to `gh issue create`).

## Partial failure handling

If any external operation — MCP call, Bash CLI (`gh`, `git`, the check task), or Skill invocation — fails or hangs, **stop immediately** and surface the partial state with a per-step status. Do not retry blindly: a failed issue write or `gh` call may have succeeded server-side, and a retry would duplicate. In the surface message, separate **what was written to the planning backend / GitHub** from what wasn't, and give explicit next-action choices with their consequences.

## When something surprises you

Surface, don't improvise. Common surprises:

- **The source ref resolves to something unexpected** (a PR, a discussion, a closed issue). Surface and ask.
- **The bug won't reproduce** from the given info. Surface; request specifics; don't guess a fix.
- **The classification is genuinely ambiguous** (bug vs missing feature). Present both readings and ask.
- **A likely duplicate already exists.** Ask continue / link / update / new.
- **The affected workstream slug is unclear.** Present your best guess + alternatives.
- **The report needs a brand-new workstream** (fits no existing slug). That's a blueprint/framing decision, not `/intake`'s — surface it.
