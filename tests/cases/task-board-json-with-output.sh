#!/usr/bin/env bash
# Scenario: With an output
# Requirement: The tool reports the board as JSON
# Change: report-the-board-as-json (task-board, ADDED).
#
# SPECIFIED: --json with --output, in either order, is BLOCKED on standard error, exit 2, nothing written to the path.
# DERIVED (design decision 5): --output --json is read as the refusal, not as a file named --json.
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
# refused [ARG...]: the run is refused and leaves standard output empty.
refused() {
  board_json "$@"
  assert_exit 2 "$RC" "stderr: $(cat "$STDERR")"
  assert_contains "$STDERR" 'Outcome: BLOCKED'
  [ ! -s "$STDOUT" ] || die "standard output is not empty: $(cat "$STDOUT")"
  assert_file_absent "$OUT"
}
project_new
entry an-entry
save
refused --json --output "$OUT"
refused --output "$OUT" --json
refused --output --json
assert_file_absent "$P/--json"
