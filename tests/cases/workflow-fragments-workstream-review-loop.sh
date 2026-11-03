#!/usr/bin/env bash
# Scenarios (mechanical half only): The loop is bounded; The operator leaves a
# defect.
# Requirement: A workstream is reviewed when it is opened and when its plan
# changes. Change: review-a-workstream-against-its-goal (session-workflow, ADDED).
#
# SPECIFIED: the rule bounds the loop at six rounds, reports where it stands
# and what is outstanding and asks before continuing at the bound; a
# conditional pass continues without a further round; a concept judged
# unsound exits at once; a fix changing the plan's substance is the
# operator's, and where the operator leaves a defect the session commits on
# that word and says so. Both forms.
# DERIVED (operationalisation, design.md decision 5's text): the paragraph is
# the line under `### Throughout` holding `workstream` and `independent
# reviewer`; one phrase per scan.
#
# Not asserted: that a session stops at six, or commits on the operator's
# word. Conduct.
#
# Static read (third situation); every scan is discriminated by a mutant. Red
# at authoring (state 2: neither fragment holds the paragraph).
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
line_scan require bound 'six rounds'
line_scan require outstanding 'what is outstanding'
line_scan require ask-at-bound 'ask before continuing'
line_scan require conditional-pass 'conditional pass'
line_scan require no-further-round 'without a further round'
line_scan require concept-unsound 'concept unsound'
line_scan require substance-operator 'substance[^.]*operator'
line_scan require commit-on-word 'commit on that word'
line_scan require say-so 'say so'

fixture="$TESTDIR/section.md"
cat > "$fixture" <<'FIXTURE'

**Commits.** Prefer small commits.

**A workstream's plan.** An independent reviewer checks that a workstream's steps reach what it is for, agree with what it has decided and leave out what it leaves out, and that what finishes it can be observed. This happens before the commit that opens it, and before a commit whose edit adds or removes a step, changes what a step does, or changes what the workstream is for, what finishes it, what it leaves out or what it has decided, whether or not the edit belongs to a change. A commit holding several such edits takes one review. Renaming or reordering steps, adding to what the workstream knows, and archiving it take none, and it adds no stage to a change. Fix and re-review until the verdict permits proceeding, bounded at six rounds; on reaching it, report where the loop stands and what is outstanding, and ask before continuing. A conditional pass is permission conditional on the fixes it names: apply them and continue without a further round. Where the reviewer judges the concept unsound rather than the plan defective, stop and raise it immediately, whatever the count. A fix that changes the plan's substance rather than its wording is the operator's to decide; where the operator decides to leave a defect, commit on that word and say so.

_Claude Code binding:_ dispatch `ai-toolkit:workstream-reviewer`. On `FIX REQUIRED` fix what is the session's to fix, take the rest to the operator, and re-dispatch unless the operator left what remains; on `CONDITIONALLY APPROVED` apply the `[MINOR]` fixes and continue; on `APPROVED` continue; on `REJECTED` stop and raise it.

**Assumptions.** Ask rather than guess.
FIXTURE

check_throughout_both_forms "$fixture"
