---
name: Cascade framing capability
about: A framing capability sub-issue created by framing (or by a human adding a capability mid-cascade). Parented under a workstream parent Issue. Rough-in will decompose this into ready-to-implement sub-sub-issues.
title: "[<workstream-slug>:F<#>] <capability>"
labels: ["cascade-depth:framed"]
assignees: []
---

<!--
Cascade framing capability template.

This Issue represents one capability within a workstream — a
demonstrable outcome that one rough-in pass will decompose into
implementable sub-sub-issues. It's parented under the workstream's
parent Issue via GitHub's sub-issue API.

Framing capabilities are the unit of "what's next" between framing and
rough-in. The body holds the capability statement, the rough-issue list
that rough-in will refine, the acceptance signal, and any cross-framing
interface commitments this capability satisfies.

The body is structured but not strangling. Prose, code snippets, links
to docs/cbk/frame-NN.md and other cascade docs are all welcome.

The only hard rule: the title format `[<slug>:F<#>] <capability>` is
mandatory. Rough-in inherits the slug + F-number from the title.
-->

## Capability statement

<!--
One paragraph stating what this capability is, written as a demonstrable
outcome — not as "implement X" but as "after this milestone, the
workstream can do Y." Pulled verbatim from frame-NN.md § Milestones
when framing creates this Issue.
-->

After this capability lands, the workstream can _<observable outcome>_.

## Rough issues

<!--
The list of rough issues framing identified for this capability. These
are intentionally rough — rough-in will refine each into a full
sub-sub-issue spec with acceptance criteria and a /finish-able body.

Bullet list of one-sentence intents. Each entry will become one
sub-sub-issue under this capability when rough-in runs.
-->

- _R1 intent: …_
- _R2 intent: …_
- _R3 intent: …_

## Acceptance signal

<!--
The single observable thing that proves this capability landed. Usually
a command, a test, a smoke check, or a user-visible outcome. This is
what rough-in's capstone issue (if any) will verify.
-->

`<command or observation that proves this capability is real>`

## Dependencies

<!--
Other capabilities or workstreams that must complete before this one
can start. Reference other framing sub-issues or workstream parent
Issues by number.

If there are no dependencies, write "None — this capability can start
as soon as rough-in picks it up."
-->

- _Depends on #<N> reaching <state>_

## Interface commitments

<!--
Cross-framing commitments this capability satisfies or relies on.
Could be APIs, vocabulary, schemas, conventions, or patterns — anything
that future framings will inherit verbatim rather than re-decide.

Reference docs/cbk/frame-NN.md § Interface Commitments for the
full table. Empty section is fine if this capability has no
cross-framing commitments — write "None from this capability."
-->

- _<interface name>_ — _shape_ — stable by this capability's completion

## Links

<!--
Citations to the cascade docs that informed this capability. Always
link the relevant frame-NN.md section.
-->

- [`docs/cbk/frame-NN.md` § <section>](../blob/main/docs/cbk/frame-NN.md)
- _Other relevant cascade docs…_
