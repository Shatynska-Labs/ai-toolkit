#!/usr/bin/env bash
# Scenario: A project without a backlog receives the seeded file (new-project
# mode). Change: seed-the-backlog.
#
# SPECIFIED: the file is created where `docs/` does not exist, the report
# states it was created, the file states each statement carried over from
# seed-the-backlog, and it contains no entry. The statement N labels below
# follow seed-the-backlog's order; the statements add-backlog-skill added or
# revised are asserted by backlog-seeded-structured-statements.sh.
#
# DERIVED (wording): the requirement fixes what the text states, not the
# text. Each statement is asserted by one stable phrase taken from the seeded
# text in design.md. A rewording that keeps a statement but drops its phrase
# fails here; that is a derived constraint, recorded in test-plan.md.
#
# DERIVED (token): `backlog: created` is the report line design.md fixes;
# the requirement says only that the report states the backlog was created.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status"
backlog="$work/docs/backlog.md"
assert_file "$backlog" "the backlog is created, with docs/ created for it"
assert_contains "$report" "backlog: created" "the report states the backlog was created"

# One phrase per listed statement, in the requirement's order.
assert_contains "$backlog" "not yet archived" \
  "statement 1: lists changes identified and not yet archived"
assert_contains "$backlog" "instead of being folded into the change that found it" \
  "statement 1: each recorded instead of being folded into the change that found it"
assert_contains "$backlog" "kebab-case" \
  "statement 2: an entry's heading is the change's kebab-case name"
assert_contains "$backlog" "the name its branch and change directory are expected to take" \
  "statement 2: the name its branch and change directory are expected to take"
assert_contains "$backlog" "may rename it if the work turns out different" \
  "statement 2: the name is not binding on the change that is opened"
assert_contains "$backlog" "only by that name" \
  "statement 2: an entry is referred to only by that name"
assert_contains "$backlog" "carries no meaning" \
  "statement 3: entry order carries no meaning"
assert_contains "$backlog" "when its change is archived" \
  "statement 4: deleted when its change is archived"
assert_contains "$backlog" "as a fix rather than a change" \
  "statement 4: deleted when the operator takes it as a fix rather than a change"
assert_contains "$backlog" "will not be made" \
  "statement 4: deleted when the operator decides the change will not be made"
assert_contains "$backlog" "when it has no entries" \
  "statement 5: the file is kept when it has no entries"
assert_contains "$backlog" "has not seen the work that found it" \
  "statement 6: the shape — what and why, for a session that has not seen the work"
assert_contains "$backlog" "Recorded by" \
  "statement 6: the shape — what recorded it"

# No entry: outside fenced blocks, no level-2-or-deeper heading exists. The
# example entry's heading sits inside a fence (design.md), so it is skipped.
# Vacuity guard: the fences must balance, or the scan's notion of "outside a
# fence" is meaningless and an unbalanced file would hide every heading.
fences="$(grep -c -E '^[[:space:]]*(```|~~~)' "$backlog")"
if [ $((fences % 2)) -ne 0 ]; then
  echo "FAIL: $backlog has unbalanced code fences ($fences); the no-entry scan cannot be read" >&2
  exit 1
fi
entries="$(awk '/^[[:space:]]*(```|~~~)/ { infence = !infence; next } !infence && /^##/ { print NR": "$0 }' "$backlog")"
if [ -n "$entries" ]; then
  echo "FAIL: the seeded backlog contains an entry; it SHALL contain none" >&2
  echo "$entries" >&2
  exit 1
fi
