#!/usr/bin/env bash
# Scenario: An absent value reads as its field.
# Requirement: A backlog is seeded where none exists.
# Change: one-file-per-backlog-entry (project-bootstrap, MODIFIED).
#
# SPECIFIED: the README gives the empty waits_on and design_with as `[]` and
# the absent workstream as `none`, and states the meaning of each key's
# absence.
# DERIVED (operationalisation): `[]` backticked; "empty list"; sentences with
# "without" naming waits_on, design_with, and workstream with none. The
# priority half of "each key's absence" is backlog-dir-seeded-priority-values.sh.
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

# shellcheck disable=SC2016 # backticks and $ are literal text in a pattern or fixture
scan require "$R" "" empty-literal '`[[][]]`'
scan require "$R" "" empty-list 'empty list'
scan require "$R" "" waits-on-absent 'without[^.]*waits_on'
scan require "$R" "" design-with-absent 'without[^.]*design_with'
scan require "$R" "" workstream-none 'without[^.]*workstream[^.]*none'

fixture_readme <<'FIXTURE'
# Backlog

A list is written inline, and empty as `[]`. An entry without `waits_on` or `design_with` has the empty list; one without `workstream` is `none`.
FIXTURE

seed_and_check
