#!/usr/bin/env bash
# Scenario: A fix is distinguished from a change by what it owes.
# Requirement: A backlog is seeded where none exists.
# Change: one-file-per-backlog-entry (project-bootstrap, MODIFIED).
#
# SPECIFIED: the README defines `kind` so that only `change` is available to
# an entry owing a specification delta: `fix` owes no delta, needs no
# decision from the operator, and fits one review sitting; otherwise
# `change`.
# DERIVED (operationalisation): one sentence names `fix` and the delta, one
# names `fix` and the decision, one names `fix` and the sitting (they may be
# the same sentence), and a sentence gives `change` as the otherwise.
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

scan require "$R" "" fix-no-delta 'fix[^.]*delta'
scan require "$R" "" fix-no-decision 'fix[^.]*decision'
scan require "$R" "" fix-one-sitting 'fix[^.]*sitting'
scan require "$R" "" otherwise-change 'otherwise[^.]*change'

fixture_readme <<'FIXTURE'
# Backlog

`kind` is `fix` only where the entry owes no specification delta, needs no decision from the operator, and is small enough to review in one sitting; otherwise it is `change`.
FIXTURE

seed_and_check
