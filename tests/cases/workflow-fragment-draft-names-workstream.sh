#!/usr/bin/env bash
# Scenarios (mechanical half only): A proposal in a workstream names it; A
# proposal in no workstream says so; A workstream is proposed, not opened.
# Requirement: A change states the workstream it advances, and archiving
# re-reads it. Change: add-workstreams (session-workflow, ADDED).
#
# SPECIFIED: at draft, the fragment directs that a proposal names the
# workstream in `docs/workstreams/` naming the change or whose goal it
# serves, and otherwise states that the change advances none; where the
# change is one of several a goal needs and no workstream holds them, it
# directs proposing that one be opened.
# DERIVED (operationalisation and placement, design.md decision 10): one
# paragraph (line) carries `docs/workstreams/` and `proposal`, and states
# "names (that|the|its) workstream", "advances none", a proposal to open one
# ("propose ... open", or "proposing that one be opened"), and defers to the
# README.
#
# Deliberately untested: "SHALL NOT direct opening one without the operator".
# A scan forbidding "open ... without" would fail a compliant sentence saying
# not to; verified by reading. Whether the paragraph sits in draft is not
# asserted; verified by reading.
#
# Static read: red until the sentence lands (status 2); discriminated by a
# mutant per scan in line_discriminate.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

line_select 'docs/workstreams/'
line_select 'proposal'
line_scan require names-workstream 'names? (that|the|its) workstream'
line_scan require advances-none 'advances none'
line_scan require propose-opening 'propose[^.]*open|proposing that one be opened'
line_scan require defers-to-readme 'readme'

fixture="$TESTDIR/fragment.md"
cat > "$fixture" <<'FIXTURE'
# Workflow

**draft** — write the proposal first.

Where a workstream in `docs/workstreams/` names this change among its steps, or the change serves one's goal, the proposal names that workstream; otherwise it states that the change advances none. Where the change is one of several a goal needs and no workstream holds them, propose opening one, as that directory's README directs.
FIXTURE

line_run "$fixture" rules/development-workflow.md
