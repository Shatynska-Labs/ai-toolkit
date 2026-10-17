#!/usr/bin/env bash
# Scenario: A partially initialized directory is completed, not refused — as
# revised by seed-the-backlog, whose concern list gains "backlog present".
#
# existing-git-no-openspec.sh covers the repository and specification-tooling
# halves and is left as it is. SPECIFIED: with a repository present and no
# backlog, the backlog concern is completed and its outcome reported on its
# own line, separately from the others.
# DERIVED (token): `backlog: created` is design.md's report line.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
git init -q
git config user.email "t@t.com"
git config user.name "t"
echo "x" > tracked.txt
git add . && git commit -q -m "initial"

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status" "should complete the missing concerns"
assert_contains "$report" "repository: already present" "repository concern reported separately"
assert_contains "$report" "backlog: created" "backlog concern completed and reported separately"
assert_file "$work/docs/backlog.md" "backlog completed"
