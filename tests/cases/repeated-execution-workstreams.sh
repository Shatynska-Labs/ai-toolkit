#!/usr/bin/env bash
# Scenario: Repeated execution is not destructive — as revised by
# add-workstreams, whose concern list gains "workstream register present".
# Requirement: Each concern is checked independently and is safe to repeat
# (project-bootstrap, MODIFIED).
#
# repeated-execution-idempotent.sh and repeated-execution-backlog.sh cover the
# other concerns and are left as they are. SPECIFIED: the second run
# completes, reports the register as already satisfied, and the README the
# first run wrote is not modified, truncated or duplicated.
# DERIVED (token): `workstreams: already present` (design.md decision 12).
#
# Executes the tool; no fixture owed. Red until the concern lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1

bash "$PROJECT_INIT" >/dev/null 2>&1
assert_exit 0 "$?" "first run should succeed"
assert_file "$work/docs/workstreams/README.md" "the first run created the register"
sum_1="$(md5sum docs/workstreams/README.md | awk '{print $1}')"

report2="$TESTDIR/report2.txt"
bash "$PROJECT_INIT" >"$report2" 2>&1
assert_exit 0 "$?" "second run should also succeed"
assert_unchanged "$work/docs/workstreams/README.md" "$sum_1" "register not modified, truncated or duplicated"
assert_contains "$report2" "workstreams: already present" "register reported as already satisfied"
assert_file_absent "$work/docs/workstreams/archive" "the second run creates no archive/ either"
