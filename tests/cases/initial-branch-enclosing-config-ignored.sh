#!/usr/bin/env bash
# Scenario: A configured default in an enclosing repository is not read.
# Requirement: A repository the tool creates starts on a stated branch.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# No global or system configuration sets init.defaultBranch.
export HOME="$TESTDIR/home" XDG_CONFIG_HOME="$TESTDIR/xdg" GIT_CONFIG_NOSYSTEM=1
unset GIT_CONFIG_GLOBAL GIT_CONFIG_SYSTEM GIT_CONFIG GIT_CONFIG_COUNT GIT_DIR GIT_WORK_TREE
mkdir -p "$HOME" "$XDG_CONFIG_HOME"

outer="$TESTDIR/outer"
mkdir -p "$outer"
cd "$outer" || exit 1
git init -q || exit 1
git config init.defaultBranch outerbranch || exit 1

inner="$outer/inner"
mkdir -p "$inner"
cd "$inner" || exit 1

# Guard: from the caller's directory the enclosing repository's setting is
# visible — otherwise this case could not tell a correct read from a wrong one.
if [ "$(git config --get init.defaultBranch 2>/dev/null)" != "outerbranch" ]; then
  echo "FAIL: precondition — the enclosing repository's init.defaultBranch is not visible from the target" >&2
  exit 1
fi

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status"
assert_contains "$report" "repository: created" "the tool created the inner repository"
head_ref="$(git -C "$inner" symbolic-ref HEAD 2>/dev/null)"
if [ "$head_ref" != "refs/heads/main" ]; then
  echo "FAIL: expected HEAD refs/heads/main — the enclosing repository's init.defaultBranch must not be read — got '${head_ref}'" >&2
  exit 1
fi
