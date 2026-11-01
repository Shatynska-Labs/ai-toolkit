#!/usr/bin/env bash
# Requirement: The board is read from the trunk
# Change: task-board (task-board, ADDED).
#
# DERIVED (design decision 1): with no origin/HEAD and no origin/main the trunk is origin/master.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry on-trunk
save
g branch -m main master
g push -q origin master
git -C "$ORIGIN" symbolic-ref HEAD refs/heads/master
g push -q origin --delete main
g remote set-head origin --delete
board_ok
one on-trunk rest 1
