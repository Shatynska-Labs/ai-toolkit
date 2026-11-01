#!/usr/bin/env bash
# Scenario: A remote branch with no reference
# Requirement: A task in flight shows its stage
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: a branch ls-remote lists, no local reference reaches, no change on the trunk and no open pull request, is unknown.
# DERIVED: no reference is arranged by a fetch refspec that takes only main.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"

source "${TESTLIB%/*}/task-board-lib.sh"

# ---- the case
project_new
entry an-entry
save
g config remote.origin.fetch '+refs/heads/main:refs/remotes/origin/main'
other_clone
in_other on_branch a-task
in_other change a-task
in_other leave_branch
in_other g push -q origin a-task
board_ok
has "$(row a-task flight)" 'unknown'
hasnt "$(row a-task flight)" 'plan:'
