#!/usr/bin/env bash
# Scenario: No configured default yields main.
# Requirement: A repository the tool creates starts on a stated branch.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Isolate git configuration from the operator's own: no global, XDG or
# system file the run can see, so init.defaultBranch is genuinely unset.
export HOME="$TESTDIR/home" XDG_CONFIG_HOME="$TESTDIR/xdg" GIT_CONFIG_NOSYSTEM=1
unset GIT_CONFIG_GLOBAL GIT_CONFIG_SYSTEM GIT_CONFIG GIT_CONFIG_COUNT GIT_DIR GIT_WORK_TREE
mkdir -p "$HOME" "$XDG_CONFIG_HOME"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1

# Precondition guard: the scenario requires init.defaultBranch unset.
if git config --get init.defaultBranch >/dev/null 2>&1; then
  echo "FAIL: precondition — init.defaultBranch is visible to the run; isolation failed" >&2
  exit 1
fi

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status" "a fresh directory still succeeds"
assert_contains "$report" "repository: created" "the tool created the repository"
head_ref="$(git -C "$work" symbolic-ref HEAD 2>/dev/null)"
if [ "$head_ref" != "refs/heads/main" ]; then
  echo "FAIL: expected HEAD refs/heads/main with no configured default, got '${head_ref}'" >&2
  exit 1
fi
