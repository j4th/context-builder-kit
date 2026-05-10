# PR Review Rules

Operational rules for the `pr-review-toolkit:review-pr` invocation in the cascade workflow. `docs/STANDARDS.md § Step 7` (or wherever your project documents the equivalent gate) establishes that automated review runs before any PR moves draft → ready; this file is the practical detail — the triage rubric, what *not* to flag, and the project-local agents that dispatch alongside.

## Plugin

`pr-review-toolkit` is a Claude Code plugin/skill installed by the user, not a project dependency. The plugin owns the agent dispatch and the diff parsing; this file documents how the project uses it and what calibration the cascade applies on top.

**Install / update**: per Claude Code plugin documentation. The plugin name and source repo are at the user's discretion; this rules file exists so the project doesn't lose track of the dependency.

## When to invoke

`/finish` Step 7 dispatches `pr-review-toolkit:review-pr` against the local branch before opening the draft PR. Invoke with no args for the default full sweep — do **not** pass the PR number as an argument (that's not the skill's interface; the skill auto-discovers via `git diff` + `gh pr view`, falling back to `git diff main...HEAD` pre-PR).

If the toolkit isn't installed or fails to invoke, **stop and surface** — do not silently skip. The "does not skip" rule in `/finish` makes a missing toolkit blocking.

## Project-local agents to dispatch alongside

When the diff touches code under their topics, dispatch project-local reviewers in parallel with the toolkit's generic agents:

- **`adr-conformance-reviewer`** (`.claude/agents/adr-conformance-reviewer.md`) — runs when the diff touches code governed by an ADR. Reads `docs/adr/README.md` and intersects the diff against ADRs whose decisions plausibly govern the changed files.
- **`logging-discipline-reviewer`** (`.claude/agents/logging-discipline-reviewer.md`) — runs when the diff touches logging or telemetry surfaces. Reads `.claude/rules/logging.md` and checks structured-only logging, correlation-ID propagation, level taxonomy, sensitive-data rules.

If your project authors additional reviewer agents (e.g., for a dependency-injection contract, a security-boundary policy, an i18n discipline), list them here so the dispatch list stays in this file rather than scattered across `/finish`.

## Pre-filters — strip before the agent reads

Before any review work runs, exclude these from the diff. Cheaper than triaging them out post-hoc, and the agent's signal-to-noise improves as the input narrows.

- **Generated files** — `*.generated.*`, codegen output directories, protobuf-emitted types, OpenAPI client stubs
- **Lock files** — `package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`, `Cargo.lock`, `mix.lock`, `uv.lock`, `Gemfile.lock`, `poetry.lock`
- **Vendored dependencies** — `vendor/`, `third_party/`, `node_modules/` (shouldn't be tracked, but defensive)
- **Build artifacts** — `dist/`, `build/`, `target/`, `_build/`, `.next/`, etc.
- **Snapshot test fixtures** larger than ~200 lines unless the test itself is on the diff

The toolkit's specialized subagents may already strip some of these; configure pre-filters at the workflow level when in doubt.

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

The calibration that distinguishes this rubric from a generic "Apply correctness, Surface taste" split. Each category names what crosses into Apply and what stays in Surface.

### Documentation

| Sub-category | Class | Why |
|---|---|---|
| Existing-doc improvements (clarity, precision, accuracy on docstrings/comments that already exist) | **Apply** | Behavior-preserving. Rewrite cost is symmetric to review cost. Future AI sessions read these and the cost of leaving them imprecise compounds. |
| Missing docstring on a function/module that is **entirely undocumented** | **Apply** | The gap is structural, not subjective — there's no debate about whether one "should exist." Apply when ≤5 lines of generated docstring. |
| Doc *expansion* of a section that already has some explanation ("this could use more detail") | **Surface** | Subjective; the human decides whether the existing explanation is sufficient. Matches CodeRabbit's separate-PR pattern for docstring generation. |
| Comment that is factually wrong (describes behavior that no longer exists) | **Apply** | Rot. Already in the standard Apply class. |
| README / ARCHITECTURE.md / CLAUDE.md prose improvements | **Apply** when ≤5 lines and clearly factual; **Surface** when stylistic or restructuring | Same gate as docstrings. |

### Defensive additions

| Sub-category | Class | Why |
|---|---|---|
| Null guard / type narrowing / assertion when there's a **concrete failing path** in the diff (the test suite would exercise it, or a demonstrated nil/error case appears in the changed code) | **Apply** | "Prove it or discard it" — if the foot-gun is real, the fix is cheap. |
| Speculative guard — "what if X were null someday" with no demonstrated path | **Surface** | This is the canonical noise category in practitioner literature. Speculative guards train people to ignore the bot. |
| Cleanup that prevents state leak between tests (missing `setup` / `teardown` / `finally`) | **Apply** | Concrete: the test pollution is reproducible. |
| Race window / silent failure with concrete timing or path evidence | **Apply** | Concrete defect. |

### Naming and renames

| Sub-category | Class | Why |
|---|---|---|
| Local-symbol rename, new name is a **fact-based correction** (the symbol is mis-named for what it does) | **Apply** | Cheap; tests catch breakage; future readability compounds. |
| Local-symbol rename, new name is a **taste improvement** (debatable better) | **Surface** | Genuine disagreement; human's call. |
| Cross-file rename, exported symbol, public API | **Apply with care** | Ripple effect across consumers; needs human scrutiny even when correct. |

### Test additions

| Sub-category | Class | Why |
|---|---|---|
| Test for an uncovered branch **on the diff**, when the test is small | **Apply** | Free coverage on code we just wrote. The branch is real; testing it costs nothing. |
| Test for code outside the diff | **Surface** | Out of scope for this PR; the pattern of "while we're here" tests grows the PR uncontrollably. |
| Suggested property-based / fuzz / load test as follow-up | **Surface** | Material new test infrastructure; human decides. |

### Style / formatting

| Sub-category | Class | Why |
|---|---|---|
| Formatter / linter violations not auto-caught by `mise run check` | **Apply** | If the project's check task should have caught it, fixing the lint is part of finishing. |
| Stylistic preference with a substantive rationale (e.g., consistency with a project pattern in `STANDARDS.md`, readability impact the agent can articulate) | **Surface** | Genuine taste call; human's judgment. |
| Stylistic nit the agent suggested without a strong rationale (one-liner vs multi-line, function vs method, naming flavor) | **Reject** | One-line dismissal in the hand-off. Surfacing these with verbatim rationale just inflates the user's review surface — that's the exact pattern that trains humans to ignore the bot. |

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

**Project may exclude additionally** (configure as the `pr-review-toolkit` configuration permits):

- **Bot-author or dependabot PRs** — reviewing automated dependency bumps line-by-line is rarely worth the tokens.
- **Docs-only PRs** — if the diff is entirely under `docs/` or `*.md`, skip the heavy review sweep; the simplify pass is enough.
- **Project-specific noise patterns** that emerge from the first month of running the toolkit. Add them here as you find them.

## Path-conditional aggressiveness

The rubric isn't uniform across path types. Adapt to where AI context is strongest vs weakest:

- **Test files** (`test/`, `tests/`, `*_test.*`, `__tests__/`) — **more aggressive Apply**. AI context for test-shape and assertion patterns is strong; blast radius is contained (test pollution catches itself). Naming, restructure-for-clarity, even modest refactors lean Apply.
- **Business logic** (`lib/`, `src/`, `apps/`) — **standard rubric**. Apply correctness/safety/behavior-preserving improvements; Surface style/structural changes.
- **Public API surface** (anything exported from a published package, anything a downstream consumer imports) — **more conservative Apply**. Even behavior-preserving renames have ripple effects. Apply with care for any signature change; Surface for any rename of an exported symbol.
- **Infrastructure / config** (`config/`, `.github/workflows/`, deployment manifests, `mise.toml` and equivalent) — **more conservative Apply**. Silent failures here are expensive (CI breaks, deploys break). Surface anything beyond strict factual fixes; let the human decide.

## Break-glass override

The "I disagree with the bot, ship anyway" escape hatch. Practitioners report it gets used <1% of the time at scale (Cloudflare: 0.6% of PRs across 30 days), so the bar is rare-but-real.

Two mechanisms:

1. **PR body marker**: include `<!-- skip-review-toolkit -->` (or similar agreed marker) in the PR description. `/finish` reads this in Step 1 and skips Step 7's review-toolkit invocation. Document the rationale in the PR body itself ("review-toolkit was wrong about X; addressing in follow-up Y").
2. **`/finish` flag** (if the user invoked manually with extra args): `--skip-review` on the slash command. Same effect.

Either path produces the same hand-off summary line: "Review-toolkit explicitly skipped per <reason>." Don't silently skip; the audit trail is in the PR body.

## Anti-patterns

### ❌ Auto-applying speculative findings

If the agent flagged something with no concrete failing scenario, no test pollution, no demonstrated path — Surface it. Auto-applying speculative changes trains future humans (and agents) to ignore the bot's findings; the noise is the cost.

### ❌ Squashing multiple Apply commits into one

Per `/finish`'s atomic-commits-not-squash discipline, each Apply finding gets its own focused commit on the branch. The squash happens at merge-time on `main` (the project's squash-merge convention), not pre-PR. One commit per logical fix.

### ❌ Applying when `mise run check` isn't passing first

Apply commits over a red branch hide regressions. Run `mise run check` after each Apply (or at minimum after the last in a batch); revert the Apply if it breaks the check, and reclassify as Apply-with-care or Defer.

### ❌ Re-running review-toolkit to override the human's earlier Surface decision

If the human reviewed the draft PR, decided to leave a Surface item alone, and the next sweep flags it again with the same reasoning — that's fine to surface again, but **don't auto-apply it**. The human's call stands until they explicitly ask for the change.

### ❌ Running review-toolkit on a docs-only PR

If the diff is entirely under `docs/` or matches `*.md`, the toolkit's specialized agents have nothing to chew on. Skip the sweep; the simplify pass is sufficient.

### ❌ Padding the hand-off summary with "looks good" prose

The hand-off is the audit surface. List counts per class plus the concrete actioned items and the verbatim Surface entries. If everything classified as Reject, say so in one line — don't pad.

## When to update this file

This rules file is load-bearing the moment `/finish` Step 7 dispatches `pr-review-toolkit`. Update it when:

- A finding type recurs in the Surface column that should clearly be Apply (or vice versa) — add a row to the Apply/Surface calibration table.
- A new noise pattern emerges that should be excluded — add it to the "What NOT to flag" list.
- A new project-local reviewer agent is authored — add it to § Project-local agents.
- A path-conditional pattern emerges (e.g., a project-specific directory that needs its own aggressiveness setting) — add a row to § Path-conditional aggressiveness.
- The break-glass mechanism gets used more than ~5% of the time — that's a signal the rubric is mis-calibrated, not the override mechanism. Investigate.

The corresponding entry in `docs/STANDARDS.md` § PR review process points here for the operational detail; that file states the principle, this file states the contract.

## References

The calibration here was synthesized from these practitioner sources:

- [Sourcery — Refactoring vs Suggestion auto-apply split](https://docs.sourcery.ai/Coding-Assistant/Reference/Rules-and-In-Line-Suggestions/Python/Default-Rules/) — behavior-preservation as the auto-apply gate
- [Cloudflare — Orchestrating AI Code Review at scale](https://blog.cloudflare.com/ai-code-review/) — exclusion lists, severity tiers, 0.6% break-glass rate
- [PhotoStructure — Most AI code reviews are noise](https://photostructure.com/coding/claude-code-review/) — "prove it or discard it" rule, omit unverified guards
- [Jet Xu — Drowning in AI Code Review Noise](https://jetxu-llm.github.io/posts/low-noise-code-review/) — signal/noise framework, Tier 1/2/3 severity
- [CodeRabbit Configuration](https://docs.coderabbit.ai/reference/configuration) and [Docstring generation](https://docs.coderabbit.ai/finishing-touches/docstrings) — opt-in for missing docs, separate-PR pattern
- [Anthropic — Code Review for Claude Code](https://claude.com/blog/code-review) — finding-rate by PR size, "won't approve PRs"
