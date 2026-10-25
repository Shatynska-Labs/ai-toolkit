#!/usr/bin/env bash
# Scenario: A backlog path that is not a directory is not written through.
# Requirement: A backlog is seeded where none exists.
# Change: one-file-per-backlog-entry (project-bootstrap, MODIFIED).
#
# SPECIFIED: where docs/backlog is a symbolic link (here to an empty directory
# outside the target) or a regular file, nothing is written at or through it,
# the report states it is not a directory the tool writes into, and the
# remaining concerns proceed (the workstream register is still seeded).
# DERIVED (token, unresolved question Q2): the report's `backlog:` line
# carries `not a directory`.
#
# Executes the tool; red until task 1.2 lands (state 1: the current tool
# reports neither path this way).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

check_report() {
  grep -E '^backlog:' "$1" | grep -q -i 'not a directory' \
    || { echo "FAIL: the backlog report line does not say the path is not a directory it writes into ($2)" >&2; cat "$1" >&2; exit 1; }
}

# A symbolic link.
work="$TESTDIR/link"
mkdir -p "$work/docs"
outside="$TESTDIR/outside"
mkdir -p "$outside"
ln -s "$outside" "$work/docs/backlog"
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report-link.txt" 2>&1
if [ ! -L "$work/docs/backlog" ] || [ "$(readlink "$work/docs/backlog")" != "$outside" ]; then
  echo "FAIL: the link at docs/backlog changed" >&2; exit 1
fi
[ -z "$(ls -A "$outside")" ] || { echo "FAIL: the tool wrote through the link:" >&2; ls -A "$outside" >&2; exit 1; }
check_report "$TESTDIR/report-link.txt" link
assert_file "$work/docs/workstreams/README.md" "the remaining concerns proceed (link)"

# A regular file.
work="$TESTDIR/file"
mkdir -p "$work/docs"
printf 'not a backlog\n' > "$work/docs/backlog"
sum="$(md5sum "$work/docs/backlog" | awk '{print $1}')"
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report-file.txt" 2>&1
assert_unchanged "$work/docs/backlog" "$sum" "the file at docs/backlog is unchanged"
check_report "$TESTDIR/report-file.txt" file
assert_file "$work/docs/workstreams/README.md" "the remaining concerns proceed (file)"
