#!/usr/bin/env bash
# Scenario: The page stands alone
# Requirement: The tool writes one self-contained page for one project
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the page refers to no external resource.
# DERIVED: the markers of one: a stylesheet link, src, an http reference in markup, @import, url() outside the page.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
entry an-entry
save
branch a-step
board_ok
hasntre "$(raw)" '<link[ >]|[ "]src=|(href|action)="(https?:)?//|@import|url\((https?:)?//'
