#!/usr/bin/env bash
# Scenario: A repository with no commit blocks a conversion.
# Requirement: The shapes before 1.0.0 are converted only where git holds the
# original. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where the target holds a v12 block and is the top level of a git
# working tree with no commit, the tool reports BLOCKED and writes nothing.
# DERIVED (fixture): the file is added to the index, so only the missing
# commit fails the precondition.
#
# Executes the tool. Red until task 1.5 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
work="$TESTDIR/work"
mkdir -p "$work"
printf '%s\n' "$V12_BLOCK" > "$work/$(target_of development-workflow)"
git -C "$work" init -q >/dev/null 2>&1 || { echo "FAIL: fixture — git init" >&2; exit 1; }
git -C "$work" add -A
before="$(tree_sum "$work")"
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
assert_outcome "$TESTDIR/report.txt" 2 "$?" BLOCKED
assert_tree "$work" "$before" "a repository with no commit"
