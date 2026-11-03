#!/usr/bin/env bash
# Scenarios (mechanical half only): The description carries the contract and
# Dispatch supplies the change (as revised); A change contradicts a workstream
# Decision; A change overturns a Decision openly; A workstream's own defect is
# not this review's; The proposal names a workstream that was not supplied;
# The change advances no workstream.
# Requirements: Review operates on a dispatched change (MODIFIED); A change is
# checked against its workstream's Decisions (ADDED).
# Change: review-a-workstream-against-its-goal (change-review).
#
# SPECIFIED: agents/change-plan-reviewer.md names `workstreamFile` in its
# `description` and its body; it reports a contradiction of a supplied
# workstream's Decision as `[MAJOR — coherence]` unless the proposal states it
# overturns it; it leaves the workstream's quality to a workstream review;
# without the file it reports agreement unverified, or not applicable where
# the proposal states the change advances none.
# DERIVED (operationalisation): `workstreamfile` matched lowercase, as the
# delta and design.md decision 6 name the input; `overturn`; "workstream
# review" or `workstream-reviewer`; "advances none" or "advances no
# workstream"; and one paragraph (line) naming `workstream` and `unverified`.
# `[MAJOR — coherence]` already appears in the plan reviewer, so it is not
# scanned here: a whole-file scan for it would pass before the change.
#
# Not asserted: which finding a given change yields, that the file is not
# counted in the artifact set, and that its Goal does not widen what the
# change is assessed against. Judgement; the cold-run check of task 2.3, run
# with a `workstreamFile`, reaches them.
#
# Static read (third situation); every scan is discriminated by a mutant. Red
# at authoring (state 1 on real content: the agent exists without these).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

A=agents/change-plan-reviewer.md
scan require "$A" @description description-names-input 'workstreamfile'
scan require "$A" "" body-names-input 'workstreamfile'
scan require "$A" "" overturned-decision 'overturn'
scan require "$A" "" quality-elsewhere 'workstream.review|workstream-reviewer'
scan require "$A" "" advances-none 'advances? (none|no workstream)'
scan require "$A" "" not-supplied-unverified 'workstream[^.]*unverified|unverified[^.]*workstream'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/agents"
cat > "$fixture/$A" <<'FIXTURE'
---
name: change-plan-reviewer
description: Reviews a change's plan. Dispatch with the change name, changeRoot and artifact paths; supplementary, specsRoot, validator output and workstreamFile.
---

## Your dispatch contract

Supplementary: `workstreamFile`, the workstream the change serves.

## The workstream's Decisions

A contradiction is `[MAJOR — coherence]` unless the proposal says it overturns the Decision. Its quality is a workstream review's. Without the file, where the proposal names a workstream, agreement with it is unverified; where it states the change advances none, not applicable.
FIXTURE

scan_run "$fixture"
