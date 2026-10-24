#!/usr/bin/env bash
# Scenario: The seeded entry shape carries the structured fields — the field
# add-workstreams adds. Requirement: A backlog is seeded where none exists.
# Change: add-workstreams (project-bootstrap, MODIFIED).
#
# SPECIFIED: the seeded entry shape names Workstream. (Priority, Kind, Waits
# on, Design with, Recorded by, Re-checked and the absence of Depends on stay
# asserted by backlog-seeded-structured-fields.sh and
# backlog-seeded-priority-field.sh.)
# DERIVED (placement): the entry shape is the fenced example; Workstream is a
# line of it beginning `**Workstream**`, after the `**Design with**` line
# (design.md decision 9) and before the `**Recorded by**` line (the
# requirement's listing order).
#
# Executes the tool; no fixture owed. Red until the field lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
bash "$PROJECT_INIT" >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"

backlog="$work/docs/backlog.md"
assert_file "$backlog" "the seeded file this case reads"

fenced_line() {
  awk -v label="$2" '
    /^[[:space:]]*(```|~~~)/ { infence = !infence; next }
    infence && index($0, "**" label "**") == 1 { print NR; exit }
  ' "$1"
}

w="$(fenced_line "$backlog" Workstream)"
d="$(fenced_line "$backlog" "Design with")"
rb="$(fenced_line "$backlog" "Recorded by")"
if [ -z "$w" ]; then
  echo "FAIL: the seeded entry shape does not name Workstream" >&2
  exit 1
fi
if [ -z "$d" ] || [ -z "$rb" ]; then
  echo "FAIL: the seeded entry shape carries no **Design with** or **Recorded by** line to place Workstream against" >&2
  exit 1
fi
if [ "$w" -le "$d" ] || [ "$w" -ge "$rb" ]; then
  echo "FAIL: Workstream (line $w) is not between Design with (line $d) and Recorded by (line $rb)" >&2
  exit 1
fi
