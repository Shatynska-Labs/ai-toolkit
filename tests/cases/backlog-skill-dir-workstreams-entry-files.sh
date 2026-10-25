#!/usr/bin/env bash
# Scenarios (mechanical half only): A step's status comes from the
# repository (an entry file in docs/backlog/); A waiting step is not next
# (its entry's `waits_on`).
# Requirement: Workstreams reports where each workstream stands.
# Change: one-file-per-backlog-entry (backlog-maintenance, MODIFIED).
#
# SPECIFIED: a step is recorded where `docs/backlog/` holds an entry of its
# name, the backlog's entry files read from the freshly fetched trunk; next
# is the first planned step, or recorded with an entry pick would list as
# takeable — unwaited or its wait satisfied, and not parked.
# DERIVED (operationalisation): in the workstreams section, "entry file" or
# `docs/backlog/`, and "unwaited" or `waits_on`. The rest of the operation is
# backlog-skill-workstreams-operation.sh's, unchanged.
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

scan require "$S" workstreams entry-files 'entry files?|docs/backlog/'
scan require "$S" workstreams wait-read 'unwaited|waits_on'

cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Workstreams

A step is recorded where an entry file of its name is in the backlog.
Next is the first planned step, or a recorded one whose entry is unwaited.
FIXTURE

scan_run "$fixture"
