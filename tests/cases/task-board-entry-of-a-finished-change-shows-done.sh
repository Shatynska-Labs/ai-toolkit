#!/usr/bin/env bash
# Requirement: Tasks are listed in columns
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: an entry still on the trunk after its change finished is listed among the tasks in no workstream, as done.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
entry finished-entry
archived finished-entry
save
board_ok
in_loose_group finished-entry
status_is finished-entry rest 'done'
