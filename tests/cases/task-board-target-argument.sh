#!/usr/bin/env bash
# Requirement: The tool writes one self-contained page for one project
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the project directory is the one optional argument.
# DERIVED: run from a directory that is not a repository, so the argument and not the working directory is what is read.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
save
mkdir -p "$TESTDIR/away"
board_in "$TESTDIR/away" --output "$OUT" "$P"
assert_exit 0 "$RC" "report: $(report)"
assert_contains "$OUT" 'an-entry'
