#!/usr/bin/env bash
# Scenario: A change on its branch naming a workstream
# Requirement: Every task is placed once
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a proposal on the branch only, naming open A, puts the change in A's group, marked unplaced.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
save
on_branch new-change
change new-change ws-a
leave_branch
board_ok
one new-change ws-a 1
has "$(row new-change ws-a)" 'unplaced'
