#!/usr/bin/env bash
# Scenario: Workstream's default is stated.
# Requirement: A backlog is seeded where none exists.
# Change: add-workstreams (project-bootstrap, MODIFIED).
#
# SPECIFIED: the entry shape states that an entry recorded by a change in a
# workstream takes that workstream unless it serves another goal, and that an
# entry without the field is `nothing`; and that the field's value is a
# workstream by name or `nothing`.
# DERIVED (placement and wording, design.md decision 9): the statements sit
# on the fenced `**Workstream**` line, carrying "takes that workstream unless
# it serves another goal", "An entry without this field is `nothing`" and
# "by name".
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

ws="$(awk '/^[[:space:]]*(```|~~~)/ { infence = !infence; next } infence && /^\*\*Workstream\*\*/ { print }' "$backlog")"
if [ -z "$ws" ]; then
  echo "FAIL: the seeded entry shape carries no **Workstream** line" >&2
  exit 1
fi
# shellcheck disable=SC2016 # backticks are literal markdown, not expansions
for phrase in "takes that workstream unless it serves another goal" 'An entry without this field is `nothing`' "by name"; do
  if ! printf '%s\n' "$ws" | grep -q -F -- "$phrase"; then
    echo "FAIL: the Workstream definition does not state \"$phrase\"" >&2
    printf '%s\n' "$ws" >&2
    exit 1
  fi
done
