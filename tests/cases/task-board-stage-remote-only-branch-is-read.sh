#!/usr/bin/env bash
# Requirement: A task in flight shows its stage
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a change's files are read from the remote's branch where ls-remote listed it, so a remote-only branch with a reference has its proposal read.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
save
other_clone
in_other on_branch a-task
in_other change a-task
in_other leave_branch
in_other g push -q origin a-task
board_ok
has "$(row a-task flight)" 'plan:drafting'
