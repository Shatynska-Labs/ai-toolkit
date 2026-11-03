#!/usr/bin/env bash
# Scenario (mechanical half only): The plan review is given the workstream
# (the binding).
# Requirement: A workstream is reviewed when it is opened and when its plan
# changes. Change: review-a-workstream-against-its-goal (session-workflow, ADDED).
#
# SPECIFIED: the plan's binding names the workstream the proposal names as
# what `ai-toolkit:change-plan-reviewer` is given. Both forms.
# DERIVED (operationalisation, design.md decision 6): the binding is the line
# opening `_Claude Code binding:_` and naming the agent, and it holds
# "workstream's file" and "proposal names".
#
# Not asserted: that a session supplies the file. Conduct.
#
# Static read (third situation); every scan is discriminated by a mutant. Red
# at authoring (state 1 on real content: the binding exists without the
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

line_select '^_claude code binding:_'
line_select 'ai-toolkit:change-plan-reviewer'
line_scan require workstream-file "workstream.s file"
line_scan require proposal-names 'proposal names'

fixture="$TESTDIR/fragment.md"
cat > "$fixture" <<'FIXTURE'
### plan

_Claude Code binding:_ dispatch `ai-toolkit:change-plan-reviewer` once every artifact the change calls for is complete, supplying the workstream's file where the proposal names one.
FIXTURE

check_both_forms "$fixture"
