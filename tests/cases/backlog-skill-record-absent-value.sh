#!/usr/bin/env bash
# Scenarios (mechanical half only): Record carries the change's workstream;
# Record refuses a workstream that is not open (as revised: it asks for an
# open workstream or the file's absent value); An overlapping entry exists
# (the Design with value written when no candidate is confirmed).
# Requirement: Record writes an entry the file can be relied on for.
# Change: list-the-entry-fields (backlog-maintenance, MODIFIED).
#
# SPECIFIED: record writes into Design with only confirmed candidates, or the
# file's absent value — `none` in the seeded file; where the file's shape
# names Workstream it sets Workstream to the workstream of the change the
# session is in, unless another goal or none is stated, and otherwise to the
# file's absent value; it writes only a name an open workstream carries, or
# that absent value; where the README exists, its name check also covers
# workstream names, open and archived.
# DERIVED (structure, as backlog-skill-record.sh assumes): read from the
# section under a heading naming `record`.
# DERIVED (operationalisation), each on one sentence: `workstream` with
# `default`; "open workstream"; `workstream` with `archived`; `workstream`
# with "absent value"; "design with" with "absent value"; the token `none`
# in the section (design.md decision 4: record names the file's absent value,
# `none` in the seeded file); and, anywhere in SKILL.md, the gate
# "where ... (shape|file) ... workstream".
# The four scans backlog-skill-record-workstream.sh also makes are repeated
# here so the coverage stands if that case, listed obsolete for its
# `nothing` scan, is removed.
#
# Not asserted: that record writes the file's own word where its preamble
# still says `nothing`, and refuses and asks on a name no open workstream
# carries. Conduct; verified by reading.
#
# Static read (third situation): red until task 2.1 lands; every scan is
# discriminated by a mutant in scan_discriminate.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
scan require "$S" record ws-default 'workstream[^.]*default|default[^.]*workstream'
scan require "$S" record ws-open-only 'open workstream'
scan require "$S" record ws-name-check-archived 'workstream[^.]*archived|archived[^.]*workstream'
scan require "$S" "" ws-applies-where-named 'where[^.]*(shape|file)[^.]*workstream|workstream[^.]*where[^.]*(shape|file)'
scan require "$S" record ws-absent-value 'workstream[^.]*absent value|absent value[^.]*workstream'
scan require "$S" record dw-absent-value 'design with[^.]*absent value|absent value[^.]*design with'
# shellcheck disable=SC2016 # backticks are literal markdown in the regex
scan require "$S" record names-none '`none`'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Before any operation

Each Workstream step applies only where the file's shape names Workstream.

## Record

Check the name against the backlog's headings.
Where the register exists, the name check also covers workstream names, open and archived.
Present each overlapping entry as a candidate, and write into Design with only the confirmed ones, or else the file's absent value.
Set Workstream by default to the workstream of the change the session is in.
Where the entry serves another goal or none, set the Workstream to that goal or to the file's absent value.
The absent value is the one the file states, `none` in the seeded file.
Write only a name an open workstream carries.

## Pick

Lists takeable entries.
FIXTURE

scan_run "$fixture"
