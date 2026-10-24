#!/usr/bin/env bash
# Scenarios (mechanical half only): A step's status comes from the
# repository; A step in two sources; The next step is named; A waiting step is
# not next; Every step done; Unplaced entries are shown; A change opened under
# another name is surfaced.
# Requirement: Workstreams reports where each workstream stands.
# Change: add-workstreams (backlog-maintenance, ADDED).
#
# SPECIFIED: for each open workstream the operation lists the steps with a
# status derived as the README states — done, in flight, recorded, planned —
# from the freshly fetched trunk and from branches and pull requests; names as
# next the first step that is planned, or recorded with an entry pick would
# list as takeable and not parked, and does not read list order as a wait;
# lists unplaced entries and open changes whose proposals name the
# workstream, the changes beside the planned steps; says the Done when is to
# be checked when every step is done; reports one workstream when given a
# name; writes nothing and archives nothing; says so where the forge cannot
# be reached.
# DERIVED (structure, unresolved question Q3): the operation sits under a
# heading naming `workstreams`, and these scans read that section.
# DERIVED (operationalisation), each a word or one sentence of the section:
# the four status names; `readme`; `trunk`; `next`; `takeable`;
# `parked`; order with not/never and wait/gate; `unplaced`; `proposal`;
# `unplaced` with `planned`; "done when"; "given a name" or "alone";
# "write(s) nothing" or "read-only"; forge unreachable; not/never ... archive.
#
# Not asserted: that the operation derives the statuses the scenarios name
# from a given repository. Conduct; verified by reading and the trigger check.
#
# Static read: red until the operation lands; every scan is discriminated by
# a mutant in scan_discriminate.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
scan require "$S" workstreams status-done '(^|[^a-z])done([^a-z]|$)'
scan require "$S" workstreams status-in-flight 'in flight'
scan require "$S" workstreams status-recorded 'recorded'
scan require "$S" workstreams status-planned 'planned'
scan require "$S" workstreams from-readme 'readme'
scan require "$S" workstreams from-trunk 'trunk'
scan require "$S" workstreams names-next '(^|[^a-z])next([^a-z]|$)'
scan require "$S" workstreams next-takeable 'takeable'
scan require "$S" workstreams next-not-parked 'parked'
scan require "$S" workstreams order-not-a-wait 'order[^.]*(not|never)[^.]*(wait|gate)|(not|never)[^.]*(wait|gate)[^.]*order'
scan require "$S" workstreams unplaced 'unplaced'
scan require "$S" workstreams unplaced-open-changes 'proposal'
scan require "$S" workstreams beside-planned 'unplaced[^.]*planned|planned[^.]*unplaced'
scan require "$S" workstreams done-when 'done when'
scan require "$S" workstreams one-by-name 'given a name|alone'
scan require "$S" workstreams read-only 'writes? nothing|read-only'
scan require "$S" workstreams forge-unreachable 'cannot be reached|unreachable|cannot reach'
scan require "$S" workstreams archives-nothing '(not|never)[^.]*archive'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Audit

Fans out.

## Workstreams

For each open workstream, list its steps with each one's status, derived as the README states.
In the seeded file a step is done, then in flight, then recorded, then planned, read from the freshly fetched trunk and from branches and pull requests.
Name as next the first step that is planned, or recorded with an entry pick would list as takeable and not parked.
List order is not a wait.
List the backlog entries naming the workstream without being a step as unplaced.
Also list each open change whose proposal names it.
Show each unplaced change beside the planned steps.
Where every step is done, say that the Done when is to be checked.
Given a name, report that workstream alone.
This operation writes nothing.
Where the forge cannot be reached, say so.
It does not open a change or archive a workstream.
FIXTURE

scan_run "$fixture"
