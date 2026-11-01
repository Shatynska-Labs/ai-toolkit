#!/usr/bin/env bash
# Requirement: Open workstreams are the board's groups
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: opening a row shows the Goal and the Done when, inside the group.
# DERIVED: the text sits outside the group's summary, so it shows on opening and not before.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
save
board_ok
has "$(group ws-a)" 'the goal text.'
has "$(group ws-a)" 'the done text.'
hasnt "$(pg gsum ws-a)" 'the goal text.'
hasnt "$(pg gsum ws-a)" 'the done text.'
