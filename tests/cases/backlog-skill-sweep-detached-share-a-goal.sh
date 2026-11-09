#!/usr/bin/env bash
# Scenario (mechanical half only): Entries detached together share a goal.
# Requirement: Sweep performs the archive step's re-read.
# Change: propose-a-workstream-for-entries-sharing-a-goal (backlog-maintenance,
# MODIFIED).
#
# SPECIFIED: an entry sweep is to set to the README's absent value is first read
# with the entries already carrying it, and with the others the same sweep
# detaches, for a goal they share, as record reads them, a workstream being
# proposed where they share one that takes more than one change.
# DERIVED (structure, as backlog-skill-sweep.sh assumes): read from the section
# under a heading naming `sweep`.
# DERIVED (wording, design.md decision 5): [read-together] and [as-record] are
# the phrase decision 5 adds to the archived-workstream group. [kept-words]
# holds that the words backlog-skill-sweep-detaches-by-read.sh pins in the same
# sentence survive, as decision 5 states.
#
# Not asserted: that sweep finds three entries sharing a goal and names them
# under a draft Goal. Conduct (design.md decision 10).
#
# Static read (third situation); every scan is discriminated by a mutant. Red at
# authoring on [read-together] and [as-record] (state 1 on real content); goes
# green as task 2.1 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
scan require "$S" sweep read-together 'those to be set to it read together with the entries already carrying it for a shared goal'
scan require "$S" sweep as-record 'for a shared goal, as [*]*record[*]* reads them'
scan require "$S" sweep kept-words 're-pointed by the same read, or set to the readme.s absent value only where it finds none'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Sweep

Where the change's archive archives a workstream, those naming that workstream, to be detached as `docs/workstreams/AGENTS.md` directs: re-pointed by the same read, or set to the README's absent value only where it finds none, those to be set to it read together with the entries already carrying it for a shared goal, as **record** reads them.

## Audit

Fans out.
FIXTURE

scan_run "$fixture"
