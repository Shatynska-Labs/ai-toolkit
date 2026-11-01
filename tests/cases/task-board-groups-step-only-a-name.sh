#!/usr/bin/env bash
# Scenario: A step that is only a name
# Requirement: Open workstreams are the board's groups
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a step with no entry, change or branch shows its name and description with the status planned.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a 'bare-step|its own description'
save
board_ok
has "$(row bare-step ws-a)" 'its own description'
status_is bare-step ws-a planned
