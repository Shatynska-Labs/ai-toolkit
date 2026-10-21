#!/usr/bin/env bash
# Scenario (mechanical half only): A parked entry whose condition has fired.
# Requirement: Audit verifies every entry independently and changes nothing
# without the operator.
# Change: add-a-backlog-priority (backlog-maintenance, MODIFIED).
#
# SPECIFIED: for a `high` entry the agent says whether its evidence still
# holds, and for a parked one whether its condition now holds; the merged
# report names the entries now unblocked or unparked, and among the stale
# facts each `high` entry whose evidence no longer holds, its Priority
# corrected as the file directs. The scenario adds that an unparked entry is
# named with the evidence that its condition holds.
# DERIVED (placement, as backlog-skill-audit.sh assumes from add-backlog-skill
# design.md decision 4): the brief and the report's sections live in
# skills/backlog/references/audit.md, scanned whole.
# DERIVED (operationalisation), each on one line: `high` with `evidence`;
# `parked` with `condition`; `condition` with `evidence`; `unblocked or
# unparked` (tasks.md 2.2's renamed section, matched in a heading or a body
# line); `no longer hold`; `priority` with `correct`.
#
# Not asserted: that an agent reaches those verdicts, and that the report
# lists the entry. Conduct; verified by reading.
#
# Static read: red until the step lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

A=skills/backlog/references/audit.md
scan require "$A" "" high-evidence-holds 'high[^a-z][^.]*evidence|evidence[^.]*[^a-z]high[^a-z]'
scan require "$A" "" parked-condition-holds 'parked[^.]*condition|condition[^.]*parked'
scan require "$A" "" condition-with-evidence 'condition[^.]*evidence|evidence[^.]*condition'
scan require "$A" "" now-unblocked-or-unparked 'unblocked or unparked'
scan require "$A" "" high-evidence-lapsed 'no longer hold'
scan require "$A" "" priority-corrected 'priority[^.]*correct|correct[^.]*priority'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog/references"
cat > "$fixture/$A" <<'FIXTURE'
# Audit brief

For an entry whose Priority is `high`, say whether its evidence still holds.
For an entry whose Priority is parked, say whether its condition now holds, citing the evidence for it.

## Report

- Stale facts: each `high` entry whose evidence no longer holds, its Priority corrected as the file directs.
- Now unblocked or unparked: the entries that can now be taken.
FIXTURE

scan_run "$fixture"
