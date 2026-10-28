#!/usr/bin/env bash
# Scenario (mechanical half only): Archiving the last step archives the
# workstream.
# Requirement: A change states the workstream it advances, and archiving
# re-reads it. Change: add-workstreams (session-workflow, ADDED).
#
# SPECIFIED: the archive step directs, where the change advanced a
# workstream, re-reading it: placing the entries attached to it, revising the
# steps the change made obsolete, and archiving it once what finishes it
# holds, as `docs/workstreams/AGENTS.md` directs, in the commit that carries
# the record.
# DERIVED (operationalisation and placement, design.md decision 10): one
# paragraph (line) carries `docs/workstreams/AGENTS.md` and `advanced`, and
# states `re-read`, `entries`, `steps`, "archive (it|the workstream)" and
# "same commit" or "commit that carries the record".
#
# Not asserted: that the paragraph sits in the archive step, and that a
# session archives the workstream. Verified by reading; conduct.
#
# Static read: red until the sentence lands (status 2); discriminated by a
# mutant per scan in line_discriminate.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

line_select 'docs/workstreams/agents[.]md'
line_select 'advanced'
line_scan require reread 're-?read'
line_scan require place-entries 'entries'
line_scan require revise-steps 'steps'
line_scan require archive-workstream 'archive (it|the workstream)'
line_scan require same-commit 'same commit|commit that carries the record'

fixture="$TESTDIR/fragment.md"
cat > "$fixture" <<'FIXTURE'
# Workflow

**archive** — re-read `docs/backlog.md` for the entries this change completed.

Where the change advanced a workstream, re-read it the same way: place the entries attached to it, revise the steps the change made obsolete, and archive it once what finishes it holds, as `docs/workstreams/AGENTS.md` directs, in the same commit.
FIXTURE

line_run "$fixture" rules/development-workflow.md
