#!/usr/bin/env bash
# Scenario: What a workstream holds is not progress. Also the added statement
# of "A project without a workstream register receives the seeded file":
# Context and Decisions say what is known and decided about the goal and never
# how far the work has come — a finding states what is true of the problem,
# not that a step found or did it, and neither names a step as done, in
# flight or merged.
# Requirement: A workstream register is seeded where none exists.
# Change: hold-shared-research-in-a-workstream (project-bootstrap, MODIFIED).
#
# SPECIFIED: the statement above.
# DERIVED (placement): the statement is one paragraph, one line (AGENTS.md),
# selected by "context and decisions say"; every phrase is required on that
# line.
# DERIVED (wording): one phrase per clause, common to the requirement and
# design.md decision 7: "what is known and decided about the goal"; "never how
# far the work has come"; "what is true of the problem"; "not that a step
# found or did it"; "neither (section )?names a step" (the requirement says
# "neither names", the design "neither section names"); "done, in flight or
# merged".
#
# Executes the tool and reads its output (second situation). The scans are
# first discriminated over a conforming fixture (tests/cases/lib/line-scan.sh).
# Red at authoring (state 1: the tool runs and writes no such paragraph);
# goes green as task 1.1 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

line_select 'context and decisions say'
line_scan require known-decided 'what is known and decided about the goal'
line_scan require never-progress 'never how far the work has come'
line_scan require true-of-problem 'what is true of the problem'
line_scan require not-step-did 'not that a step found or did it'
line_scan require neither-names 'neither (section )?names a step'
line_scan require statuses 'done, in flight or merged'

fixture="$TESTDIR/fixture.md"
cat > "$fixture" <<'FIXTURE'
# Workstreams

Context and Decisions say what is known and decided about the goal, never how far the work has come. A finding states what is true of the problem, not that a step found or did it, and neither section names a step as done, in flight or merged.
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
  echo "FAIL: no paragraph of the seeded register says what Context and Decisions may say" >&2
  exit 1
fi
[ "$status" -eq 0 ] || exit 1
