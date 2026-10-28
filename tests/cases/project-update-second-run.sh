#!/usr/bin/env bash
# Scenario: A second run changes nothing.
# Requirement: A stale block nobody edited is replaced, and nothing outside
# its markers changes. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: run twice in a row in a project holding stale blocks, the second
# run reports every block it replaced as current, and leaves every file
# byte-for-byte as the first run left it.
# DERIVED (fixture): every manifest record stale; the first run is checked to
# have replaced them, so the second cannot pass on a tool that writes nothing.
#
# Executes the tool. Red until task 1.3 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
work="$TESTDIR/work"
mkdir -p "$work"
seed_all "$work" stale
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/first.txt" 2>&1
after_first="$(tree_sum "$work")"
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/second.txt" 2>&1
assert_tree "$work" "$after_first" "the second run"
while read -r name target; do
  [ -n "$name" ] || continue
  [ "$(marker_version "$work/$target" "$name")" = "$(fversion "$name")" ] || { echo "FAIL: the first run did not replace $name" >&2; cat "$TESTDIR/first.txt" >&2; exit 1; }
  expect_line "$TESTDIR/second.txt" "$name" current
done <<< "$(records)"
