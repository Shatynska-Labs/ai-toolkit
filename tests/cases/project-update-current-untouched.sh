#!/usr/bin/env bash
# Scenario: An untouched block at the fragment's version is current.
# Requirement: Each block the manifest lists is classified from the project
# alone. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where a block was written by project-init from the fragment the
# tool reads and not changed since, its line reports it current, with its
# version, and the target is byte-for-byte unchanged.
# DERIVED (scope): every manifest record, written by project-init into an
# empty directory, is checked; "unchanged" is read over the whole tree.
#
# Executes both tools. Red until tasks 1.1 and 1.2 land (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
work="$TESTDIR/work"
mkdir -p "$work"
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/init.txt" 2>&1
assert_exit 0 "$?" "fixture — project-init in an empty directory"
before="$(tree_sum "$work")"
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
assert_tree "$work" "$before" "current blocks"
n=0
while read -r name _target; do
  [ -n "$name" ] || continue
  n=$((n + 1))
  expect_line "$TESTDIR/report.txt" "$name" current "$(fversion "$name")"
done <<< "$(records)"
[ "$n" -gt 0 ] || { echo "FAIL: target absent — the manifest lists no record" >&2; exit 1; }
