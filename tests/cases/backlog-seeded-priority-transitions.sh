#!/usr/bin/env bash
# Scenario: The seeded file states how an entry leaves parked and high.
# Change: add-a-backlog-priority (project-bootstrap, MODIFIED).
#
# SPECIFIED: the file directs a parked entry whose condition holds to
# `normal`, or to `high` with evidence; directs a `high` entry whose evidence
# no longer holds to `normal`; and names unparked entries among those the
# archive updates.
# DERIVED (placement and wording): the transitions are on the fenced
# **Priority** line and asserted by phrases from design.md decision 5 — `When
# the condition holds the entry becomes `normal``, `` `high` with evidence``,
# `evidence no longer holds it becomes `normal``; the archive statement is the
# line carrying `made stale` and `Re-checked`, and must name `unparked`.
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
for phrase in 'When the condition holds the entry becomes `normal`' \
  '`high` with evidence' \
  'evidence no longer holds it becomes `normal`'; do
  if ! printf '%s\n' "$priority" | grep -q -F -- "$phrase"; then
    echo "FAIL: the Priority definition does not state: $phrase" >&2
    printf '%s\n' "$priority" >&2
    exit 1
  fi
done

# The archive statement: the line naming the entries an
# archived change made stale and setting Re-checked.
archive="$(grep -F 'made stale' "$backlog" | grep -F 'Re-checked')"
if [ -z "$archive" ]; then
  echo "FAIL: the seeded file carries no archive statement setting Re-checked; nothing to check for unparked" >&2
  exit 1
fi
if ! printf '%s\n' "$archive" | grep -q -F 'unparked'; then
  echo "FAIL: the archive statement does not name unparked entries among those it updates" >&2
  printf '%s\n' "$archive" >&2
  exit 1
fi
