#!/usr/bin/env bash
# Scenarios (mechanical half only): An entry the change can fold in; An entry
# outside the change's files; Selection names no field.
# Requirement: A change takes the backlog entries it can fold in.
# Change: one-file-per-backlog-entry (session-workflow, MODIFIED).
#
# SPECIFIED: the apply step directs reading `docs/backlog/` before
# implementing for entries the scope rule's fold-in conditions admit, taking
# each as folded-in work whose commit names the entry, the deletion left to
# the archive re-read; it selects by the conditions and names no entry field.
# DERIVED (carried from the superseded workflow-fragment-apply-backlog-
# pickup.sh and -apply-pickup-names-no-field.sh, path revised and the
# frontmatter keys added to the forbidden fields).
#
# Static read (third situation); every scan is discriminated by a mutant. Red
# until task 3.1 lands (state 2: no apply item names docs/backlog/).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

line_select '[*][*]apply[*][*]'
line_select 'docs/backlog/'
line_scan require before-implementing 'before implementing'
line_scan require by-fold-in 'scope rule|fold-in condition'
line_scan require folded-in-work 'folded-in work|fold (it|them) in'
line_scan require commit-names-entry 'commit names the entry|naming the entry'
line_scan require archive-reread 'archive'
line_scan forbid field-kind '(^|[^a-z])kind([^a-z]|$)' 'Select entries whose Kind is fix.'
line_scan forbid field-other 'waits on|design with|re-checked|recorded by|depends on|waits_on|waits_for|design_with|re_checked|recorded_by|priority' 'Skip entries whose waits_on is set.'
line_scan forbid kind-value-fix '(^|[^a-z])fix(es)?([^a-z]|$)' 'Take the fix entries.'

fixture="$TESTDIR/fragment.md"
cat > "$fixture" <<'FIXTURE'

**apply** — implement the change's tasks. Before implementing, read `docs/backlog/` for entries the scope rule would let this change fold in, and take each as folded-in work whose commit names the entry; leave the entry itself to the archive step.
FIXTURE

line_run "$fixture" rules/development-workflow.md
