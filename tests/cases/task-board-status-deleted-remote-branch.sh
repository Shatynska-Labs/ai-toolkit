#!/usr/bin/env bash
# Scenario: A deleted remote branch
# Requirement: A task's status is derived by its name
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a remote-tracking reference to a branch deleted on the remote does not make the task in flight.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-task
save
branch a-task
g push -q origin a-task
g fetch -q origin
g branch -q -D a-task
other_clone
in_other g push -q origin --delete a-task
git -C "$P" rev-parse -q --verify refs/remotes/origin/a-task >/dev/null || die "fixture: the reference is gone"
board_ok
status_is a-task ws-a planned
