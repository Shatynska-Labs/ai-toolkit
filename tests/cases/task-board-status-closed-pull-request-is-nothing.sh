#!/usr/bin/env bash
# Requirement: A task's status is derived by its name
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a pull request closed unmerged is none of the states the lookups name.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-task
save
pr a-task CLOSED
board_ok
status_is a-task ws-a planned
