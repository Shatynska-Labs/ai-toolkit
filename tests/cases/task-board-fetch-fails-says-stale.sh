#!/usr/bin/env bash
# Scenario: The fetch fails
# Requirement: The board is read from the trunk
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the page and the report say the trunk may be stale.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry was-fetched
save
g remote set-url origin "$TESTDIR/gone.git"
board_ok
hasre "$(pg text)" 'stale'
hasre "$(report)" 'stale'
