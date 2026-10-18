#!/usr/bin/env bash
# Scenario: The tool configures no remote. (project-bootstrap: A wrapper
# connects a remote only from a URL the operator supplies.)
#
# "The tool itself SHALL NOT configure a remote or push." The remote step is
# the wrapper's; the tool is deterministic and asks nothing.
#
# This case executes the tool, so a pass reports its behaviour: the tool
# exists before this change and the change leaves it unchanged, so a pass on
# first run is the expected result, not an alarm.
#
# SPECIFIED: a run in an empty directory reaches SUCCESS and the created
# repository has no remote. DERIVED: "no remote" is read as `git remote`
# succeeding with empty output and the repository's own config carrying no
# `[remote` section; the second is this author's guard against a remote
# written somewhere `git remote` would not list.
#
# Not asserted: that nothing was pushed. With no remote configured there is
# nowhere a push could have gone that this case can observe.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
report="$TESTDIR/report.txt"

bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status" "empty directory should succeed"
assert_contains "$report" "Outcome: SUCCESS" "reports success"
# Vacuity guard: `git remote` in a directory that is not a repository fails,
# and its empty output would otherwise read as "no remote".
assert_file "$work/.git/HEAD" "git repository initialized"

remotes="$(git -C "$work" remote)"
remote_status=$?
assert_exit 0 "$remote_status" "git remote must run in the created repository"
if [ -n "$remotes" ]; then
  echo "FAIL: the tool configured a remote: $remotes" >&2
  echo "      The remote step is the wrapper's — it needs the operator's URL and a network." >&2
  exit 1
fi

if grep -q -F -- '[remote' "$work/.git/config" 2>/dev/null; then
  echo "FAIL: the created repository's config carries a remote section" >&2
  exit 1
fi
