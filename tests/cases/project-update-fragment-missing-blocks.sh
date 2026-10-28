#!/usr/bin/env bash
# Scenario: A missing fragment blocks.
# Requirement: Every run ends in one of three outcomes, and the exit code
# agrees. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: run from a copy whose manifest lists a fragment the copy does
# not hold, the tool reports BLOCKED, exits 2, and the project is unchanged.
# DERIVED (fixture): the fragment removed is the last record's; the project
# holds a stale block for every record, so a run that ignored the missing
# fragment would have something to write.
#
# Executes the tool. Red until task 1.1 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
copy="$TESTDIR/copy"
toolkit_copy "$copy"
require_update "$copy/scripts/project-update"
work="$TESTDIR/work"
mkdir -p "$work"
seed_all "$work" stale "$copy"
last="$(records "$copy" | awk 'NF { n = $1 } END { print n }')"
rm -f "$copy/rules/$last.md"
assert_file_absent "$copy/rules/$last.md" "fixture — the fragment is removed"
before="$(tree_sum "$work")"
(cd "$work" && bash "$copy/scripts/project-update") >"$TESTDIR/report.txt" 2>&1
assert_outcome "$TESTDIR/report.txt" 2 "$?" BLOCKED
assert_tree "$work" "$before" "a missing fragment"
