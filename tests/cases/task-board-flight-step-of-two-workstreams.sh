#!/usr/bin/env bash
# Scenario: A step of two workstreams in flight
# Requirement: The page opens with what is in flight
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: its line names both workstreams.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a shared-step
workstream ws-b shared-step
save
branch shared-step
board_ok
has "$(row shared-step flight)" 'ws-a'
has "$(row shared-step flight)" 'ws-b'
