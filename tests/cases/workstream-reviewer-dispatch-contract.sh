#!/usr/bin/env bash
# Scenarios (mechanical half only): Dispatch omits an essential input;
# Dispatch omits a step's artifacts; A step has no artifact yet; A blocked
# report is not a clean report.
# Requirements: Review operates on a dispatched workstream; The report has a
# declared structure.
# Change: review-a-workstream-against-its-goal (workstream-review, ADDED).
#
# SPECIFIED: the dispatch contract separates essential from supplementary
# inputs, addresses files by absolute path, is blocked on a missing essential
# input, reports conclusions resting on a missing supplementary input as
# unverified rather than not applicable, assesses a step with neither a
# backlog entry nor a proposal from its description in the workstream; and a
# blocked review carries no verdict.
# DERIVED (operationalisation and placement, design.md decision 1): the
# section under the first heading naming `dispatch` holds `essential`,
# `supplementary`, `absolute`, `blocked`, `unverified`, `not applicable` and
# `description`; the whole file states "no verdict" or "no recommended
# action".
#
# Not asserted: that the reviewer gives no verdict when blocked, or reads only
# what it was given. Conduct.
#
# Static read (third situation); every scan is discriminated by a mutant. Red
# at authoring (state 2: the agent does not exist yet).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

A=agents/workstream-reviewer.md
scan require "$A" dispatch essential 'essential'
scan require "$A" dispatch supplementary 'supplementary'
scan require "$A" dispatch absolute-path 'absolute'
scan require "$A" dispatch blocked 'blocked'
scan require "$A" dispatch unverified 'unverified'
scan require "$A" dispatch not-not-applicable 'not applicable'
scan require "$A" dispatch step-from-description 'description'
scan require "$A" "" blocked-no-verdict 'no (verdict|recommended action)'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/agents"
cat > "$fixture/$A" <<'FIXTURE'
---
name: workstream-reviewer
---

## Your dispatch contract

Essential: the workstream's name, its file and the rules file, each by absolute path. Missing one, report yourself blocked.

Supplementary: each step's artifacts. Missing one, review anyway and mark what rested on it unverified, which is not the same as not applicable. A step with neither entry nor proposal is read from its description in the workstream.

## Your report

A blocked report names what was missing and carries no verdict.
FIXTURE

scan_run "$fixture"
