#!/usr/bin/env bash
# Scenarios (mechanical half only): Record defaults Priority; Record parks an
# entry only on the operator's word.
# Requirement: Record writes an entry the file can be relied on for.
# Change: add-a-backlog-priority (backlog-maintenance, MODIFIED).
#
# SPECIFIED: where the file's shape names Priority, record sets it to the
# file's default — `normal` in the seeded file — unless the session or the
# operator states the evidence or the condition the file requires, and writes
# `high` or `parked` only once the operator confirms it.
# DERIVED (structure, unresolved question Q1 in test-plan.md): the record
# operation sits under a heading naming `record`, as backlog-skill-record.sh
# assumes, and the record scans read that section.
# DERIVED (operationalisation): the default is one line carrying `priority`
# and `default`; `normal` appears in the section; `evidence` and
# `condition` share a line (a lone `evidence` already appears there, in the
# Design with step, so it would assert nothing);
# each of `high` and `parked` shares a line with `confirm`; and the
# conditional application is a line anywhere in SKILL.md carrying `where`,
# `shape` or `file`, and `priority` in that order or the reverse (tasks.md 2.1:
# each step applies only where the file's shape names Priority, which may be
# stated once rather than per operation).
#
# Not asserted: that an entry recorded with nothing stated is written
# `normal`, and that a parked value is proposed and not written until
# confirmed. Conduct at run time; verified by reading.
#
# Static read: red until the step lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
scan require "$S" record priority-default 'priority[^.]*default|default[^.]*priority'
scan require "$S" record default-normal 'normal'
scan require "$S" record evidence-or-condition 'evidence[^.]*condition|condition[^.]*evidence'
scan require "$S" record high-on-confirm 'high[^a-z][^.]*confirm|confirm[^.]*[^a-z]high[^a-z]'
scan require "$S" record parked-on-confirm 'parked[^.]*confirm|confirm[^.]*parked'
scan require "$S" "" applies-where-named 'where[^.]*(shape|file)[^.]*priority|priority[^.]*where[^.]*(shape|file)'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Before any operation

Each Priority step applies only where the file's shape names Priority.

## Record

Check the name against the backlog's headings.
Set Priority to the file's default, `normal` in the seeded file.
Write another value only once the session or operator states the evidence or the condition it needs.
Write `high` only once the operator confirms it.
Write `parked` only once the operator confirms it.
Set Re-checked to today.

## Pick

Lists takeable entries.
FIXTURE

scan_run "$fixture"
