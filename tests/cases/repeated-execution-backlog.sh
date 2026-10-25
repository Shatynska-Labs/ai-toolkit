#!/usr/bin/env bash
# Scenario: Repeated execution is not destructive — as revised by
# seed-the-backlog, whose concern list gains "backlog present".
#
# repeated-execution-idempotent.sh covers the other concerns and is left as
# it is; this case adds the backlog. SPECIFIED: the second run completes,
# reports the backlog as already satisfied, and the backlog written by the
# first run is not modified, truncated or duplicated.
# DERIVED (token): `backlog: already present` is design.md's report line.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1

bash "$PROJECT_INIT" >/dev/null 2>&1
first_status=$?
assert_exit 0 "$first_status" "first run should succeed"
assert_file "$work/docs/backlog/README.md" "the first run created the backlog"
sum_backlog_1="$(md5sum docs/backlog/README.md | awk '{print $1}')"

report2="$TESTDIR/report2.txt"
bash "$PROJECT_INIT" >"$report2" 2>&1
second_status=$?

assert_exit 0 "$second_status" "second run should also succeed"
assert_unchanged "$work/docs/backlog/README.md" "$sum_backlog_1" "backlog not modified, truncated or duplicated"
assert_contains "$report2" "backlog: already present" "backlog reported as already satisfied"
