#!/usr/bin/env bash
# Scenario: No trunk
# Requirement: The tool reports its outcome
# Change: report-the-board-as-json (task-board, MODIFIED).
#
# SPECIFIED: under --json the outcome and the reason saying what is missing are on standard error.
#
# Runs the tool; red until scripts/task-board accepts --json.
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"
source "${TESTLIB%/*}/task-board-lib.sh"

# ---- local arrangement (test-plan.md, Missing shared arrangement)
STDOUT="$TESTDIR/stdout"
STDERR="$TESTDIR/stderr"
# board_json [ARG...]: runs the tool from $P with its streams apart; $RC.
board_json() {
  [ -f "$BOARD" ] || die "target absent — $BOARD does not exist yet"
  RC=0
  ( cd "$P" && "$BOARD" "$@" ) > "$STDOUT" 2> "$STDERR" || RC=$?
}

# ---- the case
repo_only
echo x > "$P/file"
commit first 1
board_json --json
assert_exit 2 "$RC" "stderr: $(cat "$STDERR")"
[ ! -s "$STDOUT" ] || die "standard output is not empty: $(cat "$STDOUT")"
assert_contains "$STDERR" 'Outcome: BLOCKED'
hasre "$(cat "$STDERR")" 'Reason:.*trunk'
