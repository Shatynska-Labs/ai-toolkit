#!/usr/bin/env bash
# Requirement text (no scenario of its own): "Where the initial branch cannot
# be set after the repository was created, the run SHALL end in ERROR with a
# reason naming that step."
# A PATH stub makes `git symbolic-ref` fail and passes everything else to the
# real git. This assumes the step is performed with `git symbolic-ref`, per
# design.md Decision 2 and tasks.md 1.1 — see test-plan.md.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

export HOME="$TESTDIR/home" XDG_CONFIG_HOME="$TESTDIR/xdg" GIT_CONFIG_NOSYSTEM=1
unset GIT_CONFIG_GLOBAL GIT_CONFIG_SYSTEM GIT_CONFIG GIT_CONFIG_COUNT GIT_DIR GIT_WORK_TREE
mkdir -p "$HOME" "$XDG_CONFIG_HOME"

real_git="$(command -v git)"
if [ -z "$real_git" ]; then
  echo "FAIL: precondition — git not found" >&2
  exit 1
fi

stubbin="$TESTDIR/stubbin"
mkdir -p "$stubbin"
cat > "$stubbin/git" <<STUB
#!/usr/bin/env bash
for arg in "\$@"; do
  if [ "\$arg" = "symbolic-ref" ]; then
    echo "stubbed git: deliberate symbolic-ref failure" >&2
    exit 1
  fi
done
exec "$real_git" "\$@"
STUB
chmod +x "$stubbin/git"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1

report="$TESTDIR/report.txt"
PATH="$stubbin:$PATH" bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 1 "$status" "ERROR when the initial branch cannot be set"
assert_contains "$report" "Outcome: ERROR"
if ! grep -i '^Reason:' "$report" | grep -qi 'branch'; then
  echo "FAIL: expected the Reason line to name the initial-branch step (mention 'branch')" >&2
  exit 1
fi
