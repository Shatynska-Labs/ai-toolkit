#!/usr/bin/env bash
# An open change is listed in flight whatever its name.
# Added with its fix at code review; see test-plan.md, Cases added by code review.
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"
source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
change My_change
save
board_ok
one My_change flight 1
has "$(row My_change flight)" 'plan:drafting'
