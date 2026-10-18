#!/usr/bin/env bash
# Requirement: Workflow rules reach a project as a versioned managed block —
# "Where the target's CLAUDE.md contains the @AGENTS.md import, the report
# SHALL state nothing about the import": neither the import line nor the note.
# Derived by change-test-writer for retire-the-claude-md-import-notice; see
# that change's test-plan.md for each assertion's classification.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
echo "@AGENTS.md" > CLAUDE.md

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status"
assert_file "$work/AGENTS.md" "AGENTS.md created"
if grep -qF 'Import needed:' "$report"; then
  echo "FAIL: the target's CLAUDE.md imports AGENTS.md, yet the import line was printed" >&2
  exit 1
fi
if grep -qF '2.1.277' "$report"; then
  echo "FAIL: the target's CLAUDE.md imports AGENTS.md, yet the version note was printed — nothing about the import is owed" >&2
  exit 1
fi
