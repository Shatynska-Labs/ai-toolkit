#!/usr/bin/env bash
# Scenarios (mechanical half only): Recording is stated as what is owed; An
# unrelated improvement is recorded rather than implemented.
# Requirement: A second change surfacing in a session is recorded in the
# backlog. Change: one-file-per-backlog-entry (session-workflow, MODIFIED).
#
# SPECIFIED: where the fragment routes an identified change the change in
# progress does not depend on, it records it in `docs/backlog/` as what is
# owed, opening the change as the option, not the two as equals.
# DERIVED (carried from the superseded workflow-fragment-routing-recording-
# owed.sh, its path revised): the `- Where it **does not**` item carries
# `record it in docs/backlog/`, owed, option, and no "either".
#
# Static read (third situation); every scan is discriminated by a mutant. Red
# until task 3.1 lands (state 1).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

line_select '^[[:space:]]*[-*] +where it [*]*does not[*]*'
line_scan require record-in-directory 'record (it|them) in .?docs/backlog/'
line_scan require owed '(is owed|what is owed|the obligation)'
line_scan require option '(is|as) the option|an option'
line_scan forbid equals '(^|[^a-z])either([^a-z]|$)' 'Either record it or open it.'

fixture="$TESTDIR/fragment.md"
cat > "$fixture" <<'FIXTURE'

- Where it **does**: record the dependency in the change's artifacts.
- Where it **does not**: record it in `docs/backlog/`. That is what is owed; opening the identified change instead is the option.
FIXTURE

line_run "$fixture" rules/development-workflow.md
