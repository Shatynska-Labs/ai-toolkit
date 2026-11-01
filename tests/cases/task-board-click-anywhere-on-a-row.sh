#!/usr/bin/env bash
# Scenario: Clicking a row
# Requirement: Tasks are listed in columns
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a click anywhere on the row opens the body.
# DERIVED (design decision 9): with no script that means the whole row is the summary of a <details>, so its status sits inside the summary with its name, and the body outside.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-task
entry a-task
save
board_ok
s="$(pg summary a-task ws-a)"
has "$s" 'a-task'
has "$s" 'recorded'
hasnt "$s" 'The entry body'
has "$(group ws-a)" 'The entry body'
