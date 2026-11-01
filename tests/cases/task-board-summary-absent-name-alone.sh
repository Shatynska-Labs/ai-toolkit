#!/usr/bin/env bash
# Scenario: No summary
# Requirement: A task shows what it consists of
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: an entry no step names, with no summary, shows its name and no description: its body does not stand in.
# DERIVED: read from the row's summary element, since the collapsed body is rightly elsewhere in the row.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
entry loose-entry 'workstream: ws-a'
save
board_ok
s="$(pg summary loose-entry ws-a)"
has "$s" 'loose-entry'
hasnt "$s" 'The entry body'
hasnt "$s" 'the goal text'
