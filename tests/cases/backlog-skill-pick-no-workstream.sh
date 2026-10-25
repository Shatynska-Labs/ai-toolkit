#!/usr/bin/env bash
# Scenario (mechanical half only): An entry naming no workstream is grouped
# apart.
# Requirement: Pick lists what can be taken now.
# Change: list-the-entry-fields (backlog-maintenance, MODIFIED).
#
# SPECIFIED: entries naming no workstream — the file's absent value, or an
# earlier `nothing` — are grouped as before, not as a workstream named `none`
# and not as unplaced.
# DERIVED (structure, as backlog-skill-pick.sh assumes): read from the
# section under a heading naming `pick`.
# DERIVED (operationalisation), each on one sentence: "no workstream" with
# "absent value" or `none`; "no workstream" with `nothing`.
#
# Not asserted: that pick does not list such an entry as a workstream named
# `none` or as unplaced. Conduct; verified by reading.
#
# Static read (third situation): red until task 2.1 lands; every scan is
# discriminated by a mutant in scan_discriminate.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
# shellcheck disable=SC2016 # backticks are literal markdown in the regex
scan require "$S" pick no-ws-absent-value 'no workstream[^.]*(absent value|`none`)|(absent value|`none`)[^.]*no workstream'
# shellcheck disable=SC2016 # backticks are literal markdown in the regex
scan require "$S" pick no-ws-earlier-nothing 'no workstream[^.]*`nothing`|`nothing`[^.]*no workstream'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Record

Writes one entry.

## Pick

List the entries whose Waits on is `nothing`, split into fix and change.
Entries naming one workstream are listed together as one group.
Entries naming no workstream, whether by the file's absent value or by an earlier `nothing`, are grouped as before.

## Close

Deletes an entry.
FIXTURE

scan_run "$fixture"
