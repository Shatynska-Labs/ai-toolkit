#!/usr/bin/env bash
# Requirement text, accounted under the scenario A project without a backlog
# receives the seeded file: "The tool SHALL read the README's text from its
# own copy of the library, at scripts/seed/backlog-README.md, the file
# scripts/backlog-migrate writes from too".
# Requirement: A backlog is seeded where none exists.
# Change: one-file-per-backlog-entry (project-bootstrap, MODIFIED).
#
# SPECIFIED: the seeded docs/backlog/README.md is that file, byte for byte.
#
# Executes the tool; red until tasks 1.1 and 1.2 land (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

seed="$TOOLKIT_ROOT/scripts/seed/backlog-README.md"
assert_file "$seed" "target absent — the shared seed"

work="$TESTDIR/work"
mkdir -p "$work"
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"
assert_file "$work/docs/backlog/README.md" "the seeded README"
if ! cmp -s "$seed" "$work/docs/backlog/README.md"; then
  echo "FAIL: the seeded README is not scripts/seed/backlog-README.md byte for byte" >&2
  diff "$seed" "$work/docs/backlog/README.md" >&2
  exit 1
fi
