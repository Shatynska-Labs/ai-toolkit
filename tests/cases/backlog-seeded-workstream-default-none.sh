#!/usr/bin/env bash
# Scenario: Workstream's default is stated (as revised: the absent value is
# `none`).
# Requirement: A backlog is seeded where none exists.
# Change: list-the-entry-fields (project-bootstrap, MODIFIED).
#
# SPECIFIED: the entry shape states that an entry recorded by a change in a
# workstream takes that workstream unless it serves another goal, and that an
# entry without the field is `none`; and that the field's value is a
# workstream by name or `none`.
# DERIVED (wording, design.md decision 2, which gives the item's text): the
# statements are on the fenced Workstream line and carry "takes that
# workstream unless it serves another goal", "An entry without this field is
# `none`" and "by name". The line is found with or without a leading list
# marker; the layout is backlog-seeded-fields-are-a-list.sh's to assert.
#
# Executes the tool and reads its output (second situation). Red until task
# 1.1 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Local arrangement (test-plan.md, Missing shared arrangement): as in
# backlog-seeded-absent-values.sh, declared here because a test module never
# imports from another.
fenced_field() {
  awk -v label="$2" '
    /^[[:space:]]*(```|~~~)/ { infence = !infence; next }
    infence { l = $0; sub(/^- /, "", l); if (index(l, "**" label "**") == 1) { print; exit } }
  ' "$1"
}

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
bash "$PROJECT_INIT" >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"

backlog="$work/docs/backlog.md"
assert_file "$backlog" "the seeded file this case reads"

ws="$(fenced_field "$backlog" Workstream)"
if [ -z "$ws" ]; then
  echo "FAIL: the seeded entry shape carries no Workstream field" >&2
  exit 1
fi
# shellcheck disable=SC2016 # backticks are literal markdown, not expansions
for phrase in "takes that workstream unless it serves another goal" 'An entry without this field is `none`' "by name"; do
  if ! printf '%s\n' "$ws" | grep -q -F -- "$phrase"; then
    echo "FAIL: the Workstream definition does not state \"$phrase\"" >&2
    printf '%s\n' "$ws" >&2
    exit 1
  fi
done
