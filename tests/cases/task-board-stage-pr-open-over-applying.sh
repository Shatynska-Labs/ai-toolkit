#!/usr/bin/env bash
# Requirement: A task in flight shows its stage
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: ship:pr-open comes before build:applying.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
save
on_branch a-task
change a-task
tasks_file a-task 4 12
leave_branch
pr a-task OPEN
board_ok
has "$(row a-task flight)" 'ship:pr-open'
hasnt "$(row a-task flight)" 'build:applying'
