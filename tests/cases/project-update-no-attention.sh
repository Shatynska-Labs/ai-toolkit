#!/usr/bin/env bash
# Scenario: Nothing to attend to.
# Requirement: Every run ends in one of three outcomes, and the exit code
# agrees. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where every block the manifest lists is current, the report holds
# no `Attention:` line and the outcome is SUCCESS.
# DERIVED (scope): the exit code 0, from the requirement's SUCCESS code.
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
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
assert_outcome "$TESTDIR/report.txt" 0 "$?" SUCCESS
if grep -q -E '^Attention:' "$TESTDIR/report.txt"; then
  echo "FAIL: the report holds an Attention: line with nothing to attend to" >&2; cat "$TESTDIR/report.txt" >&2; exit 1
fi
