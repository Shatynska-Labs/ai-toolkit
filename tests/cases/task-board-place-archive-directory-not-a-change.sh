#!/usr/bin/env bash
# Requirement: Every task is placed once
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: openspec/changes/archive is not an open change.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
archived old-change
save
board_ok
one archive all 0
hasre "$(flight)" 'nothing (is )?in flight'
