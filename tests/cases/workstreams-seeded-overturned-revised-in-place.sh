#!/usr/bin/env bash
# Scenario: Overturned content is revised in place. Also the added statement
# of "A project without a workstream register receives the seeded file":
# Context and Decisions state what is held now — where a change in the
# workstream overturns something they hold, it is revised in place, naming
# that change, in its plan commit or at the latest at its archive.
# Requirement: A workstream register is seeded where none exists.
# Change: hold-shared-research-in-a-workstream (project-bootstrap, MODIFIED).
#
# SPECIFIED: the statement above.
# DERIVED (placement): the statement is one paragraph, one line (AGENTS.md),
# selected by "state what is held now"; every phrase is required on that line.
# DERIVED (wording): one phrase per clause, common to the requirement and
# design.md decision 7: "a change in the workstream overturns"; "in place";
# "nam(e|ing) that change" (the design says "name", the requirement
# "naming"); "plan commit"; "at the latest at its archive".
# Not asserted: "The file's history keeps what was held before" — in design.md
# decision 7's text and the requirement's rationale, not among the statements
# the created file is required to carry.
#
# Executes the tool and reads its output (second situation). The scans are
# first discriminated over a conforming fixture (tests/cases/lib/line-scan.sh).
# Red at authoring (state 1: the tool runs and writes no such paragraph);
# goes green as task 1.1 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

line_select 'state what is held now'
line_scan require change-overturns 'a change in the workstream overturns'
line_scan require in-place 'in place'
line_scan require names-change 'nam(e|ing) that change'
line_scan require plan-commit 'plan commit'
line_scan require at-archive 'at the latest at its archive'

fixture="$TESTDIR/fixture.md"
cat > "$fixture" <<'FIXTURE'
# Workstreams

Context and Decisions state what is held now. Where a change in the workstream overturns something they hold, revise it in place and name that change, in its plan commit or at the latest at its archive. The file's history keeps what was held before.
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
  echo "FAIL: no paragraph of the seeded register says Context and Decisions state what is held now" >&2
  exit 1
fi
[ "$status" -eq 0 ] || exit 1
