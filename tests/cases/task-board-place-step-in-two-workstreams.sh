#!/usr/bin/env bash
# Scenario: A step in two workstreams
# Requirement: Every task is placed once
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: it appears as a step of each.
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
board_ok
one shared-step ws-a 1
one shared-step ws-b 1
