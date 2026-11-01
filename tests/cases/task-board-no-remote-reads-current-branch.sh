#!/usr/bin/env bash
# Scenario: No remote
# Requirement: The board is read from the trunk
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: with no remote named origin the board is written from the current branch.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry on-trunk
save
g remote remove origin
on_branch current-work
entry on-current
commit add 1
board_ok
one on-current rest 1
