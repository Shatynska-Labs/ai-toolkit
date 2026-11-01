#!/usr/bin/env bash
# Scenario: An entry that is a step
# Requirement: Every task is placed once
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: it appears once, as that step.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-task
entry a-task 'workstream: ws-a'
save
board_ok
one a-task rest 1
one a-task ws-a 1
hasnt "$(row a-task ws-a)" 'unplaced'
