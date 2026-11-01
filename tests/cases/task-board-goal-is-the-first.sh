#!/usr/bin/env bash
# A later line shaped as a Goal does not replace it.
# Added with its fix at code review; see test-plan.md, Cases added by code review.
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"
source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
printf '\n## Context\n\n**Goal**: a quoted other goal.\n' >> "$P/docs/workstreams/ws-a.md"
save
board_ok
has "$(group ws-a)" 'the goal text.'
hasnt "$(group ws-a)" 'a quoted other goal.'
