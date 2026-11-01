#!/usr/bin/env bash
# Requirement: Every task is placed once
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: an entry with workstream: nothing names no workstream, and carries no note of one.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
entry loose-entry 'workstream: nothing'
save
board_ok
in_loose_group loose-entry
hasntre "$(row loose-entry)" '(^|[^a-z])nothing([^a-z]|$)'
