#!/usr/bin/env bash
# Scenario: Branches that are not tasks
# Requirement: Every task is placed once
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a branch with a / in its name adds no task.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
save
branch dependabot/bump-thing
board_ok
one bump-thing all 0
one dependabot all 0
