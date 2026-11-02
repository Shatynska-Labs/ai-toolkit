#!/usr/bin/env bash
# Scenarios (mechanical half only): Record carries the change's workstream (as
# revised); An entry the change's workstream rules out finds another; The absent
# value follows the read.
# Requirement: Record writes an entry the file can be relied on for.
# Change: match-backlog-entries-to-a-workstream (backlog-maintenance, MODIFIED).
#
# SPECIFIED: record reads the Goal and Not in scope of every open workstream
# before setting `workstream`, keeps or replaces the change's workstream by that
# read, asks the operator where more than one Goal is served, takes what the
# operator states over that reading, and says in its answer the workstream chosen
# for each entry and why.
# DERIVED (structure, as backlog-skill-record.sh assumes): read from the section
# under a heading naming `record`.
# DERIVED (wording, design.md decision 3): each scan is one phrase of step 6, and
# the superseded trigger, a session's own statement of another goal, is gone
# (design.md decision 1: a session's own statement is no exception).
#
# Not asserted: that a session really reads the Goals, judges rightly which one an
# entry serves, or writes the absent value only where none is served. Conduct; a
# scan shows the skill directs the read, never that it happened.
#
# Static read (third situation); every scan is discriminated by a mutant. Red at
# authoring on every require scan and on [no-session-word] (state 1 on real
# content); goes green as task 2.1 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
scan require "$S" record reads-every-open 'read the goal and not in scope of every open workstream'
# shellcheck disable=SC2016 # backticks are literal markdown in the regex
scan require "$S" record readme-selects 'keep or replace that default as the readme.s `workstream` key directs'
scan require "$S" record asks-where-several 'asking the operator where more than one goal is served'
scan require "$S" record operator-wins 'what the operator states the entry serves wins over this reading'
scan require "$S" record says-choice 'say in your answer which workstream you chose for each entry and why'
scan forbid "$S" record no-session-word 'session or the operator states the entry serves' 'Write another workstream where the session or the operator states the entry serves another goal.'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Record

6. **Workstream.** The default is the open workstream the change you are in serves, as its proposal or a workstream's steps name it. Read the Goal and Not in scope of every open workstream, and keep or replace that default as the README's `workstream` key directs, asking the operator where more than one Goal is served. What the operator states the entry serves wins over this reading. Write only a name an open workstream carries, or the README's absent value, `none` in the seeded README. Say in your answer which workstream you chose for each entry and why.

## Pick

Lists takeable entries.
FIXTURE

scan_run "$fixture"
