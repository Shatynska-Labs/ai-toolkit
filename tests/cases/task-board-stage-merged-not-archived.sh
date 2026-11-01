#!/usr/bin/env bash
# Scenario: A merged change not yet archived
# Requirement: A task in flight shows its stage
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: an open change on the trunk with a merged pull request of its name is ship:merged.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
change a-task
save
pr a-task MERGED
board_ok
has "$(row a-task flight)" 'ship:merged'
