#!/usr/bin/env bash
# Scenarios (mechanical half only): A name already used by an archived
# change; Record writes one file.
# Requirement: Record writes an entry the file can be relied on for.
# Change: one-file-per-backlog-entry (backlog-maintenance, MODIFIED).
#
# SPECIFIED: record writes one entry as its own file, `docs/backlog/<name>.md`;
# before writing it checks the name against the entry files in docs/backlog/,
# the open and archived change directories and the branches, and refuses a
# name already used or `readme` in any case.
# DERIVED (structure, as backlog-skill-record.sh): read from the section under
# the heading naming `record`; terms `<name>.md`, `entry files`, `archive`,
# `branch`, `readme`, and one file ("one file", "its own file", "a file of
# its own").
#
# Not asserted: that a used name is refused and another asked for, and that
# no other file changes. Conduct; verified by reading.
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

scan require "$S" record writes-name-md '<name>[.]md'
scan require "$S" record one-file 'one file|its own file|a file of its own'
scan require "$S" record name-vs-entry-files 'entry files'
scan require "$S" record name-vs-archive 'archive'
scan require "$S" record name-vs-branches 'branch'
scan require "$S" record refuses-readme 'readme'

cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Record

Write the entry as one file, `docs/backlog/<name>.md`.
Check the name against the entry files in `docs/backlog/`.
Check it against the open and archived change directories.
Check it against the project's branches.
Never use `readme`, in any case.

## Pick

Lists takeable entries.
FIXTURE

scan_run "$fixture"
