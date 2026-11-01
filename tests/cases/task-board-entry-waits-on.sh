#!/usr/bin/env bash
# Requirement: The page carries what a task's entry states
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the page shows the entry's waits_on names.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry 'waits_on: [first-dependency, second-dependency]'
save
board_ok
has "$(row an-entry)" 'first-dependency'
has "$(row an-entry)" 'second-dependency'
