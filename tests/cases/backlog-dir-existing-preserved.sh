#!/usr/bin/env bash
# Scenario: An existing backlog is preserved exactly.
# Requirement: A backlog is seeded where none exists.
# Change: one-file-per-backlog-entry (project-bootstrap, MODIFIED).
#
# SPECIFIED: where docs/backlog/README.md exists, it and every entry file
# beside it are left byte-for-byte unchanged and the report states the
# backlog is already present. The README is deliberately not the seeded text,
# so a tool that "normalised" it would have something to change.
# SPECIFIED (Each concern is checked independently and is safe to repeat, not
# modified here): a second run of the tool over a directory it seeded leaves
# it unchanged and reports it present — the repeat half of the superseded
# repeated-execution-backlog.sh.
# DERIVED (token): `backlog: already present` (tests/README.md report
# contract).
#
# Executes the tool; red until task 1.2 lands (state 2 for the repeat half,
# which reads docs/backlog/README.md).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work/docs/backlog"
cd "$work" || exit 1
printf '# Our backlog\n\nRules of our own.\n' > docs/backlog/README.md
printf -- '---\npriority: normal\nkind: fix\n---\n\nAn entry.\n' > docs/backlog/some-entry.md
sum_readme="$(md5sum docs/backlog/README.md | awk '{print $1}')"
sum_entry="$(md5sum docs/backlog/some-entry.md | awk '{print $1}')"

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
assert_exit 0 "$?"
assert_unchanged "$work/docs/backlog/README.md" "$sum_readme" "the README is unchanged"
assert_unchanged "$work/docs/backlog/some-entry.md" "$sum_entry" "the entry file is unchanged"
assert_contains "$report" "backlog: already present" "presence reported"
# shellcheck disable=SC2012 # names are the test's own fixture names, plain ASCII
[ "$(ls -A docs/backlog | sort | tr '\n' ' ')" = "README.md some-entry.md " ] || { echo "FAIL: docs/backlog/ gained a file" >&2; exit 1; }
assert_file_absent "$work/docs/backlog.md" "no single file is written beside the directory"

# The repeat half: a directory the tool seeded itself.
again="$TESTDIR/again"
mkdir -p "$again"
cd "$again" || exit 1
bash "$PROJECT_INIT" >/dev/null 2>&1
assert_file "$again/docs/backlog/README.md" "the first run seeds the README"
sum_seeded="$(md5sum docs/backlog/README.md | awk '{print $1}')"
report2="$TESTDIR/report2.txt"
bash "$PROJECT_INIT" >"$report2" 2>&1
assert_exit 0 "$?"
assert_unchanged "$again/docs/backlog/README.md" "$sum_seeded" "a second run leaves the README"
assert_contains "$report2" "backlog: already present" "a second run reports it present"
