#!/usr/bin/env bash
# Requirement: A task's status is derived by its name
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the first rule holds on an archived change even with an open change of the name on the trunk.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-task
archived a-task
change a-task
save
board_ok
status_is a-task ws-a 'done'
