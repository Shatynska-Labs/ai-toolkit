#!/usr/bin/env bash
# Scenario: A configured default is honoured.
# Requirement: A repository the tool creates starts on a stated branch.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

export HOME="$TESTDIR/home" XDG_CONFIG_HOME="$TESTDIR/xdg" GIT_CONFIG_NOSYSTEM=1
unset GIT_CONFIG_GLOBAL GIT_CONFIG_SYSTEM GIT_CONFIG GIT_CONFIG_COUNT GIT_DIR GIT_WORK_TREE
mkdir -p "$HOME" "$XDG_CONFIG_HOME"

# The operator's (isolated) global configuration names a non-main default.
git config --global init.defaultBranch trunk || exit 1

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status" "a fresh directory still succeeds"
assert_contains "$report" "repository: created" "the tool created the repository"
head_ref="$(git -C "$work" symbolic-ref HEAD 2>/dev/null)"
if [ "$head_ref" != "refs/heads/trunk" ]; then
  echo "FAIL: expected HEAD refs/heads/trunk (the configured default), got '${head_ref}'" >&2
  exit 1
fi
