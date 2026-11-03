#!/usr/bin/env bash
# Scenario: The rule holds in both forms (the binding); and the requirement's
# binding paragraph, which no other scenario reaches.
# Requirement: A workstream is reviewed when it is opened and when its plan
# changes. Change: review-a-workstream-against-its-goal (session-workflow, ADDED).
#
# SPECIFIED: a Claude Code binding under the rule names
# `ai-toolkit:workstream-reviewer` and states what the session does on each of
# the four verdicts. Both forms. That the named agent is shipped is
# workflow-fragment-names-shipped-assets.sh's and
# workflow-fragments-no-dangling-either-form.sh's.
# DERIVED (operationalisation, design.md decision 5's binding): the binding is
# the line under `### Throughout` opening `_Claude Code binding:_` and naming
# the agent; each act is read between `on <verdict>` and the next semicolon:
# `FIX REQUIRED` takes the rest to the operator and re-dispatches,
# `CONDITIONALLY APPROVED` applies the `[MINOR]` fixes and continues,
# `APPROVED` continues, `REJECTED` stops.
#
# Not asserted: that a session acts on the verdict. Conduct.
#
# Static read (third situation); every scan is discriminated by a mutant. Red
# at authoring (state 2: neither fragment holds the binding).
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

line_select '^_claude code binding:_'
line_select 'ai-toolkit:workstream-reviewer'
# shellcheck disable=SC2016 # backticks are literal markdown in the patterns
{
  line_scan require fix-required-operator 'on `fix required`[^;]*operator'
  line_scan require fix-required-redispatch 'on `fix required`[^;]*re-?dispatch'
  line_scan require conditionally-approved 'on `conditionally approved`[^;]*[[]minor[]][^;]*continue'
  line_scan require approved 'on `approved`[^;]*continue'
  line_scan require rejected 'on `rejected`[^;]*stop'
}

fixture="$TESTDIR/section.md"
cat > "$fixture" <<'FIXTURE'

**Commits.** Prefer small commits.

**A workstream's plan.** An independent reviewer checks that a workstream's steps reach what it is for, agree with what it has decided and leave out what it leaves out, and that what finishes it can be observed. This happens before the commit that opens it, and before a commit whose edit adds or removes a step, changes what a step does, or changes what the workstream is for, what finishes it, what it leaves out or what it has decided, whether or not the edit belongs to a change. A commit holding several such edits takes one review. Renaming or reordering steps, adding to what the workstream knows, and archiving it take none, and it adds no stage to a change. Fix and re-review until the verdict permits proceeding, bounded at six rounds; on reaching it, report where the loop stands and what is outstanding, and ask before continuing. A conditional pass is permission conditional on the fixes it names: apply them and continue without a further round. Where the reviewer judges the concept unsound rather than the plan defective, stop and raise it immediately, whatever the count. A fix that changes the plan's substance rather than its wording is the operator's to decide; where the operator decides to leave a defect, commit on that word and say so.

_Claude Code binding:_ dispatch `ai-toolkit:workstream-reviewer`. On `FIX REQUIRED` fix what is the session's to fix, take the rest to the operator, and re-dispatch unless the operator left what remains; on `CONDITIONALLY APPROVED` apply the `[MINOR]` fixes and continue; on `APPROVED` continue; on `REJECTED` stop and raise it.

**Assumptions.** Ask rather than guess.
FIXTURE

check_throughout_both_forms "$fixture"
