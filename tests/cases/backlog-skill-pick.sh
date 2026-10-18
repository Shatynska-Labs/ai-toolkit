#!/usr/bin/env bash
# Scenarios (mechanical half only): A blocked entry is not offered; A wait
# already satisfied but not updated; Pick narrowed to files.
# Requirement: Pick lists what can be taken now.
# Change: add-backlog-skill (backlog-maintenance, ADDED).
#
# SPECIFIED: pick lists entries whose Waits on is `nothing`, split into `fix`
# and `change`, grouped by Design with; narrows to given paths; lists apart an
# entry whose wait names an archived change; writes nothing.
# DERIVED (structure, Q1): read from the section under a heading naming
# `pick`. DERIVED (operationalisation): "Waits on is nothing" is one line
# carrying both `waits on` and `nothing`; the satisfied wait is recognised by
# `archived`, the narrowing by `path`, writing nothing by `writes nothing`,
# `edits nothing`, `read-only` or `without writing/editing`.
#
# Not asserted: that a blocked entry is actually left out, and that the
# satisfied one is listed apart naming the change. Conduct; verified by
# reading.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
scan require "$S" pick takeable-is-waits-on-nothing 'waits on[^.]*nothing|nothing[^.]*waits on'
scan require "$S" pick split-by-kind 'fix'
scan require "$S" pick grouped-by-design-with 'design with'
scan require "$S" pick satisfied-wait-archived 'archived'
scan require "$S" pick narrowed-to-paths 'path'
scan require "$S" pick writes-nothing '(writes?|edits?) nothing|read-only|without (writing|editing)'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Record

Writes one entry.

## Pick

List the entries whose Waits on is `nothing`.
Split them into fix entries and change entries.
List together the entries that name each other in Design with.
List apart an entry whose wait names an archived change, as takeable once updated.
Given a set of path arguments, narrow the list to entries naming one.
Pick writes nothing and opens no change.
FIXTURE

scan_run "$fixture"
