#!/usr/bin/env bash
# Scenario: An edited block is left with its diff.
# Requirement: An edited block is reported with its difference and never
# overwritten. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where a block carries an older version and one line inside its
# markers was changed after it was written, the target is byte-for-byte
# unchanged, the record's line reports it edited with the version it carries
# and the version the toolkit carries, and the report holds a diff in which
# the changed line appears; each line of the diff is indented.
# DERIVED (token): the changed line is read as an indented report line that,
# after its indentation, begins `-` or `+` and holds the changed text.
#
# Executes the tool. Red until task 1.4 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
work="$TESTDIR/work"
mkdir -p "$work"
old="$(lower_version "$(fversion backlog)")"
put_block "$work" backlog "$old" "the text as written"
f="$work/$(target_of backlog)"
edit_inside "$f" backlog "a line the project changed by hand"
sum="$(md5sum "$f" | awk '{print $1}')"
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
assert_unchanged "$f" "$sum" "an edited block"
expect_line "$TESTDIR/report.txt" backlog edited "$old" "$(fversion backlog)"
grep -q -E '^[[:space:]]+[-+].*a line the project changed by hand' "$TESTDIR/report.txt" || { echo "FAIL: the report holds no indented diff line with the changed text" >&2; cat "$TESTDIR/report.txt" >&2; exit 1; }
