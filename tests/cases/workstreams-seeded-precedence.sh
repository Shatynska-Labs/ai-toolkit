#!/usr/bin/env bash
# Scenario: A step matching two sources takes the first status.
# Requirement: A workstream register is seeded where none exists.
# Change: add-workstreams (project-bootstrap, ADDED).
#
# SPECIFIED: the seeded file's precedence makes a step whose change is open on
# the trunk and whose backlog entry survives `in flight`, not `recorded`: the
# statuses are tried done, in flight, recorded, planned, "the first that
# holds winning".
# DERIVED (placement and wording, design.md decision 8): the precedence is one
# paragraph (line) carrying "the first of these that holds wins", in which
# "done when", "in flight when", "recorded when" and "planned otherwise"
# appear in that order.
#
# Executes the tool and reads its output; no fixture owed. Red until the
# concern lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

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
prev=0
for phrase in "done when" "in flight when" "recorded when" "planned otherwise"; do
  pos="$(awk -v l="$line" -v p="$phrase" 'BEGIN { print index(l, p) }')"
  if [ "$pos" -eq 0 ]; then
    echo "FAIL: the precedence statement does not name \"$phrase\"" >&2
    printf '%s\n' "$line" >&2
    exit 1
  fi
  if [ "$pos" -le "$prev" ]; then
    echo "FAIL: \"$phrase\" is out of order in the precedence statement (done, in flight, recorded, planned)" >&2
    printf '%s\n' "$line" >&2
    exit 1
  fi
  prev="$pos"
done
