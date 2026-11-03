#!/usr/bin/env bash
# Scenario (mechanical half only): The plan review is given the workstream
# (the role).
# Requirement: A workstream is reviewed when it is opened and when its plan
# changes. Change: review-a-workstream-against-its-goal (session-workflow, ADDED).
#
# SPECIFIED: the fragment's **review → fix → approve** directs supplying,
# with a change's artifact set, the workstream its proposal names. Both forms.
# DERIVED (operationalisation, design.md decision 6): the paragraph is the
# line opening `**review → fix → approve**`, and it holds "the workstream its
# proposal names" and "artifact set".
#
# Not asserted: that a session supplies the file. Conduct.
#
# Static read (third situation); every scan is discriminated by a mutant. Red
# at authoring (state 1 on real content: the paragraph exists without the
# phrase).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

# Local arrangement (test-plan.md, Missing shared arrangement: check_both_forms).
# Discriminates on the fixture, then holds both fragments to the scans.
check_both_forms() {
  local rel st status=0
  line_discriminate "$1" || exit 1
  for rel in rules/development-workflow.md rules/development-workflow-direct.md; do
    line_check "$TOOLKIT_ROOT/$rel"
    st=$?
    [ "$st" -ne 2 ] || echo "FAIL: target absent — $rel has no paragraph this case reads" >&2
    [ "$st" -eq 0 ] || status=1
  done
  exit "$status"
}

line_select '^[*][*]review → fix → approve[*][*]'
line_scan require names-workstream 'the workstream (its|the) proposal names'
line_scan require artifact-set 'artifact set'

fixture="$TESTDIR/fragment.md"
cat > "$fixture" <<'FIXTURE'
### plan

**review → fix → approve** — dispatch review against the complete artifact set, with the workstream its proposal names, never a package still being written.
FIXTURE

check_both_forms "$fixture"
