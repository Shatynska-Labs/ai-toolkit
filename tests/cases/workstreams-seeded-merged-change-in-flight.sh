#!/usr/bin/env bash
# Scenario: A change whose work has merged is still in flight.
# Requirement: A workstream register is seeded where none exists.
# Change: define-what-a-step-is (project-bootstrap, MODIFIED).
#
# SPECIFIED: a step whose change is open on the trunk and whose branch's pull
# request has merged reads in flight, not done: the pull request counts toward
# done only where the trunk holds no change of the step's name, open or
# archived, and an open change of that name makes the step in flight.
# DERIVED (wording, design.md decision 1): "no change of that name, open or
# archived"; "a pull request from a branch of that name has merged"; "an open
# change of that name".
# DERIVED (placement, design.md decision 1): on the one precedence line (found
# by "the first of these that holds wins"), the no-change condition precedes
# the merged pull request it conditions, both stand before "in flight when",
# and "an open change of that name" follows "in flight when".
#
# Executes the tool and reads its output (second situation, as this suite
# classifies its seeded-text cases). Red at authoring on the property "the
# merged pull request is conditioned on no change of that name" (state 1: the
# tool runs and writes the 1.0.0 text); goes green as task 1.1 lands. The
# local helper is checked first against specimens it must accept and reject.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Discriminator for offset_in (tests/lib.sh).
[ "$(offset_in "ab in flight when cd" "in flight when")" = 4 ] \
  || { echo "FAIL: discriminator — offset_in misreports a present phrase" >&2; exit 1; }
[ "$(offset_in "ab cd" "in flight when")" = 0 ] \
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

cond_at="$(offset_in "$line" "no change of that name, open or archived")"
pr_at="$(offset_in "$line" "a pull request from a branch of that name has merged")"
flight_at="$(offset_in "$line" "in flight when")"
open_at="$(offset_in "$line" "an open change of that name")"
for pair in "no change of that name, open or archived:$cond_at" \
            "a pull request from a branch of that name has merged:$pr_at" \
            "in flight when:$flight_at" \
            "an open change of that name:$open_at"; do
  if [ "${pair##*:}" -eq 0 ]; then
    echo "FAIL: the precedence line does not name \"${pair%:*}\"" >&2
    printf '%s\n' "$line" >&2
    exit 1
  fi
done
if [ "$cond_at" -ge "$pr_at" ]; then
  echo "FAIL: the merged pull request is not conditioned on the trunk holding no change of that name, open or archived" >&2
  printf '%s\n' "$line" >&2
  exit 1
fi
if [ "$pr_at" -ge "$flight_at" ]; then
  echo "FAIL: the merged pull request does not stand in the done clause, before \"in flight when\"" >&2
  printf '%s\n' "$line" >&2
  exit 1
fi
if [ "$open_at" -le "$flight_at" ]; then
  echo "FAIL: an open change of that name is not what makes a step in flight" >&2
  printf '%s\n' "$line" >&2
  exit 1
fi
