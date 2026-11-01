#!/usr/bin/env bash
# Scenario: A parked entry
# Requirement: The page carries what a task's entry states
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: an entry with priority: parked shows that it is parked.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry 'priority: parked'
save
board_ok
has "$(row an-entry)" 'parked'
