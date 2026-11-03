#!/usr/bin/env bash
# Scenario (mechanical half only, as revised): A conclusion rests on
# inference, whose levels now name a supplied workstream's Decisions.
# Requirement: Conclusions declare their evidence level (MODIFIED).
# Change: review-a-workstream-against-its-goal (change-review).
#
# SPECIFIED: the hierarchy's second level holds existing specifications and
# the Decisions of a supplied workstream.
# DERIVED (operationalisation): some paragraph (line) naming `inference`, the
# lowest level, names a workstream's decisions in one sentence. A hierarchy
# written as a list with `inference` on a line of its own fails here, which is
# a derived assertion to reconsider: see test-plan.md, unresolved question 2.
#
# Not asserted: the level a given conclusion declares, or the stated
# substitution where `workstreamFile` was not supplied. Conduct.
#
# Static read (third situation); every scan is discriminated by a mutant. Red
# at authoring (state 1 on real content).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

line_select 'inference'
line_scan require workstream-decisions 'workstream[^.]*decision|decision[^.]*workstream'

fixture="$TESTDIR/agent.md"
cat > "$fixture" <<'FIXTURE'
## How you weigh evidence

Declare each conclusion's level: the change's proposal and design, then existing specifications and a supplied workstream's Decisions, then task definitions, then logical inference.
FIXTURE

line_run "$fixture" agents/change-plan-reviewer.md
