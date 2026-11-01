#!/usr/bin/env bash
# Requirement: The tool changes nothing in the project
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: no branch is changed, locally or on the remote.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
save
branch a-branch
local_before="$(git -C "$P" for-each-ref refs/heads)"
remote_before="$(git -C "$ORIGIN" for-each-ref)"
board_ok
[ "$(git -C "$P" for-each-ref refs/heads)" = "$local_before" ] || die "a local branch changed"
[ "$(git -C "$ORIGIN" for-each-ref)" = "$remote_before" ] || die "the remote changed"
