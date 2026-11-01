#!/usr/bin/env bash
# Requirement: A task in flight shows its stage
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the local branch comes before the remote's.
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
tasks_file a-task 1 4
commit work 3
g push -q origin a-task
tasks_file a-task 3 4
commit work 2
g checkout -q main
board_ok
has "$(row a-task flight)" '3/4'
