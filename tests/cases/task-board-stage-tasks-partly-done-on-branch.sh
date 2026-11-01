#!/usr/bin/env bash
# Scenario: Tasks partly done on a branch
# Requirement: A task in flight shows its stage
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: 4 of 12 ticked on the branch, no pull request open, is build:applying with 4/12.
# SPECIFIED: the branch is read before the trunk, whose tasks.md here has none ticked.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
change a-task
tasks_file a-task 0 12
save
on_branch a-task
tasks_file a-task 4 12
leave_branch
board_ok
has "$(row a-task flight)" 'build:applying'
has "$(row a-task flight)" '4/12'
