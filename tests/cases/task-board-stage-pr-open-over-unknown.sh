#!/usr/bin/env bash
# Requirement: A task in flight shows its stage
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: ship:pr-open comes before unknown.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
save
g config remote.origin.fetch '+refs/heads/main:refs/remotes/origin/main'
other_clone
in_other branch a-task
in_other g push -q origin a-task
pr a-task OPEN
board_ok
has "$(row a-task flight)" 'ship:pr-open'
