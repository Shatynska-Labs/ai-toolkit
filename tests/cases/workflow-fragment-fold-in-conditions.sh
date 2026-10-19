#!/usr/bin/env bash
# Scenarios: A defect in a file the change does not edit; Small work that owes
# a delta; A small defect in a file the change edits (its conditions half).
# Requirement: Small adjacent work is folded into the change that found it.
# Change: fold-small-work-in (session-workflow, ADDED).
#
# SPECIFIED: the scope rule directs folding in work where all three hold —
# only files the change edits for its own work, or their direct tests; no
# specification delta and no decision from the operator; small, which the
# requirement defines as a defect, a test correction, a documentation or
# naming fix, about a screen of diff — and work failing any of them remains a
# separate proposed change.
# DERIVED (operationalisation, test-plan.md Q1): the scope rule is the
# paragraph opening `**Scope.**` (one paragraph per line), and each condition
# is recognised by the requirement's own phrase on that line. A condition
# stated in other words is not reached.
#
# Not asserted: that a session applies the conditions as stated. Conduct;
# verified by reading.
#
# Static read: red until the rule lands (no fold-in on the Scope paragraph).
# The fixture below is the design's text; every scan is shown to fail on a
# mutant of it.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

line_select '^[*][*]scope[.][*][*]'
line_scan require fold-in 'fold(ed)? in'
line_scan require own-files 'only files the change edits for its own work'
line_scan require direct-tests 'direct tests'
line_scan require no-delta 'no specification delta'
line_scan require no-decision 'no decision'
line_scan require small 'is small'
line_scan require example-defect 'a defect'
line_scan require example-test 'test correction'
line_scan require example-docs 'documentation or naming fix'
line_scan require size 'screen of diff'
line_scan require rest-separate 'separate proposed change'

fixture="$TESTDIR/fragment.md"
cat > "$fixture" <<'FIXTURE'
# Workflow

**Scope.** Prefer changes small enough to review in one sitting; where one grows to cover multiple independent concerns, consider splitting it. Implement only what belongs to the change in progress, with one exception. **Fold in** work noticed along the way where it touches only files the change edits for its own work, or their direct tests; owes no specification delta and no decision from the operator; and is small — a defect, a test correction, a documentation or naming fix, about a screen of diff. Give it a commit of its own whose message says it is folded in, and name it in the pull request's description. Anything else noticed along the way becomes a separate proposed change.
FIXTURE

line_run "$fixture" rules/development-workflow.md
