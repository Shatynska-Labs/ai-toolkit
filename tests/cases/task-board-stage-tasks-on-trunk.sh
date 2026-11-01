#!/usr/bin/env bash
# Requirement: A task in flight shows its stage
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: with no branch the files are read from the trunk.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
change a-task
tasks_file a-task 2 5
save
board_ok
has "$(row a-task flight)" 'build:applying'
has "$(row a-task flight)" '2/5'
