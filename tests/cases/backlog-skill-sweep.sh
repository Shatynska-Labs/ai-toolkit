#!/usr/bin/env bash
# Scenarios (mechanical half only): An entry finished without being named;
# Sweep after a squash merge; Sweep after the record has landed.
# Requirement: Sweep performs the archive step's re-read.
# Change: add-backlog-skill (backlog-maintenance, ADDED).
#
# SPECIFIED: sweep finds entries by what the change touched, taken from the
# change's merged pull requests on the forge, falling back — where the forge
# cannot be reached — to the change's specification deltas and the files its
# design and tasks name; run after the record has landed, it says the edit is
# delivered as work too small to be a change.
# DERIVED (structure, Q1): read from the section under a heading naming
# `sweep`. DERIVED (operationalisation): `touch`; `merged ... pull request`
# or `gh pr list` or `merged PRs`; a fallback (`fall back`, `fallback`,
# `cannot be reached`, `unreachable`); `delta`; `too small`.
#
# Deliberately untested: "SHALL NOT take them from the branch's diff". A scan
# forbidding `git diff ...` would also fail a compliant SKILL.md that names
# the command in order to rule it out. Verified by reading.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
scan require "$S" sweep by-what-it-touched 'touch'
scan require "$S" sweep from-merged-prs 'merged[^.]*pull request|gh pr list|merged prs?'
scan require "$S" sweep forge-fallback 'fall back|falls back|fallback|cannot be reached|unreachable'
scan require "$S" sweep fallback-deltas 'delta'
scan require "$S" sweep after-record-too-small 'too small'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Sweep

Find entries naming files the change touched.
Read them from every merged pull request on the forge.
Where the forge cannot be reached, use the fallback and say so.
That source is the specification deltas and the files design and tasks name.
After the record has landed, deliver the edit as work too small to be a change.

## Audit

Fans out.
FIXTURE

scan_run "$fixture"
