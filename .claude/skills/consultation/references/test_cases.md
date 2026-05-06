# Test cases for the consultation skill

Three realistic test prompts that exercise the full range of consultation scenarios. These are the contract for "consultation works": when the skill is run on these prompts, the output should produce a faithful problem brief and the conversation should hit the expected steps without skipping or solutionizing prematurely. Use them when revising the skill to verify nothing regressed.

For Claude.ai's qualitative test loop (no subagents, no benchmarking): a real human runs the skill on each prompt as if they were the user, then judges the output against the success criteria below. There's no automated grader for this skill — the outputs are too prose-heavy and the quality criteria are too qualitative.

## Test 1 — vague greenfield idea

**Prompt** (user opening message, no prior context):
> "I want to make a thing that helps people learn how to use the command line. Like, actually learn it, not just read about it."

**What success looks like:**
- The skill detects `prior=greenfield` and proposes `standard` rigor
- Step 1 (problem discovery) probes who the target users are and why current resources fail them, **without** jumping to solutions
- Step 2 (appetite) gets a concrete time/effort budget before any solution sketching
- Step 3 produces 2-3 rough approaches at different fidelity levels, not a single committed solution
- Step 4 surfaces real risks (pedagogy reinvention, scope creep, tool stress)
- The brief has at least one no-go and 3+ measurable success criteria
- The brief is delivered as a downloadable markdown file plus inline summary

**What failure looks like:**
- Skill jumps to "let's use Rust + Ratatui" before establishing the problem
- Brief has no no-gos or has vague no-gos like "no scope creep"
- The conversation never asks "who is this for" with enough specificity to make design decisions

## Test 2 — brownfield rework

**Prompt** (user has an existing project):
> "I have an existing Python script that processes CSVs from clients and uploads them to S3. It works but it's a mess. I want to rebuild it as a proper service with a queue and retry logic and probably a small admin UI. Where do I start?"

**What success looks like:**
- The skill detects `prior=brownfield` and loads `references/brownfield_addendum.md`
- The current-state assessment step runs first: what exists, what works, what constraints the existing system imposes
- The problem brief has the additional `## Current state` section
- Step 3 (solution sketching) acknowledges what's being preserved vs. what's being replaced
- The brief flags whether a deeper codebase analysis is needed at blueprint time
- No-gos include things the rewrite explicitly will NOT do (e.g., "no rewrite of the CSV format spec")

**What failure looks like:**
- Skill ignores the existing system and treats the brief as greenfield
- Skill jumps into a code review of the existing Python script (that's blueprint's job)
- Current state section is generic ("Python script that does CSV stuff") rather than specific

## Test 3 — partial-context with stack preference

**Prompt** (user has a sketch and a stack but no formal plan):
> "I want to build a personal dashboard for my home automation stuff. I'm thinking React on the front, probably FastAPI on the back, SQLite for storage. Help me figure out what the actual MVP should be."

**What success looks like:**
- The skill detects `prior=partial` and acknowledges the stack preference as a *constraint*, not a decision
- The skill explicitly defers stack decisions to blueprint and notes them in the brief as "preferences flagged for blueprint"
- Step 1 still probes the problem (what specifically about home automation needs a dashboard, what's broken about current solutions)
- Step 2 gets an honest appetite — personal projects often have hidden "weekends only" constraints
- Step 3 sketches 2-3 MVP scopes at different ambition levels (read-only viewer / interactive controls / automation builder)
- The brief carries the stack preferences forward to blueprint without locking them in

**What failure looks like:**
- Skill writes "we'll use React + FastAPI + SQLite" into the brief as a decision (those belong in blueprint)
- Skill skips problem discovery because the user "already knows what they want"
- MVP scope is unbounded or matches the user's most ambitious description without trade-off discussion

## How to use these tests when revising the skill

1. Pick one or more tests to run
2. Run the consultation skill on the prompt (in a real session, not synthetic)
3. Compare the actual output and conversation flow against the success criteria
4. If a failure mode triggers, capture the specific failure as a post-mortem item
5. Apply targeted fixes to SKILL.md or the relevant reference file
6. Re-run the same test to verify the fix

The Claude.ai-appropriate variant of this loop (per `skill-creator`'s guidance for environments without subagents) is qualitative — there's no automated grader and no quantitative benchmark. The success criteria above are the rubric a human reviewer uses to judge whether the test passed.
