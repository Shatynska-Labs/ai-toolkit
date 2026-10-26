#!/usr/bin/env bash
# Source: tasks 1.3 and the proposal's What Changes — skills/create-agent/
# SKILL.md's summary of the isolation names the removal. No scenario states
# this; the case is DERIVED in full. It supports the three removal scenarios
# of *Cold runs are isolated when the agent can write*
# (oblige-removing-a-cold-run-worktree, agent-authoring, MODIFIED) by checking
# that the skill's own summary does not omit what the reference states.
#
#   [names-removal]  DERIVED  a paragraph of SKILL.md names the worktree (or
#                             isolation) and its removal together
#
# The summary's heading is not fixed by any artifact, so the whole file is read.
# Static read: expected red until task 1.3 lands; a green at authoring would
# mean SKILL.md already co-locates the words, recorded in test-plan.md.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

SKILL="skills/create-agent/SKILL.md"

scan require "$SKILL" "" names-removal '(worktree|isolat).*remov|remov.*(worktree|isolat)'

fixture="$TESTDIR/conforming"
mkdir -p "$fixture/skills/create-agent"
cat > "$fixture/$SKILL" <<'FIXTURE'
---
name: create-agent
description: fixture
---
# create-agent

A write-capable agent's live run happens in an isolated worktree, populated with the draft, and the worktree is removed once its outcome is read.
FIXTURE
assert_file "$fixture/$SKILL" "the conforming fixture was not written"

scan_run "$fixture"
