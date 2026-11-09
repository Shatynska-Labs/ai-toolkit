#!/usr/bin/env bash
# Scenario (mechanical half only): No shared goal is said.
# Requirement: Record writes an entry the file can be relied on for.
# Change: propose-a-workstream-for-entries-sharing-a-goal (backlog-maintenance,
# MODIFIED).
#
# SPECIFIED: record says in its answer what it proposed, or that no shared goal
# was found.
# DERIVED (structure, as backlog-skill-record.sh assumes): read from the section
# under a heading naming `record`.
# DERIVED (wording, design.md decision 4): the scan is that sentence's phrase.
#
# Not asserted: that a session's answer says it. Conduct (design.md decision 10).
#
# Static read (third situation); the scan is discriminated by a mutant. Red at
# authoring (state 1 on real content); goes green as task 2.1 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
scan require "$S" record says-none-found 'say in your answer what you proposed, or that no shared goal was found'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Record

Where they share one, propose opening a workstream for it. Say in your answer what you proposed, or that no shared goal was found.

## Pick

Lists takeable entries.
FIXTURE

scan_run "$fixture"
