#!/usr/bin/env bash
# Scenario: An untracked legacy README blocks.
# Requirement: The shapes before 1.0.0 are converted only where git holds the
# original. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where docs/backlog/README.md exists and is not tracked by git, the
# tool reports BLOCKED, names it, and writes nothing.
# DERIVED (fixture): the repository has a commit holding other files.
#
# Executes the tool. Red until task 1.5 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
work="$TESTDIR/work"
mkdir -p "$work"
printf '# Our project\n' > "$work/README.md"
git_fixture "$work"
mkdir -p "$work/docs/backlog"
printf '# Backlog\n\nOur rules.\n' > "$work/docs/backlog/README.md"
before="$(tree_sum "$work")"
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
assert_outcome "$TESTDIR/report.txt" 2 "$?" BLOCKED
assert_contains "$TESTDIR/report.txt" "docs/backlog/README.md" "the report names the file"
assert_tree "$work" "$before" "an untracked legacy README"
