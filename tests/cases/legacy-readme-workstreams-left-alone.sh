#!/usr/bin/env bash
# Scenario: A workstreams README is left alone.
# Requirement: A directory holding its rules in a README is reported, not
# converted. Change: list-what-a-project-receives (project-bootstrap, ADDED).
#
# SPECIFIED: where docs/workstreams/ holds README.md, no AGENTS.md or
# CLAUDE.md is created in it, the README is unchanged, and the report states
# the workstreams' rules are in the shape before 1.0.0.
# DERIVED (token): read as the `workstreams:` line naming `1.0.0`.
#
# Executes the tool. Red until task 2.3 lands (state 1).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work/docs/workstreams"
printf '# Workstreams\n\nOur rules.\n' > "$work/docs/workstreams/README.md"
sum="$(md5sum "$work/docs/workstreams/README.md" | awk '{print $1}')"
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
assert_file_absent "$work/docs/workstreams/AGENTS.md" "no AGENTS.md beside the README"
assert_file_absent "$work/docs/workstreams/CLAUDE.md" "no CLAUDE.md beside the README"
assert_unchanged "$work/docs/workstreams/README.md" "$sum" "the README is left"
grep -E '^workstreams:' "$TESTDIR/report.txt" | grep -q -F '1.0.0' || { echo "FAIL: the workstreams line does not state the rules are in the shape before 1.0.0" >&2; cat "$TESTDIR/report.txt" >&2; exit 1; }
