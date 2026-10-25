#!/usr/bin/env bash
# Scenarios (mechanical half only): An entry waiting on the swept change; A
# change fulfils a parked entry's condition; A change removes a high entry's
# evidence (as revised: "as the README directs").
# Requirement: Sweep performs the archive step's re-read.
# Change: one-file-per-backlog-entry (backlog-maintenance, MODIFIED).
#
# SPECIFIED: sweep searches entries whose `waits_on` names the change and
# entries whose `waits_for` or `parked_until` it fulfils, presents an entry
# waiting on the swept change with the name proposed removed from its
# `waits_on`, proposes priority as the README directs, and updates each
# entry's file as the README directs.
# DERIVED (operationalisation): in the sweep section, `waits_on`,
# `waits_for`, `parked_until`, "remov", and "readme" with "directs".
#
# Static read (third situation); every scan is discriminated by a mutant. Red
# until task 3.2 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog/references"

scan require "$S" sweep waits-on 'waits_on'
scan require "$S" sweep waits-for 'waits_for'
scan require "$S" sweep parked-until 'parked_until'
scan require "$S" sweep name-removed 'remov'
scan require "$S" sweep readme-directs 'readme[^.]*directs'

cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Sweep

Find entries whose `waits_on` names the change, and propose the name removed.
Find entries whose `waits_for` or `parked_until` it fulfils.
Update each entry's file as the README directs.

## Audit

Verifies every entry.
FIXTURE

scan_run "$fixture"
