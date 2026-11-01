#!/usr/bin/env bash
# A stage in a group carries the unchecked mark too.
# Added with its fix at code review; see test-plan.md, Cases added by code review.
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"
source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-task
change a-task
save
board_ok
read_in_full="$(row a-task ws-a)"
touch "$TESTDIR/gh-fails"
board_ok
[ "$(row a-task ws-a)" != "$read_in_full" ] || die "the stage carries no mark: $read_in_full"
