#!/usr/bin/env bash
# Scenario: A project with no legacy item needs no repository.
# Requirement: The shapes before 1.0.0 are converted only where git holds the
# original. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where the target is not a git working tree and holds only hashed
# blocks, one of them stale, the stale block is replaced and the outcome is
# SUCCESS.
# DERIVED (scope): exit 0.
#
# Executes the tool. Red until task 1.3 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
work="$TESTDIR/work"
mkdir -p "$work"
seed_all "$work" current
f="$work/$(target_of backlog)"
rm -f "$f"
put_block "$work" backlog "$(lower_version "$(fversion backlog)")" "old"
if git -C "$work" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "FAIL: fixture — $work lies inside a git working tree" >&2; exit 1
fi
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
assert_outcome "$TESTDIR/report.txt" 0 "$?" SUCCESS
[ "$(marker_version "$f" backlog)" = "$(fversion backlog)" ] || { echo "FAIL: the stale block was not replaced" >&2; exit 1; }
