#!/usr/bin/env bash
# Requirement: Tasks are listed in columns
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a task with no branch reads the last commit on the trunk touching its change directory.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
change a-task
save 6
tasks_file a-task 0 3
save 4
entry other-entry
save 2
board_ok
hasre "$(row a-task flight)" '(^|[^0-9])4 d'
