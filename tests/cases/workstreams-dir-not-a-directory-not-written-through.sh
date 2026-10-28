#!/usr/bin/env bash
# Requirement: A project receives exactly the blocks the manifest lists —
# a target whose directory exists as something other than a directory.
# Change: list-what-a-project-receives (revises add-workstreams' error case).
#
# A regular file named `docs/workstreams` is not a directory the tool writes
# into: nothing is written for the workstreams record, the report says so,
# the other records proceed, and the run succeeds. SPECIFIED by the
# never-overwrite requirement: the project's own file is unchanged.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work/docs"
cd "$work" || exit 1
printf 'not a directory\n' > docs/workstreams
sum_before="$(md5sum docs/workstreams | awk '{print $1}')"

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status" "a refused record does not end the run"
assert_contains "$report" "workstreams: docs/workstreams is not a directory the tool writes into" "the refused record is reported"
assert_file "$work/docs/backlog/AGENTS.md" "the other records proceed"
assert_unchanged "$work/docs/workstreams" "$sum_before" "the project's own docs/workstreams file is not overwritten"
