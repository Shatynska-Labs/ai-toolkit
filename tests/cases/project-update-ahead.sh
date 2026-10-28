#!/usr/bin/env bash
# Scenario: A block ahead of the toolkit.
# Requirement: Each block the manifest lists is classified from the project
# alone. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where an untouched block carries 2.0.0 and the fragment 1.0.0,
# its line reports it ahead of this toolkit, with both versions, and the
# target is byte-for-byte unchanged.
# DERIVED (token): "ahead" is read as the word `ahead` on the line.
#
# Executes the tool. Red until task 1.2 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
copy="$TESTDIR/copy"
toolkit_copy "$copy"
require_update "$copy/scripts/project-update"
set_version "$copy/rules/development-workflow.md" 1.0.0
work="$TESTDIR/work"
mkdir -p "$work"
put_block "$work" development-workflow 2.0.0 "the text at 2.0.0" "$copy"
f="$work/$(target_of development-workflow "$copy")"
sum="$(md5sum "$f" | awk '{print $1}')"
(cd "$work" && bash "$copy/scripts/project-update") >"$TESTDIR/report.txt" 2>&1
expect_line "$TESTDIR/report.txt" development-workflow ahead 2.0.0 1.0.0
assert_unchanged "$f" "$sum" "a block ahead of the toolkit"
