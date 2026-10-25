#!/usr/bin/env bash
# Requirement: A backlog is seeded where none exists — presence clause.
# Scenario accounted: An existing backlog is preserved exactly (a link is an
# existing path). Change: seed-the-backlog.
#
# SPECIFIED: "The file is present where a path exists at `docs/backlog.md` of
# any type, including a symbolic link whether or not it resolves. A link
# counted as absent would be written through, to wherever it points."
# A dangling link is the case a plain `[ -e ]` gets wrong: the tool must
# report it present, leave the link as it was, and create nothing at its
# target.
# DERIVED (token): `backlog: already present` is design.md's report line.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work/docs"
cd "$work" || exit 1
mkdir -p "$TESTDIR/outside"
outside="$TESTDIR/outside/backlog-target.md"
ln -s "$outside" docs/backlog.md

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status"
assert_contains "$report" "backlog: present as the single file docs/backlog.md" "a dangling link counts as present, in the single-file shape"
assert_file_absent "$outside" "nothing written through the link to its target"
if [ ! -L "$work/docs/backlog.md" ]; then
  echo "FAIL: docs/backlog.md is no longer a symbolic link" >&2
  exit 1
fi
if [ "$(readlink "$work/docs/backlog.md")" != "$outside" ]; then
  echo "FAIL: the link's target changed: $(readlink "$work/docs/backlog.md")" >&2
  exit 1
fi
