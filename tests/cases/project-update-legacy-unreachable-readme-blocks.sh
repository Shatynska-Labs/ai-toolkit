#!/usr/bin/env bash
# Scenario: A README the run cannot reach blocks a conversion.
# Requirement: The shapes before 1.0.0 are converted only where git holds the
# original. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where the root AGENTS.md holds a v12 block, and docs/workstreams/
# is a symbolic link to a directory holding README.md, the tool reports
# BLOCKED and writes nothing, the root block included.
# DERIVED (fixture): everything committed, the link included; the directory
# the link names lies outside the project and is checked unchanged too.
#
# Executes the tool. Red until task 1.5 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
work="$TESTDIR/work"
ext="$TESTDIR/external-workstreams"
mkdir -p "$work/docs" "$ext"
printf '%s\n' "$V12_BLOCK" > "$work/$(target_of development-workflow)"
printf '# Workstreams\n\nOur rules.\n' > "$ext/README.md"
ln -s "$ext" "$work/docs/workstreams"
git_fixture "$work"
before="$(tree_sum "$work")"
ext_before="$(tree_sum "$ext")"
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
assert_outcome "$TESTDIR/report.txt" 2 "$?" BLOCKED
assert_tree "$work" "$before" "an unreachable README"
assert_tree "$ext" "$ext_before" "the directory the link names"
