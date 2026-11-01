#!/usr/bin/env bash
# Scenario: A proposal with no ticked task
# Requirement: A task in flight shows its stage
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a proposal on the branch and no ticked task is plan:drafting.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
save
on_branch a-task
change a-task
tasks_file a-task 0 3
leave_branch
board_ok
has "$(row a-task flight)" 'plan:drafting'
