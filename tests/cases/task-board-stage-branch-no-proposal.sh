#!/usr/bin/env bash
# Scenario: A branch with no proposal
# Requirement: A task in flight shows its stage
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: no change directory on the branch or the trunk is plan:exploring.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
save
branch a-task
board_ok
has "$(row a-task flight)" 'plan:exploring'
