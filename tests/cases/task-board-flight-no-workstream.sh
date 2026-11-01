#!/usr/bin/env bash
# Scenario: A change with no workstream
# Requirement: The page opens with what is in flight
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a branch matching no other task, with no proposal naming an open workstream, is listed as having no workstream.
# DERIVED: says none or no workstream.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
save
branch stray-branch
board_ok
hasre "$(row stray-branch flight)" 'no workstream|(^|[^a-z])none([^a-z]|$)'
