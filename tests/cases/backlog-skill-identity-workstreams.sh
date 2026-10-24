#!/usr/bin/env bash
# Scenario (mechanical half only): Invoked from a consuming project — as
# revised: the description states six operations.
# Requirement: The skill operates on the project it is invoked in.
# Change: add-workstreams (backlog-maintenance, MODIFIED).
#
# SPECIFIED: the description states the sixth operation, workstreams, and the
# phrasings that reach it. (The other five and the distinctions from
# project-init and OpenSpec stay asserted by backlog-skill-identity.sh.)
# DERIVED (design.md decision 11): the phrasings are read as the description
# naming `workstream` and one of "stand" or "in flight" ("where does the x
# workstream stand", "what's in flight"); SKILL.md does not say "five operations"
# (a count the revised requirement replaces).
#
# Not asserted: that those phrasings route to the skill. The trigger check
# (tasks.md 3.2) establishes that, not a scan.
#
# Static read: red until the description lands; every scan is discriminated by
# a mutant in scan_discriminate.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
scan require "$S" @description op-workstreams 'workstream'
scan require "$S" @description workstream-phrasing 'stand|in flight'
scan forbid "$S" "" no-five 'five operations' 'Its five operations are record, pick, close, sweep and audit.'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
---
name: backlog
description: >
  Use to record an entry, pick work, close an entry, sweep at archive, audit
  the backlog, or report where a workstream stands and what's in flight.
metadata:
  tags: [project-lifecycle]
---

# backlog
FIXTURE

scan_run "$fixture"
