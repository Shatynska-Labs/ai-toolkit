#!/usr/bin/env bash
# An output that is a directory is an ERROR and leaves nothing.
# Added with its fix at code review; see test-plan.md, Cases added by code review.
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"
source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
save
mkdir -p "$TESTDIR/a-dir"
OUT="$TESTDIR/a-dir"
board
assert_exit 1 "$RC" "report: $(report)"
assert_contains "$REPORT" 'Outcome: ERROR'
[ -z "$(ls -A "$TESTDIR/a-dir")" ] || die "left in the directory: $(ls -A "$TESTDIR/a-dir")"
