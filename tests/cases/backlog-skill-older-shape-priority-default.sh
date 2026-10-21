#!/usr/bin/env bash
# Scenario (mechanical half only): Pick meets an entry with no Priority.
# Requirement: Entries in an older shape are reported, not rewritten.
# Change: add-a-backlog-priority (backlog-maintenance, MODIFIED).
#
# SPECIFIED: where the file itself states what an entry without a field
# means, the skill reads the entry as the file states and does not report it
# as unclassified for that field.
# DERIVED (operationalisation): one line of SKILL.md carries both `default`
# and `unclassified` (tasks.md 2.1: "a field the file gives a default for is
# read as that default"), read from the whole file as
# backlog-skill-older-shape-unclassified.sh reads `unclassified`.
#
# Not asserted: that pick lists such an entry as `normal`. Conduct; verified
# by reading.
#
# Static read: red until the step lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

scan require skills/backlog/SKILL.md "" default-not-unclassified 'default[^.]*unclassified|unclassified[^.]*default'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/skills/backlog/SKILL.md" <<'FIXTURE'
# backlog

## Entries in an older shape

An entry missing Kind or Waits on is listed as unclassified.
A field the file gives a default for is read as that default, never as unclassified.
FIXTURE

scan_run "$fixture"
