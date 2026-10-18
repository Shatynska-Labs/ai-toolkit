#!/usr/bin/env bash
# Scenarios (mechanical half only): A name already used by an archived
# change; An overlapping entry exists.
# Requirement: Record writes an entry the file can be relied on for.
# Change: add-backlog-skill (backlog-maintenance, ADDED).
#
# SPECIFIED: record checks the name against the backlog's headings, the
# archived (and open) change directories and the branches; it presents
# overlapping entries as Design with candidates and writes only those
# confirmed; it sets Re-checked.
# DERIVED (structure, unresolved question Q1 in test-plan.md): the record
# operation sits under its own heading naming `record`, and these terms are
# read from that section — `heading`, `archive`, `branch`, `design with`,
# `confirm`, `re-checked`.
#
# Not asserted: that a used name is refused and another asked for, and that
# an unconfirmed candidate is left out. Conduct at run time; verified by
# reading.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
scan require "$S" record name-vs-headings 'heading'
scan require "$S" record name-vs-archive 'archive'
scan require "$S" record name-vs-branches 'branch'
scan require "$S" record design-with-candidates 'design with'
scan require "$S" record candidates-confirmed 'confirm'
scan require "$S" record rechecked 're-checked'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Record

Check the name against the backlog's headings.
Check it against open and archived change directories.
Check it against the project's branches.
Present overlapping entries as Design with candidates.
Write only those the operator confirms share a design.
Set Re-checked to today.

## Pick

Lists takeable entries.
FIXTURE

scan_run "$fixture"
