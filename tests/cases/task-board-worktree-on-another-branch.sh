#!/usr/bin/env bash
# Scenario: A worktree on another branch
# Requirement: The board is read from the trunk
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: an entry only the working tree's branch adds is not on the board as an entry.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry on-trunk
save
on_branch side-work
entry only-on-side
commit add 1
g checkout -q main
g worktree add -q "$TESTDIR/linked" side-work
board_in "$TESTDIR/linked" --output "$OUT"
assert_exit 0 "$RC" "report: $(report)"
one on-trunk rest 1
one only-on-side all 0
