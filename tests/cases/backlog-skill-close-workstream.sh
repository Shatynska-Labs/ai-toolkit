#!/usr/bin/env bash
# Scenario (mechanical half only): A closed entry was a workstream's step.
# Requirement: Close removes an entry and every reference to it.
# Change: add-workstreams (backlog-maintenance, MODIFIED).
#
# SPECIFIED: where an open workstream's steps name the closed entry, close
# names that workstream and the step, and does not edit the workstream file.
# DERIVED (structure, as backlog-skill-close.sh assumes): read from the
# section under a heading naming `close`.
# DERIVED (operationalisation), each on one sentence: `workstream` with
# `step`; and the file left alone ("not/never ... edit ... workstream",
# "edit(s) only ... backlog", or "workstream file ... unchanged").
#
# Not asserted: that close names the workstream and step when run. Conduct.
#
# Static read: red until the step lands; every scan is discriminated by a
# mutant in scan_discriminate.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
scan require "$S" close ws-names-step 'workstream[^.]*step|step[^.]*workstream'
scan require "$S" close ws-file-unedited '(not|never)[^.]*edit[^.]*workstream|edits? only[^.]*backlog|workstream file[^.]*unchanged'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Close

Delete the entry and update every entry naming it in Waits on or Design with.
Where an open workstream's steps name the entry, name that workstream and the step.
Close edits only the backlog.

## Sweep

Re-read at archive.
FIXTURE

scan_run "$fixture"
