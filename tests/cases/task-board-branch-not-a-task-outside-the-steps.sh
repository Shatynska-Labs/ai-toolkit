#!/usr/bin/env bash
# A numbered line outside the steps makes no branch a task.
# Added with its fix at code review; see test-plan.md, Cases added by code review.
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"
source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
printf '\n## Decisions\n\n1. `feature/x` was chosen.\n' >> "$P/docs/workstreams/ws-a.md"
save
branch feature/x
board_ok
one x all 0
