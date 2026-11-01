#!/usr/bin/env bash
# An archived name starting with digits keeps them.
# Added with its fix at code review; see test-plan.md, Cases added by code review.
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"
source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a fix 42-fix
mkdir -p "$P/openspec/changes/archive/2026-01-01-42-fix"
echo x > "$P/openspec/changes/archive/2026-01-01-42-fix/proposal.md"
save 3
board_ok
hasntre "$(row fix ws-a)" '[0-9] d'
hasre "$(row 42-fix ws-a)" '(^|[^0-9])3 d'
