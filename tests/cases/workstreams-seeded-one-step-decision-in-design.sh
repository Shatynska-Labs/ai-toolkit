#!/usr/bin/env bash
# Scenario: A decision for one step stays in that step's design. Also the
# added statement of "A project without a workstream register receives the
# seeded file": a decision shaping one step only belongs in that step's
# design, which points to the workstream for what it shares rather than
# copying it.
# Requirement: A workstream register is seeded where none exists.
# Change: hold-shared-research-in-a-workstream (project-bootstrap, MODIFIED).
#
# SPECIFIED: the statement above.
# DERIVED (placement): the statement is on one line (AGENTS.md: one paragraph
# per line), selected by "shapes one step only"; every phrase is required on
# that line.
# DERIVED (wording): one phrase per clause, common to the requirement and
# design.md decision 7: "that step's design"; "points to the workstream for
# what it shares"; "rather than copying it".
#
# Executes the tool and reads its output (second situation). The scans are
# first discriminated over a conforming fixture (tests/cases/lib/line-scan.sh).
# Red at authoring (state 1: the tool runs and writes no such paragraph);
# goes green as task 1.1 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

line_select 'shapes one step only'
line_scan require step-design "that step's design"
line_scan require points-to 'points to the workstream for what it shares'
line_scan require not-copied 'rather than copying it'

fixture="$TESTDIR/fixture.md"
cat > "$fixture" <<'FIXTURE'
# Workstreams

A decision that shapes one step only belongs in that step's design, which points to the workstream for what it shares rather than copying it.
FIXTURE
line_discriminate "$fixture" || exit 1

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
bash "$PROJECT_INIT" >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"

r="$work/docs/workstreams/AGENTS.md"
assert_file "$r" "the seeded file this case reads"

line_check "$r"
status=$?
if [ "$status" -eq 2 ]; then
  echo "FAIL: no paragraph of the seeded register says where a decision shaping one step only belongs" >&2
  exit 1
fi
[ "$status" -eq 0 ] || exit 1
