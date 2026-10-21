#!/usr/bin/env bash
# Scenario: A project without a backlog receives the seeded file — the
# statements add-a-backlog-priority's MODIFIED requirement revises or adds.
# Change: add-a-backlog-priority (project-bootstrap, MODIFIED "A backlog is
# seeded where none exists"). Statements the delta carries through unchanged
# stay asserted by backlog-seeded-new-project.sh and
# backlog-seeded-structured-statements.sh.
#
# SPECIFIED: the created file states that an entry states in its own fields
# how urgent it is (beside what it waits on and what it designs with); that
# when a change is archived the entries it unblocked, unparked or made stale
# are updated and their re-checked date set; and that a parked entry is not
# folded into another change before its condition holds.
#
# DERIVED (wording): each statement is asserted by a phrase from the seeded
# text in design.md decision 5 — `how urgent it is`, `unblocked, unparked or
# made stale`, `not folded into another change`. A rewording that keeps the
# statement but drops the phrase fails here.
# DERIVED (placement): urgency sits on the same line (paragraph) as `in its
# own fields`; the archive update and its Re-checked date are one line; the
# fold-in exclusion sits on the fenced **Priority** line of the entry shape.
#
# Executes the tool and reads its output, so no fixture is owed.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
bash "$PROJECT_INIT" >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"

backlog="$work/docs/backlog.md"
assert_file "$backlog" "the seeded file this case reads"

assert_contains "$backlog" "how urgent it is" \
  "order statement: an entry states how urgent it is in its own fields"
if ! grep -F 'how urgent it is' "$backlog" | grep -q -F 'in its own fields'; then
  echo "FAIL: urgency is not among what an entry states in its own fields (not on that line)" >&2
  grep -n -F 'in its own fields' "$backlog" >&2
  exit 1
fi

assert_contains "$backlog" "unblocked, unparked or made stale" \
  "archive-time update: entries unblocked, unparked or made stale are updated"
if ! grep -F 'unblocked, unparked or made stale' "$backlog" | grep -q 'Re-checked'; then
  echo "FAIL: the archive-time update naming unparked entries does not set the Re-checked date in the same statement" >&2
  exit 1
fi

# The **Priority** line of the fenced entry shape (design.md decision 5).
priority="$(awk '/^[[:space:]]*(```|~~~)/ { infence = !infence; next } infence && /^\*\*Priority\*\*/ { print }' "$backlog")"
if [ -z "$priority" ]; then
  echo "FAIL: the seeded entry shape carries no **Priority** line" >&2
  exit 1
fi
if ! printf '%s\n' "$priority" | grep -q -F 'not folded into another change'; then
  echo "FAIL: the Priority definition does not state that a parked entry is not folded into another change" >&2
  printf '%s\n' "$priority" >&2
  exit 1
fi
