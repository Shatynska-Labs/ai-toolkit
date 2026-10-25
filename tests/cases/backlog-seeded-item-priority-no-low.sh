#!/usr/bin/env bash
# Scenario: The seeded file offers no low priority.
# Requirement: A backlog is seeded where none exists.
# Change: list-the-entry-fields (project-bootstrap, MODIFIED).
# Carries: backlog-seeded-priority-no-low.sh (add-a-backlog-priority).
#
# SPECIFIED: the file offers no `low` value.
# DERIVED (operationalisation): the values the file offers are those on the
# fenced Priority field; that field must exist (a vacuity guard) and must not
# contain the word `low`. Only that field is scanned: a sentence elsewhere
# saying there is no `low` offers none and must not fail.
#
# Not asserted: "so the entry is either parked with a condition or not
# recorded" — conduct.
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
  echo "FAIL: the seeded entry shape carries no Priority field; there is nothing to check for a low value" >&2
  exit 1
fi

low_re='(^|[^a-z])low([^a-z]|$)'
# Discriminator for the regex: it must catch a low value and must not catch
# words merely containing the letters (below, follow, allow, lower).
# shellcheck disable=SC2016 # backticks are literal markdown in the specimen
printf '%s\n' '- **Priority**: `high`, `normal` or `Low`.' | grep -i -E -q "$low_re" \
  || { echo "FAIL: discriminator — the low-value scan misses a line offering Low" >&2; exit 1; }
if printf '%s\n' 'Follow below; allow a lower bar.' | grep -i -E -q "$low_re"; then
  echo "FAIL: discriminator — the low-value scan fires on words merely containing low" >&2
  exit 1
fi

if printf '%s\n' "$priority" | grep -i -E -q "$low_re"; then
  echo "FAIL: the Priority definition offers a low value" >&2
  printf '%s\n' "$priority" >&2
  exit 1
fi
