#!/usr/bin/env bash
# From a subdirectory the default page is still named for the project.
# Added with its fix at code review; see test-plan.md, Cases added by code review.
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"
source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
save
mkdir -p "$P/sub"
board_in "$P/sub"
assert_exit 0 "$RC" "report: $(report)"
assert_file "$TMPDIR/task-board-project.html"
