#!/usr/bin/env bash
# Requirement: The tool reports its outcome
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the report states the number of warnings on the page.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
echo 'Only a body.' > "$P/docs/backlog/bare-one.md"
echo 'Only a body.' > "$P/docs/backlog/bare-two.md"
save
board_ok
hasre "$(report)" 'warnings?:? *2|2 warnings?'
