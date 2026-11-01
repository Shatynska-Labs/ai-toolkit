#!/usr/bin/env bash
# Scenario: No gh
# Requirement: An unreachable forge is stated, never read as planned
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a step with no change of its name is marked as unchecked rather than shown as plainly planned.
# DERIVED: the mark is observed as a difference in the row's visible text. See the unresolved questions.
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
hide_gh
board_ok
[ "$(row a-step ws-a)" != "$read_in_full" ] || die "the step carries no mark: $read_in_full"
