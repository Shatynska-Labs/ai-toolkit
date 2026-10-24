#!/usr/bin/env bash
# Scenario: A project without a workstream register receives the seeded file
# (new-project mode). Requirement: A workstream register is seeded where none
# exists. Change: add-workstreams (project-bootstrap, ADDED).
#
# SPECIFIED: in a target with no `docs/workstreams/README.md` the file is
# created, `docs/workstreams/` with it; no `archive/` directory is created;
# the report states the register was created; the file contains no
# workstream.
# DERIVED (token): `workstreams: created` is design.md decision 12's report
# line; the requirement says only that the report states it was created.
# DERIVED (operationalisation of "no workstream"): outside fenced code, the
# file carries exactly one heading (its title), and `docs/workstreams/` holds
# README.md alone. The shape's example heading sits inside a fence (decision
# 8), so it is skipped.
#
# The statements the file must carry are asserted by
# workstreams-seeded-statements.sh and the scenario-specific
# workstreams-seeded-*.sh cases.
#
# Executes the tool; no fixture owed. Red until the concern lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status"
readme="$work/docs/workstreams/README.md"
assert_file "$readme" "the register is created, with docs/workstreams/ created for it"
assert_contains "$report" "workstreams: created" "the report states the register was created"
assert_file_absent "$work/docs/workstreams/archive" "no archive/ directory is created"

others="$(find "$work/docs/workstreams" -mindepth 1 ! -name README.md)"
if [ -n "$others" ]; then
  echo "FAIL: docs/workstreams/ holds more than its README" >&2
  echo "$others" >&2
  exit 1
fi

fences="$(grep -c -E '^[[:space:]]*(```|~~~)' "$readme")"
if [ $((fences % 2)) -ne 0 ]; then
  echo "FAIL: $readme has unbalanced code fences ($fences); the no-workstream scan cannot be read" >&2
  exit 1
fi
headings="$(awk '/^[[:space:]]*(```|~~~)/ { infence = !infence; next } !infence && /^#/ { print NR": "$0 }' "$readme")"
count="$(printf '%s\n' "$headings" | grep -c .)"
if [ "$count" -ne 1 ]; then
  echo "FAIL: outside fenced code the seeded register carries $count headings, not its title alone; it SHALL contain no workstream" >&2
  printf '%s\n' "$headings" >&2
  exit 1
fi
