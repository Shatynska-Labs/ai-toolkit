#!/usr/bin/env bash
# Scenario: Unwritable output
# Requirement: The tool reports its outcome
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: an output path that cannot be written is ERROR, exit 1.
# DERIVED: the path runs through a regular file, which holds for any user, root included.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
save
: > "$TESTDIR/a-file"
OUT="$TESTDIR/a-file/page.html"
board
assert_exit 1 "$RC" "report: $(report)"
assert_contains "$REPORT" 'Outcome: ERROR'
