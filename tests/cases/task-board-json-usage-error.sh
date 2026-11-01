#!/usr/bin/env bash
# Scenario: A usage error with --json
# Requirement: The tool reports the board as JSON
# Change: report-the-board-as-json (task-board, ADDED).
#
# SPECIFIED: with an unknown flag and --json, in either order, standard output is empty and the outcome is on standard error.
# DERIVED: the exit status is not zero; the scenario names no status, so none is fixed.
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
project_new
entry an-entry
save
for args in '--json --no-such-flag' '--no-such-flag --json'; do
  # shellcheck disable=SC2086 # split into its two flags on purpose
  board_json $args
  [ "$RC" -ne 0 ] || die "$args: exited 0"
  [ ! -s "$STDOUT" ] || die "$args: standard output is not empty: $(cat "$STDOUT")"
  assert_contains "$STDERR" 'Outcome:' "$args"
done
