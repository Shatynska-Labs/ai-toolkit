#!/usr/bin/env bash
# Scenario: Nothing to show
# Requirement: The tool reports its outcome
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: neither directory on the trunk is BLOCKED, the reason naming scripts/project-init.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
rm -rf "$P/docs"
echo x > "$P/README.md"
save
board
blocked
hasre "$(report)" 'Reason:.*scripts/project-init'
