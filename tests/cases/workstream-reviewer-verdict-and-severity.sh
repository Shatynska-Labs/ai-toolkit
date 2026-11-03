#!/usr/bin/env bash
# Scenarios (mechanical half only): A gap in the plan requires a fix; Recorded
# progress alone does not stop the plan; A clean review; A part of the Goal is
# partly reached.
# Requirements: The review shares a change review's severity and verdict; The
# review asks five questions of the plan.
# Change: review-a-workstream-against-its-goal (workstream-review, ADDED).
#
# SPECIFIED: agents/workstream-reviewer.md states the four verdicts
# (`APPROVED`, `CONDITIONALLY APPROVED`, `FIX REQUIRED`, `REJECTED`), the
# four severities (`[CRITICAL]`, `[MAJOR — design]`, `[MAJOR — coherence]`,
# `[MINOR]`), the three coverage marks (`[Covered]`, `[Partially Covered]`,
# `[Not Covered]`), and that a design remedy revisits the plan and a coherence
# remedy reconciles its parts.
# DERIVED: verdicts backticked, as change-plan-reviewer and the spec write
# them, since `APPROVED` bare is a substring of `CONDITIONALLY APPROVED`;
# remedies by `revisit` and `reconcil`.
#
# Not asserted: which severity a given defect takes and which verdict a set of
# findings yields — the spec's mapping is stated in prose whose wording a scan
# would have to guess. Verified by reading and by the cold-run check (task
# 2.2), whose fixture must return `FIX REQUIRED`.
# review-verdict-vocabulary.sh already forbids the superseded verdict names
# across agents/, the new agent included.
#
# Static read (third situation); every scan is discriminated by a mutant. Red
# at authoring (state 2: the agent does not exist yet).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

A=agents/workstream-reviewer.md
# shellcheck disable=SC2016 # backticks are literal markdown in the patterns
{
  scan require "$A" "" approved '`approved`'
  scan require "$A" "" conditionally-approved '`conditionally approved`'
  scan require "$A" "" fix-required '`fix required`'
  scan require "$A" "" rejected '`rejected`'
}
scan require "$A" "" critical '[[]critical[]]'
scan require "$A" "" major-design '[[]major — design[]]'
scan require "$A" "" major-coherence '[[]major — coherence[]]'
scan require "$A" "" minor '[[]minor[]]'
scan require "$A" "" covered '[[]covered[]]'
scan require "$A" "" partially-covered '[[]partially covered[]]'
scan require "$A" "" not-covered '[[]not covered[]]'
scan require "$A" "" design-remedy 'revisit'
scan require "$A" "" coherence-remedy 'reconcil'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/agents"
cat > "$fixture/$A" <<'FIXTURE'
---
name: workstream-reviewer
---

## Severity

`[CRITICAL]`, `[MAJOR — design]` (revisit the plan), `[MAJOR — coherence]` (reconcile its parts), `[MINOR]`.

Mark each part `[Covered]`, `[Partially Covered]` or `[Not Covered]`.

## The recommended action

One of `APPROVED`, `CONDITIONALLY APPROVED`, `FIX REQUIRED` or `REJECTED`.
FIXTURE

scan_run "$fixture"
