#!/usr/bin/env bash
# Scenario: Other blocks proceed past an edited one.
# Requirement: An edited block is reported with its difference and never
# overwritten. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where the workflow block is edited and the backlog block is stale
# and untouched, the backlog block is replaced and the workflow block is
# unchanged.
# DERIVED (fixture): the workflow block at the current version with one line
# changed; "unchanged" read over its whole target file.
#
# Executes the tool. Red until tasks 1.3 and 1.4 land (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
work="$TESTDIR/work"
mkdir -p "$work"
put_block "$work" development-workflow "$(fversion development-workflow)" "as written"
wf="$work/$(target_of development-workflow)"
edit_inside "$wf" development-workflow "a line the project changed"
put_block "$work" backlog "$(lower_version "$(fversion backlog)")" "old"
sum="$(md5sum "$wf" | awk '{print $1}')"
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
assert_unchanged "$wf" "$sum" "the edited workflow block"
[ "$(marker_version "$work/$(target_of backlog)" backlog)" = "$(fversion backlog)" ] || { echo "FAIL: the stale backlog block was not replaced" >&2; cat "$TESTDIR/report.txt" >&2; exit 1; }
