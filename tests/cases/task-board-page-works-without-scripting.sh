#!/usr/bin/env bash
# Scenario: The page stands alone
# Requirement: The tool writes one self-contained page for one project
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: every group can be opened and read with scripting disabled.
# DERIVED (design decision 9): groups are <details>, and the page holds no script or inline handler.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
entry an-entry
save
board_ok
hasntre "$(raw)" '<script|[ "]on(click|load|toggle)='
has "$(pg gsum ws-a)" 'ws-a'
has "$(group ws-a)" 'a-step'
