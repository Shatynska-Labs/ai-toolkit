#!/usr/bin/env bash
# Requirement: A task in flight shows its stage
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a pull request of the name that is open gives ship:pr-open.
# DERIVED: one closed unmerged beside it counts as neither open nor merged.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
save
branch a-task
pr a-task CLOSED
pr a-task OPEN
board_ok
has "$(row a-task flight)" 'ship:pr-open'
