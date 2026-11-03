#!/usr/bin/env bash
# Scenario (mechanical half only): Dispatch supplies the workstream.
# Requirement: Review operates on a dispatched workstream.
# Change: review-a-workstream-against-its-goal (workstream-review, ADDED).
#
# SPECIFIED: the agent's `description` names the inputs a dispatch must
# supply: the workstream's name, the absolute path to its file, the rules
# file, and, supplementary, each step's backlog entry and proposal and the
# documents the Decisions point to.
# DERIVED (operationalisation): one lowercase phrase per input, matched in the
# frontmatter `description:` value: `name`, `workstream ... file|path`,
# `rules`, `backlog entr`, `proposal`, `decision`, `absolute`. A description
# naming an input in other words fails here, which is a derived assertion to
# reconsider, not a defect in the agent.
#
# Not asserted: that the reviewer reads nothing outside the supplied paths.
# Conduct; the cold-run check of task 2.2 reaches it.
#
# Static read (third situation); every scan is discriminated by a mutant. Red
# at authoring (state 2: agents/workstream-reviewer.md does not exist yet).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

A=agents/workstream-reviewer.md
scan require "$A" @description workstream-name 'name'
scan require "$A" @description workstream-file 'workstream[^.]*(file|path)'
scan require "$A" @description rules-file 'rules'
scan require "$A" @description backlog-entry 'backlog entr'
scan require "$A" @description proposal 'proposal'
scan require "$A" @description decision-documents 'decision'
scan require "$A" @description absolute 'absolute'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/agents"
cat > "$fixture/$A" <<'FIXTURE'
---
name: workstream-reviewer
description: Reviews one workstream's plan. Dispatch with the workstream's name, the absolute path to the workstream file and to the rules file; supplementary, each step's backlog entry and proposal, and the documents its Decisions point to.
model: inherit
tools: Read, Grep, Glob
---

Body.
FIXTURE

scan_run "$fixture"
