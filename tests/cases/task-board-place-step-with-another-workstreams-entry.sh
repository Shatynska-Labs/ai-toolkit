#!/usr/bin/env bash
# Scenario: A step named by another workstream's entry value
# Requirement: Every task is placed once
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a step of A whose entry names B appears once, as a step of A.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-task
workstream ws-b b-step
entry a-task 'workstream: ws-b'
save
board_ok
one a-task ws-a 1
one a-task rest 1
hasnt "$(row a-task ws-a)" 'unplaced'
