#!/usr/bin/env bash
# Scenarios (mechanical half only): An entry done by an unmentioning change;
# The report is not applied unasked; Two entries recorded for one change.
# Requirement: Audit verifies every entry independently and changes nothing
# without the operator. Change: add-backlog-skill (backlog-maintenance).
#
# SPECIFIED: each agent checks archived changes and merged pull requests among
# its sources; returns a relevance verdict from `live`, `stale`,
# `partly-done`, `obsolete`, `waiting` and a kind verdict from `fix`,
# `change`, `fix?`; writes nothing; the merged report names entries that are
# one change recorded twice; nothing is applied until the operator says so;
# ranges run in parallel.
# DERIVED (design.md decision 4, not the spec): the brief and the report's
# sections live in skills/backlog/references/audit.md, and SKILL.md references
# it by that path.
# DERIVED (structure, Q1): the SKILL.md half is read from the section under a
# heading naming `audit`. DERIVED (operationalisation): writing nothing is
# `write(s) nothing`, `read-only`, `must not write` or `do not write`; one
# change recorded twice is `recorded twice` or `duplicate`.
#
# Not asserted: that an agent actually finds the unmentioning change, and that
# the file is unchanged before approval. Conduct; verified by reading.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
A=skills/backlog/references/audit.md
scan require "$S" audit parallel-agents 'parallel'
scan require "$S" audit operator-approves 'operator'
scan require "$S" audit brief-referenced 'references/audit[.]md'
scan require "$A" "" verdict-live '(^|[^a-z])live([^a-z]|$)'
scan require "$A" "" verdict-stale 'stale'
scan require "$A" "" verdict-partly-done 'partly-done'
scan require "$A" "" verdict-obsolete 'obsolete'
scan require "$A" "" verdict-waiting 'waiting'
scan require "$A" "" verdict-fix-uncertain 'fix[?]'
scan require "$A" "" source-archived-changes 'archive'
scan require "$A" "" source-merged-prs 'merged'
scan require "$A" "" agents-write-nothing 'writes? nothing|read-only|must not write|do not write'
scan require "$A" "" report-recorded-twice 'recorded twice|duplicate'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog/references"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Audit

Dispatch one agent per range, in parallel, with the brief in references/audit.md.
Apply the report only on the operator's word.
FIXTURE
cat > "$fixture/$A" <<'FIXTURE'
# Audit brief

Relevance verdict: live
or stale
or partly-done
or obsolete
or waiting.
Kind verdict: change, or fix?, with its reason.
Check the archive of changes.
Check the forge's merged pull requests.
Write nothing.
Report: entries that are one change recorded twice.
FIXTURE

scan_run "$fixture"
