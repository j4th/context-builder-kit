# Test cases for the scaffold skill

Three realistic test prompts that exercise scaffold's profile selection, discovery step, and provisioning flow. These are the contract for "scaffold works": when run on these prompts, the output should produce a faithful `docs/cbk/scaffold.md` and the conversation should hit the expected gates without skipping the safety floors. Use them when revising the skill to verify nothing regressed.

For Claude.ai's qualitative test loop (no subagents, no benchmarking): a real human runs the skill on each prompt as if they were the user, then judges the output against the success criteria below.

## Test 1 — solo greenfield, GitHub-only, full mode

**Prompt** (user has a fresh problem brief from consultation):
> "I just finished consultation for a CLI learning tool. Solo project, Rust, no team. Let's set up the workspace — keep things simple since I'm working alone."

**What success looks like:**
- Skill detects greenfield + solo + light-mode-leaning, but proposes **full mode** with the option to drop to light if the user pushes
- Profile selection proposes GitHub-only and surfaces the three-level constraint in one sentence before commitment
- Discovery captures team shape (solo), quality bar, PR/review process (likely "self-merge with self-review"), tool comfort, and pace
- Stage 1 confirms account state without lengthy interrogation
- Stage 2 provisions repo via GitHub MCP, walks user through manual label creation, branch naming uses a short team identifier
- Stage 3 produces `docs/cbk/scaffold.md` with all five sections populated and commits both `problem_brief.md` and `scaffold.md` to `docs/cbk/`
- Bootstrap checklist surfaces what's manual

**What failure looks like:**
- Skill skips the three-level constraint conversation
- Discovery is treated as optional and the scaffold output doc has empty Team Shape or empty Development Preferences
- Skill commits scaffold.md before presenting it inline
- Scaffold.md is generic ("solo dev, default conventions") rather than specific to the user's actual answers

## Test 2 — solo brownfield, GitHub-only, light mode

**Prompt** (user has an existing repo and wants to retrofit the cascade):
> "I have an existing repo for a Python data pipeline. I want to add the cascade to it without disrupting anything that's already there. Can you scaffold around what's already in place? Keep this fast — I just need the cascade artifacts on top of what exists."

**What success looks like:**
- Skill detects brownfield + light mode and proposes light explicitly: *"I'll run in **light** mode given the brownfield context — say 'go full' if you want every gate."*
- Brownfield audit (`references/brownfield_audit.md`) runs: lists existing labels, branches, project boards, asks what to keep / replace / avoid
- No write operations happen on resources marked "do not touch" during the audit
- Stage 2 provisioning is additive: adds `docs/cbk/` to the existing repo, adds cascade-standard labels alongside (not replacing) existing ones, does not rewrite existing branch protection or workflows
- Stage 3 scaffold.md notes the brownfield context explicitly, including which existing resources were preserved
- Even in light mode, the discovery step captures team shape and quality bar (the light-mode safety floor)

**What failure looks like:**
- Skill silently overwrites existing labels or branch naming conventions
- Scaffold.md doesn't note the brownfield context, making blueprint think it's a fresh repo
- Discovery is skipped entirely because the user said "keep this fast" — violates the light-mode safety floor

## Test 3 — small team, opinionated profile (stub graceful handling)

**Prompt** (user wants the Linear+GitHub profile):
> "We're a team of 4 working on a SaaS product. We use Linear for planning and Notion for docs. Set up the cascade with all three tools — Linear, Notion, and GitHub."

**What success looks like:**
- Skill detects opinionated profile preference and acknowledges it explicitly
- Skill **discloses honestly** that the opinionated profile is a stub : *"The opinionated profile (Linear+GitHub) is fully validated. I'll walk through what's documented and flag gaps as we hit them. If we hit something I don't have a clean answer for, I'll either fall back to manual instructions or offer to switch to GitHub-only for this phase. Sound okay to start?"*
- Discovery captures team shape with team-specific questions (timezone, decision recording, review process)
- Skill attempts what is documented and falls back to manual instructions for what isn't
- Scaffold.md notes the gaps explicitly so blueprint inherits a complete picture of what was set up vs. what wasn't

**What failure looks like:**
- Skill pretends the opinionated profile is fully fleshed out and produces fictional Linear MCP tool calls
- Skill silently switches to GitHub-only without telling the user
- Skill fails to capture team-specific discovery questions (timezone, decision recording, review)
- Scaffold.md doesn't surface the gaps, so blueprint inherits the false impression that everything was provisioned

## How to use these tests when revising the skill

1. Pick one or more tests to run (Test 1 is the canonical happy-path; Test 2 exercises brownfield + light mode together; Test 3 exercises stub-handling honesty)
2. Run scaffold on the prompt in a real session — not synthetic
3. Compare the actual conversation flow and `scaffold.md` output against the success criteria
4. If a failure mode triggers, capture the specific failure as a post-mortem item
5. Apply targeted fixes to SKILL.md or the relevant reference file
6. Re-run the same test to verify the fix

The Claude.ai-appropriate variant of this loop (per `skill-creator`'s guidance for environments without subagents) is qualitative — there's no automated grader and no quantitative benchmark. The success criteria above are the rubric a human reviewer uses to judge whether the test passed.
