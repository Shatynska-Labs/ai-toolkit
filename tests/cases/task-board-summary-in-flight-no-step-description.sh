#!/usr/bin/env bash
# Requirement: A task shows what it consists of
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the section of what is in flight shows the summary and no step description.
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
branch a-task
board_ok
has "$(row a-task flight)" 'the summary sentence'
hasnt "$(row a-task flight)" 'the step words'
