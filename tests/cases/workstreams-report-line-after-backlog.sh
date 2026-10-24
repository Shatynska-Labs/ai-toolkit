#!/usr/bin/env bash
# DERIVED, not traced to a delta-spec scenario. Change: add-workstreams.
#
# design.md decision 12 fixes the report line as `workstreams: created |
# already present` but not its position. The revised concern list in
# *Each concern is checked independently and is safe to repeat* orders the
# concerns "... backlog present, workstream register present, conventions
# file present ...", and tests/README.md's report contract prints one line
# per concern in concern order. This case holds that order: the workstreams
# line directly follows the backlog line. Recorded in test-plan.md as
# unresolved question Q1, since tests/README.md does not yet list the line.
#
# Executes the tool; no fixture owed. Red until the concern lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
assert_exit 0 "$?"

backlog_line="$(grep -n -m1 '^backlog:' "$report" | cut -d: -f1)"
ws_line="$(grep -n -m1 '^workstreams:' "$report" | cut -d: -f1)"
if [ -z "$backlog_line" ] || [ -z "$ws_line" ]; then
  echo "FAIL: the report lacks a backlog line or a workstreams line" >&2
  cat "$report" >&2
  exit 1
fi
if [ "$ws_line" -ne $((backlog_line + 1)) ]; then
  echo "FAIL: the workstreams line (line $ws_line) does not directly follow the backlog line (line $backlog_line)" >&2
  cat "$report" >&2
  exit 1
fi
