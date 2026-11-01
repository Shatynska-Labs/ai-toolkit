#!/usr/bin/env bash
# Scenario: Not a repository
# Requirement: The tool reports its outcome
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: BLOCKED, exit 2, no page.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
stub_gh
mkdir -p "$P"
board
blocked
