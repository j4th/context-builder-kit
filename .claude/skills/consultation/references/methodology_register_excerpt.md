# Methodology register — consultation excerpt

Consultation-relevant entries from the full methodology register. Cite by name when recommending; surface "fails when" conditions when relevant; never enforce. The full register is shared across all six cascade phases and lives outside this skill — this excerpt is the subset most useful during problem-brief writing.

**Citation discipline**: when you reference a pattern in the interview or brief, name it and cite the source. "This fits the Shape Up appetite pattern — Singer, *Shape Up* ch. 3" not "you should timebox this".

---

## Shape Up (Ryan Singer, Basecamp, 2019)

**The central reference for consultation.** Shape Up's shaping phase *is* what consultation is doing — setting appetite, roughing out elements, addressing rabbit holes, and producing a pitch. The problem brief's seven sections mirror Shape Up's pitch format (Problem, Appetite, Solution, Rabbit Holes, No-Gos) with two additions (Target Users, Success Criteria).

**Key concepts to cite:**
- **Appetite, not estimate.** Appetite is how much the idea is worth spending, not how long it will take. This is the single most important pattern in consultation.
- **Fat-marker sketch.** Solutions should be obviously unfinished so they can't be over-committed to.
- **Rough, solved, bounded.** The three qualities every solution sketch must have.
- **No-gos as first-class output.** Shape Up treats "what this project is not doing" as a core pitch element. The brief does too.

**Fails when**: teams treat it as fixed time *and* fixed scope, skip the shaping step, or lack senior product judgment. Also fails when the user refuses to commit to an appetite — the whole framework collapses without that constraint.

**Source**: Ryan Singer, *Shape Up: Stop Running in Circles and Ship Work that Matters* (2019). https://basecamp.com/shapeup — chapters 2–5 are the consultation-relevant ones.

---

## Spike solutions (Kent Beck, 1999)

A time-boxed research activity that produces knowledge, not shippable code. Useful in consultation when the user's problem has a technical unknown that must be resolved before a credible approach can be sketched. If step 3 (solution sketching) stalls because nobody knows if approach X is even feasible, recommend a spike *before* finishing the brief — or note it as a rabbit hole to spike during blueprint.

Ron Jeffries: *"a quick, almost brute-force experiment aimed at learning just one thing — think of driving a big nail through a board."*

**Fails when**: overused as a delay tactic, not time-boxed, or the question isn't clearly defined up front.

**Source**: Kent Beck, *Extreme Programming Explained* (1999); Ron Jeffries, *Extreme Programming Installed* (2000). https://www.mountaingoatsoftware.com/blog/spikes

---

## YAGNI (Martin Fowler, 2015)

*"You aren't gonna need it."* Don't build for speculative features. Four costs: build, delay, carry, repair. Critical caveat: **YAGNI applies to speculative features, not to refactoring, testing, or clean architecture** — it's not an excuse for skipping foundations.

Useful in consultation when the user keeps adding "and also we'll need X someday" to the approach. Name it: *"That sounds like a YAGNI candidate — want to park it as a potential future project instead of putting it in scope?"*

**Fails when**: misinterpreted as justification for neglecting code health, or applied to genuinely irreversible decisions.

**Source**: Martin Fowler, "Yagni" (2015). https://martinfowler.com/bliki/Yagni.html

---

## Pointers to the full register

Patterns relevant to *later* cascade phases — mention these in consultation only when the user explicitly asks about methodology, and defer full discussion to blueprint or framing:

- **Scrum / Kanban / Shape Up as methodologies** (full entries) — belongs in blueprint's methodology selection
- **Vertical slicing, walking skeleton, tracer bullets** — belong in framing and rough-in
- **Trunk-based development, continuous delivery, code review** — belong in scaffold
- **Augmented coding, harness engineering, TDD with agents, context engineering** — belong in scaffold and rough-in
- **ADRs, DORA metrics** — blueprint and measurement, not consultation

If the user wants to read more than the excerpt above, point them at the full register. Do not paste patterns from later phases into a problem brief — they belong in the phases where they'll actually be acted on.
