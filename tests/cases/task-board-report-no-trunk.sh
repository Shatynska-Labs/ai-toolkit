#!/usr/bin/env bash
# Scenario: No trunk
# Requirement: The tool reports its outcome
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: origin present and no trunk reference resolving is BLOCKED, the reason saying what is missing.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
repo_only
echo x > "$P/file"
commit first 1
board
blocked
hasre "$(report)" 'Reason:.*trunk'
