# Operator brief — the `/finish` A/B on [#<N>] (non-interactive, throwaway)

> **Template.** Fill the bracketed spots for the run and pass this file's directory as `args.scratch`. Every gate the executor would stop at is converted here into a recorded decision — never removed.

You are executing issue **[#<N>]** — `[<title>]` — in the repository `[<owner/name>]`, **inside a git worktree of your own** (your current working directory). This is one arm of a two-arm experiment; the branch you produce is throwaway and will never merge. Work exactly as if it were real, except for the rules below.

## What non-interactive means here

- **No human answers you.** Where the flow stops for the operator (the plan gate, a question, a permission), make the call you would propose, write it down, and continue. Record every such call in your final return under `gate_calls`.
- **The plan gate is a file.** Plan mode is unavailable to you. Write the plan to `PLAN.md` at the worktree root, treat it as approved, and proceed. The plan must still carry every `[ASSUMPTION:]` line of the issue as a confirm-or-correct item with your resolution.
- **Never run the product.** [Name the commands that would touch shared hardware, a device, a live service or the network — two arms share one machine.] Building and testing (`[the project's build command]`, `[the project's test command]`, `[the check task]`) are allowed and expected. Every acceptance criterion that needs a real run is **operational** for this experiment: leave it honestly open in the PR body and hand-off, with what the operator must do.
- **No remote writes.** Do not push, do not open a PR, do not create, edit, comment on or label any issue, do not run any `gh` write command. Reading with `gh` is fine. Write the PR body you would have submitted, complete, to `PR_BODY.md` at the worktree root.
- **The review floor is available to you** — invoke `/simplify` and `pr-review-toolkit:review-pr` as skills, exactly as the instructions you were given require, and triage their findings. The project's review **workflow** cannot run from inside a dispatched agent; record that on the sweep's line of the `## Review gate` block as skipped, with that reason. Do not claim any invocation you did not make.
- **Stay in your worktree.** Do not edit, create or delete anything outside your current working directory. Do not touch the main checkout, the scratch directory of the session that launched you, or the other arm.
- **Commit on your own branch** (create it from the worktree's current commit, named per the project's convention), never on the base branch.

## Standing decisions you inherit (do not re-decide)

- Everything in the issue body's `## Assumptions` stands unless your research proves a line false; then correct it in `PLAN.md` and say why.
- [One line per decision the gate would otherwise re-open — a path the operator approved, a rule the frame states, a dependency the operator supplies from outside the repo.]

## Hard limits

- Do not modify `docs/cbk/*`, `docs/adr/*`, `.claude/*`, the check task's dependency list, [or the product packages the issue does not name].
- Do not install system packages or change the machine's configuration.
- Stop when the branch, `PLAN.md`, `PR_BODY.md` and the hand-off exist; do not wait for anything.

## What to return

The structured result: your branch name, the worktree path, the ordered commit list (SHA and subject), the paths of `PLAN.md` and `PR_BODY.md`, the exact `check`-task command you ran last and its exit status, the test names you wrote, which skills you actually invoked (by name), the criteria you left operational, every gate call you made, and brief notes. The hand-off text goes in `handoff`.
