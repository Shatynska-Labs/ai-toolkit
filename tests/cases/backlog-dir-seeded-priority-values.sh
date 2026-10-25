#!/usr/bin/env bash
# Scenario: Priority's values and default are stated.
# Requirement: A backlog is seeded where none exists.
# Change: one-file-per-backlog-entry (project-bootstrap, MODIFIED).
#
# SPECIFIED: the README states priority's three values `high`, `normal` and
# `parked`; that `high` needs evidence of harm happening now; that `parked`
# needs a condition that can be checked, in `parked_until`; and that an entry
# without the key is `normal`.
# DERIVED (operationalisation): the three values backticked in one sentence,
# in that order; "harm happening now"; `parked_until` in a sentence naming a
# condition; "can be checked"; a sentence with "without" and `priority`
# ending at `normal`.
#
# Executes the tool; every scan is discriminated on the fixture. Red until
# tasks 1.1 and 1.2 land (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

R=docs/backlog/README.md

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
    echo "FAIL: target absent — project-init seeded no docs/backlog/README.md" >&2
  fi
  [ "$st" -eq 0 ] || exit 1
}

# shellcheck disable=SC2016 # backticks and $ are literal text in a pattern or fixture
scan require "$R" "" three-values '`high`[^.]*`normal`[^.]*`parked`'
scan require "$R" "" high-evidence 'harm happening now'
scan require "$R" "" parked-until-condition 'parked_until[^.]*condition|condition[^.]*parked_until'
scan require "$R" "" checkable 'can be checked'
scan require "$R" "" absent-normal 'without[^.]*priority[^.]*normal'

fixture_readme <<'FIXTURE'
# Backlog

`priority` is `high`, `normal` or `parked`. `high` needs evidence of harm happening now. `parked_until`, present only on a parked entry, is the condition that can be checked under which it becomes worth taking. An entry without `priority` is `normal`.
FIXTURE

seed_and_check
