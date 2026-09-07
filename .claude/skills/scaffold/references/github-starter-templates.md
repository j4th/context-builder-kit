# GitHub starter templates

The `.github/` starter files scaffold pushes on the **github-issues** planning axis. `github_only_profile.md` § State 1 step 2 cites this file; `bootstrap_checklist_template.md` lists what landed.

> **Provenance.** Scaffold promised these files for two harvest passes and cited `references/scaffold_output_template.md` for them — where they never existed; a repo-wide grep for their content returned nothing, so step 2 was an instruction to copy files that were not there. This file holds the literal bodies. Do not re-point the citation without checking the target actually holds them.

Each block below is the literal file body. Adapt the bracketed parts; leave the structure. The bodies encode rules that live elsewhere and say so at the site — the review-gate block (`.claude/rules/pr-review.md` § The floor), the promotion traps (`cbk-conventions.md` § `[skip ci]` rule), the settle window (`cbk-conventions-reference.md` § Dependency settle-window).

---

## `.github/ISSUE_TEMPLATE/bug_report.yml`

An issue **form**, not a markdown template, so the labels are applied at creation: the provenance label (`source:github`) is what makes the external-versus-cascade-native distinction queryable, and the holding label (`triage`) says the issue is not executable as filed — `/intake` investigates, reproduces and shapes it (`cbk-conventions-reference.md` § Contribution intake).

```yaml
name: Bug report
description: Something is broken
labels: ["bug", "source:github", "triage"]
body:
  - type: markdown
    attributes:
      value: |
        This lands in triage, not in the cascade. `/intake` investigates it,
        reproduces it, and shapes it into a `/finish`-able issue. Describe data
        by shape, not contents — no secrets, tokens or raw payloads.
  - type: textarea
    id: what-happened
    attributes:
      label: What happened
      description: What you observed, and what you expected instead.
    validations: { required: true }
  - type: textarea
    id: repro
    attributes:
      label: Steps to reproduce
      description: The smallest sequence that shows the problem. A failing test beats prose.
      placeholder: |
        1.
        2.
        3.
    validations: { required: true }
  - type: input
    id: version
    attributes:
      label: Version / commit
      description: Tag, release, or commit SHA, and where you saw it.
    validations: { required: true }
  - type: dropdown
    id: area
    attributes:
      label: Affected area
      description: Best guess; the cascade's workstreams are the options.
      options:
        - "[<workstream slug 1>]"
        - "[<workstream slug 2>]"
        - Unsure
  - type: textarea
    id: environment
    attributes:
      label: Environment
      description: OS, platform target, device, and anything else that scopes it.
```

## `.github/ISSUE_TEMPLATE/feature_request.yml`

The holding label here is `enhancement` — the awaiting-cascade-work marker `/intake` reads (`cbk-conventions-reference.md` § Contribution intake › Awaiting cascade work). The form tells the reporter which lane the request can take and that it is not `/finish`-able as filed.

```yaml
name: Feature request
description: Suggest a capability
labels: ["feature", "source:github", "enhancement"]
body:
  - type: markdown
    attributes:
      value: |
        `/intake` classifies this as a small capability (enhancement lane,
        `/enrich` → `/finish`) or a large one (framing backlog). It is not
        `/finish`-able as filed — a clear problem and outcome matter more than
        an implementation sketch.
  - type: textarea
    id: problem
    attributes:
      label: The problem
      description: What you're unable to do today. Describe the problem, not the solution.
    validations: { required: true }
  - type: textarea
    id: outcome
    attributes:
      label: Desired outcome
      description: What "done" looks like from a user's point of view.
    validations: { required: true }
  - type: textarea
    id: proposal
    attributes:
      label: What you have in mind
      description: Optional. A sketch is fine; the design step decides.
  - type: textarea
    id: alternatives
    attributes:
      label: What you tried instead
      description: Workarounds you've used, and why they fall short.
```

## `.github/ISSUE_TEMPLATE/config.yml`

```yaml
blank_issues_enabled: true
contact_links:
  - name: How work is structured
    url: https://github.com/<owner>/<repo>/blob/main/.claude/rules/cbk-conventions.md
    about: Lanes, labels, branch naming — the cascade conventions.
  - name: What has been decided and built
    url: https://github.com/<owner>/<repo>/blob/main/docs/cbk/README.md
    about: The cascade events index.
```

Keep blank issues **enabled**. Cascade-native issues (`[<slug>:F<#>:R<#>]` and the other title forms) are created by the cascade skills with their own bodies; a forced form would corrupt them.

## `.github/pull_request_template.md`

The `## Review gate` block is not decoration — `.claude/rules/pr-review.md` § The floor treats a PR body without it as having had **no review pass**, whatever the hand-off claims. Shipping it in the template makes the gate auditable by default rather than by memory.

```markdown
## Summary

<!-- What changed and why. -->

Closes #

## Review gate

<!-- Filled by /finish. A PR body without this block is treated as having had NO
     review pass, regardless of what the hand-off claims — .claude/rules/pr-review.md
     § The floor. The floor is that both skills were ACTUALLY INVOKED; review-sweep
     supplements and never substitutes.

     Not a /finish run (an issue-less operator-directed branch)? Say so, and mark the
     lines "not run" with the reason. Stating it beats leaving it ambiguous.

     If the repo runs the auto-review workflow: it fires when this PR is flipped to
     ready (not on later pushes); end the branch on a non-marker commit before
     flipping (cbk-conventions.md § the CI-skip rule). -->

- `/simplify` —
- `pr-review-toolkit:review-pr` —
- `review-sweep` —

## Triage

<!-- Every finding under its class. Non-actioned findings live here, not lost.
     Surface entries carry the agent's verbatim rationale so the call can be made
     without re-running the toolkit. Later rounds append `## Triage — round N`
     (/pr-respond); the body is the audit surface for the PR's whole life. -->

- **Apply (0)** —
- **Apply with care (0)** —
- **Surface (0)** —
- **Defer (0)** —
- **Reject (0)** —

## Notes

<!-- ADRs, frame milestones, design decisions, or rules files this change relies on. -->
```

## `.github/CODEOWNERS`

```
* @<github-username>
```

Solo default; ask before assuming a team. CODEOWNERS is a **routing declaration** — it enforces nothing on its own. Enforcement is a ruleset requiring Code Owner review (`manual_steps.md` § Repository administration).

## `.github/workflows/ci.yml`

A stub only. Real CI is blueprint's job (`blueprint/references/templates/tooling.md`).

```yaml
name: CI
on:
  pull_request:
  push:
    branches: [main]

jobs:
  check:
    # `name:` is the check-run context a ruleset will require. Set it before the job
    # is promoted and never rename it afterwards — matching is by name, and a rename
    # orphans the required context (cbk-conventions.md § [skip ci] rule, the
    # required-checks trap, cause 3).
    name: check
    runs-on: ubuntu-latest
    steps:
      - run: echo "CI stub — blueprint wires the real gate"
```

**Two traps to respect the moment this job is promoted to a required check** (`cbk-conventions.md` § `[skip ci]` rule):

1. **A required-check workflow carries no `paths:` filter.** A filtered workflow does not run on a PR that touches nothing matching — the required context never reports, and the PR is blocked on a check that will never arrive. Required checks are always-run by construction; any narrowing happens inside the job as a fast no-op exit.
2. **The check-run name is the immutable API.** Rename the *workflow* if you must, never the job.

## `.github/dependabot.yml`

`cbk-conventions-reference.md` § Dependency settle-window is prose; this file is the mechanism. Three invariants are encoded here and must survive edits:

- **`cooldown` gates version updates only — security advisories still patch immediately.** A platform guarantee, not a convention ("The cooldown option is only available for version updates, not security updates" — `docs.github.com/en/code-security/dependabot/working-with-dependabot/dependabot-options-reference`, read 2026-09-06). Never widen a window to delay a security fix; that is not what the knob does.
- **`groups` is the anti-spam lever; `schedule.interval` is the volume lever.** Raising a floor does not reduce update volume — an update fires on a new release, not on the floor value.
- **Every ecosystem entry carries the floor — including the inactive stubs.** An entry without `cooldown` is a policy violation, not an oversight; a stub that is later uncommented must not be able to drop the floor by omission.

```yaml
version: 2
updates:
  # ── CI actions ────────────────────────────────────────────────────────────
  # Workflow actions are dependencies too, and a tag ref (`uses: vendor/x@v4`) is
  # mutable. Every `uses:` is pinned to a full commit SHA with a trailing version
  # comment; this entry maintains those pins under the same floor as everything else.
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "monthly"
    cooldown:
      default-days: 7                 # the settle window
    groups:
      ci-actions:
        patterns: ["*"]
        applies-to: "version-updates"
    open-pull-requests-limit: 3
    commit-message:
      prefix: "chore(deps)"

  # ── The project's lockfile-managed ecosystem(s) ───────────────────────────
  # One block per ecosystem with a lockfile in the repo. `directories` names every
  # tree that carries one (a workspace with per-package lockfiles needs each path;
  # a single "/" covers none of them).
  - package-ecosystem: "<npm | pip | cargo | pub | gomod | bundler | mix | …>"
    directories:
      - "/"
    schedule:
      interval: "monthly"
    cooldown:
      default-days: 7
    groups:
      prod:
        patterns: ["*"]
        dependency-type: "production"
        applies-to: "version-updates"
      dev:
        patterns: ["*"]
        dependency-type: "development"
        applies-to: "version-updates"
    open-pull-requests-limit: 5
    commit-message:
      prefix: "chore(deps)"

  # ── Inactive stubs carry the floor ────────────────────────────────────────
  # An ecosystem the repo does not use yet stays commented out WITH its cooldown,
  # so enabling it later is an uncomment, never a re-derivation of the policy.
  # - package-ecosystem: "docker"
  #   directory: "/"
  #   schedule: { interval: "monthly" }
  #   cooldown: { default-days: 7 }
```

**Not covered by any bot, and therefore not exempt:** toolchain and single-binary pins (`mise.toml` `[tools]`, `.tool-versions`, `rust-toolchain.toml`, a bare `.nvmrc`), container base-image tags, standalone binaries. They install the compilers that build everything else. Apply the same floor by hand, record the settle evidence in the commit (`"<version> is the newest build clearing the 7-day window as of <date>"`), and name the tracking mechanism (an open question in the frame, or a project automation) — silent exemption is how the highest-privilege dependency surface in the repo ends up unaudited (`cbk-conventions-reference.md` § Dependency settle-window).

## `.gitattributes`

Ships only when the repo has a lockfile the settle window audits. The git host marks recognised lockfiles as generated and collapses their diffs — hiding exactly the review the settle-window rule mandates. The rule and its sources are in `cbk-conventions-reference.md` § Dependency settle-window › Keep the lockfile diff visible.

```
# Only if the pre-check passes: zero CRLF files in the tree, no prior .gitattributes,
# core.autocrlf and core.eol unset — renormalizing a tree that already holds CRLF
# content rewrites history-visible bytes. Verified <date>.
* text=auto eol=lf

# Counter-line per audited lockfile the host would collapse (linguist's generated
# list is per-name; check it — the line is harmless where the name is not listed).
<lockfile> linguist-generated=false
```
