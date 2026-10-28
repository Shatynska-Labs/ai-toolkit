#!/usr/bin/env bash
# Scenario: An edit at the current version is reported as an edit.
# Requirement: Each block the manifest lists is classified from the project
# alone. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where a block at the fragment's version has one line inside its
# markers changed, its line reports it edited, not current.
# DERIVED (fixture): the workflow block; the other blocks current.
#
# Executes the tool. Red until task 1.2 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
work="$TESTDIR/work"
mkdir -p "$work"
seed_all "$work" current
edit_inside "$work/$(target_of development-workflow)" development-workflow "a line the project changed"
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
expect_line "$TESTDIR/report.txt" development-workflow edited
refuse_line "$TESTDIR/report.txt" development-workflow current
