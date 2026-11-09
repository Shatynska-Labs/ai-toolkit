#!/usr/bin/env bash
# Scenario: The seeded block directs proposing a workstream. Also the revised
# statement of "A project without a workstream register receives the seeded
# file" on opening a workstream.
# Requirement: A workstream register is seeded where none exists.
# Change: propose-a-workstream-for-entries-sharing-a-goal (project-bootstrap,
# MODIFIED).
#
# SPECIFIED: the block states that opening a workstream is the operator's
# decision; that a session finding a goal no open workstream holds, shared by
# changes it proposes or by backlog entries naming `none`, proposes opening one
# to the operator, naming those changes and entries and a draft Goal, and opens
# none unasked; and that a goal one change meets is not proposed.
# DERIVED (wording, design.md decision 1): each scan is one phrase of that
# paragraph. [operator-decides] is already stated and held because the revised
# text keeps it verbatim (also pinned by workstreams-seeded-statements.sh).
#
# Not asserted: that a session finds such a goal and proposes it. Conduct
# (design.md decision 10).
#
# Executes the tool and reads its output; every scan is discriminated by a
# mutant. Red at authoring on every scan but [operator-decides] (state 1: the
# tool runs and the rule states none of the others); goes green as task 1.1
# lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

R=docs/workstreams/AGENTS.md

# Local arrangement (test-plan.md, Missing shared arrangement: seed_and_check).
# Discriminates every scan on the fixture, runs project-init in a fresh
# directory, then holds the seeded file to the scans.
seed_and_check() {
  local work="$TESTDIR/work" st
  scan_discriminate "$TESTDIR/fixture" || exit 1
  mkdir -p "$work"
  (cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
  scan_check "$work"
  st=$?
  [ "$st" -ne 2 ] || echo "FAIL: target absent — project-init seeded no $R" >&2
  [ "$st" -eq 0 ] || exit 1
}

scan require "$R" "" operator-decides 'open a workstream when the operator decides a goal needs more than one change'
scan require "$R" "" no-open-holds 'finds such a goal that no open workstream holds'
# shellcheck disable=SC2016 # backticks are literal markdown in the regex
scan require "$R" "" shared-by 'shared by changes it proposes or by backlog entries naming `none`'
scan require "$R" "" proposes-to-operator 'proposes opening one to the operator'
scan require "$R" "" names-draft 'naming those changes and entries and a draft goal'
scan require "$R" "" none-unasked 'opens none unasked'
scan require "$R" "" one-change-not-proposed 'a goal one change meets is not proposed'

mkdir -p "$TESTDIR/fixture/docs/workstreams"
cat > "$TESTDIR/fixture/$R" <<'FIXTURE'
# Workstreams

Open a workstream when the operator decides a goal needs more than one change. A session that finds such a goal that no open workstream holds, shared by changes it proposes or by backlog entries naming `none`, proposes opening one to the operator, naming those changes and entries and a draft Goal, and opens none unasked; a goal one change meets is not proposed. Commit it with the plan of the first change that advances it, or as work too small to be a change.
FIXTURE

seed_and_check
