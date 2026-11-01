#!/usr/bin/env bash
# Scenario: A step in two workstreams
# Requirement: Every task is placed once
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: both groups warn about it.
# DERIVED: a third group with no shared step carries no such warning, so the words below are not the page furniture.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a shared-step
workstream ws-b shared-step
workstream ws-c other-step
save
board_ok
hasre "$(group ws-a)" 'warning|two workstreams|another workstream|also a step|listed in'
hasre "$(group ws-b)" 'warning|two workstreams|another workstream|also a step|listed in'
hasntre "$(group ws-c)" 'warning|two workstreams|another workstream|also a step|listed in'
