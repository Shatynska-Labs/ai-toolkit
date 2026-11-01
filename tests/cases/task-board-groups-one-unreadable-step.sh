#!/usr/bin/env bash
# Scenario: One unreadable step
# Requirement: Open workstreams are the board's groups
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the other steps are shown, and the group warns about the line.
# DERIVED: the warning uses the word warning, or says the line could not be read.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a first-step '!no backticks here' third-step
save
board_ok
one first-step ws-a 1
one third-step ws-a 1
hasre "$(group ws-a)" 'warning|could not|cannot|unreadable'
