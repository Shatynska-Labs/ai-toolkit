#!/usr/bin/env bash
# Requirement: The page opens with what is in flight
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the section lists the most recent last commit first.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
save 20
branch old-work 9
branch new-work 2
branch mid-work 5
board_ok
REGION=flight in_order new-work mid-work old-work
