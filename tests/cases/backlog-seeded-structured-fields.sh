#!/usr/bin/env bash
# Scenario: The seeded entry shape carries the structured fields.
# Change: add-backlog-skill (project-bootstrap, MODIFIED).
#
# SPECIFIED: the seeded entry shape names Kind, Waits on, Design with,
# Recorded by and Re-checked, and does not name Depends on.
# SPECIFIED (requirement text, not the scenario): the "should precede"
# direction is dropped; asserted as `precede` appearing nowhere in the file.
# DERIVED (placement): the entry shape is the fenced example (design.md
# decision 2), so the five labels are read from inside a fence. `Depends on`
# and `precede` are read from the whole file.
#
# Executes the tool; no fixture owed.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
bash "$PROJECT_INIT" >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"

backlog="$work/docs/backlog.md"
assert_file "$backlog" "the seeded file this case reads"

shape="$TESTDIR/shape.txt"
awk '/^[[:space:]]*(```|~~~)/ { infence = !infence; next } infence { print }' "$backlog" > "$shape"
if [ ! -s "$shape" ]; then
  echo "FAIL: the seeded file carries no fenced entry shape; the field scan would assert nothing" >&2
  exit 1
fi

for label in "Kind" "Waits on" "Design with" "Recorded by" "Re-checked"; do
  if ! grep -q -- "$label" "$shape"; then
    echo "FAIL: the seeded entry shape does not name $label" >&2
    exit 1
  fi
done

if grep -n -i 'depends on' "$backlog" >&2; then
  echo "FAIL: the seeded file still names Depends on, which Waits on replaces" >&2
  exit 1
fi
if grep -n -i 'precede' "$backlog" >&2; then
  echo "FAIL: the seeded file still states what an entry should precede; that direction is dropped" >&2
  exit 1
fi
