#!/usr/bin/env bash
# Scenario (mechanical half only): A report is complete.
# Requirement: The report has a declared structure.
# Change: review-a-workstream-against-its-goal (workstream-review, ADDED).
#
# SPECIFIED: the report holds, in order, an executive summary, a Goal
# coverage matrix, the findings on Done when, Decisions, Not in scope and
# progress, an issues matrix, and exactly one recommended action.
# DERIVED (operationalisation and placement, design.md decision 1's section
# *Your report*): the section under the first heading naming `report` holds
# `executive summary`, `coverage matrix`, `done when`, `issues matrix` and
# `recommended action`, and the first occurrence of each stands in that order.
# A section mentioning a later element before an earlier one in passing fails
# here, which is a derived assertion to reconsider.
#
# Not asserted: that a produced report follows the structure. Conduct.
#
# Static read (third situation); every scan and the order are discriminated.
# Red at authoring (state 2: the agent does not exist yet).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

A=agents/workstream-reviewer.md
PARTS=('executive summary' 'coverage matrix' 'done when' 'issues matrix' 'recommended action')
for p in "${PARTS[@]}"; do
  scan require "$A" report "${p// /-}" "$p"
done

# Local arrangement (test-plan.md, Missing shared arrangement: in_order).
# in_order ROOT: 0 where the first occurrences of PARTS ascend; 1 with [order]
# otherwise; 2 where the section cannot be read.
in_order() {
  local text p at last=0
  text="$(scan_text "$1" "$A" report | tr '[:upper:]' '[:lower:]' | tr '\n' ' ')"
  [ -n "$text" ] || return 2
  for p in "${PARTS[@]}"; do
    at="$(awk -v t="$text" -v p="$p" 'BEGIN { print index(t, p) }')"
    if [ "$at" -le "$last" ]; then
      echo "[order] '$p' does not follow the part before it" >&2
      return 1
    fi
    last="$at"
  done
  return 0
}

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/agents"
cat > "$fixture/$A" <<'FIXTURE'
---
name: workstream-reviewer
---

## Your report

1. An executive summary.
2. The Goal coverage matrix.
3. The findings on Done when, Decisions, Not in scope and progress.
4. The issues matrix, most severe first.
5. Exactly one recommended action, justified in two or three sentences.
FIXTURE

in_order "$fixture" 2>/dev/null || { echo "FAIL: discriminator — [order] rejected the conforming fixture" >&2; exit 1; }
mkdir -p "$TESTDIR/swapped/agents"
awk '/^2[.]/ { hold = $0; next } { print } /^3[.]/ { print hold }' "$fixture/$A" > "$TESTDIR/swapped/$A"
out="$(in_order "$TESTDIR/swapped" 2>&1)"; st=$?
if [ "$st" -ne 1 ] || case "$out" in *"[order]"*) false ;; *) true ;; esac; then
  echo "FAIL: discriminator — [order] passed a report out of order (status $st): $out" >&2
  exit 1
fi

scan_discriminate "$fixture" || exit 1
scan_check "$TOOLKIT_ROOT"
st=$?
if [ "$st" -eq 2 ]; then echo "FAIL: target absent — what this case reads does not exist yet" >&2; exit 1; fi
[ "$st" -eq 0 ] || exit 1
in_order "$TOOLKIT_ROOT" || exit 1
