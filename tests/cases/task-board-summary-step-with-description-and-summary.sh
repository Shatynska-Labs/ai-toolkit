#!/usr/bin/env bash
# Requirement: A task shows what it consists of
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: in a group's list a task shows its step's description and its entry's summary.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a 'a-task|the step words'
entry a-task 'summary: the summary sentence'
save
board_ok
has "$(row a-task ws-a)" 'the step words'
has "$(row a-task ws-a)" 'the summary sentence'
