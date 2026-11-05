#!/usr/bin/env bash
# Scenario: An unchecked named wait is warned of on the page
# Requirement: The page carries what a task's entry states
# Change: report-a-tasks-kind-and-wait (task-board, MODIFIED).
#
# SPECIFIED: with the forge not read in full, an entry whose only waits_on name
# is neither an archived nor an open change, with no merged pull request of it
# read, shows a warning that the wait was not checked.
# DERIVED (operationalisation): the task's row says "checked" (as in "not
# checked" or "unchecked") more often than the row of a control entry in the
# same run whose only wait is an archived change. Both rows carry whatever mark
# a partial read puts on a task with no change of its name, so only the
# warning for the wait can make the counts differ.
#
# Runs the tool; red until the page's task row warns of the wait (task 3.3).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"
source "${TESTLIB%/*}/task-board-lib.sh"


# ---- the case
project_new
entry a-waiting 'waits_on: [lost-fix]'
entry a-control 'waits_on: [old-work]'
archived old-work
save
awk 'BEGIN { for (i = 1; i <= 20000; i++) printf "old-fix-%d\tMERGED\n", i }' > "$PRS"
board_ok
assert_contains "$REPORT" 'Forge: partly read'
w="$(row a-waiting | grep -oi 'checked' | wc -l | tr -d ' ')"
c="$(row a-control | grep -oi 'checked' | wc -l | tr -d ' ')"
[ "$w" -gt "$c" ] || die "a-waiting's row warns of no unchecked wait ($w against the control's $c): $(row a-waiting)"
