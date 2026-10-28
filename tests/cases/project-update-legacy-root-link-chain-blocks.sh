#!/usr/bin/env bash
# Scenario: A chain of links resolving outside the working tree blocks.
# Requirement: The shapes before 1.0.0 are converted only where git holds the
# original. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where the root AGENTS.md is a link to conf/AGENTS.md inside the
# working tree, itself a tracked link to a file outside it holding a v12
# block, the tool reports BLOCKED, names the file outside the working tree,
# and nothing is changed.
#
# Executes the tool. Red until task 1.5 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
outside="$TESTDIR/outside/workflow-rules.md"
mkdir -p "$TESTDIR/outside" "$TESTDIR/work/conf"
printf '%s\n' "$V12_BLOCK" > "$outside"
work="$TESTDIR/work"
ln -s "$outside" "$work/conf/AGENTS.md"
ln -s conf/AGENTS.md "$work/$(target_of development-workflow)"
git_fixture "$work"
sum="$(md5sum "$outside" | awk '{print $1}')"
before="$(tree_sum "$work")"
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
assert_outcome "$TESTDIR/report.txt" 2 "$?" BLOCKED
assert_contains "$TESTDIR/report.txt" "outside/workflow-rules.md" "the report names the file outside the working tree"
assert_unchanged "$outside" "$sum" "the file outside the working tree"
assert_tree "$work" "$before" "the chain of links"
