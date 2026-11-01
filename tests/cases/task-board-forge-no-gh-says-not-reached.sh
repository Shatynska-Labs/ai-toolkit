#!/usr/bin/env bash
# Scenario: No gh
# Requirement: An unreachable forge is stated, never read as planned
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: with gh not installed the board is written, and the page and the report say the forge was not reached.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
save
hide_gh
board_ok
hasre "$(pg text)" 'forge.*not reached|not reach.*forge'
hasre "$(report)" 'forge.*not reached|not reach.*forge'
