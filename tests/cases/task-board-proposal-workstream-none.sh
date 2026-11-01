#!/usr/bin/env bash
# A proposal naming `none` names no workstream.
# Added with its fix at code review; see test-plan.md, Cases added by code review.
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"
source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
change a-task none
save
board_ok
in_loose_group a-task
hasnt "$(row a-task)" 'not open'
