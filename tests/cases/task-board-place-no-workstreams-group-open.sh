#!/usr/bin/env bash
# Scenario: A project with no workstreams
# Requirement: Every task is placed once
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: with no open workstream the entries are shown in a group that is open.
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
o="$(pg outer an-entry rest)"
has "$o" ' open '
