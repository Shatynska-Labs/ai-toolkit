#!/usr/bin/env bash
# Requirement: An unreachable forge is stated, never read as planned
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: gh failing or unauthenticated reads as not reached, and the board is still written.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
save
touch "$TESTDIR/gh-fails"
board_ok
hasre "$(pg text)" 'forge.*not reached|not reach.*forge'
hasre "$(report)" 'forge.*not reached|not reach.*forge'
