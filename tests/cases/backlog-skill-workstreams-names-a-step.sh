#!/usr/bin/env bash
# Scenario (mechanical half only): A mention in a step's description is not a step.
# Requirement: Workstreams reports where each workstream stands.
# Change: match-backlog-entries-to-a-workstream (backlog-maintenance, MODIFIED).
#
# SPECIFIED: workstreams lists as unplaced what names the workstream without being
# one of its steps, by what the README states names a step.
# DERIVED (structure, as backlog-skill-workstreams-operation.sh assumes): the
# operation sits under a heading naming `workstreams`.
# DERIVED (wording, design.md decision 4): "states what names a step"; and the
# skill does not restate the definition, by the phrase that would carry it
# ("the rule defines it; the skill does not restate it"). The definition itself is
# held in workstreams-block-placing-settled.sh.
#
# Not asserted: that a run lists such an entry as unplaced. Conduct.
#
# Static read (third situation); every scan is discriminated by a mutant. Red at
# authoring on [by-the-rule] (state 1 on real content); goes green as task 2.1
# lands. [not-restated] passes today: its target carries the property.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
scan require "$S" workstreams by-the-rule 'states what names a step'
scan forbid "$S" "" not-restated 'backticked name' 'A step names an entry only by the backticked name a numbered step begins with.'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Workstreams

3. *Unplaced*: the entries naming the workstream that no step names them, as the README states what names a step.

## Audit

Fans out.
FIXTURE

scan_run "$fixture"
