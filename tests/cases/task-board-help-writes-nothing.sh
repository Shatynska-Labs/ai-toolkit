#!/usr/bin/env bash
# Requirement: The tool writes one self-contained page for one project
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: --help prints usage and writes nothing.
# DERIVED: exit 0, as the other shipped tools; usage contains the word usage.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
board_in "$P" --help
assert_exit 0 "$RC"
hasre "$(report)" 'usage'
[ -z "$(ls -A "$TMPDIR")" ] || die "--help wrote into the temporary directory: $(ls -A "$TMPDIR")"
