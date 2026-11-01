#!/usr/bin/env bash
# A bare repository has no working tree and is BLOCKED.
# Added with its fix at code review; see test-plan.md, Cases added by code review.
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"
source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
save
board_in "$ORIGIN" --output "$OUT"
blocked
hasre "$(report)" 'Reason:.*bare'
