#!/usr/bin/env bash
# Scenario: A branch's commit
# Requirement: Tasks are listed in columns
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a branch with commits the trunk lacks gives the last commit, as an elapsed time such as 6 d.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-task
entry a-task
save 6
branch a-task 3
board_ok
r="$(row a-task ws-a)"
hasre "$r" '(^|[^0-9])3 d'
hasntre "$r" '(^|[^0-9])6 d'
