#!/usr/bin/env bash
# Scenarios (mechanical half only): A part of the Goal has no step; Done when
# restates the steps; Done when beside an effect; A step contradicts a
# Decision; A step is out of scope; Context records progress; A step overturns
# a Decision openly; A step's artifact predates a revised Decision.
# Requirement: The review asks five questions of the plan.
# Change: review-a-workstream-against-its-goal (workstream-review, ADDED).
#
# SPECIFIED: the agent asks of the plan Goal coverage, Done when as an
# observable effect, agreement with the Decisions, staying out of Not in
# scope, and no progress in Context and Decisions; it reads "every step is
# done" alone as a defect; a step whose proposal overturns a Decision is no
# contradiction; an archived step older than a revised Decision is read from
# its description.
# DERIVED (operationalisation and placement, design.md decision 1): the
# section under the first heading naming `questions` holds `goal`,
# `done when`, `observable`, `every step`, `decision`, `not in scope`,
# `context`, `progress`, `overturn` and `archiv`.
#
# Not asserted: that the reviewer finds a gap, judges a Done when rightly, or
# splits a Goal into parts sensibly. Judgement; the cold-run check (task 2.2)
# exercises a Goal of two effects and a Done when reading "every step is
# archived".
#
# Static read (third situation); every scan is discriminated by a mutant. Red
# at authoring (state 2: the agent does not exist yet).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

A=agents/workstream-reviewer.md
scan require "$A" questions goal-coverage 'goal'
scan require "$A" questions done-when 'done when'
scan require "$A" questions observable 'observ'
scan require "$A" questions every-step-done 'every step'
scan require "$A" questions decisions 'decision'
scan require "$A" questions not-in-scope 'not in scope'
scan require "$A" questions context 'context'
scan require "$A" questions progress 'progress'
scan require "$A" questions overturned-decision 'overturn'
scan require "$A" questions archived-step 'archiv'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/agents"
cat > "$fixture/$A" <<'FIXTURE'
---
name: workstream-reviewer
---

## The five questions

1. Goal coverage: the steps together deliver each part of the Goal.
2. Done when is an observable effect; "every step is done" alone is not.
3. No step contradicts a Decision, unless its proposal says it overturns it. An archived step older than a revised Decision is read from its description.
4. No step does what Not in scope leaves out.
5. Context and Decisions record no progress.
FIXTURE

scan_run "$fixture"
