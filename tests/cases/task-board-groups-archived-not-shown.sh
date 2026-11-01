#!/usr/bin/env bash
# Scenario: An archived workstream
# Requirement: Open workstreams are the board's groups
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a file under docs/workstreams/archive/ gets no group.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-open a-step
mkdir -p "$P/docs/workstreams/archive"
workstream ws-old old-step
mv "$P/docs/workstreams/ws-old.md" "$P/docs/workstreams/archive/ws-old.md"
save
board_ok
one ws-old all 0
one old-step all 0
