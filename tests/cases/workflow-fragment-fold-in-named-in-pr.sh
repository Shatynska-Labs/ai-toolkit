#!/usr/bin/env bash
# Scenario: Folded-in work is named for the operator.
# Requirement: Small adjacent work is folded into the change that found it.
# Change: fold-small-work-in (session-workflow, ADDED).
#
# SPECIFIED: the scope rule directs that the pull request's description names
# folded-in work.
# DERIVED (operationalisation, Q1): on the paragraph opening `**Scope.**`, a
# direction to name it ("name it" / "name them") and the pull request's
# description.
#
# Not asserted: that open pr actually carries the name. Conduct; verified by
# reading.
#
# Static read: red until the rule lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

line_select '^[*][*]scope[.][*][*]'
line_scan require name-it 'name (it|them)'
line_scan require pr-description 'pull request.s description|description of the pull request'

fixture="$TESTDIR/fragment.md"
cat > "$fixture" <<'FIXTURE'
# Workflow

**Scope.** Prefer changes small enough to review in one sitting; where one grows to cover multiple independent concerns, consider splitting it. Implement only what belongs to the change in progress, with one exception. **Fold in** work noticed along the way where it touches only files the change edits for its own work, or their direct tests; owes no specification delta and no decision from the operator; and is small — a defect, a test correction, a documentation or naming fix, about a screen of diff. Give it a commit of its own whose message says it is folded in, and name it in the pull request's description. Anything else noticed along the way becomes a separate proposed change.
FIXTURE

line_run "$fixture" rules/development-workflow.md
