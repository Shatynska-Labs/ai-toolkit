#!/usr/bin/env bash
# Scenario: Two blocks of one name are malformed.
# Requirement: Each block the manifest lists is classified from the project
# alone. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where a target holds two opening markers of the record's name,
# its line reports the markers malformed, and the target is byte-for-byte
# unchanged.
# DERIVED (fixture): two whole stale workflow blocks, one after the other, so
# each alone would be replaceable.
#
# Executes the tool. Red until task 1.2 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
work="$TESTDIR/work"
mkdir -p "$work"
v="$(lower_version "$(fversion development-workflow)")"
put_block "$work" development-workflow "$v" "first"
put_block "$work" development-workflow "$v" "second"
f="$work/$(target_of development-workflow)"
sum="$(md5sum "$f" | awk '{print $1}')"
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
expect_line "$TESTDIR/report.txt" development-workflow malformed
assert_unchanged "$f" "$sum" "two blocks of one name"
