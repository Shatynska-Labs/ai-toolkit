#!/usr/bin/env bash
# Scenario: A staged change to a legacy file blocks.
# Requirement: The shapes before 1.0.0 are converted only where git holds the
# original. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where the root AGENTS.md holds a v12 block and has a change
# staged in the index but not committed, the tool reports BLOCKED and writes
# nothing.
# DERIVED (scope): "writes nothing" read over the working tree and the index.
#
# Executes the tool. Red until task 1.5 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
work="$TESTDIR/work"
mkdir -p "$work"
f="$work/$(target_of development-workflow)"
printf '%s\n' "$V12_BLOCK" > "$f"
git_fixture "$work"
printf '\nA staged line.\n' >> "$f"
git -C "$work" add -A
before="$(tree_sum "$work")"
index_before="$(git -C "$work" diff --cached | md5sum)"
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
assert_outcome "$TESTDIR/report.txt" 2 "$?" BLOCKED
assert_tree "$work" "$before" "a staged legacy file"
[ "$(git -C "$work" diff --cached | md5sum)" = "$index_before" ] || { echo "FAIL: the index changed" >&2; exit 1; }
