#!/usr/bin/env bash
# Scenario: A root link resolving to a modified file blocks.
# Requirement: The shapes before 1.0.0 are converted only where git holds the
# original. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where the root AGENTS.md is a symbolic link to a tracked file
# inside the working tree that holds a v12 block and has an uncommitted
# change, the tool reports BLOCKED, names the file it resolves to, and writes
# nothing.
# DERIVED (fixture): the link is tracked and unchanged, so checking the link
# alone would pass — the case the requirement exists for.
#
# Executes the tool. Red until task 1.5 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
work="$TESTDIR/work"
mkdir -p "$work/shared"
printf '%s\n' "$V12_BLOCK" > "$work/shared/rules.md"
ln -s shared/rules.md "$work/$(target_of development-workflow)"
git_fixture "$work"
printf '\nA change not yet committed.\n' >> "$work/shared/rules.md"
before="$(tree_sum "$work")"
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
assert_outcome "$TESTDIR/report.txt" 2 "$?" BLOCKED
assert_contains "$TESTDIR/report.txt" "shared/rules.md" "the report names the file the link resolves to"
assert_tree "$work" "$before" "a link to a modified file"
