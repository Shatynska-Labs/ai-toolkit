#!/usr/bin/env bash
# Requirement: A repository the tool creates starts on a stated branch.
# The target holds an empty `.git` directory — not a repository. The run must
# end with a repository at the target whose HEAD is refs/heads/main (no
# configured default): an empty `.git` is not a repository whose branch the
# tool must leave alone.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

export HOME="$TESTDIR/home" XDG_CONFIG_HOME="$TESTDIR/xdg" GIT_CONFIG_NOSYSTEM=1
unset GIT_CONFIG_GLOBAL GIT_CONFIG_SYSTEM GIT_CONFIG GIT_CONFIG_COUNT GIT_DIR GIT_WORK_TREE
mkdir -p "$HOME" "$XDG_CONFIG_HOME"

work="$TESTDIR/work"
mkdir -p "$work/.git"
cd "$work" || exit 1

# Guard: git does not see a repository here before the run.
if git -C "$work" rev-parse --git-dir >/dev/null 2>&1; then
  echo "FAIL: precondition — an empty .git directory was recognised as a repository" >&2
  exit 1
fi

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

head_ref="$(git -C "$work" symbolic-ref HEAD 2>/dev/null)"
if [ "$head_ref" != "refs/heads/main" ]; then
  echo "FAIL: expected HEAD refs/heads/main after initializing over an empty .git directory (exit $status), got '${head_ref}'" >&2
  exit 1
fi
