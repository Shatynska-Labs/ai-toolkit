#!/usr/bin/env bash
# Scenario: Active and other workstreams
# Requirement: Open workstreams are the board's groups
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the fourteen are all inside one collapsed row.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
i=1; while [ $i -le 14 ]; do workstream "ws-idle-$i" "idle-$i"; i=$((i + 1)); done
workstream ws-live live-step
save
branch live-step
board_ok
first="$(pg outer ws-idle-1 rest)"
has "$first" ' closed '
hasnt "$first" 'ws-idle-1'
i=2
while [ $i -le 14 ]; do
  [ "$(pg outer "ws-idle-$i" rest)" = "$first" ] || die "ws-idle-$i is not in the same collapsed row"
  i=$((i + 1))
done
