#!/usr/bin/env bash
# Scenario: Waits on holds only names.
# Requirement: A backlog is seeded where none exists.
# Change: one-file-per-backlog-entry (project-bootstrap, MODIFIED).
#
# SPECIFIED: the README directs a named change into `waits_on` and a person's
# answer, as a double-quoted condition, into `waits_for`: waits_on lists the
# names of entries or changes; waits_for is present only where the entry
# waits on something that is not a name, the condition — an answer, an access
# grant, an event.
# DERIVED (operationalisation): a sentence naming waits_on and names; one
# naming waits_for and "not a name"; one naming waits_for and an answer or an
# access grant. The double quoting is backlog-dir-seeded-frontmatter-flat.sh's.
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

scan require "$R" "" waits-on-names 'waits_on[^.]*names'
scan require "$R" "" waits-for-not-a-name 'waits_for[^.]*not a name|not a name[^.]*waits_for'
scan require "$R" "" waits-for-answer 'waits_for[^.]*(answer|access grant)|(answer|access grant)[^.]*waits_for'

fixture_readme <<'FIXTURE'
# Backlog

`waits_on` is a list of the names of entries or changes that must be archived first. `waits_for`, present only where the entry waits on something that is not a name, is the condition that can be checked: a person's answer, an access grant, an event.
FIXTURE

seed_and_check
