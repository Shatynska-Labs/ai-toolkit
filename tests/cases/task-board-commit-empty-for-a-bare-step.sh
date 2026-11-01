#!/usr/bin/env bash
# Scenario: A step that is only a name
# Requirement: Tasks are listed in columns
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a step with no branch, change or entry has an empty last commit cell.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a bare-step
save 6
board_ok
hasntre "$(row bare-step ws-a)" '[0-9] ?(d|h|m|min|w|y)([^a-z]|$)'
