#!/usr/bin/env bash
# Requirement: The page carries what a task's entry states
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: every value read from the repository is escaped: a summary, a step description, a Goal.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a 'a-step|<b class="x">step & words</b>'
sed -i.bak 's/the goal text\./<i>goal<\/i>/' "$P/docs/workstreams/ws-a.md"
rm -f "$P/docs/workstreams/ws-a.md.bak"
entry an-entry 'summary: <u>a summary</u>'
save
board_ok
hasnt "$(raw)" '<b class='
hasnt "$(raw)" '<i>goal'
hasnt "$(raw)" '<u>a summary'
has "$(raw)" '&lt;b class=&quot;x&quot;&gt;step &amp; words'
