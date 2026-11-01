#!/usr/bin/env bash
# Scenario: A branch with no change
# Requirement: A task's status is derived by its name
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a remote branch of the name makes the task in flight.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-task
save
other_clone
in_other branch a-task
in_other g push -q origin a-task
board_ok
status_is a-task ws-a 'in flight'
