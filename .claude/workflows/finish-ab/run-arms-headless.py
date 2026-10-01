#!/usr/bin/env python3
"""Run finish-ab's arms as headless `claude -p` sessions, each alone in its own git worktree, in parallel.

Why headless: a workflow agent has no Agent tool (.claude/rules/pr-review.md § The floor records the probe, its Claude
Code version and its date), so an arm run as a workflow agent can dispatch no subagents — neither a subagent-driven
arm's implementers nor the review floor's own fan-out. A top-level `claude -p` session can. The judge panel still runs
as the finish-ab workflow, handed this script's `executed.json` (finish-ab.js § args.executed).

Usage: python3 .claude/workflows/finish-ab/run-arms-headless.py <config.json> [--dry-run | --resume-existing]

--dry-run creates no worktree and runs nothing (it writes only out_dir's empty MCP config, the one an arm would get): it
prints, per arm, one JSON line {"anon", "cwd", "argv", "setup"} with the first invocation's argv and the worktree_setup
commands, so the deny list and the MCP config an arm would run under can be read before any money is spent.

An arm is complete when its session returned a structured result and PR_BODY.md exists in its worktree. An
unattended Opus 5.5 session ends turns with text while work is still owed: on this runner's first measured run
(2026-09-25, context-builder-kit#69) all three arms stopped before the end of /finish, one of them forced to return its
result while its own subagent was still running. So, as the Opus 5.5 guide prescribes
(platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5 § Unattended agentic runs,
read 2026-09-30):
- every new session gets the guide's standing paragraph on turn endings, appended to its system prompt from the
  first request (UNATTENDED below, verbatim);
- an incomplete arm is resumed in the same session with a message naming what is still open, at most
  max_continuations times per runner pass (default 3: "stop after two or three automatic continuations on the same
  task"); a later --resume-existing pass is the operator's deliberate choice and gets its own count, so only
  max_budget_usd bounds an arm's total across passes.
--resume-existing skips creating worktrees and continues each arm from the session its <anon>.json recorded.

config.json:
  repo, issue            — as finish-ab.js takes them
  base                   — the commit every arm starts from; each worktree is added there, detached
  brief                  — absolute path of the operator brief
  worktree_root          — directory the arm worktrees are created under (inside the repository, so the arms'
                           edits stay inside a working directory the session's permissions already cover). It must
                           be a gitignored path, such as .claude/worktrees/ — ignored by an anchored entry,
                           /.claude/worktrees/ (cbk-conventions-reference.md § .gitignore anchoring): an arm's
                           reviewers write .claude/agent-memory/ inside its worktree, and
                           detect-forked-agent-memory.sh blocks the launching session's hand-off on any such tree
                           outside the root that .gitignore does not exclude
  out_dir                — receives <anon>.json (the `claude -p --output-format json` payload), <anon>.err,
                           <anon>.cmd (the argv, for the record) and executed.json
  max_budget_usd         — per-arm spend cap across all its invocations (`--max-budget-usd`, given each
                           continuation as what is left), a runaway guard rather than a budget
  arms                   — [{anon, read, also?, verb?, model, effort}], as finish-ab.js's arms
  worktree_setup         — optional: shell commands run with `bash -c` in each new worktree, in order, right after it
                           is created and before any arm starts (a tool's trust step such as `mise trust`, or a
                           dependency install). One that exits non-zero stops the run before any arm is paid for,
                           naming the worktrees already created. --resume-existing does not re-run them
  check_command          — optional: the project's check task as one shell command (<the check task>). After every
                           arm has finished, the runner runs it once in each complete arm's worktree, one arm at a
                           time, into <out_dir>.checks/<anon>.check.log (beside out_dir, never in it: a judge is given
                           that path, and out_dir's records name each arm's mode), and adds {command, exit, log} to
                           the arm's result as runner_check, so the judges read one measured gate instead of each
                           re-running it: parallel gates on one machine measure the machine, not the arms
                           (context-builder-kit#69). It runs with no timeout: a hung check hangs the runner, which
                           is why executed.json is written before the checks and again after them
  mcp_config             — optional: a `--mcp-config` file naming the read-only MCP servers the arms may use (at most
                           context7 and time, MCP_ALLOWED). Absent, the arms get none: every arm runs with
                           `--strict-mcp-config`. One that names any other server — a write-capable one, or one this
                           runner does not know — is refused before any worktree is created. So an arm cannot read an
                           issue that lives behind an MCP server (a Linear planning backend), and has no docs server
                           unless this file names context7: the operator brief carries the issue's body and comments
                           verbatim (operator-brief.md § The issue, verbatim)

Every arm runs in `auto` permission mode, where a classifier reviews each action, and a `-p` run with no permission
host denies whatever would prompt ("In a `-p` run with no host, these requests are denied either way",
code.claude.com/docs/en/headless, read 2026-09-30). It runs with `--strict-mcp-config` and deny rules for the remote
writes DENY names ("Deny rules block in every mode", code.claude.com/docs/en/permission-modes, read 2026-09-30). The
launching session's environment variables whose names start with CLAUDE are stripped, and named on stdout, so each arm
starts as a fresh top-level session: a Claude Code 2.1.286 session sets CLAUDECODE, CLAUDE_CODE_SESSION_ID and
CLAUDE_CODE_ENTRYPOINT among others (observed 2026-09-30), and CLAUDE_CONFIG_DIR goes with them, so an arm reads
the default configuration directory. The settings files' own `env` blocks re-apply whatever they set. A fresh run refuses an
existing worktree or an out_dir holding an earlier run's files before creating anything; --resume-existing needs each
arm's worktree and its recorded <anon>.cmd. Stdlib only: needs python3 and git, and `claude` on PATH for a real run.
"""
import json
import os
import re
import shutil
import subprocess
import sys
import threading
import time
import uuid

# Verbatim from platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5
# § Unattended agentic runs (read 2026-09-30): "one example of such an addition, written for agents that run
# fully unattended … Add it at the end of your system prompt from the first request of the session".
UNATTENDED = (
    "A standing instruction from the user, the person you are working for. It is about how your turns end. A message "
    "with no tool call in it ends your turn, and the work stops there until you are asked to continue. The user has "
    "seen you end turns in four ways while work they asked for was still owed, and does not want any of them. One: a "
    "long summary of what was done that closes by announcing the next step and has no tool call, so the next thing "
    "never starts. Two: an offer to carry on with something unless the user would prefer otherwise, which stops to "
    "wait for an answer the user was not going to give. Three: a list of decisions for the user when, by your own "
    "account, none of them blocks the rest of the work. Four: deciding that this is a good place to report, because "
    "the turn has been long or a milestone is done. Status notes are welcome, and so are your recommendations on open "
    "decisions, but put them in the same message as your next tool call and carry on with whatever does not depend on "
    "the user's answer. If you notice yourself inviting the user to redirect you or offering to wait, delete it and "
    "do the next thing. The stops the user does want are the ones where nothing can move without them, or where the "
    "thing blocking you is deliberately protected from you. This does not override the need for confirmation on "
    "risky or destructive actions."
)

# Remote writes an arm must never make. `*` can stand anywhere in a rule (code.claude.com/docs/en/permissions
# § Wildcard patterns, read 2026-09-30), but a trailing wildcard also matches the bare command only when it is the rule's
# sole wildcard ("That holds only when the trailing `*` is the rule's only wildcard", the same page): `git * push *`
# needs text after `push`, so the bare `git -C . push` and `git -c k=v push` are caught by `git * push`, listed beside
# it — keep both. `git push *` is a sole trailing wildcard, so it already matches the bare `git push` ("`Bash(git log *)`
# matches `git log`", the same page) and needs no rule of its own. An arm reads GitHub through `gh`; reads stay open:
# `gh issue view`, `gh pr list`, `gh label list`, `gh release view`. `gh api` is denied whole, because its method is a
# flag (`-X`, or implied by `-f`), so no glob can let its reads through and stop its writes — an arm reads with
# `gh issue view` and `gh pr view` instead.
#
# The deny list is a backstop, not the boundary: a non-bare `claude -p` loads every MCP server the user's own settings
# add, and a machine can carry write-capable ones this list cannot enumerate. So every arm runs with
# `--strict-mcp-config`: only the servers the config's `mcp_config` file names load, and with none named, none do (fail
# closed). WRITE_SERVERS names the write-capable servers the kit's own axes wire — the git host (`github`), the
# planning backend (`linear`) and the knowledge backend (`notion`) — each denied whole, under its configured name and
# its plugin form (`mcp__plugin_<plugin>_<server>__*`, the names a Claude Code 2.1.286 session showed on 2026-09-30).
# A target adds every other write-capable server its own .mcp.json wires. Connectors Claude Code fetches from claude.ai
# are denied whole too ("Tools from connectors Claude Code fetches itself appear as `mcp__claude_ai_<server>__<tool>`";
# a deny rule's tool name may be a glob — code.claude.com/docs/en/permissions § MCP and § Tool name wildcards, read
# 2026-09-30): an arm reads its issue through the brief and edits files with its own tools.
WRITE_SERVERS = ('github', 'linear', 'notion')
# The only servers an arm's mcp_config may name. An allowlist, not WRITE_SERVERS turned around: a server this file does
# not know — one added to .mcp.json later, or a machine's own — is refused rather than let through (fail closed).
MCP_ALLOWED = ('context7', 'time')
DENY = [
    'Bash(git push *)', 'Bash(git * push *)', 'Bash(git * push)',
    *[f'mcp__{srv}__*' for srv in WRITE_SERVERS],
    'mcp__plugin_github_github__*', 'mcp__plugin_linear_linear__*', 'mcp__plugin_Notion_notion__*', 'mcp__claude_ai_*',
    'Bash(gh api *)',
    *[f'Bash(gh pr {c} *)' for c in ('create', 'edit', 'merge', 'comment', 'ready', 'close', 'reopen', 'review',
                                      'update-branch', 'lock', 'unlock')],
    *[f'Bash(gh issue {c} *)' for c in ('create', 'edit', 'comment', 'close', 'reopen', 'delete', 'transfer',
                                         'develop', 'pin', 'unpin', 'lock', 'unlock')],
    *[f'Bash(gh label {c} *)' for c in ('create', 'edit', 'delete', 'clone')],
    *[f'Bash(gh release {c} *)' for c in ('create', 'edit', 'delete', 'upload', 'delete-asset')],
    *[f'Bash(gh repo {c} *)' for c in ('create', 'delete', 'edit', 'fork', 'rename', 'archive', 'unarchive', 'sync')],
    *[f'Bash(gh workflow {c} *)' for c in ('run', 'enable', 'disable')],
    *[f'Bash(gh run {c} *)' for c in ('rerun', 'cancel', 'delete')],
    'Bash(gh secret *)', 'Bash(gh variable *)', 'Bash(gh gist *)',
]

# The arm's structured return: finish-ab.js's ARM_SCHEMA, with its descriptions. One difference, on purpose:
# `dispatched` is required here, because a headless arm can dispatch subagents, and optional there, where a workflow
# agent cannot (it has no Agent tool).
ARM_SCHEMA = {
    'type': 'object',
    'required': ['branch', 'worktree', 'commits', 'plan_path', 'pr_body_path', 'check_command', 'check_exit',
                 'tests_written', 'skills_invoked', 'operational', 'gate_calls', 'dispatched', 'handoff', 'notes'],
    'properties': {
        'branch': {'type': 'string'},
        'worktree': {'type': 'string', 'description': 'absolute path of the worktree you worked in'},
        'commits': {'type': 'array', 'items': {'type': 'object', 'required': ['sha', 'subject'],
                                                'properties': {'sha': {'type': 'string'}, 'subject': {'type': 'string'}}},
                    'description': 'oldest first'},
        'plan_path': {'type': 'string'},
        'pr_body_path': {'type': 'string'},
        'check_command': {'type': 'string'},
        'check_exit': {'type': 'integer'},
        'tests_written': {'type': 'array', 'items': {'type': 'string'}},
        'skills_invoked': {'type': 'array', 'items': {'type': 'string'},
                           'description': 'exact skill names actually invoked via the Skill tool'},
        'operational': {'type': 'array', 'items': {'type': 'string'},
                        'description': 'criteria left open because they need the operator or a device'},
        'gate_calls': {'type': 'array', 'items': {'type': 'string'},
                       'description': 'every decision you made where the flow would have waited for the operator'},
        'dispatched': {'type': 'array', 'items': {'type': 'object', 'required': ['role', 'model', 'effort'],
                                                   'properties': {'role': {'type': 'string'}, 'model': {'type': 'string'},
                                                                  'effort': {'type': 'string'}}},
                       'description': 'every subagent you dispatched yourself, outside the review skills: its role, model and effort'},
        'handoff': {'type': 'string'},
        'notes': {'type': 'string'},
    },
}


def arm_prompt(cfg, cell, arms):
    """The same instruction finish-ab.js's armPrompt gives a workflow arm, for a headless session."""
    files = [cell['read'], *cell.get('also', [])]
    others = sorted({f for c in arms if c['anon'] != cell['anon'] for f in [c['read'], *c.get('also', [])]} - set(files))
    forbid = (f"Do not open {', '.join(others)} or anything under .claude/skills/" if others
              else 'Do not open anything under .claude/skills/')
    read = (f"Then read {cell['read']} in full, then {', then '.join(cell['also'])} in full,"
            if cell.get('also') else f"Then read {cell['read']} in your worktree in full")
    return (f"You are executing issue #{cfg['issue']} in the repository {cfg['repo']}, from inside a git worktree of "
            f"your own — your current working directory. Read the operator brief at {cfg['brief']} first; it states "
            f"what non-interactive means for this run, the standing decisions, the hard limits and what to return. "
            f"Your worktree is checked out, detached, at commit {cfg['base']}: create your branch there before your "
            f"first commit — this run replays the issue from that commit, and nothing after it exists for you.\n\n"
            f"{read} and {cell.get('verb', 'satisfy it')} for issue {cfg['issue']}, with the brief's non-interactive "
            f"rules substituting only where the instructions would wait for the operator (the plan gate becomes "
            f"PLAN.md, the push and PR become PR_BODY.md, operational criteria stay open). Read every input the "
            f"instructions name, in full, before planning. {forbid} — the files you were given, the issue and the "
            f"inputs it names are your whole instruction. Invoke the skills it requires as skills. Return the "
            f"structured result when the hand-off exists.")


def common_flags(cfg, cell, budget=None):
    return ['--model', cell['model'], '--effort', cell['effort'], '--permission-mode', 'auto',
            '--output-format', 'json', '--json-schema', json.dumps(ARM_SCHEMA),
            '--strict-mcp-config', '--mcp-config', cfg['mcp_config'],
            '--max-budget-usd', f"{cfg['max_budget_usd'] if budget is None else budget:.2f}",
            # `--disallowedTools` is variadic (`<tools...>`, "Comma or space-separated list of tool names to deny" in
            # `claude --help` on 2.1.286, read 2026-09-30), so the spread applies every rule: a live probe with a
            # positive control denied both of two space-separated rules, and the next flag ends the list
            # (context-builder-kit#69, 2026-09-28). Do not comma-join it on a reviewer's word; re-probe. `--mcp-config`
            # is variadic too (`<configs...>`) and ends only because `--max-budget-usd` follows it: keep that order.
            '--disallowedTools', *DENY]


def worktree_of(cfg, anon):
    return os.path.join(cfg['worktree_root'], f'eval-{anon}')


def first_argv(cfg, cell, arms, session_id):
    """The arm's first invocation; --dry-run prints this same argv, so the preview cannot drift from the real call."""
    return ['claude', '-p', arm_prompt(cfg, cell, arms), '--session-id', session_id, *common_flags(cfg, cell),
            '--append-system-prompt', UNATTENDED]


def add_note(result, text):
    result['notes'] = (result.get('notes') or '') + text


def open_items(wt, payload):
    """What the arm still owes, by the completion condition: a structured result and PR_BODY.md."""
    items = []
    if not os.path.exists(os.path.join(wt, 'PR_BODY.md')):
        items.append('PR_BODY.md does not exist in your worktree yet')
    if not isinstance((payload or {}).get('structured_output'), dict):
        items.append('your last turn returned no structured result')
    return items


def continuation(items):
    return ('Your run of the instructions is not complete: ' + '; '.join(items) + '. Continue from where you stopped '
            'and finish every step your instructions still require — the review floor as they require it, the triage '
            'and its commits, PR_BODY.md with its "## Review gate" and "## Triage" blocks, and the hand-off — then '
            'return the structured result, with the commit list as it stands at that moment. Before you end a turn, '
            'wait for every subagent you started to return; do not end a turn while one is still running. If a step '
            'is blocked, say what is blocking it.')


def run_arm(cfg, cell, arms, env, resume, record):
    anon = cell['anon']
    wt = worktree_of(cfg, anon)
    out = cfg['out_dir']
    runs, t0 = [], time.time()  # one {payload, rc, err} per invocation; rc is None for one an earlier pass made
    first = 1  # the next continuation's number
    cmd_path = os.path.join(out, f'{anon}.cmd')
    if resume:
        # Continue from the latest payload an earlier pass left, and number new continuations after it, so an
        # earlier pass's cont<k> files are never overwritten and a stale first-pass result is never taken as final.
        cont = re.compile(rf'{re.escape(anon)}\.cont(\d+)\.json')
        done = sorted(int(m.group(1)) for f in os.listdir(out) if (m := cont.fullmatch(f)))
        # A killed invocation leaves its payload empty or truncated (invoke() opens the file before the child runs),
        # so every recorded payload is loaded oldest first and an unparsable one stays as None: the session-id and
        # cost lookups below skip None, so the arm resumes from the newest payload that parsed.
        for name in [f'{anon}.json', *(f'{anon}.cont{k}.json' for k in done)]:
            runs.append({'payload': load_payload(os.path.join(out, name)), 'rc': None,
                         'err': os.path.join(out, name[:-len('.json')] + '.err')})
        first = (done[-1] + 1) if done else 1
        recorded_sid = (load_payload(cmd_path) or {}).get('session_id')
    else:
        # The session id is chosen here and recorded before the first invocation, so a first invocation killed before
        # it wrote any payload can still be resumed by --resume-existing.
        recorded_sid = str(uuid.uuid4())
        argv_ = first_argv(cfg, cell, arms, recorded_sid)
        with open(cmd_path, 'w') as f:
            json.dump({'cwd': wt, 'session_id': recorded_sid, 'argv': argv_}, f, indent=1)
        runs.append(invoke(argv_, wt, env, os.path.join(out, f'{anon}.json'), os.path.join(out, f'{anon}.err')))
    stop = None
    for k in range(first, first + int(cfg.get('max_continuations', 3))):
        last = runs[-1]
        # An invocation this pass made that failed — no parsable payload, a non-zero exit, or an error subtype such as
        # error_max_budget_usd or an auth failure — is reported and not continued: a continuation would fail the same
        # way, and after a killed one the spend is unknown. An operator who fixes the cause resumes with
        # --resume-existing.
        if last['rc'] is not None and failure_of(last):
            stop = f"its last invocation failed: {failure_of(last)}"
            break
        items = open_items(wt, last['payload'])
        if not items:
            break
        # The session id from the latest payload that parsed, else the one recorded before the first invocation.
        sid = next((r['payload'].get('session_id') for r in reversed(runs) if r['payload'] and r['payload'].get('session_id')),
                   None) or recorded_sid
        if not sid:
            stop = 'no session id is recoverable (no payload parsed, and <anon>.cmd records none)'
            break
        # --max-budget-usd does not count spend restored from earlier runs: restored totals "don't count toward it"
        # (code.claude.com/docs/en/cli-reference, read 2026-09-30), so each continuation gets only what the arm's cap
        # has left, never the whole cap again.
        spent, floor = spend(runs)
        left = float(cfg['max_budget_usd']) - spent
        if left <= 0:
            stop = f"it has spent its cap (${spent:.2f}{' or more' if floor else ''})"
            break
        if floor:
            print(f'{anon}: an earlier invocation left no payload, so ${spent:.2f} spent is a floor and the '
                  f'${left:.2f} left may overstate the cap', flush=True)
        # With --system-prompt-snapshot on ("on (the default)", `claude --help` on 2.1.286, read 2026-09-30), the first
        # request's prompt — this paragraph included — is recorded and reused on resume until the conversation is
        # compacted; passing it again is a no-op until then and restores it after a compaction, or where recording is
        # off. So it is passed on every continuation.
        argv_ = ['claude', '-p', continuation(items), '--resume', sid, '--append-system-prompt', UNATTENDED,
                 *common_flags(cfg, cell, budget=left)]
        print(f'{anon}: continuation {k} — {"; ".join(items)}', flush=True)
        runs.append(invoke(argv_, wt, env, os.path.join(out, f'{anon}.cont{k}.json'), os.path.join(out, f'{anon}.cont{k}.err')))
    else:
        if open_items(wt, runs[-1]['payload']):
            stop = f"this pass reached max_continuations ({int(cfg.get('max_continuations', 3))}); --resume-existing continues it"
    # A resumed invocation reports the conversation's whole total, earlier runs included ("the run reports the
    # conversation's whole total", code.claude.com/docs/en/headless, read 2026-09-30), so the arm's cost is the latest
    # parsed payload's total, never a sum — and a floor when a later invocation left no payload.
    cost, floor = spend(runs)
    final = runs[-1]['payload'] or {}
    record[anon] = dict(wt=wt, final=final, cost=round(cost, 2), floor=floor, invocations=len(runs),
                        items=open_items(wt, final), stop=stop, minutes=round((time.time() - t0) / 60, 1))


def spend(runs):
    """(the conversation's spend so far, whether that figure is only a floor) — the latest parsed payload's total;
    a floor when an invocation after it, or every invocation, left no payload."""
    parsed = [i for i, r in enumerate(runs) if r['payload']]
    if not parsed:
        return 0.0, bool(runs)
    last = parsed[-1]
    return float(runs[last]['payload'].get('total_cost_usd') or 0), last < len(runs) - 1


def failure_of(run):
    """Why an invocation failed, in one line naming its stderr file — or None if it did not."""
    p, rc = run['payload'], run['rc']
    if p is None:
        return f"no parsable payload (exit {rc}; see {run['err']})"
    if p.get('is_error') or rc not in (None, 0):
        text = str(p.get('result') or '').strip().splitlines()
        return f"{p.get('subtype') or 'error'} (exit {rc}): {text[0][:160] if text else 'no result text'}; see {run['err']}"
    return None


def run_checks(cfg, executed, env):
    """The check task, once per complete arm, one arm at a time, after every arm has finished: the judges read this log
    rather than each re-running the gate, which on one machine measures the machine (context-builder-kit#69). No
    timeout: a hung check hangs the runner (main writes executed.json before the checks for that reason)."""
    cmd = cfg.get('check_command')
    if not cmd:
        return
    # Beside out_dir, never inside it: the log path goes into every judge's prompt, and out_dir holds each arm's
    # <anon>.cmd (its argv names the arm's instruction files and effort), payloads and executed.json — a judge sent
    # there could read which arm is which.
    log_dir = os.path.abspath(cfg['out_dir']).rstrip(os.sep) + '.checks'
    os.makedirs(log_dir, exist_ok=True)
    for e in executed:
        anon, result = e['anon'], e['result']
        log = os.path.join(log_dir, f'{anon}.check.log')
        with open(log, 'w') as f:
            try:
                rc = subprocess.run(['bash', '-c', cmd], cwd=result['worktree'], env=env, stdout=f,
                                    stderr=subprocess.STDOUT, stdin=subprocess.DEVNULL).returncode
            except OSError as ex:
                f.write(f'[runner] the check task could not start: {ex}\n')
                rc = -1
        result['runner_check'] = {'command': cmd, 'exit': rc, 'log': log}
        add_note(result, (
            f"\n[runner] check task run once by the runner after every arm finished: `{cmd}` exit {rc}; log {log}"))
        print(f'{anon}: check task exit {rc} ({log})', flush=True)


def load_payload(path):
    """A recorded `claude -p --output-format json` payload, or None when it is missing, empty or truncated."""
    try:
        with open(path) as f:
            return json.load(f)
    except (OSError, json.JSONDecodeError):
        return None


def invoke(argv_, wt, env, out_path, err_path):
    with open(out_path, 'w') as out, open(err_path, 'w') as err:
        rc = subprocess.run(argv_, cwd=wt, env=env, stdout=out, stderr=err, stdin=subprocess.DEVNULL).returncode
    return {'payload': load_payload(out_path), 'rc': rc, 'err': err_path}


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    # A mistyped flag must not fall through to a real, paid run.
    unknown = [a for a in argv[2:] if a not in ('--dry-run', '--resume-existing')]
    if unknown:
        print(f"unknown argument(s): {' '.join(unknown)} (expected --dry-run or --resume-existing)")
        return 2
    with open(argv[1]) as f:
        cfg = json.load(f)
    dry, resume = '--dry-run' in argv, '--resume-existing' in argv
    for k in ('repo', 'issue', 'base', 'brief', 'worktree_root', 'out_dir', 'max_budget_usd', 'arms'):
        if cfg.get(k) in (None, ''):
            print(f'config: {k} is required')
            return 2
    arms = cfg['arms']
    if not isinstance(arms, list) or not 2 <= len(arms) <= 4 or not all(isinstance(a, dict) for a in arms):
        print('config: arms is a list of two to four objects')
        return 2
    # Every arm is checked before any worktree exists: a missing key inside a runner thread would otherwise surface
    # only as "the thread recorded nothing", after the worktrees that block a re-run were already created.
    for cell in arms:
        bad = [k for k in ('anon', 'read', 'model', 'effort') if not isinstance(cell.get(k), str) or not cell.get(k)]
        if cell.get('also') is not None and not (isinstance(cell['also'], list) and all(isinstance(f, str) and f for f in cell['also'])):
            bad.append('also (a list of file paths)')
        if bad:
            print(f"config: arm {cell.get('anon')!r} lacks {', '.join(bad)}")
            return 2
    if len({cell['anon'] for cell in arms}) != len(arms):  # every anon is a non-empty string by now
        print('config: the arms need distinct anon ids')
        return 2
    if cfg.get('check_command') is not None and not (isinstance(cfg['check_command'], str) and cfg['check_command'].strip()):
        print('config: check_command is a shell command string, run once in each complete arm\'s worktree')
        return 2
    setup = cfg.get('worktree_setup')
    if setup is not None and not (isinstance(setup, list) and all(isinstance(c, str) and c.strip() for c in setup)):
        print('config: worktree_setup is a list of shell commands, run in each new worktree before any arm starts')
        return 2
    if not dry and shutil.which('claude') is None:
        print('claude is not on PATH')
        return 2
    cfg['worktree_root'] = os.path.abspath(cfg['worktree_root'])  # the judges read result.worktree from any cwd
    os.makedirs(cfg['out_dir'], exist_ok=True)
    stripped = sorted(k for k in os.environ if k.startswith('CLAUDE'))
    env = {k: v for k, v in os.environ.items() if k not in stripped}
    print(f"stripped from the arms' environment: {', '.join(stripped) or 'nothing'}", flush=True)
    if cfg.get('mcp_config'):
        cfg['mcp_config'] = os.path.abspath(cfg['mcp_config'])
        try:
            with open(cfg['mcp_config']) as f:
                named = sorted((json.load(f).get('mcpServers') or {}).keys())
        except (OSError, json.JSONDecodeError, AttributeError) as e:
            print(f"config: mcp_config {cfg['mcp_config']} could not be read as an MCP config ({e})")
            return 2
        others = [srv for srv in named if srv not in MCP_ALLOWED]
        if others:
            print(f"config: mcp_config names servers outside {' and '.join(MCP_ALLOWED)} ({', '.join(others)}), the only "
                  f"ones an arm may load — refusing before any worktree is created")
            return 2
    else:
        cfg['mcp_config'] = os.path.join(os.path.abspath(cfg['out_dir']), 'no-mcp-servers.json')
        with open(cfg['mcp_config'], 'w') as f:
            json.dump({'mcpServers': {}}, f)
    wts = {cell['anon']: worktree_of(cfg, cell['anon']) for cell in arms}
    if resume:
        for cell in arms:
            if not (os.path.isdir(wts[cell['anon']]) and os.path.exists(os.path.join(cfg['out_dir'], f"{cell['anon']}.cmd"))):
                print(f"--resume-existing: {cell['anon']} has no worktree or no recorded first invocation to continue")
                return 1
    else:
        # Refuse every conflict before creating anything, so a refusal never leaves half the worktrees behind; and
        # refuse an out_dir an earlier run wrote into, or a later --resume-existing would pick up its stale payloads.
        taken = [wt for wt in wts.values() if os.path.exists(wt)]
        stale = sorted(f for f in os.listdir(cfg['out_dir']) for cell in arms if f.startswith(f"{cell['anon']}."))
        if taken or stale:
            for wt in taken:
                print(f'refusing to reuse {wt}: remove it first (git worktree remove {wt})')
            if stale:
                print(f"refusing to write into {cfg['out_dir']}: it holds an earlier run's files ({', '.join(stale)})")
            return 1
        created = []
        for cell in arms:
            wt = wts[cell['anon']]
            if dry:
                argv_ = first_argv(cfg, cell, arms, '<chosen at run time>')
                print(json.dumps({'anon': cell['anon'], 'cwd': wt, 'argv': argv_, 'setup': setup or []}), flush=True)
                continue
            subprocess.run(['git', 'worktree', 'add', '--detach', wt, cfg['base']], check=True)
            created.append(wt)
            # A project's own per-worktree step (a tool's trust prompt, a dependency install), from the config rather
            # than hard-coded: a target without the tool would otherwise fail here after the first worktree exists.
            for cmd in setup or []:
                rc = subprocess.run(['bash', '-c', cmd], cwd=wt, env=env, stdin=subprocess.DEVNULL).returncode
                if rc != 0:
                    print(f"worktree_setup: `{cmd}` exited {rc} in {wt}; no arm was started. Fix it, then remove the "
                          f"worktrees this run created before running again (git worktree remove <path>): {' '.join(created)}")
                    return 1
    if dry:
        return 0
    record, threads = {}, []
    for cell in arms:
        th = threading.Thread(target=run_arm, args=(cfg, cell, arms, env, resume, record))
        th.start()
        threads.append(th)
        print(f"{cell['anon']}: {'resumed' if resume else 'started'} (model {cell['model']}, effort {cell['effort']})", flush=True)
    for th in threads:
        th.join()
    executed = []
    for cell in arms:
        r = record.get(cell['anon'])
        if r is None:
            print(f"{cell['anon']}: the runner thread recorded nothing")
            continue
        result = r['final'].get('structured_output')
        cost = f"${r['cost']}{' (a floor)' if r['floor'] else ''}"
        if r['items'] or not isinstance(result, dict):
            why = '; '.join(filter(None, [r['stop'], *r['items']]))
            print(f"{cell['anon']}: incomplete after {r['invocations']} invocation(s), {cost}: {why}; "
                  f"the arm is dropped, never guessed at")
            continue
        # The runner knows where the arm ran; the judges locate it by this field, so the arm's own report never wins.
        if result.get('worktree') and os.path.abspath(os.path.join(r['wt'], result['worktree'])) != r['wt']:
            add_note(result, f"\n[runner] the arm reported worktree {result['worktree']!r}")
        result['worktree'] = r['wt']
        add_note(result, (
            f"\n[runner] {r['invocations']} invocation(s) ({r['invocations'] - 1} continuation(s)), "
            f"{r['minutes']} min this runner pass, total_cost_usd {cost} for the whole conversation, "
            f"session {r['final'].get('session_id')}"))
        # Complete by its artifacts, yet its last invocation reported a failure (an error subtype or a non-zero exit
        # after the result was written): the arm is judged on what it produced, and the failure travels with it.
        failed = f" — {r['stop']}" if r['stop'] else ''
        if failed:
            result['notes'] += f"\n[runner] {r['stop']}"
        executed.append({'anon': cell['anon'], 'result': result})
        print(f"{cell['anon']}: complete after {r['invocations']} invocation(s), {cost}, "
              f"{len(result.get('commits', []))} commits, check exit {result.get('check_exit')}{failed}", flush=True)
    # Written before the checks and again after them: the checks run one at a time with no timeout, so a hung check or
    # an interrupt must not lose the record of arms already paid for (a later --resume-existing rewrites it anyway).
    def write_executed():
        with open(os.path.join(cfg['out_dir'], 'executed.json'), 'w') as f:
            json.dump(executed, f, indent=1)
    write_executed()
    if cfg.get('check_command'):
        run_checks(cfg, executed, env)
        write_executed()
    missing = [c['anon'] for c in arms if c['anon'] not in {e['anon'] for e in executed}]
    if missing:
        print(f"dropped arms (incomplete or no well-formed result): {', '.join(missing)}")
    return 0 if not missing else 1


if __name__ == '__main__':
    sys.exit(main(sys.argv))
