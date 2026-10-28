#!/usr/bin/env bash
# Scenario: A missing workstreams directory is named.
# Requirement: A block the project lacks is named, not written.
# Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where the project holds the workflow and backlog blocks and no
# docs/workstreams/, docs/workstreams/ is still absent after the run, and the
# workstreams line names scripts/project-init.
# DERIVED (token): the line states `project-init`.
#
# Executes the tool. Red until task 1.6 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
work="$TESTDIR/work"
mkdir -p "$work"
put_block "$work" development-workflow "$(fversion development-workflow)" "current"
put_block "$work" backlog "$(fversion backlog)" "current"
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
assert_file_absent "$work/docs/workstreams" "docs/workstreams/ is not created"
expect_line "$TESTDIR/report.txt" workstreams project-init
