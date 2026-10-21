#!/usr/bin/env bash
# Scenarios (mechanical half only): A change fulfils a parked entry's
# condition; A change removes a high entry's evidence.
# Requirement: Sweep performs the archive step's re-read.
# Change: add-a-backlog-priority (backlog-maintenance, MODIFIED).
#
# SPECIFIED: sweep searches for entries whose parked condition the change
# fulfils and entries whose `high` evidence it removes, and presents each with
# its Priority proposed as the file directs.
# DERIVED (structure, Q1): read from the section under a heading naming
# `sweep`, as backlog-skill-sweep.sh assumes.
# DERIVED (operationalisation), each on one line of that section: `parked`
# with `condition`; `fulfil`; `high` with `evidence`; `remov`; `priority` with
# `file directs` or `as the file`.
#
# Not asserted: that sweep finds such entries and presents them. Conduct;
# verified by reading.
#
# Static read: red until the step lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
scan require "$S" sweep parked-condition 'parked[^.]*condition|condition[^.]*parked'
scan require "$S" sweep condition-fulfilled 'fulfil'
scan require "$S" sweep high-evidence 'high[^a-z][^.]*evidence|evidence[^.]*[^a-z]high[^a-z]'
scan require "$S" sweep evidence-removed 'remov'
scan require "$S" sweep priority-as-file-directs 'priority[^.]*(file directs|as the file)|(file directs|as the file)[^.]*priority'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Sweep

Find entries naming files the change touched.
Find entries whose parked condition the change fulfils.
Find entries whose `high` evidence the change takes away by removing the harm.
Present each with its Priority proposed as the file directs.

## Audit

Fans out.
FIXTURE

scan_run "$fixture"
