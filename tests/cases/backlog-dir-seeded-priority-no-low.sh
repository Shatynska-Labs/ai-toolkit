#!/usr/bin/env bash
# Scenario: The seeded file offers no low priority.
# Requirement: A backlog is seeded where none exists.
# Change: one-file-per-backlog-entry (project-bootstrap, MODIFIED).
#
# SPECIFIED: the README offers no `low` value.
# DERIVED (operationalisation): the word `low` does not occur as a word; the
# README must also name `priority`, so the scan reads the file that states
# the values rather than an empty one.
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

scan require "$R" "" names-priority 'priority'
# shellcheck disable=SC2016 # backticks and $ are literal text in a pattern or fixture
scan forbid "$R" "" no-low '(^|[^a-z])low([^a-z-]|$)' 'An entry not worth taking now is `low`.'

fixture_readme <<'FIXTURE'
# Backlog

`priority` is `high`, `normal` or `parked`; follow the rules below.
FIXTURE

seed_and_check
