#!/usr/bin/env bash
# Requirement: The page opens with what is in flight
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: each line shows whether the task is unplaced.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-task
change loose-change ws-a
change a-task
save
board_ok
has "$(row loose-change flight)" 'unplaced'
hasnt "$(row a-task flight)" 'unplaced'
