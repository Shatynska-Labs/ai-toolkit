#!/usr/bin/env bash
# Scenario: A single-file backlog is named.
# Requirement: A block the project lacks is named, not written.
# Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where the project holds docs/backlog.md and no docs/backlog/,
# docs/backlog.md is unchanged, nothing is created under docs/backlog/, and
# the backlog line names scripts/backlog-migrate.
# DERIVED (token): the line states `backlog-migrate`; "nothing under
# docs/backlog/" read as docs/backlog absent.
#
# Executes the tool. Red until task 1.6 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
work="$TESTDIR/work"
mkdir -p "$work/docs"
put_block "$work" development-workflow "$(fversion development-workflow)" "current"
# shellcheck disable=SC2016 # backticks are literal markdown
printf '# Backlog\n\n## `alpha`\n\nAn entry.\n' > "$work/docs/backlog.md"
sum="$(md5sum "$work/docs/backlog.md" | awk '{print $1}')"
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
assert_unchanged "$work/docs/backlog.md" "$sum" "docs/backlog.md"
assert_file_absent "$work/docs/backlog" "docs/backlog/ is not created"
expect_line "$TESTDIR/report.txt" backlog backlog-migrate
