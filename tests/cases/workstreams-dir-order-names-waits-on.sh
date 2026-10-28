#!/usr/bin/env bash
# Scenario: Step order is not a dependency (as revised).
# Requirement: A workstream register is seeded where none exists.
# Change: one-file-per-backlog-entry (project-bootstrap, MODIFIED).
#
# SPECIFIED: the order statement says list order gates nothing and directs a
# session to the step's backlog entry's `waits_on`.
# DERIVED (operationalisation, carried from the superseded
# workstreams-seeded-order-gates-nothing.sh): the line stating "gates
# nothing" also carries `waits_on` and "backlog entry".
#
# Executes the tool; every scan is discriminated on the fixture. Red until
# task 1.3 lands (state 1: the current line names Waits on).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

line_select 'gates nothing'
line_scan require names-waits-on 'waits_on'
line_scan require names-backlog-entry 'backlog entry'

fixture="$TESTDIR/README.md"
cat > "$fixture" <<'FIXTURE'
# Workstreams

The order of the steps is the intended order of work and gates nothing, a step that cannot start before another saying so in its backlog entry's `waits_on`.
FIXTURE
line_discriminate "$fixture" || exit 1

work="$TESTDIR/work"
mkdir -p "$work"
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
line_check "$work/docs/workstreams/AGENTS.md"
st=$?
[ "$st" -eq 2 ] && echo "FAIL: target absent — the register states no order rule" >&2
[ "$st" -eq 0 ] || exit 1
