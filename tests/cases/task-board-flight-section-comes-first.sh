#!/usr/bin/env bash
# Requirement: The page opens with what is in flight
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the page begins with the section of what is in flight, before any group.
# SPECIFIED: the section lists every task in flight, whichever group it is placed in.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-task
change loose-change
save
branch a-task
board_ok
[ "$(pos a-task all)" -lt "$(pos ws-a all)" ] || die "the in-flight section does not come before the groups"
one a-task flight 1
one loose-change flight 1
