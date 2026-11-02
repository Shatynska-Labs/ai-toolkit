#!/usr/bin/env bash
# Scenario: The seeded block makes `none` the end of a search. Also the revised
# statement of "A project without a backlog receives the seeded file": the rule
# on `workstream`.
# Requirement: The backlog's rules are written where none exist.
# Change: match-backlog-entries-to-a-workstream (project-bootstrap, MODIFIED).
#
# SPECIFIED: the entry shape states that the Goal and Not in scope of every open
# workstream are read, that the entry takes the one whose Goal it serves, and
# that `none` is written only after that read finds none or on the operator's
# word; an entry recorded by a change in a workstream takes it unless it serves
# another goal or that workstream's Not in scope leaves it out.
# DERIVED (wording, design.md decision 1): each scan is one phrase of that text.
#
# Not asserted: that a session makes the read. Conduct; no scan can hold it.
#
# Executes the tool and reads its output; every scan is discriminated by a
# mutant. Red at authoring on [read-every-open], [takes-served], [none-after]
# and [not-in-scope] (state 1: the tool runs and the rule states none of them);
# goes green as task 1.1 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

R=docs/backlog/AGENTS.md

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

scan require "$R" "" read-every-open 'reading the goal and not in scope of every open workstream'
scan require "$R" "" takes-served 'takes the open workstream whose goal it serves'
# shellcheck disable=SC2016 # backticks are literal markdown in the regex
scan require "$R" "" none-after '`none` is written only after that read finds none, or on the operator'
scan require "$R" "" not-in-scope 'unless it serves another goal or that workstream.s not in scope leaves it out'

mkdir -p "$TESTDIR/fixture/docs/backlog"
cat > "$TESTDIR/fixture/$R" <<'FIXTURE'
# Backlog

An entry recorded by a change in a workstream takes that workstream unless it serves another goal or that workstream's Not in scope leaves it out. Otherwise it takes the open workstream whose Goal it serves, found by reading the Goal and Not in scope of every open workstream; `none` is written only after that read finds none, or on the operator's word.
FIXTURE

seed_and_check
