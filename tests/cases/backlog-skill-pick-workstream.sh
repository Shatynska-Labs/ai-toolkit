#!/usr/bin/env bash
# Scenarios (mechanical half only): Pick lists a workstream's entries in step
# order; A high step leads its workstream's group; An unplaced entry is shown
# under its workstream.
# Requirement: Pick lists what can be taken now.
# Change: add-workstreams (backlog-maintenance, MODIFIED).
#
# SPECIFIED: where the file's shape names Workstream, pick groups without
# changing what is takeable; entries naming one workstream are listed
# together as a group; inside it `high` entries first, then the others in the
# workstream's step order, then unplaced entries.
# DERIVED (structure, as backlog-skill-pick.sh assumes): read from the section
# under a heading naming `pick`.
# DERIVED (operationalisation), each on one sentence: `workstream` with
# `group`; "step order"; `high` before "step order"; `unplaced`; and
# takeability unchanged ("takeab..." with "unchanged" or "waits on alone", or
# "without changing what is takeable").
#
# Not asserted: the placement of a group by its highest-priority member, of a
# Design with group spanning workstreams, and that pick actually orders as
# stated. Conduct; verified by reading.
#
# Static read: red until the step lands; every scan is discriminated by a
# mutant in scan_discriminate.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
scan require "$S" pick ws-grouped 'workstream[^.]*group|group[^.]*workstream'
scan require "$S" pick ws-step-order 'step order'
scan require "$S" pick ws-high-then-step-order 'high[^a-z][^.]*step order'
scan require "$S" pick ws-unplaced 'unplaced'
scan require "$S" pick ws-takeability-unchanged 'takeab[a-z]*[^.]*(unchanged|waits on alone)|(unchanged|waits on alone)[^.]*takeab|without changing what is takeable'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Record

Writes one entry.

## Pick

List the entries whose Waits on is `nothing`, split into fix and change.
Where the file's shape names Workstream, group without changing what is takeable, which Waits on alone decides.
Entries naming one workstream are listed together as one group.
Inside the group, `high` entries come first, then the others in step order.
Then list entries naming it without being a step, as unplaced.

## Close

Deletes an entry.
FIXTURE

scan_run "$fixture"
