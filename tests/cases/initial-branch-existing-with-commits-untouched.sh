#!/usr/bin/env bash
# Scenario: An existing repository's branch is left alone (with commits).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

export HOME="$TESTDIR/home" XDG_CONFIG_HOME="$TESTDIR/xdg" GIT_CONFIG_NOSYSTEM=1
unset GIT_CONFIG_GLOBAL GIT_CONFIG_SYSTEM GIT_CONFIG GIT_CONFIG_COUNT GIT_DIR GIT_WORK_TREE
mkdir -p "$HOME" "$XDG_CONFIG_HOME"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
git init -q || exit 1
git symbolic-ref HEAD refs/heads/develop || exit 1
git config user.email "t@t.com"
git config user.name "t"
echo x > tracked.txt
git add . && git commit -q -m "initial" || exit 1

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status"
assert_contains "$report" "repository: already present" "existing repository reported as already present"
head_ref="$(git -C "$work" symbolic-ref HEAD 2>/dev/null)"
if [ "$head_ref" != "refs/heads/develop" ]; then
  echo "FAIL: expected HEAD still refs/heads/develop on an existing repository with commits, got '${head_ref}'" >&2
  exit 1
fi
