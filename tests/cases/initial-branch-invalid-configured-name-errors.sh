#!/usr/bin/env bash
# Requirement text: "Where the initial branch cannot be set after the
# repository was created, the run SHALL end in ERROR with a reason naming
# that step." The configured init.defaultBranch is `-x`, which git rejects as
# a branch name. A modern git's own `git init` rejects it too, so a stub
# emulating pre-2.28 git (init ignores init.defaultBranch) is used: the
# repository is then created, and the initial-branch step is what must fail.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

export HOME="$TESTDIR/home" XDG_CONFIG_HOME="$TESTDIR/xdg" GIT_CONFIG_NOSYSTEM=1
unset GIT_CONFIG_GLOBAL GIT_CONFIG_SYSTEM GIT_CONFIG GIT_CONFIG_COUNT GIT_DIR GIT_WORK_TREE
mkdir -p "$HOME" "$XDG_CONFIG_HOME"
git config --global init.defaultBranch -x || exit 1

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

# Guards: the stubbed init succeeds despite the invalid setting, and git
# rejects `-x` as a branch name.
probe="$TESTDIR/probe"
if ! PATH="$stubbin:$PATH" git init -q "$probe"; then
  echo "FAIL: precondition — stubbed git init did not succeed" >&2
  exit 1
fi
if git check-ref-format --branch -x >/dev/null 2>&1; then
  echo "FAIL: precondition — git accepts '-x' as a branch name" >&2
  exit 1
fi

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1

report="$TESTDIR/report.txt"
PATH="$stubbin:$PATH" bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 1 "$status" "ERROR when the configured initial branch cannot be set"
assert_contains "$report" "Outcome: ERROR"
if ! grep -i '^Reason:' "$report" | grep -qi 'branch'; then
  echo "FAIL: expected the Reason line to name the initial-branch step (mention 'branch')" >&2
  exit 1
fi
