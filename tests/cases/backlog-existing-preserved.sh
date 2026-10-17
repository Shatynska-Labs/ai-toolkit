#!/usr/bin/env bash
# Scenario: An existing backlog is preserved exactly. Change: seed-the-backlog.
#
# SPECIFIED: byte-for-byte unchanged, report states it is already present.
# The fixture is deliberately in the shape the seeded text forbids — numbered
# headings, a number paragraph — so a tool that "normalised" an existing file
# would have something to change.
# DERIVED (token): `backlog: already present` is design.md's report line.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work/docs"
cd "$work" || exit 1
cat > docs/backlog.md <<'BACKLOG'
# Backlog

Entry numbers are not stable identifiers.

## 1. some-earlier-change

Recorded by hand before the tool seeded anything.
BACKLOG
sum_before="$(md5sum docs/backlog.md | awk '{print $1}')"

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status"
assert_unchanged "$work/docs/backlog.md" "$sum_before" "byte-for-byte unchanged"
assert_contains "$report" "backlog: already present" "presence reported"
