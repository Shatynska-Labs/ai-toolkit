#!/usr/bin/env bash
# Scenario: A summary
# Requirement: A task shows what it consists of
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: an entry's summary value is shown under its name.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
entry loose-entry 'workstream: ws-a' 'summary: the summary sentence'
save
board_ok
has "$(row loose-entry ws-a)" 'the summary sentence'
REGION=ws-a in_order loose-entry 'the summary sentence'
