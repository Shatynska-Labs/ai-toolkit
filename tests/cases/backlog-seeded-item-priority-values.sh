#!/usr/bin/env bash
# Scenario: Priority's values and default are stated.
# Requirement: A backlog is seeded where none exists.
# Change: list-the-entry-fields (project-bootstrap, MODIFIED).
# Carries: backlog-seeded-priority-values.sh (add-a-backlog-priority).
#
# SPECIFIED: the seeded entry shape states Priority's three values `high`,
# `normal` and `parked until`; that `high` needs evidence of harm happening
# now; that `parked` needs a condition that can be checked; and that an entry
# without the field is `normal`.
# DERIVED (placement and wording): the definition is the fenced Priority
# field, and each statement is asserted by a phrase from that text
# (add-a-backlog-priority design.md decision 5; this change's decision 2
# keeps each item's wording).
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
