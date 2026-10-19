#!/usr/bin/env bash
# Scenarios (mechanical half only): An unrelated improvement is recorded
# rather than implemented (as revised: "and the scope rule does not fold it
# in"); The scope rule and the backlog are one obligation (as revised: the
# shared obligation is that work the scope rule does not fold in leaves the
# change); A small defect in a file the change edits (its "no backlog entry"
# half, fragment side).
# Requirement: A second change surfacing in a session is recorded in the
# backlog. Change: fold-small-work-in (session-workflow, MODIFIED).
#
# SPECIFIED: the fragment states what happens when a second change is
# identified "and the fragment's scope rule does not fold it in. Work that
# rule folds in is not a second change".
# DERIVED (operationalisation, Q1): the rule is the paragraph opening
# `**A second change surfacing.**`; on it, the scope rule, a "does not fold"
# limitation, and "is a second change". A limitation worded otherwise is not
# reached.
#
# Not asserted: that the work is not implemented in the session that found
# it, and the reconciliation's prose beyond the limitation. Verified by
# reading.
#
# Static read: red until the opening lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

line_select '^[*][*]a second change surfacing[.]?[*][*]'
line_scan require scope-rule 'scope rule'
line_scan require not-folded '(does not|doesn.t|not) fold'
line_scan require is-second-change 'is a second change'

fixture="$TESTDIR/fragment.md"
cat > "$fixture" <<'FIXTURE'
# Workflow

**A second change surfacing.** You work on one change at a time. Work you identify that the scope rule does not fold in is a second change: record it before doing anything else about it.

- Where it **does**: record the dependency in the change's artifacts.
- Where it **does not**: record it in `docs/backlog.md`. That is what is owed; opening the identified change instead is the option.
FIXTURE

line_run "$fixture" rules/development-workflow.md
