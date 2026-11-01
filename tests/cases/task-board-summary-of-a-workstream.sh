#!/usr/bin/env bash
# Scenario: A summary
# Requirement: A task shows what it consists of
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a workstream's **Summary** line is shown under its name, in its row.
# DERIVED: the fixture writes it as a list item before the Goal. See the unresolved questions.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
WS_SUMMARY='the workstream sentence' workstream ws-a a-step
save
board_ok
has "$(pg gsum ws-a)" 'the workstream sentence'
