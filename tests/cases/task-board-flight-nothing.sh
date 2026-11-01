#!/usr/bin/env bash
# Scenario: Nothing in flight
# Requirement: The page opens with what is in flight
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the section says nothing is in flight.
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
hasre "$(flight)" 'nothing (is )?in flight'
