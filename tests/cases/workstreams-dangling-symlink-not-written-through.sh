#!/usr/bin/env bash
# Scenario: An existing workstream register is preserved exactly — "or a
# symbolic link at that path ... not written through".
# Requirement: A workstream register is seeded where none exists (presence
# clause: "a path ... of any type, including a symbolic link whether or not
# it resolves"). Change: add-workstreams (project-bootstrap, ADDED).
#
# SPECIFIED: a dangling link at `docs/workstreams/README.md` is reported
# present, is left as it was, and nothing is created at its target. A dangling
# link is the case a plain `[ -e ]` gets wrong.
# DERIVED (token): `workstreams: already present` (design.md decision 12).
#
# Executes the tool; no fixture owed. Red until the concern lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work/docs/workstreams"
cd "$work" || exit 1
mkdir -p "$TESTDIR/outside"
outside="$TESTDIR/outside/register-target.md"
ln -s "$outside" docs/workstreams/README.md

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status"
assert_contains "$report" "workstreams: rules present as docs/workstreams/README.md" "a dangling link counts as present, in the shape before 1.0.0"
assert_file_absent "$outside" "nothing written through the link to its target"
if [ ! -L "$work/docs/workstreams/README.md" ]; then
  echo "FAIL: docs/workstreams/README.md is no longer a symbolic link" >&2
  exit 1
fi
if [ "$(readlink "$work/docs/workstreams/README.md")" != "$outside" ]; then
  echo "FAIL: the link's target changed: $(readlink "$work/docs/workstreams/README.md")" >&2
  exit 1
fi
