#!/usr/bin/env python3
"""Which pull requests the auto-review workflow's path filter lets through, evaluated as GitHub does.

A docs-only PR is skipped, but markdown that is a one-way door — a rule, a skill, a command or an agent under
`.claude/`, an ADR under `docs/adr/` — is reviewed (pr-review.md § What NOT to flag: "Not automatically light
where the docs are one-way doors"). A cascade artifact under `docs/cbk/`, the other one-way door, stays skipped, as
the prompt's hard skip has it, and a human reviews it. `paths-ignore` cannot say that. GitHub's workflow syntax: "If
you want to both include and exclude path patterns for a single event, use the `paths` filter prefixed with the `!`
character to indicate which paths should be excluded", and "A matching positive pattern after a negative match will
include the path again" (https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax,
§ on.<push|pull_request|pull_request_target>.<paths|paths-ignore>, read 2026-09-30). So the filter is `paths:` with
its re-includes LAST, and this fixture pins the order: a re-include moved above the `!**/*.md` negation turns every
one-way-door PR back into a skipped one, silently.

Both semantics are evaluated, so the fixture reads a `paths-ignore` filter too, and goes red on the one-way-door
cases. Glob translation per the page's filter pattern cheat sheet: `*` matches any character but `/`, `**` any
character including `/` (and `**/` zero or more directories: `'**/README.md'` matches `README.md`), `?` zero or one
of the preceding character, and "Path patterns must match the whole path".

The blueprint template must carry a filter. A filled workflow with none reviews every PR; that is the project's
call, so it passes with a notice and its cases are skipped.
Run: python3 -B .claude/workflows/tests/review-trigger-fixture.py [workflow.yml ...]
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TEMPLATE = ROOT / ".claude/skills/blueprint/references/templates/claude-review.yml"
DEFAULT = [ROOT / ".github/workflows/claude-review.yml", TEMPLATE]


def glob_re(pattern: str) -> "re.Pattern[str]":
    out, i = "", 0
    while i < len(pattern):
        if pattern.startswith("**/", i):  # zero or more directories: '**/README.md' matches README.md
            out, i = out + "(?:.*/)?", i + 3
        elif pattern.startswith("**", i):
            out, i = out + ".*", i + 2
        elif pattern[i] == "*":
            out, i = out + "[^/]*", i + 1
        elif pattern[i] == "?":
            out, i = out + "?", i + 1
        else:
            out, i = out + re.escape(pattern[i]), i + 1
    return re.compile(out + r"\Z")


def trigger(text: str):
    """The pull_request filter kind (`paths` or `paths-ignore`) and its patterns, in order; None when there is none."""
    lines = text.splitlines()
    for n, line in enumerate(lines):
        m = re.match(r"^(\s+)(paths|paths-ignore):\s*$", line)
        if not m:
            continue
        indent, patterns = len(m.group(1)), []
        for item in lines[n + 1 :]:
            if not item.strip() or item.strip().startswith("#"):
                continue
            im = re.match(r"^(\s+)- ['\"]?([^'\"#]+?)['\"]?\s*(#.*)?$", item)
            if not im or len(im.group(1)) <= indent:
                break
            patterns.append(im.group(2))
        return m.group(2), patterns
    return None


def runs(kind: str, patterns: list, changed: list) -> bool:
    if kind == "paths-ignore":  # runs unless every changed path matches some pattern
        return any(not any(glob_re(p).match(f) for p in patterns) for f in changed)
    for f in changed:  # `paths`: patterns checked in order; a later match overrides an earlier one
        included = False
        for p in patterns:
            neg = p.startswith("!")
            if glob_re(p[1:] if neg else p).match(f):
                included = not neg
        if included:
            return True
    return False


CASES = [  # (a PR's changed paths, whether the review must run)
    (["src/app.py"], True),
    (["README.md", "src/app.py"], True),
    (["README.md"], False),
    (["docs/guide.md"], False),
    (["docs/cbk/frame-01.md"], False),
    ([".gitignore"], False),
    ([".claude/rules/pr-review.md"], True),
    ([".claude/skills/rough-in/SKILL.md"], True),
    ([".claude/commands/finish.md"], True),
    ([".claude/agents/adr-conformance-reviewer.md"], True),
    (["docs/adr/0042-example.md"], True),
    (["docs/adr/corrections.md", "README.md"], True),
]


def show(path: Path) -> str:
    """A workflow's path for a message: repository-relative where it can be, as given where it cannot."""
    try:
        return str(path.resolve().relative_to(ROOT))
    except ValueError:
        return str(path)


def main() -> int:
    files = [Path(a) for a in sys.argv[1:]] or [p for p in DEFAULT if p.exists()]
    if not files:  # a renamed workflow or a moved template must not pass as "0 cases ok"
        print(f"review-trigger-fixture: no review workflow to check (looked for {', '.join(show(p) for p in DEFAULT)})")
        return 1
    n = 0
    for wf in files:
        found = trigger(wf.read_text())
        if found is None:
            if wf.resolve() == TEMPLATE.resolve():
                print(f"FAIL: {show(wf)} has no paths or paths-ignore filter (the template must carry one)")
                return 1
            print(f"review-trigger-fixture: NOTICE: {show(wf)} has no path filter, so it reviews every PR; its cases are skipped")
            continue
        kind, patterns = found
        for changed, want in CASES:
            got = runs(kind, patterns, changed)
            if got != want:
                print(f"FAIL: {show(wf)}: a PR changing {changed} "
                      f"{'must' if want else 'must not'} run the review ({kind}: {patterns})")
                return 1
            n += 1
    print(f"review-trigger-fixture: {n} cases ok ({len(files)} workflow(s))")
    return 0


if __name__ == "__main__":
    sys.exit(main())
