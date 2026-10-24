#!/usr/bin/env bash
# Scenarios (mechanical half only): The row names the workstream first; The
# report is a row, not a paragraph (as revised: the fixed order now begins
# with the workstream).
# Requirement: A session reports where its change stands before acting.
# Change: add-workstreams (session-workflow, MODIFIED).
#
# SPECIFIED: the row's cells, in order, begin with the workstream, then the
# change's name, then its stage.
# DERIVED (design.md decision 13): the fragment's row template is
# `| <workstream> | <change> | <stage> | ...` and its example row is
# `| none | some-change | plan:explore | ...`; the v10 template and example,
# whose first cell is the change, are gone (`| <change> |` or
# `| some-change |` opening a row, at a line start or after a backtick).
#
# Not asserted: that a session fills the cell from the right source, or
# prints `none` for a change advancing none. Conduct; the source order is
# workflow-fragment-status-row-workstream-source.sh.
#
# Static read: red until the row lands; every scan is discriminated by a
# mutant in scan_discriminate.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

F=rules/development-workflow.md
scan require "$F" "" row-template '[|] <workstream> [|] <change> [|] <stage> [|]'
scan require "$F" "" example-row '[|] none [|] some-change [|] plan:explore [|]'
# shellcheck disable=SC2016 # backticks are literal markdown in the pattern and specimen
scan forbid "$F" "" old-row-template '(^|`)[|] <change> [|]' '`| <change> | <stage> | <task progress> | <commits> |`'
# shellcheck disable=SC2016 # backticks are literal markdown in the pattern and specimen
scan forbid "$F" "" old-example-row '(^|`)[|] some-change [|]' '`| some-change | plan:explore | 0/0 | 1 |`'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/rules"
cat > "$fixture/$F" <<'FIXTURE'
# Workflow

On entering a working tree, report the change's status as one row: `| <workstream> | <change> | <stage> | <task progress> | <commits> |`

For example: `| none | some-change | plan:explore | 0/0 | 1 |`
FIXTURE

scan_run "$fixture"
