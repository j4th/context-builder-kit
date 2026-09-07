---
description: Read the open review feedback on a PR, triage every comment per the four-class rubric in `.claude/rules/pr-review.md`, apply the Apply / Apply-with-care findings as atomic per-finding commits (re-running the project's check task after each), reply to every thread with a commit SHA (actioned) or a justified verdict (Surface / Defer / Reject), push, and post a top-level triage-count summary. Expects one positional argument — the PR number.
argument-hint: <pr-number>
---

You are being asked to respond to the open review feedback on PR **#$1** in this repository.

This is the **PR feedback loop** — the inverse direction of `/finish`. Where `/finish` reads a rough-in sub-sub-issue and runs the simplify + review pipeline locally to produce a draft PR, `/pr-respond` reacts to review comments already posted on an existing PR: it triages every comment, applies the ones that meet the Apply bar, and replies to every thread with either a commit reference (for actioned findings) or a justified deferral (for the rest).

This executor is a living document — revised as real runs surface gaps. If the instructions below don't match what you're seeing — the PR has no review comments, the branch doesn't match the PR, the comments come from a tool that isn't in scope — **surface the gap to the user** rather than improvising past it. Improvisation is what causes the spec and the executor to drift apart over time.

## Step 1: Read the PR + review comments

Read PR #$1 and all its open review threads:

- **PR metadata**: `gh pr view $1 --json number,title,body,state,headRefName,headRefOid,baseRefName,isDraft,labels,reviews,reviewDecision` (or the github MCP equivalent)
- **Review comments** (line-specific): `gh api repos/{owner}/{repo}/pulls/$1/comments`
- **PR conversation comments** (top-level): `gh api repos/{owner}/{repo}/issues/$1/comments`
- **Review summary entries** (the "Files changed" review submissions): `gh api repos/{owner}/{repo}/pulls/$1/reviews`

Verify:

- The PR exists and is **not merged**. If merged, stop: *"PR #$1 is already merged. There's nothing to respond to."*
- You're on or can switch to the PR's head branch (`gh pr checkout $1`). If the local branch is in an inconsistent state with the PR (uncommitted changes, divergent commits), surface and ask.
- The PR has at least one open review thread or top-level comment requesting changes. If there are none, stop: *"PR #$1 has no open review threads. Nothing to respond to. (If you're expecting reviews but don't see them, the reviewer may still be in-flight.)"*

Filter the comment set:

- **Include**: top-level summary comments AND inline review comments that have NOT been marked resolved.
- **Exclude**: bot-posted comments that are clearly progress trackers (e.g., an auto-review's "I'm reviewing…" tracker comment, distinguishable by structure or author).
- **Exclude**: your own prior `/pr-respond` summary comments and per-thread replies — filtering these out is what keeps the loop from feeding on itself.

## Step 2: Pre-flight checks

Before staging any code change:

- **Check out the PR branch**: `gh pr checkout $1`. If checkout fails, stop and surface.
- **Verify the working tree is clean**: `git status --short` should report no changes. If dirty, surface and ask whether to stash, abort, or proceed cautiously.
- **Verify the project's check task is currently green on the branch.** If it's already red before you start, fixing it shouldn't happen implicitly inside `/pr-respond`. Surface and ask whether to first fix the existing red state via a separate flow.

## Step 3: Triage every comment per the four-class rubric

For each open comment thread (both inline and top-level), classify it per **`.claude/rules/pr-review.md`** — that file is the canonical source for the four-class rubric, the per-category Apply/Surface calibration (docs, defensive additions, naming, test additions, style), the "What NOT to flag" exclusion list, the path-conditional aggressiveness, and the anti-patterns. Read it now if it isn't already in context.

**Quick summary of the rubric for orientation** (the rules file is authoritative when in doubt):

- **Apply** — behavior-preserving fix with concrete evidence of need (defect with a reproducible failing path, factually wrong comment / rot, dead code, defensive addition with concrete evidence, local-symbol rename when fact-based, missing docstring on an entirely-undocumented surface) **or** a low-risk small change (≤ ~15 LOC, confined, no design call required, plausibly an improvement). Each Apply gets its own atomic commit.
- **Apply with care** — execute as its own commit but flag in the summary so the user scrutinizes: cross-file refactor >~50 LOC, new module outside the changed files, or a non-obvious correctness fix.
- **Surface** — do not apply; reply explaining why you're leaving it. Genuine design or taste calls only: the existing form is also fine, a speculative defensive guard with no concrete failing scenario, a suggested abstraction where the rule-of-three isn't yet hit.
- **Defer** — conflicts with an ADR, falls under the PR's `## Out of scope`, or contradicts the framing issue's intentional design. Do not apply; reply with the framing concern named explicitly.
- **Reject** — the reviewer factually misunderstood the codebase, OR a style nit suggested without a strong rationale. Do not apply; reply with a one-line dismissal.

**Calibration reminders** (the rules file governs):

- **When uncertain about a small low-risk change, Apply. When uncertain about a design or taste call, Surface.**
- **Don't bias away from being defensive.** Race guards, missing cleanups, and future-edit foot-guns are correctness concerns even when the test passes today — Apply, not Surface.
- **Medium-confidence findings follow the same triage as high-confidence findings** — confidence is about whether the finding is real, not whether to apply it.
- **Reviewer disagreement** (two reviewers said opposite things): pick the option aligned with project rules (`.claude/rules/`, ADRs, `docs/STANDARDS.md`) and note the disagreement in the summary so the user can sanity-check.
- **Multiple comments on the same line** with the same finding: treat as one triage decision; reply on each thread referencing the same commit.

If a comment is **a question rather than a finding** (e.g., "why did you choose X here?"), respond with an explanatory inline reply — no triage class needed. Don't shoehorn questions into the rubric.

## Step 4: Apply the actionable findings

For each finding classified **Apply** or **Apply with care**:

1. Implement the fix on the PR branch.
2. Commit as its own atomic commit with a Conventional Commits message that names the finding, e.g. `fix(<scope>): guard the null case the reviewer flagged (review thread #<id>)` or `refactor(<scope>): rename <symbol> per reviewer (review thread #<id>)`. Reference the review-thread ID (or the reviewer's verbatim issue) so each commit is traceable back to the comment it answers.
3. **Re-run the project's check task after each Apply.** If it goes red, revert that commit (`git reset --hard HEAD~1` while it's still local-only) and reclassify the finding as **Apply with care** (a more careful re-attempt) or **Defer** (with the explanation surfaced in the reply).

**One commit per Apply**, not bundled. The atomic-commit history is what the reviewer reads to verify each action; bundling defeats that audit surface.

**Tooling note.** If a comment asks for a local-symbol rename or a cross-file refactor, prefer the built-in `LSP` tool (find-references / safe-rename, via the language plugin; an MCP only for a language without one) over hand-editing call sites. Before making a defensive change the reviewer flagged against a library's behavior, verify that behavior against current documentation rather than from memory.

## Step 5: Reply to every thread

For each open review thread, post a reply. The shape depends on the triage class:

| Class | Reply shape |
|---|---|
| **Apply** | `Applied in <abbrev-SHA>: <one-line action taken>.` Example: `Applied in a1b2c3d: added a null guard before the write path; regression test added in the module's test file.` |
| **Apply with care** | `Applied in <abbrev-SHA> (flagged for scrutiny): <one-line action> — <reason for the "with care" flag>.` Example: `Applied in e4f5a6b (flagged): renamed an exported symbol across N call sites — please verify the rename caught everything.` |
| **Surface** | `Surface — leaving as-is. <one-line rationale: why the existing form stands>.` Example: `Surface — leaving as-is. The existing structure is also fine here; the alternative is a taste preference and wouldn't improve readability for a future maintainer.` |
| **Defer** | `Deferred — <one-line reason citing ADR / framing / scope>.` Example: `Deferred — this would require revisiting ADR-NNNN. If the project decides to change that architectural decision, that's a new ADR, not a PR-comment fix.` |
| **Reject** | `<one-line dismissal>.` Example: `The reviewer's claim that this function writes to <system X> is incorrect — it only writes to <system Y> per docs/STANDARDS.md § <relevant contract>.` |

Use the GitHub PR review reply API (or `gh api repos/{owner}/{repo}/pulls/$1/comments/<comment-id>/replies`). One reply per thread.

**For top-level / summary comments** that don't tie to a specific line, post a top-level PR comment that addresses each finding raised in the summary by quoting it briefly.

**Cite the commit SHA explicitly** in every Apply / Apply-with-care reply. The SHA is the reviewer's verification surface — they click it to see the diff for that specific finding.

## Step 6: Push commits

```bash
git push origin <branch>
```

If the push fails (auth, network, branch protection that requires being up-to-date with base), stop and surface per § Partial failure handling. Local commits with no remote means the reviewer sees replies citing commit SHAs that aren't visible — confusing.

## Step 7: Top-level summary comment — and the body's round block

**Append the round to the PR body first.** The PR body is the audit surface for the PR's whole life (`finish.md` item 8): append a `## Triage — round N` block — N the count of feedback rounds so far — listing every thread of this round under its class in the same `SHA: fix` / verbatim-rationale / one-line-dismissal shape as the original `## Triage`, via `gh pr edit $1 --body-file` on the fetched body (append, never rewrite; the original `## Review gate` and `## Triage` blocks stay as they were). A comment alone scrolls away; the body is what a reader of the merged PR opens.

Then post one top-level comment on the PR (an issue comment, not a review) summarizing the response cycle:

```markdown
## /pr-respond summary

Triage counts: Apply: N · Apply with care: N · Surface: N · Defer: N · Reject: N

Applied commits:
- <abbrev-SHA>: <one-line action> (thread #<id>)
- <abbrev-SHA>: <one-line action> (thread #<id>)
- ...

Non-action verdicts:
- Surface: <count> — see per-thread replies for verbatim rationale
- Defer: <count> — see per-thread replies for framing concerns
- Reject: <count> — see per-thread replies for dismissals

Project check task: green on the resulting branch state.

PR is still in <draft|ready> state. Operator owns the next move (flip to ready, request another review, merge).
```

This summary is for the operator's audit — it doesn't replace the per-thread replies; it makes the round visible at a glance.

## Step 8: Hand off

End your turn with:

1. **PR URL** — `<https://github.com/.../pull/$1>`
2. **Triage counts repeated** — one line.
3. **One-line next action** for the operator: *"Replied to all <N> threads on PR #$1. Apply commits pushed. Operator decides: flip to ready (if currently draft), request another review, or merge."*

Do not call `gh pr ready`. Do not merge. Do not auto-add review-trigger labels. Those are the operator's calls.

## What `/pr-respond` does NOT do

- **Does not modify the PR title or description body** (except by posting the NEW top-level summary comment in Step 7, which is not an edit of the description). If a reviewer asks for description changes, surface and ask whether to make them.
- **Does not flip the PR from draft → ready or ready → draft.**
- **Does not merge the PR.**
- **Does not request another reviewer or add review-trigger labels.**
- **Does not close, resolve, or hide review threads.** Replies post to open threads; resolving them is the operator's call after they've verified the actions.
- **Does not respond to its own prior replies** (avoid loops). Filter your own prior `/pr-respond` summary comments and per-thread replies from the comment set in Step 1.
- **Does not modify cascade artifacts, ADRs, or `.claude/rules/*.md`.** If a review comment asks for those, the change goes through a separate flow (a chat-skill cascade phase or a new dedicated PR). Surface the gap.
- **Does not skip the four-class triage.** Every comment in the set gets a class and a reply. No silent ignores.

## Break-glass — operator override per-comment

If the operator has marked a specific thread with a directive like `<!-- skip-respond -->` or `<!-- defer -->` (or instructed `/pr-respond` to skip a thread in the invocation prompt), respect it: skip that thread and record the skip in the Step 7 summary as "<thread #id>: operator-instructed skip." Don't silently skip.

## Partial failure handling

If any external operation — the `gh` CLI, the github MCP, an MCP fetch, or a Bash `git` / check-task call — fails or hangs, **stop immediately** and surface the partial state with a per-step status. Do not retry blindly; the failed call may have succeeded server-side, and a retry would duplicate.

If you're mid-Apply (some commits pushed, some not), surface the SHAs already pushed and the findings still pending. The operator decides whether to continue, revert, or abort.

## When something surprises you

Surfacing > improvising. Common surprises worth flagging:

- **The PR head SHA in your local branch doesn't match the remote.** Someone pushed while you were planning. Pull or surface — don't ignore.
- **A review thread references an old SHA that no longer exists** (after a force-push). The thread's anchor is broken. Surface and ask whether to reply anyway (referencing the new HEAD) or treat it as a stale thread.
- **The reviewer asked for a change that conflicts with a hard constraint in `CLAUDE.md` or an ADR.** Defer with the constraint named explicitly. Do not silently violate.
- **Multiple findings disagree.** Pick the option that aligns with project rules (`.claude/rules/`, ADRs, `docs/STANDARDS.md`) and note the disagreement in the Step 7 summary so the operator can sanity-check.
- **The PR was merged while you were running.** Stop. Tell the operator. No further action makes sense.
