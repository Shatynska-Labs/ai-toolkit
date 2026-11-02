#!/usr/bin/env bash
# Scenarios: A finished workstream is archived; An abandoned workstream is
# archived, not deleted (their "dealt with" half, as the statements revise it).
# Requirement: A workstream register is seeded where none exists.
# Change: match-backlog-entries-to-a-workstream (project-bootstrap, MODIFIED).
#
# SPECIFIED: on archiving, a step not done and still wanted is first recorded as
# a backlog entry detached from the workstream, and every backlog entry still
# naming it is re-pointed or cleared by detaching it.
# DERIVED (wording, design.md decision 2): the two phrases below, and the
# superseded phrase "backlog entry naming no workstream" being gone. That phrase
# is what wrote `none` without the search.
#
# Executes the tool and reads its output; every scan is discriminated by a
# mutant. Red at authoring on all three scans (state 1: the tool runs and the
# rule still states the superseded text); goes green as task 1.2 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

R=docs/workstreams/AGENTS.md

# Local arrangement (test-plan.md, Missing shared arrangement: seed_and_check).
# Discriminates every scan on the fixture, runs project-init in a fresh
# directory, then holds the seeded file to the scans.
seed_and_check() {
  local work="$TESTDIR/work" st
  scan_discriminate "$TESTDIR/fixture" || exit 1
  mkdir -p "$work"
  (cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
  scan_check "$work"
  st=$?
  [ "$st" -ne 2 ] || echo "FAIL: target absent — project-init seeded no $R" >&2
  [ "$st" -eq 0 ] || exit 1
}

scan require "$R" "" step-entry-detached 'recorded as a backlog entry detached from it'
scan require "$R" "" entries-by-detaching 're-point or clear every backlog entry still naming it, by detaching it'
scan forbid "$R" "" no-unexamined-none 'backlog entry naming no workstream' 'It is first recorded as a backlog entry naming no workstream.'

mkdir -p "$TESTDIR/fixture/docs/workstreams"
cat > "$TESTDIR/fixture/$R" <<'FIXTURE'
# Workstreams

Remove each step not done: it is first recorded as a backlog entry detached from it if it is not yet in flight. Then re-point or clear every backlog entry still naming it, by detaching it.
FIXTURE

seed_and_check
