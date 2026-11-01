#!/usr/bin/env bash
# Requirement: Tasks are listed in columns
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a task with no branch reads the last commit on the trunk touching its entry.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
save 6
entry other-entry
save 2
board_ok
hasre "$(row an-entry)" '(^|[^0-9])6 d'
