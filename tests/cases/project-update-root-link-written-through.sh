#!/usr/bin/env bash
# Scenario: A root AGENTS.md link is written through.
# Requirement: A stale block nobody edited is replaced, and nothing outside
# its markers changes. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where the root's AGENTS.md is a symbolic link to a file holding a
# stale workflow block, afterwards the link is still a link to the same file,
# and that file holds the current block.
# DERIVED (fixture): a relative link to shared/rules.md inside the project;
# "the current block" is read as the fragment's version in a hashed marker
# whose hash matches.
#
# Executes the tool. Red until task 1.3 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
work="$TESTDIR/work"
mkdir -p "$work/shared"
put_block "$work" development-workflow "$(lower_version "$(fversion development-workflow)")" "old"
root_t="$work/$(target_of development-workflow)"
mv "$root_t" "$work/shared/rules.md"
ln -s shared/rules.md "$root_t"
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
[ -L "$root_t" ] || { echo "FAIL: the root AGENTS.md is no longer a link" >&2; exit 1; }
[ "$(readlink "$root_t")" = shared/rules.md ] || { echo "FAIL: the link now points at $(readlink "$root_t")" >&2; exit 1; }
[ "$(marker_version "$work/shared/rules.md" development-workflow)" = "$(fversion development-workflow)" ] || { echo "FAIL: the file the link names does not hold the current block" >&2; cat "$TESTDIR/report.txt" >&2; exit 1; }
hash_ok "$work/shared/rules.md" development-workflow || { echo "FAIL: the written block's hash does not match" >&2; exit 1; }
