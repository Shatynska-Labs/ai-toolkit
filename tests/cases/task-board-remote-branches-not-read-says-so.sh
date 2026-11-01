#!/usr/bin/env bash
# Scenario: Remote branches cannot be listed
# Requirement: The board is read from the trunk
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: where the remote cannot be reached the page and the report say remote branches were not read.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry on-trunk
save
g remote set-url origin "$TESTDIR/gone.git"
board_ok
hasre "$(pg text)" 'remote branches.*not|not.*remote branches'
hasre "$(report)" 'remote branches.*not|not.*remote branches'
