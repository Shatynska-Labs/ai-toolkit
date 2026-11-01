#!/usr/bin/env bash
# A target that does not exist is BLOCKED.
# Added with its fix at code review; see test-plan.md, Cases added by code review.
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"
source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
stub_gh
mkdir -p "$TESTDIR/away"
board_in "$TESTDIR/away" --output "$OUT" "$TESTDIR/missing"
blocked
