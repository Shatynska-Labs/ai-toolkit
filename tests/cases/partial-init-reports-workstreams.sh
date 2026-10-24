#!/usr/bin/env bash
# Scenario: A partially initialized directory is completed, not refused — as
# revised by add-workstreams, whose concern list gains "workstream register
# present". Requirement: Each concern is checked independently and is safe to
# repeat (project-bootstrap, MODIFIED).
#
# existing-git-no-openspec.sh and partial-init-reports-backlog.sh cover the
# other halves and are left as they are. SPECIFIED: with a repository present
# and no register, the register concern is completed and its outcome reported
# on its own line, separately from the others.
# DERIVED (token): `workstreams: created` (design.md decision 12).
#
# Executes the tool; no fixture owed. Red until the concern lands (state 2).
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
assert_contains "$report" "workstreams: created" "register concern completed and reported separately"
assert_file "$work/docs/workstreams/README.md" "register completed"
if [ "$(grep -c '^workstreams:' "$report")" -ne 1 ]; then
  echo "FAIL: the report does not carry exactly one workstreams line" >&2
  cat "$report" >&2
  exit 1
fi
