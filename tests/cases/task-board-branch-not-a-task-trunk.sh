#!/usr/bin/env bash
# Scenario: Branches that are not tasks
# Requirement: Every task is placed once
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the trunk's branch adds no task.
# DERIVED: observed as nothing being in flight, under a trunk not named main or master.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
save
g branch -m main trunk-line
g push -q origin trunk-line
git -C "$ORIGIN" symbolic-ref HEAD refs/heads/trunk-line
g push -q origin --delete main
g remote set-head origin trunk-line
board_ok
one trunk-line flight 0
hasre "$(flight)" 'nothing (is )?in flight'
