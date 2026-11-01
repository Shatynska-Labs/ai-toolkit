#!/usr/bin/env bash
# Requirement: A task shows what it consists of
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the line states a branch, an open pull request and a merged pull request where each exists.
# DERIVED: a pull request reads as PR or pull request.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
change a-task
save
branch a-task
pr a-task OPEN
pr a-task MERGED
board_ok
r="$(row a-task flight)"
printf '%s\n' "$r" | grep -qiw branch || die "no branch: $r"
hasre "$r" 'open (pr|pull request)'
hasre "$r" 'merged (pr|pull request)'
