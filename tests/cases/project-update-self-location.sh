#!/usr/bin/env bash
# Scenario: Fragments come from the copy the tool belongs to.
# Requirement: The update tool is a standalone executable beside project-init.
# Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: run from one copy of the library while an environment variable
# names another, the blocks the tool writes carry the fragments and versions
# of the copy it was invoked from.
# DERIVED (fixture): the environment variables are AI_TOOLKIT_ROOT (the one
# project-init's own case uses) and TOOLKIT_ROOT; the two copies differ in the
# workflow fragment's version (7.7.7 against 9.9.9) and in one distinct body
# line each.
#
# Executes the tool. Red until tasks 1.1 and 1.3 land (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
mine="$TESTDIR/mine"
decoy="$TESTDIR/decoy"
toolkit_copy "$mine"
toolkit_copy "$decoy"
require_update "$mine/scripts/project-update"
set_version "$mine/rules/development-workflow.md" 7.7.7
set_version "$decoy/rules/development-workflow.md" 9.9.9
printf '\nA line only the invoked copy carries.\n' >> "$mine/rules/development-workflow.md"
printf '\nA line only the decoy carries.\n' >> "$decoy/rules/development-workflow.md"
work="$TESTDIR/work"
mkdir -p "$work"
put_block "$work" development-workflow 0.0.1 "an old text" "$mine"
f="$work/$(target_of development-workflow "$mine")"
(cd "$work" && AI_TOOLKIT_ROOT="$decoy" TOOLKIT_ROOT="$decoy" bash "$mine/scripts/project-update") >"$TESTDIR/report.txt" 2>&1
[ "$(marker_version "$f" development-workflow)" = 7.7.7 ] || { echo "FAIL: the block does not carry the invoked copy's version 7.7.7" >&2; cat "$f" >&2; cat "$TESTDIR/report.txt" >&2; exit 1; }
assert_contains "$f" "A line only the invoked copy carries." "the invoked copy's body"
if grep -q -F 'A line only the decoy carries.' "$f" || grep -q '9\.9\.9' "$TESTDIR/report.txt"; then
  echo "FAIL: the tool read the copy an environment variable names" >&2; exit 1
fi
