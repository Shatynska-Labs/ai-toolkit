#!/usr/bin/env bash
# Scenario: A failed run
# Requirement: The tool reports the board as JSON
# Requirement: The tool reports its outcome
# Change: report-the-board-as-json (task-board, ADDED).
#
# SPECIFIED: a run failing after reading has begun leaves standard output empty, exits 1, and standard error carries the outcome.
# DERIVED: the failure is an awk that does its work and then fails, so output it printed before failing would be caught. Without --json this same stub ends a run as ERROR with the target already reported, so it strikes after reading has begun.
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
workstream ws-a a-step
entry an-entry
save
real_awk="$(command -v awk)"
mkdir -p "$TESTDIR/failing"
printf '#!/usr/bin/env bash\n"%s" "$@"\nexit 1\n' "$real_awk" > "$TESTDIR/failing/awk"
chmod +x "$TESTDIR/failing/awk"
export PATH="$TESTDIR/failing:$PATH"
board_json --json
assert_exit 1 "$RC" "stderr: $(cat "$STDERR")"
[ ! -s "$STDOUT" ] || die "standard output is not empty: $(cat "$STDOUT")"
assert_contains "$STDERR" 'Outcome: ERROR'
