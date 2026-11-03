#!/usr/bin/env bash
# Scenario (mechanical half only): A one-line defect.
# Requirement: The reviewer does not modify what it reviews.
# Change: review-a-workstream-against-its-goal (workstream-review, ADDED).
#
# SPECIFIED: the reviewer holds no tool that writes: no `Write`, `Edit`,
# `MultiEdit` or `NotebookEdit` in its frontmatter `tools`.
# SPECIFIED by design.md decision 1, not the spec: the grant is
# `Read, Grep, Glob`, so `Bash`, which writes through a shell, is refused too.
# DERIVED: the vacuity guard reads `Read` as a grant the design fixes, so an
# extraction not finding it found nothing.
#
# Not asserted: that the reviewer reports a fix rather than applying it, and
# stops once its report is produced. Conduct; the grant reaches only what it
# could do.
#
# Static read (third situation); two falsifying fixtures. Red at authoring
# (state 2: the agent does not exist yet).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

AGENT_REL="agents/workstream-reviewer.md"

# Local arrangement (test-plan.md, Missing shared arrangement: tools_of).
# Prints the frontmatter's `tools` value, inline or as a YAML block list.
tools_of() {
  awk '
    NR == 1 && $0 == "---" { fm = 1; next }
    fm && $0 == "---"      { exit }
    !fm                    { exit }
    /^tools:/ { sub(/^tools:[[:space:]]*/, ""); if ($0 != "") print; list = 1; next }
    list && /^[[:space:]]+-[[:space:]]*/ { sub(/^[[:space:]]+-[[:space:]]*/, ""); print; next }
    { list = 0 }
  ' "$1"
}

check() {
  local file="$1/$AGENT_REL" tools granted
  if [ ! -s "$file" ]; then
    echo "UNREADABLE: $file is absent or empty" >&2
    return 2
  fi
  tools="$(tools_of "$file")"
  if ! printf '%s\n' "$tools" | grep -qw -- 'Read'; then
    echo "UNREADABLE: $file: no frontmatter tools grant naming Read was found" >&2
    return 2
  fi
  granted="$(printf '%s\n' "$tools" | grep -owE -- 'Write|Edit|MultiEdit|NotebookEdit|Bash' | sort -u | tr '\n' ' ')"
  if [ -n "$granted" ]; then
    echo "FAIL: $file
  the workstream reviewer is granted a tool that writes: $granted" >&2
    return 1
  fi
  return 0
}

fixture_agent() {  # ROOT TOOLS-BLOCK
  mkdir -p "$1/agents"
  printf -- '---\nname: workstream-reviewer\n%s\n---\nReport; never apply.\n' "$2" > "$1/$AGENT_REL"
}

fixture_agent "$TESTDIR/ok" 'tools: Read, Grep, Glob'
out="$(check "$TESTDIR/ok" 2>&1)" || { echo "FAIL: discriminator — the check rejected the design's grant: $out" >&2; exit 1; }

expect_granted() {  # ROOT TOOL
  local out st
  out="$(check "$1" 2>&1)"; st=$?
  if [ "$st" -eq 1 ]; then
    case "$out" in *"a tool that writes: $2"*) return 0 ;; esac
  fi
  echo "FAIL: discriminator — expected the $2 grant to be refused, status $st: $out" >&2
  exit 1
}
fixture_agent "$TESTDIR/edit" $'tools:\n  - Read\n  - Edit\n  - Grep'
expect_granted "$TESTDIR/edit" Edit
fixture_agent "$TESTDIR/bash" 'tools: Read, Grep, Glob, Bash'
expect_granted "$TESTDIR/bash" Bash

check "$TOOLKIT_ROOT"
st=$?
[ "$st" -ne 2 ] || echo "FAIL: target absent — $AGENT_REL does not exist yet" >&2
exit "$st"
