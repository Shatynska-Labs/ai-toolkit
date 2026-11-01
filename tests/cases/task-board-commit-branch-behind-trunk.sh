#!/usr/bin/env bash
# Scenario: A branch with no commits of its own
# Requirement: Tasks are listed in columns
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a branch behind the trunk's tip reads the commit touching the change directory.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
change a-task
save 6
g branch a-task
echo x > "$P/unrelated.txt"
save 8
echo y >> "$P/docs/backlog/AGENTS.md"
save 2
board_ok
r="$(row a-task flight)"
hasre "$r" '(^|[^0-9])6 d'
