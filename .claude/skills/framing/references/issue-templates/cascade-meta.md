---
name: Cascade meta-issue
about: A deferred meta-issue surfaced during framing — a gate, decision, or infrastructure item that doesn't decompose into a specific milestone but DOES gate transitions or rough-in. Parented under a workstream parent Issue with the `meta` label.
title: "[<workstream-slug>:meta] <subject>"
labels: ["cascade-depth:framed", "meta"]
assignees: []
---

<!--
Cascade deferred meta-issue template.

Meta-issues are concerns surfaced during framing that don't fit cleanly
into any specific milestone's rough issues but DO need tracking because
they:

  - gate a transition between milestones (type: gate)
  - need a decision before a milestone can be roughed-in (type: decision)
  - need to land independently of the milestone sequence (type: infrastructure)

Rough-in's mandatory pre-flight check reads the Deferred meta-issues
table from frame-NN.md and verifies any meta-issue with `Blocks: M_n
start` is resolved before decomposing M_n. So filling in the Blocks
field accurately matters — it's what rough-in checks against.

The body is short by design. If a meta-issue needs lots of prose to
describe, it might actually be a milestone in disguise — consider
looping back to framing.
-->

## Type

<!--
One of: gate, decision, infrastructure.

  - gate: blocks a transition between milestones. Rough-in must verify
    it's resolved before decomposing the gated milestone.

  - decision: needs a call before a milestone can be roughed-in.
    Rough-in must surface the open question to the user before
    generating issue specs.

  - infrastructure: needs to land independent of any specific
    milestone. Rough-in can decompose it independently of the
    milestone sequence.
-->

`<gate | decision | infrastructure>`

## Subject

<!--
One paragraph describing what this meta-issue is and why it surfaced
during framing rather than as part of a milestone's rough issues.
-->

_What this meta-issue is, in one paragraph._

## Depends on

<!--
What has to happen before this meta-issue can start. Could be a
milestone exit, another meta-issue resolution, an external prerequisite,
or "nothing".
-->

- _<milestone exit / other meta-issue / external / "nothing">_

## Blocks

<!--
What this meta-issue gates. Typically a milestone start, rough-in
start, or another meta-issue. Rough-in's pre-flight check matches
against `M_n start` strings in this section, so be precise.
-->

- _<milestone start / rough-in start / other meta-issue>_

## Resolution criteria

<!--
What "resolved" looks like for this specific meta-issue. Could be a
decision recorded in CLAUDE.md, a config file committed, a manual
setup step completed, an external account created, or anything else.

When the user closes this Issue, this is what they're claiming to have
done. Rough-in's pre-flight check trusts the close — it doesn't
re-verify resolution criteria.
-->

_What "resolved" means for this meta-issue._

## Links

<!--
Citations to the cascade docs that surfaced this meta-issue. Usually
the framing that produced it.
-->

- [`docs/cbk/frame-NN.md` § Deferred meta-issues](../blob/main/docs/cbk/frame-NN.md)
