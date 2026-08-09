# Tooling — agent tool-selection rules

> **This file is a template.** Copy it into a target project's `.claude/rules/tooling.md`, fill the bracketed stack sections with the project's actual MCPs and tools, and delete sections that don't apply. It guides which tool to reach for; pairs with [`workflows.md`](workflows.md) (which pattern) and [`orchestration.md`](orchestration.md) (which model/effort per dispatched agent).
>
> *(Naming note: this is a different surface from the blueprint skill's `templates/tooling.md`, which produces task-runner + CI configs. That one wires `mise`/`make`/CI; this one guides the agent's tool selection at runtime.)*
>
> The principle: **built-in tools are first-line; MCPs are second-line for cases the built-ins don't cover.** Don't reach for an MCP when `Read` / `Edit` / `Write` / `Bash` / `Glob` / `Grep` would suffice. MCPs add capability (semantic intelligence, hosted APIs, external services); they do not replace the fast local tools.
>
> Each section keeps the same shape: a "you want to… / reach for… / why" table plus a one-line **decision rule**. Add a section per stack surface the project actually wires (database, cloud CLI, observability, domain MCPs) using that shape.

## Code intelligence

| You want to … | Reach for | Why |
|---|---|---|
| Find a literal string or regex | `Grep` (built-in) | Fast, ripgrep-backed, no server startup |
| Find files by path / glob | `Glob` (built-in) | Same — pattern matching, no semantics |
| Read a known file | `Read` (built-in) | Direct; line-numbered output |
| Find every reference to a symbol / rename cleanly / get signatures | `<your code-intelligence MCP, if wired>` | LSP-grade operations — handles renames, imports, scope; text search misses cross-file refs through aliases |

**Decision rule**: if the operation cares about *symbols* (refs, renames, signatures), use the code-intelligence MCP (when wired). If it cares about *text* (strings, patterns), use built-ins. [If no code-intelligence MCP is wired, note the fallback: `Grep` + manual cross-file work.]

## Library / framework docs

| You want to … | Reach for | Why |
|---|---|---|
| Read current API docs for any dependency in the lockfile | `<your live-docs MCP — e.g. context7's resolve-library-id + query-docs>` | Training data lags; the live-docs MCP has current pages |
| Read a specific URL the operator quoted | `WebFetch` (built-in) | Direct fetch; markdown extraction |
| Search the open web for blog posts / consensus | `WebSearch` (built-in) | Practitioner signals, not API references |
| Confirm Claude Code / harness internals | `WebFetch` against the vendor's docs site | The vendor's docs are the authoritative source |

**Decision rule**: live-docs MCP **first** for library API references on anything pinned via lockfile — training-data recall on fast-moving libraries is unreliable. Never assert a dependency's API from memory when the project treats that dependency as fast-moving; ground it in fetched docs or the installed source.

## Planning backend

*(Fill in per the planning axis the project picked at scaffold — see `cbk-conventions.md` § Surface inventory.)*

| You want to … | Reach for | Why |
|---|---|---|
| Read a cascade issue | `<planning-backend MCP read call, or gh CLI>` | The planning backend is the source of truth for cascade sub-issues |
| Create / update an issue or comment | `<planning-backend MCP write call>` | Same |
| Create / read / comment on a PR | `<github MCP calls>` or `Bash` with `gh` | The git host is the source of truth for PRs, code review, repo state |

**Decision rule**: cascade issues live on the planning backend; PRs and code review live on the git host. `/finish` reads the planning backend for the spec and writes a PR with the close marker from `cbk-conventions.md` § Closes-keyword conventions.

## Knowledge backend

*(Delete if knowledge backend = none.)*

| You want to … | Reach for | Why |
|---|---|---|
| Read a designated page | `<knowledge-backend MCP fetch>` | After **HITL announcement** per [`knowledge-backend.md § HITL announcement discipline`](knowledge-backend.md) |
| Search knowledge content | `<knowledge-backend MCP search>` | Same — announce first |
| Write a page | `<knowledge-backend MCP write calls>` | **Only with explicit operator approval**; never as a side effect — hook-enforced via `require-knowledge-backend-ok.sh` |

**Decision rule**: never read or write the knowledge backend silently. Announce *before* every operation; the operator can decline per-page. The cascade phase determines the write default (see `knowledge-backend.md` § When to write); rough-in never writes by design.

## Time

| You want to … | Reach for | Why |
|---|---|---|
| Get the current time / convert timezones | `<a time MCP, if wired>` | Avoids drift when the system clock or session timezone differs |

**Decision rule**: convert any *relative* date in a prompt ("Thursday", "last week") to an *absolute* date before saving it to memory, a cascade artifact, or any persistent surface. Relative dates rot fast.

## [Stack surfaces — add a section per wired MCP]

[One section per stack surface the project wires — database client, cloud CLI, observability, domain services — each with the same table shape, a decision rule, and any **gotchas the build has actually proved out** (recorded here so they aren't re-discovered; date them per the conventions' dated-rails principle). Delete this placeholder once real sections exist.]

## Plugins

| Plugin / skill | When | Cite |
|---|---|---|
| `pr-review-toolkit:review-pr` | Invoked by `/finish`'s review pass (directly or via the `review-sweep` workflow); **non-skippable** | [`pr-review.md`](pr-review.md) |
| `/simplify` | Invoked by `/finish`'s simplify pass; **non-skippable** | [`simplification.md`](simplification.md) |
| [other installed plugins] | [per their own descriptions] | |

**Decision rule**: don't invoke `pr-review-toolkit` or `/simplify` outside `/finish` unless the operator explicitly asks — they're calibrated for that flow. Domain plugins are reached per their own descriptions; they are not cascade-mandatory.

## Skills

| Skill / command | Use when |
|---|---|
| `consultation` | Raw idea → problem brief (phase 1) |
| `scaffold` | Problem brief → workspace + backends (phase 2; deliberate-invoke) |
| `blueprint` | Scaffold output → stack decisions + foundation docs (phase 3; deliberate-invoke) |
| `framing` | Workstream → milestones (phase 4; deliberate-invoke, per workstream just-in-time) |
| `rough-in` | One milestone → `/finish`-ready sub-sub-issues (phase 5; deliberate-invoke) |
| `/finish <N>` | One sub-sub-issue → draft PR (phase 6) |
| `/intake <ref>` | Externally-sourced report → shaped `/finish`-able issue |
| `/enrich <N>` | Thin enhancement-lane candidate → roughed-in issue |
| `/pr-respond <N>` | Triage + action review feedback on PR #N |
| `adr-new` | Record an immutable architecture decision (auto-syncs the indexes) |

## Built-in tools (first-line)

| Tool | When |
|---|---|
| `Read` | Read a known file path |
| `Edit` | Targeted string replacement in an existing file (preferred over Write for modifications) |
| `Write` | Create a new file or full rewrite |
| `Bash` | Run a shell command (git, the task runner, gh) |
| `Glob` / `Grep` | Find files / search contents |
| Task-tracking tools | Track multi-step work — see [`workflows.md`](workflows.md) |
| `AskUserQuestion` | Surface a decision the operator owns; never preview-and-confirm trivial ops |
| `WebFetch` / `WebSearch` | Fetch a specific URL / general web search |

**Decision rule**: if a built-in answers the question, use it. Don't reach for an MCP for what `Read` / `Grep` would do.

## See also

- [`workflows.md`](workflows.md) — when to apply which workflow pattern
- [`orchestration.md`](orchestration.md) — model & effort tiering when dispatching agents
- [`knowledge-backend.md`](knowledge-backend.md) — HITL discipline for the knowledge backend
- [`cbk-conventions.md`](cbk-conventions.md) — cascade conventions; § Surface inventory records which backends/MCPs this project wired
- [`pr-review.md`](pr-review.md), [`simplification.md`](simplification.md), [`testing.md`](testing.md), [`logging.md`](logging.md)
