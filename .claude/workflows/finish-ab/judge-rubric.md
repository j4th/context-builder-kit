# Judge rubric — the `/finish` A/B on [#<N>]

> **Template.** Fill the bracketed spots; the dimensions and the verify-before-you-score discipline are the exemplar. Judges score the **work on the branch**, run the mechanical gate themselves, and report contradicted claims before they rank.

Two executors implemented issue [#<N>] (`[<title prefix>]`, repository `[<owner/name>]`) non-interactively, each in its own git worktree, under different instructions. You do not know which arm is which. Judge the **work on the branch**, not the instructions. Verify before you score: read the issue (`gh issue view [<N>] --json title,body`), the frame's milestone section (`docs/cbk/frame-[NN].md` § Milestones › [F<#> — M<#>]), the decision records the issue cites ([`docs/adr/….md` clauses]), and the rules that bind (`.claude/rules/testing.md`, `.claude/rules/pr-review.md` § The floor and § Triage rubric, `.claude/rules/simplification.md`, [the project's test-naming and label sections in `docs/STANDARDS.md`]). Then, for each worktree, run and read:

- `git log --reverse --format='%h %s' <base>..HEAD` — the commit order is the red-first evidence
- `git diff --stat <base>...HEAD` and `git diff <base>...HEAD` — the whole change
- `PLAN.md` and `PR_BODY.md` at the worktree root
- the tests under [`<the test tree the issue names>`]
- `cd <worktree> && [the check task]; echo exit=$?` — the mechanical gate (run it; do not trust the claim)
- [any second gate the issue's test plan names, run the same way]

Score each dimension 1–5 with a one-sentence reason, then rank the two. Ties are allowed only with a reason.

1. **Spec fidelity.** Each `[R<#>.AC<m>]` criterion is either implemented with the named proof present, or honestly left operational with the reason. Penalise silent drops, quiet reinterpretation, and criteria claimed done that need the operator or a device.
2. **Assumptions.** `PLAN.md` carries every `[ASSUMPTION:]` line of the issue as confirm-or-correct with a resolution; corrected ones show in the diff.
3. **Test quality and red-first evidence.** The named tests exist with their tags verbatim; logic-regime tests were committed red before the implementation (commit order and the first committed body); no muted or skipped tests; assertions test properties, not snapshots.
4. **Implementation quality within scope.** [The issue's own shape, stated as checks: the named files, the constraints the frame fixes, what the spec forbids.] No cascade-artifact, ADR or check-task edits; lockfiles changed through the tool, never by hand.
5. **Review-gate honesty and triage quality.** The `## Review gate` lines in `PR_BODY.md` are literally true against the arm's self-report (the launching session cross-checks transcripts); triage classes follow the rubric; Apply items exist as their own commits with the SHAs the body names; Surface entries carry verbatim rationale.
6. **Diff size and reviewability.** Could one reviewer read this PR in one sitting? Penalise bulk beyond the spec and files the spec forbade; reward a diff whose shape follows the spec.
7. **Hand-off and PR body prose.** Standing on its own, honest about what is open, no re-quoted spec, no narration, [any project-required block present with the right citations].

Also report:

- **hallucinations** — any claim in `PR_BODY.md`, `PLAN.md`, commit messages or code comments that the repository, the pinned package source, or the issue contradicts. Quote the claim verbatim and name the contradicting source with a path and line.
- **graft** — ideas from the loser worth carrying into the winner.
- **word counts** — `PR_BODY.md` and `PLAN.md`, and the diff's added-line count.

Write your full report to the path you are given, and return the structured result. Do not edit any file in either worktree or in the repository.
