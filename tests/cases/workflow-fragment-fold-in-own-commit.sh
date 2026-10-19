#!/usr/bin/env bash
# Scenario: A small defect in a file the change edits (its commit half).
# Requirement: Small adjacent work is folded into the change that found it.
# Change: fold-small-work-in (session-workflow, ADDED).
#
# SPECIFIED: folded-in work takes a commit of its own whose message says it is
# folded in.
# DERIVED (operationalisation, Q1): read from the paragraph opening
# `**Scope.**`; "commit of its own" and "message says it is folded in" are
# matched in the requirement's wording (says or states).
#
# Not asserted: "no backlog entry is written for it" — the fragment half is
# workflow-fragment-second-change-excludes-folded.sh (folded-in work is not a
# second change); the skill half is backlog-skill-record-fold-in.sh.
#
# Static read: red until the rule lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

line_select '^[*][*]scope[.][*][*]'
line_scan require own-commit 'commit of its own'
line_scan require message-says 'message (says|states) (that )?(it is|it.s) folded in'

fixture="$TESTDIR/fragment.md"
cat > "$fixture" <<'FIXTURE'
# Workflow

**Scope.** Prefer changes small enough to review in one sitting; where one grows to cover multiple independent concerns, consider splitting it. Implement only what belongs to the change in progress, with one exception. **Fold in** work noticed along the way where it touches only files the change edits for its own work, or their direct tests; owes no specification delta and no decision from the operator; and is small — a defect, a test correction, a documentation or naming fix, about a screen of diff. Give it a commit of its own whose message says it is folded in, and name it in the pull request's description. Anything else noticed along the way becomes a separate proposed change.
FIXTURE

line_run "$fixture" rules/development-workflow.md
