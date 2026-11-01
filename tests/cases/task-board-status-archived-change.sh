#!/usr/bin/env bash
# Scenario: An archived change
# Requirement: A task's status is derived by its name
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the trunk holding the archived change makes the task done, even where a branch remains.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-task
archived a-task
save
branch a-task
board_ok
status_is a-task ws-a 'done'
one a-task flight 0
