#!/usr/bin/env bash
# Requirement: The tool writes one self-contained page for one project
# Change: report-the-board-as-json (task-board, MODIFIED).
#
# DERIVED (tasks.md 3.1): --help names --json; the requirement states only that it prints usage.
#
# Runs the tool; red until scripts/task-board accepts --json.
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"
source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
board_in "$P" --help
assert_exit 0 "$RC"
has "$(report)" '--json'
