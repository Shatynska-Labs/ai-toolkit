#!/usr/bin/env bash
# Scenario: The seeded block reads the none entries before writing none. Also
# the revised statement of "A project without a backlog receives the seeded
# file": the rule on `workstream`.
# Requirement: The backlog's rules are written where none exist.
# Change: propose-a-workstream-for-entries-sharing-a-goal (project-bootstrap,
# MODIFIED).
#
# SPECIFIED: the rule on `workstream` states that before `none` is written the
# other entries naming `none` are read for a goal they share with this one, that
# a workstream is proposed for one taking more than one change as the
# workstreams rules direct, and that `none` is written meanwhile.
# DERIVED (wording, design.md decision 3): each scan is one phrase of the
# sentence decision 3 adds; [directs] names `docs/workstreams/AGENTS.md`, as
# decision 3's text does.
#
# Not asserted: that a session makes the read. Conduct (design.md decision 10).
#
# Executes the tool and reads its output; every scan is discriminated by a
# mutant. Red at authoring (state 1: the tool runs and the rule states none of
# them); goes green as task 1.2 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

R=docs/backlog/AGENTS.md

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

# shellcheck disable=SC2016 # backticks are literal markdown in the regexes
{
scan require "$R" "" read-before-none 'before `none` is written, the other entries naming `none` are read for a goal they share with this one'
scan require "$R" "" more-than-one 'where they share one that takes more than one change, a workstream is proposed for it'
scan require "$R" "" directs 'as `docs/workstreams/agents[.]md` directs'
scan require "$R" "" meanwhile '`none` is written meanwhile'
}

mkdir -p "$TESTDIR/fixture/docs/backlog"
cat > "$TESTDIR/fixture/$R" <<'FIXTURE'
# Backlog

Otherwise it takes the open workstream whose Goal it serves; `none` is written only after that read finds none, or on the operator's word. Before `none` is written, the other entries naming `none` are read for a goal they share with this one; where they share one that takes more than one change, a workstream is proposed for it as `docs/workstreams/AGENTS.md` directs, and `none` is written meanwhile.
FIXTURE

seed_and_check
