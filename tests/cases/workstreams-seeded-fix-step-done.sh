#!/usr/bin/env bash
# Scenario: A step taken as a fix reads as done. Also the revised status
# statement of "A project without a workstream register receives the seeded
# file": done where the freshly fetched trunk holds an archived change of that
# name, or where it holds no change of that name, open or archived, and a pull
# request from a branch of that name has merged — a step taken as a fix.
# Requirement: A workstream register is seeded where none exists.
# Change: define-what-a-step-is (project-bootstrap, MODIFIED).
#
# SPECIFIED: a merged pull request from a branch of the step's name is a
# source of `done`, for a step whose name is no change on the trunk, open or
# archived — a step taken as a fix — so the lookups make it done, not planned.
# DERIVED (wording, design.md decision 1): one stable phrase per clause:
# "no change of that name, open or archived"; "a pull request from a branch
# of that name has merged"; "taken as a fix".
# DERIVED (placement, design.md decision 1): the fix clause sits inside the
# done clause of the one precedence line (found by "the first of these that
# holds wins", as workstreams-seeded-precedence.sh finds it): after "done
# when" and before "in flight when".
#
# Executes the tool and reads its output (second situation, as this suite
# classifies its seeded-text cases). Red at authoring on the property "the
# done clause names a fix's merged pull request" (state 1: the tool runs and
# writes the 1.0.0 text); goes green as task 1.1 lands. The helper,
# offset_in from tests/lib.sh, is checked first against specimens it must accept and reject.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Discriminator for offset_in (tests/lib.sh).
[ "$(offset_in "ab done when cd" "done when")" = 4 ] \
  || { echo "FAIL: discriminator — offset_in misreports a present phrase" >&2; exit 1; }
[ "$(offset_in "ab cd" "done when")" = 0 ] \
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

assert_contains "$TESTDIR/precedence.txt" "no change of that name, open or archived" "the fix clause applies where the trunk holds no change of the step's name"
assert_contains "$TESTDIR/precedence.txt" "a pull request from a branch of that name has merged" "a merged pull request from a branch of the step's name"
assert_contains "$TESTDIR/precedence.txt" "taken as a fix" "the clause is how a step taken as a fix is done"

done_at="$(offset_in "$line" "done when")"
pr_at="$(offset_in "$line" "a pull request from a branch of that name has merged")"
flight_at="$(offset_in "$line" "in flight when")"
if [ "$done_at" -eq 0 ] || [ "$flight_at" -eq 0 ]; then
  echo "FAIL: the precedence line does not name \"done when\" and \"in flight when\"" >&2
  printf '%s\n' "$line" >&2
  exit 1
fi
if [ "$pr_at" -le "$done_at" ] || [ "$pr_at" -ge "$flight_at" ]; then
  echo "FAIL: the merged pull request is not a source of done: it does not stand between \"done when\" and \"in flight when\"" >&2
  printf '%s\n' "$line" >&2
  exit 1
fi
