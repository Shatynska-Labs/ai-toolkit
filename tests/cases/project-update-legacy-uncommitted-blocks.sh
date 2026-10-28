#!/usr/bin/env bash
# Scenario: An uncommitted legacy file blocks the whole run.
# Requirement: The shapes before 1.0.0 are converted only where git holds the
# original. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where the root AGENTS.md holds a v12 block and
# docs/workstreams/README.md has an uncommitted change, the tool reports
# BLOCKED, names docs/workstreams/README.md, and every file in the project is
# unchanged, the root block included.
# DERIVED (scope): exit 2, BLOCKED's code.
#
# Executes the tool. Red until task 1.5 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
work="$TESTDIR/work"
mkdir -p "$work/docs/workstreams"
printf '%s\n' "$V12_BLOCK" > "$work/$(target_of development-workflow)"
printf '# Workstreams\n\nOur rules.\n' > "$work/docs/workstreams/README.md"
git_fixture "$work"
printf 'A change not yet committed.\n' >> "$work/docs/workstreams/README.md"
before="$(tree_sum "$work")"
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
assert_outcome "$TESTDIR/report.txt" 2 "$?" BLOCKED
assert_contains "$TESTDIR/report.txt" "docs/workstreams/README.md" "the report names the file"
assert_tree "$work" "$before" "an uncommitted legacy README"
