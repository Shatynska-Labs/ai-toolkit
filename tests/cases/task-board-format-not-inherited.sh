#!/usr/bin/env bash
# An inherited TB_FORMAT does not turn a page run into a document.
# Added with its fix at code review; see test-plan.md.
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"
source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
save
export TB_FORMAT=json
board_ok
has "$(raw)" "<html"
