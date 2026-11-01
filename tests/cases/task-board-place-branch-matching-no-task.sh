#!/usr/bin/env bash
# Scenario: A branch matching no task
# Requirement: Every task is placed once
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a kebab-case branch no step, entry or change names appears in the collapsed group as in flight.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
save
branch stray-branch
board_ok
in_loose_group stray-branch
status_is stray-branch rest 'in flight'
