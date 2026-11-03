#!/usr/bin/env bash
# Scenarios (mechanical half only): Opening a workstream; A step is added; A
# burst of placements; What a step does changes; A Decision or Not in scope is
# revised; An edit that leaves the plan alone; A workstream is archived; The
# rule holds in both forms (its first half).
# Requirement: A workstream is reviewed when it is opened and when its plan
# changes. Change: review-a-workstream-against-its-goal (session-workflow, ADDED).
#
# SPECIFIED: under Throughout, both fragments direct an independent review of
# what the steps reach, agree with and leave out and of whether what finishes
# the workstream can be observed, before the commit opening it and before one
# adding or removing a step, changing what a step does, or changing what it is
# for, what finishes it, what it leaves out or what it has decided, whether or
# not the edit belongs to a change; one review per commit; none for renaming,
# reordering, adding to what it knows, or archiving; no stage added.
# DERIVED (operationalisation, design.md decision 5's text): the paragraph is
# the line under `### Throughout` holding `workstream` and `independent
# reviewer`; one phrase of the design's text per scan. "In the same words" in
# both forms is read as both passing the same scans; that the two are
# byte-identical outside ship is workflow-fragments-differ-only-in-ship.sh's.
#
# Not asserted: that a session dispatches the review before such a commit, or
# skips it for a rename. Conduct.
#
# Static read (third situation); every scan is discriminated by a mutant, and
# placement by a fixture with the paragraph under plan. Red at authoring
# (state 2: neither fragment holds the paragraph).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

# Local arrangement (test-plan.md, Missing shared arrangement: throughout_of,
# check_throughout_both_forms). throughout_of FILE: the `### Throughout`
# section, up to the next heading of level three or higher.
throughout_of() {
  awk '/^##?#? / { in_t = ($0 == "### Throughout"); next } in_t { print }' "$1"
}
# check_throughout_both_forms FIXTURE: discriminates the scans on FIXTURE (a
# section), shows a paragraph outside Throughout is not read, then holds both
# fragments' Throughout sections to the scans.
check_throughout_both_forms() {
  local rel st status=0 out
  line_discriminate "$1" || exit 1
  { printf "### plan\n\n"; cat "$1"; printf "\n### Throughout\n\nOther rules.\n"; } > "$TESTDIR/misplaced.md"
  throughout_of "$TESTDIR/misplaced.md" > "$TESTDIR/misplaced.section"
  out="$(line_check "$TESTDIR/misplaced.section" 2>&1)"; st=$?
  [ "$st" -eq 2 ] || { echo "FAIL: discriminator — a paragraph under plan was read as under Throughout (status $st): $out" >&2; exit 1; }
  for rel in rules/development-workflow.md rules/development-workflow-direct.md; do
    throughout_of "$TOOLKIT_ROOT/$rel" > "$TESTDIR/section"
    line_check "$TESTDIR/section"
    st=$?
    [ "$st" -ne 2 ] || echo "FAIL: target absent — $rel has no such paragraph under Throughout" >&2
    [ "$st" -eq 0 ] || status=1
  done
  exit "$status"
}

line_select 'workstream'
line_select 'independent reviewer'
line_scan require reach-goal 'reach what it is for'
line_scan require agree-decisions 'agree with what it has decided'
line_scan require leave-out 'leaves? out what it leaves out'
line_scan require observable 'can be observed|observable'
line_scan require opening 'before the commit that opens it'
line_scan require step-added 'adds or removes a step'
line_scan require step-does 'changes what a step does'
line_scan require goal-or-finish 'changes[^.]*what (the workstream|it) is for'
line_scan require done-when-revised 'changes[^.]*what finishes it'
line_scan require decision-revised 'changes[^.]*what it has decided'
line_scan require not-in-scope-revised 'changes[^.]*what it leaves out'
line_scan require outside-a-change 'whether or not the edit belongs to a change'
line_scan require burst-one-review 'one review'
line_scan require rename-none 'renam'
line_scan require reorder-none 'reorder'
line_scan require knows-none 'what the workstream knows'
line_scan require archive-none 'archiv'
line_scan require takes-none 'takes? none'
line_scan require no-stage 'no stage'

fixture="$TESTDIR/section.md"
cat > "$fixture" <<'FIXTURE'

**Commits.** Prefer small commits.

**A workstream's plan.** An independent reviewer checks that a workstream's steps reach what it is for, agree with what it has decided and leave out what it leaves out, and that what finishes it can be observed. This happens before the commit that opens it, and before a commit whose edit adds or removes a step, changes what a step does, or changes what the workstream is for, what finishes it, what it leaves out or what it has decided, whether or not the edit belongs to a change. A commit holding several such edits takes one review. Renaming or reordering steps, adding to what the workstream knows, and archiving it take none, and it adds no stage to a change. Fix and re-review until the verdict permits proceeding, bounded at six rounds; on reaching it, report where the loop stands and what is outstanding, and ask before continuing. A conditional pass is permission conditional on the fixes it names: apply them and continue without a further round. Where the reviewer judges the concept unsound rather than the plan defective, stop and raise it immediately, whatever the count. A fix that changes the plan's substance rather than its wording is the operator's to decide; where the operator decides to leave a defect, commit on that word and say so.

_Claude Code binding:_ dispatch `ai-toolkit:workstream-reviewer`. On `FIX REQUIRED` fix what is the session's to fix, take the rest to the operator, and re-dispatch unless the operator left what remains; on `CONDITIONALLY APPROVED` apply the `[MINOR]` fixes and continue; on `APPROVED` continue; on `REJECTED` stop and raise it.

**Assumptions.** Ask rather than guess.
FIXTURE

check_throughout_both_forms "$fixture"
