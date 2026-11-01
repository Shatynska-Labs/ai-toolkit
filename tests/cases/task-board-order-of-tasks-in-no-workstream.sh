#!/usr/bin/env bash
# Scenario: Order of tasks in no workstream
# Requirement: Tasks are listed in columns
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: those in flight first, then the most recent, then those parked.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
entry old-entry
save 9
entry parked-entry 'priority: parked'
save 1
entry new-entry
save 3
branch stray-branch 12
board_ok
in_order stray-branch new-entry old-entry parked-entry
