#!/usr/bin/env bash
# Scenario (mechanical half only): Entries in two ranges share a goal.
# Requirement: Audit verifies every entry independently and changes nothing
# without the operator.
# Change: propose-a-workstream-for-entries-sharing-a-goal (backlog-maintenance,
# MODIFIED).
#
# SPECIFIED: after the agents return, the skill itself reads the bodies of every
# entry carrying the absent value together, because no agent sees two ranges;
# the report names the groups sharing a goal that takes more than one change,
# each with a draft Goal, proposed as workstreams; nothing is applied until the
# operator says so, an approved workstream is opened as
# `docs/workstreams/AGENTS.md` and the workflow direct with its entries
# re-pointed to it, and the edit spans the entry files and the workstream files
# it opens.
# DERIVED (structure, as backlog-skill-audit.sh assumes): SKILL.md read from the
# section under a heading naming `audit`; the report's sections in
# skills/backlog/references/audit.md.
# DERIVED (wording and numbering, design.md decision 6): each scan is one phrase
# of decision 6's text; [fixes-eighth] and [unverified-ninth] hold the
# renumbering decision 6 states, that **Shared goals** is section 7 and
# **Fixes** and **Unverified** become 8 and 9.
#
# Not asserted: that the skill finds a group across two ranges, and that no
# workstream file is created before the operator approves. Conduct (design.md
# decision 10); "applies none of it until the operator says so" is held by
# backlog-skill-audit.sh [operator-approves].
#
# Static read (third situation); every scan is discriminated by a mutant. Red at
# authoring (state 1 on real content); goes green as tasks 2.1 and 2.2 land.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
A=skills/backlog/references/audit.md
scan require "$S" audit reads-across-ranges 'read every entry carrying the readme.s absent value together, across ranges, for goals they share'
scan require "$S" audit opens-approved 'a shared goal the operator approves is opened as the workstreams readme and the workflow direct'
scan require "$S" audit repoints 'its entries re-pointed to it'
scan require "$S" audit workstream-files 'workstream files'
scan require "$A" "" shared-goals-seventh '7[.] [*][*]shared goals[*][*]'
scan require "$A" "" draft-goal 'each with a draft goal and the entries it would hold'
scan require "$A" "" proposed-to-open 'proposed as workstreams to open'
scan require "$A" "" no-agent-two-ranges 'no agent sees two ranges'
scan require "$A" "" fixes-eighth '8[.] [*][*]fixes[*][*]'
scan require "$A" "" unverified-ninth '9[.] [*][*]unverified[*][*]'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog/references"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Audit

4. Merge the verdicts. Then read every entry carrying the README's absent value together, across ranges, for goals they share, and add what you find to the report.
5. Apply nothing until the operator says so. A shared goal the operator approves is opened as the workstreams README and the workflow direct, its entries re-pointed to it, in one edit across the entry files and the workstream files it opens.

## Workstreams

Lists them.
FIXTURE
cat > "$fixture/$A" <<'FIXTURE'
# Audit brief

## The merged report

6. **Groups**: entries sharing a design.
7. **Shared goals**: groups of entries carrying the README's absent value (`none` in the seeded README) that share a goal taking more than one change, each with a draft Goal and the entries it would hold, proposed as workstreams to open. The skill reads them itself, from the entries' bodies, because no agent sees two ranges.
8. **Fixes**: entries that can be taken as fixes.
9. **Unverified**: what could not be checked.
FIXTURE

scan_run "$fixture"
