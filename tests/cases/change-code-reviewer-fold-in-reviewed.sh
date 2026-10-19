#!/usr/bin/env bash
# Scenario (mechanical half only): A folded-in edit with a defect. With the
# requirement's two limits on what is a finding (no scenario of their own).
# Requirement: Out-of-scope edits are reported as scope.
# Change: fold-small-work-in (change-code-review, MODIFIED).
#
# SPECIFIED: a folded-in edit is reviewed for correctness and for the
# project's conventions like the rest of the diff; the no-decision condition
# is judged only where the diff makes a decision visible; a condition the
# reviewed diff cannot show, such as a pull request description not yet
# written, is not a finding.
# DERIVED (operationalisation, Q1): one paragraph per line, so "fold" shares a
# line with "correctness" or the `defect` kind; "decision" with "visible";
# "pull request" with "not a finding".
#
# Not asserted: that a defect in a folded-in commit is reported. The cold-run
# check exercises the reviewer's conduct.
#
# Static read: red until the exemption lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

A=agents/change-code-reviewer.md
# shellcheck disable=SC2016 # backticks are literal markdown in the regex
scan require "$A" "" fold-reviewed 'fold.*(correctness|`defect`)|(correctness|`defect`).*fold'
scan require "$A" "" decision-visible 'decision.*visible|visible.*decision'
scan require "$A" "" pr-not-finding 'pull request.*not a finding|not a finding.*pull request'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/agents"
cat > "$fixture/$A" <<'FIXTURE'
# change-code-reviewer

## Scope

A folded-in edit is reviewed for correctness and for the project's conventions like the rest of the diff.
Judge the no-decision condition only where the diff makes a decision visible.
A condition the diff cannot show, such as a pull request description not yet written, is not a finding.
FIXTURE

scan_run "$fixture"
