#!/usr/bin/env bash
# DERIVED from tasks.md 1.2 ("with the backlog's presence rule ... and its
# error path on a failed write") and the existing three-outcomes requirement;
# no delta scenario states it. Change: add-workstreams.
#
# A regular file named `docs/workstreams` makes `docs/workstreams/README.md`
# absent (so the tool must try to create it) and impossible to create. The
# run ends ERROR, exit 1, with a Reason naming the workstream register, as
# backlog-write-failure-errors.sh holds for the backlog. SPECIFIED by the
# existing never-overwrite requirement: the project's own file is unchanged.
#
# Executes the tool; no fixture owed. Red until the concern lands.
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

assert_exit 1 "$status" "a failed register write ends in ERROR"
assert_contains "$report" "Outcome: ERROR" "ERROR outcome reported"
if ! grep -i -E '^Reason:.*workstream' "$report" >/dev/null; then
  echo "FAIL: the Reason line does not name the workstream register" >&2
  cat "$report" >&2
  exit 1
fi
assert_unchanged "$work/docs/workstreams" "$sum_before" "the project's own docs/workstreams file is not overwritten"
