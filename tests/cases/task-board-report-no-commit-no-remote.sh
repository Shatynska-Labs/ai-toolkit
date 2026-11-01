#!/usr/bin/env bash
# Scenario: No trunk
# Requirement: The tool reports its outcome
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: with no remote too, no commit is BLOCKED.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
repo_only
g remote remove origin
board
blocked
hasre "$(report)" 'Reason:.*commit'
