#!/usr/bin/env bash
# Scenario: Forge read in full
# Requirement: An unreachable forge is stated, never read as planned
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: an answer below the limit leaves no task with the unchecked mark.
# DERIVED: the word unchecked is the mark or its explanation. With forge-no-gh-marks-a-step, which requires a difference, this fixes the direction.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
entry an-entry
save
pr merged-elsewhere MERGED
board_ok
hasntre "$(row a-step ws-a)" 'unchecked|not checked|could not be checked'
hasntre "$(row an-entry)" 'unchecked|not checked|could not be checked'
hasre "$(report)" 'full'
