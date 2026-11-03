#!/usr/bin/env bash
# Scenarios (mechanical half only): A step could have been added; A step's
# status is not reported.
# Requirement: The review is bounded by the workstream's own plan.
# Change: review-a-workstream-against-its-goal (workstream-review, ADDED).
#
# SPECIFIED: the reviewer recommends no goal, step or decision the workstream
# does not need for its stated Goal, judges whether it should exist only in
# reaching `REJECTED`, and does not report which steps are done, in flight or
# planned.
# DERIVED (operationalisation and placement, design.md decision 1's section
# *Stay inside the plan*): the section under the first heading naming
# `inside` holds `need`, `rejected`, and `status` or `in flight`.
#
# Not asserted: that the reviewer refrains. Conduct.
#
# Static read (third situation); every scan is discriminated by a mutant. Red
# at authoring (state 2: the agent does not exist yet).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

A=agents/workstream-reviewer.md
scan require "$A" inside not-needed 'need'
scan require "$A" inside existence-only-rejected 'rejected'
scan require "$A" inside no-status '(status|in flight)'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/agents"
cat > "$fixture/$A" <<'FIXTURE'
---
name: workstream-reviewer
---

## Stay inside the plan

Recommend nothing the Goal does not need. Whether the workstream should exist is a question only for `REJECTED`. Report no step's status: not done, in flight or planned.
FIXTURE

scan_run "$fixture"
