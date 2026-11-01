#!/usr/bin/env bash
# Scenario: The page states its moment
# Requirement: The tool writes one self-contained page for one project
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the page shows the trunk commit read.
# DERIVED: the commit appears as at least its first seven hexadecimal digits.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
save
sha="$(git -C "$P" rev-parse origin/main)"
board_ok
has "$(pg text)" "$(printf '%s' "$sha" | cut -c1-7)"
