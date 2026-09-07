# Manual steps reference

The canonical list of operations that scaffold does not automate. The list is scoped against **tool availability and the operator's preference** — never against detection state: where a tool the session has (a `repo`-scoped `gh` token, a connected MCP) can do the operation and the operator has not asked to keep it in hand, scaffold does it and discloses the result, and the entry below says what it tries first and what the fallback is. The rest are operations that cannot be automated technically (UI-only, OAuth browser flows, billing) or that scaffold deliberately keeps in human hands for safety (admin permissions, security tokens, irreversible workflow customization).

When generating manual instructions in the bootstrap checklist's section 2, use this file as the source. Do not invent new manual steps. If the project genuinely needs something not listed here, surface it as an exception and flag the gap.

## Always-manual operations (across all axis combinations)

### Account creation and billing

- **GitHub account creation**: scaffold cannot create accounts. If the user doesn't have one, point them at https://github.com/signup.
- **GitHub paid plans**: free tier is fine for most projects. Pro/Team/Enterprise upgrades happen at https://github.com/settings/billing/plans. Scaffold never recommends upgrading unless the user explicitly hits a tier limit.
- **Linear account creation** (when planning = `linear`): https://linear.app/signup. Free tier supports up to 10 users.
- **Notion account creation** (when knowledge = `notion`): https://notion.so/signup.

### OAuth and integrations

- **GitHub MCP authentication**: handled by Claude's MCP connection flow, not scaffold. If GitHub MCP isn't connected at the start of the session, tell the user to connect it via their Claude settings before scaffold can do automated provisioning.
- **Linear ↔ GitHub app installation** (when planning = `linear`): Visit https://linear.app/settings/integrations/github → "Connect" → authorize the Linear GitHub app → select repos. Expected outcome: branches with Linear issue IDs auto-link to issues.
- **Linear ↔ Notion integration** (when both planning = `linear` and knowledge = `notion`): Visit https://linear.app/settings/integrations/notion → enable. Then in Notion, share the relevant pages with the Linear integration. Expected outcome: pasting a Linear URL in Notion shows a live preview.
- **Notion integration creation + per-page sharing** (when knowledge = `notion`): Visit https://notion.so/my-integrations → "New integration" → name it, give it the workspace, copy the secret. Then share each Notion page with the integration manually. There is no API for "share all pages with this integration" — it's per-page. This applies whether or not Linear is also in use.

### Repository administration

- **Branch protection (a ruleset)**: **try first** — when a `gh` token with `repo` scope exists, create a ruleset with `gh api repos/{owner}/{repo}/rulesets --method POST` (target `branch`, includes `refs/heads/main`; rules: `pull_request` with the approving reviews the team shape needs — 0 for solo — and `required_status_checks` naming the check-run context **read off a real run** (`gh run view --json jobs` on the stub CI's first run; never guessed from the workflow file), with `strict_required_status_checks_policy` set deliberately — `true` blocks a stale branch and interacts with the CI-skip marker per `cbk-conventions-reference.md` § Required-checks trap). Disclose the created ruleset (`gh api repos/{owner}/{repo}/rulesets`). **Fallback** — only when the call fails or no token exists: `<repo URL>/settings/rules` → "New branch ruleset" → target `main` → require a pull request and the status checks by their context names; for team profiles, at least one approving review. Expected outcome: direct pushes to `main` rejected; a PR whose required contexts have not reported cannot merge.
- **Reviewer agent-memory**: decided in the bootstrap checklist § Rule-file disposition (`project` = committed, `local` = never committed) and recorded in `cbk-conventions.md` § Surface inventory; with `project`, delete the kit's `.claude/agent-memory/` line from `.gitignore`.
- **Repository secrets**: Visit `<repo URL>/settings/secrets/actions` → "New repository secret" for any deployment tokens, API keys, or credentials. Scaffold never handles secret values directly.
- **Repository visibility changes**: visibility set at create time. Changing later is at `<repo URL>/settings` → "Danger Zone". Scaffold never changes visibility after creation.
- **Team member invitations**: Visit `<repo URL>/settings/access` → "Invite a collaborator". Or for org repos, manage via the org's team settings.
- **CODEOWNERS enforcement**: scaffold can create the file, but enforcement requires branch protection (above) with "Require review from Code Owners" enabled.

### Workflow customization

- **Linear workflow state customization** (when planning = `linear`): Visit `https://linear.app/<workspace>/settings/teams/<team>/workflow` → customize states. Linear ships with sensible defaults (Backlog → Todo → In Progress → In Review → Done) which scaffold recommends keeping unchanged for the first few cycles.
- **GitHub Projects custom fields**: Visit the project board → "..." → "Settings" → "Custom fields". Scaffold creates the board with default fields only; custom fields are user-added later if needed.
- **GitHub Actions workflows beyond the stub**: scaffold creates the CI stub as a structural placeholder and, with the operator's PR/review answer allowing it, blueprint emits the review workflows (`blueprint/references/templates/claude-review.yml`, `claude.yml`); the ADR-immutability lint ships with the ADR starters. Real CI gates depend on stack decisions that happen in blueprint, so they are deferred there — not to the operator.

### Enterprise-only operations

- **SSO/SAML setup**: Enterprise plan only. Out of scope for scaffold; the user's IT team handles this.
- **Audit log access**: Enterprise feature. Out of scope.
- **IP allowlists**: Enterprise feature. Out of scope.

## How to use this file when generating the bootstrap checklist

1. Identify which operations are required for this specific project (based on the planning and knowledge axis choices, team size, and brief).
2. Pull the relevant entries from this file verbatim — copy the URL and expected outcome.
3. Customize only the placeholders (`<repo URL>`, `<workspace>`, etc.) with real values from the current session.
4. Group entries by category in the bootstrap checklist's section 2 if there are more than ~5 items.
5. Never add manual steps to the checklist that aren't in this file. If something is needed and not here, surface it as an exception in the chat and ask the user how to handle it.

## Why this list is closed

The cascade is supposed to be opinionated and predictable. A scaffold run that produces a different set of "manual steps" each time, depending on what Claude decides to surface, is unpredictable in exactly the way that erodes trust. Closing the list to a canonical reference means: the user knows what to expect, the skill behaves consistently across sessions, and any surprise gets surfaced as an exception (which is itself a useful signal that the cascade is missing something).

If a real run surfaces a manual step that should have been in this file but wasn't, that's a bug in the file — fix it before the next scaffold run, don't paper over it at runtime.

## Light mode

Light mode does not change this file's contents. What it changes is *how many* of these manual steps end up in a given checklist — light mode users typically skip branch protection, skip team invites (if solo), skip OAuth integrations they don't need yet, and end up with a much shorter section 2. The list itself stays canonical.
