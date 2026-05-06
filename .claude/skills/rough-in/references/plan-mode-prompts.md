# Plan-mode prompts — the load-bearing output of rough-in

This file is the operational detail behind the Implementation section of the rough-in spec template. It covers what makes a Claude Code plan-mode prompt effective, the properties of a good prompt, common pitfalls with worked examples, and the section-anchoring pattern that `/finish` uses to identify the prompt-relevant content within a sub-sub-issue body.

This is the reference rough-in consults most often during Step 5 (drafting individual specs). The Implementation section of every sub-sub-issue is functionally a Claude Code plan-mode prompt — getting it right is what makes `/finish` work cleanly and what makes rough-in valuable over just "framing plus a wish list of intents."

## What `/finish` does with the spec

`/finish {issue_number}` is the Claude Code slash command that picks up a rough-in sub-sub-issue and executes it. It will be defined in CLAUDE.md by the bootstrap-finish skill (the sixth and final in-chat skill, scoped to writing the finish section into CLAUDE.md once M1 of the first workstream has been built by hand). For now, the contract `/finish` will follow is:

1. **Read the issue body** via `issue_read get`
2. **Identify the section structure** by parsing `## ` headings — anchor on the standard six sections (Context / Implementation / Acceptance criteria / Done signal / Dependencies / PR contract)
3. **Verify the Dependencies section** — for each issue number listed, query its state and confirm it's closed. If any dependency is open, refuse to proceed and surface the unmet dependency to the user.
4. **Hand the body to Claude Code's plan mode** with the Implementation section as the primary anchor and the other sections as supporting context. Plan mode is allowed to fetch additional context (read cited docs, look at sibling files, query the parent framing sub-issue) but doesn't *need* to because the spec is self-contained.
5. **User reviews the plan**, approves or iterates
6. **Execute the plan** — Claude Code writes the code, runs the tests, iterates until the acceptance criteria are met
7. **Open the PR** following the PR contract section, with `closes #<this_issue_number>` in the description
8. **Board automation** moves the issue to Done on PR merge and ticks the parent's sub-issue progress field forward

The Implementation section is the load-bearing input to step 4. The other sections constrain what step 4 produces (acceptance criteria become test targets, done signal becomes the verification command, dependencies prove the issue is unblocked, PR contract dictates how step 7 happens) but the Implementation section is what plan mode reads as its primary instruction.

## Eight properties of a good plan-mode prompt

A plan-mode prompt — meaning the Implementation section of a rough-in sub-sub-issue — has eight properties. Drafted prompts that don't have all eight should be revised before the spec is approved.

Before the properties themselves: **rough-in's target executor is Claude Code plan mode, not a human typing each sub-sub-issue by hand.** This is load-bearing for how Implementation sections should be shaped. [Anthropic's Claude Code best practices doc](https://code.claude.com/docs/en/best-practices) frames the four-phase workflow as *"Explore → Plan → Execute → Commit"* and says directly: *"Separate research and planning from implementation to avoid solving the wrong problem. Letting Claude jump straight to coding can produce code that solves the wrong problem."* The Implementation section is the input to plan mode's Plan phase — it tells plan mode **what** to build and **why it matters architecturally**, not **how to type it out**. Exact file paths, invariants that must hold, and type signatures from locked interface commitments are "why"; inlined function bodies, prescribed test function names, and step-by-step command sequences are "how" and override plan mode's priors in ways that produce strictly worse code than a cleaner prompt would.

Properties 1-7 are shape and discipline checks. Property 8 is the calibration check that catches the most common failure mode for Claude-Code-executed workflows.

### 1. Written in second person

The prompt is an instruction, not a description. Write *"Create `crates/core-engine/src/verifier.rs`..."* not *"The file `crates/core-engine/src/verifier.rs` should exist..."*. Plan mode reads second-person prose as something it can act on; third-person descriptive prose reads as documentation that summarizes what already exists.

**The discipline test**: every sentence in the Implementation section should start with a verb that the executor (human or Claude Code) can perform. *Create. Add. Update. Modify. Implement. Define. Wire. Configure. Run. Verify.* Sentences that start with "The trait..." or "There should be..." are descriptions, not instructions.

### 2. Self-contained without forced external context

The prompt should be readable cold. A competent implementer (human or Claude Code) should be able to act on it without first chasing down five other documents. Plan mode CAN fetch additional context if it wants — that's allowed and sometimes useful — but it shouldn't NEED to.

The discipline test: imagine reading the Implementation section as the first thing you see in the morning, with no memory of the prior cascade discussion. Can you start working from it? If the answer is "no, I'd need to first read the framing to understand what 'the trait' means," the prompt has a forced external context dependency and should inline the trait's full signature instead of referring to it.

**Citing docs is not a forced dependency** — citations are pointers, not prerequisites. *"per `docs/ARCHITECTURE.md § 'The Verifier trait'`"* is fine; it tells plan mode where to find the rationale if it wants the rationale, but the prompt itself should still be actionable without reading that section.

### 3. Names specific files, constraints, and locked signatures

Vague targets force the executor to make decisions that should have been made during rough-in. *"Implement the loader"* is vague — implement it where? Constrained how? What are the invariants? *"Create `src/loader/mod.rs` with a loader function that takes a path and returns a vec of `Lesson` structs or a `LoaderError`; the loader must be pure (no I/O outside the path read), must surface malformed-row errors with line numbers, and must round-trip a valid TOML file without data loss"* is specific — it names the file, the contract, and the invariants without prescribing the function body.

**The distinction that matters**: specific ≠ prescriptive. Specificity is "this file, this contract, these invariants, these edge cases to cover." Prescription is "here's the function body, here's the test function name, here's the exact sequence of operations to type." The first tells plan mode **what must hold**; the second tells plan mode **how to do its job**, and Claude Code's plan mode is a decomposition engine that will do its job strictly worse if you override its priors. See property 8 for the discipline that keeps this distinction sharp.

**The locked-signature carve-out**: when a function or type signature is **verbatim from a locked interface commitment** (an IC-N from framing), inlining it is correct and load-bearing. ICs are locked contracts that cannot be paraphrased without risking drift, so reproducing them verbatim is the only safe way to reference them. Preface inlined IC code blocks with a sentence like *"the IC-N shape is verbatim and not negotiable — any deviation is a re-framing trigger"* so plan mode knows the code is architectural, not illustrative. When the signature is **not** from a locked IC — it's just a shape the rough-in author happens to have in mind — name the function and constrain its behavior, but leave the exact signature to plan mode to propose during the Plan phase. Plan mode is better at surfacing the right signature from real code context than rough-in is at guessing it from a framing brief.

The discipline test: every Implementation section should name at least one specific file path. If it doesn't, the prompt is operating at the wrong abstraction level for rough-in (it's still framing-shaped, not rough-in-shaped).

### 4. Cites cascade docs by section name when the rules matter

When a constraint comes from a foundation doc, cite the doc and the section by name in the Implementation section so plan mode knows which rules apply.

Examples:
- *"The trait is pure — no async, no I/O, no network — per `docs/STANDARDS.md § Unenforced invariants`"*
- *"Use the testing patterns from `docs/STANDARDS.md § Testing philosophy` — table-driven tests with named cases, no mocking of types we own"*
- *"Follow the conventions in `CLAUDE.md § Commands` — use `mise run test` not `cargo test` directly"*

The citation makes the constraint findable and gives plan mode a hook to fetch additional detail if it needs the rationale. **Don't paraphrase the constraint** — paraphrasing introduces drift and the cited section becomes the source of truth, not the prompt's restatement.

### 5. Specifies the verification step

The Implementation section should name the specific test, command, or observation that proves the implementation is correct. This isn't the same as the Done signal section (which is the top-line check) — the Implementation section's verification is *embedded in the work* ("after creating the file, run `cargo check --workspace` to confirm it compiles"), while the Done signal is the *final command* the user runs to confirm the issue is complete.

The discipline test: after the executor finishes the implementation step, what specific command tells them they did it right? If the answer is "rerun the test suite and see if anything broke," that's too vague — name the specific test or assertion.

### 6. ~300-800 words (up to ~1000 for cross-crate capstones)

Plan-mode prompts that are too short don't have enough information for plan mode to produce a good plan. Plan-mode prompts that are too long have either accumulated unnecessary detail (which dilutes the load-bearing parts) or are trying to do too much in one issue (which means the issue should be split).

**Why 300-800 rather than 200-500**: well-shaped constraint-based specs (property 8) run longer than prescriptive specs because they're listing properties and invariants rather than code. Each invariant needs a sentence; code can pack several decisions into a few lines. The older 200-500 range was shaped around prose that includes inlined function bodies, and cutting those bodies shifts the natural word count upward for the non-code portion. Cross-crate capstones — integration issues that wire together work from two or more crates, or that validate an interface commitment end-to-end — are allowed up to ~1000 words because the constraints they carry span more surfaces and need more sentences to state.

The range is a heuristic, not a hard limit. Some genuinely simple issues only need 200 words; some genuinely complex capstones need 1200. But if a draft Implementation section is consistently under 250 words or over 1100, that's a signal worth investigating before the spec is approved:

- **Under 250 words consistently** → the issue might be too small (consider folding it into another issue — see Step 4's review-unit discipline), or the rough-in is being too vague (add specific files, constraints, and invariants per property 3).
- **Over 1100 words consistently** → the issue might be too big (consider splitting it, or re-framing the milestone if the split crosses milestone boundaries), or the prompt is including non-essential context (move that to the Context section or cite a doc instead of inlining), or the prompt has drifted into prescriptive "how" prose (per property 8, convert inlined code blocks to constraint sentences).

### 7. Names what NOT to do

Often the most important guidance in a plan-mode prompt is what to defer to a later issue or what NOT to touch. *"Do not create any concrete implementations of the trait — those come in R2"* is more valuable than three more sentences about the trait itself, because it prevents plan mode from helpfully scope-creeping into work that belongs in a different issue.

The discipline test: after writing the Implementation section, ask "what is the most likely scope creep an executor might do here?" If there's a plausible scope creep, write a "Do not..." sentence to prevent it explicitly.

### 8. States intent and constraints, not implementation sequences

The load-bearing calibration property. The Implementation section should tell plan mode **what** to build and **why it matters architecturally**, not **how to type it out**. Exact file paths, invariants that must hold, and type signatures from locked interface commitments are "why"; inlined function bodies, prescribed test function names, and step-by-step command sequences are "how" and belong in plan mode's output, not rough-in's input.

**The discipline test for the author**: before approving an Implementation section, scan it for fenced code blocks (```rust, ```typescript, etc.) that are **not** verbatim from a locked interface commitment. Each such block is a candidate for deletion. Ask:
1. Would removing this block force plan mode to make a decision the rough-in author already made?
2. If yes → the decision belongs in the spec as a **constraint sentence**, not as inlined code. Convert the block to prose. *"The loader's error type should distinguish malformed-row errors (with line number and column) from I/O errors (file not found, permission denied)"* carries the same decision as inlining an `enum LoaderError { ... }` block, but leaves the exact variant names and shape to plan mode to propose.
3. If no → the block is illustrative, not load-bearing. Delete it and trust plan mode. Plan mode will produce its own code during the Plan phase that is informed by real codebase context the rough-in author didn't have.

**The exception**: code blocks that are verbatim from a locked interface commitment (IC-N from the framing) stay inlined, because the locked shape cannot be paraphrased without risking drift. Preface those blocks with *"the IC-N shape is verbatim and not negotiable — any deviation is a re-framing trigger"* so plan mode knows the code is architectural. This is the only legitimate reason to inline code in a rough-in Implementation section. If the block doesn't cite an IC-N, it's prescriptive "how" prose and should be converted or deleted.

**Why this matters for Claude Code plan mode specifically**: plan mode runs a read-only research phase before producing a plan ([see Anthropic's best practices on separating research and planning from implementation](https://code.claude.com/docs/en/best-practices)). During that phase, plan mode explores the real codebase, notices existing patterns, and surfaces questions about ambiguities via its AskUserQuestion tool. Over-prescribing implementation details in the Implementation section forces plan mode past its natural exploration phase — it skips the discovery that would have produced a better plan, and anchors on the rough-in author's prescription instead of the real code context. The compound effect: each prescriptive decision in rough-in is a decision plan mode would have made better with real code in hand, and prescriptive rough-ins stack these suboptimal decisions across every R-issue in the milestone.

**The symptom to watch for**: reviewing the spec feels like reviewing the code. If the rough-in HITL gate feels like a code review rather than a spec review, the Implementation section has drifted into prescription. Recovery: apply the discipline test above and convert or delete each non-IC code block.

## Common pitfalls with worked examples

### Pitfall 1: Vague verbs

**Bad**:

> Implement the Verifier trait. Make sure it's flexible enough to handle different verifier shapes.

**Why this is bad**: "Implement" is vague (where? with what signature?), "flexible enough" is unmeasurable, "different verifier shapes" assumes plan mode knows what shapes exist.

**Good**:

> Create `crates/core-engine/src/verifier.rs` with a `pub trait Verifier` that has three associated types (`Input`, `Context`, `Error`) and a single method `fn verify(&self, input: &Self::Input, ctx: &Self::Context) -> Result<(), Self::Error>`. Add `pub mod verifier;` to `crates/core-engine/src/lib.rs`. Do not create any concrete implementations — those come in R2.

**What changed**: every sentence is a specific instruction with a verifiable outcome. The signature is named explicitly. The scope creep ("create concrete impls") is forbidden.

### Pitfall 2: References to prior context that force chasing

**Bad**:

> Use the same pattern as the previous issue. The trait should follow the rules from the architecture doc.

**Why this is bad**: "The previous issue" forces plan mode to chase down which issue, read it, and figure out what "pattern" means in context. "The architecture doc" doesn't say which section, so plan mode has to read the whole doc.

**Good**:

> Use the canonical Rust trait pattern with three associated types (no generic parameters on the trait itself — generics go on the impl). The trait must be pure (no async, no I/O, no network) per `docs/STANDARDS.md § Unenforced invariants`. The rationale for the trait shape is in `docs/ARCHITECTURE.md § "The Verifier trait"` if you want background.

**What changed**: the pattern is named and described inline. The cited section names are specific. The rationale citation is offered as optional context, not as a forced read.

### Pitfall 3: Assuming Claude Code has memory of prior conversation

**Bad**:

> As we discussed, the trait needs to handle the four shapes. Remember that the loader will use this later.

**Why this is bad**: Claude Code under `/finish` doesn't have the chat history. "As we discussed" refers to nothing it can see. "Remember that" is asking for memory that doesn't exist.

**Good**:

> The trait will be implemented by four concrete verifier shapes (regex pure-fn, tmux external-process, vim embedded-RPC, bash PTY). The shape boundary is the v0.4 hard gate documented in `docs/ARCHITECTURE.md § "The v0.4 hard gate as an architectural commitment"`. The lesson loader (which will be built in M2 of this workstream) will use this trait via dynamic dispatch.

**What changed**: every reference is concrete and resolvable from the issue body alone. There's no implicit "you remember this from last time" — every relevant fact is named explicitly.

### Pitfall 4: Dogmatic over-specification

**Bad**:

> Create the file at exactly `crates/core-engine/src/verifier.rs`. Use exactly four spaces for indentation. Name the trait exactly `Verifier`. The associated types must be named exactly `Input`, `Context`, and `Error` in that order. The method must be named exactly `verify`.

**Why this is bad**: most of these are conventions that are already enforced by the project's lint config or follow obvious patterns. Restating them dogmatically clutters the prompt and signals distrust of the executor's judgment.

**Good**:

> Create `crates/core-engine/src/verifier.rs` with a `pub trait Verifier` that has associated types `Input`, `Context`, `Error` and a method `verify(&self, input: &Self::Input, ctx: &Self::Context) -> Result<(), Self::Error>`. The trait will be the load-bearing abstraction every pack implements, so name and shape matter — keep them as written.

**What changed**: the parts that matter (trait name, type names, method signature) are specified once with a brief note that they're load-bearing. The parts that don't need restating (indentation, file location convention) are left to the project's lint config and the executor's judgment.

### Pitfall 5: Hiding constraints in prose instead of naming them

**Bad**:

> Build the trait. By the way, it's important that the trait is sync only, and you should make sure it doesn't do any I/O. Also, the trait shouldn't depend on any networking. Oh, and try to make it work with all four verifier shapes.

**Why this is bad**: the constraints are buried in casual prose that's easy to skim past. "Try to make it work" is unmeasurable.

**Good**:

> Create the trait per the signature above. Constraints (all from `docs/STANDARDS.md § Unenforced invariants`):
>
> - The trait is **pure**: no async, no I/O, no network.
> - The trait must accommodate four implementation shapes (regex pure-fn, tmux external-process, vim embedded-RPC, bash PTY) without growing variant logic in the engine — this is the v0.4 hard gate from `docs/ARCHITECTURE.md`.
> - No concrete impls in this issue — those come in R2.

**What changed**: constraints are pulled out of prose and into a structured list. Each one cites its source. The "all four shapes" constraint is concrete (no variant logic in the engine) instead of a vague aspiration ("try to make it work").

### Pitfall 6: Inlining non-IC code blocks (the load-bearing Claude-Code-era pitfall)

This pitfall is the concrete form of property 8's discipline test and deserves its own worked example because it's the most common failure mode for rough-ins written under human-executor defaults. The pitfall: inlining function bodies, test function names, or implementation sequences for work that is **not** locked by an interface commitment, on the theory that "more specificity is better." For Claude Code plan mode, more prescriptive specificity is strictly worse — it overrides plan mode's priors and produces code slightly worse than what plan mode would draft from a cleaner prompt. Only IC-verbatim code blocks earn their place in an Implementation section.

**Bad** (hypothetical CSV loader, no locked IC):

> Create a CSV loader in `src/loader/csv.rs`:
>
> ```rust
> pub fn load_csv(path: &Path) -> Result<Vec<Record>, LoaderError> {
>     let file = File::open(path).map_err(LoaderError::Io)?;
>     let reader = BufReader::new(file);
>     let mut records = Vec::new();
>     for (line_num, line) in reader.lines().enumerate() {
>         let line = line.map_err(LoaderError::Io)?;
>         let fields: Vec<&str> = line.split(',').collect();
>         if fields.len() != 3 {
>             return Err(LoaderError::MalformedRow {
>                 line: line_num + 1,
>                 reason: format!("expected 3 fields, got {}", fields.len()),
>             });
>         }
>         records.push(Record {
>             id: fields[0].to_string(),
>             name: fields[1].to_string(),
>             value: fields[2].parse().map_err(|_| LoaderError::MalformedRow {
>                 line: line_num + 1,
>                 reason: "value is not a valid integer".to_string(),
>             })?,
>         });
>     }
>     Ok(records)
> }
> ```
>
> Write tests `test_load_csv_valid`, `test_load_csv_empty`, `test_load_csv_malformed` in the same file.

**Why this is bad**: every line of the function body is a decision. The author decided to use `BufReader`, to iterate with `enumerate()`, to split on `,` (not handling quoted fields!), to store `id` and `name` as owned `String`, to convert parse errors into a generic malformed-row error with a hand-rolled message. None of these decisions are locked by a framing IC — they're just what the author happened to type. Plan mode would make better versions of most of these decisions with real code context in hand: it would notice an existing `csv` crate dependency in `Cargo.toml` and use it instead of hand-rolling; it would check whether the project already has a `Record` type that could be reused; it would propose a test harness that matches the project's existing patterns. The inlined body prevents all of that discovery, and the reviewer is now reviewing code, not reviewing a spec.

Also: the test function names (`test_load_csv_valid`, `test_load_csv_empty`, `test_load_csv_malformed`) are prescribed, which forces plan mode to use exactly those names even if the project's convention is `it_loads_valid_csv` or `loads_valid_csv_file`. Another author-decision that should have been plan mode's call.

**Good** (same issue, constraint-shaped):

> Create a CSV loader in `src/loader/csv.rs` that loads CSV files into the existing `Record` type (`src/types/record.rs`, inherited from M1). The loader must:
>
> - Take a path and return either `Vec<Record>` or a `LoaderError`. The exact error shape is plan mode's call during the Plan phase — surface the proposal in the plan and we'll lock it in.
> - Distinguish **malformed-row errors** (with line number for diagnostics) from **I/O errors** (file not found, permission denied). Error messages should be actionable for a user authoring lesson files by hand.
> - Handle quoted fields correctly (embedded commas inside quoted cells must not split the field). Use the project's existing `csv` crate dependency — do not hand-roll parsing.
> - Round-trip a valid CSV file without data loss (a file written out after being loaded should parse back to the same records).
>
> Test coverage should cover: (1) a valid file with multiple rows, (2) an empty file (zero rows, valid header), (3) a file with one malformed row (wrong field count or unparseable value) — the error should include the line number. Match the project's existing test naming convention in `src/loader/` (check existing files for the pattern).
>
> Do not create any higher-level loader types that wrap this one — that's R<next>'s job.

**What changed**: every decision that was in the function body is now either a constraint (malformed vs I/O distinction, quoted-field handling, round-trip invariant) or deferred to plan mode (exact error shape, test function names). The one place the spec gets specific is where it needs to be — the direction to use the existing `csv` crate instead of hand-rolling, because that's a project-level convention plan mode might not notice on its own. The reviewer is now reviewing **the contract**, not the code, and the HITL gate feels like a spec review rather than a code review.

**The discipline test applied**: scan the bad version for fenced code blocks. The `pub fn load_csv` block is not from a locked IC — it's not in framing's IC-N list. Ask: would removing it force plan mode to make a decision the rough-in author already made? Yes (several decisions: `BufReader` vs `csv` crate, quoted-field handling, error message shapes, test naming). Those decisions are each a candidate for either a constraint sentence or a delegation to plan mode. Apply the conversion: invariants become constraint sentences, implementation details become delegations. The result is the good version above.

## Worked example: the regex-pack R1 spec

Here's the full Implementation section for the canonical R1 (Define Verifier trait) of the regex-pack workstream's M1, with all eight properties applied. This is the same example that appears in the rough-in SKILL.md inline and in the cascade-rough-in.md template's HTML comments — it's the canonical reference for what good looks like.

This example is a **legitimate exception** to pitfall 6: the trait code block is verbatim from IC-1 in the regex-pack framing, so inlining it is correct. Note the prefatory sentence calling out that the shape is IC-locked — that's the discipline that tells plan mode the code is architectural, not illustrative.

```markdown
## Implementation

Create `crates/core-engine/src/verifier.rs` with the following trait:

    pub trait Verifier {
        type Input;
        type Context;
        type Error;
        fn verify(&self, input: &Self::Input, ctx: &Self::Context)
            -> Result<(), Self::Error>;
    }

Add `pub mod verifier;` to `crates/core-engine/src/lib.rs`. Include
full rustdoc on the trait that cites `docs/ARCHITECTURE.md § "The
Verifier trait"` for the rationale and the v0.4 hard gate language.

Constraints (all from `docs/STANDARDS.md § Unenforced invariants`):

- The trait is **pure**: no async, no I/O, no network.
- The trait must accommodate four implementation shapes (regex pure-fn,
  tmux external-process, vim embedded-RPC, bash PTY) without growing
  variant logic in `core-engine` — this is the v0.4 hard gate from
  `docs/ARCHITECTURE.md § "The v0.4 hard gate as an architectural commitment"`.
- Do not create any concrete implementations in this issue — those come
  in R2.

After implementation, verify with `cargo check --workspace && cargo doc
--no-deps` to confirm it compiles cleanly and the rustdoc renders.

The trait will be the load-bearing abstraction every pack implements,
so name and shape matter — keep them as written. The rationale for the
trait shape is in `docs/ARCHITECTURE.md § "The Verifier trait"` if you
want background.
```

**Property check**:

1. ✅ **Second person**: "Create...", "Add...", "Include...", "verify with..." — every sentence starts with a verb the executor can act on
2. ✅ **Self-contained**: the full trait signature is inlined, the constraints are listed explicitly, the cited sections are pointers not prerequisites. A reader can act on this cold.
3. ✅ **Specific files, constraints, and locked signatures**: `crates/core-engine/src/verifier.rs` is named; the trait code block is verbatim from IC-1 (the locked-signature carve-out applies); constraints (purity, no concrete impls, v0.4 hard gate) are explicit
4. ✅ **Cites cascade docs by section name**: ARCHITECTURE.md sections cited twice with exact section names, STANDARDS.md cited once
5. ✅ **Verification step embedded**: `cargo check --workspace && cargo doc --no-deps`
6. ✅ **Length**: ~210 words — short for the 300-800 range, but this is a genuinely simple issue (one trait, no implementations) and the brevity is honest, not a sign of vagueness. A longer spec here would be padding.
7. ✅ **Names what NOT to do**: "Do not create any concrete implementations in this issue — those come in R2"
8. ✅ **States intent and constraints, not implementation sequences**: the only code block is IC-1 verbatim (prefaced with the non-negotiable marker); there are no prescribed function bodies, test names, or implementation sequences outside the IC

This is the shape every Implementation section should aim for. Not every spec will need exactly this structure (some won't need a code block at all — in fact, most won't, because code blocks are IC-verbatim only — some will need more constraints, some will be shorter because the work is genuinely simple) but the eight properties apply universally.

## How the Implementation section relates to the other sections

The Implementation section is the hottest, but the other five sections of the spec template each have a specific role and shouldn't duplicate Implementation content:

- **Context** orients the reader to where the issue sits in the cascade (workstream, framing, milestone, what came before, what comes next). It's the "why this issue exists" answer in one paragraph. Not the place for instructions.
- **Acceptance criteria** is a checklist of observable, verifiable outcomes the executor can tick off. It's where the executor proves the implementation is done. Not the place for instructions on how to get there.
- **Done signal** is the single command or observation that means the issue is complete — usually a `cargo run -- X` or `pnpm test` invocation with expected output. The top-line check, distinct from the verification step embedded in Implementation.
- **Dependencies** is the list of prior R-issues that must be closed before this issue can start. `/finish` reads this section before handing the body to plan mode and refuses to proceed if any dependency is open.
- **PR contract** is the standard text for how to close the issue when implementation is complete. Same across every cascade rough-in spec — not customized per issue.

**The boundary discipline**: anything that's an instruction goes in Implementation. Anything that's a verification goes in Acceptance criteria or Done signal. Anything that's orientation goes in Context. If you find yourself writing instructions in Acceptance criteria or verifications in Implementation, the section boundaries are slipping — pull them back to the right home.

## Section-anchoring discipline for `/finish`

`/finish` identifies sections by their `## ` heading names. The standard six headings are:

```
## Context
## Implementation
## Acceptance criteria
## Done signal
## Dependencies
## PR contract
```

**These heading names are mandatory**. Sections can be edited freely (prose, lists, code, links, tables — whatever fits the issue) but the heading names must stay as written. Renaming "Implementation" to "What to build" or "Acceptance criteria" to "How we'll know it's done" will break `/finish`'s anchoring.

The cascade-rough-in.md template enforces this with an HTML comment block at the top of the file: *"The only hard rule: keep the section headings as written. /finish identifies sections by heading name, so renaming 'Implementation' to 'What to build' will break the slash command's anchoring."*

When rough-in drafts a spec, it must use exactly these six heading names in exactly this order. If a milestone genuinely needs additional sections (e.g., a research-heavy issue might benefit from a `## Background` section), add them after the standard six rather than renaming or replacing standard sections.

## When the Implementation section gets long

Some genuinely complex issues need Implementation sections longer than 500 words. When this happens, structure the section with second-level headings to make it scannable:

```markdown
## Implementation

### Step 1: Define the loader trait

[200 words of instructions]

### Step 2: Implement the TOML deserializer

[200 words of instructions]

### Step 3: Wire the loader into the engine

[200 words of instructions]
```

The second-level headings within Implementation don't break `/finish` (which anchors on the `## Implementation` heading itself) and they make the section easier to read for both humans and plan mode. Use this pattern when a single Implementation section exceeds ~800 words and has natural sub-steps.

**But first**: when the Implementation section is getting long, ask three questions in order before reaching for restructuring:

1. **Is the length driven by prescriptive "how" prose?** (Property 8 discipline.) Scan for non-IC code blocks and prescribed function/test names. If the length comes from inlined function bodies, the fix is to convert those blocks to constraint sentences — the non-code portion may stay long (because constraints take prose to state), but the total drops significantly. This is the most common cause of over-length Implementation sections in Claude-Code-era rough-ins and should be checked first.
2. **Is the issue too big and should be split?** The 300-800 word heuristic exists because issues that need more than 1000 words of instructions are usually doing too much. Splitting is almost always the better answer than restructuring; restructure only when the work genuinely can't be split (e.g., an atomic refactor across multiple files where a partial commit would leave the codebase broken).
3. **Is the length honest for a cross-crate capstone?** Capstones that wire together work across multiple crates or validate an interface commitment end-to-end legitimately need more constraints (up to ~1000 words). If the issue is a capstone and the constraints are all load-bearing, the length is honest and restructuring-with-sub-headings is the right call.

## What this reference does NOT cover

- **The Acceptance criteria section's discipline** — that's covered in `references/templates/rough-in-spec-template.md` and the cascade-rough-in.md template comments
- **The PR contract section's standard text** — same; it's in the template
- **`/finish`'s actual implementation** — that's bootstrap-finish's job, not rough-in's. Rough-in only needs to know `/finish`'s contract (read body, anchor on Implementation, verify dependencies, hand to plan mode).
- **Plan mode's prompt-handling internals** — Claude Code's plan mode is a black box from rough-in's perspective. Rough-in produces well-shaped prompts and trusts plan mode to handle them well.
- **The bootstrap-finish skill itself** — that's the sixth in-chat skill, scoped separately, built between M1 and M2 of the first workstream once execution data informs what `/finish` should do.

If you're drafting an Implementation section and find yourself wanting to write instructions for `/finish` rather than for the executor, stop — the prompt is for the executor (Claude Code or human), not for the slash command. `/finish` is just the bridge.
