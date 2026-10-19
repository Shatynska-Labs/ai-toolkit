#!/usr/bin/env bash
# Scenarios (mechanical half only): An entry the change can fold in; An entry
# outside the change's files.
# Requirement: A change takes the backlog entries it can fold in.
# Change: fold-small-work-in (session-workflow, ADDED).
#
# SPECIFIED: the apply step directs reading `docs/backlog.md` before
# implementing, for entries the scope rule's fold-in conditions admit, taking
# each as folded-in work whose commit names the entry, and leaving the
# entry's deletion to the archive re-read. "An entry outside the change's
# files" is reached through the same sentence: selection is by the fold-in
# conditions, whose own-files condition workflow-fragment-fold-in-conditions.sh
# reads.
# DERIVED (operationalisation, Q1): the apply step is the list item naming
# `**apply**` that also names `docs/backlog.md`; on it, "before
# implementing", the scope rule or its fold-in conditions, a commit naming the
# entry, and the archive.
#
# Not asserted: that a session takes the entry, or that the archive re-read
# deletes it. Conduct; verified by reading.
#
# Static read: red until the sentence lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

line_select '[*][*]apply[*][*]'
line_select 'docs/backlog[.]md'
line_scan require before-implementing 'before implementing'
line_scan require by-fold-in 'scope rule|fold-in condition'
line_scan require folded-in-work 'folded-in work|fold (it|them) in'
line_scan require commit-names-entry 'commit names the entry|naming the entry'
line_scan require archive-reread 'archive'

fixture="$TESTDIR/fragment.md"
cat > "$fixture" <<'FIXTURE'
# Workflow

- **apply**: implement the change's tasks. Before implementing, read `docs/backlog.md` for entries the scope rule would let this change fold in, and take each as folded-in work whose commit names the entry; the archive re-read deletes it.
FIXTURE

line_run "$fixture" rules/development-workflow.md
