#!/usr/bin/env bash
# Scenario: A proposal naming a workstream that is not open
# Requirement: Every task is placed once
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a proposal naming a closed workstream gives way to the entry naming open A, marked unplaced.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
change a-task ws-closed
entry a-task 'workstream: ws-a'
save
board_ok
one a-task ws-a 1
has "$(row a-task ws-a)" 'unplaced'
