# Judge rubric — the `/finish` A/B on [#<N>]

> **Template.** Fill the bracketed spots; the dimensions and the verify-before-you-score discipline are the exemplar. **Blindness leaks past the arm ids** (context-builder-kit#69): the filled rubric names no arm's mode and points the judges at no file that does (a verdict-rule file naming what each arm is), and before the panel runs the launching session records and moves out of each worktree any untracked artifact that reveals a mode (a subagent-driven arm's `.sdd/` workspace, a ledger, a brief copy). What an arm committed stays and is judged. Never point a judge at the headless runner's `out_dir`: each `<anon>.cmd` there holds the arm's argv, which names its instruction files and effort, and `executed.json` lists what each arm dispatched — so the runner writes the check logs beside it, in `<out_dir>.checks/`, and only that directory reaches a judge's prompt. Judges score the **work on the branch**, take the mechanical gate from the runner's log where the headless runner ran it (else run it themselves), and report contradicted claims before they rank.

Several executors implemented issue [#<N>] (`[<title prefix>]`, repository `[<owner/name>]`) non-interactively, each in its own git worktree, under different instructions. You do not know which arm is which. Judge the **work on the branch**, not the instructions. Verify before you score: read the issue (`gh issue view [<N>] --json title,body`), the frame's milestone section (`docs/cbk/frame-[NN].md` § Milestones › [F<#> — M<#>]), the decision records the issue cites ([`docs/adr/….md` clauses]), and the rules that bind (`.claude/rules/testing.md`, `.claude/rules/pr-review.md` § The floor and § Triage rubric, `.claude/rules/simplification.md`, [the project's test-naming and label sections in `docs/STANDARDS.md`]). Then, for each worktree, run and read:

- `git log --reverse --format='%h %s' <base>..HEAD` — the commit order is the red-first evidence
- `git diff --stat <base>...HEAD` and `git diff <base>...HEAD` — the whole change
- `PLAN.md` and `PR_BODY.md` at the worktree root
- the tests under [`<the test tree the issue names>`]
- the mechanical gate. When your prompt names the runner's log for a worktree (headless arms: `run-arms-headless.py` ran the check task once per arm, after every arm finished), read that log and its exit, and do not re-run the whole gate — parallel gates on one machine measure the machine, not the arms (re-running a single test file is fine). Otherwise run `cd <worktree> && [the check task]; echo exit=$?` yourself. Never trust the arm's own claim
- [any second gate the issue's test plan names, run the same way]

Score each dimension 1–5 with a one-sentence reason, then rank the arms your prompt names. Ties are allowed only with a reason.

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

[**The measures, per arm.** Keep this section only when the run has a verdict rule — a measurement issue's first criterion (the rough-in spec template's measurement variant) — and delete it otherwise. Paste each measure's definition here **verbatim** from the verdict rule; never restate it: a stricter paraphrase of one definition split a panel three to three (context-builder-kit#69). Report each measure per arm, as an observed fact, in the structured result's `measures`. `red_first`, `commit_per_finding`, `tags_resolve`, `criteria_met` and `contaminated_hunks` are the exemplar's names; a run's verdict rule names its own.]

[**Replay runs.** Keep this paragraph only when the arms replay an issue already implemented on the base branch. A hunk verbatim-identical to the merged implementation is a **candidate** for contamination, never a finding: the same model converges on the same code without having seen it, so a diff against a reference it wrote over-flags. List the candidates in `measures.contaminated_hunks`. You do not decide contamination: the launching session does, from each arm's transcript (any read of a commit, ref or PR past the replay's base), and a judge reads no transcript and nothing in the runner's `out_dir`.]

Write your full report to the path you are given, and return the structured result. Do not edit any file in any worktree or in the repository.
