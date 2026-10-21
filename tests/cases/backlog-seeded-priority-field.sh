#!/usr/bin/env bash
# Scenario: The seeded entry shape carries the structured fields — the field
# add-a-backlog-priority adds.
# Change: add-a-backlog-priority (project-bootstrap, MODIFIED).
#
# SPECIFIED: the seeded entry shape names Priority. (Kind, Waits on, Design
# with, Recorded by, Re-checked and the absence of Depends on stay asserted by
# backlog-seeded-structured-fields.sh.)
# DERIVED (placement, design.md decision 5): the entry shape is the fenced
# example, Priority is a line of it beginning `**Priority**`, and it comes
# before the `**Kind**` line ("between the description and **Kind**").
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

# Line numbers of the fenced **Priority** and **Kind** lines.
fenced_line() {
  awk -v label="$2" '
    /^[[:space:]]*(```|~~~)/ { infence = !infence; next }
    infence && index($0, "**" label "**") == 1 { print NR; exit }
  ' "$1"
}

p="$(fenced_line "$backlog" Priority)"
k="$(fenced_line "$backlog" Kind)"
if [ -z "$p" ]; then
  echo "FAIL: the seeded entry shape does not name Priority" >&2
  exit 1
fi
if [ -z "$k" ]; then
  echo "FAIL: the seeded entry shape carries no **Kind** line to order Priority against" >&2
  exit 1
fi
if [ "$p" -ge "$k" ]; then
  echo "FAIL: Priority (line $p) does not precede Kind (line $k) in the entry shape" >&2
  exit 1
fi
