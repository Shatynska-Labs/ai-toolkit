#!/usr/bin/env bash
# Requirement: "the tool SHALL NOT change the repository's current branch" /
# "Where the tool initializes the repository, HEAD SHALL name ... main".
# The caller's environment carries GIT_DIR/GIT_WORK_TREE pointing at a caller
# repository on `feature` with a commit; the tool runs on a separate fresh
# target. The caller repository's branch must survive, and the target must
# get its own repository on main.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

export HOME="$TESTDIR/home" XDG_CONFIG_HOME="$TESTDIR/xdg" GIT_CONFIG_NOSYSTEM=1
unset GIT_CONFIG_GLOBAL GIT_CONFIG_SYSTEM GIT_CONFIG GIT_CONFIG_COUNT GIT_DIR GIT_WORK_TREE
mkdir -p "$HOME" "$XDG_CONFIG_HOME"

caller="$TESTDIR/caller"
mkdir -p "$caller"
cd "$caller" || exit 1
git init -q || exit 1
git symbolic-ref HEAD refs/heads/feature || exit 1
git config user.email "t@t.com"
git config user.name "t"
echo x > tracked.txt
git add . && git commit -q -m "caller history" || exit 1

target="$TESTDIR/target"
mkdir -p "$target"
cd "$TESTDIR" || exit 1

report="$TESTDIR/report.txt"
GIT_DIR="$caller/.git" GIT_WORK_TREE="$caller" bash "$PROJECT_INIT" "$target" >"$report" 2>&1
status=$?

caller_head="$(git -C "$caller" symbolic-ref HEAD 2>/dev/null)"
if [ "$caller_head" != "refs/heads/feature" ]; then
  echo "FAIL: the caller repository named by GIT_DIR had its HEAD changed (exit $status): expected refs/heads/feature, got '${caller_head}'" >&2
  exit 1
fi
if ! git -C "$caller" log --oneline | grep -q "caller history"; then
  echo "FAIL: the caller repository's commit is no longer reachable from HEAD" >&2
  exit 1
fi
assert_file "$target/.git/HEAD" "the target got its own repository (exit $status)"
target_head="$(git --git-dir="$target/.git" symbolic-ref HEAD 2>/dev/null)"
if [ "$target_head" != "refs/heads/main" ]; then
  echo "FAIL: expected the target repository's HEAD refs/heads/main, got '${target_head}'" >&2
  exit 1
fi
