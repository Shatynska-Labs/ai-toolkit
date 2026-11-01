#!/usr/bin/env bash
# Scenario: A task with no workstream
# Requirement: Every task is placed once
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: an open change naming no workstream, with no entry, appears in the collapsed group.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
change loose-change
save
board_ok
in_loose_group loose-change
