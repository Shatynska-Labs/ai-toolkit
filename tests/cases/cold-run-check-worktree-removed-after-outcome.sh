#!/usr/bin/env bash
# Scenario: The worktree is removed once the outcome is read.
# Requirement: Cold runs are isolated when the agent can write.
# Change: oblige-removing-a-cold-run-worktree (agent-authoring, MODIFIED).
#
# The scenario is an authoring session's conduct; no program here runs a cold
# run. The mechanical half a case reaches is that the authoring standard states
# the removal, in skills/create-agent/references/cold-run-check.md under the
# heading naming isolation (tasks 1.1 names *Isolation for write-capable
# agents*; the anchor is DERIVED).
#
#   [after-outcome]     SPECIFIED  removal follows the outcome being read
#   [pass-fail-abort]   SPECIFIED  whatever the outcome: pass, fail or abort
#   [before-complete]   SPECIFIED  before the agent is reported complete
#   [from-checkout]     SPECIFIED  made from the authoring checkout
#   [branch-deleted]    SPECIFIED  any branch created with the worktree deleted
#   [harness-nothing]   SPECIFIED  (requirement text, not the scenario) a
#                                  worktree the harness already removed needs
#                                  nothing further
#   [forced]            DERIVED    contents discarded is stated as the command
#                                  tasks 1.1 names: `git worktree remove --force`
#   [branch-command]    DERIVED    tasks 1.1: `git branch -D`
#   [return-to-checkout] DERIVED   tasks 1.1: return to the authoring checkout
#                                  from the `cd <wt>` before removing
#
# Each scan reads one paragraph (one line, per AGENTS.md); its wording regex is
# a DERIVED operationalisation of the requirement's terms.
# Not asserted: that a session performs the removal — the cold-run check's.
# Static read: red until the removal is stated.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

REF="skills/create-agent/references/cold-run-check.md"

scan require "$REF" isolation after-outcome      'outcome.*read.*remov|remov.*outcome.*read'
scan require "$REF" isolation pass-fail-abort    'pass[^.]*fail[^.]*abort'
scan require "$REF" isolation before-complete    'remov.*before.*complete|before.*complete.*remov'
scan require "$REF" isolation from-checkout      'remov.*from (the )?authoring checkout|from (the )?authoring checkout.*remov'
scan require "$REF" isolation branch-deleted     'delet.*branch|branch.*delet'
scan require "$REF" isolation harness-nothing    'harness.*removed.*nothing'
scan require "$REF" isolation forced             'worktree remove (--force|-f)'
scan require "$REF" isolation branch-command     'git branch -d'
scan require "$REF" isolation return-to-checkout '(return|back)[^.]*authoring checkout'

fixture="$TESTDIR/conforming"
mkdir -p "$fixture/skills/create-agent/references"
cat > "$fixture/$REF" <<'FIXTURE'
# Cold-run check

## Isolation for write-capable agents

Create the worktree with `git worktree add <wt> HEAD`, copy the definition in, and `cd <wt>` before the dispatch.

Once the run's outcome has been read from the worktree, whether the run passed, failed or was aborted, the worktree is removed, and before the agent is reported complete. Removal is made from the authoring checkout: return to the authoring checkout from the `cd <wt>`, run `git worktree remove --force <wt>`, which discards its contents, and delete any branch created with the worktree with `git branch -D <branch>`. A worktree the simulation's harness has already removed needs nothing further.

## Fixtures

Unrelated prose keeps the file realistic.
FIXTURE
assert_file "$fixture/$REF" "the conforming fixture was not written"

scan_run "$fixture"
