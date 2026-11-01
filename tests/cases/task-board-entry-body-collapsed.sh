#!/usr/bin/env bash
# Requirement: The page carries what a task's entry states
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the entry's body is shown, collapsed.
# DERIVED: collapsed means inside a <details> with no open attribute, outside its summary. The group here is open, there being no workstream, so the case reads the body's own <details>.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
save
board_ok
has "$(row an-entry)" 'The entry body.'
hasnt "$(pg summary an-entry rest)" 'The entry body.'
[ "$(pg near 'The entry body.' rest)" = closed ] || die "the body is not collapsed: $(pg near 'The entry body.' rest)"
