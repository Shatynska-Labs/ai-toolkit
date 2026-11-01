#!/usr/bin/env bash
# Scenario: The in-flight section's columns
# Requirement: Tasks are listed in columns
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a row in the section opens no body.
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
branch a-task
board_ok
one a-task flight 1
hasnt "$(flight)" 'The entry body'
has "$(group ws-a)" 'The entry body'
