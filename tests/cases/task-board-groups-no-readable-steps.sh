#!/usr/bin/env bash
# Scenario: A workstream with no readable steps
# Requirement: Open workstreams are the board's groups
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: its group appears with a warning saying its steps could not be read.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
printf '%s\n' '# `ws-bad`' '' '- **Goal**: the goal text.' '- **Done when**: the done text.' '' 'Nothing shaped as steps.' \
  > "$P/docs/workstreams/ws-bad.md"
save
board_ok
hasre "$(group ws-bad)" 'steps.*(could not|cannot|not).*read|(could not|cannot).*read.*steps'
