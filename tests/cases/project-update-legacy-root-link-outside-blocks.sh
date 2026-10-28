#!/usr/bin/env bash
# Scenario: A root link resolving outside the working tree blocks.
# Requirement: The shapes before 1.0.0 are converted only where git holds the
# original. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where the root AGENTS.md is a tracked symbolic link to a file
# outside the working tree holding a v12 block, the tool reports BLOCKED,
# names the link and the file it resolves to, and neither is changed.
# DERIVED (token): the link is named as `AGENTS.md` and the file by its path;
# the outside file is named workflow-rules.md so the two are told apart.
#
# Executes the tool. Red until task 1.5 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
outside="$TESTDIR/outside/workflow-rules.md"
mkdir -p "$TESTDIR/outside" "$TESTDIR/work"
printf '%s\n' "$V12_BLOCK" > "$outside"
work="$TESTDIR/work"
link="$work/$(target_of development-workflow)"
ln -s "$outside" "$link"
git_fixture "$work"
sum="$(md5sum "$outside" | awk '{print $1}')"
before="$(tree_sum "$work")"
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
assert_outcome "$TESTDIR/report.txt" 2 "$?" BLOCKED
assert_contains "$TESTDIR/report.txt" "outside/workflow-rules.md" "the report names the file the link resolves to"
grep -v '^Target:' "$TESTDIR/report.txt" | grep -q -F 'AGENTS.md' || { echo "FAIL: the report does not name the link AGENTS.md" >&2; cat "$TESTDIR/report.txt" >&2; exit 1; }
assert_unchanged "$outside" "$sum" "the file outside the working tree"
assert_tree "$work" "$before" "the link"
