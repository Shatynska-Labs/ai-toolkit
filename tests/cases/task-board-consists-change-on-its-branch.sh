#!/usr/bin/env bash
# Requirement: A task shows what it consists of
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a change counts whether on the trunk or on its branch.
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
leave_branch
board_ok
r="$(row a-task flight)"
printf '%s\n' "$r" | grep -qiw change || die "no change: $r"
