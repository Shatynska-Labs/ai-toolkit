#!/usr/bin/env bash
# Scenario (mechanical half only): Entries naming a workstream being archived
# (as revised: re-pointed or set to the file's absent value).
# Requirement: Sweep performs the archive step's re-read.
# Change: list-the-entry-fields (backlog-maintenance, MODIFIED).
#
# SPECIFIED: sweep presents every entry naming the archived workstream, to be
# re-pointed or set to the file's absent value as docs/workstreams/README.md
# directs.
# DERIVED (structure, as backlog-skill-sweep.sh assumes): read from the
# section under a heading naming `sweep`.
# DERIVED (operationalisation): one sentence carries `re-point` (or
# `repoint`) and "absent value" or `none`; and no sentence directs setting an
# entry to `nothing` (design.md decision 4: the skill writes the file's value,
# not a fixed word).
#
# Not asserted: that sweep presents those entries. Conduct.
#
# Static read (third situation): red until task 2.1 lands; every scan is
# discriminated by a mutant in scan_discriminate.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
# shellcheck disable=SC2016 # backticks are literal markdown in the regex
scan require "$S" sweep repoint-or-absent 're-?point[^.]*(absent value|`none`)|(absent value|`none`)[^.]*re-?point'
# shellcheck disable=SC2016 # backticks are literal markdown in the regex and specimen
scan forbid "$S" sweep no-set-to-nothing 'set (it |them )?to `nothing`' 'Present each to be re-pointed or set to `nothing`.'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Sweep

Find entries naming files the change touched.
Where the change's archive archives a workstream, also find the entries naming that workstream.
Present each to be re-pointed or set to the file's absent value, as the README directs.

## Audit

Fans out.
FIXTURE

scan_run "$fixture"
