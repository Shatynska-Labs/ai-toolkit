#!/usr/bin/env bash
# Scenario: Rows with and without a body
# Requirement: Tasks are listed in columns
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a row with a body and a row without have the same columns.
# DERIVED: observed as the same number of cells, a cell being a child of the row, or of its summary where the row is a <details>.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a with-entry without-entry
entry with-entry
save
board_ok
a="$(pg cells with-entry ws-a)"
b="$(pg cells without-entry ws-a)"
[ -n "$a" ] && [ "$a" -ge 2 ] || die "no cells read: [$a]"
[ "$a" = "$b" ] || die "cells differ: $a and $b"
