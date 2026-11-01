#!/usr/bin/env bash
# Scenario: A pull request open
# Requirement: A task in flight shows its stage
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: an open pull request of its name, none merged with an open change on the trunk, is ship:pr-open.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
change a-task
save
pr a-task OPEN
board_ok
has "$(row a-task flight)" 'ship:pr-open'
