#!/usr/bin/env bash
# Requirement: Tasks are listed in columns
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: every list in a group has the same columns, the list of tasks in no workstream among them.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
entry loose-entry
save
board_ok
h="$(pg otext loose-entry rest | tr 'A-Z' 'a-z' | grep -Ex 'status|task|last commit' | head -n3 | tr '\n' ',')"
[ "$h" = 'status,task,last commit,' ] || die "headings of the group: [$h]"
