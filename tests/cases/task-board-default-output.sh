#!/usr/bin/env bash
# Scenario: Default output
# Requirement: The tool writes one self-contained page for one project
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: with no --output the page is written outside the project and its path printed, and git status in the project is unchanged.
# DERIVED (design decision 10): the path is $TMPDIR/task-board-<project>.html.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
save
before="$(git -C "$P" status --porcelain)"
board_in "$P"
assert_exit 0 "$RC" "report: $(report)"
page="$TMPDIR/task-board-project.html"
assert_file "$page"
has "$(report)" "$page"
[ "$(git -C "$P" status --porcelain)" = "$before" ] || die "git status changed"
