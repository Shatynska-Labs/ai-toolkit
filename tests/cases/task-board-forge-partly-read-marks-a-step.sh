#!/usr/bin/env bash
# Scenario: Forge partly read
# Requirement: An unreachable forge is stated, never read as planned
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: tasks with no change of their name carry the unchecked mark.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
save
board_ok
read_in_full="$(row a-step ws-a)"
awk 'BEGIN { for (i = 1; i <= 20000; i++) printf "old-fix-%d\tMERGED\n", i }' > "$PRS"
board_ok
[ "$(row a-step ws-a)" != "$read_in_full" ] || die "the step carries no mark: $read_in_full"
