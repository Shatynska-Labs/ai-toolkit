#!/usr/bin/env bash
# Scenario: The forge is not read in full
# Requirement: A task in flight shows its stage
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: every stage carries the unchecked mark where the forge was not read in full, a change on the trunk included.
# DERIVED: the mark is observed as a difference in the row's visible text between a run with the forge read and one without. See the unresolved questions.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
change a-task
save
board_ok
read_in_full="$(row a-task flight)"
touch "$TESTDIR/gh-fails"
board_ok
[ "$(row a-task flight)" != "$read_in_full" ] || die "the stage carries no mark: $read_in_full"
