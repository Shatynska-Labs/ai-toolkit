#!/usr/bin/env bash
# Scenario: A workstream that is not open
# Requirement: Every task is placed once
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: an entry naming a workstream with no open file appears in the collapsed group with a note naming it.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
entry loose-entry 'workstream: ws-closed'
save
board_ok
in_loose_group loose-entry
has "$(row loose-entry)" 'ws-closed'
