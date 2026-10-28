#!/usr/bin/env bash
# Scenario: A failed write reports what was written.
# Requirement: Every run ends in one of three outcomes, and the exit code
# agrees. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where two blocks are stale and writing the second fails, the tool
# reports ERROR, exits 1, and the report states that the first was replaced.
# DERIVED (mechanism): the two stale records are the manifest's first and the
# last whose target lies in a subdirectory; every other record is current.
# The second write is made to fail by making its target's directory
# unwritable (mode 555) — design.md decision 3 writes a temporary file there.
# "States that the first was replaced" is read as the first record's line
# saying `replaced`. Permissions do not bind as root; the case fails there.
# DERIVED (assumption): writes happen in manifest order (test-plan.md, Q3).
#
# Executes the tool. Red until task 1.3 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
if [ "$(id -u)" = 0 ]; then
  echo "FAIL: running as root, an unwritable directory cannot be arranged" >&2; exit 1
fi
first="$(records | awk 'NF { print $1; exit }')"
second="$(records | awk 'NF && $2 ~ /\// { n = $1 } END { print n }')"
if [ -z "$first" ] || [ -z "$second" ] || [ "$first" = "$second" ]; then
  echo "FAIL: fixture — the manifest has no two records to order" >&2; exit 1
fi
work="$TESTDIR/work"
mkdir -p "$work"
while read -r n t; do
  [ -n "$n" ] || continue
  v="$(fversion "$n")"
  if [ "$n" = "$first" ] || [ "$n" = "$second" ]; then v="$(lower_version "$v")"; fi
  put_block "$work" "$n" "$v" "text of $n"
done <<< "$(records)"
sdir="$(dirname "$work/$(target_of "$second")")"
ssum="$(md5sum "$work/$(target_of "$second")" | awk '{print $1}')"
chmod 555 "$sdir"
trap 'chmod 755 "$sdir"' EXIT
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
status=$?
chmod 755 "$sdir"
assert_outcome "$TESTDIR/report.txt" 1 "$status" ERROR
expect_line "$TESTDIR/report.txt" "$first" replaced
assert_unchanged "$work/$(target_of "$second")" "$ssum" "the block whose write failed"
