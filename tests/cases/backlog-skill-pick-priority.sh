#!/usr/bin/env bash
# Scenarios (mechanical half only): A parked entry is not offered as takeable;
# A parked entry whose condition holds; A parked entry still waiting; High
# entries come first.
# Requirement: Pick lists what can be taken now.
# Change: add-a-backlog-priority (backlog-maintenance, MODIFIED).
#
# SPECIFIED: `high` entries are listed first, a Design with group placed by
# its highest-priority member; a parked entry is not listed as takeable but
# apart, under Parked, with its condition; a parked entry whose condition
# holds is listed as takeable once updated, naming what fulfilled it; Waits on
# governs first, so a parked entry still waiting is not offered at all.
# DERIVED (structure, Q1): read from the section under a heading naming
# `pick`, as backlog-skill-pick.sh assumes.
# DERIVED (operationalisation), each on one line of that section: `high`
# with `first` or `before`; `highest`; `parked` with `not ... takeable`;
# `parked` with `apart` or `under`; `parked` with `condition`; `condition`
# with `holds`, `fulfil` or `met` and `once updated`; `fulfil`; `parked` with
# `waiting`, `waits on` or `blocked`.
#
# Not asserted: the satisfied wait named beside a parked entry, and that pick
# actually orders, omits or lists apart as stated. Conduct; verified by
# reading.
#
# Static read: red until the step lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
scan require "$S" pick high-first 'high[^a-z][^.]*(first|before)|(first|before)[^.]*[^a-z]high[^a-z]'
scan require "$S" pick group-by-highest 'highest'
scan require "$S" pick parked-not-takeable 'parked[^.]*not[^.]*takeable|not[^.]*takeable[^.]*parked'
scan require "$S" pick parked-listed-apart '(apart|under)[^.]*parked|parked[^.]*(apart|under)'
scan require "$S" pick parked-with-condition 'parked[^.]*condition|condition[^.]*parked'
scan require "$S" pick condition-holds-once-updated 'condition[^.]*(holds|fulfil|met)[^.]*once updated|once updated[^.]*condition'
scan require "$S" pick names-what-fulfilled 'fulfil'
scan require "$S" pick waits-on-governs '(waiting|waits on|blocked)[^.]*parked|parked[^.]*(waiting|waits on|blocked)'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Record

Writes one entry.

## Pick

List the entries whose Waits on is `nothing`, split into fix and change.
Where the file's shape names Priority, list `high` entries first, placing a Design with group by its highest-priority member.
A parked entry is not takeable.
List it apart under Parked, with its condition.
Where its condition already holds, list it as takeable once updated, naming what fulfilled it.
Waits on governs first: a parked entry still waiting is not offered at all.
Pick writes nothing.

## Close

Deletes an entry.
FIXTURE

scan_run "$fixture"
