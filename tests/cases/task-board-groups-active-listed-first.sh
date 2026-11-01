#!/usr/bin/env bash
# Scenario: Active and other workstreams
# Requirement: Open workstreams are the board's groups
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: four workstreams with a task in flight are listed before fourteen without.
# SPECIFIED: each active workstream is a closed row.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
i=1; while [ $i -le 14 ]; do workstream "ws-idle-$i" "idle-$i"; i=$((i + 1)); done
i=1; while [ $i -le 4 ]; do workstream "ws-live-$i" "live-$i"; i=$((i + 1)); done
save
i=1; while [ $i -le 4 ]; do branch "live-$i"; i=$((i + 1)); done
board_ok
i=1
while [ $i -le 4 ]; do
  o="$(pg outer "ws-live-$i" rest)"
  has "$o" "ws-live-$i"
  has "$o" ' closed '
  [ "$(pos "ws-live-$i")" -lt "$(pos ws-idle-1)" ] || die "ws-live-$i comes after an idle workstream"
  i=$((i + 1))
done
