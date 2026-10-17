#!/usr/bin/env bash
# DERIVED, not traced to a delta-spec scenario. Change: seed-the-backlog.
#
# design.md fixes the report line as `backlog: created | already present`,
# "printed after the ignore file line", and tests/README.md's report contract
# lists lines in order. No delta scenario states the position; this case
# holds the design decision so the report stays greppable in a known order.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?
assert_exit 0 "$status"

ignore_line="$(grep -n -m1 '^ignore file:' "$report" | cut -d: -f1)"
backlog_line="$(grep -n -m1 '^backlog:' "$report" | cut -d: -f1)"
if [ -z "$ignore_line" ] || [ -z "$backlog_line" ]; then
  echo "FAIL: the report lacks an ignore file line or a backlog line" >&2
  cat "$report" >&2
  exit 1
fi
if [ "$backlog_line" -ne $((ignore_line + 1)) ]; then
  echo "FAIL: the backlog line (line $backlog_line) does not directly follow the ignore file line (line $ignore_line)" >&2
  cat "$report" >&2
  exit 1
fi
