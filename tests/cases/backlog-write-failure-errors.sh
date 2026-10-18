#!/usr/bin/env bash
# DERIVED from tasks.md 1.2 ("on a failed write finish with ERROR naming the
# backlog") and the existing three-outcomes requirement; no delta scenario
# states it. Change: seed-the-backlog.
#
# A regular file named `docs` makes `docs/backlog.md` absent (so the tool
# must try to create it) and impossible to create. The run ends ERROR, exit
# 1, with a Reason naming the backlog. SPECIFIED by the existing
# never-overwrite requirement: the project's own `docs` file is unchanged.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
printf 'not a directory\n' > docs
sum_before="$(md5sum docs | awk '{print $1}')"

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 1 "$status" "a failed backlog write ends in ERROR"
assert_contains "$report" "Outcome: ERROR" "ERROR outcome reported"
if ! grep -i -E '^Reason:.*backlog' "$report" >/dev/null; then
  echo "FAIL: the Reason line does not name the backlog" >&2
  cat "$report" >&2
  exit 1
fi
assert_unchanged "$work/docs" "$sum_before" "the project's own docs file is not overwritten"
