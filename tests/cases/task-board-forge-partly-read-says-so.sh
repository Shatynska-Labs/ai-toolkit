#!/usr/bin/env bash
# Scenario: Forge partly read
# Requirement: An unreachable forge is stated, never read as planned
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: an answer reaching the limit makes the page and the report say pull requests were partly read.
# DERIVED: the stub cuts its answer at the --limit the call gives, so the case does not fix the limit.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
save
awk 'BEGIN { for (i = 1; i <= 20000; i++) printf "old-fix-%d\tMERGED\n", i }' > "$PRS"
board_ok
hasre "$(pg text)" 'partly'
hasre "$(report)" 'partly'
