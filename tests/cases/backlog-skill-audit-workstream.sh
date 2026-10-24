#!/usr/bin/env bash
# Scenario (mechanical half only): An entry names an archived workstream.
# Requirement: Audit verifies every entry independently and changes nothing
# without the operator. Change: add-workstreams (backlog-maintenance,
# MODIFIED).
#
# SPECIFIED: where the file's shape names Workstream, each agent says whether
# the workstream an entry names is open in `docs/workstreams/`; the report
# names each entry naming an archived or absent workstream among the stale
# facts.
# DERIVED (design.md decision 11, tasks.md 3.3): both are stated in
# skills/backlog/references/audit.md, each in one sentence: `workstream` with
# `open`; `workstream` with `archived` or `absent`.
#
# Not asserted: that the archived-or-absent entry is placed under the report's
# stale facts (the brief's report structure is not fixed by the spec), and
# that an agent finds it. Verified by reading; conduct.
#
# Static read: red until the brief lands; every scan is discriminated by a
# mutant in scan_discriminate.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

A=skills/backlog/references/audit.md
scan require "$A" "" ws-open-check 'workstream[^.]*open|open[^.]*workstream'
scan require "$A" "" ws-archived-or-absent 'workstream[^.]*(archived|absent)|(archived|absent)[^.]*workstream'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog/references"
cat > "$fixture/$A" <<'FIXTURE'
# Audit brief

Where the backlog's shape names Workstream, say whether the workstream an entry names is open in `docs/workstreams/`.

## Stale facts

An entry naming a workstream that is archived or absent.
FIXTURE

scan_run "$fixture"
