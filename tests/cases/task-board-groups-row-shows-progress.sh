#!/usr/bin/env bash
# Requirement: Open workstreams are the board's groups
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the row shows the count of steps done and of placed tasks in work, unplaced ones included.
# DERIVED: the fixture makes the two counts 1 and 2, each a number of its own in the row, in whatever wording.
# DELIBERATELY UNTESTED: one mark per step. A mark may be a bare styled element with no text, so nothing here can read it without fixing the markup.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a finished-step busy-step idle-step
archived finished-step
change loose-change ws-a
save
branch busy-step
board_ok
s="$(pg gsum ws-a)"
hasre "$s" '(^|[^0-9])1([^0-9]|$)'
hasre "$s" '(^|[^0-9])2([^0-9]|$)'
