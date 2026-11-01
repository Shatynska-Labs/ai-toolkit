#!/usr/bin/env bash
# Scenario: Run in a working tree with uncommitted edits
# Requirement: The tool changes nothing in the project
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: uncommitted edits and the current branch are as they were.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
save
on_branch current-work
echo 'edited' >> "$P/docs/backlog/an-entry.md"
echo 'new' > "$P/untracked.txt"
sum="$(md5sum "$P/docs/backlog/an-entry.md" | awk '{print $1}')"
before="$(git -C "$P" status --porcelain)"
board_ok
assert_unchanged "$P/docs/backlog/an-entry.md" "$sum"
[ "$(git -C "$P" status --porcelain)" = "$before" ] || die "git status changed"
[ "$(git -C "$P" rev-parse --abbrev-ref HEAD)" = current-work ] || die "the current branch moved"
