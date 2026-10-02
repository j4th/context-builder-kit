# Harvest 5 — V10: The release

This cluster turns the kit into something a target installs and upgrades by version. It closes D41 (tags,
`CHANGELOG.md` with Sync notes, scaffold's Kit commit row in the `vX.Y.Z (sha)` form), D60 (a Quick start that
installs only the drop-in set from a tagged archive), R14 (the trace audit codified in this repository's
`CLAUDE.md`) and the release lens of the whole-kit review. Trace rows closed here: `release/1`–`release/4`,
`release/6`, `release/8`; the V10 parts of `release/5`; the handed-in V10 parts of `#60/c5892401033/helper`, `#60/c5881158391/status`,
`#67/c5881158070/2c`, `#69/body/F9`, `#69/body/finish-ab/N-arm`, `#69/body/finish-ab/runner`,
`#69/c5859756889/apply-h4/5` and `#69/c5901496433/sync-note`; `review/consistency/1`, `/2`, `/6`, `/7`,
`review/release/23`, `/25`, `/26`, `/27`, `/30`, `/61`, `/64`, `/65`; and, because V10 owns the file each lands in,
the § Syncing or `README.md`/`CLAUDE.md`/`CHANGELOG.md` parts of `#69/c5859756889/apply-h4/1`, `/2`, `/3`, `/6`,
`#71/body/1`, `#70/table/mise-mcp-row`, `#58/c5901493591/R14`, `review/claude-code/13`, `/14`,
`review/release/28`, `/29`, `/63`, `review/security/17`, `review/consistency/40` (`README.md`'s `finish.md`
sentence), `review/consistency/51` and `critic/9`. It runs last because it
describes what V1–V9 landed: the hook helper and fixtures (V1, V2), exec-form registrations, qualified plugin
keys and invoke-only commands (V3), the review-bot templates (V4), the recalibration and the
`knowledge-backend.md` split (V5), the N-arm harness and headless runner (V6), the review-sweep rewrite (V7),
the rebuilt `.mcp.json.example`, the `.gitignore` harness block and the formatter-scope surfaces (V8), and the
qualified citations (V9). The tags themselves and the GitHub Release are the master plan's Task F5.

## Before you start

- Run every task from the repository root, on `feat/harvest-5-v1.0.0`, after V9's last commit. Each task is one
  commit, and the runner is green after each.
- Each task's scratch directory is `S=$(mktemp -d)`; scripts the plan gives in full are written there, never into
  the tree.
- Every **Replace** below is an exact-string edit (the Edit tool). The old text is copied verbatim from the file
  at `643f7ff` (identical to `74edf84` there), and each anchor sits in text that, per the ownership map, no other
  cluster edits. If an anchor does not occur exactly once when the task runs, stop and reconcile; never guess.
- Every V10 block check is inserted immediately before `echo "verification: kit sub-block complete"`. The checks
  on `README.md`, `CHANGELOG.md`, `CLAUDE.md`, `LICENSE` and § Syncing the kit run only on the kit tree
  (`[ ! -f docs/cbk/scaffold.md ]`): in a target those files are the target's own. The block runs in a filled
  target too, so a kit-tree fact must not become a target's red.
- Every red line below was produced by running the check on a scratch copy of the kit at `643f7ff`
  (`cp -a`), with V10's earlier tasks applied. Where V1–V9 change which check reds first, the task says so.
- Platform quotations are re-fetched raw on the day and matched with `grep -F` after this normalisation, which
  maps typographic apostrophes to `'` and a markdown link to its text:

  ```bash
  norm() { sed -e "s/[’‘]/'/g" -e 's/\[\([^]]*\)\]([^)]*)/\1/g' "$1"; }
  ```

  If the execution day is not 2026-09-30, each task's quotation step says how to restamp the dates it wrote.
- Sanitization: nothing any task writes into `.claude/`, `.github/`, `README.md`, `CLAUDE.md` or `CHANGELOG.md`
  names a target. Task V10.2 clones `j4th/echosphere` into `$S` with the operator's `gh`
  credentials for its simulation; no sibling checkout is touched, and nothing is written outside `$S`.

### Task V10.1: § Syncing the kit speaks in versions; scaffold records the kit release as `vX.Y.Z (sha)` (release/1, release/2, #69/c5901496433/sync-note, #69/c5859756889/apply-h4/2, #69/c5859756889/apply-h4/3, #71/body/1, release/5; D41, D52, D53)

**Files:**
- Modify: `.claude/rules/cbk-conventions-reference.md` — § Syncing the kit (the whole section body), and one
  check at the kit sub-block's sentinel
- Modify: `.claude/rules/cbk-conventions.md` — the one-line pointer under `## Syncing the kit`
- Modify: `.claude/skills/scaffold/references/scaffold_output_template.md` — the Kit commit row (line 24), the
  Cascade metadata guidance (line 106), the worked example's row (line 130)
- Modify: `.claude/skills/scaffold/SKILL.md` — the Cascade metadata item of the output-doc list (line 213)
- Modify: `.claude/skills/scaffold/references/bootstrap_checklist_template.md` — one verification-matrix row,
  after `Scaffold output readable`
- Modify: `.claude/skills/scaffold/references/test_cases.md` — Test 1's two-axis Cascade metadata criterion

**Interfaces:**
- Consumes: V8's `.claude/workflows/` skip floor in `.claude/hooks/format-on-edit.sh` and its formatter-scope row
  in the bootstrap checklist (the new bullet names both as the rule's other locations). V8 hands `#71/body/1`'s
  § Syncing clause to this task and does not write it. V1's verification-matrix row and V2's corpus rows sit
  elsewhere in the same matrix. V9 may already have rewritten this section's citation to
  `context-builder-kit#58`; the section replacement accepts either spelling.
- Produces: the Kit commit form `vX.Y.Z (sha)`, with the template row text `<vX.Y.Z (sha) — the kit release this
  `.claude/` was installed from, the base of the next sync (`cbk-conventions-reference.md` § Syncing the kit)>`.
  Task V10.3's install step prints `Kit commit: vX.Y.Z (sha)`, and V10.2's Sync notes cite this section.
- Produces: the § Syncing the kit bullets `**Files run ahead of the kit merge against the release that lands
  them.**`, `**After resolving `settings.json`, diff its hook event keys against the pre-merge copy**`, `**Kit-owned
  code stays out of the target's formatter and linter scope.**` and `**No Kit commit row to read.**`.
- Produces: the block sentences `scaffold_output_template.md's Kit commit row does not take the vX.Y.Z (sha) form`
  and `cbk-conventions-reference.md § Syncing the kit does not name CHANGELOG.md's Sync notes`.
- The contract pointer grows the always-loaded total by 59 bytes (130,628 → 130,687 on the planning copy).

- [ ] **Step 0: Confirm the surfaces this task points at**

Run:
```bash
grep -n '\.claude/workflows' .claude/hooks/format-on-edit.sh | head -3
grep -n -i 'formatter' .claude/skills/scaffold/references/bootstrap_checklist_template.md | head -3
```
Expected: each prints at least one line (V8's skip floor; V8's formatter-scope row). If either prints nothing,
stop: the new bullet's last sentence names both as the rule's other locations (§ Multi-surface facts).

- [ ] **Step 1: Add the failing checks to the block**

**Replace** in `.claude/rules/cbk-conventions-reference.md` *(whole line; the kit sub-block's sentinel)*:
````text
echo "verification: kit sub-block complete"
````
with:
````text
# Releases (V10): scaffold records the kit release it installed as `vX.Y.Z (sha)`, and on the kit tree
# § Syncing the kit reads CHANGELOG.md's Sync notes before its file-by-file table.
grep -qF '| **Kit commit** | <vX.Y.Z (sha)' .claude/skills/scaffold/references/scaffold_output_template.md || { echo "scaffold_output_template.md's Kit commit row does not take the vX.Y.Z (sha) form"; exit 1; }
if [ ! -f docs/cbk/scaffold.md ]; then grep -qF 'CHANGELOG.md' <<<"$(awk '/^## Syncing the kit$/{p=1;next} /^## /{p=0} p' .claude/rules/cbk-conventions-reference.md)" || { echo "cbk-conventions-reference.md § Syncing the kit does not name CHANGELOG.md's Sync notes"; exit 1; }; fi

echo "verification: kit sub-block complete"
````

- [ ] **Step 2: Run the block — red on the template row**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected:
```
scaffold_output_template.md's Kit commit row does not take the vX.Y.Z (sha) form
verification: block exited 1
exit=1
```
Record the first line in the PR body's red-first table.

- [ ] **Step 3: The scaffold row, its guidance, its example, the SKILL list, the checklist row, the test case**

**Replace** in `.claude/skills/scaffold/references/scaffold_output_template.md` *(whole line 24)*:
````text
| **Kit commit** | <context-builder-kit sha this `.claude/` was installed from — the base of the next sync> |
````
with:
````text
| **Kit commit** | <vX.Y.Z (sha) — the kit release this `.claude/` was installed from, the base of the next sync (`cbk-conventions-reference.md` § Syncing the kit)> |
````

**Replace** in the same file *(inline, the end of the Cascade metadata guidance paragraph, line 106)*:
````text
Include only the axis-conditional rows the chosen axes need. Keep the design-doc-mode note for in-repo-markdown planning as a one-liner.
````
with:
````text
Include only the axis-conditional rows the chosen axes need. Keep the design-doc-mode note for in-repo-markdown planning as a one-liner. The `Kit commit` row reads `vX.Y.Z (sha)`: the kit release this `.claude/` came from and its commit, which the kit's install step (its `README.md` § Quick start) prints as `Kit commit: vX.Y.Z (sha)`. From a clone of the kit rather than a release archive, `git describe --tags --exact-match` and `git rev-parse --short HEAD` in that clone give the two halves; a clone on no tag records the newest tag before it (`git describe --tags --abbrev=0`) with the clone's own sha, which is the merge base.
````

**Replace** in the same file *(whole line 130, the worked example)*:
````text
| **Kit commit** | e92e9c4 |
````
with:
````text
| **Kit commit** | v0.4.0 (e92e9c4) |
````

**Replace** in `.claude/skills/scaffold/SKILL.md` *(inline, line 213)*:
````text
Notion hub URL (if knowledge = `notion`), provisioned date. For Claude in future sessions.
````
with:
````text
Notion hub URL (if knowledge = `notion`), the kit release `.claude/` was installed from (`vX.Y.Z (sha)`, the base of the next sync), provisioned date. For Claude in future sessions.
````

**Replace** in `.claude/skills/scaffold/references/bootstrap_checklist_template.md` *(whole line, the
verification matrix)*:
````text
| Scaffold output readable | View <repo URL>/blob/main/docs/cbk/scaffold.md | File renders, Cascade metadata reads `Planning backend: github-issues` | ☐ |
````
with:
````text
| Scaffold output readable | View <repo URL>/blob/main/docs/cbk/scaffold.md | File renders, Cascade metadata reads `Planning backend: github-issues` | ☐ |
| Kit release recorded | Read the **Kit commit** row of docs/cbk/scaffold.md, then run `git ls-remote --tags <kit repository URL> 'vX.Y.Z^{}'` with its tag | The row reads `vX.Y.Z (sha)`, and the peeled tag the command prints begins with that sha | ☐ |
````

**Replace** in `.claude/skills/scaffold/references/test_cases.md` *(inline, Test 1)*:
````text
the committed scaffold.md carries the two-axis Cascade metadata rows
````
with:
````text
the committed scaffold.md carries the two-axis Cascade metadata rows and a **Kit commit** row reading `vX.Y.Z (sha)`, which the bootstrap checklist's verification matrix confirms against the kit repository's tag
````

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected: the second check is now the red one.
```
cbk-conventions-reference.md § Syncing the kit does not name CHANGELOG.md's Sync notes
verification: block exited 1
exit=1
```

- [ ] **Step 4: Rewrite § Syncing the kit**

The section is one paragraph at `74edf84`, and V9 may have qualified its `#58` citation first. Write the new body
to `$S/sync-section.md`, then replace the body between `## Syncing the kit` and `## Verification` with a script
that refuses any body other than the two expected spellings.

`$S/sync-section.md` (full content):
````markdown
A kit release is an annotated tag `vX.Y.Z` on the kit repository's `main`, and the kit's `CHANGELOG.md` carries one section per release whose **Sync notes** say what a target does by hand. The versioning is informal SemVer: a major bump means a sync needs hand reconciliation beyond `git merge-file`, a minor bump is a harvest, and a patch is fixes only. A target records the release it installed as scaffold's **Kit commit** row, in the form `vX.Y.Z (sha)`: the tag is the readable name, and the sha is authoritative.

A sync to a newer release is a three-way merge, not a hand-reconciliation. First read the Sync notes of every release after the recorded one, up to and including the release being synced to. Then write the file-by-file table: classify each file as copy / add / merge / keep, and note what each merge must preserve. The table is the reusable artifact; write it before the branch. Then merge each file with `git merge-file <ours> <kit@recorded> <kit@new>`: the base is the kit at the recorded release, ours is the project's copy, and theirs is the new release. On a real application 47 of 48 files the project had customized auto-resolved (pure kit drift, derivable from the base); the conflict hunks were the two big rule files, where the kit's generalized text and the project's filled text both had to survive (context-builder-kit#58, second application, item 10). When the sync merges, record the new release and its sha where the old one was recorded.

- **Files run ahead of the kit merge against the release that lands them.** A target running files ahead of the kit records them in its own copy of this section, grouped by the kit issue each carries. Its next sync three-way-merges those files against the kit release that lands those issues, not against the recorded install. Where the kit's own application differs from the target's, the kit wins, and the difference is reconciled in that sync. Byte-identity for `copy` rows is asserted against the new release, so a fix a project needs ahead of the kit is filed upstream and carried here as a named exception, never silently patched into a copy.
- **After resolving `settings.json`, diff its hook event keys against the pre-merge copy** (`jq -r '.hooks | keys[]'` on both). A registration that sat inside a conflict hunk is dropped when the kit's side of the hunk is taken, and the diff names it before a session runs without it.
- **Kit-owned code stays out of the target's formatter and linter scope.** `.claude/workflows/**` is the kit's: a `copy` row, byte-identical to its release, so a repo-wide formatter or linter that rewrites it breaks the next sync's byte check. Exclude the tree from every repo-wide formatter and linter, and make the exclusion hold for a path handed over explicitly, as a format-on-edit hook, a pre-commit hook or an editor does. For ruff that is `extend-exclude` plus `force-exclude = true`, because otherwise "Files that are passed to `ruff` directly are always analyzed, regardless of the above criteria" (`https://raw.githubusercontent.com/astral-sh/ruff/main/docs/configuration.md` § Python file discovery, read 2026-09-30; the sentence goes on to except `force-exclude`). Exclusion is not exemption (`cbk-conventions.md` § `[skip ci]` rule): the tree's own gate is the verification block, which runs its fixtures, together with the sync's byte check on `copy` rows. The same rule is stated in `format-on-edit.sh`'s skip floor and in the bootstrap checklist.
- **A project's own hooks sync as `keep` rows, and are held to the kit's contract.** The hook fixture reads every `.claude/hooks/*.sh`, so § Hook authoring's stdin/exit contract binds a target's own guards as it binds the kit's.
- **A project sub-block re-homed into this file from a pre-split contract must split its own retired-vocabulary literals**, or the block's `absent` check matches it.
- **No Kit commit row to read.** A target whose `docs/cbk/scaffold.md` predates the row, and is immutable after its commit, records `vX.Y.Z (sha)` in its own copy of this section, beside the files it runs ahead of the kit. A target installed from an untagged commit records that sha, and reads the Sync notes from the newest release at or before it (`git describe --tags --abbrev=0 <sha>` in a kit clone).
````

`$S/sync-apply.py` (full content):
````python
import sys
path, newbody = sys.argv[1], open(sys.argv[2], encoding='utf-8').read()
t = open(path, encoding='utf-8').read()
head, tail = "## Syncing the kit\n\n", "\n\n## Verification\n"
i = t.index(head) + len(head); j = t.index(tail, i)
body = t[i:j]
A = "A target that recorded its **Kit commit** (scaffold's Cascade metadata table) syncs to a newer kit as a three-way merge, not a hand-reconciliation: for every file, `git merge-file <ours> <kit@install-sha> <kit@target-sha>` — base is the kit at the install sha, ours the project's copy, theirs the new kit. On a real application 47 of 48 files the project had customized auto-resolved (pure kit drift, derivable from the base); the conflict hunks were the two big rule files, where the kit's generalized text and the project's filled text both had to survive ({cite}, second application, item 10). The file-by-file table — classify each file as copy / add / merge / keep, then note what each merge must preserve — is the reusable artifact; write it before the branch. Two traps: a project sub-block re-homed into this file from a pre-split contract must split its own retired-vocabulary literals (or the block's `absent` check matches it), and byte-identity for `copy` rows is asserted against the target sha, so a fix a project needs ahead of the kit is filed upstream and carried as a named exception, never silently patched into a copy. Record the new sha in the table when the sync merges."
ok = [A.format(cite=c) for c in ("#58", "context-builder-kit#58")]
if body not in ok:
    sys.exit("STOP: § Syncing the kit is neither form this task expects; reconcile before editing")
open(path, 'w', encoding='utf-8').write(t[:i] + newbody.rstrip('\n') + t[j:])
print("§ Syncing the kit replaced")
````

Run: `python3 "$S/sync-apply.py" .claude/rules/cbk-conventions-reference.md "$S/sync-section.md"`
Expected: `§ Syncing the kit replaced`. A `STOP:` line means the section changed under another cluster:
reconcile, never force.

**Replace** in `.claude/rules/cbk-conventions.md` *(whole line; the pointer under `## Syncing the kit`)*:
````text
Three-way `git merge-file` against the recorded **Kit commit**; the file-by-file table first. → `cbk-conventions-reference.md` § Syncing the kit.
````
with:
````text
Three-way `git merge-file` against the recorded **Kit commit**, `vX.Y.Z (sha)`; the kit `CHANGELOG.md`'s Sync notes, then the file-by-file table, first. → `cbk-conventions-reference.md` § Syncing the kit.
````

- [ ] **Step 5: Verify the ruff quotation raw**

Run:
```bash
curl -sL https://raw.githubusercontent.com/astral-sh/ruff/main/docs/configuration.md -o "$S/ruff-configuration.md"
grep -cF 'Files that are passed to `ruff` directly are always analyzed, regardless of the above criteria' "$S/ruff-configuration.md"
grep -cx '## Python file discovery' "$S/ruff-configuration.md"
grep -cF 'unless [`force-exclude`](settings.md#force-exclude) is also enabled (via CLI or settings file).' "$S/ruff-configuration.md"
grep -cF 'Files that are passed to `ruff` directly are always analyzed, regardless of the above criteria' .claude/rules/cbk-conventions-reference.md
```
Expected: `1`, `1`, `1`, `1`. The citation names the URL the quotation matches byte for byte: the raw markdown
source, re-fetched on 2026-09-30, where the sentence is one line under `## Python file discovery` (line 344 that
day) that ends `criteria, ` and continues on the next line as ``unless [`force-exclude`](settings.md#force-exclude)
is also enabled (via CLI or settings file).`` The quotation is therefore the sentence's first clause only: the whole
sentence crosses a line break and a link, and never matches the raw source under `grep -F`. The bullet states the
`force-exclude` exception in its own words, outside the quotation marks. (The rendered page,
`https://docs.astral.sh/ruff/configuration/`, carries the same sentence with the backticks around `ruff` dropped,
so the backticked quotation does not match it.) If the third count is `0`, the exception moved: re-read the section
and correct the bullet's last clause. If the day is not 2026-09-30, restamp this one citation:
`today=$(date -u +%F); sed -i "s|(\`https://raw.githubusercontent.com/astral-sh/ruff/main/docs/configuration.md\` § Python file discovery, read 2026-09-30;|(\`https://raw.githubusercontent.com/astral-sh/ruff/main/docs/configuration.md\` § Python file discovery, read $today;|" .claude/rules/cbk-conventions-reference.md`

- [ ] **Step 6: Run the gate**

Run:
```bash
for h in .claude/hooks/*.sh .claude/hooks/lib/*.sh; do bash -n "$h" || echo "bash -n failed: $h"; done
bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E 'always-loaded total|^verification: '; echo "exit=${PIPESTATUS[0]}"
wc -l < .claude/skills/scaffold/SKILL.md
```
Expected: no `bash -n failed` line; `always-loaded total: <N> bytes` with N exactly 59 above the total the previous
commit printed; `verification: kit sub-block complete`; `verification: done`; `exit=0`; the SKILL.md line count
under 500 (337 at `74edf84`).

- [ ] **Step 7: Commit**

```bash
git add .claude/rules/cbk-conventions-reference.md .claude/rules/cbk-conventions.md \
  .claude/skills/scaffold/SKILL.md .claude/skills/scaffold/references/scaffold_output_template.md \
  .claude/skills/scaffold/references/bootstrap_checklist_template.md .claude/skills/scaffold/references/test_cases.md
git commit -F - <<'EOF'
feat(V10): § Syncing the kit speaks in versions; scaffold records the kit release as vX.Y.Z (sha)

A kit release is an annotated tag, and a sync reads CHANGELOG.md's Sync notes, writes the
file-by-file table, then merges every file against the recorded release. The section gains the
rules the applications taught: files run ahead of the kit merge against the release that lands
them, the settings.json hook-event diff, kit-owned code kept out of a target's formatter and
linter, a project's own hooks held to the kit's contract, and the fallback for a scaffold.md
that predates the Kit commit row. Scaffold's row, its guidance, its SKILL list, the bootstrap
checklist and Test 1 take the vX.Y.Z (sha) form; the block pins the row and the section.

Trace: release/1, release/2, #69/c5901496433/sync-note, #69/c5859756889/apply-h4/2,
#69/c5859756889/apply-h4/3, #71/body/1 (the § Syncing clause, handed from V8), release/5 (this
section's own citation).

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

### Task V10.2: `CHANGELOG.md` — v0.1.0 to v1.0.0, each with its Sync notes (release/6, #67/c5881158070/2c, #69/c5859756889/apply-h4/5, #69/c5901496433/sync-note, #69/c5859756889/apply-h4/1, apply-h4/2, apply-h4/3, apply-h4/6, #70/table/mise-mcp-row, #60/c5881158391/status; D41, D50; Review Focus 1)

**Files:**
- Create: `CHANGELOG.md`
- Modify: `.claude/rules/cbk-conventions-reference.md` — one check at the kit sub-block's sentinel

**Interfaces:**
- Consumes: every V1–V9 landing the v1.0.0 section describes (Step 0 checks each one it names), and Task V10.1's
  § Syncing the kit, which the Sync notes cite.
- Produces: headings of the form `## [X.Y.Z] — <date> — <harvest> (PR #<n>)`, newest first, each followed by
  `### What landed` and `### Sync notes`, under an `## [Unreleased]` heading. The master plan's Task F4 previews
  the `[1.0.0]` Sync notes in the PR body; Task F5 tags `v0.1.0`–`v1.0.0` with these headings as messages and
  publishes the `[1.0.0]` section with `awk '/^## \[1\.0\.0\]/{p=1;next} /^## \[/{p=0} p' CHANGELOG.md`.
- The `[1.0.0]` heading's date and PR number are predictions: this task writes the execution day's UTC date and
  the next free number. The master plan's Task F4 owns both: it confirms the PR number `gh pr create` returns, and
  re-dates the heading to the merge's UTC date (§ Handed to other clusters).
- Produces: the v1.0.0 always-loaded figure, measured after V10.1 (the last V10 change to an always-loaded rule).
- Produces: the block sentence `CHANGELOG.md has no [<version>] section with a ### Sync notes heading`.
- Numbers such as `#59` in this file are this repository's pull requests and issues, written bare on purpose:
  `CHANGELOG.md` is outside the drop-in set, and its `[1.0.0]` section is the GitHub Release text, where a bare
  number links to this repository. D53's hazard, a bare number linking to a target's own issue, cannot arise here.

- [ ] **Step 0: Confirm what the v1.0.0 section says landed**

Run:
```bash
t=.claude/workflows/tests
for f in $t/run-verification-block-fixture.sh $t/hook-guards-fixture.sh $t/hook-payloads-fixture.sh \
  $t/protected-paths-hook-fixture.sh $t/adr-ci-body-fixture.sh $t/review-assert-fixture.sh $t/review-trigger-fixture.py \
  $t/run-arms-headless-fixture.sh .claude/hooks/lib/resolve-path.sh .claude/rules/knowledge-backend-reference.md \
  .claude/workflows/finish-ab/run-arms-headless.py; do [ -f "$f" ] || echo "missing: $f"; done
grep -q 'project sub-block complete' .claude/workflows/tests/run-verification-block.sh || echo "no third rail"
grep -q 'stop_hook_clean' .claude/rules/cbk-conventions-reference.md || echo "no stop_hook_clean"
grep -q '140000' .claude/rules/cbk-conventions-reference.md || echo "no budget warning"
[ "$(jq '[.hooks[][] | .hooks[] | select(has("args") | not)] | length' .claude/settings.json)" = 0 ] || echo "a registration is not exec form"
jq -r '.enabledPlugins | keys | join(" ")' .claude/settings.json
[ "$(grep -l '^disable-model-invocation: true' .claude/commands/*.md | wc -l | tr -d ' ')" = 5 ] || echo "not all five commands are invoke-only"
grep -q 'silently replaces' .claude/rules/tooling.md && echo "tooling.md still says a local list replaces"
for f in .claude/skills/blueprint/references/templates/claude-review.yml .claude/skills/blueprint/references/templates/claude.yml; do grep -q 'Record the resolved model' "$f" || echo "no record-model step: $f"; done
grep -rn 'three surfaces + resolution order' .claude/ && echo "the old heading is still cited"
grep -q 'dispatch surfaces + resolution order' .claude/rules/orchestration.md || echo "no renamed heading"
grep -q 'Opus 5.5' .claude/rules/orchestration.md || echo "orchestration.md does not name Opus 5.5"
jq -r '.mcpServers | keys | join(" ")' .mcp.json.example
grep -q 'uvx' .mcp.json.example || echo "time is not pinned through uvx"
grep -q '"type": "http"' .mcp.json.example || echo "no hosted server carries type http"
grep -q 'READ_ONLY' .claude/workflows/review-sweep.js || echo "review-sweep has no read-only clause"
grep -q ':(glob)' .github/workflows/adr-immutability-check.yml || echo "the ADR job has no :(glob) body"
grep -q '^## `.gitignore`' .claude/skills/scaffold/references/github-starter-templates.md || echo "no .gitignore starter section"
grep -rqF '!/.claude/hooks/lib/' .claude/ || echo "the lib/ gitignore trap is not named"
for f in .claude/hooks/format-on-edit.sh .claude/hooks/analyze-on-edit.sh; do grep -q '"args"' "$f" || echo "Register: stanza not exec form: $f"; done
grep -q 'CONTRIBUTING.md` § Branches' .claude/commands/finish-procedure.md && echo "finish-procedure still cites CONTRIBUTING.md § Branches"
grep -qF '[task_config]' .claude/skills/blueprint/references/templates/tooling.md || echo "blueprint's tooling template has no [task_config] block"
grep -qF "'claude-fable-5'" .claude/workflows/agent-cost.py || echo "agent-cost.py does not key legacy Fable 5 by version"
for k in WRITE_SERVERS worktree_setup; do grep -q "$k" .claude/workflows/finish-ab/run-arms-headless.py 2>/dev/null || echo "run-arms-headless.py has no $k"; done
grep -q 'resolve-path\.sh' .claude/hooks/protect-immutable-adrs.sh || echo "the ADR guard does not source the helper"
grep -q 'Hook backstop slots' .claude/skills/scaffold/references/bootstrap_checklist_template.md || echo "no Hook backstop slots row"
grep -qF "[the project's CI lockfile check" .claude/hooks/protect-lock-files.sh || echo "no lockfile backstop slot"
[ "$(grep -cF "[the base branch's ruleset" .claude/hooks/protect-main-branch.sh)" -ge 2 ] || echo "protect-main-branch.sh lacks a ruleset slot in both warnings"
grep -qF '[ -f docs/cbk/blueprint.md ]' .claude/rules/cbk-conventions-reference.md || echo "the CLAUDE.md check does not key on docs/cbk/blueprint.md"
grep -q "That field follows the Bash tool's" .claude/hooks/require-repo-root-for-agents.sh || echo "P1 landed as variant A: Step 5 swaps the cd note"
grep -q '^## Relation grains$' .claude/skills/adr-new/SKILL.md || echo "adr-new has no ## Relation grains"
grep -q 'Any issue a PR closes' .claude/rules/cbk-conventions.md || echo "cbk-conventions.md has no D54 branch rule"
grep -qF '[actions skip]' .claude/rules/cbk-conventions.md || echo "the CI-skip trap does not name every token"
grep -qF '.github/ISSUE_TEMPLATE/cascade-meta.md' .claude/rules/cbk-conventions-reference.md || echo "no project check on the meta issue template"
for f in cascade-meta.md cascade-rough-in.md; do git diff --quiet 74edf84 -- ".claude/skills/scaffold/references/issue-templates/$f" && echo "issue template unchanged since 74edf84: $f"; done
```
Expected: exactly two lines of output, `commit-commands@claude-plugins-official pr-review-toolkit@claude-plugins-official`
and `context7 linear notion time`, and nothing else, when V2 applied probe P1's variant B (the planning dry runs'
outcome). Under variant A a third line reads `P1 landed as variant A: Step 5 swaps the cd note`, and Step 5 handles
it. Any other line names a sentence of the v1.0.0 section below that does not hold: stop, and reconcile that
sentence with what the cluster actually landed before writing it.

- [ ] **Step 1: Add the failing check to the block**

**Replace** in `.claude/rules/cbk-conventions-reference.md` *(whole line; the kit sub-block's sentinel)*:
````text
echo "verification: kit sub-block complete"
````
with:
````text
# Releases (V10): on the kit tree, CHANGELOG.md has a section for every tagged release, each with its Sync notes
# (a target's CHANGELOG, if it has one, is its own).
if [ ! -f docs/cbk/scaffold.md ]; then for v in 0.1.0 0.2.0 0.3.0 0.4.0 0.5.0 1.0.0; do awk -v v="$v" 'index($0, "## [" v "] ")==1{p=1;next} /^## \[/{p=0} p&&/^### Sync notes$/{f=1} END{exit !f}' CHANGELOG.md || { echo "CHANGELOG.md has no [$v] section with a ### Sync notes heading"; exit 1; }; done; fi

echo "verification: kit sub-block complete"
````

- [ ] **Step 2: Run the block — red, no changelog**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -3; echo "exit=${PIPESTATUS[0]}"`

Expected (the first line is the awk's own error, and its wording depends on the awk installed; this is mawk's):
```
awk: cannot open "CHANGELOG.md" (No such file or directory)
CHANGELOG.md has no [0.1.0] section with a ### Sync notes heading
verification: block exited 1
exit=1
```
Record the second line in the red-first table.

- [ ] **Step 3: The simulated sync (Review Focus 1) — red**

A filled target's copies are merged three ways, from the kit at harvest 4 (`74edf84`) to this branch's
tree, and every file that conflicts must be named in the v1.0.0 Sync notes. The target is `j4th/echosphere`, a
Linear-axis target that synced `74edf84` and then ran ahead of it. Besides every tracked `.claude/` file, the
simulation maps the target's review workflows onto blueprint's templates, its two committed issue templates
(`.github/ISSUE_TEMPLATE/cascade-meta.md`, `cascade-rough-in.md`) onto scaffold's, and its `.mcp.json` onto
`.mcp.json.example`. A mapped file the target does not carry is skipped, as an unmapped one is.

`$S/sim-sync.sh` (full content):
````bash
#!/usr/bin/env bash
# Simulated sync (the master plan's Review Focus 1). A filled target's copies of the kit's
# files are merged three ways, from the kit at harvest 4 (74edf84) to this branch's working tree.
# Every file that conflicts must be named, as a backticked path, in CHANGELOG.md's [1.0.0] Sync notes.
# Usage: bash sim-sync.sh <kit checkout> <target checkout>. Writes only under mktemp -d.
set -uo pipefail
kit=$1 tgt=$2 ref=origin/main base=74edf84
work=$(mktemp -d) || exit 2
trap 'rm -rf "$work"' EXIT
v1=$(awk '/^## \[1\.0\.0\] /{p=1;next} /^## \[/{p=0} p' "$kit/CHANGELOG.md" 2>/dev/null)
notes=$(awk '/^### Sync notes$/{p=1;next} /^### /{p=0} p' <<<"$v1")
[ -n "$notes" ] || { echo "FAIL: CHANGELOG.md has no [1.0.0] section with Sync notes"; exit 1; }
{ git -C "$kit" ls-files .claude | awk '{print $0" "$0}'
  printf '%s\n' '.github/workflows/adr-immutability-check.yml .github/workflows/adr-immutability-check.yml' \
    '.github/workflows/claude-review.yml .claude/skills/blueprint/references/templates/claude-review.yml' \
    '.github/workflows/claude.yml .claude/skills/blueprint/references/templates/claude.yml' \
    '.github/ISSUE_TEMPLATE/cascade-meta.md .claude/skills/scaffold/references/issue-templates/cascade-meta.md' \
    '.github/ISSUE_TEMPLATE/cascade-rough-in.md .claude/skills/scaffold/references/issue-templates/cascade-rough-in.md' \
    '.mcp.json .mcp.json.example'; } > "$work/pairs"
merged=0 conf=0 unnamed=0
while read -r tp kp; do
  git -C "$tgt" cat-file -e "$ref:$tp" 2>/dev/null || continue   # the target lacks it: an add row, no merge
  [ -f "$kit/$kp" ] || continue                                     # the kit no longer ships it: no merge
  git -C "$tgt" show "$ref:$tp" > "$work/ours"
  cp "$kit/$kp" "$work/theirs"
  if git -C "$kit" cat-file -e "$base:$kp" 2>/dev/null; then git -C "$kit" show "$base:$kp" > "$work/base"; kind=merge
  else : > "$work/base"; kind=ahead-of-kit; fi
  merged=$((merged+1))
  rc=0; git merge-file -q -p "$work/ours" "$work/base" "$work/theirs" > "$work/out" || rc=$?
  [ "$rc" -eq 0 ] && continue
  [ "$rc" -le 127 ] || { echo "ERROR: git merge-file exited $rc on $tp"; exit 2; }
  conf=$((conf+1))
  if grep -qF "\`$tp\`" <<<"$notes"; then echo "CONFLICT ($kind, named): $tp"
  else echo "UNNAMED ($kind): $tp"; unnamed=$((unnamed+1)); fi
done < "$work/pairs"
echo "simulated sync: $merged files merged, $conf conflicted, $unnamed not named in the v1.0.0 Sync notes"
[ "$unnamed" -eq 0 ]
````

Run: `gh repo clone j4th/echosphere "$S/echosphere" -- -q && bash "$S/sim-sync.sh" "$PWD" "$S/echosphere"; echo "exit=$?"`

Expected:
```
FAIL: CHANGELOG.md has no [1.0.0] section with Sync notes
exit=1
```
The script was mutation-tested while planning: with a hunk of `.claude/rules/logging.md` changed under the
target's stamped glob and the file left unnamed, it printed `UNNAMED (merge): .claude/rules/logging.md` and
exited 1.

- [ ] **Step 4: Verify the alias and action-release facts raw**

Run:
```bash
curl -sL https://code.claude.com/docs/en/model-config.md -o "$S/model-config.md"
norm "$S/model-config.md" | grep -cF '| v2.1.284 | `sonnet` resolves to Sonnet 5.5 on the Anthropic API |'
norm "$S/model-config.md" | grep -cF '| v2.1.280 | `opus` resolves to Opus 5.5 on the Anthropic API'
for v in v1.0.231 v1.0.232 v1.0.235 v1.0.236; do printf '%s ' "$v"; curl -sL "https://raw.githubusercontent.com/anthropics/claude-code-action/$v/src/entrypoints/run.ts" | grep -F 'const claudeCodeVersion'; done
```
Expected: `1`, `1`, then
```
v1.0.231   const claudeCodeVersion = "2.1.278";
v1.0.232   const claudeCodeVersion = "2.1.280";
v1.0.235   const claudeCodeVersion = "2.1.283";
v1.0.236   const claudeCodeVersion = "2.1.284";
```
(v1.0.232 is the first release that installs 2.1.280, and v1.0.236 the first that installs 2.1.284.) If any line
differs, correct the `**The review model is the action's pin.**` note to what the fetch shows.

- [ ] **Step 5: Write `CHANGELOG.md`**

Full content:
````markdown
# Changelog

Every release of the kit, newest first. A release is an annotated tag `vX.Y.Z` on `main`. The versioning is informal SemVer: a major bump means a sync needs hand reconciliation beyond `git merge-file`, a minor bump is a harvest, and a patch is fixes only. Numbers such as #59 are this repository's pull requests and issues.

Each release's **Sync notes** say what a target does by hand when its sync crosses that release. Read the notes of every release after the one your **Kit commit** row records, then follow `.claude/rules/cbk-conventions-reference.md` § Syncing the kit. Each harvest's design is under `docs/superpowers/specs/`.

## [Unreleased]

Nothing yet.

## [1.0.0] — 2026-09-30 — harvest 5 (PR #75)

The first release to be tagged; the five before it are tagged on their merge commits after the fact. It closes #58 and #60–#74, and the findings of a review of the whole kit. Design: `docs/superpowers/specs/2026-09-30-cascade-kit-harvest-5-design.md`, with one trace row per ask beside it.

### What landed

- **The verification block as a gate.** `run-verification-block.sh` gains a third rail: in a filled target, where `docs/cbk/scaffold.md` exists, the output must also carry `verification: project sub-block complete`. The Stop-hook check reds a hook that could not look. Blueprint's tooling template gives `check` a verification task, light mode included. The budget line warns above 140,000 bytes.
- **Guards that resolve the path they guard.** `.claude/hooks/lib/resolve-path.sh`, a sourced helper, resolves a path lexically and physically and compares device and inode. The ADR guard is rewritten onto it. A hard-deny guard refuses a payload `jq` cannot parse, and an ask-gate asks. The main-branch and PR-state guards match a command behind `bash -c`, quoting, a full path or a chained verb. Every fail-open warning names its surviving backstop. The ADR CI job reads a `:(glob)` pathspec, diffs three-dot from the merge base and fails closed on any git error. Three behavioural hook fixtures run in the block.
- **Claude Code conformance.** The commands declare named `arguments:` and carry `disable-model-invocation: true`. Every hook registration is exec form (`"args": []`). `enabledPlugins` keys read `<plugin>@claude-plugins-official`. `tooling.md` states how settings lists merge across scopes. `/intake` and `/pr-respond` treat report and comment text as data.
- **Review-bot templates.** The family aliases `opus` and `sonnet`, with an explicit `--effort` on every branch. A step records the model that ran. The "Assert the review posted" step is rebuilt and has a fixture. A `paths:` trigger still reviews markdown under `.claude/` and `docs/adr/`, and has a fixture. A fork guard, concurrency at job level, a prompt that applies the base branch's rules, and label checks fed as here-strings.
- **Recalibration for Opus 5.5 and Sonnet 5.5.** `orchestration.md` carries effort defaults per model and surface, the ladder from Opus 5.5, and current prices and cache-read rates. `§ The three surfaces + resolution order` is now `§ The dispatch surfaces + resolution order` in both halves. `knowledge-backend.md` splits into a contract and a path-scoped `knowledge-backend-reference.md`. `workflows.md` records why `/finish` runs inline.
- **Harness.** `finish-ab.js` runs two to four arms, each with its own model and effort, under a balanced judge panel. `run-arms-headless.py` runs each arm as a headless session in its own worktree. `agent-cost.py` keys its prices and cache-read rates by model version.
- **Review conventions.** `review-sweep.js` deduplicates on file and line and carries every title, takes finders that bring their own prompt, and tells every find and verify agent to stay read-only.
- **Target hygiene.** A `.gitignore` harness block for targets. What Dependabot covers for container images, and its three gaps. mise tasks run under bash with `pipefail`. Kit-owned code stays out of a target's formatter and linter. `.mcp.json.example` is rebuilt: `${VAR}` references, `type: "http"` on hosted servers, Linear's hosted endpoint, `time` pinned through `uvx`, and no GitHub server, because `gh` is the kit's GitHub interface. #70's mise and MCP rows land in blueprint's tooling template and in `.mcp.json.example`; no `mise.toml` template ships.
- **Consistency.** Citations point at headings every target has. Kit issues are cited `context-builder-kit#N`. `/finish` Step 1 admits five title forms. `adr-new` reads the index's rows in both of their forms.
- **The release.** This changelog. `README.md`'s Quick start installs the drop-in set from a tagged archive and prints the release to record. § Syncing the kit speaks in versions, and scaffold's **Kit commit** row reads `vX.Y.Z (sha)`.
- Always-loaded rules: 130,628 bytes at v0.5.0, @@ALWAYS_LOADED@@ bytes at v1.0.0. Checked on Claude Code 2.1.285.

### Sync notes

- **Hand-merge these files.** This release rewrites text a filled target changes in each of them. Merge each three ways from the release your Kit commit row records, and keep what the project filled:
  - `.github/workflows/claude-review.yml` and `.github/workflows/claude.yml`, your copies of blueprint's review templates. Keep your label names, turn cap, sizing, allowed tools and the filled `REVIEW_LOGIN`. Take the model and effort lines (`claude.yml` now runs `--effort high`), the `Record the resolved model` step, the rebuilt "Assert the review posted" step, the fork guard, `concurrency` moved into the job, `defaults: run: shell: bash`, `runs-on: ubuntu-24.04`, the step ids `review` and `claude`, the prompt's restore section with its two new bracketed fills, and the notes above `claude_args`. The `paths:` filter replaces `paths-ignore`: put your own prose-only negations above the re-includes of `.claude/**` and `docs/adr/**`. The kit sub-block now runs `review-trigger-fixture.py` and `review-assert-fixture.sh` against your filled `.github/workflows/claude-review.yml`, so a target that syncs the rules before merging this workflow is red until it does.
  - The CI workflow blueprint generated from its skeleton (usually `.github/workflows/ci.yml`). It was never a kit copy, so there is nothing to merge: edit it to match the skeleton. That means `defaults: run: shell: bash`, `runs-on: ubuntu-24.04`, and every `uses:` pinned to a full commit SHA with a trailing version comment, in place of a tag such as `actions/checkout@v4`.
  - `.mcp.json`, your copy of `.mcp.json.example`. Keep the servers your axes use. The kit ships no GitHub entry, hosted entries carry `"type": "http"`, and `time` runs pinned through `uvx`. Turn every literal credential into a `${VAR}` reference, export the variable before launching `claude`, and commit the file. The kit sub-block now checks the committed file's shape: a url entry without a type, an unpinned `npx`, `uvx` or `bunx` server, or a literal credential turns it red.
  - `.claude/rules/orchestration.md` and `.claude/rules/orchestration-reference.md`. Keep your posture row and your dated applied instances. Re-point any citation of `§ The three surfaces + resolution order` to `§ The dispatch surfaces + resolution order`.
  - `.claude/rules/tooling.md`. Keep your filled stack sections; take § MCP configuration's merge rule and § Automated review on the git host.
  - `.claude/settings.json`. Keep your own hooks' registrations, rewritten in exec form, and re-add their names and tiers to `_comment_hooks`. Then diff the hook event keys against your pre-merge copy (§ Syncing the kit).
  - `.claude/rules/cbk-conventions.md` and `.claude/rules/cbk-conventions-reference.md`. Keep your filled values and your project sub-block; take everything in the block above it. In `cbk-conventions.md`, take § Branch naming's rule that any issue a PR closes, cascade or not, puts its key in the branch (the bare issue number on the `github-issues` axis; `<type>/<short-slug>` only for work no issue tracks) with its Quick reference row, and the reworded substring trap in the CI-skip rule's section, which names all five skip tokens and GitHub's skip trailer and cites GitHub's page. The kit sub-block pins both, so a copy that keeps the old wording is red.
  - `.claude/rules/pr-review.md` and `.claude/rules/pr-review-reference.md`. Keep your roster entries; take the floor, the sweep and the invariants.
  - `.claude/rules/simplification.md` and `.claude/rules/workflows.md`. Take the kit's text; keep a filled § Cost+scope-explicit.
  - `.claude/rules/knowledge-backend.md`. It is now two halves. On the `notion` axis, take both, `knowledge-backend.md` and `.claude/rules/knowledge-backend-reference.md`, and move each filled value under its heading. On the `none` axis, where the rule was deleted, add neither half.
  - `.claude/commands/finish-procedure.md` and `.claude/skills/rough-in/references/finish-procedure.md`. Their citations now point at the conventions: a copy whose `CONTRIBUTING.md` citation was filled by hand takes the kit's text.
  - `.claude/skills/adr-new/SKILL.md`. Take the kit's text: it reads the index's rows in both forms, and its `## Refines vs Supersedes vs Extends` section is now `## Relation grains`, a pointer to `.claude/rules/cbk-conventions-reference.md` § ADR relation grains. Repoint any citation of "adr-new § Refines vs Supersedes" in your filled rules, reviewers or docs at `adr-new` § Relation grains or § ADR relation grains; an ADR that cites it stays as written, and the correction goes in `docs/adr/corrections.md`.
  - `.claude/hooks/format-on-edit.sh` and `.claude/hooks/analyze-on-edit.sh`. Keep your filled case arms; take the skip floor, which now names `.claude/workflows/`, and the exec-form `Register:` stanza.
  - `.github/workflows/adr-immutability-check.yml`. Re-copy it from the kit, then restore only your comments and the pinned job name: the job body is replaced. It reads a `:(glob)` pathspec, diffs three-dot from the merge base with `--no-renames`, checks out blobless, runs under `shell: bash` on a named runner image, and fails closed on any git error.
- **Files a target may already run ahead of the kit.** These carry this release's harness and guard ports: `.claude/workflows/agent-cost.py`, `.claude/workflows/tests/agent-cost-fixture.sh`, `.claude/workflows/finish-ab/finish-ab.js`, `.claude/workflows/tests/finish-ab-shape.mjs`, `.claude/workflows/finish-ab/run-arms-headless.py`, `.claude/workflows/tests/run-arms-headless-fixture.sh`, `.claude/workflows/review-sweep.js`, `.claude/workflows/tests/review-sweep-accounting.mjs`, `.claude/hooks/protect-immutable-adrs.sh` and `.claude/hooks/lib/resolve-path.sh`. For each one your target already carries, diff your copy against v1.0.0's. Where the kit's application differs from yours, take the kit's, and keep only your project's own fills. From this sync on, v1.0.0 is these files' merge base, not your install (§ Syncing the kit).
- **New files.** Add `.claude/hooks/lib/resolve-path.sh`, which is sourced, never run. A `.gitignore` with an unanchored `lib/` line hides it from `git add` without a word: add `!/.claude/hooks/lib/` after that line, and after the sync commits check that `git ls-files .claude/hooks/lib/` names the helper (if it does not, `git check-ignore -v .claude/hooks/lib/resolve-path.sh` names the line that hides it). Add the new fixtures under `.claude/workflows/tests/`, each an `add` row: the three hook fixtures `protected-paths-hook-fixture.sh`, `hook-guards-fixture.sh` and `hook-payloads-fixture.sh`; `adr-ci-body-fixture.sh`; `review-assert-fixture.sh` and `review-trigger-fixture.py`; `run-verification-block-fixture.sh`; and `extract-run-block.sh`, which the ADR and review-assert fixtures source. The block runs every one of them but the sourced helper. Append the harness block from scaffold's `references/github-starter-templates.md` § `.gitignore` to your `.gitignore`, below every stack section, and state its pin assertions in the commit body; the kit's own `.gitignore` is not in the drop-in set.
- **Kit-owned code stays out of your formatters.** Exclude `.claude/workflows/**` from every repo-wide formatter and linter, forced for explicit paths (§ Syncing the kit). A wired `format-on-edit.sh` merges the new skip-floor line.
- **mise runs tasks under bash with `pipefail`.** A target on mise adds the `[task_config]` block from blueprint's `templates/tooling.md` step 1 to its `mise.toml` and pins mise ≥ 2026.7.15 wherever tasks run, CI's setup action included. Nothing in the kit checks a target's `mise.toml`.
- **Dependabot covers more than the settle-window said.** `rust-toolchain.toml` is covered by Dependabot's `rust-toolchain` ecosystem, and so is a container base-image tag; a target whose filled § Dependency settle-window lists either as uncovered corrects that section, which now names the three image gaps.
- **The cost reader keys by model version.** A target synced at v0.5.0 prices legacy Fable 5 cache reads at Fable 5.1's 0.025x until it takes v1.0.0's `agent-cost.py`, which reads them at the standard 0.1x. A target that copies `run-arms-headless.py` sets its config's `worktree_setup` to its own per-worktree step, and adds any write-capable MCP server it wires beyond the kit's `github`, `linear` and `notion` to `WRITE_SERVERS`, which makes the file a `merge` row in its sync table.
- **A filled target owes both sentinels.** `.claude/workflows/tests/run-verification-block.sh` is a `copy` row with a third rail: it fails a target whose output lacks `verification: project sub-block complete`. `.claude/workflows/tests/run-verification-block-fixture.sh`, which the block runs against the runner, is an `add` row. Wire the runner as a verification task your `check` depends on, per blueprint's `templates/tooling.md`. If you never stamped the bracketed manifest-and-lockfile globs in `cbk-conventions-reference.md`'s `paths:`, stamp them now (the bootstrap checklist's disposition pass has the row), or the project sub-block is red. The block's `CLAUDE.md` check now fires in a target only once `docs/cbk/blueprint.md` exists: from then on your `CLAUDE.md` must mention `cbk-conventions` as a backticked path, never an `@` import.
- **Fill the three hook backstop slots.** A guard's fail-open warning names the backstop that still stands, and three of them are the project's to name: `[the project's CI lockfile check — …]` in `protect-lock-files.sh`, and `[the base branch's ruleset — pull requests only — where one exists]` in both warnings of `protect-main-branch.sh`. The bootstrap checklist's disposition pass gains a **Hook backstop slots** row: replace each bracket with the real check or ruleset, or with `none` and the reason. The project sub-block refuses a slot left bracketed. A filled slot makes those two hooks `merge` rows in your sync table.
- **The commands no longer start from a description.** `/finish`, `/intake`, `/enrich`, `/pr-respond` and `finish-procedure` carry `disable-model-invocation: true`: type them.
- **Kit issue citations are qualified.** Kit text cites its own issues as `context-builder-kit#N`, because a bare number links to the target's own issue. The rewrite touches about thirteen files a target copies byte for byte, among them the hooks, the workflow scripts and their tests, the executor pair and `adr-new`: take the kit's side of every such hunk. A copy you patched by hand takes the kit's form. The kit sub-block's bare-citation check runs on the kit's own tree only; in yours a bare number is your own issue.
- **Re-copy the issue templates.** `.github/ISSUE_TEMPLATE/cascade-meta.md` and `.github/ISSUE_TEMPLATE/cascade-rough-in.md` are byte copies of scaffold's `references/issue-templates/`, and both changed: re-copy them. The project sub-block is red while your `cascade-meta.md` still cites the retired § Deferred meta-issues.
- **An unreadable payload now denies.** A hard-deny guard refuses a payload `jq` cannot parse, and an ask-gate asks. A missing `jq` still fails open, naming its backstop.
- **The ADR guard judges what a path is, not how it is spelled.** `protect-immutable-adrs.sh` sources `lib/resolve-path.sh`, resolves the path lexically and physically, and denies an edit to an existing numbered ADR in any checkout, however the path reaches it. A target that customized its ADR hook takes the kit's hook (a `copy` row) plus the helper (an `add` row), carries anything it still needs as a named exception (§ Syncing the kit), and checks the helper is tracked (**New files**, above).
- **A dispatch after a `cd` is judged where the shell is.** A hook payload's `cwd` follows the Bash tool's `cd` (the probe is recorded in `require-repo-root-for-agents.sh`'s `Timing:` paragraph). So the launch-root guard now denies an Agent, Task or Workflow dispatch made after a `cd` into a subdirectory, and `protect-main-branch.sh` judges a commit against the checkout the shell is in. Return to the repository root, as its own command, before dispatching.
- **The review model is the action's pin.** The templates name the family aliases, so a review runs whatever model the pinned `anthropics/claude-code-action` release's Claude Code resolves them to. `opus` resolves to Opus 5.5 on the Anthropic API from Claude Code v2.1.280, and `sonnet` to Sonnet 5.5 from v2.1.284 (`https://code.claude.com/docs/en/model-config` § Version history, read 2026-09-30). The action installs Claude Code 2.1.280 from its v1.0.232 and 2.1.284 from its v1.0.236 (`src/entrypoints/run.ts`, `claudeCodeVersion`, read 2026-09-30). A workflow pinned below v1.0.232 still reviews on the previous model under `opus` (Opus 5 from Claude Code v2.1.219), and below v1.0.236 on Sonnet 5 under `sonnet`: bump the pinned SHA.

## [0.5.0] — 2026-09-22 — harvest 4 (PR #59)

The kit as applied: what two targets' syncs of v0.4.0 found. It closes #33 and lands every finding on #58 that had a proven fix; #58 stays open for its residue, which v1.0.0 closes. Design: `docs/superpowers/specs/2026-09-21-cascade-kit-harvest-4-design.md`.

### What landed

- **Settings liveness.** The two `_example_PostToolUse_*` objects are deleted from `settings.json`; an advisory hook's registration stanza lives in its header's `Register:` line. The block asserts that no top-level key holds a hook-shaped object.
- **The hook stdin/exit contract.** Every hook drains stdin first and decides on here-strings, never on a pipeline whose reader can exit first. `hook-contract-fixture.sh` checks both structurally over every hook and probes the decision sites past the pipe buffer.
- **The exercised fork detector**, with its prune rules, its staging-copy prune and its degrade path under a fixture probe.
- **The verification block's runner**, `run-verification-block.sh`, with two fail-loud rails, and the kit's own CI, `verify.yml`, which runs it on every pull request. `ADVISORY_WIRED` declares a target's wired advisory hooks.
- **Harness fixes.** Per-tier cache reads in `agent-cost.py`; `review-sweep.js`'s boundary-safe hint match, roster-read `.catch` and retry reindex; `finish-ab.js`'s distinct arm labels.
- **Records.** `/finish` Step 1 admits `[<slug>:meta]`. `adr-new` writes the index row in the index's own form. Scaffold's **Kit commit** row and § Syncing the kit.
- **Templates.** Both review workflows grant `checks: read` twice, fetch the base ref after the head checkout, and degrade explicitly past the turn cap. The knowledge-backend matcher is widened to the live tool set.

### Sync notes

- Delete any `_example_*` key, and any other hook-shaped top-level key, from `settings.json`. An advisory hook's stanza is copied from its header's `Register:` line into `hooks.PostToolUse`.
- After resolving `settings.json`, diff its hook event keys against the pre-merge copy (`jq -r '.hooks | keys[]'` on both). A registration inside a conflict hunk is lost when the kit's side is taken.
- A `docs/cbk/scaffold.md` committed before this release has no Kit commit row, and it is immutable. Record the release in your copy of § Syncing the kit instead.
- Your own hooks are held to the stdin/exit contract too. `hook-contract-fixture.sh` reads every `.claude/hooks/*.sh`, so a project hook that exits before draining stdin turns the block red: make `input="$(cat)"` its first statement.
- Wire the runner, not an inline copy of the extraction: the task your `check` depends on runs `bash .claude/workflows/tests/run-verification-block.sh`.
- Name every advisory hook you wired in the project sub-block's `ADVISORY_WIRED`.
- A review workflow that already grants `checks: read` (to the job and to the action's token) and already runs `gh pr diff` merges only the degrade clause. Size its N against `--max-turns`.

## [0.4.0] — 2026-09-07 — harvest 3 (PRs #54–#57)

Four PRs: the kit stops being wrong about itself (#54); the review gate is a floor (#55); the producing phases become contract-first (#56); the github-issues axis, the records and the hygiene (#57). Design: `docs/superpowers/specs/2026-09-06-cascade-kit-harvest-3-design.md`.

### What landed

- **The instruction budget.** `cbk-conventions.md`, `orchestration.md` and `pr-review.md` each split into an always-loaded contract and a path-scoped `-reference.md` half, and every moved section keeps a pointer heading. `logging.md` and `testing.md` carry `paths:` globs to stamp. Scaffold's bootstrap checklist gains a rule-file disposition pass.
- **The review floor.** `/simplify` and `pr-review-toolkit:review-pr` must both run, once, as skills, recorded in the PR body's `## Review gate` block. The sweep beside them is bounded and reads its reviewer roster at run time.
- **Reviewer memory does not fork.** A hard-deny hook refuses an agent dispatch from outside the repository root, and a Stop hook blocks the hand-off while a stray memory tree exists. Every hook registration takes the `${CLAUDE_PROJECT_DIR}` form.
- **Contract-first phases.** Framing, rough-in and `/finish` each split into a contract and a procedure. `/finish` gains `finish-procedure.md`, and rough-in bundles the pair. `orchestration.md` states its default tier and effort. `finish-ab` and `agent-cost.py` land with stub tests.
- **The github-issues axis and the records.** The `.github` starter bodies, blueprint's two review-workflow templates, `docs/cbk/ROADMAP.md`, `docs/adr/corrections.md`, the `Extends:` grain, § Multi-surface facts, frozen-corpus ingestion, the issue-less branch, licensing, and `.github/dependabot.yml.example`.

### Sync notes

- The three split rules move sections. Text you filled under a heading that moved goes into the `-reference.md` half, under the same heading; the contract keeps only the pointer.
- Stamp the `paths:` globs in `logging.md` and `testing.md`: a placeholder glob loads nothing. Then run the bootstrap checklist's rule-file disposition pass.
- `/finish` is now a contract and a procedure: install `finish-procedure.md` beside `finish.md`, and rough-in's bundled pair beside them.
- Take the kit's `hooks` block: every command becomes `${CLAUDE_PROJECT_DIR}/.claude/hooks/<name>.sh`, the launch-root guard registers on `PreToolUse`, and the fork detector registers on `Stop`.
- Record the reviewer agent-memory choice, `project` or `local`, in § Surface inventory.
- Do not take the two `_example_PostToolUse_*` keys this release adds to `settings.json`. A hook-shaped top-level key makes Claude Code discard the whole settings file (`.claude/rules/cbk-conventions-reference.md` § Hook authoring), and v0.5.0 removes them.

## [0.3.0] — 2026-08-09 — axis parity (PRs #6, #7)

The kit reconciled with its exercised reality, one configuration at a time. Design: `docs/superpowers/specs/2026-08-09-axis-parity-pass-design.md`.

### What landed

- **An axis-aware `/finish`.** Step 1 reads the planning backend from `docs/cbk/scaffold.md` § Cascade metadata, falling back to `.cascade/backends.toml`, and reads each axis its own way.
- **Two-axis producers.** Scaffold's and blueprint's templates emit `Planning backend` and `Knowledge backend` rows, the axis-conditional rows, and the `.cascade/backends.toml` mirror.
- **One Linear model.** Initiative, then a project shell, then the workstream as a parent issue, then F, then R; the milestones field stays unused.
- **Markdown honesty.** In-repo-markdown planning is design-doc mode, disclosed at scaffold's confirmation gate, with a defined markdown issue record.
- **Wiring and vocabulary.** A `notion` stanza in `.mcp.json.example`. The Projects v2 board contract, marked designed-unexercised. Frame headings of the form `### F<#> — M<#>: <name>`, with F continuing across a workstream's frames.
- The kit repository ignores its own reviewer memory (#6).

### Sync notes

- `/finish` reads the planning backend from `docs/cbk/scaffold.md` § Cascade metadata. A target whose scaffold.md has no `Planning backend` row writes `.cascade/backends.toml` as the mirror it falls back to.
- The Notion server's key in `.mcp.json` must be `notion`: the knowledge-backend ask-gate's matcher names that server's tools.
- Frames already committed are immutable and keep their headings. The `### F<#> — M<#>: <name>` form starts at the next frame, with F continuing the workstream's sequence.
- On Linear, the workstream is a parent issue under the project shell, and the milestones field is not used.

## [0.2.0] — 2026-08-09 — harvest 2 (PR #5)

A second harvest of real-run learnings. Design: `docs/superpowers/specs/2026-08-09-cascade-kit-harvest-2-design.md`.

### What landed

- **`/finish` Step 5 split.** Research runs executably before plan mode, which then gates the plan.
- **Research grounding.** Existence and absence claims are verified repo-wide.
- **The review sweep**, `.claude/workflows/review-sweep.js`: find, then verify adversarially.
- **Three hooks.** `protect-main-branch.sh` hard-denies a commit on `main`; `guard-pr-state.sh` and `require-knowledge-backend-ok.sh` are ask-gates.
- **Reviewer memory.** `memory: project` on the three shipped reviewers.
- **Invocation posture.** `scaffold`, `blueprint`, `framing` and `rough-in` carry `disable-model-invocation: true`; `consultation` stays model-invocable.
- **Rule templates** `workflows.md`, `tooling.md` and `orchestration.md`, and the `Explore` exemplar.
- Frame lifecycle, decision governance, testing cadence and CI supply-chain discipline.

### Sync notes

- Register the three new hooks: take the kit's entries in `settings.json`'s `hooks`.
- `tooling.md` and `orchestration.md` are templates: fill them or delete them. `workflows.md` is kept as shipped.
- `scaffold`, `blueprint`, `framing` and `rough-in` no longer start from a description: type `/scaffold`, `/blueprint`, `/framing` or `/rough-in`.
- The reviewers write precedent memory under `.claude/agent-memory/<name>/`. Decide whether your repository commits it.
- `.claude/agents/Explore.md` overrides the built-in Explore agent. Delete it to keep the built-in.

## [0.1.0] — 2026-08-09 — harvest 1 (PR #4) and everything before it

The kit as first exported (#1–#3) and its first harvest of real-run learnings (#4). Design: `docs/superpowers/specs/2026-07-04-cascade-kit-harvest-design.md`.

### What landed

- **The first export.** The cascade skills, `/finish`, the rules and the ADR scaffolding, with the README (#1).
- **Calibration** (#2). `## Assumptions` becomes the eighth issue section, and the Apply class takes small, low-risk changes.
- **The constant plus two independent axes** (#3). A planning backend and a knowledge backend replace the bundled profiles; `knowledge-backend.md` is new.
- **Harvest 1** (#4). `/finish` in eleven gated steps, reading its break-glass marker from the issue body. The bottom-up lane: `/intake`, `/enrich`, `/pr-respond` and § Contribution intake. The `cascade-rule-reviewer`. The lock-file guard. The `format-on-edit.sh` exemplar. ADR `Refines:`. Additive-increment frames. The dependency settle-window.

### Sync notes

- This is the first tagged release. A copy of the kit taken before any tag records the commit it copied, as § Syncing the kit says, and reads the Sync notes from this release on.
- The bundled profiles are gone. `profile_selection.md` and `opinionated_profile.md` are removed from scaffold, and each skill's `github-only-vs-opinionated.md` is replaced by `planning-backend-matrix.md`. Record the planning and knowledge axes instead.
- The break-glass marker `<!-- skip-review-toolkit -->` goes in the issue body or in the operator's instructions to `/finish`, never in the PR body.
- `format-on-edit.sh` ships unregistered. Wire it only after its case arms are filled.
````

Then fill the values only the execution day knows, and prove none is left:
```bash
n=$(bash .claude/workflows/tests/run-verification-block.sh | sed -n 's/^always-loaded total: \([0-9][0-9]*\) bytes$/\1/p')
sed -i "s/@@ALWAYS_LOADED@@/$(python3 -c 'import sys; print(f"{int(sys.argv[1]):,}")' "$n")/" CHANGELOG.md
cc=$(claude --version | awk '{print $1}'); [ "$cc" = 2.1.285 ] || sed -i "s/Checked on Claude Code 2\.1\.285\./Checked on Claude Code $cc./" CHANGELOG.md
today=$(date -u +%F); [ "$today" = 2026-09-30 ] || sed -i -e "s/^## \[1\.0\.0\] — 2026-09-30 — /## [1.0.0] — $today — /" -e "s/read 2026-09-30/read $today/g" CHANGELOG.md
last=$(gh api 'repos/j4th/context-builder-kit/issues?state=all&per_page=1&sort=created&direction=desc' -q '.[0].number')
if [ -z "$last" ]; then echo "STOP: gh api returned no issue number; fix gh auth, then re-run this line"
elif [ "$last" != 74 ]; then sed -i "s/^\(## \[1\.0\.0\] — .*\) (PR #75)$/\1 (PR #$((last + 1)))/" CHANGELOG.md; fi
grep -q "That field follows the Bash tool's" .claude/hooks/require-repo-root-for-agents.sh || python3 - <<'PY'
import re
p = "CHANGELOG.md"; t = open(p, encoding="utf-8").read()
a = ("- **A dispatch after a `cd` is still judged at the launch directory.** A hook payload's `cwd` stays where the"
     " session was launched after the Bash tool's `cd`, whatever the hooks page says (the probe is recorded in"
     " `require-repo-root-for-agents.sh`'s `Timing:` paragraph). The launch-root guard denies a session launched"
     " outside the repository root: relaunch it from the root.")
t2, n = re.subn(r"^- \*\*A dispatch after a `cd` is judged where the shell is\.\*\*.*$", lambda m: a, t, flags=re.M)
assert n == 1, "the P1 note"
open(p, "w", encoding="utf-8").write(t2)
print("P1 note: variant A")
PY
grep -c '@@' CHANGELOG.md; grep -n '^## \[1\.0\.0\]\|^- Always-loaded\|^- \*\*A dispatch after' CHANGELOG.md
```
Expected: `0`, then the `[1.0.0]` heading (with `(PR #75)` if `last` printed 74, the case at planning time), the
always-loaded line with both figures filled, and the P1 note: `…judged where the shell is.**` under variant B, or,
after a `P1 note: variant A` line, `…still judged at the launch directory.**`. The heading's date and PR number are both predictions: the date
is this execution day's, not the merge's, and the number is the next free one, not the PR's. The master plan's
Task F4 confirms the PR number when it opens the PR, and re-dates the heading to the merge's UTC date
(§ Handed to other clusters gives it the commands).

- [ ] **Step 6: Re-run the simulated sync — green**

Run: `bash "$S/sim-sync.sh" "$PWD" "$S/echosphere"; echo "exit=$?"`

Expected: zero or more `CONFLICT (…, named): <path>` lines, then
`simulated sync: <N> files merged, <C> conflicted, 0 not named in the v1.0.0 Sync notes` and `exit=0`. (On the
planning copy, where V1–V9 had not landed, against the target's `origin/main` at `a64f7f6`, it printed `simulated sync: 131 files merged, 0 conflicted, 0 not
named in the v1.0.0 Sync notes`; that run predates the issue-template mapping, and the target carries both
templates, so the merged count is now two higher.) The target's `cascade-meta.md` is a byte copy of the kit's at
`74edf84`, and its `cascade-rough-in.md` is an older copy without `## Assumptions`; both are named under **Re-copy
the issue templates**, so either may conflict and still count as named. The target changed 21 of the kit's `.claude/` files against `74edf84`. The 18 of
them that a V1–V9 pack names as a target are already named under **Hand-merge these files** or **Files a target
may already run ahead of the kit**, and so are the four mapped files it changed (the two review workflows, the ADR
job and `.mcp.json`) and `run-arms-headless.py`. The other three, `.claude/agents/adr-conformance-reviewer.md`, `.claude/rules/logging.md` and
`.claude/rules/testing.md`, merge clean unless a cluster changed them after all.
If a line reads `UNNAMED (<kind>): <path>`, add one sub-bullet under **Hand-merge these files**, directly above
the `.github/workflows/adr-immutability-check.yml` sub-bullet, of the form
`` - `<path>`. Keep <what the target filled in the conflicting hunk>; take the rest of the kit's text.``,
with the kept part read from that file's conflict hunk (`git merge-file -p` on the three versions the script
names). Re-run until the unnamed count is 0. Record the final summary line in the PR body.

- [ ] **Step 7: Run the gate**

Run:
```bash
for h in .claude/hooks/*.sh .claude/hooks/lib/*.sh; do bash -n "$h" || echo "bash -n failed: $h"; done
bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E '^verification: '; echo "exit=${PIPESTATUS[0]}"
git grep --untracked -n -i -E '\bcr[e]ase\b|CR[E]-[0-9]|you-are-he[a]r|echospher[e]' -- CHANGELOG.md; echo "names=$?"
```
Expected: no `bash -n failed` line; `verification: kit sub-block complete`; `verification: done`; `exit=0`;
`names=1`. (`--untracked` because `CHANGELOG.md` is not added until Step 8, and a plain `git grep` skips an
untracked file, so it would print `names=1` whatever the file said.)

- [ ] **Step 8: Commit**

```bash
git add CHANGELOG.md .claude/rules/cbk-conventions-reference.md
git commit -F - <<'EOF'
docs(V10): CHANGELOG.md — v0.1.0 to v1.0.0, each release with its Sync notes

One section per tag: harvest 1 with everything before it, harvest 2, axis parity, harvest 3's
four PRs, harvest 4, and v1.0.0. Each section records what landed and the Sync notes a target
follows by hand. v1.0.0's notes name every file a filled target must hand-merge, and say that
files run ahead of the kit take v1.0.0 as their merge base. They also record which action
release first resolves each family alias to the 5.5 models. A simulated sync of a named
target's filled .claude/ from 74edf84 to this branch leaves no conflicting file unnamed. The
block pins a section per tag.

Trace: release/6, #67/c5881158070/2c, #69/c5859756889/apply-h4/5, #69/c5901496433/sync-note
(the v1.0.0 note), #69/c5859756889/apply-h4/1, #69/c5859756889/apply-h4/2,
#69/c5859756889/apply-h4/3 and #69/c5859756889/apply-h4/6 (the v0.5.0 notes),
#70/table/mise-mcp-row (the release-notes line), #60/c5881158391/status (the note for a target
that customized its ADR hook); the v1.0.0 notes handed in by V1 (the runner a copy row with a
third rail, its fixture an add row, the check task, the reference glob, the CLAUDE.md check keyed
on blueprint.md), V2 (the path-independent ADR deny and its helper, the three backstop slots,
the refused payload, the cd behaviour probe P1 settled, the re-copied ADR job, the new
fixtures), V4 (the review workflows), V5 (the orchestration pair, the knowledge-backend split
and its none-axis disposition, the heading rename), V6 (#69/c5881157875/2-fable5-misprice, the
runner's fills), V8 (#70/body/4, #70/body/5, #70/body/6a, #70/body/6b, #71/body/3) and V9 (the
issue-template re-copy, adr-new's Relation grains for #66/body/1, the qualified citations, the
D54 branch rule for #68/body/1a, the CI-skip wording for review/portability/36).

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

### Task V10.3: `README.md` — the tagged drop-in install, prerequisites, how a phase starts, and an inventory from the tree (release/3, release/4, review/consistency/1, /2, /6, /7, review/release/23, /25, /26, /27, /30, /61; the README parts of #60/c5892401033/helper, #69/body/F9, #69/body/finish-ab/N-arm, #69/body/finish-ab/runner, review/release/28, review/security/17, review/claude-code/13, review/release/29, review/release/63, review/consistency/40 (the `finish.md` sentence), review/consistency/51, and the License paragraph of review/release/64; D41, D60)

**Files:**
- Modify: `README.md` — thirteen replacements, each anchored on text only V10 edits
- Modify: `.claude/rules/cbk-conventions-reference.md` — one check at the kit sub-block's sentinel

**Interfaces:**
- Consumes: the tree after V1–V9 (Step 0 lists it); `CHANGELOG.md`'s newest release (Task V10.2); § Syncing the
  kit (Task V10.1); V5's `.claude/rules/simplification.md` § Plugin, which the plugin list points at instead of
  restating a Claude Code version; V3's `omitClaudeMd: true` on `Explore.md`; V8's `.mcp.json.example` server set
  and its `.gitignore` starter section.
- Produces: the install block under `### 1. Install the drop-in set from a tagged release`, with the line
  `KIT_VERSION=v1.0.0` and a single-line `curl -fsSL -o "$kit_tmp/kit.tar.gz" …` download. The master plan's
  Task F5 Step 5 runs that block against the real tag. It prints `Kit commit: v1.0.0 (<7-char sha>)`, the value
  scaffold's row records (Task V10.1).
- Produces: `## Upgrading`, which the install block's refusal message and the Gotchas line point at.
- Produces: the block sentences `README.md's inventory tree does not name <file>` and `README.md's install does not
  pin v<X.Y.Z>, the newest release in CHANGELOG.md`.

- [ ] **Step 0: Confirm the tree the README describes**

Run:
```bash
for d in commands agents hooks hooks/lib rules; do printf '%s: %s\n' "$d" "$(cd .claude/$d && LC_ALL=C ls | tr '\n' ' ')"; done
jq -r '.mcpServers | keys | join(" ")' .mcp.json.example
grep -c 'uvx' .mcp.json.example
jq -r '.enabledPlugins | keys | join(" ")' .claude/settings.json
grep -c '^## Plugin' .claude/rules/simplification.md
grep -c '2\.1\.154' .claude/rules/simplification.md
grep -c '^omitClaudeMd: true$' .claude/agents/Explore.md
grep -c '^model: haiku$' .claude/agents/Explore.md
grep -c 'run-verification-block\.sh' .claude/skills/blueprint/references/templates/tooling.md
grep -c 'CLAUDE_CODE_OAUTH_TOKEN' .claude/skills/blueprint/references/templates/claude-review.yml
grep -c '^## `.gitignore`' .claude/skills/scaffold/references/github-starter-templates.md
for s in scaffold blueprint framing rough-in adr-new consultation; do printf '%s=%s ' "$s" "$(grep -c '^disable-model-invocation: true' .claude/skills/$s/SKILL.md)"; done; echo
```
Expected:
```
commands: enrich.md finish-procedure.md finish.md intake.md pr-respond.md 
agents: Explore.md adr-conformance-reviewer.md cascade-rule-reviewer.md logging-discipline-reviewer.md 
hooks: analyze-on-edit.sh detect-forked-agent-memory.sh format-on-edit.sh guard-pr-state.sh lib protect-immutable-adrs.sh protect-lock-files.sh protect-main-branch.sh require-knowledge-backend-ok.sh require-repo-root-for-agents.sh 
hooks/lib: resolve-path.sh 
rules: cbk-conventions-reference.md cbk-conventions.md knowledge-backend-reference.md knowledge-backend.md logging.md orchestration-reference.md orchestration.md pr-review-reference.md pr-review.md simplification.md testing.md tooling.md workflows.md 
context7 linear notion time
<a count>
commit-commands@claude-plugins-official pr-review-toolkit@claude-plugins-official
<eight counts>
scaffold=1 blueprint=1 framing=1 rough-in=1 adr-new=1 consultation=0
```
The listing is five commands, four agents, nine hooks and `lib/resolve-path.sh`, and thirteen rules. Every
`<count>` line must be at least `1`. A `0`, or a different set, means a sentence below describes something that
did not land: stop and reconcile that sentence first.

- [ ] **Step 1: Add the failing checks to the block**

**Replace** in `.claude/rules/cbk-conventions-reference.md` *(whole line; the kit sub-block's sentinel)*:
````text
echo "verification: kit sub-block complete"
````
with:
````text
# Releases (V10): on the kit tree, README.md's inventory names every command, agent, hook, sourced hook helper and rule
# the kit ships, and its install pins the newest release CHANGELOG.md records.
if [ ! -f docs/cbk/scaffold.md ]; then
  for f in .claude/commands/*.md .claude/agents/*.md .claude/hooks/*.sh .claude/hooks/lib/*.sh .claude/rules/*.md; do [ -e "$f" ] || continue; grep -qF -- "── $(basename "$f") " README.md || { echo "README.md's inventory tree does not name $f"; exit 1; }; done
  newest=$(awk 'match($0, /^## \[[0-9]+\.[0-9]+\.[0-9]+\]/){print substr($0, 5, RLENGTH-5); exit}' CHANGELOG.md)
  grep -qx "KIT_VERSION=v$newest" README.md || { echo "README.md's install does not pin v$newest, the newest release in CHANGELOG.md"; exit 1; }
fi

echo "verification: kit sub-block complete"
````

- [ ] **Step 2: Run the block — red**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected at execution, with V2's helper in the tree:
```
README.md's inventory tree does not name .claude/hooks/lib/resolve-path.sh
verification: block exited 1
exit=1
```
(On the planning copy, which has no `lib/` and twelve rules, every shipped name was already in the tree, so the
version pin reded instead: `README.md's install does not pin v1.0.0, the newest release in CHANGELOG.md`. The
planning copy with a stub `lib/resolve-path.sh` added reded on the line above.) Record the first line.

- [ ] **Step 3: D60's install test — red**

`$S/install-test.sh` (full content):
````bash
#!/usr/bin/env bash
# D60's local test: archive the branch head the way GitHub archives a tag, run README.md's install
# block against that archive in a scratch repository, and check that only the drop-in set lands,
# that nothing the target already had is touched, and that the printed Kit commit names the head.
# Usage: bash install-test.sh <kit checkout>. Writes only under mktemp -d.
set -uo pipefail
kit=$(cd "$1" && pwd) || exit 2
t=$(mktemp -d) || exit 2
trap 'rm -rf "$t"' EXIT
fail() { echo "FAIL: $*"; exit 1; }
git -C "$kit" archive --format=tar.gz --prefix=context-builder-kit-1.0.0/ -o "$t/archive.tar.gz" HEAD || exit 2
awk '/^### 1\. Install the drop-in set/{s=1;next} s&&/^```bash$/{c=1;next} c&&/^```$/{exit} c' "$kit/README.md" > "$t/install.sh"
grep -q '^curl -fsSL -o "\$kit_tmp/kit.tar.gz" ' "$t/install.sh" || fail "README.md's install block has no single-line curl download to swap for the local archive"
sed -i.bak 's|^curl -fsSL -o "\$kit_tmp/kit.tar.gz" .*|cp "'"$t"'/archive.tar.gz" "$kit_tmp/kit.tar.gz"|' "$t/install.sh"
mkdir "$t/target" && cd "$t/target" && git init -q . || exit 2
for f in README.md LICENSE CLAUDE.md .gitignore; do printf 'the target'"'"'s own %s\n' "$f" > "$f"; done
out=$(bash "$t/install.sh" 2>&1) || fail "the install block exited non-zero: $out"
for f in README.md LICENSE CLAUDE.md .gitignore; do grep -qx "the target's own $f" "$f" || fail "the install overwrote the target's $f"; done
find . -path ./.git -prune -o -type f -print | sed 's|^\./||' | sort > "$t/landed"
{ git -C "$kit" ls-tree -r --name-only HEAD .claude; printf '%s\n' .mcp.json.example .github/dependabot.yml.example .github/workflows/adr-immutability-check.yml README.md LICENSE CLAUDE.md .gitignore; } | sort > "$t/expected"
diff "$t/expected" "$t/landed" > "$t/diff" || { cat "$t/diff"; fail "the files that landed are not exactly the drop-in set plus the target's own four"; }
want="Kit commit: v1.0.0 ($(git -C "$kit" rev-parse --short=7 HEAD))"
grep -qxF "$want" <<<"$out" || fail "the install printed '$out', not '$want'"
[ -e .claude ] && { out2=$(bash "$t/install.sh" 2>&1); grep -q 'already exists' <<<"$out2" || fail "a second run over an existing .claude/ did not refuse"; }
echo "install test: $(wc -l < "$t/landed") files, only the drop-in set landed; printed '$want'"
````

Run: `bash "$S/install-test.sh" "$PWD"; echo "exit=$?"`

Expected:
```
FAIL: README.md's install block has no single-line curl download to swap for the local archive
exit=1
```

- [ ] **Step 4: Verify the README's quotations raw**

Run:
```bash
for p in model-config mcp discover-plugins skills sub-agents; do curl -sL "https://code.claude.com/docs/en/$p.md" -o "$S/$p.md"; done
norm "$S/model-config.md" | grep -cF 'Sonnet 5.5 requires Claude Code v2.1.284 or later, and Opus 5.5 requires v2.1.280 or later'
norm "$S/mcp.md" | grep -cF '`${VAR}`: expands to the value of environment variable `VAR`'
norm "$S/mcp.md" | grep -cF 'Check `.mcp.json` into version control so everyone on your team gets the same MCP tools and services'
norm "$S/mcp.md" | grep -cF "A cloned repository can't approve its own servers"
norm "$S/mcp.md" | grep -cF '⏸ Pending approval'
norm "$S/mcp.md" | grep -cF 'Use `/mcp` to authenticate with remote servers that require OAuth 2.0 authentication'
norm "$S/discover-plugins.md" | grep -cF '/plugin install commit-commands@claude-plugins-official'
norm "$S/skills.md" | grep -cF 'Use for workflows you want to trigger manually with `/name`'
norm "$S/sub-agents.md" | grep -cF 'A user or project subagent named `Explore` overrides the built-in and keeps its own `model` field'
norm "$S/sub-agents.md" | grep -cF 'Set to `true` to launch this subagent without the user, project, and local CLAUDE.md files'
tr -s ' \n' '  ' < LICENSE | grep -cF 'You must give any other recipients of the Work or Derivative Works a copy of this License'
```
Expected: eleven lines, each a count of at least `1`. A `0` means the page changed: re-read it, and correct or
drop that sentence before Step 5 writes it.

- [ ] **Step 5: Rewrite the README**

Make these thirteen replacements in `README.md`, in order. Every old text is verbatim from `README.md` at
`74edf84`, which no other cluster edits.

**1. The tagline.** **Replace** *(whole line 3)*:
````text
> Take an idea from *"I want to make X"* to a merged PR. Six Claude Code skills, one slash command, two reviewer agents, and a small set of rules — drop into any repo and pick the entry point that fits your moment.
````
with:
````text
> Take an idea from *"I want to make X"* to a merged PR. Claude Code skills for each phase, slash commands that execute and feed them, reviewer agents, guard hooks and a small set of rules — install them into any repo and pick the entry point that fits your moment.
````

**2. The Quick start, and a new `## Upgrading`.** **Replace** *(whole lines 27–54)*:
````markdown
## Quick start

The kit assumes [Claude Code](https://claude.com/claude-code), `git`, and ideally [`mise`](https://mise.jdx.dev/) installed.

```bash
# 1. Drop the kit into your repo
cd your-project
curl -L https://github.com/<your-fork>/context-builder-kit/archive/main.tar.gz \
  | tar xz --strip-components=1
# (Or git submodule, or just `cp -r` from a clone — pick what fits your repo.)

# 2. Customize the conventions file with your project's specifics
$EDITOR .claude/rules/cbk-conventions.md
# Fill in <TEAM>, <workstream-slug> placeholders; stamp the paths: globs in
# logging.md and testing.md; delete the template callouts once you're done.

# 3. Configure MCP servers (cascade reads from .mcp.json)
cp .mcp.json.example .mcp.json
$EDITOR .mcp.json   # fill in PATs, API keys

# 4. Install the Claude Code plugins the kit depends on
#    (See "Required dependencies" below for the canonical list.)

# 5. Open Claude Code in the repo and start. Pick an entry point — see below.
claude
```

That's it. The kit is in place; what you do next depends on where you are in the project.
````
with:
````markdown
## Quick start

### Prerequisites

| Tool | Used by | Without it |
|---|---|---|
| [Claude Code](https://claude.com/claude-code) 2.1.284 or later | Everything. The kit's model defaults name Opus 5.5 and Sonnet 5.5, and "Sonnet 5.5 requires Claude Code v2.1.284 or later, and Opus 5.5 requires v2.1.280 or later" (`https://code.claude.com/docs/en/model-config`, read 2026-09-30) | A request for either model fails |
| `git` | Every phase, every hook, the install and the sync | Nothing runs |
| `bash` 3.2 or later | The hooks, the fixtures and the verification block; the hooks use no bash-4 builtins, so a stock macOS bash runs them | The hooks cannot run |
| `jq` | Every hook whose header's `Depends:` line names it, and the verification block | Each of those guards fails open, allowing the action with a warning that names its backstop, and the block exits non-zero |
| `gh`, authenticated | `/finish`, `/intake`, `/enrich`, `/pr-respond` and the phases' issue writes on the `github-issues` axis; `gh` is the kit's GitHub interface | The `github-issues` axis cannot write issues or pull requests |
| `node` | The verification block's `.mjs` fixtures, the workflow scripts, and any `npx`-launched server in `.mcp.json` | The block exits non-zero |
| `python3` | `agent-cost.py`, `run-arms-headless.py`, and the fixtures the block runs for them | The block exits non-zero |
| `uv` | The `time` MCP server, which `.mcp.json.example` launches through `uvx` | The optional `time` server does not start |
| [`mise`](https://mise.jdx.dev/), optional | The task runner blueprint's tooling template defaults to | Nothing: any runner that defines a `check` task works |
| A `CLAUDE_CODE_OAUTH_TOKEN` Actions secret | The review workflows blueprint emits when scaffold's PR question chose automated review | Those workflows fail at their action step |

v1.0.0 was checked on Claude Code 2.1.285. To list what is missing on a machine: `for t in git jq gh node python3 uv; do command -v "$t" >/dev/null || echo "missing: $t"; done`.

### 1. Install the drop-in set from a tagged release

Run this at your repository's root. It copies only the drop-in set — `.claude/`, `.mcp.json.example`, `.github/dependabot.yml.example` and `.github/workflows/adr-immutability-check.yml` — and never touches your `README.md`, `LICENSE`, `CLAUDE.md`, `.gitignore` or `docs/`. It prints the release to record. To install from a fork, change the owner in the URL.

```bash
KIT_VERSION=v1.0.0
kit_tmp=$(mktemp -d)
curl -fsSL -o "$kit_tmp/kit.tar.gz" "https://github.com/j4th/context-builder-kit/archive/refs/tags/$KIT_VERSION.tar.gz"
tar -xzf "$kit_tmp/kit.tar.gz" -C "$kit_tmp" --strip-components=1
if [ -e .claude ]; then
  echo "A .claude/ already exists here, so nothing was copied: upgrade it instead (see Upgrading)."
else
  cp -R "$kit_tmp/.claude" .
  cp "$kit_tmp/.mcp.json.example" .
  mkdir -p .github/workflows
  cp "$kit_tmp/.github/dependabot.yml.example" .github/
  cp "$kit_tmp/.github/workflows/adr-immutability-check.yml" .github/workflows/
  echo "Kit commit: $KIT_VERSION ($(gunzip -c "$kit_tmp/kit.tar.gz" | git get-tar-commit-id | cut -c1-7))"
fi
rm -rf "$kit_tmp"
```

The printed `Kit commit:` line is the release you installed, and the base of every later sync. Scaffold records it as the **Kit commit** row of `docs/cbk/scaffold.md`. If you start at blueprint or later, record it yourself in `.claude/rules/cbk-conventions-reference.md` § Syncing the kit, and create `docs/adr/` from the starters that scaffold would have copied: `mkdir -p docs/adr && cp .claude/skills/scaffold/references/adr-starters/*.md docs/adr/`. Then fill ADR-0000's `Date:` and `Deciders:` by hand, because the ADR guard denies the agent's edits to an existing ADR.

The install leaves your `.gitignore` alone: add the harness block from `.claude/skills/scaffold/references/github-starter-templates.md` § `.gitignore` to it yourself.

### 2. Fill the conventions

```bash
$EDITOR .claude/rules/cbk-conventions.md
```

Fill in the `<TEAM>` and `<workstream-slug>` placeholders, stamp the `paths:` globs in `logging.md` and `testing.md` and the bracketed manifest-and-lockfile entry in `cbk-conventions-reference.md`'s `paths:`, and delete the template callouts once you're done. Scaffold's bootstrap checklist walks the rest of the rule files; in a filled target, an unstamped glob turns the verification block red.

### 3. Configure the MCP servers

```bash
cp .mcp.json.example .mcp.json
$EDITOR .mcp.json   # delete the servers your axes do not use
git add .mcp.json
```

`.mcp.json` is committed, because it holds `${VAR}` references and never a secret. The mcp page says "`${VAR}`: expands to the value of environment variable `VAR`", and "Check `.mcp.json` into version control so everyone on your team gets the same MCP tools and services" (`https://code.claude.com/docs/en/mcp`, read 2026-09-30). Export each variable the file references before launching `claude`, and name them in a committed `.env.example`. A hosted server that requires OAuth signs in through `/mcp`.

### 4. Install the plugins

In a Claude Code session:

```
/plugin install pr-review-toolkit@claude-plugins-official
/plugin install commit-commands@claude-plugins-official
```

These are the two `enabledPlugins` keys in `.claude/settings.json` (`https://code.claude.com/docs/en/discover-plugins`, read 2026-09-30). `/simplify` ships with Claude Code and needs no install.

### 5. Open Claude Code and start a phase

```bash
claude
```

On the first launch, accept the workspace trust dialog. "A cloned repository can't approve its own servers": until the workspace is trusted, the `enabledMcpjsonServers` list committed in `.claude/settings.json` is ignored and each server waits at `⏸ Pending approval` (`https://code.claude.com/docs/en/mcp`, read 2026-09-30). Once it is trusted, the servers that list names are approved; approve any other server in `.mcp.json` when Claude Code asks. Then start from where you are (next section).

That's it. The kit is in place; what you do next depends on where you are in the project.

## Upgrading

A repository that carries the kit upgrades by release, never by re-extracting over its filled files. Read `CHANGELOG.md` from the release your **Kit commit** row names up to the one you are moving to: each release's **Sync notes** say what to do by hand. Then follow `.claude/rules/cbk-conventions-reference.md` § Syncing the kit — a file-by-file table first, then a three-way `git merge-file` per file, with the kit at your recorded release as the base. Record the new release when the sync merges.
````

**3. The entry-point table gains a Run column, and how a phase starts.** **Replace** *(whole lines 60–69)*:
````markdown
| Where you are | Start at | Skip the cascade above? |
|---|---|---|
| **Vague idea, no repo** ("I want to build something that does X") | `consultation` | No — full cascade |
| **Clear-ish idea, no repo** (problem is shaped, you can describe it in a paragraph) | `scaffold` | Skip consultation; provide a verbal brief or paste one |
| **Existing repo, ready to set up workspace + architecture** | `blueprint` | Skip consultation + scaffold; commit a brief manually if you don't have one |
| **Architecture decided, ready to plan a specific workstream** | `framing` | Skip everything above; **needs `blueprint.md` § Workstreams** |
| **Small project — milestones obvious, just want issues** | `rough-in` ⚠️ *experimental* | Skip framing too; **brittle without a `frame-NN.md`** |
| **One concrete issue ready to implement** | `/finish <N>` | Issue must already have rough-in's eight-section body shape; backend planning axes only |

**Most users start at `blueprint`.** Consultation is HITL-heavy and works fine in plain Claude.ai chat; scaffold is mostly provisioning that's faster to do in a browser tab. The cascade's value compounds from `blueprint` forward, where the artifacts start versioning into your repo and the next phase actually inherits from disk.
````
with:
````markdown
| Where you are | Start at | Run | Skip the cascade above? |
|---|---|---|---|
| **Vague idea, no repo** ("I want to build something that does X") | `consultation` | Describe the idea in chat | No — full cascade |
| **Clear-ish idea, no repo** (problem is shaped, you can describe it in a paragraph) | `scaffold` | `/scaffold` | Skip consultation; provide a verbal brief or paste one |
| **Existing repo, ready to set up workspace + architecture** | `blueprint` | `/blueprint` | Skip consultation + scaffold; commit a brief manually if you don't have one |
| **Architecture decided, ready to plan a specific workstream** | `framing` | `/framing` | Skip everything above; **needs `blueprint.md` § Workstreams** |
| **Small project — milestones obvious, just want issues** | `rough-in` ⚠️ *experimental* | `/rough-in` | Skip framing too; **brittle without a `frame-NN.md`** |
| **One concrete issue ready to implement** | `/finish <N>` | `/finish <N>` | Issue must already have rough-in's eight-section body shape; backend planning axes only |

**How a phase starts.** `consultation` is the one skill Claude invokes on its own: describing an idea is enough. `scaffold`, `blueprint`, `framing`, `rough-in` and `adr-new`, and the commands `/finish`, `/intake`, `/enrich` and `/pr-respond`, carry `disable-model-invocation: true`. The skills page describes that setting as "Use for workflows you want to trigger manually with `/name`" (`https://code.claude.com/docs/en/skills`, read 2026-09-30): describing the intent does not start them, so type the command.

**Most users start at `blueprint`.** Consultation is HITL-heavy and works fine in plain Claude.ai chat; scaffold is mostly provisioning that's faster to do in a browser tab. The cascade's value compounds from `blueprint` forward, where the artifacts start versioning into your repo and the next phase actually inherits from disk.
````

**4. Exercised vs designed, restamped.** The one real run on the `github-issues` axis used issues, native
sub-issues and labels and recorded `**Project board** | **None.** Deliberate` in its `docs/cbk/scaffold.md`
(`j4th/you-are-hear` at `1d4d52a`), so the board contract stays designed-unexercised. **Replace** *(whole line 119)*:
````markdown
**Exercised vs designed** (recorded 2026-08-09 — the honest status per configuration, per the kit's exercised-not-provisional principle): `Linear` planning is the **exercised reference configuration** — a full real cascade ran on it end-to-end. `GitHub Issues` planning has the kit's deepest documentation and is designed first-class, but no real cascade run has exercised it yet (its Projects v2 board contract is marked designed-unexercised inline). `In-repo markdown` is design-doc mode by design. On the knowledge axis, `none` is effectively exercised daily; `Notion` is a complete contract, configured in the reference run and lightly exercised.
````
with:
````markdown
**Exercised vs designed** (restamped 2026-09-30 — the honest status per configuration, per the kit's exercised-not-provisional principle): `Linear` planning is exercised end-to-end by more than one real cascade run. `GitHub Issues` planning is exercised by a real run through issues, native sub-issues, labels and the review workflows; that run chose no Projects v2 board, so the board contract stays marked designed-unexercised inline. `In-repo markdown` is design-doc mode by design. On the knowledge axis, `none` is effectively exercised daily; `Notion` is a complete contract, configured in a real run and lightly exercised.
````

**5. The scaffold example shows the Kit commit row.** **Replace** *(whole lines 129–130)*:
````markdown
**Repo**: github.com/you/tuitor
**Project board**: github.com/you/tuitor/projects/4
````
with:
````markdown
**Repo**: github.com/you/tuitor
**Project board**: github.com/you/tuitor/projects/4
**Kit commit**: v0.5.0 (74edf84)
````

**6. Blueprint names the roadmap it writes.** **Replace** *(whole line 158)*:
````markdown
**Phase 3** — most complex of the cascade. Inherits the brief and the scaffold output, then makes the load-bearing calls: stack (language, framework, storage, testing), methodology (Shape Up, Kanban, Scrum), and produces six prose foundation docs plus tooling configs.
````
with:
````markdown
**Phase 3** — most complex of the cascade. Inherits the brief and the scaffold output, then makes the load-bearing calls: stack (language, framework, storage, testing), methodology (Shape Up, Kanban, Scrum), and produces six prose foundation docs — seven on the `github-issues` and `in-repo-markdown` axes, where `docs/cbk/ROADMAP.md` joins them — plus tooling configs. `ROADMAP.md` is the freely mutable status surface that framing, rough-in and `/finish` update.
````

**7. The bottom-up lane gets a paragraph.** **Replace** *(whole lines 281–283)*:
````markdown
**`/finish` does NOT**: modify the issue body; handle re-rough-in; bypass dependencies; skip either half of the review floor (`/simplify`, `pr-review-toolkit:review-pr` — both as skills, recorded in the `## Review gate` block); mark the PR ready; merge. When the spec is wrong or something is missing, `/finish` surfaces and aborts rather than improvising.

## What the kit ships
````
with:
````markdown
**`/finish` does NOT**: modify the issue body; handle re-rough-in; bypass dependencies; skip either half of the review floor (`/simplify`, `pr-review-toolkit:review-pr` — both as skills, recorded in the `## Review gate` block); mark the PR ready; merge. When the spec is wrong or something is missing, `/finish` surfaces and aborts rather than improvising.

### The bottom-up lane — `/intake`, `/enrich`, `/pr-respond`

The cascade runs top-down; externally sourced work comes in from the side. `/intake <ref>` turns a bug report or feature request into a shaped, `/finish`-able issue: it investigates, reproduces, classifies and shapes, and never lands code. `/enrich <N>` is rough-in for a single small capability, skipping the framing milestone. `/pr-respond <N>` closes the review loop on a PR: it triages every comment, applies what the rubric says to apply, and answers every thread. Which work skips framing and which stays framed is `cbk-conventions.md` § Contribution intake.

## What the kit ships
````

**8. What the kit ships: the tree from the drop-in set, and what is not installed.** **Replace** *(whole lines
285–347)*:
`````markdown
```
.claude/
├── commands/
│   ├── finish.md                      ← Phase 6 executor slash command (the contract)
│   ├── finish-procedure.md            ← its procedure, read on demand
│   ├── intake.md                      ← bottom-up entry: external report → /finish-able issue
│   ├── enrich.md                      ← rough-in for one small capability
│   └── pr-respond.md                  ← the PR feedback-loop executor
├── skills/
│   ├── consultation/                  ← Phase 1
│   ├── scaffold/                      ← Phase 2 (+ references/adr-starters/ incl. corrections.md, references/issue-templates/, the .github starter bodies, the cascade-events index template)
│   ├── blueprint/                     ← Phase 3 (+ references/templates/: the foundation docs, roadmap.md, the review workflows claude-review.yml + claude.yml)
│   ├── framing/                       ← Phase 4 (+ references/contract.md, references/procedure.md)
│   ├── rough-in/                      ← Phase 5 (+ references/contract.md, references/procedure.md; references/finish-command.md + finish-procedure.md, the bundled executor pair)
│   └── adr-new/                       ← ADR scaffolder (used by blueprint and onward)
├── agents/
│   ├── adr-conformance-reviewer.md    ← dispatched on every review pass
│   ├── logging-discipline-reviewer.md ← same
│   ├── cascade-rule-reviewer.md       ← same
│   └── Explore.md                     ← cheap-tier search exemplar
├── hooks/
│   ├── protect-immutable-adrs.sh      ← hard-deny: edits to existing ADRs
│   ├── protect-lock-files.sh          ← hard-deny: hand edits to lock files
│   ├── protect-main-branch.sh         ← hard-deny: git commit on main
│   ├── require-repo-root-for-agents.sh ← hard-deny: Task/Agent/Workflow dispatch outside the repo root
│   ├── guard-pr-state.sh              ← ask-gate: gh pr ready/merge/close/reopen
│   ├── require-knowledge-backend-ok.sh ← ask-gate: knowledge-backend MCP writes
│   ├── detect-forked-agent-memory.sh  ← stop: a reviewer-memory tree outside the root blocks the hand-off
│   ├── format-on-edit.sh              ← advisory exemplar (unregistered; stanza in settings.json)
│   └── analyze-on-edit.sh             ← advisory exemplar (unregistered; stanza in settings.json)
├── rules/
│   ├── cbk-conventions.md             ← project conventions — contract half (template; you fill this)
│   ├── cbk-conventions-reference.md   ← its path-scoped reference half
│   ├── orchestration.md               ← model × effort tiering — contract half (template)
│   ├── orchestration-reference.md     ← its path-scoped reference half
│   ├── pr-review.md                   ← review floor, roster, rubric — contract half
│   ├── pr-review-reference.md         ← its path-scoped reference half (calibration tables)
│   ├── testing.md                     ← three-regime testing (path-scoped; stamp the globs)
│   ├── logging.md                     ← structured logging (path-scoped; stamp the glob)
│   ├── simplification.md              ← /simplify contract
│   ├── workflows.md                   ← agent workflow patterns (portable)
│   ├── tooling.md                     ← tool-selection skeleton (template)
│   └── knowledge-backend.md           ← Notion-axis contract (delete with its hook when the axis is none)
├── workflows/
│   ├── review-sweep.js                ← find-then-verify review orchestration
│   ├── finish-ab/                     ← two-arm A/B harness exemplar (worktree-isolated arms, balanced blind judges)
│   ├── agent-cost.py                  ← per-agent cost reader for a run's transcripts
│   └── tests/                         ← stub harnesses for the workflows (no agent dispatched)
└── settings.json                      ← hook registration + plugin/MCP manifest

docs/adr/
├── README.md                          ← ADR index (starter — just ADR-0000)
├── template.md                        ← ADR template
└── 0000-record-architecture-decisions.md  ← meta-ADR establishing immutability (scaffold fills its header)

.github/workflows/
└── adr-immutability-check.yml         ← CI gate enforcing ADR-0000 at raw-git level

CLAUDE.md                              ← kit-level instructions for Claude Code
.mcp.json.example                      ← MCP server config template
```

Each skill follows the same pattern: a `SKILL.md` entrypoint plus a `references/` directory with templates and operational reference docs (failure modes, question banks, axis-specific behavior, inheritance discipline). The three producing phases — framing, rough-in and `/finish` — are contract-first: `references/contract.md` (for the executor, `commands/finish.md` itself) is the drafting read, `references/procedure.md` (`commands/finish-procedure.md`) the step-by-step on demand, and `SKILL.md` routes. Skills load `references/*.md` lazily on demand.
`````
with:
`````markdown
```
.claude/
├── commands/
│   ├── finish.md                      ← Phase 6 executor slash command (the contract)
│   ├── finish-procedure.md            ← its procedure, read on demand
│   ├── intake.md                      ← bottom-up entry: external report → /finish-able issue
│   ├── enrich.md                      ← rough-in for one small capability
│   └── pr-respond.md                  ← the PR feedback-loop executor
├── skills/
│   ├── consultation/                  ← Phase 1
│   ├── scaffold/                      ← Phase 2 (+ references/adr-starters/, the docs/adr/ starters incl. corrections.md; references/issue-templates/, the .github starter bodies, the cascade-events index template)
│   ├── blueprint/                     ← Phase 3 (+ references/templates/: the foundation docs, roadmap.md, the review workflows claude-review.yml + claude.yml)
│   ├── framing/                       ← Phase 4 (+ references/contract.md, references/procedure.md)
│   ├── rough-in/                      ← Phase 5 (+ references/contract.md, references/procedure.md; references/finish-command.md + finish-procedure.md, the bundled executor pair)
│   └── adr-new/                       ← ADR scaffolder (used by blueprint and onward)
├── agents/
│   ├── adr-conformance-reviewer.md    ← dispatched on every review pass
│   ├── logging-discipline-reviewer.md ← same
│   ├── cascade-rule-reviewer.md       ← same
│   └── Explore.md                     ← a Haiku-pinned override of the built-in Explore, with omitClaudeMd (delete it to keep the built-in)
├── hooks/
│   ├── protect-immutable-adrs.sh      ← hard-deny: edits to existing ADRs, however the path is spelled
│   ├── protect-lock-files.sh          ← hard-deny: hand edits to lock files
│   ├── protect-main-branch.sh         ← hard-deny: git commit on main
│   ├── require-repo-root-for-agents.sh ← hard-deny: Task/Agent/Workflow dispatch outside the repo root
│   ├── guard-pr-state.sh              ← ask-gate: gh pr ready/merge/close/reopen
│   ├── require-knowledge-backend-ok.sh ← ask-gate: knowledge-backend MCP writes
│   ├── detect-forked-agent-memory.sh  ← stop: a reviewer-memory tree outside the root blocks the hand-off
│   ├── format-on-edit.sh              ← advisory exemplar (unregistered; its Register: stanza is in its header)
│   ├── analyze-on-edit.sh             ← advisory exemplar (unregistered; its Register: stanza is in its header)
│   └── lib/
│       └── resolve-path.sh            ← the path resolver the ADR guard sources (sourced, never run)
├── rules/
│   ├── cbk-conventions.md             ← project conventions — contract half (template; you fill this)
│   ├── cbk-conventions-reference.md   ← its path-scoped reference half
│   ├── orchestration.md               ← model × effort tiering — contract half (template)
│   ├── orchestration-reference.md     ← its path-scoped reference half
│   ├── pr-review.md                   ← review floor, roster, rubric — contract half
│   ├── pr-review-reference.md         ← its path-scoped reference half (calibration tables)
│   ├── knowledge-backend.md           ← Notion-axis contract — contract half (delete both halves with its hook when the axis is none)
│   ├── knowledge-backend-reference.md ← its path-scoped reference half
│   ├── testing.md                     ← three-regime testing (path-scoped; stamp the globs)
│   ├── logging.md                     ← structured logging (path-scoped; stamp the glob)
│   ├── simplification.md              ← /simplify contract
│   ├── workflows.md                   ← agent workflow patterns (portable)
│   └── tooling.md                     ← tool-selection skeleton (template)
├── workflows/
│   ├── review-sweep.js                ← find-then-verify review orchestration
│   ├── finish-ab/                     ← A/B harness exemplar: two to four worktree-isolated arms, a balanced blind judge panel, and run-arms-headless.py, which runs each arm as a headless session
│   ├── agent-cost.py                  ← per-agent cost reader for a run's transcripts
│   └── tests/                         ← the verification runner and every fixture the block runs (hooks, CI job bodies, review-bot templates, workflow scripts, run-arms-headless-fixture.sh among them)
└── settings.json                      ← hook registration + plugin/MCP manifest

.github/
├── dependabot.yml.example             ← Dependabot configuration to copy, with the settle-window floor
└── workflows/
    └── adr-immutability-check.yml     ← CI gate enforcing ADR-0000 at raw-git level

.mcp.json.example                      ← MCP server config template
```

That is the drop-in set the Quick start installs; scaffold then writes `docs/adr/` from `references/adr-starters/`. The rest of this repository is the kit's own and is never installed: `README.md`, `CHANGELOG.md`, `CLAUDE.md` (instructions for working on the kit), `LICENSE`, `.gitignore`, `.github/workflows/verify.yml` (the kit's CI) and `docs/` (the kit's own decision records and harvest designs).

Each skill follows the same pattern: a `SKILL.md` entrypoint plus a `references/` directory with templates and operational reference docs (failure modes, question banks, axis-specific behavior, inheritance discipline). The three producing phases — framing, rough-in and `/finish` — are contract-first: `references/contract.md` (for the executor, `commands/finish.md` itself) is the drafting read, `references/procedure.md` (`commands/finish-procedure.md`) the step-by-step on demand, and `SKILL.md` routes. Skills load `references/*.md` lazily on demand.
`````

**9. Plugins by their install ids, the MCP servers without GitHub, the conventions without the `mise run
check` claim.** **Replace** *(whole lines 353–384)*:
````markdown
### Claude Code plugins

Listed declaratively in `.claude/settings.json` under `enabledPlugins`. Install each via Claude Code's plugin system before running `/finish`:

- **`pr-review-toolkit`** — `/finish`'s review pass dispatches `pr-review-toolkit:review-pr` for the auto-triage sweep
- **`/simplify`** — `/finish`'s simplify pass invokes it before the review pass. It is a **bundled Claude Code skill**, not a plugin (verified against the installed CLI bundle, Claude Code 2.1.263, 2026-09-06 — re-verify after harness upgrades), so it is deliberately absent from `enabledPlugins`; add `"simplify": true` there only if your install ships it as a plugin
- **`commit-commands`** — convenient wrappers for staging + committing (used by examples in this kit's docs)

The slash commands and skills these provide are referenced by name in `/finish` and the rules files; if your install uses different identifiers, edit the references.

### MCP servers

Listed declaratively in `.claude/settings.json` under `enabledMcpjsonServers`. Configure in `.mcp.json` (copy from `.mcp.json.example`):

- **`github`** — required by every cascade phase that writes to a GitHub repo. PAT with repo + read:project scopes (classic) or fine-grained PAT with Contents/Metadata write + Issues/Pull-requests write per repo.
- **`linear`** — required only when the planning backend is Linear.
- **`notion`** (Notion's official MCP, `notion.com/help/notion-mcp`) — required only when the knowledge backend is Notion. Used by every phase that reads from or writes to the knowledge backend.
- **`context7`** — used by framing and rough-in research phases for library/framework doc lookups. Reduces stale-knowledge errors when the cascade picks dependencies.
- **`time`** — optional, used by skills that need ISO-8601 conversions or timezone math.

If an expected MCP is missing, the cascade falls back to manual / web-search paths and surfaces the gap.

### Project conventions

The kit's load-bearing assumption is that your project has — or will have, after `blueprint` runs — these surfaces:

- A task runner (`mise.toml` is what `/finish` references in `mise run check`; if you use `Makefile` or `justfile`, edit `/finish` to match)
- `docs/STANDARDS.md` with a quality bar and CI Pipeline table
- The twelve files under `.claude/rules/`: the contract + reference pairs for conventions, orchestration and review; `testing.md` and `logging.md` (path-scoped — stamp their globs); `simplification.md`; `workflows.md` (portable); `tooling.md` (a template); and `knowledge-backend.md` for the Notion axis. `/finish` and the reviewer agents reference them by name.
- ADR scaffolding under `docs/adr/` (we ship the starter; `adr-new` skill maintains it)

If your project uses a different layout, the kit still works but `/finish` becomes the friction point — edit it after dropping the kit in. See "Customization" below.
````
with:
````markdown
### Claude Code plugins

Listed in `.claude/settings.json` under `enabledPlugins`, keyed `<plugin>@<marketplace>`. Install each in a Claude Code session before running `/finish` (Quick start, step 4):

- **`pr-review-toolkit@claude-plugins-official`** — `/finish`'s review pass invokes `pr-review-toolkit:review-pr`, one half of the review floor
- **`/simplify`** — `/finish`'s simplify pass invokes it before the review pass; it is the other half of the floor. It is a skill bundled with Claude Code, not a plugin, so it is deliberately absent from `enabledPlugins`. Its version history is recorded once, in `.claude/rules/simplification.md` § Plugin
- **`commit-commands@claude-plugins-official`** — convenient wrappers for staging and committing (used by examples in this kit's docs)

The slash commands and skills these provide are referenced by name in `/finish` and the rules files; if your install uses different identifiers, edit the references.

### MCP servers

`.mcp.json.example` lists each server with a comment on what uses it; `enabledMcpjsonServers` in `.claude/settings.json` names the ones approved for the project. Copy the example to `.mcp.json` and commit it (Quick start, step 3):

- **`linear`** (hosted; sign in through `/mcp`, OAuth in the browser) — required only when the planning backend is Linear.
- **`notion`** (Notion's official MCP, `notion.com/help/notion-mcp`) — required only when the knowledge backend is Notion. Used by every phase that reads from or writes to the knowledge backend. Keep the key `notion`: the knowledge-backend ask-gate matches that server's tool names.
- **`context7`** — used by framing and rough-in research phases for library/framework doc lookups. Reduces stale-knowledge errors when the cascade picks dependencies.
- **`time`** (launched through `uvx` at the version `.mcp.json.example` pins; needs `uv`) — optional, used by skills that need ISO-8601 conversions or timezone math.

There is no GitHub server: the kit's GitHub interface is the `gh` CLI (`.claude/rules/tooling.md` § Planning backend). If an expected MCP is missing, the cascade falls back to manual / web-search paths and surfaces the gap.

### Project conventions

The kit's load-bearing assumption is that your project has — or will have, after `blueprint` runs — these surfaces:

- A `check` task in whatever task runner the project uses: `/finish` runs "the project's `check` task", and blueprint's tooling template defaults to `mise` and makes the verification runner a task `check` depends on
- `docs/STANDARDS.md` with a quality bar and CI Pipeline table
- The files under `.claude/rules/`: the contract and reference pairs for conventions, orchestration, review and the knowledge backend; `testing.md` and `logging.md` (path-scoped — stamp their globs); `simplification.md`; `workflows.md` (portable); and `tooling.md` (a template). `/finish` and the reviewer agents reference them by name.
- ADR scaffolding under `docs/adr/` (scaffold writes it from the starters; the `adr-new` skill maintains it)

If your project uses a different layout, record it in `cbk-conventions.md`: `/finish` reads the conventions and needs no edit of its own. See "Customization" below.
````

**10. Customization: `finish.md` needs no edit, the budget figure is the block's, the Explore override.**
**Replace** *(whole lines 392–401)*:
````markdown
2. **`.claude/commands/finish.md`** — bakes in the project's `check` task, `docs/STANDARDS.md § Step 4`, `.claude/rules/testing.md`, `.claude/rules/logging.md`, `pr-review-toolkit:review-pr`, `/simplify`. If your stack doesn't have one of these, edit the file. The eight-section spec contract that `/finish` reads from issue bodies is the stable interface; the tooling assumptions are the swap-out point.

3. **`.claude/settings.json`** — adjust `enabledPlugins` if your installed identifiers differ; adjust `enabledMcpjsonServers` if you don't use one of the five defaults or want to add others. Never add a hook-shaped object as a top-level key while doing so — the advisory hooks' registration stanzas live in their headers (see `.claude/rules/cbk-conventions-reference.md` § Hook authoring).

4. **`.claude/rules/logging.md` and `.claude/rules/testing.md`** — stamp the `paths:` globs at the top with your project's real extensions; they ship as placeholders and a placeholder glob loads nothing. The always-loaded rule set at the kit's current sha totals the figure the verification block prints (`always-loaded total: … bytes`; 130,628 at harvest 4) — the number a fresh target starts from before path-scoping its own rules. Then settle a disposition for each template rule (`orchestration.md`, `tooling.md`, and the bracketed entry in `cbk-conventions-reference.md`'s `paths:`): fill, path-scope, or delete — see `cbk-conventions.md` § Rule loading and the instruction budget.

Optional further customization:
- Add project-local reviewer agents under `.claude/agents/` (the kit ships `adr-conformance-reviewer`, `logging-discipline-reviewer` and `cascade-rule-reviewer`; add your own for project-specific concerns).
- Tune `pr-review.md`'s Apply/Surface calibration as you learn what's noisy in your project's PRs.
- If you don't use ADRs, delete `docs/adr/` and remove the hook registration from `settings.json`.
````
with:
````markdown
2. **`.claude/commands/finish.md`** — needs no edit. It runs the project's `check` task in whatever runner defines it, and reads the foundation docs and the rules that bind the diff. What a project customizes is what those name: the `check` task, the foundation docs blueprint writes, and the `paths:` globs in `testing.md` and `logging.md`. The eight-section spec contract that `/finish` reads from issue bodies is the stable interface. A project that must diverge carries the change as a named exception (`.claude/rules/cbk-conventions-reference.md` § Syncing the kit) and edits the bundled copy, `.claude/skills/rough-in/references/finish-command.md`, in the same commit, because the verification block diffs the pair.

3. **`.claude/settings.json`** — adjust `enabledPlugins` if your installed identifiers differ (keys are `<plugin>@<marketplace>`); adjust `enabledMcpjsonServers` to the servers your `.mcp.json` keeps. Never add a hook-shaped object as a top-level key while doing so — the advisory hooks' registration stanzas live in their headers (see `.claude/rules/cbk-conventions-reference.md` § Hook authoring).

4. **`.claude/rules/logging.md` and `.claude/rules/testing.md`** — stamp the `paths:` globs at the top with your project's real extensions; they ship as placeholders and a placeholder glob loads nothing. The verification block prints the always-loaded rule set and its total (`always-loaded total: … bytes`): the number a fresh target starts from before path-scoping its own rules, which `CHANGELOG.md` records per release. Then settle a disposition for each template rule (`orchestration.md`, `tooling.md`, and the bracketed entry in `cbk-conventions-reference.md`'s `paths:`): fill, path-scope, or delete — see `cbk-conventions.md` § Rule loading and the instruction budget.

Optional further customization:
- Add project-local reviewer agents under `.claude/agents/` (the kit ships `adr-conformance-reviewer`, `logging-discipline-reviewer` and `cascade-rule-reviewer`; add your own for project-specific concerns).
- Keep or delete `.claude/agents/Explore.md`. It overrides Claude Code's built-in Explore agent — "A user or project subagent named `Explore` overrides the built-in and keeps its own `model` field" — with one pinned to `model: haiku` and set to `omitClaudeMd: true`, which launches it "without the user, project, and local CLAUDE.md files" (`https://code.claude.com/docs/en/sub-agents`, read 2026-09-30). Delete it to keep the built-in.
- Tune `pr-review.md`'s Apply/Surface calibration as you learn what's noisy in your project's PRs.
- If you don't use ADRs, delete `docs/adr/` and remove the hook registration from `settings.json`.
````

**11. The upgrade gotcha.** **Replace** *(whole line 430)*:
````markdown
**No upgrade mechanism yet.** When the kit revises, re-pull manually. A future addition might be a `mise run cbk:update` task that fetches from the public repo, but that's down the road.
````
with:
````markdown
**Upgrade by release, never by re-extracting.** Re-running the install over a repository that carries the kit would replace your filled files; the sync keeps them. See Upgrading.
````

**12. The version statement.** **Replace** *(whole line 437)*:
````markdown
- **Not finished.** Some operations along the Linear-planning and Notion-knowledge paths have documentation gaps (the kit falls back to manual where MCP-based ops aren't fully documented). The kit is at evergreen v0 — usable, but expect rough edges and surface them.
````
with:
````markdown
- **Not finished.** Some operations along the Linear-planning and Notion-knowledge paths have documentation gaps (the kit falls back to manual where MCP-based ops aren't fully documented). The kit is at v1.0.0 — versioned, with a sync path between releases in `CHANGELOG.md` — and still has rough edges; surface them.
````

**13. License and Contributing.** **Replace** *(whole lines 452–458)*:
````markdown
## License

See [LICENSE](LICENSE).

## Contributing

Issues and PRs welcome. The kit is itself a work-in-progress and rough edges are expected — surface them.
````
with:
````markdown
## License

Apache License 2.0 — see [LICENSE](LICENSE). The files you install from the kit stay under it; its section 4 sets what redistributing them requires, starting with "You must give any other recipients of the Work or Derivative Works a copy of this License". The kit's licence does not choose your project's own: scaffold asks for that separately (`.claude/rules/cbk-conventions-reference.md` § Licensing).

## Contributing

Issues and PRs welcome. The kit is itself a work-in-progress and rough edges are expected — surface them. A change that alters what a target syncs adds its entry, with its Sync notes, under `CHANGELOG.md`'s `## [Unreleased]` heading.
````

Then restamp what only the execution day knows:
```bash
cc=$(claude --version | awk '{print $1}'); [ "$cc" = 2.1.285 ] || sed -i "s/^v1\.0\.0 was checked on Claude Code 2\.1\.285\./v1.0.0 was checked on Claude Code $cc./" README.md
today=$(date -u +%F); [ "$today" = 2026-09-30 ] || sed -i -e "s/read 2026-09-30/read $today/g" -e "s/(restamped 2026-09-30 /(restamped $today /" README.md
```

- [ ] **Step 6: Run the install test, the gate and the sanitization greps — green**

Run:
```bash
bash "$S/install-test.sh" "$PWD"; echo "install=$?"
for h in .claude/hooks/*.sh .claude/hooks/lib/*.sh; do bash -n "$h" || echo "bash -n failed: $h"; done
bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E '^verification: '; echo "exit=${PIPESTATUS[0]}"
git grep -n -i -E '\bcr[e]ase\b|CR[E]-[0-9]|you-are-he[a]r|echospher[e]' -- README.md; echo "names=$?"
grep -nE '(^|[[:space:](,;])#[0-9]{1,3}([^0-9]|$)' README.md; echo "bare=$?"
```
Expected: `install test: <N> files, only the drop-in set landed; printed 'Kit commit: v1.0.0 (<HEAD's short sha>)'`
(134 files on the planning copy; more once V1–V9's files are in), `install=0`; no `bash -n failed` line;
`verification: kit sub-block complete`, `verification: done`, `exit=0`; `names=1`; `bare=1`.

- [ ] **Step 7: Commit**

```bash
git add README.md .claude/rules/cbk-conventions-reference.md
git commit -F - <<'EOF'
docs(V10): README — install the drop-in set from a tagged release, and say how to start a phase

The Quick start no longer extracts the whole repository over a target. It copies only the
drop-in set (.claude/, .mcp.json.example, .github/dependabot.yml.example and the ADR job) from
a tagged archive, refuses when a .claude/ already exists, and prints the Kit commit to record.
A new Upgrading section replaces "no upgrade mechanism". Prerequisites name what each absence
costs, and the entry table says how each phase starts. The inventory is recounted from the
tree, with the helper, the knowledge-backend pair, the N-arm harness and the kit-only files
named. The finish.md customisation paragraph, the advisory-stanza line, the plugin ids, the
MCP servers and the secret handling match the tree. The block pins the inventory and the pinned
version, and a local archive of the branch head proves only the drop-in set lands.

Trace: release/3, release/4, review/consistency/1, review/consistency/2, review/consistency/6,
review/consistency/7, review/release/23, review/release/25, review/release/26,
review/release/27, review/release/30, review/release/61, review/release/64 (the License
paragraph); README parts of #60/c5892401033/helper, #69/body/F9, #69/body/finish-ab/N-arm,
#69/body/finish-ab/runner, review/release/28, review/security/17, review/claude-code/13,
review/release/29, review/release/63, review/consistency/40 (the finish.md sentence, handed from
V3), review/consistency/51 (V9.18's count wording); the README lines V8 handed in for
#70/body/6a and #70/body/6b (the linear and time notes), and V1's reference-glob line in step 2.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

### Task V10.4: This repository's `CLAUDE.md` — the gate, the release rule, the R14 audit, and the commands' posture (release/8, review/release/65, #58/c5901493591/R14, review/claude-code/14, critic/9, the CLAUDE.md parts of #60/c5892401033/helper, #69/body/finish-ab/N-arm and review/release/63, release/5 for V10's own files; D41, D53, D57)

**Files:**
- Modify: `CLAUDE.md` — eight replacements
- Modify: `.claude/rules/cbk-conventions-reference.md` — one check at the kit sub-block's sentinel

**Interfaces:**
- Consumes: V3's `disable-model-invocation: true` and `arguments:` frontmatter on all five commands (V3 hands the
  posture sentence to this task); V2's `lib/resolve-path.sh`; V5's `knowledge-backend-reference.md`; V6's
  `run-arms-headless.py`; V3's `omitClaudeMd: true` on `Explore.md`; `CHANGELOG.md` (Task V10.2).
- Produces: `CLAUDE.md` § Working in this repo's bullets `**Releases are tags, and `CHANGELOG.md` is the upgrade
  contract.**` and `**A harvest closes by its trace, not by impression.**`, the gate every future harvest runs.
- Produces: the block sentence `CLAUDE.md does not name <word> (its gate, its release record and its harvest
  audit)`, and a check that `README.md` and `CLAUDE.md` cite no issue by a bare number. V9's bare-citation check
  covers the shipped kit files; these two are V10's, and `CHANGELOG.md` is exempt by design (Task V10.2).
- `CLAUDE.md` stays well under the ~200-line bloat line (102 lines at `74edf84`, 113 after; the layout keeps its code fence).

- [ ] **Step 0: Confirm what the text names**

Run:
```bash
grep -l '^disable-model-invocation: true' .claude/commands/*.md | wc -l
grep -l '^arguments:' .claude/commands/*.md | wc -l
ls .claude/hooks/lib/resolve-path.sh .claude/rules/knowledge-backend-reference.md .claude/workflows/finish-ab/run-arms-headless.py CHANGELOG.md
grep -c '^omitClaudeMd: true$' .claude/agents/Explore.md
grep -c '^model: haiku$' .claude/agents/Explore.md
curl -sL https://code.claude.com/docs/en/skills.md -o "$S/skills.md"
norm "$S/skills.md" | grep -cF 'such as `$0` for the first argument or `$1` for the second'
```
Expected: `5`, `5`, the four paths listed without error, `1`, `1`, `1`. Anything else: stop and reconcile the
sentence that names it (a `0` on the last line means the skills page changed: re-read it, and correct or drop the
quotation in passage 8 before writing it). If the day is not 2026-09-30, restamp the one date passage 8 writes, after
Step 3: `today=$(date -u +%F); sed -i "s|(\`https://code.claude.com/docs/en/skills\`, read 2026-09-30)|(\`https://code.claude.com/docs/en/skills\`, read $today)|" CLAUDE.md`.

- [ ] **Step 1: Add the failing checks to the block**

**Replace** in `.claude/rules/cbk-conventions-reference.md` *(whole line; the kit sub-block's sentinel)*:
````text
echo "verification: kit sub-block complete"
````
with:
````text
# Releases (V10): on the kit tree, CLAUDE.md names the gate, the release record and the harvest audit, and the
# kit-only front door (README.md, CLAUDE.md) cites no issue by a bare number.
if [ ! -f docs/cbk/scaffold.md ]; then
  for w in 'run-verification-block.sh' 'CHANGELOG.md' 'refute-by-default'; do grep -qF -- "$w" CLAUDE.md || { echo "CLAUDE.md does not name $w (its gate, its release record and its harvest audit)"; exit 1; }; done
  absent grep -nE '(^|[[:space:](,;])#[0-9]{1,3}([^0-9]|$)' README.md CLAUDE.md
fi

echo "verification: kit sub-block complete"
````

- [ ] **Step 2: Run the block — red**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"`

Expected:
```
CLAUDE.md does not name run-verification-block.sh (its gate, its release record and its harvest audit)
verification: block exited 1
exit=1
```
Record the first line. (The bare-citation half was mutation-tested while planning: a line `see #58 here`
appended to `README.md` printed `README.md:526:see #58 here` and `VIOLATION (matched above): grep -nE …`.)

- [ ] **Step 3: Rewrite the eight passages**

**1. What this repo is.** **Replace** *(whole line 7)*:
````markdown
`context-builder-kit` is **not a software project** — it is a kit that exports a set of Claude Code skills, commands, and rule files used to walk an idea from "raw thought" through to "automatically executed code issue." Everything in this repo is markdown content consumed by Claude Code itself; there is no code to build, no test suite to run, no application to start.
````
with:
````markdown
`context-builder-kit` is **not a software project** — it is a kit that exports a set of Claude Code skills, commands, and rule files used to walk an idea from "raw thought" through to "automatically executed code issue." Most of it is markdown consumed by Claude Code itself. The rest is the code that enforces it — bash hooks, JavaScript workflow scripts and Python harness scripts, each with a fixture — and the verification block that runs every fixture. There is nothing to build and no application to start.
````

**2. The deliverable is the drop-in set.** **Replace** *(whole line 9)*:
````markdown
The deliverable is the contents of `.claude/` — the cascade skills (`consultation`, `scaffold`, `blueprint`, `framing`, `rough-in`), the `/finish` slash command, the `adr-new` skill, and the example project-rules file. They are designed to be installed (copied or symlinked) into target projects' `.claude/` directories.
````
with:
````markdown
The deliverable is the drop-in set: `.claude/` — the cascade skills (`consultation`, `scaffold`, `blueprint`, `framing`, `rough-in`), the `adr-new` skill, the `/finish` executor and the contribution-lane commands, the reviewer agents, the hooks, the rules and the workflows — plus `.mcp.json.example`, `.github/dependabot.yml.example` and `.github/workflows/adr-immutability-check.yml`. A target installs it from a tagged release (`README.md` § Quick start) and syncs it release by release (`CHANGELOG.md`, and `.claude/rules/cbk-conventions-reference.md` § Syncing the kit). Everything else here — `README.md`, `CHANGELOG.md`, this file, `LICENSE`, `.gitignore`, `.github/workflows/verify.yml` and `docs/` — is the kit's own and is never installed.
````

**3. The layout, with the helper, the split rules, the harness, `.github/`, `docs/` and the changelog.**
**Replace** *(whole lines 32–51, inside the layout's code fence)*:
````text
```
.claude/
├── commands/
│   ├── finish.md                  ← the executor slash-command (phase 6) — the contract
│   ├── finish-procedure.md        ← the executor's procedure, read on demand
│   ├── intake.md                  ← bottom-up entry: externally-sourced report → /finish-able issue
│   ├── enrich.md                  ← rough-in for one small capability (enhancement lane, skips framing)
│   └── pr-respond.md              ← the PR feedback-loop executor (inverse of /finish)
├── agents/                        ← project-local PR reviewers (adr-conformance, logging-discipline, cascade-rule; memory-enabled) + Explore (cheap-tier search exemplar)
├── hooks/                         ← guards in four tiers: hard-deny (protect-immutable-adrs, protect-lock-files, protect-main-branch, require-repo-root-for-agents) + ask-gate (guard-pr-state, require-knowledge-backend-ok) + advisory exemplars, unregistered (format-on-edit, analyze-on-edit) + stop (detect-forked-agent-memory)
├── rules/                         ← operational contracts (cbk-conventions, pr-review — each split into an always-loaded contract and a path-scoped `-reference.md` half — plus testing, logging, simplification, knowledge-backend) and rule templates (tooling; orchestration, itself also split); workflows.md is portable
├── workflows/                     ← saved orchestrations (review-sweep: find-then-adversarially-verify review pass) and harness exemplars (finish-ab/ two-arm A/B, agent-cost.py) with their stub tests
└── skills/
    ├── consultation/SKILL.md      + references/ (notion_ingestion, frozen_corpus_ingestion, …)  ← phase 1
    ├── scaffold/SKILL.md          + references/ (adr-starters/ incl. corrections.md, issue-templates/, github-starter-templates.md, templates/cascade-events-index-template.md, …)  ← phase 2
    ├── blueprint/SKILL.md         + references/ (templates/ incl. roadmap.md, claude-review.yml, claude.yml, …)  ← phase 3
    ├── framing/SKILL.md           + references/ (contract.md, procedure.md, …)  ← phase 4
    ├── rough-in/SKILL.md          + references/ (contract.md, procedure.md, …)  ← phase 5
    └── adr-new/SKILL.md                           ← ADR scaffolder (used by target projects)
```
````
with:
````text
```
.claude/
├── commands/
│   ├── finish.md                  ← the executor slash-command (phase 6) — the contract
│   ├── finish-procedure.md        ← the executor's procedure, read on demand
│   ├── intake.md                  ← bottom-up entry: externally-sourced report → /finish-able issue
│   ├── enrich.md                  ← rough-in for one small capability (enhancement lane, skips framing)
│   └── pr-respond.md              ← the PR feedback-loop executor (inverse of /finish)
├── agents/                        ← project-local PR reviewers (adr-conformance, logging-discipline, cascade-rule; memory-enabled) + Explore (a Haiku-pinned override of the built-in Explore, with omitClaudeMd; delete it to keep the built-in)
├── hooks/                         ← guards in four tiers: hard-deny (protect-immutable-adrs, protect-lock-files, protect-main-branch, require-repo-root-for-agents) + ask-gate (guard-pr-state, require-knowledge-backend-ok) + advisory exemplars, unregistered (format-on-edit, analyze-on-edit) + stop (detect-forked-agent-memory); lib/resolve-path.sh is the path resolver the ADR guard sources
├── rules/                         ← operational contracts (cbk-conventions, pr-review, knowledge-backend — each split into an always-loaded contract and a path-scoped `-reference.md` half — plus testing, logging, simplification) and rule templates (tooling; orchestration, itself also split); workflows.md is portable
├── workflows/                     ← saved orchestrations (review-sweep: find-then-adversarially-verify review pass), harness exemplars (finish-ab/: a two-to-four-arm A/B workflow and run-arms-headless.py, its headless runner; agent-cost.py), and tests/: the verification runner and every fixture the block runs
└── skills/
    ├── consultation/SKILL.md      + references/ (notion_ingestion, frozen_corpus_ingestion, …)  ← phase 1
    ├── scaffold/SKILL.md          + references/ (adr-starters/ incl. corrections.md, issue-templates/, github-starter-templates.md, templates/cascade-events-index-template.md, …)  ← phase 2
    ├── blueprint/SKILL.md         + references/ (templates/ incl. roadmap.md, claude-review.yml, claude.yml, …)  ← phase 3
    ├── framing/SKILL.md           + references/ (contract.md, procedure.md, …)  ← phase 4
    ├── rough-in/SKILL.md          + references/ (contract.md, procedure.md, …)  ← phase 5
    └── adr-new/SKILL.md                           ← ADR scaffolder (used by target projects)
.github/
├── dependabot.yml.example         ← installed: the Dependabot configuration a target copies
└── workflows/
    ├── adr-immutability-check.yml ← installed: the ADR lint at raw-git level
    └── verify.yml                 ← the kit's own CI: runs the verification block on every pull request
docs/
├── adr/                           ← the ADR starters, byte-identical to scaffold's references/adr-starters/ (the block diffs them)
└── superpowers/                   ← each harvest's design spec, trace and implementation plans
CHANGELOG.md                       ← one section per release, each with the Sync notes a target follows
```
````

**4. There is a gate.** **Replace** *(whole line 77)*:
````markdown
Because there is no build/test/lint, the verification surface is editorial:
````
with:
````markdown
There is no build, but there is a gate. `bash .claude/workflows/tests/run-verification-block.sh` runs the verification block (`.claude/rules/cbk-conventions-reference.md` § Verification), which runs every fixture, `run-verification-block-fixture.sh` among them, the one that drives the runner's own rails; `.github/workflows/verify.yml` runs it on every pull request. It needs `bash`, `git`, `jq`, `node` and `python3`, and it is green after every commit. Beyond it, the verification surface is editorial:
````

**5. The release rule and the R14 audit, after the templates bullet.** **Replace** *(whole line 82)*:
````markdown
- **Templates live in `references/templates/`** and are quoted verbatim in skill output. Edits to a template change every future cascade artifact — treat them as the contract.
````
with:
````markdown
- **Templates live in `references/templates/`** and are quoted verbatim in skill output. Edits to a template change every future cascade artifact — treat them as the contract.
- **Releases are tags, and `CHANGELOG.md` is the upgrade contract.** A change that alters what a target syncs adds its entry under the changelog's `## [Unreleased]` heading, with a **Sync notes** line for anything a target must do by hand. A release renames that heading `## [X.Y.Z] — <date> — <harvest> (PR #<number>)`, where the date is the merge's in UTC and the number is the PR's, both confirmed just before the merge, and after the merge, with the operator's go-ahead, the merge commit is tagged `vX.Y.Z`, annotated. A major bump means a sync needs hand reconciliation beyond `git merge-file`, a minor bump is a harvest, and a patch is fixes only.
- **A harvest closes by its trace, not by impression.** Every ask a harvest takes in, an issue's body item or one row of a comment, gets one row in a trace file beside the design spec (`docs/superpowers/specs/<date>-harvest-<n>-trace.md`). The row carries the ask's location as `#<issue>/body/<item>` or `#<issue>/c<comment id>/<row>`, its cluster, whether it is live at the base commit, the decision it rests on, and a status that starts `open`. Before merge every row reads `landed <sha>` (the commit that names it), `non-goal` (named in the spec's § Non-goals) or `not holding` (re-checked at its commit and found not to hold, with a one-line reason). Then one fresh-context verifier, refute-by-default and read-only, tries to show that each row not marked `landed` was required and is still live at the branch head, and every row it refutes is landed. An issue closes only when every row for it is landed or a named non-goal (context-builder-kit#58, residue row R14).
````

**6. The knowledge-backend rule is split.** **Replace** *(whole line 95)*:
````markdown
- `knowledge-backend.md` — the operational contract for the knowledge-backend axis (read patterns, write tiering, HITL discipline, brownfield detection, lazy provisioning)
````
with:
````markdown
- `knowledge-backend.md` — the operational contract for the knowledge-backend axis (read patterns, write tiering, HITL discipline, brownfield detection, lazy provisioning), split like the conventions into a contract and a path-scoped half
````

**7. The path-scoped halves.** **Replace** *(whole line 98)*:
````markdown
- `cbk-conventions-reference.md`, `orchestration-reference.md`, `pr-review-reference.md` — the path-scoped halves; see `cbk-conventions.md` § Rule loading and the instruction budget
````
with:
````markdown
- `cbk-conventions-reference.md`, `orchestration-reference.md`, `pr-review-reference.md`, `knowledge-backend-reference.md` — the path-scoped halves; see `cbk-conventions.md` § Rule loading and the instruction budget
````

**8. The commands' invocation posture (handed from V3).** **Replace** *(inline, the end of line 102)*:
````markdown
(`adr-new` follows the same deliberate posture).
````
with:
````markdown
(`adr-new` follows the same deliberate posture). The five commands — `/finish`, `/intake`, `/enrich`, `/pr-respond` and `finish-procedure` — carry `disable-model-invocation: true` too, for the same reason: the four executors open branches, issues and pull requests, and `finish-procedure` is the executor's reference, not a step to run. A command that takes an argument declares it in `arguments:` frontmatter and reads it by name, because positional placeholders count from zero: "such as `$0` for the first argument or `$1` for the second" (`https://code.claude.com/docs/en/skills`, read 2026-09-30).
````

- [ ] **Step 4: Run the gate — green**

Run:
```bash
for h in .claude/hooks/*.sh .claude/hooks/lib/*.sh; do bash -n "$h" || echo "bash -n failed: $h"; done
bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E '^verification: '; echo "exit=${PIPESTATUS[0]}"
git grep -n -i -E '\bcr[e]ase\b|CR[E]-[0-9]|you-are-he[a]r|echospher[e]' -- CLAUDE.md; echo "names=$?"
wc -l < CLAUDE.md
```
Expected: no `bash -n failed` line; `verification: kit sub-block complete`, `verification: done`, `exit=0`;
`names=1`; `113`.

- [ ] **Step 5: Commit**

```bash
git add CLAUDE.md .claude/rules/cbk-conventions-reference.md
git commit -F - <<'EOF'
docs(V10): CLAUDE.md — the kit has a gate, releases are tags, and a harvest closes by its trace

"No code to build, no test suite" no longer holds: the kit ships hooks, JavaScript and Python,
each with a fixture, and the verification block runs them all. CLAUDE.md now names the runner,
the fixture that drives its rails, its tools and verify.yml. The deliverable is the drop-in set, and the layout adds the path
helper, the knowledge-backend pair, the N-arm harness, .github/, docs/ and CHANGELOG.md. Two
bullets make the release rule and the R14 trace audit the gate for every future harvest, and
the invocation-posture paragraph names the five invoke-only commands and why each reads its
argument by name. The block pins these names and keeps bare issue numbers out of README.md and
CLAUDE.md.

Trace: release/8, review/release/65 (with the runner's fixture, handed from V1),
#58/c5901493591/R14 and critic/9 (the CLAUDE.md codification of the audit, handed from V9),
review/claude-code/14 (the posture sentence, handed from V3), the CLAUDE.md parts of
#60/c5892401033/helper, #69/body/finish-ab/N-arm and review/release/63, release/5 (the check
on V10's own files).

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```

### Task V10.5: `LICENSE` names its copyright holder (review/release/64; D41)

**Files:**
- Modify: `LICENSE` — the appendix's copyright line
- Modify: `.claude/rules/cbk-conventions-reference.md` — one check at the kit sub-block's sentinel

**Interfaces:**
- Consumes: the operator's confirmation of the holder's name, and `README.md` § License (Task V10.3), which
  already tells a target what the licence asks of a redistributed copy.
- Produces: `Copyright 2026 <holder>` in place of `Copyright [yyyy] [name of copyright owner]`. 2026 is the year
  of the kit's first commit (`git log --reverse --format=%ad --date=format:%Y | head -1` prints `2026`).
- Produces: the block check `absent grep -nF '[name of copyright owner]' LICENSE` on the kit tree.
- No `NOTICE` file ships: the licence's section 4(d) binds a redistributor only to a NOTICE that exists, and the
  finding's other asks are the copyright line and the README paragraph.

- [ ] **Step 1: Add the failing check to the block**

**Replace** in `.claude/rules/cbk-conventions-reference.md` *(whole line; the kit sub-block's sentinel)*:
````text
echo "verification: kit sub-block complete"
````
with:
````text
# Releases (V10): on the kit tree, LICENSE names its copyright holder instead of the appendix's placeholder.
[ -f docs/cbk/scaffold.md ] || absent grep -nF '[name of copyright owner]' LICENSE

echo "verification: kit sub-block complete"
````

- [ ] **Step 2: Run the block — red**

Run: `bash .claude/workflows/tests/run-verification-block.sh 2>&1 | tail -3; echo "exit=${PIPESTATUS[0]}"`

Expected:
```
189:   Copyright [yyyy] [name of copyright owner]
VIOLATION (matched above): grep -nF [name of copyright owner] LICENSE
verification: block exited 1
exit=1
```
Record the second line.

- [ ] **Step 3: Confirm the holder with the operator**

Run: `git config user.name`
Expected: one line, the operator's configured name. Show the operator that name and the proposed line
`   Copyright 2026 <that name>`, and wait for an explicit yes. A different holder the operator gives replaces the
name. Nothing is written before the answer.

- [ ] **Step 4: Write the line**

**Replace** in `LICENSE` *(whole line 189, the appendix; three leading spaces)*:
````text
   Copyright [yyyy] [name of copyright owner]
````
with the confirmed line, written by:
```bash
holder=$(git config user.name)   # or the holder the operator named in Step 3
python3 - "$holder" <<'PY'
import sys
p = "LICENSE"
t = open(p, encoding="utf-8").read()
old = "   Copyright [yyyy] [name of copyright owner]\n"
assert t.count(old) == 1, "anchor"
open(p, "w", encoding="utf-8").write(t.replace(old, f"   Copyright 2026 {sys.argv[1]}\n"))
PY
git diff --stat LICENSE
```
Expected: ` LICENSE | 2 +-` and `1 file changed, 1 insertion(+), 1 deletion(-)`.

- [ ] **Step 5: Run the gate — green**

Run:
```bash
for h in .claude/hooks/*.sh .claude/hooks/lib/*.sh; do bash -n "$h" || echo "bash -n failed: $h"; done
bash .claude/workflows/tests/run-verification-block.sh 2>&1 | grep -E '^verification: '; echo "exit=${PIPESTATUS[0]}"
```
Expected: no `bash -n failed` line; `verification: kit sub-block complete`, `verification: done`, `exit=0`.

- [ ] **Step 6: Commit**

```bash
git add LICENSE .claude/rules/cbk-conventions-reference.md
git commit -F - <<'EOF'
docs(V10): LICENSE names its copyright holder

The appendix carried the licence's unfilled placeholder. The kit's files are copied into
other projects, and the licence those copies keep should say whose it is. README.md § License
already says what section 4 asks of a redistributed copy. The block keeps the placeholder out.

Trace: review/release/64.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
```
After the master plan's Task F4 pushes, confirm GitHub still detects the licence:
`gh api repos/j4th/context-builder-kit/license -q .license.spdx_id` prints `Apache-2.0`. If it prints anything
else, revert this commit's `LICENSE` hunk, restore the appendix placeholder, and put the copyright line in a
`NOTICE` file instead, in one follow-up commit that also removes the block check.

## Coverage

Every id in the V10 pack, then the rows of other clusters whose part lands in a file V10 owns.

| Id | Kind | Lands in |
|---|---|---|
| `release/1` | item | V10.1 — § Syncing the kit in versions, and the contract pointer |
| `release/2` | item | V10.1 — the Kit commit row, its guidance, the example, `SKILL.md`, the checklist row, Test 1; V10.3 shows the row in the README example |
| `release/3` | item | V10.3 — the README inventory from the tree (hooks/lib, the knowledge-backend pair, the N-arm harness, the fixtures, `.github/`, the kit-only files); V10.4 — `CLAUDE.md`'s layout |
| `release/4` | item | V10.3 — the tagged, drop-in-only install that prints the release to record |
| `release/5` | item | V10.1 — § Syncing the kit's own `#58`; V10.4 — the check that keeps bare numbers out of `README.md` and `CLAUDE.md`. Handed to V2, V4, V6, V7 and V9 for the citations in their files, and to V9 for the kit-wide check (see below) |
| `release/6` | item | V10.2 — `CHANGELOG.md` |
| `release/7` | item | Master plan Task F5 — the six annotated tags after merge, with the operator's go-ahead; V10.2's headings are their messages |
| `release/8` | item | V10.4 — `CLAUDE.md`'s layout and the Releases bullet. No Surface inventory row is added to the always-loaded contract (D50): § Syncing the kit's fallback (V10.1) covers an older target |
| `release/9` | item | Handed to V9 — the `docs/STANDARDS.md` citations in the executor procedure pair (spec § V9 Citations, D53) |
| `release/10` | item | Handed to V9 — `review/portability/31` removes the sibling name at § Hook authoring and adds the absent check; V10.3 and V10.4 prove `README.md` and `CLAUDE.md` clean (`names=1`) |
| `#60/c5892401033/helper` | handed in | V10.3 — `lib/resolve-path.sh` in the README tree; V10.4 — in `CLAUDE.md`'s hooks line |
| `#67/c5881158070/2c` | handed in | V10.2 — the v1.0.0 Sync note "The review model is the action's pin", verified raw in Step 4 |
| `#69/body/F9` | handed in | V10.3 — the README's `/simplify` bullet points at `simplification.md` § Plugin instead of restating 2.1.263 |
| `#69/body/finish-ab/N-arm` | handed in | V10.3 — the README's `finish-ab/` line; V10.4 — `CLAUDE.md`'s workflows line |
| `#69/body/finish-ab/runner` | handed in | V10.3 — `run-arms-headless.py` in the README tree |
| `#69/c5859756889/apply-h4/5` | handed in | V10.2 — the v0.5.0 Sync note on a review workflow that already had `checks: read` |
| `#69/c5901496433/sync-note` | handed in | V10.1 — the § Syncing bullet; V10.2 — the v1.0.0 note on files run ahead of the kit |
| `review/consistency/1` | review, verified | V10.1 and V10.3 — the sync is documented, the README says Upgrading and v1.0.0; the axis restamp is V10.3 (the board stamp: see Not holding) |
| `review/consistency/2` | review, verified | V10.3 — no counts in the tagline, the full tree, the kit-only files named, the `mise run check` claim and the byte figure removed, the bottom-up lane paragraph; the block pins the tree |
| `review/consistency/6` | review, verified | V10.3 — step 3 commits `.mcp.json` with `${VAR}` references. The example's `_comment`, `tooling.md` and blueprint's table are V8's (`review/release/28`) |
| `review/consistency/7` | review, verified | V10.3 — the drop-in set only |
| `review/release/23` | review, verified | V10.3 — a pinned tag of the canonical URL, the drop-in set only, `docs/adr/` left to scaffold or copied from the starters, the fork note, no submodule line. `.gitattributes` export-ignore was not adopted: the install copies named paths, and V10.3's test proves it |
| `review/release/25` | review, verified | V10.3 — the prerequisites table with each absence's cost, the Claude Code floor with its quotation, the version it was checked on, the one-line missing-tools check |
| `review/release/26` | review, verified | V10.3 — the README restamp (the board part: see Not holding) |
| `review/release/27` | review, verified | V10.3 — the advisory hooks' tree lines say the stanza is in the header |
| `review/release/30` | review, verified | V10.3 — `finish.md` needs no edit; the named-exception route and the pair diff |
| `review/release/61` | review, unverified | Holds (no `/blueprint` or `/scaffold` anywhere in `README.md` at `74edf84`). V10.3 — the Run column, how a phase starts, and the first-launch trust and approval |
| `review/release/64` | review, unverified | Holds (`LICENSE:189` is the unfilled placeholder). V10.5 — the copyright line; V10.3 — the README License paragraph |
| `review/release/65` | review, unverified | Holds (`CLAUDE.md:7` and `:77`). V10.4 |
| `#69/c5859756889/apply-h4/1` | V9 row, V10 file | V9 or V2 lands the § Hook authoring sentence; V10.1 cross-references it in § Syncing the kit; V10.2 records the v0.5.0 Sync note |
| `#69/c5859756889/apply-h4/2` | V9 row, V10 region | V10.1 — the § Syncing bullet; V10.2 — the v0.5.0 note |
| `#69/c5859756889/apply-h4/3` | V9 row, V10 region | V10.1 — `**No Kit commit row to read.**`; V10.2 — the v0.5.0 note |
| `#69/c5859756889/apply-h4/6` | V9 row, V10 file | V1 wires the runner into the templates (R4); V10.2 records the v0.5.0 note |
| `#71/body/1` | V8 row, V10 region | V10.1 — the formatter-scope bullet in § Syncing the kit, handed from V8 by the ownership map |
| `#70/table/mise-mcp-row` | V8 row, V10 file | V10.2 — the release-notes line V8's item asks for |
| `#58/c5901493591/R14` | V9 row, V10 file | V10.4 — the audit codified in `CLAUDE.md` § Working in this repo |
| `review/claude-code/13`, `review/release/29` | V3 rows, V10 file | V10.3 — the README's plugin list and step 4 use `<plugin>@claude-plugins-official` |
| `review/claude-code/14` | V3 row, V10 file | V10.4 — the posture sentence in `CLAUDE.md` |
| `review/release/63` | V3 row, V10 file | V10.3 — the Customization bullet on the Explore override, and the tree's `Explore.md` line in V3's words ("a Haiku-pinned override of the built-in Explore … delete it to keep the built-in"); V10.4 — the same words in `CLAUDE.md`'s agents line |
| `review/release/28`, `review/security/17` | V8 rows, V10 file | V10.3 — step 3's secret handling |
| `review/consistency/51` | V9 row, V10 file | V10.3 — the README's blueprint paragraph counts its docs in V9.18's words ("six prose foundation docs — seven on the `github-issues` and `in-repo-markdown` axes, where `docs/cbk/ROADMAP.md` joins them"); the count in blueprint's own files is V9's |
| `review/consistency/40` | V3 row, V10 file | V10.3 — Customization item 2: `finish.md` bakes in no `docs/STANDARDS.md § Step 4` and needs no edit (the same passage as `review/release/30`) |
| `critic/9` | V9 hand-off, V10 file | V10.4 — the R14 audit method in `CLAUDE.md` § Working in this repo (with `#58/c5901493591/R14`) |
| `#60/c5881158391/status` | V2 hand-off, V10 file | V10.2 — the Sync note for a target that customized its ADR hook: the kit's hook a `copy` row, `lib/resolve-path.sh` an `add` row, the tracked-helper check under **New files** |
| `#67/c5881158070/2c` and V4's shape changes | V4 hand-off, V10 file | V10.2 — the review-workflow hand-merge bullet: every changed line V4's § Handed to other clusters lists, the kept `REVIEW_LOGIN`, and the kit sub-block's fixtures now running against a target's filled workflow |
| `#69/c5881157875/2-fable5-misprice`, `#69/body/finish-ab/runner` (config fills) | V6 hand-off, V10 file | V10.2 — the "cost reader keys by model version" Sync note: legacy Fable 5 cache reads, `worktree_setup`, `WRITE_SERVERS` |
| `#70/body/4`, `#70/body/5`, `#70/body/6a`, `#70/body/6b`, `#71/body/3` | V8 hand-offs, V10 file | V10.2 — the Sync notes V8 wrote for V10: settle-window coverage, mise `[task_config]`, `.mcp.json`'s shape check and no GitHub entry, the `.gitignore` harness block; V10.3 — the `linear` and `time` notes in README § MCP servers. The `time` pin's release-day age check goes to Task F5 |
| V8's ruff correction (`#71/body/1`) | V8 hand-off, V10 region | V10.1 Step 5 — the quotation is the first clause of the sentence as the raw source writes it, cited at the raw URL it matches under `grep -F`, re-fetched 2026-09-30; the `force-exclude` exception is stated outside the quotation marks |
| V1 hand-off 7 (`#73/body/1`, `review/release/65`, `#69/c5859756889/apply-h4/6`) | V1 hand-off, V10 files | V10.3 — Quick start step 2 names `cbk-conventions-reference.md`'s manifest-and-lockfile glob; V10.2 — **A filled target owes both sentinels**: the runner a `copy` row with a third rail, its fixture an `add` row, the verification task in `check`, the reference glob stamped, the `CLAUDE.md` check keyed on `docs/cbk/blueprint.md`; V10.4 — passage 4 names `run-verification-block-fixture.sh` |
| V2 hand-off (`#60/c5892401033/helper`, `#60/c5881158391/status`, D61, P1) | V2 hand-off, V10 files | V10.3 and V10.4 — `hooks/lib/` in the tree and the layout; V10.2 — **The ADR guard judges what a path is**, **New files** (the tracked helper, the three hook fixtures and the others), **Fill the three hook backstop slots**, **An unreadable payload now denies**, the P1 note in the variant V2 applied (Step 0 detects it, Step 5 swaps it under variant A), and the re-copied ADR job's sub-bullet (three-dot, blobless, `shell: bash`) |
| V3 hand-off (`review/claude-code/14`, `review/release/29`, `#69/body/F9`, `review/release/63`, `review/consistency/40`) | V3 hand-off, V10 files | V10.4 passage 8 — the posture sentence, with the reason a command reads its argument by name quoted from the skills page (Step 0 verifies it); V10.3 — the plugin ids and install lines, `/simplify` pointing at `simplification.md` § Plugin, the Explore wording, the `finish.md` paragraph |
| V5 hand-off 8 (`#69/body/F9`, D59, `#67/c5881158070/2c`) | V5 hand-off, V10 files | V10.3 — `knowledge-backend-reference.md` in the tree (the count of rule files is dropped rather than restated) and the `/simplify` line; V10.4 — passages 6 and 7 name the split and the new half; V10.2 — the hand-merge sub-bullets for the orchestration pair (with the heading rename's citation sweep), `workflows.md`, `simplification.md`, `tooling.md` and the knowledge-backend pair (its `none`-axis disposition included), and the action-release note |
| V9 hand-off (Sync notes (a)–(e), `#69/c5859756889/apply-h4/2`, `/3`, `/5`, `/6`, `#69/c5901496433/sync-note`) | V9 hand-off, V10 files | V10.2 — **Re-copy the issue templates** (both copies, and the simulated sync now maps them), the `adr-new` sub-bullet's § Relation grains repoint, **Kit issue citations are qualified** (take the kit's side in the byte-copied files), and the `cbk-conventions.md` sub-bullet's D54 branch rule and CI-skip wording; V10.1 — § Syncing the kit, anchored on either citation spelling |

The pack's own `critic` list is empty; `critic/9` is handed in from V9 (above).

## Handed to other clusters

- **V2, V4, V6, V7, V9 — `release/5`.** Each rewrites the bare kit-issue citations in the files it owns, in the
  commit where it first edits them. V2: `detect-forked-agent-memory.sh` (six), `protect-lock-files.sh`,
  `require-repo-root-for-agents.sh`, and § Hook authoring's `#58` citations. V4: `claude-review.yml` (two). V6:
  `agent-cost.py`, `finish-ab.js`, `finish-ab-shape.mjs`. V7: `review-sweep.js` (three),
  `review-sweep-accounting.mjs`. V9: the remaining `cbk-conventions-reference.md` lines, `finish.md:21` with
  `finish-command.md:104`, `adr-new/SKILL.md:51`, and the kit-wide check. V9's check must not scan
  `CHANGELOG.md`, where bare numbers are this repository's own by design, nor `README.md` and `CLAUDE.md`, which
  V10.4 checks.
- **V9 — `release/9`.** The `docs/STANDARDS.md` citations in `finish-procedure.md` (lines 118, 136, 166, 221)
  and in its bundled copy, re-pointed at headings every target has.
- **V9 — `release/10`.** `review/portability/31` removes `you-are-hear #81 → PR #82` from § Hook authoring's
  stdin/exit bullet. V10.3 and V10.4 only prove `README.md` and `CLAUDE.md` clean.
- **V9 — the Projects v2 board stamp** (`review/release/26`, `review/consistency/1`). The four `backends.md`
  copies and `cbk-conventions-reference.md` § Recommended planning-backend settings keep "designed-unexercised",
  and are re-dated, not restamped: see Not holding.
- **V8 — `review/release/28`, `review/security/17`, `review/consistency/6`.** The example's `_comment`,
  `tooling.md` § MCP configuration, `blueprint-output-template.md`'s `.mcp.json (gitignored)` and
  `research-phase.md:85` agree with V10.3's step 3: committed, credentials as `${VAR}` references.
- **V8 — the formatter-scope surfaces.** `format-on-edit.sh`'s `.claude/workflows/` skip floor and the bootstrap
  checklist's formatter-scope row must land before V10.1, whose bullet names them as the rule's other locations.
  V8 hands `#71/body/1`'s § Syncing clause to V10.1 and does not write it.
- **V1.** `run-verification-block-fixture.sh` must keep running synthetic blocks: V10's kit-tree checks read
  `README.md`, `CHANGELOG.md`, `CLAUDE.md` and `LICENSE`, which a throwaway checkout without
  `docs/cbk/scaffold.md` would not carry.
- **Master plan, Task F2.** If a finding applied after V10.2 changes an always-loaded rule, re-run the runner and
  update the v1.0.0 always-loaded figure in `CHANGELOG.md` in that commit.
- **Master plan, Task F4 — the `[1.0.0]` heading's date and PR number.** Both are predictions V10.2 wrote: the
  execution day's UTC date and the next free number. F4 owns them.
  - When `gh pr create` returns, confirm its number equals the `(PR #75)` in `CHANGELOG.md`'s `[1.0.0]` heading.
  - On the day the operator merges, immediately before the squash-merge, re-date the heading to the merge's UTC
    date, and correct the number if it differed, in one commit on the branch (no CI-skip marker, so the branch
    still ends on a commit that runs CI):
    ```bash
    merged=$(date -u +%F); n=$(gh pr view --json number -q .number)
    sed -i -e "s/^\(## \[1\.0\.0\] — \)[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\( — .*\)$/\1$merged\2/" \
      -e "s/^\(## \[1\.0\.0\] — .*\) (PR #[0-9]*)$/\1 (PR #$n)/" CHANGELOG.md
    grep -c "^## \[1\.0\.0\] — $merged — harvest 5 (PR #$n)$" CHANGELOG.md
    ```
    Expected: `1`. If the heading already reads that date and number, `git diff --quiet CHANGELOG.md` exits 0 and
    there is nothing to commit. Otherwise commit `docs: date the v1.0.0 changelog heading to the merge`, run the
    runner once more, and merge only on green. If the merge slips past UTC midnight, re-run the block above.
  - After the push, run `gh api repos/j4th/context-builder-kit/license -q .license.spdx_id` and expect
    `Apache-2.0` (V10.5).
- **Master plan, Task F5.** Step 5 runs `README.md`'s install block, verbatim, into a scratch directory against
  the real `v1.0.0` tag, and checks that only the drop-in set lands and the printed `Kit commit:` sha equals
  `git rev-parse --short=7 v1.0.0^{}`. This confirms against GitHub what V10.3's local test, which archives a commit, cannot:
  that `git get-tar-commit-id` on GitHub's archive of an annotated tag returns the peeled commit. It did for
  `anthropics/claude-code-action`'s annotated tag `v1.0.236` on 2026-09-30. The install strips the archive's top
  directory whatever it is named. Also on release day, from V8: re-run
  `curl -sL https://pypi.org/pypi/mcp-server-time/json | jq -r '.releases["2026.8.18"][0].upload_time'` and confirm
  the `time` server's pin in `.mcp.json.example` is at least 7 days old.

## Not holding at planning time

- **Restamping the Projects v2 board contract as exercised** (a proposed fix in `review/consistency/1` and
  `review/release/26`). The axis-level claim in `README.md:119` is stale and V10.3 restamps it, but the board
  flag is still true. The one real `github-issues` run recorded `| **Project board** | **None.** Deliberate —
  labels, native sub-issues and a saved filter instead |` in its `docs/cbk/scaffold.md` (`j4th/you-are-hear`,
  `origin/main` at `1d4d52a`, read 2026-09-30), and the other two targets run Linear. The board stamp stays
  designed-unexercised, re-dated by V9. Re-check at execution with
  `git -C /home/j4th/Code/create/you-are-hear show origin/main:docs/cbk/scaffold.md | grep -n 'Project board'`.
- **A block check that every tracked top-level path is named in the README tree** (`review/consistency/2`'s
  proposed check). Taken as written, it reds on the kit-only paths that are deliberately not installed. V10.3's
  check covers what ships instead: every command, agent, hook, hook helper and rule. The README names the
  kit-only paths in prose.
- **A Claude Code version floor stated as tested** (`review/release/25`). No floor is tested. The README states
  the floor the documentation sets for the models the kit names (2.1.284), and the version v1.0.0 was checked
  on, as its verifier advised.

Every unverified finding in the pack (`review/release/61`, `/64`, `/65`) still held when checked against
`74edf84` while planning. Each is re-checked when its commit is made.
