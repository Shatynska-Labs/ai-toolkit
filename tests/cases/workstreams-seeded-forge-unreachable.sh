#!/usr/bin/env bash
# Scenario: A fix step without the forge. Also the revised status statement of
# "A project without a workstream register receives the seeded file": a
# session that cannot reach the forge says so rather than reading as planned a
# step a merged pull request could make done.
# Requirement: A workstream register is seeded where none exists.
# Change: define-what-a-step-is (project-bootstrap, MODIFIED).
#
# SPECIFIED: where the forge cannot be reached, the seeded file directs a
# session to say so rather than read the step as planned.
# DERIVED (wording, design.md decision 1): "forge cannot be reached"; "say
# so"; "rather than reading as planned".
# DERIVED (placement, design.md decision 1: "one sentence after the
# lookups"): the sentence is on the precedence line (found by "the first of
# these that holds wins"), after "planned otherwise".
#
# Executes the tool and reads its output (second situation, as this suite
# classifies its seeded-text cases). Red at authoring on the property "the
# file says what to do when the forge cannot be reached" (state 1: the tool
# runs and writes the 1.0.0 text); goes green as task 1.1 lands. The helper,
# offset_in from tests/lib.sh, is checked first against specimens it must accept and reject.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Discriminator for offset_in (tests/lib.sh).
[ "$(offset_in "ab say so cd" "say so")" = 4 ] \
  || { echo "FAIL: discriminator — offset_in misreports a present phrase" >&2; exit 1; }
[ "$(offset_in "ab cd" "say so")" = 0 ] \
  || { echo "FAIL: discriminator — offset_in reports an absent phrase" >&2; exit 1; }

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
bash "$PROJECT_INIT" >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"

r="$work/docs/workstreams/AGENTS.md"
assert_file "$r" "the seeded file this case reads"

line="$(grep -F 'the first of these that holds wins' "$r" | head -n1)"
if [ -z "$line" ]; then
  echo "FAIL: the seeded register states no first-match precedence for a step's status" >&2
  exit 1
fi
printf '%s\n' "$line" > "$TESTDIR/precedence.txt"

assert_contains "$TESTDIR/precedence.txt" "forge cannot be reached" "names the forge being unreachable"
assert_contains "$TESTDIR/precedence.txt" "say so" "directs saying so"
assert_contains "$TESTDIR/precedence.txt" "rather than reading as planned" "rather than reading the step as planned"

planned_at="$(offset_in "$line" "planned otherwise")"
forge_at="$(offset_in "$line" "forge cannot be reached")"
if [ "$planned_at" -eq 0 ] || [ "$forge_at" -le "$planned_at" ]; then
  echo "FAIL: the forge sentence does not follow the lookups (\"planned otherwise\")" >&2
  printf '%s\n' "$line" >&2
  exit 1
fi
