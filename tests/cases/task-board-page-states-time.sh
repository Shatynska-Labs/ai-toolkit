#!/usr/bin/env bash
# Scenario: The page states its moment
# Requirement: The tool writes one self-contained page for one project
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the page shows the time of the run.
# DERIVED: the time carries the date as YYYY-MM-DD, local or UTC. See the unresolved questions.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
save
board_ok
hasre "$(pg text)" "$(date +%Y-%m-%d)|$(date -u +%Y-%m-%d)"
