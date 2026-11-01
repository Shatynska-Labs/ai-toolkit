#!/usr/bin/env bash
# Requirement: The board is read from the trunk
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the board is read from the trunk as fetched, so a commit on origin the clone has not fetched is on it, and an unpushed one is not.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry on-trunk
save
other_clone
in_other entry pushed-elsewhere
in_other commit add 1
in_other g push -q origin main
entry not-pushed
commit add 1
board_ok
one pushed-elsewhere rest 1
one not-pushed all 0
