#!/usr/bin/env bash
# Scenario (mechanical half only): Pick meets an entry with no Kind.
# Requirement: Entries in an older shape are reported, not rewritten.
# Change: add-backlog-skill (backlog-maintenance, ADDED).
#
# SPECIFIED: an entry lacking a field the file's shape names is reported as
# `unclassified` where that field decides the outcome.
# DERIVED (operationalisation): the token `unclassified` appears in SKILL.md.
# Whole file rather than the pick section: the requirement binds every
# operation where a missing field decides the outcome, not pick alone.
#
# Not asserted: that pick lists such an entry rather than omitting it, that
# no value is invented, and that rewriting waits for the operator's word.
# Conduct; verified by reading.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

scan require skills/backlog/SKILL.md "" reports-unclassified 'unclassified'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/skills/backlog/SKILL.md" <<'FIXTURE'
# backlog

An entry missing Kind or Waits on is listed as unclassified.
FIXTURE

scan_run "$fixture"
