#!/usr/bin/env bash
# Fixture for the review workflow's "Assert the review posted" step: runs the step's own `run:` body, extracted from
# the workflow by extract-run-block.sh (never a copy), with a fake `gh` first on PATH and a throwaway git repository
# standing in for the checkout. The comment pages are SYNTHETIC, authored here; no recorded project data ships. It
# checks blueprint's templates/claude-review.yml, and a filled .github/workflows/claude-review.yml where one exists.
# Asserts:
#   - a separate summary comment with a verdict passes, and so does a tracker comment that ends with the verdict;
#   - a summary on the second page of a 32-comment PR passes (the pages are slurped once, then counted; the fake
#     gh refuses --jq, which runs once per page);
#   - a summary written before the job started and edited after it passes (updated_at); one never touched since
#     then fails, and the failure names the start time;
#   - a tracker comment with no verdict fails, and the notice says the session ran and how to re-trigger; so does one
#     that names a verdict word in passing, unbolded: the marker is the bold verdict, not the word;
#   - every bold verdict the prompt prescribes, and its bold docs-only skip line, passes as a comment of its own; a
#     verdict after a label on its line ("Verdict: **APPROVE**") passes too;
#   - a verdict from another login does not count;
#   - an unreadable comment list fails and says so, whether `gh api` fails or answers with something not JSON;
#   - no session and this PR changing the workflow fails with the validation-skip notice, posted to the PR, and so
#     does a base that changed the workflow after the PR branched — the action compares contents, so the diff is
#     tree against tree, never from the merge base; no session with the workflow unchanged fails with the
#     auth-or-setup notice instead;
#   - structure: the step's condition is `${{ !cancelled() }}`, the job's first step records the start time, the
#     step reads it, and SESSION_RAN is keyed on the execution_file of the step with `id: review`;
#   - "Pick model + effort from labels", run on each label set: the precedence (deep over fast over the default, the
#     quoted token so `claude-deep-review-wip` is no deep label), and a dispatch rule that agrees with the tool list
#     on every path — a path that disallows the Agent tool tells the reviewer not to dispatch, the path that keeps it
#     says it may; the prompt reads that rule and states no dispatch rule of its own;
#   - "Record the resolved model", in both review templates: the step runs on `always()` when its action step wrote an
#     execution_file, with continue-on-error; on a synthetic execution file its job-summary line names the model the
#     session started on, its Claude Code version, every model that answered, and the alias and effort requested;
#     claude.yml's requested alias and effort equal the --model and --effort its claude_args pass;
#   - claude.yml gates bots and the skip-claude label in its job `if:`, before the concurrency group, never in a step:
#     a step runs after the job joined the group, so a bot comment with "@claude" in it cancelled the reply in flight.
# Each body runs the way GitHub runs a `shell: bash` step: bash --noprofile --norc -eo pipefail.
# Hermetic: mktemp trees only. Needs bash, git (2.28+, for `init -b`), jq.
# Run: bash .claude/workflows/tests/review-assert-fixture.sh
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../../.." && pwd)
command -v jq >/dev/null && command -v git >/dev/null || { echo "FAIL: review-assert-fixture needs jq and git"; exit 1; }
[ -f "$here/extract-run-block.sh" ] || { echo "FAIL: extract-run-block.sh is missing beside this fixture"; exit 1; }
# shellcheck source=extract-run-block.sh
. "$here/extract-run-block.sh"
type extract_run_block >/dev/null 2>&1 || { echo "FAIL: extract-run-block.sh defines no extract_run_block"; exit 1; }
wfs=("$root/.claude/skills/blueprint/references/templates/claude-review.yml")
[ -f "$root/.github/workflows/claude-review.yml" ] && wfs+=("$root/.github/workflows/claude-review.yml")

t=$(mktemp -d)
trap 'rm -rf "$t"' EXIT
mkdir -p "$t/bin"
cat > "$t/bin/gh" <<'EOF'
#!/usr/bin/env bash
# Fake gh: `gh api …` prints $FAKE_PAGES (or fails when FAKE_API_FAIL=1) and refuses --jq, which gh runs once per
# page; `gh pr comment … --body B` logs B.
case "$1" in
  api) case " $* " in *" --jq "*) echo "fake gh: --jq runs once per page; fetch the pages, then count them with jq -s" >&2; exit 2 ;; esac
       if [ "${FAKE_API_FAIL:-0}" = 1 ]; then echo "gh: HTTP 502" >&2; exit 1; fi; cat "$FAKE_PAGES" ;;
  pr) shift; while [ $# -gt 0 ]; do if [ "$1" = --body ]; then printf '%s\n' "$2" >> "$FAKE_POSTED"; fi; shift; done ;;
  *) echo "fake gh: unexpected: $*" >&2; exit 2 ;;
esac
EOF
chmod +x "$t/bin/gh"

# A checkout with a base and a head commit; `changed` makes HEAD differ in the workflow file the action validates.
repo() {  # repo <dir> <changed|same>
  git init -q -b main "$1"
  mkdir -p "$1/.github/workflows"; printf 'name: x\n' > "$1/.github/workflows/claude-review.yml"
  git -C "$1" add -A; git -C "$1" -c user.email=f@x -c user.name=f -c commit.gpgsign=false commit -q -m base
  if [ "$2" = changed ]; then printf 'name: y\n' > "$1/.github/workflows/claude-review.yml"; fi
  printf 'x\n' > "$1/other.txt"
  git -C "$1" add -A; git -C "$1" -c user.email=f@x -c user.name=f -c commit.gpgsign=false commit -q -m head
}
repo "$t/changed" changed; repo "$t/same" same
# The base moved: the base branch changed the workflow after the PR branched, and the PR leaves it alone.
git init -q -b main "$t/moved"; mkdir -p "$t/moved/.github/workflows"
printf 'name: x\n' > "$t/moved/.github/workflows/claude-review.yml"
g() { git -C "$t/moved" -c user.email=f@x -c user.name=f -c commit.gpgsign=false "$@"; }
g add -A; g commit -q -m base; g switch -q -c pr; printf 'x\n' > "$t/moved/other.txt"; g add -A; g commit -q -m head
g switch -q main; printf 'name: y\n' > "$t/moved/.github/workflows/claude-review.yml"; g add -A; g commit -q -m moved
g switch -q pr; moved_base=$(g rev-parse main)

# Synthetic comment pages: c <login> <created_at> <updated_at> <body> is one comment; page joins comments into one page.
c() { jq -cn --arg u "$1" --arg c "$2" --arg up "$3" --arg b "$4" '{user: {login: $u}, created_at: $c, updated_at: $up, body: $b}'; }
page() { local IFS=,; printf '[%s]\n' "$*"; }
S=2026-09-28T01:00:00Z   # the job's recorded start
BOT='claude[bot]'
page "$(c octocat 2026-09-28T00:59:00Z 2026-09-28T00:59:00Z 'Looks fine to me.')" \
     "$(c "$BOT" 2026-09-28T01:05:00Z 2026-09-28T01:05:00Z '**REQUEST CHANGES** — 2 Apply, 1 Surface')" > "$t/summary.json"
page "$(c "$BOT" 2026-09-28T01:01:00Z 2026-09-28T01:09:00Z $'**Claude finished the task in 3m 2s** — [View job](https://example/run)\n\n**APPROVE WITH NITS** — 3 Surface')" > "$t/tracker-verdict.json"
page "$(c "$BOT" 2026-09-28T01:01:00Z 2026-09-28T01:04:00Z '**Claude finished the task in 3m 2s** — [View job](https://example/run)')" > "$t/tracker.json"
page "$(c "$BOT" 2026-09-28T01:01:00Z 2026-09-28T01:06:00Z $'**Claude finished the task in 3m 2s** — [View job](https://example/run)\n\nThe diff reads like an APPROVE, but the turns ran out before the summary was posted.')" > "$t/tracker-mention.json"
page "$(c "$BOT" 2026-09-28T01:05:00Z 2026-09-28T01:05:00Z 'Verdict: **APPROVE WITH NITS** — 2 Surface')" > "$t/verdict-prefixed.json"
first=(); for i in $(seq 1 30); do first+=("$(c octocat "$S" "$S" "comment $i")"); done
{ page "${first[@]}"; page "$(c octocat "$S" "$S" 'comment 31')" "$(c "$BOT" 2026-09-28T01:05:00Z 2026-09-28T01:05:00Z '**NEEDS DISCUSSION**')"; } > "$t/paged.json"
page "$(c "$BOT" 2026-09-27T12:00:00Z 2026-09-28T01:02:00Z '**APPROVE** — no findings')" > "$t/edited.json"
page "$(c "$BOT" 2026-09-27T12:00:00Z 2026-09-27T12:00:00Z '**APPROVE** — no findings')" > "$t/stale.json"
page "$(c 'github-actions[bot]' 2026-09-28T01:05:00Z 2026-09-28T01:05:00Z 'NEEDS DISCUSSION — posted by another app')" > "$t/otherapp.json"
printf '[]\n' > "$t/empty.json"
printf 'not json\n' > "$t/notjson.json"

n=0
run() {  # run <body> <want-exit> <description> <pages> <session-ran> <repo> [VAR=value …]
  local body=$1 want=$2 desc=$3 pages=$4 ran=$5 dir=$6 rc=0; shift 6
  : > "$t/posted"
  (cd "$dir" && env PATH="$t/bin:$PATH" FAKE_PAGES="$pages" FAKE_POSTED="$t/posted" GH_TOKEN=x PR_NUMBER=1 REPO=o/r \
    STARTED_AT="$S" REVIEW_LOGIN="$BOT" SESSION_RAN="$ran" BASE_SHA="$(git -C "$dir" rev-parse HEAD~1)" \
    RUN_URL=https://example/run "$@" bash --noprofile --norc -eo pipefail "$body") > "$t/out" 2>&1 || rc=$?
  n=$((n + 1))
  [ "$rc" -eq "$want" ] || { echo "FAIL: $desc (want exit $want, got $rc)"; sed 's/^/  | /' "$t/out"; exit 1; }
}
says() { grep -qF -- "$1" "$t/out" || { echo "FAIL: $2 (output lacks '$1')"; sed 's/^/  | /' "$t/out"; exit 1; }; }
posted() { grep -qF -- "$1" "$t/posted" || { echo "FAIL: $2 (the PR notice lacks '$1')"; sed 's/^/  | /' "$t/posted"; exit 1; }; }

for wf in "${wfs[@]}"; do
  rel=${wf#"$root"/}
  name=$(grep -m1 -oE -e '- name: Assert the review posted.*' "$wf" | sed 's/^- name: //') || true
  [ -n "$name" ] || { echo "FAIL: $rel has no 'Assert the review posted' step"; exit 1; }
  body=$(extract_run_block "$wf" "$name")
  [ -n "$body" ] || { echo "FAIL: $rel: the '$name' step has no run: body"; exit 1; }
  printf '%s\n' "$body" > "$t/assert.sh"

  # Structure: a cancelled run is not evaluated; a comment older than the job's start never counts; an empty
  # execution_file is what tells "no session" apart.
  cond=$(awk -v want="- name: $name" 'index($0, want) {f=1; next} f && /^ *- name: /{exit} f && /^ *if: /{sub(/^ *if: /, ""); print; exit}' "$wf")
  [ "$cond" = '${{ !cancelled() }}' ] || { echo "FAIL: $rel: the assert step's condition is '$cond', not '\${{ !cancelled() }}' (always() reports a superseded run as a failure)"; exit 1; }
  first_step=$(awk '/^    steps:/{f=1; next} f && /^ *- name: /{print; exit}' "$wf")
  grep -q 'Record job start' <<<"$first_step" || { echo "FAIL: $rel: the job's first step is not 'Record job start' (got: $first_step)"; exit 1; }
  grep -qF 'STARTED_AT: ${{ steps.start.outputs.at }}' "$wf" || { echo "FAIL: $rel: the assert step does not read the recorded start time"; exit 1; }
  grep -qF "SESSION_RAN: \${{ steps.review.outputs.execution_file != '' }}" "$wf" || { echo "FAIL: $rel: SESSION_RAN is not keyed on the review step's execution_file"; exit 1; }
  step=$(awk '/- name: Auto-review$/{f=1; next} f && /^ *- name: /{exit} f' "$wf")
  grep -q '^ *id: review$' <<<"$step" || { echo "FAIL: $rel: the Auto-review step has no 'id: review' (SESSION_RAN reads it)"; exit 1; }

  A="$t/assert.sh"
  run "$A" 0 "$rel: a separate summary comment with a verdict" "$t/summary.json" true "$t/same"
  run "$A" 0 "$rel: a tracker comment that ends with the verdict" "$t/tracker-verdict.json" true "$t/same"
  run "$A" 0 "$rel: a summary on the second page of a 32-comment PR" "$t/paged.json" true "$t/same"
  run "$A" 0 "$rel: a summary written before the start and edited after it" "$t/edited.json" true "$t/same"
  run "$A" 1 "$rel: a summary written and last edited before the job started" "$t/stale.json" true "$t/same"
  says "No review summary since $S" "$rel: the failure names the start time"
  run "$A" 1 "$rel: a tracker comment with no verdict" "$t/tracker.json" true "$t/same"
  says "session ran but no summary" "$rel: the notice says the session ran"
  posted "claude-review-again" "$rel: the notice says how to re-trigger"
  run "$A" 1 "$rel: a tracker comment that names a verdict word in passing" "$t/tracker-mention.json" true "$t/same"
  says "session ran but no summary" "$rel: a verdict word in passing is not a verdict"
  run "$A" 0 "$rel: a verdict after a label on its line" "$t/verdict-prefixed.json" true "$t/same"
  # The prompt's vocabulary is the assertion's: each bold verdict on the prompt's verdict line, and the bold marker
  # its docs-only skip line opens with, lands as a comment of its own.
  marks=$(grep -m1 -F '**APPROVE** /' "$wf" | grep -oE '[*][*][A-Z][A-Z ]*[A-Z][*][*]') || true
  skipmark=$(grep -A1 -F 'post the one-line summary' "$wf" | grep -oE '`[*][*][A-Z]+[*][*][^`]*`' | tr -d '`') || true
  [ "$(wc -l <<<"$marks")" -ge 4 ] || { echo "FAIL: $rel: the prompt's verdict line names fewer than four bold verdicts (got: $marks)"; exit 1; }
  [ -n "$skipmark" ] || { echo "FAIL: $rel: the prompt's docs-only skip line opens with no bold marker the assertion can find"; exit 1; }
  while IFS= read -r mark; do
    page "$(c "$BOT" 2026-09-28T01:05:00Z 2026-09-28T01:05:00Z "$mark")" > "$t/mark.json"
    run "$A" 0 "$rel: the prompt's own line '$mark'" "$t/mark.json" true "$t/same"
  done <<<"$marks"$'\n'"$skipmark"
  run "$A" 1 "$rel: a verdict from another login" "$t/otherapp.json" true "$t/same"
  run "$A" 1 "$rel: an unreadable comment list" "$t/summary.json" true "$t/same" FAKE_API_FAIL=1
  says "Could not list the PR's comments" "$rel: the failure says the list could not be read"
  run "$A" 1 "$rel: a comment list that is not JSON" "$t/notjson.json" true "$t/same"
  says "Could not read the PR's comments as JSON" "$rel: the failure says the list could not be parsed"
  run "$A" 1 "$rel: no session, and this PR changes the workflow (the validation skip)" "$t/empty.json" false "$t/changed"
  says "workflow validation" "$rel: the skip is named as a validation skip"
  posted "differs from its base's" "$rel: the skip notice names the workflow difference"
  run "$A" 1 "$rel: no session, and the base changed the workflow after the PR branched" "$t/empty.json" false "$t/moved" BASE_SHA="$moved_base"
  says "workflow validation" "$rel: a base that moved is a validation skip too (the action compares contents)"
  run "$A" 1 "$rel: no session, and the workflow unchanged (an auth or setup failure)" "$t/empty.json" false "$t/same"
  says "auth or setup" "$rel: the no-session notice names auth or setup"
  if grep -qF "workflow validation" "$t/posted"; then echo "FAIL: $rel: an unchanged workflow was reported as a validation skip"; exit 1; fi

  # The label step: precedence, and a dispatch rule that agrees with the tool list on every path.
  lbody=$(extract_run_block "$wf" "Pick model + effort from labels")
  [ -n "$lbody" ] || { echo "FAIL: $rel has no 'Pick model + effort from labels' run: body"; exit 1; }
  printf '%s\n' "$lbody" > "$t/labels.sh"
  for want in '[]:opus:high' '["claude-fast-review"]:sonnet:high' '["claude-deep-review"]:opus:xhigh' \
              '["claude-deep-review-wip"]:opus:high' '["claude-fast-review","claude-deep-review"]:opus:xhigh'; do
    labels=${want%%:*}; rest=${want#*:}; wm=${rest%%:*}; we=${rest#*:}
    : > "$t/ghout"; rc=0
    env LABELS_JSON="$labels" GITHUB_OUTPUT="$t/ghout" bash --noprofile --norc -eo pipefail "$t/labels.sh" > "$t/out" 2>&1 || rc=$?
    n=$((n + 1))
    [ "$rc" -eq 0 ] || { echo "FAIL: $rel: the label step exited $rc on $labels"; sed 's/^/  | /' "$t/out"; exit 1; }
    out() { sed -n "s/^$1=//p" "$t/ghout"; }
    [ "$(out model)" = "$wm" ] && [ "$(out effort)" = "$we" ] || { echo "FAIL: $rel: labels $labels picked $(out model) at $(out effort), not $wm at $we"; exit 1; }
    rule=$(out dispatch_rule)
    case "$(out disallow_arg)" in
      *Agent*) [[ $rule == *"do not dispatch"* && $rule != *"may dispatch"* ]] || { echo "FAIL: $rel: labels $labels disallow the Agent tool, but the dispatch rule is '$rule'"; exit 1; } ;;
      *) [[ $rule == *"may dispatch"* && $rule != *"not dispatch"* ]] || { echo "FAIL: $rel: labels $labels keep the Agent tool, but the dispatch rule is '$rule'"; exit 1; } ;;
    esac
  done
  grep -qF '${{ steps.model.outputs.dispatch_rule }}' "$wf" || { echo "FAIL: $rel: the prompt does not read the label step's dispatch rule"; exit 1; }
  if grep -nE 'do not dispatch|no subagents' "$wf" | grep -v 'dispatch_rule='; then
    echo "FAIL: $rel: a dispatch rule stated outside the label step contradicts a path (above)"; exit 1
  fi
done
# ── "Record the resolved model", in both templates: what the step writes to the job summary. Whether GitHub shows
# that line is designed-unexercised (the step's own comment says so); this pins what the step writes.
printf '%s\n' '[{"type":"system","subtype":"init","model":"claude-opus-5-5","claude_code_version":"2.1.285"},{"type":"assistant"},{"type":"result","subtype":"success","modelUsage":{"claude-opus-5-5":{},"claude-haiku-4-5":{}}}]' > "$t/exec.json"
printf '%s\n' '[{"type":"system","subtype":"init","model":"claude-opus-5-5","claude_code_version":"2.1.285"}]' > "$t/exec-noresult.json"
tdir="$root/.claude/skills/blueprint/references/templates"
for pair in claude-review.yml:review claude.yml:claude; do
  f=${pair%%:*}; id=${pair#*:}; wf="$tdir/$f"; rel=${wf#"$root"/}
  step=$(awk '/- name: Record the resolved model$/{f=1; print; next} f && /^ *- name: /{exit} f' "$wf")
  [ -n "$step" ] || { echo "FAIL: $rel has no 'Record the resolved model' step"; exit 1; }
  grep -qF "if: always() && steps.$id.outputs.execution_file != ''" <<<"$step" || { echo "FAIL: $rel: the record step does not run on always() when steps.$id wrote an execution_file"; exit 1; }
  grep -q '^ *continue-on-error: true$' <<<"$step" || { echo "FAIL: $rel: the record step is informational and must carry continue-on-error: true"; exit 1; }
  grep -qF "EXECUTION_FILE: \${{ steps.$id.outputs.execution_file }}" <<<"$step" || { echo "FAIL: $rel: the record step does not read steps.$id's execution_file"; exit 1; }
  body=$(extract_run_block "$wf" "Record the resolved model")
  [ -n "$body" ] || { echo "FAIL: $rel: the record step has no run: body"; exit 1; }
  printf '%s\n' "$body" > "$t/record.sh"
  for ex in exec exec-noresult; do
    : > "$t/summary"
    rc=0; env EXECUTION_FILE="$t/$ex.json" GITHUB_STEP_SUMMARY="$t/summary" REQUESTED=opus EFFORT=high \
      bash --noprofile --norc -eo pipefail "$t/record.sh" > "$t/out" 2>&1 || rc=$?
    n=$((n + 1))
    [ "$rc" -eq 0 ] || { echo "FAIL: $rel: the record step exited $rc on $ex.json"; sed 's/^/  | /' "$t/out"; exit 1; }
    case "$ex" in
      exec) want='started `claude-opus-5-5` on Claude Code `2.1.285`, used `claude-haiku-4-5, claude-opus-5-5` (requested the `opus` alias at effort `high`)' ;;
      *) want='used `none recorded`' ;;
    esac
    grep -qF -- "$want" "$t/summary" || { echo "FAIL: $rel: on $ex.json the job-summary line lacks '$want'"; sed 's/^/  | /' "$t/summary"; exit 1; }
  done
done
# claude.yml's bot and skip-claude gates sit in the job's `if:`: a step-level gate runs only after the job joined the
# concurrency group, where a bot comment that mentions @claude cancels the reply in flight.
jif=$(awk '/^  claude:$/{j=1} j && /^    if: [|]/{f=1; next} f && /^    [a-z-]+:/{exit} f' "$tdir/claude.yml")
for want in "github.event.sender.type == 'User'" "!contains(github.event.issue.labels.*.name, 'skip-claude')" \
            "!contains(github.event.pull_request.labels.*.name, 'skip-claude')"; do
  grep -qF -- "$want" <<<"$jif" || { echo "FAIL: claude.yml's job if: lacks $want"; exit 1; }
done
if grep -n 'steps[.]gate' "$tdir/claude.yml"; then echo "FAIL: claude.yml still gates in a step (above), after the concurrency group"; exit 1; fi
# claude.yml names its alias and effort twice, in claude_args and in the record step's env: the two must agree.
cy="$tdir/claude.yml"
args=$(awk '/claude_args: [|]/{f=1; next} f && /^ *(--|\$\{\{)/{print; next} {f=0}' "$cy")
m=$(awk '$1 == "--model" {print $2; exit}' <<<"$args"); e=$(awk '$1 == "--effort" {print $2; exit}' <<<"$args")
rec=$(awk '/- name: Record the resolved model$/{f=1; next} f' "$cy")
rq=$(awk '$1 == "REQUESTED:" {print $2; exit}' <<<"$rec"); ef=$(awk '$1 == "EFFORT:" {print $2; exit}' <<<"$rec")
if [ -z "$m" ] || [ "$m" != "$rq" ] || [ -z "$e" ] || [ "$e" != "$ef" ]; then
  echo "FAIL: claude.yml's record step names '$rq' at '$ef', but its claude_args run '$m' at '$e'"; exit 1
fi
echo "review-assert-fixture: $n cases ok (${#wfs[@]} workflow(s), 5 structural checks and the label step each; the record step in both templates; claude.yml's job gate)"
