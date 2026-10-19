#!/usr/bin/env bash
# Scenario: Selection names no field.
# Requirement: A change takes the backlog entries it can fold in.
# Change: fold-small-work-in (session-workflow, ADDED).
#
# SPECIFIED: the apply step selects entries by the fold-in conditions and
# SHALL NOT name an entry field, such as Kind.
# DERIVED (operationalisation): on the apply item naming `docs/backlog.md`
# (Q1), no entry-field label — kind, waits on, design with, re-checked,
# recorded by, depends on — and no selection by the `fix` kind value
# (design.md decision 5 names selecting by `Kind: fix` as what is rejected).
# The selection-by-conditions half is workflow-fragment-apply-backlog-pickup.sh.
# workflow-fragment-archive-reread-names-no-field.sh already forbids the
# capitalised labels anywhere in the fragment; this case adds the lowercase
# forms on the pickup sentence, where prose naming a field would sit.
#
# Static read: red until the sentence lands (no apply item naming the
# backlog to read).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

line_select '[*][*]apply[*][*]'
line_select 'docs/backlog[.]md'
line_scan forbid field-kind '(^|[^a-z])kind([^a-z]|$)' 'Select entries whose Kind is fix.'
line_scan forbid field-other 'waits on|design with|re-checked|recorded by|depends on' 'Skip entries whose Waits on is set.'
line_scan forbid kind-value-fix '(^|[^a-z])fix(es)?([^a-z]|$)' 'Take the fix entries.'

fixture="$TESTDIR/fragment.md"
cat > "$fixture" <<'FIXTURE'
# Workflow

- **apply**: implement the change's tasks. Before implementing, read `docs/backlog.md` for entries the scope rule would let this change fold in, and take each as folded-in work whose commit names the entry; the archive re-read deletes it.
FIXTURE

line_run "$fixture" rules/development-workflow.md
