#!/usr/bin/env bash
# Scenario: A project without a workstream register receives the seeded file
# — the revised edit statement: the file is edited only when the plan or what
# it holds changes — a step added, removed, reordered or renamed, what
# finishes it or what is out of scope revised, an open question added or
# answered, context or a decision added or revised, or the workstream
# archived.
# Requirement: A workstream register is seeded where none exists.
# Change: hold-shared-research-in-a-workstream (project-bootstrap, MODIFIED).
#
# SPECIFIED: the edit statement names the plan or what it holds as what
# changes, and lists context or a decision added or revised among the events,
# beside a step added/removed/reordered/renamed, an open question added or
# answered, and the workstream archived.
# DERIVED (placement): the statement is one paragraph, written as one line
# (AGENTS.md: prose is not hard-wrapped), selected by "edit the file only
# when"; every phrase is required on that line.
# DERIVED (wording): one stable phrase per clause, common to the requirement
# and design.md decision 7: "the plan or what it holds changes"; "context or a
# decision added or revised"; "added, removed, reordered or renamed"; "open
# question added or answered"; "workstream archived".
#
# Executes the tool and reads its output (second situation). The scans are
# first discriminated over a conforming fixture (tests/cases/lib/line-scan.sh).
# Red at authoring on the property "the edit statement covers what the file
# holds" (state 1: the tool writes "only when the plan changes"); goes green as
# task 1.1 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

line_select 'edit the file only when'
line_scan require plan-or-holds 'the plan or what it holds changes'
line_scan require context-decision 'context or a decision added or revised'
line_scan require step-events 'added, removed, reordered or renamed'
line_scan require open-question 'open question added or answered'
line_scan require archived 'workstream archived'

fixture="$TESTDIR/fixture.md"
cat > "$fixture" <<'FIXTURE'
# Workstreams

Edit the file only when the plan or what it holds changes: a step added, removed, reordered or renamed, the Done when or what is out of scope revised, an open question added or answered, context or a decision added or revised, or the workstream archived.
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
  echo "FAIL: the seeded register carries no edit statement this case can read" >&2
  exit 1
fi
[ "$status" -eq 0 ] || exit 1
