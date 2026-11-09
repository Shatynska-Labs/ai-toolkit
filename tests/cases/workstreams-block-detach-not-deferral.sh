#!/usr/bin/env bash
# Scenario: A detach is not a deferral. Also the revised statement of "A project
# without a workstream register receives the seeded file" on detaching.
# Requirement: A workstream register is seeded where none exists.
# Change: propose-a-workstream-for-entries-sharing-a-goal (project-bootstrap,
# MODIFIED).
#
# SPECIFIED: before clearing an entry to `none`, detaching reads it with the
# entries already naming `none` and the others detached in the same edit for a
# goal they share, proposing a workstream for it; each detached entry is
# re-pointed, cleared after that read, or deleted on a ground the backlog's
# rules give; a note deferring the read does not detach it.
# DERIVED (wording, design.md decision 2): each scan is one phrase of the two
# sentences decision 2 adds. [clears-last] is already stated and held because
# decision 2 adds after it rather than replacing it (also pinned by
# workstreams-block-placing-settled.sh).
#
# Not asserted: that a session detaching an abandoned workstream's entries makes
# the read and leaves no deferral note. Conduct (design.md decision 10).
#
# Executes the tool and reads its output; every scan is discriminated by a
# mutant. Red at authoring on every scan but [clears-last] (state 1: the tool
# runs and the rule states none of the others); goes green as task 1.1 lands.
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

# shellcheck disable=SC2016 # backticks are literal markdown in the regexes
{
scan require "$R" "" clears-last 'clears it to `none` only where there is none'
scan require "$R" "" read-with-none 'read it together with the entries already naming `none`'
scan require "$R" "" read-with-batch 'and with the others detached in the same edit, for a goal they share'
scan require "$R" "" proposes-as-above 'proposing a workstream for it as above'
scan require "$R" "" three-ends 're-pointed, cleared after that read, or deleted on a ground the backlog.s rules give'
scan require "$R" "" no-deferral 'a note deferring the read does not detach it'
}

mkdir -p "$TESTDIR/fixture/docs/workstreams"
cat > "$TESTDIR/fixture/$R" <<'FIXTURE'
# Workstreams

Detaching re-points it to another open workstream whose Goal it serves and whose Not in scope does not leave it out, and clears it to `none` only where there is none. Before clearing one, read it together with the entries already naming `none`, and with the others detached in the same edit, for a goal they share, proposing a workstream for it as above. Each detached entry is re-pointed, cleared after that read, or deleted on a ground the backlog's rules give; a note deferring the read does not detach it.
FIXTURE

seed_and_check
