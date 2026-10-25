#!/usr/bin/env bash
# Scenario (mechanical half only): A closed entry was another's only wait.
# Requirement: Close removes an entry and every reference to it.
# Change: one-file-per-backlog-entry (backlog-maintenance, MODIFIED).
#
# SPECIFIED: close deletes the entry's file and, in the same edit, removes
# its name from the `waits_on` and `design_with` of every other entry naming
# it; an entry whose only wait it was is left with `waits_on: []`.
# DERIVED (operationalisation): in the close section, a sentence with
# "delet" and "file", `waits_on`, `design_with`, and the empty list `[]`.
# The workstream half is backlog-skill-close-workstream.sh's, unchanged.
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

scan require "$S" close deletes-file 'delet[^.]*file|file[^.]*delet'
scan require "$S" close waits-on 'waits_on'
scan require "$S" close design-with 'design_with'
scan require "$S" close empty-list '[[][]]'

cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Close

Delete the entry's file, and remove its name from the `waits_on` and `design_with` of every other entry, leaving an emptied list as `[]`.

## Sweep

Re-reads at archive.
FIXTURE

scan_run "$fixture"
