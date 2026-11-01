#!/usr/bin/env bash
# Scenario: A change in a workstream
# Requirement: The page opens with what is in flight
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the line links to A's group.
# DERIVED (design decision 7): the link is an in-page anchor to an element carrying that id.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-task
workstream ws-b b-step
change a-task ws-a
save
board_ok
href="$(pg link a-task flight | grep '^#' | head -n1)"
[ -n "$href" ] || die "no in-page link on the line: $(pg link a-task flight)"
has "$(pg target "${href#\#}")" 'ws-a'
