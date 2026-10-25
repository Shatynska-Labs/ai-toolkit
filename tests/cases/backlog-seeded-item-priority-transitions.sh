#!/usr/bin/env bash
# Scenario: The seeded file states how an entry leaves parked and high.
# Requirement: A backlog is seeded where none exists.
# Change: list-the-entry-fields (project-bootstrap, MODIFIED).
# Carries: backlog-seeded-priority-transitions.sh (add-a-backlog-priority).
#
# SPECIFIED: the file directs a parked entry whose condition holds to
# `normal`, or to `high` with evidence; directs a `high` entry whose evidence
# no longer holds to `normal`; and names unparked entries among those the
# archive updates.
# DERIVED (placement and wording): the transitions are on the fenced
# Priority field and asserted by phrases from add-a-backlog-priority's
# design.md decision 5; the archive statement is the line carrying
# `made stale` and `Re-checked`, and must name `unparked`.
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
# the near-miss: it returns a line number, not the line. Kept local:
# AGENTS.md records no shared test arrangement (test-plan.md).
fenced_field() {
  awk -v label="$2" '
    /^[[:space:]]*(```|~~~)/ { infence = !infence; next }
    infence { l = $0; sub(/^- /, "", l); if (index(l, "**" label "**") == 1) { print; exit } }
  ' "$1"
}

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

priority="$(fenced_field "$backlog" Priority)"
if [ -z "$priority" ]; then
  echo "FAIL: the seeded entry shape carries no Priority field" >&2
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
