#!/usr/bin/env bash
# Scenario (mechanical half only): A goal one change meets earns no proposal.
# Requirement: Record writes an entry the file can be relied on for.
# Change: propose-a-workstream-for-entries-sharing-a-goal (backlog-maintenance,
# MODIFIED).
#
# SPECIFIED: record proposes a workstream only where the shared goal takes more
# than one change, as `docs/workstreams/AGENTS.md` directs; a goal one change
# meets is not proposed.
# DERIVED (design.md decisions 1 and 4): the skill does not restate the limit
# but defers to the workstreams rules, so the case holds both ends: record's
# proposal defers to the workstreams README [defers], and the fragment that
# README is written from, rules/workstreams.md, states that a goal one change
# meets is not proposed [one-change-not-proposed] and that a proposal is for a
# goal needing more than one change [more-than-one].
# DERIVED (wording): each scan is one phrase of decision 1 or 4.
#
# Not asserted: that a session judges a goal to be one change's. Conduct
# (design.md decision 10).
#
# Static read (third situation); every scan is discriminated by a mutant. Red at
# authoring (state 1 on real content); goes green as tasks 1.1 and 2.1 land.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
W=rules/workstreams.md
scan require "$S" record defers 'propose opening a workstream for it as the workstreams readme directs'
scan require "$W" "" one-change-not-proposed 'a goal one change meets is not proposed'
scan require "$W" "" more-than-one 'a session that finds such a goal that no open workstream holds'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog" "$fixture/rules"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Record

Where they share one, propose opening a workstream for it as the workstreams README directs, naming the entries and a draft Goal.

## Pick

Lists takeable entries.
FIXTURE
cat > "$fixture/$W" <<'FIXTURE'
---
kind: standing-constraint
version: 2.2.0
---
# Workstreams

Open a workstream when the operator decides a goal needs more than one change. A session that finds such a goal that no open workstream holds proposes opening one to the operator; a goal one change meets is not proposed.
FIXTURE

scan_run "$fixture"
