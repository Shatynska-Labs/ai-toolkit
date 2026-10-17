#!/usr/bin/env bash
# Requirement: "the tool SHALL NOT change the repository's current branch".
# The target holds a real repository with a commit on `develop` whose HEAD
# file is corrupted. What the tool should report or conclude is undecided
# (docs/backlog.md), so neither the report nor the outcome is asserted —
# only that the run did not write `ref: refs/heads/main` into HEAD.
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
printf 'garbage-not-a-ref\n' > "$work/.git/HEAD"

# Guard: git cannot open the repository with this HEAD.
if git -C "$work" rev-parse --git-dir >/dev/null 2>&1; then
  echo "FAIL: precondition — git still opens the repository despite the corrupted HEAD" >&2
  exit 1
fi

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

head_content="$(cat "$work/.git/HEAD" 2>/dev/null)"
if [ "$head_content" = "ref: refs/heads/main" ]; then
  echo "FAIL: the run (exit $status) wrote 'ref: refs/heads/main' into the corrupted repository's HEAD" >&2
  exit 1
fi
