#!/usr/bin/env bash
# Scenario: The seeded block settles what placing means. Also the seeded half of
# "Placing one entry owes nothing for the others", and the revised statements of
# "A project without a workstream register receives the seeded file".
# Requirement: A workstream register is seeded where none exists.
# Change: match-backlog-entries-to-a-workstream (project-bootstrap, MODIFIED).
#
# SPECIFIED: the block states that an entry is placed when recorded or left for
# the archive with the reason said; that placing a recorded entry is not the edit
# at which the others fall due; that detaching re-points to another open
# workstream whose Goal is served and whose Not in scope admits it, and clears
# only where there is none; and that only a step's own name places a change or
# an entry.
# DERIVED (wording, design.md decision 2): each scan is one phrase of that text.
#
# Not asserted: that a session places or detaches anything. Conduct.
#
# Executes the tool and reads its output; every scan is discriminated by a
# mutant. Red at authoring on every scan but [latest-at-archive], which the rule
# already states and is held here because the revised text must keep it (state
# 1: the tool runs and the rule states none of the others); goes green as task
# 1.2 lands.
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

scan require "$R" "" placed-when-recorded 'place an entry among the steps when it is recorded'
scan require "$R" "" left-with-reason 'say that it is left for the archive and why'
scan require "$R" "" others-not-due 'next edit of the workstream other than one placing a recorded entry'
scan require "$R" "" latest-at-archive 'at the latest at the archive of a change in it'
scan require "$R" "" detach-repoints 'detaching re-points it to another open workstream whose goal it serves and whose not in scope does not leave it out'
# shellcheck disable=SC2016 # backticks are literal markdown in the regex
scan require "$R" "" clears-last 'clears it to `none` only where there is none'
scan require "$R" "" own-name-only 'names a change or an entry only by its own name'
scan require "$R" "" numbered-step-name 'the backticked name a numbered step begins with'
scan require "$R" "" mention-places-nothing 'a mention in a step.s description, in context or in decisions places nothing'

mkdir -p "$TESTDIR/fixture/docs/workstreams"
cat > "$TESTDIR/fixture/$R" <<'FIXTURE'
# Workstreams

A change or a backlog entry may name the workstream it serves before any step names it. Place an entry among the steps when it is recorded, or say that it is left for the archive and why. Place each such change or entry among the steps, or detach it, at the next edit of the workstream other than one placing a recorded entry, and at the latest at the archive of a change in it. Detaching re-points it to another open workstream whose Goal it serves and whose Not in scope does not leave it out, and clears it to `none` only where there is none. A step names a change or an entry only by its own name, the backticked name a numbered step begins with; a mention in a step's description, in Context or in Decisions places nothing.
FIXTURE

seed_and_check
