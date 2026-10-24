#!/usr/bin/env bash
# Scenarios (mechanical half only): Record carries the change's workstream;
# Record refuses a workstream that is not open.
# Requirement: Record writes an entry the file can be relied on for.
# Change: add-workstreams (backlog-maintenance, MODIFIED).
#
# SPECIFIED: where the file's shape names Workstream, record sets it to the
# workstream of the change the session is in, unless another goal or none is
# stated, and otherwise `nothing`; it writes only a name an open workstream
# carries, or `nothing`; where the README exists, its name check also covers
# workstream names, open and archived.
# DERIVED (structure, as backlog-skill-record.sh assumes): read from the
# section under a heading naming `record`.
# DERIVED (operationalisation), each on one sentence: `workstream` with
# `default`; `workstream` with `nothing`; "open workstream"; `workstream`
# with `archived`; and, anywhere in SKILL.md, the gate "where ... (shape|
# file) ... workstream".
#
# Not asserted: that record writes the change's workstream, and refuses and
# asks on a name no open workstream carries. Conduct; verified by reading.
#
# Static read: red until the step lands; every scan is discriminated by a
# mutant in scan_discriminate.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
scan require "$S" record ws-default 'workstream[^.]*default|default[^.]*workstream'
scan require "$S" record ws-or-nothing 'workstream[^.]*nothing|nothing[^.]*workstream'
scan require "$S" record ws-open-only 'open workstream'
scan require "$S" record ws-name-check-archived 'workstream[^.]*archived|archived[^.]*workstream'
scan require "$S" "" ws-applies-where-named 'where[^.]*(shape|file)[^.]*workstream|workstream[^.]*where[^.]*(shape|file)'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Before any operation

Each Workstream step applies only where the file's shape names Workstream.

## Record

Check the name against the backlog's headings.
Where the register exists, the name check also covers workstream names, open and archived.
Set Workstream by default to the workstream of the change the session is in.
Where the entry serves another goal or none, set the Workstream to that or `nothing`.
Write only a name an open workstream carries.

## Pick

Lists takeable entries.
FIXTURE

scan_run "$fixture"
