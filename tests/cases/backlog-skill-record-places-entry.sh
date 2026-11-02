#!/usr/bin/env bash
# Scenarios (mechanical half only): A recorded entry is placed or left with a
# reason; Placing one entry owes nothing for the others; Record writes one file
# (as revised: the one other file it may edit).
# Requirement: Record writes an entry the file can be relied on for.
# Change: match-backlog-entries-to-a-workstream (backlog-maintenance, MODIFIED).
#
# SPECIFIED: where record writes an open workstream's name, it adds the entry to
# that workstream's steps in the same edit, asking the operator where in the
# order, or says the entry is left for the archive and why; the workstream file
# whose steps take the entry is the one other file it may edit.
# DERIVED (structure): read from the section under a heading naming `record`.
# DERIVED (wording, design.md decision 3): each require scan is one phrase.
# DERIVED (operationalisation): "edits the steps for that entry alone" is read as
# the section directing nothing about other unplaced entries.
#
# Not asserted: that a run edits exactly those files, or that it touches no other
# step. Conduct. The rule's half of the exemption is in
# workstreams-block-placing-settled.sh.
#
# Static read (third situation); every scan is discriminated by a mutant. Red at
# authoring on every require scan (state 1 on real content); goes green as task
# 2.1 lands. [not-the-others] passes today: its target carries the property.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
scan require "$S" record places-in-steps 'add it to that workstream.s steps in the same edit'
scan require "$S" record asks-order 'asking the operator where in the order'
scan require "$S" record or-says-why 'say that it is left for the archive and why'
scan require "$S" record one-other-file 'the workstream file whose steps take it is the one other file you may edit'
scan forbid "$S" record not-the-others '(other|remaining) unplaced entr' 'Place every other unplaced entry as well.'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Record

Write one entry file; the workstream file whose steps take it is the one other file you may edit.

10. **Place.** Where the entry names an open workstream, add it to that workstream's steps in the same edit, as the workstreams README directs, asking the operator where in the order. Where you do not, say that it is left for the archive and why.

## Pick

Lists takeable entries.
FIXTURE

scan_run "$fixture"
