#!/usr/bin/env bash
# Scenario (mechanical half only): The archive re-read names the entries no step
# names.
# Requirement: A change states the workstream it advances, and archiving re-reads
# it. Change: match-backlog-entries-to-a-workstream (session-workflow, MODIFIED).
#
# SPECIFIED: the archive step directs placing the entries that name the workstream
# and that no step names, and names no entry field in saying so. Both forms.
# DERIVED (selection, as workflow-fragment-archive-workstream-reread.sh reads it):
# the paragraph carrying `docs/workstreams/AGENTS.md` and `advanced`.
# DERIVED (wording, design.md decision 5): "place the entries that name it and that
# no step names"; "attached to it" gone; no backticked `workstream` on the line,
# the form the handoff proposed and decision 5 refused.
#
# Not asserted: that a session places them. Conduct.
#
# Static read (third situation); every scan is discriminated by a mutant. Red at
# authoring on [names-unplaced] and [not-attached] (state 1 on real content); goes
# green as task 1.3 lands. [no-field] passes today: its target carries the property.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

# Local arrangement (test-plan.md, Missing shared arrangement: check_both_forms).
# Discriminates on the fixture, then holds both fragments to the scans.
check_both_forms() {
  local rel st status=0
  line_discriminate "$1" || exit 1
  for rel in rules/development-workflow.md rules/development-workflow-direct.md; do
    line_check "$TOOLKIT_ROOT/$rel"
    st=$?
    [ "$st" -ne 2 ] || echo "FAIL: target absent — $rel has no paragraph this case reads" >&2
    [ "$st" -eq 0 ] || status=1
  done
  exit "$status"
}

line_select 'docs/workstreams/agents[.]md'
line_select 'advanced'
line_scan require names-unplaced 'place the entries that name it and that no step names'
line_scan forbid not-attached 'attached to it' 'Place the entries attached to it.'
# shellcheck disable=SC2016 # backticks are literal markdown in the regex and specimen
line_scan forbid no-field '`workstream`' 'Every entry whose `workstream` names it.'

fixture="$TESTDIR/fragment.md"
cat > "$fixture" <<'FIXTURE'
# Workflow

Where the change advanced a workstream, re-read it the same way: place the entries that name it and that no step names, revise the steps the change made obsolete, and archive it once what finishes it holds, as `docs/workstreams/AGENTS.md` directs, in the commit that carries the record.
FIXTURE

check_both_forms "$fixture"
