#!/usr/bin/env bash
# Requirement: The tool changes nothing in the project
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the tool fetches without pruning.
# DERIVED (design decision 1): that holds under fetch.prune=true.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
save
branch gone-branch
g push -q origin gone-branch
g fetch -q origin
g branch -q -D gone-branch
other_clone
in_other g push -q origin --delete gone-branch
g config fetch.prune true
board_ok
git -C "$P" rev-parse -q --verify refs/remotes/origin/gone-branch >/dev/null || die "the remote-tracking reference was pruned"
