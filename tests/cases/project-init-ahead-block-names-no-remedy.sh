#!/usr/bin/env bash
# Scenario: A block ahead of the toolkit names no remedy.
# Requirement: Workflow rules reach a project as a versioned managed block.
# Change: update-managed-block (project-bootstrap, MODIFIED).
#
# SPECIFIED: where a managed block for the same fragment already exists at a
# higher version than the fragment's, the block is left unchanged, and the
# report states both versions, that the block is ahead of this copy of the
# toolkit, and does not name scripts/project-update.
# DERIVED (fixture): the higher version is the fragment's major plus one.
# DERIVED (token): read on the `conventions file:` line, stating `ahead`; the
# whole report must not name `project-update`.
#
# Executes project-init. Red until task 2.1 lands (state 1).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
carried="$(fversion development-workflow)"
higher="$(printf '%s\n' "$carried" | awk -F. '{print ($1 + 1) ".0.0"}')"
work="$TESTDIR/work"
mkdir -p "$work"
put_block "$work" development-workflow "$higher" "a later text"
f="$work/$(target_of development-workflow)"
sum="$(md5sum "$f" | awk '{print $1}')"
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"
assert_unchanged "$f" "$sum" "the block ahead of the toolkit"
expect_line "$TESTDIR/report.txt" "conventions file" "$higher" "$carried" ahead
if grep -q -F 'project-update' "$TESTDIR/report.txt"; then
  echo "FAIL: the report names project-update for a block ahead of the toolkit" >&2; cat "$TESTDIR/report.txt" >&2; exit 1
fi
