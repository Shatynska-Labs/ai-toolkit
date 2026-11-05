#!/usr/bin/env bash
# Scenario: Kind and need are shown
# Requirement: The page carries what a task's entry states
# Change: report-a-tasks-kind-and-wait (task-board, MODIFIED).
#
# SPECIFIED: an entry carrying kind: fix and need: could shows fix and could.
# SPECIFIED (the requirement's body): kind is shown on every entry, so change
# shows too; need is shown only where it is not should.
# DERIVED (operationalisation): each value is matched as a whole word in the
# task's row, the names chosen to hold none of them.
#
# Runs the tool; red until the page's task row shows them (task 3.3).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"
source "${TESTLIB%/*}/task-board-lib.sh"

# entry_raw NAME [FRONTMATTER_LINE...]: an entry whose frontmatter is exactly
# the lines given, for a kind other than change; task-board-lib.sh's entry
# always writes `kind: change` first.
entry_raw() {
  local n="$1" l; shift
  { echo '---'; for l in "$@"; do printf '%s\n' "$l"; done; echo '---'; echo; echo 'The entry body.'; } \
    > "$P/docs/backlog/$n.md"
}

# ---- the case
project_new
entry_raw an-entry 'kind: fix' 'need: could'
entry a-second 'need: should'
save
board_ok
hasre "$(row an-entry)" '(^|[^a-z])fix([^a-z]|$)'
hasre "$(row an-entry)" '(^|[^a-z])could([^a-z]|$)'
hasre "$(row a-second)" '(^|[^a-z])change([^a-z]|$)'
hasntre "$(row a-second)" '(^|[^a-z])should([^a-z]|$)'
