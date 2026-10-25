#!/usr/bin/env bash
# Scenario: A README is added beside existing entries.
# Requirement: A backlog is seeded where none exists.
# Change: one-file-per-backlog-entry (project-bootstrap, MODIFIED).
#
# SPECIFIED: where docs/backlog/ is a directory holding entry files and no
# README, the README is created and every entry file is byte-for-byte
# unchanged; the README is the seed (requirement text).
# DERIVED (token, unresolved question Q2): the report's `backlog:` line
# carries `created`.
#
# Executes the tool; red until tasks 1.1 and 1.2 land (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work/docs/backlog"
cd "$work" || exit 1
printf -- '---\npriority: normal\nkind: fix\n---\n\nThe first.\n' > docs/backlog/first-entry.md
printf -- '---\nkind: change\n---\n\nThe second.\n' > docs/backlog/second-entry.md
sum1="$(md5sum docs/backlog/first-entry.md | awk '{print $1}')"
sum2="$(md5sum docs/backlog/second-entry.md | awk '{print $1}')"

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
assert_exit 0 "$?"
assert_file "$work/docs/backlog/README.md" "the README is created beside the entries"
assert_unchanged "$work/docs/backlog/first-entry.md" "$sum1" "the first entry is unchanged"
assert_unchanged "$work/docs/backlog/second-entry.md" "$sum2" "the second entry is unchanged"
seed="$TOOLKIT_ROOT/scripts/seed/backlog-README.md"
assert_file "$seed" "the shared seed"
cmp -s "$seed" "$work/docs/backlog/README.md" || { echo "FAIL: the README written is not the seed" >&2; exit 1; }
grep -E '^backlog:' "$report" | grep -q 'created' || { echo "FAIL: the backlog report line does not say the README was created" >&2; cat "$report" >&2; exit 1; }
