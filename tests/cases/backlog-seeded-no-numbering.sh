#!/usr/bin/env bash
# Scenario: The seeded file carries no numbering. Change: seed-the-backlog.
#
# SPECIFIED: no heading in the seeded file begins with a number.
# DERIVED (operationalisation): "no sentence refers to an entry's number" is
# checked as: the word `number` in any form (number, numbers, numbered,
# numbering) appears nowhere in the file, fenced example included. That is
# stricter than the scenario — a sentence using the word for something else
# would fail — and is recorded as derived in test-plan.md.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
bash "$PROJECT_INIT" >/dev/null 2>&1

backlog="$work/docs/backlog.md"
assert_file "$backlog" "the seeded file this case reads"

# Vacuity guard: a file with no heading at all would pass the heading scan.
if ! grep -q -E '^#' "$backlog"; then
  echo "FAIL: $backlog carries no heading; the numbering scan would assert nothing" >&2
  exit 1
fi

numbered="$(grep -n -E '^#+[[:space:]]*[`*_[(]*[0-9]' "$backlog")"
if [ -n "$numbered" ]; then
  echo "FAIL: a heading in the seeded backlog begins with a number" >&2
  echo "$numbered" >&2
  exit 1
fi

mentions="$(grep -n -i -E 'number' "$backlog")"
if [ -n "$mentions" ]; then
  echo "FAIL: the seeded backlog mentions numbers; it SHALL NOT mention entry numbers" >&2
  echo "$mentions" >&2
  exit 1
fi
