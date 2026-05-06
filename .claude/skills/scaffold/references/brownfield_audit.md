# Brownfield audit

Runs at the start of scaffold stage 1 when the user already has a repo, an existing planning workspace, or a labels taxonomy. Read-only — the audit never writes anything. Honors the `backends.md` rule that all operations be idempotent and that brownfield audits run before any provisioning.

## When to run the audit

Trigger the audit when any of these are true:
- The user mentions an existing repo, Linear workspace, or Notion hub in the brief or opening message
- The user picks a profile and a quick read shows resources already exist (e.g. `list_repositories` returns a repo with the project name from the brief)
- The user explicitly says "this isn't greenfield" or "we already have stuff set up"

If none of these are true, skip the audit and proceed directly to stage 1's account verification.

## The audit step

Five questions, batched at standard rigor (one-at-a-time at full), one combined batch at light rigor:

1. **What exists today that's relevant to this project?** Repos, project boards, planning workspaces, label taxonomies, knowledge bases?
2. **Of what exists, what works well that you want to keep?** (Forces a "what's worth keeping" list — brownfield briefs over-focus on what's broken.)
3. **What's broken or painful that you want to replace?**
4. **What constraints does the existing state impose on the new work?** Naming conventions you can't change, integrations you can't break, branch names downstream tooling depends on?
5. **Anything in the existing setup the cascade should *not* touch under any circumstances?** Production repos, customer-facing assets, archived projects?

After the answers, run a **non-mutating MCP read pass** to verify what the user described matches reality. For GitHub-only profile: list repos, read existing labels on the named repo, list project boards, list milestones. For opinionated profile: same plus Linear team read and Notion page list. **Surface any discrepancies** between what the user said and what actually exists — this catches "I forgot we set that up" moments before they cause provisioning failures.

## What the audit produces

A short **audit summary** in the chat, structured as:

```
## Audit findings

**Existing resources detected:**
- <repo URL> with <N> labels, <N> milestones, <project board if any>
- <other resources>

**Worth keeping:**
- <list from question 2>

**To replace or fix:**
- <list from question 3>

**Hard constraints:**
- <list from question 4>

**Do not touch:**
- <list from question 5>

**Discrepancies:** <anything where the user's description didn't match the read pass, or "none">
```

This summary gets shown to the user and held in chat context for the rest of stage 1 and stage 2 — every provisioning operation must check it before writing. Operations that would touch a "do not touch" item must be refused with a one-line explanation.

## Idempotent provisioning rules

When stage 2 proceeds after a brownfield audit, every operation must respect these rules:

- **`create_repository`**: if the repo already exists, do not recreate. Skip and note. Offer to add missing `.github/` files only.
- **`create_label_taxonomy`**: merge with existing labels, do not replace. If a cascade-standard label already exists with a different color or description, ask the user before changing it.
- **`create_project`**: if a project board with the proposed name exists, ask whether to reuse, rename, or skip.
- **`create_milestone`**: if a milestone with the proposed name exists, skip.
- **Any write to a "do not touch" resource**: refuse, surface why, ask the user to override explicitly if they really want it.

These rules implement `backends.md`'s `reuse_existing` mode without requiring a separate code path — the audit informs the operations, the operations behave defensively.

## Failure modes specific to brownfield

- **Scope gravity from existing setup** — user wants to mirror everything the old setup had even though half of it doesn't match the current project's scope. Same problem as in consultation's brownfield case. Name it: *"You mentioned X, Y, Z exist in the old setup — are those actually in scope for this project, or are they carryover from habit?"*
- **Phantom resources** — user claims something exists, audit read pass finds nothing. Don't proceed on the user's claim alone; re-check or ask them to double-check.
- **Audit bleeding into provisioning** — the audit is read-only. If you find yourself writing during the audit, stop. Provisioning starts after the audit's HITL gate, not during.
- **Skipping the "worth keeping" question** — without it, the brownfield brief becomes a list of complaints. Insist on at least one item, even small.

## Minimum-mode audit

If the user has invoked light mode (see SKILL.md), collapse the audit to a single message:

> *"You've got existing setup — give me the short version: what exists, what's worth keeping, what to replace, anything I should not touch. I'll run a quick read pass to verify and then proceed."*

Then run the read pass, surface any discrepancies in one line, and proceed to stage 2 with the idempotent rules above still in force. Light mode collapses the conversation but never disables the idempotent operation rules — those are safety, not preference.
