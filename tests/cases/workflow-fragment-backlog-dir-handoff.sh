#!/usr/bin/env bash
# Scenarios (mechanical half only): An identified change is opened without a
# proposal; An opened-and-left branch does not become the session's working
# branch.
# Requirement: A second change surfacing in a session is recorded in the
# backlog. Change: one-file-per-backlog-entry (session-workflow, MODIFIED).
#
# SPECIFIED: the fragment names `docs/backlog/` as the backlog the branching
# option sits beside, opens an identified change with `handoff.md`, and does
# not name the opened-and-left branch for a proposal.
# DERIVED (carried from the superseded workflow-fragment-names-handoff.sh and
# -no-proposal-only-branch.sh, their docs/backlog.md anchor revised to the
# directory): `docs/backlog/` and `handoff.md` are named; "proposal-only" and
# "proposal only" are not.
#
# Static read (third situation); every scan is discriminated by a mutant. Red
# until task 3.1 lands (state 1: the fragment names docs/backlog.md).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

F=rules/development-workflow.md
scan require "$F" "" names-directory 'docs/backlog/'
scan require "$F" "" names-handoff 'handoff[.]md'
scan forbid "$F" "" no-proposal-only 'proposal[- ]only' 'Open a proposal-only branch for it.'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/rules"
cat > "$fixture/$F" <<'FIXTURE'
# Workflow

- Where it **does not**: record it in `docs/backlog/`, or open it on a branch of its own carrying a `handoff.md` and no proposal.
FIXTURE

scan_run "$fixture"
