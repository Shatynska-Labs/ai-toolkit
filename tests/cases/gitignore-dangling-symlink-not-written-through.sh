#!/usr/bin/env bash
# Scenario: An existing ignore file is preserved exactly (a link is an
# existing path). Fix: count-a-dangling-ignore-file-link-as-present.
#
# A dangling link at `.gitignore` is the case a plain `[ -f ]` gets wrong: the
# tool must report it present, leave the link as it was, and create nothing at
# its target.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
mkdir -p "$TESTDIR/outside"
outside="$TESTDIR/outside/gitignore-target"
ln -s "$outside" .gitignore

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status"
assert_contains "$report" "ignore file: already present" "a dangling link counts as present"
assert_file_absent "$outside" "nothing written through the link to its target"
if [ ! -L "$work/.gitignore" ]; then
  echo "FAIL: .gitignore is no longer a symbolic link" >&2
  exit 1
fi
if [ "$(readlink "$work/.gitignore")" != "$outside" ]; then
  echo "FAIL: the link's target changed: $(readlink "$work/.gitignore")" >&2
  exit 1
fi
