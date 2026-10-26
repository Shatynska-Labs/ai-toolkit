#!/usr/bin/env bash
# Scenario: A revised body runs in a fresh worktree.
# Requirement: Cold runs are isolated when the agent can write.
# Change: oblige-removing-a-cold-run-worktree (agent-authoring, MODIFIED).
#
# Mechanical half: skills/create-agent/references/cold-run-check.md, under the
# heading naming isolation (DERIVED anchor, tasks 1.2), states it.
#
#   [removed-before-revised]  SPECIFIED  the failing run's worktree is removed
#                                        before the revised body runs
#   [fresh-worktree]          SPECIFIED  the revised body runs in a new worktree
#   [populated]               SPECIFIED  that worktree is populated as for the
#                                        first run (with the revised definition)
#
# Wording regexes are DERIVED operationalisations ("fresh" or "new", the
# requirement's and the scenario's words).
# Not asserted: that a session does so — the cold-run check's.
# Static read: red until the rule is stated.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

REF="skills/create-agent/references/cold-run-check.md"

scan require "$REF" isolation removed-before-revised 'remov.*before.*revis'
scan require "$REF" isolation fresh-worktree         'revis.*(fresh|new)[a-z ,-]*worktree|(fresh|new)[a-z ,-]*worktree.*revis'
scan require "$REF" isolation populated              '(fresh|newly|revis).*populat|populat.*(fresh|revis)'

fixture="$TESTDIR/conforming"
mkdir -p "$fixture/skills/create-agent/references"
cat > "$fixture/$REF" <<'FIXTURE'
# Cold-run check

## Isolation for write-capable agents

Copy the drafted definition into the worktree before the run.

A failing run's worktree is removed before the revised body runs; the revised body runs in a fresh, newly populated worktree, created and populated as for the first run.
FIXTURE
assert_file "$fixture/$REF" "the conforming fixture was not written"

scan_run "$fixture"
