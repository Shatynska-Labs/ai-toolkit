#!/usr/bin/env bash
# No scenario of its own: The review shares a change review's severity and
# verdict, its paragraph on evidence.
# Change: review-a-workstream-against-its-goal (workstream-review, ADDED).
#
# SPECIFIED: every conclusion declares its evidence, in the order the text of
# the workstream and the rules file, then a step's artifacts or a document a
# Decision points to, then logical inference.
# DERIVED (operationalisation and placement, design.md decision 1's section
# *How you weigh evidence*): the section under the first heading naming
# `evidence` holds `rules file`, `artifact` and `inference`, and the three
# appear in that order (first occurrence of each).
#
# Not asserted: that a report declares a level per conclusion. Conduct.
#
# Static read (third situation); every scan and the order are discriminated.
# Red at authoring (state 2: the agent does not exist yet).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

A=agents/workstream-reviewer.md
scan require "$A" evidence level-one 'rules file'
scan require "$A" evidence level-two 'artifact'
scan require "$A" evidence level-three 'inference'

# Local arrangement (test-plan.md, Missing shared arrangement: in_order).
# in_order ROOT: 0 where the section's first `rules file`, `artifact` and
# `inference` stand in that order; 1 with [order] otherwise; 2 if unreadable.
in_order() {
  local text a b c
  text="$(scan_text "$1" "$A" evidence | tr '[:upper:]' '[:lower:]' | tr '\n' ' ')"
  [ -n "$text" ] || return 2
  a="$(awk -v t="$text" 'BEGIN { print index(t, "rules file") }')"
  b="$(awk -v t="$text" 'BEGIN { print index(t, "artifact") }')"
  c="$(awk -v t="$text" 'BEGIN { print index(t, "inference") }')"
  if [ "$a" -gt 0 ] && [ "$a" -lt "$b" ] && [ "$b" -lt "$c" ]; then return 0; fi
  echo "[order] the evidence levels are not stated in order (rules file $a, artifact $b, inference $c)" >&2
  return 1
}

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/agents"
cat > "$fixture/$A" <<'FIXTURE'
---
name: workstream-reviewer
---

## How you weigh evidence

First the workstream's text and the rules file; then a step's artifact or a document a Decision points to; then inference.
FIXTURE

in_order "$fixture" 2>/dev/null || { echo "FAIL: discriminator — [order] rejected the conforming fixture" >&2; exit 1; }
mkdir -p "$TESTDIR/swapped/agents"
sed 's/the rules file; then a step.s artifact/a step'"'"'s artifact; then the rules file/' "$fixture/$A" > "$TESTDIR/swapped/$A"
out="$(in_order "$TESTDIR/swapped" 2>&1)"; st=$?
if [ "$st" -ne 1 ] || case "$out" in *"[order]"*) false ;; *) true ;; esac; then
  echo "FAIL: discriminator — [order] passed levels out of order (status $st): $out" >&2
  exit 1
fi

scan_discriminate "$fixture" || exit 1
scan_check "$TOOLKIT_ROOT"
st=$?
if [ "$st" -eq 2 ]; then echo "FAIL: target absent — what this case reads does not exist yet" >&2; exit 1; fi
[ "$st" -eq 0 ] || exit 1
in_order "$TOOLKIT_ROOT" || exit 1
