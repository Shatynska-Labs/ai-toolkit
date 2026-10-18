#!/usr/bin/env bash
# Requirement text (no scenario of its own): "The configuration SHALL be read
# as the created repository sees it, not as ... the caller's working
# directory sees it." The caller sits in an unrelated repository whose local
# configuration sets init.defaultBranch; the target is outside it.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

export HOME="$TESTDIR/home" XDG_CONFIG_HOME="$TESTDIR/xdg" GIT_CONFIG_NOSYSTEM=1
unset GIT_CONFIG_GLOBAL GIT_CONFIG_SYSTEM GIT_CONFIG GIT_CONFIG_COUNT GIT_DIR GIT_WORK_TREE
mkdir -p "$HOME" "$XDG_CONFIG_HOME"

caller="$TESTDIR/caller"
mkdir -p "$caller"
cd "$caller" || exit 1
git init -q || exit 1
git config init.defaultBranch callerbranch || exit 1

target="$TESTDIR/target"
mkdir -p "$target"

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" "$target" >"$report" 2>&1
status=$?

assert_exit 0 "$status"
assert_contains "$report" "repository: created" "the tool created the target repository"
head_ref="$(git -C "$target" symbolic-ref HEAD 2>/dev/null)"
if [ "$head_ref" != "refs/heads/main" ]; then
  echo "FAIL: expected HEAD refs/heads/main — the caller's directory configuration must not be read — got '${head_ref}'" >&2
  exit 1
fi
