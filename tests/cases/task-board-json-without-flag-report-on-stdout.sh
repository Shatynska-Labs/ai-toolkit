#!/usr/bin/env bash
# Requirement: The tool writes one self-contained page for one project
# Requirement: The tool reports its outcome
# Change: report-the-board-as-json (task-board, MODIFIED).
#
# SPECIFIED (proposal, tests/README.md): without --json nothing changes, the report and the page's path staying on standard output.
#
# Runs existing behaviour (second situation): this case passes today and holds the line. board_in merges the streams, so no existing case does.
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
board_json --output "$OUT"
assert_exit 0 "$RC"
assert_file "$OUT"
assert_contains "$STDOUT" "Board: $OUT"
assert_contains "$STDOUT" 'Outcome: SUCCESS'
if grep -q 'Outcome:' "$STDERR"; then die "the outcome went to standard error"; fi
