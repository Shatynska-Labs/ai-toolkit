#!/usr/bin/env bash
# Requirement: The tool reports its outcome
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the report states the target, the page, the trunk read, that it was fetched, that remote branches were read, the forge read in full, the warnings, and Outcome: SUCCESS, exit 0.
# DERIVED: each reads by word, since tests/README.md gains the exact lines at task 4.1. See the unresolved questions.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
save
board_ok
r="$(report)"
has "$r" "$(cd "$P" && pwd -P)"
has "$r" "$OUT"
has "$r" 'main'
hasre "$r" 'fetch'
hasre "$r" 'remote branches'
hasre "$r" 'forge.*full|full.*forge'
hasre "$r" 'warnings?:? *0|0 warnings?'
