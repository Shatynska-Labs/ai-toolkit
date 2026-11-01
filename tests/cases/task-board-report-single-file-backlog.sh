#!/usr/bin/env bash
# Scenario: A single-file backlog
# Requirement: The tool reports its outcome
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: docs/backlog.md and no docs/backlog/ on the trunk is BLOCKED, the reason naming scripts/backlog-migrate.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
rm -rf "$P/docs/backlog"
echo '# Backlog' > "$P/docs/backlog.md"
save
board
blocked
hasre "$(report)" 'Reason:.*scripts/backlog-migrate'
