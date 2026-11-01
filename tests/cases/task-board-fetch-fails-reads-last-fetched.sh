#!/usr/bin/env bash
# Scenario: The fetch fails
# Requirement: The board is read from the trunk
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: where the remote cannot be reached the board is written from the last fetched trunk.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry was-fetched
save
entry not-pushed
commit add 1
g remote set-url origin "$TESTDIR/gone.git"
board_ok
one was-fetched rest 1
one not-pushed all 0
