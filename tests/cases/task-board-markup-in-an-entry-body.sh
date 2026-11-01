#!/usr/bin/env bash
# Scenario: Markup in an entry
# Requirement: The page carries what a task's entry states
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a <script> in a body shows as text and does not run.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
echo '<script>alert(1)</script>' >> "$P/docs/backlog/an-entry.md"
save
board_ok
hasnt "$(raw)" '<script'
has "$(raw)" '&lt;script&gt;'
