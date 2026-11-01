#!/usr/bin/env bash
# Scenario: No remote
# Requirement: The board is read from the trunk
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the page and the report say the repository has no remote.
# DERIVED: the wording carries no remote, or no origin. The report line is not yet fixed.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry on-trunk
save
g remote remove origin
board_ok
hasre "$(pg text)" "no (remote|.?origin)"
hasre "$(report)" "no (remote|.?origin)|remote.*(none|no\b)"
