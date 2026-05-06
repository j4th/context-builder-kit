# Manual steps reference

The canonical list of operations that scaffold **never automates**, regardless of detection state, MCP availability, or user preference. These are operations that either cannot be automated technically (UI-only, OAuth browser flows, billing) or that scaffold deliberately keeps in human hands for safety reasons (admin permissions, security tokens, irreversible workflow customization).

When generating manual instructions in the bootstrap checklist's section 2, use this file as the source. Do not invent new manual steps. If the project genuinely needs something not listed here, surface it as an exception and flag the gap.

## Always-manual operations (both profiles)

### Account creation and billing

- **GitHub account creation**: scaffold cannot create accounts. If the user doesn't have one, point them at https://github.com/signup.
- **GitHub paid plans**: free tier is fine for most projects. Pro/Team/Enterprise upgrades happen at https://github.com/settings/billing/plans. Scaffold never recommends upgrading unless the user explicitly hits a tier limit.
- **Linear account creation** (opinionated profile): https://linear.app/signup. Free tier supports up to 10 users.
- **Notion account creation** (opinionated profile): https://notion.so/signup.

### OAuth and integrations

- **GitHub MCP authentication**: handled by Claude's MCP connection flow, not scaffold. If GitHub MCP isn't connected at the start of the session, tell the user to connect it via their Claude settings before scaffold can do automated provisioning.
- **Linear ↔ GitHub app installation** (opinionated profile): Visit https://linear.app/settings/integrations/github → "Connect" → authorize the Linear GitHub app → select repos. Expected outcome: branches with Linear issue IDs auto-link to issues.
- **Linear ↔ Notion integration** (opinionated profile): Visit https://linear.app/settings/integrations/notion → enable. Then in Notion, share the relevant pages with the Linear integration. Expected outcome: pasting a Linear URL in Notion shows a live preview.
- **Notion integration creation** (opinionated profile): Visit https://notion.so/my-integrations → "New integration" → name it, give it the workspace, copy the secret. Then share each Notion page with the integration manually. There is no API for "share all pages with this integration" — it's per-page.

### Repository administration

- **Branch protection rules**: Visit `<repo URL>/settings/branches` → "Add branch protection rule" → pattern `main` → enable "Require a pull request before merging" and "Require status checks to pass before merging". For team profiles, also enable "Require approvals" with at least 1 reviewer. Expected outcome: direct pushes to main are rejected.
- **Repository secrets**: Visit `<repo URL>/settings/secrets/actions` → "New repository secret" for any deployment tokens, API keys, or credentials. Scaffold never handles secret values directly.
- **Repository visibility changes**: visibility set at create time. Changing later is at `<repo URL>/settings` → "Danger Zone". Scaffold never changes visibility after creation.
- **Team member invitations**: Visit `<repo URL>/settings/access` → "Invite a collaborator". Or for org repos, manage via the org's team settings.
- **CODEOWNERS enforcement**: scaffold can create the file, but enforcement requires branch protection (above) with "Require review from Code Owners" enabled.

### Workflow customization

- **Linear workflow state customization** (opinionated profile): Visit `https://linear.app/<workspace>/settings/teams/<team>/workflow` → customize states. Linear ships with sensible defaults (Backlog → Todo → In Progress → In Review → Done) which scaffold recommends keeping unchanged for the first few cycles.
- **GitHub Projects custom fields**: Visit the project board → "..." → "Settings" → "Custom fields". Scaffold creates the board with default fields only; custom fields are user-added later if needed.
- **GitHub Actions workflows beyond the stub**: scaffold creates an empty CI workflow file as a structural placeholder. Real CI configuration depends on stack decisions that happen in blueprint, so it's deliberately deferred.

### Enterprise-only operations

- **SSO/SAML setup**: Enterprise plan only. Out of scope for scaffold; the user's IT team handles this.
- **Audit log access**: Enterprise feature. Out of scope.
- **IP allowlists**: Enterprise feature. Out of scope.

## How to use this file when generating the bootstrap checklist

1. Identify which operations are required for this specific project (based on profile, team size, and brief).
2. Pull the relevant entries from this file verbatim — copy the URL and expected outcome.
3. Customize only the placeholders (`<repo URL>`, `<workspace>`, etc.) with real values from the current session.
4. Group entries by category in the bootstrap checklist's section 2 if there are more than ~5 items.
5. Never add manual steps to the checklist that aren't in this file. If something is needed and not here, surface it as an exception in the chat and ask the user how to handle it.

## Why this list is closed

The cascade is supposed to be opinionated and predictable. A scaffold run that produces a different set of "manual steps" each time, depending on what Claude decides to surface, is unpredictable in exactly the way that erodes trust. Closing the list to a canonical reference means: the user knows what to expect, the skill behaves consistently across sessions, and any surprise gets surfaced as an exception (which is itself a useful signal that the cascade is missing something).

If a real run surfaces a manual step that should have been in this file but wasn't, that's a bug in the file — fix it before the next scaffold run, don't paper over it at runtime.

## Light mode

Light mode does not change this file's contents. What it changes is *how many* of these manual steps end up in a given checklist — light mode users typically skip branch protection, skip team invites (if solo), skip OAuth integrations they don't need yet, and end up with a much shorter section 2. The list itself stays canonical.
