#!/usr/bin/env bash
# Scenario: An opening marker without a closing one is malformed.
# Requirement: Each block the manifest lists is classified from the project
# alone. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where a target holds a record's opening marker and no closing
# marker of that name after it, its line reports the markers malformed, and
# the target is byte-for-byte unchanged.
# DERIVED (fixture): a stale workflow block whose closing marker is removed,
# with project text after it that a replacement would consume.
#
# Executes the tool. Red until task 1.2 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
work="$TESTDIR/work"
mkdir -p "$work"
put_block "$work" development-workflow "$(lower_version "$(fversion development-workflow)")" "old"
f="$work/$(target_of development-workflow)"
grep -v -F '<!-- /ai-toolkit:development-workflow -->' "$f" > "$f.new" && mv "$f.new" "$f"
printf '\n## Our own conventions\n' >> "$f"
sum="$(md5sum "$f" | awk '{print $1}')"
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
expect_line "$TESTDIR/report.txt" development-workflow malformed
assert_unchanged "$f" "$sum" "no closing marker"
