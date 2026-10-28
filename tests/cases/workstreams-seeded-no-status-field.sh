#!/usr/bin/env bash
# Scenario: The seeded register carries no status field.
# Requirement: A workstream register is seeded where none exists.
# Change: add-workstreams (project-bootstrap, ADDED).
#
# SPECIFIED: the workstream shape names Goal, Done when, Steps, Not in scope,
# Open questions and Opened, and names no field recording a step's status.
# The Context and Decisions sections (hold-shared-research-in-a-workstream)
# are asserted by workstreams-seeded-shape-sections-no-status.
# DERIVED (placement): the shape is the fenced example (design.md decision 8),
# each field a line of it beginning `**<label>**`.
# DERIVED (operationalisation of "no status field"): no line of the fenced
# shape carries `status`, `progress`, `in flight`, a `- [ ]`/`- [x]`
# checkbox, or a `done:` marker. A status field worded otherwise is not
# reached; verified by reading.
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

shape="$TESTDIR/shape.txt"
awk '/^[[:space:]]*(```|~~~)/ { infence = !infence; next } infence { print }' "$r" > "$shape"
if [ ! -s "$shape" ]; then
  echo "FAIL: the seeded register carries no fenced workstream shape; the field scans would assert nothing" >&2
  exit 1
fi

for label in "Goal" "Done when" "Steps" "Not in scope" "Open questions" "Opened"; do
  if ! grep -q -F -- "**$label**" "$shape"; then
    echo "FAIL: the seeded workstream shape does not name **$label**" >&2
    exit 1
  fi
done

if grep -n -i -E 'status|progress|in flight|- \[[ xX]\]|(^|[^a-z])done:' "$shape" >&2; then
  echo "FAIL: the seeded workstream shape names a field recording a step's status" >&2
  exit 1
fi
