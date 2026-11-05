#!/usr/bin/env bash
# Scenario: A named wait already done
# Requirement: The page carries what a task's entry states
# Change: report-a-tasks-kind-and-wait (task-board, MODIFIED).
#
# SPECIFIED: an entry whose waits_on names an archived change shows that name
# marked done; a name not done is not marked.
# DERIVED (operationalisation, design.md decision 9: "(done)" after the done
# ones): in the task's row read as one line, "done" follows the archived name
# with nothing but punctuation and space between, and does not follow the name
# of the open change.
#
# Runs the tool; red until the page's task row marks done names (task 3.3).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"
source "${TESTLIB%/*}/task-board-lib.sh"


# ---- the case
project_new
entry an-entry 'waits_on: [old-work, live-work]'
archived old-work
change live-work
save
board_ok
r="$(row an-entry | tr '\n' ' ')"
has "$r" 'old-work'
has "$r" 'live-work'
hasre "$r" 'old-work[^a-z0-9]*done'
hasntre "$r" 'live-work[^a-z0-9]*done'
