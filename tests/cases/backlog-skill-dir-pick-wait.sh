#!/usr/bin/env bash
# Scenarios (mechanical half only): A blocked entry is not offered; A wait
# already satisfied but not updated; A condition not shown to hold blocks;
# A parked entry is not offered as takeable (its `parked_until`); Pick
# narrowed to files (carried from the superseded backlog-skill-pick.sh,
# with its split-by-kind and writes-nothing scans).
# Requirement: Pick lists what can be taken now.
# Change: one-file-per-backlog-entry (backlog-maintenance, MODIFIED).
#
# SPECIFIED: an entry is unwaited where its `waits_on` is empty and it
# carries no `waits_for`; its wait is satisfied where every name in
# `waits_on` is an archived change and, where it carries `waits_for`, the
# condition is shown to hold; a `waits_for` the session cannot show to hold
# is treated as waiting; a parked entry is listed apart with its
# `parked_until`; entries naming each other in `design_with` are listed
# together.
# DERIVED (operationalisation): in the pick section, `unwaited`,
# `waits_on` with "empty", `waits_for`, "satisf", `archived`, "shown" or
# "show" with "hold", `parked_until`, `design_with`.
#
# Static read (third situation); every scan is discriminated by a mutant. Red
# until task 3.2 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog/references"

scan require "$S" pick unwaited 'unwaited'
scan require "$S" pick waits-on-empty 'waits_on[^.]*empty|empty[^.]*waits_on'
scan require "$S" pick waits-for 'waits_for'
scan require "$S" pick satisfied 'satisf'
scan require "$S" pick archived 'archived'
scan require "$S" pick shown-to-hold 'shown? to hold|show[^.]*holds?'
scan require "$S" pick parked-until 'parked_until'
scan require "$S" pick design-with 'design_with'
scan require "$S" pick split-by-kind '(^|[^a-z])fix([^a-z]|$)'
scan require "$S" pick narrowed-to-paths 'path'
scan require "$S" pick writes-nothing '(writes?|edits?) nothing|read-only|without (writing|editing)'

cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Pick

An entry is unwaited where its `waits_on` is empty and it carries no `waits_for`.
Its wait is satisfied where every name in `waits_on` is an archived change and any `waits_for` is shown to hold.
List a parked entry apart, with its `parked_until`.
List entries naming each other in `design_with` together.
Split the list into fix and change.
Given paths, narrow the list to entries naming one of them.
Pick writes nothing.

## Close

Deletes the entry.
FIXTURE

scan_run "$fixture"
