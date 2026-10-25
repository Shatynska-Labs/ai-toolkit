#!/usr/bin/env bash
# Scenario: A single-file backlog is pointed to the migration tool.
# Requirement: A backlog is seeded where none exists.
# Change: one-file-per-backlog-entry (project-bootstrap, MODIFIED).
#
# SPECIFIED: in a target with docs/backlog.md and no docs/backlog/, the file
# is byte-for-byte unchanged, docs/backlog/ is not created, and the report
# states the backlog is in the single-file shape and names
# scripts/backlog-migrate.
# DERIVED (token, unresolved question Q2): the report's `backlog:` line
# carries `single` (any case) and `scripts/backlog-migrate`.
#
# Executes the tool; red until task 1.2 lands (state 1: the current tool
# reports the file present without the pointer).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work/docs"
cd "$work" || exit 1
# shellcheck disable=SC2016 # backticks and $ are literal text in a pattern or fixture
printf '# Backlog\n\n## `some-change`\n\nWhat and why.\n' > docs/backlog.md
sum="$(md5sum docs/backlog.md | awk '{print $1}')"

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
assert_exit 0 "$?"
assert_unchanged "$work/docs/backlog.md" "$sum" "the single file is unchanged"
assert_file_absent "$work/docs/backlog" "docs/backlog/ is not created"
line="$(grep -E '^backlog:' "$report")"
case "$line" in
  *scripts/backlog-migrate*) ;;
  *) echo "FAIL: the backlog report line does not name scripts/backlog-migrate: $line" >&2; exit 1 ;;
esac
printf '%s\n' "$line" | grep -q -i 'single' || { echo "FAIL: the backlog report line does not say the backlog is in the single-file shape: $line" >&2; exit 1; }
