#!/usr/bin/env bash
# Scenario: Legacy items outside a repository block.
# Requirement: The shapes before 1.0.0 are converted only where git holds the
# original. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where the target holds a v12 block and is not the top level of a
# git working tree, the tool reports BLOCKED and writes nothing.
# DERIVED (fixtures): both readings of "not the top level" — a directory in
# no repository, and a committed subdirectory of one.
#
# Executes the tool. Red until task 1.5 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
plain="$TESTDIR/plain"
mkdir -p "$plain"
printf '%s\n' "$V12_BLOCK" > "$plain/$(target_of development-workflow)"
if git -C "$plain" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "FAIL: fixture — $TESTDIR lies inside a git working tree" >&2; exit 1
fi
before="$(tree_sum "$plain")"
(cd "$plain" && bash "$PROJECT_UPDATE") >"$TESTDIR/r1.txt" 2>&1
assert_outcome "$TESTDIR/r1.txt" 2 "$?" BLOCKED
assert_tree "$plain" "$before" "no repository"

repo="$TESTDIR/repo"
mkdir -p "$repo/sub"
printf '%s\n' "$V12_BLOCK" > "$repo/sub/$(target_of development-workflow)"
git_fixture "$repo"
before="$(tree_sum "$repo")"
(cd "$repo/sub" && bash "$PROJECT_UPDATE") >"$TESTDIR/r2.txt" 2>&1
assert_outcome "$TESTDIR/r2.txt" 2 "$?" BLOCKED
assert_tree "$repo" "$before" "a subdirectory of a repository"
