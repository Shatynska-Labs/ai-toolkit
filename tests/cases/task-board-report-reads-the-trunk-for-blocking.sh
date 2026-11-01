#!/usr/bin/env bash
# Requirement: The tool reports its outcome
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: what blocks is what the trunk holds, not the working tree.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
rm -rf "$P/docs"
echo x > "$P/README.md"
save
mkdir -p "$P/docs/backlog"
echo 'untracked' > "$P/docs/backlog/here-only.md"
board
blocked
