# Harvest 5 — V8: Target hygiene

**Scope.** This cluster closes what a target inherits around the cascade rather than inside it: Dependabot's real coverage of container images and its three gaps, with the named-stage remedy for `COPY --from` on all three surfaces that stated it, plus the docker stubs in both dependabot examples (`#70/body/4`, `#70/body/4-stubs`, `critic/3`, `review/portability/66`); the mise inline-task shell with its version floor, pinned by the block (`#70/body/5`, the mise half of `#70/table/mise-mcp-row` and `critic/4`); the rebuilt `.mcp.json.example` under D58, the settle-window rule that an MCP server is a dependency, and one secret-handling story across the example, `tooling.md` and the blueprint template, with probe P5 run against the live endpoints (`#70/body/6a`, `#70/body/6b`, the MCP halves of `#70/table/mise-mcp-row` and `critic/4`, `review/claude-code/12`, `review/security/17`, `review/release/24`, `review/release/28`); the anchored `.gitignore` harness block, pinned by `git check-ignore` in a throwaway repository, carried by the kit's own `.gitignore`, with the unanchored `reference/` line gone (`#71/body/3`, `#71/decision/runtime-paths`, `#58/c5901493591/R7`, `review/release/62`); and kit-owned code kept out of a target's formatter, through `format-on-edit.sh`'s floor, its forcing-flag arms, the bootstrap checklist's one-time choice, and both advisory exemplars' exec-form `Register:` stanzas with R11's three-edit note (`#71/body/1`, `#71/body/2`, `#71/decision/other-formatters`, `#71/table/bootstrap-checklist`, `critic/5`, the exemplar half of `#58/c5901493591/R11`). It consumes V1's runner and sentinels (§ Verification structure), V2's rewrite of § Hook authoring (which cites this cluster's negation bullet in § .gitignore anchoring), V3's exec-form registry and its `settings.json` edits, V4's CI-stub edits to the same starter and template files, V5's budget split, and V6's runner docstring, which cites the harness-block heading V8.4 produces. `#71/body/1`'s § Syncing the kit clause is V10's to land; its exact text is under **Handed to other clusters**.

**How to read the tasks.** Every edit is an exact-string replacement: find the **Old** text (it must occur exactly once), replace it with the **New** text. Long fragments are fenced with `~~~~`; the fence lines are not part of the text. Three files are rewritten whole (`.mcp.json.example`, `.gitignore`, `.claude/hooks/format-on-edit.sh`); V8 alone edits each of them (the ownership map), and each task first checks that the file is unchanged since `74edf84`. Each task's block check goes on the lines immediately before `echo "verification: kit sub-block complete"`. The red run is Step 2, and its FAIL line goes into the PR body's red-first table. Every red line and every green run below was produced on a scratch copy of the kit at `643f7ff` with the earlier V8 tasks applied, on 2026-09-30. At execution V1–V7 will have landed, and the line numbers will have moved, but no V8 anchor lies in a region another cluster edits.

**Before V8.1.** Run `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -3; echo "exit=${PIPESTATUS[0]}"`. Expected: `verification: kit sub-block complete`, `verification: done`, `exit=0` (V1's third rail prints nothing on the kit tree). Record the `always-loaded total:` line; V8.3 is the only V8 task that changes it.

---

### Task V8.1: Dependabot covers container images, with three named gaps (#70/body/4, #70/body/4-stubs, critic/3, review/portability/66; D52)

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md` — § Dependency settle-window (the toolchain paragraph, a new container-images paragraph) and the kit sub-block of § Verification (one check appended at the sentinel)
- Modify: `.claude/skills/blueprint/references/templates/tooling.md` — sanity question 6b
- Modify: `.claude/skills/scaffold/references/github-starter-templates.md` — § `.github/dependabot.yml`: the inactive-stub block and the "Not covered by any bot" paragraph
- Modify: `.github/dependabot.yml.example` — invariant 1's citation, and two stubs appended after the `mix` stub

**Interfaces:**
- Consumes: V1's § Verification structure (the sentinel line `echo "verification: kit sub-block complete"`), and V4's CI-stub edits, which sit elsewhere in the same starter and template files.
- Produces: the paragraph beginning `**Container images are covered, with three gaps.**` in § Dependency settle-window. V8.3 anchors its MCP paragraph on the unchanged `**Inactive ecosystem stubs carry the floor too.**` that follows it.
- Produces: the block check whose failure messages are `… § Dependency settle-window does not name the COPY --from gap`, `<file> lacks the <docker|docker-compose> stub (§ Dependency settle-window)` and `an update-bot entry lacks its cooldown floor (§ Dependency settle-window › Inactive ecosystem stubs)`. The variable `dbx` names `.github/dependabot.yml.example` when the file exists.
- Produces, for V10's Sync notes: "`rust-toolchain.toml` is covered by Dependabot's `rust-toolchain` ecosystem; a target whose filled settle-window section lists it as uncovered corrects that section."

- [ ] **Step 0: Re-fetch every source this task quotes (constraint 7)**

Run:
```bash
T=$(mktemp -d)
curl -sL 'https://docs.github.com/api/article/body?pathname=/en/code-security/dependabot/working-with-dependabot/dependabot-options-reference' -o "$T/opts.md"
curl -sL 'https://docs.github.com/api/article/body?pathname=/en/code-security/dependabot/ecosystems-supported-by-dependabot/supported-ecosystems-and-repositories' -o "$T/eco.md"
curl -sL https://raw.githubusercontent.com/dependabot/dependabot-core/main/docker/README.md -o "$T/readme.md"
curl -sL https://raw.githubusercontent.com/dependabot/dependabot-core/main/docker/lib/dependabot/docker/file_parser.rb -o "$T/parser.rb"
grep -cF '`rust-toolchain`' "$T/opts.md"
sed -E 's/<svg[^>]*aria-label="([^"]*)"[^<]*<path[^>]*><\/path><\/svg>/\1/g' "$T/opts.md" | grep -E '^\| Docker( Compose)? +\| Supported'
grep -cF 'Dependabot supports automatic updates for Rust toolchain versions defined in `rust-toolchain.toml` and `rust-toolchain` files' "$T/eco.md"
grep -cF 'to update Features in your `devcontainer.json` configuration files' "$T/eco.md"
grep -cF "Docker Hub's \`tag_last_pushed\` is currently the only accepted source" "$T/readme.md"
grep -cF 'allow the update and record a `cooldown_date_unavailable` warning' "$T/readme.md"
grep -c 'FROM_LINE' "$T/parser.rb"; grep -ci 'COPY' "$T/parser.rb"
for w in mise asdf nvm tool-versions nvmrc; do printf '%s ' "$w:$(grep -ci -- "$w" "$T/opts.md")"; done; echo
rm -rf "$T"
```
Expected, in order: a count of at least `1`; two table rows, `| Docker             | Supported | Not supported |` and `| Docker Compose     | Supported | Not supported |`; then `1`, `1`, `1`, `1`; a `FROM_LINE` count of at least `2` and a `COPY` count of `0`; and `mise:2 asdf:0 nvm:0 tool-versions:0 nvmrc:0`. Both `mise` hits are the word "compromised"; `grep -oi '.\{0,12\}mise.\{0,12\}' "$T/opts.md"` shows them. No ecosystem reads a toolchain manager's pin file. If any quote no longer matches, stop. Re-read the page, reword the sentence to what the page now says, and re-date it. Never keep a quote the page has dropped.

- [ ] **Step 1: Append the block check**

In `.claude/rules/cbk-conventions-reference.md`:

Old:
~~~~
echo "verification: kit sub-block complete"
~~~~
New:
~~~~
# Container images (context-builder-kit#70 item 4): the three surfaces that state what Dependabot covers name the
# COPY --from gap and its named-stage remedy (the reference half is read by section, so this comment cannot answer
# for it), none still calls a base-image tag uncovered, both dependabot examples offer the docker and docker-compose
# stubs, and every entry — live or stub — carries its cooldown floor (a fence closes an entry, so prose after a stub
# cannot lend it one). The elided-URL form cannot return.
sw=$(awk '/^## Dependency settle-window/{p=1; next} p && /^## /{exit} p' .claude/rules/cbk-conventions-reference.md)
grep -q 'COPY --from' <<<"$sw" || { echo "cbk-conventions-reference.md § Dependency settle-window does not name the COPY --from gap"; exit 1; }
for f in .claude/skills/blueprint/references/templates/tooling.md .claude/skills/scaffold/references/github-starter-templates.md; do grep -q 'COPY --from' "$f" || { echo "$f does not name the COPY --from gap (cbk-conventions-reference.md § Dependency settle-window)"; exit 1; }; done
absent grep -rniE "container base-image tag[s]?( are outside|, or a single)|base-image tags, standalon[e]" .claude/
dbx=""; [ -f .github/dependabot.yml.example ] && dbx=.github/dependabot.yml.example
for f in .claude/skills/scaffold/references/github-starter-templates.md $dbx; do for e in docker docker-compose; do grep -q "package-ecosystem: \"$e\"" "$f" || { echo "$f lacks the $e stub (§ Dependency settle-window)"; exit 1; }; done; awk '/package-ecosystem:/ { if (e != "" && !c) { print FILENAME ": no cooldown under " e; bad = 1 } e = $0; c = 0; next } /cooldown/ { c = 1 } /^```/ { if (e != "" && !c) { print FILENAME ": no cooldown under " e; bad = 1 } e = ""; c = 0 } END { if (e != "" && !c) { print FILENAME ": no cooldown under " e; bad = 1 } exit bad }' "$f" || { echo "an update-bot entry lacks its cooldown floor (§ Dependency settle-window › Inactive ecosystem stubs)"; exit 1; }; done
absent grep -rn "docs\.github\.com …" .claude/ $dbx
echo "verification: kit sub-block complete"
~~~~

The reference half is read by section, because this comment itself contains the words `COPY --from`. Without that, the grep would pass on the check's own text.

- [ ] **Step 2: Run it against the unfixed files**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2`
Expected (FAIL):
```
cbk-conventions-reference.md § Dependency settle-window does not name the COPY --from gap
verification: block exited 1
```
Record the first line in the PR body's red-first table.

- [ ] **Step 3: The change**

(a) In `.claude/rules/cbk-conventions-reference.md` § Dependency settle-window, correct the toolchain paragraph's opening. Only the first two sentences change; the paragraph continues unchanged from `the commit that sets the pin states`.

Old:
~~~~
**Toolchain and single-binary pins take the floor by hand.** No update bot covers the toolchain manager's pins (`mise.toml` `[tools]`, `.tool-versions`, `rust-toolchain.toml`, `.nvmrc`), a container base-image tag, or a single-binary tool fetched by URL. For each:
~~~~
New:
~~~~
**Toolchain and single-binary pins take the floor by hand.** Dependabot, the update bot the kit's `dependabot.yml` configures, covers none of the toolchain manager's pins (`mise.toml` `[tools]`, `.tool-versions`, `.nvmrc`) and no single-binary tool fetched by URL: no ecosystem in its `package-ecosystem` table reads them (`https://docs.github.com/en/code-security/dependabot/working-with-dependabot/dependabot-options-reference` § package-ecosystem, read 2026-09-30). `rust-toolchain.toml` is the exception: "Dependabot supports automatic updates for Rust toolchain versions defined in `rust-toolchain.toml` and `rust-toolchain` files" (`https://docs.github.com/en/code-security/dependabot/ecosystems-supported-by-dependabot/supported-ecosystems-and-repositories` § Rust toolchain, read 2026-09-30). For each uncovered pin:
~~~~

(b) In the same section, add the container-images paragraph before the inactive-stub paragraph.

Old:
~~~~
**Inactive ecosystem stubs carry the floor too.**
~~~~
New:
~~~~
**Container images are covered, with three gaps.** An image named in a Dockerfile `FROM` or a compose `image:` is maintained by the `docker` and `docker-compose` ecosystems, and both take the floor like any other entry (each lists `default-days` as supported — the options reference above, § cooldown, read 2026-09-30). Three corners are not covered:

- **An image referenced only by `COPY --from=<image>` is never read.** The docker updater parses `FROM` lines alone (its `FROM_LINE` pattern, `https://github.com/dependabot/dependabot-core/blob/main/docker/lib/dependabot/docker/file_parser.rb`, read 2026-09-30). Route such an image through a named stage — `FROM <image>@<digest> AS <stage>`, then `COPY --from=<stage>` — and the updater maintains it like any other `FROM`.
- **A dev container's image is outside every ecosystem.** `devcontainers` exists "to update Features in your `devcontainer.json` configuration files" (the supported-ecosystems page above, § Dev containers, read 2026-09-30), not the image the file names; that image takes the floor by hand, like a toolchain pin.
- **The cooldown has a publication date only from Docker Hub.** "Docker Hub's `tag_last_pushed` is currently the only accepted source", and where no verified date exists Dependabot's policy is to "allow the update and record a `cooldown_date_unavailable` warning" (`https://github.com/dependabot/dependabot-core/blob/main/docker/README.md` § Cooldown publication dates, read 2026-09-30). A GHCR or other-registry image is therefore proposed with no settle window at all: read its publication date by hand before merging the bump.

The same coverage fact is stated in blueprint's `templates/tooling.md` sanity question 6b and in `github-starter-templates.md` § `.github/dependabot.yml`; an edit sweeps all three in one commit (`cbk-conventions.md` § Multi-surface facts).

**Inactive ecosystem stubs carry the floor too.**
~~~~

(c) In `.claude/skills/blueprint/references/templates/tooling.md`, rewrite sanity question 6b.

Old:
~~~~
6b. **Toolchain pins the bot does not cover** — the toolchain manager's pins (`mise.toml` `[tools]`, `.tool-versions`, `rust-toolchain.toml`, `.nvmrc`) and container base-image tags are outside every dependabot ecosystem: the settle window applies by hand (`cbk-conventions-reference.md` § Dependency settle-window). Decide now how the project records the settled age at pin time and what tracks the next bump — an open question in the frame, or a project automation.
~~~~
New:
~~~~
6b. **Pins the bot does not cover** — the toolchain manager's pins (`mise.toml` `[tools]`, `.tool-versions`, `.nvmrc`), an image referenced only by `COPY --from=<image>`, and a dev container's image are outside every dependabot ecosystem, and a bumped image from any registry but Docker Hub arrives with no cooldown date: the settle window applies by hand. A Dockerfile `FROM`, a compose `image:` and `rust-toolchain.toml` are covered, and a `COPY --from` image is brought under the bot by a named `FROM … AS <stage>` (`cbk-conventions-reference.md` § Dependency settle-window, which states this once; the starter's `dependabot.yml` section restates it). Decide now how the project records the settled age at pin time and what tracks the next bump — an open question in the frame, or a project automation.
~~~~

(d) In `.claude/skills/scaffold/references/github-starter-templates.md`, add the image comment and the `docker-compose` stub to the inactive-stub block.

Old:
~~~~
  # ── Inactive stubs carry the floor ────────────────────────────────────────
  # An ecosystem the repo does not use yet stays commented out WITH its cooldown,
  # so enabling it later is an uncomment, never a re-derivation of the policy.
  # - package-ecosystem: "docker"
  #   directory: "/"
  #   schedule: { interval: "monthly" }
  #   cooldown: { default-days: 7 }
```
~~~~
New:
~~~~
  # ── Inactive stubs carry the floor ────────────────────────────────────────
  # An ecosystem the repo does not use yet stays commented out WITH its cooldown,
  # so enabling it later is an uncomment, never a re-derivation of the policy.
  # Images: `docker` reads a Dockerfile's FROM lines, `docker-compose` a compose
  # file's image: keys. Neither reads COPY --from=<image>, and the cooldown has a
  # publication date only from Docker Hub — the note below this block.
  # - package-ecosystem: "docker"
  #   directory: "/"
  #   schedule: { interval: "monthly" }
  #   cooldown: { default-days: 7 }
  # - package-ecosystem: "docker-compose"
  #   directory: "/"
  #   schedule: { interval: "monthly" }
  #   cooldown: { default-days: 7 }
```
~~~~

(e) In the same file, rewrite the paragraph under the fence.

Old:
~~~~
**Not covered by any bot, and therefore not exempt:** toolchain and single-binary pins (`mise.toml` `[tools]`, `.tool-versions`, `rust-toolchain.toml`, a bare `.nvmrc`), container base-image tags, standalone binaries. They install the compilers that build everything else. Apply the same floor by hand, record the settle evidence in the commit (`"<version> is the newest build clearing the 7-day window as of <date>"`), and name the tracking mechanism (an open question in the frame, or a project automation) — silent exemption is how the highest-privilege dependency surface in the repo ends up unaudited (`cbk-conventions-reference.md` § Dependency settle-window).
~~~~
New:
~~~~
**Not covered by Dependabot, and therefore not exempt:** toolchain and single-binary pins (`mise.toml` `[tools]`, `.tool-versions`, a bare `.nvmrc`) and standalone binaries — they install the compilers that build everything else — plus an image referenced only by `COPY --from=<image>` and a dev container's image. Apply the same floor by hand, record the settle evidence in the commit (`"<version> is the newest build clearing the 7-day window as of <date>"`), and name the tracking mechanism (an open question in the frame, or a project automation) — silent exemption is how the highest-privilege dependency surface in the repo ends up unaudited. An image in a Dockerfile `FROM` or a compose `image:` **is** covered, by the two stubs above; route a `COPY --from` image through a named `FROM <image> AS <stage>` and `docker` maintains it too. Where the image's registry is not Docker Hub, the bump arrives with no cooldown date, so read the image's publication date before merging it. The rule and its sources are `cbk-conventions-reference.md` § Dependency settle-window; blueprint's `templates/tooling.md` sanity question 6b restates it.
~~~~

(f) In `.github/dependabot.yml.example`, restore the elided URL (`review/portability/66`).

Old:
~~~~
#    guarantee: docs.github.com … dependabot-options-reference, read 2026-09-06).
~~~~
New:
~~~~
#    guarantee: https://docs.github.com/en/code-security/dependabot/working-with-dependabot/dependabot-options-reference
#    § cooldown, read 2026-09-06).
~~~~

(g) In the same file, append the image stubs after the `mix` stub. The file's invariant 3 holds for them: every stub carries its floor.

Old:
~~~~
  # - package-ecosystem: "mix"
  #   directory: "/"
  #   schedule: { interval: "monthly" }
  #   cooldown: { default-days: 7 }
~~~~
New:
~~~~
  # - package-ecosystem: "mix"
  #   directory: "/"
  #   schedule: { interval: "monthly" }
  #   cooldown: { default-days: 7 }
  # Images: `docker` reads a Dockerfile's FROM lines, `docker-compose` a compose file's
  # image: keys. Neither reads COPY --from=<image> (route it through a named
  # `FROM <image> AS <stage>`), `devcontainers` bumps Features and not the dev container's
  # image, and the cooldown has a publication date only from Docker Hub
  # (.claude/rules/cbk-conventions-reference.md § Dependency settle-window).
  # - package-ecosystem: "docker"
  #   directory: "/"
  #   schedule: { interval: "monthly" }
  #   cooldown: { default-days: 7 }
  # - package-ecosystem: "docker-compose"
  #   directory: "/"
  #   schedule: { interval: "monthly" }
  #   cooldown: { default-days: 7 }
~~~~

- [ ] **Step 4: Run green, then prove the floor check can fail**

Run:
```bash
python3 -c "import yaml; yaml.safe_load(open('.github/dependabot.yml.example')); print('yaml ok')"
bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"
b=$(mktemp); cp .github/dependabot.yml.example "$b"
awk '{ if ($0 ~ /cooldown: \{ default-days: 7 \}/) { n++; if (n == 9) next } print }' "$b" > .github/dependabot.yml.example
bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -3 | head -2
cp "$b" .github/dependabot.yml.example && rm -f "$b"; git status --short .github
```
Expected: `yaml ok`; `verification: kit sub-block complete`, `verification: done`, `exit=0`. The mutation then drops the ninth `cooldown: { default-days: 7 }` line, which belongs to the `docker-compose` stub, and prints:
```
.github/dependabot.yml.example: no cooldown under   # - package-ecosystem: "docker-compose"
an update-bot entry lacks its cooldown floor (§ Dependency settle-window › Inactive ecosystem stubs)
```
After the restore, `git status --short .github` shows ` M .github/dependabot.yml.example`, the Step 3 edit only. The always-loaded total is unchanged.

- [ ] **Step 5: Commit**

```bash
git add .claude/rules/cbk-conventions-reference.md .claude/skills/blueprint/references/templates/tooling.md .claude/skills/scaffold/references/github-starter-templates.md .github/dependabot.yml.example
git commit -m "fix(hygiene): V8 — Dependabot covers container images; name its three gaps

Three surfaces said a container base-image tag is outside every update bot.
A Dockerfile FROM and a compose image: are covered by the docker and
docker-compose ecosystems. The real gaps are now named on all three
surfaces, each with the others' locations: COPY --from is never read (route
the image through a named FROM … AS <stage>); devcontainers bumps Features,
not the image; and the cooldown has a publication date only from Docker
Hub, so a GHCR image arrives with no settle window. The same re-read showed
rust-toolchain.toml is covered by the rust-toolchain ecosystem, so it leaves
the uncovered list. Both dependabot examples gain the docker and
docker-compose stubs with their floor, and invariant 1's elided URL is
restored. A kit-sub-block check pins COPY --from on the three surfaces,
both stubs, and a cooldown under every entry.

Sources read 2026-09-30: the Dependabot options reference and supported-
ecosystems pages, and dependabot-core docker/README.md and
docker/lib/dependabot/docker/file_parser.rb.

Trace: #70/body/4, #70/body/4-stubs, critic/3, review/portability/66

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task V8.2: mise inline tasks run under bash with pipefail and inherit_errexit (#70/body/5, #70/table/mise-mcp-row (mise half), critic/4 (mise half); D52)

**Files:**
- Modify: `.claude/skills/blueprint/references/templates/tooling.md` — step 1's `mise.toml` bullet
- Modify: `.claude/rules/cbk-conventions-reference.md` — the kit sub-block of § Verification (one check appended at the sentinel)

**Interfaces:**
- Consumes: V1's edits to the same template (the minimum task set and light mode). They anchor on `Must define at minimum:` and on § Rules, and this task touches neither.
- Produces: the emitted `[task_config]` block, whose sentinel line is `shell = "bash -O inherit_errexit -c -o errexit -o pipefail"`, and the floor string `mise >= 2026.7.15`. The block check greps both.
- Produces, for V10's Sync notes: "A target on mise adds the `[task_config]` block from blueprint's `templates/tooling.md` step 1 to its `mise.toml` and pins mise ≥ 2026.7.15 wherever tasks run, CI's setup action included. Nothing in the kit checks a target's `mise.toml`."
- Resolution of `#70/table/mise-mcp-row`: the issue's "mise template" does not exist in the kit, and no file is created for it. The note lands in step 1 of the blueprint template, the only place the kit specifies `mise.toml`.

- [ ] **Step 0: Re-fetch the sources and re-measure**

Run:
```bash
T=$(mktemp -d)
curl -sL https://raw.githubusercontent.com/jdx/mise/main/settings.toml | grep -A1 -F '[unix_default_inline_shell_args]'
curl -sL https://api.github.com/repos/jdx/mise/pulls/11354 | jq -r '.title, .merged_at'
curl -sL https://api.github.com/repos/jdx/mise/releases/tags/v2026.7.15 | jq -r '.tag_name, .published_at, .body' > "$T/rel.md"; head -2 "$T/rel.md"
grep -cF 'sets a project-scoped default shell for tasks, with task-local and template `shell` still taking precedence' "$T/rel.md"
mkdir -p "$T/with" "$T/without"
printf '[task_config]\nshell = "bash -O inherit_errexit -c -o errexit -o pipefail"\n\n[tasks.p]\nrun = "false | true; echo reached"\n' > "$T/with/mise.toml"
printf '[tasks.p]\nrun = "false | true; echo reached"\n' > "$T/without/mise.toml"
for d in with without; do (cd "$T/$d" && MISE_TRUSTED_CONFIG_PATHS="$PWD" mise run p >/dev/null 2>&1; echo "$d rc=$?"); done
bash -O inherit_errexit -c -o errexit -o pipefail 'x=$(false; echo leaked); echo "x=$x"'; echo "inherit rc=$?"
mise --version | head -1; bash --version | head -1
rm -rf "$T"
```
Expected: `[unix_default_inline_shell_args]` then `default = "sh -o errexit -c"`; then `feat(task): add config-scoped default shell` and `2026-07-27T03:04:44Z`; `v2026.7.15` and `2026-07-27T18:51:46Z`; then `1`; `with rc=1` and `without rc=0`; no `x=` line and `inherit rc=1`. The versions line should read mise 2026.8.16 or later and bash 5.2 or later. If the mise or bash version differs, write the versions that were actually measured into the note's "Measured" sentence in Step 3. If a result differs, stop and re-derive the note.

- [ ] **Step 1: Append the block check**

In `.claude/rules/cbk-conventions-reference.md`:

Old:
~~~~
echo "verification: kit sub-block complete"
~~~~
New:
~~~~
# mise inline tasks (context-builder-kit#70 item 5): blueprint's tooling template emits the [task_config] shell line
# verbatim (bash with errexit, pipefail and inherit_errexit) and the mise release that introduced the key.
{ grep -qF 'shell = "bash -O inherit_errexit -c -o errexit -o pipefail"' .claude/skills/blueprint/references/templates/tooling.md && grep -qF 'mise >= 2026.7.15' .claude/skills/blueprint/references/templates/tooling.md; } || { echo "blueprint templates/tooling.md lacks the mise [task_config] shell line or its version floor"; exit 1; }
echo "verification: kit sub-block complete"
~~~~

- [ ] **Step 2: Run it against the unfixed template**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2`
Expected (FAIL):
```
blueprint templates/tooling.md lacks the mise [task_config] shell line or its version floor
verification: block exited 1
```

- [ ] **Step 3: The change**

In `.claude/skills/blueprint/references/templates/tooling.md`:

Old:
~~~~
   - `mise.toml` — for projects using mise
~~~~
New:
~~~~
   - `mise.toml` — for projects using mise. mise runs an inline task under `sh -o errexit -c` unless told otherwise (the `unix_default_inline_shell_args` default, `https://github.com/jdx/mise/blob/main/settings.toml`, read 2026-09-30) — no `pipefail`, so `false | true` passes. The emitted file carries this block verbatim:

     ```toml
     [task_config]
     # bash, errexit kept inside command substitutions (inherit_errexit), pipefail on.
     # A task's own `shell` overrides this default, so no task sets one. Needs mise >= 2026.7.15.
     shell = "bash -O inherit_errexit -c -o errexit -o pipefail"
     ```

     `task_config.shell` "sets a project-scoped default shell for tasks, with task-local and template `shell` still taking precedence" (the v2026.7.15 release notes, jdx/mise#11354, `https://github.com/jdx/mise/releases/tag/v2026.7.15`, read 2026-09-30). A mise older than that release predates the key, so pin mise at or above it wherever tasks run, a CI setup action's own pin included. Measured 2026-09-30 on mise 2026.8.16 with bash 5.2: the inline task `false | true; echo reached` exits 0 without the block and fails with it, and `inherit_errexit` is what makes `x=$(false; echo leaked)` fail instead of quietly assigning `leaked`.
~~~~

- [ ] **Step 4: Run green, and run the emitted block as mise sees it**

Run:
```bash
bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"
T=$(mktemp -d); awk '/^     ```toml/{p=1; next} p && /^     ```/{exit} p' .claude/skills/blueprint/references/templates/tooling.md | sed 's/^     //' > "$T/mise.toml"
printf '\n[tasks.p]\nrun = "false | true; echo reached"\n' >> "$T/mise.toml"
(cd "$T" && MISE_TRUSTED_CONFIG_PATHS="$PWD" mise run p >/dev/null 2>&1; echo "emitted-block rc=$?"); rm -rf "$T"
```
Expected: `verification: kit sub-block complete`, `verification: done`, `exit=0`, then `emitted-block rc=1`. The block as written, comments included, makes a failing pipe fail the task. The always-loaded total is unchanged.

- [ ] **Step 5: Commit**

```bash
git add .claude/skills/blueprint/references/templates/tooling.md .claude/rules/cbk-conventions-reference.md
git commit -m "fix(hygiene): V8 — mise inline tasks run under bash with pipefail

mise runs an inline task under 'sh -o errexit -c' by default, which has no
pipefail, so a failing pipe inside a task passes. Blueprint's tooling
template now emits a [task_config] shell line (bash, errexit, pipefail,
inherit_errexit) with its floor, mise >= 2026.7.15, where
jdx/mise#11354 introduced the key. A task's own shell overrides it, so no
task sets one. Measured 2026-09-30 on mise 2026.8.16: 'false | true' exits
0 without the line and fails with it. There is no separate mise template:
the kit specifies mise.toml only in this step. A kit-sub-block check pins
the line and the floor.

Trace: #70/body/5, #70/table/mise-mcp-row (mise half), critic/4 (mise half)

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task V8.3: `.mcp.json.example` rebuilt; an MCP server is a dependency; one secret-handling story (#70/body/6a, #70/body/6b, #70/table/mise-mcp-row (MCP half), critic/4 (MCP half), review/claude-code/12, review/security/17, review/release/24, review/release/28; D52, D58; probe P5)

**Files:**
- Modify (whole file): `.mcp.json.example`
- Modify: `.claude/rules/cbk-conventions-reference.md` — § Dependency settle-window (a new MCP paragraph) and the kit sub-block of § Verification (checks appended at the sentinel)
- Modify: `.claude/rules/tooling.md` — § MCP configuration, the "Wire a server the project depends on" row. V3 owns this section's decision rule, and this task does not touch it.
- Modify: `.claude/skills/blueprint/references/blueprint-output-template.md` — the credential-model guidance and its example table

**Interfaces:**
- Consumes: V8.1's container-images paragraph, which sits directly above `**Inactive ecosystem stubs carry the floor too.**`, this task's anchor. Also consumes V3's decision-rule edit in `tooling.md`, and V3.4's `enabledMcpjsonServers` = `linear notion context7 time` together with its block check (`settings.json enabledMcpjsonServers names …, which … does not declare`). The rebuild keeps all four as `mcpServers` keys, so that check stays green.
- Consumes: the block's existing `mcpx` variable (`mcpx=""; [ -f .mcp.json.example ] && mcpx=.mcp.json.example`).
- Produces: the paragraph `**An MCP server is a dependency.**` in § Dependency settle-window, which `tooling.md`'s row cites.
- Produces: the block's `mcps` variable (the project's `.mcp.json`, else `mcpx`), which follows V3.4's `mcpf` choice without reusing its name, with three shape checks. The failure messages begin `<file>: a url entry with no type …`, `<file>: a stdio server not pinned …` and `<file>: a literal credential or <placeholder> …`.
- Produces: the server keys `linear`, `notion`, `context7` and `time`, with no `github` key. V6's runner allowlist (`context7`, `time`) matches this set.
- Produces, for V10: the README lines listed under **Handed to other clusters**, plus two Sync notes. First, "`.mcp.json` is committed with `${VAR}` references; a target's copy is hand-merged, and the kit sub-block now checks its shape (a typed url entry, pinned stdio servers, no literal credential)". Second, "the kit ships no GitHub MCP entry". Also a release-day check of the `time` pin's age.

- [ ] **Step 0a: Probe P5 — the live endpoints, the pinned `time` server, and Claude Code's reading of the file**

Run:
```bash
init='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"probe","version":"0"}}}'
for u in https://mcp.linear.app/mcp https://mcp.notion.com/mcp https://mcp.context7.com/mcp; do echo "$u $(curl -s -o /dev/null -w '%{http_code}' -X POST -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' --data "$init" "$u")"; done
curl -sL https://pypi.org/pypi/mcp-server-time/json | jq -r '.info.version, (.releases["2026.8.18"][0].upload_time)'
printf '%s\n' "$init" | timeout 120 uvx mcp-server-time@2026.8.18 2>/dev/null | head -c 64; echo
T=$(mktemp -d)
for p in "linear.app/docs/mcp|The Linear MCP server authenticates each session via OAuth" "raw.githubusercontent.com/upstash/context7/master/README.md|pass your API key via the \`Authorization: Bearer YOUR_API_KEY\` header" "code.claude.com/docs/en/mcp.md|is a configuration error, because Claude Code reads an entry with no \`type\` as a stdio server" "code.claude.com/docs/en/mcp.md|\`\${VAR}\`: expands to the value of environment variable \`VAR\`" "raw.githubusercontent.com/astral-sh/uv/main/docs/guides/tools.md|To run a tool at a specific version, use \`command@<version>\`"; do u="https://${p%%|*}"; q="${p#*|}"; curl -sL "$u" -o "$T/page"; echo "$(grep -cF -- "$q" "$T/page") ${p%%|*}"; done
rm -rf "$T"
```
Expected: `https://mcp.linear.app/mcp 401`, `https://mcp.notion.com/mcp 401` and `https://mcp.context7.com/mcp 200`. A 401 means the endpoint is live and wants OAuth; a 404 or a connection failure is a stop. Then the newest version (`2026.8.18` on 2026-09-30) and `2026-08-18T16:06:24`; the pin must be at least 7 days old on the commit day. If PyPI's newest release is newer than 2026.8.18 and was published at least 7 days before the commit day, pin that version instead, and write its version and its date in the three places the example names them: `args`, and the `time` `_comment`'s version and date. The next line begins `{"jsonrpc":"2.0","id":1,"result":{"protoco`. Then five lines each beginning with a count of at least `1`. Reword and re-date any quote that no longer matches.

- [ ] **Step 0b: Confirm V3.4's side of the handoff**

Run: `jq -r '.enabledMcpjsonServers | join(" ")' .claude/settings.json; grep -c 'enabledMcpjsonServers names' .claude/rules/cbk-conventions-reference.md`
Expected: `linear notion context7 time` and `1`. These are V3.4's part of `#70/body/6a`: V3 owns `settings.json`, dropped `github` per D58, and landed the check that every listed name is a key in `.mcp.json`, or in `.mcp.json.example` on the kit tree. If `github` is still listed, do not edit `settings.json`; stop and reconcile with V3. The rebuilt example has no `github` key, so V3's check would name it.

- [ ] **Step 1: Append the block checks**

In `.claude/rules/cbk-conventions-reference.md`:

Old:
~~~~
echo "verification: kit sub-block complete"
~~~~
New:
~~~~
# .mcp.json shape (context-builder-kit#70 item 6, D58), read from the project's .mcp.json, or from .mcp.json.example
# where there is none (the kit tree), the same choice as the enabledMcpjsonServers check above: every url entry names
# its type (Claude Code skips one without), every npx / uvx / bunx server runs an exact version (never @latest, never
# unpinned — § Dependency settle-window), and no env or header value is a <placeholder> or a literal token:
# credentials are ${VAR} references only.
mcps=.mcp.json; [ -f "$mcps" ] || mcps=$mcpx
if [ -n "$mcps" ]; then
  [ "$(jq '.mcpServers | length' "$mcps")" -ge 1 ] || { echo "$mcps: no mcpServers read — the checks below would pass vacuously"; exit 1; }
  bad=$(jq -r '.mcpServers | to_entries[] | select(.value.url != null and .value.type == null) | .key' "$mcps"); [ -z "$bad" ] || { echo "$mcps: a url entry with no type is skipped by Claude Code:" $bad; exit 1; }
  bad=$(jq -r '.mcpServers | to_entries[] | select(.value.command == "npx" or .value.command == "uvx" or .value.command == "bunx") | select(([.value.args[]? | select(startswith("-") | not)][0] // "") | test("(@|==)[0-9]+(\\.[0-9]+)+$") | not) | .key' "$mcps"); [ -z "$bad" ] || { echo "$mcps: a stdio server not pinned to an exact version:" $bad; exit 1; }
  bad=$(jq -r '.mcpServers | to_entries[] | select([(.value.env // {}), (.value.headers // {})][] | to_entries[] | .value | tostring | test("^<.*>$|ghp_|github_pat_|gho_|lin_api_|ctx7sk|sk-ant-")) | .key' "$mcps" | sort -u); [ -z "$bad" ] || { echo "$mcps: a literal credential or <placeholder> where a \${VAR} reference belongs:" $bad; exit 1; }
fi
echo "verification: kit sub-block complete"
~~~~

- [ ] **Step 2: Run them against the unfixed example**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2`
Expected (FAIL):
```
.mcp.json.example: a url entry with no type is skipped by Claude Code: notion context7
verification: block exited 1
```

- [ ] **Step 3: The change**

(a) Confirm the example is unchanged since the baseline, then replace it whole. Run `git diff --quiet 74edf84 -- .mcp.json.example; echo "unchanged=$?"`; expected `unchanged=0` (a `1` means another commit touched it, so stop and reconcile). Then write `.mcp.json.example` with exactly this content:

~~~~
{
  "_comment": "Starter MCP server config for the cascade kit. Copy it to .mcp.json and commit that file: it holds no secret. A server that needs a credential names it as a ${VAR} reference, which Claude Code expands from the environment it was launched in ('`${VAR}`: expands to the value of environment variable `VAR`' — https://code.claude.com/docs/en/mcp § Environment variable expansion in .mcp.json, read 2026-09-30), so export the variable in the shell (or a direnv / mise env) before starting claude, keep any .env file you source out of git, and name every variable in a committed .env.example (.claude/rules/tooling.md § MCP configuration). Every hosted server carries \"type\": \"http\" — an entry with a url and no type 'is a configuration error, because Claude Code reads an entry with no `type` as a stdio server' and is skipped (same page, read 2026-09-30). Every stdio server runs an exact version at least the settle window old, never @latest and never unpinned: it runs network-fetched code at every session start, outside every lockfile and every update bot, so it is bumped by hand with its settled age in the commit body (.claude/rules/cbk-conventions-reference.md § Dependency settle-window). A hosted server cannot be pinned; its vendor changes it. There is no github entry: the kit reaches GitHub through the gh CLI (.claude/rules/tooling.md § Planning backend), and scaffold falls back to manual steps where no GitHub MCP server is connected. Remove any server you don't use; the cascade skills fall back to manual / web-search paths when an expected MCP is absent. Wire linear when planning = linear, and notion when knowledge = notion (per docs/cbk/scaffold.md § Cascade metadata / .cascade/backends.toml).",
  "mcpServers": {
    "linear": {
      "_comment": "Required when planning backend = linear. Linear's hosted MCP server: 'The Linear MCP server authenticates each session via OAuth' in the browser (https://linear.app/docs/mcp, read 2026-09-30), so no key lives in this file. Cascade calls: get_issue, save_issue (with parentId for sub-issues; type label set at creation), list_issues, list_issue_labels, list_issue_statuses, create_issue_label, list_teams.",
      "type": "http",
      "url": "https://mcp.linear.app/mcp"
    },
    "notion": {
      "_comment": "Required when knowledge backend = notion. Notion's official MCP via its hosted endpoint (in-browser OAuth on first use). The server key MUST be 'notion' — the require-knowledge-backend-ok.sh ask-gate's matcher in .claude/settings.json targets mcp__notion__* tool names; a different key silently loses the write-gate enforcement. Every read/write is HITL-announced per .claude/rules/knowledge-backend.md. Remove this entry when knowledge = none.",
      "type": "http",
      "url": "https://mcp.notion.com/mcp"
    },
    "context7": {
      "_comment": "Used by framing and rough-in research phases for library / framework / SDK documentation lookups. Reduces stale-knowledge errors when the cascade picks dependencies. The cascade falls back to web search if context7 is unavailable, but library-API misses are a recurring failure mode without it. The hosted server answers without a key; for higher rate limits add \"headers\": { \"Authorization\": \"Bearer ${CONTEXT7_API_KEY}\" } (Context7's README: 'pass your API key via the `Authorization: Bearer YOUR_API_KEY` header', https://github.com/upstash/context7/blob/master/README.md, read 2026-09-30) — and add it only once the variable is exported: an empty bearer is refused as an invalid key (probed 2026-09-30).",
      "type": "http",
      "url": "https://mcp.context7.com/mcp"
    },
    "time": {
      "_comment": "Optional. Used by skills that need ISO-8601 conversions or timezone math (e.g. cbk-conventions ADR dates). The cascade can ask the user to confirm dates if absent. The reference time server is the Python package mcp-server-time, run through uv's uvx ('To run a tool at a specific version, use `command@<version>`' — https://github.com/astral-sh/uv/blob/main/docs/guides/tools.md, read 2026-09-30); 2026.8.18 was published to PyPI on 2026-08-18 (https://pypi.org/project/mcp-server-time/, read 2026-09-30).",
      "command": "uvx",
      "args": ["mcp-server-time@2026.8.18"]
    }
  }
}
~~~~

(b) In `.claude/rules/cbk-conventions-reference.md` § Dependency settle-window:

Old:
~~~~
**Inactive ecosystem stubs carry the floor too.**
~~~~
New:
~~~~
**An MCP server is a dependency.** A stdio server launched by `npx`, `uvx` or `bunx` runs network-fetched code at every session start, outside every lockfile and every update bot. It takes an exact version at least `<N>` days old — never `@latest`, never unpinned — bumped by hand, with its settled age in the commit body and the tracking mechanism this section names. A hosted server (`"type": "http"`) cannot be pinned: its vendor changes it, so it is wired from the vendor's own documented endpoint or not at all. Credentials in `.mcp.json` are `${VAR}` references, never literals. The kit's `.mcp.json.example` is written this way, and the verification block checks the shape of whichever of it and a committed `.mcp.json` the tree holds; `tooling.md` § MCP configuration points here.

**Inactive ecosystem stubs carry the floor too.**
~~~~

(c) In `.claude/rules/tooling.md` § MCP configuration. This file is always loaded; the row grows by 120 bytes.

Old:
~~~~
| Wire a server the project depends on | The committed `.mcp.json`, with credentials as **environment-variable references** (`${GITHUB_TOKEN}`), plus a committed `.env.example` naming every variable | The config is reviewable and shared; the secrets are not. The kit's `.mcp.json.example` is the starting shape |
~~~~
New:
~~~~
| Wire a server the project depends on | The committed `.mcp.json`, with credentials as **environment-variable references** (`${GITHUB_TOKEN}`), plus a committed `.env.example` naming every variable; a stdio server at an exact version past the settle window (`cbk-conventions-reference.md` § Dependency settle-window) | The config is reviewable and shared; the secrets are not. The kit's `.mcp.json.example` is the starting shape |
~~~~

(d) In `.claude/skills/blueprint/references/blueprint-output-template.md`, fix the credential guidance:

Old:
~~~~
- Where it lives (env var, secret store, gitignored config file)
~~~~
New:
~~~~
- Where it lives (env var, secret store — never a committed file; a committed `.mcp.json` names a credential only as a `${VAR}` reference)
~~~~

(e) and its example table:

Old:
~~~~
| Used by | `claude-code-action` in CI | Local GitHub MCP |
| Lives where | Repo secret + App install | `.mcp.json` (gitignored) |
~~~~
New:
~~~~
| Used by | `claude-code-action` in CI | The local `gh` CLI, and any MCP server that takes a token |
| Lives where | Repo secret + App install | An environment variable exported in the shell; the committed `.mcp.json` references it as `${VAR}` |
~~~~

`.claude/skills/framing/references/research-phase.md` ("Blueprint commits `.mcp.json`") and `.claude/skills/scaffold/references/github_only_profile.md` (scaffold does not commit it) already agree with the committed model and stay as they are.

- [ ] **Step 4: Run green, mutation-test the three checks, and let Claude Code read the example**

Run:
```bash
jq empty .mcp.json.example && echo json-ok
bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded: .claude/rules/tooling.md|always-loaded total|verification: (kit sub-block complete|done)'; echo "exit=${PIPESTATUS[0]}"
b=$(mktemp); cp .mcp.json.example "$b"
for m in '.mcpServers.time.args=["mcp-server-time"]' '.mcpServers.time.args=["mcp-server-time@latest"]' '.mcpServers.context7.headers={"Authorization":"Bearer ctx7sk-abc"}' '.mcpServers.x={"command":"npx","args":["-y","pkg@1.0.0"],"env":{"K":"<your-key>"}}' '.mcpServers.linear|=del(.type)'; do jq "$m" "$b" > .mcp.json.example; bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2 | head -1; done
cp "$b" .mcp.json.example; rm -f "$b"
T=$(mktemp -d); cp .mcp.json.example "$T/.mcp.json"; (cd "$T" && git init -q && timeout 240 claude mcp list 2>&1 | grep -F 'but no "type"'; echo "untyped-url-diagnostics=$?"); rm -rf "$T"
```
Expected: `json-ok`; `always-loaded: .claude/rules/tooling.md (<previous + 120> bytes)`, `always-loaded total:` 120 bytes above the pre-V8 record, `verification: kit sub-block complete`, `verification: done` and `exit=0`. At `74edf84`, `tooling.md` was 12416 bytes; after V3's merge-rule rewrite, record whatever the previous commit printed plus 120. Then the five mutations, in order:
```
.mcp.json.example: a stdio server not pinned to an exact version: time
.mcp.json.example: a stdio server not pinned to an exact version: time
.mcp.json.example: a literal credential or <placeholder> where a ${VAR} reference belongs: context7
.mcp.json.example: a literal credential or <placeholder> where a ${VAR} reference belongs: x
.mcp.json.example: a url entry with no type is skipped by Claude Code: linear
```
Last, `untyped-url-diagnostics=1`: no entry trips Claude Code's missing-type diagnostic. Probe P5 was run on Claude Code 2.1.285 on 2026-09-30: the three hosted entries and `time` were listed with no project-config warning, and a control entry without `type` printed `Skipped — MCP server "…" has a "url" but no "type"`. `claude mcp list` also prints the operator's own user-scope servers, which can carry keys, so filter its output and never paste it whole into the PR.

- [ ] **Step 5: Commit**

```bash
git add .mcp.json.example .claude/rules/cbk-conventions-reference.md .claude/rules/tooling.md .claude/skills/blueprint/references/blueprint-output-template.md
git commit -m "fix(hygiene): V8 — rebuild .mcp.json.example; an MCP server is a dependency

The example launched two npm packages that do not exist (server-linear,
server-time) and one that is deprecated (server-github). Its hosted entries
had no type, which Claude Code skips as a configuration error, and it
invited pasting literal PATs into a file tooling.md says to commit. Rebuilt
per D58: Linear, Notion and context7 as type http on their vendors' hosted
endpoints, with OAuth or an optional \${VAR} header; the time server as
uvx mcp-server-time@2026.8.18 (published 2026-08-18); no github entry,
since gh is the kit's GitHub interface; and a top comment that states the
committed-with-references model. § Dependency settle-window gains 'An MCP
server is a dependency', and tooling.md's row points at it (always-loaded
+120 bytes). Blueprint's credential table no longer says .mcp.json is
gitignored. Kit-sub-block checks read the example, or a target's committed
.mcp.json: every url entry typed, every npx/uvx/bunx server at an exact
version, no literal credential or placeholder.

Probe P5, 2026-09-30: linear and notion 401 (OAuth), context7 200;
mcp-server-time@2026.8.18 answers initialize over stdio; claude mcp list
(2.1.285) reports no untyped entry.

Trace: #70/body/6a, #70/body/6b, #70/table/mise-mcp-row (MCP half), critic/4 (MCP half), review/claude-code/12, review/security/17, review/release/24, review/release/28

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task V8.4: The `.gitignore` harness block — in the starter, in the kit, pinned by `git check-ignore` (#71/body/3, #71/decision/runtime-paths, #58/c5901493591/R7, review/release/62, the `!/.claude/hooks/lib/` negation from V2's `#60/c5892401033/gitignore-trap`; D52, D43)

**Files:**
- Modify: `.claude/skills/scaffold/references/github-starter-templates.md` — the opening sentence, and a new last section `## \`.gitignore\` — the harness block`
- Modify (whole file): `.gitignore`
- Modify: `.claude/rules/cbk-conventions-reference.md` — § .gitignore anchoring (the harness-transients bullet rewritten, and a negation bullet added), and the kit sub-block of § Verification (one check appended at the sentinel)
- Modify: `.claude/skills/scaffold/references/github_only_profile.md` — State 1 step 1, and the `.gitignore` overreach gotcha
- Modify: `.claude/skills/scaffold/references/bootstrap_checklist_template.md` — section 1's Repository line
- Modify: `.claude/skills/scaffold/references/test_cases.md` — one success criterion

**Interfaces:**
- Consumes: V2's `lib/resolve-path.sh`, the helper the negation keeps tracked (the check creates the path in its throwaway repo and never reads the real file), and V2's § Hook authoring, which cites `§ .gitignore anchoring` for the negation.
- Produces: the heading `` ## `.gitignore` — the harness block `` in `github-starter-templates.md`. V6's `run-arms-headless.py` docstring and V8.5's bootstrap bullet cite it, and the block check extracts its fence by that heading.
- Produces: the fence's seven entries, `/.claude/settings.local.json`, `/.claude/agent-memory-local/`, `/.claude/worktrees/`, `/.claude-pr/`, `/.claude/workflows/**/__pycache__/`, `/.claude/workflows/**/*.py[cod]` and `!/.claude/hooks/lib/`, with `/.claude/worktrees/` also the default worktree root for V6's runner. The kit's `.gitignore` carries them all.
- Produces: the bullet `**A negation keeps the hook helpers tracked.**` in § .gitignore anchoring, which V2's § Hook authoring cites.
- Produces, for V10's Sync notes: "Append the harness block from `github-starter-templates.md` § `.gitignore` — the harness block to your `.gitignore`, below every stack section, and state its pin assertions in the commit body. The kit's own `.gitignore` is not in the drop-in set."

- [ ] **Step 0a: Re-fetch the quoted pages**

Run:
```bash
T=$(mktemp -d)
curl -sL https://code.claude.com/docs/en/settings.md -o "$T/s"; grep -cF "If you created the file by hand and Claude Code hasn't written to it yet, add it to \`.gitignore\` yourself" "$T/s"
curl -sL https://code.claude.com/docs/en/worktrees.md -o "$T/w"; grep -cF "Add \`.claude/worktrees/\` to your \`.gitignore\` so worktree contents don't appear as untracked files in your main checkout" "$T/w"
curl -sL https://raw.githubusercontent.com/github/gitignore/main/Python.gitignore | grep -cx 'lib/'
curl -sL https://raw.githubusercontent.com/git/git/master/Documentation/gitignore.adoc | grep -cF 'the last matching pattern decides the outcome'
rm -rf "$T"
```
Expected: `1`, `1`, `1`, `1`. A miss is a stop: reword the sentence to the page's current text and re-date it.

- [ ] **Step 0b: Reconcile with V2 on § .gitignore anchoring**

Run: `awk '/^## \.gitignore anchoring/{p=1; next} p && /^## /{exit} p' .claude/rules/cbk-conventions-reference.md | grep -n 'hooks/lib'; echo "rc=$?"`
Expected: `rc=1`. V2 states the sourced-helper contract in § Hook authoring and cites this section, and the negation bullet lands here, in V8's section. If V2 has already put a `!/.claude/hooks/lib/` bullet in this section, keep V2's bullet and leave out the second bullet of Step 3(c)'s New text, so the trap is stated once. V2's bullet must then carry the literal `` `!/.claude/hooks/lib/` `` in backticks, which Step 1's section diff reads; if it does not, add those backticks to V2's bullet in this commit. Everything else in this task still lands.

- [ ] **Step 1: Append the block check**

In `.claude/rules/cbk-conventions-reference.md`:

Old:
~~~~
echo "verification: kit sub-block complete"
~~~~
New:
~~~~
# The .gitignore harness block (context-builder-kit#71, context-builder-kit#58 R7): extracted from github-starter-templates.md's fence and
# pinned with git check-ignore in a throwaway repo, appended behind a stack section's unanchored `lib/` — every entry
# matches its path and not a same-named path deeper in the tree, and the hook helpers stay visible. Global and system
# excludes are off, so the host's own ignore files cannot answer. The kit's .gitignore carries every entry (kit tree
# only; a target's is its bootstrap row), and § .gitignore anchoring names each one in backticks (the same list, stated
# twice — cbk-conventions.md § Multi-surface facts).
hb=$(awk '/^## `\.gitignore` — the harness block/{p=1; next} p && /^## /{exit} p' .claude/skills/scaffold/references/github-starter-templates.md | awk '/^```/{c = !c; next} c')
[ -n "$hb" ] || { echo "github-starter-templates.md lacks the harness-block section or its fence"; exit 1; }
hbt=$(mktemp -d); git -C "$hbt" init -q; printf 'lib/\n%s\n' "$hb" > "$hbt/.gitignore"
for p in .claude/settings.local.json .claude/agent-memory-local/r/M.md .claude/worktrees/e/x .claude-pr/x .claude/workflows/__pycache__/a.pyc .claude/workflows/finish-ab/__pycache__/b.pyc .claude/workflows/a.pyc .claude/workflows/finish-ab/c.pyo docs/.claude/settings.local.json docs/.claude/agent-memory-local/x pkg/.claude/worktrees/x sub/.claude-pr/x src/__pycache__/a.pyc src/app.pyc .claude/workflows/agent-cost.py .claude/hooks/lib/resolve-path.sh; do mkdir -p "$hbt/$(dirname "$p")"; : > "$hbt/$p"; rc=0; GIT_CONFIG_NOSYSTEM=1 git -C "$hbt" -c core.excludesFile=/dev/null check-ignore -q "$p" || rc=$?; case "$p" in docs/*|pkg/*|sub/*|src/*|*.py|*.sh) want=1;; *) want=0;; esac; [ "$rc" -eq "$want" ] || { echo "harness block: git check-ignore $p exited $rc, want $want (0 ignored, 1 visible)"; rm -rf "$hbt"; exit 1; }; done
rm -rf "$hbt"
[ -f docs/cbk/scaffold.md ] || while IFS= read -r l; do case "$l" in ''|'#'*) continue;; esac; grep -qxF -- "$l" .gitignore || { echo "the kit's .gitignore lacks the harness-block entry $l"; exit 1; }; done <<<"$hb"
ga=$(awk '/^## \.gitignore anchoring/{p=1; next} p && /^## /{exit} p' .claude/rules/cbk-conventions-reference.md)
while IFS= read -r l; do case "$l" in ''|'#'*) continue;; esac; grep -qF -- "\`$l\`" <<<"$ga" || { echo "cbk-conventions-reference.md § .gitignore anchoring does not name the harness-block entry $l (the fence restates its list)"; exit 1; }; done <<<"$hb"
echo "verification: kit sub-block complete"
~~~~

The check runs sixteen `git check-ignore` cases, eight must-match and eight must-stay-visible, in a `mktemp -d` repository, with the system config and `core.excludesFile` switched off. Otherwise a host whose global excludes already carry `**/.claude/settings.local.json` (Claude Code writes that line) would answer for the block. Its last line diffs the fence against § .gitignore anchoring, which restates the same list in prose: every entry must appear there in backticks, so neither copy can gain or drop an entry alone.

- [ ] **Step 2: Run it against the unfixed starter**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2`
Expected (FAIL):
```
github-starter-templates.md lacks the harness-block section or its fence
verification: block exited 1
```

- [ ] **Step 3: The change**

(a) In `.claude/skills/scaffold/references/github-starter-templates.md`, update the opening sentence, since the file now also holds a root `.gitignore` body:

Old:
~~~~
The `.github/` starter files scaffold pushes on the **github-issues** planning axis. `github_only_profile.md` § State 1 step 2 cites this file; `bootstrap_checklist_template.md` lists what landed.
~~~~
New:
~~~~
The starter files scaffold pushes on the **github-issues** planning axis: the `.github/` bodies, plus the root `.gitattributes` counter-line and the `.gitignore` harness block. `github_only_profile.md` § State 1 steps 1 and 2 cite this file; `bootstrap_checklist_template.md` lists what landed.
~~~~

(b) In the same file, append the section after the `.gitattributes` fence, at the end of the file:

Old:
~~~~
# Counter-line per audited lockfile the host would collapse (linguist's generated
# list is per-name; check it — the line is harmless where the name is not listed).
<lockfile> linguist-generated=false
```
~~~~
New:
~~~~
# Counter-line per audited lockfile the host would collapse (linguist's generated
# list is per-name; check it — the line is harmless where the name is not listed).
<lockfile> linguist-generated=false
```

## `.gitignore` — the harness block

Appended to the stack `.gitignore` scaffold writes, after every stack section — always, whether or not the brief gave a stack hint. The rules are `cbk-conventions-reference.md` § .gitignore anchoring: every entry is anchored, so a same-named path deeper in the tree stays visible (each line below matches its path and not, say, `docs/.claude/worktrees/x` or `src/__pycache__/a.pyc`), and the commit that adds the block states those pin assertions in its body. The last line re-includes the hook helpers, which an unanchored `lib/` in a stack section above it would otherwise hide from `git add`; it must stay below every stack section. The verification block pins this fence with `git check-ignore` in a throwaway repository.

```
### Claude Code harness — per-host state and staging copies, never source ###
# Personal settings. Claude Code keeps the file out of git only when it wrote it; a hand-made one needs this line.
/.claude/settings.local.json
# Reviewer memory in the `local` scope (the `project` scope, /.claude/agent-memory/, is committed).
/.claude/agent-memory-local/
# Worktrees Claude Code creates (--worktree, isolated subagents) and finish-ab's headless arms.
/.claude/worktrees/
# The review action's staging copy of the PR's .claude/, .mcp.json and CLAUDE.md; a local reproduction leaves it.
/.claude-pr/
# Bytecode from the kit's Python under .claude/workflows/ — a by-hand import or a test writes it.
/.claude/workflows/**/__pycache__/
/.claude/workflows/**/*.py[cod]
# The hook helpers stay tracked even under a stack section's unanchored `lib/`. Keep this line last.
!/.claude/hooks/lib/
```
~~~~

Run `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2` now. Expected: `the kit's .gitignore lacks the harness-block entry /.claude/settings.local.json`, then `verification: block exited 1`. The sixteen check-ignore cases pass, and only the containment half is still red.

(c) In `.claude/rules/cbk-conventions-reference.md` § .gitignore anchoring, rewrite the harness-transients bullet and add the negation bullet after it. The bare `#58` becomes `context-builder-kit#58` (D53).

Old:
~~~~
- **Harness transients are ignored by anchored path** — the agent's scratch and memory-local trees (`/.claude/agent-memory-local/`, the session scratchpad if it is ever placed in-tree) and a hosted review action's staging copy of the branch's tooling (`/.claude-pr/` — it carries a copy of the committed memory tree, which the Stop-tier fork detector prunes unconditionally and the ignore-driven prune covers once the entry exists; #58, 2026-09-07 comment), never by a bare name that would also hide a real directory.
~~~~
New:
~~~~
- **Harness transients are ignored by anchored path** — the personal settings file (`/.claude/settings.local.json`: Claude Code excludes it only when it wrote it — "If you created the file by hand and Claude Code hasn't written to it yet, add it to `.gitignore` yourself", `https://code.claude.com/docs/en/settings`, read 2026-09-30), the agent's scratch and memory-local trees (`/.claude/agent-memory-local/`, the session scratchpad if it is ever placed in-tree), the worktrees Claude Code creates for `--worktree` and isolated subagents, which finish-ab's headless arms also use (`/.claude/worktrees/` — "Add `.claude/worktrees/` to your `.gitignore` so worktree contents don't appear as untracked files in your main checkout", `https://code.claude.com/docs/en/worktrees`, read 2026-09-30), the kit's own Python bytecode (`/.claude/workflows/**/__pycache__/`, `/.claude/workflows/**/*.py[cod]` — a by-hand import or a test writes it), and a hosted review action's staging copy of the branch's tooling (`/.claude-pr/` — it carries a copy of the committed memory tree, which the Stop-tier fork detector prunes unconditionally and the ignore-driven prune covers once the entry exists; context-builder-kit#58, 2026-09-07 comment). Each goes in the committed `.gitignore`, never only a local `.git/info/exclude` a fresh clone lacks, and never by a bare name that would also hide a real directory. The starter block is `github-starter-templates.md` § `.gitignore` — the harness block, and the kit's own `.gitignore` carries it. The rest of Claude Code's per-host runtime state is deliberately not mirrored: that list is version-specific and grows, so a committed copy would age without anyone noticing (context-builder-kit#71).
- **A negation keeps the hook helpers tracked.** A stack template's unanchored `lib/` also matches `.claude/hooks/lib/` (GitHub's own `Python.gitignore` carries one — `https://github.com/github/gitignore/blob/main/Python.gitignore`, read 2026-09-30), and `git add` then skips the sourced helper without a word. The harness block ends with `!/.claude/hooks/lib/`, which re-includes the directory only while it stays below every stack section: within one file "the last matching pattern decides the outcome" (`https://github.com/git/git/blob/master/Documentation/gitignore.adoc`, read 2026-09-30). `git check-ignore -v --no-index .claude/hooks/lib/<helper>.sh` exits 1 when the helper is visible.
~~~~

(d) Confirm `.gitignore` is unchanged since the baseline, then replace it whole. Run `git diff --quiet 74edf84 -- .gitignore; echo "unchanged=$?"`; expected `unchanged=0`. The unanchored, unexplained `reference/` line is dropped (`review/release/62`, re-checked 2026-09-30: `git check-ignore -v --no-index docs/reference/a.md` answered `.gitignore:1:reference/`, and no `reference/` directory exists in the kit). The `.claude/agent-memory/` stanza stays byte-identical, because `pr-review.md` and the bootstrap checklist tell a target to delete that exact line. Write `.gitignore` with exactly this content:

~~~~
# Reviewer precedent memory stays session-local in THIS repo: pr-review.md
# ships the memory mechanism empty, so kit-session calibration must not ride
# along when a target project copies .claude/. Target projects default the
# other way — commit the directory — per pr-review.md § Reviewer precedent
# memory: when your Surface inventory row says `project`, DELETE this line
# (scaffold's rule-file disposition pass prompts the choice; nothing flips it
# for you).
.claude/agent-memory/

# The harness block, copied from the fence in
# .claude/skills/scaffold/references/github-starter-templates.md § `.gitignore` — the harness block
# (the verification block checks that every entry of the fence is here).
### Claude Code harness — per-host state and staging copies, never source ###
# Personal settings. Claude Code keeps the file out of git only when it wrote it; a hand-made one needs this line.
/.claude/settings.local.json
# Reviewer memory in the `local` scope (the `project` scope, /.claude/agent-memory/, is committed).
/.claude/agent-memory-local/
# Worktrees Claude Code creates (--worktree, isolated subagents) and finish-ab's headless arms.
/.claude/worktrees/
# The review action's staging copy of the PR's .claude/, .mcp.json and CLAUDE.md; a local reproduction leaves it.
/.claude-pr/
# Bytecode from the kit's Python under .claude/workflows/ — a by-hand import or a test writes it.
/.claude/workflows/**/__pycache__/
/.claude/workflows/**/*.py[cod]
# The hook helpers stay tracked even under a stack section's unanchored `lib/`. Keep this line last.
!/.claude/hooks/lib/
~~~~

(e) In `.claude/skills/scaffold/references/github_only_profile.md` State 1 step 1:

Old:
~~~~
add a `.gitignore` for the one stack hint the brief gives, **anchored** per `cbk-conventions-reference.md` § .gitignore anchoring (or skip if no signal), and
~~~~
New:
~~~~
add a `.gitignore` for the one stack hint the brief gives, **anchored** per `cbk-conventions-reference.md` § .gitignore anchoring (the stack section skipped if no signal), with the harness block from `references/github-starter-templates.md` § `.gitignore` — the harness block appended after it either way, and
~~~~

(f) and its gotcha:

Old:
~~~~
generate that anchored (`/target/`, not `target/` — `cbk-conventions-reference.md` § .gitignore anchoring), note that the user can extend later.
~~~~
New:
~~~~
generate that anchored (`/target/`, not `target/` — `cbk-conventions-reference.md` § .gitignore anchoring), note that the user can extend later. The harness block is not a language section: it is appended every time, below the stack section, so its closing `!/.claude/hooks/lib/` still re-includes the hook helpers.
~~~~

(g) In `.claude/skills/scaffold/references/bootstrap_checklist_template.md` section 1:

Old:
~~~~
- **Repository**: <repo URL> — created with README, a `.gitignore` anchored per `cbk-conventions-reference.md` § .gitignore anchoring, and the licence the operator confirmed
~~~~
New:
~~~~
- **Repository**: <repo URL> — created with README, a `.gitignore` anchored per `cbk-conventions-reference.md` § .gitignore anchoring and ending with the harness block (`github-starter-templates.md` § `.gitignore` — the harness block), and the licence the operator confirmed
~~~~

(h) In `.claude/skills/scaffold/references/test_cases.md`:

Old:
~~~~
- The bootstrap checklist's rule-file disposition pass settled the reviewer agent-memory choice, wrote it to the "Reviewer agent-memory" row of § Surface inventory, and — for `project` — deleted the kit's `.claude/agent-memory/` gitignore line.
~~~~
New:
~~~~
- The bootstrap checklist's rule-file disposition pass settled the reviewer agent-memory choice, wrote it to the "Reviewer agent-memory" row of § Surface inventory, and — for `project` — deleted the kit's `.claude/agent-memory/` gitignore line.
- The committed `.gitignore` ends with the harness block from `github-starter-templates.md`, below the stack section, and the commit that added it states the block's pin assertions in its body.
~~~~

- [ ] **Step 4: Run green, prove the check-ignore half and the section diff can fail, and confirm nothing tracked became ignored**

Run:
```bash
bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"
F=.claude/skills/scaffold/references/github-starter-templates.md; b=$(mktemp); cp "$F" "$b"
sed -i 's|^/.claude/worktrees/$|worktrees/|' "$F"; bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2 | head -1; cp "$b" "$F"
sed -i '/^!\/.claude\/hooks\/lib\/$/d' "$F"; bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2 | head -1; cp "$b" "$F"; rm -f "$b"
R=.claude/rules/cbk-conventions-reference.md; b=$(mktemp); cp "$R" "$b"
sed -i 's|(`/.claude-pr/` — it carries|(the review staging copy — it carries|' "$R"; bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2 | head -1; cp "$b" "$R"; rm -f "$b"
git ls-files -ci --exclude-standard; echo "tracked-and-ignored=$?"
git check-ignore -v --no-index docs/reference/a.md; echo "reference rc=$?"
```
Expected: `verification: kit sub-block complete`, `verification: done` and `exit=0`. Then:
```
harness block: git check-ignore pkg/.claude/worktrees/x exited 0, want 1 (0 ignored, 1 visible)
harness block: git check-ignore .claude/hooks/lib/resolve-path.sh exited 0, want 1 (0 ignored, 1 visible)
cbk-conventions-reference.md § .gitignore anchoring does not name the harness-block entry /.claude-pr/ (the fence restates its list)
```
Then no tracked file listed, `tracked-and-ignored=0`, and `reference rc=1`. The always-loaded total is unchanged.

- [ ] **Step 5: Commit**

The body carries the pin assertions that § .gitignore anchoring requires of a `.gitignore`-changing commit.

```bash
git add .claude/skills/scaffold/references/github-starter-templates.md .gitignore .claude/rules/cbk-conventions-reference.md .claude/skills/scaffold/references/github_only_profile.md .claude/skills/scaffold/references/bootstrap_checklist_template.md .claude/skills/scaffold/references/test_cases.md
git commit -m "fix(hygiene): V8 — the .gitignore harness block, anchored and pinned

Harvest 4's spec promised an anchored /.claude-pr/ in the starter's
.gitignore, but the starter had no .gitignore section. It gains one:
the harness block, appended below every stack section, carrying
/.claude/settings.local.json (Claude Code excludes it only when it wrote
it), /.claude/agent-memory-local/, /.claude/worktrees/, /.claude-pr/, the
kit's Python bytecode under /.claude/workflows/, and a closing negation
line that re-includes /.claude/hooks/lib/, so a stack template's
unanchored lib/ cannot hide the hook helper. § .gitignore anchoring
names each entry, says they go in the committed .gitignore (never only
.git/info/exclude), and says why the rest
of Claude Code's per-host runtime state is not mirrored. The kit's
.gitignore carries the block, and its unanchored, unexplained reference/
line is gone. Scaffold's repository step, its gotcha, the bootstrap
Repository line and a test case cite the block.

Pin assertions (git check-ignore, a throwaway repo, lib/ above the block,
global excludes off). Ignored: .claude/settings.local.json,
.claude/agent-memory-local/r/M.md, .claude/worktrees/e/x, .claude-pr/x,
.claude/workflows/__pycache__/a.pyc,
.claude/workflows/finish-ab/__pycache__/b.pyc, .claude/workflows/a.pyc,
.claude/workflows/finish-ab/c.pyo. Visible: docs/.claude/settings.local.json,
docs/.claude/agent-memory-local/x, pkg/.claude/worktrees/x, sub/.claude-pr/x,
src/__pycache__/a.pyc, src/app.pyc, .claude/workflows/agent-cost.py,
.claude/hooks/lib/resolve-path.sh. After: docs/reference/a.md is visible.
The kit sub-block runs these on every run, and checks that
§ .gitignore anchoring names every entry of the fence.

Trace: #71/body/3, #71/decision/runtime-paths, #58/c5901493591/R7, review/release/62; the negation half of #60/c5892401033/gitignore-trap

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task V8.5: Kit-owned code stays out of a target's formatter; the advisory exemplars register in exec form with all three wiring edits (#71/body/1 (floor and checklist half), #71/body/2, #71/decision/other-formatters, #71/table/bootstrap-checklist, critic/5, #58/c5901493591/R11 (exemplar half); the exemplar half of review/claude-code/10's exec form; D52, D57)

**Files:**
- Modify (whole file): `.claude/hooks/format-on-edit.sh`
- Modify: `.claude/hooks/analyze-on-edit.sh` — the `Register:` stanza
- Modify: `.claude/skills/scaffold/references/bootstrap_checklist_template.md` — section 4's one-time choices
- Modify: `.claude/skills/scaffold/SKILL.md` — the bootstrap-checklist paragraph's restated list
- Modify: `.claude/skills/scaffold/references/test_cases.md` — one success criterion, after V8.4's
- Modify: `.claude/rules/cbk-conventions-reference.md` — the kit sub-block of § Verification (one check appended at the sentinel)

**Interfaces:**
- Consumes: V8.4's harness-block heading, which the bootstrap bullet cites, and V8.4's test-case line, this task's anchor.
- Consumes: V2's § Hook authoring sentence on the three wiring edits (R11's home, V2's region), and V3's exec-form registrations in `settings.json` with the registry check that accepts `"args"`. The exemplars stay unregistered on the kit tree, and the existing check (`advisory exemplar … is registered`) keeps asserting that.
- Consumes: V2's `hook-contract-fixture.sh`, which must stay green. `input="$(cat)"` stays the first statement after `set -uo pipefail`, and no new pipeline decides on an early-exiting reader.
- Produces: `format-on-edit.sh`'s floor pattern `.claude/workflows/*|*/.claude/workflows/*` and its dated measurement rows (ruff 0.16.9, prettier 3.9.9, biome 2.5.14, 2026-09-30); the header lines `Path:` and `Depends:`; and in both exemplars, the stanza line `"args": [] } ] }` followed by the four-line three-edits note.
- Produces: the bootstrap bullet `**Formatter and linter scope**`, which cites `cbk-conventions-reference.md` § Syncing the kit. V10 lands that section's clause from the text under **Handed to other clusters**.

- [ ] **Step 0: Re-fetch ruff's rule and re-measure the three formatters**

Run:
```bash
curl -sL https://raw.githubusercontent.com/astral-sh/ruff/main/docs/configuration.md | grep -cF 'Files that are passed to `ruff` directly are always analyzed'
T=$(mktemp -d); mkdir -p "$T/r/.claude/workflows" "$T/p/.claude/workflows" "$T/b/.claude/workflows"
(cd "$T/r" && git init -q && printf 'x=( 1,2 )\n' > .claude/workflows/a.py && printf '[tool.ruff]\nextend-exclude = [".claude/workflows"]\n' > pyproject.toml && uvx ruff@0.16.9 format .claude/workflows/a.py >/dev/null 2>&1; echo "ruff plain: $(cat .claude/workflows/a.py)"; printf 'x=( 1,2 )\n' > .claude/workflows/a.py; uvx ruff@0.16.9 format --force-exclude .claude/workflows/a.py >/dev/null 2>&1; echo "ruff force rc=$? : $(cat .claude/workflows/a.py)")
(cd "$T/p" && git init -q && printf 'const x = {a:1}\n' > .claude/workflows/a.js && printf '.claude/workflows/\n' > .prettierignore && npx -y prettier@3.9.9 --write .claude/workflows/a.js >/dev/null 2>&1; echo "prettier rc=$? : $(cat .claude/workflows/a.js)")
(cd "$T/b" && git init -q && printf 'const x = {a:1}\n' > .claude/workflows/a.js && printf '{"files":{"includes":["**","!.claude/workflows/**"]}}\n' > biome.json && npx -y @biomejs/biome@2.5.14 format --write .claude/workflows/a.js >/dev/null 2>&1; echo "biome rc=$?"; npx -y @biomejs/biome@2.5.14 format --write --no-errors-on-unmatched .claude/workflows/a.js >/dev/null 2>&1; echo "biome no-errors rc=$? : $(cat .claude/workflows/a.js)")
rm -rf "$T"
```
Expected: `1`, then:
```
ruff plain: x = (1, 2)
ruff force rc=0 : x=( 1,2 )
prettier rc=0 : const x = {a:1}
biome rc=1
biome no-errors rc=0 : const x = {a:1}
```
If a result differs, correct that formatter's row in the new `format-on-edit.sh` before writing it, and date it with the day it was measured. The rows are dated observations, not standing rules.

- [ ] **Step 1: Append the block check**

In `.claude/rules/cbk-conventions-reference.md`:

Old:
~~~~
echo "verification: kit sub-block complete"
~~~~
New:
~~~~
# Kit-owned code stays out of a target's formatter (context-builder-kit#71): format-on-edit.sh's floor skips
# .claude/workflows/ in the checkout and in a worktree's copy and its arms name the forcing flag; both advisory
# exemplars register in exec form ("args": []) and name all three wiring edits (context-builder-kit#58 R11); the
# bootstrap checklist carries the one-time formatter-scope choice.
{ grep -qF '.claude/workflows/*|*/.claude/workflows/*' .claude/hooks/format-on-edit.sh && grep -q -- '--force-exclude' .claude/hooks/format-on-edit.sh; } || { echo "format-on-edit.sh's floor does not skip .claude/workflows/, or its arms do not name the forcing flag"; exit 1; }
for h in format-on-edit.sh analyze-on-edit.sh; do reg=$(awk '/^# Register:/{p=1} p && !/^#/{exit} p' .claude/hooks/$h); { grep -qF '"args": []' <<<"$reg" && grep -q 'ADVISORY_WIRED' <<<"$reg" && grep -q 'two-views paragraph' <<<"$reg"; } || { echo "$h: the Register: stanza lacks exec form or the three-edit wiring note"; exit 1; }; done
grep -q 'Formatter and linter scope' .claude/skills/scaffold/references/bootstrap_checklist_template.md || { echo "the bootstrap checklist lacks the formatter-scope one-time choice"; exit 1; }
echo "verification: kit sub-block complete"
~~~~

- [ ] **Step 2: Run it against the unfixed exemplars**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2`
Expected (FAIL):
```
format-on-edit.sh's floor does not skip .claude/workflows/, or its arms do not name the forcing flag
verification: block exited 1
```

- [ ] **Step 3: The change**

(a) Confirm `format-on-edit.sh` is unchanged since the baseline, then replace it whole. Run `git diff --quiet 74edf84 -- .claude/hooks/format-on-edit.sh; echo "unchanged=$?"`; expected `unchanged=0`. The file keeps its mode, `-rwxrwxr-x`, because the write goes over the existing file. The new content brings the header up to § Hook authoring's full shape (`Blocked:`, `Allowed:`, `Path:`, `Tier:`, `Depends:`). It moves the stanza to exec form and adds R11's three-edits note, makes the skip list a floor that names `.claude/workflows/` in the checkout and in a worktree's copy, and gives each arm its forcing flag with the dated measurements. Write `.claude/hooks/format-on-edit.sh` with exactly this content:

~~~~
#!/usr/bin/env bash
# PostToolUse hook (Edit|Write|MultiEdit matcher) — EXEMPLAR: a project copies this hook,
# wires its own formatters into the case arms below, and registers it with the `Register:`
# stanza in this header (never as a top-level settings.json key). The load-bearing part is
# the exit-0 advisory contract, not the formatter choice: this hook auto-formats a file after
# Claude Code edits it and NEVER blocks the tool call, whatever formatter you drop in.
#
# Catches drift at Claude-edit-time — a different layer from a pre-commit hook (which catches
# developer-commit-time).
#
# An edit-time hook hands the formatter the edited file's path explicitly, and a formatter
# may format an explicit path whatever its own exclude list says — for ruff, "Files that are
# passed to `ruff` directly are always analyzed", unless force-exclude is on
# (https://github.com/astral-sh/ruff/blob/main/docs/configuration.md § Python file
# discovery, read 2026-09-30). So each arm passes its formatter's forcing flag, and the floor
# below keeps the trees no formatter may touch out, whatever any config says.
#
# Blocked:  nothing — advisory-only contract: exit 0 ALWAYS. A formatter failure surfaces on
#           stderr as a non-fatal note; it never blocks the tool call.
# Allowed:  everything.
# Path:     registered (once wired) as ${CLAUDE_PROJECT_DIR}/.claude/hooks/format-on-edit.sh.
# Tier:     ADVISORY (see the registry comment in .claude/settings.json).
# Depends:  jq (the payload fields) and the project's formatters once the arms are wired —
#           absent, the hook skips: exit 0 with a stderr note; the check task is the backstop.
# Register: copy this object into hooks.PostToolUse in .claude/settings.json once the case
#           arms are wired — never as a top-level key (cbk-conventions-reference.md § Hook
#           authoring: a hook-shaped object outside `hooks` voids the whole settings file):
#           { "matcher": "Edit|Write|MultiEdit",
#             "hooks": [ { "type": "command",
#                          "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/format-on-edit.sh",
#                          "args": [] } ] }
#           Wiring is three edits, not one: the stanza, this hook's name in the project
#           sub-block's ADVISORY_WIRED, and its name in cbk-conventions.md § Mutation
#           discipline's two-views paragraph. The verification block reads all three, so a
#           registration alone turns it red.

set -uo pipefail

# Drain stdin before any early exit, or a piping caller's SIGPIPE masks this hook's own
# exit code (cbk-conventions-reference.md § Hook authoring › The stdin / exit contract).
input="$(cat)"
# Note: deliberately NOT using `set -e` — see the advisory contract above.

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"

command -v jq &>/dev/null || { echo "format-on-edit: jq not installed; skipping (advisory)." >&2; exit 0; }

tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty')"
file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"

case "$tool_name" in
  Edit|Write|MultiEdit) ;;
  *) exit 0 ;;
esac

[[ -z "$file_path" || ! -f "$file_path" ]] && exit 0

rel="${file_path#"$PROJECT_DIR/"}"

# The floor: trees no formatter may touch, whatever a config says. Which files a formatter
# formats is that formatter's own config, held for an explicit path by its forcing flag;
# this list sits under it and is not the exclude list. `.claude/workflows/` is the kit's
# code, kept byte-identical to its source (cbk-conventions-reference.md § Syncing the kit),
# in this checkout and in a worktree's copy of it (a path outside PROJECT_DIR keeps its
# absolute form, hence the second pattern).
case "$rel" in
  .venv/*|node_modules/*|dist/*|build/*|vendor/*|.claude/workflows/*|*/.claude/workflows/*) exit 0 ;;
esac

# Wire one arm per file type your project formats. Each arm runs the formatter with the flag
# that makes the project's own excludes hold for a path handed over explicitly, and CAPTURES
# stderr, surfacing it non-fatally so the operator sees the real diagnostic. Measured
# 2026-09-30 on an explicitly passed path the formatter's own config excludes (re-measure
# after upgrading a formatter):
#   ruff 0.16.9     formats it unless --force-exclude (or force-exclude = true); with it,
#                   exit 0 and the file untouched.
#   prettier 3.9.9  honours .prettierignore for it: exit 0, the file untouched.
#   biome 2.5.14    honours a files.includes negation for it, but exits 1 ("These paths
#                   were provided but ignored") unless --no-errors-on-unmatched.
# Any other formatter: check how it treats an explicitly passed excluded path before wiring
# its arm. Example shapes (uncomment and fill in your commands):
#
#   *.py)
#     cd "$PROJECT_DIR" || exit 0
#     # ruff: ruff format --force-exclude
#     if ! out="$(YOUR_PYTHON_FORMATTER YOUR_FORCE_EXCLUDE_FLAG "$file_path" 2>&1)"; then
#       echo "format-on-edit: python formatter failed on $rel (non-fatal):" >&2
#       printf '%s\n' "$out" >&2
#     fi
#     ;;
#   *.ts|*.tsx|*.js|*.jsx|*.json)
#     cd "$PROJECT_DIR" || exit 0
#     # prettier: prettier --write (no flag needed) · biome: biome format --write --no-errors-on-unmatched
#     if ! out="$(YOUR_JS_FORMATTER YOUR_FORCE_EXCLUDE_FLAG "$file_path" 2>&1)"; then
#       echo "format-on-edit: js/ts formatter failed on $rel (non-fatal):" >&2
#       printf '%s\n' "$out" >&2
#     fi
#     ;;
case "$file_path" in
  *) : ;;  # no formatter configured yet — no-op; add arms above
esac

exit 0
~~~~

(b) In `.claude/hooks/analyze-on-edit.sh`, the stanza and the same note. The analyzer only reports, so its skip list stays as it is: it cannot rewrite kit code.

Old:
~~~~
#           { "matcher": "Edit|Write|MultiEdit",
#             "hooks": [ { "type": "command",
#                          "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/analyze-on-edit.sh" } ] }
~~~~
New:
~~~~
#           { "matcher": "Edit|Write|MultiEdit",
#             "hooks": [ { "type": "command",
#                          "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/analyze-on-edit.sh",
#                          "args": [] } ] }
#           Wiring is three edits, not one: the stanza, this hook's name in the project
#           sub-block's ADVISORY_WIRED, and its name in cbk-conventions.md § Mutation
#           discipline's two-views paragraph. The verification block reads all three, so a
#           registration alone turns it red.
~~~~

(c) In `.claude/skills/scaffold/references/bootstrap_checklist_template.md` section 4, add the one-time choice after the licence:

Old:
~~~~
- **Licence**: <SPDX id | none yet — all rights reserved>. Lives in the repo's `LICENSE` file and README § License (scaffold seeds both; the Repository line above names the choice) — it is not a row of `docs/cbk/scaffold.md`'s Cascade metadata table.
~~~~
New:
~~~~
- **Licence**: <SPDX id | none yet — all rights reserved>. Lives in the repo's `LICENSE` file and README § License (scaffold seeds both; the Repository line above names the choice) — it is not a row of `docs/cbk/scaffold.md`'s Cascade metadata table.
- **Formatter and linter scope**: `.claude/workflows/**` is the kit's code, byte-identical to its source, so every repo-wide formatter and linter excludes it, and the exclusion is forced for a path handed over explicitly (ruff: `extend-exclude` plus `force-exclude = true`; the rule is `cbk-conventions-reference.md` § Syncing the kit, and `format-on-edit.sh`'s floor already skips the tree). The committed `.gitignore` ends with the harness block (`github-starter-templates.md` § `.gitignore` — the harness block). Decision: <the config files that exclude `.claude/workflows/**`>.
~~~~

(d) In `.claude/skills/scaffold/SKILL.md`, stop restating the list, which had already missed the orchestration posture:

Old:
~~~~
plus the one-time choices — reviewer memory scope, licence).
~~~~
New:
~~~~
plus the one-time choices the template lists).
~~~~

(e) In `.claude/skills/scaffold/references/test_cases.md`:

Old:
~~~~
- The committed `.gitignore` ends with the harness block from `github-starter-templates.md`, below the stack section, and the commit that added it states the block's pin assertions in its body.
~~~~
New:
~~~~
- The committed `.gitignore` ends with the harness block from `github-starter-templates.md`, below the stack section, and the commit that added it states the block's pin assertions in its body.
- The disposition pass's one-time choices record which config files exclude `.claude/workflows/**` from the repo-wide formatters and linters, with the exclusion forced for explicit paths.
~~~~

- [ ] **Step 4: `bash -n`, a behavioural probe of the floor, the hook fixture, and the runner**

Run:
```bash
bash -n .claude/hooks/format-on-edit.sh && bash -n .claude/hooks/analyze-on-edit.sh && echo bash-n-ok
T=$(mktemp -d); mkdir -p "$T/p/.claude/workflows" "$T/p/src" "$T/wt/.claude/workflows"; : > "$T/p/.claude/workflows/a.py"; : > "$T/p/src/b.py"; : > "$T/wt/.claude/workflows/c.py"
sed 's/^  \*) : ;;  # no formatter configured yet.*/  *.py) echo "FORMATTED $rel" ;;/' .claude/hooks/format-on-edit.sh > "$T/h.sh"
for f in "$T/p/.claude/workflows/a.py" "$T/p/src/b.py" "$T/wt/.claude/workflows/c.py"; do printf '{"tool_name":"Edit","tool_input":{"file_path":"%s"}}' "$f" | CLAUDE_PROJECT_DIR="$T/p" bash "$T/h.sh"; echo "rc=$? ${f#"$T"/}"; done; rm -rf "$T"
bash .claude/workflows/tests/hook-contract-fixture.sh >/dev/null && echo hook-contract-ok
bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"
```
Expected: `bash-n-ok`; then `rc=0 p/.claude/workflows/a.py`, `FORMATTED src/b.py`, `rc=0 p/src/b.py` and `rc=0 wt/.claude/workflows/c.py`. A stub arm that formats every `*.py` never reaches kit code, in the checkout or in a worktree's copy. Then `hook-contract-ok`, `verification: kit sub-block complete`, `verification: done` and `exit=0`. The probe is a throwaway: the shipped arms stay commented. If V2 has added behavioural fixtures that read every hook (`hook-guards-fixture.sh`, `hook-payloads-fixture.sh`), the runner runs them, and they are green. The always-loaded total is unchanged.

- [ ] **Step 5: Commit**

```bash
git add .claude/hooks/format-on-edit.sh .claude/hooks/analyze-on-edit.sh .claude/skills/scaffold/references/bootstrap_checklist_template.md .claude/skills/scaffold/SKILL.md .claude/skills/scaffold/references/test_cases.md .claude/rules/cbk-conventions-reference.md
git commit -m "fix(hygiene): V8 — keep kit code out of a target's formatter; exemplars in exec form

An edit-time formatter is handed an explicit path, and ruff formats an
explicit path whatever its excludes say unless force-exclude is on. A
target's formatter hook rewrote .claude/workflows/agent-cost.py that way.
format-on-edit.sh's skip list becomes a floor that names .claude/workflows/,
in the checkout and in a worktree's copy, so the kit's code is safe
whatever a formatter's config says. Its arms name the forcing flag, with
dated measurements (2026-09-30: ruff 0.16.9 needs --force-exclude;
prettier 3.9.9 honours .prettierignore; biome 2.5.14 honours a
files.includes negation but exits 1 without --no-errors-on-unmatched). Its
header reaches the full shape (Path, Depends). Both advisory exemplars'
Register: stanzas move to exec form (\"args\": []) and say wiring is three
edits: the stanza, ADVISORY_WIRED, and the two-views paragraph. The
bootstrap checklist gains the formatter-scope one-time choice, and
scaffold/SKILL.md stops restating that list. The clause in § Syncing the
kit is V10's, handed over with its text.

Trace: #71/body/1 (floor and checklist), #71/body/2, #71/decision/other-formatters, #71/table/bootstrap-checklist, critic/5, #58/c5901493591/R11 (exemplar headers), review/claude-code/10 (exemplar stanzas)

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

## Coverage

Every id in the V8 pack, with the task that lands it. "Handed" means the named cluster owns the file the remaining part lands in.

| Id | Kind | Lands in | Note |
|---|---|---|---|
| `#70/body/4` | item | V8.1 | All three surfaces (§ Dependency settle-window, blueprint 6b, the starter's `dependabot.yml` paragraph), each naming the other two |
| `#70/body/4-stubs` | item | V8.1 | `docker` and `docker-compose` stubs in the starter and in `.github/dependabot.yml.example`. No `devcontainers` stub: it bumps Features, which is project-specific |
| `#70/body/5` | item | V8.2 | The `[task_config]` block, its reasons and the `mise >= 2026.7.15` floor, in blueprint's step 1 |
| `#70/body/6a` | item | V8.3; the `settings.json` part lands in V3.4 | The example rebuilt per D58, so there are no dead npm names to pin; `time` pinned through `uvx`. V3.4 drops `github` from `enabledMcpjsonServers`, rewords its comment, and checks that every listed name is declared; V8.3 keeps the four keys |
| `#70/body/6b` | item | V8.3 | `**An MCP server is a dependency.**` in § Dependency settle-window; `tooling.md`'s row points at it |
| `#70/table/mise-mcp-row` | item | V8.2 (mise), V8.3 (MCP) | No mise template file is created; step 1 of blueprint's `templates/tooling.md` is the kit's only `mise.toml` specification |
| `#71/body/1` | item | V8.5 (floor, checklist); handed to V10 (§ Syncing the kit clause) | V10 lands the clause text given below |
| `#71/body/2` | item | V8.5 | The floor, the forcing-flag arms, the `--force-exclude` example with its citation |
| `#71/body/3` | item | V8.4 | § .gitignore anchoring's bullet: worktrees, bytecode, `settings.local.json`, the info/exclude clause, the starter pointer. The block diffs the starter fence against this section (the pack's hazard (c): one list stated twice) |
| `#71/table/bootstrap-checklist` | item | V8.5 (one-time choice); V8.4 (Repository line) | `scaffold/SKILL.md`'s restated list replaced by a pointer; a test case each |
| `#71/decision/other-formatters` | item | V8.5 | Tool-neutral rule; ruff, prettier and biome rows measured and dated 2026-09-30; everything else is "check before wiring" |
| `#71/decision/runtime-paths` | item | V8.4 | D52 applied: only the anchored harness entries; the bullet says why the rest of the runtime state is not mirrored |
| `#58/c5901493591/R7` | item | V8.4 | `## \`.gitignore\` — the harness block`, pin-asserted in the commit body and in the block |
| `#58/c5901493591/R11` | handedIn (home V2) | V8.5 (both exemplars' `Register:` headers); § Hook authoring's sentence is V2's | The exemplar wording states the three edits the block reads |
| `critic/3` | critic | V8.1 | The named-stage remedy on all three surfaces and in both examples' stub comment |
| `critic/4` | critic | V8.2 (template pin); V8.3 (`.mcp.json` shape checks) | The kit has no `mise.toml`, so the mise half pins the template; the MCP half checks the example, or a target's committed `.mcp.json` |
| `critic/5` | critic | V8.5 | `.claude/workflows/*` and `*/.claude/workflows/*` in the floor |
| `review/claude-code/12` | review (verified) | V8.3 | Hosted entries typed; context7's real endpoint; checked by the block |
| `review/security/17` | review (verified) | V8.3; README step 3 handed to V10 | Credentials are `${VAR}` references only; blueprint's table fixed; the block refuses literal token shapes and `<placeholders>` |
| `review/release/24` | review (verified) | V8.3 | Dead and deprecated npm names replaced; probe P5 recorded |
| `review/release/28` | review (verified) | V8.3; README handed to V10 | One story: committed `.mcp.json`, `${VAR}` references, variables exported before launch, `.env.example` named |
| `review/release/62` | review (unverified; holds) | V8.4 | `reference/` removed; re-checked 2026-09-30 (evidence in V8.4 Step 3(d)) |
| `review/portability/66` | review (unverified; holds) | V8.1 | The trace row's cluster column says V9, but `.github/dependabot.yml.example` is V8's file; V8.1 lands it, and V9 has nothing to do for it |

Also landed, from outside the pack: the `!/.claude/hooks/lib/` negation line and its bullet in § .gitignore anchoring, from V2's `#60/c5892401033/gitignore-trap` (the ownership map gives V8 § .gitignore anchoring and the harness block), in V8.4; and the exec form (`"args": []`) of both exemplars' `Register:` stanzas, the exemplar half of V3's `review/claude-code/10`, in V8.5. V10's `review/consistency/6` (README's three answers on `.mcp.json`) is closed by V10 with the README lines below, which match what V8.3 lands.

## Handed to other clusters

**V10 — `cbk-conventions-reference.md` § Syncing the kit (`#71/body/1`).** V10's plan already carries this clause: its full-content rewrite of the section (V10.1, `$S/sync-section.md`) has the bullet `**Kit-owned code stays out of the target's formatter and linter scope.**`. That bullet is the landing. V10 does not also append the paragraph below, which would state the rule twice in one section. The paragraph is V8's statement of what the bullet must carry: the `copy`-row reason, the forced exclusion for explicit paths with ruff as the example, and the pointers to `format-on-edit.sh`'s floor and the bootstrap row. One correction for V10's bullet: its quote, "Files that are passed to `ruff` directly are always analyzed, regardless of the above criteria, unless `force-exclude` is also enabled", does not match the raw source under `grep -F`. The source breaks the line after `criteria,` and writes ``unless [`force-exclude`](settings.md#force-exclude) is also enabled`` (`https://raw.githubusercontent.com/astral-sh/ruff/main/docs/configuration.md`, lines 343–344, read 2026-09-30). Quote only the first clause, as below, or quote the linked form.

> **Kit-owned code stays out of the target's formatter and linter scope.** `.claude/workflows/**` is the kit's code, and the `copy` rows assert it byte-identical to the kit, so a repo-wide formatter or linter that rewrites it breaks the next sync's byte check (a target's formatter hook rewrote `agent-cost.py` this way — context-builder-kit#71). Exclude the tree from every repo-wide formatter and linter, and make the exclusion hold for a path handed over explicitly, which is what an edit-time hook, pre-commit and an editor all do: for ruff that is `extend-exclude` plus `force-exclude = true`, because otherwise "Files that are passed to `ruff` directly are always analyzed" (`https://github.com/astral-sh/ruff/blob/main/docs/configuration.md` § Python file discovery, read 2026-09-30). `format-on-edit.sh`'s floor skips the tree whatever a formatter's config says, and the bootstrap checklist's one-time choices record where the exclusion lives. An exclusion is not an exemption (`cbk-conventions.md` § `[skip ci]` rule): the tree's own gate is the verification block, which runs its fixtures, and the sync's byte check.

**V10 — `README.md` (`review/security/17`, `review/release/28`, together with V10's own `review/consistency/6`).**
- The Quick start's MCP step (today's lines 43–45: `cp .mcp.json.example .mcp.json` / `$EDITOR .mcp.json   # fill in PATs, API keys`) must stop telling the reader to paste keys. Whatever shape D60's rewrite gives the Quick start, it says: copy the example to `.mcp.json` and commit it; remove the servers you don't use; credentials stay `${VAR}` references; export any variable a server references (for example `CONTEXT7_API_KEY`) in the shell before starting `claude`, because Claude Code expands `${VAR}` from its launch environment.
- § MCP servers (today's lines 365–372): drop the `github` bullet. Add one line saying GitHub is reached through `gh` and the kit ships no GitHub MCP entry. Add "(hosted, OAuth in the browser)" to `linear`, and "(`uvx mcp-server-time@<pinned version>`; needs `uv`)" to `time`.
- Prerequisites: `uv` (for `uvx`), needed only when the `time` server is wired. Without it, that server fails to start and the cascade falls back to asking for dates.

**V10 — `CHANGELOG.md` v1.0.0 Sync notes, from V8:**
- `.mcp.json`: hand-merge. The kit ships no `github` entry, hosted entries carry `"type": "http"`, `time` runs `uvx mcp-server-time@2026.8.18`, and credentials are `${VAR}` references. The kit sub-block now reads a target's committed `.mcp.json` and turns red on an untyped url entry, an unpinned `npx`/`uvx`/`bunx` server, or a literal credential.
- `.gitignore`: append the harness block from `github-starter-templates.md` § `.gitignore` — the harness block below every stack section, and state its pin assertions in the commit body. The kit's own `.gitignore` is not in the drop-in set.
- A target on mise adds the `[task_config]` block from blueprint's `templates/tooling.md` step 1 and pins mise ≥ 2026.7.15 wherever tasks run.
- Exclude `.claude/workflows/**` from every repo-wide formatter and linter, forced for explicit paths. A wired `format-on-edit.sh` merges the new floor line.
- A target whose filled § Dependency settle-window lists `rust-toolchain.toml`, or a container base-image tag, as uncovered corrects it: both are covered, and the three image gaps are named.
- Release day (F5): re-run `curl -sL https://pypi.org/pypi/mcp-server-time/json | jq -r '.releases["2026.8.18"][0].upload_time'` and confirm the pin is at least 7 days old.

**V3 — `.claude/settings.json` (the part of `#70/body/6a` in V3's file).** V3's plan already carries this in Task V3.4: `enabledMcpjsonServers` = `linear`, `notion`, `context7`, `time`, a reworded `_comment_enabledMcpjsonServers`, and the block check that every listed name is declared. V8.3 depends on it (Step 0b) and keeps those four keys. What V8 asks of V3 beyond its plan: the comment should say the copied `.mcp.json` is committed and holds `${VAR}` references only, so `settings.json` tells the same secret-handling story as the example and `tooling.md`.

**V2 — § Hook authoring (region V2's).** Cite `§ .gitignore anchoring` for the `!/.claude/hooks/lib/` negation. The bullet it cites lands in V8.4 (see V8.4 Step 0b). The sourced-helper contract and R11's § Hook authoring sentence stay V2's. V8.5 lands only the exemplars' own header lines.

**V6 — `run-arms-headless.py`'s docstring (`#69/c5859470658/2`).** It may cite `github-starter-templates.md` § `.gitignore` — the harness block, and `/.claude/worktrees/` as a gitignored worktree root. The heading and the entry exist from V8.4 on, inside the same PR.

## Not holding at planning time

None. The pack's two unverified review findings were re-checked against the tree on 2026-09-30, and both hold. Execution re-checks them again in the tasks that land them.

- `review/release/62` holds. `.gitignore:1` is `reference/`, unanchored and uncommented, and `git check-ignore -v --no-index docs/reference/a.md` answered `.gitignore:1:reference/	docs/reference/a.md`. No `reference/` directory exists anywhere in the kit (`find . -path ./.git -prune -o -type d -name reference -print` printed nothing). The line has been there since the README commit of 2026-05-05. Landed in V8.4.
- `review/portability/66` holds. `.github/dependabot.yml.example:10` reads `#    guarantee: docs.github.com … dependabot-options-reference, read 2026-09-06).`, and the elided URL cannot be resolved. Landed in V8.1.

Two facts the pack stated were refined while planning, and the tasks carry the refined form. First, `rust-toolchain.toml` is covered by Dependabot's `rust-toolchain` ecosystem (supported-ecosystems page, read 2026-09-30), so V8.1 removes it from the uncovered list in the same sentence it rewrites. Second, the Docker Hub cooldown quote the pack flagged as drifting is present in today's README, beside the GHCR paragraph and the `cooldown_date_unavailable` policy sentence, so V8.1 quotes both.
