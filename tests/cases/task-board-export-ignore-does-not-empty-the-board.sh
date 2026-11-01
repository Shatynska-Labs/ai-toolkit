#!/usr/bin/env bash
# export-ignore in a project hides nothing from the board.
# Added with its fix at code review; see test-plan.md, Cases added by code review.
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"
source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
echo 'docs export-ignore' > "$P/.gitattributes"
save
board_ok
one an-entry rest 1
