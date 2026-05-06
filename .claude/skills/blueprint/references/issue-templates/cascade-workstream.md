---
name: Cascade workstream
about: A workstream parent Issue created by blueprint (or by a human starting a new workstream mid-cascade). The long-lived container that framing capabilities and rough-in items will be parented under via GitHub sub-issues.
title: "[<workstream-slug>] <name>"
labels: ["cascade-depth:rough"]
assignees: []
---

<!--
Cascade workstream parent Issue template.

This Issue is the long-lived container for one workstream. Framing
capabilities (sub-issues) and rough-in items (sub-sub-issues) will be
parented under it. The slug in the title — the part inside the brackets —
becomes the canonical identifier visible in every downstream Issue title,
PR title, and cascade reference. Choose it carefully; it's permanent.

The body is structured but not strangling. Prose, links, citations to
docs/cbk/blueprint.md or docs/ARCHITECTURE.md are all welcome. The four
sections below are the ones blueprint populates and downstream framings
inherit from, but you can add additional sections as the workstream
needs them.

The only hard rule: the title format `[<slug>] <name>` is mandatory because
framing and rough-in inherit the slug from the title via `issue_read`.
-->

## Purpose

<!--
One paragraph explaining what this workstream exists to do and why it
deserves to be its own workstream rather than a chunk of another one.
Pulled verbatim from the workstream entry in docs/cbk/blueprint.md when
blueprint creates this Issue.
-->

_What this workstream exists to do, in one paragraph._

## Scope sketch

<!--
Rough boundaries. What's in, what's out, what's deferred to a later
workstream. This is intentionally rough — framing will tighten it.

Bullet list or short prose, whichever fits the workstream better.
-->

- _In scope: …_
- _Out of scope: …_
- _Deferred to a later workstream: …_

## Dependencies

<!--
Other workstreams (or external prerequisites) that must complete or
reach a specific state before this workstream can start. Reference other
workstream parent Issues by number, or external prereqs in prose.

If there are no dependencies, write "None — this workstream can start
independently."
-->

- _Depends on #<N> reaching <state>_
- _External: …_

## Links

<!--
Citations to the cascade docs that informed this workstream. At
minimum, link the section of docs/cbk/blueprint.md that defines this
workstream and any docs/ARCHITECTURE.md sections relevant to its scope.
-->

- [`docs/cbk/blueprint.md` § <section>](../blob/main/docs/cbk/blueprint.md)
- [`docs/ARCHITECTURE.md` § <section>](../blob/main/docs/ARCHITECTURE.md)
- _Other relevant cascade docs…_
