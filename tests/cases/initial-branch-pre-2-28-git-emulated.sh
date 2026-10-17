#!/usr/bin/env bash
# Requirement text (no scenario of its own): "The step SHALL NOT rely on
# `git init --initial-branch` or on `git init` honouring init.defaultBranch
# ... the resulting branch SHALL be the same on an older git."
# A PATH stub emulates a pre-2.28 git: `init` rejects -b/--initial-branch and
# ignores init.defaultBranch (always starting on master); everything else is
# passed to the real git unchanged.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

export HOME="$TESTDIR/home" XDG_CONFIG_HOME="$TESTDIR/xdg" GIT_CONFIG_NOSYSTEM=1
unset GIT_CONFIG_GLOBAL GIT_CONFIG_SYSTEM GIT_CONFIG GIT_CONFIG_COUNT GIT_DIR GIT_WORK_TREE
mkdir -p "$HOME" "$XDG_CONFIG_HOME"
git config --global init.defaultBranch trunk || exit 1

real_git="$(command -v git)"
if [ -z "$real_git" ]; then
  echo "FAIL: precondition — git not found" >&2
  exit 1
fi

stubbin="$TESTDIR/stubbin"
mkdir -p "$stubbin"
cat > "$stubbin/git" <<STUB
#!/usr/bin/env bash
real_git="$real_git"
STUB
cat >> "$stubbin/git" <<'STUB'
# Find the subcommand past git's global options.
i=1
sub=""
while [ "$i" -le "$#" ]; do
  arg="${!i}"
  case "$arg" in
    -C|-c|--git-dir|--work-tree|--namespace) i=$((i + 2)) ;;
    -*) i=$((i + 1)) ;;
    *) sub="$arg"; break ;;
  esac
done
if [ "$sub" = "init" ]; then
  for arg in "$@"; do
    case "$arg" in
      -b|--initial-branch|--initial-branch=*)
        echo "error: unknown option \`${arg#--}'" >&2
        exit 129 ;;
    esac
  done
  exec "$real_git" -c init.defaultBranch=master "$@"
fi
exec "$real_git" "$@"
STUB
chmod +x "$stubbin/git"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1

# Guard: the stub really does emulate the old behaviour.
probe="$TESTDIR/probe"
PATH="$stubbin:$PATH" git init -q "$probe" || exit 1
if [ "$(git -C "$probe" symbolic-ref HEAD)" != "refs/heads/master" ]; then
  echo "FAIL: precondition — stubbed git init did not ignore init.defaultBranch" >&2
  exit 1
fi

report="$TESTDIR/report.txt"
PATH="$stubbin:$PATH" bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status" "the run must not depend on git 2.28 init features"
assert_contains "$report" "repository: created" "the tool created the repository"
head_ref="$(git -C "$work" symbolic-ref HEAD 2>/dev/null)"
if [ "$head_ref" != "refs/heads/trunk" ]; then
  echo "FAIL: expected HEAD refs/heads/trunk on an emulated pre-2.28 git, got '${head_ref}'" >&2
  exit 1
fi
