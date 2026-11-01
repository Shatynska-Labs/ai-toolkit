#!/usr/bin/env bash
# A step in flight is listed in flight whatever its name.
# Added with its fix at code review; see test-plan.md, Cases added by code review.
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"
source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a step_two
save
branch step_two
board_ok
one step_two flight 1
