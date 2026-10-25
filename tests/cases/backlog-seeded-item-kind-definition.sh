#!/usr/bin/env bash
# Scenario: A fix is distinguished from a change by what it owes.
# Requirement: A backlog is seeded where none exists.
# Change: list-the-entry-fields (project-bootstrap, MODIFIED).
# Carries: backlog-seeded-kind-definition.sh (add-backlog-skill).
#
# SPECIFIED: the file defines Kind as `fix` or `change` with the reason, and
# states `fix` as owing no specification delta, needing no decision, and
# fitting one review sitting — so an entry owing a delta can only be a change.
# DERIVED (placement and wording): the definition is the fenced Kind field,
# and each condition is asserted by a phrase from that text:
# `no specification delta`, `no decision`, `one review sitting`.
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

kind="$(fenced_field "$backlog" Kind)"
if [ -z "$kind" ]; then
  echo "FAIL: the seeded entry shape carries no Kind field" >&2
  exit 1
fi

# shellcheck disable=SC2016 # backticks are literal markdown in the phrases
for phrase in '`fix`' '`change`' 'no specification delta' 'no decision' 'one review sitting'; do
  if ! printf '%s\n' "$kind" | grep -q -F -- "$phrase"; then
    echo "FAIL: the Kind definition does not state: $phrase" >&2
    printf '%s\n' "$kind" >&2
    exit 1
  fi
done
