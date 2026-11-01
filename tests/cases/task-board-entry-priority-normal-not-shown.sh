#!/usr/bin/env bash
# Requirement: The page carries what a task's entry states
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the priority shows only where it is not normal.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry 'priority: normal'
save
board_ok
hasntre "$(row an-entry)" '(^|[^a-z])normal([^a-z]|$)'
