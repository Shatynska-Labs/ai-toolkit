#!/usr/bin/env bash
# Scenario: An aborted run's worktree is removed.
# Requirement: Cold runs are isolated when the agent can write.
# Change: oblige-removing-a-cold-run-worktree (agent-authoring, MODIFIED).
#
# Mechanical half: skills/create-agent/references/cold-run-check.md, under the
# heading naming isolation (DERIVED anchor, tasks 1.1), states removal in the
# same paragraph as the abort.
#
#   [abort-removed]  SPECIFIED  an aborted run's worktree is removed; the
#                               paragraph co-occurrence of "abort" and "remov"
#                               is a DERIVED operationalisation
#
# Not asserted: that removal is "as a finished run's would be" beyond sharing
# the statement — the when and how are asserted by
# cold-run-check-worktree-removed-after-outcome.sh; that a session removes an
# aborted run's worktree is the cold-run check's to establish.
# Static read: red until the removal is stated.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

REF="skills/create-agent/references/cold-run-check.md"

scan require "$REF" isolation abort-removed 'remov[^.]*abort|abort[^.]*remov'

fixture="$TESTDIR/conforming"
mkdir -p "$fixture/skills/create-agent/references"
cat > "$fixture/$REF" <<'FIXTURE'
# Cold-run check

## Isolation for write-capable agents

A payload naming a writable path outside the worktree aborts the run.

The worktree is removed once the outcome is read, on a pass, a failure or an abort.
FIXTURE
assert_file "$fixture/$REF" "the conforming fixture was not written"

scan_run "$fixture"
