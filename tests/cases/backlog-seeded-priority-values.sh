#!/usr/bin/env bash
# Scenario: Priority's values and default are stated.
# Change: add-a-backlog-priority (project-bootstrap, MODIFIED).
#
# SPECIFIED: the seeded entry shape states Priority's three values `high`,
# `normal` and `parked until`; that `high` needs evidence of harm happening
# now; that `parked` needs a condition that can be checked; and that an entry
# without the field is `normal`.
# DERIVED (placement and wording): the definition is the fenced **Priority**
# line (design.md decision 5), and each statement is asserted by a phrase from
# that text.
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

priority="$(awk '/^[[:space:]]*(```|~~~)/ { infence = !infence; next } infence && /^\*\*Priority\*\*/ { print }' "$backlog")"
if [ -z "$priority" ]; then
  echo "FAIL: the seeded entry shape carries no **Priority** line" >&2
  exit 1
fi

# shellcheck disable=SC2016 # backticks are literal markdown in the phrases
for phrase in '`high`' '`normal`' '`parked until`' \
  'evidence of harm happening now' \
  'a condition that can be checked' \
  'An entry without this field is `normal`'; do
  if ! printf '%s\n' "$priority" | grep -q -F -- "$phrase"; then
    echo "FAIL: the Priority definition does not state: $phrase" >&2
    printf '%s\n' "$priority" >&2
    exit 1
  fi
done
