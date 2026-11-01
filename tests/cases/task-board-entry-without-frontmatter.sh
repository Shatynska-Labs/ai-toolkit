#!/usr/bin/env bash
# Scenario: An entry without frontmatter
# Requirement: The page carries what a task's entry states
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: it is shown with a warning, reading as normal and naming no workstream.
# DERIVED: the warning reads warning, or names the frontmatter.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-step
echo 'Only a body.' > "$P/docs/backlog/bare-entry.md"
save
board_ok
in_loose_group bare-entry
r="$(row bare-entry)"
hasre "$r" 'warning|frontmatter'
hasntre "$r" '(^|[^a-z])normal([^a-z]|$)'
