#!/usr/bin/env bash
# Scenario: Recording is stated as what is owed.
# Requirement: A second change surfacing in a session is recorded in the
# backlog. Change: fold-small-work-in (session-workflow, MODIFIED), folding in
# the backlog entry state-recording-as-the-obligation.
#
# SPECIFIED: where the fragment routes an independent change it states
# recording as the obligation and branching as the option, rather than
# offering the two as equals; the fragment names the path `docs/backlog.md`.
# DERIVED (operationalisation, Q1): the routing for an independent change is
# the list item opening "Where it **does not**" (design.md decision 2). On
# it: recording in `docs/backlog.md`; recording stated as owed or as the
# obligation; opening stated as the option. "either" on that item is taken
# as offering the two as equals.
#
# Not asserted: the reason the backlog exists outside the change, which no
# token fixes. Verified by reading.
#
# Static read: red until the bullet lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

line_select '^[[:space:]]*[-*] +where it [*]*does not[*]*'
line_scan require record-in-backlog 'record (it|them) in .?docs/backlog[.]md'
line_scan require owed '(is owed|what is owed|the obligation)'
line_scan require option '(is|as) the option|an option'
line_scan forbid equals '(^|[^a-z])either([^a-z]|$)' 'Either record it or open it.'

fixture="$TESTDIR/fragment.md"
cat > "$fixture" <<'FIXTURE'
# Workflow

**A second change surfacing.** You work on one change at a time. Work you identify that the scope rule does not fold in is a second change: record it before doing anything else about it.

- Where it **does**: record the dependency in the change's artifacts.
- Where it **does not**: record it in `docs/backlog.md`. That is what is owed; opening the identified change instead is the option.
FIXTURE

line_run "$fixture" rules/development-workflow.md
