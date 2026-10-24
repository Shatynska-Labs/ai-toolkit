#!/usr/bin/env bash
# Scenario (mechanical half only): Entries naming a workstream being archived.
# Requirement: Sweep performs the archive step's re-read.
# Change: add-workstreams (backlog-maintenance, MODIFIED).
#
# SPECIFIED: where the change's archive archives a workstream, sweep searches
# for entries naming that workstream and presents each to be re-pointed or
# set to `nothing` as `docs/workstreams/README.md` directs.
# DERIVED (structure, as backlog-skill-sweep.sh assumes): read from the
# section under a heading naming `sweep`.
# DERIVED (operationalisation), each on one sentence: `workstream` with
# `archiv`; `re-point` or `repoint`.
#
# Not asserted: that sweep finds and presents those entries. Conduct.
#
# Static read: red until the step lands; every scan is discriminated by a
# mutant in scan_discriminate.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
scan require "$S" sweep ws-archived 'workstream[^.]*archiv|archiv[^.]*workstream'
scan require "$S" sweep ws-repoint 're-?point'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Sweep

Find entries naming files the change touched.
Where the change's archive archives a workstream, also find the entries naming that workstream.
Present each to be re-pointed or set to `nothing`, as the README directs.

## Audit

Fans out.
FIXTURE

scan_run "$fixture"
