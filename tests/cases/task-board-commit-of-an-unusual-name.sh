#!/usr/bin/env bash
# An entry of a non-ASCII name keeps its last commit.
# Added with its fix at code review; see test-plan.md, Cases added by code review.
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"
source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry задача
save 6
entry other-entry
save 2
board_ok
hasre "$(row задача)" '(^|[^0-9])6 d'
