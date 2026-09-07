# PR Review Rules

Operational rules for the `pr-review-toolkit:review-pr` invocation in the cascade workflow. `docs/STANDARDS.md § Step 7` (or wherever your project documents the equivalent gate) establishes that automated review runs before any PR moves draft → ready; this file is the practical detail — the triage rubric, what *not* to flag, and the project-local agents that dispatch alongside.

## Plugin

`pr-review-toolkit` is a Claude Code plugin/skill installed by the user, not a project dependency. The plugin owns the agent dispatch and the diff parsing; this file documents how the project uses it and what calibration the cascade applies on top.

**Install / update**: per Claude Code plugin documentation. The plugin name and source repo are at the user's discretion; this rules file exists so the project doesn't lose track of the dependency.

## When to invoke

`/finish`'s review pass dispatches `pr-review-toolkit:review-pr` against the local branch before opening the draft PR. Invoke with no args for the default full sweep — do **not** pass the PR number as an argument (that's not the skill's interface; the skill auto-discovers via `git diff` + `gh pr view`, falling back to `git diff main...HEAD` pre-PR).

### The floor — two skills, actually invoked

**A review pass is unsatisfied until both of these have actually run, as skills, in this session:**

1. **`/simplify`** — the real skill, per [`simplification.md`](simplification.md).
2. **`pr-review-toolkit:review-pr`** — the real skill, no args.

This is a floor, not a menu. Neither is satisfied by an agent that read the diff and reported what those skills *would* have found, by a workflow that dispatched agents "covering the same dimensions," or by a summary asserting the pass was clean. **Reasoning about a gate is not passing it.** If either skill is uninstalled or errors, the pass **fails** — stop and surface; `/finish`'s "does not skip" rule makes it blocking. A skill that runs without its own agent fan-out because the Agent tool is unavailable in the calling context counts as **invoked, not covered** — a subagent at the spawn-depth limit has no Agent tool (three layers below the main conversation by default; `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` — `https://code.claude.com/docs/en/sub-agents`, verified 2026-09-06) — and its dropped dimensions are recorded as dropped coverage on the gate line, never described as equivalent.

**Once.** The floor runs once, when the known work is complete and just before the draft PR. It is not run again on a delta that lands after the draft — an operator's runs forcing fixes, a follow-up — and it is not a tool for checking a specific change: the reviewer round on the flip covers the delta, `/pr-respond` answers it, and a further floor pass happens only when the operator asks. *(A real run, 2026-09-04, saw the floor twice and four verification workflows on one drafted artifact; the operator's rule is once.)*

**Record the invocation — the `## Review gate` block.** The PR body carries a `## Review gate` block, written before `## Triage`, with one line each for `/simplify`, `pr-review-toolkit:review-pr` and the orchestrated sweep, each stating run-or-not with counts and any dropped coverage. This is the block's one home; `/finish` Step 10 cites it rather than restating it:

```markdown
## Review gate
- `/simplify` — ran: <N> cleanup agents, <N> findings, <N> applied · or: invoked, not covered — <dropped dimensions> (never waived)
- `pr-review-toolkit:review-pr` — ran: <N> agents, <N> findings, triaged <A/AwC/S/D/R> · or: invoked, not covered — <dropped dimensions> · or: waived — <break-glass reason>
- `review-sweep` — ran: <N> finders + <N> verifiers, <N> confirmed / <N> refuted / <N> unverified, dropped coverage: <reviewers or dimensions, or none>, bounds <per-dimension>/<verified> · or: skipped — <reason>
```

A waived skill is recorded on its line with the break-glass reason, never omitted. **A PR body without this block is treated as un-reviewed, whatever the hand-off claims.** This is what makes the gate auditable rather than assertable — the failure mode it exists to stop is a confident hand-off summary describing a review that never happened.

### The orchestrated sweep supplements; it never substitutes

Where a multi-agent orchestration surface is available, `.claude/workflows/review-sweep.js` runs **beside** `pr-review-toolkit:review-pr`, after `/simplify`, and carries any focused or specific review the two skills do not cover, or do not cover enough, for the diff at hand — the project-local reviewers below always ride in it (the workflow reads § Project-local agents at dispatch time, never a copy kept in the script), and beyond them the caller names the finders this diff needs (a dimension the toolkit lacks; a targeted concern such as a schema change, a timing invariant, a boundary contract) — every finding through a refute-by-default **adversarial verification stage** before triage. Triage waits for the skill and the workflow both. The workflow widens coverage and pre-filters false positives. It is **never** an alternative to invoking the two skills, and a workflow that ran does not discharge either of them.

If the sweep is unavailable, its roster read fails, or its run fails, that is not a fallback event — the floor was always the requirement, and the sweep's absence costs only the extra coverage. Record that it was skipped, or what it dropped, on its gate line.

**Proportionality — size the sweep to the diff.** The floor is constant; the sweep's size is not. The project-local reviewers always run and cost nothing when nothing is in scope; the finders beyond them are chosen for this diff — none on a small single-surface change the two skills already cover, several on a broad or cross-cutting one (the vocabulary `/finish` Step 5a uses for research: a single-file change needs none of this; a cross-layer or multi-subsystem diff is where the fan-out earns its cost). **A session-level effort setting does not override this** — running an expensive orchestration because the session is set to a high tier is exactly the mis-sizing this clause exists to prevent. When in doubt, run the floor with the project-local reviewers and add no finder.

**Fan-outs are bounded — at dedup and verify, never in the finder prompt.** The finder prompt keeps asking for every finding the reviewer would defend (that is the docs' own review guidance); the sweep then deduplicates across dimensions and carries a bounded, severity-ranked set into verification — by default **3 per dimension and 8 verified** — logging the planned agent count before the find stage and returning anything a bound drops as unverified, never silently. Unbounded per-finding fan-out is forbidden: it makes cost a function of how noisy the finders were, which inverts the incentive the find stage should have.

**Three invariants, floor and supplement alike.** (1) **Triage judgment stays with the caller.** Dispatched review and verify agents report findings and verdicts; the executor holding this file's rubric classifies them — triage is never delegated downstream. (2) **A failed review agent is dropped coverage, not zero findings.** An agent that fails, times out, or returns nothing must be tracked as an uncovered dimension and retried — and a finding whose verification step failed is surfaced as unverified, not silently dropped — before the review pass is treated as complete. (3) **Every finding is deduplicated before it is verified**, keyed on file, line and normalized title, keeping the strongest severity reported and carrying the dimensions that independently converged — convergence is signal for triage, not a duplicate to pay for twice.

If the toolkit isn't installed or fails to invoke, **stop and surface** — do not silently skip. The "does not skip" rule in `/finish` makes a missing toolkit blocking.

## Project-local agents to dispatch alongside

Dispatch the project-local reviewers in parallel with the toolkit's generic agents. All three shipped reviewers are **cross-cutting** — dispatched unconditionally on every sweep; each greps the diff for its surface first and returns a cheap clean verdict when nothing intersects:

- **`adr-conformance-reviewer`** (`.claude/agents/adr-conformance-reviewer.md`) — scope: code governed by an ADR. Reads `docs/adr/README.md` and intersects the diff against ADRs whose decisions plausibly govern the changed files.
- **`logging-discipline-reviewer`** (`.claude/agents/logging-discipline-reviewer.md`) — scope: logging and telemetry surfaces. Reads `.claude/rules/logging.md` and checks structured-only logging, correlation-ID propagation, level taxonomy, sensitive-data rules.
- **`cascade-rule-reviewer`** (`.claude/agents/cascade-rule-reviewer.md`) — scope: code or commits governed by any `.claude/rules/*.md` other than `logging.md` (testing regimes, `cbk-conventions.md` branch/commit/label/skip-ci/mutation discipline, `simplification.md`, `knowledge-backend.md`). Applies this file's rubric to classify what it finds; it does not check the diff for whether *this* file is being followed.

If your project authors additional reviewer agents (e.g., for a dependency-injection contract, a security-boundary policy, an i18n discipline), list them here so the dispatch list stays in this file rather than scattered across `/finish`.

**Dispatch conditions live here, once.** This section is the single authoritative statement of when each reviewer runs — duplicated rosters (in `/finish`, in reviewer bodies, in a workflow script) rot out of sync, so anything else that needs the roster consults or mechanically mirrors this section. The default split: **cross-cutting reviewers run unconditionally** and return a cheap clean verdict when nothing is in scope — in particular the `cascade-rule-reviewer`, whose scope is a catch-all over the rule files (path-gating it recreates the exact gap it exists to close) — while **domain reviewers are path-matched** against the changed files.

**Authoring a project-local reviewer.** The reviewers above share a portable shape worth reusing: frontmatter (`tools: Read, Glob, Grep, Bash` [+ `Skill` if it invokes one], `model: sonnet`, `memory: project`, `effort: high` — a direct dispatch has no verify stage behind it, `orchestration.md` § The effort axis); a **Scope** section stating what it does and doesn't review, with explicit hand-offs to the other reviewers; a **Contract-surface** section naming the frozen sources it checks against (a rule file, an ADR, a reconciliation doc) with a stated precedence; a numbered checklist of concrete checks; and an output shape that emits `file:line` + the violated contract + this file's rubric class. One cardinal rule for any reviewer covering a **fast-moving or niche stack dependency**: *never answer from memory* — invoke a docs-expert skill (or read the installed source) first and ground every API claim in a citation; an ungrounded assertion about the library is itself a defect. Distinguish idiom *correctness* (flag) from idiom *preference* (Surface at most). The two archetypes (decision-text, laws), the section skeleton, grep-first items, standing refusals, stated gaps, the two drift tripwires and guard-list eviction live in `pr-review-reference.md` § Authoring a project-local reviewer; write a domain reviewer's scope on its entry line here as bare path prefixes, because the sweep's roster reader parses this section.

**Reviewer precedent memory.** The shipped reviewers declare `memory: project` (`https://code.claude.com/docs/en/sub-agents`, verified 2026-09-06; re-verify the field and its paths after harness upgrades): `project` is `.claude/agent-memory/<name>/`, meant to be committed; `local` is `.claude/agent-memory-local/<name>/`, never committed; the reviewer's prompt carries only the first 200 lines or 25 KB of its `MEMORY.md`, so the index is one line per surface; and with auto memory off (`autoMemoryEnabled` / `CLAUDE_CODE_DISABLE_AUTO_MEMORY`) the `memory` field has no effect — a reviewer that finds no memory directory says so. The memory root follows the directory the reviewer was dispatched from — `memory: project` is a relative path and a subagent starts in the main conversation's current working directory — so every sweep is launched from the repository root; `require-repo-root-for-agents.sh` refuses any other launch and `detect-forked-agent-memory.sh` blocks a hand-off while a stray tree exists. **The commit-versus-local choice is a Surface inventory row** (`cbk-conventions.md` § Surface inventory, "Reviewer agent-memory"), settled at scaffold's rule-file disposition pass; `project` is the exercised default, and with it the kit's `.claude/agent-memory/` gitignore line — a kit-repo-only exception — is deleted. Memory updates ride the commit the review produced, never a separate commit. A reviewer consults its precedents before flagging — four genres (out-of-scope precedents, clean-review calibration baselines, de-facto-convention prior art, conforming-pattern records) and three further kinds (dependency facts, findings with their disposition, techniques) — and **every genre carries a reconsider trigger**, not only the convention genre. The genres' definitions, the typed filename prefixes, one baseline per surface with a throwaway tree's expiry, and the living-record shape live in `pr-review-reference.md` § Reviewer precedent memory — genres and staleness; the entry discipline itself is stated once, in every shipped reviewer's `## Writing memory` section, and the verification block keeps those copies identical.

**Reviewer craft rules** (bind the shipped reviewers and any the project authors):

- **Verify by artifact, never by the diff's self-description.** Commit order proves a red-first claim; a grep-diff proves a multi-index sync; a test's assertions prove what it pins. The diff's narrative is a claim to verify, not evidence.
- **Pair the red-flag checklist with a maintained do-not-flag guard list.** The false-positive guards are as load-bearing as the checks — they are what keeps the bot's signal trusted.
- **A clean verdict on an out-of-surface diff is correct output.** Grep the added lines for the reviewer's surface first; "nothing in scope, clean" is a valid, cheap verdict — not a failure to find.
- **No unsourced claims about external-platform behavior.** Extends the never-answer-from-memory rule beyond stack dependencies: any normative claim or quotation about an external tool's behavior — in a reviewer, or in a rules file a reviewer enforces — carries a resolvable citation, and absence claims get a primary-source check before landing. Unsourced claims propagate to sibling docs and reviewer agents before anyone re-checks them.
- **Hand-offs name the other owner inline.** When a finding sits on another reviewer's surface (an ADR clause, a log call, a rule file), the finding says so — "→ `adr-conformance-reviewer`" — in the finding itself, so triage dedups it against that reviewer's report instead of counting it twice.
- **A reviewer lacking a tool reports *unverifiable*, never a confirmed absence.** Without the Skill tool, without a docs-expert skill, without `gh`: "could not verify X (no `<tool>` in this context)" is the output. "X is absent" from a reviewer that could not look is the most expensive false negative the gate produces.
- **Path-matched trigger prefixes are derived from where the reviewed API is used**, not from where its owner thinks the code lives: grep the tree for the calls and types the contract governs, and list those directories as the reviewer's scope in this section as bare path prefixes (`src/schema/`, never a glob or prose) — the sweep's roster read matches the changed paths against them, and an unmatchable hint is dropped coverage.
- **A skill that ran without its own fan-out counts as invoked, not covered** — § The floor states the spawn-depth fact and its source; record the skill's dimensions as dropped coverage on the gate line and dispatch them directly from the main session.

## Pre-filters — strip before the agent reads

Before any review work runs, exclude these from the diff. Cheaper than triaging them out post-hoc, and the agent's signal-to-noise improves as the input narrows.

- **Generated files** — `*.generated.*`, codegen output directories, protobuf-emitted types, OpenAPI client stubs
- **Lock files** — `package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`, `Cargo.lock`, `mix.lock`, `uv.lock`, `Gemfile.lock`, `poetry.lock`
- **Vendored dependencies** — `vendor/`, `third_party/`, `node_modules/` (shouldn't be tracked, but defensive)
- **Build artifacts** — `dist/`, `build/`, `target/`, `_build/`, `.next/`, etc.
- **Snapshot test fixtures** larger than ~200 lines unless the test itself is on the diff

The toolkit's specialized subagents may already strip some of these; configure pre-filters at the workflow level when in doubt.

Compute the pre-filtered changed-path list **once**, before any dispatch, and hand the same list to every reviewer (and to any orchestrated sweep's trigger matching) — per-agent re-derivation wastes tokens and risks inconsistent scopes across reviewers.

## Triage rubric — the four-class shape

Every finding goes into exactly one of four classes. The Apply class is narrow and substantive; soft findings go to Surface so the user decides during draft review.

| Class | Action | Triggers (see § Apply/Surface calibration below for category-by-category) |
|---|---|---|
| **Apply** | Execute the fix; commit as its own focused commit on the branch with a Conventional Commits message that names the finding. | Behavior-preserving fix with concrete evidence of need. Includes: defects with reproducible failing path; factually wrong comments / rot; dead code / unused imports; existing-doc improvements (clarity, precision, accuracy); defensive additions with concrete evidence; local-symbol renames when fact-based; missing docstrings on entirely-undocumented surfaces. **Also includes low-risk small changes**: ≤ ~15 LOC delta, confined to one file or symbol, no design call required, plausibly an improvement per the agent's rationale (e.g. typo fixes, redundant assertion drops, inlining a one-shot helper, extracting a constant the agent already named, simplifying an obvious-once-named expression). The user-side cost of triaging 5 small Surface items routinely exceeds applying them and presenting the diff. |
| **Apply with care** | Execute as its own focused commit, but flag in the hand-off summary so the user knows to scrutinize. | Cross-file refactors >~50 LOC; introducing a new module/file outside the issue's named files; changes that materially alter test or implementation strategy; correctness fix whose implementation is non-obvious. |
| **Surface** | Do **not** apply. Note in hand-off summary with the agent's rationale verbatim. | **Genuine design or taste calls only**: stylistic disagreement where the existing form is also fine; structural refactors that change surface area; speculative defensive guards (no concrete failing scenario); doc *expansions* of existing-but-thin sections; suggested abstractions where the existing duplication is small (rule-of-three not yet hit); alternative implementation approaches the agent prefers but the existing one is also fine. **NOT Surface**: small low-risk improvements (those go to Apply); style nits the agent suggested without strong rationale (those go to Reject with a one-line dismissal — don't surface them with verbatim rationale, that just inflates the user's review surface). |
| **Defer** | Note in hand-off summary; do not modify the issue body or open follow-up issues without user direction. | Conflicts with an ADR or with the issue's intentional design; finding is explicitly listed under the issue's `## Out of scope`. |
| **Reject** | Note in hand-off summary with one-line justification. | Agent factually misunderstood the codebase or the spec; finding contradicts project rules or an existing ADR. |

The Apply gate is **behavior-preservation + concrete evidence**, adapted from Sourcery's auto-apply split (refactorings that don't change behavior auto-apply; suggestions that may change behavior never auto-apply). The "concrete evidence" half adopts PhotoStructure's "prove it or discard it" rule — speculative findings without a demonstrated failing path go to Surface. The Apply class also extends to low-risk small changes that are plausibly improvements (≤ ~15 LOC, confined, no design call) — the calibration learning here is that user-side triage cost on small Surface items routinely exceeds the cost of applying-and-showing the diff, and atomic-commit history makes any wrong call cheap to revert.

**When uncertain about a small low-risk change, Apply. When uncertain about a design or taste call, Surface.** The split: if the agent's suggestion is a small, confined, no-design-call edit and the rationale is plausible, prefer Apply — atomic-commit history makes the fix easy to revert and the user-side cost of triaging Surface items routinely exceeds applying-and-showing. Reserve Surface for genuine taste calls and design decisions where reasonable people disagree. **Medium-confidence findings from review agents follow the same triage as high-confidence findings** — confidence is about whether the finding is real, not whether to apply it. Don't default mediums to Surface just because they're medium-confidence; that converts the bot's "I'm not sure this is real" into the user's "now you have to triage 5 items." The Apply bar is "would a future maintainer be wrong without this fix, OR is the fix small + low-risk + plausibly an improvement?" — defects, ADR/standards/logging-contract violations, defensive hardening, factual rot, and small low-risk improvements meet that bar; genuine design or taste calls do not.

**Don't bias away from being defensive.** Defensive hardening (e.g., adding a race guard, a missing cleanup, a setup that prevents a future edit from silently breaking a test) is a correctness concern even when the test passes today — those go in Apply, not Surface. Conservatism here means *defending the codebase against future drift*, not *being conservative about applying defenses*.

## Apply / Surface calibration

→ *Moved to* `pr-review-reference.md` § Apply / Surface calibration *(path-scoped; see `cbk-conventions.md` § Rule loading and the instruction budget).*

## What NOT to flag — the exclusion list

The highest-leverage tuning surface for AI code review (per Cloudflare's evidence: their exclusion list reduced findings from 10+ to ~1.2 per review). The toolkit's agents may already filter some of these; the cascade reinforces them at the rubric level.

**Always exclude — these are noise even when "technically correct":**

- **Issues in unchanged code.** If the diff didn't touch it, the bot doesn't comment. Past tech debt is not this PR's concern.
- **Theoretical risks without concrete preconditions.** "This could fail if X happens" — without showing how X happens in this code, this is speculation.
- **"Consider using library X" / "Consider rewriting with framework Y."** Library/framework choice is blueprint's job, not the reviewer's.
- **Restatement comments.** A comment that says what the function name already says is noise.
- **Speculative future-risk warnings.** "If you ever scale this to 1M users…" — out of scope unless the issue says so.
- **Alternative implementation approaches the agent prefers** when the existing one is also fine.
- **Style or naming on exported APIs** without a concrete compelling reason (back-compat breakage, naming-collision, etc.).
- **ADR-literal violations that a `Refines:` child ADR or a project-local reconciliation layer scopes away.** Before flagging "violates ADR-NNNN Dn", follow the ADR's `Refines:` chain and check the reconciliation layer — a scoped reading there is authoritative, and a literal-clause flag against it is a false-positive. The `adr-conformance-reviewer` enforces this; the rubric reinforces it.

**Project may exclude additionally** (configure as the `pr-review-toolkit` configuration permits):

- **Bot-author or dependabot PRs** — reviewing automated dependency bumps line-by-line is rarely worth the tokens.
- **Docs-only PRs** — if the diff is entirely under `docs/` or `*.md`, skip the heavy review sweep; the simplify pass is enough.
- **Project-specific noise patterns** that emerge from the first month of running the toolkit. Add them here as you find them.

## Path-conditional aggressiveness

→ *Moved to* `pr-review-reference.md` § Path-conditional aggressiveness *(path-scoped; see `cbk-conventions.md` § Rule loading and the instruction budget).*

## Break-glass override

The "I disagree with the bot, ship anyway" escape hatch. Practitioners report it gets used <1% of the time at scale (Cloudflare: 0.6% of PRs across 30 days), so the bar is rare-but-real.

Two mechanisms:

1. **Issue-body / operator-instruction marker**: include `<!-- skip-review-toolkit -->` (or a similar agreed marker) in the issue body, or pass it in the operator's instructions to `/finish`. `/finish` reads it in its issue-read step — a surface that exists *before* the review pass runs — and waives **exactly one named half** of the floor — the `pr-review-toolkit:review-pr` invocation — for this run; `/simplify` is never waived, and the sweep needs no marker (its absence is recorded, not waived). (The marker can't live in the PR body: the review pass runs before the draft PR is created, so a PR-body marker would never gate the review it's meant to skip.) Document the rationale so the hand-off and the PR body carry it ("review-toolkit was wrong about X; addressing in follow-up Y").
2. **`/finish` flag** (if the user invoked manually with extra args): `--skip-review` on the slash command. Same effect.

Either path produces the same record: the skill's line in the PR body's `## Review gate` block reads `waived — <reason>` (§ The floor), and the hand-off repeats it. Don't silently skip; the audit trail is the gate line, never an omitted one.

## Anti-patterns

→ *Moved to* `pr-review-reference.md` § Anti-patterns *(path-scoped; see `cbk-conventions.md` § Rule loading and the instruction budget).*

## When to update this file

→ *Moved to* `pr-review-reference.md` § When to update this file *(path-scoped; see `cbk-conventions.md` § Rule loading and the instruction budget).*

## References

The calibration here was synthesized from these practitioner sources:

- [Sourcery — Refactoring vs Suggestion auto-apply split](https://docs.sourcery.ai/Coding-Assistant/Reference/Rules-and-In-Line-Suggestions/Python/Default-Rules/) — behavior-preservation as the auto-apply gate
- [Cloudflare — Orchestrating AI Code Review at scale](https://blog.cloudflare.com/ai-code-review/) — exclusion lists, severity tiers, 0.6% break-glass rate
- [PhotoStructure — Most AI code reviews are noise](https://photostructure.com/coding/claude-code-review/) — "prove it or discard it" rule, omit unverified guards
- [Jet Xu — Drowning in AI Code Review Noise](https://jetxu-llm.github.io/posts/low-noise-code-review/) — signal/noise framework, Tier 1/2/3 severity
- [CodeRabbit Configuration](https://docs.coderabbit.ai/reference/configuration) and [Docstring generation](https://docs.coderabbit.ai/finishing-touches/docstrings) — opt-in for missing docs, separate-PR pattern
- [Anthropic — Code Review for Claude Code](https://claude.com/blog/code-review) — finding-rate by PR size, "won't approve PRs"
