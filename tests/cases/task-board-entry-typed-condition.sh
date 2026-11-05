#!/usr/bin/env bash
# Scenario: A typed condition is shown
# Requirement: The page carries what a task's entry states
# Change: report-a-tasks-kind-and-wait (task-board, MODIFIED).
#
# SPECIFIED: an entry carrying waits_for: "the operator's choice of model" and
# waits_for_type: [decision] shows the condition with decision before it.
# DERIVED (operationalisation): in the task's row read as one line, "decision"
# comes before "choice of model"; the apostrophe is left out of the match, the
# page escaping it as an entity the reader does not decode.
#
# Runs the tool; red until the page's task row shows the condition (task 3.3).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"
source "${TESTLIB%/*}/task-board-lib.sh"


# ---- the case
project_new
entry an-entry 'waits_for: "the operator'"'"'s choice of model"' 'waits_for_type: [decision]'
save
board_ok
r="$(row an-entry | tr '\n' ' ')"
has "$r" 'choice of model'
hasre "$r" '(^|[^a-z])decision([^a-z].*)?choice of model'
