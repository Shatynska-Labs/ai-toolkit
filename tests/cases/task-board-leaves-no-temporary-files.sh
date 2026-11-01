#!/usr/bin/env bash
# Requirement: The tool writes one self-contained page for one project
# Change: task-board (task-board, ADDED).
#
# DERIVED (design decisions 1 and 10): the snapshot is removed on exit, and the write beside the target leaves nothing but the page.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
save
mkdir -p "$TESTDIR/out"
OUT="$TESTDIR/out/page.html"
board_ok
[ -z "$(ls -A "$TMPDIR")" ] || die "left in the temporary directory: $(ls -A "$TMPDIR")"
[ "$(ls -A "$TESTDIR/out")" = page.html ] || die "left beside the page: $(ls -A "$TESTDIR/out")"
