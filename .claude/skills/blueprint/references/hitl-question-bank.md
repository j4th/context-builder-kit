# HITL question bank — blueprint phase

Categorized questions for HITL clarification rounds during blueprint. Pick the ones where inheritance leaves genuine ambiguity. Aim for 3–5 questions per round, covering at least 2 categories per round. Adapted from the initiative-planner skill with new sections for stack decisions, methodology selection, and inheritance verification.

**Citation note**: where a question references a specific pattern from the methodology register, name the source. The source isn't optional — it's part of the quality of the question.

## Inheritance verification (round 1, before any decisions)

Used during the inheritance check phase. The goal is to confirm blueprint understood what scaffold and consultation produced — not to make new decisions yet.

- I read the brief as: <one-sentence summary>. Is that an accurate compression?
- Scaffold's quality bar entry was: <verbatim>. Should I treat that as still-current, or has anything shifted?
- The brief flagged these deferred decisions for blueprint: <list>. Is that the complete list, or are there others I should know about?
- The brief's no-gos are: <list>. Confirming all of these still hold and I should treat them as hard constraints.
- Scaffold said the team shape is <summary>. Is anything different now?
- The brief said the appetite is <verbatim>. Is the calendar/headcount still accurate?

These aren't decision questions — they're verification questions. The user's answer is usually "yes accurate" or "no, X has changed." Move on quickly once the inheritance is confirmed.

## Stack decisions

Used during the stack decisions step. Each question proposes a default tied to inherited context and asks for confirmation or override.

**Language and framework:**
- The brief says <language>. Confirming we're using <version target> based on <appetite/quality bar>. Sound right?
- For <use case>, the framework choices are <A> and <B>. Given <inherited context>, I'd lean <default>. Override?
- Are there framework constraints I should know about — corporate-mandated, prior experience, performance requirements?

**Storage and persistence:**
- The brief implies <local-only/networked/embedded/etc>. For storage I'd lean <default> because <reason from inherited context>. Sound right?
- Migrations or schema-on-read? Given your quality bar of <verbatim>, I'd suggest <choice>.
- Where should data live? The platform standard for <macOS/Linux/Windows> is <XDG_DATA_HOME or ~/Library or %APPDATA%>. Use the standard or override?
- Any size or performance requirements I should know about for the storage layer?

**Distribution and deployment:**
- The brief says <`cargo install` is a v0.1 gate / hosted at X / etc>. Confirming distribution is <mechanism> — anything else about target platforms or update behavior?
- For versioning, <SemVer | CalVer | ZeroVer> based on <appetite>. Sound right?
- Will this need to support multiple platforms simultaneously, or is one platform enough for v1?

**External dependencies:**
- The brief mentions <external dependency>. Confirming we're committing to it — any backup plan if it changes shape?
- Dependency philosophy: minimal (resist additions), pragmatic (add when needed), maximalist (use what's available)? Defaulting to <choice>.
- Are there third-party services that need accounts/billing/auth setup before development can start?

**Testing and CI:**
- Scaffold said <verbatim testing philosophy>. Translating to: <test framework>, <coverage target>, <test categories>. Sound right?
- For CI, GitHub Actions with <gates list> based on your quality bar. Anything to add or drop?
- Pre-commit hooks: yes (catches issues before push) or no (lighter friction)? Defaulting to <choice>.

## Methodology selection

Used during the methodology selection step. Always lead with a proposal tied to inherited context plus a citation.

**Top-level methodology:**
- Given <bursty solo cadence | small team / iterative product | ongoing maintenance / etc>, I'd recommend <Shape Up | Kanban | Scrum> — <one-sentence justification>. Source: <citation>. Sound right?
- Has the team used a methodology before? Sometimes the answer is "we're agile" which means "not waterfall" — that's not a methodology choice yet. What does day-to-day work actually look like?
- What kind of cadence feels right — fixed-window cycles (Scrum/Shape Up), continuous flow (Kanban), or appetite-based (Shape Up)?

**Planning patterns:**
- For carving up the workstreams, vertical slicing is almost always a good idea (Patton, *User Story Mapping*). Confirming?
- Given the architectural uncertainty mentioned in <brief section>, a walking skeleton as the first deliverable would validate the path through all layers (Cockburn, *Crystal Clear*). Want to include it?
- For the streaming risk in the brief's rabbit holes, a spike solution before committing to the full implementation would reduce uncertainty (Beck, *XP Explained*). Worth scheduling?

## Scope and boundaries

Adapted from the existing initiative-planner question bank.

- Is this initiative the entire product/system, or one slice of a larger effort?
- Which features are must-have differentiators vs can-come-later?
- Is there a "minimum viable initiative" — a subset that's useful on its own?
- The brief mentioned <future capability> — should we include it as a horizon project, or is it truly out of scope?
- Are there any components from the brief or scaffold that you've since reconsidered?

## Dependencies and sequencing

- Are there external dependencies the brief or scaffold didn't capture?
- What can be built in parallel vs strictly sequential?
- If <external dependency> doesn't exist yet, which projects are blocked and which can proceed?
- Is there a critical path — a sequence that, if delayed, delays everything?
- Do you want to design for <future capability> from the start, even if we don't implement it yet?

## Project grouping (after a hypothesis exists)

Asked after blueprint has a hypothesis about how to group workstreams.

- I'm seeing natural clusters around <X, Y, Z>. Does this feel right?
- <A> and <B> share state. One project or two?
- <C> is a cross-cutting concern. Standalone project, or milestones spread across the projects it touches?
- I've grouped these as horizon. Any that should be promoted to core? Any core that should be demoted?
- These N projects look tightly coupled — one big project with milestones, or separate projects that integrate?

## Open question framing

When the user can't or doesn't want to resolve something during blueprint, frame it as an explicit open question with a trip-wire:

- This sounds like something to defer to first real run — want to add it as an open question with the trip-wire being <observable condition>?
- We could spike this in framing or rough-in instead of deciding now. Which feels right?
- Park this as an open question for framing? It would carry forward in `blueprint.md` so the next phase sees it.

## Verification questions (round 2)

For round-2 follow-ups when round 1 answers raised new questions or surfaced ambiguity:

- You said <X>. That implies <Y> for <stack decision>. Is that right, or is there a simpler path?
- The methodology you picked says <X about cycle structure>. For your bursty cadence, that translates to <interpretation>. Sound right?
- Earlier you said the quality bar was <X>. The PR review checklist I'm drafting has <items> — too strict, too loose, or right?
- I see two valid ways to <decision>: <A> or <B>. Each has trade-offs <explain>. Which feels more natural?

## Anti-questions (do not ask)

- "What language should we use?" cold — always lead with a proposal from inherited context
- "Are you sure about <constraint from the brief>?" — constraints from the brief are facts, not questions
- "What's your code style preference?" — that's what linters are for
- "Do you want CI?" — assume yes; ask about which gates instead
- "What database should we use?" without a proposal — same as language, lead with default
- Yes/no questions without a default — always include the default in the question itself

## How many questions per round

Default: 3–5 questions per round, batched. At rigor=light, collapse to 1–3 per round. At rigor=thorough, 5–8 per round with one-question-at-a-time variant available. Same dial pattern as consultation and scaffold.

Round structure for blueprint:
- **Round 1 — inheritance verification** (no new decisions)
- **Round 2 — stack decisions** (one batch covering all relevant categories)
- **Round 3 — methodology selection** (proposal + confirmation, often 1 question)
- **Round 4 — project grouping** (after workstream hypothesis exists)
- **Round 5+ — verification rounds** as needed

Most blueprint sessions land at 3–4 rounds total. Sessions that need 6+ rounds usually mean the inheritance was incomplete and blueprint is doing scaffold's job.
