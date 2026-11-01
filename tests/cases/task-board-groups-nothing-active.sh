#!/usr/bin/env bash
# Scenario: Nothing active
# Requirement: Open workstreams are the board's groups
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: where no workstream has a task in flight the page says none is active.
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
hasre "$(pg text)" 'no (workstream is active|active workstream)'
