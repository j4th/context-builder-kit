# Problem brief template

The one and only artifact consultation produces. Eight sections, in order. Section 8 (current state) runs only for brownfield/partial prior-context. Keep the whole thing under ~2 pages for solo, ~3 pages for teams. **Short briefs get read; long briefs get skimmed.**

## Template

```markdown
# Problem Brief: <project name>

*Produced in consultation phase. Hand off to scaffold (phase 2) when approved.*

## 1. Problem statement

<One paragraph. One specific story about why the status quo doesn't work.
Name who's hurting, what they do today, and what makes today unacceptable.
No solution language. If you find yourself writing "we need to build", rewrite.>

## 2. Target users

<Who this is for, specific enough to make design decisions. Not "developers"
— "solo hobbyist developers building side projects on macOS". Not "teams" —
"2–5 person product teams using Linear and GitHub".>

## 3. Appetite

**<Small / Medium / Large>** — <timeframe> with <team size and role mix>.

<One or two sentences on what this appetite implies for scope. Explicit
opportunity cost if for a team: what you're not building while you build this.>

## 4. Proposed approach

<2–5 paragraphs at fat-marker-sketch fidelity. Rough, solved, bounded.
Describe the shape of the solution, not the implementation. No framework
names, no database choices, no hosting decisions — those belong in blueprint.
If you must reference a tool, write "something like X" and note it as a
constraint.>

## 5. Rabbit holes and risks

- **<Rabbit hole 1>** — <one sentence on what could go deep and why>
- **<Risk 1>** — <one sentence on what could blow up the timeline>
- <etc. 2–5 items total>

## 6. No-gos

- <Explicit exclusion 1 — what this project is deliberately not doing>
- <At least one required; aim for 2–4>

## 7. Success criteria

1. <Measurable outcome — project-level, not feature-level>
2. <3–5 items total>
3. <"Done" means all of these are true>

## 8. Current state *(brownfield/partial only)*

<What exists today, what works, what's broken, what constrains the new work.
See brownfield_addendum.md for structure. Note if a codebase analysis is
needed — flag it for blueprint, do not run it here.>

---

*Approved: <date>. Ready for scaffold.*
```

## Per-section writing guidance

**§1 Problem statement** — The hardest section. Default failure is writing a feature description instead of a problem description. Test: if you can replace "the problem" with "the missing feature" and the sentence still makes sense, you're solutioning. Rewrite in terms of pain, cost, or frustration.

**§2 Target users** — Specificity is the whole value. "Developers" is useless; "solo developers who ship side projects and resent yak-shaving around tooling setup" is actionable. If the project is for the user themselves, say so explicitly — "the author, a solo developer building X".

**§3 Appetite** — The format matters. `Medium — 3 weeks with 1 developer` is an appetite. `"A few weeks"` is not. `"As long as it takes to do it right"` is a warning sign, not an appetite. For teams, always include opportunity cost.

**§4 Proposed approach** — Fat-marker sketch is the mental model. Imagine drawing the solution on a whiteboard with a thick marker — you can't fit fine detail even if you want to. If the paragraphs start naming specific technologies, step back to the shape. Stack constraints go in a note, not the approach.

**§5 Rabbit holes and risks** — Rabbit holes are things that *could go deep*; risks are things that *could blow up*. Both matter. Aim for 2–5 items total. If you have 10, the scope is too big for the appetite.

**§6 No-gos** — Mandatory. At least one explicit exclusion. This is the section that prevents scope creep six weeks from now. The user will want to skip it; don't let them. Shape Up treats no-gos as a first-class pitch element for a reason.

**§7 Success criteria** — Project-level outcomes, not feature acceptance criteria. "Users can log in" is a feature criterion. "Solo developer can set up a new project end-to-end in under 30 minutes" is a project criterion. 3–5 items. Each must be measurable (even if fuzzy — "the user says it feels fast" counts).

**§8 Current state** *(brownfield only)* — See `brownfield_addendum.md`.

## Worked examples

Two short examples to model the shape of a good brief. The first is solo greenfield; the second is small-team greenfield. Note how both stay at shape-level — no frameworks, no databases, no hosting picks — and how the no-gos section does real scope-protection work in both cases.

### Example 1 — Solo greenfield: meeting-notes capture tool

`rigor=standard, prior=greenfield`

```markdown
# Problem Brief: Meeting-notes capture tool

## 1. Problem statement

The author takes rapid notes during back-to-back meetings and loses track
of them within a day. Current workflow is a mix of scratch text files,
Slack DMs to self, and a Notion page that never gets re-opened. The pain
is not the capture — it's that nothing written down is ever found again
when it matters a week later.

## 2. Target users

The author, a solo developer who sits in 4–8 meetings a day and needs to
surface commitments and decisions from them afterward. No other users in
scope — this is a personal tool.

## 3. Appetite

**Small** — 1 week of evenings, 1 developer.

Opportunity cost is one weekend of reading. If it takes longer than a week
the project gets cut, not extended.

## 4. Proposed approach

A capture surface that's faster than opening any existing app — fewer than
two keystrokes from anywhere — plus a search-first retrieval surface that
makes finding a note from last Tuesday trivial. The two halves are the
whole product. Capture writes to a single flat store; retrieval reads from
it. No hierarchy, no tags, no folders.

Stack constraint (note for blueprint, not a decision): must run locally
without a server.

## 5. Rabbit holes and risks

- **Search quality** — naive substring search may be too dumb to find notes
  by fuzzy recollection. Could pull in an embedding model and go deep.
- **Cross-device sync** — the author uses two machines. Sync is a known
  rabbit hole; keep it out of v1.

## 6. No-gos

- No mobile app, no web version — local desktop only
- No sharing, no collaboration, no export-to-other-tools
- No tagging, hierarchy, or organizational structure of any kind

## 7. Success criteria

1. Capture is faster than opening a new text file from scratch
2. The author can find a note from 7+ days ago in under 10 seconds
3. After 2 weeks of use, the author prefers it to the current mixed workflow
```

Note how appetite is strict (`Small — 1 week, cut if it overruns`), how the no-gos kill three obvious scope temptations up front, and how success criteria are project-level behaviors, not feature checkboxes.

### Example 2 — Small-team greenfield: new-hire onboarding tracker

`rigor=standard, prior=greenfield`

```markdown
# Problem Brief: New-hire onboarding tracker

## 1. Problem statement

The team's current onboarding is a Notion doc that every new hire gets
pointed at and then silently abandons. Nobody — not the hire, not their
manager, not the team lead — can tell from looking at the doc whether
someone is on day 3 or day 30 of the process, or which steps are stuck.
The result is hires missing important setup steps and managers finding
out weeks later.

## 2. Target users

Two audiences. Primary: new hires on their first two weeks, who need to
know what to do next without asking. Secondary: hiring managers, who need
to see progress across their reports without pinging anyone.

## 3. Appetite

**Medium** — 3 weeks, 2 engineers part-time (roughly half capacity).

Opportunity cost: one engineer is also the current on-call rotation
primary, so the team ships less feature work during this window. The lead
has explicitly approved the trade because onboarding pain is recurring.

## 4. Proposed approach

A checklist surface where each new hire has a personalized list of steps,
and a dashboard view where managers can see status across their reports.
Steps are owned by templates that the team can edit — so when onboarding
changes, future hires get the new version without anyone rewriting a doc.

The product is not the list itself; it's the visibility loop that lets a
manager notice a stuck step on day 5 instead of week 3.

## 5. Rabbit holes and risks

- **Permissions model** — who can see whose progress is a real question
  and could sprawl into a full access-control system. Keep it dumb: your
  manager sees you, the lead sees everyone, everyone else sees nothing.
- **Integration pressure** — the team will immediately want to hook this
  to the HRIS and the laptop-provisioning system. Both are rabbit holes.

## 6. No-gos

- No HRIS integration in v1
- No performance reviews, goal tracking, or anything beyond onboarding
- No custom templates per hire — templates are team-level only

## 7. Success criteria

1. A hiring manager can tell from one screen which of their reports are
   behind on onboarding
2. A new hire can complete a full onboarding without asking anyone "what's
   next?"
3. Updating the onboarding template takes under 10 minutes and applies
   automatically to all future hires
```

Note the team-specific additions: explicit opportunity cost in appetite, two target-user audiences called out separately, and a no-go list that specifically kills the two most likely scope-creep requests the team will make (HRIS integration, per-hire customization).

Both examples deliberately avoid naming any framework, database, or hosting choice. Both keep stack preferences out of the approach section. Both make the no-gos do real work.
