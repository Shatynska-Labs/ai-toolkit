#!/usr/bin/env bash
# Scenario: An edited block still succeeds, and is named.
# Requirement: Every run ends in one of three outcomes, and the exit code
# agrees. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: with one block edited and every other current, the outcome is
# SUCCESS, the exit code 0, and the line `Attention: ` names the edited
# block's record only.
# DERIVED (fixture): the edited record is backlog, one line inside its markers
# changed.
#
# Executes the tool. Red until tasks 1.2 and 1.6 land (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
work="$TESTDIR/work"
mkdir -p "$work"
seed_all "$work" current
edit_inside "$work/$(target_of backlog)" backlog "a line the project changed"
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
assert_outcome "$TESTDIR/report.txt" 0 "$?" SUCCESS
lines="$(grep -E '^Attention:' "$TESTDIR/report.txt")"
[ "$lines" = "Attention: backlog" ] || { echo "FAIL: expected one line 'Attention: backlog', got: $lines" >&2; cat "$TESTDIR/report.txt" >&2; exit 1; }
