#!/usr/bin/env bash
# Scenario: Research shared by several steps has a place in the workstream.
# Also the added statement of "A project without a workstream register
# receives the seeded file": besides its plan a workstream holds what its
# steps share — under `## Context`, the research, findings and options
# considered that the goal was planned from, with why one option was chosen;
# under `## Decisions`, the decisions that shape more than one step or were
# taken before any step's proposal existed, each with who took it, when and
# why, a decision already recorded in a change's design pointed to rather
# than copied.
# Requirement: A workstream register is seeded where none exists.
# Change: hold-shared-research-in-a-workstream (project-bootstrap, MODIFIED).
#
# SPECIFIED: the statement above; and that the file "does not direct it to a
# separate document or keep the workstream short".
# DERIVED (placement): the statement is one paragraph, one line (AGENTS.md),
# selected by "besides its plan"; every phrase is required on that line.
# DERIVED (wording): one phrase per clause, common to the requirement and
# design.md decision 7: "`## context`", "research", "findings", "options
# considered", "why one option was chosen", "`## decisions`", "more than one
# step", "before any step's proposal existed", "who took it", "pointed to
# rather than copied".
# DERIVED (operationalisation of the negative clause): the whole file carries
# neither "keep a workstream short" nor "belong in a document" — the two
# phrases of the paragraph this change replaces ("Keep a workstream short ...
# Lasting decisions belong in a document or a change's design that the file
# points to"). A redirection to a separate document worded otherwise is not
# reached; verified by reading.
#
# Executes the tool and reads its output (second situation). The scans are
# first discriminated over conforming fixtures (tests/cases/lib/line-scan.sh
# and tests/cases/lib/static-scan.sh). Red at authoring on the property "the
# seeded file states where shared research goes" (state 1: the tool runs and
# writes no line saying "besides its plan", and still writes "Keep a
# workstream short"); goes green as task 1.1 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

line_select 'besides its plan'
# shellcheck disable=SC2016 # backticks are literal markdown, not expansions
line_scan require context-section '`## context`'
line_scan require research 'research'
line_scan require findings 'findings'
line_scan require options 'options considered'
line_scan require why-chosen 'why one option was chosen'
# shellcheck disable=SC2016 # backticks are literal markdown, not expansions
line_scan require decisions-section '`## decisions`'
line_scan require several-steps 'more than one step'
line_scan require before-proposal "before any step's proposal existed"
line_scan require who-when-why 'who took it'
line_scan require pointed-to 'pointed to rather than copied'

R=docs/workstreams/AGENTS.md
scan forbid "$R" "" short 'keep a workstream short' "Keep a workstream short: its goal, what finishes it and its steps."
scan forbid "$R" "" separate-document 'belong in a document' "Lasting decisions belong in a document or a change's design that the file points to."

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/docs/workstreams"
cat > "$fixture/$R" <<'FIXTURE'
# Workstreams

Besides its plan, a workstream holds what its steps share. Under `## Context` go the research, findings and options considered that the goal was planned from, with why one option was chosen. Under `## Decisions` go the decisions that shape more than one step, or were taken before any step's proposal existed, each with who took it, when and why; a decision already recorded in a change's design may be pointed to rather than copied. A decision that shapes one step only belongs in that step's design, which points to the workstream for what it shares rather than copying it.

Keep this file when there is no workstream.
FIXTURE
line_discriminate "$fixture/$R" || exit 1
scan_discriminate "$fixture" || exit 1

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
bash "$PROJECT_INIT" >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"

r="$work/$R"
assert_file "$r" "the seeded file this case reads"

fail=0
line_check "$r"
status=$?
if [ "$status" -eq 2 ]; then
  echo "FAIL: no paragraph of the seeded register states what a workstream holds besides its plan" >&2
  fail=1
elif [ "$status" -ne 0 ]; then
  fail=1
fi
scan_check "$work" || fail=1
exit "$fail"
