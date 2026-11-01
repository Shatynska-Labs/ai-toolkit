#!/usr/bin/env bash
# Scenario: Steps keep their order
# Requirement: Open workstreams are the board's groups
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: three steps show in the file's order, whatever their statuses.
# DERIVED: the statuses are chosen so a sort by status or by name would reorder them.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a zulu-step mike-step alpha-step
archived alpha-step
save
branch mike-step
board_ok
REGION=ws-a in_order zulu-step mike-step alpha-step
