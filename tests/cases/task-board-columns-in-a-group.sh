#!/usr/bin/env bash
# Requirement: Tasks are listed in columns
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a group's list has a heading for status, task and last commit, and one for the control opening the body.
# DERIVED: the fourth heading reads details, body or entry; a heading is a text of its own.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
workstream ws-a a-task
entry a-task
save
board_ok
h="$(group ws-a | tr 'A-Z' 'a-z' | grep -Ex 'status|task|last commit|details|body|entry' | head -n4 | tr '\n' ',')"
case "$h" in
  status,task,'last commit',*,) ;;
  *) die "headings of the group: [$h]" ;;
esac
[ "$(printf '%s' "$h" | tr -cd ',' | wc -c | tr -d ' ')" = 4 ] || die "four headings expected: [$h]"
