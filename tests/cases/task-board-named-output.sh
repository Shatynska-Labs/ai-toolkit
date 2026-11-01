#!/usr/bin/env bash
# Scenario: A named output
# Requirement: The tool writes one self-contained page for one project
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: --output <path> writes the page to that path, and the tool prints it.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
save
OUT="$TESTDIR/elsewhere/named.html"
mkdir -p "$TESTDIR/elsewhere"
board_ok
has "$(report)" "$OUT"
