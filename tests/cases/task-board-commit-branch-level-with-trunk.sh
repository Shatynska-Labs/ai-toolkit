#!/usr/bin/env bash
# Scenario: A branch with no commits of its own
# Requirement: Tasks are listed in columns
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a branch at the trunk's tip reads the commit touching the entry, not the branch tip.
# DERIVED: the tip is an unrelated later commit, so the two differ.
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
commit unrelated 2
g push -q origin main
g branch a-task
board_ok
r="$(row a-task ws-a)"
hasre "$r" '(^|[^0-9])6 d'
hasntre "$r" '(^|[^0-9])2 d'
