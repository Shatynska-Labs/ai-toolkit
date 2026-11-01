#!/usr/bin/env bash
# Requirement: A task shows what it consists of
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: the line states which exist, so a branch alone states no step, entry or change.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
save
branch a-task
board_ok
r="$(row a-task flight)"
printf '%s\n' "$r" | grep -qiw branch || die "no branch: $r"
if printf '%s\n' "$r" | grep -qiwE 'step|entry|change'; then die "claims what does not exist: $r"; fi
