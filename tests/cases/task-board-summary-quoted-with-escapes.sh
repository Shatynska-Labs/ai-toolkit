#!/usr/bin/env bash
# Requirement: A task shows what it consists of
# Change: task-board (task-board, ADDED).
#
# DERIVED (design decision 5): a double-quoted value is unquoted and its \" and \\ unescaped, then escaped for the page.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
entry loose-entry 'workstream: ws-a' 'summary: "a \"quoted\" back\\slash"'
save
board_ok
has "$(row loose-entry ws-a)" 'a &quot;quoted&quot; back\slash'
