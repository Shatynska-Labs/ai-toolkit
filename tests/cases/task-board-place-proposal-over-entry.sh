#!/usr/bin/env bash
# Requirement: Every task is placed once
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the proposal's workstream comes before the entry's in the order of placement.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
workstream ws-b b-step
change a-task ws-a
entry a-task 'workstream: ws-b'
save
board_ok
one a-task ws-a 1
one a-task ws-b 0
