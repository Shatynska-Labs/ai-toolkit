#!/usr/bin/env bash
# Scenario: The target is stated before any change.
# Requirement: The update tool is a standalone executable beside project-init.
# Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: given a path argument naming another directory, the first line of
# the report names that directory, and the tool acts on that directory.
# DERIVED (operationalisation): "names" is read as the first line containing
# the directory's absolute path (logical or physical); "acts on it" as a stale
# block in that directory being replaced, and the directory it was run from
# being left as it was.
#
# Executes the tool. Red until tasks 1.1 and 1.3 land (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
work="$TESTDIR/work"
elsewhere="$TESTDIR/elsewhere"
mkdir -p "$work" "$elsewhere"
seed_all "$work" stale
seed_all "$elsewhere" stale
other_before="$(tree_sum "$elsewhere")"
(cd "$elsewhere" && bash "$PROJECT_UPDATE" "$work") >"$TESTDIR/report.txt" 2>&1
first="$(head -n 1 "$TESTDIR/report.txt")"
phys="$(cd "$work" && pwd -P)"
case "$first" in
  *"$work"*|*"$phys"*) ;;
  *) echo "FAIL: the first line does not name the target: $first" >&2; exit 1 ;;
esac
want="$(fversion development-workflow)"
got="$(marker_version "$work/$(target_of development-workflow)" development-workflow)"
[ "$got" = "$want" ] || { echo "FAIL: the target's workflow block carries '$got', not $want — the tool did not act on the named directory" >&2; cat "$TESTDIR/report.txt" >&2; exit 1; }
assert_tree "$elsewhere" "$other_before" "the directory the tool was run from"
