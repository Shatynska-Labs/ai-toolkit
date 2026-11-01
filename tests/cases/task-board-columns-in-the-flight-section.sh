#!/usr/bin/env bash
# Scenario: The in-flight section's columns
# Requirement: Tasks are listed in columns
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: its columns are task, stage, last commit and workstream, each with a heading.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-task
save
branch a-task
board_ok
h="$(flight | tr 'A-Z' 'a-z' | grep -Ex 'task|stage|last commit|workstream' | head -n4 | tr '\n' ',')"
[ "$h" = 'task,stage,last commit,workstream,' ] || die "headings of the section: [$h]"
