#!/usr/bin/env bash
# Scenario: The seeded file states how an entry leaves parked and high.
# Requirement: A backlog is seeded where none exists.
# Change: one-file-per-backlog-entry (project-bootstrap, MODIFIED).
#
# SPECIFIED: a parked entry is not folded into another change before its
# condition holds; a parked entry whose condition holds becomes `normal`, or
# `high` with evidence; a `high` entry whose evidence no longer holds becomes
# `normal`; the archive updates the entries it unparked.
# DERIVED (operationalisation): one pattern per statement, listed below.
#
# Executes the tool; every scan is discriminated on the fixture. Red until
# tasks 1.1 and 1.2 land (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

R=docs/backlog/AGENTS.md

# Local arrangement (test-plan.md, Missing shared arrangement: seeded-output
# scan wrappers). static-scan.sh's scan_run checks $TOOLKIT_ROOT only; these
# point the same scans at the tree project-init writes.
#
# fixture_readme: writes stdin as the fixture tree's README.
fixture_readme() {
  mkdir -p "$TESTDIR/fixture/docs/backlog"
  cat > "$TESTDIR/fixture/$R"
}
# seed_and_check: discriminates every scan on the fixture, runs project-init
# in a fresh directory, then holds the seeded README to the scans.
seed_and_check() {
  local work="$TESTDIR/work" st
  scan_discriminate "$TESTDIR/fixture" || exit 1
  mkdir -p "$work"
  (cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
  scan_check "$work"
  st=$?
  if [ "$st" -eq 2 ]; then
    echo "FAIL: target absent — project-init seeded no docs/backlog/AGENTS.md" >&2
  fi
  [ "$st" -eq 0 ] || exit 1
}

scan require "$R" "" parked-not-folded 'not folded[^.]*condition holds'
scan require "$R" "" parked-becomes-normal 'condition holds[^.]*normal'
scan require "$R" "" or-high-with-evidence 'high`? with evidence'
scan require "$R" "" high-lapses-to-normal 'no longer holds[^.]*normal'
scan require "$R" "" archive-unparked 'unparked'

fixture_readme <<'FIXTURE'
# Backlog

A parked entry is not folded into another change before its condition holds. A parked entry whose condition holds becomes `normal`, or `high` with evidence. A `high` entry whose evidence no longer holds becomes `normal`.

When a change is archived, update the entries it unblocked, unparked or made stale.
FIXTURE

seed_and_check
