#!/usr/bin/env bash
# Scenario: An existing workstream register is preserved exactly.
# Requirement: A workstream register is seeded where none exists.
# Change: add-workstreams (project-bootstrap, ADDED).
#
# SPECIFIED: an existing `docs/workstreams/README.md` is left byte-for-byte
# unchanged and the report states the register is already present. The
# fixture is deliberately in a shape the seeded text does not have (a status
# table), so a tool that "normalised" an existing file would have something to
# change.
# DERIVED (token): `workstreams: already present` is design.md decision 12's
# report line.
#
# Executes the tool; no fixture owed. Red until the concern lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work/docs/workstreams"
cd "$work" || exit 1
cat > docs/workstreams/README.md <<'README'
# Our workstreams

| Workstream | Status |
|---|---|
| keywords-seo | in flight |
README
sum_before="$(md5sum docs/workstreams/README.md | awk '{print $1}')"

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status"
assert_unchanged "$work/docs/workstreams/README.md" "$sum_before" "byte-for-byte unchanged"
assert_contains "$report" "workstreams: already present" "presence reported"
