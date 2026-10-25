#!/usr/bin/env bash
# Scenario (mechanical half only): An entry names an unknown name; also the
# revised parts of The report is not applied unasked (the edit is across the
# entry files).
# Requirement: Audit verifies every entry independently and changes nothing
# without the operator. Change: one-file-per-backlog-entry
# (backlog-maintenance, MODIFIED).
#
# SPECIFIED: the agents say, for an entry carrying `waits_for`, whether the
# condition now holds, and where a name in `waits_on` or `design_with` is
# neither an entry nor a change, open or archived; the skill applies the
# approved cleanup as one edit across the entry files.
# DERIVED (operationalisation): references/audit.md names `waits_for` and an
# unknown name ("unknown name" or "neither an entry nor a change"); SKILL.md's
# audit section names "entry files".
#
# Static read (third situation); every scan is discriminated by a mutant. Red
# until tasks 3.2 and 3.3 land.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
A=skills/backlog/references/audit.md
fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog/references"

scan require "$A" "" waits-for-holds 'waits_for'
scan require "$A" "" unknown-name 'unknown name|neither an entry nor a change'
scan require "$S" audit entry-files 'entry files'

cat > "$fixture/$A" <<'FIXTURE'
# audit brief

For an entry carrying `waits_for`, say whether the condition now holds.
Say where a name in `waits_on` or `design_with` is neither an entry nor a change.
FIXTURE
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Audit

Apply the approved cleanup as one edit across the entry files.

## Workstreams

Reports where each stands.
FIXTURE

scan_run "$fixture"
