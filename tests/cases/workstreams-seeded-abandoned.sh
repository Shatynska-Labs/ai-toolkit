#!/usr/bin/env bash
# Scenario: An abandoned workstream is archived, not deleted.
# Requirement: A workstream register is seeded where none exists.
# Change: add-workstreams (project-bootstrap, ADDED).
#
# SPECIFIED: the file directs adding an Abandoned line with the date and the
# reason and moving the workstream to a dated file under `archive/`, after
# its unfinished steps and the entries naming it are dealt with.
# DERIVED (placement and wording, design.md decision 8): one paragraph (line)
# carries `**Abandoned**`, "date", "reason", "archive/" and "steps and
# entries".
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

line="$(grep -F '**Abandoned**' "$r" | head -n1)"
if [ -z "$line" ]; then
  echo "FAIL: the seeded register states no Abandoned line" >&2
  exit 1
fi
for phrase in "date" "reason" "archive/" "steps and entries"; do
  if ! printf '%s\n' "$line" | grep -q -F -- "$phrase"; then
    echo "FAIL: the abandonment direction does not carry \"$phrase\"" >&2
    printf '%s\n' "$line" >&2
    exit 1
  fi
done
