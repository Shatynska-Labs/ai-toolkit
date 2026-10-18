#!/usr/bin/env bash
# Scenario (mechanical half only): A closed entry was another's only wait.
# Requirement: Close removes an entry and every reference to it.
# Change: add-backlog-skill (backlog-maintenance, ADDED).
#
# SPECIFIED: close deletes the entry and updates every entry naming it in
# Waits on or Design with.
# DERIVED (structure, Q1): read from the section under a heading naming
# `close`; both field names appear there.
#
# Not asserted: that the edit is one edit and that the other entry ends up
# takeable. Conduct; verified by reading.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
scan require "$S" close references-in-waits-on 'waits on'
scan require "$S" close references-in-design-with 'design with'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Close

Delete the entry. In the same edit, update every entry naming it in Waits on.
Also update every entry naming it in Design with.

## Sweep

Re-read at archive.
FIXTURE

scan_run "$fixture"
