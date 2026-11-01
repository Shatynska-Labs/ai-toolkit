#!/usr/bin/env bash
# Scenario: A change in a workstream
# Requirement: The page opens with what is in flight
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the section lists it, naming A, and it also appears as a step in A's group.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-task
change a-task ws-a
save
board_ok
has "$(row a-task flight)" 'ws-a'
one a-task ws-a 1
