#!/usr/bin/env bash
# Requirement: The tool writes one self-contained page for one project
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the file is named for the main working tree, so every working tree of a project shares one page.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
save
g worktree add -q "$TESTDIR/linked" -b linked-tree
board_in "$TESTDIR/linked"
assert_exit 0 "$RC" "report: $(report)"
assert_file "$TMPDIR/task-board-project.html"
has "$(report)" "$TMPDIR/task-board-project.html"
