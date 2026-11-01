#!/usr/bin/env bash
# Scenario: An open change no step names
# Requirement: Every task is placed once
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: it appears in A's group, marked unplaced.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
change loose-change ws-a
save
board_ok
one loose-change ws-a 1
has "$(row loose-change ws-a)" 'unplaced'
