#!/usr/bin/env bash
# Scenario: One name in three concepts
# Requirement: A task shows what it consists of
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: one line is shown, stating step, entry and change.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-task
entry a-task
change a-task
save
board_ok
one a-task flight 1
r="$(row a-task flight)"
printf '%s\n' "$r" | grep -qiw step || die "no step: $r"
printf '%s\n' "$r" | grep -qiw entry || die "no entry: $r"
printf '%s\n' "$r" | grep -qiw change || die "no change: $r"
