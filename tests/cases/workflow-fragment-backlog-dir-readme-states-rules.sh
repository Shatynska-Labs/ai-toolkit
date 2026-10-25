#!/usr/bin/env bash
# Scenarios (mechanical half only): Entry rules are read from the backlog,
# not the fragment; A backlog entry is cited by name; A deferral outlives the
# change that recorded it.
# Requirement: A second change surfacing in a session is recorded in the
# backlog. Change: one-file-per-backlog-entry (session-workflow, MODIFIED).
#
# SPECIFIED: the fragment states that the backlog's README carries the entry
# rules (design.md decision 9: "the file itself states" becomes "its README
# states"), and gives the reason the backlog sits outside any change: a note
# kept inside a change is archived with it.
# DERIVED (operationalisation): the paragraph naming `docs/backlog/` and
# "identified changes" carries `readme` with "states" or "carries" and
# "entry", and "archived with it" or "outside any change".
#
# Static read (third situation); every scan is discriminated by a mutant. Red
# until task 3.1 lands (state 2: no paragraph names docs/backlog/).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

line_select 'docs/backlog/'
line_select 'identified changes'
line_scan require readme-states-rules 'readme[^.]*(states|carries)[^.]*entr'
line_scan require outside-any-change 'outside any change|archived with it'

fixture="$TESTDIR/fragment.md"
cat > "$fixture" <<'FIXTURE'

`docs/backlog/` holds identified changes, each the separate proposed change the scope rule calls for, recorded rather than opened. It sits outside any change, because a note kept inside one is archived with it. Its README states how an entry is written and when it is deleted.
FIXTURE

line_run "$fixture" rules/development-workflow.md
