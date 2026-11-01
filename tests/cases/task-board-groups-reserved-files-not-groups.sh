#!/usr/bin/env bash
# Requirement: Open workstreams are the board's groups
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: AGENTS.md, CLAUDE.md and README.md in docs/workstreams/ are not workstreams.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
echo '# readme' > "$P/docs/workstreams/README.md"
echo '@AGENTS.md' > "$P/docs/workstreams/CLAUDE.md"
workstream ws-a a-step
save
board_ok
one README rest 0
one CLAUDE rest 0
one AGENTS rest 0
