# Roadmap template — `docs/cbk/ROADMAP.md`

Emitted by blueprint on the **github-issues** and **in-repo-markdown** planning axes (on `linear`, the planner's projects carry the sequence). It answers the question those axes otherwise cannot: *where are we, and what is next* — issues carry the detail, labels carry state, a saved filter shows a pool, but none of them shows the order the work happens in or which step is current. Framing reads it as an input and appends a row per milestone in the same atomic commit as the frame; rough-in flips a row to *roughed-in*; `/finish` flips a row to *done* on the PR's own branch (`.claude/commands/finish.md` item 8) or the post-merge checklist does. The kit's conventions record its mutation class (`cbk-conventions.md` § Mutation discipline).

## The template

```markdown
# Roadmap — where we are, where we are going

**A living status surface, freely mutable** (unlike the cascade events index, which is append-only). Read it first when returning cold; the issue it points at has the detail. **Who keeps it current:** blueprint wrote it; **framing** adds a row per milestone it cuts and links the `F` issue, in the same commit as the frame; **rough-in** flips a row to *roughed-in* and links the `R` issues; **`/finish`** flips a row to *done* and links the PR — on the PR's own branch, as the last commit before the PR opens, with the PR number read ahead from the repository's shared issue-and-PR sequence and checked at creation (`.claude/commands/finish.md` item 8), or the post-merge checklist flips it when the spec did not name the flip. An `R` issue short of the milestone's capstone updates the row's progress note and the `## Now` paragraph the same way. Anything else that changes the sequence — a milestone re-cut, a horizon item pulled forward — edits the table in the same PR. A row that is wrong is fixed in place; this is not an audit trail (that is `docs/cbk/README.md` and git history).

## Now

**Step <#> — <name>, <state as of date>.** <Two to five sentences: what landed, with the PR links; what the next runnable command is (`/finish <N>`, `rough-in <milestone>`, `framing <workstream>`); what is blocked and on what.> **▶ Next: <the one next action>.**

## The sequence

Ordered by dependency, not by preference. <One sentence on which steps are independent and meant to interleave.>

| # | Step | Workstream | What "done" is | Depends on | Status | Where |
|---|---|---|---|---|---|---|
| 0 | **Bootstrap** — <the handoff issue's contents in a phrase> | — | <the check task green locally and in CI; handoff issue closed> | blueprint merged | planned | <handoff issue link> |
| 1 | **<capability>** — <one line> | `<slug>` | <the observable "done", as the frame states it> | 0 | planned | <blueprint § Core Projects row; the F issue once framed> |
| 2 | … | | | | | |

**Status vocabulary**: *now* · *planned* (blueprint only) · *framed* (an `F` issue exists) · *roughed-in* (`R` issues exist, `/finish`-able) · *in progress* (a branch is open) · *done* (merged — or written by `/finish` on the merging PR's own branch, per the paragraph above) · *horizon* (tracked, no timeline) · *retired* (superseded; say by what).

## Cascade position

| Phase | State |
|---|---|
| consultation | done — `problem_brief.md` |
| scaffold | done — `scaffold.md` |
| blueprint | done — `blueprint.md`, the ADRs, the foundation docs, the tooling |
| framing | <not started · in progress — `<slug>` framed <date> (`frame-NN.md`) · …> |
| rough-in | <not started · in progress — which milestone, which R issues> |
| `/finish` | <not started · in progress — which PRs merged> |

## Seeing the same thing from the tracker

```bash
gh issue list --state open --label 'cascade-depth:framed'      # milestones cut, not yet roughed-in
gh issue list --state open --label 'cascade-depth:roughed-in'  # /finish-able now
gh issue list --state open --label enhancement                 # shaped by /intake, awaiting cascade work
gh issue list --search 'Blueprint handoff in:title'            # step 0
```
```

## Authoring guidance

- **One row per step the sequence needs to show**, not per issue: a workstream's milestones are rows once framing cuts them; before that the workstream is one *planned* row pointing at its blueprint entry.
- **`## Now` is a paragraph, not a table** — it carries the narrative a returning reader needs (what landed, what is next, what is blocked), with links; keep it current every time a row flips.
- **On `in-repo-markdown`** the `## Seeing the same thing from the tracker` section is dropped and the `Where` column points at the markdown issue records.
- **Never let the roadmap become the audit trail**: a superseded row reads *retired — superseded by <row>*; the events index and git history hold what happened.
