#!/usr/bin/env bash
# Scenario: An unusable target blocks.
# Requirement: The update tool is a standalone executable beside project-init.
# Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: a target that does not exist, is not a directory, or is not
# writable is reported BLOCKED, exits with BLOCKED's code (2), and nothing is
# written.
# DERIVED (fixture): the unwritable target is a directory of mode 555 holding
# a stale block; permissions do not bind as root, so the case fails there
# rather than passing vacuously.
#
# Executes the tool. Red until task 1.1 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
if [ "$(id -u)" = 0 ]; then
  echo "FAIL: running as root, an unwritable target cannot be arranged" >&2; exit 1
fi
missing="$TESTDIR/missing"
(cd "$TESTDIR" && bash "$PROJECT_UPDATE" "$missing") >"$TESTDIR/r1.txt" 2>&1
assert_outcome "$TESTDIR/r1.txt" 2 "$?" BLOCKED
assert_file_absent "$missing" "a missing target is not created"

printf 'a file\n' > "$TESTDIR/afile"
sum="$(md5sum "$TESTDIR/afile" | awk '{print $1}')"
(cd "$TESTDIR" && bash "$PROJECT_UPDATE" "$TESTDIR/afile") >"$TESTDIR/r2.txt" 2>&1
assert_outcome "$TESTDIR/r2.txt" 2 "$?" BLOCKED
assert_unchanged "$TESTDIR/afile" "$sum" "a file named as the target"

ro="$TESTDIR/ro"
mkdir -p "$ro"
seed_all "$ro" stale
before="$(tree_sum "$ro")"
chmod 555 "$ro"
trap 'chmod 755 "$ro"' EXIT
(cd "$TESTDIR" && bash "$PROJECT_UPDATE" "$ro") >"$TESTDIR/r3.txt" 2>&1
status=$?
chmod 755 "$ro"
assert_outcome "$TESTDIR/r3.txt" 2 "$status" BLOCKED
assert_tree "$ro" "$before" "an unwritable target"
