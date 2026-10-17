#!/usr/bin/env bash
# Requirement (project-bootstrap): the tool "SHALL state the target
# directory in its report before making any change". The target argument is
# a symlink to an empty directory; the `Target:` line states the path as
# given, as `explicit-target-argument.sh` asserts for a plain path. Keeps
# that assertion meaningful where TMPDIR itself sits behind a symlink.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

export HOME="$TESTDIR/home" XDG_CONFIG_HOME="$TESTDIR/xdg" GIT_CONFIG_NOSYSTEM=1
unset GIT_CONFIG_GLOBAL GIT_CONFIG_SYSTEM GIT_CONFIG GIT_CONFIG_COUNT GIT_DIR GIT_WORK_TREE
mkdir -p "$HOME" "$XDG_CONFIG_HOME"

real="$TESTDIR/real"
link="$TESTDIR/link"
elsewhere="$TESTDIR/elsewhere"
mkdir -p "$real" "$elsewhere"
ln -s "$real" "$link" || exit 1
cd "$elsewhere" || exit 1

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" "$link" >"$report" 2>&1
status=$?

assert_exit 0 "$status"
if ! grep -qxF "Target: $link" "$report"; then
  echo "FAIL: expected the exact line 'Target: $link' (the path as given); got: $(grep '^Target:' "$report")" >&2
  exit 1
fi
assert_file "$real/AGENTS.md" "the directory behind the link was initialized"
