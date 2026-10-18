#!/usr/bin/env bash
# Scenario: An existing repository's branch is left alone — reached through a
# symlink (run from inside the link, no target argument).
# `real/` is a repository on `develop` with a commit; `link` points at it.
# Only HEAD is asserted: whether the repository concern is *reported* as
# already present via a symlink is repository-concern detection, outside
# this change's scope.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

export HOME="$TESTDIR/home" XDG_CONFIG_HOME="$TESTDIR/xdg" GIT_CONFIG_NOSYSTEM=1
unset GIT_CONFIG_GLOBAL GIT_CONFIG_SYSTEM GIT_CONFIG GIT_CONFIG_COUNT GIT_DIR GIT_WORK_TREE
mkdir -p "$HOME" "$XDG_CONFIG_HOME"

real="$TESTDIR/real"
mkdir -p "$real"
cd "$real" || exit 1
git init -q || exit 1
git symbolic-ref HEAD refs/heads/develop || exit 1
git config user.email "t@t.com"
git config user.name "t"
echo x > tracked.txt
git add . && git commit -q -m "initial" || exit 1

link="$TESTDIR/link"
ln -s "$real" "$link" || exit 1

# Guard: the link really resolves to the repository on develop.
if [ "$(git -C "$link" symbolic-ref HEAD 2>/dev/null)" != "refs/heads/develop" ]; then
  echo "FAIL: precondition — the repository is not reachable on develop through the link" >&2
  exit 1
fi

report="$TESTDIR/report.txt"
cd "$link" || exit 1
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

head_ref="$(git -C "$real" symbolic-ref HEAD 2>/dev/null)"
if [ "$head_ref" != "refs/heads/develop" ]; then
  echo "FAIL: expected HEAD still refs/heads/develop after a run through a symlink (exit $status), got '${head_ref}'" >&2
  exit 1
fi
if ! git -C "$real" log --oneline | grep -q "initial"; then
  echo "FAIL: the existing commit is no longer reachable from HEAD" >&2
  exit 1
fi
