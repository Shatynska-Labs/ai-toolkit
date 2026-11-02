#!/usr/bin/env bash
# Scenarios (mechanical half only): An entry falling outside its workstream is
# re-pointed; Entries naming a workstream being archived (as revised).
# Requirement: Sweep performs the archive step's re-read.
# Change: match-backlog-entries-to-a-workstream (backlog-maintenance, MODIFIED).
#
# SPECIFIED: an unplaced entry, or an entry naming a workstream being archived, is
# detached by the same read of the open workstreams' Goals record makes: re-pointed
# by it, and set to the README's absent value only where that read finds none.
# DERIVED (structure, as backlog-skill-sweep.sh assumes): read from the section
# under a heading naming `sweep`.
# DERIVED (wording, design.md decision 4): the two groups' phrases. That Not in
# scope is what leaves an entry out is not scanned here: the skill says "detached
# as `docs/workstreams/AGENTS.md` directs", and workstreams-block-placing-settled.sh
# holds the rule that says so.
#
# Not asserted: which workstream sweep proposes for a given entry. Conduct.
#
# Static read (third situation); every scan is discriminated by a mutant. Red at
# authoring (state 1 on real content); goes green as task 2.1 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
scan require "$S" sweep unplaced-by-read 'same read of the open workstreams. goals'
scan require "$S" sweep archived-to-be-detached 'naming that workstream, to be detached as'
scan require "$S" sweep archived-by-read 're-pointed by the same read, or set to the readme.s absent value only where it finds none'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Sweep

Where the change's archive archives a workstream, those naming that workstream, to be detached as `docs/workstreams/AGENTS.md` directs: re-pointed by the same read, or set to the README's absent value only where it finds none.

Each unplaced entry is placed among the steps or detached, by the same read of the open workstreams' Goals **record** makes.

## Audit

Fans out.
FIXTURE

scan_run "$fixture"
