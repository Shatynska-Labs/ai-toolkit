#!/usr/bin/env bash
# Requirement: The board is read from the trunk
# Change: task-board (task-board, ADDED).
#
# DERIVED (design decision 1): origin/HEAD names the trunk, whatever its name.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry on-trunk
save
g branch -m main trunk-line
g push -q origin trunk-line
git -C "$ORIGIN" symbolic-ref HEAD refs/heads/trunk-line
g push -q origin --delete main
g remote set-head origin trunk-line
entry later
commit add 1
g push -q origin trunk-line
board_ok
one later rest 1
