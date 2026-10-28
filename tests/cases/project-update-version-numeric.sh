#!/usr/bin/env bash
# Scenario: Versions compare by number, not by text.
# Requirement: Each block the manifest lists is classified from the project
# alone. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where an untouched block carries 1.9.0 and the fragment 1.10.0,
# its line reports it replaced, from 1.9.0 to 1.10.0.
# DERIVED (fixture): a copy whose workflow fragment carries 1.10.0; the
# block's marker carries 1.10.0 afterwards (the replacement requirement).
#
# Executes the tool. Red until tasks 1.2 and 1.3 land (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
copy="$TESTDIR/copy"
toolkit_copy "$copy"
require_update "$copy/scripts/project-update"
set_version "$copy/rules/development-workflow.md" 1.10.0
work="$TESTDIR/work"
mkdir -p "$work"
put_block "$work" development-workflow 1.9.0 "the text at 1.9.0" "$copy"
(cd "$work" && bash "$copy/scripts/project-update") >"$TESTDIR/report.txt" 2>&1
expect_line "$TESTDIR/report.txt" development-workflow replaced 1.9.0 1.10.0
[ "$(marker_version "$work/$(target_of development-workflow "$copy")" development-workflow)" = 1.10.0 ] || { echo "FAIL: the block does not carry 1.10.0 after the run" >&2; exit 1; }
