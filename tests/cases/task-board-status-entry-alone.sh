#!/usr/bin/env bash
# Scenario: An entry alone
# Requirement: A task's status is derived by its name
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: an entry with no change, branch or pull request is recorded.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-task
entry a-task
save
board_ok
status_is a-task ws-a recorded
