# shellcheck shell=bash
# Sourced by every fixture that runs a workflow step's own body, so the fixture runs the exact bytes CI runs
# rather than a copy that drifts. Defines one function and runs nothing on source; never reads stdin.
#
#   extract_run_block <workflow.yml> <step name>
#
# Prints the step's `run: |` body, dedented. The step is found by its `- name:` value compared as a plain
# string (a name may hold regex metacharacters). The body starts after the step's `run: |` line and ends at
# the first non-blank line indented less than the body's first line — YAML's literal-block rule. Prints
# nothing when the step or its `run:` is absent; a caller treats an empty body as a failure, never as a pass.
# Needs awk only (POSIX: no gawk extension is used).
extract_run_block() {
  awk -v want="$2" '
    function ind(s) { match(s, /^ */); return RLENGTH }
    !found {
      line = $0; sub(/^ *- name: /, "", line)
      if ($0 ~ /^ *- name: / && line == want) { found = 1; step = ind($0) }
      next
    }
    found && !inrun {
      if ($0 ~ /^ *- / && ind($0) <= step) exit        # the next step began: this one has no run: block
      if ($0 ~ /^ *run: \|/) inrun = 1
      next
    }
    inrun {
      if ($0 ~ /^ *$/) { blank++; next }
      if (!body) body = ind($0)
      if (ind($0) < body) exit
      while (blank > 0) { print ""; blank-- }
      print substr($0, body + 1)
    }
  ' "$1"
}
