#!/usr/bin/env bash
# Scenario: Step order is not a dependency.
# Requirement: A workstream register is seeded where none exists.
# Change: add-workstreams (project-bootstrap, ADDED).
#
# SPECIFIED: the seeded file states that list order gates nothing and directs
# a session asking whether a step may start to that step's backlog entry's
# Waits on.
# DERIVED (placement and wording, design.md decision 8): one paragraph (line)
# carries "gates nothing", "Waits on" and "backlog entry".
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

r="$work/docs/workstreams/README.md"
assert_file "$r" "the seeded file this case reads"

line="$(grep -F 'gates nothing' "$r")"
if [ -z "$line" ]; then
  echo "FAIL: the seeded register does not state that step order gates nothing" >&2
  exit 1
fi
for phrase in "Waits on" "backlog entry"; do
  if ! printf '%s\n' "$line" | grep -q -F -- "$phrase"; then
    echo "FAIL: the order statement does not direct the reader to the step's $phrase" >&2
    printf '%s\n' "$line" >&2
    exit 1
  fi
done
