---
description: Enrich a thin / under-specified issue into a fully-specified, `/finish`-able roughed-in issue — the single-issue sibling of the `rough-in` skill (rough-in for one issue, skipping the framing milestone). Brainstorm to pin intent + resolve the design forks framing would have made, investigate the codebase read-only (fanning out subagents when the surface is broad), then write the eight-section body + a provenance note, retitle to the enhancement-lane form, and relabel `cascade-depth:roughed-in` — all behind HITL gates. Does not land code (`/finish` is the sole code-writer); does not decompose into multiple issues (that's framing). Expects one positional argument — the planning-backend issue id.
argument-hint: <issue-id>
---

You are being asked to enrich the thin issue **$1** into a fully-specified, `/finish`-able roughed-in issue.

`/enrich` is **rough-in for a single under-specified issue** — the single-issue sibling of the milestone `rough-in` skill, rough-in operating on one thin issue instead of a whole milestone. It brainstorms + investigates + shapes; it does **not** implement the fix (that's `/finish`) and it **never lands code**. The lane it produces is the enhancement lane (the enhancement-lane convention in `.claude/rules/cbk-conventions.md`): a *small* net-new capability enriched in place into one roughed-in issue, **skipping the framing milestone**.

Use it on a thin issue from any source: a small-capability candidate from a triage/intake lane (if your project runs one), a manually-filed thin issue, or a milestone rough-in that turned out to be a single issue.

If the instructions below don't match what you're seeing, **surface the gap to the user** rather than improvising past it. Improvisation is what causes the cascade specs and the executor to drift apart over time.

## Step 1: Resolve + read the issue

Read issue $1 **and its comments** from the planning backend (the same read you'd use to fetch an issue by id — planning-backend MCP, `gh issue view`, or the in-repo markdown record, per whichever backend this project picked at scaffold).

Verify + note:

- The issue is **open** (not closed / archived). If closed, ask whether to re-enrich (it may be getting re-scoped) before continuing.
- It is genuinely **under-specified** — a thin title + body, no eight-section spec, not already `cascade-depth:roughed-in`. If it already has the eight sections + the roughed-in label, stop: *"$1 already looks `/finish`-ready. Did you mean a different issue, or do you want me to re-enrich it?"*
- Extract: the **current title**, **body**, **labels** (esp. the framing-backlog marker + `source:*` + the work type), **parent** (a workstream `[<slug>]`?), **comments** (provenance from any upstream triage, prior context), and the **affected workstream slug** (from `area:<slug>` / the body / your read — it must be a locked blueprint slug, `docs/cbk/blueprint.md` § Workstreams).

**Pre-flight:** verify the working tree is clean (`git status --short`) and the project's `check` task is currently green — Step 3 runs a read-only investigation against a known-good baseline. If dirty / red, surface and ask (don't silently fix).

If the reference can't be resolved or the slug isn't a blueprint workstream slug, surface and ask.

## Step 2: Brainstorm — pin the intent + resolve the forks (HITL)

This is the step that **replaces the framing milestone.** Conduct a focused brainstorm to (a) pin the issue's true intent and (b) resolve the design decisions framing + rough-in would otherwise have made. Scale the brainstorm to the issue — a one-file task needs little; a task with real (if few) design choices needs those forks surfaced.

Surface, one at a time (`AskUserQuestion` for genuine forks; conversational otherwise):

- **The one-sentence intent** — quotable, clear enough to predict the acceptance criteria.
- **The design forks** — the choices framing would have pinned: mechanism / approach, scope boundary (what's in vs out), defaults + parameters, which existing code / pattern to reuse. Present your read + the alternatives; let the operator steer. Don't silently resolve a fork — surface it even when you have a strong default.
- **The size check** — confirm the capability is genuinely *small* (one `/finish`, no multi-issue decomposition, no sub-dependency on an unbuilt capability, single workstream). **If it proves large, STOP** and surface: *"$1 is larger than the enhancement lane — it needs `framing` → `rough-in` first. Want me to route it to the framing backlog instead?"* Never force a large capability into one issue — honesty about the cascade boundary is the whole point of the lane.

Synthesize into the resolved intent + the resolved forks. Don't move to Step 3 until intent + forks are aligned.

## Step 3: Investigate — codebase context + constraints (read-only)

A read-only investigation, like `/finish`'s plan-mode research — **do not write code here.** Ground the resolved forks in the actual code: the files / symbols the issue touches, the constraints (ADRs, `.claude/rules/*`, `docs/STANDARDS.md`), the dependencies, and the gotchas.

- `Grep` / `Glob` for the surface; the built-in `LSP` tool (via the language plugin; an MCP only for a language without one) for find-references / symbol info / call sites — the blast radius; documentation-lookup tooling to confirm a library's actual behavior; read-only data/schema inspection when the issue is data-shaped.

**Scale the investigation to the surface — when the tooling is available:**

- **Fan out subagents in parallel** when the surface is broad or there are competing approaches: dispatch 2–3 `Explore` / general-purpose agents (one per area), then **synthesize their findings yourself** — gather with subagents, never delegate the synthesis.
- **When a workflow/orchestration tool is available, run a short investigation workflow**: parallel readers across the relevant subsystems, then an adversarial verifier for any load-bearing assumption, then synthesize.
- **Match the effort to the issue.** A one-file change needs neither; a cross-layer capability is where the fan-out earns its cost.

Produce: the affected files / modules, the acceptance shape (what observable behavior means "done"), the dependencies + blockers, the constraints (ADRs / rules), and the gotchas — enough to write a self-contained `## Implementation`.

**HITL:** present the investigation findings (and any fork the code forced a change to). Proceed on acknowledgement; revise if corrected.

## Step 4: Shape the issue — eight-section body + provenance + relabel (HITL before any backend write)

Build the issue body using the **exact eight `##` headings `/finish` requires**, verbatim: `## Context`, `## Assumptions`, `## Implementation`, `## Acceptance criteria`, `## Test plan`, `## Done signal`, `## Dependencies`, `## PR contract`. Follow the authoring guidance in the rough-in spec template (`.github/ISSUE_TEMPLATE/cascade-rough-in.md`) and the `rough-in` skill's plan-mode-prompt reference (state intent + constraints, don't over-prescribe; `## Implementation` is the load-bearing plan-mode anchor; name the tests in `## Test plan`; `## PR contract` carries the close marker for $1 per `cbk-conventions.md` § Closes-keyword conventions). Put `- None — all forks resolved during enrichment (see the provenance note).` in `## Assumptions` if the brainstorm resolved everything (it usually has — that's the point).

The enhancement-lane contract (the enhancement-lane convention in `cbk-conventions.md`):

- **Title** → `[<slug>:enh] <intent>` (the enhancement-lane title form; `<slug>` is the locked blueprint workstream slug).
- **Labels** → add `cascade-depth:roughed-in`; **drop** the framing-backlog marker (the label that routes an issue to framing); keep `area:<slug>` + `source:*` (when externally-sourced); set the **work-matching type** where the backend has a type field (a net-new capability vs a small refactor/chore).
- **Parent** → the workstream `[<slug>]` issue (usually already correct).
- **Provenance note** → post a note capturing the **framing + rough-in reasoning collapsed inline**: the resolved forks + rationale, any corrections to the thin body, and a one-line "enriched via the enhancement lane (no framing milestone)." On backends with comments this is an issue comment; on a markdown-only backend it's appended to the issue record. This is the durable audit trail + what `/finish` Step 1 reads alongside the body.

**HITL gate** — draft the title + body + label changes + the provenance note and **show the full draft**: *"Here's the enriched issue I'll write to $1: title `<title>`, labels `<…>`, body below, plus this provenance note. Apply it?"* On approval, write the issue update (title, body, labels, parent) and post the provenance note to the backend.

(Linear-tracked projects only: set the work-type field in the *same* write that sets the title — the backend caches its suggested branch name at that moment; see `cbk-conventions.md`.)

## Step 5: Hand off

End your turn with:

1. The enriched issue — $1 (URL / reference), now `[<slug>:enh]` + `cascade-depth:roughed-in`.
2. The resolved intent + the resolved forks (one line each).
3. The investigation summary — affected subsystems, key constraints, dependencies.
4. The next action — *"`/finish $1` when ready."* (On `in-repo-markdown` planning there is no `/finish`: say *"open a Claude Code session against the enriched markdown record"* instead.)
5. Loose threads — anything deferred or worth its own follow-up issue.

## What `/enrich` does NOT do

- **Does not implement the fix or land code.** `/finish` is the sole code-writer; `/enrich` ends at a `/finish`-ready issue.
- **Does not write to the planning backend silently.** Every issue update + the provenance note are drafted, shown, and approved first (a backend write is state outside the local repo — a one-way door).
- **Does not decompose into multiple issues.** Multi-issue decomposition is `framing` → `rough-in`. If the capability needs that, `/enrich` routes it to framing (Step 2's size check) — it never fans one issue into many.
- **Does not enrich large capabilities, bugs, or already-roughed-in issues.** Large → framing; bugs → the project's bug-triage lane; already-roughed-in → it's already `/finish`-able.
- **Does not fabricate a spec.** If the brainstorm + investigation can't surface a clear acceptance shape, surface that gap — intent must be clear before the eight sections are written.
- **Does not flip / merge / label PRs, or edit ADRs or other cascade artifacts.**

## Partial failure handling

If any external operation — MCP call, Bash CLI (`gh`, `git`), or Skill invocation — fails or hangs, **stop immediately** and surface the partial state with a per-step status. Do not retry blindly: a failed issue write or provenance-note post may have succeeded server-side, and a retry would duplicate. Separate **what was written to the backend** (title / body / labels / note) from what wasn't, and give explicit next-action choices with their consequences.

## When something surprises you

Surface, don't improvise. Common surprises:

- **The issue is already roughed-in / fully-specified.** Ask whether to re-enrich or move on.
- **The capability proves large** (needs decomposition / has sub-dependencies / spans workstreams). Route to framing — don't force one issue (Step 2's size check).
- **The brainstorm reveals the intent is genuinely ambiguous** (two competing scopes). Present both and ask.
- **The investigation uncovers a blocker or dependency the operator didn't mention.** Surface; decide whether to add it to `## Dependencies` or defer.
- **The issue is actually a bug, not a capability.** Route to the bug-triage lane instead.
- **The slug isn't a locked blueprint workstream slug.** Surface — the enhancement lane is workstream-scoped, not a label-only area.
