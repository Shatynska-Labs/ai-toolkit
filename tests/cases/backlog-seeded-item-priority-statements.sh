#!/usr/bin/env bash
# Scenario: A project without a backlog receives the seeded file — the
# statements add-a-backlog-priority revised or added, one of which sits on the
# Priority field.
# Requirement: A backlog is seeded where none exists.
# Change: list-the-entry-fields (project-bootstrap, MODIFIED).
# Carries: backlog-seeded-priority-statements.sh (add-a-backlog-priority).
#
# SPECIFIED: the created file states that an entry states in its own fields
# how urgent it is; that when a change is archived the entries it unblocked,
# unparked or made stale are updated and their re-checked date set; and that
# a parked entry is not folded into another change before its condition
# holds.
# DERIVED (wording and placement): `how urgent it is` on the line carrying
# `in its own fields`; `unblocked, unparked or made stale` on a line carrying
# `Re-checked`; `not folded into another change` on the fenced Priority field.
#
# Replaces, for the list layout, the case named under "Carries" whose
# extraction (`^\*\*<label>\*\*`) the layout supersedes; the assertions are
# that case's, unchanged. Executes the tool (second situation): green at
# authoring because the asserted content already exists and the reader accepts
# both layouts; it is the coverage that survives the obsolete case.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Local arrangement (test-plan.md, Missing shared arrangement): the first
# fenced line beginning `**<label>**` or `- **<label>**`, so the definition is
# read whichever layout the seeded file uses; the layout is
# backlog-seeded-fields-are-a-list.sh's to assert. tests/lib.sh's fenced_line is
# the near-miss: it returns a line number, not the line, and does not accept
# the list marker.
# The reader must find a field in either layout, or this case could only ever
# pass on the layout this change retires.
spec="$TESTDIR/specimen.md"
printf '%s\n' '```' '- **Priority**: listed' '```' '```' '**Kind**: paragraph' '```' > "$spec"
if [ "$(fenced_field "$spec" Priority)" != "- **Priority**: listed" ] || [ "$(fenced_field "$spec" Kind)" != "**Kind**: paragraph" ]; then
  echo "FAIL: discriminator — fenced_field does not read a field in both layouts" >&2
  exit 1
fi

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
  exit 1
fi

assert_contains "$backlog" "unblocked, unparked or made stale" \
  "archive-time update: entries unblocked, unparked or made stale are updated"
if ! grep -F 'unblocked, unparked or made stale' "$backlog" | grep -q 'Re-checked'; then
  echo "FAIL: the archive-time update naming unparked entries does not set the Re-checked date in the same statement" >&2
  exit 1
fi

priority="$(fenced_field "$backlog" Priority)"
if [ -z "$priority" ]; then
  echo "FAIL: the seeded entry shape carries no Priority field" >&2
  exit 1
fi
if ! printf '%s\n' "$priority" | grep -q -F 'not folded into another change'; then
  echo "FAIL: the Priority definition does not state that a parked entry is not folded into another change" >&2
  printf '%s\n' "$priority" >&2
  exit 1
fi
